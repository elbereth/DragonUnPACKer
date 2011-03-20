unit lib_bincopy;

// $Id$
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/common/lib_bincopy.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is lib_bincopy.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// Binary Copy library                                               version 4.0
// =============================================================================
//
//  Functions:
//  procedure BinCopyToStream(src, dst : TStream; soff : Int64; ssize : Int64;
//                    doff : Int64; bufsize : Integer; silent: boolean);
//
//  Version history:
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

procedure BinCopy(src : integer; dst : integer; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback);
procedure BinCopyToStream(src : integer; dst: TStream; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback); overload;
procedure BinCopyToStream(src, dst: TStream; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback); overload;

implementation

procedure BinCopyToStream(src, dst: TStream; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback); overload;
var
  i,numbuf, restbuf: Integer;
  per, oldper: word;
  real1, real2: real;
begin

    if not(silent) then
      DisplayPercent(0);

    src.Seek(soff,0);
    numbuf := ssize div bufsize;
    restbuf := ssize mod bufsize;

    oldper := 0;

    dst.Seek(doff,soFromBeginning);

    for i := 1 to numbuf do
    begin
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

    dst.CopyFrom(src,restbuf);

    if not(silent) then
      DisplayPercent(100);

end;

procedure BinCopyToStream(src : integer; dst: TStream; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback); overload;
var srcStm: THandleStream;
begin

  srcStm := THandleStream.Create(src);
  try
    BinCopyToStream(srcStm,dst,soff,ssize,doff,bufsize,silent,DisplayPercent);
  finally
    FreeAndNil(srcStm);
  end;

end;

procedure BinCopy(src,dst : integer; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback);
var srcStm, dstStm: THandleStream;
begin

  srcStm := THandleStream.Create(src);
  dstStm := THandleStream.Create(dst);
  try
    BinCopyToStream(srcStm,dstStm,soff,ssize,doff,bufsize,silent,DisplayPercent);
  finally
    FreeAndNil(srcStm);
    FreeAndNil(dstStm);
  end;

end;

end.
