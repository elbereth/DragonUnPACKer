Dragon UnPACKer v5.3.1 WIP                                  MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    10/03/2008
===============================================================================

  ** NOTE: This is a Work In Progress build, use it at your own risk. Might
           be unstable. You are warned! **

  Documentation files are not updated since last stable release (v5.2.0b).
  
  New features in v5.3 (CVS branch HEAD) :
  - HyperRipper v5.5: Much more reliable AND faster!
      Fixed buffer to 8KB and rollback to 128 bytes (should be optimal)
  
  To Do until v5.4 stable release :
  - Add previewing ability

-------------------------------------------------------------------------------
Main program version and versions history:

Version 5.3.1.174 WIP
Release [10/03/2008]

 * HyperRipper v5.5a:
   ! Fixed the threading bug (1686603), once and for all!
     This was due to bad threaded programming done by me (setting methods &
     properties of the main thread from the Execute procedure of a thread).
   i The good news (sort of) is that now I just thought of a multi-threaded
     search feature for the HyperRipper.
   ! Fixed responsiveness, it is now possible to cancel search.
 * Elbereth's Main Driver v2.0.1:
   + Added support for The Elder Scrolls 4: Oblivion .BSA files.
     Thanks to http://www.uesp.net/wiki/Tes4Mod:BSA_File_Format
     Please check there if you need to create this type of archives, there are
     free tools for that!
   + Added support for UFO: Aftermath, UFO: Aftershock and UFO: Afterlight .VFS
     files (which are all 3 the same format).
     Started research by using info on XentaX's Wiki:
     http://wiki.xentax.com/index.php?title=UFO_Aftershock
     But it took me the weekend to figure out missing parts!!
     Anyway, it works. ;) Check the sources for details on the file format.
 * Elbereth's HyperRipper 5.5 plugin v5.1.0 Beta 2
   ! Fixed MPEG Audio search not working in 5.1.0 Beta 1.
   * Improved MPEG Audio search speed (twice faster most of the time).
     Still slow on my computer but better than nothing. ;)
 i I hope to have improved stability of Dragon UnPACKer. It is now very stable
   and everything seems to be working as expected. For next WIP version I will
   focus on new features as this 5.3.1 was mainly bug fixing.
     

Version 5.3.0.173 WIP
Release [04/03/2008]

 i Long time without any versions, well here it is.
 * Updated all third party components to latests versions:
     Overbyte ICS v6 Beta 2007/11/14
     JCL v1.101.1.2725
     JVCL v3.33
     Virtual Treeview v4.5.2
 * HyperRipper v5.5:
   * Improved reliability with new DUDI v4 HyperRipper plugins.
     The new plugin formats introduce a much more reliable way to scan buffer!
     Should miss much less entries (or none at all!!).
   - Disabled Buffer and Rollback advanced options. Values are fixed to 8K and
     128bytes respectively. Those are the optimal values for the new plugin
     with Boyer-Moore search.
   + If a file is loaded in Dragon UnPACKer it is automatically closed once the
     Search button is pressed (this is to avoid the "Error reading file" when
     searching in the same file twice for example).
 * Elbereth's HyperRipper 5.5 plugin v5.1.0 Beta 1
   * Improved speed by using a Boyer-Moore search
     And now it is very FAST -> 450MB scanned for Ogg in less than 16 seconds!
   + Added support for DDS file format (Feature Request #1639688)
   ! Fixed bug #1428079 (missing bytes EOF on WAV files)
   ! Fixed bug #1729410 (extraction of mp3 subfiles creates incomplete files)
     Please note however that the search of MPEG Audio streams is very STRICT!
     That means if the embedded MP3 file has errors it might be cut in multiple
     files by the plugin. This is normal and cannot be avoided by the program.
     Just put the pieces together if needed.
 * Duppi v2.2.0:
   i Updated to work with new Overbyte's ICS v6 HTTP Client component name.
   * Added support for DUPP v3 which fixes the CRC calculation mistake that
     existed in previous versions. DUPP v2 files are still supported.


Beta Developement Page:
-----------------------

This page allow you to follow the developement log of Dragon UnPACKer 5 between
Beta releases. You can also find other informations and maybe some downloads.
     
http://www.elberethzone.net/index.php?page=dup5wip

===============================================================================