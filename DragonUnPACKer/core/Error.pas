unit Error;

// $Id: Error.pas,v 1.3 2008-03-04 19:45:31 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/Error.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is Error.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DateUtils, lib_utils, cxCPU40, Main,
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
  end;

var
  frmError: TfrmError;

implementation

{$R *.dfm}

{ TfrmError }

procedure TfrmError.FillTxtError(E: Exception; from, subfrom: String);
var x: byte;
    OSInfo: TOSInfo;
    cxCPU: TcxCPU;
begin

frmError.Height := 153;
cmdDetails.Caption := DLNGStr('BUTDET')+' >>';

txtError.Clear;

lblFrom.Caption := from+' in '+subfrom;
lblEx.Caption := e.ClassName;
lblExMessage.Caption := e.Message;

frmError.Refresh;

OSInfo := GetAllSystemInfo();

txtError.Lines.Add('____________ Error report ____________');
txtError.Lines.Add('');
txtError.Lines.Add('From: '+from+' in '+subfrom);
txtError.lines.add('Exception: '+e.ClassName);
txtError.Lines.Add('Reporting: '+e.Message);
txtError.lines.add('['+DateTimeToStr(now)+']');

txtError.Lines.Add('');

if details <> nil then
begin
  txtError.Lines.Add('____________ More Details ____________');
  txtError.Lines.Add('');

  txtError.Lines.AddStrings(details);

  txtError.Lines.Add('');
end;

txtError.Lines.Add('__________ Computer status: __________');
txtError.Lines.Add('');
txtError.Lines.Add(OSInfo.WinVersion);

cxCpu := TcxCpu.Create;
try
  for x := 1 to cxCpu.ProcessorCount.Available.AsNumber do
  begin
    txtError.Lines.Add('CPU '+inttostr(x)+': '+cxCpu.Processors[x-1].Name.AsString );
  end;
finally
  cxCPU.Free;
end;

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

  ShellExecute(Application.Handle,'open',Pchar('https://sourceforge.net/tracker/?func=add&group_id=108923&atid=652129'),nil,nil, SW_SHOWNORMAL);

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
  if details <> nil then details.Free;
  inherited;
end;

end.
