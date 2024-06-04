unit Error;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is Error.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DateUtils, lib_utils,
  prg_ver,
  ExtCtrls, lib_language, translation, ShellApi;

type
  TfrmError = class(TForm)
    txtError: TMemo;
    butCopy: TButton;
    cmdDetails: TButton;
    strInfo: TLabel;
    strReports: TLabel;
    Bevel1: TBevel;
    strEx: TLabel;
    strMessage: TLabel;
    lblExMessage: TLabel;
    lblEx: TLabel;
    cmdOk: TButton;
    strFrom: TLabel;
    lblFrom: TLabel;
    strBugRep: TLabel;
    lblEmailReport: TLabel;
    procedure cmdDetailsClick(Sender: TObject);
    procedure cmdOkClick(Sender: TObject);
    procedure lblEmailReportMouseEnter(Sender: TObject);
    procedure lblEmailReportMouseLeave(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure lblEmailReportClick(Sender: TObject);
    procedure butCopyClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    constructor Create(AOwner: TComponent); override;
    destructor destroy; override;
  private
    Save_Cursor: TCursor;
    { Private declarations }
  public
    { Public declarations }
    details: TStrings;
    procedure FillTxtError(E: Exception; from, subfrom: String);
    procedure PrepareError();
    procedure OnAppliException (Sender: TObject; E: Exception);
  end;

var
  frmError: TfrmError;

implementation

{$R *.dfm}

{$Include datetime.inc}

{ TfrmError }

procedure TfrmError.FillTxtError(E: Exception; from, subfrom: String);
var OSInfo: TOSInfo;
    SysInfo: TSystemInfo;
begin

frmError.Height := 153;
cmdDetails.Caption := DLNGStr('BUTDET')+' >>';

txtError.Clear;

lblFrom.Caption := from+' in '+subfrom;
lblEx.Caption := e.ClassName;
lblExMessage.Caption := e.Message;

frmError.Refresh;

OSInfo := GetAllSystemInfo();
GetSystemInfo(SysInfo);

txtError.Lines.Add('____________ Error report ____________');
txtError.Lines.Add('');

txtError.lines.add('Timestamp: '+DateTimeToStr(now));
txtError.Lines.Add('From: '+from+' in '+subfrom);
txtError.lines.add('Exception: '+e.ClassName);
txtError.Lines.Add('Reporting: '+e.Message);
if CurEdit = '' then
  txtError.Lines.Add('Version: ' + CurVersion + ' (Build ' + IntToStr(CurBuild) +') ['+DateToStr(compileTime)+ ' '+TimeToStr(compileTime)+']')
else
  txtError.Lines.Add('Version: ' + CurVersion + ' ' + CurEdit + ' (Build ' + IntToStr(CurBuild) +') ['+DateToStr(compileTime)+ ' '+TimeToStr(compileTime)+']');

txtError.Lines.Add('');

if (details <> nil) and (details.Count > 0) then
begin
  txtError.Lines.Add('____________ More Details ____________');
  txtError.Lines.Add('');

  txtError.Lines.AddStrings(details);

  txtError.Lines.Add('');
end;

txtError.Lines.Add('__________ Computer status: __________');
txtError.Lines.Add('');
txtError.Lines.Add(OSInfo.WinVersion);
txtError.Lines.Add('CPU Count='+inttostr(SysInfo.dwNumberOfProcessors)+' OEMID='+inttostr(SysInfo.dwOemId)+' Arch='+inttostr(SysInfo.wProcessorArchitecture)+' Level='+inttostr(SysInfo.wProcessorLevel)+' Rev='+inttostr(SysInfo.wProcessorRevision));

txtError.Lines.Add('Memory: Free='+inttostr(OSInfo.MemAvailable div 1048576)+'MB / Total='+inttostr(OSInfo.MemTotal div 1048576)+'MB');
txtError.Lines.Add('');

{txtError.Lines.Add('__________ Program status: __________');
txtError.Lines.Add('');
txtError.Lines.Add('Loaded file: '+FSE.GetFileName+' ('+inttostr(FSE.GetFileSize)+' bytes)');
txtError.Lines.Add('Detected type: '+FSE.DriverID);
txtError.Lines.Add('');
txtError.Lines.Add('Loaded drivers (FSE):');

for x := 1 to FSE.NumDrivers do
  txtError.Lines.Add('['+inttostr(x)+'] '+FSE.Drivers[x].FileName+' : '+FSE.Drivers[x].Info.Name+' <'+FSE.Drivers[x].Info.Author+'> ('+FSE.Drivers[x].Info.Version +' | '+inttostr(FSE.Drivers[x].GetVersion)+')');

txtError.Lines.Add(' Total='+inttostr(FSE.NumDrivers));

txtError.Lines.Add('');
txtError.Lines.Add('Loaded convert plugins:');

for x := 1 to CPlug.NumPlugins do
  txtError.Lines.Add('['+inttostr(x)+'] '+CPlug.Plugins[x].FileName+' : '+CPlug.Plugins[x].Version.Name+' <'+CPlug.Plugins[x].Version.Author+'> ('+CPlug.Plugins[x].Version.Version +' | '+inttostr(CPlug.Plugins[x].Version.VerID)+')');

txtError.Lines.Add(' Total='+inttostr(Cplug.NumPlugins));

txtError.Lines.Add('');
txtError.Lines.Add('Loaded HyperRipper plugins:');

for x := 1 to HPlug.NumPlugins do
  txtError.Lines.Add('['+inttostr(x)+'] '+HPlug.Plugins[x].FileName+' : '+HPlug.Plugins[x].Version.Name+' <'+HPlug.Plugins[x].Version.Author+'> ('+inttostr(HPlug.Plugins[x].Version.Version)+')');

txtError.Lines.Add(' Total='+inttostr(Hplug.NumPlugins));}

txtError.SelectAll;
txtError.SelLength := 0;

frmError.ShowModal;

end;

procedure TfrmError.cmdDetailsClick(Sender: TObject);
begin

  if (frmError.Height = 153) then
  begin
    frmError.Height := 305;
    cmdDetails.Caption := '<< '+DLNGStr('BUTDET');
  end
  else
  begin
    frmError.Height := 153;
    cmdDetails.Caption := DLNGStr('BUTDET')+' >>';
  end;

end;

procedure TfrmError.cmdOkClick(Sender: TObject);
begin

frmError.ModalResult := mrOk;

end;

procedure TfrmError.lblEmailReportMouseEnter(Sender: TObject);
begin

  lblEmailReport.Font.Style := [fsUnderline];
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHandPoint;

end;

procedure TfrmError.lblEmailReportMouseLeave(Sender: TObject);
begin

  lblEmailReport.Font.Style := [];
  Screen.Cursor := Save_Cursor;

end;

procedure TfrmError.FormHide(Sender: TObject);
begin

  if (Screen.Cursor = crHandPoint) then
    Screen.Cursor := Save_Cursor;

end;

procedure TfrmError.lblEmailReportClick(Sender: TObject);
begin

  ShellExecute(Application.Handle,'open',Pchar('https://github.com/elbereth/DragonUnPACKer/issues'),nil,nil, SW_SHOWNORMAL);

end;

procedure TfrmError.butCopyClick(Sender: TObject);
begin

  txtError.SelectAll;
  txtError.CopyToClipboard;
  txtError.SelLength := 0;

end;

procedure TfrmError.FormShow(Sender: TObject);
begin

  translateError();

end;

procedure TfrmError.PrepareError;
begin

  details.Clear;

end;

constructor TfrmError.Create(AOwner: TComponent);
begin
  inherited create(AOwner);
  details := TStringList.Create;
end;

destructor TfrmError.destroy;
begin
  if details <> nil then FreeAndNil(details);
  inherited;
end;

procedure TfrmError.OnAppliException(Sender: TObject; E: Exception);
begin
 Try
   prepareError;
   fillTxtError(E, Screen.ActiveForm.Name,Screen.ActiveControl.Name);
 Except
   Application.ShowException(E);
 End;
 FreeAndNil(e);
end;

end.
