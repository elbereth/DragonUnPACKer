unit prg_ver;

// $Id: prg_ver.pas,v 1.4.2.3 2004-10-03 21:28:30 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/prg_ver.pas,v $
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

const
  CurVersion: String = '5.1.2';
//  CurEdit: String = 'GiantsHell.com Edition';
  CurEdit: String = 'WIP';
  CurURL: String = 'http://www.dragonunpacker.com';

implementation

function LectureVersion:string;
var
    S        : string;
    Taille  : DWord;
    Buffer  : PChar;
    VersionPC : PChar;
    VersionL    : DWord;

begin

    Result:='';
    {--- on demande la taille des informations sur l'application ---}
    S := Application.ExeName;
    Taille := GetFileVersionInfoSize(PChar(S), Taille);
    if Taille>0
    then try
    {--- Réservation en mémoire d'une zone de la taille voulue ---}
    Buffer := AllocMem(Taille);
    {--- Copie dans le buffer des informations ---}
    GetFileVersionInfo(PChar(S), 0, Taille, Buffer);
    {--- Recherche de l'information de version ---}
    if VerQueryValue(Buffer, PChar('\StringFileInfo\040C04E4\FileVersion'), Pointer(VersionPC), VersionL)
        then Result:=VersionPC;
    finally
    FreeMem(Buffer, Taille);
    end;

end;

function curBuild:integer;
var lv : string;
begin

  lv := lectureVersion;
  result := strtoint(rightstr(lv, length(lv) - posrev('.',lv)));

end;

end.
