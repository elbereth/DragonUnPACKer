unit lib_language;

// $Id: lib_language.pas,v 1.8 2008-04-16 21:01:29 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/common/lib_language.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is lib_language.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// Language (DLNG) Management Library
// =============================================================================
//
//  Functions:
//  function DLNGStr(sch: string): string;
//  function GetFont(): String;
//  function GetIcon(fil: string): TBitmap;
//  function GetLanguageInfo(fil: string; out Name, Author, URL, Email,
//                           FontName: String; out IsIcon: boolean): Boolean;
//  procedure LoadInternalLanguage();
//  procedure LoadLanguage(fil: string);
//  function ReplaceValue(substr: string; str: string; newval: string): string;
//
// -----------------------------------------------------------------------------

interface
uses Graphics, Zlib,lib_language_internal;

function GetIcon(fil: string): TBitmap;
function GetFont(): String;
function GetLanguageInfo(fil: string; out Name, Author, URL, Email, FontName: String; out IsIcon: boolean): Boolean;
procedure LoadLanguage(fil: string);
procedure LoadInternalLanguage();
function DLNGStr(sch: string): string;
function ReplaceValue(substr: string; str: string; newval: string): string;

var curlanguage : string = '';

implementation

uses SysUtils, forms,Dialogs,lib_zlib,lib_crc,spec_DLNG,Classes,lib_binutils;

type
   Internal_Tab = record
     ID: string;
     Value: WideString;
   end;

const DLNG_VERSION : byte = 4;
      DLNG_PRGVER : byte = 9;

var tabLNG: array[1..1000] of Internal_Tab;
    numLNG: integer = 0;
    UseInternalLanguage: Boolean = True;
    SelectedFontName: String;

procedure LoadLanguage(fil: string);
var HDR: DLNG_Header_v4;
    HDRX: DLNG_ExtendedHeader;
    lng,x: integer;
    Idx: array[1..1000] of DLNG_IndexEntry_v4;
    inpFileStm: THandleStream;
    dataStm: TMemoryStream;
    decompStm: TDecompressionStream;
begin

  if FileExists(fil) then
  begin
    lng := FileOpen(fil, (fmOpenRead or fmShareExclusive));
    try
      FileRead(lng,HDR,SizeOf(HDR));

      if HDR.ID <> 'DLNG'+chr(26) then
        MessageDlg('This is not a valid Dragon Software Language file.'+chr(10)+'Please remove this file:'+chr(10)+chr(10)+fil,mtWarning,[mbOk],0)
      else
        if HDR.Version <> DLNG_VERSION then
          MessageDlg('Unsupported version of Dragon Software Language file.'+chr(10)+chr(10)+'Needed: version 4'+chr(10)+'File: version '+IntToStr(HDR.Version),mtWarning,[mbok],0)
        else
          if HDR.PrgID <> 'UP' then
            MessageDlg('This Language file is not for Dragon UnPACKer.',mtWarning,[mbok],0)
          else
            if HDR.PrgVER <> DLNG_PRGVER then
              MessageDlg('This Language file is not for this version of Dragon UnPACKer.',mtWarning,[mbok],0)
            else
            begin

//  MessageDlg(HDR.ID,mtInformation,[mbOk],0);

              HDRX.Name := Get8u(lng);
              HDRX.Author := Get8u(lng);
              HDRX.URL := Get8u(lng);
              HDRX.Email := Get8u(lng);
              HDRX.FontName := Get8u(lng);
              SelectedFontName := HDRX.FontName;
//      messagedlg(HDRX.Name + chr(10) + HDRX.Author + chr(10) + HDRX.URL + chr(10) + HDRX.Email  ,mtInformation,[mbOk],0);

//      messagedlg(inttostr(HDR.BodySizeComp),mtInformation,[mbOk],0);

//      crc := getstrCrc32(HDRX.Name + HDRX.Author + HDRX.URL + HDRX.Email + BigStr);

//      MessageDlg(IntToStr(crc)+chr(10)+IntToStr(HDR.FileCRC),mtInformation,[mbok],0);

              dataStm := TMemoryStream.Create;
              try

                inpFileStm := THandleStream.Create(lng);
                try
                  inpFileStm.Seek(HDR.DataOffSet,soFromBeginning);

                  if HDR.Compression = 0 then
                  begin

                    dataStm.CopyFrom(inpFileStm, HDR.DataSize);

                  end
                  else if HDR.Compression = 99 then
                  begin

                    decompStm := TDecompressionStream.Create(inpFileStm);
                    dataStm.CopyFrom(decompStm,HDR.DataSize);
                    decompStm.Free;

                  end;

                  dataStm.Seek(0,soFromBeginning);

                finally
                  inpFileStm.Free;
                end;

                FileSeek(lng, HDR.IndexOffSet,0);

                numLNG := HDR.IndexNum;

                for x := 1 to HDR.IndexNum do
                begin
                  FillChar(Idx[x],SizeOf(DLNG_IndexEntry_v4),0);
                  FileRead(lng,Idx[x],SizeOf(DLNG_IndexEntry_v4));
                  tabLNG[x].ID := Idx[x].ID;
                  dataStm.Seek(Idx[x].Offset*2,soFromBeginning);
                  setLength(tabLNG[x].Value,Idx[x].Length);
                  dataStm.ReadBuffer(tabLNG[x].value[1],Idx[x].Length*2);
