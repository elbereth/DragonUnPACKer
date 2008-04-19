unit Main;

// $Id: Main.pas,v 1.3 2008-03-02 18:27:56 elbereth Exp $
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
    richLog: TJvRichEdit;
    ToolBar: TToolBar;
    butAdd: TToolButton;
    butDel: TToolButton;
    ProgressBar: TProgressBar;
    Label14: TLabel;
    txtPackageFile: TEdit;
    butBrowsePackageFile: TButton;
    GroupBox4: TGroupBox;
    JvImgBtn1: TJvImgBtn;
    butOpen: TJvImgBtn;
    JvImgBtn3: TJvImgBtn;
    butCompile: TJvImgBtn;
    butExit: TButton;
    lblDUPVersion: TStaticText;
    butVersionPrev: TButton;
    butVersionNext: TButton;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    lblFileVersion: TStaticText;
    Label19: TLabel;
    optDUPPv2: TRadioButton;
    optDUPPv3: TRadioButton;
    Label20: TLabel;
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
    procedure JvImgBtn1Click(Sender: TObject);
    procedure txtDUP5VersionChange(Sender: TObject);
    procedure butVersionPrevClick(Sender: TObject);
    procedure butVersionNextClick(Sender: TObject);
    procedure writeLog(text: string);
    procedure butBrowsePackageFileClick(Sender: TObject);
//    function convertInstallTo(val: integer): string;
  private
    { D�clarations priv�es }
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
    { D�clarations publiques }
  end;

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
       ForcedDir: boolean;
       constructor Create(Comp, Upg, StoreDT, ReadO, Hide, Reg: boolean; InstTo: integer; Vers: integer; FName, InstallDir: string);
     end;

var
  frmMain: TfrmMain;
  curFileInfo: FileInfo;
  curSelectedRow: integer;

implementation

uses Compile, Config;

const DPSVERSION = 2;
      VERSION = 20040;

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

