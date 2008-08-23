library drv_11th;

// $Id: drv_11th.dpr,v 1.1.1.1 2004-05-08 10:26:52 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/drivers/11th/drv_11th.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is drv_11th.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

uses
  Dialogs,
  Controls,
  Registry,
  Classes,
  StrUtils,
  Windows,
  SysUtils,
  Forms,
  lib_version in '..\..\..\common\lib_version.pas',
  WindowsEx in 'WindowsEx.pas',
  The11thHour in 'The11thHour.pas' {frm11thHour};

{$E d5d}

{$R *.res}

type FSE = ^element;
     element = record
        Name : String;
        Size : Int64;
        Offset : Int64;
        DataX : integer;
        DataY : integer;
        suiv : FSE;
     end;
     TInts = ^TInt;
     TInt = record
        Value : Integer;
        suiv : TInts;
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
   TPercentCallback = procedure (p: byte);
   TLanguageCallback = function (lngid: ShortString): ShortString;

type EDup5PathNotFound = class(Exception);
     EPluginNotActivated = class(Exception);

{ ////////////////////////////////////////////////////////////////////////////
  Driver History:
  Version   DUP5 Description
    10000  50021 First version ever
    10011  50023 Changed to DUDI v3.
                 Added config box
    10012  50023 Dynamic translation added

  //////////////////////////////////////////////////////////////////////////// }

const DRIVER_VERSION = 10012;
      DUP_VERSION = 50023;

      BUFFER_SIZE = 4096;

type GJD_Entry = packed record         // 32 Bytes
    Unknown: integer;
    Offset: longword;
    Size: longword;
    Index: word;
    Filename: array[1..18] of char;
  end;

type GJD_Entry_7 = packed record       // 20 Bytes
    Filename: array[1..12] of char;
    Offset: longword;
    Size: longword;
  end;

var DataBloc: FSE;
    FHandle: Integer = 0;
    DrvInfo: CurrentDriverInfo;
    ErrInfo: ErrorInfo;
    SetPercent: TPercentCallback;
    DLNGStr: TLanguageCallback;
    CurPath: string;
    isInitiated: boolean = false;
    AHandle : THandle;
    AOwner : TComponent;

function DUDIVersion: Byte; stdcall;
begin
  DUDIVersion := 3;
end;

function GetNumVersion: Integer; stdcall;
begin

  GetNumVersion := DRIVER_VERSION;

end;

function GetDriverInfo: DriverInfo; stdcall;
begin

  GetDriverInfo.Name := 'Elbereth''s 11th Hour Driver';
  GetDriverInfo.Author := 'Alexandre Devilliers (aka Elbereth)';
  GetDriverInfo.Version := getVersion(DRIVER_VERSION);
  GetDriverInfo.Comment := 'The 11th Hour GJD files support.';
  GetDriverInfo.NumFormats := 1;
  GetDriverInfo.Formats[1].Extensions := '*.gjd';
  GetDriverInfo.Formats[1].Name := '11th Hour (*.GJD)';

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

procedure FSE_add(Name: String; Offset, Size: Int64; DataX, DataY: integer);
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

function getIndexNumberFromFileName(fil:string): integer;
var T: TextFile;
    Line: string;
    infil, outfil: string;
begin

  outfil := lowercase(ExtractFilename(fil));

  FileMode := fmOpenRead;
  Assign(T,curpath+'drv_11th.idx');
  Reset(T);
  result := -1;
  while not(Eof(T)) and (result = -1) do
  begin
    ReadLn(T,Line);
    infil := copy(Line,0,pos(' ',Line)-1);
    if (infil = outfil) then
    begin
      result := strtoint(copy(line,pos(' ',Line),length(Line)));
    end;
  end;
  CloseFile(T);

end;

function Read11thHourGJD(src: string): Integer;
var NumE, infil: integer;
    hLST: integer;
    x, totsize, totent: integer;
    ENT: GJD_Entry;
begin

  FHandle := FileOpen(src,fmOpenRead);

  if FHandle > 0 then
  begin

    hLST := FileOpen(CurPath+'drv_11th.lst',fmOpenRead);
    try
      totsize := FileSeek(hLST,0,2);
      totent := totsize div 32;
      FileSeek(hLST,0,0);

      NumE := 0;
      infil := GetIndexNumberFromFilename(src);

      for x := 1 to totent do
      begin
        FileRead(hLST,ENT,32);
        if (ENT.Index = infil) then
        begin
          Inc(NumE);
          FSE_Add(Strip0(ENT.Filename),ENT.Offset,ENT.Size,ENT.Unknown,0);
        end;
        SetPercent(round((x / totent)*100));
      end;
    finally
      if hLST > 0 then FileClose(hLST);
    end;

    DrvInfo.ID := '11TH';
    DrvInfo.Sch := '';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

    result := NumE;

  end
  else
    Result := -2;

end;

function Read7thGuestGJD(src: string): Integer;
var NumE, infil: integer;
    hLST: integer;
    x, totsize, totent: integer;
    ENT: GJD_Entry;
begin

  FHandle := FileOpen(src,fmOpenRead);

  if FHandle > 0 then
  begin

    hLST := FileOpen(CurPath+'drv_11th.lst',fmOpenRead);
    try
      totsize := FileSeek(hLST,0,2);
      totent := totsize div 32;
      FileSeek(hLST,0,0);

      NumE := 0;
      infil := GetIndexNumberFromFilename(src);

      for x := 1 to totent do
      begin
        FileRead(hLST,ENT,32);
        if (ENT.Index = infil) then
        begin
          Inc(NumE);
          FSE_Add(Strip0(ENT.Filename),ENT.Offset,ENT.Size,ENT.Unknown,0);
        end;
        SetPercent(round((x / totent)*100));
      end;
    finally
      if hLST > 0 then FileClose(hLST);
    end;

    DrvInfo.ID := '11TH';
    DrvInfo.Sch := '';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

    result := NumE;

  end
  else
    Result := -2;

end;

function ReplaceValue(substr: string; str: string; newval: string): string;
var possub: integer;
    res: string;
begin

  possub := Pos(substr,str);
  if possub > 0 then
  begin
    res := Copy(str,0,possub-1) + Copy(str,possub+length(substr),length(str)-length(substr)+1);
    Insert(newval,res,possub);
  end
  else
    res := str;

  ReplaceValue := res;

end;

function activate11th(verbose: boolean): boolean;
var diag: TOpenDialog;
//    OpenFile: TFile;
    lReturn: integer;
    buf: PChar;
    filter: PChar;
begin

  result := false;

  if (MessageDlg(DLNGStr('11TH01'),mtInformation,mbOkCancel,0) = mrOk) then
  begin
    diag := TOpenDialog.Create(AOwner);
    diag.Filter := 'The 11th Hour GJD.GJD|gjd.gjd';
    diag.Title := ReplaceValue('%f',DLNGStr('11TH02'),'GJD.GJD');
    if (diag.Execute) then
    begin
      CopyFile(PChar(diag.Files.Strings[0]),PChar(CurPath+'drv_11th.idx'),false);
      if (FileExists(ExtractFilePath(Diag.Files.Strings[0])+'dir.rl')) then
      begin
        CopyFile(PChar(ExtractFilePath(Diag.Files.Strings[0])+'dir.rl'),PChar(CurPath+'drv_11th.lst'),false);
        result := true;
      end
      else
      begin
        diag.Filter := 'The 11th Hour DIR.RL|dir.rl';
        diag.Title := ReplaceValue('%f',DLNGStr('11TH02'),'DIR.RL');
        if (diag.Execute) then
        begin
          CopyFile(PChar(diag.Files.Strings[0]),PChar(CurPath+'drv_11th.lst'),false);
          result := true;
        end;
      end;

      if result then
        MessageDlg(DLNGStr('11TH03'),mtInformation,[mbOk],0)
    end;

  {    FillChar(OpenFile,SizeOf(OPENFILE),0);
    OpenFile.lStructSize := SizeOf(OPENFILE);
    OpenFile.hwndOwner := hWnd;
    OpenFile.lpstrFilter := 'The 11th Hour (GJD.GJD)'+#0+'gjd.gjd'+#0+#0;
    OpenFile.nFilterIndex := 1;
    getmem(buf,MAX_PATH+1);
    FillChar(buf,MAX_PATH+1,0);
    OpenFile.lpstrFile := buf;
    OpenFile.nMaxFile := MAX_PATH;
    OpenFile.lpstrTitle := 'Select the GJD.GJD file from 11th Hour...'+#10;
    OpenFile.flags := 0;
    lReturn := GetOpenFileName(@OpenFile);
    ShowMessage(inttostr(lReturn));}
  end;

end;

function deactivate11th(verbose: boolean): boolean;
var //diag: TOpenDialog;
//    OpenFile: TFile;
    lReturn: integer;
    buf: PChar;
    filter: PChar;
    Attrs: integer;
begin

  result := false;

  if (MessageDlg(ReplaceValue('%b',ReplaceValue('%a',DLNGStr('11TH04'),curpath+'drv_11th.idx'),curpath+'drv_11th.lst'),mtWarning,mbOkCancel,0) = mrOk) then
  begin
    Attrs := FileGetAttr(curPath+'drv_11th.idx');
    if Attrs and faReadOnly <> 0 then
      FileSetAttr(curPath+'drv_11th.idx', Attrs-faReadOnly);
    Attrs := FileGetAttr(curPath+'drv_11th.lst');
    if Attrs and faReadOnly <> 0 then
      FileSetAttr(curPath+'drv_11th.lst', Attrs-faReadOnly);
    result := DeleteFile(curPath+'drv_11th.idx');
    result := DeleteFile(curPath+'drv_11th.lst') or result;
  end;

end;

function ReadFormat(fil: ShortString; Deeper: boolean): Integer; stdcall;
var ext: string;
    diag: TOpenDialog;
begin

  SetPercent(0);

  ext := ExtractFileExt(fil);

  if ext <> '' then
    ext := copy(ext,2,length(ext)-1);

  ext := UpperCase(ext);

  if IsConsole then
    writeln('ReadFormat: '+fil+' ('+ext+')');

  if (ext = 'GJD') then
  begin
    if (FileExists(CurPath+'drv_11th.idx') and FileExists(CurPath+'drv_11th.lst')) then
    begin
      result := Read11thHourGJD(fil);
    end
    else
    begin
      if activate11th(true) then
        result := Read11thHourGJD(fil)
      else
        result := -1;
    end;
  end
  else
    Result := -1;


end;

procedure CloseFormat; stdcall;
begin

  DrvInfo.Sch := '';
  DrvInfo.ID := '';
  DrvInfo.FileHandle := 0;

  if FHandle <> 0 then
    FileClose(FHandle);

  FHandle := 0;

end;

type
  FormatEntry = record
    FileName: ShortString;
    Offset, Size: Int64;
    DataX, DataY: Integer;
  end;

function GetEntry(): FormatEntry; stdcall;
var a: FSE;
begin

  if DataBloc <> NIL then
  begin
    a := DataBloc;
    DataBloc := DataBloc^.suiv;
    GetEntry.FileName := a^.Name;
    GetEntry.Offset := a^.Offset;
    GetEntry.Size := a^.Size;
    GetEntry.DataX := a^.DataX;
    GetEntry.DataY := a^.DataY;
    Dispose(a);
  end
  else
  begin
    GetEntry.FileName := '';
    GetEntry.Offset := 0;
    GetEntry.Size := 0;
    GetEntry.DataX := 0;
    GetEntry.DataY := 0;
  end;

end;

function GetCurrentDriverInfo(): CurrentDriverInfo; stdcall;
begin

  GetCurrentDriverInfo := DrvInfo;

end;

function GetErrorInfo(): ErrorInfo; stdcall;
begin

  GetErrorInfo := ErrInfo;

end;

function IsFormat(fil: ShortString; Deeper: Boolean): Boolean; stdcall;
var ext: string;
begin

  ext := ExtractFileExt(fil);

  if ext <> '' then
    ext := copy(ext,2,length(ext)-1);

  ext := UpperCase(ext);

  IsFormat := (ext = 'GJD');

end;

function getCurrentStatus(): boolean;
begin

  result := (FileExists(CurPath+'drv_11th.lst') and FileExists(CurPath+'drv_11th.idx'));

end;

procedure AboutBox; stdcall;
var status: string;
    OldH: THandle;
begin

//  activate11th(true);

  if getCurrentStatus then
    status := DLNGStr('11TH07')
  else
    status := DLNGStr('11TH06');

  OldH := Application.Handle;
  Application.Handle := AHandle;
  MessageDlg('Elbereth''s 11th Hour Driver v'+getVersion(DRIVER_VERSION)+#10+
             '(c)Copyright 2003 Alexandre Devilliers'+#10+#10+
             'Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+#10+#10+
             ReplaceValue('%s',DLNGStr('11TH05'),status)
             ,mtInformation,[mbOk],0);
  Application.Handle := OldH;

end;

procedure ConfigBox; stdcall;
var status: boolean;
    OldH: THandle;
    frmCfg: Tfrm11thHour;
begin

  status := getCurrentStatus;

  OldH := Application.Handle;
  Application.Handle := AHandle;

  frmCfg := Tfrm11thHour.Create(AOwner);
  try
    with frmCfg do
    begin
      if status then
      begin
        lblStatus.Caption := DLNGStr('11TH07');
        cmdEnable.Enabled := false;
      end
      else
      begin
        lblStatus.Caption := DLNGStr('11TH06');
        cmdDisable.Enabled := false;
      end;
      lblVersion.Caption := GetVersion(DRIVER_VERSION);
      Caption := DLNGStr('11TH10');
      strStatus.Caption := DLNGStr('11TH13');
      cmdEnable.Caption := DLNGStr('11TH11');
      cmdDisable.Caption := DLNGStr('11TH12');
      grp11th.Caption := DLNGStr('11TH14');
      enableSupport := @activate11th;
      disableSupport := @deactivate11th;
      stEnabled := DLNGStr('11TH07');
      stDisabled := DLNGStr('11TH07');
      ShowModal;
    end;
  finally
    frmCfg.Free;
  end;


{  if (status = 'Disabled') then
  begin


  end
  else if (status = 'Enabled') then
  begin

    MessageDlg('Elbereth''s 11th Hour Driver v'+getVersion(DRIVER_VERSION)+#10+
               '(c)Copyright 2003 Alexandre Devilliers'+#10+#10+
               'Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+#10+#10+
               'Plugin status: '+status+#10+'(Enabled means you can open files)'+#10+'(Disabled means you need to import GJD.GJD and DIR.RL)'+#10+#10+
               'Limitations:'+#10+
               'Still extremely experimental and untranslated (english only).'
               ,mtInformation,[mbOk],0);

  end;}

  Application.Handle := OldH;

end;


procedure InitPlugin(per: TPercentCallback; lngid: TLanguageCallback; DUP5Path: ShortString; AppHandle: THandle; AppOwner: TComponent); stdcall;
begin

  SetPercent := per;
  DLNGStr := lngid;
  CurPath := DUP5Path;
  AHandle := AppHandle;
  AOwner := AppOwner;

end;

exports
  DUDIVersion,
  ReadFormat,
  CloseFormat,
  GetEntry,
  GetDriverInfo,
  GetNumVersion,
  GetCurrentDriverInfo,
  GetErrorInfo,
  AboutBox,
  ConfigBox,
  InitPlugin,
  IsFormat;

begin
end.
