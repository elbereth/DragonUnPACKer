unit The11thHour;

// $Id: The11thHour.pas,v 1.1.1.1 2004-05-08 10:26:53 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/drivers/11th/The11thHour.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is The11thHour.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TEnableDisableProc = function(verbose: boolean): boolean;
  Tfrm11thHour = class(TForm)
    grp11th: TGroupBox;
    cmdOk: TButton;
    strStatus: TLabel;
    lblStatus: TStaticText;
    cmdEnable: TButton;
    cmdDisable: TButton;
    lblVersion: TLabel;
    Label1: TLabel;
    procedure cmdOkClick(Sender: TObject);
    procedure cmdDisableClick(Sender: TObject);
    procedure cmdEnableClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    enableSupport: TEnableDisableProc;
    disableSupport: TEnableDisableProc;
    stEnabled: string;
    stDisabled: string;
  end;

var
  frm11thHour: Tfrm11thHour;

implementation

{$R *.dfm}

procedure Tfrm11thHour.cmdOkClick(Sender: TObject);
begin

  Close;

end;

procedure Tfrm11thHour.cmdDisableClick(Sender: TObject);
begin

  if disableSupport(true) then
  begin
    lblStatus.Caption := stDisabled;
    cmdEnable.Enabled := true;
    cmdDisable.Enabled := false;
  end;

end;

procedure Tfrm11thHour.cmdEnableClick(Sender: TObject);
begin

  if enableSupport(true) then
  begin
    lblStatus.Caption := stEnabled;
    cmdEnable.Enabled := false;
    cmdDisable.Enabled := true;
  end;

end;

end.
