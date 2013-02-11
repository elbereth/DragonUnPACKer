Dragon UnPACKer v5.7.0 Beta                                 MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    11/02/2013
===============================================================================

  ** NOTE: This is a Work In Progress build (Alpha, Beta or Release Candidate),
           use it at your own risk. Might be unstable. You were warned! **

  Documentation files are not updated since last stable release (v5.6.2).
  
-------------------------------------------------------------------------------
Main program version and versions history:

Version 5.7.0.270
SVN Release 635 [Unreleased]

 ! Added extra check in the extraction routine to avoid going past the end of
   file.
 ! Fixed many memory leaks (thanks to FastMM!).
 * Refactoring the TDrivers class to stop using pointers replaced by dynamic
   arrays. Will be easier to maintain and hopefully not slower.
   Also introduced DUDI v6 that uses a callback function everytime an entry
   needs to be added. This is completly different than DUDI v5.
   Both methods will be supported.
   Note 1: Current version of Dragon UnPACKerm might not work correctly as
           not everything was adapted with the new changes.
   Note 2: Only main driver was adapted to DUDI v6.
   Note 3: Directory cache is not implemented in this version so full entries
           scan is needed everytime you click on a folder. Cache should be
		   less needed than in previous method (due to indexing on integer
		   value of the folder) but I would like to add it anyway.
 + Added FastCode & FastMove.
   http://fastcode.sourceforge.net/
 i HyperRipper v5.6a:
   ! Fixed the sanity check on the BIK searching algorithm.
     Should avoid some false-positives.
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
     http://hcs64.com/vgmstream.html

Beta Developement Page:
-----------------------

This page allow you to follow the developement log of Dragon UnPACKer 5 between
Beta releases. You can also find other informations and maybe some downloads.
     
http://www.elberethzone.net/en/dup-devlog.html

===============================================================================