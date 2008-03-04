unit HyperRipper;

// $Id: HyperRipper.pas,v 1.7 2008-03-04 06:12:51 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/HyperRipper.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is HyperRipper.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, declFSE, lib_language, Registry,
  ExtCtrls, classHyperRipper, lib_utils, classFSE, spec_HRF,
  DateUtils, Spin, JvComponent, JvCtrls, JvExControls, JvLabel,
  translation, U_IntList;

type PFormatListElem = ^FormatsListElemEx;
     SearchItem = record
       DriverNum : integer;
       ID : integer;
     end;
     SearchList = record
       num: integer;
       items: array[1..1000] of SearchItem;
     end;
     PFoundItem = ^FoundItem;
     FoundItem = record
       Offset: integer;
       Index: integer;
     end;
  TfrmHyperRipper = class(TForm)
    OpenDialog: TOpenDialog;
    PageControl: TPageControl;
    tabSearch: TTabSheet;
    tabFormats: TTabSheet;
    tabAdvanced: TTabSheet;
    lstResults: TListBox;
    cmdOk: TButton;
    cmdSearch: TButton;
    txtSource: TEdit;
    Progress: TProgressBar;
    cmdBrowse: TButton;
    Panel1: TPanel;
    lblHexDump: TLabel;
    strBufferLength: TLabel;
    lblBufferLength: TLabel;
    strSpeed: TLabel;
    lblSpeed: TLabel;
    strSource: TLabel;
    panHRF: TPanel;
    chkHRF: TCheckBox;
    txtHRF: TEdit;
    cmdHRFBrowse: TButton;
    lstFormats: TListView;
    lblFound: TLabel;
    strFound: TLabel;
    grpRollback: TGroupBox;
    chkRollback0: TRadioButton;
    chkRollback1: TRadioButton;
    chkRollback2: TRadioButton;
    chkRollback3: TRadioButton;
    grpBuffer: TGroupBox;
    chkBuffer32K: TRadioButton;
    chkBuffer64K: TRadioButton;
    chkBuffer128K: TRadioButton;
    chkBufferUD: TRadioButton;
    lblBufferUD: TLabel;
    strRollBack: TLabel;
    lblRollback: TLabel;
    cmdCancel: TButton;
    grpFormatting: TGroupBox;
    tabHRF: TTabSheet;
    GroupBox4: TGroupBox;
    grpHRFVersion: TGroupBox;
    radiov30: TRadioButton;
    imgBlood: TImage;
    tabAbout: TTabSheet;
    imgHR: TImage;
    Bevel1: TBevel;
    strHRVersion: TLabel;
    Panel3: TPanel;
    strNumPlugs: TLabel;
    lblNumPlugs: TLabel;
    strNumFormats: TLabel;
    lblNumFormats: TLabel;
    chkHRFInfo: TCheckBox;
    Panel4: TPanel;
    strHRFTitle: TLabel;
    txtHRFTitle: TEdit;
    txtHRFAuthor: TEdit;
    strHRFAuthor: TLabel;
    strHRFURL: TLabel;
    txtHRFURL: TEdit;
    grpHRFOptions: TGroupBox;
    radiov10: TRadioButton;
    radiov20: TRadioButton;
    chkHRF3_NoPRGID: TCheckBox;
    chkHRF3_NoPRGVer: TCheckBox;
    SaveDialog: TSaveDialog;
    chkMakeDirs: TCheckBox;
    grpNaming: TGroupBox;
    chkNamingAuto: TRadioButton;
    chkNamingCustom: TRadioButton;
    txtNaming: TEdit;
    spinBufferUD: TSpinEdit;
    lblAboutInfo: TLabel;
    lblAboutBeware: TLabel;
    cmdConfig: TButton;
    cmdAll: TButton;
    cmdImage: TButton;
    cmdVideo: TButton;
    cmdAudio: TButton;
    lblHRVersion: TJvLabel;
    lblNamingLegF: TLabel;
    lblNamingLegX: TLabel;
    lblNamingLegO: TLabel;
    lblNamingLegN: TLabel;
    lblNamingLegH: TLabel;
    panNamingExemple: TPanel;
    Panel2: TPanel;
    strMaxLength: TLabel;
    strCompatible: TLabel;
    lblMaxLength: TLabel;
    lblCompatible: TLabel;
    lblNamingLegL: TLabel;
    lblNamingLegS: TLabel;
    panNaming: TPanel;
    txtExample: TEdit;
    procedure cmdOkClick(Sender: TObject);
    procedure cmdSearchClick(Sender: TObject);
    procedure cmdBrowseClick(Sender: TObject);
    procedure txtSourceChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure addResult(st: String);
    procedure lastResult(st: String);
    procedure chkBufferUDClick(Sender: TObject);
    procedure chkBuffer128KClick(Sender: TObject);
    procedure chkBuffer64KClick(Sender: TObject);
    procedure chkBuffer32KClick(Sender: TObject);
    procedure saveSettings();
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure chkRollback0Click(Sender: TObject);
    procedure chkRollback1Click(Sender: TObject);
    procedure chkRollback2Click(Sender: TObject);
    procedure chkRollback3Click(Sender: TObject);
    procedure RunSearch(filename: String; slist: SearchList);
    procedure cmdCancelClick(Sender: TObject);
    procedure chkHRFClick(Sender: TObject);
    procedure chkHRFInfoClick(Sender: TObject);
    procedure txtHRFTitleChange(Sender: TObject);
    procedure txtHRFAuthorChange(Sender: TObject);
    procedure txtHRFURLChange(Sender: TObject);
    procedure txtHRFChange(Sender: TObject);
    procedure cmdHRFBrowseClick(Sender: TObject);
    procedure chkHRF3_NoPRGIDClick(Sender: TObject);
    procedure chkHRF3_NoPRGVerClick(Sender: TObject);
    procedure chkMakeDirsClick(Sender: TObject);
    procedure chkNamingCustomClick(Sender: TObject);
    procedure chkNamingAutoClick(Sender: TObject);
    procedure txtNamingChange(Sender: TObject);
    procedure spinBufferUDChange(Sender: TObject);
    procedure lstFormatsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure cmdConfigClick(Sender: TObject);
    procedure cmdAllClick(Sender: TObject);
    procedure cmdImageClick(Sender: TObject);
    procedure cmdVideoClick(Sender: TObject);
    procedure cmdAudioClick(Sender: TObject);
    procedure lstFormatsCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lstFormatsColumnClick(Sender: TObject; Column: TListColumn);
    procedure radiov30Click(Sender: TObject);
    procedure radiov20Click(Sender: TObject);
    procedure radiov10Click(Sender: TObject);
  private
    SearchThread: TThread;
    SortType: integer;
    SortMode: boolean;
    procedure showExample(st: string);
  public
    function getInfo(): DriverInfo;
    procedure stopSearch();
    { Déclarations publiques }
  end;
  THRipSearch = class(TThread)
  private
    MAXSIZE: integer;
    filename: string;
    slist: SearchList;
    hrip: TfrmHyperRipper;
    cancel: boolean;
    function normalizePrefix(prefix: string): string;
  protected
    procedure Execute; override;
  public
    procedure setSearch(filnam: String; sl: SearchList; hr: TfrmHyperRipper; bufSize: integer);
    constructor Create(CreateSuspended: Boolean);
    procedure cancelSearch();
  end;

