
#include "ntddk.h"
#include "ntddstor.h"


typedef struct _INTTERUPT_STACK
{
ULONG InterruptReturnAddress;
ULONG SavedCS;
ULONG SavedFlags;
ULONG FunctionReturnAddress;
ULONG Arg;
}INTTERUPT_STACK;


typedef struct _HOOKED_FUNCTION_DESCRIPTOR
{
ULONG RealCode;
ULONG ProxyCode;
}HOOKED_FUNCTION_DESCRIPTOR;

extern NTSTATUS ObOpenObjectByPointer(IN PVOID Object, IN ULONG HandleAttributes,
									  IN PACCESS_STATE PassedAccessState OPTIONAL,
									  IN ACCESS_MASK DesiredAccess OPTIONAL,
									  IN POBJECT_TYPE ObjectType OPTIONAL,
									  IN KPROCESSOR_MODE AccessMode,OUT PHANDLE Handle);


extern NTSTATUS ZwQueryObject(IN HANDLE ObjectHandle OPTIONAL,
							  ULONG ObjectInformationClass,
							  OUT PVOID ObjectInformation,IN ULONG Length,OUT PULONG ResultLength);


typedef NTSTATUS (__stdcall*ProxyDispatch)(IN PDEVICE_OBJECT device,IN PIRP Irp);



ProxyDispatch realdispatcher;ULONG Int1RealHandler,BPXRealHandler,IdtsHooked;
UCHAR replacementbuff[64];ULONG idtbases[16]; KEVENT event;

HOOKED_FUNCTION_DESCRIPTOR HookedFunctionDescriptor;






NTSTATUS Dispatch(IN PDEVICE_OBJECT device,IN PIRP Irp)
{

NTSTATUS status=0; ULONG a=0;PSTORAGE_PROPERTY_QUERY query;
PSTORAGE_DEVICE_DESCRIPTOR descriptor;

PIO_STACK_LOCATION loc= IoGetCurrentIrpStackLocation(Irp);



if(loc->Parameters.DeviceIoControl.IoControlCode==IOCTL_STORAGE_QUERY_PROPERTY)
{

query=(PSTORAGE_PROPERTY_QUERY)Irp->AssociatedIrp.SystemBuffer;
if(query->PropertyId==StorageDeviceProperty)
{
	
descriptor=(PSTORAGE_DEVICE_DESCRIPTOR)Irp->AssociatedIrp.SystemBuffer;


status=realdispatcher(device,Irp);

descriptor->RemovableMedia=TRUE;


return status;
}

}


return realdispatcher(device,Irp);

}



//this function is needed in order to make our hooking work 
ULONG __stdcall INT1check(INTTERUPT_STACK * savedstack)
{

	ULONG offset=0,stepping=savedstack->SavedFlags&0x100;

	//if INT 1 has been raised for some reason other than single-stepping, return 0,
//so that execution will eventually go to the real handler of INT 1
	if(!stepping)return 0;

//check if single-stepping is somewhow related to our hooking. If not,return 0

if(savedstack->InterruptReturnAddress<=HookedFunctionDescriptor.ProxyCode || savedstack->InterruptReturnAddress>=HookedFunctionDescriptor.ProxyCode+8) return 0;


//change the return address on the stack, and clear TF flag
offset=savedstack->InterruptReturnAddress-HookedFunctionDescriptor.ProxyCode;
savedstack->InterruptReturnAddress=HookedFunctionDescriptor.RealCode+offset;
savedstack->SavedFlags &=0xfffffeff;

//clear DR6
_asm
{
mov eax,0
mov dr6,eax
}

return 1;
}





ULONG __stdcall BPXcheck(INTTERUPT_STACK * savedstack)
{ 
	PDRIVER_OBJECT driver;char buff[1024]; HANDLE handle=0;
	PUNICODE_STRING unistr=(PUNICODE_STRING)&buff[0];ULONG a=0;

//if breakpoint has nothing to do with our hooking,return 0
if(savedstack->InterruptReturnAddress!=HookedFunctionDescriptor.RealCode+1)return 0;

//make INT1 return to the code that we have copied, and set TF flag
savedstack->SavedFlags|=0x100;
savedstack->InterruptReturnAddress=HookedFunctionDescriptor.ProxyCode;

//All x86-related stuff has been done above. Now let's proceed to actual job


driver=(PDRIVER_OBJECT)savedstack->Arg;

if(ObOpenObjectByPointer(driver,0, NULL, 0,0,KernelMode,&handle))return 1;
ZwQueryObject(handle,1,buff,256,&a);
if(!unistr->Buffer){ZwClose(handle);return 1;}
if(_wcsicmp(unistr->Buffer,L"\\Driver\\USBSTOR")){ZwClose(handle);return 1;}

ZwClose(handle);

a=(ULONG)driver->MajorFunction[IRP_MJ_DEVICE_CONTROL];

if(a==(ULONG)Dispatch)return 1;

realdispatcher=(ProxyDispatch)a;
driver->MajorFunction[IRP_MJ_DEVICE_CONTROL]=Dispatch;
return 1;


}




_declspec(naked) INT1Proxy()
{

_asm	
{
pushfd
pushad
mov ebx,esp
add ebx,36
push ebx
call INT1check

cmp eax,0
je fin

popad
popfd
iretd

fin: popad
	 popfd
	 jmp Int1RealHandler
}


}


