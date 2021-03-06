unit classHyperRipper;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is classHyperRipper.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

// ============================================================================
// classConvert unit / This unit manages the HiperRipper plugins (loading, use
//                   / and freeing)
// ----------------------------------------------------------------------------
// Current DUHI (Dragon UnPACKer HyperRipper Interface): v4
// History:
//   v3 - Added support for 64bits SearchFile (very big files)
//   v4 - Search reliability enhanced
// ============================================================================

interface

uses
  Forms,
  ComCtrls,
  lib_Language,
  lib_utils,
  Classes,
  Dialogs,
  Windows,
  Main,
  Graphics,
  U_IntList,
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
       FormatsList : array of FormatsListElemEx;
     end;
     FoundInfo = record
       Offset: integer;
       Size: integer;
       Ext: ShortString;
       GenType: integer;
     end;
     FoundInfo64 = record
       Offset: int64;
       Size: int64;
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
  TSearchBufferEx = function(format: Integer; buffer: PByteArray; bufSize: integer): TIntList; stdcall;
  TSearchFile = function(format: integer; handle: integer; offset: integer): FoundInfo; stdcall;
  TSearchFile64 = function(format: integer; handle: integer; offset: int64): FoundInfo64; stdcall;
  TInitPlugin = procedure(percent: TPercentCallback; dlngstr: TLanguageCallback; dup5pth: shortstring); stdcall;
  TInitPlugin2 = procedure(percent: TPercentCallback; dlngstr: TLanguageCallback; dup5pth: shortstring; AppHandle: THandle; AppOwner: TComponent); stdcall;
  TGetVersionInfo = function(): VersionInfo; stdcall;
  TShowOptionPanel = procedure(DriverID: integer);
  TShowBox = procedure(hwnd: integer; lngstr: TLanguageCallback); stdcall;
  TShowBox2 = procedure; stdcall;

type
   EDUHIUnknownPluginIdentifier = class(Exception);
   EDUHIFileIsTooBig = class(Exception);

type HRPlugin = record
   DUHIVersion : Byte;
   FileName : ShortString;
   Handle : THandle;
   GetList : TGetSearchFormats;
   SearchBuffer : TSearchBuffer;
   SearchBufferEx : TSearchBufferEx;
   SearchFile : TSearchFile;
   SearchFile64 : TSearchFile64;
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
    function searchBuffer(driverNumber, format: Integer; buffer: PByteArray; bufSize: integer): TIntList;
    function searchFile(driverNumber: integer; format: integer; handle: integer; offset: int64): FoundInfo64;
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

  if FindFirst(pth+'*.d5h', faAnyFile, sr) = 0 then
  begin
    repeat
      if IsConsole then
        write(sr.name+ ' ')
      else
        dup5Main.writeLogVerbose(1,' + '+sr.Name+' :');
      Handle := LoadLibrary(PChar(pth + sr.name));
      if Handle <> 0 then
      begin
        @DUHIVer := GetProcAddress(Handle, 'DUHIVersion');

        if (@DUHIVer <> Nil) and ((DUHIVer = 1) or (DUHIVer = 2) or (DUHIVer = 3) or (DUHIVer = 4)) then
        begin
          if IsConsole then
            write('IsDUHI... ')
          else
            dup5Main.appendLogVerbose(2,'DUHI v'+inttostr(DUHIVer)+' -');
          Inc(NumPlugins);

          Plugins[NumPlugins].DUHIVersion := DUHIVer;
          @Plugins[NumPlugins].GetList := GetProcAddress(Handle, 'GetSearchFormats');

          if (DUHIVer = 1) then
          begin
            @Plugins[NumPlugins].Init := GetProcAddress(Handle, 'InitPlugin');
            @Plugins[NumPlugins].ShowAboutBox := GetProcAddress(Handle, 'AboutBox');
            @Plugins[NumPlugins].ShowConfigBox := GetProcAddress(Handle, 'ConfigBox');
            @Plugins[NumPlugins].SearchFile := GetProcAddress(Handle, 'SearchFile');
            @Plugins[NumPlugins].SearchBuffer := GetProcAddress(Handle, 'SearchBuffer');
          end
          else if (DUHIVer = 2) then
          begin
            @Plugins[NumPlugins].Init2 := GetProcAddress(Handle, 'InitPlugin');
            @Plugins[NumPlugins].ShowAboutBox2 := GetProcAddress(Handle, 'AboutBox');
            @Plugins[NumPlugins].ShowConfigBox2 := GetProcAddress(Handle, 'ConfigBox');
            @Plugins[NumPlugins].SearchFile := GetProcAddress(Handle, 'SearchFile');
            @Plugins[NumPlugins].SearchBuffer := GetProcAddress(Handle, 'SearchBuffer');
          end
          else if (DUHIVer = 3) then
          begin
            @Plugins[NumPlugins].Init2 := GetProcAddress(Handle, 'InitPlugin');
            @Plugins[NumPlugins].ShowAboutBox2 := GetProcAddress(Handle, 'AboutBox');
            @Plugins[NumPlugins].ShowConfigBox2 := GetProcAddress(Handle, 'ConfigBox');
            @Plugins[NumPlugins].SearchFile64 := GetProcAddress(Handle, 'SearchFile64');
            @Plugins[NumPlugins].SearchBuffer := GetProcAddress(Handle, 'SearchBuffer');
          end
          else if (DUHIVer = 4) then
          begin
            @Plugins[NumPlugins].Init2 := GetProcAddress(Handle, 'InitPlugin');
            @Plugins[NumPlugins].ShowAboutBox2 := GetProcAddress(Handle, 'AboutBox');
            @Plugins[NumPlugins].ShowConfigBox2 := GetProcAddress(Handle, 'ConfigBox');
            @Plugins[NumPlugins].SearchFile64 := GetProcAddress(Handle, 'SearchFile64');
            @Plugins[NumPlugins].SearchBufferEx := GetProcAddress(Handle, 'SearchBufferEx');
          end;

          @Plugins[NumPlugins].Version := GetProcAddress(Handle, 'GetVersionInfo');
          @Plugins[NumPlugins].ShowOptionPanel := GetProcAddress(Handle, 'ShowOptionPanel');

          if (@Plugins[NumPlugins].GetList = Nil)
          or ((DUHIVer <> 4) and (@Plugins[NumPlugins].SearchBuffer = Nil))
          or (((DUHIVer = 1) or (DUHIVer = 2)) and (@Plugins[NumPlugins].SearchFile = Nil))
          or ((DUHIVer = 1) and (@Plugins[NumPlugins].Init = Nil))
          or ((DUHIVer = 2) and (@Plugins[NumPlugins].Init2 = Nil))
          or ((DUHIVer = 3) and (@Plugins[NumPlugins].SearchFile64 = Nil))
          or ((DUHIVer = 4) and (@Plugins[NumPlugins].SearchBufferEx = Nil))
          or (@Plugins[NumPlugins].Version = Nil)
          then
          begin
            if dup5Main.getVerboseLevel = 0 then
              dup5Main.writeLog(' + '+sr.Name+' :');
            dup5Main.appendLog(DLNGstr('ERRH02'));
            dup5Main.colorLog(clRed);
            dec(NumPlugins);
            FreeLibrary(handle);
          end
          else
          begin
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
            dup5Main.appendLogVerbose(1,Plugins[NumPlugins].Version.Name +' v'+ GetPlugVersion(Plugins[NumPlugins].Version.Version));
            if (DUHIVer < 3) then
            begin
              if dup5Main.getVerboseLevel = 0 then
                dup5Main.writeLog(' + '+sr.Name+' : '+Plugins[NumPlugins].Version.Name +' v'+ GetPlugVersion(Plugins[NumPlugins].Version.Version));
              dup5Main.appendLog('['+DLNGStr('ERRH03')+']');
              dup5Main.colorLog(clRed);
            end;
          end;
        end
        else
        begin
          if dup5Main.getVerboseLevel = 0 then
            dup5Main.writeLog(' + '+sr.Name+' :');
          dup5Main.appendLog(DLNGstr('ERRH01'));
          dup5Main.colorLog(clRed);
