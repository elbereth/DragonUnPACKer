unit List;

// $Id: List.pas,v 1.5 2009-09-12 05:53:05 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/List.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is List.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, jpeg, spec_DUHT, StrUtils, declFSE, prg_ver,
  lib_language, class_duht, classFSE, VirtualTrees, lib_binUtils, lib_utils, Registry;

const MAX_DUHT = 256;

type
  TfrmList = class(TForm)
    grp1: TGroupBox;
    lstTemplates: TComboBox;
    strVersion: TLabel;
    strAuthor: TLabel;
    strEmail: TLabel;
    strURL: TLabel;
    Panel1: TPanel;
    imgPreview: TImage;
    grp2: TGroupBox;
    grp3: TGroupBox;
    optSortAlpha: TRadioButton;
    status: TStatusBar;
    cmdGo: TButton;
    cmdCancel: TButton;
    optSelected: TRadioButton;
    optAll: TRadioButton;
    optCurrentDir: TRadioButton;
    chkSubDirs: TCheckBox;
    optSortSize: TRadioButton;
    optSortOffset: TRadioButton;
    optSortInvert: TCheckBox;
    lblVersion: TLabel;
    lblAuthor: TLabel;
    lblEmail: TLabel;
    lblURL: TLabel;
    SaveDialog: TSaveDialog;
    chkSort: TCheckBox;
    panSortDisabled: TPanel;
    procedure cmdCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lstTemplatesChange(Sender: TObject);
    procedure cmdGoClick(Sender: TObject);
    procedure chkSortClick(Sender: TObject);
    procedure optSelectedClick(Sender: TObject);
    procedure optAllClick(Sender: TObject);
    procedure optCurrentDirClick(Sender: TObject);
    procedure chkSubDirsClick(Sender: TObject);
    procedure optSortInvertClick(Sender: TObject);
    procedure optSortAlphaClick(Sender: TObject);
    procedure optSortSizeClick(Sender: TObject);
    procedure optSortOffsetClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    lstDUHT: array[1..MAX_DUHT] of TDUHT;
    numDUHT: integer;
    procedure listUHT();
    procedure clearUHT();
    function macroHeader(src, cdir: string): string;
    function macroFooter(src, cdir: string; totSize: int64; totE: integer): string;
    function macroVar(src,cdir,fnam,desc: string; offset, size: int64; datax, datay: integer): string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmList: TfrmList;

implementation

uses Main;

{$R *.dfm}

procedure TfrmList.clearUHT;
var x: integer;
begin

  for x := 1 to numDUHT do
    if lstDUHT[x] <> nil then
      FreeAndNil(lstDUHT[x]);

  numDUHT := 0;

  lstTemplates.Clear;

end;

procedure TfrmList.cmdCancelClick(Sender: TObject);
begin

  frmList.Close;

end;

procedure TfrmList.FormShow(Sender: TObject);
begin

  listUHT();

end;

