unit MsgBox;

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
