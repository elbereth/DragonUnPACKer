unit Main;

// $Id: Main.pas,v 1.2 2006-01-30 10:49:13 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/tools/dpackc/Main.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is Main.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, zlib,
  Dialogs, ComCtrls, StdCtrls, Menus, ToolWin, ImgList, ExtCtrls,
  lib_crc, lib_zlib, spec_DUPP, JvComponent, JvSimpleXml, lib_version, lib_binutils,
  JvExStdCtrls, JvButton, JvCtrls, JvRichEdit;

type
     BMPHeader = packed record
       ID: array[0..1] of char;
       Size: integer;
       Reserved1: word;
       Reserved2: word;
       Offset: integer;
       ID2: integer;
       Width: integer;
       height: integer;
       Planes: word;
       Bpp: word;
       Compression: integer;
       SizeImage: integer;
       XPPM: integer;
       YPPM: integer;
       ColorsUsed: integer;
       ColorsImportant: integer;
     end;
  TfrmMain = class(TForm)
    Dialog: TOpenDialog;
    imgButtons: TImageList;
    SaveDialog: TSaveDialog;
    SimpleXML: TJvSimpleXml;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    panPicture: TPanel;
    imgAbout: TImage;
    lblVersion: TLabel;
    lblCompatible: TLabel;
    TabSheet2: TTabSheet;
    lstFiles: TListView;
    grpInfos: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    chkCompress: TCheckBox;
    chkUpgradeOnly: TCheckBox;
    chkStoreDateTime: TCheckBox;
    chkReadOnly: TCheckBox;
    chkHidden: TCheckBox;
    txtInstallTo: TComboBox;
    txtInstallDir: TEdit;
    chkRegSvr: TCheckBox;
    TabSheet3: TTabSheet;
    GroupBox1: TGroupBox;
    txtVersion: TEdit;
    Label4: TLabel;
    lblPreviewVersion: TStaticText;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    GroupBox2: TGroupBox;
    optCompInf: TRadioButton;
    optCompSup: TRadioButton;
    chkDUP5: TCheckBox;
    optCompEqual: TRadioButton;
    optCompDiff: TRadioButton;
    txtDUP5Version: TEdit;
    GroupBox3: TGroupBox;
    Label3: TLabel;
    txtName: TEdit;
    Label5: TLabel;
    txtURL: TEdit;
    Label6: TLabel;
    txtAuthor: TEdit;
    Label11: TLabel;
    txtComment: TEdit;
    chkImagePerso: TCheckBox;
    txtImageFile: TEdit;
    butBrowseImage: TButton;
    TabSheet4: TTabSheet;
    JvRichEdit1: TJvRichEdit;
    ToolBar: TToolBar;
    butAdd: TToolButton;
    butDel: TToolButton;
    ProgressBar1: TProgressBar;
    Label14: TLabel;
    Edit1: TEdit;
    Button2: TButton;
    GroupBox4: TGroupBox;
    JvImgBtn1: TJvImgBtn;
    butOpen: TJvImgBtn;
    JvImgBtn3: TJvImgBtn;
    butCompile: TJvImgBtn;
    butExit: TButton;
    procedure ListBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListBox1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure butCompileClick(Sender: TObject);
    procedure butAddClick(Sender: TObject);
    function GetFSize(filnam: string): Int64;
    procedure menuFichier_QuitterClick(Sender: TObject);
    procedure lstFilesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure chkCompressClick(Sender: TObject);
    procedure butDelClick(Sender: TObject);
    procedure chkUpgradeOnlyClick(Sender: TObject);
    procedure chkStoreDateTimeClick(Sender: TObject);
    procedure chkReadOnlyClick(Sender: TObject);
    procedure chkHiddenClick(Sender: TObject);
    procedure txtInstallToChange(Sender: TObject);
    procedure Paramtres1Click(Sender: TObject);
    procedure lstFilesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure txtInstallDirChange(Sender: TObject);
    procedure menuFichier_CompilerClick(Sender: TObject);
    procedure chkRegSvrClick(Sender: TObject);
    procedure menuFichier_SaveClick(Sender: TObject);
    procedure menuFichier_OuvrirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure butExitClick(Sender: TObject);
    procedure txtVersionChange(Sender: TObject);
    procedure chkDUP5Click(Sender: TObject);
    procedure chkImagePersoClick(Sender: TObject);
