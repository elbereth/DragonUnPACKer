unit MsgBox;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, RichMemo;

type
  TfrmMsgBox = class(TForm)
    butOK: TButton;
    richText: TRichMemo;
    procedure butOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMsgBox: TfrmMsgBox;

implementation

{$R *.lfm}

procedure TfrmMsgBox.butOKClick(Sender: TObject);
begin

  frmMsgBox.ModalResult := mrOk;

end;

end.
