unit classConvert;

// $Id$
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/classConvert.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is classConvert.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

// ============================================================================
// classConvert unit / This unit manages the convert plugins (loading, use and
//                   / freeing)
// ----------------------------------------------------------------------------
// Current DUCI (Dragon UnPACKer Convert Interface): v4
// ============================================================================

interface

uses
  lib_Language,
  lib_utils,
  lib_temptools,
  UBufferedFS,
  classConvertExport,
  Forms,
  Dialogs,
  Windows,
  Classes,
  Main,
  Graphics,
  SysUtils;

type ConvertListElem = record
       Display: ShortString;
       Ext: ShortString;
       ID: ShortString;
     end;
     ConvertList = record
       NumFormats :  Byte;
       List : array[1..255] of ConvertListElem;
     end;
     ExtList = record
       Info: ConvertListElem;
       Plugin: Integer;
     end;
     ExtConvertList = record
       NumFormats :  Byte;
       List : array[1..255] of ExtList;
     end;
     ConvertInfo = record
       Name: ShortString;
       Version: ShortString;
       Author: ShortString;
       Comment: ShortString;
       VerID: Integer;
     end;

type
  TPercentCallback = procedure (p: byte);
  TLanguageCallback = function (lngid: ShortString): ShortString;
  TMsgBoxCallback = procedure(const title, msg: AnsiString);
  TDUCIVersion = function(): Byte; stdcall;
  TDUCIVersionEx = function(supported: byte): Byte; stdcall;
  TIsFileCompatible = function(nam: ShortString; Offset, Size: Int64; fmt: ShortString; DataX, DataY: Integer): boolean; stdcall;
  TGetFileConvert = function(nam: ShortString; Offset, Size: Int64; fmt: ShortString; DataX, DataY: Integer): ConvertList; stdcall;
  TConvert = function(src, dst, nam, fmt, cnv: ShortString; Offset: Int64; DataX, DataY: Integer; Silent: Boolean): integer; stdcall;
  TConvertStream = function (src, dst: TStream; nam, fmt, cnv: ShortString; Offset: Int64; DataX, DataY: Integer; Silent: Boolean): integer; stdcall;
  TInitPlugin = procedure(percent: TPercentCallback; dlngstr: TLanguageCallback; dup5pth: shortstring); stdcall;
  TInitPlugin2 = procedure(percent: TPercentCallback; dlngstr: TLanguageCallback; dup5pth: shortstring; AppHandle: THandle; AppOwner: TComponent); stdcall;
  TInitPluginEx4 = procedure(MsgBox: TMsgBoxCallback); stdcall;
  TVersionInfo = function(): ConvertInfo;
  TVersionInfo2 = function(): ConvertInfo; stdcall;
  TShowBox = procedure(hwnd: integer; lngstr: TLanguageCallback); stdcall;
  TShowBox2 = procedure; stdcall;

type plugin = record
   DUCIVersion : Byte;
   FileName : ShortString;
   Handle : THandle;
   TestFile : TIsFileCompatible;
   GetList : TGetFileConvert;
   Convert : TConvert;
   ConvertStream : TConvertStream;
   Init : TInitPlugin;
   Init2 : TInitPlugin2;
   InitEx4 : TInitPluginEx4;
   Version : TVersionInfo;
   Version2 : TVersionInfo2;
   ShowAboutBox : TShowBox;
   ShowAboutBox2 : TShowBox2;
   IsAboutBox : Boolean;
   ShowConfigBox : TShowBox;
   ShowConfigBox2 : TShowBox2;
   IsConfigBox : Boolean;
 end;