//    function convertInstallTo(val: integer): string;
  private
    { Déclarations privées }
    function getPluginVersion(filename: String): Integer;
    procedure refreshSelectedInstallTo;
  public
    PackVersion: Integer;
    PackDUP5Check: Boolean;
    PackDUP5Comp: Integer;
    PackDUP5Version: Integer;
    PackName: String;
    PackURL: String;
    PackAuthor: String;
    PackComment: String;
    PackImagePerso: Boolean;
    PackImageFile: String;
    { Déclarations publiques }
  end;

var
  frmMain: TfrmMain;

implementation

uses Compile, Config;

type FileInfo = class
     public
       Compress: boolean;
       UpgradeOnly: boolean;
       StoreDateTime: boolean;
       ReadOnly: boolean;
       Hidden: boolean;
       RegSvr: boolean;
       InstallTo: integer;
       Version: integer;
       Filename: string;
       InstallDir: string;
       constructor Create(Comp, Upg, StoreDT, ReadO, Hide, Reg: boolean; InstTo: integer; Vers: integer; FName, InstallDir: string);
     end;

const DPSVERSION = 1;
      VERSION = 20011;

{$R *.dfm}

{$Include datetime.inc}

procedure TfrmMain.ListBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
begin

ShowMessage(Source.ClassName);

end;

procedure TfrmMain.ListBox1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin

  ShowMessage(Source.ClassName);

end;

procedure TfrmMain.butCompileClick(Sender: TObject);
var HDR: DUP5PACK_Header;
    NFO: DUP5PACK_Info;
    NFO1: DUP5PACK_Info_v1;
    ENT: DUP5PACK_File;
    fin: integer;
    fout: integer;
    x: integer;
    tmp: FileInfo;
    buf: PChar;
    bufoutstr: string;
    tByt: byte;
    InputStream: TCompressionStream;
    OutputStream: TMemoryStream;
    Size: Integer;
    Buffer: PByteArray;
    hBAN: integer;
    BMP: BMPHeader;
