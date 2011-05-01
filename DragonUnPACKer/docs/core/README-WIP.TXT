Dragon UnPACKer v5.6.2 Beta                                 MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    01/05/2011
===============================================================================

  ** NOTE: This is a Work In Progress build (Alpha, Beta or Release Candidate),
           use it at your own risk. Might be unstable. You were warned! **

  Documentation files are not updated since last stable release (v5.6.1).
  
-------------------------------------------------------------------------------
Main program version and versions history:

Version 5.6.2.265
SVN Release 617 [Unreleased]

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
 + External Tools Convertion plugin v0.0.2 Alpha:
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