procedure TfrmMain.writeLog(text: string);
begin

  if richLog.Lines.Count = 32760 then
    richLog.Lines.Delete(0);

  richLog.Lines.Add(DateTimeToStr(now)+' : '+text);
  richLog.Perform(EM_LINESCROLL,0,1);

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

     writeLog('Starting compilation...');
     ProgressBar.Position := 0;

     fout := FileCreate(txtPackageFile.Text, fmOpenWrite);

     writeLog('+ Filename: '+txtPackageFile.Text);

     HDR.ID := 'DUPP';
     HDR.EOF := 26;

     if (optDUPPv3.Checked) then
       HDR.Version := 3
     else
       HDR.Version := 2;

     HDR.NeededVersion := 0;

     writeLog('+ Format: DUPP v'+inttostr(HDR.Version));

     if HDR.Version = 2 then
     begin
       for x := 0 to lstFiles.Items.Count-1 do
       begin
         tmp := FileInfo(lstFiles.Items.Item[x].Data);
         if (tmp.InstallDir <> '') then
         begin
           HDR.NeededVersion := 20240;
           break;
         end;
       end;

       if (chkImagePerso.Checked and FileExists(txtImageFile.Text)) then
       begin
         HDR.NeededVersion := 20240;
       end;
     end
     else if HDR.Version = 3 then
       HDR.NeededVersion := 22040;

     if (HDR.NeededVersion = 0) then
       writeLog('+ Compatibility: Full')
     else
       writeLog('+ Compatibility: Requires Duppi v'+getVersion(HDR.NeededVersion));

     writeLog('Writing header...');
     FileWrite(fout,HDR,8);

     ProgressBar.Position := 5;

     writeLog('Computing extended header...');

     NFO.NumVer := strtoint(txtVersion.text);
     if (chkDUP5.Checked) then
     begin
       if (optCompSup.Checked) then
         NFO.DUP5VerTest := 1
       else if (optCompInf.Checked) then
         NFO.DUP5VerTest := 2
       else if (optCompEqual.Checked) then
         NFO.DUP5VerTest := 0
       else if (optCompDiff.Checked) then
         NFO.DUP5VerTest := 3;
     end
     else
       NFO.DUP5VerTest := -1;
     NFO.DUP5VerValue := strtoint(txtDUP5Version.Text);
     NFO.NumFiles := lstFiles.Items.Count;

     FillChar(NFO1,SizeOf(NFO1),0);
     NFO1.PictureCompressed := 0;
     NFO1.PictureCompressedSize := 0;

     if (chkImagePerso.Checked and FileExists(txtImageFile.Text)) then
     begin
       writeLog('+ Importing image from: '+txtImageFile.Text);
       hBAN := FileOpen(txtImageFile.Text,fmOpenRead);
       try
         NFO.PictureSize := FileSeek(hBAN,0,2);
         getmem(Buffer,NFO.PictureSize);
         try
           FileSeek(hBAN,0,0);
           FileRead(hBAN,BMP,SizeOf(BMP));
           if ((BMP.ID = 'BM') and (BMP.Width = 465) and (BMP.height = 90)) then
           begin
             writeLog('+ Image is BMP 465x90 as expected... Writing banner ('+inttostr(NFO.PictureSize)+' bytes) & extended header...');
             FileSeek(hBAN,0,0);
             FileRead(hBAN,Buffer^,NFO.PictureSize);
             FileWrite(fout,NFO,20);
             FileWrite(fout,NFO1,SizeOf(NFO1));
             put8(fout,txtName.Text);
             put8(fout,txtURL.Text);
             put8(fout,txtAuthor.Text);
             put8(fout,txtComment.Text);
             FileWrite(fout,Buffer^,NFO.PictureSize);
           end
           else
           begin
             writeLog('+ Image is NOT BMP 465x90 as expected not using banner... Writing extended header...');
             NFO.PictureSize := 0;
             FileWrite(fout,NFO,20);
             put8(fout,txtName.Text);
             put8(fout,txtURL.Text);
             put8(fout,txtAuthor.Text);
             put8(fout,txtComment.Text);
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
       writeLog('+ Writing extended header...');
       NFO.PictureSize := 0;
       FileWrite(fout,NFO,20);
       FileWrite(fout,NFO1,SizeOf(NFO1));
       put8(fout,txtName.Text);
       put8(fout,txtURL.Text);
       put8(fout,txtAuthor.Text);
       put8(fout,txtComment.Text);
     end;

     ProgressBar.Position := 10;

     writeLog('Adding '+inttostr(lstFiles.Items.Count)+' file(s)...');
     for x := 0 to lstFiles.Items.Count-1 do
     begin
       tmp := FileInfo(lstFiles.Items.Item[x].Data);
       writeLog('+ File '+inttostr(x+1)+': '+tmp.Filename);
       fin := FileOpen(tmp.Filename,fmOpenRead);
       ENT.DSize := FileSeek(fin,0,2);
       writeLog('+--+ Size: '+inttostr(ENT.DSize)+' bytes');
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
       if HDR.Version = 3 then
         ENT.CRC := GetBufCRC32(buf,ENT.DSize)
       else
         ENT.CRC := GetStrCRC32(buf^);

       writeLog('+--+ CRC: '+inttohex(ENT.CRC,8));

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
         end;
         writeLog('+--+ Compressed size: '+inttostr(ENT.Size)+' bytes');
       end
       else
       begin
         ENT.Size := ENT.DSize;
         ENT.CompressionType := 0;
       end;

       writeLog('+--+ Writing file data...');

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

       ProgressBar.Position := 10 + round(((x+1)/lstFiles.Items.Count)*90);

     end;

     ProgressBar.Position := 100;
     writeLog('Compilation finished!');
     writeLog('-----------------------------------------------------------------------------------------------------------------------');

     FileClose(fout);

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
        tmp.ForcedDir := true;
        tmp.Version := getPluginVersion(Dialog.Filename);
      end
      else if (ext = '.d5c') then
      begin
        tmp.InstallTo := 0;
        tmp.ForcedDir := true;
        tmp.Version := getPluginVersion(Dialog.Filename);
      end
      else if (ext = '.d5h') then
      begin
        tmp.InstallTo := 3;
        tmp.ForcedDir := true;
        tmp.Version := getPluginVersion(Dialog.Filename);
      end
      else if (ext = '.dpal') then
      begin
        tmp.InstallTo := 0;
        tmp.ForcedDir := true;
      end
      else if (ext = '.dulk') or (ext = '.lng') then
      begin
        tmp.InstallTo := 1;
        tmp.ForcedDir := true;
      end
      else
      begin
        tmp.InstallTo := 4;
      end;

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
//var tmp: FileInfo;
begin

  curSelectedRow := item.Index;

  curFileInfo := FileInfo(item.data);

  txtInstallTo.ItemIndex := curFileInfo.InstallTo;
  txtInstallTo.Enabled := not(curFileInfo.ForcedDir);
  txtInstallDir.Text := curFileInfo.InstallDir;
  txtInstallDir.Enabled := not(curFileInfo.ForcedDir);

  chkStoreDateTime.Checked := curFileInfo.StoreDateTime;
  chkStoreDateTime.Enabled := true;

  chkRegSvr.Checked := curFileInfo.RegSvr;
  if (uppercase(ExtractFileExt(curFileInfo.Filename)) = '.DLL')
  or (uppercase(ExtractFileExt(curFileInfo.Filename)) = '.OCX')
  then
    chkRegSvr.Enabled := true
  else
    chkRegSvr.Enabled := false;

  chkUpgradeOnly.Checked := curFileInfo.UpgradeOnly;
  chkUpgradeOnly.Enabled := (curFileInfo.Version > -1);

  chkCompress.Checked := curFileInfo.Compress;
  chkCompress.Enabled := true;

  chkReadOnly.Checked := curFileInfo.ReadOnly;
  chkReadOnly.Enabled := true;
  chkHidden.Checked := curFileInfo.Hidden;
  chkHidden.Enabled := true;

  if curFileInfo.Version <> -1 then
    lblFileVersion.Caption := getVersion(curFileInfo.Version)
  else
    lblFileVersion.Caption := '';

  butDel.Enabled := true;

