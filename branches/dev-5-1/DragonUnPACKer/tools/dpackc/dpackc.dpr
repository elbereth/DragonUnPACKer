program dpackc;

// $Id: dpackc.dpr,v 1.1.1.1 2004-05-08 10:26:59 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/tools/dpackc/dpackc.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is dpackc.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

uses
  Forms,
  Main in 'Main.pas' {frmMain},
  Config in 'Config.pas' {frmPackCfg},
  Compile in 'Compile.pas' {frmCompile},
  lib_bincopy in '..\..\common\lib_bincopy.pas',
  lib_crc in '..\..\common\lib_crc.pas',
  lib_language in '..\..\common\lib_language.pas',
  lib_utils in '..\..\common\lib_utils.pas',
  lib_version in '..\..\common\lib_version.pas',
  lib_zlib in '..\..\common\lib_zlib.pas',
  spec_DLNG in '..\..\common\spec_DLNG.pas',
  spec_DUPP in '..\..\common\spec_DUPP.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Dragon UnPACKer 5 Package Maker';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmPackCfg, frmPackCfg);
  Application.CreateForm(TfrmCompile, frmCompile);
  Application.Run;
end.
