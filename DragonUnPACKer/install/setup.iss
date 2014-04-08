; This Source Code Form is subject to the terms of the Mozilla Public
; License, v. 2.0. If a copy of the MPL was not distributed with this
; file, You can obtain one at http://mozilla.org/MPL/2.0/.
;
; The Original Code is setup.iss, released May 8, 2004.
;
; The Initial Developer of the Original Code is Alexandre Devilliers
; (elbereth@users.sourceforge.net, http://www.elberethzone.net).

[Setup]
Compression=lzma2/ultra64
LZMAUseSeparateProcess=yes
SolidCompression=true
AppName=Dragon UnPACKer 5
AppVerName=Dragon UnPACKer v5.7.0 Beta (unstable)
AppPublisher=Alexandre Devilliers (aka Elbereth)
AppPublisherURL=http://www.elberethzone.net
AppSupportURL=http://www.elberethzone.net/dup-support.html
AppUpdatesURL=http://www.dragonunpacker.com
AppCopyright=Mozilla Public License 1.1
DefaultDirName={pf}\Dragon UnPACKer 5
DefaultGroupName=Dragon UnPACKer 5
OutputBaseFilename=dup570beta-setup
AppMutex=DragonUnPACKer5
AppId=DragonUnPACKer5
DisableStartupPrompt=true
UninstallDisplayName=Dragon UnPACKer 5
UninstallDisplayIcon={app}\drgunpack5.exe
WizardImageBackColor=$ffffff
WizardImageFile=dup5-instimage.bmp
WizardSmallImageFile=dup5-inst55x55.bmp
VersionInfoVersion=5.7.0
MinVersion=5.0
LicenseFile=..\docs\core\source\LICENCE.txt
InternalCompressLevel=ultra64
VersionInfoDescription=Dragon UnPACKer 5 Setup
VersionInfoTextVersion=5.7.0 Beta
VersionInfoCopyright=Elbereth / MPL 1.1
VersionInfoProductName=Dragon UnPACKer
VersionInfoProductVersion=5.7.0
AppVersion=5.7.0 Beta
SetupIconFile=..\tools\duppi\duppi.ico
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
Name: deleteoldhrplugins; Description: Remove old useless plugins/dlls; GroupDescription: Update from previous versions; Flags: checkedonce; Languages: en
Name: deleteoldhrplugins; Description: Supprimer les anciennes extensions/dlls inutiles; GroupDescription: Mise à jour depuis une ancienne version; Flags: checkedonce; Languages: fr
Name: deleteoldhrplugins; Description: Borrar las antiguas versiones de las extenciones/dlls; GroupDescription: Antiguas versiones; Flags: checkedonce; Languages: sp

[Files]
Source: E:\Developpement\dup-compiled-release\drgunpack5.exe; DestDir: {app}; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\drgunpack5.exe.sig; DestDir: {app}; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\data\*.*; DestDir: {app}\data; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\data\drivers\*.*; DestDir: {app}\data\drivers; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\data\convert\*.*; DestDir: {app}\data\convert; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\data\themes\Default\*.*; DestDir: {app}\data\themes\Default; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\data\themes\Default\16x16\*.*; DestDir: {app}\data\themes\Default\16x16; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\data\themes\Default\16x16\Types\*.*; DestDir: {app}\data\themes\Default\16x16\Types; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\data\themes\Default\32x32\*.*; DestDir: {app}\data\themes\Default\32x32; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\utils\*.*; DestDir: {app}\utils; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\utils\data\*.*; DestDir: {app}\utils\data; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\utils\templates\*.*; DestDir: {app}\utils\templates\; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\utils\translation\*.*; DestDir: {app}\utils\translation\; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\file_id.diz; DestDir: {app}; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\historique.txt; DestDir: {app}; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\lisezmoi.txt; DestDir: {app}; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\readme.txt; DestDir: {app}; Flags: ignoreversion
Source: E:\Developpement\dup-compiled-release\whatsnew.txt; DestDir: {app}; Flags: ignoreversion
; For WIP versions
Source: E:\Developpement\dup-compiled-release\readme-WIP.txt; DestDir: "{app}"; Flags: ignoreversion

[INI]
Filename: {app}\DrgUnPack5.url; Section: InternetShortcut; Key: URL; String: http://www.dragonunpacker.com

[Icons]
Name: {group}\Dragon UnPACKer 5; Filename: {app}\DrgUnPack5.exe
; vvv --- sp --- vvv
Name: {group}\Read me; Languages: en sp; Filename: {app}\readme.txt
; For WIP versions
Name: "{group}\Read me (Unstable releases)"; Languages: en; Filename: "{app}\readme-WIP.txt"
Name: "{group}\Lisez moi (version instable) [Anglais]"; Languages: fr; Filename: "{app}\readme-WIP.txt"
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
Name: {app}\data\default.dulk; Type: files; Tasks: 
Name: {app}\data\drivers\drv_11th.d5d; Type: files; Tasks: 
Name: {app}\data\drivers\drv_mix.d5d; Type: files; Tasks: 
Name: {app}\data\drivers\drv_giants.d5d; Type: files; Tasks: 
Name: {app}\data\drivers\unzip32.dll; Type: files; Tasks: 
Name: {app}\utils\libcurl-3.dll; Type: files; Tasks: 
Name: {app}\utils\zlib1.dll; Type: files; Tasks: 
Name: {app}\data\HyperRipper\*.d5h; Type: files; Tasks: 
Name: {app}\data\HyperRipper; Type: dirifempty; Tasks: 

[Registry]
Root: HKCR; SubKey: DUP5.Files; ValueData: ""; Flags: UninsDeleteKey DeleteKey;
Root: HKCR; SubKey: DUP5.Packages; ValueData: ""; Flags: UninsDeleteKey DeleteKey;
Root: HKCU; SubKey: Software\Dragon Software\Dragon UnPACKer 5; ValueData: ""; Flags: UninsDeleteValue;
Root: HKCU; SubKey: Software\Dragon Software; ValueData: ""; Flags: UninsDeleteKeyIfEmpty; 
