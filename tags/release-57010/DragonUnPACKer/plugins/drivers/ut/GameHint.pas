unit GameHint;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