// ----------------------------------------------------------------------------
// TPLugins class / This class manages the convert plugins
//                / Number of plugins is fixed (255), that means no more than
//                / 255 convert plugins can be loaded
// ----------------------------------------------------------------------------
 type TPlugins = class
    procedure LoadPlugins(pth: String);
    procedure FreePlugins;
    function GetFileConvert(nam: ShortString; Offset, Size: int64; fmt: ShortString; DataX, DataY: integer): extconvertlist;
    function TestFileConvert(nam: ShortString; Offset, Size: int64; fmt: ShortString; DataX, DataY: integer): boolean;
    procedure SetPercent(p: TPercentCallback);
    procedure SetLanguage(l: TLanguageCallback);
    procedure SetPath(pth: String);
    procedure SetOwner(AOwner: TComponent);
    procedure showAboutBox(hwnd: integer; drvnum: integer);
    procedure showConfigBox(hwnd: integer; drvnum: integer);
  private
    Percent: TPercentCallback;
    Language: TLanguageCallback;
    DUP5Path: ShortString;
    CurAOwner: TComponent;
  protected
    Plugins: array of Plugin;
    NumPlugins: Integer;
  public
    function getNumPlugins(): integer;
    function getPluginInfo(pid: integer): ConvertInfoEx;
    function convert(pid: integer; src, dst: TStream; nam, fmt, cnv: ShortString; Offset: Int64; DataX, DataY: Integer; Silent: Boolean): boolean;
end;

type EUndefinedPlugin = class(Exception);

const
  DUCIVERSION = 4;  // Max supported DUCIVersion

implementation

procedure showMsgBox(const title, msg: AnsiString);
begin

  dup5Main.messageDlgTitle(title,msg,[mbOk],0);

end;

{ TDrivers }

function TPlugins.convert(pid: integer; src, dst: TStream; nam, fmt, cnv: ShortString; Offset: Int64; DataX, DataY: Integer; Silent: Boolean): boolean;
var stmFile: TFileStream;
    tmpfil, tmpfil2: string;
    res: integer;
begin

  dec(pid);

  if (pid < Low(Plugins)) or (pid > High(Plugins)) then
    raise EUndefinedPlugin.Create('Min: '+inttostr(Low(Plugins))+' / Max: '+inttostr(High(Plugins))+' / Asked: '+inttostr(pid));

  if Plugins[pid].DUCIVersion < 3 then
  begin
    tmpfil := getTemporaryDir+getTemporaryFilename('src');
    stmFile := TFileStream.Create(tmpfil,fmCreate);
    try
      stmFile.CopyFrom(src,src.size);
    finally
      FreeAndNil(stmFile);
    end;
    tmpfil2 := getTemporaryDir+getTemporaryFilename('dst');
    result := (Plugins[pid].Convert(tmpfil,tmpfil2,nam,fmt,cnv,Offset,DataX,DataY,Silent) = 0);
    if result then
    begin
      stmFile := TFileStream.Create(tmpfil2,fmOpenRead);
      try
        dst.CopyFrom(stmFile,stmFile.Size);
      finally
        FreeAndNil(stmFile);
      end;
      try
        if FileExists(tmpfil2) then
          DeleteFile(tmpfil2);
      except
        dup5Main.tempFiles.Add(tmpfil2);
      end;
    end;
    try
      if FileExists(tmpfil) then
        DeleteFile(tmpfil);
    except
      dup5Main.tempFiles.Add(tmpfil);
    end;
  end
  else
    result := (Plugins[pid].ConvertStream(src,dst,nam,fmt,cnv,Offset,DataX,DataY,Silent) = 0);

  if result then
    dup5Main.appendLog(DLNGStr('LOG510'))
  else
  begin
    dup5Main.colorLog(clRed);
    dup5Main.appendLog(DLNGStr('LOG512'));
  end;

end;

function TPlugins.getNumPlugins(): integer;
begin

  result := NumPlugins;

end;

