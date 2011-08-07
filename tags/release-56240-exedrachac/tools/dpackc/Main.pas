unit Main;

// $Id$
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
  Dialogs, ComCtrls, StdCtrls, Menus, ToolWin, ImgList, ExtCtrls, Buttons,
  lib_crc, lib_zlib, spec_DUPP, lib_version, lib_binutils, BrowseForFolderU,
  ULZMAEnc,UBufferedFS,DCPsha512,DCPsha256,DCPsha1,DCPmd5,DCPripemd160,DCPcrypt2,
  // JVCL is used for XML manipulation (project files)
  JvSimpleXml;

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
     DirEntry = record
       FileName: string;
       FileSize: integer;
       FileHash: array[0..63] of byte;
       Hashed: boolean;
       Value: boolean;
       ToDelete: boolean;
     end;
     PDirEntry = ^DirEntry;

  TfrmMain = class(TForm)
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
    chkImagePerso: TCheckBox;
    txtImageFile: TEdit;
    butBrowseImage: TButton;
    TabSheet4: TTabSheet;
    richLog: TRichEdit;
    ToolBar: TToolBar;
    butAdd: TToolButton;
    butDel: TToolButton;
    ProgressBar: TProgressBar;
    Label14: TLabel;
    txtPackageFile: TEdit;
    butBrowsePackageFile: TButton;
    GroupBox4: TGroupBox;
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
    TabSheet5: TTabSheet;
    grpCompressionOptions: TGroupBox;
    chkCompressNone: TCheckBox;
    chkCompressZlib: TCheckBox;
    chkCompressLZMA: TCheckBox;
    GroupBox6: TGroupBox;
    optFileHashMD5: TRadioButton;
    optFileHashSHA1: TRadioButton;
    optFileHashSHA256: TRadioButton;
    optFileHashSHA512: TRadioButton;
    optFileHashRipemd160: TRadioButton;
    GroupBox7: TGroupBox;
    optFileCompressSingle: TRadioButton;
    optFileCompressSolid: TRadioButton;
    GroupBox8: TGroupBox;
    optDUPPv2: TRadioButton;
    optDUPPv3: TRadioButton;
    optDUPPv4: TRadioButton;
    txtComment: TMemo;
    lblCommentMax: TLabel;
    lblNameMax: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    lblURLMax: TLabel;
    Label23: TLabel;
    lblAuthorMax: TLabel;
    lblCommentMaxMax: TLabel;
    TabSheet6: TTabSheet;
    txtUpdateDir1: TEdit;
    butOldVersionBrowse: TButton;
    txtUpdateDir2: TEdit;
    butNewVersionBrowse: TButton;
    Label22: TLabel;
    Label24: TLabel;
    GroupBox5: TGroupBox;
    GroupBox9: TGroupBox;
    GroupBox10: TGroupBox;
    Label25: TLabel;
    Label26: TLabel;
    lblDir1Num: TLabel;
    lblDir1Size: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    lblDir2Num: TLabel;
    Label32: TLabel;
    lblDir2Size: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    lblUpdNum: TLabel;
    Label37: TLabel;
    lblUpdSize: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    lblUpdSaved: TLabel;
    Label42: TLabel;
    lblUpdSavedPercent: TLabel;
    GroupBox11: TGroupBox;
    ProgressBarUpdate: TProgressBar;
    lblUpdateInfo: TLabel;
    butNew: TSpeedButton;
    butOpen: TSpeedButton;
    butSave: TSpeedButton;
    butDiff: TSpeedButton;
    butCompile: TSpeedButton;
    shapeComment: TShape;
    shapeAuthor: TShape;
    shapeURL: TShape;
    shapeName: TShape;
    GroupBox12: TGroupBox;
    chkOverrideNeededVersion: TCheckBox;
    txtOverrideNeededVersion: TEdit;
    chkDelete: TCheckBox;
    Label27: TLabel;
    lblDir2DelNum: TLabel;
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
    procedure butNewClick(Sender: TObject);
    procedure txtDUP5VersionChange(Sender: TObject);
    procedure butVersionPrevClick(Sender: TObject);
    procedure butVersionNextClick(Sender: TObject);
    procedure writeLog(text: string);
    procedure butBrowsePackageFileClick(Sender: TObject);
    procedure optDUPPClick(Sender: TObject);
    procedure butBrowseImageClick(Sender: TObject);
    procedure txtNameChange(Sender: TObject);
    procedure txtURLChange(Sender: TObject);
    procedure txtAuthorChange(Sender: TObject);
    procedure txtCommentChange(Sender: TObject);
    procedure chkCompressNoneClick(Sender: TObject);
    procedure chkCompressZlibClick(Sender: TObject);
    procedure chkCompressLZMAClick(Sender: TObject);
    procedure butNewUpdateClick(Sender: TObject);
    procedure butOldVersionBrowseClick(Sender: TObject);
    procedure butNewVersionBrowseClick(Sender: TObject);
    procedure JvImgBtn1Click(Sender: TObject);
    procedure chkOverrideNeededVersionClick(Sender: TObject);
    procedure chkDeleteClick(Sender: TObject);
//    function convertInstallTo(val: integer): string;
  private
    { Déclarations privées }
    function getPluginVersion(filename: String): Integer;
    function compressDUPPv4best(tmpStream: TStream; var CmpType: Byte): TMemoryStream;
    procedure refreshSelectedInstallTo;
    procedure refreshAvailableOptions;
    procedure createDUPPv2_v3;
    procedure createDUPPv4;
    procedure diffDirectories(dir1, dir2: String);
    function getFilesTreeFromDirectory(root, dirName: string): TList;
    procedure addFile(filename: string; installTo: integer = -1; deleteFile: boolean = false);
    procedure reinitFilesTab();
    function checkIfDeleteFile(): boolean;
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

type FileInfo = class
     public
       Compress: boolean;
       CompressType: byte;
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
       DeleteFile: boolean;
       constructor Create(Comp, Upg, StoreDT, ReadO, Hide, Reg, DelFile: boolean; CompType, InstTo: integer; Vers: integer; FName, InstallDir: string);
     end;

var
  frmMain: TfrmMain;
  curFileInfo: FileInfo;
  curSelectedRow: integer;

implementation

uses Compile, Config;

const DPSVERSION = 5;
      VERSION: integer = 36140;

{$R *.dfm}

{$Include datetime.inc}

function TfrmMain.checkIfDeleteFile(): boolean;
var x: integer;
    tmpFileInfo: FileInfo;
begin

  result := false;
  for x := 0 to lstFiles.Items.Count-1 do
  begin
    tmpFileInfo := FileInfo(lstFiles.Items.Item[x].Data);
    result := result or tmpFileInfo.DeleteFile;
  end;

end;

procedure TfrmMain.refreshAvailableOptions;
begin

  chkCompressNone.Enabled := optDUPPv4.Checked;
  chkCompressZlib.Enabled := optDUPPv4.Checked;
  chkCompressLZMA.Enabled := optDUPPv4.Checked;

  optFileCompressSingle.Enabled := optDUPPv4.Checked;
  optFileCompressSolid.Enabled := optDUPPv4.Checked;

  optFileHashMD5.Enabled := optDUPPv4.Checked;
  optFileHashSHA1.Enabled := optDUPPv4.Checked;
  optFileHashSHA256.Enabled := optDUPPv4.Checked;
  optFileHashSHA512.Enabled := optDUPPv4.Checked;
  optFileHashRIPEMD160.Enabled := optDUPPv4.Checked;

  chkOverrideNeededVersion.Enabled := optDUPPv4.Checked;

  if optDUPPv4.Checked then
    lblCommentMaxMax.Caption := 'Max: 32767'
  else
    lblCommentMaxMax.Caption := 'Max: 255';

end;

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