begin

   if SaveDialog.Execute then
   begin
     fout := FileCreate(SaveDialog.FileName, fmOpenWrite);

     HDR.ID := 'DUPP';
     HDR.EOF := 26;
     HDR.Version := 2;

     HDR.NeededVersion := 20240;

     for x := 0 to lstFiles.Items.Count-1 do
     begin
       tmp := FileInfo(lstFiles.Items.Item[x].Data);
       if (tmp.InstallDir <> '') then
       begin
         HDR.NeededVersion := 20240;
         break;
       end;
     end;

     if (frmPackCfg.chkImagePerso.Checked and FileExists(frmPackCfg.txtImageFile.Text)) then
     begin
       HDR.NeededVersion := 20240;
     end;

     FileWrite(fout,HDR,8);

     NFO.NumVer := strtoint(frmPackCfg.txtVersion.text);
     if (frmPackCfg.chkDUP5.Checked) then
     begin
       if (frmPackCfg.optCompSup.Checked) then
         NFO.DUP5VerTest := 1
       else if (frmPackCfg.optCompInf.Checked) then
         NFO.DUP5VerTest := 2
       else if (frmPackCfg.optCompEqual.Checked) then
         NFO.DUP5VerTest := 0
       else if (frmPackCfg.optCompDiff.Checked) then
         NFO.DUP5VerTest := 3;
     end
     else
       NFO.DUP5VerTest := -1;
     NFO.DUP5VerValue := strtoint(frmPackCfg.txtDUP5Version.Text);
     NFO.NumFiles := lstFiles.Items.Count;

     FillChar(NFO1,SizeOf(NFO1),0);
     NFO1.PictureCompressed := 0;
     NFO1.PictureCompressedSize := 0;

     if (frmPackCfg.chkImagePerso.Checked and FileExists(frmPackCfg.txtImageFile.Text)) then
     begin
       hBAN := FileOpen(frmPackCfg.txtImageFile.Text,fmOpenRead);
       try
         NFO.PictureSize := FileSeek(hBAN,0,2);
         getmem(Buffer,NFO.PictureSize);
         try
           FileSeek(hBAN,0,0);
           FileRead(hBAN,BMP,SizeOf(BMP));
           if ((BMP.ID = 'BM') and (BMP.Width = 465) and (BMP.height = 90)) then
           begin
             FileSeek(hBAN,0,0);
             FileRead(hBAN,Buffer^,NFO.PictureSize);
             FileWrite(fout,NFO,20);
             FileWrite(fout,NFO1,SizeOf(NFO1));
             put8(fout,frmMain.PackName);
             put8(fout,frmMain.PackURL);
             put8(fout,frmMain.PackAuthor);
             put8(fout,frmMain.PackComment);
             FileWrite(fout,Buffer^,NFO.PictureSize);
           end
           else
           begin
             NFO.PictureSize := 0;
             FileWrite(fout,NFO,20);
             put8(fout,frmMain.PackName);
             put8(fout,frmMain.PackURL);
             put8(fout,frmMain.PackAuthor);
             put8(fout,frmMain.PackComment);
           end;
         finally
           FreeMem(buffer);
         end;
       finally
         FileClose(hBAN);
       end;
     end
     else
     begin
       NFO.PictureSize := 0;
       FileWrite(fout,NFO,20);
       FileWrite(fout,NFO1,SizeOf(NFO1));
       put8(fout,frmMain.PackName);
       put8(fout,frmMain.PackURL);
       put8(fout,frmMain.PackAuthor);
       put8(fout,frmMain.PackComment);
     end;

     for x := 0 to lstFiles.Items.Count-1 do
     begin
       tmp := FileInfo(lstFiles.Items.Item[x].Data);
       fin := FileOpen(tmp.Filename,fmOpenRead);
       ENT.DSize := FileSeek(fin,0,2);
       FileSeek(fin,0,0);
       if tmp.StoreDateTime then
         ENT.DateT := FileGetDate(fin)
       else
         ENT.DateT := 0;
       if tmp.Hidden then
         ENT.Hidden := 1
       else
         ENT.Hidden := 0;
       if tmp.ReadOnly then
         ENT.ReadOnly := 1
       else
         ENT.ReadOnly := 0;

       ENT.Flags := 0;
       if tmp.RegSvr then
         ENT.Flags := ENT.Flags or D5PFILE_REGSVR32;

       ENT.BaseInstallDir := tmp.InstallTo;
       if tmp.UpgradeOnly then
         ENT.UpdateOnly := 1
       else
         ENT.UpdateOnly := 0;
       ENT.Version := tmp.Version;

       GetMem(Buf,ENT.DSize);
       FileRead(fin,buf^,ENT.DSize);
       ENT.CRC := getStrCRC32(buf^);

       if tmp.Compress then
       begin
         ENT.CompressionType := 1;
         OutputStream := TMemoryStream.Create;
         try
           InputStream := TCompressionStream.Create(clMax, OutputStream);
           try
             InputStream.Write(ENT.DSize, 4);
             InputStream.Write(buf^, ENT.DSize)
           finally
             InputStream.Free
           end;
           ENT.Size := Outputstream.Size;
           SetLength(bufoutstr, OutputStream.Size);
           OutputStream.Seek(0, soFromBeginning);
           OutputStream.Read(bufoutstr[1], Length(bufoutstr))
         finally
           OutputStream.Free
         end
       end
       else
       begin
         ENT.Size := ENT.DSize;
         ENT.CompressionType := 0;
       end;

       FileWrite(fout,ENT.Size,4);
       FileWrite(fout,ENT.DSize,4);
       FileWrite(fout,ENT.DateT,4);
       FileWrite(fout,ENT.Hidden,1);
       FileWrite(fout,ENT.ReadOnly,1);
       FileWrite(fout,ENT.Flags,1);
       FileWrite(fout,ENT.UpdateOnly,1);
       FileWrite(fout,ENT.Version,4);
       FileWrite(fout,ENT.CompressionType,4);
       FileWrite(fout,ENT.BaseInstallDir,4);
       FileWrite(fout,ENT.CRC,4);
