unit lib_bincopy;

// $Id: lib_bincopy.pas,v 1.1.1.1 2004-05-08 10:25:11 elbereth Exp $
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
// Binary Copy library                                               version 2.0
// =============================================================================
//
//  Types:  
//  DULK_Header
//  DULK_IndexEntry
//  
//  Const:
//  DULK_Version
//  DULK_IndexNum
//  
//  Functions:
//  procedure BinCopy(src : integer; dst : integer; soff : Int64; ssize : Int64;
//                    doff : Int64; bufsize : Integer; silent: boolean);
//
//  Version history:
//  v2.0: Updated for Int64 support (very huge files supported)
//        Added silent flag
//  v1.0: Initial version.
//
// -----------------------------------------------------------------------------

interface
  procedure BinCopy(src : integer; dst : integer; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean);

implementation

uses SysUtils, Dialogs;

procedure BinCopy(src : integer; dst : integer; soff : Int64; ssize : Int64; doff : Int64; bufsize : Integer; silent: boolean);
var
  //sFileLength: Integer;
  Buffer: PChar;
  i,numbuf, restbuf: Integer;
  per, oldper: word;
  real1, real2: real;
begin

try
  //sFileLength := FileSeek(src,0,2);
  FileSeek(src,soff,0);
  numbuf := ssize div bufsize;
  restbuf := ssize mod bufsize;

  GetMem(Buffer,bufsize);

  oldper := 0;

  for i := 1 to numbuf do
  begin
    FileRead(src, Buffer^, bufsize);
    FileWrite(dst, Buffer^, bufsize);
    if not(silent) then
    begin
      real1 := i;
      real2 := numbuf;
      real1 := (real1 / real2)*100;
      per := Round(real1);
      if per >= oldper + 10 then
      begin
        oldper := per;
      end;
    end;
  end;

//  if not(silent) then
//    DisplayPercent(100);

  FileRead(src, Buffer^, restbuf);
  FileWrite(dst, Buffer^, restbuf);

  FreeMem(Buffer);

except
  on E: Exception do MessageDlg(E.Message, mtError, [mbOk], E.HelpContext);
end;

end;

end.
