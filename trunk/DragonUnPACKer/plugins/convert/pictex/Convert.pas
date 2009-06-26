unit Convert;

// $Id: Convert.pas,v 1.2 2009-06-26 21:05:32 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/convert/pictex/Convert.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is Convert.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, spec_DPAL;

type
  TfrmConvert = class(TForm)
    grpPal: TGroupBox;
    cmdGo: TButton;
    lstPal: TComboBox;
    cmdAdd: TButton;
    grpAdd: TGroupBox;
    lblSource: TLabel;
    txtSource: TEdit;
    cmdBrowse: TButton;
    lblName: TLabel;
    txtName: TEdit;
    lblAuthor: TLabel;
    txtAuthor: TEdit;
    lblFormat: TLabel;
    lstFormats: TComboBox;
    cmdAddPal: TButton;
    OpenDialog: TOpenDialog;
    cmdRemove: TButton;
    procedure cmdGoClick(Sender: TObject);
    procedure cmdAddClick(Sender: TObject);
    procedure cmdBrowseClick(Sender: TObject);
    procedure txtSourceChange(Sender: TObject);
    procedure txtNameChange(Sender: TObject);
    procedure cmdAddPalClick(Sender: TObject);
    procedure cmdRemoveClick(Sender: TObject);
  private
    procedure checkEnableAdd();
    procedure resetForm();
    { Déclarations privées }
  public
    curPath: string;
    errorMessage: string;
    cnv990: string;
    cnv991: string;
    cnv992: string;
    cnv120: string;
    successMessage: string;
    lstPALFil: TStringList;
    { Déclarations publiques }
  end;

var
  frmConvert: TfrmConvert;

implementation

{$R *.dfm}

procedure TfrmConvert.cmdGoClick(Sender: TObject);
begin

  cmdGo.Tag := -1;
  close;

end;

procedure TfrmConvert.cmdAddClick(Sender: TObject);
begin

  if (height = 217) then
    Height := 87
  else
    Height := 217;

end;

procedure TfrmConvert.cmdBrowseClick(Sender: TObject);
begin

  if (OpeNDialog.Execute) then
  begin
    txtSource.Text := OpenDialog.FileName;
  end;

end;

procedure TfrmConvert.txtSourceChange(Sender: TObject);
var ext: string;
begin

  if (length(txtSource.Text) > 0) then
  begin

    ext := UpperCase(extractfileext(txtSource.Text));
    if (ext = '.PCX') then
      lstFormats.ItemIndex := 0
    else if (ext = '.BMP') then
      lstFormats.ItemIndex := 1
    else if (ext = '.PAL') then
      lstFormats.ItemIndex := 2
    else if (ext = '.PSPPALETTE') then
      lstFormats.ItemIndex := 3
    else
      lstFormats.ItemIndex := 4;

    checkEnableAdd;

  end;

end;

procedure TfrmConvert.checkEnableAdd;
begin

  cmdAddPal.Enabled := (FileExists(txtSource.Text) and (length(txtName.Text ) > 0));

end;

procedure TfrmConvert.txtNameChange(Sender: TObject);
begin

  checkEnableAdd();

end;

function ReplaceValue(substr: string; str: string; newval: string): string;
var possub: integer;
    res: string;
begin

  possub := Pos(substr,str);
  if possub > 0 then
  begin
    res := Copy(str,0,possub-1) + Copy(str,possub+length(substr),length(str)-length(substr)+1);
    Insert(newval,res,possub);
  end
  else
    res := str;

  ReplaceValue := res;

end;

