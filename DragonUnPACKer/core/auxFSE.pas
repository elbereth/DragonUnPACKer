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
procedure ParseDirs(Sch: string; Databloc: FSE; Fname: String);
function ConvertSlash(st: String): String;
procedure CreateRoot(Fname: string);
procedure CreateRootHR(Fname: string; subdirs: boolean);
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

procedure ParseDirs(Sch: string; Databloc: FSE; Fname: String);
var a: FSE;
    pslash: integer;
    CurDir, CurDirCache, Parse, Before: String;
    Dupe: Boolean;
    Data, DataCache: TObject;
    Root, Nod, NodAdd: PVirtualNode;
    NodeData: pvirtualIndexData;
    cache: TDirCache;
//    StartTime: TDateTime;
begin

//  StartTime := Now;

  Root := dup5Main.lstIndex.AddChild(nil);
  NodeData := dup5Main.lstIndex.GetNodeData(Root);
  NodeData.dirname := FName;
  NodeData.imageIndex := 2;
  NodeData.selectedImageIndex := 2;

  ht := TStringHashTrie.Create;
  dirCache := TStringHashTrie.Create;

  a := DataBloc;
//  nbdir := 0;

  while a <> NIL do
  begin
    pslash := posrev(sch, a^.Name)-1;
    if pslash > 0 then
    begin
      curdir := Copy(a^.Name,1,pslash+1);
      curdircache := uppercase(Copy(curdir,1,pslash));
      DataCache := nil;
      dirCache.Find(curdircache,DataCache);
      cache := Pointer(DataCache);
      if (cache = nil) then
      begin
        cache := TDirCache.Create(sch);
        cache.addItem(a);
        dirCache.Add(curDirCache,Pointer(cache));
        curDirCache := '';
        //showmessage(curDirCache);
      end
      else
      begin
        cache.addItem(a);
      end;
      pslash := pos(sch,curdir);
      Before := '';
      while pslash > 0 do
      begin
        parse := Copy(curdir,1,pslash-1);
        curdir := Copy(curdir,pslash+1,length(curdir)-pslash);
        if before = '' then
        begin
          Dupe := ht.Find(parse+'\',Data);
          if not(Dupe) then
          begin
            Nod := dup5Main.lstIndex.AddChild(Root);
            NodeData := dup5Main.lstIndex.GetNodeData(Nod);
            NodeData.dirname := parse;
            NodeData.imageIndex := 1;
            NodeData.selectedImageIndex := 0;
            ht.Add(parse+'\',Pointer(Nod));
          end
          else
            Nod := Pointer(Data);
          before := parse+'\';
        end
        else
        begin
          Dupe := ht.Find(before+parse+'\',Data);
          if not(Dupe) then
          begin
            NodAdd := dup5Main.lstIndex.AddChild(Nod);
            NodeData := dup5Main.lstIndex.GetNodeData(NodAdd);
            NodeData.dirname := parse;
            NodeData.imageIndex := 1;
            NodeData.selectedImageIndex := 0;
            ht.Add(before+parse+'\',Pointer(NodAdd));
            Nod := NodAdd;
          end
          else
            Nod := Pointer(Data);
          before := before + parse+'\';
          //ShowMessage(a^.Name+#10+parse+#10+curdir+#10+before+#10+BoolToStr(Dupe));
        end;
        SetLength(parse,0);
        pslash := pos(sch,curdir);
      end;
    end;
    a := a^.suiv;

  end;

  SetLength(before,0);

//  ShowMessage(inttostr(nbdir)+#10+inttostr(MilliSecondsBetween(Now,StartTime)));
  FreeAndNil(ht);
  dup5Main.lstIndex.RootNodeCount := 1;
  dup5Main.lstIndex.FocusedNode := Root;
  dup5Main.lstIndex.SortTree(1,sdAscending);

end;

procedure CreateRoot(Fname: string);
//var Nod: TTreeNode;
var Nod: PVirtualNode;
    NodeData: pvirtualIndexData;
begin

  dup5Main.lstIndex.RootNodeCount := 0;
  dup5Main.lstIndex.Clear;

  Nod := dup5Main.lstIndex.AddChild(nil);
  NodeData := dup5Main.lstIndex.GetNodeData(Nod);
  NodeData.dirname := FName;
  NodeData.selectedImageIndex := 2;
  NodeData.imageIndex := 2;

  dup5Main.lstIndex.RootNodeCount := 1;
  dup5Main.lstIndex.FocusedNode := Nod;
//  dup5Main.lstIndexFocusChanged(dup5Main.lstIndex,Nod,-1);

end;

procedure CreateRootHR(Fname: string; subdirs: boolean);
var Nod, Nod2: PVirtualNode;
    NodeData: pvirtualIndexData;
begin

  dup5Main.lstIndex.RootNodeCount := 0;
  dup5Main.lstIndex.Clear;

  Nod := dup5Main.lstIndex.AddChild(nil);
  NodeData := dup5Main.lstIndex.GetNodeData(Nod);
  NodeData.dirname := FName;
  NodeData.selectedImageIndex := 2;
  NodeData.imageIndex := 2;

  if (subdirs) then
  begin

    Nod2 := dup5Main.lstIndex.AddChild(Nod);
    NodeData := dup5Main.lstIndex.GetNodeData(Nod2);
    NodeData.dirname := 'Audio';
    NodeData.selectedImageIndex := 0;
    NodeData.imageIndex := 1;

    Nod2 := dup5Main.lstIndex.AddChild(Nod);
    NodeData := dup5Main.lstIndex.GetNodeData(Nod2);
    NodeData.dirname := 'Video';
    NodeData.selectedImageIndex := 0;
    NodeData.imageIndex := 1;

    Nod2 := dup5Main.lstIndex.AddChild(Nod);
    NodeData := dup5Main.lstIndex.GetNodeData(Nod2);
    NodeData.dirname := 'Image';
    NodeData.selectedImageIndex := 0;
    NodeData.imageIndex := 1;

    Nod2 := dup5Main.lstIndex.AddChild(Nod);
    NodeData := dup5Main.lstIndex.GetNodeData(Nod2);
    NodeData.dirname := 'Unknown';
    NodeData.selectedImageIndex := 0;
    NodeData.imageIndex := 1;

  end;

  dup5Main.lstIndex.RootNodeCount := 1;
  dup5Main.lstIndex.FocusedNode := Nod;
//  dup5Main.lstIndexFocusChanged(dup5Main.lstIndex,Nod,-1);

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
