library drv_giants;

// $Id: drv_giants.dpr,v 1.1.1.1 2004-05-08 10:26:53 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/drivers/giants/drv_giants.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is drv_giants.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

uses
  SysUtils,
  Windows,
  lib_version in '..\..\..\common\lib_version.pas';

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

const DRIVER_VERSION = 10140;
      DUP_VERSION = 50040;

var DataBloc: FSE;
    FHandle: Integer = 0;
    CurFormat: Integer = 0;
    DrvInfo: CurrentDriverInfo;
    ErrInfo: ErrorInfo;
    SetPercent: TPercentCallBack;

function DUDIVersion: Byte; stdcall;
begin
  DUDIVersion := 1;
end;

function GetNumVersion: Integer; stdcall;
begin

  GetNumVersion := DRIVER_VERSION;

end;

function GetDriverInfo: DriverInfo; stdcall;
begin

  GetDriverInfo.Name := 'Nullpointer''s Giants GZP Driver';
  GetDriverInfo.Author := 'Alexandre Devilliers (aka Elbereth)';
  GetDriverInfo.Version := getVersion(DRIVER_VERSION);
  GetDriverInfo.Comment := 'Read/Extract from Giants: Citizen Kabuto GZP files. Decompression code by Thilo Girmann (NullPointer).';
  GetDriverInfo.NumFormats := 1;
  GetDriverInfo.Formats[1].Extensions := '*.gzp';
  GetDriverInfo.Formats[1].Name := 'Giants: Citizen Kabuto (*.GZP)';

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

type GZPEntry = record
    size : integer;
    size_uncmp :integer;
    datetime :integer;    // can be ignored
    start :integer;       // start position of block
    compr :byte;          // 1: compressed, 2: not compressed
    namelength :byte;
   end;
   GZPHeader = record
    ID : integer;   // &H6608F101
    Offset : integer;
    Unknown1 : integer;
    Unknown2 : integer;
    Unknown3 : integer;
    Unknown4 : integer;
   end;

function Get8v(src: integer; size: byte): string;
var tchar: array[0..255] of Char;
    res: string;
begin

  FillChar(tchar,256,0);
  FileRead(src,tchar,size);

  res := tchar;
  Get8v := Copy(res,1,size);

end;

function ReadGiantsGZP(src: string): Integer;
var HDR: GZPHeader;
    ENT: GZPEntry;
    Name: string;
    NumE, x, Per, PerOld: integer;
begin

  FHandle := FileOpen(src, fmOpenRead);

  if FHandle > 0 then
  begin
    FileSeek(FHandle, 0, 0);
    FileRead(FHandle, HDR, SizeOf(HDR));

    if HDR.ID <> $6608F101 then
    begin
      FileClose(FHandle);
      FHandle := 0;
      ReadGiantsGZP := -3;
      ErrInfo.Format := 'GZP';
      ErrInfo.Games := 'Giants: Citizen Kabuto';
    end
    else
    begin

      FileSeek(FHandle, HDR.Offset+4, 0);
      FileRead(FHandle, NumE,4);

      PerOld := 0;

      for x:= 1 to NumE do
      begin

        Per := Round((x / NumE)*100);
        if Per >= PerOld + 5 then
        begin
          SetPercent(Per);
          PerOld := Per;
        end;
        
        FileRead(FHandle, ENT, 18);
        Name := Strip0(Get8v(FHandle,ENT.namelength));

        FSE_add(Name,ENT.start+16,ENT.size_uncmp,ENT.size,ENT.compr);

      end;

      ReadGiantsGZP := NumE;

      DrvInfo.ID := 'GZP';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end;
  end
  else
    ReadGiantsGZP := -2;

end;

function ReadFormat(fil: ShortString; percent: TPercentCallback; Deeper: boolean): Integer; stdcall;
var ext: string;
begin

  @SetPercent := @Percent;
  SetPercent(0);
  ext := ExtractFileExt(fil);

  if ext <> '' then
    ext := copy(ext,2,length(ext)-1);

  ext := UpperCase(ext);

  if IsConsole then
    writeln('ReadFormat: '+fil+' ('+ext+')');

  if ext = 'GZP' then
    ReadFormat := ReadGiantsGZP(fil)
  else
    ReadFormat := -1;

end;

function IsFormat(fil: ShortString; Deeper: Boolean): Boolean; stdcall;
var ext: string;
begin

  ext := ExtractFileExt(fil);

  if ext <> '' then
    ext := copy(ext,2,length(ext)-1);

  ext := UpperCase(ext);

  if ext = 'GZP' then
    IsFormat := True
  else
    IsFormat := False;

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

function DecompressGZP(buf :PByteArray; start,len,finalsize:longint):PByteArray;
var
  i,j,vbufstart,decbits,decpos,declen :longint;
  decbyte :byte;
  res: PByteArray;
begin

  GetMem(res,finalsize);

  i := 0;
  j := 0;
  vbufstart := $FEE;
  decbits := 8;
  decbyte := 0;

  while j<finalsize do begin
    if decbits=8 then begin
      decbyte := buf^[i];
      inc(i);
      decbits := 0;
    end;
    if (decbyte shr decbits) and 1=0 then begin
      decpos := (buf^[i]+longint(buf^[i+1]) and $F0 shl 4-vbufstart-j) and $FFF-$1000+j;
      declen := buf^[i+1] and $F+3;
      inc(i,2);
      while declen>0 do begin
        if decpos>=0 then
          res^[j] := res^[decpos]
        else
          res^[j] := 32;
        inc(j);
        inc(decpos);
        dec(declen)
      end
    end
    else begin
      res^[j] := buf^[i];
      inc(i);
      inc(j);
    end;
    inc(decbits);
  end;

  DecompressGZP := res;

end;

function ExtractFile(outputfile: shortstring; entrynam: shortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; silent: boolean): boolean; stdcall;
var Buf: PByteArray;
    BufEnd: PByteArray;
    fil: Integer;
begin

  fil := FileCreate(outputfile,fmOpenRead or fmShareExclusive);

  FileSeek(FHandle,Offset,0);

  if (DataY = 1) then
  begin
    GetMem(Buf,DataX);
    FileRead(FHandle,Buf^,DataX);
    BufEnd := DecompressGZP(Buf,Offset,DataX,Size);
    FileWrite(fil,BufEnd^,Size);
  end
  else
  begin
    GetMem(Buf,DataX);
    FileRead(FHandle,Buf^,DataX);
    FileWrite(fil,Buf^,DataX);
  end;

  FreeMem(Buf);
  FileClose(fil);

  ExtractFile := true;

end;

function GetErrorInfo(): ErrorInfo; stdcall;
begin

  GetErrorInfo := ErrInfo;

end;


procedure AboutBox(hwnd: Integer; DLNGstr: TLanguageCallBack); stdcall;
begin

  MessageBoxA(hwnd, PChar('Nullpointer''s Giants GZP Driver v'+getVersion(DRIVER_VERSION)+#10+
                          '(c)Copyright 2002-2003 Alexandre Devilliers'+#10+#10+
                          'Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+#10+#10+
                          'Decompression code based on infos by:'+#10+
                          'Thilo Girmann (Nullpointer)')
                        , 'About Nullpointer''s Giants: Citizen Kabuto Driver...', MB_OK);

end;

exports
  DUDIVersion,
  ReadFormat,
  CloseFormat,
  GetEntry,
  GetDriverInfo,
  GetCurrentDriverInfo,
  GetNumVersion,
  ExtractFile,
  GetErrorInfo,
  AboutBox,
  IsFormat;

begin
end.
