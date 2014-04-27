library cnv_exttools;

// $Id$
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is cnv_pictex.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

uses
  FastMM4,
  Forms,
  ComCtrls,
  Windows,
  StrUtils,
  SysUtils,
  IniFiles,
  ShellApi,
  Classes,
  lib_version in '..\..\..\common\lib_version.pas',
  lib_BinUtils in '..\..\..\common\lib_BinUtils.pas',
  lib_temptools in '..\..\..\common\lib_temptools.pas',
  u_frmExtTool in 'u_frmExtTool.pas' {frmExtTool},
  u_ListOfToolsDataStruct in 'u_ListOfToolsDataStruct.pas';

{$E d5c}

{$R *.res}

{$Include datetime.inc}

type ConvertListElem = record
       Display: ShortString;
       Ext: ShortString;
       ID: ShortString;
     end;
     ConvertList = record
       NumFormats :  Byte;
       List : array[1..255] of ConvertListElem;
     end;
     ConvertInfo = record
       Name: ShortString;
       Version: ShortString;
       Author: ShortString;
       Comment: ShortString;
       VerID: Integer;
     end;
     TPercentCallback = procedure (p: byte);
     TLanguageCallback = function (lngid: ShortString): ShortString;
//     EBadType = class(Exception);
     // Procedure to display a message box by using host application
     TMsgBoxCallback = procedure(const title, msg: AnsiString);


var Percent: TPercentCallback;
    DLNGStr: TLanguageCallback;
    CurPath: ShortString;
    SupportedDUCI: byte = 0;
    palfil: string;
    AHandle: THandle;
    AOwner: TComponent;
    ShowMsgBox : TMsgBoxCallback;
    ListOfTools: array of TToolInfo;

const
  DUCI_VERSION = 4;
  DUCI_VERSION_COMPATIBLE = 3;
  DRIVER_VERSION = 01010;
  DUP_VERSION = 56240;
  SVN_REVISION = '$Rev$';
  SVN_DATE = '$Date$';

