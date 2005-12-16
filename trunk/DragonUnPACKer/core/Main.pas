unit Main;

// $Id: Main.pas,v 1.5 2005-12-16 20:15:47 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/Main.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is Main.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, lib_binCopy, StdCtrls, ComCtrls, ExtCtrls, ToolWin, Menus, ImgList,
  lib_language, translation, ShellApi, JvJCLUtils, VirtualTrees, lib_look,
  DropSource, XPMan, DragDrop, DragDropFile, prg_ver, JvclVer,
  classIconsFromExt, DateUtils, JvMenus,  JvRichEdit,
  JvComponent, cxCpu40, JvBaseDlg, JvBrowseFolder, lib_binutils,
  JvExStdCtrls, commonTypes;

type
  Tdup5Main = class(TForm)
    Splitter: TSplitter;
    ctrlBar: TControlBar;
    Percent: TProgressBar;
    ToolBar: TToolBar;
    Bouton_Ouvrir: TToolButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    imgContents: TImageList;
    imgIndex: TImageList;
    imgLook: TImageList;
    Bouton_Fermer: TToolButton;
    Separateur_1: TToolButton;
    Bouton_Options: TToolButton;
    imgContentsBig: TImageList;
    lstContent: TVirtualStringTree;
    DropFileSource: TDropFileSource;
    imgPopup1: TImageList;
    imgPopup2: TImageList;
    XPManifest: TXPManifest;
    mainMenu: TJvMainMenu;
    menuFichier: TMenuItem;
    menuFichier_Ouvrir: TMenuItem;
    menuEdit: TMenuItem;
    menuEdit_Search: TMenuItem;
    menuTools: TMenuItem;
    menuOptions: TMenuItem;
    menuAbout: TMenuItem;
    menuFichier_Fermer: TMenuItem;
    N9: TMenuItem;
    menuFichier_HyperRipper: TMenuItem;
    N10: TMenuItem;
    menuRecent0: TMenuItem;
    menuRecent1: TMenuItem;
    menuRecent2: TMenuItem;
    N12: TMenuItem;
    menuFichier_Quitter: TMenuItem;
    menuTools_List: TMenuItem;
    menuOptions_Basic: TMenuItem;
    menuOptions_Plugins: TMenuItem;
    menuOptions_Assoc: TMenuItem;
    menuOptions_Look: TMenuItem;
    menuOptions_Convert: TMenuItem;
    menuOptions_Drivers: TMenuItem;
    menuOptions_HyperRipper: TMenuItem;
    menuAbout_About: TMenuItem;
    Popup_Contents: TJvPopupMenu;
    Popup_Extrairevers: TMenuItem;
    N6: TMenuItem;
    Popup_Extrairevers_MODEL: TMenuItem;
    Popup_Extrairevers_Raw: TMenuItem;
    Popup_Extrairemulti: TMenuItem;
    Popup_ExtraireMulti_RAW: TMenuItem;
    N7: TMenuItem;
    Popup_ExtraireMulti_MODEL: TMenuItem;
    Popup_Open: TMenuItem;
    Popup_Index: TJvPopupMenu;
    menuIndex_ExtractAll: TMenuItem;
    menuIndex_ExtractDirs: TMenuItem;
    N1: TMenuItem;
    menuIndex_Expand: TMenuItem;
    menuIndex_Collapse: TMenuItem;
    N2: TMenuItem;
    menuIndex_Infos: TMenuItem;
    DirSelect: TJvBrowseForFolderDialog;
    lstIndex2: TVirtualStringTree;
    PanelStatusEx: TPanel;
    TimerParam: TTimer;
    SplitterBottom: TSplitter;
    Popup_Log: TJvPopupMenu;
    menuLog_Hide: TMenuItem;
    menuLog_Show: TMenuItem;
    panBottom: TPanel;
    Status: TStatusBar;
    N3: TMenuItem;
    menuLog_Clear: TMenuItem;
    richLog: TJvRichEdit;
    procedure FormResize(Sender: TObject);
    procedure menuFichier_QuitterClick(Sender: TObject);
    procedure menuAbout_AboutClick(Sender: TObject);
    procedure menuFichier_OuvrirClick(Sender: TObject);
    procedure lstIndexChange(Sender: TObject; Node: TTreeNode);
    procedure menuFichier_FermerClick(Sender: TObject);
    procedure menuEdit_SearchClick(Sender: TObject);
    procedure menuRecent0Click(Sender: TObject);
    procedure menuRecent1Click(Sender: TObject);
    procedure menuRecent2Click(Sender: TObject);
    procedure menuIndex_InfosClick(Sender: TObject);
    procedure menuIndex_ExtractAllClick(Sender: TObject);
    procedure menuIndex_ExtractDirsClick(Sender: TObject);
    procedure menuOptions_BasicClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Bouton_OptionsClick(Sender: TObject);
    procedure Bouton_FermerClick(Sender: TObject);
    procedure Bouton_OuvrirClick(Sender: TObject);
    procedure menuOptions_DriversClick(Sender: TObject);
    procedure MenuOptions_LookClick(Sender: TObject);
    procedure PopUp_OpenClick(Sender: TObject);
    procedure menuOptions_AssocClick(Sender: TObject);
    procedure menuFichier_HyperRipperClick(Sender: TObject);
    procedure WMUser(var msg: TMessage); message wm_User;
    procedure menuIndex_ExpandClick(Sender: TObject);
    procedure menuIndex_CollapseClick(Sender: TObject);
    procedure Popup_Extrairevers_RAWClick(Sender: TObject);
    procedure Popup_Extrairevers_MODELClick(Sender: TObject);
    procedure Popup_ExtraireMulti_RAWClick(Sender: TObject);
    procedure Popup_ExtraireMulti_MODELClick(Sender: TObject);
    procedure menuOptions_ConvertClick(Sender: TObject);
    procedure lstContentInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure lstContentGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure FormCreate(Sender: TObject);
    procedure lstContentCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure lstContentGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure lstContentHeaderClick(Sender: TVTHeader;
      Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure lstContentContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure closeCurrent();
    procedure lstContentMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function ExtractSelectedFilesToTempDir(): boolean;
    procedure DropFileSourceDrop(Sender: TObject; DragType: TDragType;
      var ContinueDrop: Boolean);
    procedure lstContentStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure TDup5FileQuitExecute(Sender: TObject);
    procedure TDup5FileHyperRipperExecute(Sender: TObject);
    procedure TDup5OptionsExecute(Sender: TObject);
    procedure TDup5OptionsGenExecute(Sender: TObject);
    procedure TDup5OptionsPluginsExecute(Sender: TObject);
    procedure TDup5OptionsAssocExecute(Sender: TObject);
    procedure TDup5OptionsLookExecute(Sender: TObject);
    procedure TDup5PluginsConvertExecute(Sender: TObject);
    procedure TDup5PluginsDriversExecute(Sender: TObject);
    procedure TDup5PluginsHRExecute(Sender: TObject);
//    procedure TDup5HelpAboutExecute(Sender: TObject);
    procedure TDup5FileExecute(Sender: TObject);
    procedure TDup5HelpExecute(Sender: TObject);
    procedure TDup5EditSearchExecute(Sender: TObject);
    procedure TDup5EditExecute(Sender: TObject);
    procedure TDup5FileOpenExecute(Sender: TObject);
    procedure TDup5FileCloseExecute(Sender: TObject);
    procedure TDup5ToolsListExecute(Sender: TObject);
    function GetNodePath(Nod: TTreeNode): string;
    function GetNodePath2(Nod: PVirtualNode): string;
    procedure lstIndex2GetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure lstIndex2GetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure lstIndex2FocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure lstIndex2CompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure lstIndex2ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TimerParamTimer(Sender: TObject);
    procedure menuLog_ShowClick(Sender: TObject);
    procedure menuLog_HideClick(Sender: TObject);
    procedure Popup_LogPopup(Sender: TObject);
    procedure menuLog_ClearClick(Sender: TObject);
  private
    verboseLevel: integer;
    AlreadyDragging: boolean;
    bottomHeight: integer;
    procedure Open_Hub(src: String);
    procedure setRichEditLineStyle(R: TJvRichEdit; Line: Integer;
      Style: TFontStyles);
    procedure setRichEditLineColor(R: TJvRichEdit; Line: Integer;
      Color: TColor);
  public
    function getVerboseLevel(): integer;
    procedure setVerboseLevel(verbLevel: integer);
    procedure writeLog(text: string);
    procedure writeLogVerbose(minLevel: integer; text: string);
    procedure appendLog(text: string);
    procedure appendLogVerbose(minLevel: integer; text: string);
    procedure styleLog(Style : TFontStyles);
    procedure styleLogVerbose(minLevel: integer; Style : TFontStyles);
    procedure colorLog(Color : TColor);
    procedure colorLogVerbose(minLevel: integer; Color : TColor);
    procedure separatorLog();
    procedure separatorLogVerbose(minLevel: integer);
    { Déclarations publiques }
  end;

var
  dup5Main: Tdup5Main;
  CurFile: integer = 0;
  CurrentDir: string;
  SortMode: integer;
  SortOrder: boolean = true;
  debugDrop: boolean = true;
  menuVar: byte;
  icons: TIconsFromExt;

implementation

uses About, Registry, lib_utils, Search,
     DrvInfo, Options, Splash, spec_DULK, declFSE,
     HyperRipper, classConvert, classFSE, List, Error;

var
  RecentFiles: array[0..9] of String;
  TempFiles: TStrings;
  msgBuf: String;
  CListInfo: extConvertList;

{$R *.dfm}

{$Include datetime.inc}

procedure Tdup5Main.Open_Hub(src: String);
var Reg: TRegistry;
    res: boolean;
    loadRes: TDriverLoadResult;
begin

  Res := false;
  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      if Reg.ValueExists('UseHyperRipper') then
        Res := Reg.ReadBool('UseHyperRipper');
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  separatorLog;
  writeLog(ReplaceStr(DLNGStr('LOG101'),'%f',src));

  loadRes := FSE.LoadFile(src, res);

  if (loadRes = dlOk) then
  begin
    Caption := 'Dragon UnPACKer v' + CurVersion + ' ' + CurEdit+ ' - '+src;
    menuFichier_Fermer.Enabled := True;
    Bouton_Fermer.Enabled := True;
    menuEdit.Visible := True;
    menuTools.Visible := True;
    Status.Panels.Items[3].Text := FSE.DriverID;
  end
  else
  begin

    if loadRes = dlCouldNotLoad then
      writeLog(DLNGStr('LOG102'))
    else if loadRes = dlFileNotFound then
    begin
      appendLog(DLNGStr('LOG104'));
      colorLog($000070FF);
    end
    else if loadRes = dlError then
    begin
      writeLog(DLNGStr('LOG513'));
      colorLog(clRed);
    end;

    if res and (loadRes <> dlFileNotFound) then
    begin
      writeLog(DLNGStr('LOG103'));
      frmHyperRipper.Show;
      frmHyperRipper.txtSource.Text := src;
    end;

  end;

end;

procedure RecentFiles_Save();
var reg: TRegistry;
    x: integer;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Options',True) then
    begin
      for x:=0 to 9 do
        Reg.WriteString('Recent_'+IntToStr(x),RecentFiles[x]);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure RecentFiles_Display();
begin

  if length(RecentFiles[0]) > 0 then
  begin
    dup5Main.menuRecent0.Caption := '1. '+RecentFiles[0];
    dup5Main.menuRecent0.Visible := true;
  if length(RecentFiles[1]) > 0 then
  begin
    dup5Main.menuRecent1.Caption := '2. '+RecentFiles[1];
    dup5Main.menuRecent1.Visible := true;
  if length(RecentFiles[2]) > 0 then
  begin
    dup5Main.menuRecent2.Caption := '3. '+RecentFiles[2];
    dup5Main.menuRecent2.Visible := true;
  end;
  end;
  end;

end;

procedure RecentFiles_Load();
var reg: TRegistry;
    x: integer;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Options',True) then
    begin
      for x:=0 to 9 do
        if Reg.ValueExists('Recent_'+IntToStr(x)) then
          RecentFiles[x] := Reg.ReadString('Recent_'+IntToStr(x));
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  RecentFiles_Display;

end;

procedure RecentFiles_Add(newfile: string);
var x: integer;
begin

  if RecentFiles[0] <> newfile then
  begin
    for x := 8 downto 0 do
      RecentFiles[x+1] := RecentFiles[x];

    RecentFiles[0] := newfile;
    RecentFiles_Display;
    RecentFiles_Save;
  end;

end;

procedure RecentFiles_Decal(oldpos: integer);
var tmps: string;
    x: integer;
begin

  tmps := RecentFiles[oldPos];
  for x := oldpos-1 downto 0 do
    RecentFiles[x+1] := RecentFiles[x];

  RecentFiles[0] := tmps;

  RecentFiles_Save;
  RecentFiles_Display;

end;

procedure Tdup5Main.FormResize(Sender: TObject);
var fsize, x : integer;
begin

  fsize := Status.Width;
  for x:=2 to Status.Panels.Count-1 do
    dec(fsize,Status.Panels[x].Width);
  fsize := fsize div 2;
  Status.Panels[0].Width := fsize;
  Status.Panels[1].Width := fsize;
  PanelStatusEx.Top := Status.Top + 2;
  PanelStatusEx.Width := Status.Panels[0].Width + Status.Panels[1].Width;

end;

procedure Tdup5Main.menuFichier_QuitterClick(Sender: TObject);
begin

  if (Not FSE.IsListEmpty) then
    menuFichier_Fermer.Click;

  Application.Terminate;

end;

procedure Tdup5Main.setRichEditLineStyle(R : TJvRichEdit; Line : Integer; Style : TFontStyles);
var
 oldPos,
 oldSelLength : Integer;
 Line_Index : Integer;
 To_Line_Index : Integer;
 Line_Range : Integer;
begin
 OldPos := R.SelStart;
 oldSelLength := R.SelLength;
 Try
   Line_Index := R.Perform(EM_LINEINDEX,Line-1,0);
   if Line_Index > - 1 then
   begin
     to_Line_Index := R.Perform(EM_LINEINDEX,Line,0);
     if to_Line_Index < Line_Index then
       Line_Range := Length(R.Text)-Line_Index
     else
       Line_Range := to_Line_Index-Line_Index;
     R.SelStart := Line_Index;
     R.SelLength := Line_Range;
     R.SelAttributes.Style := Style;
   end;
 finally
   R.SelStart := OldPos;
   R.SelLength := oldSelLength;
 end;
end;

procedure Tdup5Main.setRichEditLineColor(R : TJvRichEdit; Line : Integer; Color : TColor);
var
 oldPos,
 oldSelLength : Integer;
 Line_Index : Integer;
 To_Line_Index : Integer;
 Line_Range : Integer;
begin
 OldPos := R.SelStart;
 oldSelLength := R.SelLength;
 Try
   Line_Index := R.Perform(EM_LINEINDEX,Line-1,0);
   if Line_Index > - 1 then
   begin
     to_Line_Index := R.Perform(EM_LINEINDEX,Line,0);
     if to_Line_Index < Line_Index then
       Line_Range := Length(R.Text)-Line_Index
     else
       Line_Range := to_Line_Index-Line_Index;
     R.SelStart := Line_Index;
     R.SelLength := Line_Range;
     R.SelAttributes.Color := Color;
   end;
 finally
   R.SelStart := OldPos;
   R.SelLength := oldSelLength;
 end;
end;

procedure Tdup5Main.menuAbout_AboutClick(Sender: TObject);
begin

  TranslateAbout;
  frmAbout.txtMoreinfo.Clear;

  frmAbout.txtMoreinfo.Visible := false;
  frmAbout.txtMoreinfo.Lines.Add('');
  frmAbout.txtMoreinfo.Lines.Add(DLNGstr('ABT002'));
  frmAbout.txtMoreinfo.Lines.Add('elbereth@user.sourceforge.net');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsItalic]);
  frmAbout.txtMoreinfo.Lines.Add('');
  frmAbout.txtMoreinfo.Lines.Add(DLNGstr('ABT004'));
  frmAbout.txtMoreinfo.Lines.Add('JVCL v'+JVCL_VERSIONSTRING);
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('http://jvcl.sourceforge.net');
  frmAbout.txtMoreinfo.Lines.Add('VirtualTree v'+VTVersion);
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('http://www.delphi-gems.com');
  frmAbout.txtMoreinfo.Lines.Add('cxCpu v'+cxCpu.Version.FormatVersion);
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('http://www.carbonsoft.com/cxcpu/');
  frmAbout.txtMoreinfo.Lines.Add('Drag and Drop Component Suite');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('http://www.users.on.net/johnson/delphi/');

