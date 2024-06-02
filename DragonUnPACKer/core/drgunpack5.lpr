program drgunpack5;

{$MODE Delphi}

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is drgunpack5.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

{DEFINE DRGUNPACK is defined in the project options}

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
  classIconsFromExt in 'classIconsFromExt.pas',
  HashTrie in 'HashTrie.pas',
  lib_bincopy in '..\common\lib_bincopy.pas',
  lib_binUtils in '..\common\lib_binUtils.pas',
  lib_crc in '..\common\lib_crc.pas',
  lib_language in '..\common\lib_language.pas',
  lib_look in 'lib_look.pas',
  lib_Utils in '..\common\lib_Utils.pas',
  lib_Zlib in '..\common\lib_zlib.pas',
  prg_ver in 'prg_ver.pas',
  spec_DLNG in '..\common\spec_DLNG.pas',
  spec_DUHT in '..\common\spec_DUHT.pas',
  Translation in 'Translation.pas',
  spec_HRF in '..\common\spec_HRF.pas',
  commonTypes in '..\common\commonTypes.pas',
  U_IntList in '..\common\U_IntList.pas',
  BrowseForFolderU in '..\common\BrowseForFolderU.pas',
  spec_DDS in '..\common\spec_DDS.pas',
  MpegAudioOptions in 'MpegAudioOptions.pas' {frmOptMPEGa},
  MsgBox in 'MsgBox.pas' {frmMsgBox},
  classConvertExport, lib_temptools, cls_duplog, lib_version, ComCtrls,
  Interfaces, cls_dupcommands, lib_pe32,
  spec_DUDI;

const _DEBUGMODE = TRUE;

var     dupLog: TDupLog;

// TODO: replace with .lrs in the future
{$R *.res}

{$R 'icones.res' 'icones.rc'}
{$R 'images.res' 'images.rc'}

// =============================================================================
//  CheckLanguage                                                      function
// -----------------------------------------------------------------------------
// Check from registry the value of the option Language (String) exists.
// By default returns False if the value do not exists.
// Also force value to False if first parameter of Dragon UnPACKer 5 is "/lng"
// =============================================================================
function CheckLanguage(): Boolean;
var Reg: TRegistry;
begin

  result := False;

  // Only check the value in registry if first parameter is not "/lng"
  if not(ParamStr(1) = '/lng') then
  begin

    // Create the TRegistry object
    Reg := TRegistry.Create;
    Try

      // Settings are stored per USER (HKEY_CURRENT_USER)
      Reg.RootKey := HKEY_CURRENT_USER;

      // Open path to Dragon UnPACKer 5 start up options
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin

        // Check that the Language key exists in registry
        result := Reg.ValueExists('Language');

        // Close the Key
        Reg.CloseKey;
      end;

    Finally
      // Free the TRegistry object
      FreeAndNil(Reg);
    end;
  end;

end;

// =============================================================================
//  CheckByPass                                                        function
// -----------------------------------------------------------------------------
// Retrieve from registry the value of the option NoSplash (Boolean).
// By default returns False if the value do not exists.
// =============================================================================
function CheckByPass(): Boolean;
var Reg: TRegistry;
begin

  // Default returns False (avoid warnings because of try block)
  result := False;

  // Create the TRegistry object
  Reg := TRegistry.Create;
  Try

    // Settings are stored per USER (HKEY_CURRENT_USER)
    Reg.RootKey := HKEY_CURRENT_USER;

    // Open path to Dragon UnPACKer 5 start up options
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin

      // Check that the NoSplash key exists in registry
      // If it does read it
      // Else return False
      if Reg.ValueExists('NoSplash') then
        result := Reg.ReadBool('NoSplash')
      else
        result := false;

      // Close the Key
      Reg.CloseKey;

    end;
  Finally
    // Free the TRegistry object
    FreeAndNil(Reg);
  end;

end;

// =============================================================================
//  CheckOneOnly                                                       function
// -----------------------------------------------------------------------------
// Retrieve from registry the value of the option OneInstanceOnly (Boolean).
// By default returns False if the value do not exists.
// =============================================================================
function CheckOneOnly(): Boolean;
var Reg: TRegistry;
begin

  // Default returns False (avoid warnings because of try block)
  result := False;

  // Create the TRegistry object
  Reg := TRegistry.Create;
  Try

    // Settings are stored per USER (HKEY_CURRENT_USER)
    Reg.RootKey := HKEY_CURRENT_USER;

    // Open path to Dragon UnPACKer 5 start up options
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin

      // Check that the OneInstanceOnly key exists in registry
      // If it does read it
      // Else return False
      if Reg.ValueExists('OneInstanceOnly') then
        result := Reg.ReadBool('OneInstanceOnly')
      else
        result := false;

      // Close the Key
      Reg.CloseKey;
    end;
  Finally
    // Free the TRegistry object
    FreeAndNil(Reg);
  end;

