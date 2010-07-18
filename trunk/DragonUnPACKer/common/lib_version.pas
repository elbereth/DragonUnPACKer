unit lib_version;

// $Id: lib_version.pas,v 1.3 2009-07-20 21:34:51 elbereth Exp $
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
function getSVNRevision(SVNRevisionTag: string): string;
function getSVNDate(SVNDateTag: string): string;
function getCVSRevision(CVSRevisionTag: string): string;
function getCVSBuild(CVSRevisionTag: string): cardinal;
function getCVSDate(CVSDateTag: string): string;

implementation

function getCVSBuild(CVSRevisionTag: string): cardinal;
var buildStr: string;
begin

  buildStr := rightstr(CVSRevisionTag,length(CVSRevisionTag)-pos('.',CVSRevisionTag));
  buildStr := leftstr(buildStr,length(buildStr)-2);
  result := strtoint(buildStr);

end;

function getCVSDate(CVSDateTag: string): string;
begin

  If (length(CVSDateTag) > 7) and (Copy(CVSDateTag,1,7) = '$Date: ') then
  begin
    result := Copy(CVSDateTag,8,Length(CVSDateTag)-9);
  end
  else
    result := CVSDateTag;

end;

function getSVNDate(SVNDateTag: string): string;
begin

  If (length(SVNDateTag) > 7) and (Copy(SVNDateTag,1,7) = '$Date: ') then
  begin
    result := Copy(SVNDateTag,8,Length(SVNDateTag)-9);
    result := Trim(Copy(result,1,pos('(',result)-1));
  end
  else
    result := SVNDateTag;

end;

function getCVSRevision(CVSRevisionTag: string): string;
begin

  If (length(CVSRevisionTag) > 12) and (Copy(CVSRevisionTag,1,11) = '$Revision: ') then
  begin
    result := Copy(CVSRevisionTag,12,Length(CVSRevisionTag)-13);
  end
  else
    result := CVSRevisionTag;

end;

function getSVNRevision(SVNRevisionTag: string): string;
begin

  If (length(SVNRevisionTag) > 8) and (Copy(SVNRevisionTag,1,5) = '$Rev:') then
  begin
    result := Trim(Copy(SVNRevisionTag,6,Length(SVNRevisionTag)-7));
  end
  else
    result := SVNRevisionTag;

end;

function getVersion(version: integer): string; overload;
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