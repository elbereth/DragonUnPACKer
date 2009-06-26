unit HyperRipper_aux;

// $Id: HyperRipper_aux.pas,v 1.2 2009-06-26 21:01:29 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/HyperRipper_aux.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is HyperRipper_aux.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Windows, Classes, HyperRipper, lib_utils, SysUtils, declFSE, Main;

type
  THRipSearch = class(TThread)
  private
    MAXSIZE: integer;
    RollBack: integer;
    filename: string;
    slist: SearchList;
    hrip: TfrmHyperRipper;
  protected
    procedure Execute; override;
    procedure setSearch(filnam: String; sl: SearchList; hr: TfrmHyperRipper; bufSize: integer; RBSize: integer);
  end;

implementation

{ Important : les méthodes et propriétés des objets de la VCL ou CLX peuvent uniquement être
  utilisées dans une méthode appelée avec Synchronize. Par exemple,

      Synchronize(UpdateCaption);

  UpdateCaption ayant l''apparence suivante :

    procedure THRipSearch.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ THRipSearch }

function FListCompare(Item1, Item2: Pointer): Integer;
var Elem1, Elem2: PFoundItem;
begin

  Elem1 := Item1;
  Elem2 := Item2;

  result := Elem2^.Offset - Elem1^.Offset;

end;

procedure THRipSearch.Execute;
var hSRC, x: integer;
    totsize,curpos: int64;
    buffer: PByteArray;
    bufsize,testsize: integer;
    per, oldper: real;
    SomethingFound: Boolean;
    curOffset, foundOffset, minOffset, foundDriver: integer;
    found: FoundInfo;
    numFound, rollback: integer;
    flist: TList;
    fitem: PFoundItem;
    startTime: Cardinal;
    speedcalc: Integer;
begin

  hrip.addResult('Opening '+ExtractFileName(filename)+'...');

  hSRC := FileOpen(filename,fmOpenRead or fmShareExclusive);

  startTime := GetTickCount;

  if MAXSIZE < 1024 then
    hrip.lblBufferLength.Caption := inttostr(MAXSIZE) +'b'
  else if MAXSIZE < 1048576 then
    hrip.lblBufferLength.Caption := inttostr(MAXSIZE div 1024) +'Kb'
  else
    hrip.lblBufferLength.Caption := inttostr(MAXSIZE div 1048576) +'Mb';

  hrip.Progress.Max := 100;
  OldPer := 0;
  numFound := 0;

  if rollback < 1024 then
    hrip.lblRollback.Caption := inttostr(rollback) +'b'
  else if rollback < 1048576 then
    hrip.lblRollback.Caption := inttostr(rollback div 1024) +'Kb'
  else
    hrip.lblRollback.Caption := inttostr(rollback div 1048576) +'Mb';

  hrip.lblFound.Caption := IntTostr(numFound);

  if hSRC > 0 then
  begin
    hrip.LastResult('Opening '+ExtractFileName(filename)+'... Done!');
    hrip.AddResult('Allocating ressources... ');
    flist := TList.Create;
    try
     try
      FSE.LoadHyperRipper(filename);
      totsize := FileSeek(hSRC,0,2);
      if totsize > MAXSIZE then
        bufsize := MAXSIZE
      else
        bufsize := totsize;
      getmem(Buffer,bufsize);
      CurPos := 0;
      hrip.LastResult('Allocating ressources... Done!');
      hrip.AddResult('Scanning for known file formats...');
      while CurPos < TotSize do
      begin
        FileSeek(hSRC,CurPos,0);
        TestSize := FileRead(hSRC,buffer^,bufsize);

        per := (CurPos / TotSize);
        per := per * 100;

        minOffset := -1;
        foundDriver := -1;
        for x := 0 to flist.Count-1 do
          Dispose(flist.Items[x]);
        flist.Clear;
        for x := 1 to slist.num do
        begin
          foundOffset := HPlug.plugins[slist.items[x].DriverNum].SearchBuffer(slist.items[x].ID,buffer,bufsize);
          if (foundOffset > -1) then
          begin
            new(fitem);
            fitem^.Offset := foundOffset;
            fitem^.Index := x;
            flist.Add(fitem);
          end;
        end;

        if (flist.Count > 0) then
          flist.sort(@FListCompare);

        SomeThingFound := false;

        for x := 0 to flist.Count-1 do
        begin
          fitem := flist.Items[x];
          Found := HPlug.plugins[slist.items[fitem^.Index].DriverNum].SearchFile(slist.items[fitem^.Index].ID,hSRC,curPos+fitem^.Offset);
          if (Found.GenType <> HR_TYPE_ERROR) then
          begin
            inc(numFound);
            hrip.addResult('Found '+Found.Ext +' @ '+inttohex(Found.Offset,8)+' of '+inttostr(Found.Size)+' bytes');
            curPos := Found.Offset+Found.Size;
            SomethingFound := true;
            break;
          end;
        end;

        if Per >= (OldPer + 1) then
        begin
          hrip.Progress.Position := Round(Per);
          hrip.lstResults.Refresh;
          hrip.lblFound.Caption := IntTostr(numFound);
          hrip.lblHexDump.Caption := '';
          for x := 0 to 17 do
            hrip.lblHexDump.Caption := hrip.lblHexDump.Caption + IntToHex(buffer[x],2)+' ';
          OldPer := Per;
          if (GetTickCount - StartTime) > 0 then
            SpeedCalc := Round((CurPos / ((GetTickCount - StartTime) / 1000)) / 1024)
          else
            SpeedCalc := 0;
          hrip.lblSpeed.Caption := IntToStr(SpeedCalc)+'Kb/s';
          hrip.Refresh;
        end;

        if Not(SomethingFound) then
        begin
          CurPos := CurPos + bufsize;
          if (bufsize = MAXSIZE) then
            Dec(CurPos,rollback);
        end;
        if (totsize - CurPos) < MAXSIZE then
          bufsize := (totsize - CurPos);

      end;

