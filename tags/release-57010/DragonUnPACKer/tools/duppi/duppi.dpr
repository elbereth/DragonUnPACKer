program duppi;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is duppi.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

{$DEFINE DUPPI}
{$WARN SYMBOL_PLATFORM OFF}

uses
  FastMM4,
  FastCode,
  FastMove,
  Forms,
  Installer in 'Installer.pas' {frmInstaller},
  Proxy in 'Proxy.pas' {frmProxy},
  lib_bincopy in '..\..\common\lib_bincopy.pas',
  lib_crc in '..\..\common\lib_crc.pas',
  lib_language in '..\..\common\lib_language.pas',
  lib_utils in '..\..\common\lib_utils.pas',
  lib_version in '..\..\common\lib_version.pas',
  lib_zlib in '..\..\common\lib_zlib.pas',
  spec_DLNG in '..\..\common\spec_DLNG.pas',
  spec_DUPP in '..\..\common\spec_DUPP.pas',
  lib_BinUtils in '..\..\common\lib_BinUtils.pas',
  lib_temptools in '..\..\common\lib_temptools.pas';

{$R duppi.rec}
{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Dragon UnPACKer 5 Package Installer';
  Application.CreateForm(TfrmInstaller, frmInstaller);
  Application.CreateForm(TfrmProxy, frmProxy);
  Application.Run;
end.
