; $Id: setup.iss,v 1.2 2004-05-08 14:26:38 elbereth Exp $
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
Compression=lzma/max
SolidCompression=yes
AppName=Dragon UnPACKer 5
AppVerName=Dragon UnPACKer v5.0.0.129 Release Candidate 4
AppPublisher=Elbereth Zone
AppPublisherURL=http://www.elberethzone.net
AppSupportURL=http://www.dragonunpacker.com
AppUpdatesURL=http://www.dragonunpacker.com
DefaultDirName={pf}\Dragon UnPACKer 5
DefaultGroupName=Dragon UnPACKer 5
OutputBaseFilename=dup500rc4-setup
AppMutex=DragonUnPACKer5
AppId=DragonUnPACKer5
DisableStartupPrompt=yes
UninstallDisplayName=Dragon UnPACKer 5
UninstallDisplayIcon={app}\dunpacker5.exe
WizardImageBackColor=$FFFFFF
WizardImageFile=dup5-instimage.bmp
WizardSmallImageFile=dup5-inst55x55.bmp
VersionInfoVersion=5.0.0.129
; uncomment the following line if you want your installation to run on NT 3.51 too.
MinVersion=4.10,4

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"; InfoBeforeFile: "H:\Programmation\CVS\DragonUnPACKer\DragonUnPACKer\install\setup-info-english.rtf"
Name: "sp"; MessagesFile: "SpanishStd-1-4.1.4.isl"; InfoBeforeFile: "H:\Programmation\CVS\DragonUnPACKer\DragonUnPACKer\install\setup-info-spanish.rtf"
Name: "fr"; MessagesFile: "compiler:languages\French.isl"; InfoBeforeFile: "H:\Programmation\CVS\DragonUnPACKer\DragonUnPACKer\install\setup-info-french.rtf"

[Tasks]
Name: "desktopicon"; Languages: en; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; MinVersion: 4,4
Name: "quicklaunchicon"; Languages: en; Description: "Create a &Quick Launch icon"; GroupDescription: "Additional icons:"; MinVersion: 4,4; Flags: unchecked
Name: "desktopicon"; Languages: fr; Description: "Placer une icone sur le bureau"; GroupDescription: "Icones supplémentaires:"; MinVersion: 4,4
Name: "quicklaunchicon"; Languages: fr; Description: "Placer une icone sur la barre de lancement rapide"; GroupDescription: "Icones supplémentaires:"; MinVersion: 4,4; Flags: unchecked
Name: "desktopicon"; Languages: sp; Description: "Poner un icono sobre el desktop"; GroupDescription: "Iconos adicionales:"; MinVersion: 4,4
Name: "quicklaunchicon"; Languages: sp; Description: "Poner un icono en la bara de lanzamiento rapido"; GroupDescription: "Iconos adicionales:"; MinVersion: 4,4; Flags: unchecked

[Files]
Source: "H:\Programmation\Compiled\drgunpacker\current\drgunpack5.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "H:\Programmation\Compiled\drgunpacker\current\drgunpack5.exe.sig"; DestDir: "{app}"; Flags: ignoreversion
Source: "H:\Programmation\Compiled\drgunpacker\current\data\*.*"; DestDir: "{app}\data";  Flags: ignoreversion
Source: "H:\Programmation\Compiled\drgunpacker\current\data\drivers\*.*"; DestDir: "{app}\data\drivers"; Flags: ignoreversion
Source: "H:\Programmation\Compiled\drgunpacker\current\data\convert\*.*"; DestDir: "{app}\data\convert"; Flags: ignoreversion
Source: "H:\Programmation\Compiled\drgunpacker\current\data\hyperripper\*.*"; DestDir: "{app}\data\hyperripper"; Flags: ignoreversion
Source: "H:\Programmation\Compiled\drgunpacker\current\utils\*.*"; DestDir: "{app}\utils"; Flags: ignoreversion
Source: "H:\Programmation\Compiled\drgunpacker\current\utils\templates\*.*"; DestDir: "{app}\utils\templates\"; Flags: ignoreversion
Source: "H:\Programmation\Compiled\drgunpacker\current\utils\translation\*.*"; DestDir: "{app}\utils\translation\"; Flags: ignoreversion
Source: "H:\Programmation\Compiled\drgunpacker\current\file_id.diz"; DestDir: "{app}"; Flags: ignoreversion
Source: "H:\Programmation\Compiled\drgunpacker\current\historique.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "H:\Programmation\Compiled\drgunpacker\current\lisezmoi.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "H:\Programmation\Compiled\drgunpacker\current\readme.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "H:\Programmation\Compiled\drgunpacker\current\whatsnew.txt"; DestDir: "{app}"; Flags: ignoreversion

[INI]
Filename: "{app}\DrgUnPack5.url"; Section: "InternetShortcut"; Key: "URL"; String: "http://www.dragonunpacker.com"

[Icons]
Name: "{group}\Dragon UnPACKer 5"; Filename: "{app}\DrgUnPack5.exe"
Name: "{group}\Dragon UnPACKer 5 on the Web"; Filename: "{app}\DrgUnPack5.url"
Name: "{group}\Duppi (Package installer & Internet update)"; Filename: "{app}\utils\Duppi.exe"
Name: "{userdesktop}\Dragon UnPACKer 5"; Filename: "{app}\DrgUnPack5.exe"; MinVersion: 4,4; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\Dragon UnPACKer 5"; Filename: "{app}\DrgUnPack5.exe"; MinVersion: 4,4; Tasks: quicklaunchicon
Name: "{group}\Uninstall"; Filename: "{uninstallexe}"

[Run]
Languages: en; Filename: "{app}\DrgUnPack5.exe"; Description: "Launch Dragon UnPACKer 5 to finish installation"; Flags: nowait postinstall skipifsilent
Languages: fr; Filename: "{app}\DrgUnPack5.exe"; Description: "Lancer Dragon UnPACKer 5 pour finir l'installation"; Flags: nowait postinstall skipifsilent
Languages: sp; Filename: "{app}\DrgUnPack5.exe"; Description: "Lanzar Dragon UnPACKer 5 para terminar la instalacion"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\DrgUnPack5.url"