end;

procedure TfrmMain.chkCompressClick(Sender: TObject);
//var tmp: FileInfo;
begin

//  tmp := FileInfo(lstFiles.Selected.Data);
  curFileInfo.Compress := chkCompress.Checked;

end;

procedure TfrmMain.butDelClick(Sender: TObject);
begin

  if (lstFiles.SelCount > 0) then
  begin
    lstFiles.Items.Delete(lstFiles.Selected.Index);
    curSelectedRow := -1;
  end;

  butDel.Enabled := false;

  txtInstallTo.Enabled := false;
  txtInstallTo.ItemIndex := 4;
  txtInstallDir.Enabled := false;
  txtInstallDir.Text := '';
  chkCompress.Enabled := false;
  chkUpgradeOnly.Enabled := false;
  chkStoreDateTime.Enabled := false;
  chkRegSvr.Enabled := false;
  chkReadOnly.Enabled := false;
  chkHidden.Enabled := false;
  lblFileVersion.Caption := '';

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

  ForcedDir := false;

end;

procedure TfrmMain.chkUpgradeOnlyClick(Sender: TObject);
//var tmp: FileInfo;
begin

//  tmp := FileInfo(lstFiles.Selected.Data);
  curFileInfo.UpgradeOnly := chkUpgradeOnly.Checked;

end;

procedure TfrmMain.chkStoreDateTimeClick(Sender: TObject);
//var tmp: FileInfo;
begin

//  tmp := FileInfo(lstFiles.Selected.Data);
  curFileInfo.StoreDateTime := chkStoreDateTime.Checked;

end;

procedure TfrmMain.chkReadOnlyClick(Sender: TObject);
//var tmp: FileInfo;
begin

//  tmp := FileInfo(lstFiles.Selected.Data);
  curFileInfo.ReadOnly := chkReadOnly.Checked;

end;

procedure TfrmMain.chkHiddenClick(Sender: TObject);
//var tmp: FileInfo;
begin

//  tmp := FileInfo(lstFiles.Selected.Data);
  curFileInfo.Hidden := chkHidden.checked;

end;

procedure TfrmMain.txtInstallToChange(Sender: TObject);
//var tmp: FileInfo;
begin

