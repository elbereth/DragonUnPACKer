unit Installer;

// $Id: Installer.pas,v 1.7 2008-03-02 18:13:26 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/tools/duppi/Installer.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
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
  ExtCtrls, ShellAPI, lib_language, XPMan, VirtualTrees, OverbyteIcsHttpProt,
  JvListView, IniFiles, lib_utils, JvExStdCtrls, JvRichEdit,
  OverbyteIcsWndControl;

type
 pvirtualTreeData = ^virtualTreeData;
 virtualTreeData = record
   ImageIndex: Integer;
   Release: Integer;
   GameTitle: String;
   Country: String;
   ReleasedBy: String;
   Tracks: array[1..8] of byte;
   Size: Integer;
   ProdNum: String;
   NumFiles: Integer;
   Format: Integer;
   Redumped: Boolean;
   NeedRedump: Boolean;
   IsNew: boolean;
   NumCD: byte;
 end;

type
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
    strStatus: TLabel;
    lblStatus: TLabel;
    Progress: TProgressBar;
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
    List: TListBox;
    stepChoice: TPanel;
    optInstall: TRadioButton;
    txtPathD5P: TEdit;
    cmdBrowseD5P: TButton;
    optInternet: TRadioButton;
    lblChoice: TLabel;
    lblWhat: TLabel;
    cmdNext: TButton;
    stepInternet: TPanel;
    HttpCli1: THttpCli;
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
    lblInternetComment: TLabel;
    imgCustomBanner: TImage;
    butProxy2: TButton;
    richLog: TJvRichEdit;
    lstUpdatesTypes: TComboBox;
    lblLinkToStable: TLabel;
    lblUpdatesTypes: TLabel;
    lblLinkToWIP: TLabel;
    linkToStable: TLabel;
    linkToWIP: TLabel;
    Shape1: TShape;
    lstTranslations: TListView;
    procedure parseDUPP_version1to3(src: integer; version: integer);
    function infosDUPP_version1(src: integer): boolean;
    function infosDUPP_version2(src: integer): boolean;
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
    procedure HttpCli1DocData(Sender: TObject; Buffer: Pointer;
      Len: Integer);
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
  private
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
    function infosDUPP(): boolean;
    procedure parseDUPP();
    procedure translate();
    function getPluginVersion(filename: String):integer;
    function getDestDir(i: integer): string;
    function getTempFile(ext: string): string;
    function getDup5Version(): integer;
    function ExecAndWait(const ExecuteFile, ParamString : string): boolean;
    function RegisterOCX(ocxpath: string): boolean;
    procedure appendLog(text: string);
    procedure colorLog(Color: TColor);
    procedure separatorLog;
    procedure setRichEditLineColor(R: TJvRichEdit; Line: Integer;
      Color: TColor);
    procedure setRichEditLineStyle(R: TJvRichEdit; Line: Integer;
      Style: TFontStyles);
    procedure styleLog(Style: TFontStyles);
    procedure writeLog(text: string);
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
  VERSION: Integer = 22040;

implementation

uses Proxy;

{$R *.dfm}

procedure TfrmInstaller.closeDUPP();
begin

  NFOLoaded := false;

  if (hDupp <> 0) then
    FileClose(hDupp);

end;

function TfrmInstaller.loadDUPP(duppfile: string): boolean;
begin

   if FileExists(duppfile) then
   begin

     hDupp := FileOpen(duppfile, fmOpenRead);

     FileRead(hDupp,HDR,8);

     if (HDR.ID <> 'DUPP') or (HDR.EOF <> 26) then
     begin
       FileClose(hDupp);
       hDupp := 0;
       MessageDlg(DLNGstr('PI0015'),mtError,[mbOk],0);
       result := false;
     end
     else if (HDR.NeededVersion > VERSION) then
     begin
       FileClose(hDupp);
       hDupp := 0;
       MessageDlg(ReplaceValue('%y',ReplaceValue('%v',DLNGstr('PI0041'),GetVersionFromInt(HDR.NeededVersion)),GetVersionFromInt(VERSION)),mtError,[mbOk],0);
       result := false;
     end
     else
     begin
       result := true;
       NFOloaded := false;
     end;

   end
   else
   begin
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
    else
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
    List.Items.Add('File '+inttostr(x)+'...');
    lblStatus.Caption := DLNGstr('PI0018');

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

    lblStatus.Caption := filename+' ('+inttostr(Round(ENT.DSize/1024))+'kb) ';

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