procedure TfrmMain.createDUPPv2_v3();
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
//    Size: Integer;
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

       if tmp.InstallTo > 4 then
         ENT.BaseInstallDir := 4
       else
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

function TfrmMain.compressDUPPv4best(tmpStream: TStream; var CmpType: Byte): TMemoryStream;
var TmpNone, TmpZlib, TmpLZMA: TMemoryStream;
    ZlibStream: TCompressionStream;
begin

  TmpNone := TMemoryStream.Create;
  TmpZlib := TMemoryStream.Create;
  TmpLZMA := TMemoryStream.Create;

  tmpStream.Seek(0,0);
  TmpNone.CopyFrom(tmpStream,tmpStream.Size);

  writeLog('+-+ Compressing block (Size: '+inttostr(tmpNone.Size)+' bytes)');

  if (chkCompressLZMA.Checked) then
  begin
    // Compress with LZMA
    writeLog('+---+ LZMA');
     TmpLZMA := TMemoryStream.Create;
    tmpNone.Seek(0,0);
    lzma_encode(tmpNone,TmpLZMA);
    writeLog('+-----+ OK (Size: '+inttostr(TmpLZMA.Size)+' bytes - '+floattostrF(((TmpLZMA.size/tmpNone.Size)*100),ffFixed,1,1)+'%)');
  end;

  if (chkCompressZlib.Checked) then
  begin
    writeLog('+---+ Zlib');
    TmpZlib := TMemoryStream.Create;
    tmpNone.Seek(0,0);
    ZlibStream := TCompressionStream.Create(clMax, tmpZlib);
    try
      ZlibStream.CopyFrom(tmpNone,tmpNone.Size);
    finally
      ZlibStream.Free;
    end;
    writeLog('+-----+ OK (Size: '+inttostr(TmpZlib.Size)+' bytes - '+floattostrF(((TmpZlib.size/tmpNone.Size)*100),ffFixed,1,1)+'%)');
  end;

  if chkCompressNone.Checked and ((chkCompressZlib.Checked and chkCompressLzma.Checked and (tmpNone.Size <= tmpZlib.Size) and (tmpNone.Size <= tmpLZMA.Size))
                               or (chkCompressZlib.Checked and not(chkCompressLzma.Checked) and (tmpNone.Size <= tmpZlib.Size))
                               or (not(chkCompressZlib.Checked) and chkCompressLzma.Checked and (tmpNone.Size <= tmpLzma.Size))
                               or (not(chkCompressZlib.Checked) and not(chkCompressLzma.Checked))) then
  begin
    writeLog('+---+ Best: No compression');
    cmpType := D5PCOMPRESSION_NONE;
    result := tmpNone;

    if tmpZlib <> nil then
      tmpZlib.Free;
    if tmpLzma <> nil then
      tmpLzma.Free;
  end
  else if chkCompressZlib.Checked and ((chkCompressNone.Checked and chkCompressLzma.Checked and (tmpZlib.Size < tmpNone.Size) and (tmpZlib.Size < tmpLZMA.Size))
                               or (chkCompressNone.Checked and not(chkCompressLzma.Checked) and (tmpZlib.Size < tmpNone.Size))
                               or (not(chkCompressNone.Checked) and chkCompressLzma.Checked and (tmpZlib.Size < tmpLzma.Size))
                               or (not(chkCompressNone.Checked) and not(chkCompressLzma.Checked))) then
  begin
    writeLog('+---+ Best: Zlib');
    cmpType := D5PCOMPRESSION_ZLIB;
    result := tmpZlib;

    if tmpNone <> nil then
      tmpNone.Free;
    if tmpLzma <> nil then
      tmpLzma.Free;
  end
  else if chkCompressLZMA.Checked and ((chkCompressNone.Checked and chkCompressZlib.Checked and (tmpLzma.Size < tmpNone.Size) and (tmpLzma.Size < tmpZlib.Size))
                               or (chkCompressNone.Checked and not(chkCompressZlib.Checked) and (tmpLzma.Size < tmpNone.Size))
                               or (not(chkCompressNone.Checked) and chkCompressZlib.Checked and (tmpLzma.Size < tmpZlib.Size))
                               or (not(chkCompressNone.Checked) and not(chkCompressZlib.Checked))) then
  begin
    writeLog('+---+ Best: LZMA');
    cmpType := D5PCOMPRESSION_LZMA;
    result := tmpLZMA;

    if tmpNone <> nil then
      tmpNone.Free;
    if tmpZlib <> nil then
      tmpZlib.Free;
  end
  else
    raise Exception.Create('No compression found!'); 

end;

procedure TfrmMain.createDUPPv4();
var HDR: DUP5PACK_Header_v4;
    BlocksOffsets: array of DUP5PACK_Offsets_v4;
    Blocks: array of TMemoryStream;
    NFO: DUP5PACK_Info_v4;
    Files: array of DUP5PACK_File_v4;
    FilesData: array of TMemoryStream;
    FTR: DUP5PACK_Footer_v4;
    Hash_SHA256: TDCP_sha256;
//    Hash_SHA512: TDCP_sha512;
    Hash_Engine: TDCP_hash;
    HashUsed: Integer;
    TmpStream, TmpStream2, TmpStream4: TStream;
    TmpStream3: TMemoryStream;
    x,i,CurBlock,entriesBlock,dataBlock,namesBlock: integer;
    BMP: BMPHeader;
    fInfo: FileInfo;
    fIn, fOut: TStream;
    s: String;
