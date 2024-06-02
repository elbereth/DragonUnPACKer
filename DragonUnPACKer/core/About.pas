unit About;

{$mode objfpc}{$H+}

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is About.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ShellApi, ComCtrls, RichMemo;

type
  TfrmAbout = class(TForm)
    cmdOk: TButton;
    TimerStartBlend: TTimer;
    lblVersion: TLabel;
    lblURL: TLabel;
    lblFreeware: TLabel;
    ImgAbout: TImage;
    lblCompDate: TLabel;
    Label1: TLabel;
    Shape1: TShape;
    txtMoreinfo: TRichMemo;
    imgWIP: TImage;
    procedure cmdOkClick(Sender: TObject);
    procedure TimerStartBlendTimer(Sender: TObject);
    procedure lblURLClick(Sender: TObject);
    procedure txtMoreinfoURLClick(Sender: TObject; const URLText: String;
      Button: TMouseButton);
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.lfm}

procedure TfrmAbout.cmdOkClick(Sender: TObject);
begin

  frmAbout.Close;

end;

procedure TfrmAbout.TimerStartBlendTimer(Sender: TObject);
begin

  if (frmAbout.AlphaBlendValue = 255) then
  begin
    frmAbout.AlphaBlendValue := 255;
    frmAbout.AlphaBlend := false;
    TimerStartBlend.Enabled := false;
  end
  else
    frmAbout.AlphaBlendValue := frmAbout.AlphaBlendValue + 1;

end;

procedure TfrmAbout.lblURLClick(Sender: TObject);
begin

  ShellExecute(application.Handle,'open',PCHar('http://www.dragonunpacker.com'),nil,nil,SW_SHOW);

end;

procedure TfrmAbout.txtMoreinfoURLClick(Sender: TObject;
  const URLText: String; Button: TMouseButton);
begin

  ShellExecute(application.Handle,'open',PChar(URLText),nil,nil,SW_SHOW);

end;

end.