{ * Version History:
  * v0.0.1 Alpha (00100): First version (never distributed)
  * v0.0.2 Alpha (00200): Added return code testing (in order to know something
  *                       went wrong
  *                       The list of configured tools is now shown in the
  *                       about box
  * v0.1.0 Beta  (01010): Added configuration box
  *                       Changed format of the configuration ini file:
  *                        Tool sections are now [tool-<id>] where <id> is an
  *                         integer (from 0 to 2^31-1)
  *                        toolslist in the main section now indicate the
  *                         number of Tool sections
  * }

function Explode(var a: TStrArray; Border, S: string): Integer;
var
  S2: string;
begin
  Result  := 0;
  S2 := S + Border;
  repeat
    SetLength(A, Length(A) + 1);
    a[Result] := Copy(S2, 0,Pos(Border, S2) - 1);
    Delete(S2, 1,Length(a[Result] + Border));
    Inc(Result);
  until S2 = '';
end;

function shellExec(ExecuteFile, ParamString, StartInString: String): integer;
var SEInfo: TShellExecuteInfo;
    ExitCode: DWORD;
begin

  FillChar(SEInfo, SizeOf(SEInfo), 0) ;
  SEInfo.cbSize := SizeOf(TShellExecuteInfo) ;
  with SEInfo do begin
    fMask := SEE_MASK_NOCLOSEPROCESS;
    Wnd := AHandle;
    lpFile := PChar(ExecuteFile);
    lpParameters := PChar(ParamString);
 {
 StartInString specifies the
 name of the working directory.
 If ommited, the current directory is used.
 }
 // lpDirectory := PChar(StartInString) ;
    nShow := SW_HIDE;
  end;
  if ShellExecuteEx(@SEInfo) then
  begin
    repeat
      //Application.ProcessMessages;
      GetExitCodeProcess(SEInfo.hProcess, ExitCode) ;
    until (ExitCode <> STILL_ACTIVE) { or Application.Terminated};
    result := ExitCode;
  end
  else
    result := -1;

end;

procedure reloadSettings();
var iniFile: TMemIniFile;
    x, curnum, nbtools: integer;
begin

  if fileexists(CurPath+'cnv_exttools.ini') then
  begin
    iniFile := TMemInifile.Create(CurPath+'cnv_exttools.ini');
    try
      if iniFile.SectionExists('cnv_exttools') and iniFile.ValueExists('cnv_exttools','toolslist') then
      begin
        nbtools := iniFile.ReadInteger('cnv_exttools','toolslist',-1);
        if nbtools >= 0 then
        begin
          setlength(ListOfTools,nbtools);
          for x := 0 to (nbtools-1) do
          begin
            if iniFile.SectionExists('tool-'+inttostr(x)) then
            begin
              ListOfTools[x].enabled := iniFile.ReadBool('tool-'+inttostr(x),'enabled',false);
              ListOfTools[x].name := iniFile.ReadString('tool-'+inttostr(x),'name','');
              ListOfTools[x].author := iniFile.ReadString('tool-'+inttostr(x),'author','');
              ListOfTools[x].url := iniFile.ReadString('tool-'+inttostr(x),'url','');
              ListOfTools[x].comment := iniFile.ReadString('tool-'+inttostr(x),'comment','');
              ListOfTools[x].path := iniFile.ReadString('tool-'+inttostr(x),'path','');
              ListOfTools[x].command := iniFile.ReadString('tool-'+inttostr(x),'command','');
              ListOfTools[x].resultext := iniFile.ReadString('tool-'+inttostr(x),'resultext','');
              ListOfTools[x].resultoktest := iniFile.ReadInteger('tool-'+inttostr(x),'resultoktest',0);
              ListOfTools[x].resultok := iniFile.ReadInteger('tool-'+inttostr(x),'resultok',0);
              explode(ListOfTools[x].extensions,' ',iniFile.ReadString('tool-'+inttostr(x),'extensions',''));
            end
            else
            begin
              ListOfTools[x].enabled := false;
              ListOfTools[x].name := '';
              ListOfTools[x].author := '';
              ListOfTools[x].url := '';
              ListOfTools[x].comment := '';
              ListOfTools[x].path := '';
              ListOfTools[x].command := '';
              ListOfTools[x].resultext := '';
              ListOfTools[x].resultoktest := 0;
              ListOfTools[x].resultok := 0;
            end;
          end;
        end;
      end;
    finally
      FreeAndNil(iniFile);
    end;
  end;

end;

// Identifies the DLL as a Convert plugin (minimum version to load plugin)
// Exported
function DUCIVersion: Byte; stdcall;
begin
  Result := DUCI_VERSION_COMPATIBLE;
  SupportedDUCI := DUCI_VERSION_COMPATIBLE;
end;

// Indicate current DUCIVersion (should return 4 at minimum)
// Exported
function DUCIVersionEx(supported: byte): byte; stdcall;
begin
  result := DUCI_VERSION;
  SupportedDUCI := supported;
end;

// Returns Driver plugin version
// Exported
function VersionInfo2(): ConvertInfo; stdcall;
begin

  // Information about the plugin
  with result do
  begin
    Name := 'Elbereth''s External Tools Convert Plugin';
    Version := getVersion(DRIVER_VERSION);
    Author := 'Alexandre Devilliers (aka Elbereth)';
    Comment := 'Convert files using external command line tools.';
    VerID := DRIVER_VERSION;
  end;

end;

function IsFileCompatible(nam: ShortString; Offset, Size: Int64; fmt: ShortString; DataX, DataY: Integer): boolean; stdcall;
begin

  result := true;

end;

function GetFileConvert(nam: ShortString; Offset, Size: Int64; fmt: ShortString; DataX, DataY: Integer): ConvertList; stdcall;
var ext: string;
    x, e: integer;
begin

  ext := lowercase(extractfileext(nam));
  if (ext[1] = '.') then
    ext := rightstr(ext,length(ext)-1);
  result.NumFormats := 0;

  for x := low(ListOfTools) to high(ListOfTools) do
  begin
    if (ListOfTools[x].enabled) then
    begin
      for e := low(ListOfTools[x].extensions) to high(ListOfTools[x].extensions) do
      begin
        if (ext = ListOfTools[x].extensions[e]) then
        begin
          inc(result.NumFormats);
          result.List[result.NumFormats].Display := uppercase(ListOfTools[x].resultext)+' - '+ListOfTools[x].name;
          result.List[result.NumFormats].Ext := uppercase(ListOfTools[x].resultext);
          result.List[result.NumFormats].ID := inttostr(x);
          break;
        end;
      end;
    end;
  end;

end;

function ConvertStream(src, dst: TStream; nam, fmt, cnv: ShortString; Offset: Int64; DataX, DataY: Integer; Silent: Boolean): integer; stdcall;
var Size: int64;
    tmpFile: TFileStream;
    toolnum: integer;
    tmpFileName, tmpFileNameOut, params, path: String;
begin

  result := 0;
  toolnum := strtoint(cnv);

  if (toolnum >= low(ListOfTools)) and (toolnum <= high(ListOfTools))
  and ListOfTools[toolnum].enabled and (FileExists(ListOfTools[toolnum].path) or FileExists(CurPath + ListOfTools[toolnum].path)) then
  begin
    tmpFileName := getTemporaryDir+getTemporaryFilename('cnv_exttools_'+cnv+'_'+nam);
    tmpFileNameOut := changefileext(tmpFileName,'.'+ListOfTools[toolnum].resultext);
    tmpFile := TFileStream.Create(tmpFileName,fmCreate);
    tmpFile.CopyFrom(src,src.Size);
    tmpFile.Seek(0,soFromBeginning);
    FreeAndNil(tmpfile);
    params := StringReplace(StringReplace(ListOfTools[toolnum].command,'%o',tmpFileNameOut,[]),'%i',tmpFileName,[]);
    if not(FileExists(ListOfTools[toolnum].path)) and
           FileExists(CurPath + ListOfTools[toolnum].path) then
      path := CurPath + ListOfTools[toolnum].path
    else
      path := ListOfTools[toolnum].path;
    result := ShellExec(path,params,extractfilepath(path));
    
    case ListOfTools[toolnum].resultoktest of
      0: if (result = ListOfTools[toolnum].resultok) then
           result := 0
         else
           result := -1;
      1: if (result > ListOfTools[toolnum].resultok) then
           result := 0
         else
           result := -1;
      2: if (result < ListOfTools[toolnum].resultok) then
           result := 0
         else
           result := -1;
      3: if (result >= ListOfTools[toolnum].resultok) then
           result := 0
         else
           result := -1;
      4: if (result <= ListOfTools[toolnum].resultok) then
           result := 0
         else
           result := -1;
      5: if (result <> ListOfTools[toolnum].resultok) then
           result := 0
         else
           result := -1;
    end;

    if FileExists(tmpFileNameOut) then
    begin
      tmpFile := TFileStream.Create(tmpFileNameOut,fmOpenRead);
      if tmpFile.Size > 0 then
      begin
        dst.CopyFrom(tmpFile,tmpFile.Size);
        result := 0;
      end;
      FreeAndNil(tmpFile);
    end;
    if (fileexists(tmpFileNameOut)) then
      Deletefile(tmpFileNameOut);
    if (fileexists(tmpFileName)) then
      Deletefile(tmpFileName);
  end;

end;

  // Obsolete Convert, so we wrap it to the ConvertStream version
function Convert(src, dst, nam, fmt, cnv: ShortString; Offset: Int64; DataX, DataY: Integer; Silent: Boolean): integer; stdcall;
var src_stm, dst_stm: TFileStream;
begin

  src_stm := TFileStream.Create(src,fmOpenRead or fmShareDenyWrite);
  dst_stm := TFileStream.Create(dst,fmCreate or fmShareDenyWrite);

  try
    result := ConvertStream(src_stm, dst_stm,nam,fmt,cnv,Offset,DataX,DataY,Silent);
  finally
    FreeAndNil(src_stm);
    FreeAndNil(dst_stm);
  end;

end;

procedure InitPlugin(per: TPercentCallback; lngid: TLanguageCallback; DUP5Path: ShortString; AppHandle: THandle; AppOwner: TComponent); stdcall;
begin

  Percent := per;
  DLNGStr := lngid;
  CurPath := DUP5Path;
  AHandle := AppHandle;
  AOwner := AppOwner;

  reloadSettings;

end;

procedure InitPluginEx4(MsgBox: TMsgBoxCallback); stdcall;
begin

  showMsgBox := MsgBox;

end;

procedure AboutBox; stdcall;
var aboutText: string;
    x: integer;
begin

  reloadSettings;

  if (SupportedDUCI >= 4) then
  begin

    aboutText := '{\rtf1\ansi\ansicpg1252\deff0\deflang1036{\fonttbl{\f0\fswiss\fcharset0 Arial;}}'+#10+
                 '\viewkind4\uc1\pard\qc\ul\b\f0\fs24\par Elbereth''s External Tools Convert plugin v'+getVersion(DRIVER_VERSION)+'\par'+#10+
                 '\ulnone\b0\i\fs22 Created by \b Alexandre Devilliers (aka Elbereth/Piecito)\par'+#10+
                 '\par'+#10+
                 '\b0\i0\fs20 Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+'\par'+#10+
                 'Driver Interface [DUCI] v'+inttostr(DUCI_VERSION)+' (v'+inttostr(DUCI_VERSION_COMPATIBLE)+' compatible) [using v'+inttostr(SupportedDUCI)+']\par'+#10+
                 'Compiled the '+DateToStr(CompileTime)+' at '+TimeToStr(CompileTime)+'\par'+#10+
                 'Based on SVN rev '+getSVNRevision(SVN_REVISION)+' ('+getSVNDate(SVN_DATE)+')\par'+#10+
                 '\par'+#10+
                 'List of enabled tools:\par'+#10;

    for x := Low(ListOfTools) to High(ListOfTools) do
    begin
      if ListOfTools[x].enabled then
        aboutText := aboutText + inttostr(x+1) + ': '+ListOfTools[x].name+ ' ('+ListOfTools[x].author+') ['+ListOfTools[x].comment+']\par'+#10+'URL: {\field{\*\fldinst HYPERLINK "'+ListOfTools[x].url+'"}{\fldrslt '+ListOfTools[x].url+'}}\par'+#10;
    end;

    aboutText := aboutText + '}'+#10;

  end
  else
  begin
    aboutText := 'Elbereth''s External Tools Convert plugin v'+getVersion(DRIVER_VERSION)+#10+
                 'Created by \b Alexandre Devilliers (aka Elbereth/Piecito)'+#10+#10+
                 'Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+#10+
                 'Driver Interface [DUCI] v'+inttostr(DUCI_VERSION)+' (v'+inttostr(DUCI_VERSION_COMPATIBLE)+' compatible) [using v'+inttostr(SupportedDUCI)+']'+#10+
                 'Compiled the '+DateToStr(CompileTime)+' at '+TimeToStr(CompileTime)+#10+
                 'Based on CVS rev '+getSVNRevision(SVN_REVISION)+' ('+getSVNDate(SVN_DATE)+')'+#10;
  end;

  showMsgBox('About Elbereth''s External Tools Convert Plugin...',aboutText);

end;

procedure ConfigBox; stdcall;
var frmExtConf: TfrmExtTool;
    OApp: THandle;
    itmX: TListItem;
    toolInfo: PToolInfo;
    x: integer;
begin

  OApp := Application.Handle;
  Application.Handle := AHandle;
  frmExtConf := TfrmExtTool.Create(AOwner);
  try
    frmExtConf.Caption := 'External Tools Convert Plugin v'+getVersion(DRIVER_VERSION)+' - Configuration';
    frmExtConf.lblExtra1.Caption := 'Created by Alexandre Devilliers (aka Elbereth/Piecito)';
    frmExtConf.lblExtra2.Caption := 'Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION);

    for x := Low(ListOfTools) to High(ListOfTools) do
    begin
      itmX := frmExtConf.lstTools.Items.Add;
      itmX.Checked := ListOfTools[x].enabled;
      itmX.Caption := ListOfTools[x].name;
      toolInfo := @ListOfTools[x];
      itmX.Data := toolInfo;
    end;
    frmExtConf.ShowModal;
  finally
    frmExtConf.Release;
  end;
  Application.Handle := OApp;

end;

exports
  DUCIVersion,
  DUCIVersionEx,
  ConfigBox,
  Convert,
  ConvertStream,
  GetFileConvert,
  IsFileCompatible,
  VersionInfo2,
  InitPlugin,
  InitPluginEx4,
  AboutBox;

begin
end.