unit Options;

// $Id: Options.pas,v 1.2.2.5 2004-10-10 09:17:47 elbereth Exp $
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
  CheckLst, Main, lib_look;

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
    grpAssoc1: TGroupBox;
    cmdTypesAll: TButton;
    cmdTypesNone: TButton;
    GroupBox2: TGroupBox;
    grpAssoc2: TGroupBox;
    imgAssocIcon: TImage;
    Edit1: TEdit;
    lstTypes: TCheckListBox;
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
    tabHyperRipper: TPanel;
    lblHR: TLabel;
    cmdHRSetup: TButton;
    grpHRInfo: TGroupBox;
    strHRInfoAuthor: TLabel;
    lblHRInfoAuthor: TLabel;
    strHRInfoVersion: TLabel;
    lblHRInfoVersion: TLabel;
    strHRInfoComments: TLabel;
    Panel5: TPanel;
    lblHRInfoComments: TLabel;
    cmdHRAbout: TButton;
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
    lstHR2: TListView;
    grpHRAdvInfo: TGroupBox;
    lblDUHI: TLabel;
    lblHIntVer: TLabel;
    txtDUHI: TStaticText;
    txtHIntVer: TStaticText;
    trkAssocIcon: TTrackBar;
    chkLog: TCheckBox;
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
    procedure cmdHRAboutClick(Sender: TObject);
    procedure cmdHRSetupClick(Sender: TObject);
    procedure chkUseHyperRipperClick(Sender: TObject);
    procedure lstDrivers2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lstDrivers2Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure trkPriorityChange(Sender: TObject);
    procedure butRefreshClick(Sender: TObject);
    procedure lstConvert2Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lstHR2Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure chkLogClick(Sender: TObject);
  private
    { Déclarations privées }
  public
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
    Reg.Free;
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
begin

  frmConfig.lstConvert2.Clear;
  for x := 1 to CPlug.NumPlugins do
  begin
    itmx := frmConfig.lstConvert2.Items.Add;
    itmx.Caption := CPlug.Plugins[x].Version.Name;
    itmx.SubItems.Add(CPlug.Plugins[x].Version.Version);
    itmx.SubItems.Add(ChangeFileExt(CPlug.Plugins[x].FileName,''));
  end;

  if CPlug.NumPlugins > 0 then
  begin
    frmConfig.lstConvert2.ItemIndex := 0;
  end;

end;

procedure HRIPList();
var x : integer;
    itmx : TListItem;
begin

  frmConfig.lstHR2.Clear;
  for x := 1 to HPlug.NumPlugins do
  begin
    itmx := frmConfig.lstHR2.Items.Add;
    itmx.Caption := HPlug.Plugins[x].Version.Name;
    itmx.SubItems.Add(GetPlugVersion(HPlug.Plugins[x].Version.Version));
    itmx.SubItems.Add(ChangeFileExt(HPlug.Plugins[x].FileName,''));
  end;

  if HPlug.NumPlugins > 0 then
  begin
    frmConfig.lstHR2.ItemIndex := 0;
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
    if CheckRegistryType(frmConfig.lstTypes.Items.Strings[x]) then
      frmConfig.lstTypes.Checked[x] := true;

end;

procedure TfrmConfig.FormShow(Sender: TObject);
var Reg: TRegistry;
begin

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
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  Loading := True;

  CONVList;
  DRVList;
  HRIPList;
  LOOKList;
  frmConfig.lstLookClick(Self);
  TYPEList;

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
    Reg.Free;
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
    Reg.Free;
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
        Reg.Free;
      end;
    end;

  end;

end;

procedure TfrmConfig.cmdTypesAllClick(Sender: TObject);
var x : integer;
begin

  for x := 0 to lstTypes.Count - 1 do
  begin
    lstTypes.Checked[x] := True;
    SetRegistryType(lstTypes.Items.Strings[x]);
  end;

end;

procedure TfrmConfig.cmdTypesNoneClick(Sender: TObject);
var x : integer;
begin

  for x := 0 to lstTypes.Count - 1 do
  begin
    lstTypes.Checked[x] := False;
    UnSetRegistryType(lstTypes.Items.Strings[x]);
  end;

end;

