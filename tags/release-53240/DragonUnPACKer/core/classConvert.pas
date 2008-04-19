unit classConvert;

// $Id: classConvert.pas,v 1.3 2005-12-16 20:15:47 elbereth Exp $
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
// Current DUCI (Dragon UnPACKer Convert Interface): v3
// ============================================================================

interface

uses
  lib_Language,
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
  TDUCIVersion = function(): Byte; stdcall;
  TIsFileCompatible = function(nam: ShortString; Offset, Size: Int64; fmt: ShortString; DataX, DataY: Integer): boolean; stdcall;
  TGetFileConvert = function(nam: ShortString; Offset, Size: Int64; fmt: ShortString; DataX, DataY: Integer): ConvertList; stdcall;
  TConvert = function(src, dst, nam, fmt, cnv: ShortString; Offset: Int64; DataX, DataY: Integer; Silent: Boolean): integer; stdcall;
  TConvertStream = function (src, dst: TStream; nam, fmt, cnv: ShortString; Offset: Int64; DataX, DataY: Integer; Silent: Boolean): integer; stdcall;
  TInitPlugin = procedure(percent: TPercentCallback; dlngstr: TLanguageCallback; dup5pth: shortstring); stdcall;
  TInitPlugin2 = procedure(percent: TPercentCallback; dlngstr: TLanguageCallback; dup5pth: shortstring; AppHandle: THandle; AppOwner: TComponent); stdcall;
  TVersionInfo = function(): ConvertInfo;
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
   Version : TVersionInfo;
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
  public
    Plugins: array[1..255] of Plugin;
    NumPlugins: Integer;
end;

implementation

{ TDrivers }

procedure TPlugins.FreePlugins;
var x: integer;
begin

  dup5Main.writeLogVerbose(1,replaceValue('%p',DLNGStr('LOGC01')+' ',inttostr(NumPlugins)));

  for x := 1 to NumPlugins do
  begin
    dup5Main.writeLogVerbose(2,' - '+Plugins[x].FileName+'...');
    FreeLibrary(Plugins[x].Handle);
    dup5Main.appendLogVerbose(2,' '+DLNGStr('LOG510'));
  end;

  dup5Main.appendLogVerbose(1,DLNGStr('LOG510'));

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

    if Plugins[x].TestFile(nam, Offset, Size, fmt, DataX, DataY) then
    begin
      CList := Plugins[x].GetList(nam, Offset, Size, fmt, DataX, DataY);
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
        if (@DUCIVer <> Nil) and ((DUCIVer = 1) or (DUCIVer = 2) or (DUCIVer = 3)) then
        begin
          dup5Main.appendLogVerbose(2,'DUCI v'+inttostr(DUCIVer)+' -');

          Inc(NumPlugins);

          Plugins[NumPlugins].DUCIVersion := DUCIVer;
          @Plugins[NumPlugins].TestFile := GetProcAddress(Handle, 'IsFileCompatible');
          @Plugins[NumPlugins].GetList := GetProcAddress(Handle, 'GetFileConvert');
          @Plugins[NumPlugins].Convert := GetProcAddress(Handle, 'Convert');

          if (DUCIVer = 1) then
          begin
            @Plugins[NumPlugins].Init := GetProcAddress(Handle, 'InitPlugin');
            @Plugins[NumPlugins].ShowAboutBox := GetProcAddress(Handle, 'AboutBox');
            @Plugins[NumPlugins].ShowConfigBox := GetProcAddress(Handle, 'ConfigBox');
          end
          else if (DUCIVer = 2) then
          begin
            @Plugins[NumPlugins].Init2 := GetProcAddress(Handle, 'InitPlugin');
            @Plugins[NumPlugins].ShowAboutBox2 := GetProcAddress(Handle, 'AboutBox');
            @Plugins[NumPlugins].ShowConfigBox2 := GetProcAddress(Handle, 'ConfigBox');
          end
          else if (DUCIVer = 3) then
          begin
            @Plugins[NumPlugins].Init2 := GetProcAddress(Handle, 'InitPlugin');
            @Plugins[NumPlugins].ShowAboutBox2 := GetProcAddress(Handle, 'AboutBox');
            @Plugins[NumPlugins].ShowConfigBox2 := GetProcAddress(Handle, 'ConfigBox');
            @Plugins[NumPlugins].ConvertStream := GetProcAddress(Handle, 'ConvertStream');
          end;

          @Plugins[NumPlugins].Version := GetProcAddress(Handle, 'VersionInfo');

          if (@Plugins[NumPlugins].TestFile = Nil)
          or (@Plugins[NumPlugins].GetList = Nil)
          or (@Plugins[NumPlugins].Convert = Nil)
          or ((DUCIVer = 1) and (@Plugins[NumPlugins].Init = Nil))
          or (((DUCIVer = 2) or (DUCIVer = 3)) and (@Plugins[NumPlugins].Init2 = Nil))
          or ((DUCIVer = 3) and (@Plugins[NumPlugins].ConvertStream = Nil))
          or (@Plugins[NumPlugins].Version = Nil)
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
            Plugins[NumPlugins].FileName := ExtractFileName(sr.Name);
            Plugins[NumPlugins].Handle := Handle;
            if (DUCIVer = 1) then
            begin
              Plugins[NumPlugins].Init(Percent,Language,dup5path);
              Plugins[NumPlugins].IsAboutBox := not(@Plugins[NumPlugins].ShowAboutBox = nil);
              Plugins[NumPlugins].IsConfigBox := not(@Plugins[NumPlugins].ShowConfigBox = nil);
            end
            else
            begin
              Plugins[NumPlugins].Init2(Percent,Language,dup5path,Application.Handle,curAOwner);
              Plugins[NumPlugins].IsAboutBox := not(@Plugins[NumPlugins].ShowAboutBox2 = nil);
              Plugins[NumPlugins].IsConfigBox := not(@Plugins[NumPlugins].ShowConfigBox2 = nil);
            end;
            dup5Main.appendLogVerbose(1,Plugins[NumPlugins].Version.Name +' v'+Plugins[NumPlugins].Version.Version)
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

  if (Plugins[drvnum].DUCIVersion = 1) then
  begin
    Plugins[drvnum].ShowAboutBox(hwnd,language);
  end
  else if (Plugins[drvnum].DUCIVersion = 2) or (Plugins[drvnum].DUCIVersion = 3) then
  begin
    Plugins[drvnum].ShowAboutBox2;
  end;

end;

procedure TPlugins.showConfigBox(hwnd, drvnum: integer);
begin

  if (Plugins[drvnum].DUCIVersion = 1) then
  begin
    Plugins[drvnum].ShowConfigBox(hwnd,language);
  end
  else if (Plugins[drvnum].DUCIVersion = 2) or (Plugins[drvnum].DUCIVersion = 3) then
  begin
    Plugins[drvnum].ShowConfigBox2;
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
    result := result or Plugins[x].TestFile(nam, offset, Size, fmt, DataX, DataY);
    inc(x);
  end;

end;

end.
