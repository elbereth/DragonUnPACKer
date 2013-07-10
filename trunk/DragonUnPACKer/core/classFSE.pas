unit classFSE;

// $Id$
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/classFSE.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is classFSE.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

// ----------------------------------------------------------------------------
// Information
// ----------------------------------------------------------------------------
// This file contains the TDrivers class. This is truly the core of Dragon
// UnPACKer as it is this class that loads driver plugins, parse results and
// prepare everything for display (normal display, directory specific, search
// results, etc..).
// ----------------------------------------------------------------------------

interface

uses auxFSE, Classes, Comctrls, Controls, DateUtils, Dialogs, Forms,
     lib_binCopy, lib_binutils, lib_language, lib_utils, Main, prg_ver, Registry,
     spec_HRF, strutils, Windows, SysUtils, Error, Graphics, commonTypes, virtualtrees,
     HashTrie, spec_DUDI;

{ Record declaration }

type

  ExtensionsResult = record            // This record is used to store the list
    Num: integer;                      // of all supported extensions (that
    Lists: array[1..5] of ShortString; // Dragon UnPACKer can handle).
  end;                                 // Fractionned as 255 chars max Strings.

  ModifExtensionsList = record
    Extension: String;
    Description: String;
    DriverIdx: integer;
  end;
  ModifExtensionsResult = array of ModifExtensionsList;

{ External Function/Procedure declaration }

const
  DUDIVERSION = 6;  // Max supported DUDIVersion

type

  { Callback functions (the driver can call those functions/procedure) }

  // TPercentCallback : Used to set the current progress of the process
  //                    p must be between 0 and 100.
  TPercentCallback = procedure(p: byte);
  // TLanguageCallback : Used to retrieve language strings (translations)
  //                     lngid is a 6 chars ID for a language string.
  TLanguageCallback = function (lngid: ShortString): ShortString;

  // TMsgBoxCallback : Used by the plugin to display About box
  TMsgBoxCallback = procedure(const title, msg: AnsiString);

  // TAddEntryCallback : Used by the plugin to add found entries
  TAddEntryCallback = procedure (entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer);

  { Driver plugin functions }

  // TDUDIVersion : Returns the driver plugin DUDI (Dragon UnPACKer Driver
  //                Interface) version.
  //                Current class supports : 1 = Version 1
  //                                         2 = Version 2
  //                                         3 = Version 3
  //                                         4 = Version 4
  //                                         5 = Version 5 (see DUDIVersionEx)
  //                                         6 = Version 6
  //                Each version has different exported functions/procedure
  //                and/or same function/procedure with different export
  //                parameters.
  //                For version 5+ DUDI plugins this returns the minimum compatible
  //                version. Ex: DUDIVersionEx returns 5
  //                             DUDIVersion returns 4
  //                             This means the plugins is version 5 but is
  //                             compatible with version 4.
  TDUDIVersion = function(): Byte; stdcall;
  // TDUDIVersionEx : Returns the driver plugin DUDI (Dragon UnPACKer Driver
  //                Interface) version. This exported function was created with
  //                version 5 of DUDI interface.
  //                Current class supports : 1 = Version 1
  //                                         2 = Version 2
  //                                         3 = Version 3
  //                                         4 = Version 4
  //                                         5 = Version 5
  //                                         6 = Version 6
  //                Each version has different exported functions/procedure
  //                and/or same function/procedure with different export
  //                parameters.
  //                The parameter supported provides information on the host
  //                core program supported version (ex: if only version 4 plugin
  //                is supported the plugin might react differently).
  //                If DUDIVersionEx was not called, it is to be expected that
  //                the host core program do not supported extended version 5
  //                features.
  TDUDIVersionEx = function(supported: Byte): Byte; stdcall;
  // TCloseFormat : Called to (obviously) close current opened file.
  //                Driver is also supposed to free any resource associated with
  //                the opening of that file.
  TCloseFormat = function(): boolean; stdcall;
  // TOpenFormat : Called to open a file.
  // (DUDI v1)     src is the full path to the file
  //               Percent is the callback function for progress indication
  //               Deeper indicates to the driver if it have to dig into file
  //               format if it doesn't recognize it by the extension.
  //     Returns : <0 = If anything was wrong
  //                0 = No entries found in file
  //               >0 = Number of entries in file
  TOpenFormat = function(src: ShortString; Percent: TPercentCallback; Deeper: boolean): Integer; stdcall;
  // TOpenFormat2 : Called to open a file.
  // (DUDI v2->v4)  src is the full path to the file
  //                Deeper indicates to the driver if it have to dig into file
  //                format if it doesn't recognize it by the extension.
  //     Returns : <0 = If anything was wrong
  //                0 = No entries found in file
  //               >0 = Number of entries in file
  TOpenFormat2 = function(src: ShortString; Deeper: boolean): Integer; stdcall;
  // TGetEntry : Called by core to retrieve entries
  // (DUDI v1 to v5)
  TGetEntry = function(): FormatEntry; stdcall;
  TGetDriverInfo = function(): DriverInfo; stdcall;
  TGetDriverModifInfo = function(): DriverModifInfo; stdcall;
  TGetNumVersion = function(): Integer; stdcall;
  TGetCurrentDriverInfo = function(): CurrentDriverInfo; stdcall;
  TIsFormat = function(src: ShortString; deeper: Boolean): Boolean; stdcall;
  TExtractFile = function(outputfile: ShortString; entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: Boolean): boolean; stdcall;
  // TExtractFileToStream : Called to extract a file into a stream object
  // (DUDI v4)
  TExtractFileToStream = function(outstream: TStream; entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: Boolean): boolean; stdcall;
  TGetError = function(): ErrorInfo; stdcall;
  TShowBox = procedure(hwnd: integer; lngstr: TLanguageCallback); stdcall;
  TShowBox2 = procedure(hwnd: integer); stdcall;
  TShowBox3 = procedure; stdcall;
  TInitPlugin = procedure(percent: TPercentCallback; dlngstr: TLanguageCallback; dup5pth: shortstring); stdcall;
  TInitPlugin3 = procedure(percent: TPercentCallback; dlngstr: TLanguageCallback; dup5pth: shortstring; AppHandle: THandle; AppOwner: TComponent); stdcall;
  TInitPluginEx5 = procedure(MsgBox: TMsgBoxCallback); stdcall;
  // TInitPluginEx6 : Pass the callback procedure used to send entries to core
  // (DUDI v6)
  TInitPluginEx6 = procedure(AddEntry: TAddEntryCallback); stdcall;

type TDUDEntryFunctions = record
     CanOpen : TIsFormat;
     CloseFile : TCloseFormat;
     ExtractFile : TExtractFile;
     ExtractFileToStream : TExtractFileToStream;
     GetEntry : TGetEntry;
     GetError : TGetError;
     GetInfo : TGetDriverInfo;
     GetInfoModif : TGetDriverModifInfo;
     GetDriver : TGetCurrentDriverInfo;
     GetVersion : TGetNumVersion;
     InitPlugin : TInitPlugin;
     InitPlugin3 : TInitPlugin3;
     InitPluginEx5 : TInitPluginEx5;
     InitPluginEx6 : TInitPluginEx6;
     OpenFile : TOpenFormat;
     OpenFile2 : TOpenFormat2;
     ShowAboutBox : TShowBox;
     ShowAboutBox2 : TShowBox2;
     ShowAboutBox3 : TShowBox3;
     ShowConfigBox : TShowBox;
     ShowConfigBox2 : TShowBox2;
     ShowConfigBox3 : TShowBox3;
   end;
   TDUDEntryInfos = record
     DUDIVersion : Byte;
     DriverInfo : DriverInfo;
     FileName : ShortString;
     InternalVersion : integer;
     IsAboutBox : Boolean;
     IsConfigBox : Boolean;
     ModifCapabilities : DriverModifInfo;
     Priority : Integer;         // 5.1 : Prioritization of drivers
   end;
   TDUDEntry = record
     Handle : THandle;
     Functions : TDUDEntryFunctions;
     Infos : TDUDEntryInfos;
   end;

 pvirtualTreeData = ^virtualTreeData;
 virtualTreeData = record
   ImageIndex: Integer;
   tdirpos: integer;
   entryIndex: integer;
   loaded: boolean;
   desc: String;
 end;

 pvirtualIndexData = ^virtualIndexData;
 virtualIndexData = record
   dirname: String;
   imageIndex: integer;
   selectedImageIndex: integer;
   FolderID: integer;
 end;

type
  PEntList = ^EntList;
  EntList = record
    FileName: string;
    Offset: int64;
    Size: int64;
    DataX: integer;
    DataY: integer;
  end;

type TDrivers = class
  private
    currentFolderID: integer;
    HRipInfo: DriverInfo;
    sizeTest: int64;
    listData: array of virtualTreeData;
    entryList: array of FSEentry;
    entryListIndex: integer;
    entryListFolderCache: array of array of integer;
    LoadTimeOpen: Int64;
    LoadTimeRetrieve: Int64;
    LoadTimeParse: Int64;
    NumElems: Integer;
    DispNumElems: Integer;
    TView: TTreeView;
    Percent: TPercentCallback;
    CurrentDriver: Integer;
    CurrentDriverID: String;
    SCh: ShortString;
    InternalExtract: Boolean;
    CurrentFile: Integer;
    CurrentFileName: string;
    CurrentFileSize: Int64;
    DUP5Pth: ShortString;
    Language: TLanguageCallBack;
    CurAOwner: TComponent;
    Drivers: array[1..16] of TDUDEntry;
    DriversSorted: array[1..16] of integer;
    function ParseFileTypes(names: string; ext: string): string;
    procedure ExtractFile_Alt(outfile,entrynam: string; offset: int64; size: int64; datax: integer; datay: integer; silent: boolean);
    procedure ExtractFileToStream_Alt(outstream: TStream; entrynam: string; offset: int64; size: int64; datax: integer; datay: integer; silent: boolean);
    function CalculateNumberOfFiles(cdir: string): Integer;
    function GetRegistryBool(key: string; value: string; default: boolean = false): boolean;
    function SearchAll(searchst: string; CaseSensible: Boolean): integer;
    function SearchDir(searchst: string; CurrentDirID: integer; CaseSensible: Boolean): integer;
    procedure saveHRF_v1(srcfil, filename: string; srcsize: int64; prgver: integer);
    procedure saveHRF_v2(srcfil, filename: string; srcsize: int64; prgver: integer; info: boolean; title,author, url: string);
    procedure saveHRF_v3(srcfil, filename: string; srcsize: int64; prgver: integer; prgid: byte; info: boolean; title,author, url: string);
    function getDriverPriority(drivername: string): integer;
    procedure quickSortDrivers(lowerPos, upperPos: integer);
    function getBufferSize(): integer;
    procedure parseEntries(withDirectories: boolean);
    function getEntryList(index: integer): FSEentry;
  public
    NumDrivers: Integer;
    function CurrentDriverInfos(): DriverInfo;
    function GetNumEntries(): Integer;
    function GetLoadTime(t: byte): Int64;
    function GetFileName(): string;
    function GetFileSize(): Int64;
    function GetDriverInfo(idx: integer): TDUDEntryInfos;
