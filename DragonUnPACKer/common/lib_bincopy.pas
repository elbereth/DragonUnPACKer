unit lib_bincopy;

{$MODE Delphi}

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is lib_bincopy.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// Binary Copy library                                               version 5.0
// =============================================================================
//
//  Functions:
//  procedure BinCopyToStream(src, dst : TStream; soff : Int64; ssize : Int64;
//                    doff : Int64; bufsize : Integer; silent: boolean);
//
//  Version history:
//  v5.0: Fixed Huge Files seeking --> Int64 seek()
//  v4.0: Improved to drop GetMem & pointers
//  v3.0: Updated for Stream support
//  v2.0: Updated for Int64 support (very huge files supported)
//        Added silent flag
//  v1.0: Initial version.
//
// -----------------------------------------------------------------------------

interface

uses SysUtils, Classes;

type TPercentCallback = procedure(p: byte);

procedure BinCopy(src : integer; dst : integer; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback; xored: byte = 0);
procedure BinCopyToStream(src : integer; dst: TStream; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback; xored: byte = 0); overload;
procedure BinCopyToStream(src, dst: TStream; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback; xored: byte = 0); overload;

implementation

procedure BinCopyToStream(src, dst: TStream; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback; xored: byte = 0); overload;
var
  i,j, numbuf, restbuf, wordsbuf, bytesbuf: Integer;
  per, oldper: word;
  real1, real2: real;
  xored4, toxor: longword;
  startpos, endpos: int64;
  memstm: TMemoryStream;
  toxorbyte: byte;
begin

  if xored <> 0 then
  begin
    xored4 := xored + xored * $100 + xored * $10000 + xored * $1000000;
    memstm := TMemoryStream.Create;
  end;

  if not(silent) then
    DisplayPercent(0);

  // Test there is something to do, without it the result is weird....
  if ssize > 0 then
  begin

    // Avoid extracting past the end of the file (this should be only necessary
    // for bad plugins which returns incorrect offsets/sizes
    if (soff+ssize) > src.Size then
      ssize := src.Size - soff;

    src.Seek(soff,soBeginning);
    numbuf := ssize div bufsize;
    restbuf := ssize mod bufsize;
    wordsbuf := bufsize div 4;
    bytesbuf := bufsize mod 4;

    oldper := 0;

    dst.Seek(doff,soBeginning);

    for i := 1 to numbuf do
    begin
      if (xored <> 0) then
      begin
        memstm.Seek(0,0);
        memstm.CopyFrom(src,bufsize);
        memstm.Seek(0,0);
        for j := 1 to wordsbuf do
        begin
          memstm.Read(toxor,4);
          memstm.Seek((j-1)*4,0);
          toxor := toxor xor xored4;
          memstm.Write(toxor, 4);
        end;
        for j := 1 to bytesbuf do
        begin
          memstm.Read(toxorbyte,1);
          memstm.Seek((wordsbuf*4)+j-1,0);
          toxorbyte := toxorbyte xor xored;
          memstm.Write(toxorbyte, 1);
        end;
        memstm.Seek(0,0);
        dst.CopyFrom(memstm,bufsize);
      end
      else
        dst.CopyFrom(src, bufsize);
      if not(silent) then
      begin
        real1 := i;
        real2 := numbuf;
        real1 := (real1 / real2)*100;
        per := Round(real1);
        if per >= oldper + 10 then
        begin
          DisplayPercent(per);
          oldper := per;
        end;
      end;
    end;

    if (xored <> 0) then
    begin
      memstm.Seek(0,0);
      memstm.CopyFrom(src,restbuf);
      memstm.Seek(0,0);
      wordsbuf := restbuf div 4;
      bytesbuf := restbuf mod 4;
      for j := 1 to wordsbuf do
      begin
        memstm.Read(toxor,4);
        memstm.Seek((j-1)*4,0);
        toxor := toxor xor xored4;
        memstm.Write(toxor, 4);
      end;
      for j := 1 to bytesbuf do
      begin
        memstm.Read(toxorbyte,1);
        memstm.Seek((wordsbuf*4)+j-1,0);
        toxorbyte := toxorbyte xor xored;
        memstm.Write(toxorbyte, 1);
      end;
      memstm.Seek(0,0);
      dst.CopyFrom(memstm,restbuf);
    end
    else
      dst.CopyFrom(src,restbuf);

  end;

  if xored <> 0 then
  begin
    FreeAndNil(memstm);
  end;

  if not(silent) then
    DisplayPercent(100);

end;

procedure BinCopyToStream(src : integer; dst: TStream; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback; xored: byte = 0); overload;
var srcStm: THandleStream;
begin

  srcStm := THandleStream.Create(src);
  try
    BinCopyToStream(srcStm,dst,soff,ssize,doff,bufsize,silent,DisplayPercent,xored);
  finally
    FreeAndNil(srcStm);
  end;

end;

procedure BinCopy(src,dst : integer; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback; xored: byte = 0);
var srcStm, dstStm: THandleStream;
begin

  srcStm := THandleStream.Create(src);
  dstStm := THandleStream.Create(dst);
  try
    BinCopyToStream(srcStm,dstStm,soff,ssize,doff,bufsize,silent,DisplayPercent,xored);
  finally
    FreeAndNil(srcStm);
    FreeAndNil(dstStm);
  end;

end;

end.
