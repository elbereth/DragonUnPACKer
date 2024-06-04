unit Installer;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is Installer.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, lib_binutils, spec_DUPP, zlib, lib_crc, lib_zlib, Registry,
  ExtCtrls, ShellAPI, lib_language, XPMan, StrUtils,
  IniFiles, lib_utils,
  // LZMA
  ULZMADecoder,UBufferedFS,ULZMADec,
  // Hash (DCPCrypt2)
  DCPsha512,DCPsha256,DCPsha1,DCPmd5,DCPripemd160,DCPcrypt2,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type
   TLogType = (Internet, Install);
   TfrmInstaller = class(TForm)
    butInstall: TButton;
    imgBanner: TImage;
    strVersion: TLabel;
    lblLastExec: TLabel;
    lineBas: TBevel;
    cmdCancel: TButton;
    cmdClose: TButton;
    XPManifest: TXPManifest;
    stepInstall: TPanel;
    panIntro: TPanel;
    lblInstall2: TLabel;
    lblInstall1: TLabel;
    panInstall: TPanel;
    lblInstalling: TLabel;
    grpPackInfos: TGroupBox;
    panPVersion: TPanel;
    strPVersion: TPanel;
    panTitle: TPanel;
    strTitle: TPanel;
    strAuthor: TPanel;
    panAuthor: TPanel;
    strComment: TPanel;
    panComment: TPanel;
    strURL: TPanel;
    panURL: TPanel;
    cmdURL: TButton;
    stepChoice: TPanel;
    optInstall: TRadioButton;
    txtPathD5P: TEdit;
    cmdBrowseD5P: TButton;
    optInternet: TRadioButton;
    lblChoice: TLabel;
    lblWhat: TLabel;
    cmdNext: TButton;
    stepInternet: TPanel;
    butRefresh: TButton;
    InfoLabel: TLabel;
    lstUpdates: TListView;
    ProgressDL: TProgressBar;
    butDownload: TButton;
    cmdContinue: TButton;
    butProxy: TButton;
    OpenDialog: TOpenDialog;
    lblInternetNote: TLabel;
    strInternetComment: TLabel;
    Panel1: TPanel;
    imgCustomBanner: TImage;
    butProxy2: TButton;
    richLog: TRichEdit;
    lstUpdatesTypes: TComboBox;
    lblLinkToStable: TLabel;
    lblUpdatesTypes: TLabel;
    lblLinkToWIP: TLabel;
    linkToStable: TLabel;
    linkToWIP: TLabel;
    Shape1: TShape;
    lstTranslations: TListView;
    chkShowUnstable: TCheckBox;
    lblInternetComment: TMemo;
    lstUpdatesUnstable: TListView;
    AutoCheckTimer: TTimer;
    RichEditInstall: TRichEdit;
    Progress: TProgressBar;
    IdHTTP: TIdHTTP;
    procedure parseDUPP_version1to3(src: integer; version: integer);
    procedure parseDUPP_version4(src: integer);
    function infosDUPP_version1(src: integer): boolean;
    function infosDUPP_version2(src: integer): boolean;
    function infosDUPP_version4(src: integer): boolean;
    function sanitycheckDUPP_version4(src: integer): boolean;
    function getDUPP_version4_blockcontent(src,id: integer): TStream;
    function searchDUPP_version4_blockID(id: integer): integer;
    function extractDUPP_version4_file(fileid: DUP5PACK_File_v4; srcStream: TStream; var dstStream: TBufferedFS): integer;
    function isDup5Running(): boolean;
    procedure FormShow(Sender: TObject);
    procedure butInstallClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure cmdURLClick(Sender: TObject);
    procedure cmdCloseClick(Sender: TObject);
    procedure cmdNextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure butRefreshClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lstUpdatesClick(Sender: TObject);
    procedure butDownloadClick(Sender: TObject);
    procedure cmdContinueClick(Sender: TObject);
    procedure butProxyClick(Sender: TObject);
    procedure cmdBrowseD5PClick(Sender: TObject);
    procedure txtPathD5PClick(Sender: TObject);
    procedure lstUpdatesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure linkToStableMouseEnter(Sender: TObject);
    procedure linkToStableMouseLeave(Sender: TObject);
    procedure linkToWIPMouseEnter(Sender: TObject);
    procedure linkToWIPMouseLeave(Sender: TObject);
    procedure linkToStableClick(Sender: TObject);
    procedure lstUpdatesTypesChange(Sender: TObject);
    procedure linkToWIPClick(Sender: TObject);
    procedure chkShowUnstableClick(Sender: TObject);
    procedure lstUpdatesUnstableClick(Sender: TObject);
    procedure AutoCheckTimerTimer(Sender: TObject);
    procedure IdHTTPWork(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCount: Integer);
    procedure IdHTTPConnected(Sender: TObject);
    procedure IdHTTPStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: String);
  private
    sha1Engine: TDCP_Hash;
    DUS: TIniFile;
    Dup5Path: string;
    tmpFile: string;
    curDL: string;
    lstUpd: TStringList;
    curUpd: integer;
    hDupp: integer;
    coreBuild: integer;
    curDLSize: integer;
    NFO: DUP5PACK_Info;
    NFO1: DUP5PACK_Info_v1;
    HDR: DUP5PACK_Header;
    PackName: string;
    PackURL: string;
    PackAuthor: string;
    PackComment: string;
    urlToStable: string;
    urlToWIP: string;
    NFOLoaded: boolean;
    BlockOffsets: array of DUP5PACK_Offsets_v4;
    function infosDUPP(): boolean;
    procedure parseDUPP();
    procedure translate();
    function getPluginVersion(filename: String):integer;
    function getRawDestDir(i: integer): string;
    function getDestDir(i: integer): string;
    function getTempFile(ext: string): string;
    function getDup5Version(): integer;
    function ExecAndWait(const ExecuteFile, ParamString : string): boolean;
    function RegisterOCX(ocxpath: string): boolean;
    procedure appendLog(dest: TLogType; text: string);
    procedure colorLog(dest: TLogType; Color: TColor);
    procedure separatorLog(dest: TLogType);
    procedure setRichEditLineColor(R: TRichEdit; Line: Integer;
      Color: TColor);
    procedure setRichEditLineStyle(R: TRichEdit; Line: Integer;
      Style: TFontStyles);
    procedure styleLog(dest: TLogType; Style: TFontStyles);
    procedure writeLog(dest: TLogType; text: string);
    procedure applyProxyValues();
    { Déclarations privées }
  public
    proxy: string;
    proxyPort: string;
    proxyUserPass: boolean;
    proxyUser: string;
    proxyPass: string;
    function loadDUPP(duppfile: string): boolean;
    procedure closeDUPP();
    { Déclarations publiques }
  end;

var
  frmInstaller: TfrmInstaller;

const
  VERSION: Integer = 34140;

implementation

uses Proxy;

{$R *.dfm}

procedure TfrmInstaller.closeDUPP();
begin

  NFOLoaded := false;

  if (hDupp <> 0) then
    FileClose(hDupp);

end;

// -------------------------------------------------------------------------- //
// DUPP version 4 support functions ========================================= //
// -------------------------------------------------------------------------- //

// This function pre-process DUPP v4 files to be sure it is not broken
//   1) Checks footer is present
//   2) Checks header+offets hash is OK
//   3) Reads the block offsets
//   4) Checks the flags are OK
// Returns False if anything is wrong
//         True if all is OK
function TfrmInstaller.sanitycheckDUPP_version4(src: integer): boolean;
var HDR: DUP5PACK_Header_v4;
    FTR: DUP5PACK_Footer_v4;
    tmpStream, srcStream: TStream;
    Hash_SHA256: TDCP_sha256;
    Hash: array[0..31] of byte;
    HashOk, OffsetsOk: boolean;
    x, NeededBlocks: integer;
begin

  Result := false;

  srcStream := THandleStream.Create(src);
  tmpStream := TMemoryStream.Create;
  Hash_SHA256 := TDCP_sha256.Create(Self);

  OffsetsOk := true;
  NeededBlocks := 0;

  try

    srcStream.Seek(0,0);
    tmpStream.CopyFrom(srcStream,SizeOf(DUP5PACK_Header_v4));
    tmpStream.Seek(0,0);
    tmpStream.Read(HDR,SizeOf(DUP5PACK_Header_v4));
    tmpStream.CopyFrom(srcStream,SizeOf(DUP5PACK_Offsets_v4)*HDR.NumOffsets);

    srcStream.Seek(-SizeOf(DUP5PACK_Footer_v4),2);
    srcStream.Read(FTR,SizeOf(DUP5PACK_Footer_v4));

    if (FTR.ID = 'PPUD') and (FTR.EOF = 26) and (FTR.Version = 1) then
    begin
      tmpStream.Seek(0,0);
      Hash_SHA256.Init;
      Hash_SHA256.UpdateStream(tmpStream,tmpStream.Size);
      Hash_SHA256.Final(Hash);

      HashOk := true;
      for x := 0 to 31 do
        HashOk := HashOk and (Hash[x] = FTR.HashHeaderOffsets[x]);

      if HashOk then
      begin

        tmpStream.Seek(SizeOf(DUP5PACK_Header_v4),0);
        SetLength(BlockOffsets,HDR.NumOffsets);

        for x := 0 to HDR.NumOffsets-1 do
        begin
          tmpStream.Read(BlockOffsets[x],SizeOf(DUP5PACK_Offsets_v4));
          OffsetsOk := OffsetsOk and
            ((((BlockOffsets[x].OptionsFlags and D5PBLOCK_COMPRESSED) = D5PBLOCK_COMPRESSED)
              and ((BlockOffsets[x].CompressionType = D5PCOMPRESSION_ZLIB)
                or (BlockOffsets[x].CompressionType = D5PCOMPRESSION_LZMA))
               and (BlockOffsets[x].DSize > 0))
              or (((BlockOffsets[x].OptionsFlags and D5PBLOCK_COMPRESSED) = 0)
               and (BlockOffsets[x].CompressionType = D5PCOMPRESSION_NONE)
               and (BlockOffsets[x].DSize = 0)))

            and ((((BlockOffsets[x].OptionsFlags and D5PBLOCK_COMPANION) = D5PBLOCK_COMPANION)
               and (BlockOffsets[x].CompanionOfID > 0))
              or (((BlockOffsets[x].OptionsFlags and D5PBLOCK_COMPANION) = 0)
               and (BlockOffsets[x].CompanionOfID = 0)))

            and ((((BlockOffsets[x].OptionsFlags and D5PBLOCK_ENTRIES) = D5PBLOCK_ENTRIES)
               and (BlockOffsets[x].NumEntries > 0))
              or (((BlockOffsets[x].OptionsFlags and D5PBLOCK_ENTRIES) = 0)
               and (BlockOffsets[x].NumEntries = 0)))

            and ((BlockOffsets[x].ID = 1) or (BlockOffsets[x].ID = 10)
              or (BlockOffsets[x].ID = 2) or (BlockOffsets[x].ID = 20)
              or (BlockOffsets[x].ID = 21)
              or ((BlockOffsets[x].OptionsFlags and D5PBLOCK_UNIMPORTANT) = D5PBLOCK_UNIMPORTANT));

          if (BlockOffsets[x].ID = 1)
          or (BlockOffsets[x].ID = 2)
          or (BlockOffsets[x].ID = 20)
          or (BlockOffsets[x].ID = 21) then
            Inc(NeededBlocks);
        end;

      end;

      Result := HashOk and OffsetsOk and (NeededBlocks = 4);

    end;

  finally
    srcStream.Free;
    tmpStream.Free;
  end;

end;

function TfrmInstaller.searchDUPP_version4_blockID(id: integer): integer;
var x: integer;
begin

  result := -1;

  for x := 0 to length(BlockOffsets) do
  begin
    if (BlockOffsets[x].ID = id) then
    begin
      result := x;
      exit;
    end;
  end;

end;

function TfrmInstaller.extractDUPP_version4_file(fileid: DUP5PACK_File_v4; srcStream: TStream; var dstStream: TBufferedFS): integer;
var tmpStream: TStream;
    DStream: TDecompressionStream;
    Hash_Engine: TDCP_hash;
    Hash: array[0..63] of byte;
    x, hashsize: integer;
    testValue: int64;
    HashOk: boolean;
    s1,s2: string;