begin

  writeLog('Creating Dragon UnPACKer Package [DUPP] v4...');
  ProgressBar.Position := 0;

  writeLog('+ Initializing hash engines...');
  writeLog('+-+ Block hash: SHA256');
  Hash_SHA256 := TDCP_sha256.Create(Self);

  if (optFileHashMD5.Checked) then
  begin
    writeLog('+-+ File hash: MD5');
    HashUsed := D5PHASH_MD5;
    Hash_Engine := TDCP_md5.Create(Self);
  end
  else if (optFileHashSHA1.Checked) then
  begin
    writeLog('+-+ File hash: SHA1');
    HashUsed := D5PHASH_SHA1;
    Hash_Engine := TDCP_sha1.Create(Self);
  end
  else if (optFileHashSHA256.Checked) then
  begin
    writeLog('+-+ File hash: SHA256');
    HashUsed := D5PHASH_SHA256;
    Hash_Engine := TDCP_sha256.Create(Self);
  end
  else if (optFileHashSHA256.Checked) then
  begin
    writeLog('+-+ File hash: RIPEMD160');
    HashUsed := D5PHASH_RIPEMD160;
    Hash_Engine := TDCP_ripemd160.Create(Self);
  end
  else
  begin
    writeLog('+-+ File hash: SHA512');
    HashUsed := D5PHASH_SHA512;
    Hash_Engine := TDCP_sha512.Create(Self);
  end;

  writeLog('+ Generating header...');

  // --------------------------------------------------------------------------
  // === HEADER ===============================================================
  // --------------------------------------------------------------------------

  FillChar(HDR,SizeOf(DUP5PACK_Header_v4),0);
  HDR.ID := 'DUPP';
  HDR.EOF := 26;
  HDR.Version := 4;

  if chkOverrideNeededVersion.Checked then
  begin
    try
      HDR.NeededVersion := strtoint(txtOverrideNeededVersion.Text);
    except
      on EConvertError do
      begin
        if checkIfDeleteFile then
          HDR.NeededVersion := 32040
        else
          HDR.NeededVersion := 30040;
      end;
    end;
  end
  else
    if checkIfDeleteFile then
      HDR.NeededVersion := 32040
    else
      HDR.NeededVersion := 30040;

  writeLog('+-+ Compatibility: Duppi v'+getVersion(HDR.NeededVersion));

  // There will be at least 4 blocks
  HDR.NumOffsets := 4;

  SetLength(BlocksOffsets,HDR.NumOffsets);
  SetLength(Blocks,HDR.NumOffsets);

  curBlock := 0;

  // --------------------------------------------------------------------------
  // === INFORMATION BLOCK ====================================================
  // --------------------------------------------------------------------------

  writeLog('+ Generating information block...');

  // Fill block offset data (minus Offset & Hash that will be calculated afterwards)
  BlocksOffsets[curBlock].ID := D5PID_INFORMATION;                 // Information block
  BlocksOffsets[curBlock].OptionsFlags := 0;     // Block is compressed
  BlocksOffsets[curBlock].CompanionOfID := 0;                      // This is a main block
  BlocksOffsets[curBlock].NumEntries := 0;                         // No entry based block

  // Fill block information
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

  // Create block content
  tmpStream := TMemoryStream.Create;
  tmpStream.Write(NFO,SizeOf(DUP5PACK_Info_v4));
  put8(tmpStream,txtName.Text);
  put8(tmpStream,txtURL.Text);
  put8(tmpStream,txtAuthor.Text);
  put32(tmpStream,txtComment.Text);

  Blocks[curBlock] := compressDUPPv4best(tmpStream,BlocksOffsets[curBlock].CompressionType);

  if BlocksOffsets[curBlock].CompressionType <> D5PCOMPRESSION_NONE then
  begin
    BlocksOffsets[curBlock].OptionsFlags := BlocksOffsets[curBlock].OptionsFlags or D5PBLOCK_COMPRESSED;
    // Indicate size of block
    BlocksOffsets[curBlock].DSize := tmpStream.Size;
  end
  else
  begin
    // Indicate size of block
    BlocksOffsets[curBlock].DSize := 0;
  end;

  BlocksOffsets[curBlock].Size := Blocks[curBlock].Size;

  writeLog('+-+ Calculating hash of the block...');

  // Calculates SHA-256 hash of the block
  Blocks[curBlock].Seek(0,0);
  Hash_SHA256.Init;
  Hash_SHA256.UpdateStream(Blocks[curBlock],Blocks[curBlock].Size);
  Hash_SHA256.Final(BlocksOffsets[curBlock].Hash);
  Blocks[curBlock].Seek(0,0);

  writeLog('+---+ OK');

  // --------------------------------------------------------------------------
  // === BANNER BLOCK =========================================================
  // --------------------------------------------------------------------------

  if (chkImagePerso.Checked and FileExists(txtImageFile.Text)) then
  begin
    writeLog('+ Generating banner block...');
    writeLog('+-+ Importing image from: '+txtImageFile.Text);
    tmpStream := TFileStream.Create(txtImageFile.Text,fmOpenRead or fmShareDenyWrite);
    try
      tmpStream.Seek(0,0);
      tmpStream.Read(BMP,SizeOf(BMP));
      tmpStream.Seek(0,0);
      if ((BMP.ID = 'BM') and (BMP.Width = 465) and (BMP.height = 90)) then
      begin
        writeLog('+ Image is BMP 465x90 as expected... Adding BANNER block ('+inttostr(tmpStream.Size)+' bytes)...');

        inc(HDR.NumOffsets);
        SetLength(Blocks,HDR.NumOffsets);
        SetLength(BlocksOffsets,HDR.NumOffsets);

        inc(curBlock);

        // Fill block offset data (minus Offset & Hash that will be calculated afterwards)
        BlocksOffsets[curBlock].ID := D5PID_BANNER;                      // Banner block
        BlocksOffsets[curBlock].OptionsFlags := D5PBLOCK_COMPANION;      // Block is a companion
//        BlocksOffsets[curBlock].CompressionType := D5PCOMPRESSION_LZMA;  // Zlib compressed
        BlocksOffsets[curBlock].CompanionOfID := D5PID_INFORMATION;      // This is a companion of information block
        BlocksOffsets[curBlock].NumEntries := 0;                         // No entry based block

        // Compress
        Blocks[curBlock] := compressDUPPv4best(tmpStream,BlocksOffsets[curBlock].CompressionType);
        if BlocksOffsets[curBlock].CompressionType <> D5PCOMPRESSION_NONE then
        begin
          BlocksOffsets[curBlock].OptionsFlags := BlocksOffsets[curBlock].OptionsFlags or D5PBLOCK_COMPRESSED;
          // Indicate size of block
          BlocksOffsets[curBlock].DSize := tmpStream.Size;
        end
        else
        begin
          // Indicate size of block
          BlocksOffsets[curBlock].DSize := 0;
        end;

        BlocksOffsets[curBlock].Size := Blocks[curBlock].Size;


        //lzma_encode(tmpStream,Blocks[curBlock]);

        // Calculates SHA-256 hash of the block
        Blocks[curBlock].Seek(0,0);
        Hash_SHA256.Init;
        Hash_SHA256.UpdateStream(Blocks[curBlock],Blocks[curBlock].Size);
        Hash_SHA256.Final(BlocksOffsets[curBlock].Hash);
        Blocks[curBlock].Seek(0,0);

      end
      else
        writeLog('+ Image is NOT BMP 465x90 as expected not using banner...');
    finally
      tmpStream.Free;
    end;
  end;

  // --------------------------------------------------------------------------
  // === NAMES BLOCK ==========================================================
  // --------------------------------------------------------------------------

  writeLog('+ Generating names block...');

  inc(curBlock);
  entriesBlock := curBlock;
  inc(curBlock);
  namesBlock := curBlock;
  inc(curBlock);
  dataBlock := curBlock;

  // Fill block offset data (minus Offset & Hash that will be calculated afterwards)
  BlocksOffsets[namesBlock].ID := D5PID_NAMES;                     // Entries block
  BlocksOffsets[namesBlock].OptionsFlags := D5PBLOCK_COMPANION or D5PBLOCK_ENTRIES;
//  BlocksOffsets[namesBlock].CompressionType := D5PCOMPRESSION_LZMA;  // LZMA compressed
  BlocksOffsets[namesBlock].CompanionOfID := D5PID_ENTRIES;          // This is a companion block
  BlocksOffsets[namesBlock].NumEntries := lstFiles.Items.Count;      // Number of filenames (must be equal to block entries number)

  // Generate contents of names block
  tmpStream := TMemoryStream.Create;
  try
    for x := 0 to lstFiles.Items.Count-1 do
    begin
      put8(tmpStream,lstFiles.Items.Item[x].Caption);
    end;

    tmpStream.Seek(0,0);

//    writeLog('+-+ Compressing block with LZMA (Size: '+inttostr(tmpStream.Size)+' bytes)');

    // Compress
//    Blocks[namesBlock] := TMemoryStream.Create;
//    lzma_encode(tmpStream,Blocks[namesBlock]);
    Blocks[namesBlock] := compressDUPPv4best(tmpStream,BlocksOffsets[namesBlock].CompressionType);

    if BlocksOffsets[namesBlock].CompressionType <> D5PCOMPRESSION_NONE then
    begin
      BlocksOffsets[namesBlock].OptionsFlags := BlocksOffsets[namesBlock].OptionsFlags or D5PBLOCK_COMPRESSED;

      // Indicate size of block
      BlocksOffsets[namesBlock].DSize := tmpStream.Size;
    end
    else
    begin
      BlocksOffsets[namesBlock].DSize := 0;
    end;

    BlocksOffsets[namesBlock].Size := Blocks[namesBlock].Size;