var
  frmHyperRipper: TfrmHyperRipper;

implementation

uses Main;

{$R *.dfm}

var prefix: string;
    numWAV: Integer;
    Loading: Boolean = True;
    numChecked: Integer;

procedure TfrmHyperRipper.cmdOkClick(Sender: TObject);
begin

  frmHyperRipper.Close;

end;

function Fill0(st: string): string;
begin

  Fill0 := Copy('0000000000'+st,length(st)+1,10);

end;

procedure TfrmHyperRipper.cmdSearchClick(Sender: TObject);
var x: Integer;
    cformat: PFormatListElem;
    slist: SearchList;
begin

  numWAV := 0;
  numChecked := 0;
  prefix := ExtractFileName(txtSource.Text);
  lstResults.Items.Clear;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    if (lstFormats.Items.Item[x].Checked) then
    begin
       cformat := lstFormats.Items.Item[x].Data;
       inc(numChecked);
       slist.items[numChecked].ID := cformat.ID;
       slist.items[numChecked].DriverNum := cformat.DriverNum;
    end;
  end;

  slist.num := numChecked;

  if FileExists(txtSource.Text) then
  begin
    if numChecked > 0 then
    begin
//      Dup5Main.closeCurrent;
      RunSearch(txtSource.text, slist);
    end
    else
      addResult(DLNGstr('HRLG01'));
  end
  else
    addResult(ReplaceValue('%f',DLNGstr('HRLG02'),ExtractFileName(txtSource.Text)));

end;

procedure TfrmHyperRipper.cmdBrowseClick(Sender: TObject);
begin

  OpenDialog.FileName := txtSource.text;
  OpenDialog.Title := DLNGStr('HYPOPN');
  OpenDialog.Filter := DLNGStr('ALLFIL');
  if OpenDialog.Execute then
    txtSource.Text := OpenDialog.FileName;

end;

procedure TfrmHyperRipper.txtSourceChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteString('Source',txtSource.text);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  txtHRF.text := ChangeFileExt(txtSource.Text,'.hrf');

  end;

end;

procedure TfrmHyperRipper.FormShow(Sender: TObject);
var Reg: TRegistry;
    List: ExtSearchFormatsList;
    x: integer;
    itemx : TListItem;
