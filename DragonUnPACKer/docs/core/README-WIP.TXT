Dragon UnPACKer v5.6.2 Beta                                 MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    16/07/2011
===============================================================================

  ** NOTE: This is a Work In Progress build (Alpha, Beta or Release Candidate),
           use it at your own risk. Might be unstable. You were warned! **

  Documentation files are not updated since last stable release (v5.6.1).
  
-------------------------------------------------------------------------------
Main program version and versions history:

Version 5.6.2.268
SVN Release 627 [Unreleased]

 + Added new macros to the create list feature:
   Available in both header & footer:
    $$FTOTNUMBYTES$$  Number of bytes in file (formatted with thousands seps)
    $$FTOTNUMFILES$$  Number of files in file (formatted with thousands seps)
   Available in variable:
    $$FSIZE$$         Size (formatted with thousands seps)
    $$FOFFSET$$       Offset (formatted with thousands seps)
   The formatting is using the regional settings of Windows.
   For example, for English (USA) the separator will be a comma "," but for
   French (France) it will be a space " ".
 * Changed the following 2 macros in create list feature to be usable also in
   the header (and not only in footer):
    $$TOTNUMBYTES$$   Number of bytes in file
    $$TOTNUMFILES$$   Number of files in file
 + Added Advanced option to accept 0 bytes entries from the Drivers plugins.
   When this option is checked the 0 bytes entries are not skipped. This is not
   recommended but it will work (extraction will create a 0 bytes file).
 + Added Basic option to display Data X & Y fields in the content list. Those
   fields are used internally by some plugins (and some formats). This is for
   debug purposes and will most likely be only useful to me. :p
 ! Fixed extraction in files of more than 2GB:
   The content of entries which offset was after the 2GB position was wrong...
 ! Fixed drag & drop extraction of files.
 ! Fixed bug #3361911: OggS & TGA were not working correctly due to the use of
   seek from current position (broken in TBufferedFS).
 ! Changed all .Seek() calls to int64 compatible calls (or Position equivalent).
 * Added new main icons for 128x128 and 256x256 (16x16 and 32x32 stays the same)
   based on Iconshock design of Twitter treasure chest:
     http://www.iconshock.com
 * Duppi v3.3.5:
   * Added new main icons for 64x64, 128x128 and 256x256.
     Based on Oxygen Team's Apps system software update icon.
	 Old resolutions 16x16 and 32x32 stays the same. :p
 + External Tools Convertion plugin v0.1.0 Beta:
   i This plugin allows to use external command line tools to convert file
     formats (for example the excellent vgmstream tool for audio files).
	 This first version works fine but is only configured for vgmstream and to
	 trigger on .smp files of Ghostbusters.
	 Configuration is completely done in the .INI file:
	 data\convert\cnv_exttools.ini
	 You will also need a working test.exe file from vgmstream in the following
	 folder (along with needed dlls):
     data\convert\tools\vgmstream


Beta Developement Page:
-----------------------

This page allow you to follow the developement log of Dragon UnPACKer 5 between
Beta releases. You can also find other informations and maybe some downloads.
     
http://www.elberethzone.net/en/dup-devlog.html

===============================================================================