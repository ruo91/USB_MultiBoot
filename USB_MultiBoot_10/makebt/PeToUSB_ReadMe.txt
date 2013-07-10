PeToUSB v3.0
============

Author	: Rich Burnham
Date	: 2005
WWW		: http://GoCoding.Com

Boot your BartPE/WinPE from a USB Flash Disk Drive!
Also supports USB HardDisks.

PeToUSB is a GUI Win32 application that will partition, format 
and makebootable to XP/W2K3 a USB Flash Disk (UFD). A lot of 
utilities that say they can do this, actually can't. 

PeToUSB does not make the device DOS bootable, it makes it 'XP' 
bootable (ie: the bootstrap code will look for NTLDR).

A lot of improvements have been made since version 2. Check
the change log for details. But in short its more compatible
with more devices, and easier to use with more functionality.

New Features/Changes:
o	Rewrites the MBR code just in case its corrupted.
	This option can be disabled if desired.
o	On Removable media, the partition is completely rewritten.
o	Backup/Restore MBR.
o	View disk information.
o	Assign drive letters.
o	Automatic notification of device arrival/removal.
o	Now supports WinPE builds as well.


To make a UFD bootable requires it to be formatted to FAT16, 
the partition set as bootable AND the volume boot sector id 
to be set to 0x80. If all this is done the UFD should be 
bootable on any system whose BIOS can boot to USB-HDD. Some 
UFDs partition tables have been set to a starting offset of
32 sectors, this will not be bootable under USB-HDD. It seems
that USB-ZIP requires this, USB-HDD requires offset of 63 
sectors.

If your UFD still won't boot after this type of format then 
either your UFD's chipset isn't capable or the BIOS on the 
system you are trying to boot is either set incorerectly or 
incapable of booting to UFD.

But PeToUSB does more than just make a UFD bootable. It will 
also copy all the required files from a successful BartPE build, 
to the UFD. The all that remains is for you to boot the stick 
on a system.

Instructions
------------
o	Build you BartPE/WinPE installation. No need to check the 
	'CD Record' box.

o	Insert your USB stick into the slot. 

o	BACK UP ANY DATA, BECAUSE WE ARE GOING TO FORMAT IT!

o	Use Tools/Backup MBR to make a backup of the disks MBR.
	(This can be restored later if things don't go as excpected)

o	Remove any security options on the UFD as this will mess
	up any booting process.

o	Extract PeToUSB.exe from it's zip archive and run it.

o	First we want to select the USB stick (Destination Drive).
	In the window check your USB stick has been recognised.
	There is a drop list containing all the detected removable
	disks. If you can't see it. Then click the 'Refresh' button.
	Make sure you select the drive that you want to use.
	
o	Next we want to get the path to our PE installation.
	Click the [...] button and choose the path. The 'OK' on
	the Browse Dialog will not display until you select 
	the correct folder.

o	Next we want to choose our options. For the first run we 
	need to choose:-
	o	Enable Disk Format
	o	Enable File Copy (if you are only wanting to format then 
							leave this)
	
o	Now we are ready to format the drive and copy the PE
	to the stick. Click 'Start' button and answer any 
	confirmation boxes.
	
o	Copying the files to a UFD takes a lot longer than to an
	IDE drive. So don't worry about it taking some time. Just
	watch the progress bar for an indication of how long it 
	will take.
	
o	After successfully completing the above operations. Your
	stick is now ready to be booted on the target system.

SOME NOTES ON DISKS
-------------------
PeToUSB will list fixed and removable disks. On the following 
conditions:-

It is LESS than 2GB. (It wont format FAT16 > 2Gb)
It is NOT the current system drive.
It is NOT the drive where PeToUSB is running from.

If it is a USB HardDisk (eg FixedMedia) then it must have its 
partitions already defined, as PeToUSB will not partition these 
devices due to possibilty of user losing their data when the 
partitions are altered. And the first paritition starting at 
Sector 63 and being less that 2Gb in size.

If it fails to format then check that the whole partition is
enclosed in the first 2Gb of the physical disk. The format
function will have problems if not.


SOME NOTES ON SETTING BIOS OPTIONS
----------------------------------
I'm no expert at compatablity of BIOSs with UFDs. But I have
learnt a few things...

o	In the BIOS boot sequence, set USB-HDD as the first boot 
	device.

o	Then make sure the 'Boot Other Devices' is disabled.

o	Save the BIOS settings. And power down.

o	Stick you UDF in the slot and powerup.

These notes relate to AWARD-BIOS. Other BIOS manufacturers will
have different but similar settings. You may need to experiment!


System Requirements
-------------------
PeToUSB will run on windows XP/2003/BartPE and most 2000Pros
It requires about 3Mb ram to run.
USB Disk Minimum Size of 256MB (dependant on size of PE build)


USB STICKS TESTED
=================
SanDisk Cruzer Mini		SUCCESSFUL
PenDrive 2.0 Mini		SUCCESSFUL
PQI iStick 2.0			SUCCESSFUL
I-Bead MP3 Player		FAILED		(I think the UFD initializes 
									 too slow for the BIOS)

DISCLAIMER
==========
This software and instruction is brought to you freely and in 
good faith. However the author or distributor of this program
cannot be held liable for any misuse/malfunction/failure which
causes damage to any system or hardware and cannot be held liable
for the cost implications thereof or of any consquence of such
misuse/malfunction/failure.

