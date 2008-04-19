# Language Source File (for DLNGC v4.0)
# ============================================================================
#  Program: Dragon UnPACKer v5.3.2 WIP
# Language: English
#  Version: 1
#   Author: Alex Devilliers
# ============================================================================
#
# This file is the model for translations of Dragon UnPACKer.
#
# Just translate everything between {BODY} and {/BODY}
#
# Then compile the file with DLNGC and put the resulting .LNG file into the
# \Data\ sub-directory of Dragon UnPACKer.
#
# To select a new Language into Dragon UnPACKer run: DrgUnPACK5.exe /lng
# Or go into the General Options.
#
# DON'T MODIFY ANY KEYWORD - JUST CHANGE THINGS AFTER THE = SYMBOL
#
# If you have made a translation for your language send it to Alex Devilliers
# so it can be distributed along with the main program archive.
#
# You can reach Alex Devilliers by e-mail: translation@dragonunpacker.com
#                                  by ICQ: 1535372 (Elbereth)
#
# ============================================================================
# Informations about this translation
# ============================================================================
#
# version 10:
# Added new options.
#
# version 9a:
# Added missing OPT203 keyword
#
# version 9:
# Added UT Package driver plugin strings.
# Added Log feature strings.
# Added Duppi strings.
#
# version 8:
# Changed some error messages.
#
# version 7:
# Added new Options strings (drivers priority, etc..).
# Added Log feature strings.
#
# version 6a:
# Added FontName header option.
#
# version 6: (see english-rc3-changes.txt for changes since version 5)
# Fixed two missing HyperRipper plugin error strings (ERRH01 and ERRH02)
# Added some convert plugin strings.
# Added new about box strings.
# Added 11th Hour driver plugin strings.
#
# version 5: (see english-rc2-changes.txt for changes since version 4)
# Added Use HyperRipper if all plugins fails option string.
# Fixed some leading ' characters.
#
# version 4: (see english-rc1-changes.txt for changes since version 3)
# Added Error handling string.
# Added HyperRipper v5.0a strings.
# Added Convert pic/tex plugin palette convertion strings.
#
# version 3: (see english-beta3-changes.txt for changes since version 2)
#            (no changes between beta3 and beta4)
# Added Create List strings.
# Added Error handling strings.
# Added Duppi v2 strings.
# Added 1 option string.
#
# version 2: (see english-beta2-changes.txt for changes since version 1)
# Added 1 Duppi string.
# Added all HyperRipper translation labels.
#
# version 1:
# First version.
#
{LSF}
{HEADER}
#
# * Header *
#
# + Name +
# Write here the name that will appear in Dragon UnPACKer 4 dialog box for
# your language file (ex: English )
#
# Can be up to 80 characters
#
Name = English
#
# + Author +
# Write here your name or alias (and any comment)
#
# Can be up to 80 characters
#
Author = Alexandre Devilliers
#
# + Email +
# Write here your email
#
# Can be up to 80 characters
#
Email = dup5.translation@dragonunpacker.com
#
# + URL +
# Write here the Internet URL where your file can be downloaded
#
# Can be up to 80 characters
#
URL = http://www.dragonunpacker.com
#
# + Program Block (ProgramID & ProgramVer)
#
# DON'T CHANGE THIS UNLESS YOU KNOW WHAT YOU ARE DOING
#
#                                ID      Ver
# Dragon UnPACKer v5.0.0 Beta 1  UP       1
# Dragon UnPACKer v5.0.0 Beta 2  UP       2
# Dragon UnPACKer v5.0.0 Beta 3  UP       3
# Dragon UnPACKer v5.0.0 Beta 4  UP       3
# Dragon UnPACKer v5.0.0 RC1     UP       4
# Dragon UnPACKer v5.0.0 RC2     UP       5
# Dragon UnPACKer v5.0.0 RC3     UP       6
# Dragon UnPACKer v5.1.0         UP       7
# Dragon UnPACKer v5.1.2         UP       8
# Dragon UnPACKer v5.2.0         UP       9
# Dragon UnPACKer v5.2.0a        UP       9
# Dragon UnPACKer v5.2.0b        UP       9
# Dragon UnPACKer v5.3.0         UP       9
# Dragon UnPACKer v5.3.1         UP       9
# Dragon UnPACKer v5.3.2         UP      10
#
ProgramID = UP
ProgramVer = 10
#
# + IconFile +
# Path & FileName of the "icon" displayed with language name (ex: c:\test.bmp)
#
# This file must be a Windows Bitmap file 16x16 (Width=16 Height=16).
# The compiler will not test the file but the program will not display the
# icon if it is not a valid file.
#
# If you don't want to add an icon just comment out the line.
#
IconFile = flag_us.bmp
#
# + OutFile +
# Path & FileName of the compiled file (ex: c:\test.lng)
#
OutFile = english.lng
#
# + FontName +
# Name of the font to use to display this languages strings.
# (For ex Arial, Tahoma, etc..)
#
#FontName=Comic Sans MS
#
# + Compression +
# Compression type to use for data (language strings).
#
# Possible values:   0 = None (Default)
#                   99 = Zlib
#
Compression=99
#
{/HEADER}
#
# * Body *
#
# Each Language Keyword used in the program is followed by the string to
# appear in the program.
#
# Ex: TEST01=This is for testing purposes
#
# Each Language Keyword cannot be longer than 6 characters.
#
# Special words:
#  %n = New line
# Any other %k (where k can be any character but n) is a special keyword that
# will be replaced during Dragon UnPACKer runtime by a value.
#
# DON'T ADD/DELETE KEYWORDS UNLESS YOU KNOW WHAT YOU ARE DOING.
# THE PROGRAM WILL TEST FOR KEYWORDS AND WILL ABORT IF THERE IS AN ERROR.
#
{BODY}
MNU1=&File
MNU1S1=&Open...
MNU1S2=&Close
MNU1S3=&Quit
MNU4=&Edit
MNU4S1=&Search
MNU5=&Tools
MNU5S1=Create entry list...
MNU2=&Options
MNU2S1=Basic
MNU2S2=Drivers
MNU2S3=Look/Icons
MNU2S4=File Types
MNU2S5=Convert
MNU2S6=Plugins
MNU3=&?
MNU3S1=About
LSTCP1=File
LSTCP2=Size (Bytes)
LSTCP3=Offset
LSTCP4=Description
STAT10=object(s)
STAT20=byte(s)
ABT001=Freeware program
ABT002=Contact me:
ABT003=Internet homepage:
ABT004=Dragon UnPACKer make use of:
ABT005=Beta testing team:
ABT006=Special thanks to all the translators:
INFO99=Informations
INFO00=Driver
INFO01=Name:
INFO02=Author:
INFO03=Comment:
INFO04=Version:
INFO05=E-mail:
INFO10=File
INFO11=Format:
INFO12=Entries:
INFO13=Size:
INFO14=Load time:
INFO20=Plugin name
INFO21=Version
INFO22=Advanced Informations
INFO23=Int.Ver.:

SCHTIT=Search
SCHGRP=Options
SCH001=Case sensitive
SCH002=All files
SCH003=Current directory only
SCH004=object(s) found(s)
DIRTIT=Select the directory...
POP1S1=Extract file to...
POP1S2=Extract files to...
POP1S3=Open
POP1S4=Without Convertion
POP2S1=Extract all to...
POP2S2=Extract sub-directories to...
POP2S3=Informations
POP2S4=Full Expand
POP2S5=Full Collapse
POP3S1=Show log
POP3S2=Hide log
POP3S3=Clear log
OPTTIT=Configuration
OPT010=Temporary Directory
OPT011=Use auto-detected temporary directory
OPT012=Use defined temporary directory:
OPT013=Select temporary directory to use...
OPT020=Options for 'Open file'
OPT021=Make 'Extract file... Without conversion' the default option
OPT030=Buffer memory
OPT031=Select the size of the extraction buffer:
OPT032=No buffer / Not recommended! (Very slow)
OPT033=%d byte(s)
OPT034=%d kbytes
OPT035=%d Mbytes
OPT036=Default
OPT100=Basic options
OPT110=Language
OPT120=Options
OPT121=Do not display splash screen on startup
OPT122=Only allow one instance of the program
OPT123=Smart file format detection (at opening)
OPT124=Get icons from Windows registry (may be slower)
OPT125=Use HyperRipper if no plugin could open the file
OPT126=Show runtime log
OPT191=Those plugins will handle the convertion of file formats when extracting or previewing files. Example: Convert textures from .ART file format to .BMP
OPT192=Those plugins handle opening file formats so Dragon UnPACKer can browse into them. If a file is not supported that means no driver plugin could load it. HyperRipper handle files with another type of plugins (see below).
OPT193=Those plugins handle the file format to scan in HyperRipper (ex: MPEG Audio, BMP, etc..)
OPT200=Drivers
OPT201=About..
OPT202=Setup
OPT203=Driver plugins:
OPT210=Driver Information
OPT220=Priority :
OPT221=Refresh list
OPT300=Look/Icons
OPT310=Look Information
OPT320=Look themes (files):
OPT330=Look options
OPT331=XP-like menus and toolbar
OPT400=File Types
OPT401=Select the extensions Dragon UnPACKer should open when you will double-click them in the Explorer:
OPT402=Currently associated icon:
OPT411=None
OPT412=All
OPT420=Verify associations at start-up
OPT430=Use external icon
OPT431=Select icon file for association with Dagon UnPACKer 5...
OPT432=Icons
OPT440=Change the association text:
OPT450=Add Windows Explorer extension "%d"
OPT451=Open with Dragon UnPACKer 5
OPT500=Convert
OPT501=Convert plugins:
OPT510=Plugin information
OPT600=Plugins
OPT701=HyperRipper plugins:
OPT710=Plugin information
OPT800=Execution log
OPT810=Execution log options
OPT811=Show the execution log in main window.
OPT840=Verbose Level
OPT841=Select the amount of informations to display :
OPT850=Low - Scarce information
OPT851=Medium - A good amount of information
OPT852=High - A lot of information!

