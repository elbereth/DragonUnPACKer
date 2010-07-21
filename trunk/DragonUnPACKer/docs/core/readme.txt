Dragon UnPACKer v5.6.0 "Exedra"                             MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    21/07/2010
===============================================================================

  ** English Readme (voir lisezmoi.txt pour la version française)

  ** For information about what's new in this version see the whatsnew.txt file

  Index:
   1. Legal Stuff & Distribution Information
   2. Program Description
   3. Installation
   4. Needed to work
   5. How-to use this program
   6. HyperRipper
   7. Options
   8. Supported Formats
   9. Contacts
  10. Special Thanks
  

===============================================================================
 1. LEGAL STUFF & DISTRIBUTION INFORMATION
-------------------------------------------------------------------------------

 This program is open source under the Mozilla Public Licence 1.1 (see
LICENCE.txt for details).

 Quickly: - Completly free
          - Source code available (see http://www.dragonunpacker.com)

 Any public version (beta, release candidate or final) can be placed on any
media for distribution (ex: CD-Rom, FTP, HTTP, etc..). But all text files must
stay intact, and no files can be added to the zip file.

 This program have 2 differents types of releases (same content):
    SETUP - ~2.5MB - dup560exedra-setup.exe - With Install/Uninstall
       7Z - ~2.4MB - dup560exedra.7z        - Plain 7-Zip (v9.15 beta) archive

===============================================================================
 2. PROGRAM DESCRIPTION
-------------------------------------------------------------------------------

 This program allow you to see into the big files in games like Quake 2 (go
look in the baseq2 sub directory, see the big pak0.pak file, that's one) and
extract files to anywhere you want easily. It can also convert some weird
formats to common formats (like .ART Duke Nukem 3D files to Windows BitMaP .BMP
files).

 Version 5 brings modularity and a completly recoded program from scratch in
Delphi 6/7. This means much faster and better memory management than version 4.
 
 See the SUPPORTED FORMATS chapter to known which files are readable and which
file formats can be created/edited.


===============================================================================
 3. INSTALLATION
-------------------------------------------------------------------------------

 If you have downloaded the SETUP version then you already have installed
Dragon UnPACKer 5. ;)

 If not decompress the 7z archive in the directory of your choice. Then run
DrgUnPack5.exe and voila it is installed..

 Here is a list of files you must find in the Dragon UnPACKer distribution:
 (if not go to homepage and download it from there)

*drgunpack5.exe    	        3669 KB
 drgunpack5.exe.sig            1 KB  GPG Signature of drgunpack5.exe file
 file_id.diz       	           1 KB
 historique.txt    	          42 KB
 lisezmoi.txt      	          61 KB
 readme.txt        	          55 KB
 whatsnew.txt      	          36 KB
 
 data\
 default.dulk                 40 KB  Default Look
*english.lng                  10 KB  English translation of DUP5
 homepage.uht                 22 KB  Create list template "DUP4 Style"
*spanish.lng                  11 KB  Spanish translation of DUP5
 text-db.uht                   6 KB  Create list template "Text Database"
 xml-db.uht                    6 KB  Create list template "XML Database"

 data\convert\
 Blood.dpal                    1 KB  Blood color palette
 cnv_pictex.d5c              779 KB  Textures convert plugin (v2.1.1)
 Doom.dpal                     1 KB  Doom color palette
 Duke3D.dpal                   1 KB  Duke Nukem 3D color palette
 Quake 1.dpal                  1 KB  Quake color palette
 Quake 2.dpal                  1 KB  Quake 2 color palette
 Shadow Warrior.dpal           1 KB  Shadow Warrior color palette
 
 data\drivers\
 drv_11th.d5d                412 KB  11th Hour driver plugin (v1.0.0)
 drv_default.d5d             239 KB  Elbereth's Main driver plugin (v2.1.0)
 drv_ut.d5d                  669 KB  UT Packages driver plugin (v2.3.0)
 drv_zip.d5d                 103 KB  ZIP driver plugin (v1.1.2)
 unzip32.dll                 100 KB  Info-Zip's UnZip32.Dll v5.5.2
                                 
 data\hyperripper\               
 hr_default.d5h              626 KB  Elbereth's HyperRipper Plugin (v5.1.0)
                                 
 utils\                          
+duppi.exe                   798 KB  DUP5 Package installer (v3.3.3)
+DuppiInstall.exe             42 KB  Duppi Auto-Update Installer
+libcurl-3.dll               268 KB  Curl Library (no SSL) (v7.21.0)
+zlib1.dll                    80 KB  Zlib Library (v1.2.5)
 hrf_30_spec.txt               7 KB  HyperRipper file 3.0 specification

 utils\data\
+english.lng                   4 KB  Duppi English translation
+spanish.lng                   4 KB  Duppi Spanish translation

 utils\templates\
 duhtcomp.exe                116 KB  UHT file compiler
 duhtcomp.txt                  5 KB  UHT file compiler documentation
 ex-homepage.zip              23 KB  Sources of the homepage.uht template
 ex-text.zip                   8 KB  Sources of the text-db.uht template
 ex-xml.zip                    7 KB  Sources of the xml-db.uht template
 
 utils\translation\
 dlngc.exe                   124 KB  LNG file compiler
 dlngc.txt                     4 KB  LNG file compiler documentation
 english.ls                   19 KB  English translation sources (Core)
 english_duppi.ls              9 KB  English translation sources (Duppi)
 english-beta2-changes.txt     4 KB  Changes in english.ls 5.0.0 Beta 1 -> 2
 english-beta3-changes.txt     4 KB  Changes in english.ls 5.0.0 Beta 2 -> 3
 english-rc1-changes.txt       2 KB  Changes in english.ls 5.0.0 Beta 3 -> RC1
 english-rc2-changes.txt       2 KB  Changes in english.ls 5.0.0 RC1 -> RC2
 english-rc3-changes.txt       3 KB  Changes in english.ls 5.0.0 RC2 -> RC3
 english-520-changes.txt       4 KB  Changes in english.ls 5.0.0 -> 5.2.0
 english-532-changes.txt       3 KB  Changes in english.ls 5.2.0 -> 5.3.2 WIP
 english-533-changes.txt       2 KB  Changes in english.ls 5.3.2 -> 5.3.3 Beta
 english-540-changes.txt       7 KB  Changes in english.ls 5.3.3 Beta -> 5.4.0
 flag_fr.bmp                   1 KB  France flag icon
 flag_sp.bmp                   1 KB  Spain flag icon
 flag_us.bmp                   1 KB  USA flag icon
 french.ls                    20 KB  French translation sources (Core)
 french_duppi.ls              10 KB  French translation sources (Duppi)
 spanish.ls                   16 KB  Spanish translation sources (Core)
 spanish_duppi.ls              7 KB  Spanish translation sources (Duppi)
 translation.txt               2 KB  How to make a DUP5 translation

  * Needed files for DRGUNPACK5.EXE to work.
  + Needed files for DUPPI.EXE to work.


===============================================================================
 4. NEEDED TO WORK
-------------------------------------------------------------------------------

 You will need:

  * Windows 98/ME/NT/2000/XP/2003/Vista/2008/Seven.
    Tested under:
      Windows Seven Ultimate x64       (Hardware see below / UAC=Off)
	  Windows Seven Ultimate x86       (VM with 2x CPU and 2GB RAM / UAC=On)
	  Windows XP Professional x86 SP3  (VM with 2x CPU and 1GB RAM)
    Does not work under Windows 95.
  * The programs runs under Linux OS but by the mean of Wine and the display is
    slow as hell...
    The only way for a native Linux Dragon UnPACKer would be by using Lazarus
    and FreePascal compiler (this would also bring MacOS support I guess). But
    this is very difficult because not all libraries used by Dragon UnPACKer
    exists for FPC.

 Author's computer:

  * Antec Solo case
  * Seasonic S12-500 power supply
  * Gigabyte GA-EX58-UD5 (BIOS F3)
  * Intel Quad Core Core i7 920 2.4Ghz (Nehalem) [166Mhz x 20 = 3.3Ghz]
    Noctua C12P
  * 6144MB (3x2048MB) of DDR3-1333 OCZ Platinum Cas 7 (7-7-7-20)
  * Intel SSD X25-M G2 (Postville)      160GB (System)
    Samsung Spinpoint F1 (HD103UJ)        1TB
	Western Digital Green (WD10EADS)      1TB (2x in RAID-1)
	Western VelociRaptor (WD3000HlFS)   300GB (Games)
  * nVidia GeForce GTX 285 1024MB (648Mhz/1242Mhz/1476Mhz) graphic card
    
  (when i say something is fast you should test it before by yourself!! :) )


