; $Id: setup.iss,v 1.15 2009-09-12 06:41:06 elbereth Exp $
; $Source: /home/elbzone/backup/cvs/DragonUnPACKer/install/setup.iss,v $
;
; The contents of this file are subject to the Mozilla Public License
; Version 1.1 (the "License"); you may not use this file except in compliance
; with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
;
; Software distributed under the License is distributed on an "AS IS" basis,
; WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
; specific language governing rights and limitations under the License.
;
; The Original Code is setup.iss, released May 8, 2004.
;
; The Initial Developer of the Original Code is Alexandre Devilliers
; (elbereth@users.sourceforge.net, http://www.elberethzone.net).

[Setup]
Compression=lzma/ultra64
SolidCompression=true
AppName=Dragon UnPACKer 5
AppVerName=Dragon UnPACKer v5.5.1 Beta (build 226/unstable)
AppPublisher=Alexandre Devilliers (aka Elbereth)
AppPublisherURL=http://www.elberethzone.net
AppSupportURL=http://www.elberethzone.net/dup-support.html
AppUpdatesURL=http://www.dragonunpacker.com
AppCopyright=Mozilla Public License 1.1
DefaultDirName={pf}\Dragon UnPACKer 5
DefaultGroupName=Dragon UnPACKer 5
OutputBaseFilename=dup551beta-setup
AppMutex=DragonUnPACKer5
AppId=DragonUnPACKer5
DisableStartupPrompt=true
UninstallDisplayName=Dragon UnPACKer 5
UninstallDisplayIcon={app}\drgunpack5.exe
WizardImageBackColor=$ffffff
WizardImageFile=dup5-instimage.bmp
WizardSmallImageFile=dup5-inst55x55.bmp
VersionInfoVersion=5.5.1.226
; uncomment the following line if you want your installation to run on NT 3.51 too.
MinVersion=4.10,4.0sp6
LicenseFile=..\docs\core\source\LICENCE.txt
InternalCompressLevel=ultra64
VersionInfoDescription=Dragon UnPACKer 5 Setup
VersionInfoTextVersion=5.5.1 Beta (Build 226)
VersionInfoCopyright=Elbereth / MPL 1.1
VersionInfoProductName=Dragon UnPACKer
VersionInfoProductVersion=5.5.1.226
AppVersion=5.5.1 Beta
SetupIconFile=E:\Developpement\dup-HEAD-2008\DragonUnPACKer\tools\duppi\duppi.ico
AppReadmeFile={app}\readme.txt

[Languages]
Name: en; MessagesFile: compiler:Default.isl; InfoBeforeFile: setup-info-english.rtf
Name: sp; MessagesFile: compiler:languages\Spanish.isl; InfoBeforeFile: setup-info-spanish.rtf
Name: fr; MessagesFile: compiler:languages\French.isl; InfoBeforeFile: setup-info-french.rtf

[Tasks]
Name: desktopicon; Languages: en; Description: Create a &desktop icon; GroupDescription: Additional icons:; MinVersion: 4,4
Name: quicklaunchicon; Languages: en; Description: Create a &Quick Launch icon; GroupDescription: Additional icons:; MinVersion: 4,4; Flags: unchecked
Name: desktopicon; Languages: fr; Description: Placer une icone sur le bureau; GroupDescription: Icones supplémentaires:; MinVersion: 4,4
Name: quicklaunchicon; Languages: fr; Description: Placer une icone sur la barre de lancement rapide; GroupDescription: Icones supplémentaires:; MinVersion: 4,4; Flags: unchecked
Name: desktopicon; Languages: sp; Description: Poner un icono sobre el desktop; GroupDescription: Iconos adicionales:; MinVersion: 4,4
Name: quicklaunchicon; Languages: sp; Description: Poner un icono en la bara de lanzamiento rapido; GroupDescription: Iconos adicionales:; MinVersion: 4,4; Flags: unchecked
Name: deleteoldhrplugins; Description: Remove old useless plugins; GroupDescription: Update from previous versions; Flags: checkedonce; Languages: en
Name: deleteoldhrplugins; Description: Supprimer les anciennes extensiosn; GroupDescription: Mise à jour depuis une ancienne version; Flags: checkedonce; Languages: fr
Name: deleteoldhrplugins; Description: Borrar las antiguas versiones de las extenciones; GroupDescription: Antiguas versiones; Flags: checkedonce; Languages: sp

[Files]
Source: E:\Developpement\dup-dev-5.1-compiled\drgunpack5.exe; DestDir: {app}; Flags: ignoreversion
Source: E:\Developpement\dup-dev-5.1-compiled\drgunpack5.exe.sig; DestDir: {app}; Flags: ignoreversion
Source: E:\Developpement\dup-dev-5.1-compiled\data\*.*; DestDir: {app}\data; Flags: ignoreversion
Source: E:\Developpement\dup-dev-5.1-compiled\data\drivers\*.*; DestDir: {app}\data\drivers; Flags: ignoreversion
Source: E:\Developpement\dup-dev-5.1-compiled\data\convert\*.*; DestDir: {app}\data\convert; Flags: ignoreversion
Source: E:\Developpement\dup-dev-5.1-compiled\utils\*.*; DestDir: {app}\utils; Flags: ignoreversion
Source: E:\Developpement\dup-dev-5.1-compiled\utils\data\*.*; DestDir: {app}\utils\data; Flags: ignoreversion
Source: E:\Developpement\dup-dev-5.1-compiled\utils\templates\*.*; DestDir: {app}\utils\templates\; Flags: ignoreversion
Source: E:\Developpement\dup-dev-5.1-compiled\utils\translation\*.*; DestDir: {app}\utils\translation\; Flags: ignoreversion
Source: E:\Developpement\dup-dev-5.1-compiled\file_id.diz; DestDir: {app}; Flags: ignoreversion
Source: E:\Developpement\dup-dev-5.1-compiled\historique.txt; DestDir: {app}; Flags: ignoreversion
Source: E:\Developpement\dup-dev-5.1-compiled\lisezmoi.txt; DestDir: {app}; Flags: ignoreversion
Source: E:\Developpement\dup-dev-5.1-compiled\readme.txt; DestDir: {app}; Flags: ignoreversion
Source: E:\Developpement\dup-dev-5.1-compiled\whatsnew.txt; DestDir: {app}; Flags: ignoreversion
; For WIP versions
;Source: "E:\Developpement\dup-dev-5.1-compiled\readme-WIP.txt"; DestDir: "{app}"; Flags: ignoreversion

[INI]
Filename: {app}\DrgUnPack5.url; Section: InternetShortcut; Key: URL; String: http://www.dragonunpacker.com

[Icons]
Name: {group}\Dragon UnPACKer 5; Filename: {app}\DrgUnPack5.exe
; vvv --- sp --- vvv
Name: {group}\Read me; Languages: en sp; Filename: {app}\readme.txt
; For WIP versions
;Name: "{group}\Read me (Unstable releases)"; Languages: en; Filename: "{app}\readme-WIP.txt"
;Name: "{group}\Lisez moi (version instable) [Anglais]"; Languages: fr; Filename: "{app}\readme-WIP.txt"
Name: {group}\Lisez moi; Languages: fr; Filename: {app}\lisezmoi.txt
; vvv --- sp --- vvv
Name: {group}\What's new; Languages: en sp; Filename: {app}\whatsnew.txt
Name: {group}\Historique des versions; Languages: fr; Filename: {app}\historique.txt
Name: {group}\Dragon UnPACKer 5 on the Web; Languages: en; Filename: {app}\DrgUnPack5.url
Name: {group}\Dragon UnPACKer 5 sur le Web; Languages: fr; Filename: {app}\DrgUnPack5.url
Name: {group}\Dragon UnPACKer 5 sobre la Red; Languages: sp; Filename: {app}\DrgUnPack5.url
Name: {group}\Duppi (Package installer & Internet update); Languages: en; Filename: {app}\utils\Duppi.exe
Name: {group}\Duppi (Installation de packets et mise à jour via Internet); Languages: fr; Filename: {app}\utils\Duppi.exe
Name: {group}\Duppi (Instalador de paquetes y puestas al dia por Internet); Languages: sp; Filename: {app}\utils\Duppi.exe
Name: {userdesktop}\Dragon UnPACKer 5; Filename: {app}\DrgUnPack5.exe; MinVersion: 4,4; Tasks: desktopicon
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\Dragon UnPACKer 5; Filename: {app}\DrgUnPack5.exe; MinVersion: 4,4; Tasks: quicklaunchicon
Name: {group}\Uninstall; Filename: {uninstallexe}

[Run]
Languages: en; Filename: {app}\DrgUnPack5.exe; Parameters: /lng; Description: Launch Dragon UnPACKer 5 to finish installation; Flags: nowait postinstall skipifsilent
Languages: fr; Filename: {app}\DrgUnPack5.exe; Parameters: /lng; Description: Lancer Dragon UnPACKer 5 pour finir l'installation; Flags: nowait postinstall skipifsilent
Languages: sp; Filename: {app}\DrgUnPack5.exe; Parameters: /lng; Description: Lanzar Dragon UnPACKer 5 para terminar la instalacion; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: {app}\DrgUnPack5.url

[InstallDelete]
Name: {app}\data\drivers\drv_mix.d5d; Type: files; Tasks: 
Name: {app}\data\drivers\drv_giants.d5d; Type: files; Tasks: 
Name: {app}\data\HyperRipper\*.d5h; Type: files; Tasks: 
Name: {app}\data\HyperRipper; Type: dirifempty; Tasks: 
