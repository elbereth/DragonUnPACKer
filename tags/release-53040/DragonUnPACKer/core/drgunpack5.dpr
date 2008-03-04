program drgunpack5;

// $Id: drgunpack5.dpr,v 1.6 2008-03-04 06:16:34 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/drgunpack5.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is drgunpack5.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

uses
  About in 'About.pas' {frmAbout},
  DrvInfo in 'DrvInfo.pas' {frmDrvInfo},
  Error in 'Error.pas' {frmError},
  HyperRipper in 'HyperRipper.pas' {frmHyperRipper},
  List in 'List.pas' {frmList},
  Main in 'Main.pas' {dup5Main},
  Options in 'Options.pas' {frmConfig},
  Search in 'Search.pas' {frmSearch},
  SelectLanguage in 'SelectLanguage.pas' {frmSelectLanguage},
  Splash in 'Splash.pas' {frmSplash},
  Dialogs,
  Forms,
  Messages,
  Registry,
  SysUtils,
  Windows,
  auxFSE in 'auxFSE.pas',
  class_duht in 'class_duht.pas',
  classConvert in 'classConvert.pas',
  classFSE in 'classFSE.pas',
  classHyperRipper in 'classHyperRipper.pas',
  classIconsFromExt in 'classIconsFromExt.pas',
  declFSE in 'declFSE.pas',
  HashTrie in 'HashTrie.pas',
  lib_bincopy in '..\common\lib_bincopy.pas',
  lib_binUtils in '..\common\lib_binUtils.pas',
  lib_crc in '..\common\lib_crc.pas',
  lib_language in '..\common\lib_language.pas',
  lib_look in 'lib_look.pas',
  lib_Percent in 'lib_Percent.pas',
  lib_Utils in '..\common\lib_Utils.pas',
  lib_Zlib in '..\common\lib_zlib.pas',
  prg_ver in 'prg_ver.pas',
  spec_DLNG in '..\common\spec_DLNG.pas',
  spec_DUHT in '..\common\spec_DUHT.pas',
  spec_DULK in '..\common\spec_DULK.pas',
  Translation in 'Translation.pas',
  spec_HRF in '..\common\spec_HRF.pas',
  commonTypes in '..\common\commonTypes.pas',
  U_IntList in '..\common\U_IntList.pas';

{$R *.res}

{$R 'icones.res' 'icones.rc'}
{$R 'images.res' 'images.rc'}

var  IsTestRunning : Boolean = False;

function CheckImportantFiles(): Boolean;
begin

  result := FileExists(ExtractFilePath(Application.ExeName)+'data\default.dulk');
//  result := result and FileExists(ExtractFilePath(Application.ExeName)+'data\drivers\drv_default.d5d');

end;

function CheckLanguage(): Boolean;
var Reg: TRegistry;
begin

  CheckLanguage := True;

  if ParamStr(1) = '/lng' then
  begin
    CheckLanguage := False;
  end
  else
  begin
    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin
        CheckLanguage := Reg.ValueExists('Language');
        Reg.CloseKey;
      end;
    Finally
      Reg.Free;
    end;
  end;

end;

function CheckByPass(): Boolean;
var Reg: TRegistry;
begin

  CheckByPass := False;

  if Not(CheckLanguage) or Not(CheckImportantFiles) then
  begin
    CheckByPass := False;
  end
  else
  begin
    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin
        if Reg.ValueExists('NoSplash') then
          CheckByPass := Reg.ReadBool('NoSplash')
        else
          CheckByPass := false;
        Reg.CloseKey;
      end;
    Finally
      Reg.Free;
    end;
  end;

end;

function CheckOneOnly(): Boolean;
var Reg: TRegistry;
begin

  CheckOneOnly := False;

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      if Reg.ValueExists('OneInstanceOnly') then
        CheckOneOnly := Reg.ReadBool('OneInstanceOnly')
      else
        CheckOneOnly := false;
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

function DoTest(): boolean;
begin

  DoTest := True;
  if Not(CheckLanguage) then
  begin
    with TfrmSelectLanguage.Create(nil) do
    try
      ShowModal;
    finally
      free;
    end;
  end;
  if Not(FileExists(ExtractFilePath(Application.ExeName)+'data\default.dulk')) then
  begin
    MessageDlg('Needed file not found:'+#10+'\data\default.dulk'+#10+#10+'Please reinstall Dragon UnPACKer 5.',mtError,[mbOk],0);
    DoTest := False;
  end;

end;

var hwnd : word = 0;
    x: integer;
    res: boolean;
    hProcess: THandle;
begin

  // Set CPU affinity to first processor only
  // This fixes the problem with 1686603 (Problem with AMD Dual Core CPU's)
  hProcess := OpenProcess( PROCESS_ALL_ACCESS, FALSE, GetCurrentProcessID() );
  SetProcessAffinityMask(hProcess,1);

  if CheckOneOnly then
    hwnd := FindWindow('Tdup5Main', nil)
  else
    hwnd := 0;

  if hwnd<>0 then
  begin
    for x:=1 to length(ParamStr(1)) do
    begin
      PostMessage(hwnd, wm_User, ord(ParamStr(1)[x]), 0);
    end;
    PostMessage(hwnd, wm_User, 0, 0);
  end
  else begin
    CreateMutex(nil, False, 'DragonUnPACKer5');
    with TfrmSplash.Create(nil) do
    try
      if CheckByPass then
        Visible := False
      else
      begin
        If (pos('WIP',CurEdit) > 0) then
          imgWIP.Visible := true;
        If (pos('RC',CurEdit) > 0) then
          imgRC.Visible := true;
        If (pos('Beta',CurEdit) > 0) then
          imgBeta.Visible := true;
        If (pos('Alpha',CurEdit) > 0) then
          imgAlpha.Visible := true;
        Show;
        Update;
      end;
      res := DoTest;
      if res then
      begin
        Application.Initialize;
        Application.Title := 'Dragon UnPACKer 5';
        Application.CreateForm(Tdup5Main, dup5Main);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmSearch, frmSearch);
  Application.CreateForm(TfrmDrvInfo, frmDrvInfo);
  Application.CreateForm(TfrmConfig, frmConfig);
  Application.CreateForm(TfrmHyperRipper, frmHyperRipper);
  Application.CreateForm(TfrmList, frmList);
  Application.CreateForm(TfrmError, frmError);
  end;
    finally
      TimerClose.Enabled := true;
    end;
    if res then
    begin
      Application.Run;
    end;
  end;


end.
