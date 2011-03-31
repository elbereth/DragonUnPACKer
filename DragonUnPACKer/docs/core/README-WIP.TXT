Dragon UnPACKer v5.6.1 Beta                                 MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    31/03/2011
===============================================================================

  ** NOTE: This is a Work In Progress build (Alpha, Beta or Release Candidate),
           use it at your own risk. Might be unstable. You were warned! **

  Documentation files are not updated since last stable release (v5.6.0).
  
-------------------------------------------------------------------------------
Main program version and versions history:

Version 5.6.1.255
SVN Release 591 [Unreleased]

 i Now using FastMM v4.97 as memory manager. Only core for the moment.
 ! Fixed a lot of memory leaks (more to come). Thanks to FastMM debuging mode.
 ! Fixed the missing sort options in the file listing pane. Clicking on the
   header would do nothing.
 * Changed association icons to use 256x256 icons (much more appropriate for
   modern OSes than the old 32x32 one.
   The chest icons (closed & open) were made by Mohsen Fakharian, check his
   work here: http://mohsenfakharian.deviantart.com
   For the moment only the first icon is used, I will try to modify the
   association part so it can be choosen between both possibilities.
 * MAJOR speedup when lots of entries in the opened resource file:
     When left-clicking an entry for a preview
	 When right-clicking for popup menu
   I was doing some pretty dumb things which were slow as hell!!! 
 - Removed use of CxCpu (which was only used in Error handling popup).
   Unmaintained and not really useful anyway.
 * Auto-expand the folder list when loading a file.
   This can be turned off in the Basic Options.
 + The program now remembers which file type you had selected in the open dialog
   and will reselect it automatically unless the format list changed (ex: when
   updating the driver plugins).
   This can also be turned off in the Basic Options.
 + Added option to automatically clear the log everytime a file is opened.
 * The create file list now automatically adds the extension to the filename
   if it is missing.
 * Elbereth's Main Driver plugin v2.1.1:
   * Enhanced Bloodrayne .POD support by using buffered directory reading.
   + Added Ghostbusters: The Video Game .POD support (POD5).
     This is almost the same file format as Bloodrayne .POD (POD3).
   + Added Ghostbusters: Sanctum of Slime .PAK support.
     Includes decompression of entries (LZMA).
   * Changed how magic ID string is copied.


Beta Developement Page:
-----------------------

This page allow you to follow the developement log of Dragon UnPACKer 5 between
Beta releases. You can also find other informations and maybe some downloads.
     
http://www.elberethzone.net/en/dup-devlog.html

===============================================================================