//    writeLog('+---+ OK (Size: '+inttostr(Blocks[namesBlock].Size)+' bytes - '+floattostrF(((Blocks[namesBlock].size/tmpStream.Size)*100),ffFixed,1,1)+'%)');

    writeLog('+-+ Calculating hash of the block...');

    // Calculates SHA-256 hash of the block
    Blocks[namesBlock].Seek(0,0);
    Hash_SHA256.Init;
    Hash_SHA256.UpdateStream(Blocks[namesBlock],Blocks[namesBlock].Size);
    Hash_SHA256.Final(BlocksOffsets[namesBlock].Hash);
    Blocks[namesBlock].Seek(0,0);

    writeLog('+---+ OK');
  finally
    tmpStream.Free;
  end;

  // --------------------------------------------------------------------------
  // === DATA & ENTRIES BLOCKS ================================================
  // --------------------------------------------------------------------------

  // Fill block offset data (minus Offset & Hash that will be calculated afterwards)
  BlocksOffsets[entriesBlock].ID := D5PID_ENTRIES;                     // Entries block
  BlocksOffsets[entriesBlock].OptionsFlags := D5PBLOCK_ENTRIES;
//  BlocksOffsets[entriesBlock].CompressionType := D5PCOMPRESSION_LZMA;  // LZMA compressed
  BlocksOffsets[entriesBlock].CompanionOfID := 0;                      // This is a main block
  BlocksOffsets[entriesBlock].NumEntries := lstFiles.Items.Count;      // List of files

  // Fill block offset data (minus Offset & Hash that will be calculated afterwards)
  BlocksOffsets[dataBlock].ID := D5PID_DATA;                        // Entries block
  BlocksOffsets[dataBlock].OptionsFlags := D5PBLOCK_COMPANION;
  BlocksOffsets[dataBlock].CompanionOfID := D5PID_ENTRIES;          // This is a main block
  BlocksOffsets[dataBlock].NumEntries := 0;

//  Blocks[entriesBlock] := TMemoryStream.Create;
//  Blocks[dataBlock] := TMemoryStream.Create;

  SetLength(Files,lstFiles.Items.Count);
  SetLength(FilesData,lstFiles.Items.Count);

  tmpStream2 := TMemoryStream.Create;
  tmpStream3 := TMemoryStream.Create;

  writeLog('+ Generating data & entries blocks...');

  for x := 0 to lstFiles.Items.Count-1 do
  begin
    fInfo := FileInfo(lstFiles.Items.Item[x].Data);
    writeLog('+ File '+inttostr(x+1)+': '+fInfo.Filename);
    fin := TFileStream.Create(fInfo.Filename,fmOpenRead or fmShareDenyWrite);
    try
      Files[x].DSize := fin.Size;
      writeLog('+--+ Size: '+inttostr(Files[x].DSize)+' bytes');
      if fInfo.StoreDateTime then
        Files[x].DateT := FileAge(fInfo.Filename)
      else
        Files[x].DateT := 0;
      Files[x].Flags := 0;
      if fInfo.DeleteFile then
      begin
        Files[x].Flags := Files[x].Flags or D5PFILE_DELETE;
        Files[x].CompressionType := D5PCOMPRESSION_ABSOLUTE;
        Files[x].DSize := 0;
        Files[x].Size := 0;
        fInfo.Compress := false;
        fInfo.ReadOnly := false;
        fInfo.RegSvr := false;
        fInfo.UpgradeOnly := false;
        fInfo.Hidden := false;
      end;
      if fInfo.Hidden then
        Files[x].Flags := Files[x].Flags or D5PFILE_HIDDEN;
      if fInfo.ReadOnly then
        Files[x].Flags := Files[x].Flags or D5PFILE_READONLY;
      if fInfo.RegSvr then
        Files[x].Flags := Files[x].Flags or D5PFILE_REGSVR32;
      if fInfo.UpgradeOnly then
        Files[x].Flags := Files[x].Flags or D5PFILE_UPDATEONLY;

      Files[x].BaseInstallDir := fInfo.InstallTo;
      Files[x].NameID := x;
      Files[x].Version := fInfo.Version;

      fin.Seek(0,0);

      if not(fInfo.DeleteFile) then
      begin
        Files[x].HashType := HashUsed;
        FillChar(Files[x].Hash,64,0);
        Hash_Engine.Init;
        Hash_Engine.UpdateStream(fin,fin.Size);
        Hash_Engine.Final(Files[x].Hash);

        fin.Seek(0,0);

        s:= '';
        for i:= 0 to (Hash_Engine.GetHashSize div 8)-1 do
          s:= s + IntToHex(Files[x].Hash[i],2);
        writeLog('+--+ Hash: '+Lowercase(s));

        if fInfo.Compress and not(optFileCompressSolid.Checked) then
        begin
//        Files[x].CompressionType := D5PCOMPRESSION_LZMA;

//        tmpStream3 := TMemoryStream.Create;
          fin.Seek(0,0);
//        tmpStream3.CopyFrom(fin,fin.Size);
//        tmpStream3.Seek(0,0);
//        lzma_encode(fin,tmpStream);
          tmpStream := compressDUPPv4best(fin,Files[x].CompressionType);
//        tmpStream3.Free;
          tmpStream.Seek(0,0);

          if (Files[x].CompressionType <> D5PCOMPRESSION_NONE) then
            Files[x].Flags := Files[x].Flags or D5PFILE_COMPRESSED;

          Files[x].Size := tmpStream.Size;

          tmpStream3.CopyFrom(tmpStream,tmpStream.Size);

          writeLog('+---+ OK (Size: '+inttostr(Files[x].Size)+' bytes - '+floattostrF(((Files[x].Size/Files[x].DSize)*100),ffFixed,1,1)+'%)');

          tmpStream.Free;
        end
        else
        begin
          Files[x].Size := Files[x].DSize;

          tmpStream3.CopyFrom(fin,Files[x].Size);
          Files[x].CompressionType := D5PCOMPRESSION_NONE;
        end;
      end
      else
      begin

          writeLog('+---+ OK (Flagged as Delete File)');

      end;

      if (x = 0) then
        Files[x].RelOffset := 0
      else
        Files[x].RelOffset := Files[x-1].RelOffset+Files[x-1].Size;

    finally
      fin.Free;
    end;

    tmpStream2.Write(Files[x],SizeOf(DUP5PACK_File_v4)); 

    ProgressBar.Position := 10 + round(((x+1)/lstFiles.Items.Count)*90);

  end;

  // Compress the entries block
  tmpStream2.Seek(0,0);
