library drv_multiex;

// $Id: drv_multiex.dpr,v 1.1.1.1 2004-05-08 10:26:54 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/drivers/multiex/drv_multiex.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is drv_multiex.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// To create multiex_TLB.pas file, use import ActiveX function on the MultiEx.DLL.

uses
  Classes,
  Windows,
  IniFiles,
//  Dialogs,
  SysUtils,
  Zlib,
  lib_version in '..\..\common\lib_version.pas',
  multiex_TLB in 'F:\Program Files\Developpement\Delphi7\Imports\multiex_TLB.pas';

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
   BMSInfo = record
     ext: string;
     games: string;
     id: string;
   end;
   TPercentCallback = procedure (p: byte);
   TLanguageCallback = function (lngid: ShortString): ShortString;

   MEX_Header = packed record
     NumberOfFiles : LongWord;
     Mex3ComType : LongWord;      // Compressiontype of the files in the archive (if any)
                                  //        99  = none
                                  //			  750 = ZLibCompression1
     Mex3ImpType : LongWord;      // Importationtype that lets you know:
                                  //			  iStandard = 710
                                  //			  (both fileoffsets and filesizes are mentioned in the
                                  //			   archive)
                                  //			  iSFileOff = 711
                                  //		           (only fileoffsets are mentioned)
                                  //			  iSFileSize = 712
                                  //		           (only filesizes are mentioned)
                                  //			  iNone = 713
                                  // 			  (for MultiEx Commander : no importing allowed)
                                  //			  iStandardTail = 714
                                  //			  (Standard but with a tailpointer at the beginning)
     TailOffOffYes: Byte;         // Is there an offset of a pointer to a tail?
                                  //			  0 = No
                                  //			  1 = Yes
     TailOffOff: LongWord;        // The location of the offset of a pointer to a tail
                                  //			  in the archive.
     FileOffs_Rev: Byte;          // The (long) variables depicting the Offsets of
                                  //			  the different files in the archive are reversed in saved
                                  //			  format. So An offset of 12cd3400 would be written in the
                                  //			  archive as 00 34 cd 12. Low Byte->High Byte switched!
                                  //			  0 = No
                                  //			  1 = Yes
     FileSizes_Rev: Byte;         // Like above, now for the size variables for each file
                                  //			  in the archive
   end;

