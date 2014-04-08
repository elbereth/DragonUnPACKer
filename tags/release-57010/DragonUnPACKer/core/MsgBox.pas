unit MsgBox;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TfrmMsgBox = class(TForm)
    butOK: TButton;
    richText: TRichEdit;
    procedure butOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMsgBox: TfrmMsgBox;

implementation

{$R *.dfm}

procedure TfrmMsgBox.butOKClick(Sender: TObject);
begin

  frmMsgBox.ModalResult := mrOk;

end;

end.