//  lzma_encode(tmpStream2,Blocks[entriesBlock]);
  writeLog('+ Compressing entries block...');
  Blocks[entriesBlock] := compressDUPPv4best(tmpStream2,BlocksOffsets[entriesBlock].CompressionType);
  if BlocksOffsets[entriesBlock].CompressionType <> D5PCOMPRESSION_NONE then
  begin
    BlocksOffsets[entriesBlock].OptionsFlags := BlocksOffsets[entriesBlock].OptionsFlags or D5PBLOCK_COMPRESSED;

    // Indicate size of entries block
    BlocksOffsets[entriesBlock].DSize := tmpStream2.Size;
  end
  else
  begin
    BlocksOffsets[entriesBlock].DSize := 0;
  end;

  BlocksOffsets[entriesBlock].Size := Blocks[entriesBlock].Size;

  writeLog('+-+ Calculating hash of the entries block...');

  // Calculates SHA-256 hash of the entries block
  Blocks[entriesBlock].Seek(0,0);
  Hash_SHA256.Init;
  Hash_SHA256.UpdateStream(Blocks[entriesBlock],Blocks[entriesBlock].Size);
  Hash_SHA256.Final(BlocksOffsets[entriesBlock].Hash);
  Blocks[entriesBlock].Seek(0,0);

  tmpStream2.Free;

  writeLog('+---+ OK');

  if optFileCompressSolid.Checked then
  begin

    writeLog('+ Compressing data block...');
    tmpStream3.Seek(0,0);
    Blocks[dataBlock] := compressDUPPv4best(tmpStream3,BlocksOffsets[dataBlock].CompressionType);
    // Indicate size of data block
    BlocksOffsets[dataBlock].Size := Blocks[dataBlock].Size;
    if BlocksOffsets[dataBlock].CompressionType <> D5PCOMPRESSION_NONE then
    begin
      BlocksOffsets[dataBlock].OptionsFlags := BlocksOffsets[dataBlock].OptionsFlags or D5PBLOCK_COMPRESSED;
      BlocksOffsets[dataBlock].DSize := tmpStream3.Size;
    end
    else
    begin
      BlocksOffsets[dataBlock].DSize := 0;
    end;
    tmpStream3.Free;

  end
  else
  begin

    BlocksOffsets[dataBlock].CompressionType := D5PCOMPRESSION_NONE;  // Each file is compressed independently in the block
    Blocks[dataBlock] := tmpStream3;

    // Indicate size of data block
    BlocksOffsets[dataBlock].Size := Blocks[dataBlock].Size;
    BlocksOffsets[dataBlock].DSize := 0;

  end;

  writeLog('+-+ Calculating hash of the data block...');

  Blocks[dataBlock].Seek(0,0);

  // Calculates SHA-256 hash of the data block
  Hash_SHA256.Init;
  Hash_SHA256.UpdateStream(Blocks[dataBlock],Blocks[dataBlock].Size);
  Hash_SHA256.Final(BlocksOffsets[dataBlock].Hash);
  Blocks[dataBlock].Seek(0,0);

  writeLog('+---+ OK');

  writeLog('+ Generating file...');

  tmpStream := TMemoryStream.Create;
  tmpStream.Write(HDR,SizeOf(DUP5PACK_Header_v4));

  writeLog('+-+ Header ('+inttostr(SizeOf(DUP5PACK_Header_v4))+' bytes)');

  // Calculating offsets
  for x := 0 to HDR.NumOffsets-1 do
  begin

    if x = 0 then
      BlocksOffsets[x].Offset := SizeOf(DUP5PACK_Offsets_v4)*(curBlock+1) + SizeOf(DUP5PACK_Header_v4)
    else
      BlocksOffsets[x].Offset := BlocksOffsets[x-1].Offset+BlocksOffsets[x-1].Size;

    writeLog('+-+ Block offset '+inttostr(x+1)+'/'+inttostr(HDR.NumOffsets)+' ('+inttostr(tmpStream.Write(BlocksOffsets[x],SizeOf(DUP5PACK_Offsets_v4)))+' bytes)');

  end;

  // --------------------------------------------------------------------------
  // === FOOTER ===============================================================
  // --------------------------------------------------------------------------

  FillChar(FTR,SizeOf(DUP5PACK_Footer_v4),0);
  FTR.ID := 'PPUD';
  FTR.EOF := 26;
  FTR.Version := 1;
  FTR.SignatureID := 1;
  FTR.SignatureVersion := VERSION;

  writeLog('+--+ Calculating footer hash...');

  // Calculates SHA-256 hash of the data block
  tmpStream.Seek(0,0);
  Hash_SHA256.Init;
  Hash_SHA256.UpdateStream(tmpStream,tmpStream.Size);
  Hash_SHA256.Final(FTR.HashHeaderOffsets);

  writeLog('+----+ OK');

  // Write to file (finally?!)
  fout := TBufferedFS.Create(txtPackageFile.Text, fmCreate);

  writeLog('+--+ Writing to file...');

  tmpStream.Seek(0,0);
  fout.CopyFrom(tmpStream,tmpStream.Size);

  for x := 0 to HDR.NumOffsets-1 do
  begin

    Blocks[x].Seek(0,0);
    writeLog('+-+ Data of block '+inttostr(x+1)+'/'+inttostr(HDR.NumOffsets)+' ('+inttostr(fout.CopyFrom(Blocks[x],Blocks[x].Size))+' bytes)');
    Blocks[x].Free;

  end;

  writeLog('+-+ Footer ('+inttostr(fout.Write(FTR,SizeOf(DUP5PACK_Footer_v4)))+' bytes)');

  writeLog('+ Finished ('+inttostr(fout.Size)+' bytes)!');

  fout.Free;

end;

procedure TfrmMain.butCompileClick(Sender: TObject);
begin

  if lstFiles.Items.Count = 0 then
    ShowMessage('You need at least 1 file to create a D5P.')
  else if txtPackageFile.Text = '' then
    ShowMessage('You need a package filename.') 
  else
    if optDUPPv2.Checked or optDUPPv3.Checked then
      createDUPPv2_v3
    else
      createDUPPv4;

end;

procedure TfrmMain.butAddClick(Sender: TObject);
var Dialog: TOpenDialog;
    x: integer;
begin

  Dialog := TOpenDialog.Create(self);
  Dialog.Filter := 'All files|*.*';
  Dialog.Title := 'Add a file to the package...';
  Dialog.Options := [ofAllowMultiSelect, ofFileMustExist, ofEnableSizing];

  if Dialog.Execute and (Dialog.Files.Count > 0) then
  begin

    for x := 0 to Dialog.Files.Count - 1 do
    begin

      addFile(Dialog.Files.Strings[x]);

    end;
  end;
  Dialog.Free;

end;

function TfrmMain.GetFSize(filnam: string): Int64;
var F: integer;
begin

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

  chkDelete.Checked := curFileInfo.DeleteFile;
  chkDelete.Enabled := optDUPPv4.Checked;

  chkCompress.enabled := not(curFileInfo.DeleteFile);
  chkUpgradeOnly.enabled := not(curFileInfo.DeleteFile);
  chkStoreDateTime.enabled := not(curFileInfo.DeleteFile);
  chkHidden.enabled := not(curFileInfo.DeleteFile);
  chkReadOnly.enabled := not(curFileInfo.DeleteFile);
  chkStoreDateTime.enabled := not(curFileInfo.DeleteFile);

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
  chkDelete.Enabled := false;
  lblFileVersion.Caption := '';

end;

{ FileInfo }

constructor FileInfo.Create(Comp, Upg, StoreDT, ReadO, Hide, Reg, DelFile: boolean; CompType, InstTo: integer; Vers: Integer; FName, InstallDir: String);
begin

  Compress := comp;
  CompressType := comptype;
  UpgradeOnly := Upg;
  StoreDateTime := StoreDT;
  ReadOnly := ReadO;
  Hidden := Hide;
  RegSvr := Reg;
  InstallTo := InstTo;
  Version := Vers;
  FileName := FName;
  DeleteFile := DelFile;

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
    chkDelete.Enabled := false;
  end;

end;

function TfrmMain.getPluginVersion(filename: String): Integer;
var Handle: THandle;
    DUDIVer: TDUDIVersion;
    DUCIVer: TDUDIVersion;
    DUHIVer: TDUDIVersion;
//    CnvInfo: ConvertInfo;
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

    if ((@DUDIVer <> Nil) and (DUDIVer >= 1)) then
    begin
      @GetNumVer := GetProcAddress(Handle, 'GetNumVersion');

      if (@GetNumVer = nil) then
        result := -1
      else
        result := GetNumVer;
    end
    else if ((@DUCIVer <> Nil) and (DUCIVer >= 1)) then
    begin
      @GetConvertVer := GetProcAddress(Handle, 'VersionInfo');

      if (@GetConvertVer = nil) then
        result := -1
      else
        result := GetConvertVer.VerID;
    end
    else if ((@DUHIVer <> Nil) and (DUHIVer >= 1)) then
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
    else if optDUPPv2.Checked then
      sub.Properties.Add('duppversion',2)
    else
      sub.Properties.Add('duppversion',4);
    sub := head.Items.Add('CHECKDUP5VERSION');
    sub.Value := txtDUP5Version.Text;
    sub := head.Items.Add('UPDATECREATOROLDDIR');
    sub.Value := txtUpdateDir1.Text;
    sub := head.Items.Add('UPDATECREATORNEWDIR');
    sub.Value := txtUpdateDir2.Text;

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

    sub := head.Items.Add('COMPRESSION');
    sub.Value := '';

    sub.Properties.Add('none',chkCompressNone.Checked);
    sub.Properties.Add('zlib',chkCompressZlib.Checked);
    sub.Properties.Add('lzma',chkCompressLZMA.Checked);
    sub.Properties.Add('solid',optFileCompressSolid.Checked);

    sub := head.Items.Add('HASH');
    sub.Value := '';

    if (optFileHashMD5.Checked) then
      sub.Properties.Add('type',0)
    else if (optFileHashSHA1.Checked) then
      sub.Properties.Add('type',1)
    else if (optFileHashSHA256.Checked) then
      sub.Properties.Add('type',2)
    else if (optFileHashRIPEMD160.Checked) then
      sub.Properties.Add('type',4)
    else
      sub.Properties.Add('type',3);

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
      sub2.Properties.Add('delfile',tmp.DeleteFile);

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
    sub: TJvSimpleXMLElem;
    tmp: FileInfo;
    x: integer;
    itmx: TListItem;
    ext: string;
