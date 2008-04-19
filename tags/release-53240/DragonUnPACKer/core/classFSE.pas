unit classFSE;

// $Id: classFSE.pas,v 1.7 2008-04-19 17:53:33 elbereth Exp $
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
     spec_HRF, strutils, Windows, SysUtils, Error,JvJCLUtils, Graphics,
     commonTypes;

{ Record declaration }

type

  ExtensionsResult = record            // This record is used to store the list
    Num: integer;                      // of all supported extensions (that
    Lists: array[1..5] of String;      // Dragon UnPACKer can handle).
  end;                                 // Fractionned as 255 chars max Strings.

  FormatEntry = record                 // Data is retrieved from the driver
    FileName: ShortString;             // using this structure (each item is
    Offset, Size: Int64;               // returned using this struct).
    DataX, DataY: Integer;
  end;

  CurrentDriverInfo = record           // When a driver have opened a file
    Sch : ShortString;                 // successfully a function is called to
    ID : ShortString;                  // get more information. This structure
    FileHandle : Integer;              // stores the result.
    ExtractInternal : Boolean;
  end;

  FormatInfo = record                  // Used for the list of supported games
    Extensions : ShortString;          // and extensions
    Name : ShortString;
  end;

  DriverInfo = record                  // This structure is returned when the
    Name : ShortString;                // driver is queried for information.
    Author : ShortString;              // Contains a list of supported games.
    Version : ShortString;
    Comment : ShortString;
    NumFormats : Byte;
    Formats : array[1..255] of FormatInfo;
  end;

  ErrorInfo = record                   // This is returned whenever there is
    Format : ShortString;              // an error in a driver.
    Games : ShortString;
  end;

{ External Function/Procedure declaration }

type

  { Callback functions (the driver can call those functions/procedure) }

  // TPercentCallback : Used to set the current progress of the process
  //                    p must be between 0 and 100.
  TPercentCallback = procedure(p: byte);
  // TLanguageCallback : Used to retrieve language strings (translations)
  //                     lngid is a 6 chars ID for a language string.
  TLanguageCallback = function (lngid: ShortString): ShortString;

  { Driver plugin functions }

  // TDUDIVersion : Returns the driver plugin DUDI (Dragon UnPACKer Driver
  //                Interface) version.
  //                Current class supports : 1 = Version 1
  //                                         2 = Version 2
  //                                         3 = Version 3
  //                                         4 = Version 4
  //                Each version has different exported functions/procedure
  //                and/or same function/procedure with different export
  //                parameters.
  TDUDIVersion = function(): Byte; stdcall;
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
  TGetEntry = function(): FormatEntry; stdcall;
  TGetDriverInfo = function(): DriverInfo; stdcall;
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

type driver = record
   FileName : ShortString;
   Handle : THandle;
   CloseFile : TCloseFormat;
   OpenFile : TOpenFormat;
   OpenFile2 : TOpenFormat2;
   GetEntry : TGetEntry;
   GetInfo : TGetDriverInfo;
   GetVersion : TGetNumVersion;
   Info : DriverInfo;
   GetDriver : TGetCurrentDriverInfo;
   CanOpen : TIsFormat;
   ExtractFile : TExtractFile;
   ExtractFileToStream : TExtractFileToStream;
   GetError : TGetError;
   ShowAboutBox : TShowBox;
   ShowAboutBox2 : TShowBox2;
   ShowAboutBox3 : TShowBox3;
   IsAboutBox : Boolean;
   ShowConfigBox : TShowBox;
   ShowConfigBox2 : TShowBox2;
   ShowConfigBox3 : TShowBox3;
   IsConfigBox : Boolean;
   DUDIVersion : Byte;
   InitPlugin : TInitPlugin;
   InitPlugin3 : TInitPlugin3;
   Priority : Integer;         // 5.1 : Prioritization of drivers
 end;

 pvirtualTreeData = ^virtualTreeData;
 virtualTreeData = record
   ImageIndex: Integer;
   tdirpos: integer;
   data: FSE;
   loaded: boolean;
   desc: String;
 end;

 pvirtualIndexData = ^virtualIndexData;
 virtualIndexData = record
   dirname: String;
   imageIndex: integer;
   selectedImageIndex: integer;
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
    Drivers: array[1..200] of Driver;
    NumDrivers: Integer;
    function CurrentDriverInfos(): DriverInfo;
    function GetNumEntries(): Integer;
    function GetLoadTime(t: byte): Int64;
    function GetFileName(): string;
    function GetFileSize(): Int64;
//    procedure ExtractFile(entrynam: string; outfile: string; silent: boolean);
    procedure ExtractFile(entry: FSE; outfile: string; silent: boolean);
    procedure ExtractFileToStream(entry: FSE; outstream: TStream; fallbacktempfile: string; silent: boolean);
    procedure ExtractDir(cdir: string; outpath: string);
    function IsListEmpty: Boolean;
    function GetListSize: Integer;
    function SlashMode: string;
    function DriverID: string;
    function GetFileTypes: string;
    function GetAllFileTypes(Partitionned: boolean): ExtensionsResult;
    procedure BrowseDir(cdir: string);
    function BrowseDirToList(cdir: string; SubDirs: Boolean): TList;
    procedure FreeList;
    procedure GetListElem(Name: string; out Offset, Size: Int64; out DataX, DataY: integer);
    procedure SetListElem(Name: string; Offset, Size: Int64; DataX, DataY: integer);
    procedure SetTreeView(a: TTreeView);
    procedure SetProgressBar(a: TPercentCallback);
    procedure LoadDrivers(pth: String);
    procedure FreeDrivers;
    function LoadFile(pth: String; Silent: boolean): TDriverLoadResult;
    procedure LoadHyperRipper(fil: String; filHandle: integer; loadTime: integer; subdirs: boolean);
    function CloseFile(): boolean;
    function Search(searchst: string; CaseSensible: Boolean; cdir: string; sdir: boolean): integer;
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
  private
    HRipInfo: DriverInfo;
    listData: array of virtualTreeData;
    LoadTimeOpen: Int64;
    LoadTimeRetrieve: Int64;
    LoadTimeParse: Int64;
    DataBloc: FSE;
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
    procedure DataBlocAdd(Name: String; Offset, Size: Int64; DataX, DataY: integer);
    procedure DataBlocFree();
    procedure DataBlocFree_Aux(a: FSE);
    procedure FreeList_Aux(a: FSE);
    function ParseFileTypes(names: string; ext: string): string;
    procedure ExtractFile_Alt(outfile,entrynam: string; offset: int64; size: int64; datax: integer; datay: integer; silent: boolean);
    procedure ExtractFileToStream_Alt(outstream: TStream; entrynam: string; offset: int64; size: int64; datax: integer; datay: integer; silent: boolean);
    function CalculateNumberOfFiles(cdir: string): Integer;
    function GetRegistryBool(key: string; value: string; default: boolean = false): boolean;
    function SearchAll(searchst: string; CaseSensible: Boolean): integer;
    function SearchDir(searchst, cdir: string; CaseSensible: Boolean): integer;
    procedure saveHRF_v1(srcfil, filename: string; srcsize: int64; prgver: integer);
    procedure saveHRF_v2(srcfil, filename: string; srcsize: int64; prgver: integer; info: boolean; title,author, url: string);
    procedure saveHRF_v3(srcfil, filename: string; srcsize: int64; prgver: integer; prgid: byte; info: boolean; title,author, url: string);
    function getDriverPriority(drivername: string): integer;
    procedure quickSortDrivers(lowerPos, upperPos: integer);
    function getBufferSize(): integer;
  protected
