unit lib_version;

// $Id: lib_version.pas,v 1.1.1.1 2004-05-08 10:25:11 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/common/lib_version.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is lib_version.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// Dragon UnPACKer Version Management library
// =============================================================================
//  
//  Functions:
//  function getVersion(version: integer): string;
//
// -----------------------------------------------------------------------------

interface
uses StrUtils, SysUtils;

function getVersion(version: integer): string;

implementation
function getVersion(version: integer): string;
var majVer: integer;
    minVer: integer;
    revVer: integer;
    typVer: integer;
    valVer: integer;
    inStr: String;
    typStr: String;
    valStr: String;
begin

  inStr := IntToStr(version);

  if (length(inStr) >= 5) then
    majVer := StrToInt(LeftStr(inStr, length(inStr)-4))
  else
    majVer := 0;

  if (length(inStr) >= 4) then
    minVer := StrToInt(MidStr(inStr,length(inStr)-3,1))
  else
    minVer := 0;

  if (length(inStr) >= 3) then
    revVer := StrToInt(MidStr(inStr,length(inStr)-2,1))
  else
    revVer := 0;

  if (length(inStr) >= 2) then
    typVer := StrToInt(MidStr(inStr,length(inStr)-1,1))
  else
    typVer := 0;

  if (length(inStr) >= 5) then
    valVer := StrToInt(RightStr(inStr, 1))
  else
    valVer := 0;

  case typVer of
    0: typStr := 'Alpha ';
    1: typStr := 'Beta ';
    2: typStr := 'RC';
    3: typStr := 'Gold ';
    4: typStr := '';
    5: typStr := '';
    6: typStr := '';
    7: typStr := 'Fix ';
    8: typStr := 'Patch ';
    9: typStr := 'Special ';
  end;

  if (typVer = 4) and (valVer > 0) then
  begin
    typStr := 'Release ';
    valStr := Chr(64+valVer);
  end
  else if (typVer = 5) then
  begin
    typStr := 'Release ';
    valStr := Chr(74+valVer);
  end
  else if (typVer = 6) then
  begin
    typStr := 'Release ';
    case valVer of
      7: valStr := '+';
      8: valStr := '++';
      9: valStr := '+++';
    else
      valStr := Chr(84+valVer);
    end;
  end
  else if (valVer > 0) then
    valStr := IntToStr(valVer)
  else
    valStr := '';

  result := TrimRight(IntToStr(majVer)+'.'+IntToStr(minVer)+'.'+IntToStr(revVer)+' '+typStr+ valStr);

end;

end.