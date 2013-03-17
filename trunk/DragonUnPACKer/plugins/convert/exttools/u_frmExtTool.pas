unit u_frmExtTool;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, IniFiles,
  u_ListOfToolsDataStruct;

type
  TfrmExtTool = class(TForm)
    lstTools: TListView;
    txtToolname: TEdit;
    txtToolAuthor: TEdit;
    txtToolComment: TEdit;
    txtToolPath: TEdit;
    txtToolCommand: TEdit;
    txtToolResultExt: TEdit;
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
    shToolResultExt: TShape;
    shToolResultvalue: TShape;
    procedure txtExtChange(Sender: TObject);
    procedure butExtRemoveClick(Sender: TObject);
    procedure lstExtClick(Sender: TObject);
    procedure butExtAddClick(Sender: TObject);
    procedure lstToolsClick(Sender: TObject);
    procedure butExitClick(Sender: TObject);
    procedure txtToolnameChange(Sender: TObject);
    procedure txtToolPathChange(Sender: TObject);
    procedure txtToolCommandChange(Sender: TObject);
    procedure txtToolResultExtChange(Sender: TObject);
    procedure txtToolResultValueChange(Sender: TObject);
    procedure butToolSaveClick(Sender: TObject);
    procedure butToolAddClick(Sender: TObject);
    procedure lstToolsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure butToolResetClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    newListofTools: array of TToolInfo;
    { Private declarations }
    procedure checkSaveButton();
  public
    { Public declarations }
    curPath: string;
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
begin

  butToolRemove.Enabled := (lstTools.SelCount > 0);

  if (lstTools.SelCount = 0) then
    butToolAdd.Click;

end;

procedure TfrmExtTool.butExitClick(Sender: TObject);
begin

  Close;

end;

procedure TfrmExtTool.txtToolnameChange(Sender: TObject);
begin

  if (length(txtToolname.Text) > 0) then
    shToolName.Brush.Color := clLime
  else
    shToolName.Brush.Color := clRed;

  checkSaveButton;

end;

procedure TfrmExtTool.txtToolPathChange(Sender: TObject);
begin

  if Length(txtToolPath.Text) > 0 then
  begin
    if (FileExists(txtToolPath.Text) or FileExists(CurPath+txtToolPath.Text)) then
      shToolPath.Brush.Color := clLime
    else
      shToolPath.Brush.Color := clYellow;
  end
  else
    shToolPath.Brush.Color := clRed;

  checkSaveButton;

end;

procedure TfrmExtTool.txtToolCommandChange(Sender: TObject);
begin

  if Length(txtToolCommand.Text) > 0 then
  begin
    if (Pos('%o',txtToolCommand.Text) > 0) and (Pos('%i',txtToolCommand.Text) > 0) then
      shToolCommand.Brush.Color := clLime
    else
      shToolCommand.Brush.Color := clYellow;
  end
  else
    shToolCommand.Brush.Color := clRed;

  checkSaveButton;

end;

procedure TfrmExtTool.txtToolResultExtChange(Sender: TObject);
begin

  if (Length(txtToolResultExt.Text) > 0) then
    shToolResultExt.Brush.Color := clLime
  else
    shToolResultExt.Brush.Color := clRed;

  checkSaveButton;

end;

procedure TfrmExtTool.txtToolResultValueChange(Sender: TObject);
begin

  if (Length(txtToolResultValue.Text) > 0) then
    shToolResultValue.Brush.Color := clLime
  else
    shToolResultValue.Brush.Color := clRed;

  checkSaveButton;

end;

procedure TfrmExtTool.butToolSaveClick(Sender: TObject);
var iniFile: TMemIniFile;
    ToolInfo: PToolInfo;
    x, resVal: integer;
    iniFileName, inext: string;
    itmX: TListItem;