begin

  tmpStream := TMemoryStream.Create;

  case fileid.HashType of
    D5PHASH_MD5: Hash_Engine := TDCP_md5.Create(Self);
    D5PHASH_SHA1: Hash_Engine := TDCP_sha1.Create(Self);
    D5PHASH_SHA256: Hash_Engine := TDCP_sha256.Create(Self);
    D5PHASH_SHA512: Hash_Engine := TDCP_sha512.Create(Self);
    D5PHASH_RIPEMD160: Hash_Engine := TDCP_ripemd160.Create(Self);
  else
    raise Exception.Create(ReplaceValue('%h',DLNGStr('PIE401'),inttostr(fileid.HashType)));
  end;

  hashsize := Hash_Engine.GetHashSize div 8;
  result := 0;

  try
    testValue := srcStream.Seek(fileid.RelOffset,0);
    if testValue <> fileid.RelOffset then
      raise Exception.Create(ReplaceValue('%a',ReplaceValue('%b',DLnGStr('PIE402'),inttohex(fileid.RelOffset,8)),inttohex(testValue,8)));

    testValue := tmpStream.CopyFrom(srcStream,fileid.Size);
    if testValue <> fileid.Size then
      raise Exception.Create(ReplaceValue('%a',ReplaceValue('%b',DLNGStr('PIE403'),inttostr(fileid.Size)),inttostr(testValue)));

    if fileid.DSize > 1024 then
      appendLog(Install,ReplaceValue('%s','('+DLNGStr('PI0053')+')',inttostr(fileid.DSize div 1024)))
    else
      appendLog(Install,ReplaceValue('%s','('+DLNGStr('PI0052')+')',inttostr(fileid.DSize)));

    tmpStream.Seek(0,0);
    if (fileid.Flags and D5PFILE_COMPRESSED) = D5PFILE_COMPRESSED then
    begin
      appendLog(Install,DLNGStr('PI0030'));
      case fileid.CompressionType of
        D5PCOMPRESSION_ZLIB: begin
          DStream := TDecompressionStream.Create(tmpStream);
          try
            testValue := dstStream.CopyFrom(DStream,fileid.DSize);
          finally
            DStream.Free;
          end;
          if testValue <> fileid.DSize then
            raise Exception.Create(ReplaceValue('%a',ReplaceValue('%b',ReplaceValue('%c',DLNGStr('PIE404'),inttostr(fileid.DSize)),inttostr(testValue)),'Zlib'));
        end;
        D5PCOMPRESSION_LZMA: begin
          lzma_decode(tmpStream,dstStream);
          if dstStream.size <> fileid.DSize then
            raise Exception.Create(ReplaceValue('%a',ReplaceValue('%b',ReplaceValue('%c',DLNGStr('PIE404'),inttostr(fileid.DSize)),inttostr(dstStream.size)),'LZMA'));
        end;
      else  // Unsupported compression format
        raise Exception.Create(ReplaceValue('%a',DLNGStr('PIE405'),inttohex(fileid.CompressionType,2)));
      end;
    end
    else
    begin
      dstStream.copyFrom(tmpStream,tmpStream.size);
    end;

    result := fileid.DSize;

    dstStream.Seek(0,0);

    Hash_Engine.Init;
    Hash_Engine.UpdateStream(dstStream,dstStream.Size);
    Hash_Engine.Final(Hash);

    HashOk := true;
    for x := 0 to hashsize - 1 do
    begin
      HashOk := HashOk and (Hash[x] = fileid.Hash[x]);
      s1:= s1 + IntToHex(Hash[x],2);
      s2:= s2 + IntToHex(fileid.Hash[x],2);
    end;

    if not(HashOk) then
      raise Exception.Create(ReplaceValue('%a',ReplaceValue('%b',DLNGStr('PIE406'),s2),s1));

    appendLog(Install,DLNGStr('PI0032'));

  finally
    Hash_Engine.Free;
    tmpStream.free;
  end;

end;

function TfrmInstaller.getDUPP_version4_blockcontent(src,id: integer): TStream;
var tmpStream, srcStream: TStream;
    DStream: TDecompressionStream;
    Hash_SHA256: TDCP_sha256;
    Hash: array[0..31] of byte;
    x: integer;
    testValue: int64;
    HashOk: boolean;
    s1,s2: string;
begin

  srcStream := THandleStream.Create(src);
  tmpStream := TMemoryStream.Create;
  Hash_SHA256 := TDCP_sha256.Create(Self);
  result := nil;

  try
    testValue := srcStream.Seek(BlockOffsets[id].Offset,0);
    if testValue <> BlockOffsets[id].Offset then
      raise Exception.Create(ReplaceValue('%a',ReplaceValue('%b',DLNGStr('PIE407'),inttohex(BlockOffsets[id].Offset,8)),inttohex(testValue,8)));

    testValue := tmpStream.CopyFrom(srcStream,BlockOffsets[id].Size);
    if testValue <> BlockOffsets[id].Size then
      raise Exception.Create(ReplaceValue('%a',ReplaceValue('%b',DLNGStr('PIE408'),inttostr(BlockOffsets[id].Size)),inttostr(testValue)));

    tmpStream.Seek(0,0);
    Hash_SHA256.Init;
    Hash_SHA256.UpdateStream(tmpStream,tmpStream.Size);
    Hash_SHA256.Final(Hash);

    HashOk := true;
    for x := 0 to 31 do
    begin
      HashOk := HashOk and (Hash[x] = BlockOffsets[id].Hash[x]);
      s1:= s1 + IntToHex(Hash[x],2);
      s2:= s2 + IntToHex(BlockOffsets[id].Hash[x],2);
    end;

    if not(HashOk) then
      raise Exception.Create(ReplaceValue('%a',ReplaceValue('%b',DLNGStr('PIE406'),s2),s1));

    tmpStream.Seek(0,0);
    if (BlockOffsets[id].OptionsFlags and D5PBLOCK_COMPRESSED) = D5PBLOCK_COMPRESSED then
    begin
      if BlockOffsets[id].DSize > 1024 then
        appendLog(Install,ReplaceValue('%s','('+DLNGStr('PI0053')+')',inttostr(BlockOffsets[id].DSize div 1024)))
      else
        appendLog(Install,ReplaceValue('%s','('+DLNGStr('PI0052')+')',inttostr(BlockOffsets[id].DSize)));
      case BlockOffsets[id].CompressionType of
        D5PCOMPRESSION_ZLIB: begin
          result := TMemoryStream.Create;
          DStream := TDecompressionStream.Create(tmpStream);
          try
            testValue := result.CopyFrom(DStream,BlockOffsets[id].DSize);
          finally
            DStream.Free;
          end;
          if testValue <> BlockOffsets[id].DSize then
            raise Exception.Create(ReplaceValue('%a',ReplaceValue('%b',ReplaceValue('%c',DLNGStr('PIE404'),inttostr(BlockOffsets[id].DSize)),inttostr(testValue)),'Zlib'));
          result.Seek(0,0);
        end;
        D5PCOMPRESSION_LZMA: begin
          result := TMemoryStream.Create;
          lzma_decode(tmpStream,result);
          if result.size <> BlockOffsets[id].DSize then
            raise Exception.Create(ReplaceValue('%a',ReplaceValue('%b',ReplaceValue('%c',DLNGStr('PIE404'),inttostr(BlockOffsets[id].DSize)),inttostr(result.size)),'LZMA'));

          result.Seek(0,0);
        end;
      else  // Unsupported compression format
        raise Exception.Create(ReplaceValue('%a',DLNGStr('PIE405'),inttohex(BlockOffsets[id].CompressionType,2)));
      end;
    end
    else
    begin
      result := tmpStream;
    end;
    appendLog(Install,DLNGStr('PI0032'));
  finally
    srcStream.free;
    Hash_SHA256.Free;
    if result <> tmpStream then
      tmpStream.free;
  end;

end;

function TfrmInstaller.infosDUPP_version4(src: integer): boolean;
var  Dup5Ver: integer;
    infoid, bannerid: integer;
    tmpStream: TStream;
    NFO: DUP5PACK_Info_v4;
    isError, cont: boolean;
    imgTmp: tbitmap;
begin

  isError := false;
  cont := false;

  if (length(BlockOffsets) > 0) or sanitycheckDUPP_version4(src) then
  begin

    infoid := searchDUPP_version4_blockID(D5PID_INFORMATION);
    bannerid := searchDUPP_version4_blockID(D5PID_BANNER);

    if infoid <> -1 then
    begin
      tmpStream := nil;

      try
        tmpStream := getDUPP_version4_blockcontent(src,infoid);
      except
        on E: exception do
        begin
          writelog(Install,DLNGStr('PIE409'));
          colorLog(Install,clRed);
          writelog(Install,e.Message);
          colorLog(Install,clRed);
          MessageDlg(DLNGStr('PIE409')+chr(10)+e.Message,mtError,[mbOk],0);
          isError := true;
        end;
      end;

      if (tmpStream <> nil) and not(isError) then
      begin

        tmpStream.Read(NFO,SizeOf(DUP5PACK_Info_v4));
        PackName := Get8(tmpStream);
        PackURL := get8(tmpStream);
        PackAuthor := get8(tmpStream);
        PackComment := get32(tmpStream);

        tmpStream.free;

        panTitle.Caption := ' '+StringReplace(PackName,'&','&&',[rfReplaceAll]);
        panPVersion.Caption := ' '+getVersionFromInt(NFO.NumVer);
        panAuthor.Caption := ' '+StringReplace(PackAuthor,'&','&&',[rfReplaceAll]);
        panComment.Caption := ' '+StringReplace(PackComment,'&','&&',[rfReplaceAll]);
        panURL.Caption := ' '+PackURL;

        Dup5Ver := getDup5Version;

        cont := (NFO.DUP5VerTest = -1) or
                ((NFO.DUP5VerTest = 0) and (Dup5Ver = NFO.DUP5VerValue)) or
                ((NFO.DUP5VerTest = 1) and (Dup5Ver > NFO.DUP5VerValue)) or
                ((NFO.DUP5VerTest = 2) and (Dup5Ver < NFO.DUP5VerValue)) or
                ((NFO.DUP5VerTest = 3) and (Dup5Ver <> NFO.DUP5VerValue));

        NFOLoaded := true;

        if not(cont) then
        begin
          MessageDlg(DLNGStr('PI0042'),mtError,[mbOk],0);
        end
        else if bannerid <> -1 then
        begin

          try
            tmpStream := getDUPP_version4_blockcontent(src,bannerid);
          except
            on E: exception do
            begin
              writelog(Install,DLNGStr('PIE410'));
              colorLog(Install,clRed);
              writelog(Install,e.Message);
              colorLog(Install,clRed);
              MessageDlg(DLNGStr('PIE410')+chr(10)+e.Message,mtError,[mbOk],0);
              isError := true;
            end;
          end;

          if not(isError) then
          begin

            imgCustomBanner.Visible := false;
            tmpStream.Seek(0,0);
            imgTmp := TBitmap.Create;
            imgTmp.LoadFromStream(tmpStream);
            imgCustomBanner.Picture.Assign(imgTmp);
            imgCustomBanner.Visible := true;

          end;
        end;
      end;
    end;
  end;

  result := not(isError) and cont;

end;

function TfrmInstaller.loadDUPP(duppfile: string): boolean;
begin

   writelog(Install,ReplaceValue('%a',DLNGStr('PI0054'),extractfilename(duppfile))+' ');

   if FileExists(duppfile) then
   begin

     hDupp := FileOpen(duppfile, fmOpenRead);

     FileRead(hDupp,HDR,8);

     if (HDR.ID <> 'DUPP') or (HDR.EOF <> 26) then
     begin
       FileClose(hDupp);
       hDupp := 0;
       writeLog(Install,DLNGstr('PI0015'));
       colorLog(Install,clRed);
       MessageDlg(DLNGstr('PI0015'),mtError,[mbOk],0);
       result := false;
     end
     else if (HDR.NeededVersion > VERSION) then
     begin
       FileClose(hDupp);
       hDupp := 0;
       writeLog(Install,ReplaceValue('%y',ReplaceValue('%v',DLNGstr('PI0041'),GetVersionFromInt(HDR.NeededVersion)),GetVersionFromInt(VERSION)));
       colorLog(Install,clRed);
       MessageDlg(ReplaceValue('%y',ReplaceValue('%v',DLNGstr('PI0041'),GetVersionFromInt(HDR.NeededVersion)),GetVersionFromInt(VERSION)),mtError,[mbOk],0);
       result := false;
     end
     else if (HDR.Version = 4) and not(sanitycheckDUPP_version4(hDupp)) then
     begin
       FileClose(hDupp);
       hDupp := 0;
       writeLog(Install,ReplaceValue('%a',DLNGStr('PIE411'),'HDR')+' Sanity check failed');
       colorLog(Install,clRed);
       // ToTRANSLATE //
       MessageDlg(ReplaceValue('%a',DLNGStr('PIE411'),'HDR')+' Sanity check failed',mtError,[mbOk],0);
       result := false;
     end
     else
     begin
       appendlog(Install,'[DUPP v'+inttostr(HDR.Version)+']');
       result := true;
       NFOloaded := false;
     end;

   end
   else
   begin
     writeLog(Install,ReplaceValue('%f',DLNGstr('PI0017'),duppfile));
     colorLog(Install,clRed);
     MessageDlg(ReplaceValue('%f',DLNGstr('PI0017'),duppfile),mtError,[mbOk],0);
     result := false;
   end;

end;

procedure TfrmInstaller.parseDUPP();
begin

  if (hDupp <> 0) and (NFOLoaded) then
    case HDR.Version of
      1: parseDUPP_version1to3(hDupp,HDR.Version);
      2: parseDUPP_version1to3(hDupp,HDR.Version);
      3: parseDUPP_version1to3(hDupp,HDR.Version);
      4: parseDUPP_version4(hDupp);
    else
      writeLog(Install,ReplaceValue('%v',DLNGstr('PI0014'),inttostr(HDR.Version)));
      colorLog(Install,clRed);
      MessageDlg(ReplaceValue('%v',DLNGstr('PI0014'),inttostr(HDR.Version)),mtError, [mbOk],0);
    end;

end;

function TfrmInstaller.isDup5Running: boolean;
begin

  result := FindWindow('Tdup5Main', nil) <> 0;

end;

procedure TfrmInstaller.parseDUPP_version1to3(src: integer; version: integer);
var ENT: DUP5PACK_File;
    FileName, InstallDir, DestDir: string;
    x, fout, calcCRC, size, destVersion: integer;
    Buf, bufoutstr: PChar;
    InputStream: TMemoryStream;
    OutputStream: TDeCompressionStream;
    installFile: boolean;
    errCount: integer;