//            MessageDlg(DLNGstr('ERRH01')+#10+sr.Name,mtWarning,[mbOk],0);
//          dec(NumPlugins);
          FreeLibrary(handle);
        end;
      end

    until FindNext(sr) <> 0;

  end
  else
    NumPlugins := 0;

  FindClose(sr);

end;

// Function to encapsulate call to searchFile
// This allow to manage old plugins that do not support 64bit for file access
function THRPlugins.searchFile(driverNumber, format, handle: integer;
  offset: int64): FoundInfo64;
var found32: FoundInfo;
begin

  if ((driverNumber > 0) and (driverNumber <= NumPlugins)) then
  begin
    if (Plugins[driverNumber].DUHIVersion = 3)
    or (Plugins[driverNumber].DUHIVersion = 4) then
    begin
      result := Plugins[driverNumber].searchFile64(format,handle,offset);
    end
    else if offset <= high(integer) then
    begin
      found32 := Plugins[driverNumber].SearchFile(format,handle,offset);
      result.Offset := found32.Offset;
      result.Size := found32.Size;
      result.Ext := found32.Ext;
      result.GenType := found32.GenType;
    end
    else
    begin

      raise EDUHIFileIsTooBig.Create(ReplaceValue('%p',DLNGStr('ERRH05'),Plugins[driverNumber].Version.Name + ' v'+getPlugVersion(Plugins[driverNumber].Version.Version)+' ('+Plugins[driverNumber].FileName+')'));

    end;
  end
  else
  begin

    raise EDUHIUnknownPluginIdentifier.Create(ReplaceValue('%i',DLNGStr('ERRH04'),inttostr(driverNumber)));

  end;

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
  else if (Plugins[drvnum].DUHIVersion = 2) or (Plugins[drvnum].DUHIVersion = 3) or (Plugins[drvnum].DUHIVersion = 4) then
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
  else if (Plugins[drvnum].DUHIVersion = 2) or (Plugins[drvnum].DUHIVersion = 3) or (Plugins[drvnum].DUHIVersion = 4) then
  begin
    Plugins[drvnum].ShowConfigBox2;
  end;

end;

// Function to encapsulate call to searchBuffer
// This allow to manage old plugins that do not support support the more reliable
// searchBufferEx
function THRPlugins.searchBuffer(driverNumber, format: Integer; buffer: PByteArray; bufSize: integer): TIntList;
var tmpRes: Integer;
begin

  if ((driverNumber > 0) and (driverNumber <= NumPlugins)) then
  begin
    if (Plugins[driverNumber].DUHIVersion = 4) then
    begin
      result := Plugins[driverNumber].SearchBufferEx(format,buffer,bufSize);
    end
    else
    begin
      result := TIntList.Create;
      tmpRes := Plugins[driverNumber].SearchBuffer(format,buffer,bufSize);
      if tmpRes > -1 then
        result.Add(tmpRes);
    end;
  end
  else
  begin

    raise EDUHIUnknownPluginIdentifier.Create(ReplaceValue('%i',DLNGStr('ERRH04'),inttostr(driverNumber)));

  end;

end;

end.
