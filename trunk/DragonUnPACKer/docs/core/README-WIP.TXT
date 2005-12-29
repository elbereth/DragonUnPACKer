Dragon UnPACKer v5.1.2 WIP                                  MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    27/03/2005
===============================================================================

  ** NOTE: This is a Work In Progress build, use it at your own risk. Might
           be unstable. You are warned! **

  Documentation file are not updated since last stable release (v5.0.0).
  
  New features in v5.1 (CVS branch dev-5-1) :
  - Ability to use priority for Drivers plugins.
    What is that for ?
    Well, basically for expert users this allows to prefer one driver over
    another one when trying to open files.
    For example:
    If you want drv_mix to try opening a file before drv_default you will give
    drv_mix a priority higher than for drv_default.
    Maximum priority: 200
    Minimum priority:   0
  - New error dialog box. I hope this will allow for better bug reports.
    (Not used everywhere, but should show in most situations)
  - Add a log to the UI to know what is going on.
    You can hide this new log thingy (hint: right click or in the options).
  - New convert and driver plugin system (respectively DUCI v3 and DUDI v4).
    They now have TStream functions to export and convert data.
    This allow for direct (without using temporary file, therefore faster)
    convertion.
  - New HiperRipper v5.0c and HR plugin system (DUHI v3) to support very big
    files (more than 2GB).
  
  To Do until v5.2 stable release :
  - Convert (if possible) all others drivers plugin to DUDI v4.

-------------------------------------------------------------------------------
Main program version and versions history:

Version 5.2.0.165
Release Candidate 1 [15/12/2005]

 ! Fixed HyperRipper about button in the options for DUHI v3 plugins.
 ! Fixed Error log details. Some text were not showing up correctly...
 * Polished the log display when opening a file.
 * UT Packages driver plugin is now v2.3.0 (DUDI v4):
   * Now using TUTPackages v2.3-cvs (09/05/2004)
     This is certainly the last version ever from Antonio Cordero.
     Modified it a bit to support extraction to a stream.     
   + Added Game Hint structure. This is needed for better game support by the
     library. For every new file you open it will popup asking from which game
     is the file. Just select the game in the drop down list.
     If the game is not in the list, it will most probably be not supported
     correctly.
 * ZIP driver plugin is now v1.1.0 (DUDI v4):
   i Now using UnZip.pas from Gerke Preussner <j3rky@gerke-preussner.de>
     InfoZIP UnZip for Delphi Wrapper (http://www.gerke-preussner.de)
   * Now using UnZip32.Dll (InfoZip) v5.5.2.
   i This version of the plugin is extracting the whole entry to memory and
     then writes it into a file. If needed I might add an option to go direct
     to disk when file is more than a certain size.
     

Version 5.1.2.163 WIP
Release [21/03/2005]

 * Tons of stuff I cannot remember...
 * Linked new TStream I/O between convert and driver plugin.
 * Log is even more used in this version.
   Removed wordwrap for the Richtext log component.
 + Added a new log options tab (in the Options obviously)
 ! Fixed bug #1118661: Very Big Files failure
   This fix require the use of the new HyperRipper v5.0c (included in v5.1.2 WIP
   of Dragon UnPACKer) and HyperRipper plugin v5.0.2 (included too).
 ! Fixed bug #1066079: Caption "Drivers" cannot be translated
 * Convert plugin is now v2.0.1 Beta (DUCI v3):
   ! Fixed some more bugs
 * Main driver plugin is now v2.0.0 Beta 2 (DUDI v4):
   i Merged changes from v1.3.5 and 1.3.6
 * Duppi v2.0.3b:
   + Added support to retrieve version number for all 3 new plugins interfaces
     (DUCI v3, DUDI v4 and DUHI v3)
   ! Fixed bug #1066080: Caption: "InfoLab" while connecting to server


Version 5.1.1.149 WIP
Release [03/10/2004]

 + New drivers and convert plugin system using TStream as I/O.
   Those features aren't linked yet to the user interface, this version should
   behave as the last one.
   This should allow for quicker convertion and later for easy preview
   implementation.
 * Converted main convert plugin and main driver to the new system.
   * Convert plugin is now v2.0.0 Beta (DUCI v3):
     + New convert function that use TStream input and output.
     * Old convert function are now only wrappers to the new functions.
     ! Fixed some bugs (not sure they weren't introduced by the TStream system)
   * Main driver plugin is now v2.0.0 Beta 1 (DUDI v4):
     + New extraction function that use TStream as output.
     * All internal extraction functions were edited to use TStream. This might
       have broken something (from the quick tests I did that didn't broke
       anything).
     + Added progress display for a bunch of extraction functions.
 * Changed the log to a Rich text log.
   This allows colors and styles. Errors are now in red for example.
 * Added much more information when loading plugins.
   No more popups when errors are encountered, a red line is displayed in the
   log.
 * Added auto scroll to the Rich text log. Everytime a line is added the
   component scrolls down a line.
 

Version 5.1.0.144 WIP
Release [22/08/2004]

 i See start of file for new features in this version.
 * Duppi v2.0.3a:
   i Compiled for support of language files version 7.


Beta Developement Page:
-----------------------

This page allow you to follow the developement log of Dragon UnPACKer 5 between
Beta releases. You can also find other informations and maybe some downloads.
     
http://www.elberethzone.net/index.php?page=dup5dev

===============================================================================