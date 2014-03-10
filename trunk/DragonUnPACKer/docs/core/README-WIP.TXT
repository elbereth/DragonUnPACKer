Dragon UnPACKer v5.7.0 Beta                                 MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    10/03/2014
===============================================================================

  ** NOTE: This is a Work In Progress build (Alpha, Beta or Release Candidate),
           use it at your own risk. Might be unstable. You were warned! **

  Documentation files are not updated since last stable release (v5.6.2).
  
-------------------------------------------------------------------------------
Main program version and versions history:

Version 5.7.0.280
SVN Release 666 [Unreleased]

 ! Added extra check in the extraction routine to avoid going past the end of
   file.
 ! Fixed many memory leaks (thanks to FastMM!).
 ! Fixed create list feature (macros can be upper-case or lower-case).
 * Changed macros in the DUP4 HTML template (v1.2) for lists to upper-case
   anyway to be consistent.
 * Re-factoring the TDrivers class to stop using pointers replaced by dynamic
   arrays. Will be easier to maintain and hopefully not slower.
   Also introduced DUDI v6 that uses a callback function every time an entry
   needs to be added. This is completely different than DUDI v5 were the core
   program calls the plug-in function for all found entries.
   Both the old DUDI v1-v5 & v6 methods will be supported by Dragon UnPACKer
   5.7.0+.
   New directory cache should be as fast (if not faster) than the old one.
   Note: Only main driver was adapted to DUDI v6.
   ! SVN 646: Fixed files without directories not working in previous SVN 644.
   ! SVN 648: Fixed folder cache never cleared when closing files. This was
              resulting in duplicate files when loading HRF files for ex.
   ! SVN 649: Fixed DUDI v6 plugin internal extraction not working.
              Fixed exception when there was only 1 entry in the input file.
   ! SVN 652: Fixed search functions.
 + Added FastCode & FastMove.
   http://fastcode.sourceforge.net/
 ! Fixed support for multiple convert plug-ins during preview.
 * Re-factored how TDrivers & TPlugins were global variables, now properties
   of the main form. Both don't access directly main form components any more
   and go through a wrapper command class.
 * Completely revamped the logging features.
   This is still work in progress but is now used everywhere.
 i HyperRipper v5.6b:
   ! Fixed the sanity check on the BIK searching algorithm.
     Should avoid some false-positives.
   ! Fixed the memory leak for not freeing the TBufferedFS component:
     Switched back to using THandleStream instead of TBufferedFS.
	 Free THandleStream but keep handle open and pass it to TDrivers.
 + Revamped the old "Look" functionality to a much easier to maintain and
   modify "Theme" (files in a folder for the moment).
   Current SVN version is transitional and the new folder structure does not
   exists (which means the Nightly build will be icon less for the menu,
   po-pups and tool bar).
 * Elbereth's Main Driver plug-in v3.0.0:
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