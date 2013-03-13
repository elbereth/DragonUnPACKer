Dragon UnPACKer v5.7.0 Beta                                 MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    13/03/2013
===============================================================================

  ** NOTE: This is a Work In Progress build (Alpha, Beta or Release Candidate),
           use it at your own risk. Might be unstable. You were warned! **

  Documentation files are not updated since last stable release (v5.6.2).
  
-------------------------------------------------------------------------------
Main program version and versions history:

Version 5.7.0.273
SVN Release 647 [Unreleased]

 ! Added extra check in the extraction routine to avoid going past the end of
   file.
 ! Fixed many memory leaks (thanks to FastMM!).
 * Refactoring the TDrivers class to stop using pointers replaced by dynamic
   arrays. Will be easier to maintain and hopefully not slower.
   Also introduced DUDI v6 that uses a callback function everytime an entry
   needs to be added. This is completly different than DUDI v5.
   Both the old DUDI v1-v5 & v6 methods will be supported by Dragon UnPACKer
   5.7.0+.
   New directory cache should be as fast (if not faster) than the old one.
   Note: Only main driver was adapted to DUDI v6.
   ! SVN 646: Fixed files without directories not working in previous SVN 644.
 + Added FastCode & FastMove.
   http://fastcode.sourceforge.net/
 ! Fixed support for multiple convert plugins during preview.
 i HyperRipper v5.6a:
   ! Fixed the sanity check on the BIK searching algorithm.
     Should avoid some false-positives.
 * Duppi v3.4.0:
   i Updated to work with Indy 9 instead of Curl.
     This means a full Delphi implementation with no need for DLLs.
	 It is also compatible with Lazarus (Indy 9 & 10 were ported to Lazarus).
   i Now compiled with FastMM4, FastCode & FastMove.
 + External Tools Convertion plugin v0.2.0 Beta:
   i This plugin allows to use external command line tools to convert file
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
     To get to it, just click on Configure button in the Convert plugin options
	 screen of Dragon UnPACKer while cnv_exttools plugin is selected.

Beta Developement Page:
-----------------------

This page allow you to follow the developement log of Dragon UnPACKer 5 between
Beta releases. You can also find other informations and maybe some downloads.
     
http://www.elberethzone.net/en/dup-devlog.html

===============================================================================