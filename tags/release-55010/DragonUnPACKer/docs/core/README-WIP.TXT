Dragon UnPACKer v5.5.0 Beta                                 MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    27/06/2009
===============================================================================

  ** NOTE: This is a Work In Progress build (Alpha, Beta or Release Candidate),
           use it at your own risk. Might be unstable. You were warned! **

  Documentation files are not updated since last stable release (v5.2.0b).
  
  Purpose of v5.5 (CVS branch HEAD):
  - Migrate to Lazarus/FreePascal platform instead of Borland Delphi 7.
  
  Done in this version:
  - drv_default can be compiled with Lazarus/FPC and run fine in Delphi built
    core.
  - Some non compatible components were replaced by compatible ones.
  - HyperRipper plugin was merged into the core.
  
  To Do until v5.6 stable release :
  - Migrate core application (DrgUnPACKer.exe).
  - Migrate convert plugin, create standalone configuration tool.
    Another solution would be to merge to the core.
  - Migrate driver plugins.
  - Migrate tools applications (Duppi, Dlngc, Dlngcomp, Dlookc, Dlookd,
    duhtcomp & Dpackc).
  
  Ideas for the future:
  - Add popup to select between different driver plugin when more than one
    declares being able to open the file
  - Add a certainty of ability to open a file
    Ex:   High if smart used with a very good ID/Magic string
        Medium if smart used with a weak ID/Magic string
           Low if smart was not used (only based on extension)        
  - "Create" plugins (do not integrate the creation to the drivers plugins.

-------------------------------------------------------------------------------
Main program version and versions history:

Version 5.5.0.218
Beta [27/06/2009]

 - Removed all use of JCL & JVCL. Replaced by:
    Personnal equivalent functions
    API calls
	Delphi VCL
 * Replacement for JVCL JvBrowseDialog, uses ShellApi (by Brian Cryer code with
   help of Martin Birk)
 * HyperRipper v5.6 Beta 1:
   - HyperRipper plugin support was removed, this was done with multiple goals
     in mind:
	   Easier to compile with Lazarus\FreePascal
	   Ability to do multi-threading in the future
   * The latest plugin version was merged with Dragon UnPACKer core to provide
     same functionnality as last HyperRipper + last HyperRipper plugin.
 i EXE file is 227KiB smaller than v5.4.0a. Not much but still not bad! :p


Beta Developement Page:
-----------------------

This page allow you to follow the developement log of Dragon UnPACKer 5 between
Beta releases. You can also find other informations and maybe some downloads.
     
http://www.elberethzone.net/lang-en/dup-devlog.html

===============================================================================