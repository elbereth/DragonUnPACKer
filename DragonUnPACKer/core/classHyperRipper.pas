unit classHyperRipper;

// $Id: classHyperRipper.pas,v 1.1.1.1 2004-05-08 10:25:13 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/classHyperRipper.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is classHyperRipper.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Forms,
  ComCtrls,
  lib_Language,
  Classes,
  Dialogs,
  Windows,
  SysUtils;

type FormatsListElem = record
       GenType: Integer;
       Format: ShortString;
       Desc: ShortString;
       ID: Integer;
       IsConfig: Boolean;
     end;
     SearchFormatsList = record
       NumFormats :  Byte;
       FormatsList : array[1..255] of FormatsListElem;
     end;
     FormatsListElemEx = record
       GenType: Integer;
       Format: ShortString;
       Desc: ShortString;
       ID: Integer;
       DriverNum: Integer;
       IsConfig: boolean;
     end;
     ExtSearchFormatsList = record
       NumFormats : Integer;
       FormatsList : array[1..1000] of FormatsListElemEx;
     end;
     FoundInfo = record
       Offset: integer;
       Size: integer;
       Ext: ShortString;
       GenType: integer;
     end;
     VersionInfo = record
       Name: ShortString;
       Author: ShortString;
       Comment: ShortString;
       Version: Integer;
     end;

type
  TDUHIVersion = function(): Byte;
  TPercentCallback = procedure (p: byte);
  TLanguageCallback = function (lngid: ShortString): ShortString;
  TGetSearchFormats = function(): SearchFormatsList; stdcall;
  TSearchBuffer = function(format: integer; buffer: PByteArray; bufSize: integer): integer; stdcall;
  TSearchFile = function(format: integer; handle: integer; offset: integer): FoundInfo; stdcall;
  TInitPlugin = procedure(percent: TPercentCallback; dlngstr: TLanguageCallback; dup5pth: shortstring); stdcall;
  TInitPlugin2 = procedure(percent: TPercentCallback; dlngstr: TLanguageCallback; dup5pth: shortstring; AppHandle: THandle; AppOwner: TComponent); stdcall;
  TGetVersionInfo = function(): VersionInfo; stdcall;
  TShowOptionPanel = procedure(DriverID: integer);
  TShowBox = procedure(hwnd: integer; lngstr: TLanguageCallback); stdcall;
  TShowBox2 = procedure; stdcall;

type HRPlugin = record
   DUHIVersion : Byte;
   FileName : ShortString;
   Handle : THandle;
   GetList : TGetSearchFormats;
   SearchBuffer : TSearchBuffer;
   SearchFile : TSearchFile;
   Init : TInitPlugin;
   Init2 : TInitPlugin2;
   Version : TGetVersionInfo;
   ShowOptionPanel : TShowOptionPanel;
   ShowAboutBox : TShowBox;
   ShowAboutBox2 : TShowBox2;
   IsAboutBox : Boolean;
   ShowConfigBox : TShowBox;
   ShowConfigBox2 : TShowBox2;
   IsConfigBox : Boolean;
 end;

type THRPlugins = class
    procedure LoadPlugins(pth: String);
    procedure FreePlugins;

    function GetFormatsList(): ExtSearchFormatsList;

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
    Plugins: array[1..255] of HRPlugin;
    NumPlugins: Integer;
end;

implementation

{ TDrivers }

procedure THRPlugins.FreePlugins;
var x: integer;
begin

  if IsConsole then
    write('Freeing '+inttostr(NumPlugins)+' drivers... ');

  for x := 1 to NumPlugins do
    FreeLibrary(Plugins[x].Handle);

  if IsConsole then
    writeln('OK');

end;

function THRPlugins.GetFormatsList(): ExtSearchFormatsList;
var list: SearchFormatsList;
    x, z: integer;
begin

  x := 1;
  result.NumFormats := 0;
  while (x <=NumPlugins) do
  begin

    list := Plugins[x].GetList;

    for z := 1 to List.NumFormats do
    begin
      Inc(result.NumFormats);
      result.FormatsList[result.NumFormats].GenType := List.FormatsList[z].GenType;
      result.FormatsList[result.NumFormats].Format := List.FormatsList[z].Format;
      result.FormatsList[result.NumFormats].Desc := List.FormatsList[z].Desc;
      result.FormatsList[result.NumFormats].ID := List.FormatsList[z].ID;
      result.FormatsList[result.NumFormats].DriverNum := x;
      result.FormatsList[result.NumFormats].IsConfig := List.FormatsList[z].IsConfig;
    end;
    inc(x);
  end;

end;

procedure THRPlugins.LoadPlugins(pth: String);
var sr: TSearchRec;
    DUHIVer: TDUHIVersion;
    Handle: THandle;
