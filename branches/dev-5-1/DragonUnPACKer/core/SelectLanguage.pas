unit SelectLanguage;

// $Id: SelectLanguage.pas,v 1.1.1.1 2004-05-08 10:25:50 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/SelectLanguage.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is SelectLanguage.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList;

type
  TfrmSelectLanguage = class(TForm)
    lstLangues: TComboBoxEx;
    imgLstLangue: TImageList;
    cmdOk: TButton;
    procedure LNGList();
    procedure FormHide(Sender: TObject);
    procedure cmdOkClick(Sender: TObject);
    procedure lstLanguesSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmSelectLanguage: TfrmSelectLanguage;

implementation

{$R *.dfm}

uses lib_Language, Splash, Registry;

var lngFiles: array[1..100] of String;
    numLngFiles: byte;

procedure TfrmSelectLanguage.LNGList();
var sr: TSearchRec;
    Name,Author,URL,Email,FontName: string;
    itmx : TComboExItem;
    IsIcon: Boolean;
    Sel, IcnIdx: integer;
    Icn: TBitmap;
begin

  Icn := TBitmap.Create;
  imgLstLangue.GetBitmap(0,Icn);
  imgLstLangue.Clear;
  imgLstLangue.Add(Icn,Nil);
  lstLangues.Clear;
  itmx := lstLangues.ItemsEx.Add;
  itmx.Caption := 'Français (French)';
  itmx.ImageIndex := 0;

  Sel := 0;

  if FindFirst(ExtractFilePath(Application.ExeName)+'data\*.lng',0,sr) = 0 then
  begin

    repeat
      if GetLanguageInfo(ExtractFilePath(Application.ExeName)+'data\'+sr.Name,Name,Author,URL,Email,FontName,IsIcon) then
      begin
        itmx := lstLangues.ItemsEx.Add;
        itmx.Caption := Name;
        numLngFiles := numLngFiles + 1;
        lngFiles[numLngFiles] := sr.Name;
        if sr.Name = curlanguage then
          Sel := itmx.Index;
        if IsIcon then
        begin
          Icn := GetIcon(ExtractFilePath(Application.ExeName)+'data\'+sr.Name);
          Icn.TransparentColor := clBlack;
          Icn.Transparent := True;
          IcnIdx := imgLstLangue.Add(icn,nil);

          if IcnIdx <> -1 then
            itmx.ImageIndex := IcnIdx;
        end;

      end;
    until FindNext(sr) <> 0;

    FindClose(sr);
  end;

  lstLangues.ItemIndex := Sel;

end;

procedure TfrmSelectLanguage.FormHide(Sender: TObject);
begin

  lstLanguesSelect(nil);
  Close;

end;

procedure TfrmSelectLanguage.cmdOkClick(Sender: TObject);
begin

  lstLanguesSelect(nil);
  Close;

end;

procedure TfrmSelectLanguage.lstLanguesSelect(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      if lstLangues.ItemIndex = 0 then
        Reg.WriteString('Language','*')
      else
        Reg.WriteString('Language',lngFiles[lstLangues.ItemIndex]);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure TfrmSelectLanguage.FormShow(Sender: TObject);
begin

  LNGList;

end;

end.
