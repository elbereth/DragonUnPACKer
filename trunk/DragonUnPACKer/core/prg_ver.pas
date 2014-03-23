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
function curVersion:string;
function curEdit:string;

const
  CurVersionFallback: String = '?.?.?';
  CurSpecialEdit: String = 'Missing VersionInfo';
  CurURL: String = 'http://www.dragonunpacker.com';
  CurSVNRevision: String = '$Rev$';
  CurSVNDate: String = '$Date$';
  isSpecialBuild: Boolean = False;

implementation

var
  fileVersion: String;
  productVersionCache: String;
  isFileVersionRetrieved: Boolean = False;

function LectureVersion(out productVersion: string): string;
var
    S        : string;
    Taille  : DWord;
    Buffer  : PChar;
    VersionPC, ProductVersionPC : PChar;
    VersionL    : DWord;

begin

  if isFileVersionRetrieved then
  begin

    result := fileVersion;
    productVersion := productVersionCache;

  end
  else
  begin

    Result:='';
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
        {--- Recherche de l'information de version ---}
        if VerQueryValue(Buffer, PChar('\StringFileInfo\040C04E4\FileVersion'), Pointer(VersionPC), VersionL)
            then Result:=VersionPC;
        if VerQueryValue(Buffer, PChar('\StringFileInfo\040C04E4\ProductVersion'), Pointer(ProductVersionPC), VersionL)
            then productVersion:=ProductVersionPC;
        isFileVersionRetrieved := true;
        fileVersion := result;
        productVersionCache := ProductVersionPC;
      finally
        FreeMem(Buffer, Taille);
      end;
    end;

  end;

end;

function curBuild:integer;
var lv, editinfo : string;
begin

  lv := lectureVersion(editInfo);
  if (lv = '') then
    result := 0
  else
    result := strtoint(rightstr(lv, length(lv) - posrev('.',lv)));

end;

function curVersion:string;
var lv, editinfo : string;
begin

  lv := lectureVersion(editInfo);
  if (lv = '') then
    result := curVersionFallback
  else
    result := leftstr(lv,posrev('.',lv)-1);

end;

function curEdit:string;
var lv, editinfo : string;
begin

  if isSpecialBuild then
    result := curSpecialEdit
  else
  begin
    lv := lectureVersion(editInfo);
    if editInfo = '' then
      result := curSpecialEdit
    else
      result := editInfo;
  end;

end;

end.
