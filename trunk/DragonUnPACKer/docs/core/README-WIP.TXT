Dragon UnPACKer v5.6.3 Beta                                 MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    29/01/2013
===============================================================================

  ** NOTE: This is a Work In Progress build (Alpha, Beta or Release Candidate),
           use it at your own risk. Might be unstable. You were warned! **

  Documentation files are not updated since last stable release (v5.6.2).
  
-------------------------------------------------------------------------------
Main program version and versions history:

Version 5.6.3.269
SVN Release 634 [Unreleased]

 ! Added extra check in the extraction routine to avoid going past the end of
   file. Should fix bug 
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


Beta Developement Page:
-----------------------

This page allow you to follow the developement log of Dragon UnPACKer 5 between
Beta releases. You can also find other informations and maybe some downloads.
     
http://www.elberethzone.net/en/dup-devlog.html

===============================================================================