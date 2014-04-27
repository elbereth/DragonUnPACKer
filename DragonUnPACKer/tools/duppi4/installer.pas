unit Installer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ActnList, ExtCtrls, StdCtrls, registry, Windows, lib_binutils, lib_language,
  IdHTTP, IdSSLOpenSSL, IdComponent, IdSSLOpenSSLHeaders, IdCTypes,
  IdAntiFreeze, IdIntercept, IdCompressorZLib, IdHeaderList, IdSocks, IniFiles,
  IdURI, lib_version;

type

  RProxySettings = record
    ProxyType: integer;
    Host: string;
    Port: String;
    UseAuth: boolean;
    Username: string;
    Password: string;
  end;

  { TfrmInstaller }

  TfrmInstaller = class(TForm)
    butPrevious: TButton;
    butNext: TButton;
    butClose: TButton;
    butProxyOptions: TButton;
    butPackagePath: TButton;
    chkTest: TCheckBox;
    chkProxyUseAuth: TCheckBox;
    IdSocksInfo: TIdSocksInfo;
    lstProxyType: TComboBox;
    grpProxyUserPass: TGroupBox;
    IdAntiFreeze: TIdAntiFreeze;
    IdConnectionIntercept: TIdConnectionIntercept;
    IdHTTP: TIdHTTP;
    IOHandlerSSL: TIdSSLIOHandlerSocketOpenSSL;
    lblProxyType: TLabel;
    lblProxyPassword: TLabel;
    lblProxyUsername: TLabel;
    ListView1: TListView;
    Memo1: TMemo;
    barDownload: TProgressBar;
    tabUpdates: TTabSheet;
    txtPackagePath: TEdit;
    lblPage1Text3: TLabel;
    lblPage1Text2: TLabel;
    lblPage1Text1: TLabel;
    lblPage1Version: TLabel;
    lblPage1Path: TLabel;
    lblDragonUnPACKerVersion: TLabel;
    lblDragonUnPACKerPath: TLabel;
    optInternet: TRadioButton;
    optInstallPackage: TRadioButton;
    txtProxyHost: TEdit;
    txtProxyPassword: TEdit;
    txtProxyPort: TEdit;
    imgHeaderLogo: TImage;
    lblProxyHost: TLabel;
    lblProxyPort: TLabel;
    lblTitle: TLabel;
    lblSubTitle: TLabel;
    pages: TPageControl;
    tabIntro: TTabSheet;
    tabProxyOption: TTabSheet;
    tabConnecting: TTabSheet;
    txtProxyUsername: TEdit;
    procedure butCloseClick(Sender: TObject);
    procedure butNextClick(Sender: TObject);
    procedure butPreviousClick(Sender: TObject);
    procedure butProxyOptionsClick(Sender: TObject);
    procedure chkProxyUseAuthChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IdHTTPStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure imgHeaderLogoDblClick(Sender: TObject);
    procedure IOHandlerSSLStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure IOHandlerSSLStatusInfo(const AMsg: String);
    function IOHandlerSSLVerifyPeer(Certificate: TIdX509; AOk: Boolean; ADepth,
      AError: Integer): Boolean;
    procedure lstProxyTypeChange(Sender: TObject);
    procedure tabIntroContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure optInstallPackageChange(Sender: TObject);
  private
    { private declarations }
    Dup5Path: String;
    Dup5Build: Cardinal;
    ProxySettings: RProxySettings;
    procedure goToPage(pagenum: integer);
    procedure saveProxySettings();
    procedure applyProxySettings();
    procedure getInternetUpdates();
  public
    { public declarations }
  end;

const
  VERSION: Cardinal = 40001;

var
  frmInstaller: TfrmInstaller;

implementation

{$R *.lfm}

{ TfrmInstaller }