//  Compile Time Expert

  frmAbout.txtMoreinfo.Lines.Add('');
  frmAbout.txtMoreinfo.Lines.Add(DLNGStr('ABT005'));
  frmAbout.txtMoreinfo.Lines.Add('Babagunush');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('capt.ahab');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('ChaosSystem');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('Kirschsaft');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('Kostolomac.TK');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('MindMaker');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('RomSonic');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('Zethy');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('');

  frmAbout.txtMoreinfo.Lines.Add(DLNGstr('ABT006'));
  frmAbout.txtMoreinfo.Lines.Add('Andrew Bondar');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('Fabrizio "Rush" Degni');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('Felix Riemann');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('indirect Y');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('Jakub "Cubituss" Kowalski');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('Kostolomac.TK');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('Macsi Gergely');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('Mircha Houtkooper');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('Mohammad Atiyeh Deeb');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);
  frmAbout.txtMoreinfo.Lines.Add('Reza Kianrad');
  setRichEditLineStyle(frmAbout.txtMoreinfo,frmAbout.txtMoreinfo.Lines.Count,[fsBold]);

  frmAbout.txtMoreinfo.Visible := true;

  if CurEdit = '' then
    frmAbout.lblVersion.Caption := CurVersion + ' (Build ' + IntToStr(CurBuild) +')'
  else
    frmAbout.lblVersion.Caption := CurVersion + ' ' + CurEdit + ' (Build ' + IntToStr(CurBuild) +')';
  frmAbout.Top := dup5Main.Top + ((Height - frmAbout.Height) div 2) ;
  frmAbout.Left := dup5Main.Left + ((Width - frmAbout.Width) div 2) ;

  frmAbout.lblCompDate.Caption := DateToStr(compileTime)+ ' '+TimeToStr(compileTime);

  if (pos('WIP',Uppercase(CurEdit)) > 0) then
    frmAbout.imgWIP.visible := true
  else
    frmAbout.imgWIP.visible := false;

  frmAbout.ShowModal;

end;

procedure Tdup5Main.menuFichier_OuvrirClick(Sender: TObject);
var src, exts : string;
    extlist: ExtensionsResult;
    cl,t : integer;
begin

extlist := FSE.GetAllFileTypes(True);
if extlist.Num > 1 then
begin
  for cl := 1 to extlist.Num do
  begin
    t := pos(';',extlist.lists[cl]);
    if exts <> '' then
    begin
      if t > 0 then
        exts := exts +'|'+DLNGStr('ALLCMP') + ' ('+Uppercase(Copy(extlist.lists[cl],0,t-1))+' -> '+Uppercase(Copy(extlist.lists[cl],posrev(';',extlist.lists[cl])+1,length(extlist.lists[cl])-PosRev(';',extlist.lists[cl])))+ ')|'+extlist.lists[cl]
      else
        exts := exts +'|'+DLNGStr('ALLCMP') + ' ('+Uppercase(extlist.lists[cl])+')|'+extlist.lists[cl]
    end
    else
      exts := DLNGStr('ALLCMP') + ' ('+Uppercase(Copy(extlist.lists[cl],0,t-1))+' -> '+Uppercase(Copy(extlist.lists[cl],posrev(';',extlist.lists[cl])+1,length(extlist.lists[cl])-PosRev(';',extlist.lists[cl])))+ ')|'+extlist.lists[cl];
  end;
