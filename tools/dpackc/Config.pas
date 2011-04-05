unit Config;

// $Id: Config.pas,v 1.2 2006-01-30 10:49:13 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/tools/dpackc/Config.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is Config.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, StrUtils, lib_version;

type
  TfrmPackCfg = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    chkDUP5: TCheckBox;
    optCompSup: TRadioButton;
    optCompInf: TRadioButton;
    optCompDiff: TRadioButton;
    optCompEqual: TRadioButton;
    txtDUP5Version: TEdit;
    TabSheet3: TTabSheet;
    Label3: TLabel;
    txtName: TEdit;
    Label4: TLabel;
    txtURL: TEdit;
    Label5: TLabel;
    txtAuthor: TEdit;
    Label6: TLabel;
    txtComment: TEdit;
    TabSheet4: TTabSheet;
    chkImagePerso: TCheckBox;
    txtImageFile: TEdit;
    butBrowseImage: TButton;
    butOk: TButton;
    SaveDialog: TSaveDialog;
    txtVersion: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    lblVersion: TStaticText;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    procedure butOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure txtVersionChange(Sender: TObject);
    procedure txtDUP5VersionChange(Sender: TObject);
    procedure optCompSupClick(Sender: TObject);
    procedure optCompEqualClick(Sender: TObject);
    procedure optCompInfClick(Sender: TObject);
    procedure optCompDiffClick(Sender: TObject);
    procedure chkDUP5Click(Sender: TObject);
    procedure txtNameChange(Sender: TObject);
    procedure txtURLChange(Sender: TObject);
    procedure txtAuthorChange(Sender: TObject);
    procedure txtCommentChange(Sender: TObject);
    procedure chkImagePersoClick(Sender: TObject);
    procedure txtImageFileChange(Sender: TObject);
    procedure butBrowseImageClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmPackCfg: TfrmPackCfg;

implementation

uses Main;

{$R *.dfm}

procedure TfrmPackCfg.butOkClick(Sender: TObject);
begin

  frmPackCfg.Close;

end;

procedure TfrmPackCfg.FormShow(Sender: TObject);
begin

  txtVersion.Text := IntToStr(frmMain.packVersion);

end;

procedure TfrmPackCfg.txtVersionChange(Sender: TObject);
begin

  lblVersion.Caption := getVersion(strtoint(txtVersion.Text));
  frmMain.PackVersion := StrToInt(txtVersion.Text);

end;

procedure TfrmPackCfg.txtDUP5VersionChange(Sender: TObject);
begin

  frmMain.PackDUP5Version := StrToInt(txtDUP5Version.Text);

end;

procedure TfrmPackCfg.optCompSupClick(Sender: TObject);
begin

  frmMain.PackDUP5Comp := 0;

end;

procedure TfrmPackCfg.optCompEqualClick(Sender: TObject);
begin

  frmMain.PackDUP5Comp := 1;

end;

procedure TfrmPackCfg.optCompInfClick(Sender: TObject);
begin

  frmMain.PackDUP5Comp := 2;

end;

procedure TfrmPackCfg.optCompDiffClick(Sender: TObject);
begin

  frmMain.PackDUP5Comp := 3;

end;

procedure TfrmPackCfg.chkDUP5Click(Sender: TObject);
begin

  frmMain.PackDUP5Check := chkDUP5.Checked;

  if (frmMain.PackDUP5Check) then
  begin
    optCompSup.Enabled := true;
    optCompInf.Enabled := true;
    optCompdiff.Enabled := true;
    optCompEqual.Enabled := true;
    txtDUP5Version.Enabled := true;
  end
  else
  begin
    optCompSup.Enabled := false;
    optCompInf.Enabled := false;
    optCompdiff.Enabled := false;
    optCompEqual.Enabled := false;
    txtDUP5Version.Enabled := false;
  end;

end;

procedure TfrmPackCfg.txtNameChange(Sender: TObject);
begin

  frmMain.PackName := txtName.Text;

end;

procedure TfrmPackCfg.txtURLChange(Sender: TObject);
begin

  frmMain.PackURL := txtURL.Text;

end;

procedure TfrmPackCfg.txtAuthorChange(Sender: TObject);
begin

  frmMain.PackAuthor := txtAuthor.Text;

  end;

procedure TfrmPackCfg.txtCommentChange(Sender: TObject);
begin

  frmMain.PackComment := txtComment.Text;


end;

procedure TfrmPackCfg.chkImagePersoClick(Sender: TObject);
begin

  frmMain.PackImagePerso := chkImagePerso.Checked;

end;

procedure TfrmPackCfg.txtImageFileChange(Sender: TObject);
begin

  frmMain.PackImageFile := txtImageFile.Text;

end;

procedure TfrmPackCfg.butBrowseImageClick(Sender: TObject);
begin

  if saveDialog.execute then
  begin

    txtImageFile.Text := SaveDialog.FileName;

  end;

end;

end.