procedure TfrmConvert.cmdAddPalClick(Sender: TObject);
var DPAL: TConvertDPAL;
begin

  if FileExists(CurPath+txtName.Text+'.dpal') then
  begin
    MessageDlg(ReplaceValue('%e',ReplaceValue('%t',ReplaceValue('%f',ErrorMessage,txtSource.Text),'-'),cnv990),mtWarning,[mbOk],0);
  end
  else
  begin
    DPAL := TConvertDPAL.create;
    DPAL.setName(txtName.Text);
    DPAL.setAuthor(txtAuthor.Text);  
    try
      case lstFormats.ItemIndex of
        0: if (DPAL.LoadPCX(txtSource.Text)) then
           begin
             DPAL.SaveToDPAL(CurPath+txtName.Text+'.dpal');
             lstPALFil.Add(txtName.Text+'.dpal');
             lstPal.Items.Add(txtName.Text);
             resetForm();
             MessageDlg(successMessage,mtInformation,[mbOk],0);
           end
           else
             MessageDlg(ReplaceValue('%e',ReplaceValue('%t',ReplaceValue('%f',ErrorMessage,txtSource.Text),'ZSoft Paintbrush PCX v5 (8bpp)'),cnv991),mtWarning,[mbOk],0);
        1: if (DPAL.LoadBMP(txtSource.Text)) then
           begin
             DPAL.SaveToDPAL(CurPath+txtName.Text+'.dpal');
             lstPALFil.Add(txtName.Text+'.dpal');
             lstPal.Items.Add(txtName.Text);
             resetForm();
             MessageDlg(successMessage,mtInformation,[mbOk],0);
           end
           else
             MessageDlg(ReplaceValue('%e',ReplaceValue('%t',ReplaceValue('%f',ErrorMessage,txtSource.Text),'Windows BitMaP (8bpp)'),cnv991),mtWarning,[mbOk],0);
        2: if (DPAL.LoadPAL(txtSource.Text)) then
           begin
             DPAL.SaveToDPAL(CurPath+txtName.Text+'.dpal');
             lstPALFil.Add(txtName.Text+'.dpal');
             lstPal.Items.Add(txtName.Text);
             resetForm();
             MessageDlg(successMessage,mtInformation,[mbOk],0);
           end
           else
             MessageDlg(ReplaceValue('%e',ReplaceValue('%t',ReplaceValue('%f',ErrorMessage,txtSource.Text),'Microsoft Palette (RIFF)'),cnv991),mtWarning,[mbOk],0);
        3: if (DPAL.LoadPSPPALETTE(txtSource.Text)) then
           begin
             DPAL.SaveToDPAL(CurPath+txtName.Text+'.dpal');
             lstPALFil.Add(txtName.Text+'.dpal');
             lstPal.Items.Add(txtName.Text);
             resetForm();
             MessageDlg(successMessage,mtInformation,[mbOk],0);
           end
           else
             MessageDlg(ReplaceValue('%e',ReplaceValue('%t',ReplaceValue('%f',ErrorMessage,txtSource.Text),'Jasc PSP Palette (PSPPALETTE)'),cnv991),mtWarning,[mbOk],0);
        4: if (DPAL.LoadRGB(txtSource.Text)) then
           begin
             DPAL.SaveToDPAL(CurPath+txtName.Text+'.dpal');
             lstPALFil.Add(txtName.Text+'.dpal');
             lstPal.Items.Add(txtName.Text);
             resetForm();
             MessageDlg(successMessage,mtInformation,[mbOk],0);
           end
           else
             MessageDlg(ReplaceValue('%e',ReplaceValue('%t',ReplaceValue('%f',ErrorMessage,txtSource.Text),'Binary RGB'),cnv991),mtWarning,[mbOk],0);
        5: if (DPAL.LoadBGR(txtSource.Text)) then
           begin
             DPAL.SaveToDPAL(CurPath+txtName.Text+'.dpal');
             lstPALFil.Add(txtName.Text+'.dpal');
             lstPal.Items.Add(txtName.Text);
             resetForm();
             MessageDlg(successMessage,mtInformation,[mbOk],0);
           end
           else
             MessageDlg(ReplaceValue('%e',ReplaceValue('%t',ReplaceValue('%f',ErrorMessage,txtSource.Text),'Binary BGR'),cnv991),mtWarning,[mbOk],0);
      end;
    except
      on E:Exception do begin
        MessageDlg(ReplaceValue('%e',ReplaceValue('%t',ReplaceValue('%f',ErrorMessage,txtSource.Text),'Binary BGR'),E.className+'['+E.Message+']'),mtWarning,[mbOk],0);
      end
    end;
    FreeAndNil(DPAL);
  end;

end;

procedure TfrmConvert.resetForm;
begin

  txtSource.Text := '';
  txtName.Text := cnv120;
  cmdAddClick(self);

end;

procedure TfrmConvert.cmdRemoveClick(Sender: TObject);
begin

  if (lstPal.Items.Count > 0) then
  begin
    If (MessageDlg(CNV992,mtConfirmation,[mbYes, mbNo],0)) = mrYes then
    begin
      DeleteFile(curPath + lstPALFil.Strings[lstPal.ItemIndex]);
      lstPALFil.Delete(lstPal.ItemIndex);
      lstPal.Items.Delete(lstPal.ItemIndex);
      if lstPal.Items.Count = 0 then
      begin
        cmdRemove.Enabled := false;
      end
      else
      begin
        lstPal.ItemIndex := 0;
      end;
    end;
  end
  else
    cmdRemove.Enabled := false;

end;

end.