_declspec(naked) BPXProxy()
{

_asm	
{
pushfd
pushad
mov ebx,esp
add ebx,36
push ebx
call BPXcheck

cmp eax,0
je fin



popad
popfd
iretd

fin: popad
	 popfd
	 jmp BPXRealHandler



}


}




// this routine hooks and restores IDT. We have to make sure that this function runs only
//on one CPU, so that we disable interrupts throughout its execution in order to avoid context
// swithches
void HookIDT()
{

ULONG handler1,handler2,idtbase,tempidt,a;
UCHAR idtr[8];

//get the addresses that we have write to IDT

handler1=(ULONG)&replacementbuff[0];handler2=(ULONG)&replacementbuff[32];

//allocate temp. memory. This should be our first step - from the moment we disable interrupts
//till return we don't risk to call any code that has not been written by ourselves
// (theoretically this code may re-enable interrupts without our knowledge, and then.....)
tempidt=(ULONG)ExAllocatePool(NonPagedPool,2048);




_asm
{
cli

sidt idtr
lea ebx,idtr
mov eax,dword ptr[ebx+2]
mov idtbase,eax
}

//check whether our IDT has already been hooked. If yes, re-enable interrupts and return
for(a=0;a<IdtsHooked;a++)
{
	if(idtbases[a]==idtbase)
	{
		_asm sti
		ExFreePool((void*)tempidt);
		KeSetEvent(&event,0,0);
		PsTerminateSystemThread(0);

	}
}


_asm
{
//now we are going to load the copy of IDT into IDTR register
// in my experience, modifying memory,pointed to by IDTR register, is unsafe
mov edi,tempidt
mov esi,idtbase
mov ecx,2048
rep movs

lea ebx,idtr
mov eax,tempidt
mov dword ptr[ebx+2],eax
lidt idtr

//now we can safely modify IDT. Get ready
mov ecx,idtbase

//hook INT 1
add ecx,8
mov ebx,handler1

mov word ptr[ecx],bx
shr ebx,16
mov word ptr[ecx+6],bx

///hook INT 3
add ecx,16
mov ebx,handler2

mov word ptr[ecx],bx
shr ebx,16
mov word ptr[ecx+6],bx


//reload the original idt
lea ebx,idtr
mov eax,idtbase
mov dword ptr[ebx+2],eax
lidt idtr
sti
}

//now add the address of IDT we just hooked to the list of hooked IDTs
idtbases[IdtsHooked]=idtbase;
IdtsHooked++;
ExFreePool((void*)tempidt);
KeSetEvent(&event,0,0);
PsTerminateSystemThread(0);

}









NTSTATUS DriverEntry(IN PDRIVER_OBJECT driver,IN PUNICODE_STRING path)
{

ULONG a;PUCHAR pool=0; UCHAR idtr[8];HANDLE threadhandle=0;

 //fill the array with machine codes
replacementbuff[0]=255;replacementbuff[1]=37;
a=(long)&replacementbuff[6];
memmove(&replacementbuff[2],&a,4);
a=(long)&INT1Proxy;
memmove(&replacementbuff[6],&a,4);

replacementbuff[32]=255;replacementbuff[33]=37;
a=(long)&replacementbuff[38];
memmove(&replacementbuff[34],&a,4);
a=(long)&BPXProxy;
memmove(&replacementbuff[38],&a,4);






//save the original addresses of INT 1 handler

_asm
{
sidt idtr
lea ebx,idtr
mov ecx,dword ptr[ebx+2]

/////save INT1
add ecx,8
mov ebx,0
mov bx,word ptr[ecx+6]
shl ebx,16
mov bx,word ptr[ecx]
mov Int1RealHandler,ebx

/////save INT3
add ecx,16
mov ebx,0
mov bx,word ptr[ecx+6]
shl ebx,16
mov bx,word ptr[ecx]
mov BPXRealHandler,ebx
}


//hook INT 1 and INT 3 handlers - it has to be done before overwriting NDIS
//Run HookUnhookIDT() as a separate thread until all IDTs get hooked



KeInitializeEvent(&event,SynchronizationEvent,0);

RtlZeroMemory(&idtbases[0],64);
a=KeNumberProcessors[0];
while(1)
{
PsCreateSystemThread(&threadhandle,(ACCESS_MASK) 0L,0,0,0,(PKSTART_ROUTINE)HookIDT,0); 
KeWaitForSingleObject(&event,Executive,KernelMode,0,0);
if(IdtsHooked==a)break;
}

KeSetEvent(&event,0,0);


//fill the structure...
a=(ULONG)&IoCreateDevice;
HookedFunctionDescriptor.RealCode=a;
pool=ExAllocatePool(NonPagedPool,8);
memmove(pool,a,8);
HookedFunctionDescriptor.ProxyCode=(ULONG)pool;


//now let's proceed to overwriting memory


_asm

{
//remove protection before overwriting
mov eax,cr0
push eax
and eax,0xfffeffff
mov cr0,eax

//insert breakpoint (0xCC opcode)

mov ebx,a
mov al,0xcc

mov byte ptr[ebx],al


//restore protection
pop eax
mov cr0,eax

}



	  
return 0;
}