//    FileSeek(src,ENT.Size,1);

    if not(installFile) then
    begin
      lblStatus.Caption := filename+' ('+inttostr(Round(ENT.DSize/1024))+DLNGstr('PI0028')+')... '+DLNGstr('PI0027');
      FileSeek(src,ENT.Size,1);
    end
    else
    begin

      List.Items.Add(filename+' ('+inttostr(Round(ENT.DSize/1024))+'kb)');
      lblStatus.Caption := filename+' ('+inttostr(Round(ENT.DSize/1024))+DLNGstr('PI0028')+')... '+DLNGstr('PI0029');

      GetMem(Buf,ENT.Size);
      try
        List.Items.Add('Reading..');
        FileRead(src,buf^,ENT.Size);

        if (ENT.CompressionType = 1) then
        begin
          InputStream := TMemoryStream.Create;

          List.Items.Add('Decompressing..');
          lblStatus.Caption := filename+' ('+inttostr(Round(ENT.DSize/1024))+DLNGstr('PI0028')+')... '+DLNGstr('PI0030');
          try
            InputStream.Write(buf^, ENT.Size);
            InputStream.Seek(0, soFromBeginning);

            OutputStream := TDecompressionStream.Create(InputStream);
            try
              OutputStream.Read(Size, SizeOf(Size));
              getMem(bufoutstr,Size);
              OutputStream.Read(bufoutstr^, Size);
            finally
              OutputStream.Free
            end
          finally
            InputStream.Free
          end;
          List.Items.Add('Calculating CRC32..');
          if version = 3 then
            calcCRC := GetBufCRC32(bufoutstr,ENT.DSize)
          else
            calcCRC := getStrCRC32(bufoutstr^);
          List.Items.Add('Buffer: '+IntToHex(calcCRC,8)+' / Compare: '+IntToHex(ENT.CRC,8));
        end
        else
        begin
          if version = 3 then
            calcCRC := GetBufCRC32(buf,ENT.DSize)
          else
            calcCRC := getStrCRC32(buf^);
          Size := ENT.DSize;
        end;

        lblStatus.Caption := filename+' ('+inttostr(Round(ENT.DSize/1024))+DLNGstr('PI0028')+')... '+DLNGstr('PI0031');

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
            List.Items.Add('Registering ActiveX DLL...');
            RegisterOcx(destdir);
          end;
        end;

        lblStatus.Caption := filename+' ('+inttostr(Round(ENT.DSize/1024))+DLNGstr('PI0028')+')... '+DLNGstr('PI0032');
        List.Items.Add('Freeing memory buffer..');

      finally
        FreeMem(Buf);
      end;
    end;

  //  ShowMessage(filename);


    Progress.Position := Round((x / NFO.NumFiles)*100);

  end;

  Progress.Position := 100;
  if (errCount = 0) then
  begin
    lblStatus.Caption := ReplaceValue('%i',DLNGstr('PI0022'),IntToStr(NFO.NumFiles));
    lblInstalling.Caption := DLNGstr('PI0023');
  end
  else
  begin
    lblStatus.Caption := ReplaceValue('%e',DLNGstr('PI0024'),intToStr(errCount));
    lblInstalling.Caption := ReplaceValue('%i',ReplaceValue('%e',DLNGstr('PI0025'),intToStr(errCount)),intToStr(NFO.NumFiles - errCount));
  end;

end;