//  tmp := FileInfo(lstFiles.Selected.Data);
  curFileInfo.InstallTo := txtInstallTo.ItemIndex;
  refreshSelectedInstallTo;

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

    if ((@DUDIVer <> Nil) and ((DUDIVer = 1) or (DUDIVer = 2) or (DUDIVer = 3) or (DUDIVer = 4))) then
    begin
      @GetNumVer := GetProcAddress(Handle, 'GetNumVersion');

      if (@GetNumVer = nil) then
        result := -1
      else
        result := GetNumVer;
    end
    else if ((@DUCIVer <> Nil) and ((DUCIVer = 1) or (DUCIVer = 2) or (DUCIVer = 3))) then
    begin
      @GetConvertVer := GetProcAddress(Handle, 'VersionInfo');

      if (@GetConvertVer = nil) then
        result := -1
      else
        result := GetConvertVer.VerID;
    end
    else if ((@DUHIVer <> Nil) and ((DUHIVer = 1) or (DUHIVer = 2) or (DUHIVer = 3))) then
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
//var tmp: FileInfo;
begin

//  tmp := FileInfo(lstFiles.Selected.Data);
  curFileInfo.InstallDir := txtInstallDir.Text;
  refreshSelectedInstallTo;

end;

procedure TfrmMain.refreshSelectedInstallTo;
begin

  if curSelectedRow <> -1 then
    if txtInstallDir.Text = '' then
      lstFiles.Items.Item[curSelectedRow].SubItems.Strings[2] := txtInstallTo.Items.Strings[curFileInfo.InstallTo]
    else
      lstFiles.Items.Item[curSelectedRow].SubItems.Strings[2] := txtInstallTo.Items.Strings[curFileInfo.InstallTo] + '\' + curFileInfo.InstallDir;

end;

procedure TfrmMain.menuFichier_CompilerClick(Sender: TObject);
begin

  butCompile.Click;

end;

procedure TfrmMain.chkRegSvrClick(Sender: TObject);
//var tmp: FileInfo;
begin

//  tmp := FileInfo(lstFiles.Selected.Data);
  curFileInfo.RegSvr := chkRegSvr.Checked;

end;

procedure TfrmMain.menuFichier_SaveClick(Sender: TObject);
var head: TJvSimpleXMLElem;
    sub, sub2: TJvSimpleXMLElem;
    tmp: FileInfo;
    x: integer;
    SimpleXML: TJvSimpleXML;
begin

  SaveDialog.Title := 'Save project...';
  SaveDialog.Filter := 'Dragon UnPACKer 5 Package Project (*.D5PP)|*.D5PP';

  if SaveDialog.Execute then
  begin

    SimpleXML := TJvSimpleXML.Create(self);

    SimpleXML.Root.Create(nil);
    SimpleXML.Root.Name := 'DPS';

    SimpleXML.Root.Properties.Add('version',DPSVERSION);

    head := SimpleXML.Root.Items.Add('HEAD');
    sub := head.Items.Add('NAME');
    sub.Value := txtName.Text;
    sub := head.Items.Add('URL');
    sub.Value := txtURL.Text;
    sub := head.Items.Add('AUTHOR');
    sub.Value := txtAuthor.Text;
    sub := head.Items.Add('COMMENT');
    sub.Value := txtComment.Text;
    sub := head.Items.Add('VERSION');
    sub.Value := txtVersion.text;
    sub := head.Items.Add('PACKFILENAME');
    sub.Value := txtPackageFile.Text;
    if optDUPPv3.Checked then
      sub.Properties.Add('duppversion',3)
    else
      sub.Properties.Add('duppversion',2);
    sub := head.Items.Add('CHECKDUP5VERSION');
    sub.Value := txtDUP5Version.Text;

    sub.Properties.Add('use',chkDUP5.Checked);

    if (optCompSup.Checked) then
      sub.Properties.Add('op',1)
    else if (optCompInf.Checked) then
      sub.Properties.Add('op',2)
    else if (optCompEqual.Checked) then
      sub.Properties.Add('op',0)
    else
      sub.Properties.Add('op',3);

    sub := head.Items.Add('THEME');
    sub.Value := txtImageFile.Text;

    sub.Properties.Add('use',chkImagePerso.Checked);

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
    SimpleXML.Destroy;

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
    SimpleXML: TJvSimpleXML;