//    procedure ExtractFile(entrynam: string; outfile: string; silent: boolean);
    procedure ExtractFile(entryIndex: integer; outfile: string; silent: boolean);
    procedure ExtractFileToStream(entryIndex: integer; outstream: TStream; fallbacktempfile: string; silent: boolean);
    procedure ExtractDir(cdir: string; outpath: string);
    function IsListEmpty: Boolean;
    function GetListSize: Integer;
    function SlashMode: string;
    function DriverID: string;
    function GetFileTypes: string;
    function GetAllFileTypes(Partitionned: boolean): ExtensionsResult;
    function GetAllModifFileTypes(): ModifExtensionsResult;
    procedure BrowseDirFromID(CurrentDirID: integer);
    function BrowseDirToList(cdir: string; SubDirs: Boolean): TList;
    procedure SetTreeView(a: TTreeView);
    procedure SetProgressBar(a: TPercentCallback);
    procedure LoadDrivers(pth: String);
    procedure FreeDrivers;
    function LoadFile(pth: String; Silent: boolean): TDriverLoadResult;
    procedure LoadHyperRipper(fil: String; filHandle: integer; loadTime: integer; subdirs: boolean);
    function CloseFile(): boolean;
    function Search(searchst: string; CaseSensible: Boolean; cdiridx: integer; sdir: boolean): integer;
    function getListData(n: integer): virtualTreeData;
    function getListNum(): integer;
    procedure PrepareHyperRipper(Info: DriverInfo);
    procedure saveHRF(srcfil, filename: string; srcsize: int64; prgver: integer; prgid: byte; version: byte; info: boolean;  title, author, url: string);
    procedure showAboutBox(hwnd: integer; drvnum: integer);
    procedure showConfigBox(hwnd: integer; drvnum: integer);
    procedure SetPath(a: string);
    procedure SetLanguage(l: TLanguageCallback);
    procedure SetOwner(AOwner: TComponent);
    procedure setDriverPriority(index, priority: integer);
    procedure sortDriversByPriority;
    procedure addEntry(entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer);
    constructor Create();
    destructor Destroy(); override;
    property Items[Index : integer] : FSEentry read getEntryList;
end;

implementation

{ TDrivers }

procedure showMsgBox(const title, msg: AnsiString);
begin

  dup5Main.messageDlgTitle(title,msg,[mbOk],0);

end;

procedure addEntryCB(entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer);
begin

  dup5Main.addEntry(entrynam,offset,size,datax,datay);

end;

function TDrivers.GetFileSize(): Int64;
begin

  Result := CurrentFileSize;

end;

function TDrivers.GetFileName(): string;
begin

  Result := CurrentFileName;

end;

function TDrivers.GetLoadTime(t: byte): Int64;
begin

  case t of
    1: Result := LoadTimeOpen;
    2: Result := LoadTimeRetrieve;
    3: Result := LoadTimeParse;
  else
    Result := LoadTimeOpen + LoadTimeRetrieve + LoadTimeParse;
  end;

end;

function TDrivers.GetNumEntries(): integer;
begin

  result := DispNumElems;

end;

// GetListSize : Return the size of the data chain
//     Returns : 0 if the file list is empty
//               n if the file list has n elements
//        NOTE : This does not actually return the true size of the chain but
//               the size returned by the driver (after correction by TDriver)
function TDrivers.GetListSize: Integer;
begin

  if IsListEmpty then
    result := 0
  else
    result := DispNumElems;

end;

// IsListEmpty : Indicate if current data chain is empty
//     Returns : TRUE if file list is empty
//               FALSE if not
function TDrivers.IsListEmpty: Boolean;
begin

  IsListEmpty := entryListIndex = -1;

end;


procedure TDrivers.SetTreeView(a: TTreeView);
begin

  TView := a;

end;

procedure TDrivers.SetProgressBar(a: TPercentCallback);
begin

  Percent := a;

end;

procedure TDrivers.FreeDrivers;
var x: integer;
begin

  if IsConsole then
    write('Freeing '+inttostr(NumDrivers)+' drivers... ');

  for x := 1 to NumDrivers do
    FreeLibrary(Drivers[x].Handle);

  if IsConsole then
    writeln('OK');

end;

procedure TDrivers.LoadDrivers(pth: String);
var sr: TSearchRec;
    DUDIVer: TDUDIVersion;
    DUDIVerEx: TDUDIVersionEx;
    DUDIVerVal, DUDIVerExVal: byte;
    Handle: THandle;
    tmpInfo: DriverInfo;
    tmpModifInfo: ^DriverModifInfo;
begin

  NumDrivers := 0;

  if IsConsole then
    writeln('Looking for drivers...');

  if FindFirst(pth+'*.d5d', faAnyFile, sr) = 0 then
  begin
    repeat
      if IsConsole then
        write(sr.name+ ' ')
      else
        dup5Main.writeLogVerbose(1,' + '+sr.Name+' :');
      Handle := LoadLibrary(PChar(pth + sr.name));
      if Handle <> 0 then
      begin
        if IsConsole then
          write('Loaded... ');
          @DUDIVer := GetProcAddress(Handle, 'DUDIVersion');
          @DUDIVerEx := GetProcAddress(Handle, 'DUDIVersionEx');
        if (@DUDIVer <> Nil) then
          DUDIVerVal := DUDIVer
        else
          DUDIVerVal := 0;
        if (@DUDIVerEx <> Nil) then
          DUDIVerExVal := DUDIVerEx(DUDIVersion)
        else
          DUDIVerExVal := 0;
        if (@DUDIVer <> Nil) and ((DUDIVerVal >= 1) and (DUDIVerVal <= DUDIVersion)) then
        begin
          Inc(NumDrivers);
          if (@DUDIVerEx <> Nil) and (DUDIVerExVal >= 5) and (DUDIVerExVal <= DUDIVersion) then
            Drivers[NumDrivers].Infos.DUDIVersion := DUDIVerExVal
          else
            Drivers[NumDrivers].Infos.DUDIVersion := DUDIVerVal;

          if IsConsole then
            write('IsDUDI... ')
          else
            dup5Main.appendLogVerbose(2,'DUDI v'+inttostr(Drivers[NumDrivers].Infos.DUDIVersion)+' -');

          @Drivers[NumDrivers].Functions.CloseFile := GetProcAddress(Handle, 'CloseFormat');
          @Drivers[NumDrivers].Functions.GetEntry := GetProcAddress(Handle, 'GetEntry');
          @Drivers[NumDrivers].Functions.GetInfo := GetProcAddress(Handle, 'GetDriverInfo');
          @Drivers[NumDrivers].Functions.GetDriver := GetProcAddress(Handle, 'GetCurrentDriverInfo');
          @Drivers[NumDrivers].Functions.GetVersion := GetProcAddress(Handle, 'GetNumVersion');
          @Drivers[NumDrivers].Functions.CanOpen := GetProcAddress(Handle, 'IsFormat');
          @Drivers[NumDrivers].Functions.ExtractFile := GetProcAddress(Handle, 'ExtractFile');
          @Drivers[NumDrivers].Functions.GetError := GetProcAddress(Handle, 'GetErrorInfo');
          if (Drivers[NumDrivers].Infos.DUDIVersion = 1) then
          begin
            @Drivers[NumDrivers].Functions.ShowAboutBox := GetProcAddress(Handle, 'AboutBox');
            @Drivers[NumDrivers].Functions.ShowConfigBox := GetProcAddress(Handle, 'ConfigBox');
            @Drivers[NumDrivers].Functions.OpenFile := GetProcAddress(Handle, 'ReadFormat');
          end
          else if (Drivers[NumDrivers].Infos.DUDIVersion = 2) then
          begin
            @Drivers[NumDrivers].Functions.ShowAboutBox2 := GetProcAddress(Handle, 'AboutBox');
            @Drivers[NumDrivers].Functions.ShowConfigBox2 := GetProcAddress(Handle, 'ConfigBox');
            @Drivers[NumDrivers].Functions.InitPlugin := GetProcAddress(Handle, 'InitPlugin');
            @Drivers[NumDrivers].Functions.OpenFile2 := GetProcAddress(Handle, 'ReadFormat');
          end
          else if (Drivers[NumDrivers].Infos.DUDIVersion >= 3) then
          begin
            @Drivers[NumDrivers].Functions.ShowAboutBox3 := GetProcAddress(Handle, 'AboutBox');
            @Drivers[NumDrivers].Functions.ShowConfigBox3 := GetProcAddress(Handle, 'ConfigBox');
            @Drivers[NumDrivers].Functions.OpenFile2 := GetProcAddress(Handle, 'ReadFormat');
            @Drivers[NumDrivers].Functions.InitPlugin3 := GetProcAddress(Handle, 'InitPlugin');
            if (Drivers[NumDrivers].Infos.DUDIVersion >= 4) then
              @Drivers[NumDrivers].Functions.ExtractFileToStream := GetProcAddress(Handle, 'ExtractFileToStream');
            if (Drivers[NumDrivers].Infos.DUDIVersion >= 5) then
              @Drivers[NumDrivers].Functions.InitPluginEx5 := GetProcAddress(Handle, 'InitPluginEx5');
            if (Drivers[NumDrivers].Infos.DUDIVersion >= 6) then
            begin
              @Drivers[NumDrivers].Functions.InitPluginEx6 := GetProcAddress(Handle, 'InitPluginEx6');
              @Drivers[NumDrivers].Functions.GetInfoModif := GetProcAddress(Handle, 'GetDriverModifInfo');
            end;
          end;

          if ((Drivers[NumDrivers].Infos.DUDIVersion = 1) and (@Drivers[NumDrivers].Functions.OpenFile = Nil))
          or ((Drivers[NumDrivers].Infos.DUDIVersion >= 2) and (@Drivers[NumDrivers].Functions.OpenFile2 = Nil))
          or (@Drivers[NumDrivers].Functions.CloseFile = Nil)
          or (@Drivers[NumDrivers].Functions.GetEntry = Nil)
          or (@Drivers[NumDrivers].Functions.GetInfo = Nil)
          or (@Drivers[NumDrivers].Functions.GetDriver = Nil)
          or (@Drivers[NumDrivers].Functions.GetVersion = Nil)
          or (@Drivers[NumDrivers].Functions.CanOpen = Nil)
          or (@Drivers[NumDrivers].Functions.GetError = Nil)
          or ((Drivers[NumDrivers].Infos.DUDIVersion = 2) and (@Drivers[NumDrivers].Functions.InitPlugin = Nil))
          or ((Drivers[NumDrivers].Infos.DUDIVersion >= 3) and (@Drivers[NumDrivers].Functions.InitPlugin3 = Nil))
          or ((Drivers[NumDrivers].Infos.DUDIVersion >= 4) and (@Drivers[NumDrivers].Functions.ExtractFileToStream = Nil))
          or ((Drivers[NumDrivers].Infos.DUDIVersion >= 5) and (@Drivers[NumDrivers].Functions.InitPluginEx5 = Nil))
          or ((Drivers[NumDrivers].Infos.DUDIVersion >= 6) and ((@Drivers[NumDrivers].Functions.InitPluginEx6 = Nil) or (@Drivers[NumDrivers].Functions.GetInfoModif = Nil)))
          then
          begin
            if IsConsole then
              writeln('Malformed!')
            else
            begin
              if dup5Main.getVerboseLevel = 0 then
                dup5Main.writeLog(' + '+sr.Name+' :');
              dup5Main.appendLog(DLNGstr('ERRD02'));
              dup5Main.colorLog(clRed);
            end;
            dec(NumDrivers);
            FreeLibrary(handle);
          end
          else
          begin
            if IsConsole then
              writeln('OK');
            try
              if (Drivers[NumDrivers].Infos.DUDIVersion = 2) then
              begin
                Drivers[NumDrivers].Functions.InitPlugin(Percent,Language,dup5pth);
              end
              else if (Drivers[NumDrivers].Infos.DUDIVersion = 3) or (Drivers[NumDrivers].Infos.DUDIVersion = 4) then
              begin
                Drivers[NumDrivers].Functions.InitPlugin3(Percent,Language,dup5pth,Application.Handle,CurAOwner);
              end
              else if (Drivers[NumDrivers].Infos.DUDIVersion = 5) then
              begin
                Drivers[NumDrivers].Functions.InitPlugin3(Percent,Language,dup5pth,Application.Handle,CurAOwner);
                Drivers[NumDrivers].Functions.InitPluginEx5(showMsgBox);
              end
              else if (Drivers[NumDrivers].Infos.DUDIVersion >= 6) then
              begin
                Drivers[NumDrivers].Functions.InitPlugin3(Percent,Language,dup5pth,Application.Handle,CurAOwner);
                Drivers[NumDrivers].Functions.InitPluginEx5(showMsgBox);
                Drivers[NumDrivers].Functions.InitPluginEx6(addEntryCB);
                Drivers[NumDrivers].Infos.ModifCapabilities := Drivers[NumDrivers].Functions.GetInfoModif;
              end;
              Drivers[NumDrivers].Infos.DriverInfo := Drivers[NumDrivers].Functions.GetInfo;
              Drivers[NumDrivers].Infos.FileName := ExtractFileName(sr.Name);
              Drivers[NumDrivers].Infos.InternalVersion := Drivers[NumDrivers].Functions.GetVersion;
              Drivers[NumDrivers].Handle := Handle;
              Drivers[NumDrivers].Infos.IsAboutBox := not(@Drivers[NumDrivers].Functions.ShowAboutBox = nil) or not(@Drivers[NumDrivers].Functions.ShowAboutBox2 = nil) or not(@Drivers[NumDrivers].Functions.ShowAboutBox3 = nil);
              Drivers[NumDrivers].Infos.IsConfigBox := not(@Drivers[NumDrivers].Functions.ShowConfigBox = nil) or not(@Drivers[NumDrivers].Functions.ShowConfigBox2 = nil) or not(@Drivers[NumDrivers].Functions.ShowConfigBox3 = nil);
              Drivers[NumDrivers].Infos.Priority := getDriverPriority(ExtractFileName(sr.Name));
              DriversSorted[NumDrivers] := NumDrivers;
              dup5Main.appendLogVerbose(1,Drivers[NumDrivers].Functions.GetInfo.Name+' v'+Drivers[NumDrivers].Functions.GetInfo.Version)
            except
              on E:Exception do
              begin
                Dec(NumDrivers);
              end;
            end;
          end;
        end
        else
        begin
          if IsConsole then
            writeln('Bad DUDI')
          else
          begin
            if dup5Main.getVerboseLevel = 0 then
            begin
              dup5Main.writeLog(' + '+sr.Name+' :');
            end;
            dup5Main.appendLog(DLNGstr('ERRD01'));
            dup5Main.colorLog(clRed);
          end;
          FreeLibrary(handle);
        end;
      end
      else
      begin
        if dup5Main.getVerboseLevel = 0 then
        begin
          dup5Main.writeLog(' + '+sr.Name+' :');
        end;
        dup5Main.appendLog(DLNGstr('ERRD01'));
        dup5Main.colorLog(clRed);
      end;

    until FindNext(sr) <> 0;

    if NumDrivers > 0 then
      sortDriversByPriority;

  end;

  FindClose(sr);

  if IsConsole then
    writeln('Finished!');