end;

implementation

{ TDrivers }

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

// FreeList_Aux : Auxiliary function that frees the data chain (chained records)
//                by going through the data and freeing every item.
procedure TDrivers.FreeList_Aux(a: FSE);
begin

  if (a <> nil) then
  begin

    if (a^.suiv <> nil) then
      FreeList_aux(a^.suiv);

    dispose(a);

  end;

end;

// FreeList : This frees all data allocated in the file list by the data chain
procedure TDrivers.FreeList;
begin

  if Not(IsListEmpty) then
  begin
    FreeList_Aux(databloc);
    DataBloc := Nil;
    NumElems := 0;
  end;

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

  IsListEmpty := DataBloc = NIL;

end;

procedure TDrivers.GetListElem(Name: string; out Offset, Size: Int64; out DataX, DataY: integer);
var autrFSE: FSE;
    Nam: Pchar;
begin

  Nam := PChar(Name);

  autrFSE := DataBloc;

  if autrFSE <> NIL then
  begin
    while (autrFSE^.suiv <> NIL) and (autrFSE^.Name <> Nam) do
    begin
      autrFSE := autrFSE^.suiv;
    end;
    if (autrFSE^.Name = Nam) then
    begin
      Offset := autrFSE^.Offset;
      Size := autrFSE^.Size;
      DataX := autrFSE^.DataX;
      DataY := autrFSE^.DataY;
    end
    else
    begin
      Offset := 0;
      Size := 0;
      DataX := 0;
      DataY := 0;
    end
  end;

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
    Handle: THandle;
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
        if (@DUDIVer <> Nil) and ((DUDIVer = 1) or (DUDIVer = 2) or (DUDIVer = 3) or (DUDIVer = 4)) then
        begin
          if IsConsole then
            write('IsDUDI... ')
          else
            dup5Main.appendLogVerbose(2,'DUDI v'+inttostr(DUDIVer)+' -');
          Inc(NumDrivers);

          Drivers[NumDrivers].DUDIVersion := DUDIVer;
          @Drivers[NumDrivers].CloseFile := GetProcAddress(Handle, 'CloseFormat');
          @Drivers[NumDrivers].GetEntry := GetProcAddress(Handle, 'GetEntry');
          @Drivers[NumDrivers].GetInfo := GetProcAddress(Handle, 'GetDriverInfo');
          @Drivers[NumDrivers].GetDriver := GetProcAddress(Handle, 'GetCurrentDriverInfo');
          @Drivers[NumDrivers].GetVersion := GetProcAddress(Handle, 'GetNumVersion');
          @Drivers[NumDrivers].CanOpen := GetProcAddress(Handle, 'IsFormat');
          @Drivers[NumDrivers].ExtractFile := GetProcAddress(Handle, 'ExtractFile');
          @Drivers[NumDrivers].GetError := GetProcAddress(Handle, 'GetErrorInfo');
          if (DUDIVer = 1) then
          begin
            @Drivers[NumDrivers].ShowAboutBox := GetProcAddress(Handle, 'AboutBox');
            @Drivers[NumDrivers].ShowConfigBox := GetProcAddress(Handle, 'ConfigBox');
            @Drivers[NumDrivers].OpenFile := GetProcAddress(Handle, 'ReadFormat');
          end
          else if (DUDIVer = 2) then
          begin
            @Drivers[NumDrivers].ShowAboutBox2 := GetProcAddress(Handle, 'AboutBox');
            @Drivers[NumDrivers].ShowConfigBox2 := GetProcAddress(Handle, 'ConfigBox');
            @Drivers[NumDrivers].InitPlugin := GetProcAddress(Handle, 'InitPlugin');
            @Drivers[NumDrivers].OpenFile2 := GetProcAddress(Handle, 'ReadFormat');
          end
          else if (DUDIVer = 3) then
          begin
            @Drivers[NumDrivers].ShowAboutBox3 := GetProcAddress(Handle, 'AboutBox');
            @Drivers[NumDrivers].ShowConfigBox3 := GetProcAddress(Handle, 'ConfigBox');
            @Drivers[NumDrivers].InitPlugin3 := GetProcAddress(Handle, 'InitPlugin');
            @Drivers[NumDrivers].OpenFile2 := GetProcAddress(Handle, 'ReadFormat');
          end
          else if (DUDIVer = 4) then
          begin
            @Drivers[NumDrivers].ShowAboutBox3 := GetProcAddress(Handle, 'AboutBox');
            @Drivers[NumDrivers].ShowConfigBox3 := GetProcAddress(Handle, 'ConfigBox');
            @Drivers[NumDrivers].InitPlugin3 := GetProcAddress(Handle, 'InitPlugin');
            @Drivers[NumDrivers].OpenFile2 := GetProcAddress(Handle, 'ReadFormat');
            @Drivers[NumDrivers].ExtractFileToStream := GetProcAddress(Handle, 'ExtractFileToStream');
          end;

          if ((DUDIVer = 1) and (@Drivers[NumDrivers].OpenFile = Nil))
          or (((DUDIVer = 2) or (DUDIVer = 3) or (DUDIVer = 4)) and (@Drivers[NumDrivers].OpenFile2 = Nil))
          or (@Drivers[NumDrivers].CloseFile = Nil)
          or (@Drivers[NumDrivers].GetEntry = Nil)
          or (@Drivers[NumDrivers].GetInfo = Nil)
          or (@Drivers[NumDrivers].GetDriver = Nil)
          or (@Drivers[NumDrivers].GetVersion = Nil)
          or (@Drivers[NumDrivers].CanOpen = Nil)
          or (@Drivers[NumDrivers].GetError = Nil)
          or ((DUDIVer = 2) and (@Drivers[NumDrivers].InitPlugin = Nil))
          or (((DUDIVer = 3) or (DUDIVer = 4)) and (@Drivers[NumDrivers].InitPlugin3 = Nil))
          or ((DUDIVer = 4) and (@Drivers[NumDrivers].ExtractFileToStream = Nil))
          then
          begin
            if IsConsole then
              writeln('Malformed!')
            else
            begin
              if dup5Main.getVerboseLevel = 0 then
              begin
                dup5Main.writeLog(' + '+sr.Name+' :');
              end;
              dup5Main.appendLog(DLNGstr('ERRD02'));
              dup5Main.colorLog(clRed);
              //MessageDlg(DLNGstr('ERRD02')+#10+sr.Name,mtWarning,[mbOk],0);
            end;
            dec(NumDrivers);
            FreeLibrary(handle);
          end
          else
          begin
            if IsConsole then
              writeln('OK');
            try
              if (DUDIVer = 2) then
              begin
                Drivers[NumDrivers].InitPlugin(Percent,Language,dup5pth);
              end
              else if (DUDIVer = 3) or (DUDIVer = 4) then
              begin
                Drivers[NumDrivers].InitPlugin3(Percent,Language,dup5pth,Application.Handle,CurAOwner);
              end;
              Drivers[NumDrivers].FileName := ExtractFileName(sr.Name);
              Drivers[NumDrivers].Handle := Handle;
              Drivers[NumDrivers].Info := Drivers[NumDrivers].GetInfo;
              Drivers[NumDrivers].Info.Version := Drivers[NumDrivers].Info.Version;
              Drivers[NumDrivers].IsAboutBox := not(@Drivers[NumDrivers].ShowAboutBox = nil) or not(@Drivers[NumDrivers].ShowAboutBox2 = nil) or not(@Drivers[NumDrivers].ShowAboutBox3 = nil);
              Drivers[NumDrivers].IsConfigBox := not(@Drivers[NumDrivers].ShowConfigBox = nil) or not(@Drivers[NumDrivers].ShowConfigBox2 = nil) or not(@Drivers[NumDrivers].ShowConfigBox3 = nil);
              Drivers[NumDrivers].Priority := getDriverPriority(ExtractFileName(sr.Name));
              dup5Main.appendLogVerbose(1,Drivers[NumDrivers].Info.Name+' v'+Drivers[NumDrivers].Info.Version)
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

    until FindNext(sr) <> 0;

    if NumDrivers > 1 then
      quickSortDrivers(1,NumDrivers);

  end
  else
    NumDrivers := 0;

  FindClose(sr);

  if IsConsole then
    writeln('Finished!');

