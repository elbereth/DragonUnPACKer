program drgunpack5;

// $Id: drgunpack5.dpr,v 1.3 2004-07-17 19:25:31 elbereth Exp $
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
  spec_HRF in '..\common\spec_HRF.pas';

{$R *.res}

{$R 'icones.res' 'icones.rc'}
{$R 'images.res' 'images.rc'}

var  IsTestRunning : Boolean = False;

function CheckImportantFiles(): Boolean;
begin

  result := FileExists(ExtractFilePath(Application.ExeName)+'data\default.dulk');
//  result := result and FileExists(ExtractFilePath(Application.ExeName)+'data\drivers\drv_default.d5d');
//  CheckImportantFiles := FileExists(ExtractFilePath(Application.ExeName)+'data\default.dulk') and FileExists(ExtractFilePath(Application.ExeName)+'data\drivers\drv_giants.dup5');

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
  end
{  else if Not(FileExists(ExtractFilePath(Application.ExeName)+'data\drivers\drv_default.d5d')) then
  begin
    MessageDlg('Needed file not found:'+#10+'\data\drivers\drv_default.d5d'+#10+#10+'Please reinstall Dragon UnPACKer 5.',mtError,[mbOk],0);
    DoTest := False;
  end;}

end;

var hwnd : word = 0;
    x: integer;
    res: boolean;
//    T: TextFile;
begin

{  AssignFile(T, 'debug.txt');
  if FileExists('debug.txt') then
    Reset(T)
  else
    Rewrite(T);

  writeln(T,DateTimeToStr(Now)+' - Starting DUP5...');  }

  if CheckOneOnly then
    hwnd := FindWindow('Tdup5Main', nil)
  else
    hwnd := 0;

//  writeln(T,DateTimeToStr(Now)+' - hwnd='+inttostr(hwnd));

  if hwnd<>0 then
  begin
//    writeln(T,DateTimeToStr(Now)+' - ParamStr(1)='+paramstr(1)+' / '+inttostr(length(paramstr(1))));
    for x:=1 to length(ParamStr(1)) do
    begin
      PostMessage(hwnd, wm_User, ord(ParamStr(1)[x]), 0);
      //Showmessage(IntTostr(ord(ParamStr(1)[x])));
    end;
    PostMessage(hwnd, wm_User, 0, 0);
//    writeln(T,DateTimeToStr(Now)+' - Message posted to old instance');
  end
  else begin
//    writeln(T,DateTimeToStr(Now)+' - Creating MUTEX');
    CreateMutex(nil, False, 'DragonUnPACKer5');
//    writeln(T,DateTimeToStr(Now)+' - Creating Splash window');
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
//        writeln(T,DateTimeToStr(Now)+' - Visible - Show()');
        Show;
//        writeln(T,DateTimeToStr(Now)+' - Visible - Update()');
        Update;
//        writeln(T,DateTimeToStr(Now)+' - Visible - Done!');
      end;
//      writeln(T,DateTimeToStr(Now)+' - Testing...');
      res := DoTest;
//      writeln(T,DateTimeToStr(Now)+' - Testing... '+booltostr(res,true));
{      if CheckByPass then
      begin
        TimerBlend.Enabled := False;
        TimerLoad.Enabled := True;
        frmSplash.Visible := False;
      end
      else
        TimerBlend.Enabled := True;
 }
      if res then
      begin
//        writeln(T,DateTimeToStr(Now)+' - Application.Initialize');
        Application.Initialize;
//        writeln(T,DateTimeToStr(Now)+' - Application.Title');
        Application.Title := 'Dragon UnPACKer 5';
      //Application.CreateForm(TfrmSplash, frmSplash);
      //Application.CreateForm(TfrmSelectLanguage, frmSelectLanguage);
//        writeln(T,DateTimeToStr(Now)+' - Application.CreateForm(Tdu5main)');
        Application.CreateForm(Tdup5Main, dup5Main);
  //      writeln(T,DateTimeToStr(Now)+' - Application.CreateForm(TAbout)');
        Application.CreateForm(TfrmAbout, frmAbout);
    //    writeln(T,DateTimeToStr(Now)+' - Application.CreateForm(TfrmSearch)');
        Application.CreateForm(TfrmSearch, frmSearch);
      //  writeln(T,DateTimeToStr(Now)+' - Application.CreateForm(TfrmDrvInfo)');
        Application.CreateForm(TfrmDrvInfo, frmDrvInfo);
        //writeln(T,DateTimeToStr(Now)+' - Application.CreateForm(TfrmConfig)');
        Application.CreateForm(TfrmConfig, frmConfig);
        //writeln(T,DateTimeToStr(Now)+' - Application.CreateForm(TfrmDirSelect)');
        //Application.CreateForm(TfrmDirSelect, frmDirSelect);
        //writeln(T,DateTimeToStr(Now)+' - Application.CreateForm(TfrmHyperRipper)');
        Application.CreateForm(TfrmHyperRipper, frmHyperRipper);
        //writeln(T,DateTimeToStr(Now)+' - Application.CreateForm(TfrmList)');
        Application.CreateForm(TfrmList, frmList);
        //writeln(T,DateTimeToStr(Now)+' - Application.CreateForm(TfrmError)');
        Application.CreateForm(TfrmError, frmError);
      end;
    finally
      //writeln(T,DateTimeToStr(Now)+' - Enabling TimerClose');
      TimerClose.Enabled := true;
    end;
//    writeln(T,DateTimeToStr(Now)+' - '+booltostr(res)+' RUN');
  //  CloseFile(T);
    if res then
    begin
      Application.Run;
    end;
  end;


end.