begin

  errCount := 0;

  for x := 1 to NFO.NumFiles do
  begin

    writeLog(Install,DLNGstr('PI0018'));

    FileRead(src,ENT.Size,4);
    FileRead(src,ENT.DSize,4);
    FileRead(src,ENT.DateT,4);
    FileRead(src,ENT.Hidden,1);
    FileRead(src,ENT.ReadOnly,1);
    FileRead(src,ENT.Flags,1);
    FileRead(src,ENT.UpdateOnly,1);
    FileRead(src,ENT.Version,4);
    FileRead(src,ENT.CompressionType,4);
    FileRead(src,ENT.BaseInstallDir,4);
    FileRead(src,ENT.CRC,4);
    filename := get8(src);
    installdir := get8(src);

    if ENT.DSize > 1024 then
      writeLog(Install,filename+' ('+ReplaceValue('%s',DLNGStr('PI0053'),inttostr(Round(ENT.DSize/1024)))+') ')
    else
      writeLog(Install,filename+' ('+ReplaceValue('%s',DLNGStr('PI0052'),inttostr(ENT.DSize))+') ');

    DestDir := getDestDir(ENT.BaseInstallDir) + installdir + filename;
    ForceDirectories(getDestDir(ENT.BaseInstallDir) + installdir);

    if (ENT.Version >= 0) and FileExists(DestDir) then
      destVersion := getPluginVersion(DestDir)
    else
      destVersion := -1;

    if (ENT.Version >= 0) and (ENT.Version <= destVersion) then
    begin
      if (ENT.UpdateOnly = 0) then
      begin
        if MessageDlg(ReplaceValue('%2',ReplaceValue('%1',ReplaceValue('%f',DLNGstr('PI0019'),destdir),getVersionFromInt(destVersion)),getVersionFromInt(ENT.Version)),mtConfirmation,[mbYes, mbNo],0) = mrYes then
        begin
          installFile := true;
        end
        else
          installFile := false;
      end
      else
        installFile := false;
    end
    else
      installFile := true;

    if not(installFile) then
    begin
      writeLog(Install,filename+' ('+inttostr(Round(ENT.DSize/1024))+DLNGstr('PI0028')+')... '+DLNGstr('PI0027'));
      FileSeek(src,ENT.Size,1);
    end
    else
    begin

      writeLog(Install,filename+' ('+inttostr(Round(ENT.DSize/1024))+DLNGstr('PI0028')+')... '+DLNGstr('PI0029'));

      GetMem(Buf,ENT.Size);
      try
        FileRead(src,buf^,ENT.Size);
        calcCRC := 0;

        if (ENT.CompressionType = 1) then
        begin
          InputStream := TMemoryStream.Create;

          writeLog(Install,filename+' ('+inttostr(Round(ENT.DSize/1024))+DLNGstr('PI0028')+')... '+DLNGstr('PI0030'));
          try
            InputStream.Write(buf^, ENT.Size);
            InputStream.Seek(0, soFromBeginning);

            OutputStream := TDecompressionStream.Create(InputStream);
            try
              OutputStream.Read(Size, SizeOf(Size));
              getMem(bufoutstr,Size);
              OutputStream.Read(bufoutstr^, Size);
              if version = 3 then
                calcCRC := GetBufCRC32(bufoutstr,ENT.DSize)
              else
                calcCRC := getStrCRC32(bufoutstr^);
            finally
              OutputStream.Free
            end
          finally
            InputStream.Free
          end;
        end
        else if ENT.CompressionType = 0 then
        begin
          if version = 3 then
            calcCRC := GetBufCRC32(buf,ENT.DSize)
          else
            calcCRC := getStrCRC32(buf^);
          Size := ENT.DSize;
        end
        else
        begin
          writelog(Install,ReplaceValue('%a',DLNGStr('PIE405'),inttostr(ENT.CompressionType))+chr(10)+chr(13)+FileName);
          colorLog(Install,clRed);
          MessageDlg(ReplaceValue('%a',DLNGStr('PIE405'),inttostr(ENT.CompressionType))+chr(10)+chr(13)+FileName,mtConfirmation,[mbOk],0);
        end;

        writeLog(Install,filename+' ('+inttostr(Round(ENT.DSize/1024))+DLNGstr('PI0028')+')... '+DLNGstr('PI0031'));

        if (calcCRC <> ENT.CRC) then
        begin
          MessageDlg(ReplaceValue('%f',DLNGstr('PI0020'),FileName),mtConfirmation,[mbOk],0);
          inc(errCount);
        end
        else if (Size <> ENT.DSize) then
        begin
          MessageDlg(ReplaceValue('%f',DLNGstr('PI0021'),FileName),mtConfirmation,[mbOk],0);
          inc(errCount);
        end
        else
        begin
          if (FileExists(destdir)) then
            DeleteFile(destdir);
          fout := FileCreate(destdir);
          if (ENT.CompressionType = 1) then
          begin
            FileWrite(fout,bufoutstr^,ENT.DSize);
            FreeMem(bufoutstr);
          end
          else
            FileWrite(fout,buf^,ENT.DSize);
          FileClose(fout);
          if ((ENT.Flags and D5PFILE_REGSVR32) = D5PFILE_REGSVR32) then
          begin
            writelog(Install,DLNGStr('PI0061'));
            RegisterOcx(destdir);
          end;
        end;

        writeLog(Install,filename+' ('+inttostr(Round(ENT.DSize/1024))+DLNGstr('PI0028')+')... '+DLNGstr('PI0032'));

      finally
        FreeMem(Buf);
      end;
    end;

    Progress.Position := Round((x / NFO.NumFiles)*100);

  end;

  Progress.Position := 100;
  if (errCount = 0) then
  begin
    writeLog(Install,ReplaceValue('%i',DLNGstr('PI0022'),IntToStr(NFO.NumFiles)));
    lblInstalling.Caption := DLNGstr('PI0023');
  end
  else
  begin
    writeLog(Install,ReplaceValue('%e',DLNGstr('PI0024'),intToStr(errCount)));
    lblInstalling.Caption := ReplaceValue('%i',ReplaceValue('%e',DLNGstr('PI0025'),intToStr(errCount)),intToStr(NFO.NumFiles - errCount));
  end;

end;

procedure TfrmInstaller.parseDUPP_version4(src: integer);
var DestDir, DuppiInstallNew: string;
    x, destVersion: integer;
    installFile, isDeleteFile: boolean;

    entStream,namStream,datStream: TStream;
    entriesid, namesid, dataid,fileattrib: integer;
    isError: boolean;

    outFile: TBufferedFS;

    names: array of String;
    files: array of DUP5PACK_File_v4;

    duppiInstall: boolean;


begin

//  result := false;
  isError := false;
  duppiInstall := false;
  entriesId := -1;

  if (length(BlockOffsets) > 0) or sanitycheckDUPP_version4(src) then
  begin

    writelog(Install,DLNGStr('PI0055'));

    entriesid := searchDUPP_version4_blockID(D5PID_ENTRIES);
    namesid := searchDUPP_version4_blockID(D5PID_NAMES);
    dataid := searchDUPP_version4_blockID(D5PID_DATA);

    if (entriesid <> -1) and (namesid <> -1) and (dataid <> -1) then
    begin

      writelog(Install,ReplaceValue('%a',DLNGStr('PI0056'),DLNGStr('PI0057')));

      entStream := nil;
      try
        entStream := getDUPP_version4_blockcontent(src,entriesid);
      except
        on E: exception do
        begin
          writelog(Install,ReplaceValue('%a',DLNGStr('PIE411'),DLNGStr('PI0057')));
          colorLog(Install,clRed);
          writelog(Install,e.Message);
          colorLog(Install,clRed);
          isError := true;
        end;
      end;

      writelog(Install,ReplaceValue('%a',DLNGStr('PI0056'),DLNGStr('PI0058')));

      namStream := nil;
      try
        namStream := getDUPP_version4_blockcontent(src,namesid);
      except
        on E: exception do
        begin
          writelog(Install,ReplaceValue('%a',DLNGStr('PIE411'),DLNGStr('PI0058')));
          colorLog(Install,clRed);
          writelog(Install,e.Message);
          colorLog(Install,clRed);
          isError := true;
        end;
      end;

      writelog(Install,ReplaceValue('%a',DLNGStr('PI0056'),DLNGStr('PI0059')));

      datStream := nil;
      try
        datStream := getDUPP_version4_blockcontent(src,dataid);
      except
        on E: exception do
        begin
          writelog(Install,ReplaceValue('%a',DLNGStr('PIE411'),DLNGStr('PI0059')));
          colorLog(Install,clRed);
          writelog(Install,e.Message);
          colorLog(Install,clRed);
          isError := true;
        end;
      end;

      if (entStream <> nil) and (namStream <> nil) and (datStream <> nil) and not(isError) then
      begin

        SetLength(names,BlockOffsets[namesid].NumEntries);
        namStream.Seek(0,0);
        for x := 0 to BlockOffsets[namesid].NumEntries - 1 do
          names[x] := Get8(namStream);
        namStream.Free;

        SetLength(files,BlockOffsets[entriesid].NumEntries);
        entStream.Seek(0,0);
        for x := 0 to BlockOffsets[entriesid].NumEntries - 1 do
          entStream.Read(files[x],SizeOf(DUP5PACK_File_v4));
        entStream.Free;

        for x := 0 to BlockOffsets[entriesid].NumEntries - 1 do
        begin

          writelog(Install,ReplaceValue('%a',ReplaceValue('%b',DLNGStr('PI0060'),getRawDestDir(files[x].BaseInstallDir) + names[x]),inttostr(x+1)));

          if (files[x].BaseInstallDir = 5) and ((compareText(names[x],'duppi.exe') = 0)
                                             or (compareText(names[x],'libcurl-3.dll') = 0)
                                             or (compareText(names[x],'zlib1.dll') = 0)) then
          begin
            duppiInstall := true;
            DestDir := getDestDir(files[x].BaseInstallDir) + names[x] + '.new';
            duppiInstallNew := getDestDir(files[x].BaseInstallDir);
          end
          else
            DestDir := getDestDir(files[x].BaseInstallDir) + names[x];

          if (files[x].Version >= 0) and FileExists(DestDir) then
            destVersion := getPluginVersion(DestDir)
          else
            destVersion := -1;

          isDeleteFile := (files[x].Flags and D5PFILE_DELETE) = D5PFILE_DELETE;

          if isDeleteFile then
          begin

            if FileExists(destdir) then
              if (files[x].Version = 0) then
              begin
                if MessageDlg(ReplaceValue('%f',DLNGStr('PI0065'),destdir)+DLNGStr('PI0067'),mtConfirmation,[mbYes, mbNo],0) = mrYes then
                  if DeleteFile(destdir) then
                    appendLog(Install,DLNGStr('PI0068'));
              end
              else if (files[x].Version >= 0) and (files[x].Version >= destVersion) then
              begin
                if MessageDlg(ReplaceValue('%f',DLNGStr('PI0065'),destdir)+ReplaceValue('%2',ReplaceValue('%1',DLNGStr('PI0066'),getVersionFromInt(destVersion)),getVersionFromInt(files[x].Version))+DLNGStr('PI0067'),mtConfirmation,[mbYes, mbNo],0) = mrYes then
                  if DeleteFile(destdir) then
                    appendLog(Install,DLNGStr('PI0068'));
              end;

          end
          else
          begin

            ForceDirectories(getDestDir(files[x].BaseInstallDir));

            if (files[x].Version >= 0) and (files[x].Version <= destVersion) then
            begin
              if (files[x].Flags and D5PFILE_UPDATEONLY) = D5PFILE_UPDATEONLY then
              begin
                if MessageDlg(ReplaceValue('%2',ReplaceValue('%1',ReplaceValue('%f',DLNGstr('PI0019'),destdir),getVersionFromInt(destVersion)),getVersionFromInt(files[x].Version)),mtConfirmation,[mbYes, mbNo],0) = mrYes then
                  installFile := true
                else
                  installFile := false;
              end
              else
                installFile := false;
            end
            else
              installFile := true;

            if installFile then
            begin

              if FileExists(destdir) then
                DeleteFile(destdir);
              outfile := TBufferedFS.Create(destdir,fmCreate or fmShareExclusive);
              try
                extractDUPP_version4_file(files[x],datStream,outfile);
              finally
                outfile.Free;
              end;

              fileattrib := 0;
              if (files[x].Flags and D5PFILE_HIDDEN) = D5PFILE_HIDDEN then
                fileattrib := fileattrib or faHidden;
              if (files[x].Flags and D5PFILE_READONLY) = D5PFILE_READONLY then
                fileattrib := fileattrib or faReadOnly;

              if fileattrib > 0 then
                filesetattr(DestDir,fileattrib);

              filesetdate(destdir,files[x].DateT);

              if ((files[x].Flags and D5PFILE_REGSVR32) = D5PFILE_REGSVR32) then
              begin
                writelog(Install,DLNGStr('PI0061'));
                RegisterOcx(destdir);
              end;

            end;

          end;
        end;
      end;
    end;
  end;

  writelog(Install,ReplaceValue('%i',DLNGStr('PI0022'),inttostr(BlockOffsets[entriesid].NumEntries)));
  styleLog(Install,[fsBold]);
  colorLog(Install,clGreen);

  if duppiInstall then
  begin

    // Duppi will restart to update itself
    MessageDlg(DLNGStr('PI0062'),mtCustom,[mbOk],0);
    ShellExecute(0, nil,PChar('"'+extractfilepath(Application.EXEName)+'DuppiInstall.exe"'), PChar('X X "'+DuppiInstallNew+'"'), nil, SW_SHOW);
    Application.Terminate;

  end;

end;

