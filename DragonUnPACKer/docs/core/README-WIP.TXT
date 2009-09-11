Dragon UnPACKer v5.5.1 Beta                                 MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    11/09/2009
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

Version 5.5.1.226
Beta [Unreleased]

 - Removed old Felix Riemann drv_mix driver (for which no source is available).
 ! Fixed opening message bug in logs (%f).
 ! Fixed small log bug (invertion of variable texts when logging a successful
   opening).
 ! Fixed memory amount retrieval in Error box when more than 2GB of RAM in the
   system.
 * Changed application title to include version and currently open file.
 + Added Windows Vista/7 taskbar progress indicator when Aero is enabled.
 * HyperRipper v5.6 Beta 2:
   ! Fixed BMFind broken in last version (could not find any WAV or AVI for ex)
   * Speed-up (same or slightly faster than plugin version now).
   + Added Windows Vista/7 Taskbar Progress support.
   + Added Exclude False positive option (checked by default).
     This prevent selecting file formats that will most probably retrieve tons
	 of False positives (669, IT & FLIC which are very old file formats which
	 are never used nowadays).
   + Added Auto-Start scanning option (in advanced options).
     If you use this with the option to auto use HyperRipper when file format
	 is unknown, scanning will start automatically in those cases.
   + Added Auto-Close when entries found (in advanced options).
     HyperRipper will auto close when scanning is finished and entries where
	 found.
   + Added Force buffer size option (in advanced options).
     This can be used to force the size of the buffer from the standard 128k.
	 Although this is NOT recommended (big/low values can be/are slower) if
	 you want to try, feel free.
	 The only way to change the value is by directly editing the registry:
	 HKEY_CURRENT_USER\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper
	 DWORD key BufferSize
	 Smallest possible value is 32, largest is 32MB.
	 Rollback is fixed to 16 bytes.
 - Giants: Citizen Kabuto drv_giant .GZP plugin.
   Support is now in Elbereth's Main Driver.
 - Felix Riemann drv_mix .MIX plugin.
   Support is now in Elbereth's Main Driver.
 * Elbereth's Main Driver plugin v2.0.8:
   + Added Blade Runner .MIX support.
	 Added Command & Conquer .MIX support.
	 Added Command & Conquer: Red Alert .MIX support.
	 Only non-crypted files are supported, decryption code it still a no-go.
     Should work as Felix Riemann driver, but with detection of filenames based
	 on XCC-Util database.
   + Added Giant: Citizen Kabuto .GZP support.
     Merged from the now removed stand alone plugin.
 

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