unit lib_BinUtils;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is lib_binutils.pas, released April 8, 2014.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// Binary Utilities library
// =============================================================================
//
// Useful functions to read/write strings/data from/to files
//
// -----------------------------------------------------------------------------

interface

uses classes, SysUtils, StrUtils;

function Get0(src: integer): string; overload;
function Get0(stm: TStream): string; overload;
function GetStm0(stm: TStream): TMemoryStream;
function Get0A(src: integer): string;
function Get16(src: integer): string; overload;
function Get16(src: integer; size: word): string; overload;
function Get16(src: TStream): string; overload;
function Get16(src: TStream; size: word): string; overload;
function Get32(src: TStream): string; overload;
function Get32(src: TStream; size: integer): string; overload;
function Get32(src: integer): string; overload;
function Get32(src, size: integer): string; overload;
function Get8(src: integer): string; overload;
function Get8(stm: TStream): string; overload;
function Get8u(src: integer): string; overload;
function Get8u(src: TStream): string; overload;
function Get8v(src: integer; size: byte): string;
function GetSwapInt(src: integer): Integer;
procedure put8(src: integer; val: string); overload;
procedure put8(outstm: TStream; val: string); overload;
procedure put32(outstm: TStream; val: AnsiString);
function revstr(str: string): string;
function posrev(substr: string; str: string): integer;
function strip0(str : string): string;
function SwapBytes(Value: LongWord): LongWord;
function SwapBytes64(Value: Int64; NumBytes: byte): Int64;

implementation

function SwapBytes(Value: LongWord): LongWord;
type
  Bytes = packed array[0..3] of Byte;
begin
  Bytes(Result)[0]:= Bytes(Value)[3];
  Bytes(Result)[1]:= Bytes(Value)[2];
  Bytes(Result)[2]:= Bytes(Value)[1];
  Bytes(Result)[3]:= Bytes(Value)[0];
end;

function SwapBytes64(Value: Int64; NumBytes: byte): Int64;
type
  Bytes = packed array[0..7] of Byte;
var
  index: Byte;
begin
  Result := 0;
  for index := NumBytes-1 downto 0 do
    Bytes(Result)[7-index]:= Bytes(Value)[index];
end;

function Get0(src: integer): string;
var tchar: Char;
    res: string;
begin

  repeat
    FileRead(src,tchar,1);
    res := res + tchar;
  until tchar = chr(0);

  Get0 := res;

end;

function Get0(stm: TStream): string;
var tchar: Char;
    res: string;
begin

  repeat
    stm.Read(tchar,1);
    res := res + tchar;
  until tchar = chr(0);

  result := res;

end;

function GetStm0(stm: TStream): TMemoryStream;
var tchar: Char;
begin

  result := TMemoryStream.Create;
  repeat
    stm.Read(tchar,1);
    if tchar <> chr(0) then
      result.Write(tchar,1);
  until tchar = chr(0);

end;

function Get0A(src: integer): string;
var tchar: Char;
    res: string;
begin

  repeat
    FileRead(src,tchar,1);
    res := res + tchar;
  until tchar = chr(10);

  result := res;

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

function Get16(src: integer): string; overload;
var tchar: Pchar;
    tword: Word;
    res: string;
begin

  FileRead(src,tword,2);
  GetMem(tchar,tword);
  FillChar(tchar^,tword,0);
  FileRead(src,tchar^,tword);

  res := tchar;
  result := Copy(res,1,tword);

  FreeMem(tchar);

end;

function Get16(src: integer; size: word): string; overload;
var tchar: array[1..1024] of Char;
    res: string;
begin

  FillChar(tchar,1023,0);
  FileRead(src,tchar,size);

  res := tchar;
  result := Copy(res,1,size);

end;

function Get16(src: TStream): string; overload;
var tchar: Pchar;
    tword: Word;
    res: string;
begin

  src.ReadBuffer(tword,2);
  GetMem(tchar,tword);
  FillChar(tchar^,tword,0);
  src.ReadBuffer(tchar^,tword);

  res := tchar;
  result := Copy(res,1,tword);

  FreeMem(tchar);

end;

function Get16(src: TStream; size: word): string; overload;
begin

  setLength(result,size);
  src.ReadBuffer(result,size);

end;

procedure put8(src: integer; val: string);
var tchar: array[0..255] of Char;
    tbyt: byte;
    x: integer;
