unit classFSE;

// $Id: classFSE.pas,v 1.1.1.1 2004-05-08 10:25:13 elbereth Exp $
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

interface

uses auxFSE, Main, Comctrls, Windows, SysUtils, Dialogs,lib_binCopy,lib_language,classes,Controls, Forms, Registry,DateUtils, lib_utils, spec_HRF, prg_ver, strutils;

type
  ExtensionsResult = record
    Num: integer;
    Lists: array[1..5] of String;
  end;
  FormatEntry = record
    FileName: ShortString;
    Offset, Size: Int64;
    DataX, DataY: Integer;
  end;
  CurrentDriverInfo = record
    Sch : ShortString;
    ID : ShortString;
    FileHandle : Integer;
    ExtractInternal : Boolean;
  end;
  FormatInfo = record
    Extensions : ShortString;
    Name : ShortString;
  end;
  DriverInfo = record
    Name : ShortString;
    Author : ShortString;
    Version : ShortString;
    Comment : ShortString;
    NumFormats : Byte;
    Formats : array[1..255] of FormatInfo;
  end;
  ErrorInfo = record
    Format : ShortString;
    Games : ShortString;
  end;

type
  TPercentCallback = procedure(p: byte);
  TLanguageCallback = function (lngid: ShortString): ShortString;
  TDUDIVersion = function(): Byte; stdcall;
  TCloseFormat = function(): boolean; stdcall;
  TOpenFormat = function(src: ShortString; Percent: TPercentCallback; Deeper: boolean): Integer; stdcall;
  TOpenFormat2 = function(src: ShortString; Deeper: boolean): Integer; stdcall;
  TGetEntry = function(): FormatEntry; stdcall;
  TGetDriverInfo = function(): DriverInfo; stdcall;
  TGetNumVersion = function(): Integer; stdcall;
  TGetCurrentDriverInfo = function(): CurrentDriverInfo; stdcall;
  TIsFormat = function(src: ShortString; deeper: Boolean): Boolean; stdcall;
  TExtractFile = function(outputfile: ShortString; entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: Boolean): boolean; stdcall;
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
    function LoadFile(pth: String; Silent: boolean): boolean;
    procedure LoadHyperRipper(fil: String; filHandle: integer; loadTime: integer; subdirs: boolean);
    function CloseFile(): boolean;
    function Search(searchst: string; CaseSensible: Boolean; cdir: string; sdir: boolean): integer;
    function getListData(n: integer): virtualTreeData;
    function getIndexData(n: integer): virtualIndexData;
    function getListNum(): integer;
    procedure PrepareHyperRipper(Info: DriverInfo);
    procedure saveHRF(srcfil, filename: string; srcsize: int64; prgver: integer; prgid: byte; version: byte; info: boolean;  title, author, url: string);
    procedure showAboutBox(hwnd: integer; drvnum: integer);
    procedure showConfigBox(hwnd: integer; drvnum: integer);
    procedure SetPath(a: string);
    procedure SetLanguage(l: TLanguageCallback);
    procedure SetOwner(AOwner: TComponent);
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
    function PosRev(substr: string; str: string): integer;
    function ParseFileTypes(names: string; ext: string): string;
    procedure ExtractFile_Alt(outfile,entrynam: string; offset: int64; size: int64; datax: integer; datay: integer; silent: boolean);
    function CalculateNumberOfFiles(cdir: string): Integer;
    function GetRegistryBool(key: string; value: string; default: boolean = false): boolean;
    function SearchAll(searchst: string; CaseSensible: Boolean): integer;
    function SearchDir(searchst, cdir: string; CaseSensible: Boolean): integer;
    procedure saveHRF_v1(srcfil, filename: string; srcsize: int64; prgver: integer);
    procedure saveHRF_v2(srcfil, filename: string; srcsize: int64; prgver: integer; info: boolean; title,author, url: string);
    procedure saveHRF_v3(srcfil, filename: string; srcsize: int64; prgver: integer; prgid: byte; info: boolean; title,author, url: string);
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

procedure TDrivers.FreeList_Aux(a: FSE);
begin

  if (a <> nil) then
  begin

    if (a^.suiv <> nil) then
      FreeList_aux(a^.suiv);

    dispose(a);

  end;

end;

procedure TDrivers.FreeList;
begin

  if Not(IsListEmpty) then
  begin
    FreeList_Aux(databloc);
    DataBloc := Nil;
    NumElems := 0;
  end;

end;