//    Handle: THandle;
    Dialog: TSaveDialog;
    SimpleXML: TJvSimpleXML;
begin

  Dialog := TSaveDialog.Create(Self);

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

    if (SimpleXML.Root.Properties.IntValue('version') > DPSVERSION) and
       (SimpleXML.Root.Properties.IntValue('version') < 1) then
    begin

      ShowMessage('Error: Project file must be version '+inttostr(DPSVERSION)+' (v1 to v'+inttostr(DPSVERSION-1)+' are also supported).');

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
          4: optDUPPv4.Checked := true;
        else
          optDUPPv4.Checked := true;
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

      if head.Items.IndexOf('COMPRESSION') <> -1 then
      begin
        chkCompressNone.Checked := head.Items.ItemNamed['COMPRESSION'].Properties.BoolValue('none',true);
        chkCompressZlib.Checked := head.Items.ItemNamed['COMPRESSION'].Properties.BoolValue('zlib',true);
        chkCompressLZMA.Checked := head.Items.ItemNamed['COMPRESSION'].Properties.BoolValue('lzma',true);
        optFileCompressSolid.Checked := head.Items.ItemNamed['COMPRESSION'].Properties.BoolValue('solid',false);
      end;

      if head.Items.IndexOf('UPDATECREATOROLDDIR') <> -1 then
        txtUpdateDir1.Text := head.Items.ItemNamed['UPDATECREATOROLDDIR'].Value;
      if head.Items.IndexOf('UPDATECREATORNEWDIR') <> -1 then
        txtUpdateDir2.Text := head.Items.ItemNamed['UPDATECREATORNEWDIR'].Value;

      if head.Items.IndexOf('HASH') <> -1 then
      begin
        case head.Items.ItemNamed['HASH'].Properties.IntValue('type',3) of
          0: optFileHashMD5.Checked := true;
          1: optFileHashSHA1.Checked := true;
          2: optFileHashSHA256.Checked := true;
          4: optFileHashRIPEMD160.Checked := true;
        else
          optFileHashSHA512.Checked := true;
        end;
      end;

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
            sub.Items.ItemNamed['OPTIONS'].Properties.BoolValue('delfile',false),
            D5PCOMPRESSION_LZMA,
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

  Dialog.Free;

end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin

  frmMain.Caption := 'Dragon UnPACKer 5 (D5P) Package Maker v'+getVersion(VERSION);
  application.Title := frmMain.Caption;
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
  txtImageFile.Enabled := PackImagePerso;
  butBrowseImage.Enabled := PackImagePerso;

end;

procedure TfrmMain.butNewClick(Sender: TObject);
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

  reinitFilesTab;

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
      173: lblDUPVersion.Caption := 'v5.3.0 WIP';
      174: lblDUPVersion.Caption := 'v5.3.1 WIP';
      178: lblDUPVersion.Caption := 'v5.3.2 WIP';
      182: lblDUPVersion.Caption := 'v5.3.3 Beta';
      191: lblDUPVersion.Caption := 'v5.4.0';
      193: lblDUPVersion.Caption := 'v5.4.0a';
      218: lblDUPVersion.Caption := 'v5.5.0 Beta';
      226: lblDUPVersion.Caption := 'v5.5.1 Beta';
      239: lblDUPVersion.Caption := 'v5.6.0';
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
      173: txtDUP5Version.Text := '169';
      174: txtDUP5Version.Text := '173';
      178: txtDUP5Version.Text := '174';
      182: txtDUP5Version.Text := '178';
      191: txtDUP5Version.Text := '182';
      193: txtDUP5Version.Text := '191';
      218: txtDUP5Version.Text := '193';
      226: txtDUP5Version.Text := '218';
      239: txtDUP5Version.Text := '226';
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
      169: txtDUP5Version.Text := '173';
      173: txtDUP5Version.Text := '174';
      174: txtDUP5Version.Text := '178';
      178: txtDUP5Version.Text := '182';
      182: txtDUP5Version.Text := '191';
      191: txtDUP5Version.Text := '193';
      193: txtDUP5Version.Text := '218';
      218: txtDUP5Version.Text := '226';
      226: txtDUP5Version.Text := '239';
    else
      txtDUP5Version.Text := inttostr(oldValue+1);
    end;
  except
    on EConvertError do
      txtDUP5Version.Text := '239';
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

procedure TfrmMain.optDUPPClick(Sender: TObject);
begin

  if checkIfDeleteFile and not(optDUPPv4.Checked) then
  begin

    refreshAvailableOptions;

    ShowMessage('Delete file option for at least one entry, only Version 4 supports this feature');

    optDUPPv4.Checked := true;

  end;

  refreshAvailableOptions;

end;

procedure TfrmMain.butBrowseImageClick(Sender: TObject);
var Dialog: TOpenDialog;
begin

  Dialog := TOpenDialog.Create(self);
  Dialog.Filter := 'Windows BitMaP file (465x90)|*.BMP';
  Dialog.Title := 'Select custom Duppi picture (465x90 BMP)';

  if Dialog.Execute then
  begin
    txtImageFile.Text := Dialog.FileName;
  end;
  Dialog.Free;

end;

procedure TfrmMain.txtNameChange(Sender: TObject);
begin

  if length(txtName.Text) <= 128 then
    shapeName.Brush.Color := clLime
  else if length(txtName.text) <= 192 then
    shapeName.Brush.Color := clYellow
  else if length(txtName.text) <= 255 then
    shapeName.Brush.Color := $004080FF
  else
    shapeName.Brush.Color := clRed;
  lblNameMax.Caption := inttostr(length(txtName.Text));

end;

procedure TfrmMain.txtURLChange(Sender: TObject);
begin

  if length(txtURL.Text) <= 128 then
    shapeURL.Brush.Color := clLime
  else if length(txtURL.text) <= 192 then
    shapeURL.Brush.Color := clYellow
  else if length(txtURL.text) <= 255 then
    shapeURL.Brush.Color := $004080FF
  else
    shapeURL.Brush.Color := clRed;
  lblURLMax.Caption := inttostr(length(txtURL.Text));

end;

procedure TfrmMain.txtAuthorChange(Sender: TObject);
begin

  if length(txtAuthor.Text) <= 128 then
    shapeAuthor.Brush.Color := clLime
  else if length(txtAuthor.text) <= 192 then
    shapeAuthor.Brush.Color := clYellow
  else if length(txtAuthor.text) <= 255 then
    shapeAuthor.Brush.Color := $004080FF
  else
    shapeAuthor.Brush.Color := clRed;
  lblAuthorMax.Caption := inttostr(length(txtAuthor.Text));

end;

