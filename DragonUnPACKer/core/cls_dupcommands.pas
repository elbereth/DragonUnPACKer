unit cls_dupcommands;

{$MODE Delphi}

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is cls_dupcommands.pas, released August 18, 2013.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses Classes, ComCtrls, Forms, lib_language, prg_ver, SysUtils, VirtualTrees;

// The class for commands toward main form of Dragon UnPACKer
{$M+}
type TDupCommands = class(TObject)
     private
       _MainForm: TForm;
       _StatusBar: TStatusBar;
       _ProgressBar: TProgressBar;
       _LstIndex: TVirtualStringTree;
       _LstContent: TVirtualStringTree;
       _SavedTitle: String;
       _TempFiles: TStrings;
     published
       constructor Create(MainForm: TForm; StatusBar: TStatusBar; ProgressBar: TProgressBar; LstContent, LstIndex: TVirtualStringTree; TempFiles: TStrings);
       procedure DisplayPercent(intPercent: integer);
       procedure AddTempFile(TempFile: String);
       function LstIndexAddChild(Parent: PVirtualNode): PVirtualNode;
       function LstIndexGetNodeData(Node: PVirtualNode): Pointer;
       procedure LstIndexFocusRootNode(Root: PVirtualNode);
       procedure RestoreTitle();
       procedure SaveTitle();
       procedure SetFilesNumber(intFilesNumber: integer);
       procedure SetFilesSizes(intFilesSizes: int64);
       procedure SetFormat(strFormat: String);
       procedure SetLstContentRootNodeCount(intNodeCount: integer);
       procedure SetStatus(strStatus: string);
       procedure SetTitle(strTitle: String = '');
       procedure SetTitleDefault();
     end;

implementation

// Create a Dup Command Facility
constructor TDupCommands.Create(MainForm: TForm; StatusBar: TStatusBar; ProgressBar: TProgressBar; LstContent, LstIndex: TVirtualStringTree; TempFiles: TStrings);
begin

  _LstContent := LstContent;
  _LstIndex := LstIndex;
  _MainForm := MainForm;
  _ProgressBar := ProgressBar;
  _StatusBar := StatusBar;
  _TempFiles := TempFiles;

end;

procedure TDupCommands.SetStatus(strStatus: String);
begin

  _StatusBar.Panels.Items[2].Text := strStatus;
  _MainForm.Refresh;

end;

procedure TDupCommands.SetFilesNumber(intFilesNumber: integer);
begin

  _StatusBar.Panels.Items[0].Text := IntToStr(intFilesNumber) + ' ' + DLNGStr('STAT10');
  _MainForm.Refresh;

end;

procedure TDupCommands.SetFilesSizes(intFilesSizes: int64);
begin

  _StatusBar.Panels.Items[1].Text := IntToStr(intFilesSizes) + ' ' + DLNGStr('STAT20');
  _MainForm.Refresh;

end;

procedure TDupCommands.SetTitle(strTitle: String = '');
var strTitleComplete: string;
begin

  strTitleComplete := 'Dragon UnPACKer v'+CurVersion+' '+CurEdit;

  if (strTitle <> '') then
    strTitleComplete := strTitleComplete + ' - '+strTitle;

  _MainForm.Caption := strTitleComplete;
  application.Title := _MainForm.Caption;
  _MainForm.Refresh;

end;

procedure TDupCommands.SetTitleDefault();
begin

  SetTitle();

end;

procedure TDupCommands.SaveTitle();
var seppos: integer;
begin

  seppos := pos(' - ',_MainForm.Caption);
  _SavedTitle := Copy(_MainForm.Caption,seppos+3,Length(_MainForm.Caption)-seppos-2);

end;

procedure TDupCommands.RestoreTitle();
begin

  if _SavedTitle <> '' then
    SetTitle(_SavedTitle);

end;

procedure TDupCommands.DisplayPercent(intPercent: integer);
begin

  if intPercent < 0 then
    intPercent := 0;
  if intPercent > 100 then
    intPercent := 100;
  _ProgressBar.Position := intPercent;
  _ProgressBar.Refresh;

end;

procedure TDupCommands.SetLstContentRootNodeCount(intNodeCount: integer);
begin

  _LstContent.RootNodeCount := intNodeCount;

end;

procedure TDupCommands.SetFormat(strFormat: String);
begin

  _StatusBar.Panels.Items[3].Text := strFormat;
  _MainForm.Refresh;

end;

function TDupCommands.LstIndexAddChild(Parent: PVirtualNode): PVirtualNode;
begin

  result := _LstIndex.AddChild(Parent);

end;


function TDupCommands.LstIndexGetNodeData(Node: PVirtualNode): Pointer;
begin

  result := _LstIndex.GetNodeData(Node);

end;

procedure TDupCommands.LstIndexFocusRootNode(Root: PVirtualNode);
begin

  _LstIndex.RootNodeCount := 1;
  _LstIndex.FocusedNode := Root;

end;

procedure TDupCommands.AddTempFile(TempFile: String);
begin

  _TempFiles.Add(TempFile);

end;

end.