//      raise Exception.create('bouh');
      hrip.lblFound.Caption := IntTostr(numFound);
      hrip.Progress.Position := 100;
      if (TotSize < 1024) then
        hrip.AddResult('Scanned '+inttostr(TotSize)+'bytes in '+floattostr(round((getTickCount-starttime)/100)/10)+'sec!')
      else if (TotSize < 1048576) then
        hrip.AddResult('Scanned '+inttostr(TotSize div 1024)+'Kb in '+floattostr(round((getTickCount-starttime)/100)/10)+'sec!')
      else if (TotSize < 1073741824) then
        hrip.AddResult('Scanned '+inttostr(TotSize div 1048576)+'Mb in '+floattostr(round((getTickCount-starttime)/100)/10)+'sec!')
      else
        hrip.AddResult('Scanned '+inttostr(TotSize div 1073741824)+'Gb in '+floattostr(round((getTickCount-starttime)/100)/10)+'sec!');
      hrip.AddResult('Displaying result in Dragon UnPACKer...');
      hrip.Refresh;
      dup5Main.Caption := 'Dragon UnPACKer v' + CurVersion + ' ' + CurEdit+ ' - '+filename;
      dup5Main.menuFichier_Fermer.Enabled := True;
      dup5Main.Bouton_Fermer.Enabled := True;
      dup5Main.menuEdit.Visible := True;
      dup5Main.Status.Panels.Items[3].Text := 'HRIP';
      FSE.BrowseDir('');
      hrip.LastResult('Displaying result in Dragon UnPACKer... Done!');
     except
      hrip.AddResult('Error while scanning.. aborting...');
     end;
    finally
      hrip.AddResult('Freeing ressources..');
      for x := 0 to flist.Count-1 do
        Dispose(flist.Items[x]);
      FreeAndNil(flist);
      freemem(Buffer);
      FileClose(hSRC);
      hrip.LastResult('Freeing ressources.. Done!');
    end;
  end
  else
    hrip.LastResult('Opening '+ExtractFileName(filename)+'... Error!');

end;

procedure THRipSearch.setSearch(filnam: String; sl: SearchList; hr: TfrmHyperRipper; bufSize: integer; RBSize: integer);
begin

  filename := filnam;
  slist := sl;
  hrip := hr;
  MAXSIZE := bufSize;
  RollBack := RBSize;

end;

end.