//       FileWrite(fout,ENT,32);

       tByt := length(lstFiles.Items.Item[x].Caption);
       FileWrite(fout,tByt,1);
       FileWrite(fout,PChar(lstFiles.Items.Item[x].Caption)^,tByt);
       tByt := 0;
       FileWrite(fout,tByt,1);

       if tmp.Compress then
       begin
         FileWrite(fout,bufoutstr[1],ENT.Size);
       end
       else
       begin
         FileWrite(fout,buf^,ENT.Size);
       end;

       FreeMem(Buf);

       FileClose(fin);
     end;

     FileClose(fout);
//  frmCompile.Show;

  end;

end;

procedure TfrmMain.butAddClick(Sender: TObject);
var itmx: TListItem;
    ext: string;
    tmp: FileInfo;
    Handle: THandle;
begin

  Dialog.Filter := 'Tous les fichiers|*.*';
  Dialog.Title := 'Ajouter un fichier au package...';

  if Dialog.Execute then
  begin

    itmx := lstFiles.Items.Add;
    with itmx do
    begin
      itmx.Caption := ExtractFilename(Dialog.FileName);
      itmx.SubItems.Add(IntToStr(GetFSize(Dialog.Filename)));
      itmx.SubItems.Add(DateTimeToStr(FileDateToDateTime(FileAge(Dialog.FileName))));
      ext := lowercase(ExtractFileExt(Dialog.FileName));
      tmp := FileInfo.Create(True, True, True, False, False,False, 0,-1,Dialog.FileName,'');
      if ext = '.d5d' then
      begin
        tmp.InstallTo := 2;
        tmp.Version := getPluginVersion(Dialog.Filename);
      end
      else if (ext = '.d5c') then
      begin
        tmp.InstallTo := 0;
        tmp.Version := getPluginVersion(Dialog.Filename);
      end
      else if (ext = '.d5h') then
      begin
        tmp.InstallTo := 3;
        tmp.Version := getPluginVersion(Dialog.Filename);
      end
      else if (ext = '.dpal') then
        tmp.InstallTo := 0
      else if (ext = '.dulk') or (ext = '.lng') then
        tmp.InstallTo := 1
      else
        tmp.InstallTo := 4;

      if (tmp.Version = -1) then
        tmp.UpgradeOnly := false;
      itmx.SubItems.Add(txtInstallTo.Items.Strings[tmp.InstallTo]);
      itmx.Data := tmp;
    end;

  end;

end;

function TfrmMain.GetFSize(filnam: string): Int64;
var F: integer;
begin

  Result := 0;

  F := FileOpen(filnam,fmOpenRead);
  try
    Result := FileSeek(F,0,2);
  finally
    FileClose(F);
  end;

end;

procedure TfrmMain.menuFichier_QuitterClick(Sender: TObject);
begin

  Application.Terminate;

end;