OPEN00=Open a file...
ALLCMP=Compatible files
ALLFIL=All files
XTRCAP=Extraction in progress...
XTRSTA=Extracting %f...
BUTOK=OK
BUTGO=Go!
BUTSCH=Search
BUTDIR=New Directory
BUTDET=More
BUTADD=Add
BUTDEL=Delete
BUTCNV=Convert
BUTINS=Install
BUTCAN=Cancel
BUTCLO=Close
BUTCON=Continue
BUTNEX=Next
BUTPAL=Add Palette
BUTREF=Refresh
BUTREM=Remove
BUTEDT=Edit
HYPAD=This version can only search for WAVE sound files.
HYPFIN=Type %t (Offset %o / %s bytes)
HYPOPN=Select a file to scan...
CNV000=Picture/Texture convertion
CNV001=Palette
CNV010=Note:%nUse the configuration box to manage%n(add or remove) palettes.
CNV100=Add new palette
CNV101=Source:
CNV102=Name:
CNV103=Author:
CNV104=Format:
CNV110=Raw 768bytes binary palette
CNV120=Unknown
CNV900=Error while converting the palette:%n%nSource file: %f%nSource format: %t%n%nError: %e%n%nCould not add the palette.
CNV901=Palette converted successfully!%nYou can now select it from the list.
CNV990=Palette name already exists.
CNV991=Format unknown (try changing the format).
CNV992=Do you really want to delete this palette?

TLD001=Reading %f...
TLD002=Retrieving data...
TLD003=Parsing and displaying root dir...

