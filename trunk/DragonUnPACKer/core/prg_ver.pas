unit prg_ver;

// $Id$
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is prg_ver.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses SysUtils, Windows, Forms, lib_binutils, StrUtils;

function curBuild:integer;
function LinkerTimestamp: TDateTime; overload;

const
  CurVersion: String = '5.7.0';
  CurEdit: String = 'Fafnir';
  CurURL: String = 'http://www.dragonunpacker.com';

implementation

var
  CurBuildCache: integer = 0;

function LinkerTimestamp: TDateTime; overload;
begin
  Result := PImageNtHeaders(HInstance + PImageDosHeader(HInstance)^._lfanew)^.FileHeader.TimeDateStamp / SecsPerDay + UnixDateDelta;
end;

function getBuildFromVersionInfo: integer;
var
    S        : string;
    Taille  : DWord;
    Buffer  : PChar;
    iDummy : DWord;
    pFileInfo : Pointer;
begin

    Result:=0;
    {--- on demande la taille des informations sur l'application ---}
    S := Application.ExeName;
    Taille := GetFileVersionInfoSize(PChar(S), Taille);
    if Taille>0
    then
    begin
      {--- Réservation en mémoire d'une zone de la taille voulue ---}
      Buffer := AllocMem(Taille);
      try
        {--- Copie dans le buffer des informations ---}
        GetFileVersionInfo(PChar(S), 0, Taille, Buffer);
        VerQueryValue(Buffer, '\', pFileInfo, iDummy);
//        iVer[1] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
//        iVer[2] := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
//        iVer[3] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
//        iVer[4] := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
        Result := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
      finally
        FreeMem(Buffer, Taille);
      end;
    end;

end;

function curBuild:integer;
var lv : string;
begin

  if (curBuildCache = 0) then
    curBuildCache := getBuildFromVersionInfo;
  result := curBuildCache;

end;

end.