procedure TfrmMain.lstFilesSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var tmp: FileInfo;
begin

  tmp := FileInfo(item.data);

  txtInstallTo.ItemIndex := tmp.InstallTo;
  txtInstallDir.Text := tmp.InstallDir;

  chkCompress.Checked := tmp.Compress;
  chkUpgradeOnly.Checked := tmp.UpgradeOnly;
  chkUpgradeOnly.Enabled := (tmp.Version > -1);
  chkStoreDateTime.Checked := tmp.StoreDateTime;
  chkReadOnly.Checked := tmp.ReadOnly;
  chkHidden.Checked := tmp.Hidden;
  chkRegSvr.Checked := tmp.RegSvr;
  butDel.Enabled := true;

  txtInstallTo.Enabled := false;
  txtInstallDir.Enabled := false;
  chkCompress.Enabled := false;
  chkUpgradeOnly.Enabled := false;
  chkStoreDateTime.Enabled := false;
  chkRegSvr.Enabled := false;
  chkReadOnly.Enabled := false;
  chkHidden.Enabled := false;

  if (uppercase(ExtractFileExt(tmp.Filename)) = '.DLL')
  or (uppercase(ExtractFileExt(tmp.Filename)) = '.OCX')
  then
    chkRegSvr.Enabled := true
  else
    chkRegSvr.Enabled := false;

end;

procedure TfrmMain.chkCompressClick(Sender: TObject);
var tmp: FileInfo;
begin

  tmp := FileInfo(lstFiles.Selected.Data);
  tmp.Compress := chkCompress.Checked;

end;

procedure TfrmMain.butDelClick(Sender: TObject);
begin

     lstFiles.Items.Delete(lstFiles.Selected.Index);

     if (lstFiles.SelCount = 0) then
     begin
       butDel.Enabled := false;
     end;

     PanPicture.Visible := true;

end;

{ FileInfo }

constructor FileInfo.Create(Comp, Upg, StoreDT, ReadO, Hide, Reg: boolean; InstTo: integer; Vers: Integer; FName, InstallDir: String);
begin

  Compress := comp;
  UpgradeOnly := Upg;
  StoreDateTime := StoreDT;
  ReadOnly := ReadO;
  Hidden := Hide;
  RegSvr := Reg;
  InstallTo := InstTo;
  Version := Vers;
  FileName := FName;

end;

procedure TfrmMain.chkUpgradeOnlyClick(Sender: TObject);
var tmp: FileInfo;
begin

  tmp := FileInfo(lstFiles.Selected.Data);
  tmp.UpgradeOnly := chkUpgradeOnly.Checked;

end;

procedure TfrmMain.chkStoreDateTimeClick(Sender: TObject);
var tmp: FileInfo;
begin

  tmp := FileInfo(lstFiles.Selected.Data);
  tmp.StoreDateTime := chkStoreDateTime.Checked;

end;

procedure TfrmMain.chkReadOnlyClick(Sender: TObject);
var tmp: FileInfo;
begin

  tmp := FileInfo(lstFiles.Selected.Data);
  tmp.ReadOnly := chkReadOnly.Checked;

end;

procedure TfrmMain.chkHiddenClick(Sender: TObject);
var tmp: FileInfo;
begin

  tmp := FileInfo(lstFiles.Selected.Data);
  tmp.Hidden := chkHidden.checked;

end;

procedure TfrmMain.txtInstallToChange(Sender: TObject);
var tmp: FileInfo;
begin

  tmp := FileInfo(lstFiles.Selected.Data);
  tmp.InstallTo := txtInstallTo.ItemIndex;
  refreshSelectedInstallTo;

end;

procedure TfrmMain.Paramtres1Click(Sender: TObject);
begin

     frmPackCfg.ShowModal();

end;

procedure TfrmMain.lstFilesChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin

  if lstFiles.Items.Count > 0 then
  begin
    butCompile.Enabled := true
  end
  else
  begin
    butCompile.Enabled := false;
    txtInstallTo.Enabled := false;
    txtInstallDir.Enabled := false;
    chkCompress.Enabled := false;
    chkUpgradeOnly.Enabled := false;
    chkStoreDateTime.Enabled := false;
    chkRegSvr.Enabled := false;
    chkReadOnly.Enabled := false;
    chkHidden.Enabled := false;
  end;

end;

function TfrmMain.getPluginVersion(filename: String): Integer;
var Handle: THandle;
    DUDIVer: TDUDIVersion;
    DUCIVer: TDUDIVersion;
    DUHIVer: TDUDIVersion;
    CnvInfo: ConvertInfo;
    GetNumVer: TGetNumVersion;
    GetConvertVer: TGetConvertVersion;
    GetHRVer: TGetHRVersion;