HR0000=About...
HR0001=The HyperRipper allows to search for "standard" file formats%nin other files that are not directly supported by Dragon UnPACKer.
HR0002=WARNING: For expert users only!
HR0003=Loaded plugins:
HR0004=Total supported formats:
HR1000=Search
HR1001=Source:
HR1002=Create HyperRipper File (HRF):
HR1003=Cancel / Stop
HR1011=Buffer size:
HR1012=Rollback size:
HR1013=Search speed:
HR1014=Found:
HR2000=Formats
HR2011=Format
HR2012=Type
HR2021=Setup
HR2022=All / None
HR3000=HyperRipper File
HR3010=Include following information:
HR3011=Title:
HR3012=URL:
HR3020=HRF Version
HR3021=Version
HR3030=Options
HR3031=Set program IDentifier to anonymous
HR3032=Don't set program version
HR3033=Maximum entry name length:
HR3034=%c characters
HR3035=Compatible with version:
HR3036=%v and earlier
HR4000=Advanced
HR4010=Buffer memory
HR4011=Kbytes
HR4012=bytes
HR4020=Memory rollback
HR4021=No Rollback (not recommended)
HR4022=Default Rollback (128 bytes)
HR4023=Big Rollback (1/4 of buffer)
HR4024=Huge Rollback (1/2 of buffer)
HR4030=Entries formatting
HR4031=Make directories using type given by plugin
HR4050=Naming
HR4051=Automatic
HR4052=Custom
HR4053=Example
HRLEGF=filename
HRLEGN=number
HRLEGX=extension
HRLEGO=offset (Dec)
HRLEGH=offset (Hex)
HRLG01=No formats selected...
HRLG02=File %f not found!
HRLG03=Opening %f...
HRLG04=Done!
HRLG05=Allocating ressources...
HRLG06=Scanning file for selected formats...
HRLG07=Could not read %b bytes from the file...
HRLG08=Found %e @ %a (%s bytes)
HRLG09=Scanned %s in %t secs!
HRLG10=bytes
HRLG11=Kb
HRLG12=Mb
HRLG13=Gb
HRLG14=Saving HRF...
HRLG15=Displaying result in Dragon UnPACKer...
HRLG16=Error while scanning... Aborting...
HRLG17=Freeing ressources...
HRLG18=Error!
HRTYP0=Unknown
HRTYP1=Audio
HRTYP2=Video
HRTYP3=Picture
HRTYPM=Other
HRTYPE=Type (%i)
HRD000=MPEG Audio Options
HRD100=MPEG Audio formats to search for
HRD101=Unofficial
HRD200=Limit by
HRD211=Minimum frame numbers:
HRD212=Maximum frame numbers:
HRD213=frame(s)
HRD221=Minimum size:
HRD222=Maximum size:
HRD223=byte(s)
HRD300=Special
HRD301=Search (and use) Xing VBR header
HRD302=Search ID3Tag v1.0/1.1

LST000=Create list
LST001=Sort
LST100=Template
LST101=Version:
LST102=Author:
LST103=Email:
LST104=URL:
LST200=List
LST201=Selected entries
LST202=All entries
LST203=Current directory
LST204=Include sub-directories
LST300=Sort by
LST301=Name
LST302=Size
LST303=Offset
LST304=Invert
LST400=WARNING: Sorting will slow down list creation...
LST500=Save list to...
LST501=Getting Header element from template...
LST502=Getting Footer element from template...
LST503=Getting Variable element from template...
LST504=Retrieving entries...
LST505=Sorting %v entries...
LST506=Computing %v entries... %p%
LST507=Saving file list...
LST508=Extracting companion files from template...
LST509=Done!

