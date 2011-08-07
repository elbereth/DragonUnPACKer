unit class_duht;

// $Id: class_duht.pas,v 1.3 2009-06-26 21:05:31 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/class_duht.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is class_duht.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses classes, sysutils, zlib, lib_binUtils, spec_duht;

type DUHTList_Entry = record
    entry: DUHT_Entry;
    offset: int64;
    FileName: string;
  end;
  DUHT_Info = record
    TemplateName: string;
    TemplateVersion: string;
    AuthorName: string;
    AuthorEmail: string;
    URL: string;
    Ext: string;
    ExtInfo: string;
  end;

type
  ECRC32Error = class(Exception);

type TDUHT = class(TObject)
    function parseDUHT(src: string): integer;
    function getInfoFromDUHT(): DUHT_Info;
    function extractIM(outdir: string): integer;
    function getEntry(id: string): TMemoryStream;
    function isEntry(id: string): boolean;
    procedure closeDUHT();
    function getFilename(): string;
  private
    filename: string;
    entryList: array of DUHTList_Entry;
    numE: integer;
    hDUHT: integer;
    xHead: DUHT_HeaderX_v1;
    info: DUHT_Info;
    function getEntryByIndex(idx: integer): TMemoryStream;
  end;

implementation

{ TDUHT }

procedure TDUHT.closeDUHT;
begin

  SetLength(entryList,0);
  FileClose(hDUHT);

end;

function TDUHT.extractIM(outdir: string): integer;
var x: integer;
begin

  result := 0;

  for x := 0 to numE-1 do
  begin
    if entryList[x].entry.ID = 'IM' then
    begin
      inc(result);
      getEntryByIndex(x).SaveToFile(outdir+entryList[x].FileName);
    end;
  end;

end;

function TDUHT.getEntry(id: string): TMemoryStream;
var x: integer;
begin

  result := nil;

  for x := 0 to numE-1 do
  begin
    if entryList[x].entry.ID = id then
    begin
      result := getEntryByIndex(x);
      break;
    end;
  end;

end;

function TDUHT.getEntryByIndex(idx: integer): TMemoryStream;
var buf: PByteArray;
    InputStream: TMemoryStream;
    DStream: TDecompressionStream;
begin

  getMem(buf,entryList[idx].entry.Size);
  FileSeek(hDUHT,entryList[idx].offset,0);
  try
    FileRead(hDUHT,Buf^,entryList[idx].entry.Size);
    result := TMemoryStream.Create;

    if entryList[idx].entry.Compression = 1 then
    begin

     InputStream := TMemoryStream.Create;
     try
      InputStream.Write(Buf^,entryList[idx].entry.Size);
      InputStream.Seek(0, soBeginning);
      DStream := TDecompressionStream.Create(InputStream);
      try
        result.CopyFrom(DStream,entryList[idx].entry.FileSize);
      finally
        FreeAndNil(DStream);
      end

      finally
        FreeAndNil(InputStream);
      end
    end
    else
    begin
      result.Write(buf^,EntryList[idx].entry.Size);
    end;
    result.Seek(0, soBeginning);

  finally
    FreeMem(Buf);
  end;

end;

function TDUHT.getFilename: string;
begin

  result := filename;

end;

function TDUHT.getInfoFromDUHT: DUHT_Info;
begin

  result := info;

end;

function TDUHT.isEntry(id: string): boolean;
var x: integer;
begin

  result := false;

  for x := 0 to numE-1 do
  begin
    if entryList[x].entry.ID = id then
    begin
      result := true;
      break;
    end;
  end;

end;

function TDUHT.parseDUHT(src: string): integer;
var HDR: DUHT_Header;
    ENTRY: DUHT_Entry;
    hIn,x: integer;
begin

  if hDUHT >= 0 then
    closeDUHT();

  if FileExists(src) then
  begin
    hIn := FileOpen(src,fmOpenRead or fmShareDenyWrite);
    if hIn >= 0 then
    begin
      FileRead(hIn,HDR,SizeOf(DUHT_Header));
      if (HDR.ID = 'DUHT'+#26) and (HDR.Version = 2) and (HDR.NumEntries > 0) then
      begin
        if HDR.ExtendedHeader = 1 then
          FileRead(hIn,xHead,SizeOf(xHead));
        Info.TemplateName := Get8(hIn);
        Info.AuthorName := Get8(hIn);
        Info.AuthorEmail := Get8(hIn);
        Info.TemplateVersion := Get8(hIn);
        Info.URL := get8(hIn);
        if HDR.Revision >= 1 then
        begin
          Info.Ext := get8(hIn);
          Info.ExtInfo := get8(hIn);
        end
        else
        begin
          Info.Ext := 'XML';
          Info.ExtInfo := 'eXtended Markup Language';
        end;
        SetLength(entryList,HDR.NumEntries);
        FileSeek(hIn,HDR.StartOffset,0);
        numE := HDR.NumEntries;
        for x := 0 to HDR.NumEntries-1 do
        begin
          FileRead(hIn,ENTRY,SizeOf(ENTRY));
          entryList[x].entry := ENTRY;
          if ENTRY.ID = 'IM' then
            entryList[x].FileName := Get8(hIn)
          else
            entryList[x].FileName := '';
          entryList[x].offset := FileSeek(hin,0,1);
          FileSeek(hin,ENTRY.Size,1);
        end;
        hDUHT := hIn;
        result := 0;
        filename := extractfilename(src);
      end
      else
      begin
        FileClose(hIn);
        result := -3;
      end;
    end
    else
      result := -2;
  end
  else
    result := -1;

end;

end.