end;

// =============================================================================
//  DoTest                                                             function
// -----------------------------------------------------------------------------
// Test everything needed by Dragon UnPACKer to run is set & files exists.
// This was used in some Alphas/Beta to check if at least the main plugin
// existed but was later removed.
//
// This functions tests if a language was selected (first run of Dragon UnPACKer
// and if not displays a language selection windows.
// =============================================================================
function DoTest(): boolean;
begin

  // Default result if True (everything OK)
  result := True;

  dupLog.AddMessage(' + Sanity check - CheckLanguage',sevDebug);

  // If the CheckLanguage returns false
  if Not(CheckLanguage) then
  begin

    dupLog.AddMessage(' = Missing language setting --> Creating select language form',sevDebug);

    // Create the select language form
    with TfrmSelectLanguage.Create(nil) do
    try
      dupLog.AddMessage(' + Displaying Select Language form',sevDebug);
      // Display the form as modal
      ShowModal;
    finally
      dupLog.AddMessage(' + Freeing Select Language form',sevDebug);
      // Free the form, we don't need it anymore
      free;
    end;

  end;

end;

// =============================================================================
//  MAIN                                                                   MAIN
// =============================================================================
var hwnd : word = 0;
    x: integer;
    res: boolean = false;
    compileTime: TDateTime;