end;

procedure TDrivers.DataBlocAdd(Name: String; Offset, Size: Int64; DataX, DataY: integer);
var nouvFSE: FSE;
begin

  new(nouvFSE);
  nouvFSE^.Name := Name;
  nouvFSE^.Offset := Offset;
  nouvFSE^.Size := Size;
  nouvFSE^.DataX := DataX;
  nouvFSE^.DataY := DataY;
  nouvFSE^.suiv := DataBloc;
  DataBloc := nouvFSE;

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
    Reg.Free;
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
    CanOpen: array[1..200] of Integer;
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

    while (x <= NumDrivers) do
    begin
      try
        if Drivers[x].CanOpen(pchar(pth),SmartOpen) then
        begin
          dup5Main.writeLogVerbose(1,ReplaceStr(DLNGStr('LOG500'),'%d',Drivers[x].Info.Name));
          Inc(NumCanOpen);
          CanOpen[NumCanOpen] := x;
        end;
      except
        on E:EFOpenError do MessageDlg(ReplaceValue('%f',DLNGstr('ERRIO'),pth),mtWarning,[mbOk],0);
        on Ex:Exception do
        begin  // New error dialog box
          frmError.PrepareError;
          frmError.details.Add(DLNGStr('ERRCAL'));
          frmError.details.Add('if Drivers['+inttostr(x)+'].CanOpen('''+pth+''','+booltostr(SmartOpen,true)+') then');
          frmError.details.Add('');
          frmError.details.Add('Drivers['+inttostr(x)+'].Filename='+Drivers[x].FileName);
          frmError.details.Add('Drivers['+inttostr(x)+'].Info.Name='+Drivers[x].Info.Name);
          frmError.details.Add('Drivers['+inttostr(x)+'].Info.Author='+Drivers[x].Info.Author);
          frmError.details.Add('Drivers['+inttostr(x)+'].Info.Version='+Drivers[x].Info.Version);
          frmError.details.Add('Drivers['+inttostr(x)+'].Info.Comment='+Drivers[x].Info.Comment);
          frmError.FillTxtError(Ex,'classFSE.pas','LoadFile:'+Drivers[x].FileName+'.CanOpen');
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

      for x := 1 to NumCanOpen do
      begin
        CurrentDriver := CanOpen[x];

        i := FileOpen(pth,fmOpenRead or fmShareDenyNone);
        zero64 := 0;
        CurrentFileSize := FileSeek(i,zero64,2);
        FileClose(i);

        dup5Main.writeLogVerbose(1,ReplaceStr(DLNGStr('LOG501'),'%d',Drivers[CurrentDriver].Info.Name));

        StartTime := Now;
        try
          if (Drivers[CurrentDriver].DUDIVersion = 1) then
            NumElems := Drivers[CurrentDriver].OpenFile(pchar(pth),Percent,SmartOpen)
          else if (Drivers[CurrentDriver].DUDIVersion = 2) or (Drivers[CurrentDriver].DUDIVersion = 3) or (Drivers[CurrentDriver].DUDIVersion = 4) then
            NumElems := Drivers[CurrentDriver].OpenFile2(pchar(pth),SmartOpen);
        except
          on Ex:Exception do
          begin  // New error dialog box
            frmError.PrepareError;
            frmError.details.Add(DLNGStr('ERRCAL'));
            if Drivers[CurrentDriver].DUDIVersion = 1 then
              frmError.details.Add('NumElems := Drivers['+inttostr(CurrentDriver)+'].OpenFile('''+pth+''',Percent,'+booltostr(SmartOpen,true)+')')
            else if (Drivers[CurrentDriver].DUDIVersion = 2) or (Drivers[CurrentDriver].DUDIVersion = 3) or (Drivers[CurrentDriver].DUDIVersion = 4) then
              frmError.details.Add('NumElems := Drivers['+inttostr(CurrentDriver)+'].OpenFile2('''+pth+''','+booltostr(SmartOpen,true)+')');
            frmError.details.Add('');
            frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Filename='+Drivers[CurrentDriver].FileName);
            frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Name='+Drivers[CurrentDriver].Info.Name);
            frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Author='+Drivers[CurrentDriver].Info.Author);
            frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Version='+Drivers[CurrentDriver].Info.Version);
            frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Comment='+Drivers[CurrentDriver].Info.Comment);
            frmError.FillTxtError(Ex,'classFSE.pas','LoadFile:'+Drivers[CurrentDriver].FileName+'.OpenFile');
            NumElems := -999
          end;
        end;
        LoadTimeOpen := MilliSecondsBetween(Now, StartTime);

        dup5Main.appendLogVerbose(2,inttostr(LoadTimeOpen)+'ms');

        if NumElems > 0 then
        begin

          dup5Main.appendLog(DLNGStr('LOG511'));

          SetTitle(DLNGstr('TLD002'));
          StartTime := Now;

          DrvInfo := Drivers[CurrentDriver].GetDriver;
          CurrentDriverID := DrvInfo.ID;

          if IsConsole then
            writeln('NumElems: '+IntToStr(NumElems));

          DispNumElems := 0;
          y := 0;

          dup5Main.writeLogVerbose(1,ReplaceStr(DLNGStr('LOG502'),'%x',inttostr(NumElems)));

          try
            for y := 1 to NumElems do
            begin
              Test := Drivers[CurrentDriver].GetEntry();
              if (Test.Offset >= 0) and (Test.Size > 0) then
              begin
                Inc(DispNumElems);
                DataBlocAdd(Test.FileName,Test.Offset,Test.Size,Test.DataX,Test.DataY);
              end;
            end;
          except
            on Ex:Exception do
            begin  // New error dialog box
              dup5Main.writeLog(ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[CurrentDriver].FileName));
              dup5Main.colorLog(clRed);
              dup5Main.writeLog(Ex.Message +' @ TDrivers.LoadFile:'+Drivers[CurrentDriver].FileName+'.GetEntry');
              dup5Main.colorLog(clRed);
              dup5Main.writeLog(ReplaceValue('%a',DLNGstr('ERRDR1'),Drivers[CurrentDriver].Info.Author));
              dup5Main.colorLog(clRed);

              frmError.PrepareError;
              frmError.details.Add(DLNGStr('ERRCAL'));

              frmError.details.Add('for y := 1 to '+inttostr(NumElems)+' do');
              frmError.details.Add('begin');
              frmError.details.Add('  Test := Drivers['+inttostr(CurrentDriver)+'].GetEntry();');
              frmError.details.Add('  if ('+inttostr(Test.Offset)+' >= 0) and ('+inttostr(Test.Size)+' > 0) then');
              frmError.details.Add('  begin');
              frmError.details.Add('    Inc(DispNumElems);');
              frmError.details.Add('    DataBlocAdd('''+Test.FileName+''','+inttostr(Test.Offset)+','+inttostr(Test.Size)+','+inttostr(Test.DataX)+','+inttostr(Test.DataY)+');');
              frmError.details.Add('  end;');
              frmError.details.Add('end;');

              frmError.details.Add('');
              frmError.details.Add('y='+inttostr(y));
              frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Filename='+Drivers[CurrentDriver].FileName);
              frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Name='+Drivers[CurrentDriver].Info.Name);
              frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Author='+Drivers[CurrentDriver].Info.Author);
              frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Version='+Drivers[CurrentDriver].Info.Version);
              frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Comment='+Drivers[CurrentDriver].Info.Comment);
              frmError.FillTxtError(Ex,'TDrivers','LoadFile:'+Drivers[CurrentDriver].FileName+'.GetEntry');

              NumElems := y-1;
//            MessageDlg(ReplaceValue('%e',ReplaceValue('%a',ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[x].FileName),Drivers[x].Info.Author),ex.message),mtWarning,[mbOk],0);
//            MessageDlg(ReplaceValue('%a',ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[x].FileName),Drivers[x].Info.Author),mtWarning,[mbOk],0);
            end;
          end;

          LoadTimeRetrieve := MilliSecondsBetween(Now, StartTime);

          dup5Main.appendLogVerbose(2,inttostr(LoadTimeRetrieve)+'ms');

          SetTitle(DLNGstr('TLD003'));
          StartTime := Now;

          SCh := DrvInfo.Sch;

          InternalExtract := DrvInfo.ExtractInternal;
          CurrentFile := DrvInfo.FileHandle;

          dup5Main.writeLogVerbose(1,DLNGStr('LOG503'));

          if Sch <> '' then
            ParseDirs(Sch, DataBloc, ExtractFileName(pth))
          else
            CreateRoot(ExtractFileName(pth));

          LoadTimeParse := MilliSecondsBetween(Now, StartTime);

          dup5Main.appendLogVerbose(2,inttostr(LoadTimeParse)+'ms');

          CurrentFileName := pth;

          SetTitle(pth);

          res := dlOK;

          dup5Main.writeLogVerbose(1,ReplaceStr(ReplaceStr(DLNGStr('LOG504'),'%p',Drivers[CurrentDriver].Info.Name),'%f',DriverID));

          break;

        end
        else if NumElems = 0 then
        begin
          dup5Main.appendLog(DLNGStr('LOG512'));
          inc(ErrNum);
          DrvInfo := Drivers[CurrentDriver].GetDriver;
          Drivers[CurrentDriver].CloseFile;
          ErrList.Add('<'+Drivers[CurrentDriver].FileName+'> '+DLNGstr('ERREMP'));
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
                  ErrInfo := Drivers[CurrentDriver].GetError;
                  ErrList.Add(ReplaceValue('%f',DLNGStr('ERRCMP'),ErrInfo.Games));
                end;
            -3: begin
                  ErrInfo := Drivers[CurrentDriver].GetError;
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

    ErrList.Free;
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
begin

  CloseFile := True;

  if NumElems > 0 then
  begin
    DataBlocFree;
    if CurrentDriver <> -1 then
      try
        CloseFile := Drivers[CurrentDriver].CloseFile;
      except
        on E:Exception do
        begin
          dup5Main.writeLog(ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[CurrentDriver].FileName));
          dup5Main.colorLog(clRed);
          dup5Main.writeLog(E.Message +' @ TDrivers.CloseFile');
          dup5Main.colorLog(clRed);
          dup5Main.writeLog(ReplaceValue('%a',DLNGstr('ERRDR1'),Drivers[CurrentDriver].Info.Author));
          dup5Main.colorLog(clRed);
          CloseFile := false;
        end;
      end;
  end;

  if (CurrentDriver = -1) and (CurrentFile >= 0) then
    FileClose(CurrentFile);

  CurrentDriver := 0;

end;

procedure TDrivers.DataBlocFree;
begin

  if DataBloc <> Nil then
  begin
    DataBlocFree_Aux(databloc);
    DataBloc := Nil;
    NumElems := 0;
  end;

end;

procedure TDrivers.DataBlocFree_Aux(a: FSE);
begin

  if (a <> nil) then
  begin

    if (a^.suiv <> nil) then
      DataBlocFree_Aux(a^.suiv);

    dispose(a);

  end;

end;

procedure TDrivers.BrowseDir(cdir: string);
var a: FSE;
    TDir: string;
    TDirPos: integer;
    TotSize: int64;
    TotFiles: longword;
    curData, curSize, curIdx, per, perold, x: integer;
    cache: TDirCache;
//    starttime: TDateTime;
begin

//  starttime := now;

  TotSize := 0;

  CDir := UpperCase(CDir);

  cache := GetDirCache(CDir);

  if cache <> nil then
  begin
    setLength(ListData,cache.getNumItems);
    totFiles := cache.getNumItems;
//    if cache.getNumItems > 0 then
//      TDirPos := posrev(sch, cache.getItem(1)^.name);
    TDirPos := cache.getTDirPos;
    for x := 0 to cache.getNumItems-1 do
    begin
      listData[x].tdirpos := TDirPos;
{      posext := posrev('.',cache.getItem(x)^.Name);
      if posext > 0 then
        ext := Copy(cache.getItem(x)^.Name,posext+1,length(cache.getItem(x)^.Name)-posext)
      else
        ext := '';}
      listData[x].data := cache.getItem(x);
//      listData[x].desc := DescFromExt(ext);
      listData[x].loaded := false;

//      listData[curData].ImageIndex := IconFromExt(ext);
{      listData[x].ImageIndex := icons.getIcon(cache.getItem(x)^.Name);}
      TotSize := TotSize + cache.getItem(x)^.Size;
    end;
  end
  else
  begin

  curSize := 2000;
  setLength(listData,curSize);

  displayPercent(0);

  a := DataBloc;
  curData := 0;
  curIdx := 0;
  perold := 0;

  while a <> NIL do
  begin

    if sch = '' then
    begin
      TDir := '';
      TDirPos := 0;
    end
    else
    begin
      TDirPos := posrev(sch, a^.Name);
      if TDirPos >0 then
        TDir := Uppercase(Copy(a^.Name,1,TDirPos-1))
      else
        TDir := '';
    end;

    if TDir = CDir then
    begin
//      listData[curData].fileName := Copy(a^.Name,TDirPos+1,Length(a^.Name)-TDirPos);
      listData[curData].tdirpos := TDirPos;
{      posext := posrev('.',a^.Name);
      if posext > 0 then
        ext := Copy(a^.Name,posext+1,length(a^.Name)-posext)
      else
        ext := '';}
      listData[curData].data := a;
//      listData[curData].desc := DescFromExt(ext);
      listData[curData].loaded := false;

//      listData[curData].ImageIndex := IconFromExt(ext);
{      listData[curData].ImageIndex := icons.getIcon(a^.Name); }
      TotSize := TotSize + a^.Size;
      inc(curData);
      if (a^.suiv <> nil) and (curData = curSize) then
      begin
        inc(curSize,2000);
        setLength(listData,curSize);
      end
    end;

    Inc(CurIdx);

    per := round((CurIdx / NumElems) * 100);
    if (per >= perold + 5) then
    begin
      DisplayPercent(per);
      perold := per;
    end;
    a := a^.suiv;

  end;

  TotFiles := curData;

  end;

//  showmessage(inttostr(millisecondsbetween(now,starttime)));

  displayPercent(100);

  if TotFiles > 0 then
  begin
    setLength(listData,TotFiles);

    dup5Main.lstContent.RootNodeCount := 0;
    dup5Main.lstContent.RootNodeCount := TotFiles;

  end
  else
  begin
    dup5Main.lstContent.RootNodeCount := 0;
    setLength(listData,0);
  end;

  dup5Main.Status.Panels.Items[1].Text := IntToStr(TotSize) + ' ' + DLNGStr('STAT20');
  dup5Main.Status.Panels.Items[0].Text := IntToStr(TotFiles) + ' ' + DLNGStr('STAT10');

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

  for x := 1 to NumDrivers do
    for y := 1 to Drivers[x].Info.NumFormats do
    begin
      names := Drivers[x].Info.Formats[y].Name;
      ext := Drivers[x].Info.Formats[y].Extensions;
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
    for y := 1 to Drivers[x].Info.NumFormats do
      if res <> '' then
        res := res + ';' + Drivers[x].Info.Formats[y].Extensions
      else
        res := Drivers[x].Info.Formats[y].Extensions;
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
      ExtList.Free;
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
procedure TDrivers.ExtractFile(entry: FSE; outfile: string; silent: boolean);
var //Offset,Size: int64;
//    DataX,DataY: integer;
    Save_Cursor:TCursor;
begin

  SetStatus('E');
  Save_Cursor := Screen.Cursor;
  SaveTitle;
  SetTitle(DLNGStr('XTRCAP'));
  SetPanelEx(ReplaceValue('%f',DLNGStr('XTRSTA'),entry^.name));
  ShowPanelEx;
  Screen.Cursor := crHourGlass;    { Affiche le curseur en forme de sablier }
  try
    //GetListElem(entrynam,Offset,Size,DataX,DataY);
    ExtractFile_Alt(outfile,entry^.Name,entry^.Offset,entry^.Size,entry^.DataX,entry^.DataY,silent);
  finally
    Screen.Cursor := Save_Cursor;  { Revient toujours à normal }
    SetStatus('-');
    RestoreTitle;
    HidePanelEx;
  end;

end;

procedure TDrivers.ExtractDir(cdir, outpath: string);
var a: FSE;
    TDir,cfil,cfilcnv: string;
    totfiles,curfiles,lencdir: integer;
    Save_Cursor:TCursor;
    perc,numper: integer;
begin

  SetStatus('E');
  Save_Cursor := Screen.Cursor;
  SaveTitle;
  SetTitle(DLNGStr('XTRCAP'));
  ShowPanelEx;
  Screen.Cursor := crHourGlass;    { Affiche le curseur en forme de sablier }
  try

    a := DataBloc;
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

    while a <> NIL do
    begin

      if Length(a^.Name) >= LenCDir then
        TDir := Copy(a^.Name,1,lenCDir)
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

        SetPanelEx(ReplaceValue('%f',DLNGStr('XTRSTA'),a^.Name));
        cfil := Copy(a^.Name,length(TDir)+1,Length(a^.Name)-length(TDir));
        if Copy(cfil,1,1) = sch then
          cfil := Copy(cfil,2,length(cfil)-1);

        if Sch = '/' then
          cfilcnv := ConvertSlash(cfil)
        else
          cfilcnv := cfil;

        ExtractFile_Alt(outpath+cfilcnv,a^.Name,a^.Offset,a^.Size,a^.DataX,a^.DataY,false);
//      MessageDlg(DLNGStr('ERR102')+ ' '+cfil,mtError,[mbOk],0);

      end;

      a := a^.suiv;

    end;
  finally
    Screen.Cursor := Save_Cursor;  { Revient toujours à normal }
    SetStatus('-');
    HidePanelEx;
    RestoreTitle;
  end;

end;

procedure TDrivers.ExtractFile_Alt(outfile, entrynam: string; offset, size: int64;
  datax, datay: integer; silent: boolean);
var dst: integer;
    tmpStm: THandleStream;
begin

 try
  if (CurrentDriver <> -1) and Drivers[CurrentDriver].GetDriver.ExtractInternal then
  begin
    if @Drivers[CurrentDriver].ExtractFile <> Nil then
    begin
      Drivers[CurrentDriver].ExtractFile(outfile,entrynam,offset,size,datax,datay,silent);
      dup5Main.appendLog(DLNGStr('LOG510'));
    end
    else
    begin
      dup5Main.appendLog(DLNGStr('LOG512'));
      dup5Main.colorLog(clRed);
      dup5Main.writeLog(ReplaceStr(DLNGStr('ERR900'),'%f','ExtractFile()'));
      dup5Main.colorLog(clRed);
    end;
  end
  else
  begin
    dst := FileCreate(outfile, (fmOpenWrite or fmShareDenyWrite));
    if dst > 0 then
    begin
      tmpStm := THandleStream.Create(dst);
//      BinCopy(CurrentFile,dst,Offset,Size,0,16384,silent);
      BinCopyToStream(CurrentFile,tmpStm,Offset,Size,0,getBufferSize(),silent,percent);
      tmpStm.Free;
      FileClose(dst);
      dup5Main.appendLog(DLNGStr('LOG510'));
    end;
  end;
 except
  on E: Exception do
  begin  // New error dialog box
    dup5Main.writeLog(ReplaceValue(DLNGstr('ERRDRV'),'%d',Drivers[CurrentDriver].FileName));
    dup5Main.colorLog(clRed);
    dup5Main.writeLog(E.Message +' @ TDrivers.ExtractFile_Alt:'+Drivers[CurrentDriver].FileName);
    dup5Main.colorLog(clRed);
    dup5Main.writeLog(ReplaceValue(DLNGstr('ERRDR1'),'%a',Drivers[CurrentDriver].Info.Author));
    dup5Main.colorLog(clRed);

    frmError.PrepareError;
    frmError.details.Add(ReplaceStr(DLNGStr('ERREXT'),'%f',Drivers[CurrentDriver].FileName));
    frmError.details.Add('');
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Filename='+Drivers[CurrentDriver].FileName);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Name='+Drivers[CurrentDriver].Info.Name);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Author='+Drivers[CurrentDriver].Info.Author);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Version='+Drivers[CurrentDriver].Info.Version);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Comment='+Drivers[CurrentDriver].Info.Comment);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].GetDriver.ExtractInternal='+booltostr(Drivers[CurrentDriver].GetDriver.ExtractInternal,true));
    frmError.details.Add('outfile='+outfile);
    frmError.details.Add('CurrentFile='+inttostr(CurrentFile));
    frmError.details.Add('Offset='+inttostr(Offset));
    frmError.details.Add('Size='+inttostr(Size));
    frmError.FillTxtError(E,'TDrivers','ExtractFile_Alt:'+Drivers[CurrentDriver].FileName);
  end;
//   MessageDlg(ReplaceValue('%e',ReplaceValue('%a',ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[CurrentDriver].FileName),Drivers[CurrentDriver].Info.Author),E.Message),mtWarning,[mbOk],0);
 end;

end;

procedure TDrivers.ExtractFileToStream_Alt(outstream: TStream; entrynam: string; offset, size: int64;
  datax, datay: integer; silent: boolean);
begin

 try
  if (CurrentDriver <> -1) and Drivers[CurrentDriver].GetDriver.ExtractInternal then
  begin
    if @Drivers[CurrentDriver].ExtractFileToStream <> Nil then
    begin
      Drivers[CurrentDriver].ExtractFileToStream(outstream,entrynam,offset,size,datax,datay,silent);
      dup5Main.appendLog(DLNGStr('LOG510'));
    end
    else
    begin
      dup5Main.appendLog(DLNGStr('LOG512'));
      dup5Main.colorLog(clRed);
      dup5Main.writeLog(ReplaceStr(DLNGStr('ERR900'),'%f','ExtractFileToStream()'));
      dup5Main.colorLog(clRed);
    end;
  end
  else
  begin
    BinCopyToStream(CurrentFile,outstream,Offset,Size,0,getBufferSize(),silent,percent);
    dup5Main.appendLog(DLNGStr('LOG510'));
  end;
 except
  on E: Exception do
  begin  // New error dialog box
    dup5Main.appendLog(DLNGStr('LOG513'));
    dup5Main.colorLog(clRed);
    frmError.PrepareError;
    frmError.details.Add(ReplaceStr(DLNGStr('ERRSTM'),'%f',Drivers[CurrentDriver].FileName));
    frmError.details.Add('');
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Filename='+Drivers[CurrentDriver].FileName);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Name='+Drivers[CurrentDriver].Info.Name);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Author='+Drivers[CurrentDriver].Info.Author);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Version='+Drivers[CurrentDriver].Info.Version);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].Info.Comment='+Drivers[CurrentDriver].Info.Comment);
    frmError.details.Add('Drivers['+inttostr(CurrentDriver)+'].GetDriver.ExtractInternal='+booltostr(Drivers[CurrentDriver].GetDriver.ExtractInternal,true));
    frmError.details.Add('CurrentFile='+inttostr(CurrentFile));
    frmError.details.Add('Offset='+inttostr(Offset));
    frmError.details.Add('Size='+inttostr(Size));
    frmError.FillTxtError(E,'classFSE.pas','ExtractFile_Alt:'+Drivers[CurrentDriver].FileName);
  end;
//   MessageDlg(ReplaceValue('%e',ReplaceValue('%a',ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[CurrentDriver].FileName),Drivers[CurrentDriver].Info.Author),E.Message),mtWarning,[mbOk],0);
 end;

end;

function TDrivers.CurrentDriverInfos: DriverInfo;
begin

  if CurrentDriver <> -1 then
    CurrentDriverInfos := Drivers[CurrentDriver].Info
  else
    CurrentDriverInfos := HRipInfo;

end;

function TDrivers.Search(searchst: string; CaseSensible: Boolean; cdir: string; sdir: boolean): integer;
begin

  if SDir then
    Search := SearchDir(searchst,cdir,CaseSensible)
  else
    Search := SearchAll(searchst, CaseSensible);

end;

function TDrivers.CalculateNumberOfFiles(cdir: string): Integer;
var a: FSE;
    TDir: string;
    res,lencdir: integer;
begin

  a := DataBloc;
  res := 0;

  LenCDir := Length(CDir);
  if LenCDir > 0 then
  begin
    CDir := CDir + sch;
    LenCDir := LenCDir + 1;
  end;

  while a <> NIL do
  begin

    if Length(a^.Name) >= LenCDir then
      TDir := Copy(a^.Name,1,lenCDir)
    else
      TDir := '';

    if TDir = CDir then
      Inc(res);

    a := a^.suiv;

  end;

  CalculateNumberOfFiles := res;

end;

procedure TDrivers.SetListElem(Name: string; Offset, Size: Int64; DataX,
  DataY: integer);
begin

  DataBlocAdd(Name,Offset,Size,DataX,DataY);
  Inc(NumElems);
  DispNumElems := NumElems;

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
  StartTime := Now;
  if subdirs then
    ParseDirs(Sch, DataBloc, ExtractFileName(fil))
  else
    CreateRootHR(ExtractFileName(fil),subdirs);
  LoadTimeParse := MilliSecondsBetween(Now, StartTime);
  CurrentDriver := -1;
  CurrentFile := filHandle;
  zero64 := 0;
  CurrentFileSize := FileSeek(filHandle,zero64,2);
  dup5Main.Caption := 'Dragon UnPACKer v' + CurVersion + ' ' + CurEdit+ ' - '+fil;
//  Dup5main.TDup5FileClose.Enabled := True;
  Dup5Main.menuFichier_Fermer.Enabled := True;
  dup5Main.Bouton_Fermer.Enabled := True;
//  Dup5Main.TDup5Edit.Visible := true;
  dup5Main.menuEdit.Visible := True;
  dup5Main.Status.Panels.Items[3].Text := 'HRIP';
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
    testpos,posext: integer;
    a: FSE;
    TotSize: int64;
    CurData, TotFiles: integer;
begin

  TotSize := 0;
  TotFiles := 0;

  a := DataBloc;

  while a <> NIL do
  begin

    if CaseSensible then
      testpos := Pos(searchst,a^.Name)
    else
      testpos := Pos(AnsiUpperCase(searchst),AnsiUpperCase(a^.Name));

    if testpos > 0 then
      Inc(TotFiles);

    a := a^.suiv;

  end;

  if (TotFiles > 0) then
  begin
    setLength(listData,TotFiles);

    a := DataBloc;
    curData := 0;

    while a <> NIL do
    begin

      if CaseSensible then
        testpos := Pos(searchst,a^.Name)
      else
        testpos := Pos(AnsiUpperCase(searchst),AnsiUpperCase(a^.Name));

      if testpos > 0 then
      begin
        if (sch = '') then
//          outp := a^.name
          listData[curData].tdirpos := 0
        else
        begin
          listData[curData].tdirpos := posrev(sch,a^.Name);
{          tmpi := posrev(sch,a^.Name);
          if tmpi > 0 then
            outp := Copy(a^.Name, tmpi+1,length(a^.Name)-tmpi)
          else
            outp := a^.Name;}
        end;
//        listData[curData].fileName := outp;
        posext := posrev('.',a^.Name);
        if posext > 0 then
          ext := Copy(a^.Name,posext+1,length(a^.Name)-posext)
        else
          ext := '';
        listData[curData].data := a;
        listData[curData].desc := DescFromExt(ext);
  //      listData[curData].ImageIndex := IconFromExt(ext);
        listData[curData].ImageIndex := icons.getIcon(a^.Name);
        TotSize := TotSize + a^.Size;
        inc(curData);
      end;

      a := a^.suiv;

    end;
    dup5Main.lstContent.RootNodeCount := 0;
    dup5Main.lstContent.RootNodeCount := TotFiles;

  end
  else
    dup5Main.lstContent.RootNodeCount := 0;

  dup5Main.Status.Panels.Items[1].Text := IntToStr(TotSize) + ' ' + DLNGStr('STAT20');
  dup5Main.Status.Panels.Items[0].Text := IntToStr(TotFiles) + ' ' + DLNGStr('STAT10');

  SearchAll := TotFiles;

end;

function TDrivers.SearchDir(searchst, cdir: string;
  CaseSensible: Boolean): integer;
var ext,TDir: String;
    TDirPos,testpos,posext,tmpi: integer;
    a: FSE;
    TotSize: int64;
    CurData, TotFiles: integer;
begin

  TotSize := 0;
  TotFiles := 0;

  a := DataBloc;

  while a <> NIL do
  begin

    if (sch = '') then
      TDirPos := 0
    else
      TDirPos := posrev(sch, a^.Name);
    if TDirPos >0 then
      TDir := Copy(a^.Name,1,TDirPos-1)
    else
      TDir := '';

    if TDir = CDir then
    begin
      if CaseSensible then
        testpos := Pos(searchst,a^.Name)
      else
        testpos := Pos(AnsiUpperCase(searchst),AnsiUpperCase(a^.Name));
      if testpos > 0 then
        Inc(TotFiles);
    end;

    a := a^.suiv;

  end;

  if (TotFiles > 0) then
  begin
    setLength(listData,TotFiles);

    a := DataBloc;
    curData := 0;

    while a <> NIL do
    begin

      if (sch = '') then
        TDirPos := 0
      else
        TDirPos := posrev(sch, a^.Name);
      if TDirPos >0 then
        TDir := Copy(a^.Name,1,TDirPos-1)
      else
        TDir := '';

      if TDir = CDir then
      begin

        if CaseSensible then
          testpos := Pos(searchst,a^.Name)
        else
          testpos := Pos(AnsiUpperCase(searchst),AnsiUpperCase(a^.Name));

        if testpos > 0 then
        begin
          if (sch = '') then
            tmpi := 0
          else
            tmpi := posrev(sch,a^.Name);
{          if tmpi > 0 then
            outp := Copy(a^.Name, tmpi+1,length(a^.Name)-tmpi)
          else
            outp := a^.Name;
          listData[curData].fileName := outp;}
          listData[curData].tdirpos := tmpi;
          posext := posrev('.',a^.Name);
          if posext > 0 then
            ext := Copy(a^.Name,posext+1,length(a^.Name)-posext)
          else
            ext := '';
          listData[curData].data := a;
          listData[curData].desc := DescFromExt(ext);
          //listData[curData].ImageIndex := IconFromExt(ext);
          listData[curData].ImageIndex := icons.getIcon(a^.Name);
          TotSize := TotSize + a^.Size;
          inc(curData);
        end;

      end;

      a := a^.suiv;

    end;

    dup5Main.lstContent.RootNodeCount := 0;
    dup5Main.lstContent.RootNodeCount := TotFiles;

  end
  else
    dup5Main.lstContent.RootNodeCount := 0;

  dup5Main.Status.Panels.Items[1].Text := IntToStr(TotSize) + ' ' + DLNGStr('STAT20');
  dup5Main.Status.Panels.Items[0].Text := IntToStr(TotFiles) + ' ' + DLNGStr('STAT10');

  SearchDir := TotFiles;

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
    x: integer;
    cstr: string;
    a: FSE;
begin

  hHRF := FileCreate(filename);
  if hHRF > -1 then
    try
      HDR.ID := 'HRFi'+#26;
      HDR.MajorVersion := 3;
      HDR.MinorVersion := 0;
      HDR.PrgVersion := prgver;
      HDR.PrgID := prgid;
      HDR.OffsetIndex := sizeOf(HDR);
      if info then
      begin
        HDR.Attribs := 1;
        inc(HDR.OffsetIndex, sizeOf(NFO));
      end
      else
        HDR.Attribs := 0;

      FillChar(HDR.Filename, 255,0);
      cstr := ExtractFileName(srcfil);
      for x := 1 to length(cstr) do
        HDR.Filename[x] := cstr[x];
      HDR.Filesize := srcsize;
      HDR.NumEntries := NumElems;
      FileWrite(hHRF,HDR,SizeOf(HDR));
      if info then
      begin
        NFO.InfoType := 0;
        FillChar(NFO.Author,64,0);
        for x := 1 to length(author) do
          NFO.Author[x] := author[x];
        FillChar(NFO.URL,128,0);
        for x := 1 to length(url) do
          NFO.URL[x] := url[x];
        FillChar(NFO.Title,64,0);
        for x := 1 to length(title) do
          NFO.Title[x] := title[x];
        FileWrite(hHRF,NFO,SizeOf(NFO));
      end;

      a := DataBloc;

      while a <> NIL do
      begin
        FillChar(ENT.Filename,255,0);
        for x := 1 to length(a^.Name) do
          ENT.Filename[x] := a^.Name[x];
        ENT.Offset := a^.Offset;
        ENT.Size := a^.Size;
        FileWrite(hHRF,ENT,SizeOf(ENT));
        a := a^.suiv;
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
    x: integer;
    cstr: string;
    a: FSE;
begin

  hHRF := FileCreate(filename);
  if hHRF > -1 then
    try
      HDR.ID := 'HRFi'+#26;
      HDR.Version := 2;
      HDR.HRipVer.Major := Trunc(prgver/10000);
      HDR.HRipVer.Minor := Trunc(((prgver/10000)-Trunc(prgver/10000))*10);
      HDR.Dirnum := NumElems;
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

      a := DataBloc;

      while a <> NIL do
      begin
        FillChar(ENT.Filename,64,0);
        for x := 0 to length(a^.Name)-1 do
          ENT.Filename[x] := a^.Name[x+1];
        ENT.Offset := a^.Offset+1;
        ENT.Size := a^.Size;
        ENT.FileType := 199;
        Fillchar(ENT.Security,16,0);
        FileWrite(hHRF,ENT,SizeOf(ENT));
        a := a^.suiv;
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
    x: integer;
    cstr: string;
    a: FSE;
begin

  hHRF := FileCreate(filename);
  if hHRF > -1 then
    try
      HDR.ID := 'HRFi'+#26;
      HDR.Version := 1;
      HDR.HRipVer.Major := Trunc(prgver/10000);
      HDR.HRipVer.Minor := Trunc(((prgver/10000)-Trunc(prgver/10000))*10);
      HDR.Dirnum := NumElems;
      FillChar(HDR.Filename, 98,0);
      cstr := ExtractFileName(srcfil);
      for x := 0 to length(cstr)-1 do
        HDR.Filename[x] := cstr[x+1];
      HDR.Filesize := srcsize;
      FileWrite(hHRF,HDR,SizeOf(HRF_Header));

      a := DataBloc;

      while a <> NIL do
      begin
        FillChar(ENT.Filename,32,0);
        for x := 0 to length(a^.Name)-1 do
          ENT.Filename[x] := a^.Name[x+1];
        ENT.Offset := a^.Offset+1;
        ENT.Size := a^.Size;
        ENT.FileType := 199;
        FileWrite(hHRF,ENT,SizeOf(ENT));
        a := a^.suiv;
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
var a: FSE;
    TDir: string;
    TDirPos: integer;
    EntRec: PEntList;
begin

  // If the right most char of cdir is the directory separator then remove it
  if rightstr(cdir,1) = sch then
    cdir := leftstr(cdir,length(cdir)-1);

  // Spawning the result TList object
  Result := TList.Create;

  // Convert cdir to uppercase (for comparison without case sensitivity)
  CDir := UpperCase(CDir);

  // First entry in the pointer chain for currently opened file
  a := DataBloc;

  // Loop while current pointer isn't NIL
  while a <> NIL do
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
          TDirPos := posex(sch,a^.Name,Length(cdir));
      end
      // Else if no subdirs then the position is last occurence of the directory
      // separator
      else
        TDirPos := posrev(sch, a^.Name);
      // Returns in TDir the directory we will compare with CDir
      if TDirPos >0 then
        TDir := Uppercase(Copy(a^.Name,1,TDirPos-1))
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
      EntRec^.FileName := a^.Name;
      EntRec^.Offset := a^.Offset;
      EntRec^.Size := a^.Size;
      EntRec^.DataX := a^.DataX;
      EntRec^.DataY := a^.DataY;
      Result.Add(EntRec);
    end;

    // Check next entry in the chain
    a := a^.suiv;

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
  if (Drivers[drvnum].DUDIVersion = 1) then
  begin
    // Run the first version of the ShowAboutBox function
    Drivers[drvnum].ShowAboutBox(hwnd,language);
  end
  // If driver at drvnum index has DUDI version 2
  else if (Drivers[drvnum].DUDIVersion = 2) then
  begin
    // Run the second version of the ShowAboutBox function
    Drivers[drvnum].ShowAboutBox2(hwnd);
  end
  // If driver at drvnum index has DUDI version 3 or 4
  else if (Drivers[drvnum].DUDIVersion = 3) or (Drivers[drvnum].DUDIVersion = 4) then
  begin
    // Run the third version of the ShowAboutBox function
    Drivers[drvnum].ShowAboutBox3;
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
  if (Drivers[drvnum].DUDIVersion = 1) then
  begin
    // Run the first version of the ShowConfigBox function
    Drivers[drvnum].ShowConfigBox(hwnd,language);
  end
  // If driver at drvnum index has DUDI version 2
  else if (Drivers[drvnum].DUDIVersion = 2) then
  begin
    // Run the second version of the ShowConfigBox function
    Drivers[drvnum].ShowConfigBox2(hwnd);
  end
  // If driver at drvnum index has DUDI version 3 or 4
  else if (Drivers[drvnum].DUDIVersion = 3) or (Drivers[drvnum].DUDIVersion = 4) then
  begin
    // Run the third version of the ShowConfigBox function
    Drivers[drvnum].ShowConfigBox3;
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
    Reg.Free;
  end;

end;

procedure TDrivers.setDriverPriority(index, priority: integer);
var Reg: TRegistry;
begin

  if (index > 0) and (index <= NumDrivers) then
  begin
    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\'+Drivers[index].FileName,True) then
      begin
        Reg.WriteInteger('Priority',priority);
        Drivers[index].Priority := priority;
        Reg.CloseKey;
      end;
    Finally
      Reg.Free;
    end;
  end;

end;

procedure TDrivers.quickSortDrivers(lowerPos, upperPos: integer);
var temp: driver;
    i, middlePos, pivotValue : integer;
Begin
   { check that the lower position is less than the upper position }
   if lowerPos < upperPos then begin
      { Select a pivot value }
      pivotValue := Drivers[lowerPos].Priority;
      { default to the middle position to the lower position }
      middlePos := lowerPos;
      { partition the array about the pivot value }
      for i := lowerPos+1 to upperPos do begin
         if Drivers[i].Priority > pivotValue then begin
            { bump up the middle position }
            inc(middlePos);
            { swap this element to the "lower" part of the array }
            temp := Drivers[middlePos];
            Drivers[middlePos] := Drivers[i];
            drivers[i] := temp;
         end; { if }
      end; { for }
      { place the pivot value in the middle to finish the partitioning }
      temp := Drivers[lowerPos];
      Drivers[lowerPos] := Drivers[middlePos];
      Drivers[middlePos] := temp;
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
    Reg.Free;
  end;

end;

procedure TDrivers.ExtractFileToStream(entry: FSE; outstream: TStream; fallbacktempfile: string; silent: boolean);
var Save_Cursor:TCursor;
    tmpStm: TFileStream;
begin

  SetStatus('E');
  Save_Cursor := Screen.Cursor;
  SaveTitle;
  SetTitle(DLNGStr('XTRCAP'));
  SetPanelEx(ReplaceValue('%f',DLNGStr('XTRSTA'),entry^.name));
  ShowPanelEx;
  Screen.Cursor := crHourGlass;    { Affiche le curseur en forme de sablier }
  try
    if (CurrentDriver <> -1) and Drivers[CurrentDriver].GetDriver.ExtractInternal and (Drivers[CurrentDriver].DUDIVersion < 4) then
    begin
      ExtractFile_Alt(fallbacktempfile,entry^.Name,entry^.Offset,entry^.Size,entry^.DataX,entry^.DataY,silent);
      tmpStm := TFileStream.Create(fallbacktempfile,fmOpenRead or fmShareDenyWrite);
      try
        outstream.CopyFrom(tmpStm,tmpStm.Size);
      finally
        tmpStm.Free;
      end;
    end
    else
      ExtractFileToStream_Alt(outstream,entry^.Name,entry^.Offset,entry^.Size,entry^.DataX,entry^.DataY,silent);
  finally
    Screen.Cursor := Save_Cursor;  { Revient toujours à normal }
    SetStatus('-');
    RestoreTitle;
    HidePanelEx;
  end;

end;

end.