procedure TfrmMain.txtCommentChange(Sender: TObject);
begin

  if optDUPPv4.Checked then
  begin
    if length(txtComment.Text) <= 16384 then
      shapeComment.Brush.Color := clLime
    else if length(txtComment.text) <= 24576 then
      shapeComment.Brush.Color := clYellow
    else if length(txtComment.text) <= 32767 then
      shapeComment.Brush.Color := $7FFF8040
    else
      shapeComment.Brush.Color := clRed;
  end
  else
    if length(txtComment.Text) <= 128 then
      shapeComment.Brush.Color := clLime
    else if length(txtComment.text) <= 192 then
      shapeComment.Brush.Color := clYellow
    else if length(txtComment.text) <= 255 then
      shapeComment.Brush.Color := $004080FF
    else
      shapeComment.Brush.Color := clRed;

  lblCommentMax.Caption := inttostr(length(txtComment.Text));

end;

procedure TfrmMain.chkCompressNoneClick(Sender: TObject);
begin

  chkCompressNone.Checked := chkCompressNone.Checked or (not(chkCompressZlib.Checked) and not(chkCompressLzma.Checked));

end;

procedure TfrmMain.chkCompressZlibClick(Sender: TObject);
begin

  chkCompressZlib.Checked := chkCompressZlib.Checked or (not(chkCompressNone.Checked) and not(chkCompressLzma.Checked));

end;

procedure TfrmMain.chkCompressLZMAClick(Sender: TObject);
begin

  chkCompressLzma.Checked := chkCompressLzma.Checked or (not(chkCompressNone.Checked) and not(chkCompressZlib.Checked));

end;

procedure TfrmMain.butNewUpdateClick(Sender: TObject);
begin

  TabSheet2.Visible := false;
  TabSheet3.Visible := false;
  TabSheet4.Visible := false;
  TabSheet5.Visible := false;
  TabSheet6.Visible := true;

  TabSheet6.Highlighted := true;

end;


function TfrmMain.getFilesTreeFromDirectory(root, dirName: string): TList;
var
  sr: TSearchRec;
  FileAttrs, x: Integer;
  DirItem: PDirEntry;
  searchStr,newDir: string;
  dirList: TList;
begin

  result := Tlist.Create;

  FileAttrs := faAnyFile or faVolumeID;
  if length(dirName) > 0 then
    searchStr := root + '\' + dirName + '\*.*'
  else
    searchStr := root + '\*.*';

  if FindFirst(searchStr, FileAttrs, sr) = 0 then
  begin
    repeat
      if (sr.Attr and FileAttrs) = sr.Attr then
        if (sr.Attr and faDirectory) = faDirectory then
        begin
          if (sr.Name <> '.') and (sr.Name <> '..') then
          begin
            newDir := dirName + '\' + sr.Name;
            dirList := getFilesTreeFromDirectory(root,newDir);
            for x := 0 to dirList.Count-1 do
              result.Add(dirList.Items[x]);
            dirList.Free;
          end;
        end
        else
        begin
          New(DirItem);
          DirItem^.FileName := dirName + '\' + sr.Name;
          DirItem^.FileSize := sr.Size;
          FillChar(DirItem^.FileHash,64,0);
          DirItem^.Value := false;
          DirItem^.Hashed := false;
          result.Add(DirItem);
        end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;

end;

procedure TfrmMain.diffDirectories(dir1, dir2: String);
var DirList1, DirList2: TList;
    numDir1, numDir2, x, installTo, totSize,TotSizeUpd, numUpd, numDel: integer;
    DirItem1, DirItem2: PDirEntry;
    Hash_SHA512: TDCP_sha512;
    fin: TStream;
    HashOk: boolean;
    pathId: string;