===============================================================================
 5. HOW TO USE THIS PROGRAM
-------------------------------------------------------------------------------

 Introduction:
 -------------

 Just run DRGUNPACK5.EXE.
 If it is the first time you run it, you will have to select your language.
 Default language is French. But English and Spanish is also available.

 --> If you want to make a translation to your language go to UTILS sub-dir and
     read the TRANSLATION.TXT file.

 You can also associate supported file extensions with Dragon UnPACKer 5 in the
 options.

 That is the only thing you should configure in order to use this program.
 There is more options, but if you are not an expert user you should not be
 changing them.


 Interface:
 ----------
 
 There is a Menu, a Tool Bar, 2 Explorer Lists, an optional preview panel (on
 the right) and a Status Bar.
 
 Here is a list of all menus:
 Menu                             Description
 File > Open                      Allow to open a file which format is
                                  supported (see Supported Formats chapter)
 File > Close                     Allow to close an opened file.
                                  This action is automatic when you do
                                  File > Open.
 File > Reopen                    The last 10 opened files are shown there.
 File > HyperRipper               Will run the HyperRipper module.
 Edit > Search                    Only displayed when a file is opened and
                                  searching is supported.
                                  Allow you to display all files which name
                                  include the string you typed.
 Options > Basic > Basic          Open the configuration panel of Dragon
                                  UnPACKer on Basic options tab.
 Options > Basic > Advanced       Open the configuration panel of Dragon
                                  UnPACKer on Advanced options tab.
 Options > Basic > Execution Log  Open the configuration panel of Dragon
                                  UnPACKer on Execution log options tab.
 Options > Plugins > Convert      Open the configuration panel of Dragon
                                  UnPACKer on Convert Plugins options tab.
 Options > Plugins > Drivers      Open the configuration panel of Dragon
                                  UnPACKer on Drivers Plugins options tab.
 Options > Plugins > HyperRipper  Open the configuration panel of Dragon
                                  UnPACKer on HyperRipper Plugins options tab.
 Options > File Types             Open the configuration panel of Dragon
                                  UnPACKer on File Association tab.
 Options > Look/Icons             Open the configuration panel of Dragon
                                  UnPACKer on Look/Icons options tab.
 Options > Preview                Open the configuration panel of Dragon
                                  UnPACKer on Preview options tab.
 Tools > Create entry list        Will open the Create list window.
                                  If you want to create new templates for this
                                  you can look at the UTILS\TEMPLATES sub-dir
                                  of Dragon UnPACKer 5.
 ? > Check for new versions...    Runs Duppi to check new versions on Internet
 ? > About...                     Display information about the Dragon UnPACKer
                                  
 The Tool Bar have the following buttons (in order of appearence):
 Open  Close | Options | []


 Left-Side Explorer:
 -------------------

 It displays the tree of directories in the file you opened, beginning by the
filename itself, then directories. Example:

 --- Exemple.PAK
  |--- Sound
  |--- Maps
  |--- Textures

 By clicking on the filename or on a directory the program will display in the
