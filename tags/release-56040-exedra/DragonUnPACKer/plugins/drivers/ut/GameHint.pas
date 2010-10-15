unit GameHint;

// $Id: GameHint.pas,v 1.2 2005-12-13 23:24:27 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/drivers/ut/GameHint.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is GameHint.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmGameHint = class(TForm)
    panOpen: TPanel;
    lblOpening: TLabel;
    lstGameHints: TComboBox;
    chkDontAsk: TCheckBox;
    butOK: TButton;
    procedure butOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGameHint: TfrmGameHint;

implementation

{$R *.dfm}

procedure TfrmGameHint.butOKClick(Sender: TObject);
begin

  ModalResult := lstGameHints.ItemIndex + 1;

end;

end.
