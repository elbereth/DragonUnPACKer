unit About;

// $Id: About.pas,v 1.1.1.1 2004-05-08 10:25:12 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/About.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is About.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, lib_Utils, ExtCtrls, StdCtrls, JclShell, ComCtrls, JvRichEd;

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
    txtMoreinfo: TJvxRichEdit;
    imgWIP: TImage;
    procedure cmdOkClick(Sender: TObject);
    procedure TimerStartBlendTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblURLClick(Sender: TObject);
    procedure txtMoreinfoURLClick(Sender: TObject; const URLText: String;
      Button: TMouseButton);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.dfm}

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

procedure TfrmAbout.FormCreate(Sender: TObject);
begin


  //TimerStartBlend.Enabled := true;
//  if CheckOs then
//    imgAbout.Picture.Bitmap.LoadFromResourceName(Hinstance,'DUP5W2K')
//  else
//    imgAbout.Picture.Bitmap.LoadFromResourceName(Hinstance,'DUP5W9X');

end;

procedure TfrmAbout.lblURLClick(Sender: TObject);
begin

  ShellExec(application.Handle,'open','http://www.dragonunpacker.com','','',SW_SHOW);

end;

procedure TfrmAbout.txtMoreinfoURLClick(Sender: TObject;
  const URLText: String; Button: TMouseButton);
begin

  ShellExec(application.Handle,'open',URLText,'','',SW_SHOW);

end;

end.
