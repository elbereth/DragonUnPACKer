Dragon UnPACKer v5.2.0                                      MPL 1.1 open source
by Alexande "Elbereth" Devilliers                                    23/12/2005
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
    SETUP - ~2.2MB - dup520cinthia-setup.exe  - With Install/Uninstall
       7Z - ~1.9MB - dup520cinthia.7z         - Plain 7-Zip (v4.32) archive


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

 drgunpack5.exe    	        2770 KB
 drgunpack5.exe.sig            1 KB  PGP Signature of drgunpack5.exe file
 file_id.diz       	           1 KB
 historique.txt    	          30 KB
 lisezmoi.txt      	          43 KB
 readme.txt        	          40 KB
 whatsnew.txt      	          27 KB
 
 data\
 default.dulk                 40 KB  Default Look
+english.lng                  11 KB  English translation of DUP5
 homepage.uht                 22 KB  Create list template "DUP4 Style"
+spanish.lng                  11 KB  Spanish translation of DUP5
 text-db.uht                   6 KB  Create list template "Text Database"
 xml-db.uht                    6 KB  Create list template "XML Database"

 data\convert\
 Blood.dpal                    1 KB  Blood color palette
 cnv_pictex.d5c              459 KB  Textures convert plugin (v2.0.1)
 Doom.dpal                     1 KB  Doom color palette
 Duke3D.dpal                   1 KB  Duke Nukem 3D color palette
 Quake 1.dpal                  1 KB  Quake color palette
 Quake 2.dpal                  1 KB  Quake 2 color palette
 Shadow Warrior.dpal           1 KB  Shadow Warrior color palette
 
 data\drivers\
 drv_11th.d5d                410 KB  11th Hour driver plugin (v1.0.0 Beta 2)
 drv_default.d5d             219 KB  Main driver plugin (v2.0.0)
 drv_giants.d5d               96 KB  Giants GZP driver plugin (v1.0.2)
 drv_mix.d5d                  64 KB  WestWood MIX driver plugin (v1.1.4 Beta)
                                     By Felix Riemann
 drv_ut.d5d                  669 KB  UT Packages driver plugin (v2.3.0)
 drv_zip.d5d                  98 KB  ZIP driver plugin (v1.1.0)
 unzip32.dll                 100 KB  Info-Zip's UnZip32.Dll v5.5.2
                                 
 data\hyperripper\               
 hr_default.d5h              517 KB  Default HyperRipper plugin (v5.0.2)
                                 
 utils\                          
 duppi.exe                   885 KB  DUP5 Package installer (v2.1.0)
 hrf_30_spec.txt               7 KB  HyperRipper file 3.0 specification

 utils\templates\
 duhtcomp.exe                116 KB  UHT file compiler
 duhtcomp.txt                  5 KB  UHT file compiler documentation
 ex-homepage.zip              23 KB  Sources of the homepage.uht template
 ex-text.zip                   8 KB  Sources of the text-db.uht template
 ex-xml.zip                    7 KB  Sources of the xml-db.uht template
 
 utils\translation\
 dlngc.exe                   124 KB  LNG file compiler
 dlngc.txt                     3 KB  LNG file compiler documentation
 english-520-changes.txt       4 KB  Changes in english.ls 5.0.0 -> 5.2.0
 english.ls                   20 KB  English translation sources
 english-beta2-changes.txt     4 KB  Changes in english.ls 5.0.0 Beta 1 -> 2
 english-beta3-changes.txt     4 KB  Changes in english.ls 5.0.0 Beta 2 -> 3
 english-rc1-changes.txt       2 KB  Changes in english.ls 5.0.0 Beta 3 -> RC1
 english-rc2-changes.txt       2 KB  Changes in english.ls 5.0.0 RC1 -> RC2
 english-rc3-changes.txt       3 KB  Changes in english.ls 5.0.0 RC2 -> RC3
 flag_sp.bmp                   1 KB  Spain flag icon
 flag_us.bmp                   1 KB  USA flag icon
 spanish.ls                   17 KB  Spanish translation sources
 translation.txt               2 KB  How to make a DUP5 translation

  * Needed files for DRGUNPACK5.EXE to work.


