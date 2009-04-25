# Language Source File (for DLNGC v4.0)
# ============================================================================
#  Program: Duppi v3.0.0 (Dragon UnPACKer)
# Language: English
#  Version: 1
#   Author: Alex Devilliers
# ============================================================================
#
# This file is the model for translations of Duppi (Dragon UnPACKer Package
# Installer).
#
# Just translate everything between {BODY} and {/BODY}
#
# Then compile the file with DLNGC and put the resulting .LNG file into the
# \Utils\ sub-directory of Dragon UnPACKer (along with Duppi.exe file).
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
# version 1:
# Initial release
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
# Duppi v3.0.0                   PI       1
#
ProgramID = PI
ProgramVer = 1
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
PI0045=Unknown destination directory!
PI0046=Update of Duppi successfull!
PI0047=A new version of Duppi is available:%nYour version: %a%nAvailable version: %b%nUpdate size: %s Kbytes%n%nDo you want to update now (Recommended)?
PI0048=Also show unstables (alpha/beta/RC)
PI0049=No URL for Duppi update!
PI0050=A new version of Dragon UnPACKer is available to download.%n%nNew version: %v%nUpdate size: %s Kbytes%nComment: %c%n%nDo you want to update now (Recommended)?

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
PIEM10=Error while retrieving latest core stable version info!
PIEM11=Error while retrieving latest core unstable version info!
PIEM12=Error while retrieving core stable update information!
PIEM13=Error while retrieving core unstable update information!
PIEM20=Error while retrieving your version info!
PIEM30=Error while retrieving available stable convert plugins!
PIEM31=Error while retrieving available stable driver plugins!
PIEM32=Error while retrieving available stable HyperRipper plugins!
PIEM33=Error while retrieving available translations!
PIEM40=Error while retrieving list of servers!
PIEM41=Error while retrieving available stable+unstable driver plugins!
PIEM42=Error while retrieving available stable+unstable convert plugins!
PIEM43=Error while retrieving available stable+unstable HyperRipper plugins!
PIEM60=Error while retrieving latest Duppi version info!
PIEP01=Wrong parameter! If you have not run Dragon UnPACKer do it and re-run Duppi afterwards.
PIEP02=The server did not recognize your Dragon UnPACKer version...
PIEUNK=Unknown server error: "%e"

PIP000=Proxy configuration
PIP001=Proxy:
PIP002=Proxy port:
PIP003=Proxy needs Username/Password:
PIP004=Username:
PIP005=Password:

BUTADD=Add
BUTCAN=Cancel
BUTCLO=Close
BUTCNV=Convert
BUTCON=Continue
BUTDEL=Delete
BUTDET=More
BUTDIR=New Directory
BUTEDT=Edit
BUTGO=Go!
BUTINS=Install
BUTNEX=Next
BUTOK=OK
BUTPAL=Add Palette
BUTREF=Refresh
BUTREM=Remove
BUTSCH=Search

{/BODY}
#
# End of Language Source File
#
{/LSF}