begin

  Dialog.Title := 'Open project...';
  Dialog.Filter := 'Dragon UnPACKer 5 Package Project (*.D5PP)|*.D5PP';

  if Dialog.FileName <> '' then
    Dialog.FileName := ExtractFilePath(Dialog.FileName);

  if Dialog.Execute then
  begin

   try

    SimpleXML := TJvSimpleXML.Create(self);
    SimpleXML.LoadFromFile(Dialog.FileName);

    head := SimpleXML.Root.Items.ItemNamed['HEAD'];

    if (SimpleXML.Root.Properties.IntValue('version') <> DPSVERSION) and
       (SimpleXML.Root.Properties.IntValue('version') <> 1) then
    begin

      ShowMessage('Error: Project file must be version '+inttostr(DPSVERSION)+' (v1 are also supported).');

    end
    else
    begin

      txtName.Text := head.Items.ItemNamed['NAME'].Value;
      txtURL.Text := head.Items.ItemNamed['URL'].Value;
      txtAuthor.Text := head.Items.ItemNamed['AUTHOR'].Value;
      txtComment.Text := head.Items.ItemNamed['COMMENT'].Value;
      txtVersion.Text := head.Items.ItemNamed['VERSION'].Value;
      if head.Items.IndexOf('PACKFILENAME') <> -1 then
      begin
        txtPackageFile.Text := head.Items.ItemNamed['PACKFILENAME'].Value;
        case head.Items.ItemNamed['PACKFILENAME'].Properties.IntValue('duppversion',0) of
          2: optDUPPv2.Checked := true;
          3: optDUPPv3.Checked := true;
        else
          optDUPPv3.Checked := true;
        end;
      end;
      txtDUP5Version.Text := head.Items.ItemNamed['CHECKDUP5VERSION'].Value;
      chkDUP5.Checked := head.Items.ItemNamed['CHECKDUP5VERSION'].Properties.BoolValue('use',false);
      case head.Items.ItemNamed['CHECKDUP5VERSION'].Properties.IntValue('op',0) of
        1: optCompSup.Checked := true;
        2: optCompInf.Checked := true;
        3: optCompEqual.Checked := true;
      else
        optCompDiff.Checked := true;
      end;

      txtImageFile.Text := head.Items.ItemNamed['THEME'].Value;
      chkImagePerso.Checked := head.Items.ItemNamed['THEME'].Properties.BoolValue('use',false);

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
            sub.Items.ItemNamed['PATH'].Value,
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

    SimpleXML.Destroy;

   except
     ShowMessage('Error: Could not load project file.');
   end;

  end;

end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin

  frmMain.Caption := 'Dragon UnPACKer 5 (D5P) Package Maker v'+getVersion(VERSION);
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
    butVersionPrev.Enabled := true;
    butVersionNext.Enabled := true;
  end
  else
  begin
    optCompSup.Enabled := false;
    optCompInf.Enabled := false;
    optCompdiff.Enabled := false;
    optCompEqual.Enabled := false;
    txtDUP5Version.Enabled := false;
    butVersionPrev.Enabled := false;
    butVersionNext.Enabled := false;
  end;

end;

procedure TfrmMain.chkImagePersoClick(Sender: TObject);
begin

  PackImagePerso := chkImagePerso.Checked;

end;

procedure TfrmMain.JvImgBtn1Click(Sender: TObject);
begin

  txtVersion.Text := '10000';
  PackVersion := 10000;
  txtName.Text := '';
  txtURL.Text := '';
  txtAuthor.Text := '';
  txtComment.Text := '';
  txtImageFile.Text := '';
  chkImagePerso.Checked := false;
  txtImageFile.Enabled := false;
  butBrowseImage.Enabled := false;
  chkDUP5.Checked := false;
  optCompSup.Checked := true;
  txtDUP5Version.Text := '169';
  txtDUP5Version.Enabled := false;

  lstFiles.Clear;

  txtInstallTo.Enabled := false;
  txtInstallDir.Enabled := false;
  chkCompress.Enabled := false;
  chkUpgradeOnly.Enabled := false;
  chkStoreDateTime.Enabled := false;
  chkRegSvr.Enabled := false;
  chkReadOnly.Enabled := false;
  chkHidden.Enabled := false;

  butDel.Enabled := false;

end;