===============================================================================
 4. NEEDED TO WORK
-------------------------------------------------------------------------------

 You will need:

  * Windows 98/ME/NT/2000/XP/2003.
    Tested under Windows XP.
    Does not work under Windows 95.

 Author's computer:

  * Antec P180 case
  * Seasonic S12-600 power supply
  * Asus A8N-SLI Deluxe (BIOS 1015)
  * AMD Athlon 64 X2 4400+ (220Mhz x 11 = 2.4Ghz)
    Termalright XP-120 with NoiseBlocker SX2 fan
  * 2048MB (2x1024MB) of DDRam Corsair PC3200 Cas 2 (3-3-3-8-T1 @ 220Mhz)
  * 1.8TB of hard disk space (8 physical hard disks)
  * Pioneer DVR-109 DVD-RW 16x burner
  * Sound Blaster Audigy 2 ZS sound card
  * Asus GeForce 7800 GTX 256MB (500Mhz/1.34Ghz) graphic card
    NV Silencer 5 rev 3
    
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
 
 There is a Menu, a Tool Bar, 2 Explorer Lists and a Status Bar.
 
 Here is a list of all menus:
 Menu                             Description
 File > Open                      Allow to open a file which format is
                                  supported (see Supported Formats chapter)
 File > Close                     Allow to close an opened file.
                                  This action is automatic when you do
                                  File > Open.
 File > HyperRipper               Will run the HyperRipper module.
 Edit > Search                    Only displayed when a file is opened and
                                  searching is supported.
                                  Allow you to display all files which name
                                  include the string you typed.
 Tools > Create file list         Will open the Create list window.
                                  If you want to create new templates for this
                                  you can look at the UTILS\TEMPLATES sub-dir
                                  of Dragon UnPACKer 5.
 Options > Basic                  Open the configuration panel of Dragon
                                  UnPACKer on Basic options tab.
 Options > Plugins                Open the configuration panel of Dragon
                                  UnPACKer on Plugins options tab.
 Options > File Association       Open the configuration panel of Dragon
                                  UnPACKer on File Association tab.
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

  669        - UNIT 669 Module
  AVI        - Audio-Video Interleace
  BIK        - BInKley Videos
  BMP        - Windows BitMap pictures
  EMF        - Windows Enhanced MetaFile
  FLIC       - Autodesk Animator FLIC files
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
  VOC        - Sounds (Creative VOice)
  WAV        - Sounds (RIFF/WAVE)
  WMF        - Windows MetaFile (Aldus Placeable format)
  XM         - Fast Tracker 2 Module

  * = Not sure (file size may often be wrong).


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

 If a plugin got a configuration dialog the "Setup" button will be enabled.
 If a plugin got an information dialog the "About..." button will be enabled. 
 
 
 Look/Icons:
 -----------

 This allows you to choose the icons used by Dragon UnPACKer.
 There is only one available at the moment "XT (XP Look)". 
 
 
 Execution log:
 --------------
 
 This allows you to setup the execution log:
 + Display it or not
 + Select the level of detail


 File association:
 -----------------
 
 This section allow to associate files to Dragon UnPACKer to be able to open
those file in the windows explorer (for example) with Dragon UnPACKer.

 If an extension is checked it is associated with Dragon UnPACKer.


===============================================================================
 8. SUPPORTED FORMATS
-------------------------------------------------------------------------------

 If there is a file format you want to be supported by Dragon UnPACKer, contact
the author (see the Contact Me chapter).

 Games                                     Extensions  Tested Comment    
 11th Hour                                       .GJD  Yes    See options/cfg
 Age of Empires 2: Age of Kings                  .DRS  Yes
 Age of Empires 3                                .BAR  Yes
 Age of Mythology                                .BAR  Tes
 Alien vs Predator                               .FFL  Yes
 Alien vs Predator 2                             .REZ  Yes
 American McGee Alice                            .PK3  Yes
