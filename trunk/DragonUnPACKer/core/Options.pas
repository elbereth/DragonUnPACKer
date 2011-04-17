unit Options;

// $Id: Options.pas,v 1.12 2010-04-21 15:51:00 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/Options.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is Options.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ImgList, StdCtrls, ExtCtrls, Registry, declFSE,
  CheckLst, Main, lib_look, ShellApi, BrowseForFolderU,classConvertExport;

type
  TfrmConfig = class(TForm)
    cmdOk: TButton;
    imgLstLangue: TImageList;
    tabBasic: TPanel;
    grpLanguage: TGroupBox;
    strAuthor: TLabel;
    lblAuthor: TLabel;
    strEmail: TLabel;
    strURL: TLabel;
    lblEmail: TLabel;
    lblURL: TLabel;
    lstLangues: TComboBoxEx;
    grpOptions: TGroupBox;
    ChkNoSplash: TCheckBox;
    tabLook: TPanel;
    lstLook: TListBox;
    grpLookInfo: TGroupBox;
    strLookName: TLabel;
    strLookAuthor: TLabel;
    strLookEmail: TLabel;
    lblLookName: TLabel;
    lblLookAuthor: TLabel;
    lblLookEmail: TLabel;
    strLookComment: TLabel;
    Panel2: TPanel;
    lblLookComment: TLabel;
    tabPlugins: TPanel;
    cmdDrvSetup: TButton;
    grpDrvInfo: TGroupBox;
    strDrvInfoAuthor: TLabel;
    lblDrvInfoAuthor: TLabel;
    strDrvInfoVersion: TLabel;
    lblDrvInfoVersion: TLabel;
    strDrvInfoComments: TLabel;
    Panel1: TPanel;
    lblDrvInfoComments: TLabel;
    cmdDrvAbout: TButton;
    strDriversList: TLabel;
    strLookList: TLabel;
    tabAssoc: TGroupBox;
    ChkOneInstance: TCheckBox;
    ChkSmartOpen: TCheckBox;
    tabConvert: TPanel;
    strConvertList: TLabel;
    treeConfig: TTreeView;
    cmdCnvSetup: TButton;
    cmdCnvAbout: TButton;
    grpCnvInfo: TGroupBox;
    strCnvInfoAuthor: TLabel;
    lblCnvInfoAuthor: TLabel;
    strCnvInfoVersion: TLabel;
    lblCnvInfoVersion: TLabel;
    strCnvInfoComments: TLabel;
    Panel3: TPanel;
    lblCnvInfoComments: TLabel;
    chkRegistryIcons: TCheckBox;
    chkUseHyperRipper: TCheckBox;
    lstDrivers2: TListView;
    grpAdvInfo: TGroupBox;
    lblDUDI: TLabel;
    txtDUDI: TStaticText;
    lblIntVer: TLabel;
    txtIntVer: TStaticText;
    lblPriority: TLabel;
    trkPriority: TTrackBar;
    txtPriority: TStaticText;
    butRefresh: TButton;
    lstConvert2: TListView;
    grpCnvAdvInfo: TGroupBox;
    lblDUCI: TLabel;
    lblCIntVer: TLabel;
    txtDUCI: TStaticText;
    txtCIntVer: TStaticText;
    tabLog: TPanel;
    grpLogVerbose: TGroupBox;
    grpLogOptions: TGroupBox;
    strVerbose: TLabel;
    trackbarVerbose: TTrackBar;
    lblVerbose: TLabel;
    chkLog: TCheckBox;
    tabAdvanced: TPanel;
    grpAdvOpenFile: TGroupBox;
    grpAdvTemp: TGroupBox;
    grpAdvBufferSize: TGroupBox;
    lblBufferSize: TLabel;
    chkMakeExtractDefault: TCheckBox;
    txtTmpDir: TEdit;
    butTmpDirSelect: TButton;
    cmdTypesNone: TButton;
    cmdTypesAll: TButton;
    chkAssocOpenWith: TCheckBox;
    imgAssocIcon: TImage;
    txtAssocText: TEdit;
    chkAssocText: TCheckBox;
    chkAssocCheckStartup: TCheckBox;
    chkAssocExtIcon: TCheckBox;
    txtAssocExtIcon: TEdit;
    lblAssocInfo: TLabel;
    lblAssocCurIcon: TLabel;
    imgAssocIcon16: TImage;
    tabPluginsInfos: TPanel;
    grpPluginsInfo: TGroupBox;
    lblPluginsConvert: TLabel;
    panPluginsConvert: TPanel;
    lblPluginsConvertInfo: TLabel;
    lblPluginsDrivers: TLabel;
    panPluginsDrivers: TPanel;
    lblPluginsDriversInfo: TLabel;
    butAssocExtIconBrowse: TButton;
    radTmpDirDefault: TRadioButton;
    radTmpDirOther: TRadioButton;
    txtTmpDirDefault: TEdit;
    lstBufferSize: TComboBox;
    tabPreview: TPanel;
    grpPreviewBasic: TGroupBox;
    chkPreviewEnable: TCheckBox;
    grpPreviewLimits: TGroupBox;
    optPreviewLimitNo: TRadioButton;
    optPreviewLimitYes: TRadioButton;
    lstPreviewLimit: TComboBox;
    lblPreviewLimit: TLabel;
    lblPreviewLimitBytes: TLabel;
    txtPreviewLimitSize: TLabel;
    grpPreviewDisplay: TGroupBox;
    optPreviewDisplayFull: TRadioButton;
    optPreviewDisplayStretch: TRadioButton;
    lblFindNewLanguages: TLabel;
    lstTypes: TCheckListBox;
    chkLogClearNew: TCheckBox;
    chkAutoExpand: TCheckBox;
    chkKeepFilterIndex: TCheckBox;
    grpDriversIntegrity: TGroupBox;
    chkAccept0Bytes: TCheckBox;
    procedure lstLanguesSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmdOkClick(Sender: TObject);
    procedure ChkNoSplashClick(Sender: TObject);
    procedure lstDriversClick(Sender: TObject);
    procedure lstLookClick(Sender: TObject);
    procedure cmdTypesAllClick(Sender: TObject);
    procedure cmdTypesNoneClick(Sender: TObject);
    procedure lstTypesClickCheck(Sender: TObject);
    procedure ChkOneInstanceClick(Sender: TObject);
    procedure ChkSmartOpenClick(Sender: TObject);
    procedure cmdDrvAboutClick(Sender: TObject);
    procedure treeConfigChange(Sender: TObject; Node: TTreeNode);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure chkRegistryIconsClick(Sender: TObject);
    procedure cmdDrvSetupClick(Sender: TObject);
    procedure cmdCnvAboutClick(Sender: TObject);
    procedure cmdCnvSetupClick(Sender: TObject);
    procedure chkUseHyperRipperClick(Sender: TObject);
    procedure lstDrivers2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lstDrivers2Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure trkPriorityChange(Sender: TObject);
    procedure butRefreshClick(Sender: TObject);
    procedure lstConvert2Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure chkLogClick(Sender: TObject);
    procedure trackbarVerboseChange(Sender: TObject);
    procedure chkAssocExtIconClick(Sender: TObject);
    procedure butAssocExtIconBrowseClick(Sender: TObject);
    procedure txtAssocExtIconChange(Sender: TObject);
    procedure chkAssocTextClick(Sender: TObject);
    procedure txtAssocTextChange(Sender: TObject);
    procedure chkAssocOpenWithClick(Sender: TObject);
    procedure chkAssocCheckStartupClick(Sender: TObject);
    procedure butTmpDirSelectClick(Sender: TObject);
    procedure radTmpDirOtherClick(Sender: TObject);
    procedure txtTmpDirChange(Sender: TObject);
    procedure chkMakeExtractDefaultClick(Sender: TObject);
    procedure lstBufferSizeChange(Sender: TObject);
    procedure chkPreviewEnableClick(Sender: TObject);
    procedure optPreviewLimitNoClick(Sender: TObject);
    procedure lstPreviewLimitChange(Sender: TObject);
    procedure optPreviewLimitYesClick(Sender: TObject);
    procedure optPreviewDisplayFullClick(Sender: TObject);
    procedure optPreviewDisplayStretchClick(Sender: TObject);
    procedure lblFindNewLanguagesMouseEnter(Sender: TObject);
    procedure lblFindNewLanguagesMouseLeave(Sender: TObject);
    procedure lblFindNewLanguagesClick(Sender: TObject);
    procedure lstTypesClick(Sender: TObject);
    procedure chkLogClearNewClick(Sender: TObject);
    procedure chkAutoExpandClick(Sender: TObject);
    procedure chkKeepFilterIndexClick(Sender: TObject);
    procedure chkAccept0BytesClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    procedure trackbarVerboseUpdateHint;
    procedure updateAssocIcon;
    { Déclarations publiques }
  end;

  procedure LOOKList();