procedure TfrmMain.txtDUP5VersionChange(Sender: TObject);
var checkBuild: integer;
begin

  try
    checkBuild := strToint(txtDUP5Version.Text);
    case checkBuild of
       2: lblDUPVersion.Caption := 'v5.0.0 Preview';
       3: lblDUPVersion.Caption := 'v5.0.0 Pre-Alpha 1';
       5: lblDUPVersion.Caption := 'v5.0.0 Pre-Alpha 2';
       7: lblDUPVersion.Caption := 'v5.0.0 Pre-Alpha 3';
       8: lblDUPVersion.Caption := 'v5.0.0 Pre-Alpha 4';
       9: lblDUPVersion.Caption := 'v5.0.0 Pre-Alpha 5';
       10: lblDUPVersion.Caption := 'v5.0.0 Pre-Alpha 6';
       12: lblDUPVersion.Caption := 'v5.0.0 Pre-Alpha 7';
       13: lblDUPVersion.Caption := 'v5.0.0 Pre-Alpha 8';
       17: lblDUPVersion.Caption := 'v5.0.0 Pre-Alpha 9';
       23: lblDUPVersion.Caption := 'v5.0.0 Alpha 1';
       27: lblDUPVersion.Caption := 'v5.0.0 Alpha 2';
       29: lblDUPVersion.Caption := 'v5.0.0 Alpha 3';
       36: lblDUPVersion.Caption := 'v5.0.0 Alpha 4';
       39: lblDUPVersion.Caption := 'v5.0.0 Alpha 5';
       40: lblDUPVersion.Caption := 'v5.0.0 Alpha 6';
       43: lblDUPVersion.Caption := 'v5.0.0 Alpha 7';
       45: lblDUPVersion.Caption := 'v5.0.0 Alpha 8';
       48: lblDUPVersion.Caption := 'v5.0.0 Alpha 9';
       50: lblDUPVersion.Caption := 'v5.0.0 Alpha 10';
       51: lblDUPVersion.Caption := 'v5.0.0 Alpha 10.1';
       55: lblDUPVersion.Caption := 'v5.0.0 Alpha 11';
       56: lblDUPVersion.Caption := 'v5.0.0 Alpha 11.1';
       60: lblDUPVersion.Caption := 'v5.0.0 Beta 1';
       77: lblDUPVersion.Caption := 'v5.0.0 Beta 2';
       86: lblDUPVersion.Caption := 'v5.0.0 Beta 3';
       95: lblDUPVersion.Caption := 'v5.0.0 Beta 4';
      109: lblDUPVersion.Caption := 'v5.0.0 RC1';
      119: lblDUPVersion.Caption := 'v5.0.0 RC2';
      127: lblDUPVersion.Caption := 'v5.0.0 RC3';
      129: lblDUPVersion.Caption := 'v5.0.0 RC4';
      134: lblDUPVersion.Caption := 'v5.0.0';
      144: lblDUPVersion.Caption := 'v5.1.0 WIP';
      149: lblDUPVersion.Caption := 'v5.1.1 WIP';
      163: lblDUPVersion.Caption := 'v5.1.2 WIP';
      165: lblDUPVersion.Caption := 'v5.2.0 RC1';
      167: lblDUPVersion.Caption := 'v5.2.0';
      168: lblDUPVersion.Caption := 'v5.2.0a';
      169: lblDUPVersion.Caption := 'v5.2.0b';
    else
      lblDUPVersion.Caption := '???';
    end;
  except
    on EConvertError do
      lblDUPVersion.Caption := '???';
  end;

end;

