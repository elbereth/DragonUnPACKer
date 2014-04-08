Dragon UnPACKer v5.7.0 Beta                                 MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    08/04/2014
===============================================================================

  ** NOTE: This is a Work In Progress build (Alpha, Beta or Release Candidate),
           use it at your own risk. Might be unstable. You were warned! **

  Documentation files are not updated since last stable release (v5.6.2).
  
-------------------------------------------------------------------------------
Main program version and versions history:

Version 5.7.0.284
Beta (SVN Release 694) [08/04/2014]

 i Updated licence to MPL 2.0 (from MPL 1.1).
 ! Added extra check in the extraction routine to avoid going past the end of
   file.
 ! Fixed many memory leaks (thanks to FastMM!).
 ! Fixed create list feature (macros can be upper-case or lower-case).
 * Changed macros in the DUP4 HTML template (v1.2) for lists to upper-case
   anyway to be consistent.
 * Re-factored the TDrivers class to stop using pointers replaced by dynamic
   arrays. Will be easier to maintain and less prone to errors.
   Also introduced DUDI v6 that uses a callback function every time an entry
   needs to be added. This is completely different than DUDI v5 were the core
   program calls the plug-in function for all found entries.
   Both the old DUDI v1-v5 & v6 methods are supported by Dragon UnPACKer
   5.7.0+.
   New directory cache should be as fast (if not faster) than the old one.
   Note: Only main & ZIP driver were adapted to DUDI v6.
 + Added FastCode & FastMove.
   http://fastcode.sourceforge.net/
 ! Fixed support for multiple convert plug-ins during preview.
 * Re-factored how TDrivers & TPlugins were global variables, now properties
   of the main form. Both don't access directly main form components any more
   and go through a wrapper command class.
 * Completely revamped the logging features.
   There might still be some places were it misbehaves.
 + Revamped the old "Look" functionality to a much easier to maintain and
   modify "Theme" (files in a folder for the moment).
   Not really nice with Delphi 7 but should pave the way to Lazarus.
 + Added chained conversion from plug-ins to internal Vampyre Imaging Library.
   This allows for the plug-ins to just convert to .DDS for example and the
   chaining will also propose BMP, PNG and TGA with no additional work from
   the plug-in.
 + Added direct internal Vampyre Imaging Library convertion of compatible
   files. For ex: .DDS to .BMP/.PNG/.TGA.
 ! Fixed the SetPercent callback function that was refreshing the component
   on every call, now it will refresh only if the value changed...
   This resulted in tremendous speed up for the loading of some formats, for
   ex: POD5 loading in previous version: ~17sec now: ~7sec.
 i HyperRipper v5.6b:
   ! Fixed the sanity check on the BIK searching algorithm.
     Should avoid some false-positives.
   ! Fixed the memory leak for not freeing the TBufferedFS component:
     Switched back to using THandleStream instead of TBufferedFS.
	 Free THandleStream but keep handle open and pass it to TDrivers.
 * Elbereth's ZIP Driver plug-in v2.0.0 Beta 1:
   * Updated to new DUDI v6. This means as of this version the plug-in
     requires Dragon UnPACKer v5.7.0 or more. It won't work with older Dragon
	 UnPACKer versions.
   * Changed to use Abbrevia instead of Info-Zip UnZip32.dll.
 * Elbereth's Main Driver plug-in v3.0.1 Beta 4:
   * Updated to new DUDI v6. This means as of this version the plug-in
     requires Dragon UnPACKer v5.7.0 or more. It won't work with older Dragon
	 UnPACKer versions.
   + Added support for Aliens vs. Predator (2010) .ASR file format.
     Actually support for both uncompressed & compressed Asura files.
	 Almost all files in the game use those formats (.EN/.GUI/etc..).
	 If you have smart format activated (which you should) it will load them
	 automatically.
	 Please note the compressed Asura files are slow to load & to extract from
	 but there is nothing I can do (the format is not foreseen for random read
	 access).
   + Added support for Star Wars Starfighter .PAK file format.
     Feature request #89 by James Krayenhagen.
   + Added support for The 7th Guest .GJD file format.
     (This never worked in drv_11th...)
   + Added support for The 11th Hour .GJD file format.
     (No activation needed)
   * Added sanity checks to Terminal Velocity .POD format.
 - Removed Elbereth's The 11th Hour Driver plug-in.
   Not needed anymore, features merged in drv_default v3.0.1 Beta 3.
 * Duppi v3.4.0:
   i Updated to work with Indy 9 instead of Curl.
     This means a full Delphi implementation with no need for DLLs.
	 It is also compatible with Lazarus (Indy 9 & 10 were ported to Lazarus).
   i Now compiled with FastMM4, FastCode & FastMove.
 + External Tools Conversion plug-in v0.2.1 Beta:
   i This plug-in allows to use external command line tools to convert file
     formats (for example the excellent vgmstream tool for audio files).
	 This first version works fine but is only configured for vgmstream and to
	 trigger on .smp files of Ghostbusters.
	 Configuration is completely done in .INI files (one for each tool):
	 data\convert\cnv_exttools\*.ini
	 data\convert\cnv_exttools\vgmstream.ini for ex.
	 You will also need a working test.exe file from vgmstream in the following
	 folder (along with needed dlls):
     data\convert\cnv_exttools\vgmstream
     http://hcs64.com/vgmstream.html
   i Edit or add new tools via the included configuration screen.
     To get to it, just click on Configure button in the Convert plug-in options
	 screen of Dragon UnPACKer while cnv_exttools plug-in is selected.
   ! Fixed EAccessViolation exception when the entry clicked in Dragon UnPACKer
     has no extension.
   ! Fixed exception when clicking on the close configuration box of the plug-in
     while an entry was selected.
 + Default Conversion plug-in v2.2.1:
   + Added Ghostbusters: The Video Game .TEX to .DDS
     Based on Ghostbusters texture converter C++ code by Jonathan Wilson
	 Published in 2010.
   i Thanks Paul (from spookcentral.tk/) for the idea and for the testing.

Beta Development Page:
-----------------------

This page allow you to follow the development log of Dragon UnPACKer 5 between
Beta releases. You can also find other informations and maybe some downloads.
     
http://www.elberethzone.net/en/dup-devlog.html

===============================================================================