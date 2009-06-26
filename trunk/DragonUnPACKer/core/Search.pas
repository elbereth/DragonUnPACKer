unit Search;

// $Id: Search.pas,v 1.3 2009-06-26 21:05:31 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/Search.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is Search.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, lib_language, declFSE;

type
  TfrmSearch = class(TForm)
    GroupBox: TGroupBox;
    txtSearch: TEdit;
    cmdSearch: TButton;
    StatusBar: TStatusBar;
    CheckCase: TCheckBox;
    RadioTout: TRadioButton;
    RadioDirOnly: TRadioButton;
    cmdOk: TButton;
    procedure cmdSearchClick(Sender: TObject);
    procedure CheckCaseClick(Sender: TObject);
    procedure RadioToutClick(Sender: TObject);
    procedure RadioDirOnlyClick(Sender: TObject);
    procedure cmdOkClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmSearch: TfrmSearch;

implementation

uses Main, Registry;

{$R *.dfm}

procedure TfrmSearch.cmdSearchClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Options',True) then
    begin
      Reg.WriteString('Search_Text',txtSearch.Text);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  StatusBar.Panels.Items[0].Text := IntToStr(FSE.Search(txtSearch.Text,CheckCase.Checked,CurrentDir,RadioDirOnly.Checked))+' '+DLNGStr('STAT10');

end;

procedure TfrmSearch.CheckCaseClick(Sender: TObject);
var reg: tregistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Options',True) then
    begin
      Reg.WriteBool('Search_Case',checkCase.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmSearch.RadioToutClick(Sender: TObject);
var reg: Tregistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Options',True) then
    begin
      Reg.WriteBool('Search_Type',RadioDirOnly.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmSearch.RadioDirOnlyClick(Sender: TObject);
var reg: tregistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Options',True) then
    begin
      Reg.WriteBool('Search_Type',RadioDirOnly.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmSearch.cmdOkClick(Sender: TObject);
begin

  close;

end;

end.