begin

  translateHyperRipper;

  SortMode := true;
  SortType := 0;
  Loading := True;
  showExample('%f_%x-%n');
  lblMaxLength.Caption := ReplaceValue('%c',DLNGStr('HR3034'),'255');
  lblCompatible.Caption := ReplaceValue('%v',DLNGStr('HR3036'),'5.0.0.77');

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      if Reg.ValueExists('Source') then
      begin
        txtSource.Text := Reg.ReadString('Source');
        txtHRF.text := ChangeFileExt(txtSource.Text,'.hrf');
      end;
      if Reg.ValueExists('BufferUserDefined') then
        spinBufferUD.value := Reg.ReadInteger('BufferUserDefined');
      if Reg.ValueExists('Buffer') then
        case Reg.ReadInteger('Buffer') of
          32: begin
                chkBufferUD.Checked := true;
                spinBufferUD.Value := 32768;
              end;
          64: begin
                chkBufferUD.Checked := true;
                spinBufferUD.Value := 65536;
              end;
         128: begin
                chkBufferUD.Checked := true;
                spinBufferUD.Value := 131072;
              end;
         256: chkBuffer32K.Checked := true;
         512: chkBuffer64K.Checked := true;
        1024: chkBuffer128K.Checked := true;
        else
          chkBufferUD.Checked := true;
        end;
      if Reg.ValueExists('BufferRollback') then
        case Reg.ReadInteger('BufferRollback') of
           0: chkRollback0.Checked := true;
           2: chkRollback2.Checked := true;
           3: chkRollback3.Checked := true;
        else
          chkRollback1.Checked := true;
        end;
      if Reg.ValueExists('CreateHRF') then
        chkHRF.Checked := Reg.ReadBool('CreateHRF');
      if Reg.ValueExists('HRF3_NoPRGID') then
        chkHRF3_NoPRGID.Checked := Reg.ReadBool('HRF3_NoPRGID');
      if Reg.ValueExists('HRF3_NoPRGVer') then
        chkHRF3_NoPRGVer.Checked := Reg.ReadBool('HRF3_NoPRGVer');
      if Reg.ValueExists('MakeDirs') then
        chkMakeDirs.Checked := Reg.ReadBool('MakeDirs');
      if Reg.ValueExists('HRF_IncludeInformations') then
        chkHRFInfo.Checked := Reg.ReadBool('HRF_IncludeInformations');
      if Reg.ValueExists('HRFAuthor') then
        txtHRFAuthor.Text := Reg.ReadString('HRFAuthor');
      if Reg.ValueExists('HRFTitle') then
        txtHRFTitle.Text := Reg.ReadString('HRFTitle');
      if Reg.ValueExists('HRFURL') then
        txtHRFURL.Text := Reg.ReadString('HRFURL');
      if Reg.ValueExists('Prefix') then
        case Reg.ReadInteger('Prefix') of
          1: chkNamingCustom.Checked := true;
        else
          chkNamingAuto.Checked := true;
        end;
      if Reg.ValueExists('PrefixPredef') then
        txtNaming.Text := Reg.ReadString('PrefixPredef');
      if Reg.ValueExists('HRF_Version') then
        case Reg.ReadInteger('HRF_Version') of
           1: radiov10.Checked := true;
           2: radiov20.Checked := true;
          30: radiov30.Checked := true;
        else
          radiov30.Checked := true;
        end;
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

{  for x := 1 to HPlug.NumPlugins do
    if not(@HPlug.Plugins[x].OptionPanel = nil) then
    begin
      NewTabSheet := TTabSheet.Create(PageControl);
      NewTabSheet.PageControl := PageControl;
      HPlug.Plugins[x].OptionPanel(self,NewTabSheet);
    end;}

  List := HPlug.GetFormatsList;

  lblNumPlugs.Caption := inttostr(HPlug.NumPlugins);
  lblNumFormats.Caption := inttostr(List.NumFormats);
  lblHRVersion.Caption := getHRVersion(HR_VERSION);

  lstFormats.Items.Clear;

  for x:=1 to List.NumFormats do
  begin
    itemx := lstFormats.Items.Add;
    itemx.Caption := List.FormatsList[x].Format;
    case List.FormatsList[x].GenType of
      HR_TYPE_AUDIO: itemx.SubItems.Add (DLNGstr('HRTYP1'));
      HR_TYPE_VIDEO: itemx.SubItems.Add (DLNGstr('HRTYP2'));
      HR_TYPE_IMAGE: itemx.SubItems.Add (DLNGstr('HRTYP3'));
      HR_TYPE_OTHER: itemx.SubItems.Add (DLNGstr('HRTYPM'));
      HR_TYPE_UNKNOWN: itemx.SubItems.Add (DLNGstr('HRTYP0'));
    else
      itemx.SubItems.Add (ReplaceValue('%i',DLNGstr('HRTYPE'),inttostr(List.FormatsList[x].GenType)));
    end;
    itemx.SubItems.Add (List.FormatsList[x].Desc);
    itemx.Data := @List.FormatsList[x];
    itemx.Checked := CheckRegistryHR(HPlug.Plugins[List.FormatsList[x].DriverNum].FileName,List.FormatsList[x].ID);
  end;

  Loading := False;

end;

procedure TfrmHyperRipper.addResult(st: String);
begin

  if (lstResults.Items.Count = 5) then
    lstResults.Items.Delete(0);
  lstResults.Items.Add(st);

end;