begin

  Handle := LoadLibrary(PChar(filename));

  if Handle <> 0 then
  begin
    @DUDIVer := GetProcAddress(Handle, 'DUDIVersion');
    @DUCIVer := GetProcAddress(Handle, 'DUCIVersion');
    @DUHIVer := GetProcAddress(Handle, 'DUHIVersion');

    if ((@DUDIVer <> Nil) and ((DUDIVer = 1) or (DUDIVer = 2))) then
    begin
      @GetNumVer := GetProcAddress(Handle, 'GetNumVersion');

      if (@GetNumVer = nil) then
        result := -1
      else
        result := GetNumVer;
    end
    else if ((@DUCIVer <> Nil) and (DUCIVer = 1)) then
    begin
      @GetConvertVer := GetProcAddress(Handle, 'VersionInfo');

      if (@GetConvertVer = nil) then
        result := -1
      else
        result := GetConvertVer.VerID;
    end
    else if ((@DUHIVer <> Nil) and (DUHIVer = 1)) then
    begin
      @GetHRVer := GetProcAddress(Handle, 'GetVersionInfo');

      if (@GetHRVer = nil) then
        result := -1
      else
        result := GetHRVer.Version;
    end
    else
      result := -1;

    FreeLibrary(handle);
  end
  else
    result := -1;

end;

procedure TfrmMain.txtInstallDirChange(Sender: TObject);
var tmp: FileInfo;
begin

  tmp := FileInfo(lstFiles.Selected.Data);
  tmp.InstallDir := txtInstallDir.Text;
  refreshSelectedInstallTo;

end;

procedure TfrmMain.refreshSelectedInstallTo;
var tmp: FileInfo;
begin

  if txtInstallDir.Text = '' then
    lstFiles.Selected.SubItems.Strings[2] := txtInstallTo.Items.Strings[tmp.InstallTo]
  else
    lstFiles.Selected.SubItems.Strings[2] := txtInstallTo.Items.Strings[tmp.InstallTo] + '\' + txtInstallDir.Text ;

end;

procedure TfrmMain.menuFichier_CompilerClick(Sender: TObject);
begin

  butCompile.Click;

end;

procedure TfrmMain.chkRegSvrClick(Sender: TObject);
var tmp: FileInfo;
begin

  tmp := FileInfo(lstFiles.Selected.Data);
  tmp.RegSvr := chkRegSvr.Checked;

end;

procedure TfrmMain.menuFichier_SaveClick(Sender: TObject);
var head: TJvSimpleXMLElem;
    sub, sub2: TJvSimpleXMLElem;
    tmp: FileInfo;
    x: integer;