*Armored Fist 3                                  .PFF  No     PFF3 only
 Battlefield 1942                                .RFA  Yes
 Black & White                                   .SAD  Yes
 Black & White 2                          .LUG;.STUFF  Yes
 Blood                                           .ART  Yes
 Blood 2                                         .REZ  No 
 BloodRayne                                      .POD  Yes
#Breakneck                                       .SYN  Yes    Partial/Useless
 Civilization 4                                  .FPK  Yes
*Comanche 4                                      .PFF  No     PFF3 only
 Command and Conquer 1                           .MIX  ???    By Felix Riemann
 Command and Conquer: Generals                   .BIG  Yes
 Conflict: Freespace                             .VP   Yes
 Cyberbykes                                      .BIN  Yes
!Daikatana                                       .PAK  Yes    Does not work
 Dark Force                                      .GOB  Yes
 DarkStone                                       .MTF  Yes
*Delta Force 1                                   .PFF  No     PFF3 only
*Delta Force 2                                   .PFF  No     PFF3 only
*Delta Force: Land Warrior                       .PFF  Yes    PFF3 only
 Descent                                         .HOG  Yes
 Descent 2                                       .HOG  No 
 Descent 3                                  .HOG;.MN3  Yes
 Desperados: Wanted Dead or Alive                .PAC  Yes    .PAC on the CD
 Deus Ex                               .UAX;.UMX;.UTX  Yes
 Doom 3                                          .PK4  Yes
 Dragon UnPACKer HyperRipper                     .HRF  Yes    v0 v1 v2 v3.0
 Duke Nukem 3D                              .ART;.GRP  Yes
 Dune 2                                          .PAK  Yes
*Dungeon Keeper 2                           .SDT;.WAD  Yes
 Earth Siege 2                                   .VOL  Yes
 Emperor: Battle for Dune                   .BAG;.RFD  Yes    Fully supported
 Evil Islands                                    .RES  Yes
#Excessive Speed                                 .SYN  Yes    Partial/Useless
 F22 Lighting 3                                  .PFF  Yes
 Fable: The Lost Chapters                        .LUG  Yes
 F.E.A.R.                                     .ARCH00  Yes
 Freedom Fighters                                .TEX  Yes
 Freespace 2                                     .VP   Yes
 Giants: Citizen Kabuto                          .GZP  Yes    Fully supported
 GTA3                                       .DIR/.IMG  Yes
 GTA: Vice City                                  .ADF  Yes
 Gunlok                                          .DAT  Yes
 Gunman Chronicle                                .WAD  Yes
 Half Life                                  .PAK;.WAD  Yes
 Hand of Fate                               .PAK;.TLK  Yes
 Harbinger                                       .SQH  Yes
 Harry Potter                          .UAX;.UMX;.UTX  Yes
 Heavy Metal: F.A.K.K.2                          .PK3  Yes
 Heretic 2                                  .PAK;.WAD  Yes
 Hexen 2                                         .PAK  No 
 Hidden & Dangerous                              .DTA  Yes    Run the game once
 Hitman 2: Silent Assassin                       .TEX  Yes
 Hitman: Contracts                          .PRM;.TEX  Yes
 Hooligans                                       .X13  Yes
 Indiana Jones 3D                                .GOB  Yes
 Interstate '76                                  .ZFS  Yes
 Interstate '82                                  .ZFS  Yes
 Jagged Alliance 2                               .SLF  Yes
 James Bond NightFire                            .007  Yes    Demo/Retail
 Jedi Knight: Dark Forces 2                      .GOB  Yes
 Jedi Knight 2: Jedi Outcast                     .PK3  Yes
 Lands of Lore                              .PAK;.TLK  Yes
 LEGO Star Wars                                  .DAT  Yes
 Leisure Suit Larry: Magna Cum Laude             .JAM  Yes
 Lemmings Revolution                             .BOX  Yes
 MDK                                             .SNI  Yes
 Medal of Honor: Allied Assault                  .PK3  Yes
 Metal Gear Solid                                .MGZ  Yes
 Monkey Island 3                                 .BUN  Yes
 Mortyr                                          .HAL  Yes
 Moto Racer                                      .BKF  Yes
 Myst IV: Revelation                             .M4B  Yes