procedure TfrmList.listUHT;
var sr: TSearchRec;
    pth,curtemp: string;
    Reg: TRegistry;
    seltemp: integer;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\ListCreation',True) then
    begin
      if Reg.ValueExists('RecurseSubDir') then
        ChkSubDirs.Checked := Reg.ReadBool('RecurseSubDir')
      else
        ChkSubDirs.Checked := true;
      if Reg.ValueExists('SortInv') then
        optSortInvert.Checked := Reg.ReadBool('SortInv')
      else
        optSortInvert.Checked := false;
      if Reg.ValueExists('SortList') then
        chkSort.Checked := Reg.ReadBool('SortList')
      else
        chkSort.Checked := true;
      If Reg.ValueExists('Style') then
      begin
        case Reg.ReadInteger('Style') of
          0: optSelected.Checked := true;
          2: optCurrentDir.Checked := true;
        else
          optAll.Checked := true;
        end;
      end
      else
        optAll.Checked := true;
      if Reg.ValueExists('Template') then
        curtemp := Reg.ReadString('Template')
      else
        curtemp := '';
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  pth := extractfilepath(Application.ExeName);

  clearUHT();

  if FindFirst(pth+'data\*.uht', faAnyFile, sr) = 0 then
  begin
    seltemp := 0;
    repeat
      inc(numDUHT);
      lstDUHT[numDUHT] := TDUHT.Create;
      lstDUHT[numDUHT].parseDUHT(pth+'data\'+sr.Name);
      lstTemplates.Items.Add(lstDUHT[numDUHT].getInfoFromDUHT().TemplateName+' v'+lstDUHT[numDUHT].getInfoFromDUHT().TemplateVersion);
      if SameText(sr.Name,curTemp) then
        seltemp := numDUHT-1;
//      showmessage(sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
    if numDUHT > 0 then
    begin
      lstTemplates.ItemIndex := seltemp;
      lstTemplatesChange(frmList);
    end;
  end;

end;

procedure TfrmList.lstTemplatesChange(Sender: TObject);
var prevImg: TJpegImage;
    Reg: TRegistry;
begin

  lblVersion.Caption := lstDUHT[lstTemplates.ItemIndex+1].getInfoFromDUHT().TemplateVersion;
  lblAuthor.Caption := lstDUHT[lstTemplates.ItemIndex+1].getInfoFromDUHT().AuthorName;
  lblEmail.Caption := lstDUHT[lstTemplates.ItemIndex+1].getInfoFromDUHT().AuthorEmail;
  lblURL.Caption := lstDUHT[lstTemplates.ItemIndex+1].getInfoFromDUHT().URL;

  prevImg := TJpegImage.Create;
  prevImg.LoadFromStream(lstDUHT[lstTemplates.ItemIndex+1].getEntry('PV'));
  imgPreview.Picture.Assign(prevImg);

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\ListCreation',True) then
    begin
      Reg.WriteString('Template',lstDUHT[lstTemplates.ItemIndex+1].getFilename);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

function compareAlpha(Item1, Item2: Pointer): Integer;
var PItem1, PItem2: PEntList;
begin
  PItem1 := Item1;
  PItem2 := Item2;
  Result := CompareText(PItem1^.FileName, PItem2^.FileName);
end;

function compareAlphaInv(Item1, Item2: Pointer): Integer;
var PItem1, PItem2: PEntList;
    res: integer;
begin
  PItem1 := Item1;
  PItem2 := Item2;
  res := CompareText(PItem1^.FileName, PItem2^.FileName);
  result := -res;
end;

function compareSize(Item1, Item2: Pointer): Integer;
var PItem1, PItem2: PEntList;
begin
  PItem1 := Item1;
  PItem2 := Item2;
  Result := PItem1^.Size - PItem2^.Size;
end;

function compareSizeInv(Item1, Item2: Pointer): Integer;
var PItem1, PItem2: PEntList;
begin
  PItem1 := Item1;
  PItem2 := Item2;
  Result := PItem2^.Size - PItem1^.Size;
end;

function compareOffset(Item1, Item2: Pointer): Integer;
var PItem1, PItem2: PEntList;
begin
  PItem1 := Item1;
  PItem2 := Item2;
  Result := PItem1^.Offset - PItem2^.Offset;
end;

function compareOffsetInv(Item1, Item2: Pointer): Integer;
var PItem1, PItem2: PEntList;
begin
  PItem1 := Item1;
  PItem2 := Item2;
  Result := PItem2^.Offset - PItem1^.Offset;
end;

procedure TfrmList.cmdGoClick(Sender: TObject);
var header,footer,varstart: string;
    mem: TMemoryStream;
    ss,outBuf: TStringStream;
    outFile: TFileStream;
    Size,x,TotSize,per,perold: integer;
    dname, dpath, rep, perstr, fnam, dext: string;

    EntRec: PEntList;
    Data: pvirtualTreeData;
    Node: PVirtualNode;
    SortList: TList;
    posrep: integer;
begin

  SaveDialog.Filter := lstDUHT[lstTemplates.ItemIndex+1].GetInfoFromDUHT().ExtInfo + ' (*.'+lstDUHT[lstTemplates.ItemIndex+1].GetInfoFromDUHT().Ext+')|*.'+lstDUHT[lstTemplates.ItemIndex+1].GetInfoFromDUHT().Ext+ '|'+DLNGStr('ALLFIL')+'|*.*';
  SaveDialog.Title := DLNGStr('LST500');

  if SaveDialog.Execute then
  begin
    dname := SaveDialog.FileName;
    dext := extractfileext(dname);
    if (dext = '') then
      dname := dname + '.' + lstDUHT[lstTemplates.ItemIndex+1].GetInfoFromDUHT().Ext
    else if (dext = '.') then
      dname := dname + lstDUHT[lstTemplates.ItemIndex+1].GetInfoFromDUHT().Ext;
    dpath := extractfilepath(dname);

    status.simpletext := '[1/9] '+DLNGStr('LST501');
    frmList.Refresh;

    if lstDUHT[lstTemplates.ItemIndex+1].isEntry('HD') then
    begin
      mem := lstDUHT[lstTemplates.ItemIndex+1].getEntry('HD');
      size := mem.Seek(0,SoFromEnd);
      mem.Seek(0,SoFromBeginning);
      ss := TStringStream.Create('');
      ss.CopyFrom(mem,size);
      ss.Seek(0,SoFromBeginning);
      header := ss.ReadString(size);
      FreeAndNil(mem);
      FreeAndNil(ss);
    end
    else
      header := '';

    status.simpletext := '[2/9] '+DLNGStr('LST502');
    frmList.Refresh;

    if lstDUHT[lstTemplates.ItemIndex+1].isEntry('FT') then
    begin
      mem := lstDUHT[lstTemplates.ItemIndex+1].getEntry('FT');
      size := mem.Seek(0,SoFromEnd);
      mem.Seek(0,SoFromBeginning);
      ss := TStringStream.Create('');
      ss.CopyFrom(mem,size);
      ss.Seek(0,SoFromBeginning);
      footer := ss.ReadString(size);
      FreeAndNil(mem);
      FreeAndNil(ss);
    end
    else
      footer := '';

    status.simpletext := '[3/9] '+DLNGStr('LST503');
    frmList.Refresh;

    if lstDUHT[lstTemplates.ItemIndex+1].isEntry('VR') then
    begin
      mem := lstDUHT[lstTemplates.ItemIndex+1].getEntry('VR');
      size := mem.Seek(0,SoFromEnd);
      mem.Seek(0,SoFromBeginning);
      ss := TStringStream.Create('');
      ss.CopyFrom(mem,size);
      ss.Seek(0,SoFromBeginning);
      varstart := ss.ReadString(size);
      FreeAndNil(mem);
      FreeAndNil(ss);
    end
    else
    begin
      // ERROR.. VR must exist!!!
    end;

    status.simpletext := '[4/9] '+DLNGStr('LST504');
    frmList.Refresh;

    SortList := TList.Create;
    OutBuf := TStringStream.Create('');
    try
      if optSelected.Checked then
      begin
        if (dup5Main.lstContent.SelectedCount > 1) then
        begin

          rep := dup5Main.GetNodePath2(dup5Main.lstIndex2.FocusedNode);
          if length(rep) > 0 then
            rep := rep + FSE.SlashMode;

          header := macroHeader(header, rep);

          Node := dup5Main.lstContent.GetFirstSelected;

          while (Node <> nil) do
          begin
            Data := dup5Main.lstContent.GetNodeData(Node);

            New(EntRec);
            EntRec^.FileName := Copy(Data.data^.Name, Data.tdirpos+1,length(Data.data^.Name)-Data.tdirpos);
            EntRec^.Offset := Data.data^.Offset ;
            EntRec^.Size := Data.data^.Size;
            SortList.Add(EntRec);

            Node := dup5Main.lstContent.GetNextSelected(Node);
          end;
        end;
      end
      else if optCurrentDir.Checked then
      begin

        rep := dup5Main.GetNodePath2(dup5Main.lstIndex2.FocusedNode);
        if length(rep) > 0 then
          rep := rep + FSE.SlashMode;

        header := macroHeader(header, rep);

        SortList := FSE.BrowseDirToList(rep,chkSubDirs.Checked);

      end
      else
      begin

        header := macroHeader(header, '');

        SortList := FSE.BrowseDirToList('',true);

      end;

      status.simpletext := '[5/9] '+ReplaceValue('%v',DLNGStr('LST505'),inttostr(SortList.Count));
      frmList.Refresh;

      if chkSort.Checked then
       if optSortAlpha.Checked then
       begin
        if optSortInvert.Checked then
        begin
          SortList.Sort(@CompareAlphaInv);
        end
        else
        begin
          SortList.Sort(@CompareAlpha);
        end;
       end
       else if optSortSize.Checked then
       begin
        if optSortInvert.Checked then
        begin
          SortList.Sort(@CompareSizeInv);
        end
        else
        begin
          SortList.Sort(@CompareSize);
        end;
       end
       else  // Tri par offset
       begin
        if optSortInvert.Checked then
        begin
          SortList.Sort(@CompareOffsetInv);
        end
        else
        begin
          SortList.Sort(@CompareOffset);
        end;
       end;

      status.simpletext := '[6/9] '+ReplaceValue('%p',ReplaceValue('%v',DLNGStr('LST506'),inttostr(SortList.Count)),'0');
      frmList.Refresh;

      OutBuf.WriteString(header);

      TotSize := 0;
      perold := 0;

      perstr := ReplaceValue('%v',DLNGStr('LST506'),inttostr(SortList.Count));

      for x := 0 to SortList.Count-1 do
      begin
        per := Round(((x+1) / SortList.Count)*100);
        if per >= (perold+5) then
        begin
          status.simpletext := '[6/9] '+ReplaceValue('%p',perstr,inttostr(per));
          frmList.Refresh;
          perold := per;
        end;

        EntRec := SortList.Items[x];
        posrep := posrev(FSE.SlashMode,EntRec^.FileName);
        if posrep = (length(EntRec^.FileName)+1) then
        begin
          rep := '';
          Fnam := EntRec^.FileName;
        end
        else
        begin
          rep := LeftStr(EntRec^.FileName,posrep);
          Fnam := RightStr(EntRec^.FileName,length(EntRec^.FileName)-posrep);
        end;

        OutBuf.WriteString(macroVar(varstart,rep,FNam,DescFromExt(ExtractFileExt(EntRec^.FileName)),EntRec^.Offset,EntRec^.Size,EntRec^.DataX,EntRec^.DataY));
        inc(TotSize,EntRec^.Size);
      end;

      OutBuf.WriteString(macroFooter(footer,rep,TotSize,SortList.Count));

      status.simpletext := '[7/9] '+DLNGStr('LST507');
      frmList.Refresh;

      if FileExists(dname) then
        DeleteFile(dname);

      OutFile := TFileStream.Create(dname,fmCreate);
      try
        OutBuf.Seek(0,0);
        OutFile.CopyFrom(OutBuf,OutBuf.Size);
      finally
        FreeAndNil(OutFile);
      end;

    finally
      for x := 0 to (SortList.Count - 1) do
      begin
        EntRec := SortList.Items[x];
        Dispose(EntRec);
      end;
      FreeAndNil(SortList);
      FreeAndNil(OutBuf);
    end;

//    footer := macroFooter(footer, '');

    status.simpletext := '[8/9] '+DLNGStr('LST508');
    frmList.Refresh;

    lstDUHT[lstTemplates.ItemIndex+1].extractIM(dpath);

    status.simpletext := '[9/9] '+DLNGStr('LST509');
    frmList.Refresh;

    ShowMessage(DLNGStr('LST509'));
    frmList.Close;

  end;

end;

function TfrmList.macroHeader(src, cdir: string): string;
var i,j: integer;
    keyw: string;
begin

  i := 0;
  repeat
    i := PosEx('$$FILENAME$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+ExtractFilename(FSE.GetFileName)+RightStr(src,Length(src)-(i+11));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$DIRECTORY$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+cdir+RightStr(src,Length(src)-(i+12));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$DUPVER$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+CurVersion+RightStr(src,Length(src)-(i+9));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$DUPEDIT$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+CurEdit+RightStr(src,Length(src)-(i+10));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$DUPURL$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+CurURL+RightStr(src,Length(src)-(i+9));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$FORMAT$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+FSE.DriverID+RightStr(src,Length(src)-(i+9));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$LNG<',uppercase(src),i+1);
    if i > 0 then
    begin
      j := PosEx('>$$',uppercase(src),i+1);
      keyw := LeftStr(MidStr(src,i+6,j-1),6);
      src := LeftStr(src,i-1)+DLNGStr(keyw)+RightStr(src,Length(src)-(j+2));
    end;
  until i = 0;

  result := src;

end;

function TfrmList.macroFooter(src, cdir: string; totSize: int64;
  totE: integer): string;
var i: integer;
begin

  src := macroHeader(src,cdir);

  i := 0;
  repeat
    i := PosEx('$$TOTNUMFILES$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+IntToStr(totE)+RightStr(src,Length(src)-(i+14));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$TOTNUMBYTES$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+IntToStr(totSize)+RightStr(src,Length(src)-(i+14));
    end;
  until i = 0;

  result := src;

end;

function TfrmList.macroVar(src, cdir, fnam, desc: string; offset,
  size: int64; datax, datay: integer): string;
var i: integer;
    tmp: string;
begin

  i := 0;
  repeat
    i := PosEx('$$FILENAME$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+ExtractFilename(FSE.GetFileName)+RightStr(src,Length(src)-(i+11));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$DIRECTORY$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+cdir+RightStr(src,Length(src)-(i+12));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$FILE$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+ExtractFilename(fnam)+RightStr(src,Length(src)-(i+7));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$FILE0$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+ChangeFileExt(ExtractFilename(fnam),'')+RightStr(src,Length(src)-(i+8));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$FILEEXT$$',uppercase(src),i+1);
    if i > 0 then
    begin
      tmp := ExtractFileExt(fnam);
      if length(tmp) > 1 then
        tmp := RightStr(tmp,Length(tmp)-1)
      else if length(tmp) = 1 then
        tmp := '';
      src := LeftStr(src,i-1)+tmp+RightStr(src,Length(src)-(i+10));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$DESC$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+desc+RightStr(src,Length(src)-(i+7));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$SIZE$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+inttostr(size)+RightStr(src,Length(src)-(i+7));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$HSIZE$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+inttohex(size,8)+RightStr(src,Length(src)-(i+8));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$OFFSET$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+inttostr(offset)+RightStr(src,Length(src)-(i+9));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$HOFFSET$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+inttohex(offset,16)+RightStr(src,Length(src)-(i+10));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$DATAX$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+inttostr(datax)+RightStr(src,Length(src)-(i+8));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$HDATAX$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+inttohex(datax,8)+RightStr(src,Length(src)-(i+9));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$DATAY$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+inttostr(datay)+RightStr(src,Length(src)-(i+8));
    end;
  until i = 0;

  i := 0;
  repeat
    i := PosEx('$$HDATAY$$',uppercase(src),i+1);
    if i > 0 then
    begin
      src := LeftStr(src,i-1)+inttohex(datay,8)+RightStr(src,Length(src)-(i+9));
    end;
  until i = 0;

  result := src;

end;

procedure TfrmList.chkSortClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\ListCreation',True) then
    begin
      Reg.WriteBool('SortList',chkSort.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  grp3.Enabled := chkSort.Checked;
  panSortDisabled.Visible := not(chkSort.Checked);

end;

procedure TfrmList.optSelectedClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\ListCreation',True) then
    begin
      Reg.WriteInteger('Style',0);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmList.optAllClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\ListCreation',True) then
    begin
      Reg.WriteInteger('Style',1);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmList.optCurrentDirClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\ListCreation',True) then
    begin
      Reg.WriteInteger('Style',2);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmList.chkSubDirsClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\ListCreation',True) then
    begin
      Reg.WriteBool('RecurseSubDir',chkSubDirs.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmList.optSortInvertClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\ListCreation',True) then
    begin
      Reg.WriteBool('SortInv',optSortInvert.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmList.optSortAlphaClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\ListCreation',True) then
    begin
      Reg.WriteInteger('SortStyle',0);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmList.optSortSizeClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\ListCreation',True) then
    begin
      Reg.WriteInteger('SortStyle',1);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmList.optSortOffsetClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\ListCreation',True) then
    begin
      Reg.WriteInteger('SortStyle',2);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmList.FormHide(Sender: TObject);
begin

  clearUHT;

end;

end.