begin

  if (length(val) > 256) then
    val := LeftStr(val,256);

  FillChar(tchar,256,0);

  for x := 0 to length(val)-1 do
    tchar[x] := val[x+1];

  tbyt := length(val);

  FileWrite(src,tbyt,1);
  if (tbyt > 0) then
        FileWrite(src,tchar,length(val));

end;

procedure put8(outstm: TStream; val: string); overload;
var tchar: array[0..255] of Char;
    tbyt: byte;
    x: integer;
begin

  if (length(val) > 256) then
    val := LeftStr(val,256);

  FillChar(tchar,256,0);

  for x := 0 to length(val)-1 do
    tchar[x] := val[x+1];

  tbyt := length(val);

  outstm.Write(tbyt,1);
  if (tbyt > 0) then
    outstm.Write(tchar,length(val));

end;

function Get8(src: integer): string; overload;
var tchar: array[0..255] of Char;
    tbyt: byte;
begin

  FileRead(src,tbyt,1);
  FillChar(tchar,256,0);
  // Fixed bug #958622 : this may have fixed other functions relying on get8
  FileRead(src,tchar[0],tbyt);

  Get8 := tchar;

end;

function Get8(stm: TStream): string; overload;
var tchar: array[0..255] of Char;
    tbyt: byte;
begin

  stm.Read(tbyt,1);
  FillChar(tchar,256,0);
  // Fixed bug #958622 : this may have fixed other functions relying on get8
  stm.Read(tchar[0],tbyt);

  result := tchar;

end;

function Get8u(src: integer): string; overload;
var tchar: WideString;
    tbyt: byte;
begin

  FileRead(src,tbyt,1);
  setlength(tchar,tbyt);
//  FillChar(tchar,256,0);
  FileRead(src,tchar[1],tbyt*2);

  result := tchar;

end;

function Get8u(src: TStream): string; overload;
var tchar: WideString;
    tbyt: byte;
begin

  src.ReadBuffer(tbyt,1);
  setlength(tchar,tbyt);
//  FillChar(tchar,256,0);
  src.ReadBuffer(tchar[1],tbyt*2);
  result := tchar;

end;

procedure put32(outstm: TStream; val: AnsiString);
var tint: integer;
begin

  tint := Length(val);
  outstm.Write(tint,4);
  if (tint > 0) then
    outstm.Write(val[1],tint);

end;

function Get32(src: TStream): string; overload;
var tchar: Pchar;
    tint: Integer;
    res: string;
begin

  src.Read(tint,4);
  if tint > 255 then
  begin
    raise Exception.Create(inttostr(tint)+' octets! t''es fou ?!'+#10+inttostr(src.Position)+#10+inttohex(src.Position,16));
  end;
  GetMem(tchar,tint);
  FillChar(tchar^,tint,0);
  src.Read(tchar^,tint);

  res := tchar;
  Result := Copy(res,1,tint);

  FreeMem(tchar);

end;

function Get32(src: TStream; size: integer): string; overload;
var tchar: Pchar;
    res: string;
begin

  if size > 255 then
  begin
    raise Exception.Create(inttostr(size)+' octets! t''es fou ?!'+#10+inttostr(src.Position)+#10+inttohex(src.Position,16));
  end;
  GetMem(tchar,size);
  FillChar(tchar^,size,0);
  src.Read(tchar^,size);

  res := tchar;
  Result := Copy(res,1,size);

  FreeMem(tchar);

end;
function Get32(src: integer): string; overload;
var tchar: Pchar;
    tint: Integer;
    res: string;
begin

  FileRead(src,tint,4);
  GetMem(tchar,tint);
  FillChar(tchar^,tint,0);
  FileRead(src,tchar^,tint);

  res := tchar;
  result := Copy(res,1,tint);

  FreeMem(tchar);

end;

function Get32(src, size: integer): string; overload;
var tchar: PChar;
    res: string;
    x: integer;
begin

  GetMem(tchar,size);

  FillChar(tchar^,size,0);
  FileRead(src,tchar^,size);

  for x := 0 to size-1 do
    res := res + tchar[x];

  FreeMem(tchar);

  Result := Copy(res,1,size);

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

function revstr(str: string): string;
var res: string;
    x: integer;
begin

  for x := 0 to length(str)-1 do
    res := str[x]+res;

  revstr := res;

end;

function posrev(substr: string; str: string): integer;
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

function GetSwapInt(src: integer): Integer;
var tint: integer;
begin
  FileRead(src,tint,4);
  result := swap(tint shr 16) or
           (longint(swap(tint and $ffff)) shl 16);
end;

end.