Right-Side Explorer all files found in that directory.

 By right-clicking you get a Pop-Up menu.
 If you click on the filename, you will get 2 options:

  + Extract all...
    Allow to extract all files from the opened file to a directory.
    This option is not always available.
    Directories tree is keeped.
  + Expand all
    This will expand all nodes.
  + Collapse all
    This will collapse all nodes.
  + Informations
    Open a little information window about the opened file and about the driver
    used to open this file format.

 If you click on a directory, you will have 1 option:
 
  + Extract sub-directories...
    Allow to extract all files in this directory and all sub-directories.
    This option is not always available.
    Directories tree is keeped.
  + Expand all
    This will expand all nodes.
  + Collapse all
    This will collapse all nodes.


 Right-Side Explorer:
 --------------------

 It displays the list of files in the opened file, a directory in this file or
the result of the search. Example: 

 File                    Size       Offset     Description
 Exemple1.WAV           36201           12     Sound (RIFF/WAVE)
 Exemple2.WAV           97321        36213     Sound (RIFF/WAVE)

 Here is an explanation for each column:

  + File
    The filename
  + Size
    The size in bytes of the file
  + Offset
    The offset of the file (starting at offset #0) in the opened file.
    This information is only useful for expert users.
  + Description
    Give the file type (Sound, Picture, etc..) and if possible his format
    (RIFF/WAVE, MPEG, etc..).

 By right-clicking on the filename you will have 2 options:

  + Extract file
    You have multiple choices, you can Extract raw data (without convertion) or
    Convert files during extraction (only if possible).
  + Open file
    Open the file with an external program (using the Windows Registry).
    Example: .TXT files are opened by Notepad :o).

 You can select many files at once, then if you right-click you will have 2
options:

  + Extract files...
    Allow you to extract all selected files to a directory.

 
 Preview pane:
 -------------

 This is an image/texture preview pane. The image/texture can be shown stretched
of original full size. The pane can be hidden.

 By right-clicking you will have 4 options:
 
  + Hide preview
    This will hide the preview pane. To show it back, right click on the status
    bar.
  + Display mode > Original size with scrollbars (if needed)
  + Display mode > Shrinked/Stretched to panel size
  + Preview options
    This will open the options on the Preview options tab.
     

 Execution log:
 --------------
 
 It is at the bottom of the window, just before the status bar. It will display
messages indicating what the program is doing. You can select which level of
detail you wish in the options or just disable (hide) the log.

 By right clicking on it, you can :
 
  + Hide/Display the log
  + Clear the log
 
 A red line indicates an error.
 An orange line indicates a warning or something important.


 Command line:
 -------------
 
 You can run Dragon UnPACKer with following options:
 
 DrgUnPack5.exe /lng
 Displays the language selection box on start-up.
 
 DrgUnPack5.exe <file.ext>
 Open the file.ext file.


===============================================================================
 6. HYPER RIPPER
-------------------------------------------------------------------------------

 !!! For Expert users !!!

 Introduction:
 -------------

 This method for opening files allow you to scan it for embedded file formats:

 -669        - UNIT 669 Module
  AVI        - Audio-Video Interleace
  BIK        - BInKley Videos
  BMP        - Windows BitMap pictures
  DDS        - Direct-X Surface file (Textures)
  EMF        - Windows Enhanced MetaFile
 -FLIC       - Autodesk Animator FLIC files
  GIF        - Graphics Interchange Format pictures
  IFF        - Interchange File Format pictures
 *IT         - Impulse Tracker Module
  JPEG       - JPEG Interchange File Format (JFIF) pictures
  MIDI       - Music files
  MOV        - QuickTime Movie
  MPEG Audio - MPEG Layer III (also known as MP3)
  OGG        - Ogg Stream
  PNG        - Portable Network Graphics pictures
 *S3M        - ScreamTracker 3 Module
  TGA        - Truevision Targa (RGB only)
  VOC        - Sounds (Creative VOice)
  WAV        - Sounds (RIFF/WAVE)
  WMF        - Windows MetaFile (Aldus Placeable format)
  XM         - Fast Tracker 2 Module

  * = Not sure (file size may often be wrong).
  - = Many wrong positives (many "found" files are not true 669/FLIC files)


 How to use it:
 --------------

 Using the HyperRipper is pretty easy, but the results can seem quite bizare.
For example the HyperRipper will find files thinking there are of the searched
format, but that's not sure at 100%.

 First of all select the file you wish to scan (Source file).

 Select formats you wish to search for. You should select only files that may
appear in the scanned file. For example if you scan SNDFILE.DAT, you should
search only for Sound formats, and remove Picture formats (PNG, IFF/LBM, BMP).
 The HyperRipper will be faster when only 1 format is selected.

 When finished selecting the formats to search for, click on the Search! button
you will then have to wait some time (can be very long for Big files of 200Mb).
If you can put the file to scan on a RAM Disk, then DO IT!!!

 
 'Create HyperRipper File' option:
 ---------------------------------
 
 If you check this option, the HyperRipper will create a companion file of the
source file with the .HRF extension (you can change this filename as you like)
that will store all results from the HyperRipper. That will allow you to open
the .HRF file later with Dragon UnPACKer and have the list of found files
without having to redo the search in the HyperRipper.

 You can select HRF options in the 'HyperRipper file' tab. You have the choice