//                  ShowMessage(Idx[x].ID+' '+inttostr(Idx[x].Offset)+' '+inttostr(Idx[x].Length)+' '+tabLNG[x].value);
//                tabLNG[x].Value :=  Get16v(lng,);
//        if length(tabLNG[x].Value) > 100 then
                end;

              finally
                dataStm.Free;
              end;


//      messagedlg(bigstr,mtInformation,[mbOk],0);

              UseInternalLanguage := False;
              curlanguage := ExtractFileName(fil);

            end;

    finally
      FileClose(lng);
    end;
  end
  else
  begin
    MessageDlg('Warning the language file you where using before could not be found.'+chr(10)+chr(10)+'The program will continue in french.',mtWarning,[mbOk],0);
    LoadInternalLanguage;
  end;
end;

procedure LoadInternalLanguage();
begin

  CurLanguage := '*';
  UseInternalLanguage := True;
  SelectedFontName := '';

end;

function GetFont(): String;
begin

  result := SelectedFontname;

end;

function GetIcon(fil: string): TBitmap;
var icn: TBitmap;
    stm: TMemoryStream;
    res : boolean;
    lng : integer;
    HDR: DLNG_Header_v4;
    buffer: pchar;
begin

//  Randomize;
//  tmpfil := ExtractFilePath(Application.ExeName)+'data\tmp_dlng_icn'+ IntToStr(random(99999))+'.bmp';

  icn := TBitmap.Create;

//  if FileExists(tmpfil) then
//    DeleteFile(tmpfil);

  if FileExists(fil) then
  begin
    lng := FileOpen(fil, (fmOpenRead or fmShareExclusive));
    try
      FileRead(lng,HDR,SizeOf(HDR));

      res := (HDR.ID = 'DLNG'+chr(26)) and (HDR.Version = DLNG_VERSION) and (HDR.PrgID = 'UP') and (HDR.PrgVER = DLNG_PRGVER);

      if res then
      begin

        FileSeek(lng,HDR.ExtendedHeaderSize,1);
//        tmps := Get8u(lng);
//        tmps := Get8u(lng);
//        tmps := Get8u(lng);
//        tmps := Get8u(lng);
//        tmps := Get8u(lng);

        if HDR.IconSize > 0 then
        begin
          stm := TMemoryStream.Create;
          GetMem(buffer,HDR.IconSize);
          FileRead(lng,Buffer^,HDR.IconSize);
          stm.WriteBuffer(Buffer^, HDR.IconSize);
          stm.Seek(0,soFromBeginning);
          icn.LoadFromStream(stm);
          stm.Free;
          FreeMem(buffer);
        end;
      end;

    finally
      FileClose(lng);
    end;
  end;

  GetIcon := icn;

end;

function GetLanguageInfo(fil: string; out Name, Author, URL, Email, FontName: String; out IsIcon: boolean): Boolean;
var HDR: DLNG_Header_v4;
    lng: integer;
    res: boolean;
begin

  res := false;

  if FileExists(fil) then
  begin
    IsIcon := false;
    lng := FileOpen(fil, (fmOpenRead or fmShareExclusive));
    try
      FileRead(lng,HDR,SizeOf(HDR));

      res := (HDR.ID = 'DLNG'+chr(26)) and (HDR.Version = DLNG_VERSION) and (HDR.PrgID = 'UP') and (HDR.PrgVER = DLNG_PRGVER);

      if res then
      begin
        Name := Get8u(lng);
        Author := Get8u(lng);
        URL := Get8u(lng);
        Email := Get8u(lng);
        FontName := Get8u(lng);
        IsIcon := HDR.IconSize > 0;
      end;

    finally
      FileClose(lng);
    end;
  end;

  GetLanguageInfo := res;

end;

function PadRight(Data: string; PadWidth: integer) : string;
begin
   result := data;
   while length(result) < PadWidth do
      result := result + ' ';
end;

function DLNGStr(sch: string): string;
var res: string;
    x: integer;
begin

  res := '';

  if (length(sch) > 0) and (length(sch) < 7) then
  begin
    if UseInternalLanguage then
      res := DLNGInternalStr(sch)
    else
    begin
      sch := PadRight(sch,6);
      x := 1;
      while (res = '') and (x <= numLNG) do
      begin
        //MessageDlg(tabLNG[x].ID + chr(10)+tabLNG[x].Value,mtInformation,[mbOk],0);
        if tabLNG[x].ID = sch then
          res := tabLNG[x].Value;
        x := x + 1;
      end;
    end
  end;

  if res = '' then
    res := '--Undefined--'+sch+'--';

  while Pos('%n',res) > 0 do
  begin
    res := ReplaceValue('%n',res,chr(10));
  end;

  DLNGStr := res;

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

end.