begin

  // If the tool already exists we retrieve the current data & the ini filename
  if (lstTools.SelCount > 0) then
  begin
    itmX := lstTools.Selected;
    ToolInfo := lstTools.Selected.Data;
    iniFileName := ToolInfo.iniFileName;
  end
  // If not we create a new item in the list and new info
  // Ini file is the name + .ini at the end
  else
  begin
    SetLength(newListOfTools,Length(newListOfTools)+1);
    ToolInfo := @newListOfTools[High(newListOfTools)];
    iniFileName := Trim(txtToolName.Text) + '.ini';
    ToolInfo.iniFileName := iniFileName;
    itmX := lstTools.Items.Add;
    itmX.Data := toolInfo;
  end;

  // Save the new data in the structure
  ToolInfo.enabled := true;
  ToolInfo.name := txtToolName.Text;
  ToolInfo.author := txtToolAuthor.Text;
  ToolInfo.url := txtToolURL.Text;
  ToolInfo.comment := txtToolComment.Text;
  ToolInfo.path := txtToolPath.Text;
  ToolInfo.command := txtToolCommand.Text;
  ToolInfo.resultext := txtToolResultExt.Text;
  ToolInfo.resultoktest := rgrpResultTest.ItemIndex;
  Val(txtToolResultValue.Text, ToolInfo.resultok, resVal);
  if (resVal <> 0) then
    ToolInfo.resultok := 0;
  SetLength(ToolInfo.extensions,lstExt.Count);

  // Prepare the extension list for the ini format
  // Copy the extensions to the array of strings in ToolInfo
  inext := '';
  for x := 0 to lstExt.Count - 1 do
  begin
    inext := inext + lstExt.Items[x] + ' ';
    ToolInfo.extensions[x] := lstExt.Items[x];
  end;
  inext := TrimRight(inext);

  // Create the INI file object
  iniFile := TMemInifile.Create(CurPath+iniFileName);

  // Write the data in the INI file
  try
    iniFile.WriteBool('cnv_exttools','enabled',true);
    iniFile.WriteString('cnv_exttools','name',ToolInfo.name);
    iniFile.WriteString('cnv_exttools','author',ToolInfo.author);
    iniFile.WriteString('cnv_exttools','url',ToolInfo.url);
    iniFile.WriteString('cnv_exttools','comment',ToolInfo.comment);
    iniFile.WriteString('cnv_exttools','path',ToolInfo.path);
    iniFile.WriteString('cnv_exttools','command',ToolInfo.command);
    iniFile.WriteString('cnv_exttools','resultext',ToolInfo.resultext);
    iniFile.WriteInteger('cnv_exttools','resultoktest',ToolInfo.resultoktest);
    iniFile.WriteInteger('cnv_exttools','resultok',ToolInfo.resultok);
    iniFile.WriteString('cnv_exttools','extensions',inext);
    iniFile.UpdateFile;
  finally
    FreeAndNil(iniFile);
  end;

  // Set the value for the item in the list
  itmX.Checked := ToolInfo.enabled;
  itmX.Caption := ToolInfo.name;

end;

procedure TfrmExtTool.butToolAddClick(Sender: TObject);
begin

  if (lstTools.SelCount > 0) then
    lstTools.Selected.Selected := false;

  butToolReset.Click;

end;

procedure TfrmExtTool.lstToolsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var ToolInfo: PToolInfo;
    x: integer;
begin

  if (Selected) then
  begin
    ToolInfo := Item.Data;

    txtToolname.Text := ToolInfo^.name;
    txtToolauthor.Text := ToolInfo^.author;
    txtToolURL.Text := ToolInfo^.URL;
    txtToolcomment.Text := ToolInfo^.comment;
    txtToolpath.Text := ToolInfo^.path;
    txtToolcommand.Text := ToolInfo^.command;
    txtToolresultExt.Text := ToolInfo^.resultext;
    rgrpResultTest.ItemIndex := ToolInfo^.resultoktest;
    txtToolResultValue.Text := inttostr(ToolInfo^.resultok);

    lstExt.Clear;
    for x := Low(ToolInfo^.extensions) to High(ToolInfo^.extensions) do
      lstExt.Items.Add(ToolInfo^.extensions[x]);
  end;

end;

procedure TfrmExtTool.checkSaveButton;
begin

  butToolSave.Enabled := (shToolname.Brush.Color = clLime)
                     and (shToolPath.Brush.Color = clLime)
                     and (shToolResultExt.Brush.Color = clLime)
                     and (shToolResultValue.Brush.Color = clLime);

end;

procedure TfrmExtTool.butToolResetClick(Sender: TObject);
begin

  txtToolname.Text := '';
  txtToolauthor.Text := '';
  txtToolURL.Text := '';
  txtToolcomment.Text := '';
  txtToolpath.Text := '';
  txtToolcommand.Text := '';
  txtToolresultExt.Text := '';
  rgrpResultTest.ItemIndex := 0;
  txtToolResultValue.Text := '';
  lstExt.Clear;

end;

procedure TfrmExtTool.FormDestroy(Sender: TObject);
begin

  SetLength(newListOfTools,0);

end;

end.