procedure TfrmMain.butVersionPrevClick(Sender: TObject);
var oldValue: integer;
begin

  try
    oldValue := strToint(txtDUP5Version.Text);
    if (oldValue <= 3) then
      txtDUP5Version.Text := '2'
    else
      case oldValue of
       5: txtDUP5Version.Text := '3';
       7: txtDUP5Version.Text := '5';
       8: txtDUP5Version.Text := '7';
       9: txtDUP5Version.Text := '8';
       10: txtDUP5Version.Text := '9';
       12: txtDUP5Version.Text := '10';
       13: txtDUP5Version.Text := '12';
       17: txtDUP5Version.Text := '13';
       23: txtDUP5Version.Text := '17';
       27: txtDUP5Version.Text := '23';
       29: txtDUP5Version.Text := '27';
       36: txtDUP5Version.Text := '29';
       39: txtDUP5Version.Text := '36';
       40: txtDUP5Version.Text := '39';
       43: txtDUP5Version.Text := '40';
       45: txtDUP5Version.Text := '43';
       48: txtDUP5Version.Text := '45';
       50: txtDUP5Version.Text := '48';
       51: txtDUP5Version.Text := '50';
       55: txtDUP5Version.Text := '51';
       56: txtDUP5Version.Text := '55';
       60: txtDUP5Version.Text := '56';
       77: txtDUP5Version.Text := '60';
       86: txtDUP5Version.Text := '77';
       95: txtDUP5Version.Text := '86';
      109: txtDUP5Version.Text := '95';
      119: txtDUP5Version.Text := '109';
      127: txtDUP5Version.Text := '119';
      129: txtDUP5Version.Text := '127';
      134: txtDUP5Version.Text := '129';
      144: txtDUP5Version.Text := '134';
      149: txtDUP5Version.Text := '144';
      163: txtDUP5Version.Text := '149';
      165: txtDUP5Version.Text := '163';
      167: txtDUP5Version.Text := '165';
      168: txtDUP5Version.Text := '167';
      169: txtDUP5Version.Text := '168';
    else
      txtDUP5Version.Text := inttostr(oldValue-1);
    end;
  except
    on EConvertError do
      txtDUP5Version.Text := '2';
  end;

end;

procedure TfrmMain.butVersionNextClick(Sender: TObject);
var oldValue: integer;
begin

  try
    oldValue := strToint(txtDUP5Version.Text);
    if (oldValue < 2) then
      txtDUP5Version.Text := '2'
    else
      case oldValue of
       2: txtDUP5Version.Text := '3';
       3: txtDUP5Version.Text := '5';
       5: txtDUP5Version.Text := '7';
       7: txtDUP5Version.Text := '8';
       8: txtDUP5Version.Text := '9';
       9: txtDUP5Version.Text := '10';
       10: txtDUP5Version.Text := '12';
       12: txtDUP5Version.Text := '13';
       13: txtDUP5Version.Text := '17';
       17: txtDUP5Version.Text := '23';
       23: txtDUP5Version.Text := '27';
       27: txtDUP5Version.Text := '29';
       29: txtDUP5Version.Text := '36';
       36: txtDUP5Version.Text := '39';
       39: txtDUP5Version.Text := '40';
       40: txtDUP5Version.Text := '43';
       43: txtDUP5Version.Text := '45';
       45: txtDUP5Version.Text := '48';
       48: txtDUP5Version.Text := '50';
       50: txtDUP5Version.Text := '51';
       51: txtDUP5Version.Text := '55';
       55: txtDUP5Version.Text := '56';
       56: txtDUP5Version.Text := '60';
       60: txtDUP5Version.Text := '77';
       77: txtDUP5Version.Text := '86';
       86: txtDUP5Version.Text := '95';
       95: txtDUP5Version.Text := '109';
      109: txtDUP5Version.Text := '119';
      119: txtDUP5Version.Text := '127';
      127: txtDUP5Version.Text := '129';
      129: txtDUP5Version.Text := '134';
      134: txtDUP5Version.Text := '144';
      144: txtDUP5Version.Text := '149';
      149: txtDUP5Version.Text := '163';
      163: txtDUP5Version.Text := '165';
      165: txtDUP5Version.Text := '167';
      167: txtDUP5Version.Text := '168';
      168: txtDUP5Version.Text := '169';
    else
      txtDUP5Version.Text := inttostr(oldValue+1);
    end;
  except
    on EConvertError do
      txtDUP5Version.Text := '169';
  end;

end;

procedure TfrmMain.butBrowsePackageFileClick(Sender: TObject);
begin


  SaveDialog.Title := 'Packge filename...';
  SaveDialog.Filter := 'Dragon UnPACKer 5 Package (*.D5P)|*.D5P';

  if SaveDialog.Execute then
  begin
    txtPackageFile.Text := SaveDialog.Filename;
  end;

end;

end.