procedure TfrmInstaller.FormShow(Sender: TObject);
var Reg: TRegistry;
    clng, lv, S: string;
    Taille  : DWord;
    Buffer  : PChar;
    VersionPC : PChar;
    VersionL    : DWord;
    VerifBuild: integer;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      Dup5Path := '';
      if Reg.ValueExists('Path') then
        Dup5Path := Reg.ReadString('Path');
      if Reg.ValueExists('Version') then
      begin
        lblLastExec.Caption := Reg.ReadString('Version');
        lblLastExec.Hint := dup5Path;
        if Reg.ValueExists('Build') then
        begin
          coreBuild := Reg.ReadInteger('Build');
          lblLastExec.Caption := lblLastExec.Caption + '.'+IntTostr(CoreBuild);
        end
        else
          coreBuild := 0;
        if Reg.ValueExists('Edit') then
          lblLastExec.Caption := lblLastExec.Caption + ' '+ Reg.ReadString('Edit');
      end;
      if Reg.ValueExists('Language') then
        clng := Reg.ReadString('Language')
      else
        clng := '*';
      if clng = '*' then
        LoadInternalLanguage
      else
        LoadLanguage(ExtractFilePath(Application.ExeName)+'\data\'+clng,false);
      Reg.CloseKey;
    end;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Duppi',True) then
    begin
      if Reg.ValueExists('Proxy') then
        proxy := Reg.ReadString('Proxy')
      else
        proxy := '';
      if Reg.ValueExists('ProxyPort') then
        proxyPort := Reg.ReadString('ProxyPort')
      else
        proxyPort := '';
      if Reg.ValueExists('ProxyUserPass') then
        proxyUserPass := Reg.ReadBool('ProxyUserPass')
      else
        proxyUserPass := false;
      if Reg.ValueExists('ProxyUser') then
        proxyUser := Reg.ReadString('ProxyUser')
      else
        proxyUser := '';
      if Reg.ValueExists('ProxyPass') then
        proxyPass := Reg.ReadString('ProxyPass')
      else
        proxyPass := '';
      if Reg.ValueExists('InstallPath') then
        txtPathD5P.Text := Reg.ReadString('InstallPath');
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  if Not(FileExists(Dup5Path+'drgunpack5.exe')) then
  begin
    MessageDlg(DLNGstr('PI0026'),mtError,[mbOk],0);
    Close;
  end;

  {--- on demande la taille des informations sur l'application ---}
  S := Dup5Path+'drgunpack5.exe';
  Taille := GetFileVersionInfoSize(PChar(S), Taille);
  lv := '';
  if Taille>0
  then
  begin
    {--- Réservation en mémoire d'une zone de la taille voulue ---}
    Buffer := AllocMem(Taille);
    try
      {--- Copie dans le buffer des informations ---}
      GetFileVersionInfo(PChar(S), 0, Taille, Buffer);
      {--- Recherche de l'information de version ---}
      if VerQueryValue(Buffer, PChar('\StringFileInfo\040C04E4\FileVersion'), Pointer(VersionPC), VersionL)
          then lv:=VersionPC;
    finally
      FreeMem(Buffer, Taille);
    end;
  end;
  VerifBuild := strtoint(rightstr(lv, length(lv) - posrev('.',lv)));

  if VerifBuild <> coreBuild then
  begin
    if MessageDlg(ReplaceValue('%b',ReplaceValue('%a',DLNGstr('PI0069'),inttostr(VerifBuild)),inttostr(coreBuild)),mtError,[mbYes, mbNo],0) = mrYes then
    begin
      ShellExecute(Application.Handle,
                        'OPEN',
                        PChar(Dup5Path+'drgunpack5.exe'),
                        nil,
                        nil,
                        SW_SHOW);
    end;
    Close;
  end;

  frmInstaller.Caption := 'Duppi v'+getVersionFromInt(VERSION);
  Application.Title := 'Duppi v'+getVersionFromInt(VERSION);

  translate;

  if (ParamStr(1) = '/InstalledOK') then
  begin

    ShowMessage(DLNGstr('PI0046'));

  end
  else if (lowercase(ParamStr(1)) = '/checknewversions') or (lowercase(ParamStr(1)) = '/checktranslations') then
  begin

    optInternet.Checked := true;
    AutoCheckTimer.Enabled := true;

  end
  else if (ParamStr(1) <> '') then
  begin
    stepChoice.Visible := false;
    stepInstall.Visible := true;
    cmdNext.Visible := false;
    butInstall.Visible := true;
    lstUpd.Add(ParamStr(1));
    curUpd := 0;
    if not(loadDUPP(ParamStr(1))) then
      close;
    if not(infosDUPP()) then
      close;
  end;

end;

procedure TfrmInstaller.butInstallClick(Sender: TObject);
begin

  if (isDup5Running()) then
  begin
    writeLog(Install,DLNGstr('PI0012'));
    MessageDlg(DLNGstr('PI0013'),mtError,[mbOk],0);
  end
  else
  begin
    if CurUpd = (lstUpd.Count-1) then
    begin
      cmdCancel.Visible := false;
      cmdClose.Visible := true;
      lineBas.Width := 393;
    end
    else
    begin
      cmdContinue.Visible := true;
    end;

    butInstall.Visible := false;
    panIntro.Visible := false;
    panInstall.Visible := true;
    refresh;

    parseDUPP();
    closeDUPP();
  end;

end;

function TfrmInstaller.infosDUPP_version1(src: integer): boolean;
var cont: boolean;
    Dup5Ver: integer;
    imgTmp: tbitmap;
  //  previewfile: string;
    stmTmp: TMemoryStream;
    Buffer: PByteArray;
begin

  FileRead(src,NFO.NumVer,4);
  FileRead(src,NFO.DUP5VerTest,4);
  FileRead(src,NFO.DUP5VerValue,4);
  FileRead(src,NFO.PictureSize,4);
  FileRead(src,NFO.NumFiles,4);

  PackName := get8(src);
  PackURL := get8(src);
  PackAuthor := get8(src);
  PackComment := get8(src);

  panTitle.Caption := ' '+StringReplace(PackName,'&','&&',[rfReplaceAll]);
  panPVersion.Caption := ' '+getVersionFromInt(NFO.NumVer);
  panAuthor.Caption := ' '+StringReplace(PackAuthor,'&','&&',[rfReplaceAll]);
  panComment.Caption := ' '+StringReplace(PackComment,'&','&&',[rfReplaceAll]);
  panURL.Caption := ' '+PackURL;

  Dup5Ver := getDup5Version;

  cont := (NFO.DUP5VerTest = -1) or
          ((NFO.DUP5VerTest = 0) and (Dup5Ver = NFO.DUP5VerValue)) or
          ((NFO.DUP5VerTest = 1) and (Dup5Ver > NFO.DUP5VerValue)) or
          ((NFO.DUP5VerTest = 2) and (Dup5Ver < NFO.DUP5VerValue)) or
          ((NFO.DUP5VerTest = 3) and (Dup5Ver <> NFO.DUP5VerValue));

  if not(cont) then
  begin
    writelog(Install,DLNGStr('PI0042'));
    colorLog(Install,clRed);
    MessageDlg(DLNGStr('PI0042'),mtError,[mbOk],0);
  end
  else
  begin
    // Gestion de l'image a rajouter.. (Skip atm)
    //FileSeek(src,NFO.PictureSize,1);

    imgCustomBanner.Visible := false;
    if (NFO.PictureSize > 0) then
    begin
//        previewFile := getTempFilename;
      GetMem(Buffer,NFO.PictureSize);
     stmTmp := TMemoryStream.Create;
     try
      try
        FileRead(src,buffer^,NFO.PictureSize);
        stmTmp.Write(Buffer^,NFO.PictureSize);
      finally
        FreeMem(Buffer);
      end;

      imgTmp := TBitMap.Create;
      stmTmp.Seek(0,0);
      imgTmp.LoadFromStream(stmTmp);
      imgCustomBanner.Picture.Assign(imgTmp);
      imgCustomBanner.Visible := true;
     finally
      stmTmp.Free;
     end;
    end;

    NFOLoaded := true;
  end;

  result := cont;

end;

function TfrmInstaller.infosDUPP: boolean;
begin

  writeLog(Install,DLNGStr('PI0063'));

  result := false;

  if (hDupp <> 0) and not(NFOLoaded) then
    case HDR.Version of
      1: result := infosDUPP_version1(hDupp);
      2: result := infosDUPP_version2(hDupp);
      3: result := infosDUPP_version2(hDupp);
      4: result := infosDUPP_version4(hDupp);
    else
      MessageDlg(ReplaceValue('%v',DLNGstr('PI0014'),inttostr(HDR.Version)),mtError, [mbOk],0);
      result := false;
    end;

end;

procedure TfrmInstaller.cmdCancelClick(Sender: TObject);
begin

  if MessageDlg(DLNGstr('PI0011'),mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    Application.Terminate;

end;

procedure TfrmInstaller.cmdURLClick(Sender: TObject);
begin

   ShellExecute(Application.Handle,
                        'OPEN',
                        PChar(PackURL),
                        nil,
                        nil,
                        SW_SHOW);

end;

procedure TfrmInstaller.cmdCloseClick(Sender: TObject);
begin

  Close;

end;

function TfrmInstaller.getPluginVersion(filename: String): integer;
var Handle: THandle;
    DUDIVer: TDUDIVersion;
    DUCIVer: TDUDIVersion;
    DUHIVer: TDUDIVersion;
    GetNumVer: TGetNumVersion;
    GetCnvVer: TGetConvertVersion;
    GetHRVer: TGetHRVersion;
begin

  Handle := LoadLibrary(PChar(filename));

  if Handle <> 0 then
  begin
    @DUDIVer := GetProcAddress(Handle, 'DUDIVersion');
    @DUCIVer := GetProcAddress(Handle, 'DUCIVersion');
    @DUHIVer := GetProcAddress(Handle, 'DUHIVersion');

    if ((@DUDIVer <> Nil) and (DUDIVer >= 1) and (DUDIVer <= 6)) then
    begin

      @GetNumVer := GetProcAddress(Handle, 'GetNumVersion');

      if (@GetNumVer = nil) then
        result := -1
      else
        result := GetNumVer;

    end
    else if ((@DUCIVer <> Nil) and ((DUCIVer = 1) or (DUCIVer = 2) or (DUCIVer = 3))) then
    begin

      @GetCnvVer := GetProcAddress(Handle, 'VersionInfo');

      if (@GetCnvVer = nil) then
        result := -1
      else
        result := GetCnvVer.VerID;

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

function TfrmInstaller.getRawDestDir(i: integer): string;
begin

  case i of
    0: result := 'data\convert\';
    1: result := 'data\';
    2: result := 'data\drivers\';
    3: if HDR.Version = 2 then
         result := 'data\hyperripper\'
       else
         result := '';
    4: result := '';
    5: result := 'utils\';
    6: result := 'utils\templates\';
    7: result := 'utils\translation\';
    8: result := 'utils\data\';
  else
    raise Exception.Create(DLNGStr('PI0045'));
  end;

end;

function TfrmInstaller.getDestDir(i: integer): string;
begin

  try
    result := Dup5Path + getRawDestDir(i);
  except
    on e: exception do
      raise Exception.Create(e.Message);
  end;

end;

procedure TfrmInstaller.translate;
begin

  butInstall.Caption := DLNGstr('BUTINS');
  cmdCancel.Caption := DLNGstr('BUTCAN');
  cmdClose.Caption := DLNGstr('BUTCLO');
  butRefresh.Caption := DLNGstr('BUTREF');
  cmdNext.Caption := DLNGstr('BUTNEX');
  cmdContinue.Caption := DLNGstr('BUTCON');
  strVersion.Caption := DLNGstr('PI0000');
  strTitle.Caption := DLNGstr('PI0001');
  strAuthor.Caption := DLNGstr('PI0002');
  strComment.Caption := DLNGstr('PI0003');
  strURL.Caption := DLNGstr('PI0004');
  grpPackInfos.Caption := DLNGstr('PI0005');
  lblInstalling.Caption := DLNGstr('PI0006');
  lblInstall1.Caption := DLNGstr('PI0007');
  lblInstall2.Caption := DLNGstr('PI0008');
//  strStatus.Caption := DLNGstr('PI0009');
  //lblStatus.Caption := DLNGstr('PI0010');
  strPVersion.Caption := DLNGstr('PI0033');
  lblWhat.Caption := DLNGstr('PI0034');
  lblChoice.Caption := DLNGstr('PI0035');
  optInternet.Caption := DLNGstr('PI0036');
  lblInternetNote.Caption := DLNGstr('PI0037');
  butProxy.Caption := DLNGstr('PI0038');
  butProxy2.Caption := butProxy.Caption;
  optInstall.Caption := DLNGstr('PI0039');
  lstUpdates.Columns.Items[0].Caption := DLNGstr('PII001');
  lstUpdates.Columns.Items[1].Caption := DLNGstr('PII002');
  lstUpdates.Columns.Items[2].Caption := DLNGstr('PII003');
  lstUpdates.Columns.Items[3].Caption := DLNGstr('PII005');
  lstUpdatesUnstable.Columns.Items[0].Caption := DLNGstr('PII001');
  lstUpdatesUnstable.Columns.Items[1].Caption := DLNGstr('PII002');
  lstUpdatesUnstable.Columns.Items[2].Caption := DLNGstr('PII003');
  lstUpdatesUnstable.Columns.Items[3].Caption := DLNGstr('PII005');
  strInternetComment.Caption := DLNGstr('PI0003');
  chkShowUnstable.Caption := DLNGStr('PI0048');

  lstTranslations.Columns.Items[0].Caption := DLNGstr('PII030');
  lstTranslations.Columns.Items[1].Caption := DLNGstr('PII031');
  lstTranslations.Columns.Items[2].Caption := DLNGstr('PII032');
  lstTranslations.Columns.Items[3].Caption := DLNGstr('PII005');

  lblUpdatesTypes.Caption := DLNGstr('PII011');
  lstUpdatesTypes.Items.Strings[0] := DLNGstr('PII012');
  lstUpdatesTypes.Items.Strings[1] := DLNGstr('PII013');
  lblLinkToStable.Caption := DLNGstr('PII021');
  lblLinkToWIP.Caption := DLNGstr('PII022');

end;

procedure TfrmInstaller.cmdNextClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Duppi',True) then
    begin
      Reg.WriteString('InstallPath',txtPathD5P.Text);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  if optInternet.Checked then
  begin
    if (ParamCount = 1) and (lowercase(ParamStr(1)) = '/checktranslations') then
      lstUpdatesTypes.ItemIndex := 1
    else
      lstUpdatesTypes.ItemIndex := 0;
    butDownload.Visible := true;
    cmdNext.Visible := false;
    stepChoice.Visible := false;
    stepInstall.Visible := false;
    stepInternet.Visible := true;
    applyProxyValues;
    imgBanner.Visible := false;
    refresh;
    butRefresh.Click;
  end;

  if optInstall.Checked and (txtPathD5P.Text <> '') then
  begin
    butInstall.Visible := true;
    cmdNext.Visible := false;
    stepChoice.Visible := false;
    stepInstall.Visible := true;
    stepInternet.Visible := false;
    lstUpd.Add(txtPathD5P.Text);
    imgBanner.Visible := true;
    curUpd := 0;
    if not(loadDupp(txtPathD5P.Text)) then
      close
    else if not(infosDupp()) then
      close;
  end;

end;

procedure TfrmInstaller.FormCreate(Sender: TObject);
begin

//  lstInstalled.NodeDataSize := SizeOf(virtualTreeData);

  IdHTTP.Request.UserAgent := 'Duppi/'+getVersionFromInt(VERSION);

  sha1Engine := TDCP_sha1.Create(Self);

  lstUpd := TStringList.Create;

end;

procedure TfrmInstaller.butRefreshClick(Sender: TObject);
Var updList,updUnstableList: TStringList;
    lngList: TStringList;
    itm: TListItem;
    x, tmpVer, servid: integer;
    butDl, butDlUnstable, coreUpdate, duppiUpdate, delFile, noUnstable, dlError: boolean;
    coreMessage, url, tmpFileName, tmpIniFile, testSHA: string;
    errCode, dusURL: string;
    Hash: array[0..19] of byte;
    stmTemp: TFileStream;
begin

  butRefresh.Enabled := false;
  tmpIniFile := getTempFile('.dus');
  butDlUnstable := false;

  // Old URLs:
  // http://dus.dragonunpacker.com/dup5.dus
  // http://www.elberethzone.net/dup5.dus'     // 5.0/5.1 URL DUS v2.0
  // Current URLs:
  dusURL := 'http://update.dragonunpacker.com/dus.php?installedbuild='+inttostr(corebuild)+'&duppiversion='+inttostr(VERSION);
  writeLog(Internet,ReplaceValue('%f',DLNGstr('PII101'),dusURL));

  curDL := 'dus.ini';
  refresh;
  
  stmTemp := TFileStream.Create(tmpIniFile,fmCreate);
  try
    IdHTTP.Get(dusURL,stmTemp);
    dlError := false;
  except
    on e: EIdHTTPProtocolException do
    begin
      writeLog(Internet,ReplaceValue('%d',ReplaceValue('%c',DLNGstr('PII104'),IntToStr(e.ReplyErrorCode)),e.Message));
      colorLog(Internet,clRed);
      dlError := true;
    end;
    on e: exception do
    begin
      writeLog(Internet,'Unhandled: '+e.ClassName +' '+e.Message);
      colorLog(Internet,clRed);
      dlError := true;
    end;
  end;
  stmTemp.Free;

  ButRefresh.Enabled := true;
  butDl := false;

  if dlError then
  begin
    // Do nothing...
  end
  else if IdHTTP.Response.ContentType <> 'text/plain' then
  begin
    writeLog(Internet,'Invalid ContentType: '+IdHTTP.Response.ContentType);
    colorLog(Internet,clRed);
  end
  else if fileexists(tmpIniFile) then
    begin
      dus := TIniFile.Create(tmpIniFile);
      try
        if not(dus.SectionExists('ID')) then
        begin
          writeLog(Internet,DLNGStr('PI0044'));
        end
        else
          if not(dus.ValueExists('ID','DUS')) then
          begin
            writeLog(Internet,DLNGStr('PI0044'));
          end
          else
            if (dus.ReadInteger('ID','DUS',0) <> 3) or not(dus.ValueExists('ID','Result')) then
            begin
              writeLog(Internet,DLNGStr('PI0044'));
            end
            else
            begin
              writeLog(Internet,dus.ReadString('ID','Description',DLNGstr('PII105')));
              styleLog(Internet,[fsBold]);

              if (dus.ReadString('ID','Result','ERR') <> 'OK') then
              begin
                errCode := dus.ReadString('ID','Result','ERR');

                if errCode = 'M01' then
                  writeLog(Internet,DLNGStr('PIEM01'))
                else if errCode = 'M02' then
                  writeLog(Internet,DLNGStr('PIEM01'))
                else if errCode = 'M10' then
                  writeLog(Internet,DLNGStr('PIEM10'))
                else if errCode = 'M11' then
                  writeLog(Internet,DLNGStr('PIEM11'))
                else if errCode = 'M12' then
                  writeLog(Internet,DLNGStr('PIEM12'))
                else if errCode = 'M20' then
                  writeLog(Internet,DLNGStr('PIEM20'))
                else if errCode = 'M30' then
                  writeLog(Internet,DLNGStr('PIEM30'))
                else if errCode = 'M31' then
                  writeLog(Internet,DLNGStr('PIEM31'))
                else if errCode = 'M32' then
                  writeLog(Internet,DLNGStr('PIEM32'))
                else if errCode = 'M33' then
                  writeLog(Internet,DLNGStr('PIEM33'))
                else if errCode = 'M40' then
                  writeLog(Internet,DLNGStr('PIEM40'))
                else if errCode = 'M41' then
                  writeLog(Internet,DLNGStr('PIEM41'))
                else if errCode = 'M42' then
                  writeLog(Internet,DLNGStr('PIEM42'))
                else if errCode = 'M43' then
                  writeLog(Internet,DLNGStr('PIEM43'))
                else if errCode = 'M60' then
                  writeLog(Internet,DLNGStr('PIEM60'))
                else if errCode = 'P01' then
                  writeLog(Internet,DLNGStr('PIEP01'))
                else if errCode = 'P02' then
                  writeLog(Internet,DLNGStr('PIEP02'))
                else
                  writeLog(Internet,ReplaceValue('%e',DLNGStr('PIEUNK'),errCode));

                colorLog(Internet,clRed);
              end;

              updList := splitStr(trim(dus.ReadString('ID','Updates','')),' ');
              updUnstableList := splitStr(trim(dus.ReadString('ID','UpdatesUnstable','')),' ');
              lngList := splitStr(dus.ReadString('ID','Translations',''),' ');
              writeLog(Internet,ReplaceValue('%t',ReplaceValue('%p',DLNGStr('PII108'),inttostr(updList.Count)+'['+inttostr(updUnstableList.Count)+']'),inttostr(lngList.Count)));
              lstUpdates.Clear;
              lstUpdatesUnstable.Clear;
              lstTranslations.Clear;
              coreUpdate := false;

              for x:=0 to updList.Count -1 do
              begin

                if (dus.ReadBool(updList.Strings[x],'AutoUpdate',true)) then
                begin
                  itm := lstUpdates.Items.Add;
                  itm.Caption := dus.ReadString(updList.Strings[x],'Description',DLNGstr('PII106'));
                  tmpVer := getPluginVersion(Dup5Path+dus.ReadString(updList.Strings[x],'File',''));
                  itm.SubItems.Add(getVersionFromInt(tmpVer));
                  if tmpVer < dus.ReadInteger(updList.Strings[x],'Version',0) then
                  begin
                    itm.Checked := true;
                    butDl := true;
                  end;
                  itm.SubItems.Add(dus.ReadString(updList.Strings[x],'VersionDisp',''));
                  itm.SubItems.Add(inttostr(dus.ReadInteger(updList.Strings[x],'Size',0)));
                  if CurLanguage = '*' then
                    itm.SubItems.Add(dus.ReadString(updList.Strings[x],'CommentFR',''))
                  else
                    itm.SubItems.Add(dus.ReadString(updList.Strings[x],'Comment',''));
                  itm.SubItems.Add(updList.Strings[x]);
                end;
              end;

              for x:=0 to updUnstableList.Count -1 do
              begin

                if (dus.ReadBool(updUnstableList.Strings[x],'AutoUpdate',true)) then
                begin
                  itm := lstUpdatesUnstable.Items.Add;
                  itm.Caption := dus.ReadString(updUnstableList.Strings[x],'Description',DLNGstr('PII106'));
                  tmpVer := getPluginVersion(Dup5Path+dus.ReadString(updUnstableList.Strings[x],'File',''));
                  itm.SubItems.Add(getVersionFromInt(tmpVer));
                  if tmpVer < dus.ReadInteger(updUnstableList.Strings[x],'Version',0) then
                  begin
                    itm.Checked := true;
                    butDlUnstable := true;
                  end;
                  itm.SubItems.Add(dus.ReadString(updUnstableList.Strings[x],'VersionDisp',''));
                  itm.SubItems.Add(inttostr(dus.ReadInteger(updUnstableList.Strings[x],'Size',0)));
                  if CurLanguage = '*' then
                    itm.SubItems.Add(dus.ReadString(updUnstableList.Strings[x],'CommentFR',''))
                  else
                    itm.SubItems.Add(dus.ReadString(updUnstableList.Strings[x],'Comment',''));
                  itm.SubItems.Add(updUnstableList.Strings[x]);
                end;
              end;

              noUnstable := true;

              if updUnstableList.Count = updList.Count then
              begin
                for x:=0 to updList.Count -1 do
                   noUnstable := noUnstable and (updUnstableList.IndexOf(updList.Strings[x]) <> -1);
              end;

              FreeAndNil(updList);
              FreeAndNil(updUnstableList);

              chkShowUnstable.Enabled := not(noUnstable);

              for x:=0 to lngList.Count -1 do
              begin

                itm := lstTranslations.Items.Add;
                itm.Caption := dus.ReadString(lngList.Strings[x],'Description',DLNGstr('PII106'));
                itm.SubItems.Add(dus.ReadString(lngList.Strings[x],'Release',''));
                itm.SubItems.Add(dus.ReadString(lngList.Strings[x],'Author',''));
                itm.SubItems.Add(inttostr(dus.ReadInteger(lngList.Strings[x],'Size',0)));
                itm.SubItems.Add(lngList.Strings[x]);

              end;

              FreeAndNil(lngList);

              butDownload.Enabled := (butDL and not(chkShowUnstable.Checked)) or (butDLUnstable and chkShowUnstable.Checked);

              lstUpdatesTypesChange(lstUpdatesTypes);

              if dus.SectionExists('core') then
              begin
                if (dus.ReadInteger('core','Version',0) > coreBuild) then
                begin
                  coreUpdate := true;
                end;
                linkToStable.Caption := dus.ReadString('core','VersionDisp','');
                if curLanguage = '*' then
                  linkToStable.hint := ReplaceValue('%c',coreMessage,dus.ReadString('core','CommentFR','-'))
                else
                  linkToStable.hint := ReplaceValue('%c',coreMessage,dus.ReadString('core','Comment','-'));
                urlToStable := dus.ReadString('core','updateurl','http://sourceforge.net/project/showfiles.php?group_id=108923&package_id=117643&release_id=253827');
                linkToStable.Visible := true;
              end
              else
                linkToStable.Visible := false;

              if dus.SectionExists('corewip') then
              begin
                linkToWIP.Caption := dus.ReadString('corewip','VersionDisp','');
                if curLanguage = '*' then
                  linkToWIP.hint := ReplaceValue('%c',coreMessage,dus.ReadString('corewip','CommentFR','-'))
                else
                  linkToWIP.hint := ReplaceValue('%c',coreMessage,dus.ReadString('corewip','Comment','-'));
                urlToWIP := dus.ReadString('corewip','updateurl','http://sourceforge.net/project/showfiles.php?group_id=108923&package_id=127752&release_id=315908');
                linkToWIP.Visible := true;
              end
              else
                linkToWIP.Visible := false;

              DuppiUpdate := dus.SectionExists('Duppi') and (VERSION < dus.ReadInteger('Duppi','Version',0));

              if DuppiUpdate then
              begin
                coreMessage := ReplaceValue('%s',ReplaceValue('%b',ReplaceValue('%a',DLNGStr('PI0047'),getVersionFromInt(VERSION)),dus.ReadString('Duppi','VersionDisp',GetVersionFromInt(dus.ReadInteger('Duppi','Version',0)))),dus.ReadString('Duppi','Size','???'));
                if (MessageDlg(coreMessage,mtInformation,[mbYes, mbNo],0) = mrYes) then
                begin
                  tmpFile := dup5Path+'Download';
                  if not(DirectoryExists(tmpFile)) then
                    mkdir(tmpfile);
                  for servid := 1 to dus.ReadInteger('ID','NumServers',1) do
                  begin
                    writeLog(Internet,ReplaceValue('%i',ReplaceValue('%d',DLNGStr('PI3001'),dus.ReadString('ID','Server'+inttostr(servid-1),'???')),inttostr(servid)));
                    if servid = 1 then
                      url := dus.ReadString('Duppi','URL','')
                    else
                      url := dus.ReadString('Duppi','URL'+inttostr(servid-1),'');
                    if url = '' then
                      raise Exception.Create(DLNGstr('PI0049'));
                    tmpFileName := dus.ReadString('Duppi','FileDL',extractfilename(getTempFile(extractfileext(url))));
                    tmpFile := dup5Path+'Download\'+tmpFileName;
                    CurDL := tmpFileName;
                    CurDLSize := dus.ReadInteger('Duppi','RealSize',1);
                    progressDL.Position := 0;
                    progressDL.Max := 100;
                    WriteLog(Internet,ReplaceValue('%f',DLNGstr('PII101'),curDL));
                    stmTemp := TFileStream.Create(tmpFile,fmCreate);
                    try
                      IdHTTP.Get(url,stmTemp);
                      dlError := false;
                    except
                      on e: EIdHTTPProtocolException do
                      begin
                        writeLog(Internet,ReplaceValue('%d',ReplaceValue('%c',DLNGstr('PII104'),IntToStr(e.ReplyErrorCode)),e.Message));
                        colorLog(Internet,clRed);
                        dlError := true;
                      end;
                      on e: exception do
                      begin
                        writeLog(Internet,'Unhandled: '+e.ClassName +' '+e.Message);
                        colorLog(Internet,clRed);
                        dlError := true;
                      end;
                    end;
                    stmTemp.Free;
                    if dlError then
                    begin
                      // Do nothing
                    end
                    else if dus.ValueExists('Duppi','Realsize') and (GetFileSize(tmpFile) <> CurDLSize) then
                    begin
                      writeLog(Internet,ReplaceValue('%a',ReplaceValue('%b',DLNGstr('PI3002'),IntToStr(GetFileSize(tmpFile))),IntTostr(CurDLSize)));
                      colorLog(Internet,clRed);
                    end
                    else
                    begin
                      try
                        if dus.ValueExists('Duppi','Hash') then
                        begin
                          writeLog(Internet,DLNGStr('PI3003'));
                          stmTemp := TFileStream.Create(tmpFile,fmOpenRead);
                          sha1Engine.Init;
                          stmTemp.Seek(0,0);
                          sha1Engine.UpdateStream(stmTemp,curDLSize);
                          stmTemp.Free;
                          sha1Engine.Final(Hash);
                          testSHA := '';
                          for x := 0 to 19 do
                            testSHA := testSHA + LowerCase(inttohex(Hash[x],2));
                        end;
                        if dus.ValueExists('Duppi','Hash') and (testSHA <> dus.ReadString('Duppi','Hash','')) then
                        begin
                          writeLog(Internet,ReplaceValue('%a',ReplaceValue('%b',DLNGstr('PI3004'),testSHA),dus.ReadString('Duppi','Hash','')));
                          colorLog(Internet,clRed);
                        end
                        else
                        begin
                          lstUpd.Add(tmpFile);
                          butDownload.Click;
                          exit;
                        end;
                      except
                        on e: Exception do
                        begin
                          writeLog(Internet,ReplaceValue('%b',ReplaceValue('%a',DLNGstr('PI3004'),e.ClassName),e.Message));
                          colorLog(Internet,clRed);
                        end;
                      end;
                    end;
                  end;
                end;
              end;

              if (CoreUpdate) then
              begin
                coreMessage := ReplaceValue('%s',ReplaceValue('%v',ReplaceValue('%c',DLNGStr('PI0050'),'-'),dus.ReadString('core','VersionDisp',GetVersionFromInt(dus.ReadInteger('core','Version',0)))),dus.ReadString('core','PackageSize','???'));
                if dus.ValueExists('core','PackageURL') and (MessageDlg(coreMessage,mtInformation,[mbYes, mbNo],0) = mrYes) then
                begin
                  tmpFile := dup5Path+'Download';
                  if not(DirectoryExists(tmpFile)) then
                    mkdir(tmpfile);
                  for servid := 1 to dus.ReadInteger('ID','NumServers',1) do
                  begin
                    writeLog(Internet,ReplaceValue('%i',ReplaceValue('%d',DLNGStr('PI3001'),dus.ReadString('ID','Server'+inttostr(servid-1),'???')),inttostr(servid)));
                    if servid = 1 then
                      url := dus.ReadString('core','PackageURL','')
                    else
                      url := dus.ReadString('core','PackageURL'+inttostr(servid-1),'');
                    if url = '' then
                      raise Exception.Create(DLNGstr('PI0051'));
                    tmpFileName := dus.ReadString('core','PackageFileDL',extractfilename(getTempFile(extractfileext(url))));
                    tmpFile := dup5Path+'Download\'+tmpFileName;
                    CurDL := tmpFileName;
                    CurDLSize := dus.ReadInteger('core','RealSize',1);
                    progressDL.Position := 0;
                    progressDL.Max := 100;
                    WriteLog(Internet,ReplaceValue('%f',DLNGstr('PII101'),curDL));
                    stmTemp := TFileStream.Create(tmpFile,fmCreate);
                    try
                      IdHTTP.Get(url,stmTemp);
                      dlError := false;
                    except
                      on e: EIdHTTPProtocolException do
                      begin
                        writeLog(Internet,ReplaceValue('%d',ReplaceValue('%c',DLNGstr('PII104'),IntToStr(e.ReplyErrorCode)),e.Message));
                        colorLog(Internet,clRed);
                        dlError := true;
                      end;
                      on e: exception do
                      begin
                        writeLog(Internet,'Unhandled: '+e.ClassName +' '+e.Message);
                        colorLog(Internet,clRed);
                        dlError := true;
                      end;
                    end;
                    stmTemp.Free;
                    if dlError then
                    begin
                      // Do nothing
                    end
                    else if dus.ValueExists('core','Realsize') and (GetFileSize(tmpFile) <> CurDLSize) then
                    begin
                      writeLog(Internet,ReplaceValue('%a',ReplaceValue('%b',DLNGstr('PI3002'),IntToStr(GetFileSize(tmpFile))),IntTostr(CurDLSize)));
                      colorLog(Internet,clRed);
                    end
                    else
                    begin
                      try
                        if dus.ValueExists('core','Hash') then
                        begin
                          writeLog(Internet,DLNGStr('PI3003'));
                          stmTemp := TFileStream.Create(tmpFile,fmOpenRead);
                          sha1Engine.Init;
                          stmTemp.Seek(0,0);
                          sha1Engine.UpdateStream(stmTemp,curDLSize);
                          stmTemp.Free;
                          sha1Engine.Final(Hash);
                          testSHA := '';
                          for x := 0 to 19 do
                            testSHA := testSHA + LowerCase(inttohex(Hash[x],2));
                        end;
                        if dus.ValueExists('core','Hash') and (testSHA <> dus.ReadString('core','Hash','')) then
                        begin
                          writeLog(Internet,ReplaceValue('%a',ReplaceValue('%b',DLNGstr('PI3004'),testSHA),dus.ReadString('core','Hash','')));
                          colorLog(Internet,clRed);
                        end
                        else
                        begin
                          lstUpd.Add(tmpFile);
                          butDownload.Click;
                          exit;
                        end;
                      except
                        on e: Exception do
                        begin
                          writeLog(Internet,ReplaceValue('%b',ReplaceValue('%a',DLNGstr('PI3004'),e.ClassName),e.Message));
                          colorLog(Internet,clRed);
                        end;
                      end;
                    end;

                  end;

                  url := dus.ReadString('core','PackageURL','');
                  if url = '' then
                    raise Exception.Create(DLNGstr('PI0051'));
                  tmpFileName := dus.ReadString('core','PackageFileDL',extractfilename(getTempFile(extractfileext(url))));
                  tmpFile := dup5Path+'Download\'+tmpFileName;
                  CurDL := tmpFileName;
                  CurDLSize := dus.ReadInteger('core','PackageSize',1)*1024;
                  inc(curDLSize);
                  progressDL.Position := 0;
                  progressDL.Max := 100;
                  WriteLog(Internet,ReplaceValue('%f',DLNGstr('PII101'),curDL));
                  stmTemp := TFileStream.Create(tmpFile,fmCreate);
                  try
                    IdHTTP.Get(url,stmTemp);
                    dlError := false;
                  except
                    on e: EIdHTTPProtocolException do
                    begin
                      writeLog(Internet,ReplaceValue('%d',ReplaceValue('%c',DLNGstr('PII104'),IntToStr(e.ReplyErrorCode)),e.Message));
                      colorLog(Internet,clRed);
                      dlError := true;
                    end;
                    on e: exception do
                    begin
                      writeLog(Internet,'Unhandled: '+e.ClassName +' '+e.Message);
                      colorLog(Internet,clRed);
                      dlError := true;
                    end;
                  end;
                  stmTemp.Free;
                  if not(dlError) then
                    lstUpd.Add(tmpFile);

                  butDownload.Click;
                  exit;
                end
                else
                begin
                  coreMessage := ReplaceValue('%v',DLNGstr('PII107'),dus.ReadString('core','VersionDisp','-'));
                  if curLanguage = '*' then
                    coreMessage := ReplaceValue('%c',coreMessage,dus.ReadString('core','CommentFR','-'))
                  else
                    coreMessage := ReplaceValue('%c',coreMessage,dus.ReadString('core','Comment','-'));
                  if (MessageDlg(coreMessage,mtInformation,[mbYes, mbNo],0) = mrYes) then
                  begin
                    ShellExecute(Application.Handle,
                               'OPEN',
                               PChar(dus.ReadString('core','UpdateURL','http://www.dragonunpacker.com')),
                               nil,
                               nil,
                               SW_SHOW);
                    close;
                  end;
                end;
              end;
            end;
     finally
        //dus.free;
        //if FileExists(tmpIniFile) then
        //  DeleteFile(tmpIniFile);
      end;
    end;


end;

function TfrmInstaller.getTempFile(ext: string): string;
var TempDir: array[0..MAX_PATH] of Char;
begin

  { find our Windows temp directory }
  GetTempPath(MAX_PATH, @TempDir);

  Randomize;

  result := Strip0(TempDir)+'dup5dus-'+IntToStr(Random(99999999))+ext;

end;

procedure TfrmInstaller.FormDestroy(Sender: TObject);
begin

  FreeAndNil(lstUpd);

  FreeAndNil(sha1Engine);

  if (dus <> Nil) then
    FreeAndNil(dus);

  if FileExists(tmpFile) then
    DeleteFile(tmpFile);

end;

procedure TfrmInstaller.lstUpdatesClick(Sender: TObject);
var x: integer;
    res: boolean;
begin

  res := false;
  x:=0;
  while (x < lstUpdates.Items.Count) and not(res) do
  begin
    res := lstUpdates.Items.Item[x].Checked;
    inc(x);
  end;
  x:=0;
  while (x < lstTranslations.Items.Count) and not(res) do
  begin
    res := lstTranslations.Items.Item[x].Checked;
    inc(x);
  end;

  butDownload.Enabled := res;

end;

procedure TfrmInstaller.butDownloadClick(Sender: TObject);
var x, y, servid : integer;
    url, tmpfile, tmpFileName, testSHA : string;
    delFile, dlError : boolean;
    stmTemp : TFileStream;
    hash: array[0..19] of byte;
begin

  tmpFile := dup5Path+'Download';
  if not(DirectoryExists(tmpFile)) then
    mkdir(tmpfile);

  lstUpdates.Enabled := false;
  butDownload.Enabled := false;
  butRefresh.Enabled := false;
  butProxy2.Enabled := false;

  if lstUpd.Count = 0 then
  begin

    if not(chkShowUnstable.Checked) then
    begin
      for x := 0 to lstUpdates.Items.Count-1 do
      begin
        if lstUpdates.Items.Item[x].Checked then
        begin

          for servid := 1 to dus.ReadInteger('ID','NumServers',1) do
          begin
            if ((servid = 1) and dus.ValueExists(lstUpdates.Items.Item[x].SubItems[4],'URL'))
            or ((servid <> 1) and dus.ValueExists(lstUpdates.Items.Item[x].SubItems[4],'URL'+inttostr(servid-1))) then
            begin
              writeLog(Internet,ReplaceValue('%i',ReplaceValue('%d',DLNGStr('PI3001'),dus.ReadString('ID','Server'+inttostr(servid-1),'???')),inttostr(servid)));
              if servid = 1 then
                url := dus.ReadString(lstUpdates.Items.Item[x].SubItems[4],'URL','')
              else
                url := dus.ReadString(lstUpdates.Items.Item[x].SubItems[4],'URL'+inttostr(servid-1),'');
              tmpFileName := dus.ReadString(lstUpdates.Items.Item[x].SubItems[4],'FileDL',getTempFile(getTempFile(extractfileext(url))));
              tmpFile := dup5Path+'Download\'+tmpFileName;
              CurDL := tmpFileName;
              CurDLSize := dus.ReadInteger(lstUpdates.Items.Item[x].SubItems[4],'RealSize',1);
              progressDL.Position := 0;
              progressDL.Max := 100;
              WriteLog(Internet,ReplaceValue('%f',DLNGstr('PII101'),curDL));
              stmTemp := TFileStream.Create(tmpFile,fmCreate);
              dlError := false;
              try
                IdHTTP.Get(url,stmTemp);
              except
                on e: EIdHTTPProtocolException do
                begin
                  writeLog(Internet,ReplaceValue('%d',ReplaceValue('%c',DLNGstr('PII104'),IntToStr(e.ReplyErrorCode)),e.Message));
                  colorLog(Internet,clRed);
                  dlError := true;
                end;
                on e: exception do
                begin
                  writeLog(Internet,'Unhandled: '+e.ClassName +' '+e.Message);
                  colorLog(Internet,clRed);
                  dlError := true;
                end;
              end;
              stmTemp.Free;
              DelFile := False;
              if dlError then
                DelFile := true
              else if dus.ValueExists(lstUpdates.Items.Item[x].SubItems[4],'Realsize') and (GetFileSize(tmpFile) <> CurDLSize) then
              begin
                writeLog(Internet,ReplaceValue('%a',ReplaceValue('%b',DLNGstr('PI3002'),IntToStr(GetFileSize(tmpFile))),IntTostr(CurDLSize)));
                colorLog(Internet,clRed);
                DelFile := true;
              end
              else
              begin
                try
                  if dus.ValueExists(lstUpdates.Items.Item[x].SubItems[4],'Hash') then
                  begin
                    writeLog(Internet,DLNGStr('PI3003'));
                    stmTemp := TFileStream.Create(tmpFile,fmOpenRead);
                    sha1Engine.Init;
                    stmTemp.Seek(0,0);
                    sha1Engine.UpdateStream(stmTemp,curDLSize);
                    stmTemp.Free;
                    sha1Engine.Final(Hash);
                    testSHA := '';
                    for y := 0 to 19 do
                      testSHA := testSHA + LowerCase(inttohex(Hash[y],2));
                  end;
                  if dus.ValueExists(lstUpdates.Items.Item[x].SubItems[4],'Hash') and (testSHA <> dus.ReadString(lstUpdates.Items.Item[x].SubItems[4],'Hash','')) then
                  begin
                    writeLog(Internet,ReplaceValue('%a',ReplaceValue('%b',DLNGstr('PI3004'),testSHA),dus.ReadString(lstUpdates.Items.Item[x].SubItems[4],'Hash','')));
                    colorLog(Internet,clRed);
                    DelFile := true;
                  end
                  else
                  begin
                    lstUpd.Add(tmpFile);
                    break;
                  end;
                except
                  on e: Exception do
                  begin
                    writeLog(Internet,ReplaceValue('%b',ReplaceValue('%a',DLNGstr('PI3004'),e.ClassName),e.Message));
                    colorLog(Internet,clRed);
                    DelFile := true;
                  end;
                end;
              end; 
              if DelFile and FileExists(tmpFile) then
                DeleteFile(tmpFile);
            end;
          end;
          ButDownload.Visible := true;
        end;
      end;
    end
    else
    begin
      for x := 0 to lstUpdatesUnstable.Items.Count-1 do
      begin
        if lstUpdatesUnstable.Items.Item[x].Checked then
        begin
          for servid := 1 to dus.ReadInteger('ID','NumServers',1) do
          begin
            if ((servid = 1) and dus.ValueExists(lstUpdatesUnstable.Items.Item[x].SubItems[4],'URL'))
            or ((servid <> 1) and dus.ValueExists(lstUpdatesUnstable.Items.Item[x].SubItems[4],'URL'+inttostr(servid-1))) then
            begin
              writeLog(Internet,ReplaceValue('%i',ReplaceValue('%d',DLNGStr('PI3001'),dus.ReadString('ID','Server'+inttostr(servid-1),'???')),inttostr(servid)));
              if servid = 1 then
                url := dus.ReadString(lstUpdatesUnstable.Items.Item[x].SubItems[4],'URL','')
              else
                url := dus.ReadString(lstUpdatesUnstable.Items.Item[x].SubItems[4],'URL'+inttostr(servid-1),'');
              tmpFileName := dus.ReadString(lstUpdatesUnstable.Items.Item[x].SubItems[4],'FileDL',getTempFile(getTempFile(extractfileext(url))));
              tmpFile := dup5Path+'Download\'+tmpFileName;
              CurDL := tmpFileName;
              CurDLSize := dus.ReadInteger(lstUpdatesUnstable.Items.Item[x].SubItems[4],'RealSize',1);
              progressDL.Position := 0;
              progressDL.Max := 100;
              WriteLog(Internet,ReplaceValue('%f',DLNGstr('PII101'),curDL));
              stmTemp := TFileStream.Create(tmpFile,fmCreate);
              dlError := false;
              try
                IdHTTP.Get(url,stmTemp);
              except
                on e: EIdHTTPProtocolException do
                begin
                  writeLog(Internet,ReplaceValue('%d',ReplaceValue('%c',DLNGstr('PII104'),IntToStr(e.ReplyErrorCode)),e.Message));
                  colorLog(Internet,clRed);
                  dlError := true;
                end;
                on e: exception do
                begin
                  writeLog(Internet,'Unhandled: '+e.ClassName +' '+e.Message);
                  colorLog(Internet,clRed);
                  dlError := true;
                end;
              end;
              stmTemp.Free;
              if dlError then
                DelFile := true
              else if dus.ValueExists(lstUpdatesUnstable.Items.Item[x].SubItems[4],'Realsize') and (GetFileSize(tmpFile) <> CurDLSize) then
              begin
                writeLog(Internet,ReplaceValue('%a',ReplaceValue('%b',DLNGstr('PI3002'),IntToStr(GetFileSize(tmpFile))),IntTostr(CurDLSize)));
                colorLog(Internet,clRed);
                DelFile := true;
              end
              else
              begin
                DelFile := false;
                try
                  if dus.ValueExists(lstUpdatesUnstable.Items.Item[x].SubItems[4],'Hash') then
                  begin
                    writeLog(Internet,DLNGStr('PI3003'));
                    stmTemp := TFileStream.Create(tmpFile,fmOpenRead);
                    sha1Engine.Init;
                    stmTemp.Seek(0,0);
                    sha1Engine.UpdateStream(stmTemp,curDLSize);
                    stmTemp.Free;
                    sha1Engine.Final(Hash);
                    testSHA := '';
                    for y := 0 to 19 do
                      testSHA := testSHA + LowerCase(inttohex(Hash[y],2));
                  end;
                  if dus.ValueExists(lstUpdatesUnstable.Items.Item[x].SubItems[4],'Hash') and (testSHA <> dus.ReadString(lstUpdatesUnstable.Items.Item[x].SubItems[4],'Hash','')) then
                  begin
                    writeLog(Internet,ReplaceValue('%a',ReplaceValue('%b',DLNGstr('PI3004'),testSHA),dus.ReadString(lstUpdatesUnstable.Items.Item[x].SubItems[4],'Hash','')));
                    colorLog(Internet,clRed);
                    DelFile := true;
                  end
                  else
                  begin
                    lstUpd.Add(tmpFile);
                    break;
                  end;
                except
                  on e: Exception do
                  begin
                    writeLog(Internet,ReplaceValue('%b',ReplaceValue('%a',DLNGstr('PI3004'),e.ClassName),e.Message));
                    colorLog(Internet,clRed);
                    DelFile := true;
                  end;
                end;
              end;
              if DelFile and FileExists(tmpFile) then
                DeleteFile(tmpFile);
            end;
          end;
          ButDownload.Visible := true;
        end;
      end;
    end;

    for x := 0 to lstTranslations.Items.Count-1 do
    begin
      if lstTranslations.Items.Item[x].Checked then
      begin
        for servid := 1 to dus.ReadInteger('ID','NumServers',1) do
        begin
          if ((servid = 1) and dus.ValueExists(lstTranslations.Items.Item[x].SubItems[3],'URL'))
          or ((servid <> 1) and dus.ValueExists(lstTranslations.Items.Item[x].SubItems[3],'URL'+inttostr(servid-1))) then
          begin
            writeLog(Internet,ReplaceValue('%i',ReplaceValue('%d',DLNGStr('PI3001'),dus.ReadString('ID','Server'+inttostr(servid-1),'???')),inttostr(servid)));
            if servid = 1 then
              url := dus.ReadString(lstTranslations.Items.Item[x].SubItems[3],'URL','')
            else
              url := dus.ReadString(lstTranslations.Items.Item[x].SubItems[3],'URL'+inttostr(servid-1),'');
            tmpFileName := dus.ReadString(lstTranslations.Items.Item[x].SubItems[3],'FileDL',getTempFile(getTempFile(extractfileext(url))));
            tmpFile := dup5Path+'Download\'+tmpFileName;
            CurDL := tmpFileName;
            CurDLSize := dus.ReadInteger(lstTranslations.Items.Item[x].SubItems[3],'RealSize',1);
            progressDL.Position := 0;
            progressDL.Max := 100;
            WriteLog(Internet,ReplaceValue('%f',DLNGstr('PII101'),curDL));
            stmTemp := TFileStream.Create(tmpFile,fmCreate);
            dlError := false;
            try
              IdHTTP.Get(url,stmTemp);
            except
              on e: EIdHTTPProtocolException do
              begin
                writeLog(Internet,ReplaceValue('%d',ReplaceValue('%c',DLNGstr('PII104'),IntToStr(e.ReplyErrorCode)),e.Message));
                colorLog(Internet,clRed);
                dlError := true;
              end;
              on e: exception do
              begin
                writeLog(Internet,'Unhandled: '+e.ClassName +' '+e.Message);
                colorLog(Internet,clRed);
                dlError := true;
              end;
            end;
            stmTemp.Free;
            if dlError then
              DelFile := true
            else if dus.ValueExists(lstTranslations.Items.Item[x].SubItems[3],'Realsize') and (GetFileSize(tmpFile) <> CurDLSize) then
            begin
              writeLog(Internet,ReplaceValue('%a',ReplaceValue('%b',DLNGstr('PI3002'),IntToStr(GetFileSize(tmpFile))),IntTostr(CurDLSize)));
              colorLog(Internet,clRed);
              DelFile := true;
            end
            else
            begin
              try
                if dus.ValueExists(lstTranslations.Items.Item[x].SubItems[3],'Hash') then
                begin
                  writeLog(Internet,DLNGStr('PI3003'));
                  stmTemp := TFileStream.Create(tmpFile,fmOpenRead);
                  sha1Engine.Init;
                  stmTemp.Seek(0,0);
                  sha1Engine.UpdateStream(stmTemp,curDLSize);
                  stmTemp.Free;
                  sha1Engine.Final(Hash);
                  testSHA := '';
                  for y := 0 to 19 do
                    testSHA := testSHA + LowerCase(inttohex(Hash[y],2));
                end;
                if dus.ValueExists(lstTranslations.Items.Item[x].SubItems[3],'Hash') and (testSHA <> dus.ReadString(lstTranslations.Items.Item[x].SubItems[3],'Hash','')) then
                begin
                  writeLog(Internet,ReplaceValue('%a',ReplaceValue('%b',DLNGstr('PI3004'),testSHA),dus.ReadString(lstTranslations.Items.Item[x].SubItems[3],'Hash','')));
                  colorLog(Internet,clRed);
                  DelFile := true;
                end
                else
                begin
                  lstUpd.Add(tmpFile);
                  break;
                end;
              except
                on e: Exception do
                begin
                  writeLog(Internet,ReplaceValue('%b',ReplaceValue('%a',DLNGstr('PI3004'),e.ClassName),e.Message));
                  colorLog(Internet,clRed);
                  DelFile := true;
                end;
              end;
            end;
            if DelFile and FileExists(tmpFile) then
              DeleteFile(tmpFile);
          end;
        end;
        ButDownload.Visible := true;
      end;
    end;
  end;

  curUpd := 0;

  if lstUpd.Count = 0 then
  begin
    MessageDlg(DLNGstr('PII200'),mtError, [mbOk], 0);
    close;
  end
  else
  begin
    butInstall.Visible := true;
    butDownload.Visible := false;
    stepInternet.Visible := false;
    stepInstall.Visible := true;
    imgBanner.Visible := true;

    if loadDupp(lstUpd.Strings[curUpd]) then
      if not(infosDupp()) then
      begin
        if CurUpd = (lstUpd.Count-1) then
        begin
          cmdCancel.Visible := false;
          cmdClose.Visible := true;
          lineBas.Width := 393;
        end
        else
        begin
          cmdContinue.Visible := true;
        end;

        butInstall.Visible := false;
        panIntro.Visible := false;
        panInstall.Visible := true;
        refresh;

        closeDUPP();
      end;
  end;

end;

procedure TfrmInstaller.cmdContinueClick(Sender: TObject);
begin

  inc(CurUpd);

  cmdContinue.Visible := false;
  butInstall.Visible := true;
  panIntro.Visible := true;
  panInstall.Visible := false;
  imgBanner.Visible := true;

  translate;

  writelog(Install,'Package ['+inttostr(CurUpd)+'/'+inttostr(lstUpd.Count)+']: '+extractfilename(lstUpd.Strings[curUpd]));

  if loadDupp(lstUpd.Strings[curUpd]) then
    if not(infosDupp()) then
    begin
      if CurUpd = (lstUpd.Count-1) then
      begin
        cmdCancel.Visible := false;
        cmdClose.Visible := true;
        lineBas.Width := 393;
      end
      else
      begin
        cmdContinue.Visible := true;
      end;

      butInstall.Visible := false;
      panIntro.Visible := false;
      panInstall.Visible := true;
      refresh;

      closeDUPP();
    end;

end;

procedure TfrmInstaller.butProxyClick(Sender: TObject);
begin

  optInternet.Checked := true;

  frmProxy.strProxy.Caption := DLNGstr('PIP001');
  frmProxy.strProxyPort.Caption := DLNGstr('PIP002');
  frmProxy.chkUserPass.Caption := DLNGstr('PIP003');
  frmProxy.strProxyUser.Caption := DLNGstr('PIP004');
  frmProxy.strProxyPass.Caption := DLNGstr('PIP005');
  frmProxy.cmdOk.Caption := DLNGstr('BUTOK');

  frmProxy.txtProxy.Text := proxy;
  frmProxy.txtProxyPort.Text := proxyPort;
  frmProxy.txtProxyUser.Text := proxyUser;
  frmProxy.txtProxyPass.Text := proxyPass;
  frmProxy.chkUserPass.Checked := proxyUserPass;

  // Fix for bug #958619
  frmProxy.Caption := DLNGstr('PI0038');

  frmProxy.ShowModal;

  proxy := frmProxy.txtProxy.Text;
  proxyPort := frmProxy.txtProxyPort.Text;
  proxyUser := frmProxy.txtProxyUser.Text;
  proxyPass := frmProxy.txtProxyPass.Text;
  proxyUserPass := frmProxy.chkUserPass.Checked;

  applyProxyValues;

end;

procedure TfrmInstaller.applyProxyValues;
begin

 IdHttp.ProxyParams.ProxyServer := proxy;
 if (proxyPort > '') then
 begin
   try
     IdHttp.ProxyParams.ProxyPort := strtoint(proxyPort);
   except
     IdHttp.ProxyParams.ProxyPort := 8080;
   end;
 end;
 IdHttp.ProxyParams.BasicAuthentication := proxyUserPass;
 if proxyUserPass then
 begin
   IdHttp.ProxyParams.ProxyUsername := proxyuser;
   IdHttp.ProxyParams.ProxyPassword := proxypass;
 end;

end;

procedure TfrmInstaller.cmdBrowseD5PClick(Sender: TObject);
begin

  optInstall.Checked := true;

  OpenDialog.InitialDir := txtPathD5P.Text;

  OpenDialog.Filter := ReplaceValue('%d',DLNGStr('PI0064'),'Dragon UnPACKer 5')+'(*.D5P)|*.d5p';
  OpenDialog.Title := DLNGstr('PI0040');

  if OpenDialog.Execute then
    txtPathD5P.Text := OpenDialog.FileName;


end;

procedure TfrmInstaller.txtPathD5PClick(Sender: TObject);
begin

  optInstall.Checked := true;

end;

procedure TfrmInstaller.lstUpdatesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin

  lblInternetComment.Text := item.SubItems[3];

end;

function TfrmInstaller.getDup5Version: integer;
var Reg: TRegistry;
begin

  result := 0;
  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      if Reg.ValueExists('Build') then
      begin
        result := Reg.ReadInteger('Build');
      end;
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

function TfrmInstaller.ExecAndWait(const ExecuteFile,
  ParamString: string): boolean;
var
  SEInfo: TShellExecuteInfo;
  ExitCode: DWORD;
begin
  FillChar(SEInfo, SizeOf(SEInfo), 0);
  SEInfo.cbSize := SizeOf(TShellExecuteInfo);
  with SEInfo do begin
    fMask := SEE_MASK_NOCLOSEPROCESS;
    Wnd := Application.Handle;
    lpFile := PChar(ExecuteFile);
    lpParameters := PChar(ParamString);
    nShow := SW_HIDE;
  end;
  if ShellExecuteEx(@SEInfo) then
  begin
    repeat
      Application.ProcessMessages;
      GetExitCodeProcess(SEInfo.hProcess, ExitCode);
    until (ExitCode <> STILL_ACTIVE) or Application.Terminated;
    if ExitCode <> 0 then
      Result := False
    else
      Result:=True;
  end
  else Result:=False;
end;

function TfrmInstaller.RegisterOCX(ocxpath: string): boolean;
type
  TRegFunc = function : HResult; stdcall;
var
  ARegFunc : TRegFunc;
  aHandle  : THandle;
begin
 result := false;
 try
  aHandle := LoadLibrary(PChar(ocxPath));
  if aHandle <> 0 then
  begin
    ARegFunc := GetProcAddress(aHandle,'DllRegisterServer');
    if Assigned(ARegFunc) then
    begin
      result := ExecAndWait('regsvr32','/s "' + ocxPath+'"');
    end;
    FreeLibrary(aHandle);
  end;
 except
  MessageDlg(ReplaceValue('%s',DLNGStr('PI0043'),ocxPath),mtWarning,[mbOk],0);
 end;
end;

procedure TfrmInstaller.writeLog(dest: TLogType; text: string);
var logToUse: TRichEdit;
begin

  if dest = Internet then
    logToUse := richLog
  else
    logToUse := richEditInstall;

  if logToUse.Lines.Count = 32760 then
    logToUse.Lines.Delete(0);

  logToUse.Lines.Add(DateTimeToStr(now)+' : '+text);
  logToUse.Perform(EM_LINESCROLL,0,1);

end;

procedure TfrmInstaller.appendLog(dest: TLogType; text: string);
var logToUse: TRichEdit;
begin

  if dest = Internet then
    logToUse := richLog
  else
    logToUse := richEditInstall;

  logToUse.Lines.Strings[logToUse.Lines.Count-1] := logToUse.Lines.Strings[logToUse.Lines.Count-1]+' '+text;

end;


procedure TfrmInstaller.separatorLog(dest: TLogType);
begin

  writelog(dest,StringOfchar('-',80));

end;

procedure TfrmInstaller.styleLog(dest: TLogType; Style: TFontStyles);
var logToUse: TRichEdit;
begin

  if dest = Internet then
    logToUse := richLog
  else
    logToUse := richEditInstall;

  setRichEditLineStyle(logToUse, logToUse.Lines.Count, Style);

end;

procedure TfrmInstaller.colorLog(dest: TLogType; Color: TColor);
var logToUse: TRichEdit;
begin

  if dest = Internet then
    logToUse := richLog
  else
    logToUse := richEditInstall;

  setRichEditLineColor(logToUse, logToUse.Lines.Count, Color);

end;

procedure TfrmInstaller.setRichEditLineStyle(R : TRichEdit; Line : Integer; Style : TFontStyles);
var
 oldPos,
 oldSelLength : Integer;
 Line_Index : Integer;
 To_Line_Index : Integer;
 Line_Range : Integer;
begin
 OldPos := R.SelStart;
 oldSelLength := R.SelLength;
 Try
   Line_Index := R.Perform(EM_LINEINDEX,Line-1,0);
   if Line_Index > - 1 then
   begin
     to_Line_Index := R.Perform(EM_LINEINDEX,Line,0);
     if to_Line_Index < Line_Index then
       Line_Range := Length(R.Text)-Line_Index
     else
       Line_Range := to_Line_Index-Line_Index;
     R.SelStart := Line_Index;
     R.SelLength := Line_Range;
     R.SelAttributes.Style := Style;
   end;
 finally
   R.SelStart := OldPos;
   R.SelLength := oldSelLength;
 end;
end;

procedure TfrmInstaller.setRichEditLineColor(R : TRichEdit; Line : Integer; Color : TColor);
var
 oldPos,
 oldSelLength : Integer;
 Line_Index : Integer;
 To_Line_Index : Integer;
 Line_Range : Integer;
begin
 OldPos := R.SelStart;
 oldSelLength := R.SelLength;
 Try
   Line_Index := R.Perform(EM_LINEINDEX,Line-1,0);
   if Line_Index > - 1 then
   begin
     to_Line_Index := R.Perform(EM_LINEINDEX,Line,0);
     if to_Line_Index < Line_Index then
       Line_Range := Length(R.Text)-Line_Index
     else
       Line_Range := to_Line_Index-Line_Index;
     R.SelStart := Line_Index;
     R.SelLength := Line_Range;
     R.SelAttributes.Color := Color;
   end;
 finally
   R.SelStart := OldPos;
   R.SelLength := oldSelLength;
 end;
end;

function TfrmInstaller.infosDUPP_version2(src: integer): boolean;
var cont: boolean;
    Dup5Ver: integer;
    imgTmp: tbitmap;
    stmTmp: TMemoryStream;
    InputStream: TMemoryStream;
    DStream: TDecompressionStream;
    Buffer: PByteArray;
begin

  FileRead(src,NFO.NumVer,4);
  FileRead(src,NFO.DUP5VerTest,4);
  FileRead(src,NFO.DUP5VerValue,4);
  FileRead(src,NFO.PictureSize,4);
  FileRead(src,NFO.NumFiles,4);

  FileRead(src,NFO1,SizeOf(DUP5PACK_Info_v1));
  
  PackName := get8(src);
  PackURL := get8(src);
  PackAuthor := get8(src);
  PackComment := get8(src);

  panTitle.Caption := ' '+StringReplace(PackName,'&','&&',[rfReplaceAll]);
  panPVersion.Caption := ' '+getVersionFromInt(NFO.NumVer);
  panAuthor.Caption := ' '+StringReplace(PackAuthor,'&','&&',[rfReplaceAll]);
  panComment.Caption := ' '+StringReplace(PackComment,'&','&&',[rfReplaceAll]);
  panURL.Caption := ' '+PackURL;

  Dup5Ver := getDup5Version;

  cont := (NFO.DUP5VerTest = -1) or
          ((NFO.DUP5VerTest = 0) and (Dup5Ver = NFO.DUP5VerValue)) or
          ((NFO.DUP5VerTest = 1) and (Dup5Ver > NFO.DUP5VerValue)) or
          ((NFO.DUP5VerTest = 2) and (Dup5Ver < NFO.DUP5VerValue)) or
          ((NFO.DUP5VerTest = 3) and (Dup5Ver <> NFO.DUP5VerValue));

  if not(cont) then
  begin
    writelog(Install,DLNGStr('PI0042'));
    colorlog(Install,clRed);
    MessageDlg(DLNGStr('PI0042'),mtError,[mbOk],0);
//    ShowMessage('This package cannot be installed with your version of Dragon UnPACKer.');
  end
  else
  begin
    // Gestion de l'image a rajouter.. (Skip atm)
    //FileSeek(src,NFO.PictureSize,1);

    imgCustomBanner.Visible := false;
    if (NFO.PictureSize > 0) then
    begin
//        previewFile := getTempFilename;
      stmTmp := TMemoryStream.Create;

      try

       if (NFO.NumVer = 1) and (NFO1.PictureCompressed = 1) then
       begin

        GetMem(Buffer,NFO1.PictureCompressedSize);
        try
          FileRead(src,Buffer^,NFO1.PictureCompressedSize);

          InputStream := TMemoryStream.Create;
          try
            InputStream.Write(Buffer^,NFO1.PictureCompressedSize);
            InputStream.Seek(0, soFromBeginning);

            DStream := TDecompressionStream.Create(InputStream);
            try
              stmTmp.CopyFrom(DStream,NFO.PictureSize);
            finally
              DStream.Free;
            end;
          finally
            InputStream.Free;
          end;
        finally
          FreeMem(Buffer);
        end;

       end
       else
       begin

        GetMem(Buffer,NFO.PictureSize);
        stmTmp := TMemoryStream.Create;

        try
          FileRead(src,buffer^,NFO.PictureSize);
          stmTmp.Write(Buffer^,NFO.PictureSize);
        finally
          FreeMem(Buffer);
        end;

      end;

      imgTmp := TBitMap.Create;
      stmTmp.Seek(0,0);
      imgTmp.LoadFromStream(stmTmp);
      imgCustomBanner.Picture.Assign(imgTmp);
      imgCustomBanner.Visible := true;

     finally
      stmTmp.Free;
     end;

    end;

    NFOLoaded := true;
  end;

  result := cont;

end;

procedure TfrmInstaller.linkToStableMouseEnter(Sender: TObject);
begin

  linkToStable.Font.Style := [fsUnderline];

end;

procedure TfrmInstaller.linkToStableMouseLeave(Sender: TObject);
begin

  linkToStable.Font.Style := []

end;

procedure TfrmInstaller.linkToWIPMouseEnter(Sender: TObject);
begin

  linkToWIP.Font.Style := [fsUnderline];

end;

procedure TfrmInstaller.linkToWIPMouseLeave(Sender: TObject);
begin

  linkToWIP.Font.Style := [];

end;

procedure TfrmInstaller.linkToStableClick(Sender: TObject);
begin

   ShellExecute(Application.Handle,
                        'OPEN',
                        PChar(urlToStable),
                        nil,
                        nil,
                        SW_SHOW);

end;

procedure TfrmInstaller.lstUpdatesTypesChange(Sender: TObject);
begin

  if lstUpdatesTypes.ItemIndex = 0 then
  begin
    if chkShowUnstable.Checked then
    begin
      lstUpdates.Visible := false;
      lstUpdatesUnstable.Visible := true;
    end
    else
    begin
      lstUpdates.Visible := true;
      lstUpdatesUnstable.Visible := false;
    end;
    lstTranslations.Visible := false;
  end
  else
  begin
    lstUpdates.Visible := false;
    lstUpdatesUnstable.Visible := false;
    lstTranslations.Visible := true;
  end;

end;

procedure TfrmInstaller.linkToWIPClick(Sender: TObject);
begin

   ShellExecute(Application.Handle,
                        'OPEN',
                        PChar(urlToWIP),
                        nil,
                        nil,
                        SW_SHOW);

end;

procedure TfrmInstaller.chkShowUnstableClick(Sender: TObject);
begin

  lstUpdatesTypesChange(Sender);
  if chkShowUnstable.Checked then
    lstUpdatesUnstableClick(Sender)
  else
    lstUpdatesClick(Sender);

end;

procedure TfrmInstaller.lstUpdatesUnstableClick(Sender: TObject);
var x: integer;
    res: boolean;
begin

  res := false;
  x:=0;
  while (x < lstUpdatesUnstable.Items.Count) and not(res) do
  begin
    res := lstUpdatesUnstable.Items.Item[x].Checked;
    inc(x);
  end;
  x:=0;
  while (x < lstTranslations.Items.Count) and not(res) do
  begin
    res := lstTranslations.Items.Item[x].Checked;
    inc(x);
  end;

  butDownload.Enabled := res;
  
end;

procedure TfrmInstaller.AutoCheckTimerTimer(Sender: TObject);
begin

  AutoCheckTimer.Enabled := false;
  CmdNext.Click;

end;

procedure TfrmInstaller.IdHTTPWork(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCount: Integer);
var
  ContentLength: Int64;
begin

  ContentLength := IdHttp.Response.ContentLength;
  infoLabel.Caption := ReplaceValue('%b',ReplaceValue('%f',DLNGstr('PII102'),curDL),IntToStr(AWorkCount)+'/'+Inttostr(ContentLength));

  if (ContentLength > 0) then
    ProgressDL.Position := 100*AWorkCount div ContentLength
  else
    ProgressDL.Position := 0;
  refresh;

end;

procedure TfrmInstaller.IdHTTPConnected(Sender: TObject);
begin

  writeLog(Internet,DLNGstr('PII105'));
  colorLog(Internet,clGreen);
  refresh;

end;

procedure TfrmInstaller.IdHTTPStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin

  writeLog(Internet,AStatusText);
  colorLog(Internet,clLtGray);
  refresh;

end;

end.