between 3 versions of the file:

 + Version 1 is the oldest version supported and is only included for history
   reasons (very limited). Can be read by Dragon UnPACKer since v4.00.
 + Version 2 is the extended format introduced in Dragon UnPACKer v4.13, it
   have more room to store information but should be avoided (also included for
   compatibility). Can be read by Dragon UnPACKer since v4.13.
 + Version 3.0 is the default and is recommended. Introduced in Dragon UnPACKer
   v5.0.0 Beta 2 it is made for HyperRipper 5.0.


 Advanced options:
 -----------------

 => Buffer size and rollback?
 
 The HyperRipper reads the source file searching for known structures, the 
 buffer size is the amount of data that is read from file each time. For
 example 256 bytes means that HyperRipper will read by blocks of 256 bytes.
 Because of this a rollback is needed. The rollback just goes back a few bytes.
 
 For example with a buffer size of 6 bytes and a rollback of 3.
 
 Source file: A B C D E F G H I J K L M N O P Q R S T ...
  First read: A B C D E F
 Second read: D E F G H I (went back 3 bytes and read 6)

 That way if you are searching for a format that start by F G H it will be
 found. Without rollback it wouldn't have been detected.
 
 As a conclusion just use default values :-)
 Buffer size: 256 bytes
 Rollback   : 128 bytes
 
 You can test tweaking the values to get more performance. But only change the
 buffer size. The 128 bytes rollback is more than enough for all supported
 formats.

 NOTE: In v5.4.0 those options are NOT modifiable anymore, the default values
       of 128 KB for Buffer and 32 bytes for Rollback.

 => Entries formatting?
 
 The make directories using type given by plugin allows to put all found videos
 in a sub directory Video, all sounds and musics in an Audio directory, etc...
 
 Naming options allows you to select the name of the found files. There is two
 modes:
 Automatic: Same name as in older versions.
            For ex: pak01.pak_0000003.wav
    Custom: You can define the name of the files yourself!
            You absolutly need to add at least %n, %o or %h somewhere in the
            filename or all found files will have same name!
            The "macros":  %f = source filename (without extension)
                           %x = extension of the source file (without point)
                           %n = number representing the n-th found file
                           %o = decimal offset of the found file
                           %h = hexa-decimal offset of the found file
            For ex: %f.$x_%h      pak01.pak_000002DF.wav
                    %f_%h         pak01_000002DF.wav
                    %f_%o         pak01_735.wav
                    %f_%n         pak01_0000003.wav


 'MPEG Audio' options:
 ---------------------

 To access MPEG Audio options click on Formats tab, then select MPEG Audio and
 then click on the Setup button.

 First of all there is a table with 3 lines and 3 columns.
 First column is for MPEG 1 format.
 Second column is for MPEG 2.0 format.
 Third column is for MPEG 2.5 format.
 First line is for Layer I.
 Second line is for Layer II.
 Third line is for Layer III.

 Each format have its own sub-formats (sample rate, bit rate) but you should
know that MPEG 2.5 is an unofficial format created to support low Bit Rates and
sample rates (ex: 8Khz at 8 KBps). You should also know that the most used
format is the Layer III (named MP3 or MPEG3).

 Following formats could not be tested (I lack files to test):
 MPEG 2.0 Layer I, MPEG 2.0 Layer II, MPEG 2.5 Layer I and MPEG 2.5 Layer II

 To select a format in order to search it in the HyperRipper only check the
option. To the right there is 3 buttons (1, 2 and 3) allowing you to select
only the Layer to search (ex: Layer I, Layer II or Layer III).

 Limits:
 By puting limits on the search you will lower the possibility of having false
MPEG Audio detected in files by limiting the number frames (a MPEG Audio file
is built up using a large amount of frames, the frame contents is the music)
and/or the size.
 I think a lower limit of 5 frames should be the minimum to use (an MPEG3 file
for example have 40 frames per second), by default is set to 20 (0.5 seconds).
 The lower size limit should also be set to at least 2048 bytes.
 Maximum size limit should only be used to cut the MPEG Audio in many parts
instead of having an HUGE single MPEG Audio file.
 Beware, setting the Maximum limit lower than the Minimum limit will not work..

 Special:
 There is sometimes special things in MPEG Audio files (mainly MP3).
 That's why there is 2 options:

 + Search Xing VBR Header:
   Xing Tech. added a small header to their VBR (Variable Bit Rate) MPEG Audio
   files. When present and this option used this will speed-up the HyperRipper.
   Recommended.
 + Search ID3Tag v1.0/v1.1:
   ID3Tag are informations about the song, Title, Author, etc..
   This is found at the end of the file. If this option is not checked the
   program will ignore any ID3Tag and will not add them to the file.
   ID3Tag v2.0 (found in the start of files) are not supported, and will not
   be supported.


===============================================================================
 7. OPTIONS