begin

  progressBarUpdate.Position := 0;
  lblDir1Num.Caption := '0';
  lblDir1Size.Caption := '0';
  lblDir2Num.Caption := '0';
  lblDir2Size.Caption := '0';
  lblDir2DelNum.Caption := '0';
  lblUpdNum.Caption := '0';
  lblUpdSize.Caption := '0';
  lblUpdSaved.Caption := '0';
  lblUpdSavedPercent.Caption := '0%';

  frmMain.Refresh;

  reinitFilesTab;

  lblUpdateInfo.Caption := 'Retrieving files in old directory...';
  lblUpdateInfo.Refresh;
  dirList1 := getFilesTreeFromDirectory(dir1,'');
  lblDir1Num.Caption := inttostr(dirList1.Count);
  TotSize := 0;
  for x := 0 to dirList1.Count-1 do
  begin
    dirItem1 := dirList1.Items[x];
    inc(TotSize,dirItem1^.FileSize);
  end;
  lblDir1Size.Caption := inttostr(TotSize);
  progressBarUpdate.Position := 10;
  frmMain.Refresh;
  lblUpdateInfo.Caption := 'Retrieving files in new directory...';
  lblUpdateInfo.Refresh;
  dirList2 := getFilesTreeFromDirectory(dir2,'');
  lblDir2Num.Caption := inttostr(dirList2.Count);
  TotSize := 0;
  for x := 0 to dirList2.Count-1 do
  begin
    dirItem2 := dirList2.Items[x];
    inc(TotSize,dirItem2^.FileSize);
  end;
  lblDir2Size.Caption := inttostr(TotSize);
  progressBarUpdate.Position := 20;
  Hash_SHA512 := TDCP_sha512.Create(self);
  frmMain.Refresh;

  NumUpd := 0;
  for numDir2 := 0 to dirList2.Count-1 do
  begin
    dirItem2 := dirList2.Items[numDir2];
    dirItem2^.Value := true;
    lblUpdateInfo.Caption := 'Checking '+dirItem2^.FileName+'...';
    lblUpdateInfo.Refresh;
    for numDir1 := 0 to dirList1.Count-1 do
    begin
      dirItem1 := dirList1.Items[numDir1];
      if (dirItem2^.FileName = dirItem1^.FileName) then
      begin
        if (dirItem2^.FileSize = dirItem1^.FileSize) then
        begin
          if not(dirItem1^.Hashed) then
          begin
            Hash_SHA512.Init;
            fIn := TBufferedFS.Create(dir1+dirItem1^.FileName, fmOpenRead);
            Hash_SHA512.UpdateStream(fin,fin.Size);
            fIn.Free;
            Hash_SHA512.Final(dirItem1^.FileHash);
            dirItem1^.Hashed := true;
          end;
          if not(dirItem2^.Hashed) then
          begin
            Hash_SHA512.Init;
            fIn := TBufferedFS.Create(dir2+dirItem2^.FileName, fmOpenRead);
            Hash_SHA512.UpdateStream(fin,fin.Size);
            fIn.Free;
            Hash_SHA512.Final(dirItem2^.FileHash);
            dirItem2^.Hashed := true;
          end;
          HashOk := true;
          for x := 0 to 63 do
            HashOk := HashOk and (dirItem1^.FileHash[x] = dirItem2^.FileHash[x]);
          dirItem2^.Value := not(HashOk);
          dirItem1^.Value := dirItem2^.Value;
        end;
        break;
      end;
    end;
    progressBarUpdate.Position := 20 + round(((numDir2+1) / (dirList2.Count+1))*80);
    frmMain.Refresh;
    if dirItem2^.Value then
      inc(NumUpd);
  end;

  lblUpdateInfo.Caption := 'Checking removed files...';
  lblUpdateInfo.Refresh;

  for numDir1 := 0 to dirList1.Count-1 do
  begin
    dirItem1 := dirList1.Items[numDir1];
    if not(dirItem1^.Value) then
    begin
      dirItem1^.ToDelete := true;
      for numDir2 := 0 to dirList2.Count-1 do
      begin
        dirItem2 := dirList2.Items[numDir2];
        if (dirItem2^.FileName = dirItem1^.FileName) then
        begin
          dirItem1^.ToDelete := false;
          break;
        end;
      end;
    end;
  end;

  lblUpdateInfo.Caption := 'Adding files to the list...';
  lblUpdateInfo.Refresh;

  lblUpdNum.Caption := inttostr(NumUpd);
  TotSizeUpd := 0;
  frmMain.Refresh;
  for x := 0 to dirList2.Count-1 do
  begin
    dirItem2 := dirList2.Items[x];
    if (dirItem2^.Value) then
    begin
      inc(TotSizeUpd,dirItem2^.FileSize);
      pathId := ExtractFilePath(dirItem2^.FileName);
      if (pathId = '\data\convert\') then
        installTo := 0
      else if (pathId = '\data\') then
        installTo := 1
      else if (pathId = '\data\drivers\') then
        installTo := 2
      else if (pathId = '\data\hyperripper\') then
        installTo := 3
      else if (pathId = '\') then
        installTo := 4
      else if (pathId = '\utils\') then
        installTo := 5
      else if (pathId = '\utils\templates\') then
        installTo := 6
      else if (pathId = '\utils\translation\') then
        installTo := 7
      else if (pathId = '\utils\data\') then
        installTo := 8
      else
        installTo := -1;

      addFile(Dir2 + dirItem2^.FileName,installTo);

    end;
    Dispose(DirItem2);
  end;
  numDel := 0;
  for x := 0 to dirList1.Count-1 do
  begin
    dirItem1 := dirList1.Items[x];
    if (dirItem1^.ToDelete) then
    begin
//      inc(TotSizeUpd,dirItem1^.FileSize);
      inc(numDel);
      pathId := ExtractFilePath(dirItem1^.FileName);
      if (pathId = '\data\convert\') then
        installTo := 0
      else if (pathId = '\data\') then
        installTo := 1
      else if (pathId = '\data\drivers\') then
        installTo := 2
      else if (pathId = '\data\hyperripper\') then
        installTo := 3
      else if (pathId = '\') then
        installTo := 4
      else if (pathId = '\utils\') then
        installTo := 5
      else if (pathId = '\utils\templates\') then
        installTo := 6
      else if (pathId = '\utils\translation\') then
        installTo := 7
      else if (pathId = '\utils\data\') then
        installTo := 8
      else
        installTo := -1;

      addFile(Dir1 + dirItem1^.FileName,installTo,true);

    end;
    Dispose(DirItem1);
  end;
  DirList1.Free;
  DirList2.Free;
  lblUpdSize.Caption := inttostr(TotSizeUpd);
  lblUpdSaved.Caption := inttostr(TotSize-TotSizeUpd);
  lblUpdSavedPercent.Caption := inttostr(Round(((TotSize-TotSizeUpd)/TotSize)*100))+'%';
  lblUpdateInfo.Caption := 'Finished!';
  lblUpdateInfo.Refresh;
  lblDir2DelNum.Caption := inttostr(NumDel);

  Hash_SHA512.Free;

end;

procedure TfrmMain.addFile(filename: string; installTo: integer = -1; deleteFile: boolean = false);
var itmx: TListItem;
    ext,datestr: string;
    tmp: FileInfo;
begin

      itmx := lstFiles.Items.Add;
      with itmx do
      begin
        itmx.Caption := ExtractFilename(filename);
        itmx.SubItems.Add(IntToStr(GetFSize(filename)));
        try
          datestr := DateTimeToStr(FileDateToDateTime(FileAge(filename)));
        except
          datestr := '';
        end;
        itmx.SubItems.Add(datestr);
        ext := lowercase(ExtractFileExt(filename));
        if installTo <> -1 then
          tmp := FileInfo.Create(True, True, True, False, False,False,deleteFile,D5PCOMPRESSION_LZMA,installTo,-1,filename,'')
        else
          tmp := FileInfo.Create(True, True, True, False, False,False,deleteFile,D5PCOMPRESSION_LZMA,0,-1,filename,'');
        if ext = '.d5d' then
        begin
          if installTo = -1 then
            tmp.InstallTo := 2;
          tmp.ForcedDir := true;
          tmp.Version := getPluginVersion(filename);
        end
        else if (ext = '.d5c') then
        begin
          if installTo = -1 then
            tmp.InstallTo := 0;
          tmp.ForcedDir := true;
          tmp.Version := getPluginVersion(filename);
        end
        else if (ext = '.d5h') then
        begin
          if installTo = -1 then
            tmp.InstallTo := 3;
          tmp.ForcedDir := true;
          tmp.Version := getPluginVersion(filename);
        end
        else if (ext = '.dpal') then
        begin
          if installTo = -1 then
            tmp.InstallTo := 0;
          tmp.ForcedDir := true;
        end
        else if (ext = '.dulk') then
        begin
          if installTo = -1 then
            tmp.InstallTo := 1;
          tmp.ForcedDir := true;
        end
        else if (ext = '.lng') then
        begin
          if installTo = -1 then
            tmp.InstallTo := 1;
        end
        else if (installTo = -1) then
        begin
          tmp.InstallTo := 4;
        end;

        if (tmp.Version = -1) then
          tmp.UpgradeOnly := false;
        itmx.SubItems.Add(txtInstallTo.Items.Strings[tmp.InstallTo]);
        if tmp.DeleteFile then
        begin
          tmp.Compress := false;
          tmp.CompressType := D5PCOMPRESSION_ABSOLUTE;
          tmp.UpgradeOnly := false;
          tmp.StoreDateTime := false;
          tmp.ReadOnly := false;
          tmp.Hidden := false;
          tmp.RegSvr := false;
        end;
        itmx.Data := tmp;
      end;

end;

procedure TfrmMain.reinitFilesTab();
begin

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

procedure TfrmMain.butOldVersionBrowseClick(Sender: TObject);
var newDir: string;
begin

  newDir := BrowseForFolder('Select directory of old Dragon UnPACKer version:',txtUpdateDir1.text);

  if newDir <> '' then
    txtUpdateDir1.Text := newdir;

end;

procedure TfrmMain.butNewVersionBrowseClick(Sender: TObject);
var newDir: string;
begin

  newDir := BrowseForFolder('Select directory of new Dragon UnPACKer version:',txtUpdateDir2.text);

  if newDir <> '' then
    txtUpdateDir2.Text := newdir;

end;

procedure TfrmMain.JvImgBtn1Click(Sender: TObject);
begin

  if not(DirectoryExists(txtUpdateDir1.text)) then
    ShowMessage('Old directory does not exists:'+chr(10)+txtUpdateDir1.text)
  else if not(DirectoryExists(txtUpdateDir2.text)) then
    ShowMessage('New directory does not exists:'+chr(10)+txtUpdateDir2.text)
  else
    diffDirectories(txtUpdateDir1.Text,txtUpdateDir2.Text);

end;

procedure TfrmMain.chkOverrideNeededVersionClick(Sender: TObject);
begin

  txtOverrideNeededVersion.Enabled := chkOverrideNeededVersion.Checked;

end;

procedure TfrmMain.chkDeleteClick(Sender: TObject);
begin

  curFileInfo.DeleteFile := chkDelete.Checked;

  if curFileInfo.DeleteFile then
  begin
    chkCompress.Checked := false;
    chkUpgradeOnly.Checked := false;
    chkStoreDateTime.Checked := false;
    chkHidden.Checked := false;
    chkReadOnly.Checked := false;
    chkStoreDateTime.Checked := false;
  end;

  chkCompress.enabled := not(curFileInfo.DeleteFile);
  chkUpgradeOnly.enabled := not(curFileInfo.DeleteFile);
  chkStoreDateTime.enabled := not(curFileInfo.DeleteFile);
  chkHidden.enabled := not(curFileInfo.DeleteFile);
  chkReadOnly.enabled := not(curFileInfo.DeleteFile);
  chkStoreDateTime.enabled := not(curFileInfo.DeleteFile);

end;

end.