procedure TfrmHyperRipper.RunSearch(filename: String; slist: SearchList);
var bufSize: integer;
begin

  bufSize := 256;

  if (chkBuffer32K.Checked) then
    bufSize := 256
  else if (chkBuffer64K.Checked) then
    bufSize := 512
  else if (chkBuffer128K.Checked) then
    bufSize := 1024
  else if (chkBufferUD.Checked) then
  begin
    bufSize := spinBufferUD.value;
    if bufSize < 256 then
      bufSize := 256;
  end;

  SearchThread := THripSearch.Create(true);
  (SearchThread as THripSearch).setSearch(filename,slist,Self,bufSize);
  cmdOk.Enabled := false;
  cmdSearch.Visible := false;
  cmdCancel.Visible := true;
  SearchThread.Resume;

end;

procedure TfrmHyperRipper.chkBufferUDClick(Sender: TObject);
var Reg: TRegistry;
begin

  spinBufferUD.Enabled := true;
  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('Buffer',0);
      Reg.WriteInteger('BufferUserDefined',spinBufferUD.Value);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure TfrmHyperRipper.chkBuffer128KClick(Sender: TObject);
var Reg: TRegistry;
begin

  spinBufferUD.Enabled := false;
  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('Buffer',1024);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure TfrmHyperRipper.chkBuffer64KClick(Sender: TObject);
var Reg: TRegistry;
begin

  spinBufferUD.Enabled := false;
  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('Buffer',512);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure TfrmHyperRipper.chkBuffer32KClick(Sender: TObject);
var Reg: TRegistry;
begin

  spinBufferUD.Enabled := false;
  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('Buffer',256);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure TfrmHyperRipper.lastResult(st: String);
begin

  lstResults.Items.Strings[lstResults.Items.Count-1] := st;

end;

procedure TfrmHyperRipper.saveSettings;
var x: integer;
    cformat: PFormatListElem;
begin

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.Item[x].Data;
    setRegistryHR(HPlug.Plugins[cformat.DriverNum].FileName,cformat.ID,lstFormats.Items.Item[x].Checked);
  end;

end;

procedure TfrmHyperRipper.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

  saveSettings;

end;