-------------------------------------------------------------------------------

 Basic Options:
 --------------

 + Do not display Loading screen
   This will remove the introduction box (Dragon UnPACKer) displayed while
   the program loads on startup. Checking this won't make the program load
   faster. 
 + Only allow one instance at once
   This will limit to one instance of the program running at once.
   Further tries to launch the program will make the currently opened instance
   to open the clicked file.
 + Use Smart Format Detection when opening files
   By default the program will check the file format by looking at his
   extension but sometimes this is impossible, so by checking this option the
   program will read the file header to check for the file format. Recommended.
 + Get icons from Windows registry (may be slower)
   By selecting this options the icons for file types displaying in Dragon
   UnPACKer 5 are taken from the registry of Windows (ex: WinAmp icon for MP3
   files). If this option is slowing down your browsing in DUP5 you can disable
   it, DUP5 will then use internal icons.
 + Use HyperRipper if no plugin could open the file
   When no driver can load the file then HyperRipper will be displayed with the
   current file selected as source.
   If this isn't checked then a message box is displayed saying no driver could
   load the file.
   
 + Language
   Allow you to select the language used for Dragon UnPACKer.
   Language change is made on-the-fly (no restart needed).
   The homepage URL displayed is the Language file author one.
   (See Utils\Translation.Txt)
   You can click on Find more translations, this will run Duppi program and
   show all available translations to download from the website.

   NOTE: Translations (other than English/Spanish & French) are done by third
         parties. Therefore new translations can appear months after a release.
         Check now & then if your language is not available yet (or go ahead
         and translate it yourself! Don't forget to send me the translation!).
         (See Utils\Translation.Txt)


 Advanced options:
 -----------------

 + Temporary Directory
   This directory is used to store temporary data files for ex when pressing
   open on embedded files, they are first extracted in that directory then
   opened by their associated program. It is also used during convertion for
   some obsolete (DUDI v3) plugins.
   You can either use the auto-detected one (Current user Windows temporary
   directory) or define one yourself (for ex: Ram disk).
   
 + Options for 'Open file'
   Changes the behavior when double clicking on the right-side explorer pane.
   By default the file is Opened by the associated program.
   If you prefer you can set: Make 'Extract file... Without Convertion' the
   default option
   
 + Buffer memory
   The buffer memory is used for extraction (when handled by Dragon UnPACKer).
   The default buffer is enough for optimal speed, but you can change it if
   you want.
 
 
 Execution log:
 --------------
 
 This allows you to setup the execution log:
 + Display it or not
 + Select the level of detail, there are 3 levels:
     Low - Will only show important messages and all errors
     Medium
     High - All messages, warnings and errors are shown


 Plugins:
 --------
 
 This allows you to see the list of loaded plugins and their version.
 
 The "Advanced Informations" contains informations about :
 + The interface version of the plugin :
     DUDI for Drivers
     DUCI for Convert
     DUHI for HyperRipper
 + The internal version of the plugin (mainly used by Duppi).
 + For drivers this panel also have a priority field:
   Basically for expert users this allows to prefer one driver over another one
   when trying to open files.
   For example:
   If you want drv_mix to try opening a file before drv_default you will give
   drv_mix a priority higher than for drv_default.
   Maximum priority: 200
   Minimum priority:   0

 If a plugin got an information dialog the "About..." button will be enabled. 
 If a plugin got a configuration dialog the "Setup" button will be enabled.
 
 
 Look/Icons:
 -----------

 This allows you to choose the icons used by Dragon UnPACKer.
 There is only one available at the moment "XT (XP Look)". 


 File association:
 -----------------
 
 This section allow to associate files to Dragon UnPACKer to be able to open
those file in the windows explorer (for example) with Dragon UnPACKer.

 If an extension is checked it is associated with Dragon UnPACKer.

 There are 4 options:
 + Verify associations on start-up
   On start-up all selected extensions will be associated with Dragon UnPACKer.
 + Use external icon
   If you prefer another icon for the extensions, use an external icon instead
   of the internal one.
 + Change the association text
   Instead of Dragon UnPACKer Archive, use whatever you prefer.
 + Add Windows Explorer extension "Open with Dragon UnPACKer 5"
   By right clicking on any file in Windows Explorer you will have the option
   to open it with Dragon UnPACKer.
 
 
 Preview:
 --------
 
 This section is all about the preview feature, you can enable/disable the
 preview and set the stretched/shrinked/full size option.
 
 You can also disable the threshold limit for preview size:
 The extraction for certain file formats can be slow, therefore the preview
 can be very sluggish. In order to avoid this, there is a limit for the size
 of the embedded file. If the size is bigger it is not extracted and not
 previewed. The default of 2MB is sometimes slow, you can set it to whatever
 you prefer or disable the limit completely (always preview, this is NOT
 recommended).


===============================================================================
 8. SUPPORTED FORMATS
-------------------------------------------------------------------------------

 If there is a file format you want to be supported by Dragon UnPACKer, contact
the author (see the Contact Me chapter). For more detailed information please
see the webpage at: http://www.elberethzone.net/dup-supportedgames.html

 Complete support:
 -----------------

 Game                                                    Files Driver
 18 Wheels of Steel: Across America                     .ZIPFS drv_zip 
 18 Wheels of Steel: Pedal to the Metal                   .CSC drv_zip 
 The 11th Hour                                            .GJD drv_11th 
 Act of War                                               .DAT drv_default 
 Against Rome                                             .DAT drv_zip 
 Age of Empires 2: Age of Kings                           .DRS drv_default 
 Age of Empires 3                                         .BAR drv_default 
 Age of Mythology                                         .BAR drv_default 
 AGON                                                     .SFL drv_default 
 Alien vs Predator                                        .FFL drv_default 
 Alien vs Predator 2                                      .REZ drv_default 
 Alpha Black Zero                                         .ABZ drv_zip 
 American McGee Alice                                     .PK3 drv_zip 
 Arena Wars                                 .TEXTUREPACK;.DATA drv_zip 
 Ascendancy                                               .COB drv_default 
 Battlefield 1942                                         .RFA drv_default 
 Battlefield 2                                            .ZIP drv_zip 
 Black & White                                            .SAD drv_default 
 Black & White 2                                   .LUG;.STUFF drv_default 
 Blitzkrieg                                               .PAK drv_zip 
 Blitzkrieg Burning Horizon                               .PAK drv_zip 
 Blitzkrieg Rolling Thunder                               .PAK drv_zip 
 Blood                                                    .ART drv_default 
 Blood 2                                                  .REZ ??? 
 Bloodrayne                                               .POD drv_default 
 Brothers Pilots 4                                        .PAK drv_zip 
 Call of Duty                                             .PK3 drv_zip 
 Call of Duty 2                                           .IWD drv_zip 
 Call of Duty 3                                           .IWD drv_zip 
 Call of Duty 4: Modern Warfare                           .IWD drv_zip 
 Call of Duty: World at War                               .IWD drv_zip 
 Call of Juarez                                           .PAK drv_zip 
 Call to Power                                            .CTP drv_zip 
 Cellblock Squadrons                                      .BOX drv_zip 
 Civilization 4                                           .FPK drv_default 
 Command & Conquer: Generals                              .BIG drv_default 
 Conflict: Freespace                                       .VP drv_default 
 Cyberbykes                                               .BIN drv_default 
 Dark Forces                                              .GOB drv_default 
 Darkstone                                                .MTF drv_default 
 Deadly Dozen                                              .ZA drv_zip 
 Deadly Dozen 2: Pacific Theater                           .ZA drv_zip 
 Defiance                                                 .DAT drv_zip 
 Descent                                                  .HOG drv_default 
 Descent 2                                                .HOG drv_default 
 Descent 3                                           .HOG/.MN3 drv_default 
 Desperados: Wanted Dead of Alive                         .PAC drv_zip 
 Dethkarz                                                 .ZIP drv_zip 
 Dreamfall: The Longest Journey                           .PAK drv_default 
 Dinosaur Digs                                            .ZTD drv_zip 
 Dirty Little Helper 98                                   .DLU drv_zip 
 Doom 3                                                   .PK4 drv_zip 
 Doom 3: Resurrection of Evil                             .PK4 drv_zip 
 Duke Nukem 3D                                            .ART drv_default 
 Duke Nukem: Manhattan Project                          .ZIPFS drv_zip 
 Dune 2                                                   .PAK drv_default 
 Dungeon Keeper 2                                         .SDT drv_default 
 Earth Siege 2                                            .VOL drv_default 
 El Airplane                                              .ARH drv_zip 
 Electranoid                                              .RES drv_default 
 Elite Warriors                                            .ZA drv_zip 
 Emperor: Battle for Dune                            .BAG;.RFD drv_default 
 Empire Earth 2                                           .ZIP drv_zip 
 Enclave                                             .XTC;.XWC drv_default 
 Entropia Universe                                        .BNT drv_default 
 Eve Online                                             .STUFF drv_default 
 Evil Island                                              .RES drv_default 
 Fable: The Lost Chapters                                 .LUG drv_default 
 Falcon 4                                                 .ZIP drv_zip 
 Fallout Tactics                                          .BOS drv_zip 
 Far Cry                                                  .PAK drv_zip 
 F.E.A.R.                                              .ARCH00 drv_default 
 Fire Starter                                             .ZIP drv_zip 
 Florensia                                                .PAK drv_default 
 Freedom Fighters                                         .ZIP drv_zip 
 Freedom Fighters                                         .TEX drv_default 
 Freedom Force                                             .FF drv_zip 
 Freedom Force vs The 3rd Reich                            .FF drv_zip 
 Freelancer                                             .FLMOD drv_zip 
 Freespace 2                                               .VP drv_default 
 Fuzzy's World of Miniature Space Golf                    .RES drv_default 
 Giants: Citizen Kabuto                                   .GZP drv_default
 Grand Theft Auto 3                                  .IMG/.DIR drv_default 
 Grand Theft Auto: Vice City                              .ADF drv_default 
 Gunlok                                                   .DAT drv_default 
 Half Life                                           .PAK;.WAD drv_default 
 Hands of Fate                                       .PAK;.TLK drv_default 
 Harbinger                                                .SQH drv_default 
 Heavy Metal F.A.K.K.2                                    .PK3 drv_zip 
 Hellhog XP                                                 .A drv_zip 
 Heretic 2                                           .PAK;.WAD drv_default 
 Hexen 2                                             .PAK;.WAD ??? 
 Hidden & Dangerous                                  .DTA/.CNT drv_default 
 Hitman: Bloodmoney                                       .ZIP drv_zip 
 Hitman: Bloodmoney                                  .TEX;.PRM drv_default 
 Hitman 2: Silent Assassin                                .ZIP drv_zip 
 Hitman 2: Silent Assassin                           .TEX;.PRM drv_default 
 Hitman: Contracts                                        .ZIP drv_zip 
 Hitman: Contracts                                   .TEX;.PRM drv_default 
 Holy Games 2005                                          .POD drv_zip 
 Hooligans                                                .X13 drv_default 
 Hot Rod American Street Drag                             .ROD drv_zip 
 Hunting Unlimited 3                                      .SCS drv_zip 
 Indiana Jones 3D                                         .GOB drv_default 
 Interstate '76                                           .ZFS drv_default 
 Interstate '82                                           .ZFS drv_default 
 Itch                                                     .PSH drv_zip 
 Jagged Alliance 2                                        .SLF drv_default 
 James Bond 007: Nightfire                                .007 drv_default 
 Jedi Knight 2: Jedi Outcast                              .PK3 drv_zip 
 Lands of Lore                                       .PAK;.TLK drv_default 
 Laser Light                                              .RES drv_default 
 LEGO Star Wars                                           .DAT drv_default 
 Leisure Suite Larry: Magna Cum Laude                     .JAM drv_default 
 Lemmings Revolution                                      .BOX drv_default 
 Line of Sight: Vietnam                                    .ZA drv_zip 
 Low and Order 3: Justice is Served                       .LZP drv_zip 
 Marine Mania                                             .ZTD drv_zip 
 Master of Orion 3                                        .MOB drv_zip 
 Maximus XV                                               .PAK drv_zip 
 MDK                                                      .SNI drv_default 
 Medal of Honor: Allied Assault                           .PK3 drv_zip 
 Metal Gear Solid                                         .MGZ drv_zip 
 Microsoft Flight Simulator 2004                          .CAB drv_zip 
 Monkey Island 3                                          .BUN drv_default 
 Monte Cristo                                             .PAK drv_zip 
 Mortyr                                                   .HAL drv_default 
 Moto Racer                                               .BKF drv_default 
 Myst IV: Revelation                                      .M4B drv_default 
 Nascar Racing                                            .DAT drv_default 
 Neighbours From Hell                                     .BND drv_zip 
 Neighbours From Hell 2                                   .BND drv_zip 
 No One Lives for Ever                                    .REZ drv_default 
 No One Lives for Ever 2                                  .REZ drv_default 
 Nocturne                                                 .POD drv_default 
 Outfront                                                 .PAK drv_zip 
 Packmania 2                                              .ARF drv_zip 
 Painkiller                                               .PAK drv_default 
 Paridise Cracked                                         .PAK drv_zip 
 Patrician II                                             .CPR drv_default 
 Perimeter                                                .PAK drv_zip 
 Port Royale                                              .CPR drv_default 
 Postal                                                   .SAK drv_default 
 Purge                                                    .REZ drv_default 
 Pusher                                                   .PSH drv_zip 
 Quake                                               .PAK;.WAD drv_default 
 Quake 2                                                  .PAK drv_default 
 Quake 3 Arena                                            .PK3 drv_zip 
 Quake 4                                                  .PK4 drv_zip 
 Qui veut gagner des millions                             .AWF drv_default 
 Rage of Mages                                            .RES drv_default 
 Rage of Mages 2                                          .RES drv_default 
 realMyst 3D                                              .DNI drv_default 
 Revenant                                           .RVI;.RVM;.RVR drv_zip 
 Richard Burns Rally                                      .RBZ drv_zip 
 Ricochet: Lost Worlds Recharged                          .DAT drv_zip 
 Ricochet Xtreme                                          .DAT drv_zip 
 Sabotain                                                 .SAB drv_zip 
 Sanity Aiken's Artifact                                  .REZ drv_default 
 Serious Sam                                              .GRO drv_zip 
 Serious Sam 2                                            .GRO drv_zip 
 Shadow Warrior                                           .GRP drv_default 
 Shadowgrounds                                            .FBZ drv_zip 
 Shogo                                                    .REZ drv_default 
 Sin                                                      .SIN drv_default 
 Singles: Flirt up your Life                              .SXT drv_zip 
 Slave Zero                                               .ZIP drv_zip 
 Spellforce                                               .PAK drv_default 
 Star Crusader                                        .GL;.PAK drv_default 
 Star Wolves                                              .DAT drv_zip 
 SWAT 3: Close Quarters Battle                            .RES drv_zip 
 System Shock 2                                           .CRF drv_zip 
 Team Factor                                              .BOT drv_zip 
 Terminal Velocity                                        .POD drv_default 
 Terminator 3                                             .POD drv_zip 
 The Chronicles of Riddick: Escape from Butcher Bay  .XTC;.XWC drv_default 
 The Elder Scroll 4: Oblivion                             .BSA drv_default 
 The Lord of the Rings: Battle for the Middle Earth       .BIG drv_default 
 The Movies                                          .LUG;.PAK drv_default 
 The Sims                                                 .FAR drv_default 
 Theme Park World                                    .WAD;.SDT drv_default 
 Thief                                                    .CRF drv_zip 
 Thief 2                                                  .CRF drv_zip 
 Tony Hawk Pro Skater 2                                   .PAK drv_default 
 Total Annihilation                                  .HPI;.UFO drv_default 
 Total Annihilation: The Core Contingency                 .CCX drv_default 
 Tribes                                                   .VOL drv_default 
 Tribes 2                                                 .VL2 drv_zip 
 Trickstyle                                               .PAK drv_default 
 Tron 2.0                                                 .REZ drv_default 
 UFO: Afterlight                                          .VFS drv_default 
 UFO: Aftermath                                           .VFS drv_default 
 UFO: Aftershock                                          .VFS drv_default 
 Uplink                                                   .DAT drv_zip 
 Vampire: The Masquerade                                  .NOB drv_zip 
 Vampire: The Masquerade: Redemption                      .NOB drv_zip 
 Warlords Battlecry                                       .XCR drv_default 
 Warlords Battlecry 2                                     .XCR drv_default 
 Who wants to be a millionaire                            .AWF drv_default 
 X-Men Legends 2                                          .BIN drv_zip 
 Xatax                                                    .RES drv_default 
 Xpand Rally                                              .BIN drv_zip 
 XS Mark                                             .PK1;.PK2 drv_zip 
 Zanzarah                                                 .PAK drv_default 

 Partial support:
 ----------------
 
 Game                                                    Files Driver
 Armored Fist 3                                           .PFF drv_default 
 Comanche 4                                               .PFF drv_default 
 Delta Force                                              .PFF drv_default 
 Delta Force 2                                            .PFF drv_default 
 Delta Force: Land Warrior                                .PFF drv_default 
 F22 Lightning 3                                          .PFF drv_default 
                              	Only PFF3 files are supported.

 Commandos 3                                              .PCK drv_default 
                     	          Decryption keys are hardcoded.

 Dig It!                                                  .XRS drv_default 
                                  Crypted/Compressed? Dunno...

 Dungeon Keeper 2                                         .SDT drv_default 
 F-22 Air Dominance Fighter                               .DAT drv_default 
 Super EF2000                                             .DAT drv_default 
   Filenames are not retrieved and .RA compressed files are not decompressed.

 Operation Flashpoint                                     .PBO drv_default 
                                      Limited to 2000 entries.

 Deus Ex                                        .UAX;.UMX;.UTX drv_ut 
 Harry Potter                                   .UAX;.UMX;.UTX drv_ut 
 Rune                                           .UAX;.UMX;.UTX drv_ut 
 Undying                                             .UAX;.UTX drv_ut 
 Unreal                                         .UAX;.UMX;.UTX drv_ut 
 Unreal 2                                            .UAX;.UTX drv_ut 
 Unreal: Return to Na Pali                      .UAX;.UMX;.UTX drv_ut 
 Unreal Tournament                              .UAX;.UMX;.UTX drv_ut 
 Unreal Tournament 2003                              .UAX;.UTX drv_ut 
   Unreal Engine packages (.UAX, .UMX &.UTX) from newer games might be opened
   by the UT Package driver of Dragon UnPACKer but it will almost certainly
   fail to extract anything because of internal changes in newer packages.

 Experimental/Broken support:
 ----------------------------

 Game                                                    Files Driver
 Breakneck                                                .SYN drv_default 
 Excessive Speed                                          .SYN drv_default 
 N.I.C.E. 2                                               .SYN drv_default 
                                                Not decrypted.

 Daikatana                                                .PAK drv_default 
                      	     Impossible to extract anything...
                      
 Empires: Dawn of the Modern World                        .SSA drv_default 
                         Somes files uses unknown compression.

 NoX                                                  .BAG/IDX drv_default 
                             Only GABA/Audio.bag\idx supported

 If you find other games that work with current drivers please contact Alex
Devilliers with the game name and version.
 If any driver fail to work with a game that should be working, also contact
Alex Devilliers. (see end of file)


 About others Formats
 --------------------

 Game                   Extension   Informations
 Blizzard Games              .MPQ   Don't expect much..
                                    If you really need use MPQView.
                                    (http://www.starcraft.org)
 C&C,C&C2,C&C:RA,Dune 2000   .???   Crypted and/or compressed formats
                                    WILL (I THINK) NEVER BE SUPPORTED!
 Descent 1                   .PIG   DDN Specification is bad. So don't expect
                                    much.
 MDK                         .???   Other files than .SNI
 Mech Warrior 3              .ZBD   Very strange format.. I think will not be
                                    supported
 Midtown Madness             .AR    Extract possible but I cannot give names to
                                    files (I don't understand the format)... :(

 If you can help by giving me informations or the specification of the format,
contact me (see Contacts chapter).


===============================================================================
 9. CONTACTS
-------------------------------------------------------------------------------

 You can find latest version here:
 http://www.dragonunpacker.com

 You can contact the author (Alex Devilliers):
 Send bug reports, comments, suggestions, etc...
 Write me only in french, english or spanish.
 
  E-Mail: dup560 (at) dragonunpacker (DOT) com
     ICQ: 1535372 (Elbereth)
     
 WARNING: You will NEVER receive any email from me having the above email as
          from field. If you do you can safely ignore and delete such mails.


===============================================================================
 10. SPECIAL THANKS
-------------------------------------------------------------------------------

 Alexey Vasilyev for his translation of Dragon UnPACKer.
                 and for his help on finding translation bugs.
                 EMail: alexxwiz (at) chat (dot) ru
                   URL: http://alexxwiz.newmail.ru

 Andrew Bondar for his translation of Dragon UnPACKer and checking for all the
               gui glitches that I left in the program. ;)
               EMail: pit0n2 (at) mail (dot) ru

 Andre N Belokon for his HashTrie dynamic hash Delphi implementation.
                 EMail: support (at) softlab (dot) od (dot) ua
                   URL: http://www.softlab.od.ua

 Anonimeitor for the help on improving Spellforce .PAK support.

 Beaubois Luc for the Japanese translation of Dragon UnPACKer (japanese.lng)
              and all the beautiful icons and images of Dragon UnPACKer. The
              only one he didn't do is the HyperRipper one.
              EMail: barf (at) hellokitty (dot) ne (dot) jp
                URL: http://www.barfhappy.com/japan/

 Cariad Ysbryd for his help in the test of the MP3 support in the HyperRipper
               and for Diablo 2 Stress Test ;)
               EMail: cariad (at) lodoss (dot) org
                 URL: http://www.multimania.com/epistein2/Cariad

 Christoph Schulze for his tests of the Final Fantasy 8 PAK support.
                   EMail: chr.schulze (at) aon (dot) at

 Deniz Oezmen for his specifications and his help for RL/GJD file formats of
              The 8th Guest and The 11th Hour.
              And for his German translation of Dragon UnPACKer.
              EMail: Deniz.Oezmen (at) t-online (dot) de

 Descent Developper Network (DDN) for formats specs of Descent 1, 2 & 3
                                  and Descent Freespace
                                  URL: http://www.descent2.com/

 Felix Riemann for his WestWood MIX driver plugin.

 Gustav Munkby for his 'Get "non-musical" data from an .MP3-file' homepage:
               EMail: grd (at) swipnet (dot) se
                 URL: http://home.swipnet.se/grd/mp3info/

 Guy Ratajczak for his decompression code for Darkstone MTF file format:
               EMail: guy.ratajczak (at) wanadoo (dot) fr
                 URL: http://www.chez.com/misterjack/

 Info-ZIP for the UnZip32.DLL v5.5.2 (allowing ZIP file listing/extraction)
        By Info-ZIP group
        Portions:
        Copyright (c) 1992 Igor Mandrichenko.
        Copyright (c) 1994 Greg Roelofs.
        Copyright (c) 1996 Mike White.
        Info-ZIP source/executables can be found from the following
        Internet/WWW URL.
        URL: http://www.info-zip.org/pub/infozip/UnZip.html

 Jordan Russell pour Inno Setup (programme d'installation):
                URL: http://www.innosetup.com

 Ken Taylor for the dniExtract source allowing support for realMyst 3D DNI
            files.
            Email:  taylork (at) alum (dot) mit (dot) edu

 Lizardking for the About box music.

 Marek Mauder for the Vampyre Imaging Library v0.26.0 (used for fast preview)
        Email: marekmauder (at) gmail (dot) com
          URL: http://imaginglib.sourceforge.net/
          
 Michele Marcon for the Italian translation of Dragon UnPACKer (italiano.lng).
                EMail: markovitch (at) inwind (dot) it
                  URL: http://arena.sci.univr.it/~marcon

 Mike Lischke for his superb VirtualTree (replacement of standard Delphi slow
              TListView).
              EMail: public (at) lischke-online (dot) de
                URL: http://www.lischke-online.de

 MIDAS Digital Audio System (MIDAS11.DLL) (allow to listen modules, MIDIs and
                                           WAVE files)
           Copyright (c) 1996-1997 Housemarque Inc.
           EMail (Technical questions and comments): pekangas (at) sci (dot) fi
           EMail (Licensing information): midas (at) housemarque (dot) fi
           URL: http://www.s2.org/midas/
 
 Mr.Mouse for his findings about the Painkiller .PAK format (and for his DLL
          version of MultiEx).
          URL: http://forum.xentax.com/viewtopic.php?t=664
               http://www.xentax.com

 PkWARE for format specs of ZIP files
        URL: http://www.pkware.com

 Psych0phobiA for the TrueVision Targa .TGA support (patch) in HyperRipper.

 Quake Specs v3.4 by Olivier Montanuy for format specs of Quake 1 PACK

 Qhimm for his informations on how to open Final Fantasy 8 .PAK files.
       EMail: mrdata82 (at) swipnet (dot) se
         URL: http://home.swipnet.se/mrdata82/

 The Wotsit's Format for all those file formats specification.
                     URL: http://www.wotsit.org

 UPX - The Ultimate Packer for eXecutables
       Copyright (c) 1996-2001 Markus Oberhumer & Laszlo Molnar
       URLs: http://wildsau.idv.uni-linz.ac.at/mfx/upx.html
             http://www.nexus.hu/upx
             http://upx.tsx.org

===============================================================================