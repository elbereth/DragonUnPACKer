unit lib_unlzw;

// $Id: lib_unlzw.pas,v 1.1 2009-06-19 06:39:32 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/common/lib_unlzw.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is unlzw.c, released July 7, 2008.
//
// The Initial Developer of the Original Code is Luigi Auriemma
// (aluigi@autistici.org, http://aluigi.org).
//
// Here is the original intro text by Luigi:
// Very simple and basic LZW memory decompressor (compatible with
// gunzip) written by me during the reversing of the
// COM_LZW_Decompress function (LZW_lib) used in the Vietcong game.
// As already said this code has the semplicity in mind and I hope
// my comments help a bit the understanding of how the things work.
// My first implementation used only one function and many #defines
// but I have thought that is better to use a function for each
// repeated sequence of operations and the needed global variables.
// This code works on both little and big endian systems and some
// variables have been optimized for speed and size (like dictlen).
// In case of compatibility problems try to limit "bits" to 12 in
// unlzw_dictionary.
//
// Adaptations by Alexandre Devilliers:
// The only modification I did was to the main unlzw function. It will take
// 2 TStream objects as input/output instead of the pointer to bytes of the
// original function.
// Original comments were kept as much as possible.
//
// License note: The original code was under GPL, so this translation to
// Delphi/Pascal is probably also to be considered under GPL.

interface

uses classes;

function unlzw(inStr,outStr:TStream): cardinal;

implementation

const UNLZW_BITS = 9;
      UNLZW_END = 256;

type dict_t = record
      data: integer;        // data offset
      len: word;            // data size, 16 bits: in over half gigabyte
    end;                    // of zeroes this len was minor than 30000

var dict: array of dict_t;  // the dictionary
    outlen: cardinal;       // current output length
    outsize: cardinal;      // output buffer size
    dictsize: cardinal;     // offset of the last element in the dictionary
    dictoff: cardinal;      // offset of the new entry to add to the dictionary
    dictalloc: cardinal;    // used only for dynamic dictionary
    dictlen: word;          // offset length (like dict_t.len)
    bits: byte;             // init bits (usually max 16)
    ibits: byte;            // inverted bits for catching the element
    outbuf: array of byte;  // output buffer

function unlzw_init: integer;
begin
  bits := UNLZW_BITS;
  ibits := 0;
  dictsize := UNLZW_END + 1;
  dictoff := 0;
  dictlen := 0;
  if dict = nil then        // allocate memory for a dictionary of UNLZW_BITS bits
  begin
    dictalloc := (1 shl (UNLZW_BITS + 3));
    SetLength(dict,dictalloc);   // + 3 is used for avoiding too much SetLength calls
    if dict = nil then
    begin
      result := -1;
      exit;
    end;
  end;                      // if dict still exists we use it
  fillchar(dict[0],sizeof(dict),0); // all lengths set to zero to avoid malicious crashes
  result := 0;
end;

procedure unlzw_cpy(var src: array of byte; srcStart: Integer;var dst: array of byte; dstStart: Integer; len: integer);
var
 i : integer;
begin
 for i := 0 to len - 1 do
  dst[dstStart+i]:=src[srcStart+i];
end;

function unlzw_expand(code: cardinal): integer;
begin

  if code >= dictsize then   // invalid so return 0
  begin
    result := 0;
    exit;
  end;

  if code >= UNLZW_END then  // put the data in the dictionary
  begin
    if (outlen + dict[code].len) > outsize then
    begin
      result := -1;
      exit;
    end;
    unlzw_cpy(outbuf,dict[code].data,outbuf,outlen,dict[code].len);
    result := dict[code].len;
    exit;
  end;

  if((outlen + 1) > outsize) then
  begin
    result := -1;
    exit;
  end;

  // put the byte
  outbuf[outlen] := code;
  result := 1;

end;

function unlzw_dictionary(): integer;    // fill the dictionary
var tmp: cardinal;
begin

  if dictlen <> 0 then
  begin
    inc(dictlen);
    if ((dictoff + dictlen) > outsize) then
    begin
      dictlen := outsize - dictoff;
    end;
    dict[dictsize].data := dictoff;
    dict[dictsize].len := dictlen;
    inc(dictsize);
    if ((dictsize + 1) shr bits) <> 0 then
    begin
      inc(bits);    // dynamic dictionary
      tmp := 1 shl bits;
      if tmp > dictalloc then
      begin
        setlength(dict,tmp);
        dictalloc := tmp;
      end;
    end;
  end
  else
    inc(dictlen);

  result := 0;

end;

function unlzw(inStr,outStr:TStream): cardinal;
var code: cardinal;         // current element
    inlen: cardinal;        // current input length
    insize: cardinal;       // bytes written in the output
    n: integer;
    inbuf: array of byte;
begin

  n := 0;
  inlen := 0;               // current input length
  outlen := 0;              // current output length

  // init the output buffer to the expected size of output
  // we fill the output with zeroes
  setlength(outbuf,outstr.Size);
  fillchar(outbuf[0],outstr.size,0);
  outsize := outstr.Size;
  insize := instr.Size;

  // global var initialization
  dict := nil;
  if unlzw_init() < 0 then
  begin
    result := 0;
    exit;
  end;

  setlength(inbuf,insize);
  instr.Seek(0,0);
  instr.ReadBuffer(inbuf[0],insize);

  while inlen < insize do
  begin
    // read at least 24 bits (16 + 7) and cut them
    code := inbuf[inlen];
    if ((insize - inlen) > 1) then
      code := code or (inbuf[inlen + 1] shl 8);
    if ((insize - inlen) > 2) then
      code := code or (inbuf[inlen + 2] shl 16);
    code := (code shr ibits) and ((1 shl bits) - 1);

    inc(inlen,(bits + ibits) shr 3);   // increment the input length
    ibits := (bits + ibits) and 7;     // adjust the inverted bits

    if code = UNLZW_END then           // means that we need to reset 
    begin
      if (ibits <> 0) then
        inc(inlen);

      if (unlzw_init() < 0) then
        break;

      continue;                        // and restart the unpacking
    end;

    if code = dictsize then            // I think this is used for repeated chars
    begin
      if (unlzw_dictionary() < 0) then // fill the dictionary
        break;

      n := unlzw_expand(code);         // unpack
    end
    else
    begin
      n := unlzw_expand(code);

      if (unlzw_dictionary() < 0) then
        break;
    end;

    if (n < 0) then                    // break if unlzw_expand() failed
      break;

    dictoff := outlen;                 // increment all the remaining values
    dictlen := n;
    inc(outlen,n);
  end;

  // Write the output buffer to the stream
  // and return the number of bytes written
  outstr.Seek(0,0);
  result := outstr.Write(outbuf[0],outlen);

  // Free memory
  SetLength(outbuf,0);
  SetLength(inbuf,0);
  SetLength(dict,0);

end;

end.
