program drgunpack5;

// $Id$
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

{$DEFINE DRGUNPACK}

uses
  FastMM4,
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
  U_IntList in '..\common\U_IntList.pas',
  BrowseForFolderU in '..\common\BrowseForFolderU.pas',
  spec_DDS in '..\common\spec_DDS.pas',
  MpegAudioOptions in 'MpegAudioOptions.pas' {frmOptMPEGa},
  MsgBox in 'MsgBox.pas' {frmMsgBox},
  classConvertExport in 'classConvertExport.pas',
  lib_temptools in '..\common\lib_temptools.pas';

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

  // If the CheckLanguage returns false
  if Not(CheckLanguage) then
  begin

    // Create the select language form
    with TfrmSelectLanguage.Create(nil) do
    try
      // Display the form as modal
      ShowModal;
    finally
      // Free the form, we don't need it anymore
      free;
    end;

  end;

  // If the default LOOK file do not exists
  // Return false because this is a needed file.
  if Not(FileExists(ExtractFilePath(Application.ExeName)+'data\default.dulk')) then
  begin
    // Displays an english error message, cannot send translated message because the language files are not loaded yet
    MessageDlg('Needed file not found:'+#10+'\data\default.dulk'+#10+#10+'Please reinstall Dragon UnPACKer 5.',mtError,[mbOk],0);
    result := False;
  end;

end;

// =============================================================================
//  MAIN                                                                   MAIN
// =============================================================================
var hwnd : word = 0;
    x: integer;
    res: boolean = false;
//    hProcess: THandle;
begin

  { Removed because I fixed the root of the problem in the thread execution stuff
  // Set CPU affinity to first processor only
  // This fixes the problem with 1686603 (Problem with AMD Dual Core CPU's)
  hProcess := OpenProcess( PROCESS_ALL_ACCESS, FALSE, GetCurrentProcessID() );
  SetProcessAffinityMask(hProcess,1);}

  // If only one instance can be run at once, search if a Dragon UnPACKer 5 windows exists
  // and retrieve the handle
  if CheckOneOnly then
    hwnd := FindWindow('Tdup5Main', nil)
  else
    hwnd := 0;

  // If the windows was found
  // We send the parameters to the existing dragon unpacker by posting
  // messages to the handle
  if hwnd<>0 then
  begin
    for x:=1 to length(ParamStr(1)) do
    begin
      PostMessage(hwnd, wm_User, ord(ParamStr(1)[x]), 0);
    end;
    PostMessage(hwnd, wm_User, 0, 0);
  end
  // If not we create a Mutex and start Dragon UnPACKer
  else begin

    // The Mutex is used by Duppi to check if Dragon UnPACKer is running.
    CreateMutex(nil, False, 'DragonUnPACKer5');

    // Create the Splash screen
    with TfrmSplash.Create(nil) do
    try

      // Check if need to display the splash screen
      if CheckByPass then
        Visible := False
      else
      begin

        // Check if need to display WIP/RC/Beta/Alpha image
        If (pos('WIP',CurEdit) > 0) then
          imgWIP.Visible := true;
        If (pos('RC',CurEdit) > 0) then
          imgRC.Visible := true;
        If (pos('Beta',CurEdit) > 0) then
          imgBeta.Visible := true;
        If (pos('Alpha',CurEdit) > 0) then
          imgAlpha.Visible := true;

        // Show & Update the splash screen
        Show;
        Update;

      end;

      // Test everything needed to run Dragon UnPACKer is present
      res := DoTest;

      // If everything is OK
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
  Application.CreateForm(TfrmOptMPEGa, frmOptMPEGa);
  Application.CreateForm(TfrmMsgBox, frmMsgBox);
  end;
    finally
      // When everything is loaded we start the close timer
      TimerClose.Enabled := true;
    end;

    // If everything is OK
    if res then
    begin

      // Global Error handling
      Application.OnException := frmError.OnAppliException;

      // Execute application
      Application.Run;

    end;
  end;

end.