function TPlugins.getPluginInfo(pid: integer): ConvertInfoEx;
begin

  dec(pid);

  if (pid < Low(Plugins)) or (pid > High(Plugins)) then
    raise EUndefinedPlugin.Create('Min: '+inttostr(Low(Plugins))+' / Max: '+inttostr(High(Plugins))+' / Asked: '+inttostr(pid));

  result.DUCIVersion := Plugins[pid].DUCIVersion;

  if (Plugins[pid].DUCIVersion <= 3) then
  begin
    result.Name := Plugins[pid].Version.Name;
    result.Version := Plugins[pid].Version.Version;
    result.Author := Plugins[pid].Version.Author;
    result.Comment := Plugins[pid].Version.Comment;
    result.VerID := Plugins[pid].Version.VerID;
  end
  else
  begin
    result.Name := Plugins[pid].Version2.Name;
    result.Version := Plugins[pid].Version2.Version;
    result.Author := Plugins[pid].Version2.Author;
    result.Comment := Plugins[pid].Version2.Comment;
    result.VerID := Plugins[pid].Version2.VerID;
  end;

  result.Filename := Plugins[pid].FileName;
  result.isAboutBox := Plugins[pid].IsAboutBox;
  result.isConfigBox := Plugins[pid].IsConfigBox;

end;

procedure TPlugins.FreePlugins;
var x: integer;
begin

  for x := 1 to NumPlugins do
    FreeLibrary(Plugins[x].Handle);

  SetLength(Plugins,0);
  NumPlugins := 0;

end;

function TPlugins.GetFileConvert(nam: ShortString; Offset, Size: int64; fmt: ShortString; DataX,
  DataY: integer): extconvertlist;
var Clist: ConvertList;
    x, z: integer;
begin

  x := 1;
  result.NumFormats := 0;
  while (x <=NumPlugins) do
  begin

    if Plugins[x-1].TestFile(nam, Offset, Size, fmt, DataX, DataY) then
    begin
      CList := Plugins[x-1].GetList(nam, Offset, Size, fmt, DataX, DataY);
      for z := 1 to CList.NumFormats do
      begin
        Inc(result.NumFormats);
        result.List[result.NumFormats].Info := CList.List[z];
        result.List[result.NumFormats].Plugin := x;
      end;
    end;
    inc(x);
  end;

end;

procedure TPlugins.LoadPlugins(pth: String);
var sr: TSearchRec;
    DUCIVer: TDUCIVersion;
    DUCIVerEx: TDUCIVersionEx;
    DUCIVerVal, DUCIVerExVal: byte;
    Handle: THandle;