end
else
  exts := DLNGStr('ALLCMP') + '|' + extlist.lists[1];

OpenDialog.Filter := exts + '|'+DLNGStr('ALLFIL')+'|*.*' + '|' + FSE.GetFileTypes;

if extlist.Num > 1 then
  OpenDialog.FilterIndex := extlist.Num+1
else
  OpenDialog.FilterIndex := 1;

OpenDialog.Title := DLNGStr('OPEN00');

if length(RecentFiles[0]) > 0 then
  OpenDialog.FileName := RecentFiles[0];

if OpenDialog.Execute then
begin
  CloseCurrent;
  src := OpenDialog.FileName;
  RecentFiles_Add(src);
  Open_HUB(src);
end

end;

function Tdup5Main.GetNodePath(Nod: TTreeNode): string;
var res: string;
begin
  if Not(Nod.IsFirstNode) then
  begin
    res := GetNodePath(Nod.Parent);
    if length(res)>0 then
      res := res + FSE.SlashMode;
    res := res + Nod.text;
  end
  else
    res := '';
  GetNodePath := res;
end;

procedure Tdup5Main.lstIndexChange(Sender: TObject; Node: TTreeNode);
var disp: string;
begin

  disp := GetNodePath(Node);
  FSE.BrowseDir(disp);
  CurrentDir := disp;

end;

procedure Tdup5Main.menuFichier_FermerClick(Sender: TObject);
begin

  CloseCurrent;

end;

procedure RegNothing();
begin

end;

procedure Tdup5Main.menuEdit_SearchClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Options',True) then
    begin
      if Reg.ValueExists('Search_Text') then
        frmSearch.txtSearch.Text := Reg.ReadString('Search_Text');
      if Reg.ValueExists('Search_Type') then
        frmSearch.RadioDirOnly.Checked := Reg.ReadBool('Search_Type');
      if Reg.ValueExists('Search_Case') then
        frmSearch.checkCase.Checked := Reg.ReadBool('Search_Case');
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  TranslateSearch;
  frmSearch.ShowModal;

end;

procedure Tdup5Main.menuRecent0Click(Sender: TObject);
begin

  CloseCurrent;
  open_HUB(RecentFiles[0]);

end;

procedure Tdup5Main.menuRecent1Click(Sender: TObject);
begin

  CloseCurrent;
  open_HUB(RecentFiles[1]);
  RecentFiles_Decal(1);

end;

procedure Tdup5Main.menuRecent2Click(Sender: TObject);
begin

  CloseCurrent;
  open_HUB(RecentFiles[2]);
  RecentFiles_Decal(2);

end;

procedure Tdup5Main.menuIndex_InfosClick(Sender: TObject);
begin

  TranslateInfos;

  frmDrvInfo.lblFileFormat.Caption := Status.Panels.Items[3].Text;
  frmDrvInfo.lblFileEntries.Caption := IntToStr(FSE.GetNumEntries);
  frmDrvInfo.lblFileLoadTime.Caption := IntToStr(FSE.GetLoadTime(1))+'ms/'+IntToStr(FSE.GetLoadTime(2))+'ms/'+IntToStr(FSE.GetLoadTime(3))+'ms';
  frmDrvInfo.lblFileTotalTime.Caption := IntToStr(FSE.GetLoadTime(0))+'ms';
  frmDrvInfo.lblFileSize.Caption := IntToStr(FSE.GetFileSize)+' '+DLNGStr('STAT20');

  frmDrvInfo.lblName.Caption := FSE.CurrentDriverInfos.Name;
  frmDrvInfo.lblAuthor.Caption := FSE.CurrentDriverInfos.Author;
  frmDrvInfo.lblComment.Caption := FSE.CurrentDriverInfos.Comment;
  frmDrvInfo.lblVersion.Caption := FSE.CurrentDriverInfos.Version;
  frmDrvInfo.ShowModal;

end;

function CallDirSelect(): String;
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Options',True) then
    begin
      if Reg.ValueExists('Dir_Path') then
      begin
        dup5Main.DirSelect.Directory := Reg.ReadString('Dir_Path');
//        frmDirSelect.Drive.Drive := Reg.ReadString('Dir_Path')[1];
//        frmDirSelect.DirList.Directory := Reg.ReadString('Dir_Path');
      end;
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  dup5Main.DirSelect.Title := DLNGStr('DIRTIT');

//  TranslateDirSelect();

//  Canceled := True;
//  frmDirSelect.DirList.Update;
//  frmDirSelect.ShowModal;
  if dup5Main.DirSelect.Execute then
  begin
//    result := frmDirSelect.DirList.Directory;
    result := dup5Main.DirSelect.Directory;

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Options',True) then
      begin
//        Reg.WriteString('Dir_Path',frmDirSelect.DirList.Directory);
        Reg.WriteString('Dir_Path',dup5Main.DirSelect.Directory);
        Reg.CloseKey;
      end;
    Finally
      Reg.Free;
    end;
  end
  else
    result := '';

end;

procedure CreateDirs(Nod: TTreeNode; Pth: String);
var NodC: TTreeNode;
    NewDir: string;
begin

//  MessageDlg(Nod.Text, mtInformation,[mbok],0);

  if Nod.HasChildren then
  begin

    NodC := Nod.getFirstChild;

    while NodC <> Nil do
    begin
      NewDir := Pth + NodC.text;