procedure TfrmHyperRipper.chkRollback0Click(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('BufferRollback',0);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure TfrmHyperRipper.chkRollback1Click(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('BufferRollback',1);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure TfrmHyperRipper.chkRollback2Click(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('BufferRollback',2);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure TfrmHyperRipper.chkRollback3Click(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('BufferRollback',3);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

function FListCompare(Item1, Item2: Pointer): Integer;
var Elem1, Elem2: PFoundItem;
begin

  Elem1 := Item1;
  Elem2 := Item2;

  result := Elem2^.Offset - Elem1^.Offset;

end;

procedure THRipSearch.cancelSearch;
begin

  cancel := true;

end;

constructor THRipSearch.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  Priority := tpNormal;
  FreeOnTerminate := true;
end;

procedure THRipSearch.Execute;
var hSRC, x: integer;
    totsize,curpos: int64;
    buffer: PByteArray;
    bufsize,testsize: integer;
    per, oldper: real;
    SomethingFound: Boolean;
    foundOffset: integer;
    found: FoundInfo64;
    numFound, rollback: integer;
    flist: TList;
    fitem: PFoundItem;
    startTime: Cardinal;
    speedcalc: Integer;
    loadTime: integer;
    prgid: byte;
    prgver: integer;
    prefix, resprefix, fext, predir: string;
    lastTimer: TDateTime;
    hrfver: byte;
    intTmp1,intTmp2,absoluteOffset: int64;
    foundOffsets: TIntList;
    iNumOffset: Integer;
begin

  cancel := false;

  hrip.addResult(ReplaceValue('%f',DLNGstr('HRLG03'),ExtractFileName(filename)));

  hSRC := FileOpen(filename,fmOpenRead or fmShareExclusive);

  if (hrip.chkNamingAuto.Checked) then
    prefix := '%f_%x-%n'
  else
    prefix := hrip.txtNaming.Text;

  prefix := NormalizePrefix(prefix);

  prefix := ReplaceValue('%f',prefix,changefileext(extractfilename(filename),''));

  fext := extractfileext(filename);
  if (Copy(fext,1,1) = '.') then
    fext := Copy(fext,2,length(fext)-1);

  prefix := ReplaceValue('%x',prefix,fext);

  startTime := GetTickCount;

  // For 5.3.0 WIP fix buffer to 8K, the advanced options will be removed afterwards
  MAXSIZE := 8192;

  if MAXSIZE < 1024 then
    hrip.lblBufferLength.Caption := inttostr(MAXSIZE) +'B'
  else if MAXSIZE < 1048576 then
    hrip.lblBufferLength.Caption := inttostr(MAXSIZE div 1024) +'KB'
  else
    hrip.lblBufferLength.Caption := inttostr(MAXSIZE div 1048576) +'MB';

  hrip.Progress.Max := 100;
  OldPer := 0;
  numFound := 0;

  RollBack := 0;

  if hrip.chkRollback1.Checked then
    RollBack := 128
  else if hrip.chkRollback2.Checked then
    RollBack := MAXSIZE div 4
  else if hrip.chkRollback3.Checked then
    RollBack := MAXSIZE div 2;

  // For 5.3.0 WIP fix buffer rollback to 128 bytes, the advanced options will be removed afterwards
  rollback := 128;

  if rollback < 1024 then
    hrip.lblRollback.Caption := inttostr(rollback) +'B'
  else if rollback < 1048576 then
    hrip.lblRollback.Caption := inttostr(rollback div 1024) +'KB'
  else
    hrip.lblRollback.Caption := inttostr(rollback div 1048576) +'MB';

  hrip.lblFound.Caption := IntTostr(numFound);

  if hSRC >= 0 then
  begin
    hrip.LastResult(ReplaceValue('%f',DLNGstr('HRLG03'),ExtractFileName(filename))+' '+DLNGstr('HRLG04'));
    hrip.AddResult(DLNGstr('HRLG05'));
    flist := TList.Create;
    curPos := 0;
    totsize := FileSeek(hSRC,curPos,2);
    if totsize > MAXSIZE then
      bufsize := MAXSIZE
    else
      bufsize := totsize;
    getmem(Buffer,bufsize);
    try
     try
      FSE.PrepareHyperRipper(frmHyperRipper.getInfo);
      CurPos := 0;
      lastTimer := now;
      hrip.LastResult(DLNGstr('HRLG05')+' '+DLNGstr('HRLG04'));
      hrip.AddResult(DLNGstr('HRLG06'));
      while (CurPos < TotSize) and not(cancel) do
      begin
        FileSeek(hSRC,CurPos,0);
        TestSize := FileRead(hSRC,buffer^,bufsize);
        if (TestSize <> bufsize) then
          raise Exception.create(ReplaceValue('%b',DLNGstr('HRLG07'),inttostr(bufsize-TestSize)));

        per := (CurPos / TotSize);
        per := per * 100;

        for x := 0 to flist.Count-1 do
          Dispose(flist.Items[x]);
        flist.Clear;
        for x := 1 to slist.num do
        begin
          foundOffsets := HPlug.searchBuffer(slist.items[x].DriverNum,slist.items[x].ID,buffer,bufsize);
          if (foundOffsets.Count > 0) then
          begin
            for iNumOffset := 0 to foundOffsets.Count - 1 do
            begin
              new(fitem);
              fitem^.Offset := foundOffsets.Integers[iNumOffset];
              fitem^.Index := x;
              flist.Add(fitem);
            end;
          end;
        end;

        if (flist.Count > 0) then
          flist.sort(@FListCompare);

        SomeThingFound := false;

        for x := 0 to flist.Count-1 do
        begin
          fitem := flist.Items[x];
          absoluteOffset := fitem^.offset;
          absoluteOffset := absoluteOffset + curPos;
          try
            Found := HPlug.searchFile(slist.items[fitem^.Index].DriverNum,slist.items[fitem^.Index].ID,hSRC,absoluteOffset);
          except
            on ex: Exception do
            begin
              hrip.addResult(ex.ClassName + ': '+ex.Message);
              break; 
            end;
          end;
//          Found := HPlug.plugins[slist.items[fitem^.Index].DriverNum].SearchFile(slist.items[fitem^.Index].ID,hSRC,curPos+fitem^.Offset);
          if (Found.GenType <> HR_TYPE_ERROR) and (Found.Size > 0) then
          begin
            if (hrip.chkMakeDirs.Checked) then
            begin
              if Found.GenType = HR_TYPE_UNKNOWN then
                predir := 'Unknown\'
              else if Found.GenType = HR_TYPE_AUDIO then
                predir := 'Audio\'
              else if Found.GenType = HR_TYPE_VIDEO then
                predir := 'Video\'
              else if Found.GenType = HR_TYPE_IMAGE then
                predir := 'Image\'
              else
                predir := '';
            end
            else
              predir := '';

            inc(numFound);
            hrip.addResult(ReplaceValue('%e',ReplaceValue('%a',ReplaceValue('%s',DLNGstr('HRLG08'),inttostr(Found.Size)),inttohex(Found.Offset,8)),Found.Ext));

            resprefix := ReplaceValue('%o',prefix,IntToStr(Found.Offset));
            resprefix := ReplaceValue('%h',resprefix,IntToHex(Found.Offset,16));
            // Feature request 1216790 //
            resprefix := ReplaceValue('%s',resprefix,IntToStr(Found.Size));
            resprefix := ReplaceValue('%l',resprefix,IntToHex(Found.Size,16));
            //\ Feature request 1216790 //\
            resprefix := ReplaceValue('%n',resprefix,Fill0(inttostr(numFound)));

            FSE.SetListElem(predir+resprefix+'.'+Found.Ext,Found.Offset,Found.Size,0,0);
            curPos := Found.Offset+Found.Size;
            SomethingFound := true;
            break;
          end;
        end;

        if (Per >= (OldPer + 1)) or (SecondsBetween(lastTimer,now) > 1) then
        begin
          hrip.Progress.Position := Round(Per);
          hrip.lstResults.Refresh;
          hrip.lblFound.Caption := IntTostr(numFound);
          hrip.lblHexDump.Caption := '';
          for x := 0 to 17 do
            hrip.lblHexDump.Caption := hrip.lblHexDump.Caption + IntToHex(buffer[x],2)+' ';
          OldPer := Per;
          if (GetTickCount - StartTime) > 0 then
            SpeedCalc := Round((CurPos / ((GetTickCount - StartTime) / 1000)) / 1024)
          else
            SpeedCalc := 0;
          hrip.lblSpeed.Caption := IntToStr(SpeedCalc)+'KB/s';
          hrip.Refresh;
          lastTimer := now;
        end;

        if Not(SomethingFound) then
        begin
          CurPos := CurPos + bufsize;
          if (bufsize = MAXSIZE) then
            Dec(CurPos,rollback);
        end;
        if (totsize - CurPos) < MAXSIZE then
          bufsize := (totsize - CurPos);

      end;

//      raise Exception.create('bouh');
      hrip.lblFound.Caption := IntTostr(numFound);
      hrip.Progress.Position := 100;
      if (TotSize < 1024) then
        hrip.AddResult(ReplaceValue('%s',ReplaceValue('%t',DLNGstr('HRLG09'),floattostr(round((getTickCount-starttime)/100)/10)),inttostr(CurPos)+DLNGstr('HRLG10')))
      else if (TotSize < 1048576) then
        hrip.AddResult(ReplaceValue('%s',ReplaceValue('%t',DLNGstr('HRLG09'),floattostr(round((getTickCount-starttime)/100)/10)),inttostr(Round(CurPos / 1024))+DLNGstr('HRLG11')))
      else if (TotSize < 1073741824) then
        hrip.AddResult(ReplaceValue('%s',ReplaceValue('%t',DLNGstr('HRLG09'),floattostr(round((getTickCount-starttime)/100)/10)),inttostr(Round(CurPos / 1048576))+DLNGstr('HRLG12')))
      else
        hrip.AddResult(ReplaceValue('%s',ReplaceValue('%t',DLNGstr('HRLG09'),floattostr(round((getTickCount-starttime)/100)/10)),inttostr(Round(CurPos / 1073741824))+DLNGstr('HRLG13')));
      if (hrip.chkHRF.checked) then
      begin
        hrip.addResult(DLNGstr('HRLG14'));
        if hrip.chkHRF3_NoPRGID.Checked then
          prgid := 0
        else
          prgid := HR_ID;
        if hrip.chkHRF3_NoPRGVer.Checked then
          prgver := 0
        else
          prgver := HR_VERSION;
        if hrip.radiov30.Checked then
          hrfver := 3
        else if hrip.radiov20.Checked then
          hrfver := 2
        else
          hrfver := 1;
        FSE.saveHRF(filename, hrip.txtHRF.Text, TotSize, prgver, prgid, hrfver, hrip.chkHRFInfo.Checked,hrip.txtHRFTitle.Text,hrip.txtHRFAuthor.text,hrip.txtHRFURL.Text);
        hrip.lastResult(DLNGstr('HRLG14')+' '+DLNGstr('HRLG04'));
      end;
      hrip.AddResult(DLNGstr('HRLG15'));
      hrip.Refresh;
      loadTime := getTickCount - startTime;
      FSE.LoadHyperRipper(filename,hSRC,loadTime,hrip.chkMakeDirs.Checked);
      //FSE.BrowseDir('');
      hrip.LastResult(DLNGstr('HRLG15')+' '+DLNGstr('HRLG04'));
     except
      hrip.AddResult(DLNGstr('HRLG16'));
      Synchronize(hrip.stopSearch);
     end;
    finally
      hrip.AddResult(DLNGstr('HRLG17'));
      for x := 0 to flist.Count-1 do
        Dispose(flist.Items[x]);
      flist.Free;
      freemem(Buffer);
//      FileClose(hSRC);
      hrip.LastResult(DLNGstr('HRLG17')+' '+DLNGstr('HRLG04'));
      Synchronize(hrip.stopSearch);
    end;
  end
  else
  begin
    hrip.LastResult(ReplaceValue('%f',DLNGstr('HRLG03'),ExtractFileName(filename))+' '+DLNGstr('HRLG18')+' ('+inttostr(hSRC)+')');
    Synchronize(hrip.stopSearch);
  end;

end;

function THRipSearch.normalizePrefix(prefix: string): string;
var x: integer;
    res: string;
begin

  res := '';

  for x := 1 to length(prefix) do
  begin
    if (prefix[x] = '/')
    or (prefix[x] = '\')
    or (prefix[x] = ':')
    or (prefix[x] = '*')
    or (prefix[x] = '?')
    or (prefix[x] = '"')
    or (prefix[x] = '<')
    or (prefix[x] = '>')
//    or (prefix[x] = '.')
    or (prefix[x] = '|') then
      res := res + '_'
    else
      res := res + prefix[x];
  end;

  result := res;

end;

procedure THRipSearch.setSearch(filnam: String; sl: SearchList; hr: TfrmHyperRipper; bufSize: integer);
begin

  filename := filnam;
  slist := sl;
  hrip := hr;
  MAXSIZE := bufSize;

end;

procedure TfrmHyperRipper.stopSearch;
begin

  cmdOk.Enabled := true;
  cmdSearch.Visible := true;
  cmdCancel.Visible := false;

end;

procedure TfrmHyperRipper.cmdCancelClick(Sender: TObject);
begin

  (SearchThread as THRipSearch).cancelSearch;

end;

function TfrmHyperRipper.getInfo: DriverInfo;
begin

  result.Name := 'HyperRipper';
  result.Author := 'Alexandre Devilliers';
  result.Version := getHRVersion(HR_VERSION);
  result.Comment := '';
  result.NumFormats := 0;

end;

procedure TfrmHyperRipper.chkHRFClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('CreateHRF',chkHRF.Checked);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  txtHRF.Enabled := chkHRF.Checked;
  cmdHRFBrowse.Enabled := chkHRF.Checked;

end;

procedure TfrmHyperRipper.chkHRFInfoClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('HRF_IncludeInformations',chkHRFInfo.Checked);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  txtHRFTitle.Enabled := chkHRFInfo.Checked;
  txtHRFAuthor.Enabled := chkHRFInfo.Checked;
  txtHRFURL.Enabled := chkHRFInfo.Checked;

end;

procedure TfrmHyperRipper.txtHRFTitleChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteString('HRFTitle',txtHRFTitle.Text);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  end;

end;

procedure TfrmHyperRipper.txtHRFAuthorChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteString('HRFAuthor',txtHRFAuthor.Text);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  end;

end;

procedure TfrmHyperRipper.txtHRFURLChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteString('HRFURL',txtHRFURL.Text);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  end;

end;

procedure TfrmHyperRipper.txtHRFChange(Sender: TObject);
//var Reg: TRegistry;
begin

{  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteString('HRF_Filename',txtHRF.Text);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;}

end;

procedure TfrmHyperRipper.cmdHRFBrowseClick(Sender: TObject);
begin

  SaveDialog.Title := 'Make following HyperRIpper file...';
  SaveDialog.Filter := 'All files|*.*|HyperRipper File (*.HRF)|*.HRF';
  SaveDialog.FilterIndex := 2;

  if SaveDialog.Execute then
  begin
    txtHRF.Text := SaveDialog.FileName;

  end;

end;

procedure TfrmHyperRipper.chkHRF3_NoPRGIDClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('HRF3_NoPRGID',chkHRF3_NoPRGID.Checked);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure TfrmHyperRipper.chkHRF3_NoPRGVerClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('HRF3_NoPRGVer',chkHRF3_NoPRGVer.Checked);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure TfrmHyperRipper.chkMakeDirsClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('MakeDirs',chkMakeDirs.Checked);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure TfrmHyperRipper.chkNamingCustomClick(Sender: TObject);
var Reg: TRegistry;
begin

  txtNaming.Enabled := true;
  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('Prefix',1);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  showExample(txtNaming.Text);
  
end;

procedure TfrmHyperRipper.chkNamingAutoClick(Sender: TObject);
var Reg: TRegistry;
begin

  txtNaming.Enabled := false;
  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('Prefix',0);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  showExample('%f_%x-%n');

end;

procedure TfrmHyperRipper.txtNamingChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteString('PrefixPredef',txtNaming.Text);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

    showExample(txtNaming.Text);
  end
  else if txtNaming.Enabled then
    showExample(txtNaming.Text);

end;

procedure TfrmHyperRipper.spinBufferUDChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
        Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
      begin
        Reg.WriteInteger('Buffer',spinBufferUD.Value);
        Reg.WriteInteger('BufferUserDefined',spinBufferUD.Value);
        Reg.CloseKey;
      end;
    Finally
      Reg.Free;
    end;

  end;

end;

procedure TfrmHyperRipper.lstFormatsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
var cformat: PFormatListElem;
begin

  if not(loading) then
  begin

    if (lstFormats.ItemIndex > -1) then
    begin
      cformat := lstFormats.Selected.Data;

      if cformat.IsConfig then
        cmdConfig.Enabled := true
      else
        cmdConfig.Enabled := false;
    end
    else
      cmdConfig.Enabled := false;
      
  end
  else
    cmdConfig.Enabled := false;

end;

procedure TfrmHyperRipper.cmdConfigClick(Sender: TObject);
var cformat: PFormatListElem;
begin

  try
    cformat := lstFormats.Selected.Data;
    HPlug.Plugins[cformat.DriverNum].ShowOptionPanel(cformat.ID);
  except
    // une erreur..
  end;

end;

procedure TfrmHyperRipper.cmdAllClick(Sender: TObject);
var x, nc: integer;
begin

  nc := 0;

  for x := 0 to lstFormats.Items.Count-1 do
    if lstFormats.Items.Item[x].Checked then
      inc(nc);

  for x := 0 to lstFormats.Items.Count-1 do
    lstFormats.Items.Item[x].Checked := not(nc = lstFormats.Items.Count);

end;

procedure TfrmHyperRipper.cmdImageClick(Sender: TObject);
var x, nc, gt: integer;
    cformat: PFormatListElem;
begin

  gt := 0;
  nc := 0;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if cformat.GenType = HR_TYPE_IMAGE then
    begin
      inc(gt);
      if lstFormats.Items.Item[x].Checked then
        inc(nc);
    end;
  end;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if cformat.GenType = HR_TYPE_IMAGE then
      lstFormats.Items.Item[x].Checked := not(nc = gt);
  end;

end;

procedure TfrmHyperRipper.cmdVideoClick(Sender: TObject);
var x, nc, gt: integer;
    cformat: PFormatListElem;
begin

  gt := 0;
  nc := 0;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if cformat.GenType = HR_TYPE_VIDEO then
    begin
      inc(gt);
      if lstFormats.Items.Item[x].Checked then
        inc(nc);
    end;
  end;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if cformat.GenType = HR_TYPE_VIDEO then
      lstFormats.Items.Item[x].Checked := not(nc = gt);
  end;

end;

procedure TfrmHyperRipper.cmdAudioClick(Sender: TObject);
var x, nc, gt: integer;
    cformat: PFormatListElem;
begin

  gt := 0;
  nc := 0;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if cformat.GenType = HR_TYPE_AUDIO then
    begin
      inc(gt);
      if lstFormats.Items.Item[x].Checked then
        inc(nc);
    end;
  end;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if cformat.GenType = HR_TYPE_AUDIO then
      lstFormats.Items.Item[x].Checked := not(nc = gt);
  end;

end;

procedure TfrmHyperRipper.lstFormatsCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin

  case Data of
    0: begin
         if (Item1.Caption = Item2.Caption) then
           Compare := 0
         else if (Item1.Caption < Item2.Caption) then
           Compare := -1
         else
           Compare := 1;
       end;
    1: begin
         if (Item1.SubItems.Strings[0] = Item2.SubItems.Strings[0]) then
           Compare := 0
         else if (Item1.SubItems.Strings[0] < Item2.SubItems.Strings[0]) then
           Compare := -1
         else
           Compare := 1;
       end;
    2: begin
         if (Item1.SubItems.Strings[1] = Item2.SubItems.Strings[1]) then
           Compare := 0
         else if (Item1.SubItems.Strings[1] < Item2.SubItems.Strings[1]) then
           Compare := -1
         else
           Compare := 1;
       end;
  end;

//  ShowMessage(inttostr(data)+#10+inttostr(compare));

end;

procedure TfrmHyperRipper.lstFormatsColumnClick(Sender: TObject;
  Column: TListColumn);
begin

  lstFormats.CustomSort(nil,Column.Index); 

end;

procedure TfrmHyperRipper.radiov30Click(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin
    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
        Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
      begin
        Reg.WriteInteger('HRF_Version',30);
        Reg.CloseKey;
      end;
    Finally
      Reg.Free;
    end;
  end;

  lblMaxLength.Caption := ReplaceValue('%c',DLNGStr('HR3034'),'255');
  lblCompatible.Caption := ReplaceValue('%v',DLNGStr('HR3036'),'5.0.0.77');

  chkHRF3_NoPRGID.Enabled := true;
  chkHRFInfo.Enabled := true;
  txtHRFTitle.Enabled := true;
  txtHRFAuthor.Enabled := true;
  txtHRFURL.Enabled := true;

end;

procedure TfrmHyperRipper.radiov20Click(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin
    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
        Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
      begin
        Reg.WriteInteger('HRF_Version',2);
        Reg.CloseKey;
      end;
    Finally
      Reg.Free;
    end;
  end;

  lblMaxLength.Caption := ReplaceValue('%c',DLNGStr('HR3034'),'64');
  lblCompatible.Caption := ReplaceValue('%v',DLNGStr('HR3036'),'4.13.74');

  chkHRF3_NoPRGID.Enabled := false;
  chkHRFInfo.Enabled := true;
  txtHRFTitle.Enabled := true;
  txtHRFAuthor.Enabled := true;
  txtHRFURL.Enabled := true;

end;

procedure TfrmHyperRipper.radiov10Click(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin
    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
        Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
      begin
        Reg.WriteInteger('HRF_Version',1);
        Reg.CloseKey;
      end;
    Finally
      Reg.Free;
    end;
  end;

  lblMaxLength.Caption := ReplaceValue('%c',DLNGStr('HR3034'),'32');
  lblCompatible.Caption := ReplaceValue('%v',DLNGStr('HR3036'),'4.00.38');

  chkHRF3_NoPRGID.Enabled := false;
  chkHRFInfo.Enabled := false;
  txtHRFTitle.Enabled := false;
  txtHRFAuthor.Enabled := false;
  txtHRFURL.Enabled := false;

end;

procedure TfrmHyperRipper.showExample(st: string);
var res: string;
begin

  res := trim(st);
  res := ReplaceValue('%f',res,'exsounds');
  res := ReplaceValue('%x',res,'pak');
  res := ReplaceValue('%o',res,'9562');
  res := ReplaceValue('%h',res,'000000000000255A');
  // Feature request 1216790 //
  res := ReplaceValue('%s',res,'7890');
  res := ReplaceValue('%l',res,'0000000000001ED2');
  //\ Feature request 1216790 //\
  res := ReplaceValue('%n',res,'5');

  txtExample.Text := ' '+res+'.wav';


end;

end.