function TDrivers.GetListSize: Integer;
// GetListSize
// Returns 0 if the file list is empty
//         n if the file list has n elements
begin

  if IsListEmpty then
    GetListSize := 0
  else
    GetListSize := DispNumElems;

end;

function TDrivers.IsListEmpty: Boolean;
// IsListEmpty
// Returns TRUE if file list is empty
//         FALSE if not
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

//  TView := TTreeView.Create(Nil);
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
        write(sr.name+ ' ');
      Handle := LoadLibrary(PChar(pth + sr.name));
      if Handle <> 0 then
      begin
        if IsConsole then
          write('Loaded... ');
          @DUDIVer := GetProcAddress(Handle, 'DUDIVersion');
        if (@DUDIVer <> Nil) and ((DUDIVer = 1) or (DUDIVer = 2) or (DUDIVer = 3)) then
        begin
          if IsConsole then
            write('IsDUDI... ');
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
          end;

          if ((DUDIVer = 1) and (@Drivers[NumDrivers].OpenFile = Nil))
          or (((DUDIVer = 2) or (DUDIVer = 3)) and (@Drivers[NumDrivers].OpenFile2 = Nil))
          or (@Drivers[NumDrivers].CloseFile = Nil)
          or (@Drivers[NumDrivers].GetEntry = Nil)
          or (@Drivers[NumDrivers].GetInfo = Nil)
          or (@Drivers[NumDrivers].GetDriver = Nil)
          or (@Drivers[NumDrivers].GetVersion = Nil)
          or (@Drivers[NumDrivers].CanOpen = Nil)
          or (@Drivers[NumDrivers].GetError = Nil)
          or ((DUDIVer = 2) and (@Drivers[NumDrivers].InitPlugin = Nil))
          or ((DUDIVer = 3) and (@Drivers[NumDrivers].InitPlugin3 = Nil))
          then
          begin
            if IsConsole then
              writeln('Malformed!')
            else
              MessageDlg(DLNGstr('ERRD02')+#10+sr.Name,mtWarning,[mbOk],0);
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
              else if (DUDIVer = 3) then
              begin
                Drivers[NumDrivers].InitPlugin3(Percent,Language,dup5pth,Application.Handle,CurAOwner);
              end;
              Drivers[NumDrivers].FileName := ExtractFileName(sr.Name);
              Drivers[NumDrivers].Handle := Handle;
              Drivers[NumDrivers].Info := Drivers[NumDrivers].GetInfo;
              Drivers[NumDrivers].Info.Version := Drivers[NumDrivers].Info.Version;
              Drivers[NumDrivers].IsAboutBox := not(@Drivers[NumDrivers].ShowAboutBox = nil) or not(@Drivers[NumDrivers].ShowAboutBox2 = nil) or not(@Drivers[NumDrivers].ShowAboutBox3 = nil);
              Drivers[NumDrivers].IsConfigBox := not(@Drivers[NumDrivers].ShowConfigBox = nil) or not(@Drivers[NumDrivers].ShowConfigBox2 = nil) or not(@Drivers[NumDrivers].ShowConfigBox3 = nil);
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
            MessageDlg(DLNGstr('ERRD01')+#10+sr.Name,mtWarning,[mbOk],0);
          FreeLibrary(handle);
        end;
      end

    until FindNext(sr) <> 0;

  end
  else
    NumDrivers := 0;

  FindClose(sr);

  if IsConsole then
    writeln('Finished!');

end;


function TDrivers.PosRev(substr, str: string): integer;
var res,x : integer;
begin

  res := 0;
  x := (length(str) - length(substr) + 1);

  while (x >= 1) and (res = 0) do
  begin

    if copy(str,x, length(substr)) = substr then
      res := x;

    x := x - 1;

  end;

  posrev := res;

end;

function strip0(str : string): string;
var pos0: integer;
begin

  pos0 := pos(chr(0),str);

  if pos0 > 0 then
    strip0 := copy(str, 1, pos0 - 1)
  else
    strip0 := str;

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

function TDrivers.LoadFile(pth: String; Silent: boolean): boolean;
var x,y,i: integer;
    Test: FormatEntry;
    DrvInfo: CurrentDriverInfo;
    res,SmartOpen: boolean;
    ErrInfo: ErrorInfo;
    StartTime: TDateTime;
    CanOpen: array[1..200] of Integer;
    NumCanOpen: Integer;
    ErrList: TStringList;
    ErrStr: String;
    ErrNum: integer;
begin

  SaveTitle;
  SetTitle(ReplaceValue('%f',DLNGstr('TLD001'),ExtractFilename(pth)));
  result := false;

  if (FileExists(pth)) then
  begin

    SmartOpen := GetRegistryBool('StartUp','SmartOpen',True);

    x := 1 ;
    NumCanOpen := 0;
    ErrNum := 0;
    ErrList := TStringList.Create;
    res := false;

    while (x <= NumDrivers) do
    begin
      try
        if Drivers[x].CanOpen(pchar(pth),SmartOpen) then
        begin
          Inc(NumCanOpen);
          CanOpen[NumCanOpen] := x;
        end;
      except
        on E:EFOpenError do MessageDlg(ReplaceValue('%f',DLNGstr('ERRIO'),pth),mtWarning,[mbOk],0);
        on Ex:Exception do MessageDlg(ReplaceValue('%e',ReplaceValue('%a',ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[x].FileName),Drivers[x].Info.Author),ex.message),mtWarning,[mbOk],0);
      end;
      Inc(x);
    end;

    if NumCanOpen = 0 then
    begin
      if not(silent) then
        MessageDlg(DLNGstr('ERRUNK'),mtInformation,[mbOk],0);
      RestoreTitle;
    end
    else
    begin

      for x := 1 to NumCanOpen do
      begin
        CurrentDriver := CanOpen[x];

        i := FileOpen(pth,fmOpenRead or fmShareDenyNone);
        CurrentFileSize := FileSeek(i,0,2);
        FileClose(i);

        StartTime := Now;
        try
          if (Drivers[CurrentDriver].DUDIVersion = 1) then
            NumElems := Drivers[CurrentDriver].OpenFile(pchar(pth),Percent,SmartOpen)
          else if (Drivers[CurrentDriver].DUDIVersion = 2) or (Drivers[CurrentDriver].DUDIVersion = 3) then
            NumElems := Drivers[CurrentDriver].OpenFile2(pchar(pth),SmartOpen);
        except
          on Ex:Exception do
          begin
            MessageDlg(ReplaceValue('%e',ReplaceValue('%a',ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[x].FileName),Drivers[x].Info.Author),ex.message),mtWarning,[mbOk],0);