//      MessageDlg(NewDir,mtInformation,[mbok],0);
      CreateDir(NewDir);
      CreateDirs(NodC,NewDir+'\');
      NodC := Nod.GetNextChild(NodC)
    end;

  end;

end;

procedure CreateDirs2(Nod: PVirtualNode; Pth: String);
var NodC: PVirtualNode;
    NodeData: pvirtualIndexData;
    NewDir: string;
begin

//  MessageDlg(Nod.Text, mtInformation,[mbok],0);

  if Nod.ChildCount > 0 then
  begin

    NodC := Nod.FirstChild;
//    duP5Main.lstIndex2.get NodC.

    while NodC <> Nil do
    begin
      NodeData := dup5main.lstIndex2.GetNodeData(NodC); 
      NewDir := Pth + NodeData.dirname;
//      MessageDlg(NewDir,mtInformation,[mbok],0);
      CreateDir(NewDir);
      CreateDirs2(NodC,NewDir+'\');
      NodC := NodC.NextSibling;
    end;

  end;

end;

procedure Tdup5Main.menuIndex_ExtractDirsClick(Sender: TObject);
var outputdir: string;
begin

  outputdir := CallDirSelect;
  if length(outputdir)>0 then
  begin
    if copy(outputdir,length(outputdir),1) <> '\' then
      outputdir := outputdir + '\';

    CreateDirs2(lstIndex2.FocusedNode,outputdir);
    FSE.ExtractDir(GetNodePath2(lstIndex2.FocusedNode),outputdir)

  end

end;

procedure Tdup5Main.menuIndex_ExtractAllClick(Sender: TObject);
var outputdir: string;
begin

  outputdir := CallDirSelect;
  if length(outputdir)>0 then
  begin
    if copy(outputdir,length(outputdir),1) <> '\' then
      outputdir := outputdir + '\';

    CreateDirs2(lstIndex2.FocusedNode,outputdir);
    FSE.ExtractDir('',outputdir)

  end

end;

procedure InitOptions;
begin

  frmConfig.Top := dup5Main.Top + ((dup5Main.Height - frmConfig.Height) div 2) ;
  frmConfig.Left := dup5Main.Left + ((dup5Main.Width - frmConfig.Width) div 2) ;
  TranslateOptions;

end;

procedure Tdup5Main.menuOptions_BasicClick(Sender: TObject);
begin

  InitOptions;

  TabSelect := 0;
  frmConfig.ShowModal;

end;

procedure Tdup5Main.FormHide(Sender: TObject);
var Reg: TRegistry;
    x: integer;
begin

  if (CurFile > 0) then
    CloseCurrent;

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Windows',True) then
    begin
      Reg.WriteInteger('Main_X',Left);
      Reg.WriteInteger('Main_Y',Top);
      Reg.WriteInteger('Main_H',Height);
      Reg.WriteInteger('Main_W',Width);
      Reg.WriteInteger('Main_S',lstIndex2.Width);
      if richLog.Visible then
        Reg.WriteInteger('Main_B',panBottom.Height)
      else
        Reg.WriteInteger('Main_B',bottomHeight);
      Reg.WriteInteger('lstContent_0',lstContent.Header.Columns.Items[0].Width);
      Reg.WriteInteger('lstContent_1',lstContent.Header.Columns.Items[1].Width);
      Reg.WriteInteger('lstContent_2',lstContent.Header.Columns.Items[2].Width);
      Reg.WriteInteger('lstContent_3',lstContent.Header.Columns.Items[3].Width);
      Reg.WriteInteger('toolBar_T',toolBar.Top);
      Reg.WriteInteger('toolBar_L',ToolBar.Left);
      Reg.WriteInteger('Percent_T',Percent.Top);
      Reg.WriteInteger('Percent_L',Percent.Left);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  FSE.FreeDrivers;
  FSE.Free;

  Icons.close;
  Icons.Free;
  
  for x := 0 to TempFiles.Count-1 do
    if FileExists(TempFiles.Strings[x]) and Not(DeleteFile(TempFiles.Strings[x])) then
      MessageDlg(ReplaceValue('%f',DLNGStr('ERRTMP'),TempFiles.Strings[x]),mtWarning,[mbOk],0);

  TempFiles.Free;

  Application.Terminate;

end;

procedure PercentCB(p: byte);
begin

  if p>100 then
    p := 100;
  dup5Main.Percent.Position := p;
  dup5Main.Refresh;

end;

function LanguageCB(lngid: shortstring): shortstring;
begin

  result := DLNGStr(lngid);

end;

procedure Tdup5Main.FormShow(Sender: TObject);
var Reg: TRegistry;
    tmpi: integer;
    clng,clook: string;
begin

  Caption := 'Dragon UnPACKer v' + CurVersion + ' ' + CurEdit;

  if CurEdit = '' then
    dup5Main.writeLog('Dragon UnPACKer v' + CurVersion + ' (Build ' + IntToStr(CurBuild) +' - '+DateToStr(compileTime)+ ' '+TimeToStr(compileTime)+')')
  else
    dup5Main.writeLog('Dragon UnPACKer v' + CurVersion + ' ' + CurEdit + ' (Build ' + IntToStr(CurBuild)  +' - '+DateToStr(compileTime)+ ' '+TimeToStr(compileTime)+')');

  menuEdit.Visible := false;
  menuTools.Visible := false;

  setRegistryDuppi;

  Top := ((Screen.Height - Height) div 2) ;
  Left := ((Screen.Width - Width) div 2) ;

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      Reg.WriteDateTime('LastDateExec', Now);
      Reg.WriteString('Path',ExtractFilePath(Application.Exename));
      Reg.WriteString('Version',CurVersion);
      Reg.WriteString('Edit',CurEdit);
      Reg.WriteInteger('Build',CurBuild);
      if Reg.ValueExists('Language') then
        clng := Reg.ReadString('Language')
      else
        clng := '*';
      if clng = '*' then
        LoadInternalLanguage
      else
        LoadLanguage(ExtractFilePath(Application.ExeName)+'data\'+clng);

      if Reg.ValueExists('ShowLog') then
      begin
        richLog.visible := Reg.ReadBool('ShowLog');
        splitterBottom.Visible := richLog.Visible;
      end;

      if Reg.ValueExists('VerboseLevel') then
      begin
        verboseLevel := reg.ReadInteger('VerboseLevel');
      end;

      if Reg.ValueExists('VerboseLevel') then
        verboseLevel := Reg.ReadInteger('VerboseLevel')
      else
        verboseLevel := 0;

      if Reg.ValueExists('Look') then
        clook := Reg.ReadString('Look')
      else
        clook := 'default.dulk';
{      if Reg.ValueExists('XPStyle') then
        XPMenu.Active := Reg.ReadBool('XPStyle')
      else
        XPMenu.Active := true;}
      Reg.CloseKey;
    end;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Windows',True) then
    begin
      if Reg.ValueExists('Main_H') then
      begin
        tmpi := Reg.ReadInteger('Main_H');
        if tmpi > 0 then
        begin
          Height := tmpi;
          Top := ((Screen.Height - Height) div 2) ;
        end;
      end;
      if Reg.ValueExists('Main_W') then
      begin
        tmpi := Reg.ReadInteger('Main_W');
        if tmpi > 0 then
        begin
          Width := tmpi;
          Left := ((Screen.Width - Width) div 2) ;
        end;
      end;
      if Reg.ValueExists('Main_X') then
      begin
        tmpi := Reg.ReadInteger('Main_X');
        if tmpi > 0 then
          Left := tmpi;
      end;
      if Reg.ValueExists('Main_Y') then
      begin
        tmpi := Reg.ReadInteger('Main_Y');
        if tmpi > 0 then
          Top := tmpi;
      end;
      if Reg.ValueExists('Main_S') then
      begin
        tmpi := Reg.ReadInteger('Main_S');
        if tmpi > 20 then
          lstIndex2.Width := tmpi;
      end;
      if Reg.ValueExists('Main_B') then
      begin
        tmpi := Reg.ReadInteger('Main_B');
        if tmpi > 100 then
          bottomHeight := tmpi
        else
          bottomHeight := 100;
        if richLog.Visible then
          panBottom.Height := bottomHeight
        else
          panBottom.Height := status.Height;
      end;
      if Reg.ValueExists('lstContent_0') then
      begin
        tmpi := Reg.ReadInteger('lstContent_0');
        if tmpi >= 0 then
          lstContent.Header.Columns.Items[0].Width := tmpi;
      end;
      if Reg.ValueExists('lstContent_1') then
      begin
        tmpi := Reg.ReadInteger('lstContent_1');
        if tmpi >= 0 then
          lstContent.Header.Columns.Items[1].Width := tmpi;
      end;
      if Reg.ValueExists('lstContent_2') then
      begin
        tmpi := Reg.ReadInteger('lstContent_2');
        if tmpi >= 0 then
          lstContent.Header.Columns.Items[2].Width := tmpi;
      end;
      if Reg.ValueExists('lstContent_3') then
      begin
        tmpi := Reg.ReadInteger('lstContent_3');
        if tmpi > 0 then
          lstContent.Header.Columns.Items[3].Width := tmpi;
      end;
      if Reg.ValueExists('toolBar_T') then
      begin
        tmpi := Reg.ReadInteger('toolBar_T');
        if tmpi > 0 then
          toolBar.Top := tmpi;
      end;
      if Reg.ValueExists('toolBar_L') then
      begin
        tmpi := Reg.ReadInteger('toolBar_L');
        if tmpi > 0 then
          toolBar.Left := tmpi;
      end;
      if Reg.ValueExists('Percent_T') then
      begin
        tmpi := Reg.ReadInteger('Percent_T');
        if tmpi > 0 then
          Percent.Top := tmpi;
      end;
      if Reg.ValueExists('Percent_L') then
      begin
        tmpi := Reg.ReadInteger('Percent_L');
        if tmpi > 0 then
          Percent.Left := tmpi;
      end;
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  TranslateMain;
  LoadLook('default.dulk');
  if clook <> 'default.dulk' then
    LoadLook(clook);

  richLog.Refresh;

  dup5Main.writeLog(DLNGStr('LOG001'));

  dup5Main.writeLog(DLNGStr('LOG002'));

  FSE := FSEInit;
  FSE.SetProgressBar(PercentCB);
  FSE.SetLanguage(LanguageCB);
  FSE.SetPath(ExtractFilePath(Application.ExeName)+'data\drivers\');
  FSE.SetOwner(frmConfig);
  FSE.LoadDrivers(ExtractFilePath(Application.ExeName)+'data\drivers\');

  dup5Main.writeLog(' = '+ReplaceStr(DLNGStr('LOG009'),'%p',inttostr(FSe.NumDrivers)));

  dup5Main.writeLog(DLNGStr('LOG003'));

  CPlug := CPlugInit;
  CPlug.SetPercent(PercentCB);
  CPlug.SetLanguage(LanguageCB);
  CPlug.SetPath(ExtractFilePath(Application.ExeName)+'data\convert\');
  CPlug.SetOwner(self);
  CPlug.LoadPlugins(ExtractFilePath(Application.ExeName)+'data\convert\');

  dup5Main.writeLog(' = '+ReplaceStr(DLNGStr('LOG009'),'%p',inttostr(CPlug.NumPlugins)));

  dup5Main.writeLog(DLNGStr('LOG004'));

  HPlug := HPlugInit;
  HPlug.SetPercent(PercentCB);
  HPlug.SetLanguage(LanguageCB);
  HPlug.SetPath(ExtractFilePath(Application.ExeName)+'data\HyperRipper\');
  HPlug.SetOwner(self);
  HPlug.LoadPlugins(ExtractFilePath(Application.ExeName)+'data\HyperRipper\');

  dup5Main.writeLog(' = '+ReplaceStr(DLNGStr('LOG009'),'%p',inttostr(HPlug.NumPlugins)));

  Icons := TIconsFromExt.Create;
  Icons.init(imgContents);

  TempFiles := TStringList.Create;

  RecentFiles_Load;

  if ParamCount > 0 then
    if ParamStr(1) <> '/lng' then
      if FileExists(ParamStr(1)) then
      begin
        TimerParam.Enabled := true;
      end;

end;

procedure Tdup5Main.Bouton_OptionsClick(Sender: TObject);
begin

  menuOptions_Basic.Click;

end;

procedure Tdup5Main.Bouton_FermerClick(Sender: TObject);
begin

  menuFichier_Fermer.Click;

end;

procedure Tdup5Main.Bouton_OuvrirClick(Sender: TObject);
begin

  menuFichier_Ouvrir.Click;

end;

procedure Tdup5Main.menuOptions_DriversClick(Sender: TObject);
begin

  InitOptions;
  TabSelect := 3;
  frmConfig.ShowModal;

end;

procedure Tdup5Main.MenuOptions_LookClick(Sender: TObject);
begin

  InitOptions;
  TabSelect := 5;
  frmConfig.ShowModal;

end;

procedure Tdup5Main.PopUp_OpenClick(Sender: TObject);
var tmpfil: string;
    TempDir: array[0..MAX_PATH] of Char;
    Data: pvirtualTreeData;
begin

  if (lstContent.SelectedCount > 0) then
  begin

    { find our Windows temp directory }
    GetTempPath(MAX_PATH, @TempDir);

    Randomize;

    Data := lstContent.getNodeData(lstContent.getFirstSelected);

    tmpfil := Strip0(TempDir)+'dup5tmp-'+IntToStr(Random(99999999))+'-'+Copy(Data.data^.Name, Data.tdirpos+1,length(Data.data^.Name)-Data.tdirpos);

{    rep := GetNodePath2(lstIndex2.FocusedNode);
    if length(rep) > 0 then
      rep := rep + FSE.SlashMode;}
    FSE.ExtractFile(data.data,tmpfil,false);

    tempfiles.Add(tmpfil);

//  ShowMessage(tmpfil);

    ShellExecute(Application.Handle,'open',Pchar(tmpfil),nil,nil, SW_SHOWNORMAL);

  end;

end;

procedure Tdup5Main.menuOptions_AssocClick(Sender: TObject);
begin

  InitOptions;
  TabSelect := 7;
  frmConfig.ShowModal;

end;

procedure Tdup5Main.menuFichier_HyperRipperClick(Sender: TObject);
begin

  translateHyperRipper;
  frmHyperRipper.ShowModal;

end;

procedure Tdup5Main.WMUser(var msg: TMessage);
begin


//  ShowMessage(inttostr(msg.Result)+' '+inttostr(msg.WParam)+' '+inttostr(msg.LParam )+' '+inttostr(msg.Msg));
  if msg.WParam = 0 then
  begin
    Application.Restore;
    Activate;
    if FileExists(msgBuf) then
    begin
      RecentFiles_Add(msgBuf);
      Open_HUB(msgBuf);
    end;
    msgBuf := '';
  end
  else
  begin
    msgBuf := msgBuf + Chr(msg.WParam);
  end;
end;

procedure Tdup5Main.menuIndex_ExpandClick(Sender: TObject);
begin

//  lstIndex.FullExpand;
  lstIndex2.FullExpand(lstIndex2.FocusedNode);

end;

procedure Tdup5Main.menuIndex_CollapseClick(Sender: TObject);
begin

  lstIndex2.FullCollapse(lstIndex2.FocusedNode); 
//  lstIndex.FullCollapse;

end;

procedure Tdup5Main.Popup_Extrairevers_RAWClick(Sender: TObject);
var rep,dstfil: string;
    Data: pvirtualTreeData;
begin

  SaveDialog.Title := DLNGStr('POP1S1');
  SaveDialog.Filter := DLNGStr('ALLFIL')+'|*.*';

  Data := lstContent.GetNodeData(lstContent.GetFirstSelected);

  SaveDialog.FileName := Copy(Data.data^.Name, Data.tdirpos+1,length(Data.data^.Name)-Data.tdirpos);

  if SaveDialog.Execute then
  begin
    dstfil := SaveDialog.Filename;
    rep := GetNodePath2(lstIndex2.FocusedNode);
    if length(rep) > 0 then
      rep := rep + FSE.SlashMode;
//    FSE.ExtractFile(rep+Copy(Data.data^.Name, Data.tdirpos+1,length(Data.data^.Name)-Data.tdirpos),dstfil,false)
    FSE.ExtractFile(Data.data,dstfil,false);
    //  Application.MessageBox(PChar(DLNGStr('ERR101')),PChar(DLNGStr('ERR000')),MB_OK);
  end;

end;

procedure Tdup5Main.Popup_Extrairevers_MODELClick(Sender: TObject);
var ext,dstfil,tmpfil: string;
    TempDir: array[0..MAX_PATH] of Char;
//    DataX, DataY: integer;
//    Offset, Size: int64;
    CurrentMenu: TMenuItem;
    Data: pvirtualTreeData;
    Filename: string;
    tmpStm: TMemoryStream;
    outStm: TFileStream;
    silentExtract: boolean;
begin

  CurrentMenu := Sender as TMenuItem;

  SaveDialog.Title := DLNGStr('POP1S1');
  SaveDialog.Filter := DLNGStr('ALLFIL')+'|*.*';

  Data := lstContent.GetNodeData(lstContent.GetFirstSelected);
  Filename := Copy(Data.data^.Name, Data.tdirpos+1,length(Data.data^.Name)-Data.tdirpos);

  writeLog(ReplaceStr(ReplaceStr(DLNGStr('LOGC10'),'%a',Data.data^.Name),'%b',CListInfo.List[CurrentMenu.Tag].Info.Display));

  SaveDialog.FileName := ChangeFileExt(filename,'.'+CListInfo.List[CurrentMenu.Tag].Info.Ext);

  if SaveDialog.Execute then
  begin

    { find our Windows temp directory }
    GetTempPath(MAX_PATH, @TempDir);

    Randomize;

    tmpfil := Strip0(TempDir)+'dup5tmp-'+IntToStr(Random(99999999))+'-'+filename;

    dstfil := SaveDialog.Filename;

    ext := ExtractFileExt(filename);
    if ext[1] = '.' then
      ext := RightStr(ext,length(ext)-1);
    ext := UpperCase(ext);

    silentExtract := getVerboseLevel = 0;

    if CPlug.Plugins[CListInfo.List[CurrentMenu.Tag].Plugin].DUCIVersion < 3 then
    begin
      appendLog(DLNGStr('LOGC12'));
      FSE.ExtractFile(Data.data,tmpfil,silentExtract);
      writeLogVerbose(1,ReplaceStr(DLNGStr('LOGC13'),'%b',CListInfo.List[CurrentMenu.Tag].Info.Display));
      CPlug.Plugins[CListInfo.List[CurrentMenu.Tag].Plugin].Convert(tmpfil,dstfil,filename,FSE.DriverID,CListInfo.List[CurrentMenu.Tag].Info.ID,Data.Data^.Offset,Data.Data^.DataX,Data.Data^.DataY,False);
      appendLog(DLNGStr('LOG510'));
    end
    else
    begin
      appendLog(DLNGStr('LOGC11'));
      tmpStm := TMemoryStream.Create;
      outStm := TFileStream.Create(dstfil,fmCreate or fmShareDenyWrite);
      try
        FSE.ExtractFileToStream(Data.data,tmpStm,tmpfil,silentExtract);
        tmpStm.Seek(0,soFromBeginning);
        writeLogVerbose(1,ReplaceStr(DLNGStr('LOGC13'),'%b',CListInfo.List[CurrentMenu.Tag].Info.Display));
        CPlug.Plugins[CListInfo.List[CurrentMenu.Tag].Plugin].ConvertStream(tmpStm,outStm,filename,FSE.DriverID,CListInfo.List[CurrentMenu.Tag].Info.ID,Data.Data^.Offset,Data.Data^.DataX,Data.Data^.DataY,False);
        appendLog(DLNGStr('LOG510'));
      finally
        tmpStm.Free;
        outStm.Free;
      end;
    end;

    try
      if FileExists(tmpfil) then
        DeleteFile(tmpfil);
    except
      tempFiles.Add(tmpfil);
    end;
  end;

end;

procedure Tdup5Main.Popup_ExtraireMulti_RAWClick(Sender: TObject);
var outputdir: string;
    dstfil,rep,filename: string;
    curfiles,perc,numper: integer;
    Node: PVirtualNode;
    Data: pvirtualTreeData;
begin

  outputdir := CallDirSelect;
  if length(outputdir)>0 then
  begin
    if copy(outputdir,length(outputdir),1) <> '\' then
      outputdir := outputdir + '\';
    CurFiles := 1;

    rep := GetNodePath2(lstIndex2.FocusedNode);
    if length(rep) > 0 then
      rep := rep + FSE.SlashMode;

    Node := lstContent.GetFirstSelected;
    numper := 0;
    Percent.Position := 0;

    while Node <> nil do
    begin
      Data := lstContent.GetNodeData(Node);
      Filename := Copy(Data.data^.Name, Data.tdirpos+1,length(Data.data^.Name)-Data.tdirpos);
      dstfil := outputdir + fileName;
      FSE.ExtractFile(data.data,dstfil,true);
      Inc(CurFiles);
      perc := Round((CurFiles / lstContent.SelectedCount)*100);
      if (perc >= numper+5) then
      begin
        Percent.Position := perc;
        numper := perc;
      end;
      Node := lstContent.GetNextSelected(Node);
    end;
    Percent.Position := 100;
  end;

end;

procedure Tdup5Main.Popup_ExtraireMulti_MODELClick(Sender: TObject);
var outputdir: string;
    x,oldperc: integer;
{    DataX, DataY: integer;
    Offset, Size: int64;}
    tmpfil,dstfil,rep,filename: string;
    perc: integer;
    TempDir: array[0..MAX_PATH] of Char;
    CurrentMenu: TMenuItem;
    Silent: boolean;
    Node: PVirtualNode;
    Data: pvirtualTreeData;
    useOldMethod: Boolean;
    tmpStm: TMemoryStream;
    outStm: TFileStream;
begin

  CurrentMenu := Sender as TMenuItem;
  Silent := False;

  outputdir := CallDirSelect;
  if length(outputdir)>0 then
  begin
    if copy(outputdir,length(outputdir),1) <> '\' then
      outputdir := outputdir + '\';
    x := 0;

    rep := GetNodePath2(lstIndex2.FocusedNode);
    if length(rep) > 0 then
      rep := rep + FSE.SlashMode;

    GetTempPath(MAX_PATH, @TempDir);
    Randomize;

    Oldperc := 0;
    Percent.Position := 0;

    Node := lstContent.GetFirstSelected;

    writeLog(ReplaceStr(DLNGStr('LOGC14'),'%b',CListInfo.List[CurrentMenu.Tag].Info.Display));

    useOldMethod := CPlug.Plugins[CListInfo.List[CurrentMenu.Tag].Plugin].DUCIVersion < 3;

    if useOldMethod then
      appendLogVerbose(2,DLNGStr('LOGC12'))
    else
      appendLogVerbose(2,DLNGStr('LOGC11'));

    while (Node <> Nil) do
    begin
      Data := lstContent.GetNodeData(Node);
      filename := Copy(Data.data^.Name, Data.tdirpos+1,length(Data.data^.Name)-Data.tdirpos);
      dstfil := outputdir + ChangeFileExt(fileName,'.'+CListInfo.List[CurrentMenu.Tag].Info.Ext);
      tmpfil := Strip0(TempDir)+'dup5tmp-'+IntToStr(Random(99999999))+'-'+fileName;

      if useOldMethod then
      begin
        FSE.ExtractFile(Data.data,tmpfil,false);
        appendLogVerbose(2,DLNGStr('LOGC15'));
        CPlug.Plugins[CListInfo.List[CurrentMenu.Tag].Plugin].Convert(tmpfil,dstfil,filename,FSE.DriverID,CListInfo.List[CurrentMenu.Tag].Info.ID,Data.Data^.Offset,Data.Data^.DataX,Data.Data^.DataY,Silent);
        appendLog(DLNGStr('LOG510'));
      end
      else
      begin
        tmpStm := TMemoryStream.Create;
        outStm := TFileStream.Create(dstfil,fmCreate or fmShareDenyWrite);
        try
          FSE.ExtractFileToStream(Data.data,tmpStm,tmpfil,false);
          tmpStm.Seek(0,soFromBeginning);
          appendLog(DLNGStr('LOGC15'));
          CPlug.Plugins[CListInfo.List[CurrentMenu.Tag].Plugin].ConvertStream(tmpStm,outStm,filename,FSE.DriverID,CListInfo.List[CurrentMenu.Tag].Info.ID,Data.Data^.Offset,Data.Data^.DataX,Data.Data^.DataY,Silent);
          appendLog(DLNGStr('LOG510'));
        except
          on E: Exception do
          begin
            appendLog(DLNGStr('LOG513'));
            writeLog(DLNGStr('ERR200')+' '+E.ClassName+' - '+E.Message);
            colorLog(clRed);
            styleLog([fsBold]);
          end;
        end;
        tmpStm.Free;
        outStm.Free;
      end;

      if not(Silent) then
        Silent := True;
//      FSE.ExtractFile(data.data,tmpfil,true);
//      FSE.GetListElem(rep+fileName,Offset,Size,DataX,DataY);

//      CPlug.Plugins[CListInfo.List[CurrentMenu.Tag].Plugin].Convert(tmpfil,dstfil,fileName,FSE.DriverID,CListInfo.List[CurrentMenu.Tag].Info.ID,Data.Data^.Offset,Data.Data^.DataX,Data.Data^.DataY,Silent);

      try
        if FileExists(tmpfil) then
          DeleteFile(tmpfil);
      except
        tempFiles.Add(tmpfil);
      end;
      Inc(x);
      perc := Round((x / lstContent.SelectedCount)*100);
      if perc >= (oldperc+5) then
      begin
        oldperc := perc;
        Percent.Position := perc;
        Percent.Refresh;
      end;
      Node := lstContent.GetNextSelected(Node);
    end;
  end;

end;

procedure Tdup5Main.menuOptions_ConvertClick(Sender: TObject);
begin

  InitOptions;
  TabSelect := 2;
  frmConfig.ShowModal;

end;

procedure Tdup5Main.lstContentInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var Data: pvirtualTreeData;
    infoData: virtualTreeData;
begin
  Data := Sender.GetNodeData(Node);
  infoData := FSE.getListData(Node.Index);

  // These are the editor kinds used in the grid tree.
{  Data.ImageIndex := infoData.ImageIndex;
  Data.fileName := infoData.fileName;
  Data.data := infoData.data;
  Data.desc := infoData.desc;}

  Data^ := infoData;

  if Sender.FocusedColumn < 1 then
    Sender.FocusedColumn := 1;

end;

procedure Tdup5Main.lstContentGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var Data: pvirtualTreeData;
    posext: integer;
    ext: string;
begin

  Data := Sender.GetNodeData(Node);

  if not(Data.loaded) then
  begin
    posext := posrev('.',Data.data^.Name);
    if posext > 0 then
      ext := Copy(Data.data^.Name,posext+1,length(Data.data^.Name)-posext)
    else
      ext := '';
      Data.desc := DescFromExt(ext);

      Data.ImageIndex := icons.getIcon(Data.data^.Name);
//      listData[x].ImageIndex := icons.getIcon(cache.getItem(x)^.Name);
//    TotSize := TotSize + cache.getItem(x)^.Size;
    Data.loaded := true;
  end;

  case Column of
    0: CellText := Copy(Data.data^.Name, Data.tdirpos+1,length(Data.data^.Name)-Data.tdirpos);
    1: CellText := IntToStr(Data.data^.size);
    2: CellText := IntToStr(Data.data^.offset);
    3: CellText := Data.desc;
  else
    CellText := '';
  end;

end;

procedure Tdup5Main.FormCreate(Sender: TObject);
begin

  lstContent.NodeDataSize := SizeOf(virtualTreeData);
  lstContent.Header.SortColumn := 0;

  lstIndex2.NodeDataSize := SizeOf(virtualIndexData);

end;

procedure Tdup5Main.lstContentCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var Data1, Data2: pvirtualTreeData;
    Filename1, Filename2: string;
    posext : integer;
    ext : string;
begin

  Data1 := Sender.GetNodeData(Node1);
  Data2 := Sender.GetNodeData(Node2);
  Filename1 := Copy(Data1.data^.Name, Data1.tdirpos+1,length(Data1.data^.Name)-Data1.tdirpos);
  Filename2 := Copy(Data2.data^.Name, Data2.tdirpos+1,length(Data2.data^.Name)-Data2.tdirpos);

  case Column of
    -1, 0: begin
             if (UpperCase(fileName1) < UpperCase(fileName2)) then
               Result := -1
             else if (UpperCase(fileName1) > UpperCase(fileName2)) then
               Result := 1
             else
               Result := 0;
           end;
        1: begin
             if (Data1.data^.size < Data2.data^.size) then
               Result := -1
             else if (Data1.data^.size > Data2.data^.size) then
               Result := 1
             else
               Result := 0;
           end;
        2: begin
             if (Data1.data^.offset < Data2.data^.offset) then
               Result := -1
             else if (Data1.data^.offset > Data2.data^.offset) then
               Result := 1
             else
               Result := 0;
           end;
        3: begin
             if not(Data1.loaded) then
             begin
               posext := posrev('.',Data1.data^.Name);
               if posext > 0 then
                 ext := Copy(Data1.data^.Name,posext+1,length(Data1.data^.Name)-posext)
               else
                 ext := '';
               Data1.desc := DescFromExt(ext);

               Data1.ImageIndex := icons.getIcon(Data1.data^.Name);
               Data1.loaded := true;
             end;
             if not(Data2.loaded) then
             begin
               posext := posrev('.',Data2.data^.Name);
               if posext > 0 then
                 ext := Copy(Data2.data^.Name,posext+1,length(Data2.data^.Name)-posext)
               else
                 ext := '';
               Data2.desc := DescFromExt(ext);

               Data2.ImageIndex := icons.getIcon(Data2.data^.Name);
               Data2.loaded := true;
             end;

             if (UpperCase(Data1.desc) < UpperCase(Data2.desc)) then
               Result := -1
             else if (UpperCase(Data1.desc) > UpperCase(Data2.desc)) then
               Result := 1
             else
               Result := 0;
           end;
  end;

end;

procedure Tdup5Main.lstContentGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var Data: pvirtualTreeData;
    posext: integer;
    ext: string;
begin

  if (Column = 0) then
  begin

    Data := Sender.GetNodeData(Node);
    if not(Data.loaded) then
    begin
      posext := posrev('.',Data.data^.Name);
      if posext > 0 then
        ext := Copy(Data.data^.Name,posext+1,length(Data.data^.Name)-posext)
      else
        ext := '';
      Data.desc := DescFromExt(ext);

//      Data.ImageIndex := IconFromExt(ext);
      Data.ImageIndex := icons.getIcon(Data.data^.Name);
//    TotSize := TotSize + cache.getItem(x)^.Size;
      Data.loaded := true;
    end;

    Imageindex := Data.ImageIndex;
  end;

end;

procedure Tdup5Main.lstContentHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var curSort: TSortDirection;
begin

  if (Sender.SortDirection = sdAscending) then
    curSort := sdDescending
  else
    curSort := sdAscending;

  Sender.SortDirection := curSort;
  Sender.SortColumn := Column;
  lstContent.Sort(nil,Column,curSort);

end;

procedure Tdup5Main.lstContentContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var Data: pvirtualTreeData;
    Node: PVirtualNode;
    Test: TMenuItem;
    rep,ext,mext,filename: string;
    Offset, Size: int64;
    i,DataX, DataY: integer;
    CList: ExtConvertList;
    ConvertOK: Boolean;
begin

   if (lstContent.SelectedCount > 1) then
   begin
     Popup_Extrairevers.Visible := False;
     Popup_ExtraireMulti.Visible := True;
     Popup_Open.Visible := False;

     rep := GetNodePath2(lstIndex2.FocusedNode);
     if length(rep) > 0 then
       rep := rep + FSE.SlashMode;

     Node := lstContent.GetFirstSelected;
     Data := lstContent.GetNodeData(Node);

     mext := ExtractFileExt(Data.data^.Name);
     if mext[1] = '.' then
       mext := RightStr(mext,length(mext)-1);
     mext := UpperCase(mext);

     ConvertOK := true;
     while (Node <> nil) and ConvertOK do
     begin
         Data := lstContent.GetNodeData(Node);
         ext := ExtractFileExt(Data.data^.Name);
         if ext[1] = '.' then
           ext := RightStr(ext,length(ext)-1);
         ext := UpperCase(ext);
         ConvertOK := (ext = mext);
         if ConvertOK then
         begin
           Filename := Copy(Data.data^.Name, Data.tdirpos+1,length(Data.data^.Name)-Data.tdirpos);
           FSE.GetListElem(rep+fileName,Offset,Size,DataX,DataY);
           ConvertOK := CPlug.TestFileConvert(fileName,offset,size,FSE.DriverID,DataX,DataY);
         end;
         Node := lstContent.GetNextSelected(Node);
     end;
     for i := Popup_ExtraireMulti.Count-1 downto 2  do
       Popup_ExtraireMulti.Remove(Popup_ExtraireMulti.Items[i]);

     if ConvertOK then
     begin
       FSE.GetListElem(rep+fileName,Offset,Size,DataX,DataY);
       CList := CPlug.GetFileConvert(fileName,offset,size,FSE.DriverID,DataX, DataY);

       CListInfo.NumFormats := CList.NumFormats;
       for i := 1 to CList.NumFormats do
       begin
         Test := TMenuItem.Create(Self);
         Test.Caption := CList.List[i].Info.Display;
         Test.Tag := i;
         CListInfo.List[i] := CList.List[i];
         Test.OnClick := Popup_ExtraireMulti_MODEL.OnClick;
         Popup_ExtraireMulti.Add(Test);
       end;
       N7.Visible := True;
     end
     else
     begin
       N7.Visible := False;
     end;

       lstContent.PopupMenu.Popup(dup5Main.Left + lstContent.Left + MousePos.X + 8, dup5Main.Top + lstContent.Top + ToolBar.Top + ToolBar.Height + 20 + MousePos.Y);
   end
   else if (lstContent.SelectedCount = 1) then
   begin
     Popup_Extrairevers.Visible := True;
     Popup_ExtraireMulti.Visible := False;
     Popup_Open.Visible := True;

     rep := GetNodePath2(lstIndex2.FocusedNode);
     if length(rep) > 0 then
       rep := rep + FSE.SlashMode;

     Node := lstContent.GetFirstSelected;
     Data := lstContent.GetNodeData(Node);
     Filename := Copy(Data.data^.Name, Data.tdirpos+1,length(Data.data^.Name)-Data.tdirpos);

     FSE.GetListElem(rep+fileName,Offset,Size,DataX,DataY);

     ext := ExtractFileExt(fileName);
     if ext <> '' then
     begin
       if ext[1] = '.' then
         ext := RightStr(ext,length(ext)-1);
       ext := UpperCase(ext);
     end;

     CList := CPlug.GetFileConvert(fileName,offset,size,FSE.DriverID,DataX, DataY);

     for i := Popup_Extrairevers.Count-1 downto 2  do
       Popup_Extrairevers.Remove(Popup_Extrairevers.Items[i]);

     CListInfo.NumFormats := CList.NumFormats;
     for i := 1 to CList.NumFormats do
     begin
       Test := TMenuItem.Create(Self);
       Test.Caption := CList.List[i].Info.Display;
       Test.Tag := i;
       CListInfo.List[i] := CList.List[i];
       Test.OnClick := Popup_Extrairevers_MODEL.OnClick;
       Popup_Extrairevers.Add(Test);
     end;

     if CList.NumFormats > 0 then
       N6.Visible := True
     else
       N6.Visible := False;

     lstContent.PopupMenu.Popup(dup5Main.Left + lstContent.Left + MousePos.X + 8, dup5Main.Top + lstContent.Top + ToolBar.Top + ToolBar.Height + 20 + MousePos.Y);
   end;

end;

procedure Tdup5Main.closeCurrent;
begin

  writeLog(DLNGStr('LOG200'));

  dup5Main.menuFichier_Fermer.Enabled := False;
  dup5Main.Bouton_Fermer.Enabled := False;
  dup5Main.menuEdit.Visible := False;
  dup5Main.menuTools.Visible := False;
  dup5Main.Caption := 'Dragon UnPACKer v'+CurVersion+' '+CurEdit;

  dup5Main.Status.Panels.Items[0].Text := '0 '+DLNGStr('STAT10');
  dup5Main.Status.Panels.Items[1].Text := '0 '+DLNGStr('STAT20');
  dup5Main.Status.Panels.Items[3].Text := '-';

//  FSE_Close;
  FSE.CloseFile;
  dup5Main.lstContent.clear;
//  dup5Main.lstIndex.Items.Clear;
  dup5Main.lstIndex2.Clear;

  if CurFile > 0 then
  begin
    FileClose(CurFile);
    CurFile := 0;
  end;

  appendLog(DLNGStr('LOG510'));

end;

procedure Tdup5Main.lstContentMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

  Shift := (Shift * [ssDouble]);

  if Shift = [ssDouble] then
    PopUp_OpenClick(sender);

end;

function Tdup5main.ExtractSelectedFilesToTempDir(): boolean;
var dstfil,filename: string;
    curfiles,perc,numper: integer;
    Node: PVirtualNode;
    Data: pvirtualTreeData;
    TempDir: array[0..MAX_PATH] of Char;
    tmpdir: string;
begin

  result := (lstContent.SelectedCount = DropFileSource.Files.Count);

  if result then
  begin
    CurFiles := 1;

    GetTempPath(MAX_PATH, @TempDir);
    tmpdir := Strip0(TempDir)+'dup5tmp-dragndrop\';

    if not(DirectoryExists(tmpdir)) then
      mkdir(tmpdir);

{    rep := GetNodePath2(lstIndex2.FocusedNode);
    if length(rep) > 0 then
      rep := rep + FSE.SlashMode;}

    Node := lstContent.GetFirstSelected;
    numper := 0;
    Percent.Position := 0;

    while Node <> nil do
    begin
      Data := lstContent.GetNodeData(Node);
      filename := Copy(Data.data^.Name, Data.tdirpos+1,length(Data.data^.Name)-Data.tdirpos);
      dstfil := tmpdir + fileName;
//      showmessage(dstfil+#10+DropFileSource.Files.Strings[curFiles-1]);
      FSE.ExtractFile(Data.data,dstfil,true);
      TempFiles.Add(dstfil);
      Inc(CurFiles);
      perc := Round((CurFiles / lstContent.SelectedCount)*100);
      if (perc >= numper+5) then
      begin
        Percent.Position := perc;
        numper := perc;
      end;
      Node := lstContent.GetNextSelected(Node);
    end;
    Percent.Position := 100;
  end;

end;

procedure Tdup5Main.DropFileSourceDrop(Sender: TObject;
  DragType: TDragType; var ContinueDrop: Boolean);
begin

  ContinueDrop := ExtractSelectedFilesToTempDir;

end;

procedure Tdup5Main.lstContentStartDrag(Sender: TObject;
  var DragObject: TDragObject);
var Node: PVirtualNode;
    Data: pvirtualTreeData;
    TempDir: array[0..MAX_PATH] of Char;
    tmpdir: string;
begin

  if not(AlreadyDragging) then
  begin

    if lstContent.SelectedCount > 0 then
    begin
      DropFileSource.Files.Clear;
      AlreadyDragging := true;

      { find our Windows temp directory }
      GetTempPath(MAX_PATH, @TempDir);
      tmpdir := Strip0(TempDir)+'dup5tmp-dragndrop\';

      Node := lstContent.GetFirstSelected;

      while Node <> nil do
      begin
        Data := lstContent.GetNodeData(Node);
        DropFileSource.Files.Add(tmpdir+Copy(Data.data^.Name, Data.tdirpos+1,length(Data.data^.Name)-Data.tdirpos));
        Node := lstContent.GetNextSelected(Node);
      end;

      DropFileSource.Execute;

      AlreadyDragging := false;
    end;
  end;

  abort;

end;

procedure Tdup5Main.TDup5FileQuitExecute(Sender: TObject);
begin

  if (Not FSE.IsListEmpty) then
    menuFichier_Fermer.Click;

  Application.Terminate;

end;

procedure Tdup5Main.TDup5FileHyperRipperExecute(Sender: TObject);
begin

  translateHyperRipper;
  frmHyperRipper.ShowModal;

  //frmError.FillTxtError(Exception.Create('Error E/S'),'Tdup5Main.TDup5FileHyperRipperExecute('+sender.classname+')');

end;

procedure Tdup5Main.TDup5OptionsExecute(Sender: TObject);
begin

  menuVar := 2;

end;

procedure Tdup5Main.TDup5OptionsGenExecute(Sender: TObject);
begin

  InitOptions;
  TabSelect := 0;
  frmConfig.ShowModal;

end;

procedure Tdup5Main.TDup5OptionsPluginsExecute(Sender: TObject);
begin

//

end;

procedure Tdup5Main.TDup5OptionsAssocExecute(Sender: TObject);
begin

  InitOptions;
  TabSelect := 6;
  frmConfig.ShowModal;

end;

procedure Tdup5Main.TDup5OptionsLookExecute(Sender: TObject);
begin

  InitOptions;
  TabSelect := 5;
  frmConfig.ShowModal;

end;

procedure Tdup5Main.TDup5PluginsConvertExecute(Sender: TObject);
begin

  InitOptions;
  TabSelect := 2;
  frmConfig.ShowModal;

end;

procedure Tdup5Main.TDup5PluginsDriversExecute(Sender: TObject);
begin

  InitOptions;
  TabSelect := 3;
  frmConfig.ShowModal;

end;

procedure Tdup5Main.TDup5PluginsHRExecute(Sender: TObject);
begin

  InitOptions;
  TabSelect := 4;
  frmConfig.ShowModal;

end;

{
procedure Tdup5Main.TDup5HelpAboutExecute(Sender: TObject);
begin

  TranslateAbout;
  frmAbout.lblVersion.Caption := CurVersion + ' ' + CurEdit+' (Build '+inttostr(CurBuild)+')';
  frmAbout.Top := dup5Main.Top + ((Height - frmAbout.Height) div 2) ;
  frmAbout.Left := dup5Main.Left + ((Width - frmAbout.Width) div 2) ;
  frmAbout.lblSubVersion.Caption := 'VirtualTree v'+VTVersion;
  frmAbout.lblCompDate.Caption := DateToStr(CompileTime);
  frmAbout.lblCompTime.Caption := TimeToStr(CompileTime);


  frmAbout.ShowModal;

end;
}

procedure Tdup5Main.TDup5FileExecute(Sender: TObject);
begin

menuVar := 0;

end;

procedure Tdup5Main.TDup5HelpExecute(Sender: TObject);
begin

menuVar := 3;

end;

procedure Tdup5Main.TDup5EditSearchExecute(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Options',True) then
    begin
      if Reg.ValueExists('Search_Text') then
        frmSearch.txtSearch.Text := Reg.ReadString('Search_Text');
      if Reg.ValueExists('Search_Type') then
        frmSearch.RadioDirOnly.Checked := Reg.ReadBool('Search_Type');
      if Reg.ValueExists('Search_Case') then
        frmSearch.checkCase.Checked := Reg.ReadBool('Search_Case');
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  TranslateSearch;
  frmSearch.ShowModal;

end;

procedure Tdup5Main.TDup5EditExecute(Sender: TObject);
begin

menuVar := 1;

end;

procedure Tdup5Main.TDup5FileOpenExecute(Sender: TObject);
var src, exts : string;
    extlist: ExtensionsResult;
    cl,t : integer;
begin

extlist := FSE.GetAllFileTypes(True);
if extlist.Num > 1 then
begin
  for cl := 1 to extlist.Num do
  begin
    t := pos(';',extlist.lists[cl]);
    if exts <> '' then
    begin
      if t > 0 then
        exts := exts +'|'+DLNGStr('ALLCMP') + ' ('+Uppercase(Copy(extlist.lists[cl],0,t-1))+' -> '+Uppercase(Copy(extlist.lists[cl],posrev(';',extlist.lists[cl])+1,length(extlist.lists[cl])-PosRev(';',extlist.lists[cl])))+ ')|'+extlist.lists[cl]
      else
        exts := exts +'|'+DLNGStr('ALLCMP') + ' ('+Uppercase(extlist.lists[cl])+')|'+extlist.lists[cl]
    end
    else
      exts := DLNGStr('ALLCMP') + ' ('+Uppercase(Copy(extlist.lists[cl],0,t-1))+' -> '+Uppercase(Copy(extlist.lists[cl],posrev(';',extlist.lists[cl])+1,length(extlist.lists[cl])-PosRev(';',extlist.lists[cl])))+ ')|'+extlist.lists[cl];
  end;
end
else
  exts := DLNGStr('ALLCMP') + '|' + extlist.lists[1];

OpenDialog.Filter := exts + '|'+DLNGStr('ALLFIL')+'|*.*' + '|' + FSE.GetFileTypes;

if extlist.Num > 1 then
  OpenDialog.FilterIndex := extlist.Num+1
else
  OpenDialog.FilterIndex := 1;

OpenDialog.Title := DLNGStr('OPEN00');

if length(RecentFiles[0]) > 0 then
  OpenDialog.FileName := RecentFiles[0];

if OpenDialog.Execute then
begin
  CloseCurrent;
  src := OpenDialog.FileName;
  RecentFiles_Add(src);
  Open_HUB(src);
end

end;

procedure Tdup5Main.TDup5FileCloseExecute(Sender: TObject);
begin

  CloseCurrent;

end;

procedure Tdup5Main.TDup5ToolsListExecute(Sender: TObject);
begin

  TranslateList;
  frmList.ShowModal;

end;

procedure Tdup5Main.lstIndex2GetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var NodeData: pvirtualIndexData;
begin

  NodeData := Sender.GetNodeData(Node);
  // return identifier of the node

  CellText := NodeData.dirname;

end;

procedure Tdup5Main.lstIndex2GetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var NodeData: pvirtualIndexData;
begin

  NodeData := Sender.GetNodeData(Node);

  case Kind of
    ikState: // for the case the state icon has been requested
      ImageIndex := -1;
    ikNormal:
      ImageIndex := NodeData.imageIndex;
    ikSelected: begin
        ImageIndex := NodeData.selectedImageIndex;
        Ghosted := true;
      end;
  end;


end;

procedure Tdup5Main.lstIndex2FocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var disp: string;
begin

  disp := GetNodePath2(Node);
  writelogVerbose(1,ReplaceStr(DLNGStr('LOG300'),'%d',disp));
  FSE.BrowseDir(disp);
  CurrentDir := disp;
  appendLogVerbose(1,ReplaceStr(DLNGStr('LOG301'),'%e',inttostr(lstContent.TotalCount)));

end;

function Tdup5Main.GetNodePath2(Nod: PVirtualNode): string;
var res: string;
    NodeData: pvirtualIndexData;
begin

  if (Nod <> nil) then
  begin
    NodeData := lstIndex2.GetNodeData(Nod);

    if (NodeData <> nil) and (NodeData.imageIndex <> 2) then
    begin
      res := GetNodePath2(Nod.Parent);
      if length(res)>0 then
        res := res + FSE.SlashMode;
      res := res + NodeData.dirname;
    end
    else
      res := '';
    result := res;
  end
  else
    result := '';

end;

procedure Tdup5Main.lstIndex2CompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var Data1, Data2: pvirtualIndexData;
begin

  Data1 := Sender.GetNodeData(Node1);
  Data2 := Sender.GetNodeData(Node2);

  Result := AnsiCompareStr(UpperCase(Data1.dirname),UpperCase(Data2.dirname));
//  ShowMessage(GetNodePath2(Node1)+#10+GetNodePath2(Node2)+#10+#10+Data1.dirname+#10+Data2.dirname);
//  Result := AnsiCompareStr(GetNodePath2(Node1),GetNodePath2(Node2));

{  if (UpperCase(Data1.dirname) < UpperCase(Data2.dirName)) then
    Result := -1
  else if (UpperCase(Data1.dirName) > UpperCase(Data2.dirName)) then
    Result := 1
  else
    Result := 0;}

end;

procedure Tdup5Main.lstIndex2ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var NodeData: pvirtualIndexData;
begin

 if (lstIndex2.RootNodeCount > 0) and (lstIndex2.FocusedNode <> nil) then
 begin
   NodeData := lstIndex2.GetNodeData(lstIndex2.FocusedNode);
   if (NodeData.imageIndex = 2) then
   begin
     menuIndex_ExtractAll.Visible := True;
     menuIndex_Infos.Visible := True;
     menuIndex_ExtractDirs.Visible := False;
     N2.Visible := true;
     lstIndex2.PopupMenu.Popup(Left + MousePos.X + 8, Top + lstIndex2.Top + ToolBar.Top + ToolBar.Height + 20 + MousePos.Y)
   end
   else
   begin
     menuIndex_ExtractAll.Visible := False;
     menuIndex_Infos.Visible := False;
     N2.Visible := false;
     menuIndex_ExtractDirs.Visible := True;
     lstIndex2.PopupMenu.Popup(Left + MousePos.X + 8, Top + lstIndex2.Top + ToolBar.Top + ToolBar.Height + 20 + MousePos.Y)
   end;
 end
 else
   Handled := true;

     { OLD List Index

          if lstIndex.Selected.IsFirstNode then
     begin
       menuIndex_ExtractAll.Visible := True;
       menuIndex_Infos.Visible := True;
       menuIndex_ExtractDirs.Visible := False;
       lstIndex.PopupMenu.Popup(Left + X + 8, Top + lstIndex.Top + ToolBar.Top + ToolBar.Height + 20 + Y)
     end
     else
     begin
       menuIndex_ExtractAll.Visible := False;
       menuIndex_Infos.Visible := False;
       N2.Visible := false;
       menuIndex_ExtractDirs.Visible := True;
       lstIndex.PopupMenu.Popup(Left + X + 8, Top + lstIndex.Top + ToolBar.Top + ToolBar.Height + 20 + Y)
     end;



     }

end;

procedure Tdup5Main.TimerParamTimer(Sender: TObject);
begin

  TimerParam.Enabled := false;

  if (fileexists(paramstr(1))) then
  begin
    RecentFiles_Add(ParamStr(1));
    Open_HUB(ParamStr(1));
  end;

end;

procedure Tdup5Main.menuLog_ShowClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      Reg.WriteBool('ShowLog',true);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;
  
  richLog.Visible := true;
  SplitterBottom.Visible := true;
  panBottom.Height := bottomHeight;

end;

procedure Tdup5Main.menuLog_HideClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      Reg.WriteBool('ShowLog',false);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  richLog.Visible := false;
  SplitterBottom.Visible := false;
  bottomHeight := panBottom.Height;
  panBottom.Height := status.Height;

end;

procedure Tdup5Main.Popup_LogPopup(Sender: TObject);
begin

  menuLog_Show.Visible := not(richLog.Visible);
  menuLog_Hide.Visible := richLog.Visible;

end;



procedure Tdup5Main.writeLog(text: string);
begin

  if richLog.Lines.Count = 32760 then
    richLog.Lines.Delete(0);

  richLog.Lines.Add(DateTimeToStr(now)+' : '+text);
  richLog.Perform(EM_LINESCROLL,0,1);

end;

procedure Tdup5Main.appendLog(text: string);
begin

  richLog.Lines.Strings[richLog.Lines.Count-1] := richLog.Lines.Strings[richLog.Lines.Count-1]+' '+text;

end;

procedure Tdup5Main.separatorLog;
begin

  writelog(StringOfchar('-',80));

end;

procedure Tdup5Main.menuLog_ClearClick(Sender: TObject);
begin

  richLog.Clear;

end;

procedure Tdup5Main.styleLog(Style: TFontStyles);
begin

  setRichEditLineStyle(richLog, richLog.Lines.Count, Style);

end;

procedure Tdup5Main.colorLog(Color: TColor);
begin

  setRichEditLineColor(richLog, richLog.Lines.Count, Color);

end;

function Tdup5Main.getVerboseLevel: integer;
begin

  result := verboseLevel;

end;

procedure Tdup5Main.styleLogVerbose(minLevel: integer; Style: TFontStyles);
begin

  if verboseLevel >= minLevel then
    styleLog(Style);

end;

procedure Tdup5Main.appendLogVerbose(minLevel: integer; text: string);
begin

  if verboseLevel >= minLevel then
    appendLog(text);

end;

procedure Tdup5Main.writeLogVerbose(minLevel: integer; text: string);
begin

  if verboseLevel >= minLevel then
    writeLog(text);

end;

procedure Tdup5Main.separatorLogVerbose(minLevel: integer);
begin

  if verboseLevel >= minLevel then
    separatorLog;

end;

procedure Tdup5Main.colorLogVerbose(minLevel: integer; Color: TColor);
begin

  if verboseLevel >= minLevel then
    colorLog(Color);

end;

procedure Tdup5Main.setVerboseLevel(verbLevel: integer);
begin

  verboseLevel := verbLevel;

end;

end.