begin

  NumPlugins := 0;

  if FindFirst(pth+'*.d5c', faAnyFile, sr) = 0 then
  begin
    repeat
      if IsConsole then
        write(sr.name+ ' ')
      else
        dup5Main.writeLogVerbose(1,' + '+sr.Name+' :');
      Handle := LoadLibrary(PChar(pth + sr.name));
      if Handle <> 0 then
      begin
        @DUCIVer := GetProcAddress(Handle, 'DUCIVersion');
        if (@DUCIVer <> Nil) then
          DUCIVerVal := DUCIVer;
        @DUCIVerEx := GetProcAddress(Handle, 'DUCIVersionEx');
        if (@DUCIVerEx <> Nil) then
          DUCIVerExVal := DUCIVerEx(DUCIVERSION);
        if (@DUCIVer <> Nil) and (DUCIVerVal >= 1) and (DUCIVerVal <= DUCIVERSION) then
        begin
          Inc(NumPlugins);
          SetLength(Plugins,NumPlugins);
          if (@DUCIVerEx <> Nil) and (DUCIVerExVal >= 4) and (DUCIVerExVal <= DUCIVERSION) then
            Plugins[NumPlugins-1].DUCIVersion := DUCIVerExVal
          else
            Plugins[NumPlugins-1].DUCIVersion := DUCIVerVal;
          dup5Main.appendLogVerbose(2,'DUCI v'+inttostr(Plugins[NumPlugins-1].DUCIVersion)+' -');

          @Plugins[NumPlugins-1].TestFile := GetProcAddress(Handle, 'IsFileCompatible');
          @Plugins[NumPlugins-1].GetList := GetProcAddress(Handle, 'GetFileConvert');
          @Plugins[NumPlugins-1].Convert := GetProcAddress(Handle, 'Convert');

          if (Plugins[NumPlugins-1].DUCIVersion = 1) then
          begin
            @Plugins[NumPlugins-1].Init := GetProcAddress(Handle, 'InitPlugin');
            @Plugins[NumPlugins-1].ShowAboutBox := GetProcAddress(Handle, 'AboutBox');
            @Plugins[NumPlugins-1].ShowConfigBox := GetProcAddress(Handle, 'ConfigBox');
            @Plugins[NumPlugins-1].Version := GetProcAddress(Handle, 'VersionInfo');
          end
          else if (Plugins[NumPlugins-1].DUCIVersion = 2) then
          begin
            @Plugins[NumPlugins-1].Init2 := GetProcAddress(Handle, 'InitPlugin');
            @Plugins[NumPlugins-1].ShowAboutBox2 := GetProcAddress(Handle, 'AboutBox');
            @Plugins[NumPlugins-1].ShowConfigBox2 := GetProcAddress(Handle, 'ConfigBox');
            @Plugins[NumPlugins-1].Version := GetProcAddress(Handle, 'VersionInfo');
          end
          else if (Plugins[NumPlugins-1].DUCIVersion = 3) then
          begin
            @Plugins[NumPlugins-1].Init2 := GetProcAddress(Handle, 'InitPlugin');
            @Plugins[NumPlugins-1].ShowAboutBox2 := GetProcAddress(Handle, 'AboutBox');
            @Plugins[NumPlugins-1].ShowConfigBox2 := GetProcAddress(Handle, 'ConfigBox');
            @Plugins[NumPlugins-1].ConvertStream := GetProcAddress(Handle, 'ConvertStream');
            @Plugins[NumPlugins-1].Version := GetProcAddress(Handle, 'VersionInfo');
          end
          else if (Plugins[NumPlugins-1].DUCIVersion >= 4) then
          begin
            @Plugins[NumPlugins-1].Init2 := GetProcAddress(Handle, 'InitPlugin');
            @Plugins[NumPlugins-1].ShowAboutBox2 := GetProcAddress(Handle, 'AboutBox');
            @Plugins[NumPlugins-1].ShowConfigBox2 := GetProcAddress(Handle, 'ConfigBox');
            @Plugins[NumPlugins-1].ConvertStream := GetProcAddress(Handle, 'ConvertStream');
            @Plugins[NumPlugins-1].Version2 := GetProcAddress(Handle, 'VersionInfo2');
            @Plugins[NumPlugins-1].InitEx4 := GetProcAddress(Handle, 'InitPluginEx4');
          end;


          if (@Plugins[NumPlugins-1].TestFile = Nil)
          or (@Plugins[NumPlugins-1].GetList = Nil)
          or (@Plugins[NumPlugins-1].Convert = Nil)
          or ((Plugins[NumPlugins-1].DUCIVersion = 1) and (@Plugins[NumPlugins-1].Init = Nil))
          or (((Plugins[NumPlugins-1].DUCIVersion = 2) or (Plugins[NumPlugins-1].DUCIVersion = 3)) and (@Plugins[NumPlugins-1].Init2 = Nil))
          or ((Plugins[NumPlugins-1].DUCIVersion = 3) and (@Plugins[NumPlugins-1].ConvertStream = Nil))
          or ((Plugins[NumPlugins-1].DUCIVersion >= 1) and (Plugins[NumPlugins-1].DUCIVersion <= 3) and (@Plugins[NumPlugins-1].Version = Nil))
          or ((Plugins[NumPlugins-1].DUCIVersion >= 4) and (Plugins[NumPlugins-1].DUCIVersion <= DUCIVERSION) and (@Plugins[NumPlugins-1].Version2 = Nil) and (@Plugins[NumPlugins-1].InitEx4 = Nil))
          then
          begin
            if dup5Main.getVerboseLevel = 0 then
              dup5Main.writeLog(' + '+sr.Name+' :');
            dup5Main.appendLog(DLNGstr('ERRC02'));
            dup5Main.colorLog(clRed);
            //MessageDlg(DLNGstr('ERRC02')+#10+sr.Name,mtWarning,[mbOk],0);
            dec(NumPlugins);
            FreeLibrary(handle);
          end
          else
          begin
            Plugins[NumPlugins-1].FileName := ExtractFileName(sr.Name);
            Plugins[NumPlugins-1].Handle := Handle;
            if (Plugins[NumPlugins-1].DUCIVersion = 1) then
            begin
              Plugins[NumPlugins-1].Init(Percent,Language,dup5path);
              Plugins[NumPlugins-1].IsAboutBox := not(@Plugins[NumPlugins-1].ShowAboutBox = nil);
              Plugins[NumPlugins-1].IsConfigBox := not(@Plugins[NumPlugins-1].ShowConfigBox = nil);
            end
            else
            begin
              Plugins[NumPlugins-1].Init2(Percent,Language,dup5path,Application.Handle,curAOwner);
              Plugins[NumPlugins-1].IsAboutBox := not(@Plugins[NumPlugins-1].ShowAboutBox2 = nil);
              Plugins[NumPlugins-1].IsConfigBox := not(@Plugins[NumPlugins-1].ShowConfigBox2 = nil);
            end;
            if (Plugins[NumPlugins-1].DUCIVersion <= 3) then
              dup5Main.appendLogVerbose(1,Plugins[NumPlugins-1].Version.Name +' v'+Plugins[NumPlugins-1].Version.Version)
            else
            begin
              dup5Main.appendLogVerbose(1,Plugins[NumPlugins-1].Version2.Name +' v'+Plugins[NumPlugins-1].Version2.Version);
              Plugins[NumPlugins-1].InitEx4(showMsgBox);
            end;
          end;
        end
        else
        begin
          if dup5Main.getVerboseLevel = 0 then
            dup5Main.writeLog(' + '+sr.Name+' :');
          dup5Main.appendLog(DLNGstr('ERRC01'));
          dup5Main.colorLog(clRed);
          //MessageDlg(DLNGstr('ERRC01')+#10+sr.Name,mtWarning,[mbOk],0);
          FreeLibrary(handle);
        end;
      end

    until FindNext(sr) <> 0;

  end
  else
    NumPlugins := 0;

  FindClose(sr);