//            MessageDlg(ReplaceValue('%a',ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[x].FileName),Drivers[x].Info.Author),mtWarning,[mbOk],0);
            NumElems := -999
          end;
        end;
        LoadTimeOpen := MilliSecondsBetween(Now, StartTime);

        if NumElems > 0 then
        begin

          SetTitle(DLNGstr('TLD002'));
          StartTime := Now;

          DrvInfo := Drivers[CurrentDriver].GetDriver;
          CurrentDriverID := DrvInfo.ID;

          if IsConsole then
            writeln('NumElems: '+IntToStr(NumElems));

          DispNumElems := 0;

          try
            for y := 1 to NumElems do
            begin
              Test := Drivers[CurrentDriver].GetEntry();
//            ShowMessage(Test.FileName+#10+inttostr(Test.Offset)+#10+inttostr(Test.Size));
              if (Test.Offset >= 0) and (Test.Size > 0) then
              begin
                Inc(DispNumElems);
//              Percent(Round((y/NumElems)*100));
                DataBlocAdd(Test.FileName,Test.Offset,Test.Size,Test.DataX,Test.DataY);
              end;
            end;
          except
            on Ex:Exception do
            begin
              MessageDlg(ReplaceValue('%e',ReplaceValue('%a',ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[x].FileName),Drivers[x].Info.Author),ex.message),mtWarning,[mbOk],0);
//            MessageDlg(ReplaceValue('%a',ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[x].FileName),Drivers[x].Info.Author),mtWarning,[mbOk],0);
              NumElems := y-1;
            end;
          end;

          LoadTimeRetrieve := MilliSecondsBetween(Now, StartTime);
      //ShowMessage('Retrieve: OK');
          SetTitle(DLNGstr('TLD003'));
          StartTime := Now;

          SCh := DrvInfo.Sch;

          InternalExtract := DrvInfo.ExtractInternal;
          CurrentFile := DrvInfo.FileHandle;

          if Sch <> '' then
            ParseDirs(Sch, DataBloc, ExtractFileName(pth))
          else
            CreateRoot(ExtractFileName(pth));

          LoadTimeParse := MilliSecondsBetween(Now, StartTime);

          CurrentFileName := pth;

          SetTitle(pth);

          res := true;

          break;

        end
        else if NumElems = 0 then
        begin
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
        res := false;
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
        MessageDlg(ErrStr,mtInformation,[mbOk],0);
        RestoreTitle;
      end;

    end;

    ErrList.Free;
    LoadFile := res;

  end
  else
  begin
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
        MessageDlg(ReplaceValue('%a',ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[CurrentDriver].FileName),Drivers[CurrentDriver].Info.Author),mtWarning,[mbOk],0);
        CloseFile := false;
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
    TDir,ext: string;
    TDirPos,posext: integer;
    TotSize: int64;
    TotFiles: longword;
    curData, curSize, curIdx, per, perold, CDirSize, x: integer;
    cache: TDirCache;