begin

  NumPlugins := 0;

  if IsConsole then
    writeln('Looking for HyperRipper plugins...');

  if FindFirst(pth+'*.d5h', faAnyFile, sr) = 0 then
  begin
    repeat
      if IsConsole then
        write(sr.name+ ' ');
      Handle := LoadLibrary(PChar(pth + sr.name));
      if Handle <> 0 then
      begin
        if IsConsole then
          write('Loaded... ');
        @DUHIVer := GetProcAddress(Handle, 'DUHIVersion');

        if (@DUHIVer <> Nil) and ((DUHIVer = 1) or (DUHIVer = 2)) then
        begin
          if IsConsole then
            write('IsDUHI... ');
          Inc(NumPlugins);

          Plugins[NumPlugins].DUHIVersion := DUHIVer;
          @Plugins[NumPlugins].GetList := GetProcAddress(Handle, 'GetSearchFormats');
          @Plugins[NumPlugins].SearchBuffer := GetProcAddress(Handle, 'SearchBuffer');
          @Plugins[NumPlugins].SearchFile := GetProcAddress(Handle, 'SearchFile');

          if (DUHIVer = 1) then
          begin
            @Plugins[NumPlugins].Init := GetProcAddress(Handle, 'InitPlugin');
            @Plugins[NumPlugins].ShowAboutBox := GetProcAddress(Handle, 'AboutBox');
            @Plugins[NumPlugins].ShowConfigBox := GetProcAddress(Handle, 'ConfigBox');
          end
          else if (DUHIVer = 2) then
          begin
            @Plugins[NumPlugins].Init2 := GetProcAddress(Handle, 'InitPlugin');
            @Plugins[NumPlugins].ShowAboutBox2 := GetProcAddress(Handle, 'AboutBox');
            @Plugins[NumPlugins].ShowConfigBox2 := GetProcAddress(Handle, 'ConfigBox');
          end;

          @Plugins[NumPlugins].Version := GetProcAddress(Handle, 'GetVersionInfo');
          @Plugins[NumPlugins].ShowOptionPanel := GetProcAddress(Handle, 'ShowOptionPanel');

          if (@Plugins[NumPlugins].GetList = Nil)
          or (@Plugins[NumPlugins].SearchBuffer = Nil)
          or (@Plugins[NumPlugins].SearchFile = Nil)
          or ((DUHIVer = 1) and (@Plugins[NumPlugins].Init = Nil))
          or ((DUHIVer = 2) and (@Plugins[NumPlugins].Init2 = Nil))
          or (@Plugins[NumPlugins].Version = Nil)
          then
          begin
            if IsConsole then
              writeln('Malformed!')
            else
              MessageDlg(DLNGstr('ERRH02')+#10+sr.Name,mtWarning,[mbOk],0);
            dec(NumPlugins);
            FreeLibrary(handle);
          end
          else
          begin
            if IsConsole then
              writeln('OK');
            Plugins[NumPlugins].FileName := ExtractFileName(sr.Name);
            Plugins[NumPlugins].Handle := Handle;
            if (DUHIVer = 1) then
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
          end;
        end
        else
        begin
          if IsConsole then
            writeln('Bad DUHI')
          else
            MessageDlg(DLNGstr('ERRH01')+#10+sr.Name,mtWarning,[mbOk],0);
//          dec(NumPlugins);
          FreeLibrary(handle);
        end;
      end

    until FindNext(sr) <> 0;

  end
  else
    NumPlugins := 0;

  FindClose(sr);

  if IsConsole then
    writeln('Finished!');

end;

procedure THRPlugins.SetLanguage(l: TLanguageCallback);
begin

  Language := l;

end;

procedure THRPlugins.SetOwner(AOwner: TComponent);
begin

  CurAOwner := AOwner;

end;

procedure THRPlugins.SetPath(pth: String);
begin

  DUP5Path := pth;

end;

procedure THRPlugins.SetPercent(p: TPercentCallback);
begin

  Percent := p;

end;

procedure THRPlugins.showAboutBox(hwnd, drvnum: integer);
begin

  if (Plugins[drvnum].DUHIVersion = 1) then
  begin
    Plugins[drvnum].ShowAboutBox(hwnd,language);
  end
  else if (Plugins[drvnum].DUHIVersion = 2) then
  begin
    Plugins[drvnum].ShowAboutBox2;
  end;

end;

procedure THRPlugins.showConfigBox(hwnd, drvnum: integer);
begin

  if (Plugins[drvnum].DUHIVersion = 1) then
  begin
    Plugins[drvnum].ShowConfigBox(hwnd,language);
  end
  else if (Plugins[drvnum].DUHIVersion = 2) then
  begin
    Plugins[drvnum].ShowConfigBox2;
  end;

end;

end.