begin

  SaveDialog.Title := 'Save project...';
  SaveDialog.Filter := 'Dragon UnPACKer 5 Package Project (*.DPS)|*.DPS';

  if SaveDialog.Execute then
  begin

    SimpleXML.Root.Create(nil);
    SimpleXML.Root.Name := 'DPS';

    SimpleXML.Root.Properties.Add('version',DPSVERSION);

    head := SimpleXML.Root.Items.Add('HEAD');
    sub := head.Items.Add('NAME');
    sub.Value := frmMain.PackName;
    sub := head.Items.Add('URL');
    sub.Value := frmMain.PackURL;
    sub := head.Items.Add('AUTHOR');
    sub.Value := frmMain.PackAuthor;
    sub := head.Items.Add('COMMENT');
    sub.Value := frmMain.PackComment;
    sub := head.Items.Add('VERSION');
    sub.Value := frmPackCfg.txtVersion.text;
    sub := head.Items.Add('CHECKDUP5VERSION');
    sub.Value := frmPackCfg.txtDUP5Version.Text;

    sub.Properties.Add('use',frmPackCfg.chkDUP5.Checked);

    if (frmPackCfg.optCompSup.Checked) then
      sub.Properties.Add('op',1)
    else if (frmPackCfg.optCompInf.Checked) then
      sub.Properties.Add('op',2)
    else if (frmPackCfg.optCompEqual.Checked) then
      sub.Properties.Add('op',0)
    else
      sub.Properties.Add('op',3);

    sub := head.Items.Add('THEME');
    sub.Value := frmPackCfg.txtImageFile.Text;

    sub.Properties.Add('use',frmPackCfg.chkImagePerso.Checked);

    head := SimpleXML.Root.Items.Add('FILES');

    for x := 0 to lstFiles.Items.Count-1 do
    begin
      sub := head.Items.Add('FILE');
      sub.Value := lstFiles.Items.Item[x].Caption;

      tmp := FileInfo(lstFiles.Items.Item[x].Data);
      sub2 := sub.Items.Add('PATH');
      sub2.Value := tmp.Filename;

      sub2 := sub.Items.Add('OPTIONS');
      sub2.Properties.Add('storedatetime',tmp.StoreDateTime);
      sub2.Properties.Add('hidden',tmp.Hidden);
      sub2.Properties.Add('readonly',tmp.ReadOnly);
      sub2.Properties.Add('regsvr',tmp.RegSvr);
      sub2.Properties.Add('updateonly',tmp.UpgradeOnly);
      sub2.Properties.Add('compress',tmp.Compress);

      sub2 := sub.Items.Add('INSTALLDIR');
      sub2.Value := tmp.InstallDir;
      sub2.Properties.Add('basedir',tmp.InstallTo);

      sub2 := sub.Items.Add('INSTALLNAME');
      sub2.Value := lstFiles.Items.Item[x].Caption;
    end;

    SimpleXML.SaveToFile(SaveDialog.FileName);

  end;

end;

procedure TfrmMain.menuFichier_OuvrirClick(Sender: TObject);
var head: TJvSimpleXMLElem;
    sub, sub2: TJvSimpleXMLElem;
    tmp: FileInfo;
    x: integer;
    itmx: TListItem;
    ext: string;
    Handle: THandle;