procedure TfrmInstaller.FormShow(Sender: TObject);
var Reg: TRegistry;
    clng: string;
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
        LoadLanguage(dup5path+'data\'+clng);
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
    Reg.Free;
  end;

  if Not(FileExists(Dup5Path+'drgunpack5.exe')) then
  begin
    MessageDlg(DLNGstr('PI0026'),mtError,[mbOk],0);
    Close;
  end;

  frmInstaller.Caption := 'Duppi v'+getVersionFromInt(VERSION);

  translate;

  if (ParamStr(1) <> '') then
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
    lblStatus.Caption := DLNGstr('PI0012');
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

  result := false;

  if (hDupp <> 0) and not(NFOLoaded) then
    case HDR.Version of
      1: result := infosDUPP_version1(hDupp);
      2: result := infosDUPP_version2(hDupp);
      3: result := infosDUPP_version2(hDupp);
    else
      MessageDlg(ReplaceValue('%v',DLNGstr('PI0014'),inttostr(HDR.Version)),mtError, [mbOk],0);
      result := false;
    end;

end;

procedure TfrmInstaller.cmdCancelClick(Sender: TObject);
begin

  if (httpCli1.State <> httpReady) then
    httpCli1.Abort
  else
    if MessageDlg(DLNGstr('PI0011'),mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      Close;

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

function TfrmInstaller.getDestDir(i: integer): string;
begin

  case i of
    0: result := Dup5Path + 'data\convert\';
    1: result := Dup5Path + 'data\';
    2: result := Dup5Path + 'data\drivers\';
    3: if HDR.Version = 2 then
         result := Dup5Path + 'data\hyperripper\'
       else
         result := Dup5Path;
    4: result := Dup5Path;
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
  strStatus.Caption := DLNGstr('PI0009');
  lblStatus.Caption := DLNGstr('PI0010');
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
//  lstUpdates.Columns.Items[3].Caption := DLNGstr('PII004');
  lstUpdates.Columns.Items[3].Caption := DLNGstr('PII005');
  strInternetComment.Caption := DLNGstr('INFO03');

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
    Reg.Free;
  end;

  if optInternet.Checked then
  begin
    lstUpdatesTypes.ItemIndex := 0;
    butDownload.Visible := true;
    cmdNext.Visible := false;
    stepChoice.Visible := false;
    stepInstall.Visible := false;
    stepInternet.Visible := true;
    httpCli1.Proxy := proxy;
    httpCli1.ProxyPort := proxyPort;
    if proxyUserPass then
    begin
      httpCli1.ProxyUsername := proxyUser;
      httpCli1.ProxyPassword := proxyPass;
    end;
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
    curUpd := 0;
    if loadDupp(txtPathD5P.Text) then
      if not(infosDupp()) then
        close;
  end;

end;

procedure TfrmInstaller.FormCreate(Sender: TObject);
begin

//  lstInstalled.NodeDataSize := SizeOf(virtualTreeData);

  lstUpd := TStringList.Create;

end;

procedure TfrmInstaller.butRefreshClick(Sender: TObject);
Var updList: TStringList;
    lngList: TStringList;
    itm: TListItem;
    x, tmpVer: integer;
    butDl, coreUpdate: boolean;
    coreMessage: string;
    errCode: string;
begin

  butRefresh.Enabled := false;
//HttpCli1.URL := 'http://dus.dragonunpacker.com/dup5.dus';   // Old URL
//HttpCli1.URL := 'http://www.elberethzone.net/dup5.dus';     // 5.0/5.1 URL DUS v2.0
  HttpCli1.URL := 'http://dragonunpacker.sourceforge.net/dus.php?installedbuild='+inttostr(corebuild);     // 5.2+ URL DUS v3.0
  writeLog(inttostr(corebuild));
  tmpFile := getTempFile('.dus');
  HttpCli1.RcvdStream := TFileStream.Create(tmpFile,fmCreate);
  CurDL := DLNGstr('PII100');
    try
        try
            writeLog(ReplaceValue('%f',DLNGstr('PII101'),curDL));
            HttpCli1.Get;
            writeLog(ReplaceValue('%b',ReplaceValue('%f',DLNGstr('PII103'),curDL),IntToStr(HttpCli1.RcvdStream.Size)));
        except
            on E: EHttpException do begin
              writeLog(ReplaceValue('%d',ReplaceValue('%c',DLNGstr('PII104'),IntToStr(HttpCli1.StatusCode)),HttpCli1.ReasonPhrase));
              colorLog(clRed);
            end
            else
                raise;
        end;

    finally
        HttpCli1.RcvdStream.Destroy;
        HttpCli1.RcvdStream := nil;
        ButRefresh.Enabled := true;
    end;

    butDl := false;

    if fileexists(tmpFile) then
    begin
      dus := TIniFile.Create(tmpFile);
      if not(dus.SectionExists('ID')) then
      begin
        writeLog(DLNGStr('PI0044'));
      end
      else
        if not(dus.ValueExists('ID','DUS')) then
        begin
          writeLog(DLNGStr('PI0044'));
        end
        else
          if (dus.ReadInteger('ID','DUS',0) <> 3) or not(dus.ValueExists('ID','Result')) then
          begin
            writeLog(DLNGStr('PI0044'));
          end
          else
          begin
            writeLog(dus.ReadString('ID','Description',DLNGstr('PII105')));

            if (dus.ReadString('ID','Result','ERR') <> 'OK') then
            begin
              errCode := dus.ReadString('ID','Result','ERR');

              if errCode = 'M01' then
                writeLog(DLNGStr('PIEM01'))
              else if errCode = 'M02' then
                writeLog(DLNGStr('PIEM01'))
              else if errCode = 'M10' then
                writeLog(DLNGStr('PIEM10'))
              else if errCode = 'M11' then
                writeLog(DLNGStr('PIEM11'))
              else if errCode = 'M20' then
                writeLog(DLNGStr('PIEM20'))
              else if errCode = 'M30' then
                writeLog(DLNGStr('PIEM30'))
              else if errCode = 'M31' then
                writeLog(DLNGStr('PIEM31'))
              else if errCode = 'M32' then
                writeLog(DLNGStr('PIEM32'))
              else if errCode = 'M33' then
                writeLog(DLNGStr('PIEM33'))
              else if errCode = 'P01' then
                writeLog(DLNGStr('PIEP01'))
              else if errCode = 'P02' then
                writeLog(DLNGStr('PIEP02'))
              else
                writeLog(ReplaceValue('%e',DLNGStr('PIEUNK'),errCode));

              colorLog(clRed);
            end;

            updList := splitStr(dus.ReadString('ID','Updates',''),' ');
            lngList := splitStr(dus.ReadString('ID','Translations',''),' ');
            writeLog(ReplaceValue('%t',ReplaceValue('%p',DLNGStr('PII108'),inttostr(updList.Count)),inttostr(lngList.Count)));
            lstUpdates.Clear;
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

            for x:=0 to lngList.Count -1 do
            begin

              itm := lstTranslations.Items.Add;
              itm.Caption := dus.ReadString(lngList.Strings[x],'Description',DLNGstr('PII106'));
              itm.SubItems.Add(dus.ReadString(lngList.Strings[x],'Release',''));
              itm.SubItems.Add(dus.ReadString(lngList.Strings[x],'Author',''));
              itm.SubItems.Add(inttostr(dus.ReadInteger(lngList.Strings[x],'Size',0)));
              itm.SubItems.Add(lngList.Strings[x]);

            end;

            butDownload.Enabled := butDL;

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

            if (CoreUpdate) then
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
                           PChar(dus.ReadString('core','URL','http://www.dragonunpacker.com')),
                           nil,
                           nil,
                           SW_SHOW);
                close;
              end;
            end;

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

  if FileExists(tmpFile) then
    DeleteFile(tmpFile);

end;

procedure TfrmInstaller.HttpCli1DocData(Sender: TObject; Buffer: Pointer;
  Len: Integer);
begin

  infoLabel.Caption := ReplaceValue('%b',ReplaceValue('%f',DLNGstr('PII102'),curDL),IntToStr(HttpCli1.RcvdCount));
  ProgressDL.Position := HttpCli1.RcvdCount;

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
var x : integer;
    url, tmpfile, tmpFileName : string;
    delFile : boolean;
begin

  tmpFile := dup5Path+'Download';
  if not(DirectoryExists(tmpFile)) then
    mkdir(tmpfile);

  lstUpdates.Enabled := false;
  butDownload.Enabled := false;
  butRefresh.Enabled := false;
  butProxy2.Enabled := false;

  for x := 0 to lstUpdates.Items.Count-1 do
  begin
    if lstUpdates.Items.Item[x].Checked then
    begin
      if dus.ValueExists(lstUpdates.Items.Item[x].SubItems[4],'URL') then
      begin
        url := dus.ReadString(lstUpdates.Items.Item[x].SubItems[4],'URL','');
        tmpFileName := dus.ReadString(lstUpdates.Items.Item[x].SubItems[4],'FileDL',getTempFile(extractfileext(url)));
        tmpFile := dup5Path+'Download\'+tmpFileName;
        HttpCli1.URL := url;
        HttpCli1.RcvdStream := TFileStream.Create(tmpFile,fmCreate);
        CurDL := tmpFileName;
        CurDLSize := strtoint(lstUpdates.Items.Item[x].SubItems[2]);
        inc(curDLSize);
        progressDL.Position := 0;
        progressDL.Max := CurDLSize*1024;
        delFile := false;
        try
          try
            WriteLog(ReplaceValue('%f',DLNGstr('PII101'),curDL));
            HttpCli1.Get;
            lstUpd.Add(tmpFile);
            WriteLog(ReplaceValue('%b',ReplaceValue('%f',DLNGstr('PII103'),curDL),IntToStr(HttpCli1.RcvdStream.Size)));
          except
            on E: EHttpException do begin
                writeLog(ReplaceValue('%d',ReplaceValue('%c',DLNGstr('PII104'),IntToStr(HttpCli1.StatusCode)),HttpCli1.ReasonPhrase));
                colorLog(clRed);
                DelFile := true;
            end
          else
            raise;
          end;

        finally
          HttpCli1.RcvdStream.Destroy;
          HttpCli1.RcvdStream := nil;
          ButDownload.Visible := true;
          if DelFile and FileExists(tmpFile) then
            DeleteFile(tmpFile);
        end;
      end;
    end;
  end;

  for x := 0 to lstTranslations.Items.Count-1 do
  begin
    if lstTranslations.Items.Item[x].Checked then
    begin
      if dus.ValueExists(lstTranslations.Items.Item[x].SubItems[3],'URL') then
      begin
        url := dus.ReadString(lstTranslations.Items.Item[x].SubItems[3],'URL','');
        tmpFileName := dus.ReadString(lstTranslations.Items.Item[x].SubItems[3],'FileDL',getTempFile(extractfileext(url)));
        tmpFile := dup5Path+'Download\'+tmpFileName;
        HttpCli1.URL := url;
        HttpCli1.RcvdStream := TFileStream.Create(tmpFile,fmCreate);
        CurDL := tmpFileName;
        CurDLSize := strtoint(lstTranslations.Items.Item[x].SubItems[2]);
        inc(curDLSize);
        progressDL.Position := 0;
        progressDL.Max := CurDLSize*1024;
        delFile := false;
        try
          try
            WriteLog(ReplaceValue('%f',DLNGstr('PII101'),curDL));
            HttpCli1.Get;
            lstUpd.Add(tmpFile);
            WriteLog(ReplaceValue('%b',ReplaceValue('%f',DLNGstr('PII103'),curDL),IntToStr(HttpCli1.RcvdStream.Size)));
          except
            on E: EHttpException do begin
                writeLog(ReplaceValue('%d',ReplaceValue('%c',DLNGstr('PII104'),IntToStr(HttpCli1.StatusCode)),HttpCli1.ReasonPhrase));
                colorLog(clRed);
                DelFile := true;
            end
          else
            raise;
          end;

        finally
          HttpCli1.RcvdStream.Destroy;
          HttpCli1.RcvdStream := nil;
          ButDownload.Visible := true;
          if DelFile and FileExists(tmpFile) then
            DeleteFile(tmpFile);
        end;
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

  translate;

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

  httpCli1.Proxy := proxy;
  httpCli1.ProxyPort := proxyPort;
  if proxyUserPass then
  begin
    httpCli1.ProxyUsername := proxyUser;
    httpCli1.ProxyPassword := proxyPass;
  end;

end;

procedure TfrmInstaller.cmdBrowseD5PClick(Sender: TObject);
begin

  optInstall.Checked := true;

  OpenDialog.InitialDir := txtPathD5P.Text;

  OpenDialog.Filter := 'Dragon UnPACKer 5 Package (*.D5P)|*.d5p';
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

  lblInternetComment.Caption := item.SubItems[3];

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
    Reg.Free;
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

procedure TfrmInstaller.writeLog(text: string);
begin

  if richLog.Lines.Count = 32760 then
    richLog.Lines.Delete(0);

  richLog.Lines.Add(DateTimeToStr(now)+' : '+text);
  richLog.Perform(EM_LINESCROLL,0,1);

end;

procedure TfrmInstaller.appendLog(text: string);
begin

  richLog.Lines.Strings[richLog.Lines.Count-1] := richLog.Lines.Strings[richLog.Lines.Count-1]+' '+text;

end;


procedure TfrmInstaller.separatorLog;
begin

  writelog(StringOfchar('-',80));

end;

procedure TfrmInstaller.styleLog(Style: TFontStyles);
begin

  setRichEditLineStyle(richLog, richLog.Lines.Count, Style);

end;

procedure TfrmInstaller.colorLog(Color: TColor);
begin

  setRichEditLineColor(richLog, richLog.Lines.Count, Color);

end;

procedure TfrmInstaller.setRichEditLineStyle(R : TJvRichEdit; Line : Integer; Style : TFontStyles);
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

procedure TfrmInstaller.setRichEditLineColor(R : TJvRichEdit; Line : Integer; Color : TColor);
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
  //  previewfile: string;
    stmTmp: TMemoryStream;
    InputStream: TMemoryStream;
    DStream: TDecompressionStream;
    FinalSize: integer;
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
              FinalSize := stmTmp.CopyFrom(DStream,NFO.PictureSize);
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
    lstUpdates.Visible := true;
    lstTranslations.Visible := false;
  end
  else
  begin
    lstUpdates.Visible := false;
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

end.