//    hProcess: THandle;
begin

  // Create the logging facility and start logging
  dupLog := TDupLog.Create();

  if _DEBUGMODE then
    dupLog.enableLogIntoFile(Application.ExeName+'.debug.'+FormatDateTime('yyyymmddhhnnsszzz',Now)+'.log');

  compileTime := GetExecutableCompilationDateTime();
  if CurEdit = '' then
    dupLog.addMessage('Dragon UnPACKer v' + CurVersion + ' (Build ' + IntToStr(CurBuild) +' - '+DateToStr(compileTime)+ ' '+TimeToStr(compileTime)+')',sevHigh)
  else
    dupLog.addMessage('Dragon UnPACKer v' + CurVersion + ' ' + CurEdit + ' (Build ' + IntToStr(CurBuild)  +' - '+DateToStr(compileTime)+ ' '+TimeToStr(compileTime)+')',sevHigh);

  { Removed because I fixed the root of the problem in the thread execution stuff
  // Set CPU affinity to first processor only
  // This fixes the problem with 1686603 (Problem with AMD Dual Core CPU's)
  hProcess := OpenProcess( PROCESS_ALL_ACCESS, FALSE, GetCurrentProcessID() );
  SetProcessAffinityMask(hProcess,1);}

  dupLog.AddMessage('Checking if Dragon UnPACKer is already running...',sevDebug);

  // If only one instance can be run at once, search if a Dragon UnPACKer 5 windows exists
  // and retrieve the handle
  if CheckOneOnly then
    hwnd := FindWindow('Tdup5Main', nil)
  else
    hwnd := 0;

  dupLog.AddMessage(' = hwnd: '+inttostr(hwnd),sevDebug);

  // If the windows was found
  // We send the parameters to the existing dragon unpacker by posting
  // messages to the handle
  if hwnd<>0 then
  begin
    dupLog.AddMessage(' + Existing window was found so we send parameter to the existing instance',sevDebug);
    dupLog.AddMessage(' + ParamStr(1)='+ParamStr(1),sevDebug);

    for x:=1 to length(ParamStr(1)) do
    begin
      PostMessage(hwnd, wm_User, ord(ParamStr(1)[x]), 0);
    end;
    PostMessage(hwnd, wm_User, 0, 0);
    dupLog.AddMessage(' = PostMessage done',sevDebug);
  end
  // If not we create a Mutex and start Dragon UnPACKer
  else begin

    dupLog.AddMessage('Create the mutex',sevDebug);
    dupLog.flushMessages();

    // The Mutex is used by Duppi to check if Dragon UnPACKer is running.
    CreateMutex(nil, False, 'DragonUnPACKer5');

    dupLog.AddMessage('Create the Splash screen',sevDebug);
    dupLog.flushMessages();

    // Create the Splash screen
    Application.Initialize;
    with TfrmSplash.Create(nil) do
    try

      dupLog.AddMessage(' + Check if the Splash screen should be visible',sevDebug);

      // Check if need to display the splash screen
      if CheckByPass then
      begin
        dupLog.AddMessage(' = Visible := False',sevDebug);
        Visible := False
      end
      else
      begin
        dupLog.AddMessage(' = Visible := True',sevDebug);
        dupLog.AddMessage('Display special images for WIP/RC/Beta/Alpha',sevDebug);

        // Check if need to display WIP/RC/Beta/Alpha image
        If (pos('WIP',CurEdit) > 0) or (pos('SVN',CurEdit) > 0) or (pos('Nightly',CurEdit) > 0) then
        begin
          dupLog.AddMessage(' + WIP/Nightly detected',sevDebug);
          imgWIP.Visible := true;
        end;
        If (pos('RC',CurEdit) > 0) then
        begin
          dupLog.AddMessage(' + RC detected',sevDebug);
          imgRC.Visible := true;
        end;
        If (pos('Beta',CurEdit) > 0) then
        begin
          dupLog.AddMessage(' + Beta detected',sevDebug);
          imgBeta.Visible := true;
        end;
        If (pos('Alpha',CurEdit) > 0) then
        begin
          dupLog.AddMessage(' + Alpha detected',sevDebug);
          imgAlpha.Visible := true;
        end;

        dupLog.AddMessage(' = Showing splash screen',sevDebug);

        // Show & Update the splash screen
        Show;
        dupLog.AddMessage(' = Updating splash screen',sevDebug);
        Update;

      end;

      dupLog.AddMessage('Execute sanity checks',sevDebug);

      // Test everything needed to run Dragon UnPACKer is present
      res := DoTest;

      // If everything is OK
      if res then
      begin
        dupLog.AddMessage(' = Sanity Checks are OK',sevDebug);
        dupLog.AddMessage('Application.Initialize;',sevDebug);
        dupLog.AddMessage('Application.CreateForm(Tdup5Main, dup5Main)',sevDebug);
        Application.CreateForm(Tdup5Main, dup5Main);
  dup5Main.setLogFacility(dupLog);
        dupLog.AddMessage('Application.CreateForm(TfrmAbout, frmAbout)',sevDebug);
        Application.CreateForm(TfrmAbout, frmAbout);
        dupLog.AddMessage('Application.CreateForm(TfrmSearch, frmSearch)',sevDebug);
        Application.CreateForm(TfrmSearch, frmSearch);
        dupLog.AddMessage('Application.CreateForm(TfrmDrvInfo, frmDrvInfo)',sevDebug);
        Application.CreateForm(TfrmDrvInfo, frmDrvInfo);
        dupLog.AddMessage('Application.CreateForm(TfrmConfig, frmConfig)',sevDebug);
        Application.CreateForm(TfrmConfig, frmConfig);
        dupLog.AddMessage('Application.CreateForm(TfrmHyperRipper, frmHyperRipper)',sevDebug);
        Application.CreateForm(TfrmHyperRipper, frmHyperRipper);
        dupLog.AddMessage('Application.CreateForm(TfrmList, frmList)',sevDebug);
        Application.CreateForm(TfrmList, frmList);
        dupLog.AddMessage('Application.CreateForm(TfrmError, frmError)',sevDebug);
        Application.CreateForm(TfrmError, frmError);
        dupLog.AddMessage('Application.CreateForm(TfrmOptMPEGa, frmOptMPEGa)',sevDebug);
        Application.CreateForm(TfrmOptMPEGa, frmOptMPEGa);
        dupLog.AddMessage('Application.CreateForm(TfrmMsgBox, frmMsgBox)',sevDebug);
        Application.CreateForm(TfrmMsgBox, frmMsgBox);
      end;
    finally
      dupLog.AddMessage('Activate timer to close the Splash screen',sevDebug);
      // When everything is loaded we start the close timer
      TimerClose.Enabled := true;
    end;

    // If everything is OK
    if res then
    begin

      dupLog.AddMessage('Adding special error handling',sevDebug);

      // Global Error handling
      Application.OnException := frmError.OnAppliException;

      dupLog.AddMessage('Run Application',sevDebug);

      // Execute application
      Application.Run;

      if Assigned(dupLog) then
        dupLog.Free;

    end;
  end;

end.
