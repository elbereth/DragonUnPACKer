unit u_frmExtTool;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  u_ListOfToolsDataStruct;

type
  TfrmExtTool = class(TForm)
    lstTools: TListView;
    txtToolname: TEdit;
    txtToolAuthor: TEdit;
    txtToolComment: TEdit;
    txtToolPath: TEdit;
    txtToolCommand: TEdit;
    txtToolResultest: TEdit;
    rgrpResultTest: TRadioGroup;
    txtToolResultValue: TEdit;
    lstExt: TListBox;
    txtExt: TEdit;
    butExtAdd: TButton;
    butExit: TButton;
    butToolAdd: TButton;
    butExtRemove: TButton;
    Label1: TLabel;
    butToolRemove: TButton;
    txtToolURL: TEdit;
    Bevel1: TBevel;
    lblExtra1: TLabel;
    lblExtra2: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Button1: TButton;
    Label7: TLabel;
    Label8: TLabel;
    shToolName: TShape;
    butToolSave: TButton;
    butToolReset: TButton;
    Label9: TLabel;
    shToolPath: TShape;
    shToolCommand: TShape;
    shToolResultTest: TShape;
    shToolResultvalue: TShape;
    procedure txtExtChange(Sender: TObject);
    procedure butExtRemoveClick(Sender: TObject);
    procedure lstExtClick(Sender: TObject);
    procedure butExtAddClick(Sender: TObject);
    procedure lstToolsClick(Sender: TObject);
    procedure butExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmExtTool: TfrmExtTool;

implementation

{$R *.dfm}

procedure TfrmExtTool.txtExtChange(Sender: TObject);
begin

  butExtAdd.Enabled := (length(txtExt.Text) > 0) and (lstExt.Items.IndexOf(txtExt.Text) = -1);

end;

procedure TfrmExtTool.butExtRemoveClick(Sender: TObject);
var x: integer;
begin

  for x := (lstExt.Items.Count - 1) downto 0 do
    if lstExt.Selected[x] then
      lstExt.Items.Delete(x);

end;

procedure TfrmExtTool.lstExtClick(Sender: TObject);
begin

  butExtRemove.Enabled := (lstExt.SelCount > 0);

end;

procedure TfrmExtTool.butExtAddClick(Sender: TObject);
begin

  butExtAdd.Enabled := (length(txtExt.Text) > 0) and (lstExt.Items.IndexOf(txtExt.Text) = -1);

  if butExtAdd.Enabled then
  begin
    lstExt.Items.Add(txtExt.Text);
    butExtAdd.Enabled := false;
  end;
  
end;

procedure TfrmExtTool.lstToolsClick(Sender: TObject);
var ToolInfo: PToolInfo;
    x: integer;
begin

  butToolRemove.Enabled := (lstTools.SelCount > 0);
  ToolInfo := lstTools.Selected.Data;

  txtToolname.Text := ToolInfo^.name;
  txtToolauthor.Text := ToolInfo^.author;
  txtToolURL.Text := ToolInfo^.URL;
  txtToolcomment.Text := ToolInfo^.comment;
  txtToolpath.Text := ToolInfo^.path;
  txtToolcommand.Text := ToolInfo^.command;
  txtToolresultest.Text := ToolInfo^.resultext;
  rgrpResultTest.ItemIndex := ToolInfo^.resultoktest;
  txtToolResultValue.Text := inttostr(ToolInfo^.resultok);

  lstExt.Clear;
  for x := Low(ToolInfo^.extensions) to High(ToolInfo^.extensions) do
    lstExt.Items.Add(ToolInfo^.extensions[x]);

end;

procedure TfrmExtTool.butExitClick(Sender: TObject);
begin

  Close;

end;

end.
