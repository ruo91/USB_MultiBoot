
Thank you for downloading MBRtool, the only tool that lets you do just about anything with the MBR.


Readme file accompanying MBRtool version 2.2.100, dated December 16th, 2003
When viewing this document using Notepad, be sure to enable Wordwrap.


Webpage : www.diydatarecovery.nl
Please contact us through the support forum. Detailed contact information can be found in the manual.


MBRtool is a very powerful tool that allows you to manipulate just about anything in/about the Master Boot Record.
As such it is very important to read the entire manual before you start experimenting with it.

I cannot stress this enough, READ THE ENTIRE MANUAL!

-----

What it does, a short description :

- backup, verify and restore the MBR, using backup-sectors or files
- backup, restore, wipe, clean or dump the track 0 for a disk
- edit or wipe the MBR Partition Table
- refresh the MBR bootcode, without destroying the Volume Bytes (also known as Admin Bytes)
- remove the MBR bootcode
- re-write the MBR signature bytes
- display the MBR sector or dump the MBR sector to file
- perform above mentioned edit, bootcode, display and dump functions on the MBR backups
- create a blank backup-file to create a MBR from scratch and restore it later
- perform attribute changes on partitions listed in the MBR Partition Table (hide, activate, delete etc.)
- manipulate the volume bytes that are associated with volumes in Windows NT / 2K / XP

MBRtool is a 16 bit DOS application and is best run from a dedicated DOS boot disk.
Do not run this program from a Command prompt in Windows NT / 2K / XP.

MBRtool is mainly aimed at powerusers or users that have a working knowledge of partitioning, harddisks and Master Boot Records.

-----

Version history :


- Current version : 2.2.100

Changes since version 2.1.100

- the /RBC parameter (refresh bootcode) is now Volume Byte aware. refreshing the bootcode will no longer overwrite the volume bytes, and thus leave the volume information contained in the MBR intact. please note that wiping the bootcode (/WBC) WILL remove the Volume Bytes, this is by design.
- manipulation of volume bytes has been adapted, only the 4 correct bytes can be erased or restored 
- bootcode is replaced with US english XP bootcode 
- minor cosmetic changes in some screens 

Changes since version 2.0.150:

- added the MBRtool menu, including the possibility to run commands from the menuprompt 
- added the dump track 0 function (/DT0) 
- added a Custom Geometry Value function to the Partition Table Editor 
- feedback on errors during restore / verify track0 improved 
- for /DSK:A, the requested action is only performed on actually existing disks. MBRtool now tests for disk existence before any action is performed 
- a backup count per disk is added to the /LST function 
- error checking has been changed, is now handled globally 
- maximum cylinder value in the Partition Table Editor is changed from 9999 to 99999 
- geometry values are added to Display and Dump output 
- Partition Table Editor has been changed to be a bit more friendly to work with 

Changes since version 2.0.100:

- minor cosmetic changes 
- commandline help screen is now displayed if the menu add-on is not found 

Changes since version 1.20:

- the commandline is revised, and is now easier to understand and use 
- more on-screen information has been added to several functions 
- the value entered in the partition table editor for Active Partition is now checked (must be 0 or 128) 
- /PTM has been improved, unknown partition types will be left alone 
- the MBR display function now uses 50 lines per screen, showing the entire MBR on 1 screen 
- saving and restoring of track 0 to file has been improved, it is now much faster 
- the saving and restoring of track 0 is now more reliable (the conditions and results are checked) 
- errordisplay for track 0 functions and MBR backup functions has been improved 
- fixed: problem in the Partition Table Editor when a non-existing backup from sector was requested 
- new function: clean track 0 
- new function: verify track 0 against a previously made backup 
- new function: delete a Partition Table Entry from the commandline 
- new function: added support for volume bytes (delete and restore) 
- new function: dump a MBR (backup or original) to file 
- added errorlevels for batch-file support 
- added a more elegant general-error exit routine 
- a new and more indicative version numbering system is introduced 

Changes since version 1.10:

- the version number. it seemed that version 1.01 and version 1.10 were the same to some software download sites 
- the support information has been changed 
- the manual has been updated and expanded 

Changes since version 1.01:

- major code overhaul 
- bug in backup to file for more than 1 disk fixed 
- check on maximum heads corrected 
- partition type is now displayed correctly in the editor (including the attribute) 
- partition attributes can now be changed from the commandline (/P parameter) 
- display MBR now includes the Partition Table in editor format 
- added corruption check to the backup files 
- added function to write a blank backup (/X:A) 
- added errorhandling for reading the backup files 
- changed the sequence of items in the partition table display and edit screens 
- added LBA calculations to the editor 
- added saving, restoring and wiping of track 0 
- added display of used disk geometry values for LBA calculations in the edit screen 
- added possibility to delete 1 entry in the edit screen 

Changes since version 1.00:

- LBA values when entered in the Partition Table editor are now checked. Due to a restraint in the compiler, i can not calculate Hex values larger than Dec 2,147,483,647 (well, actually i can but i haven't figured it out completely yet). This means for now that you can not enter values for LBA larger than this. The above mentioned value translates into a 1Tb harddisk size, so in practice this will hardly pose a problem. However, people with harddisks/hardware raid5 systems larger than 1Tb should NOT use the partition table editor that MBRtool provides. Backup and restore are safe.
- Version 1.00 of MBRtool simply crashed when a large value for LBA was encountered. Though not quite nice, it means that no changes to the MBR were made at runtime so no trouble there. 
- some minor cosmetic code changes 


-----


MBRtool is freeware.

Please enjoy.
