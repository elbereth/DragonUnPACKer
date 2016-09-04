Dragon UnPACKer v5.7.1 Beta                                 MPL 2.0 open source
by Alexande "Elbereth" Devilliers                                    02/09/2016
===============================================================================

  ** NOTE: This is a Work In Progress build (Alpha, Beta or Release Candidate),
           use it at your own risk. Might be unstable. You were warned! **

  Documentation files are not updated since last stable release (v5.6.2).
  
-------------------------------------------------------------------------------
Main program version and versions history:

Version 5.7.1.287
Git master [Unreleased]

 ! Fixed title of application when extracting for example.
 ! Fixed MPL 2.0 in installation readme files.
 i Switched sources to git VCS instead of SVN.
   Changed so that splash screen and about box displays Work In Progress for
   nighlies builds with git.
 ! Fixed the file types option screen was not showing all types.
 ! Fixed splash screen for new nightly builds with git.
 ! Fixed resource leak on Exception popup.
 + Added splash to preview pane when unused.
 ! Fixed extraction of sub-directories.
 ! Fixed unhandled error when selecting entries without extension.
 * HyperRipper v5.7:
   + Added search support for AAC in pure ADTS (Audio Data Transport Stream)
   + Added search support for MPEG-4 Audio files (MPEG TS)
   + Added search support for MPEG-4 Video files (MPEG TS)
   i For both MPEG-4 TS files, the moov atom is expected at the end.
   ! Fixed possible problems with MOV support (added sanity checks)
 * Elbereth's Main Driver plug-in v3.0.1 Beta 7:
   + Added support for Astebreed, Ether Vapor Remaster and Fairy Bloom Fresia
     .TGP file format.
     Actually support for both v1 and v2 TGP files.
	 Uncompressed, compressed and crypted are all supported.
   + Added support for Artifex Mundi .CUB file format
     Tested with all 3 Nightmare from the Deep games
   + Added support for Geometry Wars 3: Dimension Evolved .WAD file format.
     No filenames (not stored in file). Some deducted from files themselves.
   + Added support for The Secret of Monkey Island Special Edition .PAK file
     format.
	 .dxt files are converted to .DDS files on the fly.
   + Added support for Monkey Island 2 Special Edition .PAK file format.
	 .dxt files are decompressed and converted to .DDS files on the fly.
   + Added support for South Park: The Stick of Truth .OAF file format.
 + External Tools Conversion plug-in v0.2.2 Beta:
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
	 Also has ImageMagick ini file to convert images to PNG.
	 http://www.imagemagick.org/script/binary-releases.php
   i Edit or add new tools via the included configuration screen.
     To get to it, just click on Configure button in the Convert plug-in options
	 screen of Dragon UnPACKer while cnv_exttools plug-in is selected.
   ! Fixed EAccessViolation exception when the entry clicked in Dragon UnPACKer
     has no extension.
   ! Fixed exception when clicking on the close configuration box of the plug-in
     while an entry was selected.
	 

Version 5.7.0.284
Beta (SVN Release 695) [08/04/2014]

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
 + Default Conversion plug-in v2.2.1:
   + Added Ghostbusters: The Video Game .TEX to .DDS
     Based on Ghostbusters texture converter C++ code by Jonathan Wilson
	 Published in 2010.
   i Thanks Paul (from spookcentral.tk/) for the idea and for the testing.

Development Page:
-----------------

This page allow you to get absolute latest cuting edge binaries from Dragon
UnPACKer 5 development.
     
https://www.elberethzone.net/dragon-unpacker-dev.html

===============================================================================