procedure TfrmConfig.lstTypesClickCheck(Sender: TObject);
begin

  SetRegistryDUP5;
  if lstTypes.Checked[lstTypes.ItemIndex] then
    SetRegistryType(lstTypes.Items.Strings[lstTypes.ItemIndex])
  else
    UnSetRegistryType(lstTypes.Items.Strings[lstTypes.ItemIndex]);

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
    Reg.Free;
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
    Reg.Free;
  end;

end;

procedure TfrmConfig.cmdDrvAboutClick(Sender: TObject);
begin

  FSE.showAboutBox(Application.Handle,lstDrivers2.ItemIndex+1);

end;

procedure TfrmConfig.treeConfigChange(Sender: TObject; Node: TTreeNode);
begin

  tabBasic.Visible := False;
  tabPlugins.Visible := False;
  tabLook.Visible := False;
  tabAssoc.Visible := False;
  tabConvert.Visible := False;
  tabHyperRipper.Visible := False;

  case treeConfig.Selected.AbsoluteIndex of
    0: begin
         tabBasic.Visible := True;
         LNGList;
         frmConfig.lstLanguesSelect(Self);
       end;
    1: tabPlugins.Visible := True;
    2: tabConvert.Visible := True;
    3: tabPlugins.Visible := True;
    4: tabHyperRipper.Visible := True;
    5: tabLook.Visible := True;
    6: tabAssoc.Visible := True;
    7: tabAssoc.Visible := True;
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
    Reg.Free;
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

procedure TfrmConfig.cmdHRAboutClick(Sender: TObject);
begin

  HPlug.showAboutBox(Application.Handle,lstHR2.ItemIndex+1);

end;

procedure TfrmConfig.cmdHRSetupClick(Sender: TObject);
begin

  HPlug.showConfigBox(Application.Handle,lstHR2.ItemIndex+1);

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
    Reg.Free;
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
begin

  if (Change = ctState)
  and (lstConvert2.ItemIndex > -1) then
  begin

    lblCnvInfoAuthor.Caption := CPlug.Plugins[lstConvert2.ItemIndex+1].Version.Author;
    lblCnvInfoVersion.Caption := CPlug.Plugins[lstConvert2.ItemIndex+1].Version.Version;
    lblCnvInfoComments.Caption := CPlug.Plugins[lstConvert2.ItemIndex+1].Version.Comment;

    cmdCnvAbout.Enabled := CPlug.Plugins[lstConvert2.ItemIndex+1].IsAboutBox;
    cmdCnvSetup.Enabled := CPlug.Plugins[lstConvert2.ItemIndex+1].IsConfigBox;

    txtDUCI.Caption := 'v'+inttostr(CPlug.Plugins[lstConvert2.ItemIndex+1].DUCIVersion);
    txtCIntVer.Caption := inttostr(CPlug.Plugins[lstConvert2.ItemIndex+1].Version.VerID);

//    trkPriority.Position := FSE.Drivers[lstDrivers2.ItemIndex+1].Priority;
  end;

end;

procedure TfrmConfig.lstHR2Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin

  if (Change = ctState)
  and (lstHR2.ItemIndex > -1) then
  begin

    lblHRInfoAuthor.Caption := HPlug.Plugins[lstHR2.ItemIndex+1].Version.Author;
    lblHRInfoVersion.Caption := GetplugVersion(HPlug.Plugins[lstHR2.ItemIndex+1].Version.Version);
    lblHRInfoComments.Caption := HPlug.Plugins[lstHR2.ItemIndex+1].Version.Comment;

    cmdHRAbout.Enabled := HPlug.Plugins[lstHR2.ItemIndex+1].IsAboutBox;
    cmdHRSetup.Enabled := HPlug.Plugins[lstHR2.ItemIndex+1].IsConfigBox;

    txtDUHI.Caption := 'v'+inttostr(HPlug.Plugins[lstHR2.ItemIndex+1].DUHIVersion);
    txtHIntVer.Caption := inttostr(HPlug.Plugins[lstHR2.ItemIndex+1].Version.Version);
//    trkPriority.Position := FSE.Drivers[lstDrivers2.ItemIndex+1].Priority;
  end;

end;

procedure TfrmConfig.chkLogClick(Sender: TObject);
begin

  if not(chkLog.Checked) then
    dup5Main.menuLog_HideClick(self)
  else
    dup5Main.menuLog_ShowClick(self);

end;

end.
