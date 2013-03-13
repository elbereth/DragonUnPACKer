unit auxFSE;

// $Id$
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/auxFSE.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is aux_FSE.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses Main, VirtualTrees, ComCtrls, Dialogs, lib_Language, lib_utils, SysUtils, DateUtils, Classes, prg_ver;

type FSE = ^element;
  element = record
  Name : String;
  Size : Int64;
  Offset : Int64;
  DataX : integer;
  DataY : integer;
  suiv : FSE;
end;

type FSEentry = record
  Name : String;
  FolderID : Integer;
  FileName : String;
  Size : Int64;
  Offset : Int64;
  DataX : integer;
  DataY : integer;
end;

 pvirtualIndexData = ^virtualIndexData;
 virtualIndexData = record
   dirname: String;
   imageIndex: integer;
   selectedImageIndex: integer;
   FolderID: integer;
 end;

type TDirCache = class
    constructor Create(dirSep: string);
    destructor Free();
    procedure addItem(itm: FSE);
    function getItem(idx: integer): FSE;
    function getNumItems: integer;
    function getTDirPos: integer;
  private
    data: array of FSE;
    numData: integer;
    maxData: integer;
    tdirpos: integer;
    sch: string;
  end;

//procedure ParseDirs(ASlash: Boolean; Databloc: FSE; Fname: String);
function ConvertSlash(st: String): String;
procedure SetStatus(st: ShortString);
procedure RestoreTitle;
procedure SaveTitle;
procedure SetTitle(st: String);
procedure SetTitleDefault();
procedure SetPanelEx(st: string);
procedure DisplayPercent(value: integer);
function GetDirCache(CurDir: string): TDirCache;

implementation

uses HashTrie;

var SavedTitle: String;
    ht: TStringHashTrie;
    dirCache: TStringHashTrie;

function PosRev(substr, str: string): integer;
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

function GetDirCache(CurDir: string): TDirCache;
var Data: TObject;
begin

  if (length(curDir) > 0) then
  begin
    data := nil;
    dirCache.Find(curDir,data);
//    showmessage(curDir);
    if data = nil then
      result := nil
    else
      result := Pointer(data);
  end
  else
    result := nil;

end;

function ConvertSlash(st: String): String;
var x: integer;
begin

  for x := 1 to length(st) do
    if st[x] = '/' then
      st[x] := '\';

  ConvertSlash := st;

end;

procedure SetStatus(st: ShortString);
begin

  dup5Main.Status.Panels.Items[2].Text := st;
  dup5Main.Refresh;

end;

procedure SetTitle(st: String);
begin

  dup5Main.Caption := 'Dragon UnPACKer v'+CurVersion+' '+CurEdit+' - '+St;
  dup5Main.Refresh;

end;

procedure SetTitleDefault();
begin

  dup5Main.Caption := 'Dragon UnPACKer v'+CurVersion+' '+CurEdit;
  dup5Main.Refresh;

end;

procedure SaveTitle;
begin

  SavedTitle := dup5Main.Caption;

end;

procedure RestoreTitle;
begin

  if SavedTitle <> '' then
    dup5Main.Caption := SavedTitle;

end;

procedure SetPanelEx(st: string);
begin

  dup5Main.writeLog(st);
  dup5Main.Refresh;

end;

procedure DisplayPercent(value: integer);
begin

  if value < 0 then
    value := 0;
  if value > 100 then
    value := 100;
  dup5Main.Percent.Position := value;
  dup5Main.Percent.Refresh;

end;

{ TDirCache }

procedure TDirCache.addItem(itm: FSE);
begin

  inc(numData);
  if (numData > maxData) then
  begin
    maxData := maxData + 4;
    setLength(data,maxData);
  end;
  data[numdata-1] := itm;
  if TDirPos = 0 then
    TDirPos := posrev(sch, itm^.name);

end;

function TDirCache.getItem(idx: integer): FSE;
begin

  result := data[idx];

end;

function TDirCache.getNumItems: integer;
begin

  result := numData;

end;

constructor TDirCache.Create(dirSep: string);
begin

  maxData := 4;
  setLength(data,maxData);
  numData := 0;
  tdirpos := 0;
  sch := dirSep;

end;

destructor TDirCache.Free();
begin

  setLength(data,0);
  
end;

function TDirCache.getTDirPos: integer;
begin

  result := TDirPos;

end;

initialization

finalization

  try
    if (ht <> nil) then
    begin
      ht.AutoFreeObjects := true;
      FreeAndNil(ht);
    end;
  finally
    try
      if (dirCache <> nil) then
      begin
        dirCache.AutoFreeObjects := true;
        FreeAndNil(dirCache);
      end;
    finally
    end;
  end;

end.