PI0000=Detected version of DUP5:
PI0001=Title
PI0002=Author
PI0003=Comment
PI0004=URL
PI0005=Package informations
PI0006=Please wait while installing package...
PI0007=This program will install the following package to the Dragon UnPACKer directory.
PI0008=Dragon UnPACKer 5 must be closed to continue the installation.
PI0009=Status:
PI0010=Waiting for user input...
PI0011=Are you sure you want to quit ?
PI0012=Error.. DUP5 is running..
PI0013=Error Dragon UnPACKer 5 is running..%nClose it and try again.
PI0014=Fatal Error.. Unsupported version of Dragon UnPACKer 5 Package file (.D5P) [version %v]
PI0015=Fatal Error.. This is not a Dragon UnPACKer 5 Package file (.D5P)
PI0016=Usage: duppi <file.d5p>%n%nThis will install the package file.d5p to the Dragon UnPACKer 5 directory.
PI0017=File not found!%n%f
PI0018=Reading package...
PI0019=The following file already exist and is newer or same as the file you try to install:%n%n%f%n%nCurrent version: %1%nFile in package: %2%n%nInstall anyway?
PI0020=The following file have bad CRC. The file will be skipped.%nIf you downloaded the file, try again.%n%n%f
PI0021=The following file have bad size. The file will be skipped.%nIf you downloaded the file, try again.%n%n%f
PI0022=Installed successfully %i file(s)...
PI0023=Installation terminated successfully...
PI0024=Installation failed (%e file(s) gave errors)...
PI0025=Installation failed... %i file(s) successfully installed and %e error(s)...
PI0026=Path to Dragon UnPACKer 5 not found.%nPlease run Dragon UnPACKer 5 at least once before trying again.
PI0027=Skipping...
PI0028=Kb
PI0029=Reading...
PI0030=Decompressing...
PI0031=Writing...
PI0032=OK
PI0033=Version
PI0034=This program allows you to install packages for Dragon UnPACKer 5.
PI0035=What would you like to do ?
PI0036=Check on internet for new or updated packages and install them.
PI0037=Note: Absolutly no data is sent to Dragon Software web site.
PI0038=Proxy Options
PI0039=Install a package from the hard disk:
PI0040=Select the package to install...
PI0041=To install this Dragon UnPACKer 5 Package (D5P) file you need a newer Duppi version.%nYour Duppi version: %y%nNeeded Duppi version: %v%n%nPlease update your Dragon UnPACKer 5!
PI0042=This package cannot be installed with your version of Dragon UnPACKer.
PI0043=Unable to register %s.
PI0044=Bad data received from the update server!

PII001=Title
PII002=Your Version
PII003=Available Version
PII004=Description
PII005=Size
PII011=Show updates:
PII012=Plugins
PII013=Translations
PII021=Current stable version :
PII022=Current WIP version :
PII030=Translation
PII031=Revision
PII032=Author
PII100=updates list
PII101=Downloading %f...
PII102=Downloading %f (%b bytes received)
PII103=Successfully received %f (%b bytes)
PII104=Error: %c (%d)
PII105=Server contacted successfully!
PII106=-No description-
PII107=A new version of Dragon UnPACKer is available to download.%n%nNew version: %v%nComment: %c%n%nDo you want to go to the official homepage to download it?
PII108=%p plugin(s) and %t translation(s) available!

PII200=No update could be downloaded.%nThe program will now stop.

PIEM01=Database connection error. Please try again later!
PIEM10=Error while retrieving latest stable version info!
PIEM11=Error while retrieving latest WIP version info!
PIEM20=Error while retrieving your version info!
PIEM30=Error while retrieving available convert plugins!
PIEM31=Error while retrieving available driver plugins!
PIEM32=Error while retrieving available HyperRipper plugins!
PIEM33=Error while retrieving available translations!
PIEP01=Wrong parameter! If you have not run Dragon UnPACKer do it and re-run Duppi afterwards.
PIEP02=The server did not recognize your Dragon UnPACKer version...
PIEUNK=Unknown server error: "%e"

PIP000=Proxy configuration
PIP001=Proxy:
PIP002=Proxy port:
PIP003=Proxy needs Username/Password:
PIP004=Username:
PIP005=Password:

11TH01=To activate support for 11th Hour game files the plugin needs to copy two files that can be found in the GROOVIE directory of the CDRom of The 11th Hour.%n%nDo you want to continue ?
11TH02=Select the %f file from 11th Hour...
11TH03=The plugin is now activated.%nNow you can open 11th Hour GJD files!
11TH04=Disabling 11th Hour support will remove the following files:%n%n%a%n%b%n%nYou will be able to recreate them by enabling 11th Hour support again later using your 11th Hour CDRom.%n%nAre you sure you want to continue?
11TH05=Plugin status: %s%n(Enabled means you can open files)%n(Disabled means you need to import GJD.GJD and DIR.RL)
11TH06=Disabled
11TH07=Enabled
11TH10=11th Hour plugin configuration
11TH11=Enable
11TH12=Disable
11TH13=Current status:
11TH14=The 11th Hour support:

DUT100=Configuration
DUT101=Library
DUT110=ID
DUT111=Path
DUT112=Game Hint
DUT113=DA?
DUT114=GID
DUT201=From which game is the package you are opening ?
DUT202=Don't ask again for this directory
DUT203=- Unknown / Other -

EX=File %e
EXANIM=Animation (%e)
EXART=Art Package (Textures)
EXBIN=Data (%e)
EXCFG=Configuration (%e)
EXDLL=Dynamic Link Library
EXFIRE=Fire Texture (Dynamic)
EXIMG=Image %e (%d)
EXMAP=Level Map (%e)
EXMDL=3D Model (%e)
EXMPEG=MPEG Audio/Video
EXMUS=Music (%d)
EXPAL=Palette
EXSCRP=Script (%e)
EXSND=Sound (%d)
EXSPR=Sprite
EXTEX=Texture (%e)
EXTXT=Text Document

LOG001=Initializing plugins:
LOG002=Loading Drivers plugins...
LOG003=Loading Convert plugins...
LOG004=Loading HyperRipper plugins...
LOG009=%p plugin(s)
LOG101=Opening "%f" file:
LOG102=File format not recognized!
LOG103=Starting HyperRipper...
LOG104=File not found (or is locked by another program)...
LOG200=Closing current file...
LOG300=Displaying entries of "%d" directory...
LOG301=%e entries...
LOG400=Using SmartOpen to detect format of source file.
LOG500=Driver plugin "%d" thinks it can open this file.
LOG501=Opening the file using "%d" plugin...
LOG502=Retrieving %x entries...
LOG503=Parsing entries for directories...
LOG504=File successfully opened using "%p" plugin (detected format: "%f")
LOG510=Done!
LOG511=Success!
LOG512=Failed!
LOG513=Error!

ERR000=Error
ERR101=Error while extracting.
ERR102=Error while extracting file:
ERR200=The following unhandled error happened:
ERR201=From:
ERR202=Exception:
ERR203=Message:
ERR204=If you want to do an error report please include following details (push the "More" button).
ERR205=Copy to clipboard
ERR206=Send bug report to:
ERRCAL=Error while calling:
ERRCMP=Following needed companion file not found:%n%n%f
ERREMP=File is empty.
ERREXT=Error while extracting data (File mode) from %f driver:
ERRSTM=Error while extracting data (Stream mode) from %f driver:
ERRFIL=This file is not a valid %f file (%g).
ERROPN=Error while opening source file:%n%n%f
ERRUNK=No driver could load this file.
ERRTMP=Unable to remove following temporary file:%n%n%f
ERRD01=Driver could not be loaded (bad interface version or not a DUP5 driver).
ERRD02=Driver could not be loaded (missing important functions).
ERRDRV=Error while using the "%d" driver:
ERRDR1=For more information about this error please contact the driver's author (%a).
ERRC01=Convert plugin could not be loaded (bad interface version or not a DUP5 convert plugin).
ERRC02=Convert plugin could not be loaded (missing important functions).
ERRC10=Error while converting palette.%nImpossible to add the new palette.
ERRH01=HyperRipper plugin could not be loaded (bad interface version or not a DUP5 HyperRipper plugin).
ERRH02=HyperRipper plugin could not be loaded (missing important functions).
ERRIO=Could not open the following file:%n%n%f%n%nCheck if it isn't available anymore or if it is opened in another program.
ERR900=Missing %f function in plugin...

{/BODY}
#
# End of Language Source File
#
{/LSF}