end;

procedure TPlugins.SetLanguage(l: TLanguageCallback);
begin

  Language := l;

end;

procedure TPlugins.SetOwner(AOwner: TComponent);
begin

  CurAOwner := AOwner;

end;

procedure TPlugins.SetPath(pth: String);
begin

  DUP5Path := pth;

end;

procedure TPlugins.SetPercent(p: TPercentCallback);
begin

  Percent := p;

end;

procedure TPlugins.showAboutBox(hwnd, drvnum: integer);
begin

  if (Plugins[drvnum-1].DUCIVersion = 1) then
  begin
    Plugins[drvnum-1].ShowAboutBox(hwnd,language);
  end
  else if (Plugins[drvnum-1].DUCIVersion >= 2) then
  begin
    Plugins[drvnum-1].ShowAboutBox2;
  end;

end;

procedure TPlugins.showConfigBox(hwnd, drvnum: integer);
begin

  if (Plugins[drvnum-1].DUCIVersion = 1) then
  begin
    Plugins[drvnum-1].ShowConfigBox(hwnd,language);
  end
  else if (Plugins[drvnum-1].DUCIVersion >= 2) then
  begin
    Plugins[drvnum-1].ShowConfigBox2;
  end;

end;

function TPlugins.TestFileConvert(nam: ShortString; Offset, Size: int64; fmt: ShortString; DataX,
  DataY: integer): boolean;
var x: integer;
begin

  x := 1;
  result := false;
  while (x <=NumPlugins) do
  begin
    result := result or Plugins[x-1].TestFile(nam, offset, Size, fmt, DataX, DataY);
    inc(x);
  end;

end;



end.