end;

function TDrivers.GetRegistryBool(key: string; value: string; default: boolean = false): boolean;
var Reg: TRegistry;
begin

  Result := default;

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\'+key,True) then
    begin
      if Reg.ValueExists(value) then
        Result := Reg.ReadBool(value);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

function TDrivers.LoadFile(pth: String; Silent: boolean): TDriverLoadResult;
var x,y,i: integer;
    Test: FormatEntry;
    DrvInfo: CurrentDriverInfo;
    SmartOpen: boolean;
    res : TDriverLoadResult;
    ErrInfo: ErrorInfo;
    StartTime: TDateTime;
    CanOpen: array of Integer;
    NumCanOpen: Integer;
    ErrList: TStringList;
    ErrStr: String;
    ErrNum, hTest: integer;
    zero64: int64;
begin

  SaveTitle;
  SetTitle(ReplaceValue('%f',DLNGstr('TLD001'),ExtractFilename(pth)));
  //result := dlError;

  if (FileExists(pth)) then
  begin

    hTest := FileOpen(pth,fmOpenRead);

    if hTest = -1 then
    begin
      result := dlFileNotFound;
      MessageDlg(ReplaceValue('%f',DLNGstr('ERRIO'),pth),mtWarning,[mbOk],0);
      restoreTitle;
      exit;
    end;

    FileClose(hTest);

    SmartOpen := GetRegistryBool('StartUp','SmartOpen',True);
    if SmartOpen then
      dup5Main.writeLogVerbose(1,DLNGStr('LOG400'));

    x := 1 ;
    NumCanOpen := 0;
    ErrNum := 0;
    ErrList := TStringList.Create;
    res := dlError;
    SetLength(CanOpen,NumDrivers);

    while (x <= NumDrivers) do
    begin
      try
        if Drivers[DriversSorted[x]].Functions.CanOpen(pchar(pth),SmartOpen) then
        begin
          dup5Main.writeLogVerbose(1,ReplaceValue('%d',DLNGStr('LOG500'),Drivers[DriversSorted[x]].Infos.DriverInfo.Name));
          CanOpen[NumCanOpen] := DriversSorted[x];
          Inc(NumCanOpen);
        end;
      except
        on E:EFOpenError do MessageDlg(ReplaceValue('%f',DLNGstr('ERRIO'),pth),mtWarning,[mbOk],0);
        on Ex:Exception do
        begin  // New error dialog box
          frmError.PrepareError;
          frmError.details.Add(DLNGStr('ERRCAL'));
          frmError.details.Add('if Drivers['+inttostr(DriversSorted[x])+'].CanOpen('''+pth+''','+booltostr(SmartOpen,true)+') then');
          frmError.details.Add('');
          frmError.details.Add('Drivers['+inttostr(DriversSorted[x])+'].Filename='+Drivers[DriversSorted[x]].Infos.FileName);
          frmError.details.Add('Drivers['+inttostr(DriversSorted[x])+'].Info.Name='+Drivers[DriversSorted[x]].Infos.DriverInfo.Name);
          frmError.details.Add('Drivers['+inttostr(DriversSorted[x])+'].Info.Author='+Drivers[DriversSorted[x]].Infos.DriverInfo.Author);
          frmError.details.Add('Drivers['+inttostr(DriversSorted[x])+'].Info.Version='+Drivers[DriversSorted[x]].Infos.DriverInfo.Version);
          frmError.details.Add('Drivers['+inttostr(DriversSorted[x])+'].Info.Comment='+Drivers[DriversSorted[x]].Infos.DriverInfo.Comment);
          frmError.FillTxtError(Ex,'classFSE.pas','LoadFile:'+Drivers[DriversSorted[x]].Infos.FileName+'.CanOpen');
        end;
      end;
      Inc(x);
    end;

    if NumCanOpen = 0 then
    begin
      if not(silent) then
        MessageDlg(DLNGstr('ERRUNK'),mtInformation,[mbOk],0);
      RestoreTitle;
      res := dlCouldNotLoad;
    end
    else
    begin

      for x := 0 to NumCanOpen-1 do
      begin
        CurrentDriver := CanOpen[x];

        i := FileOpen(pth,fmOpenRead or fmShareDenyNone);
        zero64 := 0;
        CurrentFileSize := FileSeek(i,zero64,2);
        FileClose(i);

        dup5Main.writeLogVerbose(1,ReplaceValue('%d',DLNGStr('LOG501'),Drivers[CurrentDriver].Infos.DriverInfo.Name));

        StartTime := Now;
        entryListIndex := -1;
        try
          if (Drivers[CurrentDriver].Infos.DUDIVersion = 1) then
            NumElems := Drivers[CurrentDriver].Functions.OpenFile(pchar(pth),Percent,SmartOpen)
          else if (Drivers[CurrentDriver].Infos.DUDIVersion >= 2) then
            NumElems := Drivers[CurrentDriver].Functions.OpenFile2(pchar(pth),SmartOpen);
        except
          on Ex:Exception do
          begin  // New error dialog box
            frmError.PrepareError;
            frmError.details.Add(DLNGStr('ERRCAL'));
            if Drivers[CurrentDriver].Infos.DUDIVersion = 1 then
              frmError.details.Add('NumElems := Drivers['+inttostr(CurrentDriver)+'].OpenFile('''+pth+''',Percent,'+booltostr(SmartOpen,true)+')')
            else if (Drivers[CurrentDriver].Infos.DUDIVersion >= 2) then
              frmError.details.Add('NumElems := Drivers['+inttostr(CurrentDriver)+'].OpenFile2('''+pth+''','+booltostr(SmartOpen,true)+')');
            frmError.details.Add('');
            frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Filename='+Drivers[CurrentDriver].Infos.FileName);
            frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Name='+Drivers[CurrentDriver].Infos.DriverInfo.Name);
            frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Author='+Drivers[CurrentDriver].Infos.DriverInfo.Author);
            frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Version='+Drivers[CurrentDriver].Infos.DriverInfo.Version);
            frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Comment='+Drivers[CurrentDriver].Infos.DriverInfo.Comment);
            frmError.FillTxtError(Ex,'classFSE.pas','LoadFile:'+Drivers[CurrentDriver].Infos.FileName+'.OpenFile');
            NumElems := -999
          end;
        end;
        LoadTimeOpen := MilliSecondsBetween(Now, StartTime);

        dup5Main.appendLogVerbose(2,inttostr(LoadTimeOpen)+'ms');

        if  NumElems > 0 then
        begin

          dup5Main.appendLog(DLNGStr('LOG511'));

          SetTitle(DLNGstr('TLD002'));
          StartTime := Now;

          DrvInfo := Drivers[CurrentDriver].Functions.GetDriver;
          CurrentDriverID := DrvInfo.ID;

          if IsConsole then
            writeln('NumElems: '+IntToStr(NumElems));

          DispNumElems := 0;
          y := 0;

          if (Drivers[CurrentDriver].Infos.DUDIVersion < 6) then
          begin

            dup5Main.writeLogVerbose(1,ReplaceValue('%x',DLNGStr('LOG502'),inttostr(NumElems)));

            try
              for y := 1 to NumElems do
              begin
                Test := Drivers[CurrentDriver].Functions.GetEntry();
                AddEntry(Test.FileName,Test.Offset,Test.Size,Test.DataX,Test.DataY);
              end;
            except
              on Ex:Exception do
              begin  // New error dialog box
                dup5Main.writeLog(ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[CurrentDriver].Infos.FileName));
                dup5Main.colorLog(clRed);
                dup5Main.writeLog(Ex.Message +' @ TDrivers.LoadFile:'+Drivers[CurrentDriver].Infos.FileName+'.GetEntry');
                dup5Main.colorLog(clRed);
                dup5Main.writeLog(ReplaceValue('%a',DLNGstr('ERRDR1'),Drivers[CurrentDriver].Infos.DriverInfo.Author));
                dup5Main.colorLog(clRed);

                frmError.PrepareError;
                frmError.details.Add(DLNGStr('ERRCAL'));

                frmError.details.Add('for y := 1 to '+inttostr(NumElems)+' do');
                frmError.details.Add('begin');
                frmError.details.Add('  Test := Drivers['+inttostr(CurrentDriver)+'].GetEntry();');
                frmError.details.Add('  AddEntry('''+Test.FileName+''','+inttostr(Test.Offset)+','+inttostr(Test.Size)+','+inttostr(Test.DataX)+','+inttostr(Test.DataY)+');');
                frmError.details.Add('end;');

                frmError.details.Add('');
                frmError.details.Add('y='+inttostr(y));
                frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Filename='+Drivers[CurrentDriver].Infos.FileName);
                frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Name='+Drivers[CurrentDriver].Infos.DriverInfo.Name);
                frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Author='+Drivers[CurrentDriver].Infos.DriverInfo.Author);
                frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Version='+Drivers[CurrentDriver].Infos.DriverInfo.Version);
                frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Comment='+Drivers[CurrentDriver].Infos.DriverInfo.Comment);
                frmError.FillTxtError(Ex,'TDrivers','LoadFile:'+Drivers[CurrentDriver].Infos.FileName+'.GetEntry');

                NumElems := y-1;
              end;
            end;

            LoadTimeRetrieve := MilliSecondsBetween(Now, StartTime);

            dup5Main.appendLogVerbose(2,inttostr(LoadTimeRetrieve)+'ms');
          end;

          DispNumElems := entryListIndex+1;

          SetTitle(DLNGstr('TLD003'));
          StartTime := Now;

          SCh := DrvInfo.Sch;

          InternalExtract := DrvInfo.ExtractInternal;
          CurrentFile := DrvInfo.FileHandle;

          dup5Main.writeLogVerbose(1,DLNGStr('LOG503'));

          CurrentFileName := pth;

          // Prepare lstIndex root node and parse directories (create sub-nodes) if needed
          // Also fill the entry cache
          ParseEntries((Sch <> ''));

          LoadTimeParse := MilliSecondsBetween(Now, StartTime);

          dup5Main.appendLogVerbose(2,inttostr(LoadTimeParse)+'ms');

          SetTitle(pth);

          res := dlOK;

          dup5Main.writeLogVerbose(1,ReplaceValue('%p',ReplaceValue('%f',DLNGStr('LOG504'),DriverID),Drivers[CurrentDriver].Infos.DriverInfo.Name));

          break;

        end
        else if NumElems = 0 then
        begin
          dup5Main.appendLog(DLNGStr('LOG512'));
          inc(ErrNum);
          DrvInfo := Drivers[CurrentDriver].Functions.GetDriver;
          Drivers[CurrentDriver].Functions.CloseFile;
          ErrList.Add('<'+Drivers[CurrentDriver].Infos.FileName+'> '+DLNGstr('ERREMP'));
//          FileClose(DrvInfo.FileHandle);
//          res := false;
//          MessageDlg(DLNGstr('ERREMP'),mtInformation,[mbOk],0);
//          RestoreTitle;
        end
        else
        begin
          dup5Main.appendLog(DLNGStr('LOG513'));
          inc(ErrNum);
          case NumElems of
            -4: begin
                  ErrInfo := Drivers[CurrentDriver].Functions.GetError;
                  ErrList.Add(ReplaceValue('%f',DLNGStr('ERRCMP'),ErrInfo.Games));
                end;
            -3: begin
                  ErrInfo := Drivers[CurrentDriver].Functions.GetError;
                  ErrList.Add(ReplaceValue('%g',ReplaceValue('%f',DLNGStr('ERRFIL'),ErrInfo.Format),ErrInfo.Games));
                end;
            -2: begin
                  ErrList.Add(ReplaceValue('%f',DLNGStr('ERROPN'),ExtractFileName(Pth)));
                end;
          end;
        end;
      end;

      if (ErrNum = NumCanOpen) then
      begin
        res := dlCouldNotLoad;
        if (ErrList.Count = 0) then
          ErrStr := DLNGstr('ERRUNK')
        else
        begin
          ErrStr := '';
          for x := 0 to ErrList.Count - 1 do
            if ErrStr <> '' then
              ErrStr := ErrStr + #10 + ErrList.Strings[x]
            else
              ErrStr := ErrList.Strings[x];
        end;
        dup5Main.writeLog(ErrStr);
        MessageDlg(ErrStr,mtInformation,[mbOk],0);
        RestoreTitle;
      end;

    end;

    FreeAndNil(ErrList);
    LoadFile := res;

  end
  else
  begin
    result := dlFileNotFound;
    MessageDlg(ReplaceValue('%f',DLNGstr('ERRIO'),pth),mtWarning,[mbOk],0);
    RestoreTitle;
  end;

end;

function TDrivers.CloseFile: boolean;
var x: integer;
begin

  // By default everything was fine
  result := True;

  // The entryList is reset
  entryListIndex := -1;
  setLength(entryList,16);

  // The current folder data is reset
  dup5Main.lstContent.RootNodeCount := 0;
  setLength(listData,0);

  // Clear the cache
  for x := Low(entryListFolderCache) to High(entryListFolderCache) do
    SetLength(entryListFolderCache[x],0);
  SetLength(entryListFolderCache,0);

  // In case we have some elements and an active driver we call the exported CloseFile function of the driver
  if NumElems > 0 then
  begin
    if CurrentDriver >= 0 then
      try
        result := Drivers[CurrentDriver].Functions.CloseFile;
      except
        on E:Exception do
        begin
          dup5Main.writeLog(ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[CurrentDriver].Infos.FileName));
          dup5Main.colorLog(clRed);
          dup5Main.writeLog(E.Message +' @ TDrivers.CloseFile');
          dup5Main.colorLog(clRed);
          dup5Main.writeLog(ReplaceValue('%a',DLNGstr('ERRDR1'),Drivers[CurrentDriver].Infos.DriverInfo.Author));
          dup5Main.colorLog(clRed);
          CloseFile := false;
        end;
      end;
  end;

  // If HyperRipper driver and the file is still open we close it
  if (CurrentDriver = -1) and (CurrentFile >= 0) then
    FileClose(CurrentFile);

  // Reset CurrentDriver to -2 (none)
  CurrentDriver := -2;

end;

function TDrivers.SlashMode: string;
begin

  SlashMode := Sch;

end;

function TDrivers.DriverID: string;
begin

  DriverID := CurrentDriverID;

end;

function TDrivers.GetFileTypes: string;
var x: integer;
    y: Byte;
    names, res, ext : string;
    TypeList: TStringList;
    i: integer;
begin

  res := '';
  TypeList := TStringList.Create;

  for x := Low(Drivers) to High(Drivers) do
    for y := 1 to Drivers[x].Infos.DriverInfo.NumFormats do
    begin
      names := Drivers[x].Infos.DriverInfo.Formats[y].Name;
      ext := Drivers[x].Infos.DriverInfo.Formats[y].Extensions;
      i := Pos('|',names);

      while i <> 0 do
      begin
       TypeList.Add(Copy(names,0,i-1)+'|'+ext);
       names := Copy(names,i+1,length(names)-i);
        i := Pos('|',names);
      end;

      TypeList.Add(names + '|' + ext);
    end;

  TypeList.Sort;

  res := TypeList.Strings[0];
  for x := 1 to TypeList.Count-1 do
    res := res + '|' + TypeList.Strings[x];

  GetFileTypes := res;

end;

function TDrivers.GetAllFileTypes(Partitionned: boolean): ExtensionsResult;
var x, cl: integer;
    y: Byte;
    res, res2 : string;
    ExtList: TStringList;
begin

  res := '';

  for x := 1 to NumDrivers do
  begin
    for y := 1 to Drivers[x].Infos.DriverInfo.NumFormats do
      if res <> '' then
        res := res + ';' + Drivers[x].Infos.DriverInfo.Formats[y].Extensions
      else
        res := Drivers[x].Infos.DriverInfo.Formats[y].Extensions;
  end;

 { Assign(T,'H:\dup5ext.txt');
  Rewrite(T);
  Writeln(T,res);}

  if Partitionned then
  begin
    ExtList := TStringList.Create;
    try
      ExtList.Sorted := True;
      ExtList.Duplicates := dupIgnore;
      while pos(';',res) > 0 do
      begin
        ExtList.Add(Copy(res,0,pos(';',res)-1));
        res := Copy(res,pos(';',res)+1,length(res)-pos(';',res));
      end;
      ExtList.Add(res);

      for x := 0 to ExtList.Count-1 do
        if x > 0 then
          res2 := res2 + ';' + ExtList.Strings[x]
        else
          res2 := ExtList.Strings[x];

      cl := 1;
      for x := 0 to ExtList.Count-1 do
      begin
        if length(Result.Lists[cl]+';'+ExtList.Strings[x]) > 255 then
          inc(cl);
        if Result.Lists[cl] <> '' then
          Result.Lists[cl] := Result.Lists[cl] + ';' + ExtList.Strings[x]
        else
          Result.Lists[cl] := ExtList.Strings[x];
      end;
      Result.Num := cl;

    finally
      FreeAndNil(ExtList);
    end;
  end
  else
  begin
    result.Num := 1;
    result.lists[1] := res;
  end;

//  result := '*.art;*.awf;*.bag;*.bkf;*.box;*.bun;*.crf;*.dat;*.drs;*.dta;*.far;*.ffl;*.gob;*.gro;*.grp;*.gzp;*.hal;*.hog;*.hrf;*.mgz;*.mn3;*.mtf;*.nob;*.pac;*.pak;*.pbo;*.pff;*.pk3;*.pkr;*.pod;*.res;*.rez;*.rfh;*.rvi;*.rvm;*.rvr;*.sad;*.sdt;*.slf;*.snd;*.sni;*.syn;*.tlk;*.uax;*.ums;*.umx;*.utx;*.vl2;*.vp;*.wad';
//  ShowMessage(result);

{  Writeln(T,result);

  Close(T);}

end;

function TDrivers.GetAllModifFileTypes(): ModifExtensionsResult;
var x, cl, TotalModifFormats: integer;
    y: Byte;
    res, res2 : string;

begin

  TotalModifFormats := 0;

  for x := Low(Drivers) to High(Drivers) do
    inc(TotalModifFormats,Drivers[x].Infos.ModifCapabilities.NumFormats);


end;

function TDrivers.ParseFileTypes(names, ext: string): string;
var i: integer;
    res: string;
begin

  i := Pos('|',names);

  while i <> 0 do
  begin
    if res <> '' then
      res := res + '|';
    res := res + copy(names,0,i-1) + '|' + ext;
    names := Copy(names,i+1,length(names)-i);
    i := Pos('|',names);
  end;

  if res <> '' then
    res := res + '|';
  res := res + names + '|' + ext;

  ParseFileTypes := res;

end;

//procedure TDrivers.ExtractFile(entrynam, outfile: string; silent: boolean);
procedure TDrivers.ExtractFile(entryIndex: integer; outfile: string; silent: boolean);
var //Offset,Size: int64;
//    DataX,DataY: integer;
    Save_Cursor:TCursor;
begin

  SetStatus('E');
  Save_Cursor := Screen.Cursor;
  SaveTitle;
  SetTitle(DLNGStr('XTRCAP'));
  if not(silent) then
    SetPanelEx(ReplaceValue('%f',DLNGStr('XTRSTA'),entryList[entryIndex].Name));
  Screen.Cursor := crHourGlass;    { Affiche le curseur en forme de sablier }
  try
    //GetListElem(entrynam,Offset,Size,DataX,DataY);
    ExtractFile_Alt(outfile,entryList[entryIndex].Name,entryList[entryIndex].Offset,entryList[entryIndex].Size,entryList[entryIndex].DataX,entryList[entryIndex].DataY,silent);
  finally
    Screen.Cursor := Save_Cursor;  { Revient toujours à normal }
    SetStatus('-');
    RestoreTitle;
  end;

end;

procedure TDrivers.ExtractDir(cdir, outpath: string);
var TDir,cfil,cfilcnv: string;
    totfiles,curfiles,lencdir,x: integer;
    Save_Cursor:TCursor;
    perc,numper: integer;
begin

  SetStatus('E');
  Save_Cursor := Screen.Cursor;
  SaveTitle;
  SetTitle(DLNGStr('XTRCAP'));
//  ShowPanelEx;
  Screen.Cursor := crHourGlass;    { Affiche le curseur en forme de sablier }
  try

    totfiles := CalculateNumberOfFiles(cdir);
    curfiles := 0;
    perc := 0;

    numper := totfiles div 20;

    LenCDir := Length(CDir);
    if LenCDir > 0 then
    begin
      CDir := CDir + sch;
      LenCDir := LenCDir + 1;
    end;

    CDir := UpperCase(CDir);

    for x:=0 to entryListIndex do
    begin

      if Length(entryList[x].Name) >= LenCDir then
        TDir := Copy(entryList[x].Name,1,lenCDir)
      else
        TDir := '';

      if UpperCase(TDir) = CDir then
      begin
        inc(CurFiles);

        if (CurFiles >= numper) then
        begin
          perc := perc + 5;
          DisplayPercent(perc);
          CurFiles := 0;
        end;

        SetPanelEx(ReplaceValue('%f',DLNGStr('XTRSTA'),entryList[x].Name));
        cfil := Copy(entryList[x].Name,length(TDir)+1,Length(entryList[x].Name)-length(TDir));
        if Copy(cfil,1,1) = sch then
          cfil := Copy(cfil,2,length(cfil)-1);

        if Sch = '/' then
          cfilcnv := ConvertSlash(cfil)
        else
          cfilcnv := cfil;

        ExtractFile_Alt(outpath+cfilcnv,entryList[x].Name,entryList[x].Offset,entryList[x].Size,entryList[x].DataX,entryList[x].DataY,true);
//      MessageDlg(DLNGStr('ERR102')+ ' '+cfil,mtError,[mbOk],0);

      end;

    end;
  finally
    Screen.Cursor := Save_Cursor;  { Revient toujours à normal }
    SetStatus('-');
//    HidePanelEx;
    RestoreTitle;
  end;

end;

procedure TDrivers.ExtractFile_Alt(outfile, entrynam: string; offset, size: int64;
  datax, datay: integer; silent: boolean);
var dst: integer;
    tmpStm: THandleStream;
begin

 try
  if (CurrentDriver > -1) and Drivers[CurrentDriver].Functions.GetDriver.ExtractInternal then
  begin
    if @Drivers[CurrentDriver].Functions.ExtractFile <> Nil then
    begin
      Drivers[CurrentDriver].Functions.ExtractFile(outfile,entrynam,offset,size,datax,datay,silent);
      if not(silent) then
        dup5Main.appendLog(DLNGStr('LOG510'));
    end
    else
    begin
      dup5Main.appendLog(DLNGStr('LOG512'));
      dup5Main.colorLog(clRed);
      dup5Main.writeLog(ReplaceValue('%f',DLNGStr('ERR900'),'ExtractFile()'));
      dup5Main.colorLog(clRed);
    end;
  end
  else
  begin
    dst := FileCreate(outfile, (fmOpenWrite or fmShareDenyWrite));
    if dst > 0 then
    begin
      if size > 0 then
      begin
        tmpStm := THandleStream.Create(dst);
//      BinCopy(CurrentFile,dst,Offset,Size,0,16384,silent);
        BinCopyToStream(CurrentFile,tmpStm,Offset,Size,0,getBufferSize(),silent,percent);
        FreeAndNil(tmpStm);
      end;
      FileClose(dst);
      if not(silent) then
        dup5Main.appendLog(DLNGStr('LOG510'));
    end
    else if not(silent) then
    begin
      dup5Main.appendLog(DLNGStr('LOG512'));
      dup5Main.colorLog(clRed);
    end;
  end;
 except
  on E: Exception do
  begin  // New error dialog box
    dup5Main.writeLog(ReplaceValue(DLNGstr('ERRDRV'),'%d',Drivers[CurrentDriver].Infos.FileName));
    dup5Main.colorLog(clRed);
    dup5Main.writeLog(E.Message +' @ TDrivers.ExtractFile_Alt:'+Drivers[CurrentDriver].Infos.FileName);
    dup5Main.colorLog(clRed);
    dup5Main.writeLog(ReplaceValue(DLNGstr('ERRDR1'),'%a',Drivers[CurrentDriver].Infos.DriverInfo.Author));
    dup5Main.colorLog(clRed);

    frmError.PrepareError;
    frmError.details.Add(ReplaceValue('%f',DLNGStr('ERREXT'),Drivers[CurrentDriver].Infos.FileName));
    frmError.details.Add('');
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Filename='+Drivers[CurrentDriver].Infos.FileName);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Name='+Drivers[CurrentDriver].Infos.DriverInfo.Name);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Author='+Drivers[CurrentDriver].Infos.DriverInfo.Author);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Version='+Drivers[CurrentDriver].Infos.DriverInfo.Version);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Comment='+Drivers[CurrentDriver].Infos.DriverInfo.Comment);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].GetDriver.ExtractInternal='+booltostr(Drivers[CurrentDriver].Functions.GetDriver.ExtractInternal,true));
    frmError.details.Add('outfile='+outfile);
    frmError.details.Add('CurrentFile='+inttostr(CurrentFile));
    frmError.details.Add('Offset='+inttostr(Offset));
    frmError.details.Add('Size='+inttostr(Size));
    frmError.FillTxtError(E,'TDrivers','ExtractFile_Alt:'+Drivers[CurrentDriver].Infos.FileName);
  end;
//   MessageDlg(ReplaceValue('%e',ReplaceValue('%a',ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[CurrentDriver].FileName),Drivers[CurrentDriver].Info.Author),E.Message),mtWarning,[mbOk],0);
 end;

end;

procedure TDrivers.ExtractFileToStream_Alt(outstream: TStream; entrynam: string; offset, size: int64;
  datax, datay: integer; silent: boolean);
begin

 try
  if (CurrentDriver > -1) and Drivers[CurrentDriver].Functions.GetDriver.ExtractInternal then
  begin
    if @Drivers[CurrentDriver].Functions.ExtractFileToStream <> Nil then
    begin
      Drivers[CurrentDriver].Functions.ExtractFileToStream(outstream,entrynam,offset,size,datax,datay,silent);
      if not(silent) then
        dup5Main.appendLog(DLNGStr('LOG510'));
    end
    else
    begin
      dup5Main.appendLog(DLNGStr('LOG512'));
      dup5Main.colorLog(clRed);
      dup5Main.writeLog(ReplaceValue('%f',DLNGStr('ERR900'),'ExtractFileToStream()'));
      dup5Main.colorLog(clRed);
    end;
  end
  else
  begin
    if (Size > 0) then
      BinCopyToStream(CurrentFile,outstream,Offset,Size,0,getBufferSize(),silent,percent);
    if not(silent) then
      dup5Main.appendLog(DLNGStr('LOG510'));
  end;
 except
  on E: Exception do
  begin  // New error dialog box
    dup5Main.appendLog(DLNGStr('LOG513'));
    dup5Main.colorLog(clRed);
    frmError.PrepareError;
    frmError.details.Add(ReplaceValue('%f',DLNGStr('ERRSTM'),Drivers[CurrentDriver].Infos.FileName));
    frmError.details.Add('');
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Filename='+Drivers[CurrentDriver].Infos.FileName);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Name='+Drivers[CurrentDriver].Infos.DriverInfo.Name);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Author='+Drivers[CurrentDriver].Infos.DriverInfo.Author);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Version='+Drivers[CurrentDriver].Infos.DriverInfo.Version);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Comment='+Drivers[CurrentDriver].Infos.DriverInfo.Comment);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].GetDriver.ExtractInternal='+booltostr(Drivers[CurrentDriver].Functions.GetDriver.ExtractInternal,true));
    frmError.details.Add('CurrentFile='+inttostr(CurrentFile));
    frmError.details.Add('Offset='+inttostr(Offset));
    frmError.details.Add('Size='+inttostr(Size));
    frmError.FillTxtError(E,'classFSE.pas','ExtractFile_Alt:'+Drivers[CurrentDriver].Infos.FileName);
  end;
//   MessageDlg(ReplaceValue('%e',ReplaceValue('%a',ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[CurrentDriver].FileName),Drivers[CurrentDriver].Info.Author),E.Message),mtWarning,[mbOk],0);
 end;

end;

function TDrivers.CurrentDriverInfos: DriverInfo;
begin

// TODO
//  if CurrentDriver > -1 then
//    CurrentDriverInfos := Drivers[CurrentDriver].GetInfo
//  else
    CurrentDriverInfos := HRipInfo;

end;

function TDrivers.Search(searchst: string; CaseSensible: Boolean; cdiridx: integer; sdir: boolean): integer;
begin

  if SDir then
    Search := SearchDir(searchst,cdiridx,CaseSensible)
  else
    Search := SearchAll(searchst, CaseSensible);

end;

function TDrivers.CalculateNumberOfFiles(cdir: string): Integer;
var TDir: string;
    res,lencdir,x: integer;
begin

  res := 0;

  LenCDir := Length(CDir);
  if LenCDir > 0 then
  begin
    CDir := CDir + sch;
    LenCDir := LenCDir + 1;
  end;

  for x := 0 to entryListIndex do
  begin

    if Length(entryList[x].Name) >= LenCDir then
      TDir := Copy(entryList[x].Name,1,lenCDir)
    else
      TDir := '';

    if TDir = CDir then
      Inc(res);

  end;

  CalculateNumberOfFiles := res;

end;

procedure TDrivers.LoadHyperRipper(fil: String; filHandle: integer; loadTime: integer; subdirs: boolean);
var starttime: TDateTime;
    zero64: int64;
begin

  if (subdirs) then
    Sch := '\'
  else
    Sch := '';

  CurrentDriverID := 'HRIP';
  CurrentFilename := fil;
  StartTime := Now;
  parseEntries(subdirs);
  LoadTimeParse := MilliSecondsBetween(Now, StartTime);
  CurrentDriver := -1;
  CurrentFile := filHandle;
  DispNumElems := entryListIndex+1;
  zero64 := 0;
  CurrentFileSize := FileSeek(filHandle,zero64,2);
  dup5Main.Caption := 'Dragon UnPACKer v' + CurVersion + ' ' + CurEdit+ ' - '+fil;
//  Dup5main.TDup5FileClose.Enabled := True;
  Dup5Main.menuFichier_Fermer.Enabled := True;
  dup5Main.Bouton_Fermer.Enabled := True;
//  Dup5Main.TDup5Edit.Visible := true;
  dup5Main.menuEdit.Visible := True;
  dup5Main.menuTools.Visible := True;
  dup5Main.Status.Panels.Items[3].Text := CurrentDriverID;
  loadTimeOpen := loadTime;
//  loadTimeParse := 0;

  loadTimeRetrieve := 0;

end;

function TDrivers.getListData(n: integer): virtualTreeData;
begin

  if (n < getListNum) and (n >= 0) then
     result := listData[n];

end;

function TDrivers.getListNum: integer;
begin

  result := length(listData);

end;

function TDrivers.SearchAll(searchst: string; CaseSensible: Boolean): integer;
var ext: String;
    testpos,posext,x,TDirPos,per,perold: integer;
    TotSize: int64;
    CurData, CurSize, TotFiles: integer;
begin

  TotSize := 0;
  TotFiles := 0;

  dup5Main.lstContent.RootNodeCount := 0;
  CurSize := 2000;
  setLength(listData,CurSize);
  perold := 0;
  DisplayPercent(0);

  for x := 0 to entryListIndex do
  begin

    if CaseSensible then
      testpos := Pos(searchst,entryList[x].FileName)
    else
      testpos := Pos(AnsiUpperCase(searchst),AnsiUpperCase(entryList[x].FileName));

    if testpos > 0 then
    begin
      if Sch = '' then
        TDirPos := 0
      else
        TDirPos := posrev(Sch, entryList[x].Name);

      listData[TotFiles].tdirpos := TDirPos;
      listData[TotFiles].entryIndex := x;
      listData[TotFiles].loaded := false;

      TotSize := TotSize + entryList[x].Size;
      inc(TotFiles);
      if (TotFiles = curSize) then
      begin
        inc(curSize,2000);
        setLength(listData,curSize);
      end;

      per := round((x / entryListIndex) * 100);
      if (per >= perold + 5) then
      begin
        DisplayPercent(per);
        perold := per;
      end;

    end;

  end;

  DisplayPercent(100);
  setLength(listData,TotFiles);

  dup5Main.lstContent.RootNodeCount := TotFiles;

  dup5Main.Status.Panels.Items[1].Text := IntToStr(TotSize) + ' ' + DLNGStr('STAT20');
  dup5Main.Status.Panels.Items[0].Text := IntToStr(TotFiles) + ' ' + DLNGStr('STAT10');

  SearchAll := TotFiles;

end;

function TDrivers.SearchDir(searchst: string; CurrentDirID: integer; CaseSensible: Boolean): integer;
var ext,TDir: String;
    TDirPos,testpos,posext,tmpi, per, perold: integer;
    TotSize: int64;
    CurData, CurSize, TotFiles, x, y, fullSizeCache: integer;
begin

  // Initialize listData to 2000 (to avoid increasing the size 1 by 1)
  curSize := 2000;
  setLength(listData,curSize);

  // Initialize variables
  TotSize := 0;
  curData := 0;
  perold := 0;

  // Indicate via the progress bar we are at 0%
  displayPercent(0);

  // Get the size of the currently selected folders (in number of entries)
  fullSizeCache := length(entryListFolderCache[CurrentDirID]);

  // Go through the cache for the current folder
  for y := Low(entryListFolderCache[CurrentDirID]) to High(entryListFolderCache[CurrentDirID]) do
  begin

    // Get the index in the entryList array from the current cache entry
    x:= entryListFolderCache[CurrentDirID][y];

    // Search for the string in the name of the entry
    if CaseSensible then
      testpos := Pos(searchst,entryList[x].FileName)
    else
      testpos := Pos(AnsiUpperCase(searchst),AnsiUpperCase(entryList[x].FileName));

    // If the string was found
    if testpos > 0 then
    begin
      // Retrieve the full folder path position
      if Sch = '' then
        TDirPos := 0
      else
        TDirPos := posrev(Sch, entryList[x].Name);

      // Fill listData with required values
      listData[curData].tdirpos := TDirPos;
      listData[curData].entryIndex := x;
      listData[curData].loaded := false;

      // Increase the Total Size of the folder with the entry size
      TotSize := TotSize + entryList[x].Size;

      // Increment the future index
      // If it is bigger than the current size of listData array we increase the
      // array by 2000
      inc(curData);
      if (curData = curSize) then
      begin
        inc(curSize,2000);
        setLength(listData,curSize);
      end;
    end;

    // Display the percent processed
    per := round((y / fullSizeCache) * 100);
    if (per >= perold + 5) then
    begin
      DisplayPercent(per);
      perold := per;
    end;

  end;

  // Number of files found correspond to the future curData index
  TotFiles := curData;

  // Be sure to display 100%
  displayPercent(100);

  // Reset the number of entries to 0
  dup5Main.lstContent.RootNodeCount := 0;

  // If something was found
  if TotFiles > 0 then
  begin

    // Crop the listData array to the true number of entries
    setLength(listData,TotFiles);

    // Set the number of entries to display to the number of entries found
    dup5Main.lstContent.RootNodeCount := TotFiles;

  end
  // Nothing was found we empty the listData array
  else
    setLength(listData,0);

  // Display what was found & displayed
  dup5Main.Status.Panels.Items[1].Text := IntToStr(TotSize) + ' ' + DLNGStr('STAT20');
  dup5Main.Status.Panels.Items[0].Text := IntToStr(TotFiles) + ' ' + DLNGStr('STAT10');

  result := TotFiles;

end;

procedure TDrivers.PrepareHyperRipper(info: DriverInfo);
begin

  HRipInfo := info;
  dup5main.closeCurrent;

end;

procedure TDrivers.saveHRF(srcfil, filename: string; srcsize: int64; prgver: integer; prgid: byte; version: byte; info: boolean;
  title, author, url: string);
begin

  case version of
    1: saveHRF_v1(srcfil, filename, srcsize, prgver);
    2: saveHRF_v2(srcfil, filename, srcsize, prgver, info, title, author, url);
    3: saveHRF_v3(srcfil, filename, srcsize, prgver, prgid, info, title, author, url);
  end;

end;

procedure TDrivers.saveHRF_v3(srcfil, filename: string; srcsize: int64; prgver: integer; prgid: byte; info: boolean; title,
  author, url: string);
var hHRF: integer;
    HDR: HRF3_Header;
    NFO: HRF3_Info;
    ENT: HRF3_Index;
    x, y: integer;
    cstr: string;
begin

  hHRF := FileCreate(filename);
  if hHRF > -1 then
    try
      HDR.ID := 'HRFi'+#26;
      HDR.MajorVersion := 3;
      HDR.MinorVersion := 0;
      HDR.PrgVersion := prgver;
      HDR.PrgID := prgid;
      HDR.OffsetIndex := sizeOf(HRF3_Header);
      if info then
      begin
        HDR.Attribs := 1;
        inc(HDR.OffsetIndex, sizeOf(HRF3_Info));
      end
      else
        HDR.Attribs := 0;

      FillChar(HDR.Filename, 255,0);
      cstr := ExtractFileName(srcfil);
      Move(cstr[1],HDR.Filename,length(cstr));
      HDR.Filesize := srcsize;
      HDR.NumEntries := entryListIndex+1;
      FileWrite(hHRF,HDR,SizeOf(HRF3_Header));
      if info then
      begin
        NFO.InfoType := 0;
        FillChar(NFO.Author,64,0);
        Move(Author[1],NFO.Author,length(Author));
        FillChar(NFO.URL,128,0);
        Move(url[1],NFO.URL,length(url));
        FillChar(NFO.Title,64,0);
        Move(title[1],NFO.Title,length(title));
        FileWrite(hHRF,NFO,SizeOf(HRF3_Info));
      end;

      for y := 0 to entryListIndex do
      begin
        FillChar(ENT.Filename,255,0);
        Move(entryList[y].Name[1],ENT.Filename,length(entryList[y].Name));
        ENT.Offset := entryList[y].Offset;
        ENT.Size := entryList[y].Size;
        FileWrite(hHRF,ENT,SizeOf(HRF3_Index));
      end;

    finally
      FileClose(hHRF);
    end;

end;

procedure TDrivers.saveHRF_v2(srcfil, filename: string; srcsize: int64;
  prgver: integer; info: boolean; title, author, url: string);
var hHRF: integer;
    HDR: HRF_Header;
    NFO: HRF_Infos_v0;
    NFO1: HRF_Infos_v1;
    ENT: HRF_Index_v2;
    x, y: integer;
    cstr: string;
begin

  hHRF := FileCreate(filename);
  if hHRF > -1 then
    try
      HDR.ID := 'HRFi'+#26;
      HDR.Version := 2;
      HDR.HRipVer.Major := Trunc(prgver/10000);
      HDR.HRipVer.Minor := Trunc(((prgver/10000)-Trunc(prgver/10000))*10);
      HDR.Dirnum := entryListIndex+1;
      FillChar(HDR.Filename, 98,0);
      cstr := ExtractFileName(srcfil);
      for x := 0 to length(cstr)-1 do
        HDR.Filename[x] := cstr[x+1];
      HDR.Filesize := srcsize;
      FileWrite(hHRF,HDR,SizeOf(HRF_Header));

      if info then
      begin
        NFO.InfoVer := 1;
        NFO.SecuritySize := 0;
        FillChar(NFO1.Author,64,0);
        for x := 0 to length(author)-1 do
          NFO1.Author[x] := author[x+1];
        FillChar(NFO1.url,128,0);
        for x := 0 to length(url)-1 do
          NFO1.url[x] := url[x+1];
        FillChar(NFO1.Title,64,0);
        for x := 0 to length(title)-1 do
          NFO1.Title[x] := title[x+1];
        FileWrite(hHRF,NFO,SizeOf(HRF_Infos_v0));
        FileWrite(hHRF,NFO1,SizeOf(HRF_Infos_v1));
      end
      else
      begin
        NFO.InfoVer := 0;
        NFO.SecuritySize := 0;
        FileWrite(hHRF,NFO,SizeOf(HRF_Infos_v0));
      end;

      for y := 0 to entryListIndex do
      begin
        FillChar(ENT.Filename,64,0);
        for x := 0 to length(entryList[y].Name)-1 do
          ENT.Filename[x] := entryList[y].Name[x+1];
        ENT.Offset := entryList[y].Offset+1;
        ENT.Size := entryList[y].Size;
        ENT.FileType := 199;
        Fillchar(ENT.Security,16,0);
        FileWrite(hHRF,ENT,SizeOf(ENT));
      end;

    finally
      FileClose(hHRF);
    end;

end;

procedure TDrivers.saveHRF_v1(srcfil, filename: string; srcsize: int64;
  prgver: integer);
var hHRF: integer;
    HDR: HRF_Header;
    ENT: HRF_Index_v1;
    x, y: integer;
    cstr: string;
begin

  hHRF := FileCreate(filename);
  if hHRF > -1 then
    try
      HDR.ID := 'HRFi'+#26;
      HDR.Version := 1;
      HDR.HRipVer.Major := Trunc(prgver/10000);
      HDR.HRipVer.Minor := Trunc(((prgver/10000)-Trunc(prgver/10000))*10);
      HDR.Dirnum := entryListIndex+1;
      FillChar(HDR.Filename, 98,0);
      cstr := ExtractFileName(srcfil);
      for x := 0 to length(cstr)-1 do
        HDR.Filename[x] := cstr[x+1];
      HDR.Filesize := srcsize;
      FileWrite(hHRF,HDR,SizeOf(HRF_Header));

      for y := 0 to entryListIndex do
      begin
        FillChar(ENT.Filename,32,0);
        for x := 0 to length(entryList[y].Name)-1 do
          ENT.Filename[x] := entryList[y].Name[x+1];
        ENT.Offset := entryList[y].Offset+1;
        ENT.Size := entryList[y].Size;
        ENT.FileType := 199;
        FileWrite(hHRF,ENT,SizeOf(ENT));
      end;

    finally
      FileClose(hHRF);
    end;

end;

// BrowseDirToList : This function returns in a TList object the list of entries
//                   in the "cdir" directory (with or without subdirectories)
//                   from the currently opened file.
//                      cdir : is the directory to parse
//                   subdirs : should return subdirectories too ?
//         Returns : TList with EntRec entries for each corresponding entry in
//                   file.
function TDrivers.BrowseDirToList(cdir: string; subdirs: boolean): TList;
var TDir: string;
    TDirPos,x: integer;
    EntRec: PEntList;
begin

  // If the right most char of cdir is the directory separator then remove it
  if rightstr(cdir,1) = sch then
    cdir := leftstr(cdir,length(cdir)-1);

  // Spawning the result TList object
  Result := TList.Create;

  // Convert cdir to uppercase (for comparison without case sensitivity)
  CDir := UpperCase(CDir);

  // Go through all entries
  for x:=0 to entryListIndex do
  begin

    // If the is no directory separation in currently opened file
    // then TDir is empty (current directory of entry is empty)
    if sch = '' then
    begin
      TDir := '';
    end
    // Else we will calculate the length of the directory we are searching for
    // and return the TDir string containing directory to compare
    else
    begin
      // If subdirs are to be returned
      if subdirs then
      begin
        // If cdir is empty, then always returns a position of 0
        if cdir = '' then
          TDirPos := 0
        // else search for the position of the first directory separator
        // starting at the index of the size of the cdir string
        else
          TDirPos := posex(sch,entryList[x].Name,Length(cdir));
      end
      // Else if no subdirs then the position is last occurence of the directory
      // separator
      else
        TDirPos := posrev(sch, entryList[x].Name);
      // Returns in TDir the directory we will compare with CDir
      if TDirPos >0 then
        TDir := Uppercase(Copy(entryList[x].Name,1,TDirPos-1))
      else
        TDir := '';
    end;

    // If TDir and CDir are identical (either entry is in same dir as the dir
    // we need the entry list, or it is in a subdirectory of this dir)
    if TDir = CDir then
    begin
      // Then we allocate new entry record, fill it with data and add it to the
      // result list
      New(EntRec);
      EntRec^.FileName := entryList[x].Name;
      EntRec^.Offset := entryList[x].Offset;
      EntRec^.Size := entryList[x].Size;
      EntRec^.DataX := entryList[x].DataX;
      EntRec^.DataY := entryList[x].DataY;
      Result.Add(EntRec);
    end;

  end;

end;

// showAboutBox : show the about box of a driver plugin
//                This function run the right exported ShowAboutBox
//                function depending of the DUDI version of the driver.
//                  hwnd : is the handle of the application
//                drvnum : is the driver index number
procedure TDrivers.showAboutBox(hwnd, drvnum: integer);
begin

  // If driver at drvnum index has DUDI version 1
  if (Drivers[DriversSorted[drvnum]].Infos.DUDIVersion = 1) then
  begin
    // Run the first version of the ShowAboutBox function
    Drivers[DriversSorted[drvnum]].Functions.ShowAboutBox(hwnd,language);
  end
  // If driver at drvnum index has DUDI version 2
  else if (Drivers[DriversSorted[drvnum]].Infos.DUDIVersion = 2) then
  begin
    // Run the second version of the ShowAboutBox function
    Drivers[DriversSorted[drvnum]].Functions.ShowAboutBox2(hwnd);
  end
  // If driver at drvnum index has DUDI version 3 or +
  else if (Drivers[DriversSorted[drvnum]].Infos.DUDIVersion >= 3) then
  begin
    // Run the third version of the ShowAboutBox function
    Drivers[DriversSorted[drvnum]].Functions.ShowAboutBox3;
  end;

end;

// showConfigBox : show the config box of a driver plugin
//                 This function run the right exported ShowConfigBox
//                 function depending of the DUDI version of the driver.
//                   hwnd : is the handle of the application
//                 drvnum : is the driver index number
procedure TDrivers.showConfigBox(hwnd, drvnum: integer);
begin

  // If driver at drvnum index has DUDI version 1
  if (Drivers[DriversSorted[drvnum]].Infos.DUDIVersion = 1) then
  begin
    // Run the first version of the ShowConfigBox function
    Drivers[DriversSorted[drvnum]].Functions.ShowConfigBox(hwnd,language);
  end
  // If driver at drvnum index has DUDI version 2
  else if (Drivers[DriversSorted[drvnum]].Infos.DUDIVersion = 2) then
  begin
    // Run the second version of the ShowConfigBox function
    Drivers[DriversSorted[drvnum]].Functions.ShowConfigBox2(hwnd);
  end
  // If driver at drvnum index has DUDI version 3 or +
  else if (Drivers[DriversSorted[drvnum]].Infos.DUDIVersion >= 3) then
  begin
    // Run the third version of the ShowConfigBox function
    Drivers[DriversSorted[drvnum]].Functions.ShowConfigBox3;
  end;

end;

procedure TDrivers.SetPath(a: string);
begin

  Dup5Pth := a;

end;

procedure TDrivers.SetLanguage(l: TLanguageCallback);
begin

  language := l;

end;

procedure TDrivers.SetOwner(AOwner: TComponent);
begin

  CurAOwner := AOwner;

end;

function TDrivers.getDriverPriority(drivername: string): integer;
var Reg: TRegistry;
begin

  Result := 0;

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\'+drivername,True) then
    begin
      if Reg.ValueExists('Priority') then
        Result := Reg.ReadInteger('Priority')
      else
        Reg.WriteInteger('Priority',0);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TDrivers.setDriverPriority(index, priority: integer);
var Reg: TRegistry;
begin

  if (index >= 1) and (index <= NumDrivers) then
  begin
    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\'+Drivers[DriversSorted[index]].Infos.FileName,True) then
      begin
        Reg.WriteInteger('Priority',priority);
        Drivers[DriversSorted[index]].Infos.Priority := priority;
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;
  end;

end;

procedure TDrivers.quickSortDrivers(lowerPos, upperPos: integer);
var temp: integer;
    i, middlePos, pivotValue : integer;
Begin
   { check that the lower position is less than the upper position }
   if lowerPos < upperPos then begin
      { Select a pivot value }
      pivotValue := Drivers[DriversSorted[lowerPos]].Infos.Priority;
      { default to the middle position to the lower position }
      middlePos := lowerPos;
      { partition the array about the pivot value }
      for i := lowerPos+1 to upperPos do begin
         if Drivers[DriversSorted[i]].Infos.Priority > pivotValue then begin
            { bump up the middle position }
            inc(middlePos);
            { swap this element to the "lower" part of the array }
            temp := DriversSorted[middlePos];
            DriversSorted[middlePos] := DriversSorted[i];
            DriversSorted[i] := temp;
         end; { if }
      end; { for }
      { place the pivot value in the middle to finish the partitioning }
      temp := DriversSorted[lowerPos];
      DriversSorted[lowerPos] := DriversSorted[middlePos];
      DriversSorted[middlePos] := temp;
      { Finally, recursively call QuickSort on the two parititioned halves.}
      quickSortDrivers(lowerPos, middlePos-1);
      quickSortDrivers(middlePos+1, upperPos);
   { else
      the lower position has reached or exceeded the upper position,
      so we're done.  This case terminates the tail-end recursion. }
   end;  { if }
End;  { Procedure QuickSort }

procedure TDrivers.sortDriversByPriority;
begin

  quickSortDrivers(1,NumDrivers);

end;

function TDrivers.getBufferSize(): integer;
var Reg: TRegistry;
begin

  Result := 16384;

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      if Reg.ValueExists('BufferSize') then
        Result := Reg.ReadInteger('BufferSize')
      else
        Result := 6;

      case result of
        0: Result := 1;
        1: Result := 512;
        2: Result := 1024;
        3: Result := 2048;
        4: Result := 4096;
        5: Result := 8192;
        6: Result := 16384;
        7: Result := 32768;
        8: Result := 65536;
        9: Result := 131072;
        10: Result := 262144;
        11: Result := 524288;
        12: Result := 1048576;
      end;

      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TDrivers.ExtractFileToStream(entryIndex: integer; outstream: TStream; fallbacktempfile: string; silent: boolean);
var Save_Cursor:TCursor;
    tmpStm: TFileStream;
begin

  SetStatus('E');
  Save_Cursor := Screen.Cursor;
  SaveTitle;
  SetTitle(DLNGStr('XTRCAP'));
  if not(silent) then
    SetPanelEx(ReplaceValue('%f',DLNGStr('XTRSTA'),entryList[entryIndex].name));
  Screen.Cursor := crHourGlass;    { Affiche le curseur en forme de sablier }
  try
    if (CurrentDriver > -1) and Drivers[CurrentDriver].Functions.GetDriver.ExtractInternal and (Drivers[CurrentDriver].Infos.DUDIVersion < 4) then
    begin
      ExtractFile_Alt(fallbacktempfile,entryList[entryIndex].Name,entryList[entryIndex].Offset,entryList[entryIndex].Size,entryList[entryIndex].DataX,entryList[entryIndex].DataY,silent);
      tmpStm := TFileStream.Create(fallbacktempfile,fmOpenRead or fmShareDenyWrite);
      try
        outstream.CopyFrom(tmpStm,tmpStm.Size);
      finally
        FreeAndNil(tmpStm);
      end;
    end
    else
      ExtractFileToStream_Alt(outstream,entryList[entryIndex].Name,entryList[entryIndex].Offset,entryList[entryIndex].Size,entryList[entryIndex].DataX,entryList[entryIndex].DataY,silent);
  except
    on E: Exception do
    begin
      dup5Main.writeLogVerbose(0,DLNGStr('ERR101'));
      dup5Main.colorLogVerbose(0,clRed);
      dup5Main.writeLogVerbose(2,DLNGStr('ERR202')+' '+E.ClassName);
      dup5Main.colorLogVerbose(2,clRed);
      dup5Main.writeLogVerbose(2,DLNGStr('ERR203')+' '+E.Message);
      dup5Main.colorLogVerbose(2,clRed);
    end;
  end;
  Screen.Cursor := Save_Cursor;  { Revient toujours à normal }
  SetStatus('-');
  RestoreTitle;

end;

procedure TDrivers.addEntry(entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer);
begin

  // Exclusion 0 bytes & negative offsets
  if (Offset >= 0) and (Size > sizeTest) then
  begin

    // If the size of the dynamic array entryList is too small for the new entry
    // we increase the size by 16
    inc(entryListIndex);
    if entryListIndex >= Length(entryList) then
      setLength(entryList,Length(entryList)+16);

    // Store the new entry
    entryList[entryListIndex].Name := entryNam;
    entryList[entryListIndex].Offset := offset;
    entryList[entryListIndex].Size := size;
    entryList[entryListIndex].DataX := datax;
    entryList[entryListIndex].DataY := datay;

  end
  else if (Offset < 0) then
    dup5Main.writeLogVerbose(2,ReplaceValue('%r',ReplaceValue('%f',DLNGstr('LOG505'),entrynam),DLNGstr('LOG507')))
  else if (Size = 0) then
    dup5Main.writeLogVerbose(2,ReplaceValue('%r',ReplaceValue('%f',DLNGstr('LOG505'),entrynam),DLNGstr('LOG506')));

end;

constructor TDrivers.Create();
var Reg: TRegistry;
begin

  // Initialize the entryList to 16 entries
  setLength(entryList,16);
  entryListIndex := -1;

  // Initialize Folder ID
  currentFolderID := 0;

  // Initialize the value of sizeTest
  sizeTest := 0;
  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      if Reg.ValueExists('Accept0Bytes') and Reg.ReadBool('Accept0Bytes') then
        sizeTest := -1;
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

destructor TDrivers.Destroy;
var x: integer;
begin

  // Close file
  CloseFile;

  // Destroy the entryList dynamic array by setting size to 0
  setLength(entryList,0);

  // Free loaded drivers
  FreeDrivers;

  // Destroy the folder cache
  For x:=Low(entryListFolderCache) to High(entryListFolderCache) do
    SetLength(entryListFolderCache[x],0);
  SetLength(entryListFolderCache,0);

  inherited Destroy();

end;

procedure TDrivers.parseEntries(withDirectories: boolean);
var Root, CachedVirtualNode: PVirtualNode;
    NodeData, CachedNodeData: pvirtualIndexData;
    parsedDir, previousDir, currentDir: string;
    x, pslash, tdirpos: integer;
    DataCache: TObject;
    dirCache: TStringHashTrie;
    Percent, OldPercent: integer;
begin

  // Reset the folder id
  CurrentFolderID := 0;

  // Show that we are starting to do something 0% progress
  percent := 0;
  oldPercent := 0;
  DisplayPercent(percent);

  // Create the root entry of the lstIndex by using the filename
  Root := dup5Main.lstIndex.AddChild(nil);
  NodeData := dup5Main.lstIndex.GetNodeData(Root);
  NodeData.dirname := ExtractFilename(CurrentFileName);
  NodeData.imageIndex := 20;
  NodeData.selectedImageIndex := 20;
  NodeData.FolderID := 0;

  // Initilialize the cache for the root
  setLength(entryListFolderCache,1);

  // If there are no sub-directories
  if not(withDirectories) then
  begin

    // The cache for the root node will have all entries
    setLength(entryListFolderCache[0],entryListIndex+1);

    // Simply add all entries to the cache
    for x := 0 to entryListIndex do
    begin

      // Save the filename
      entryList[x].FileName := entryList[x].Name;

      // Add the entry to the cache
      entryListFolderCache[0,x] := x;

      // Refresh the progress everytime we did 10% more
      if (entryListIndex > 0) then
      begin
        percent := round((x / entryListIndex) * 100);
        if percent = oldpercent + 10 then
        begin
          DisplayPercent(percent);
          oldPercent := percent;
          dup5main.Refresh;
        end;
      end;
      
    end;
    
  end
  else
  begin

    // Initialize the cache of directories
    dirCache := TStringHashTrie.Create;

    try
      // For each entry retrieved
      for x := 0 to entryListIndex do
      begin

        // Retrieve the last position of the search string (usually / or \)
        pslash := posrev(sch, entryList[x].Name)-1;
        tdirpos := pslash+1;

        // If the search string is found
        if pslash > 0 then
        begin

          // Retrieve the directory of the current entry
          currentDir := Copy(entryList[x].Name,1,pslash+1);

          // Save the filename
          entryList[x].FileName := Copy(entryList[x].Name,tdirpos+1,Length(entryList[x].Name)-tdirpos);

          // Search it in the cache
          // If it was found in the cache we retrieve the ID
          if (dirCache.Find(currentDir,DataCache)) then
          begin
            CachedVirtualNode := Pointer(DataCache);
            CachedNodeData := dup5Main.lstIndex.GetNodeData(CachedVirtualNode);
            entryList[x].FolderID := CachedNodeData.FolderID;
            setLength(entryListFolderCache[entryList[x].FolderID],Length(entryListFolderCache[entryList[x].FolderID])+1);
            entryListFolderCache[ entryList[x].FolderID , High(entryListFolderCache[entryList[x].FolderID]) ] := x;
          end
          // If not we need to create it
          else
          begin

            pslash := pos(sch,currentDir);
            previousDir := '';
            while pslash > 0 do
            begin

              // Directory without the search character
              parsedDir := Copy(currentDir,1,pslash-1);

              // Rest of the directory
              currentDir := Copy(currentDir,pslash+1,length(currentDir)-pslash);

              // If this is the root
              if previousDir = '' then
              begin

                // If we don't find the directory in the cache
                // Then we create it as a child of the Root node
                // And add it to the cache
                if not(dirCache.Find(parsedDir+Sch,DataCache)) then
                begin
                  CachedVirtualNode := dup5Main.lstIndex.AddChild(Root);
                  CachedNodeData := dup5Main.lstIndex.GetNodeData(CachedVirtualNode);
                  CachedNodeData.dirname := parsedDir;
                  CachedNodeData.imageIndex := 19;
                  CachedNodeData.selectedImageIndex := 18;
                  Inc(CurrentFolderID);
                  CachedNodeData.FolderID := CurrentFolderID;
                  dirCache.Add(parsedDir+Sch,Pointer(CachedVirtualNode));

                  // Increase entryListFolderCache by the current number of folders + root
                  setLength(entryListFolderCache,CurrentFolderID+1);
                end
                // Else we retrieve the node from the cache
                else
                  CachedVirtualNode := Pointer(DataCache);

                previousDir := parsedDir+Sch;

              end
              else
              begin

                // If we don't find the directory in the cache
                // Then we create it as a child of the current node
                // And add it to the cache
                if not(dirCache.Find(previousDir+parsedDir+Sch,DataCache)) then
                begin

                  CachedVirtualNode := dup5Main.lstIndex.AddChild(CachedVirtualNode);
                  CachedNodeData := dup5Main.lstIndex.GetNodeData(CachedVirtualNode);
                  CachedNodeData.dirname := parsedDir;
                  CachedNodeData.imageIndex := 19;
                  CachedNodeData.selectedImageIndex := 18;
                  Inc(CurrentFolderID);
                  CachedNodeData.FolderID := CurrentFolderID;
                  dirCache.Add(previousDir+parsedDir+Sch,Pointer(CachedVirtualNode));

                  // Increase entryListFolderCache by the current number of folders + root
                  setLength(entryListFolderCache,CurrentFolderID+1);
                end
                // Else we retrieve the node from the cache
                else
                  CachedVirtualNode := Pointer(DataCache);

                previousDir := previousDir + parsedDir+Sch;

              end;

              SetLength(parsedDir,0);
              pslash := pos(sch,currentDir);

            end;

            // After all folders & sub-folders are created we retrieve the folder ID
            // of the last level for the entryList
            CachedNodeData := dup5Main.lstIndex.GetNodeData(CachedVirtualNode);
            entryList[x].FolderID := CachedNodeData.FolderID;
            setLength(entryListFolderCache[entryList[x].FolderID],Length(entryListFolderCache[entryList[x].FolderID])+1);
            entryListFolderCache[ entryList[x].FolderID , High(entryListFolderCache[entryList[x].FolderID]) ] := x;

          end;
        end
        // If no search string is found (this is an entry in the root)
        else
        begin
          entryList[x].FolderID := 0;
          entryList[x].FileName := entryList[x].Name;
          setLength(entryListFolderCache[entryList[x].FolderID],Length(entryListFolderCache[entryList[x].FolderID])+1);
          entryListFolderCache[ entryList[x].FolderID , High(entryListFolderCache[entryList[x].FolderID]) ] := x;
        end;

        // Refresh the progress everytime we did 5% more
        if (entryListIndex > 0) then
        begin
          percent := round((x / entryListIndex) * 100);
          if percent = oldpercent + 5 then
          begin
            DisplayPercent(percent);
            oldPercent := percent;
            dup5main.Refresh;
          end;
        end;

      end;
    finally
      // We don't need the directory cache anymore
      FreeAndNil(dirCache);
    end;
  end;

  // Focus the root node (to force display of directory content)
  dup5Main.lstIndex.RootNodeCount := 1;
  dup5Main.lstIndex.FocusedNode := Root;

end;

procedure TDrivers.BrowseDirFromID(CurrentDirID: integer);
var TDirPos: integer;
    TotSize: int64;
    TotFiles: longword;
    curData, curSize, per, perold, x, y, fullSizeCache: integer;
begin

  // Initialize listData to 2000 (to avoid increasing the size 1 by 1)
  curSize := 2000;
  setLength(listData,curSize);

  // Initialize variables
  TotSize := 0;
  curData := 0;
  perold := 0;

  // Indicate via the progress bar we are at 0%
  displayPercent(0);

  // Get the size of the currently selected folders (in number of entries)
  fullSizeCache := length(entryListFolderCache[CurrentDirID]);

  // Go through the cache for the current folder
  for y := Low(entryListFolderCache[CurrentDirID]) to High(entryListFolderCache[CurrentDirID]) do
  begin

    // Get the index in the entryList array from the current cache entry
    x:= entryListFolderCache[CurrentDirID][y];

    // Retrieve the full folder path position
    if Sch = '' then
      TDirPos := 0
    else
      TDirPos := posrev(Sch, entryList[x].Name);

    // Fill listData with required values
    listData[curData].tdirpos := TDirPos;
    listData[curData].entryIndex := x;
    listData[curData].loaded := false;

    // Increase the Total Size of the folder with the entry size
    TotSize := TotSize + entryList[x].Size;

    // Increment the future index
    // If it is bigger than the current size of listData array we increase the
    // array by 2000
    inc(curData);
    if (curData = curSize) then
    begin
      inc(curSize,2000);
      setLength(listData,curSize);
    end;

    // Display the percent processed
    per := round((y / fullSizeCache) * 100);
    if (per >= perold + 5) then
    begin
      DisplayPercent(per);
      perold := per;
    end;

  end;

  // Number of files found correspond to the future curData index
  TotFiles := curData;

  // Be sure to display 100%
  displayPercent(100);

  // Reset the number of entries to 0
  dup5Main.lstContent.RootNodeCount := 0;

  // If something was found
  if TotFiles > 0 then
  begin

    // Crop the listData array to the true number of entries
    setLength(listData,TotFiles);

    // Set the number of entries to display to the number of entries found
    dup5Main.lstContent.RootNodeCount := TotFiles;

  end
  // Nothing was found we empty the listData array
  else
    setLength(listData,0);

  // Display what was found & displayed
  dup5Main.Status.Panels.Items[1].Text := IntToStr(TotSize) + ' ' + DLNGStr('STAT20');
  dup5Main.Status.Panels.Items[0].Text := IntToStr(TotFiles) + ' ' + DLNGStr('STAT10');

end;

function TDrivers.getEntryList(Index: integer): FSEentry;
begin

  result := entryList[Index];

end;

function TDrivers.GetDriverInfo(idx: integer): TDUDEntryInfos;
begin

  if ((idx >= 1) and (idx <= NumDrivers)) then
    result := Drivers[DriversSorted[idx]].Infos;

end;

end.