procedure TfrmInstaller.FormCreate(Sender: TObject);
var Reg: TRegistry;
    clng, lv, S: string;
    Taille  : DWord;
    Buffer  : PChar;
    VersionPC : PChar;
    VersionL    : DWord;
    VerifBuild: Cardinal;
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
        lblDragonUnPACKerVersion.Caption := Reg.ReadString('Version');
        lblDragonUnPACKerPath.Caption := dup5Path;
        if Reg.ValueExists('Build') then
        begin
          Dup5Build := Reg.ReadInteger('Build');
          lblDragonUnPACKerVersion.Caption := lblDragonUnPACKerVersion.Caption + '.'+IntTostr(Dup5Build);
        end
        else
          Dup5Build := 0;
        if Reg.ValueExists('Edit') then
          lblDragonUnPACKerVersion.Caption := lblDragonUnPACKerVersion.Caption + ' '+ Reg.ReadString('Edit');
      end;
      if Reg.ValueExists('Language') then
        clng := Reg.ReadString('Language')
      else
        clng := '*';
      {if clng = '*' then
        LoadInternalLanguage
      else
        LoadLanguage(ExtractFilePath(Application.ExeName)+'\data\'+clng,false);}
      Reg.CloseKey;
    end;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Duppi',True) then
    begin
      if Reg.ValueExists('ProxyType') then
        ProxySettings.ProxyType := Reg.ReadInteger('ProxyType')
      else
        ProxySettings.ProxyType := 0;
      if Reg.ValueExists('Proxy') then
        ProxySettings.Host := Reg.ReadString('Proxy')
      else
        ProxySettings.Host := '';
      if Reg.ValueExists('ProxyPort') then
        ProxySettings.Port := Reg.ReadString('ProxyPort')
      else
        ProxySettings.Port := '';
      if Reg.ValueExists('ProxyUserPass') then
        ProxySettings.UseAuth := Reg.ReadBool('ProxyUserPass')
      else
        ProxySettings.UseAuth := false;
      if Reg.ValueExists('ProxyUser') then
        ProxySettings.Username := Reg.ReadString('ProxyUser')
      else
        ProxySettings.Username := '';
      if Reg.ValueExists('ProxyPass') then
        ProxySettings.Password := Reg.ReadString('ProxyPass')
      else
        ProxySettings.Password := '';
      if Reg.ValueExists('InstallPath') then
        txtPackagePath.Text := Reg.ReadString('InstallPath');
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  if Not(FileExists(Dup5Path+'drgunpack5.exe')) then
  begin
    MessageDlg('Dragon UnPACKer not found in the last known execution path!',mtError,[mbOk],0);
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

  if VerifBuild <> Dup5Build then
  begin
    if MessageDlg(ReplaceValue('%b',ReplaceValue('%a',DLNGstr('PI0069'),inttostr(VerifBuild)),inttostr(Dup5Build)),mtError,[mbYes, mbNo],0) = mrYes then
    begin
      ShellExecute(0,
                        'OPEN',
                        PChar(Dup5Path+'drgunpack5.exe'),
                        nil,
                        nil,
                        SW_SHOW);
    end;
    Close;
  end;

  frmInstaller.Caption := 'Duppi v'+getVersion(VERSION);
  Application.Title := frmInstaller.Caption;
  IdHTTP.Request.UserAgent := 'Mozilla/4.0 (compatible; Duppi/'+inttostr(VERSION)+')';

//  translate;

  if (ParamStr(1) = '/InstalledOK') then
  begin

    ShowMessage(DLNGstr('PI0046'));

  end
  else if (lowercase(ParamStr(1)) = '/checknewversions') or (lowercase(ParamStr(1)) = '/checktranslations') then
  begin

    optInternet.Checked := true;
//    AutoCheckTimer.Enabled := true;

  end
  else if (ParamStr(1) <> '') then
  begin
//    stepChoice.Visible := false;
//    stepInstall.Visible := true;
//    cmdNext.Visible := false;
//    butInstall.Visible := true;
//    lstUpd.Add(ParamStr(1));
//    curUpd := 0;
//    if not(loadDUPP(ParamStr(1))) then
//      close;
//    if not(infosDUPP()) then
//      close;
  end;

end;

procedure TfrmInstaller.IdHTTPStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin

  refresh;

end;

procedure TfrmInstaller.IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin

  Memo1.Append('Work Count '+InttoStr(AWorkCount)+' / '+inttostr(IdHTTP.Response.ContentLength));
  Refresh;

end;

procedure TfrmInstaller.imgHeaderLogoDblClick(Sender: TObject);
begin

  // Hidden "feature", if on proxy options page, display the test checkbox
  if pages.PageIndex = 1 then
    chkTest.Visible := true;

end;

procedure TfrmInstaller.IOHandlerSSLStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin

  refresh;

end;

procedure TfrmInstaller.IOHandlerSSLStatusInfo(const AMsg: String);
begin

  refresh;

end;

function TfrmInstaller.IOHandlerSSLVerifyPeer(Certificate: TIdX509;
  AOk: Boolean; ADepth, AError: Integer): Boolean;
begin

  if AOk and (ADepth = 0) then
    Memo1.Append('Server identity verified.');
  refresh;
  Result := Aok;

end;

procedure TfrmInstaller.lstProxyTypeChange(Sender: TObject);
begin

  lblProxyHost.Enabled := (lstProxyType.ItemIndex <> 0);
  txtProxyHost.Enabled := lblProxyHost.Enabled;
  lblProxyPort.Enabled := lblProxyHost.Enabled;
  txtProxyPort.Enabled := lblProxyHost.Enabled;

end;

procedure TfrmInstaller.butProxyOptionsClick(Sender: TObject);
begin

  butProxyOptions.Tag := pages.PageIndex;
  goToPage(1);

end;

procedure TfrmInstaller.chkProxyUseAuthChange(Sender: TObject);
begin

  lblProxyUsername.Enabled := chkProxyUseAuth.Checked;
  txtProxyUsername.Enabled := chkProxyUseAuth.Checked;
  lblProxyPassword.Enabled := chkProxyUseAuth.Checked;
  txtProxyPassword.Enabled := chkProxyUseAuth.Checked;

end;

procedure TfrmInstaller.butCloseClick(Sender: TObject);
begin

  if MessageDlg('Are you sure you want to exit?',mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    Application.Terminate;

end;

procedure TfrmInstaller.butNextClick(Sender: TObject);
begin

  if pages.PageIndex = 0 then
  begin
    if optInternet.Checked then
    begin
      getInternetUpdates();
    end
    else
    begin

    end;
  end
  else if pages.PageIndex = 1 then
  begin
    ProxySettings.Host := txtProxyHost.Text;
    ProxySettings.Port := txtProxyPort.Text;
    ProxySettings.UseAuth := chkProxyUseAuth.Checked;
    ProxySettings.Username := txtProxyUsername.Text;
    ProxySettings.Password := txtProxyPassword.Text;
    saveProxySettings;
    applyProxySettings;
    goToPage(butProxyOptions.Tag);
  end;

end;

procedure TfrmInstaller.butPreviousClick(Sender: TObject);
begin

  if pages.PageIndex = 1 then
  begin
    goToPage(butProxyOptions.Tag);
  end;

end;

procedure TfrmInstaller.tabIntroContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

procedure TfrmInstaller.optInstallPackageChange(Sender: TObject);
begin

  txtPackagePath.Enabled := optInstallPackage.Checked;
  butPackagePath.Enabled := optInstallPackage.Checked;

end;

procedure TfrmInstaller.goToPage(pagenum: integer);
begin

  if pagenum = 0 then
  begin
    lblTitle.Caption := 'Dragon UnPACKer Package Installer';
    lblSubTitle.Caption := 'This program allows you to keep your Dragon UnPACKer up to date.';
    butNext.Caption := 'Next >';
    butNext.Visible := true;
    butPrevious.Visible := false;
    butProxyOptions.Visible := true;
  end
  else if pagenum = 1 then
  begin
    chkTest.Visible := false;
    lblTitle.Caption := 'Proxy Options';
    lblSubTitle.Caption := 'Set the proxy to use for internet connection (Optional).';
    butNext.Caption := 'Save';
    butNext.Visible := true;
    butPrevious.Caption := 'Cancel';
    butPrevious.Visible := true;
    butProxyOptions.Visible := false;
    txtProxyHost.Text := ProxySettings.Host;
    txtProxyPort.Text := ProxySettings.Port;
    txtProxyUsername.Text := ProxySettings.Username;
    txtProxyPassword.Text := ProxySettings.Password;
    chkProxyUseAuth.Checked := ProxySettings.UseAuth;
  end;
  pages.PageIndex := pagenum;
  refresh;

end;

procedure TfrmInstaller.saveProxySettings;
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Duppi',True) then
    begin
      Reg.WriteInteger('Proxy',ProxySettings.ProxyType);
      Reg.WriteString('Proxy',ProxySettings.Host);
      Reg.WriteString('ProxyPort',ProxySettings.Port);
      Reg.WriteString('ProxyUser',ProxySettings.Username);
      Reg.WriteString('ProxyPass',ProxySettings.Password);
      Reg.WriteBool('ProxyUserPass',ProxySettings.UseAuth);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmInstaller.applyProxySettings;
begin

  IdHttp.ProxyParams.ProxyServer := ProxySettings.Host;
  if (ProxySettings.Port > '') then
  begin
    try
      IdHttp.ProxyParams.ProxyPort := strtoint(ProxySettings.Port);
    except
      IdHttp.ProxyParams.ProxyPort := 8080;
    end;
  end;
  IdHttp.ProxyParams.BasicAuthentication := ProxySettings.UseAuth;
  if ProxySettings.UseAuth then
  begin
    IdHttp.ProxyParams.ProxyUsername := ProxySettings.Username;
    IdHttp.ProxyParams.ProxyPassword := ProxySettings.Password;
  end;

end;

procedure TfrmInstaller.getInternetUpdates;
var tmpStm: TMemoryStream;
    DUS: TIniFile;
    url,urltest: String;
    URI: TIdUri;
begin

  // Define the URL to use for update
  //   HTTPS for secure channel
  //   Host is update.dragonunpacker.com
  //   Path is empty "/" for production server or "/test/" for test server
  //   Parameter installedbuild contains the Dragon UnPACKer build
  //   Parameter duppiversion contains the Duppi VERSION constant
  URI := TIdURI.Create('https://update.dragonunpacker.com/dus.php?installedbuild='+inttostr(dup5Build)+'&duppiversion='+inttostr(VERSION));

  // If the test checkbox is set then use the test DUS server
  if chkTest.Checked then
    URI.Path := '/test/';

  url := URI.GetFullURI();

  // Go to tabConnecting
  GoToPage(2);

  // We need a TMemoryStream to store the dus.ini file
  tmpStm := TMemoryStream.Create;

  // Set the Root CA certificate to ElberethZone one (in duppi.pem)
  IOHandlerSSL.SSLOptions.RootCertFile := ExtractFilePath(Application.ExeName)+'duppi.pem';

  Memo1.Append('Contacting Dragon Update Server over secure channel...');
  Memo1.Append(url);
  Memo1.Append('Using Indy v'+IOHandlerSSL.Version+' ');

  try
    // Retrieve dus.ini (over SSL so can take more time)
    IdHTTP.Get(url,tmpStm);

    Memo1.Append('Done ('+inttostr(tmpStm.Size)+' bytes)');
    Memo1.Append('Parsing update information...');

    // Parse dus.ini file
    tmpStm.Position := 0;
    DUS := TIniFile.Create(tmpStm);
    try
      if not(dus.SectionExists('ID')) then
      begin
        Memo1.Append(DLNGStr('PI0044'));
      end
      else
        if not(dus.ValueExists('ID','DUS')) then
        begin
          Memo1.Append(DLNGStr('PI0044'));
        end
        else
          if (dus.ReadInteger('ID','DUS',0) <> 3) or not(dus.ValueExists('ID','Result')) then
          begin
            Memo1.Append(DLNGStr('PI0044'));
          end
          else
          begin
            Memo1.Append(dus.ReadString('ID','Description',DLNGstr('PII105')));

            if (dus.ReadString('ID','Result','ERR') <> 'OK') then
            begin
                      Memo1.Append(dus.ReadString('ID','Result','ERR'));
            end;

          end;

    finally
      FreeAndNil(DUS);
    end;
  except
    on e: Exception do
    begin
      Memo1.Append(e.ClassName+ ' '+e.Message);
    end;
  end;
  FreeAndNil(tmpStm);

end;

end.