#N.I.C.E.2                                       .SYN  Yes    Partial/Useless
 Nascar Racing                                   .DAT  Yes
 No One Lives for Ever                           .REZ  Yes
 No One Lives for Ever 2                         .REZ  Yes
#NoX                                         .BAG/IDX  Yes    Partial/Experim.
 Operation Flashpoint                            .PBO  Yes
 Painkiller                                      .PAK  Yes    Thanks to MrMouse
 Patrician II                                    .CPR  Yes
 Port Royale                                     .CPR  Yes
 Postal                                          .SAK  Yes
 Purge                                           .REZ  Yes
 Quake                                      .PAK;.WAD  Yes
 Quake 2                                    .PAK;.WAD  Yes
 Quake 3 Arena                                   .PK3  Yes
 Quake 4                                         .PK4  Yes
 Qui veut gagner des millions                    .AWF  Yes
 Rage of Mages                                   .RES  Yes
 Rage of Mages 2                                 .RES  Yes
 realMyst 3D                                     .DNI  Yes
 Revenant                              .RVI;.RVM;.RVR  Yes
 Rune                                  .UAX;.UMX;.UTX  Yes
 Sanity: Aiken's Artifact                        .REZ  Yes
 Serious Sam                                     .GRO  Yes
 Serious Sam 2                                   .GRO  Yes
 Shadow Warrior                             .ART;.GRP  Yes
 Shogo: Mobile Armor Division                    .REZ  Yes
 Sin                                             .SIN  Yes
 Star Crusader                               .GL;.PAK  Yes
 System Shock 2                                  .CRF  Yes
 Terminal Velocity                               .POD  Yes
 The Sims                                        .FAR  Yes
 The Lord of the Rings: Battle for Middle Earth  .BIG  Yes
 The Movies                                 .BIG;.LUG  Yes
 Theme Park World                           .SDT;.WAD  Yes
 Thief                                           .CRF  Yes
 Thief 2                                         .CRF  Yes
 Tony Hawk Pro Skater 2                          .PKR  Yes
 Total Annihilation                         .HPI;.UFO  Yes
 Total Annihilation: Contrea-Attaque             .CCX  Yes
 Tribes                                          .VOL  Yes
 Tribes 2                                        .VL2  Yes
 Trickstyle                                      .PAK  Yes
 Tron 2.0                                        .REZ  Yes
 Undying                                    .UAX;.UTX  Yes
 Unreal                                .UAX;.UMX;.UTX  No 
 Unreal 2                                   .UAX;.UTX  Yes
 Unreal Tournament                     .UAX;.UMX;.UTX  Yes
 Unreal Tournament 2003                     .UAX;.UTX  Yes    Betas/Demo/Retail
 Vampire: La Mascarade                           .NOB  Yes
#Vietcong (Demo)                                 .CBF  Yes    No decompression
 Warlords Battlecry                              .XCR  Yes
 Warlords Battlecry 2                            .XCR  Yes
 Who wants to be a millionaire                   .AWF  Yes
 Zanzarah                                        .PAK  Yes

* = Some files don't work properly.
# = Experimental Driver (Incomplet and/or untested).
! = Don't work

   Total:       Supported Games = 134

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
 
  E-Mail: dup520 (at) dragonunpacker (DOT) com
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

 Beaubois Luc for the Japanese translation of Dragon UnPACKer (japanese.lng).
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
            Email: taylok2 (at) rpi (dot) edu
              URL: http://www.rpi.edu/~taylok2/dniExtract

 Lizardking for the About box music.

 Michal Hajek for the Czech translation of Dragon UnPACKer (cestina.lng).
        EMail: michal.hajek (at) email (dot) cz
          URL: http://bouchac.misto.cz

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