//    starttime: TDateTime;
begin

//  starttime := now;

  TotSize := 0;

  CDir := UpperCase(CDir);
  CDirSize := length(CDir);

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
var Offset,Size: int64;
    DataX,DataY: integer;
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
begin

 try
  if (CurrentDriver <> -1) and Drivers[CurrentDriver].GetDriver.ExtractInternal then
  begin
    if @Drivers[CurrentDriver].ExtractFile <> Nil then
    begin
      Drivers[CurrentDriver].ExtractFile(outfile,entrynam,offset,size,datax,datay,silent);
    end
    else
      ShowMessage('Missing ExtractFile() function in driver.');
  end
  else
  begin
    dst := FileCreate(outfile, (fmOpenWrite or fmShareDenyWrite));
    if dst > 0 then
    begin
      BinCopy(CurrentFile,dst,Offset,Size,0,16384,silent);
      FileClose(dst);
    end;
  end;
 except
  on E: Exception do MessageDlg(ReplaceValue('%e',ReplaceValue('%a',ReplaceValue('%d',DLNGstr('ERRDRV'),Drivers[CurrentDriver].FileName),Drivers[CurrentDriver].Info.Author),E.Message),mtWarning,[mbOk],0);
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
  CurrentFileSize := FileSeek(filHandle,0,2);
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
var ext,outp: String;
    testpos,posext,tmpi: integer;
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
var ext,outp,TDir: String;
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

function TDrivers.BrowseDirToList(cdir: string; subdirs: boolean): TList;
var a: FSE;
    TDir: string;
    TDirPos: integer;
    EntRec: PEntList;
begin

  if rightstr(cdir,1) = sch then
    cdir := leftstr(cdir,length(cdir)-1);

  Result := TList.Create;

  CDir := UpperCase(CDir);

  a := DataBloc;

  while a <> NIL do
  begin

    if sch = '' then
    begin
      TDir := '';
    end
    else
    begin
      if subdirs then
      begin
        if cdir = '' then
          TDirPos := 0
        else
          TDirPos := posex(sch,a^.Name,Length(cdir));
      end
      else
        TDirPos := posrev(sch, a^.Name);
      if TDirPos >0 then
        TDir := Uppercase(Copy(a^.Name,1,TDirPos-1))
      else
        TDir := '';
    end;

    if TDir = CDir then
    begin
      New(EntRec);
      EntRec^.FileName := a^.Name;
      EntRec^.Offset := a^.Offset;
      EntRec^.Size := a^.Size;
      EntRec^.DataX := a^.DataX;
      EntRec^.DataY := a^.DataY;
      Result.Add(EntRec);
    end;

    a := a^.suiv;

  end;

end;

function TDrivers.getIndexData(n: integer): virtualIndexData;
begin

//  if (n < getListNum) and (n >= 0) then
//     result := listData[n];

end;

procedure TDrivers.showAboutBox(hwnd, drvnum: integer);
begin

  if (Drivers[drvnum].DUDIVersion = 1) then
  begin
    Drivers[drvnum].ShowAboutBox(hwnd,language);
  end
  else if (Drivers[drvnum].DUDIVersion = 2) then
  begin
    Drivers[drvnum].ShowAboutBox2(hwnd);
  end
  else if (Drivers[drvnum].DUDIVersion = 3) then
  begin
    Drivers[drvnum].ShowAboutBox3;
  end;

end;

procedure TDrivers.showConfigBox(hwnd, drvnum: integer);
begin

  if (Drivers[drvnum].DUDIVersion = 1) then
  begin
    Drivers[drvnum].ShowConfigBox(Application.Handle,language);
  end
  else if (Drivers[drvnum].DUDIVersion = 2) then
  begin
    Drivers[drvnum].ShowConfigBox2(Application.Handle);
  end
  else if (Drivers[drvnum].DUDIVersion = 3) then
  begin
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

end.