var
  frmConfig: TfrmConfig;
  TabSelect: integer = 0;

implementation

{$R *.dfm}

uses lib_language, translation,spec_DULK,lib_binUtils,lib_Utils;

var lngFiles: array[1..100] of String;
    numLngFiles: byte;
    Loading: Boolean = False;

procedure TfrmConfig.lstLanguesSelect(Sender: TObject);
var Name,Author,URL,Email,FontName: string;
    IsIcon: boolean;
    Reg: TRegistry;
begin

  if lstLangues.ItemIndex = 0 then
  begin
    lblAuthor.Caption := 'Alexandre Devilliers';
    lblEmail.Caption := 'dup5.translation@dragonunpacker.com';
    lblURL.Caption := 'http://www.dragonunpacker.com';
    LoadInternalLanguage;
  end
  else
    if GetLanguageInfo(ExtractFilePath(Application.ExeName)+'data\'+lngFiles[lstLangues.ItemIndex],Name,Author,URL,Email,FontName,IsIcon) then
    begin
      lblAuthor.Caption := Author;
      lblEmail.Caption := Email;
      lblURL.Caption := URL;
      LoadLanguage(ExtractFilePath(Application.ExeName)+'data\'+lngFiles[lstLangues.ItemIndex]);
    end;

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      Reg.WriteString('Language',curlanguage);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  if Not(Loading) then
  begin
    TranslateOptions;
    TranslateMain;
  end;

end;

procedure LNGList();
var sr: TSearchRec;
    Name,Author,URL,Email,FontName: string;
    itmx : TComboExItem;
    IsIcon: Boolean;
    Sel, IcnIdx: integer;
    Icn: TBitmap;
begin

  Icn := TBitmap.Create;
  frmConfig.imgLstLangue.GetBitmap(0,Icn);
  frmConfig.imgLstLangue.Clear;
  frmConfig.imgLstLangue.Add(Icn,Nil);
  frmConfig.lstLangues.Clear;
  itmx := frmConfig.lstLangues.ItemsEx.Add;
  itmx.Caption := 'Français (French)';
  itmx.ImageIndex := 0;

  Sel := 0;

  if FindFirst(ExtractFilePath(Application.ExeName)+'data\*.lng',0,sr) = 0 then
  begin

    repeat
      if GetLanguageInfo(ExtractFilePath(Application.ExeName)+'data\'+sr.Name,Name,Author,URL,Email,FontName,IsIcon) then
      begin
        itmx := frmConfig.lstLangues.ItemsEx.Add;
        itmx.Caption := Name;
        numLngFiles := numLngFiles + 1;
        lngFiles[numLngFiles] := sr.Name;
        if sr.Name = curlanguage then
          Sel := itmx.Index;
        if IsIcon then
        begin
          Icn := GetIcon(ExtractFilePath(Application.ExeName)+'data\'+sr.Name);
          Icn.TransparentColor := clBlack;
          Icn.Transparent := True;
          IcnIdx := frmConfig.imgLstLangue.Add(icn,nil);

          if IcnIdx <> -1 then
            itmx.ImageIndex := IcnIdx;
        end;

      end;
    until FindNext(sr) <> 0;

    FindClose(sr);
  end;

  frmConfig.lstLangues.ItemIndex := Sel;

end;

procedure DRVList();
var x : integer;
    itmx : TListItem;
begin

  frmConfig.lstDrivers2.Clear;
  for x := 1 to FSE.NumDrivers do
  begin
    itmx := frmConfig.lstDrivers2.Items.Add;
    itmx.Caption := inttostr(FSE.Drivers[x].Priority);
    itmx.SubItems.Add(FSE.Drivers[x].Info.Name);
    itmx.SubItems.Add(FSE.Drivers[x].Info.Version);
    itmx.SubItems.Add(ChangeFileExt(FSE.Drivers[x].FileName,''));
  end;

  if FSE.NumDrivers > 0 then
  begin
    frmConfig.lstDrivers2.ItemIndex := 0;
  end;

end;

procedure CONVList();
var x : integer;
    itmx : TListItem;
    info : ConvertInfoEx;
begin

  frmConfig.lstConvert2.Clear;
  for x := 1 to CPlug.getNumPlugins() do
  begin
    itmx := frmConfig.lstConvert2.Items.Add;
    info := CPlug.getPluginInfo(x);
    itmx.Caption := info.Name;
    itmx.SubItems.Add(info.Version);
    itmx.SubItems.Add(ChangeFileExt(info.FileName,''));
  end;

  if CPlug.getNumPlugins() > 0 then
  begin
    frmConfig.lstConvert2.ItemIndex := 0;
  end;

end;

function RemoveIllegalChars(str: string): string;
var x : integer;
    res : string;
begin

  for x := 1 to length(str) do
    if str[x] <> '*' then
      res := res + str[x];

  RemoveIllegalChars := res;

end;

procedure TYPEList();
var str,tmp: string;
    x: integer;
begin

  str := FSE.GetAllFileTypes(False).Lists[1];

  frmConfig.lstTypes.Clear;

  while (pos(';',str) <> 0) do
  begin
    tmp := Copy(str,0,pos(';',str)-1);
    if pos('.',tmp) <> 0 then
      tmp := Copy(tmp,posrev('.',tmp)+1,length(tmp)-posrev('.',tmp));
    tmp := UpperCase(RemoveIllegalChars(tmp));
    if frmConfig.lstTypes.Items.IndexOf(tmp) = -1 then
      frmConfig.lstTypes.Items.Add(tmp);
    str := Copy(str,pos(';',str)+1,length(str)-length(tmp));
  end;

  if pos('.',str) <> 0 then
    str := Copy(str,posrev('.',str)+1,length(str)-posrev('.',str));
  str := UpperCase(RemoveIllegalChars(str));
  if frmConfig.lstTypes.Items.IndexOf(str) = -1 then
    frmConfig.lstTypes.Items.Add(str);

  for x := 0 to frmConfig.lstTypes.Count - 1 do
    try
      if CheckRegistryType(frmConfig.lstTypes.Items.Strings[x]) then
        frmConfig.lstTypes.Checked[x] := true;
    except
      on e: exception do
        dup5Main.writeLog(e.ClassName+' '+e.Message); 
    end;

end;

procedure TfrmConfig.FormShow(Sender: TObject);
var Reg: TRegistry;
    TempDir: array[0..MAX_PATH] of Char;
begin

  Loading := True;

  GetTempPath(MAX_PATH, @TempDir);
  txtTmpDirDefault.text := Strip0(TempDir);

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      if Reg.ValueExists('NoSplash') then
        ChkNoSplash.Checked := Reg.ReadBool('NoSplash')
      else
        ChkNoSplash.Checked := false;
      if Reg.ValueExists('OneInstanceOnly') then
        ChkOneInstance.Checked := Reg.ReadBool('OneInstanceOnly')
      else
        ChkOneInstance.Checked := false;
      if Reg.ValueExists('SmartOpen') then
        ChkSmartOpen.Checked := Reg.ReadBool('SmartOpen')
      else
        ChkSmartOpen.Checked := true;
      if Reg.ValueExists('ShowLog') then
        ChkLog.Checked := Reg.ReadBool('ShowLog')
      else
        ChkLog.Checked := true;
      if Reg.ValueExists('ClearLogWhenOpenFile') then
        ChkLogClearNew.Checked := Reg.ReadBool('ClearLogWhenOpenFile')
      else
        ChkLogClearNew.Checked := false;
      if Reg.ValueExists('KeepFilterIndex') then
        ChkKeepFilterIndex.Checked := Reg.ReadBool('KeepFilterIndex')
      else
        ChkKeepFilterIndex.Checked := true;
      if Reg.ValueExists('Accept0Bytes') then
        ChkAccept0Bytes.Checked := Reg.ReadBool('Accept0Bytes')
      else
        ChkAccept0Bytes.Checked := false;
      if Reg.ValueExists('AutoExpand') then
        ChkAutoExpand.Checked := Reg.ReadBool('AutoExpand')
      else
        ChkAutoExpand.Checked := true;
      // Remove obsolete key
      if Reg.ValueExists('XPStyle') then
        Reg.DeleteKey('XPStyle');
      if Reg.ValueExists('RegistryIcons') then
        ChkRegistryIcons.Checked := Reg.ReadBool('RegistryIcons')
      else
        ChkRegistryIcons.Checked := true;
      if Reg.ValueExists('UseHyperRipper') then
        ChkUseHyperRipper.Checked := Reg.ReadBool('UseHyperRipper')
      else
        ChkUseHyperRipper.Checked := true;
      if Reg.ValueExists('UseAltTempDir') then
      begin
        radTmpDirOther.Checked := Reg.ReadBool('UseAltTempDir');
        radTmpDirDefault.Checked := not(radTmpDirOther.Checked);
      end
      else
      begin
        radTmpDirOther.Checked := false;
        radTmpDirDefault.Checked := true;
      end;
      if Reg.ValueExists('AltTempDir') then
        txtTmpDir.Text := Reg.ReadString('AltTempDir')
      else
        txtTmpDir.Text := txtTmpDirDefault.text;
      if Reg.ValueExists('MakeExtractDefault') then
        chkMakeExtractDefault.Checked := Reg.ReadBool('MakeExtractDefault')
      else
        chkMakeExtractDefault.Checked := false;

      if Reg.ValueExists('BufferSize') then
        lstBufferSize.ItemIndex := Reg.ReadInteger('BufferSize')
      else
        lstBufferSize.ItemIndex := 6;

      if dup5Main.isPreviewLimit then
        optPreviewLimitYes.Checked := true
      else
        optPreviewLimitNo.Checked := true;

      lstPreviewLimit.ItemIndex := dup5Main.previewLimitValue;
      lstPreviewLimitChange(self);
      
      Reg.CloseKey;
    end;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Association',True) then
    begin
      if Reg.ValueExists('ExternalIconFile') then
        txtAssocExtIcon.Text := Reg.ReadString('ExternalIconFile')
      else
        txtAssocExtIcon.Text := '';
      if Reg.ValueExists('UseExternalIcon') then
        chkAssocExtIcon.Checked := Reg.ReadBool('UseExternalIcon')
      else
        chkAssocExtIcon.Checked := false;
      if Reg.ValueExists('AlternateDescription') then
        txtAssocText.Text := Reg.ReadString('AlternateDescription')
      else
        txtAssocText.Text := 'Dragon UnPACKer 5 Archive';
      if Reg.ValueExists('UseAlternateDescription') then
        chkAssocText.Checked := Reg.ReadBool('UseAlternateDescription')
      else
        chkAssocText.Checked := false;
      if Reg.ValueExists('UseOpenWith') then
        chkAssocOpenWith.Checked := Reg.ReadBool('UseOpenWith')
      else
        chkAssocOpenWith.Checked := false;
      if Reg.ValueExists('CheckStartup') then
        chkAssocCheckStartup.Checked := Reg.ReadBool('CheckStartup')
      else
        chkAssocCheckStartup.Checked := false;
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  optPreviewDisplayStretch.Checked := dup5Main.imgPreview.Stretch;
  optPreviewDisplayFull.checked := not(dup5Main.imgPreview.Stretch);

  trackbarVerbose.Position := dup5Main.getVerboseLevel;
  trackbarVerboseUpdateHint;

  CONVList;
  DRVList;
  LOOKList;
  frmConfig.lstLookClick(Self);
  TYPEList;

  treeConfig.Images := dup5Main.imgLook;

  Loading := False;

  treeConfig.Items.Item[TabSelect].Selected := True;
  treeConfig.FullExpand;
  frmConfig.treeConfigChange(Self, frmConfig.treeConfig.Selected);

end;

procedure TfrmConfig.cmdOkClick(Sender: TObject);
begin

  frmConfig.Close;

end;

procedure TfrmConfig.ChkNoSplashClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      Reg.WriteBool('NoSplash',chkNoSplash.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmConfig.lstDriversClick(Sender: TObject);
begin

{  lblDrvInfoAuthor.Caption := FSE.Drivers[lstDrivers.ItemIndex+1].Info.Author;
  lblDrvInfoVersion.Caption := FSE.Drivers[lstDrivers.ItemIndex+1].Info.Version;
  lblDrvInfoComments.Caption := FSE.Drivers[lstDrivers.ItemIndex+1].Info.Comment;

  cmdDrvAbout.Enabled := FSE.Drivers[lstDrivers.ItemIndex+1].IsAboutBox;
  cmdDrvSetup.Enabled := FSE.Drivers[lstDrivers.ItemIndex+1].IsConfigBox;
}
end;

procedure GetLOOKInfos(fil: string);
var Hin: Integer;
    HDR: DULK_Header;
begin

  if FileExists(ExtractFilePath(Application.ExeName)+'Data\'+fil) then
  begin
    Hin := FileOpen(ExtractFilePath(Application.ExeName)+'Data\'+fil,fmOpenRead);
    if Hin > 0 then
    begin
      FileRead(hin,HDR,SizeOf(HDR));
      if (HDR.ID = 'DULK'+#26) and (HDR.Version = DULK_Version) and (HDR.IndexNum = DULK_IndexNum) then
      begin

         frmConfig.lblLookName.Caption := Get8(Hin);
         frmConfig.lblLookAuthor.Caption := Get8(Hin);
         frmConfig.lblLookEmail.Caption := Get8(Hin);
         frmConfig.lblLookComment.Caption := Get8(Hin);

      end;
      FileClose(Hin);
    end;
  end;

end;

procedure LOOKList();
var sr: TSearchRec;
    Hin: Integer;
    HDR: DULK_Header;
    Reg: TRegistry;
    CFil: string;
    CFilIdx: integer;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      if Reg.ValueExists('Look') then
         cfil := Reg.ReadString('Look')
      else
        cfil := 'default.dulk';
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  CFilIdx := -1;

  frmConfig.lstLook.Clear;

  if FindFirst(ExtractFilePath(Application.ExeName)+'Data\*.dulk',faAnyFile,sr) = 0 then
  begin
    repeat
      if (sr.Attr and faDirectory) <> faDirectory then
      begin
        Hin := FileOpen(ExtractFilePath(Application.ExeName)+'Data\'+sr.Name,fmOpenRead);
        if Hin > 0 then
        begin
          FileRead(hin,HDR,SizeOf(HDR));
          if (HDR.ID = 'DULK'+#26) and (HDR.Version = DULK_Version) and (HDR.IndexNum = DULK_IndexNum) then
          begin
            frmConfig.lstLook.Items.Add(Get8(Hin) + ' ('+sr.Name+')');
            if UpperCase(Sr.name) = UpperCase(CFil) then
              CFilIdx := frmConfig.lstLook.Count-1;
          end;
          FileClose(Hin);
        end;
      end;
    until FindNext(sr) <>0;
    FindClose(sr);
  end;

  if CFilIdx > -1 then
    frmConfig.lstLook.ItemIndex := CFilIdx
  else
    if frmConfig.lstLook.Count > 0 then
      frmConfig.lstLook.ItemIndex := 0;

end;

procedure TfrmConfig.chkAutoExpandClick(Sender: TObject);
var Reg: TRegistry;
begin

  if not(Loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin
        Reg.WriteBool('AutoExpand',chkAutoExpand.Checked);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

  end;

end;

procedure TfrmConfig.lstLookClick(Sender: TObject);
var st,fil: string;
    parpos: integer;
    Reg: TRegistry;
begin

  if (lstLook.ItemIndex > -1) then
  begin
    st := lstLook.Items[lstLook.ItemIndex];
    parpos := posrev('(',st);

    fil := Copy(st,parpos+1,length(st)-parpos-1);

    GetLOOKInfos(fil);
    LoadLook(fil);

    if Not(Loading) then
    begin
      Reg := TRegistry.Create;
      Try
        Reg.RootKey := HKEY_CURRENT_USER;
        if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
        begin
          Reg.WriteString('Look',fil);
          Reg.CloseKey;
        end;
      Finally
        FreeAndNil(Reg);
      end;
    end;

  end;

end;

procedure TfrmConfig.cmdTypesAllClick(Sender: TObject);
var x : integer;
begin

  try
    SetRegistryDUP5;
    for x := 0 to lstTypes.Count - 1 do
    begin
      lstTypes.Checked[x] := True;
      SetRegistryType(lstTypes.Items.Strings[x]);
    end;
  except
    on e: exception do
      dup5Main.writeLog(e.ClassName+' '+e.Message);
  end;

end;

procedure TfrmConfig.cmdTypesNoneClick(Sender: TObject);
var x : integer;
begin

  try
    for x := 0 to lstTypes.Count - 1 do
    begin
      lstTypes.Checked[x] := False;
      UnSetRegistryType(lstTypes.Items.Strings[x]);
    end;
  except
    on e: exception do
      dup5Main.writeLog(e.ClassName+' '+e.Message);
  end;

end;

procedure TfrmConfig.lstTypesClickCheck(Sender: TObject);
begin

  try
    SetRegistryDUP5;
    if lstTypes.Checked[lstTypes.ItemIndex] then
      SetRegistryType(lstTypes.Items.Strings[lstTypes.ItemIndex])
    else
      UnSetRegistryType(lstTypes.Items.Strings[lstTypes.ItemIndex]);
  except
    on e: exception do
      dup5Main.writeLog(e.ClassName+' '+e.Message);
  end;

end;

procedure TfrmConfig.ChkOneInstanceClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      Reg.WriteBool('OneInstanceOnly',chkOneInstance.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmConfig.ChkSmartOpenClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      Reg.WriteBool('SmartOpen',chkSmartOpen.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmConfig.cmdDrvAboutClick(Sender: TObject);
begin

  FSE.showAboutBox(Application.Handle,lstDrivers2.ItemIndex+1);

end;

procedure TfrmConfig.treeConfigChange(Sender: TObject; Node: TTreeNode);
begin

  tabBasic.Visible := False;
  tabAdvanced.Visible := False;
  tabPluginsInfos.Visible := False;
  tabPlugins.Visible := False;
  tabLook.Visible := False;
  tabAssoc.Visible := False;
  tabLog.Visible := False;
  tabConvert.Visible := False;
  tabPreview.Visible := False;

  case treeConfig.Selected.AbsoluteIndex of
    0: begin
         tabBasic.Visible := True;
         LNGList;
         frmConfig.lstLanguesSelect(Self);
       end;
    1: tabAdvanced.Visible := True;
    2: tabLog.Visible := True;
    3: tabPluginsInfos.Visible := True;
    4: tabConvert.Visible := True;
    5: tabPlugins.Visible := True;
    6: tabLook.Visible := True;
    7: begin
         tabAssoc.Visible := True;
         updateAssocIcon;
       end;
    8: tabPreview.Visible := True;
  end;

end;

procedure TfrmConfig.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if (Key = 27) then
    cmdOk.Click;

end;

procedure TfrmConfig.chkRegistryIconsClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      Reg.WriteBool('RegistryIcons',chkRegistryIcons.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmConfig.cmdDrvSetupClick(Sender: TObject);
begin

  FSE.showConfigBox(Application.Handle,lstDrivers2.ItemIndex+1);

end;

procedure TfrmConfig.cmdCnvAboutClick(Sender: TObject);
begin

  CPlug.showAboutBox(Application.Handle,lstConvert2.ItemIndex+1);

end;

procedure TfrmConfig.cmdCnvSetupClick(Sender: TObject);
begin

  CPlug.showConfigBox(Application.Handle,lstConvert2.ItemIndex+1);

end;

procedure TfrmConfig.chkUseHyperRipperClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      Reg.WriteBool('UseHyperRipper',chkUseHyperRipper.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmConfig.lstDrivers2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if (Key = 27) then
    cmdOk.Click;

end;

procedure TfrmConfig.lstDrivers2Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin

  if (Change = ctState)
  and (lstDrivers2.ItemIndex > -1) then
  begin
    lblDrvInfoAuthor.Caption := FSE.Drivers[lstDrivers2.ItemIndex+1].Info.Author;
    lblDrvInfoVersion.Caption := FSE.Drivers[lstDrivers2.ItemIndex+1].Info.Version;
    lblDrvInfoComments.Caption := FSE.Drivers[lstDrivers2.ItemIndex+1].Info.Comment;

    cmdDrvAbout.Enabled := FSE.Drivers[lstDrivers2.ItemIndex+1].IsAboutBox;
    cmdDrvSetup.Enabled := FSE.Drivers[lstDrivers2.ItemIndex+1].IsConfigBox;

    txtDUDI.Caption := 'v'+inttostr(FSE.Drivers[lstDrivers2.ItemIndex+1].DUDIVersion);
    txtIntVer.Caption := inttostr(FSE.Drivers[lstDrivers2.ItemIndex+1].GetVersion);

    trkPriority.Position := FSE.Drivers[lstDrivers2.ItemIndex+1].Priority;
  end;

end;

procedure TfrmConfig.trkPriorityChange(Sender: TObject);
begin

  txtPriority.Caption := inttostr(trkPriority.Position);
  if FSE.Drivers[lstDrivers2.ItemIndex + 1].Priority <> trkPriority.Position then
    FSE.setDriverPriority(lstDrivers2.ItemIndex + 1, trkPriority.Position);

end;

procedure TfrmConfig.butRefreshClick(Sender: TObject);
begin

  FSE.sortDriversByPriority;
  DRVlist;

end;

procedure TfrmConfig.lstConvert2Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var info: ConvertInfoEx;  
begin

  if (Change = ctState)
  and (lstConvert2.ItemIndex > -1) then
  begin

    info := CPlug.getPluginInfo(lstConvert2.ItemIndex+1);
    lblCnvInfoAuthor.Caption := info.Author;
    lblCnvInfoVersion.Caption := info.Version;
    lblCnvInfoComments.Caption := info.Comment;
    txtCIntVer.Caption := inttostr(info.VerID);

    cmdCnvAbout.Enabled := info.isAboutBox;
    cmdCnvSetup.Enabled := info.isConfigBox;

    txtDUCI.Caption := 'v'+inttostr(info.DUCIVersion);

  end;

end;

procedure TfrmConfig.chkLogClick(Sender: TObject);
begin

  if not(chkLog.Checked) then
    dup5Main.menuLog_HideClick(self)
  else
    dup5Main.menuLog_ShowClick(self);

end;

procedure TfrmConfig.trackbarVerboseUpdateHint();
begin
  lblVerbose.Caption := DLNGStr('OPT85'+inttostr(trackbarVerbose.Position));
end;

procedure TfrmConfig.trackbarVerboseChange(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      Reg.WriteInteger('VerboseLevel',trackbarVerbose.Position);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  trackbarVerboseUpdateHint;

  dup5Main.setVerboseLevel(trackbarVerbose.Position);

end;

procedure TfrmConfig.updateAssocIcon();
var icnLarge, icnSmall: TIcon;
begin

  icnLarge := TIcon.Create;
  icnSmall := TIcon.Create;

  try
    if chkAssocExtIcon.Checked and FileExists(txtAssocExtIcon.Text) then
    begin
      GetLargeIconFromFile(txtAssocExtIcon.Text,0,icnLarge);
      GetSmallIconFromFile(txtAssocExtIcon.Text,0,icnSmall);
    end
    else
    begin
      GetLargeIconFromFile(Application.ExeName,1,icnLarge);
      GetSmallIconFromFile(Application.ExeName,1,icnSmall);
    end;

    imgAssocIcon.Picture.Icon := icnLarge;
    imgAssocIcon16.Picture.Icon := icnSmall;
    imgAssocIcon.Visible := true;
    imgAssocIcon16.Visible := true;
  except
    on E: Exception do
    begin
      imgAssocIcon.Visible := false;
      imgAssocIcon16.Visible := false;
    end;
  end;
  FreeAndNil(icnLarge);
  FreeAndNil(icnSmall);

end;

procedure TfrmConfig.chkAssocExtIconClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Association',True) then
    begin
      Reg.WriteBool('UseExternalIcon',chkAssocExtIcon.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  txtAssocExtIcon.Enabled := chkAssocExtIcon.Checked;
  butAssocExtIconBrowse.Enabled := chkAssocExtIcon.Checked;
  try
    updateAssocIcon;
    SetRegistryDUP5;
  except
    on e: exception do
      dup5Main.writeLog(e.ClassName+' '+e.Message);
  end;

end;

procedure TfrmConfig.butAssocExtIconBrowseClick(Sender: TObject);
var diagOpen: TOpenDialog;
begin

  diagOpen := TOpenDialog.Create(Self);
  try
    diagOpen.Title := DLNGStr('OPT431');
    diagOpen.Filter := DLNGStr('OPT432')+' (*.ICO)|*.ico';
    if diagOpen.Execute then
      txtAssocExtIcon.Text := diagOpen.FileName;
  finally
    FreeAndNil(diagOpen);
  end;

end;

procedure TfrmConfig.txtAssocExtIconChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(Loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Association',True) then
      begin
        Reg.WriteString('ExternalIconFile',txtAssocExtIcon.Text);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

    updateAssocIcon;
    SetRegistryDUP5;

  end;

end;

procedure TfrmConfig.chkAssocTextClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Association',True) then
    begin
      Reg.WriteBool('UseAlternateDescription',chkAssocText.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  txtAssocText.Enabled := chkAssocText.Checked;
  try
    SetRegistryDUP5;
  except
    on e: exception do
      dup5Main.writeLog(e.ClassName+' '+e.Message);
  end;

end;

procedure TfrmConfig.txtAssocTextChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(Loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Association',True) then
      begin
        Reg.WriteString('AlternateDescription',txtAssocText.Text);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

    try
      SetRegistryDUP5;
    except
      on e: exception do
        dup5Main.writeLog(e.ClassName+' '+e.Message);
    end;

  end;
  
end;

procedure TfrmConfig.chkAssocOpenWithClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Association',True) then
    begin
      Reg.WriteBool('UseOpenWith',chkAssocOpenWith.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  try
    SetRegistryDUP5;
  except
    on e: exception do
      dup5Main.writeLog(e.ClassName+' '+e.Message);
  end;

end;

procedure TfrmConfig.chkAssocCheckStartupClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Association',True) then
    begin
      Reg.WriteBool('CheckStartup',chkAssocCheckStartup.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmConfig.butTmpDirSelectClick(Sender: TObject);
var tmpDir: string;
begin

  tmpdir := BrowseForFolder(DLNGStr('OPT013'),txtTmpDir.Text,true);
  if tmpdir <> '' then
    txtTmpDir.Text := tmpdir;

end;

procedure TfrmConfig.radTmpDirOtherClick(Sender: TObject);
var Reg: TRegistry;
begin

  if Not(Loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin
        Reg.WriteBool('UseAltTempDir',radTmpDirOther.Checked);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

  end;

  txtTmpDir.Enabled := radTmpDirOther.Checked;
  butTmpDirSelect.Enabled := radTmpDirOther.Checked;

  txtTmpDirDefault.Enabled := radTmpDirDefault.Checked;

end;

procedure TfrmConfig.txtTmpDirChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(Loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin
        Reg.WriteString('AltTempDir',txtTmpDir.Text);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

  end;

end;


procedure TfrmConfig.chkMakeExtractDefaultClick(Sender: TObject);
var Reg: TRegistry;
begin

  if not(Loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin
        Reg.WriteBool('MakeExtractDefault',chkMakeExtractDefault.Checked);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

  end;

end;

procedure TfrmConfig.lstBufferSizeChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(Loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin
        Reg.WriteInteger('BufferSize',lstBufferSize.ItemIndex);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

  end;

end;

procedure TfrmConfig.chkPreviewEnableClick(Sender: TObject);
begin

  if not(chkPreviewEnable.Checked) then
    dup5Main.actionPreviewHide(self)
  else
    dup5Main.actionPreviewShow(self);

end;

procedure TfrmConfig.optPreviewLimitNoClick(Sender: TObject);
var Reg: TRegistry;
begin

  if not(Loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin
        Reg.WriteBool('PreviewLimit',false);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

    dup5main.isPreviewLimit := false;
    
  end;

  lstPreviewLimit.Enabled := false;

end;

procedure TfrmConfig.lstPreviewLimitChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(Loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin
        Reg.WriteInteger('PreviewLimitSize',lstPreviewLimit.ItemIndex);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

    dup5main.previewLimitValue := lstPreviewLimit.ItemIndex;

  end;

  txtPreviewLimitSize.Caption := inttostr(dup5Main.getPreviewLimitInBytes(dup5main.previewLimitValue));

end;

procedure TfrmConfig.optPreviewLimitYesClick(Sender: TObject);
var Reg: TRegistry;
begin

  if not(Loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin
        Reg.WriteBool('PreviewLimit',true);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

    dup5main.isPreviewLimit := true;

  end;

  lstPreviewLimit.Enabled := true;

end;

procedure TfrmConfig.optPreviewDisplayFullClick(Sender: TObject);
begin

  if not(Loading) then
    dup5Main.menuPreview_Display_FullClick(Self);

end;

procedure TfrmConfig.optPreviewDisplayStretchClick(Sender: TObject);
begin

  if not(Loading) then
    dup5Main.menuPreview_Display_StretchedClick(Self);

end;

procedure TfrmConfig.lblFindNewLanguagesMouseEnter(Sender: TObject);
begin

  lblFindNewLanguages.Font.Style := [fsUnderline];

end;

procedure TfrmConfig.lblFindNewLanguagesMouseLeave(Sender: TObject);
begin

  lblFindNewLanguages.Font.Style := [];

end;

procedure TfrmConfig.lblFindNewLanguagesClick(Sender: TObject);
begin

  ShellExecute(application.Handle,'open',PChar(ExtractFilePath(Application.ExeName)+'\Utils\Duppi.exe'),PChar('/checktranslations'),nil,SW_SHOW);

end;

procedure TfrmConfig.lstTypesClick(Sender: TObject);
begin

  try
    SetRegistryDUP5;
    if lstTypes.Checked[lstTypes.ItemIndex] then
      SetRegistryType(lstTypes.Items.Strings[lstTypes.ItemIndex])
    else
      UnSetRegistryType(lstTypes.Items.Strings[lstTypes.ItemIndex]);
  except
    on e: exception do
      dup5Main.writeLog(e.ClassName+' '+e.Message);
  end;

end;

procedure TfrmConfig.chkLogClearNewClick(Sender: TObject);
var Reg: TRegistry;
begin

  if not(Loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin
        Reg.WriteBool('ClearLogWhenOpenFile',chkLogClearNew.Checked);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

  end;

end;

procedure TfrmConfig.chkKeepFilterIndexClick(Sender: TObject);
var Reg: TRegistry;
begin

  if not(Loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin
        Reg.WriteBool('KeepFilterIndex',chkKeepFilterIndex.Checked);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

  end;

end;

procedure TfrmConfig.chkAccept0BytesClick(Sender: TObject);
var Reg: TRegistry;
begin

  if not(Loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
      begin
        Reg.WriteBool('Accept0Bytes',chkAccept0Bytes.Checked);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

  end;

end;

end.