begin

  Dialog.Title := 'Open project...';
  Dialog.Filter := 'Dragon UnPACKer 5 Package Project (*.DPS)|*.DPS';

  if Dialog.Execute then
  begin

   try

    SimpleXML.LoadFromFile(Dialog.FileName);

    head := SimpleXML.Root.Items.ItemNamed['HEAD'];
    if SimpleXML.Root.Properties.IntValue('version') <> DPSVERSION then
    begin

      ShowMessage('Error: Project file must be version '+inttostr(DPSVERSION)+'.');

    end
    else
    begin

      frmPackCfg.txtName.Text := head.Items.ItemNamed['NAME'].Value;
      frmPackCfg.txtURL.Text := head.Items.ItemNamed['URL'].Value;
      frmPackCfg.txtAuthor.Text := head.Items.ItemNamed['AUTHOR'].Value;
      frmPackCfg.txtComment.Text := head.Items.ItemNamed['COMMENT'].Value;
      frmPackCfg.txtVersion.Text := head.Items.ItemNamed['VERSION'].Value;
      frmPackCfg.txtDUP5Version.Text := head.Items.ItemNamed['CHECKDUP5VERSION'].Value;
      frmPackCfg.chkDUP5.Checked := head.Items.ItemNamed['CHECKDUP5VERSION'].Properties.BoolValue('use',false);
      case head.Items.ItemNamed['CHECKDUP5VERSION'].Properties.IntValue('op',0) of
        1: frmPackCfg.optCompSup.Checked := true;
        2: frmPackCfg.optCompInf.Checked := true;
        3: frmPackCfg.optCompEqual.Checked := true;
      else
        frmPackCfg.optCompDiff.Checked := true;
      end;

      frmPackCfg.txtImageFile.Text := head.Items.ItemNamed['THEME'].Value;
      frmPackCfg.chkImagePerso.Checked := head.Items.ItemNamed['THEME'].Properties.BoolValue('use',false);

      head := SimpleXML.Root.Items.ItemNamed['FILES'];

      lstFiles.Items.Clear;

      for x := 0 to head.Items.Count-1 do
      begin

        sub := head.Items.Item[x];

        if (fileexists(sub.Items.ItemNamed['PATH'].Value)) then
        begin
          itmx := lstFiles.Items.Add;

          itmx.Caption := sub.Items.ItemNamed['INSTALLNAME'].Value;
          itmx.SubItems.Add(IntToStr(GetFSize(sub.Items.ItemNamed['PATH'].Value)));
          itmx.SubItems.Add(DateTimeToStr(FileDateToDateTime(FileAge(sub.Items.ItemNamed['PATH'].Value))));

          tmp := FileInfo.Create(
            sub.Items.ItemNamed['OPTIONS'].Properties.BoolValue('compress',true),
            sub.Items.ItemNamed['OPTIONS'].Properties.BoolValue('updateonly',true),
            sub.Items.ItemNamed['OPTIONS'].Properties.BoolValue('storedatetime',true),
            sub.Items.ItemNamed['OPTIONS'].Properties.BoolValue('readonly',false),
            sub.Items.ItemNamed['OPTIONS'].Properties.BoolValue('hidden',false),
            sub.Items.ItemNamed['OPTIONS'].Properties.BoolValue('regsvr',false),
            sub.Items.ItemNamed['INSTALLDIR'].Properties.IntValue('basedir',0),
            -1,
            sub.Items.ItemNamed['INSTALLNAME'].Value,
            sub.Items.ItemNamed['INSTALLDIR'].Value
          );

          ext := lowercase(ExtractFileExt(sub.Items.ItemNamed['PATH'].Value));
          if ext = '.d5d' then
            tmp.Version := getPluginVersion(sub.Items.ItemNamed['PATH'].Value)
          else if (ext = '.d5c') then
            tmp.Version := getPluginVersion(sub.Items.ItemNamed['PATH'].Value)
          else if (ext = '.d5h') then
            tmp.Version := getPluginVersion(sub.Items.ItemNamed['PATH'].Value);

          if (tmp.Version = -1) then
            tmp.UpgradeOnly := false;

          itmx.SubItems.Add(txtInstallTo.Items.Strings[tmp.InstallTo]);
          itmx.Data := tmp;
        end
        else
        begin
          ShowMessage('Following file was not found:'+#10+#10+sub.Items.ItemNamed['PATH'].Value);
        end;

      end;
    end;

   except
     ShowMessage('Error: Could not load project file.');
   end;

  end;

end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin

  frmMain.Caption := 'Dragon UnPACKer 5 (DUP5) Package Maker v'+getVersion(VERSION);
  lblVersion.Caption := 'Version '+getVersion(VERSION);
  lblCompatible.Caption := 'Compiled the '+DateToStr(CompileTime)+' at '+TimeToStr(CompileTime);

end;

procedure TfrmMain.butExitClick(Sender: TObject);
begin

  Application.Terminate;

end;

procedure TfrmMain.txtVersionChange(Sender: TObject);
begin

  lblPreviewVersion.Caption := getVersion(strtoint(txtVersion.Text));
  PackVersion := StrToInt(txtVersion.Text);

end;

procedure TfrmMain.chkDUP5Click(Sender: TObject);
begin

  PackDUP5Check := chkDUP5.Checked;

  if (PackDUP5Check) then
  begin
    optCompSup.Enabled := true;
    optCompInf.Enabled := true;
    optCompdiff.Enabled := true;
    optCompEqual.Enabled := true;
    txtDUP5Version.Enabled := true;
  end
  else
  begin
    optCompSup.Enabled := false;
    optCompInf.Enabled := false;
    optCompdiff.Enabled := false;
    optCompEqual.Enabled := false;
    txtDUP5Version.Enabled := false;
  end;

end;

procedure TfrmMain.chkImagePersoClick(Sender: TObject);
begin

  PackImagePerso := chkImagePerso.Checked;

end;

end.