{ ////////////////////////////////////////////////////////////////////////////
  Driver History:
  Version   DUP5 Description
    10001  50022 First version ever! This is driver use DUDI v2!!!
                 REQUIRES Dragon UnPACKer v5.0.0 RC2-WIP4 or earlier!!
    10002  50022 Initialisation is now in InitPlugin
                 Fixed a bug when / or \ at start of file entries
                 Changed AboutBox to reflect request by MultiEx author
                 Cleaned up the code
  //////////////////////////////////////////////////////////////////////////// }

const DRIVER_VERSION = 10002;
      DUP_VERSION = 50022;

      BUFFER_SIZE = 4096;

var DataBloc: FSE;
    DrvInfo: CurrentDriverInfo;
    ErrInfo: ErrorInfo;
    MExObj: AMex3GetFileInfoClass;
    DLNGstr: TLanguageCallBack;
    SetPercent: TPercentCallback;
    CurPath: String;
    BMSList: TStringList;
    BMSInfoList: array of BMSInfo;

function DUDIVersion: Byte; stdcall;
begin
  DUDIVersion := 2;
end;

function GetNumVersion: Integer; stdcall;
begin

  GetNumVersion := DRIVER_VERSION;

end;

function GetDriverInfo: DriverInfo; stdcall;
var x,cdrv: integer;
begin

  GetDriverInfo.Name := 'Mr.Mouse''s MultiEx wrapper';
  GetDriverInfo.Author := 'Alexandre Devilliers (aka Elbereth)';
  GetDriverInfo.Version := getVersion(DRIVER_VERSION);
  GetDriverInfo.Comment := 'Wrapper to the MultiEX ActiveX DLL.';
  cdrv := 0;
  for x := 0 to BMSList.Count -1 do
  begin
    if (BMSInfoList[x].ext <> '') and (BMSInfoList[x].games <> '') then
    begin
      inc(cdrv);
      GetDriverInfo.Formats[cdrv].Extensions := BMSInfoList[x].ext;
      GetDriverInfo.Formats[cdrv].Name := BMSInfoList[x].games;
    end;
  end;
  GetDriverInfo.NumFormats := cdrv;

end;

function GetLongVB(src: integer): longword;
var tlongword: LongWord;
begin

  FileSeek(src,2,1);
  FileRead(src,tlongword,4);
  result := tlongword;

end;

function GetStringVB(src: integer): string;
var tchar: Pchar;
    tword: Word;
    res: string;
begin

  FileRead(src,tword,2);
  FileRead(src,tword,2);
  GetMem(tchar,tword);
  FillChar(tchar^,tword,0);
  FileRead(src,tchar^,tword);

  res := tchar;
  result := Copy(res,1,tword);

  FreeMem(tchar);

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

function parseMultiExLST: integer;
var hMEX: integer;
    HDR: MEX_Header;
    x: integer;
    filename: string;
    offset, osize,size: integer;
begin

  result := -1;
  
  hMEX := fileopen(curPath+'drv_multiex.lst',fmOpenRead);
  if (hMEX = -1) then
  begin
    result := -1;
  end
  else
  begin
   try
    fileread(hMEX,HDR,SizeOf(MEX_Header));
    DrvInfo.ExtractInternal := HDR.Mex3ComType = 750;
    DrvInfo.Sch := '';
    for x := 1 to HDR.NumberOfFiles do
    begin
      filename := getStringVB(hMEX);
      offset := getLongVB(hMEX);
      size := getLongVB(hMEX);
      FileSeek(hMEX,12,1);
      if (HDR.Mex3ComType <> 99) then
        osize := getLongVB(hMEX)
      else
        osize := size;
      if (DrvInfo.Sch = '') and (pos('\',filename) > 0) then
        DrvInfo.Sch := '\'
      else if (DrvInfo.Sch = '') and (pos('/',filename) > 0) then
        DrvInfo.Sch := '/';
      if (filename[1] = '\') or (filename[1] = '/') then
        filename := copy(filename,2,length(filename)-1);

      FSE_Add(filename,offset,osize,HDR.Mex3ComType,size);
      result := HDR.NumberOfFiles;
    end;
   finally
    FileClose(hMEX);
   end;
  end;

end;

procedure refreshBMSList();
var sr: TSearchRec;
    reg: TMemIniFile;
    x: integer;
begin

  BMSList.Clear;
  if FindFirst(CurPath+'MultiEX\*.BMS', faAnyFile, sr) = 0 then
  begin
    repeat
      if not((sr.Attr and faDirectory) = faDirectory) then
      begin
        BMSList.Add(sr.Name);
      end
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  setLength(BMSInfoList,BMSList.Count);

  reg := TMemIniFile.Create(CurPath+'drv_multiex.ini');
  try
    reg.CaseSensitive := false;
    for x := 0 to BMSList.Count-1 do
    begin
      BMSInfoList[x].ext := reg.ReadString(BMSList.Strings[x],'ext','');
      BMSInfoList[x].games := reg.ReadString(BMSList.Strings[x],'games','');
      BMSInfoList[x].id := reg.ReadString(BMSList.Strings[x],'id','MEX');
    end;
  finally
    reg.Free;
  end;

end;

// Convert a LFN to it's short version
// [IN] lfn - the LFN to be converted into a short filename
// Returns - the short filename
function SDUConvertLFNToSFN(lfn: string): string;
var
  sfn: string;
begin
  if not(FileExists(lfn)) and not(DirectoryExists(lfn)) then
    begin
    Result := '';
    exit;
    end;

  sfn := ExtractShortPathName(lfn);
  if sfn[2]=':' then
    begin
    sfn[1] := upcase(sfn[1]);
    end;
  Result := sfn;
end;


function ReadFormat(fil: ShortString; Deeper: boolean): Integer; stdcall;
var ext: string;
    x: integer;
    lstFile: string;
begin

  SetPercent(0);

  ext := ExtractFileExt(fil);

  if ext <> '' then
    ext := copy(ext,2,length(ext)-1);

  ext := UpperCase(ext);

  if IsConsole then
    writeln('ReadFormat: '+fil+' ('+ext+')');

  Result := 0;

  lstFile := SDUConvertLFNtoSFN(curpath)+'drv_multiex.lst';

    for x := 0 to BMSList.Count -1 do
    begin
      if (BMSInfoList[x].ext <> '') then
        if (pos(UpperCase(extractfileext(fil)),UpperCase(BMSInfoList[x].ext)) > 0) then
        begin
          MExObj.Mex3GetFileInfo(curpath+'MultiEx\'+BMSList.Strings[x],fil,'-lst '+lstFile);
          result := parseMultiExLST;
          DeleteFile(lstFile);
          if result > 0 then
          begin

            DrvInfo.ID := BMSINfoList[x].id;
            DrvInfo.FileHandle := FileOpen(fil,fmOpenRead);

            break;
          end;
        end;
    end;

end;

procedure CloseFormat; stdcall;
begin

  DrvInfo.Sch := '';
  DrvInfo.ID := '';

  if DrvInfo.FileHandle <> 0 then
    FileClose(DrvInfo.FileHandle);

  DrvInfo.FileHandle := 0;

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

  for x := 0 to BMSList.Count -1 do
  begin
    if (BMSInfoList[x].ext <> '') then
      if (pos(UpperCase(extractfileext(fil)),UpperCase(BMSInfoList[x].ext)) > 0) then
      begin
        MExObj.Mex3GetFileInfo(curpath+'MultiEx\'+BMSList.Strings[x],fil,'-lst '+lstFile);
        result := parseMultiExLST;
        DeleteFile(lstFile);
        if result > 0 then
        begin

          DrvInfo.ID := BMSINfoList[x].id;
          DrvInfo.FileHandle := FileOpen(fil,fmOpenRead);

          break;
        end;
      end;
  end;

{  if Deeper then
    IsFormat := IsFormatSMART(fil) or (ext = 'POD') or (ext = 'PAK') or (ext = 'TLK') or (ext = 'SDT') or (ext = 'RFH') or (ext = 'MTF') or (ext = 'BKF') or (ext = 'DAT') or (ext = 'PBO') or (ext = 'AWF') or (ext = 'SND') or (ext = 'ART') or (ext = 'SNI') or (ext = 'DIR') or (ext = 'IMG') or (ext = 'BAR') or (ext = 'BAG') or (ext = 'SQH') or (ext = 'GL')
  else
    if ext = 'WAD' then  }
      IsFormat := True;

end;

procedure AboutBox(hwnd: Integer); stdcall;
begin

  MessageBoxA(hwnd, PChar('Mr.Mouse''s MultiEx DLL wrapper v'+getVersion(DRIVER_VERSION)+#10+
                          '(c)Copyright 2003 Alexandre Devilliers'+#10+#10+
                          'Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+#10+#10+
                          'MultiEx.DLL (C) 2003 XeNTaX'+#10+
                          'You can get MultiEx Commander'+#10+'and everything you need to make BMS scripts from:'+#10+
                          'http://www.xentax.com'
                          )
                        , 'About Mr.Mouse''s MultiEx DLL wrapper...', MB_OK);

end;

procedure InitPlugin(per: TPercentCallback; lngid: TLanguageCallback; DUP5Path: ShortString); stdcall;
begin

  SetPercent := per;
  DLNGStr := lngid;
  CurPath := DUP5Path;

  MexObj := CoAMex3GetFileInfoClass.Create;
  BMSList := TStringList.Create;
  refreshBMSList;

end;

procedure BinCopy(src : integer; dst : integer; soff : Int64; ssize : Int64; bufsize : Integer);
var
  //sFileLength: Integer;
  Buffer: PChar;
  i,numbuf, restbuf: Integer;
  per, oldper, perstep: word;
  real1, real2: real;
begin

  //sFileLength := FileSeek(src,0,2);
  FileSeek(src,soff,0);
  numbuf := ssize div bufsize;
  if (numbuf > 25000) then
    perstep := 2
  else if (numbuf > 12500) then
    perstep := 5
  else if (numbuf > 6000) then
    perstep := 10
  else
    perstep := 15;
  restbuf := ssize mod bufsize;

GetMem(Buffer,bufsize);
try
  oldper := 0;

  for i := 1 to numbuf do
  begin
    FileRead(src, Buffer^, bufsize);
    FileWrite(dst, Buffer^, bufsize);
    real1 := i;
    real2 := numbuf;
    real1 := (real1 / real2)*100;
    per := Round(real1);
    if per >= oldper + perstep then
    begin
      oldper := per;
      SetPercent(per);
    end;
  end;

  SetPercent(100);

  FileRead(src, Buffer^, restbuf);
  FileWrite(dst, Buffer^, restbuf);

finally
  FreeMem(Buffer);
end;

end;

function DecompressZlib(fil: integer; Size:  Int64; OSize: Int64) : Boolean;
var
  Buf: PChar;
  InputStream: TMemoryStream;
  OutputStream: THandleStream;
  DStream: TDecompressionStream;
  FinalSize: integer;
begin

  GetMem(Buf,Size);
  try
    FileRead(DrvInfo.FileHandle,Buf^,Size);

    InputStream := TMemoryStream.Create;
    OutputStream := THandleStream.Create(fil);
    try
      InputStream.Write(Buf^,Size);
      InputStream.Seek(0, soFromBeginning);

      DStream := TDecompressionStream.Create(InputStream);
      try
        FinalSize := OutputStream.CopyFrom(DStream,OSize);
      finally
        DStream.Free;
      end

    finally
      InputStream.Free;
      OutputStream.Free;
    end
  finally
    FreeMem(Buf);
  end;

  Result := FinalSize = OSize;

End;

function ExtractFile(outputfile: ShortString; entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: boolean): boolean; stdcall;
var fil: Integer;
begin

  fil := FileCreate(outputfile,fmOpenRead or fmShareExclusive);

  FileSeek(DrvInfo.FileHandle,Offset,0);

  if (DataX = 750) then
  begin
    DecompressZlib(fil, DataY, Size);
  end
  else
  begin
    BinCopy(DrvInfo.FileHandle,fil,offset,Size,BUFFER_SIZE);
  end;

  FileClose(fil);

  ExtractFile := true;

end;

exports
  DUDIVersion,
  ExtractFile,
  ReadFormat,
  CloseFormat,
  GetEntry,
  GetDriverInfo,
  GetNumVersion,
  GetCurrentDriverInfo,
  GetErrorInfo,
  AboutBox,
  InitPlugin,
  IsFormat;

begin

end.
