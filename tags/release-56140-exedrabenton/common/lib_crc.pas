unit lib_crc;

// $Id$
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/common/lib_crc.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is lib_crc.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is unknown.
//
// =============================================================================
// CRC32 of String Library
// =============================================================================
//
//  Functions:
//  function GetStrCRC32(Data: string) : longint;
//
// -----------------------------------------------------------------------------

interface

uses classes;

function GetStrCRC32(Data: string) : longint;
function GetBufCRC32(Data: PChar; datalength: integer) : longint;
function GetStmCRC32(Data: TStream; datalength: integer) : longint;

implementation

{CRC32}
type
   crc32tabletype = array[0..255] of longint;
var
   fcrctable: crc32tabletype;
   tabinit: boolean = false;

function crc32gen: crc32tabletype;
var
   crc, poly: longint;
   i, j: integer;
   crc32table: crc32tabletype;
begin
   fillchar(crc32table, sizeof(crc32table) , 0) ;
   poly := longint($EDB88320) ;
   for i := 0 to 255 do
   begin
      crc := i;
      for j := 8 downto 1 do
      begin
         if (crc and 1) = 1 then
            crc := (crc shr 1) xor poly
         else
            crc := crc shr 1;
      end;
      crc32table[i] := crc;
   end;
   result := crc32table;
end;

function GetStrCRC32(Data: string) : longint;
var
   crc: longint;
   index, datalength: integer;
begin
   if not(tabinit) then
     fcrctable := crc32gen;

   crc := longint($FFFFFFFF) ;

   datalength := length(data) ;
   index := 1;
   while index <= datalength do
   begin
      crc := ((crc shr 8) and $FFFFFF) xor fcrctable[(crc xor byte(data[index]) ) and $FF];
      inc(index) ;
   end;
   result := (crc xor Integer($FFFFFFFF) ) ;
end;

function GetBufCRC32(Data: PChar; datalength: Integer) : longint;
var
   crc: longint;
   index: integer;
begin
   if not(tabinit) then
     fcrctable := crc32gen;

   crc := longint($FFFFFFFF) ;

   datalength := length(data) ;
   index := 1;
   while index <= datalength do
   begin
      crc := ((crc shr 8) and $FFFFFF) xor fcrctable[(crc xor byte(data[index]) ) and $FF];
      inc(index) ;
   end;
   result := (crc xor Integer($FFFFFFFF) ) ;
end;

function GetStmCRC32(Data: TStream; datalength: integer) : longint;
var
   crc: longint;
   index: integer;
   tmpRead: byte;
begin
   if not(tabinit) then
     fcrctable := crc32gen;

   crc := longint($FFFFFFFF) ;

   index := 1;
   while index <= datalength do
   begin
      tmpRead := data.Read(tmpRead,1);
      crc := ((crc shr 8) and $FFFFFF) xor fcrctable[(crc xor tmpRead) and $FF];
      inc(index) ;
   end;
   result := (crc xor Integer($FFFFFFFF) ) ;
end;

end.
