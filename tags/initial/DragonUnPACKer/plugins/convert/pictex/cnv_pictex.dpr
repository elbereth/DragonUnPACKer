library cnv_pictex;

// $Id: cnv_pictex.dpr,v 1.1.1.1 2004-05-08 10:26:52 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/convert/pictex/cnv_pictex.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is cnv_pictex.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

uses
  Windows,
  Forms,
  StrUtils,
  SysUtils,
  Classes,
  Registry,
  Controls,
  class_Images in 'class_Images.pas',
  Convert in 'Convert.pas' {frmConvert},
  lib_version in '..\..\..\common\lib_version.pas',
  spec_DPAL in '..\..\..\common\spec_DPAL.pas';

{$E d5c}

{$R *.res}

type ConvertListElem = record
       Display: ShortString;
       Ext: ShortString;
       ID: ShortString;
     end;
     ConvertList = record
       NumFormats :  Byte;
       List : array[1..255] of ConvertListElem;
     end;
     ConvertInfo = record
       Name: ShortString;
       Version: ShortString;
       Author: ShortString;
       Comment: ShortString;
       VerID: Integer;
     end;
     TPercentCallback = procedure (p: byte);
     TLanguageCallback = function (lngid: ShortString): ShortString;
//     EBadType = class(Exception);

var Percent: TPercentCallback;
    DLNGStr: TLanguageCallback;
    CurPath: ShortString;
    palfil: string;
    AHandle: THandle;
    AOwner: TComponent;

const DRIVER_VERSION = 10510;
const DUP_VERSION = 50040;

{ * Version History:
  * v1.0.0 Alpha (10000): First version (never distributed)
  * v1.0.0 Beta  (10010): Renamed to Pictures/Textures convert plugin
  * v1.0.1 Beta  (10110): Now the plugins remind last used palette
  * v1.0.2 Beta  (10210): Added palette convertion
  * v1.0.3 Beta  (10310): Added Bloodrayne TEX support
  * v1.0.4 Beta  (10410): Using DUCI v2
  *                       Added palette management in config box
  * v1.0.5 Beta  (10510): Fixed some bugs in palette creator (author/name)
  * }

function DUCIVersion: Byte; stdcall;
begin
  Result := 2;
end;

function VersionInfo(): ConvertInfo;
begin

  result.Name := 'Elbereth''s Picture/Textures convert plugin';
  result.Version := getVersion(DRIVER_VERSION);
  result.Author := 'Alexandre Devilliers (aka Elbereth)';
  result.Comment := 'Converting pictures and textures? Yeah!';
  result.VerID := DRIVER_VERSION;

end;

function IsFileCompatible(nam: ShortString; Offset, Size: Int64; fmt: ShortString; DataX, DataY: Integer): boolean; stdcall;
begin

  result := false;

//  ShowMessage(inttostr(DataX)+#10+fmt+#10+LeftStr(nam,8)+#10+inttostr(Size));

  if (fmt = 'WAD2') or (fmt = 'WAD3') then
  begin
    case DataX of
      66: result := true;
      67: result := true;
      68: result := true;
      69: begin
            if ((Size = 16384) or (Size = 64000)) then
              result := true;
          end;
    end;
  end
  else if (fmt = 'POD3') and (uppercase(extractfileext(nam)) = '.TEX') then
    result := true
  else if (fmt = 'ART') then
    result := true;

end;

function GetFileConvert(nam: ShortString; Offset, Size: Int64; fmt: ShortString; DataX, DataY: Integer): ConvertList; stdcall;
begin

  if (fmt = 'WAD2') or (fmt = 'WAD3') then
  begin
    case DataX of
      66: begin
            result.NumFormats := 3;
{            result.List[1].Display := 'PCX - ZSoft Paintbrush (8bpp RLE)';
            result.List[1].Ext := 'PCX';
            result.List[1].ID := 'PCX';}
            result.List[1].Display := 'BMP - Windows BitMaP (8bpp)';
            result.List[1].Ext := 'BMP';
            result.List[1].ID := 'BMP';
            result.List[2].Display := 'TGA - Targa (8bpp Colormap)';
            result.List[2].Ext := 'TGA';
            result.List[2].ID := 'TGA8';
            result.List[3].Display := 'TGA - Targa (24bpp)';
            result.List[3].Ext := 'TGA';
            result.List[3].ID := 'TGA24';
          end;
      67: begin
            result.NumFormats := 3;
{            result.List[1].Display := 'PCX - ZSoft Paintbrush (8bpp RLE)';
            result.List[1].Ext := 'PCX';
            result.List[1].ID := 'PCX';}
            result.List[1].Display := 'BMP - Windows BitMaP (8bpp)';
            result.List[1].Ext := 'BMP';
            result.List[1].ID := 'BMP';
            result.List[2].Display := 'TGA - Targa (8bpp Colormap)';
            result.List[2].Ext := 'TGA';
            result.List[2].ID := 'TGA8';
            result.List[3].Display := 'TGA - Targa (24bpp)';
            result.List[3].Ext := 'TGA';
            result.List[3].ID := 'TGA24';
            result.List[4].Display := 'M8 - Heretic 2 MipMap (8bpp)';
            result.List[4].Ext := 'M8';
            result.List[4].ID := 'M8';
            result.List[5].Display := 'WAL - Quake  2 MipMap (8bpp)';
            result.List[5].Ext := 'WAL';
            result.List[5].ID := 'WAL';
          end;
      68: begin
            result.NumFormats := 3;
{            result.List[1].Display := 'PCX - ZSoft Paintbrush (8bpp RLE)';
            result.List[1].Ext := 'PCX';
            result.List[1].ID := 'PCX';}
            result.List[1].Display := 'BMP - Windows BitMaP (8bpp)';
            result.List[1].Ext := 'BMP';
            result.List[1].ID := 'BMP';
            result.List[2].Display := 'TGA - Targa (8bpp Colormap)';
            result.List[2].Ext := 'TGA';
            result.List[2].ID := 'TGA8';
            result.List[3].Display := 'TGA - Targa (24bpp)';
            result.List[3].Ext := 'TGA';
            result.List[3].ID := 'TGA24';
          end;
      69: begin
            if ((Size = 16384) or (Size = 64000)) then
            begin
              result.NumFormats := 3;
{            result.List[1].Display := 'PCX - ZSoft Paintbrush (8bpp RLE)';
            result.List[1].Ext := 'PCX';
            result.List[1].ID := 'PCX';}
              result.List[1].Display := 'BMP - Windows BitMaP (8bpp)';
              result.List[1].Ext := 'BMP';
              result.List[1].ID := 'BMP';
              result.List[2].Display := 'TGA - Targa (8bpp Colormap)';
              result.List[2].Ext := 'TGA';
              result.List[2].ID := 'TGA8';
              result.List[3].Display := 'TGA - Targa (24bpp)';
              result.List[3].Ext := 'TGA';
              result.List[3].ID := 'TGA24';
            end;
          end;
    end;
  end
  else if (fmt = 'POD3') and (uppercase(extractfileext(nam)) = '.TEX') then
  begin
    result.NumFormats := 3;
    result.List[1].Display := 'BMP - Windows BitMaP (8bpp)';
    result.List[1].Ext := 'BMP';
    result.List[1].ID := 'BMP';
    result.List[2].Display := 'TGA - Targa (8bpp Colormap)';
    result.List[2].Ext := 'TGA';
    result.List[2].ID := 'TGA8';
    result.List[3].Display := 'TGA - Targa (24bpp)';
    result.List[3].Ext := 'TGA';
    result.List[3].ID := 'TGA24';
  end
  else if (fmt = 'ART') then
  begin
    result.NumFormats := 3;
    result.List[1].Display := 'BMP - Windows BitMaP (8bpp)';
    result.List[1].Ext := 'BMP';
    result.List[1].ID := 'BMP';
    result.List[2].Display := 'TGA - Targa (8bpp Colormap)';
    result.List[2].Ext := 'TGA';
    result.List[2].ID := 'TGA8';
    result.List[3].Display := 'TGA - Targa (24bpp)';
    result.List[3].Ext := 'TGA';
    result.List[3].ID := 'TGA24';
  end;

end;

function GetDPALName(fil: string): string;
var dpal:integer;
    HDR: DPALHeader;
begin

  result := '';

  if FileExists(fil) then
  begin
    dpal := FileOpen(fil,fmOpenRead);
    try
      if FileSeek(dpal,0,2) = 1024 then
      begin
        FileSeek(dpal,0,0);
        FileRead(dpal,HDR.ID,5);
        FileRead(dpal,HDR.Version,1);
        FileRead(dpal,HDR.Game,100);
        FileRead(dpal,HDR.Author,100);
        FileRead(dpal,HDR.Reserved,50);
        if (HDR.ID = 'DPAL'+chr(26)) and (HDR.Version = 1) then
        begin
          result := TrimRight(HDR.Game);
        end;
      end;
    finally
      FileClose(dpal);
    end;
  end;

end;

function ConvertART(src, dst, pal: string; w, h: integer; cnv: String): integer;
var Img: TSaveImage;
    hSRC,x,y: integer;
    Buffer: PByteArray;
begin

  result := 0;

  img := TSaveImage.Create;
  try
    img.LoadPAL(pal);
    hSRC := FileOpen(src,fmOpenRead or fmShareDenyWrite);
    GetMem(Buffer,W*H);
    try
      img.SetSize(W,H);
      FileRead(hSRC,Buffer^,W*H);
      for y := 0 to H-1 do
        for x := 0 to W-1 do
          img.Pixels[x][y] := Buffer[x*H+y];
      if cnv = 'BMP' then
        img.SaveToBMP(dst)
//      else if cnv = 'PCX' then
//        img.SaveToPCX(dst)
      else if cnv = 'TGA8' then
        img.SaveToTGA8(dst)
      else if cnv = 'TGA24' then
        img.SaveToTGA24(dst);
    finally
      FreeMem(Buffer);
      FileClose(hSRC);
    end;
  finally
    img.Free;
  end;

end;

function ConvertWAD242(src, dst, pal, cnv: String): integer;
var Img: TSaveImage;
    hSRC,W,H,x,y: integer;
    Buffer: PByteArray;
begin

  result := 0;

  img := TSaveImage.Create;
  try
    img.LoadPAL(pal);
    hSRC := FileOpen(src,fmOpenRead or fmShareDenyWrite);
    try
      FileRead(hSRC,W,4);
      FileRead(hSRC,H,4);
      img.SetSize(W,H);
      GetMem(Buffer,W*H);
      try
        FileRead(hSRC,Buffer^,W*H);
        for y := 0 to H-1 do
          for x := 0 to W-1 do
            img.Pixels[x][y] := Buffer[y*W+x];
      finally
        FreeMem(Buffer);
      end;
      if cnv = 'BMP' then
        img.SaveToBMP(dst)
//      else if cnv = 'PCX' then
//        img.SaveToPCX(dst)
      else if cnv = 'TGA8' then
        img.SaveToTGA8(dst)
      else if cnv = 'TGA24' then
        img.SaveToTGA24(dst);
    finally
      FileClose(hSRC);
    end;
  finally
    img.Free;
  end;

end;

function ConvertWAD343(src, dst, cnv: String): integer;
var Img: TSaveImage;
    hSRC,W,H,x,y: integer;
    HDR: WAD2MipMap;
    Buffer: PByteArray;
//    StartTime: TDateTime;
begin

  result := 0;
//  StartTime := Now;

  img := TSaveImage.Create;
  try
//    img.LoadPAL(pal);
    hSRC := FileOpen(src,fmOpenRead or fmShareDenyWrite);
    try
      FileRead(hSRC,HDR.FileName,16);
      FileRead(hSRC,HDR.Width,4);
      FileRead(hSRC,HDR.Height,4);
      FileRead(hSRC,HDR.Q1Offset,4);
      FileRead(hSRC,HDR.Q2Offset,4);
      FileRead(hSRC,HDR.Q4Offset,4);
      FileRead(hSRC,HDR.Q8Offset,4);
      FileSeek(hSRC,HDR.Q1Offset,0);
      W := HDR.Width;
      H := HDR.Height;
      img.SetSize(W,H);
      if (cnv = 'M8') or (cnv = 'WAL') then
        img.SetMipMaps(3);
      GetMem(Buffer,W*H);
      try
        FileSeek(hSRC,HDR.Q1Offset,0);
        FileRead(hSRC,Buffer^,H*W);
        for y := 0 to H-1 do
          for x := 0 to W-1 do
            img.Pixels[x][y] := Buffer[(y*W)+x];
        if (cnv = 'M8') or (cnv = 'WAL') then
        begin
          FileSeek(hSRC,HDR.Q2Offset,0);
          FileRead(hSRC,Buffer^,(H div 2)*(W div 2));
          for y := 0 to (H div 2)-1 do
            for x := 0 to (W div 2)-1 do
              img.MipMaps[0][x][y] := Buffer[(y*W)+x];
          FileSeek(hSRC,HDR.Q4Offset,0);
          FileRead(hSRC,Buffer^,(H div 2)*(W div 2));
          for y := 0 to (H div 4)-1 do
            for x := 0 to (W div 4)-1 do
              img.MipMaps[1][x][y] := Buffer[(y*W)+x];
          FileSeek(hSRC,HDR.Q8Offset,0);
          FileRead(hSRC,Buffer^,(H div 2)*(W div 2));
          for y := 0 to (H div 8)-1 do
            for x := 0 to (W div 8)-1 do
              img.MipMaps[2][x][y] := Buffer[(y*W)+x];
        end;
        FileSeek(hSRC,-770,2);
        FileRead(hSRC,Buffer^,768);
        for x := 0 to 255 do
        begin
          img.Palette[x].R := Buffer[x*3];
          img.Palette[x].G := Buffer[(x*3)+1];
          img.Palette[x].B := Buffer[(x*3)+2];
        end;
      finally
        FreeMem(Buffer);
      end;
      if cnv = 'BMP' then
        img.SaveToBMP(dst)
//      else if cnv = 'PCX' then
//        img.SaveToPCX(dst)
      else if cnv = 'TGA8' then
        img.SaveToTGA8(dst)
      else if cnv = 'TGA24' then
        img.SaveToTGA24(dst);
    finally
      FileClose(hSRC);
    end;
  finally
    img.Free;
  end;

//  ShowMessage(IntToStr(MillisecondsBetween(Now,StartTime)));

end;

function ConvertWAD244(src, dst, pal, cnv: String): integer;
var Img: TSaveImage;
    hSRC,W,H,x,y: integer;
    HDR: WAD2MipMap;
    Buffer: PByteArray;
//    StartTime: TDateTime;
begin

  result := 0;
//  StartTime := Now;

  img := TSaveImage.Create;
  try
    img.LoadPAL(pal);
    hSRC := FileOpen(src,fmOpenRead or fmShareDenyWrite);
    try
      FileRead(hSRC,HDR.FileName,16);
      FileRead(hSRC,HDR.Width,4);
      FileRead(hSRC,HDR.Height,4);
      FileRead(hSRC,HDR.Q1Offset,4);
      FileRead(hSRC,HDR.Q2Offset,4);
      FileRead(hSRC,HDR.Q4Offset,4);
      FileRead(hSRC,HDR.Q8Offset,4);
      FileSeek(hSRC,HDR.Q1Offset,0);
      W := HDR.Width;
      H := HDR.Height;
      img.SetSize(W,H);
      if (cnv = 'M8') or (cnv = 'WAL') then
        img.SetMipMaps(3);
      GetMem(Buffer,W*H);
      try
        FileSeek(hSRC,HDR.Q1Offset,0);
        FileRead(hSRC,Buffer^,H*W);
        for y := 0 to H-1 do
          for x := 0 to W-1 do
            img.Pixels[x][y] := Buffer[(y*W)+x];
        if (cnv = 'M8') or (cnv = 'WAL') then
        begin
          FileSeek(hSRC,HDR.Q2Offset,0);
          FileRead(hSRC,Buffer^,(H div 2)*(W div 2));
          for y := 0 to (H div 2)-1 do
            for x := 0 to (W div 2)-1 do
              img.MipMaps[0][x][y] := Buffer[(y*W)+x];
          FileSeek(hSRC,HDR.Q4Offset,0);
          FileRead(hSRC,Buffer^,(H div 2)*(W div 2));
          for y := 0 to (H div 4)-1 do
            for x := 0 to (W div 4)-1 do
              img.MipMaps[1][x][y] := Buffer[(y*W)+x];
          FileSeek(hSRC,HDR.Q8Offset,0);
          FileRead(hSRC,Buffer^,(H div 2)*(W div 2));
          for y := 0 to (H div 8)-1 do
            for x := 0 to (W div 8)-1 do
              img.MipMaps[2][x][y] := Buffer[(y*W)+x];
        end;
      finally
        FreeMem(Buffer);
      end;
      if cnv = 'BMP' then
        img.SaveToBMP(dst)
//      else if cnv = 'PCX' then
//        img.SaveToPCX(dst)
      else if cnv = 'TGA8' then
        img.SaveToTGA8(dst)
      else if cnv = 'TGA24' then
        img.SaveToTGA24(dst);
    finally
      FileClose(hSRC);
    end;
  finally
    img.Free;
  end;

//  ShowMessage(IntToStr(MillisecondsBetween(Now,StartTime)));

end;

function ConvertWAD245(src, dst, pal, cnv: String): integer;
var Img: TSaveImage;
    hSRC,W,H,x,y: integer;
    Buffer: PByteArray;
begin

  result := 0;

  img := TSaveImage.Create;
  try
    img.LoadPAL(pal);
    hSRC := FileOpen(src,fmOpenRead or fmShareDenyWrite);
    try
      case FileSeek(hSRC,0,2) of
        16384: begin
                 W := 128;
                 H := 128;
               end;
        64000: begin
                 W := 200;
                 H := 320;
               end;
        else
          W := 0;
          H := 0;
      end;
      FileSeek(hSRC,0,0);
      img.SetSize(W,H);
      GetMem(Buffer,W*H);
      try
        FileRead(hSRC,Buffer^,H*W);
        for y := 0 to H-1 do
          for x := 0 to W-1 do
            img.Pixels[x][y] := Buffer[(y*W)+x];
      finally
        FreeMem(Buffer);
      end;
      if cnv = 'BMP' then
        img.SaveToBMP(dst)
//      else if cnv = 'PCX' then
//        img.SaveToPCX(dst)
      else if cnv = 'TGA8' then
        img.SaveToTGA8(dst)
      else if cnv = 'TGA24' then
        img.SaveToTGA24(dst);
    finally
      FileClose(hSRC);
    end;
  finally
    img.Free;
  end;

end;

function ConvertPOD3TEX(src, dst, cnv: String): integer;
var Img: TSaveImage;
    hSRC,W,H,x,y: integer;
    HDR: POD3TEXHeader;
    Buffer: PByteArray;
//    StartTime: TDateTime;
begin

  result := 0;
//  StartTime := Now;

  img := TSaveImage.Create;
  try
//    img.LoadPAL(pal);
    hSRC := FileOpen(src,fmOpenRead or fmShareDenyWrite);
    try
      FileRead(hSRC,HDR,SizeOf(HDR));
      W := HDR.Width;
      H := HDR.Height;
      img.SetSize(W,H);
      GetMem(Buffer,W*H);
      try
        FileRead(hSRC,Buffer^,768);
        for x := 0 to 255 do
        begin
          img.Palette[x].R := Buffer[x*3];
          img.Palette[x].G := Buffer[(x*3)+1];
          img.Palette[x].B := Buffer[(x*3)+2];
        end;
        FileRead(hSRC,Buffer^,H*W);
        for y := 0 to H-1 do
          for x := 0 to W-1 do
            img.Pixels[x][y] := Buffer[(y*W)+x];
      finally
        FreeMem(Buffer);
      end;
      if cnv = 'BMP' then
        img.SaveToBMP(dst)
//      else if cnv = 'PCX' then
//        img.SaveToPCX(dst)
      else if cnv = 'TGA8' then
        img.SaveToTGA8(dst)
      else if cnv = 'TGA24' then
        img.SaveToTGA24(dst);
    finally
      FileClose(hSRC);
    end;
  finally
    img.Free;
  end;

//  ShowMessage(IntToStr(MillisecondsBetween(Now,StartTime)));

end;

function setLastPal(lastPal: string): string;
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\cnv_default.d5c',True) then
    begin
      Reg.WriteString('LastPalette',lastPal);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

function getLastPal(): string;
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  result := '';
  Try
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\cnv_default.d5c',True) then
    begin
      if Reg.ValueExists('LastPalette') then
        result := Reg.ReadString('LastPalette');
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

function SelectPal(): String;
var frmCnv: TfrmConvert;
    sr: TSearchRec;
    dpalnam: string;
    lstPALFil: TStringList;
    lastPal: string;
    lastIdx: integer;
    OApp: THandle;
begin

  result := '';
  lastIdx := 0;
  lastPal := getLastPal();
  OApp := Application.Handle;
  Application.Handle := AHandle;
  frmCnv := TfrmConvert.Create(AOwner);
  lstPALFil := TStringList.Create;
  try
    if FindFirst(CurPath+'*.dpal',faAnyFile,sr) = 0 then
    begin
      repeat
        if not((sr.Attr and faDirectory) = faDirectory) then
        begin
          dpalnam := GetDPALName(CurPath+sr.Name);
          if dpalnam <>'' then
          begin
            frmCnv.lstPal.Items.Add(dpalnam);
            lstPALFil.Add(sr.Name);
            if (sr.name = lastPal) then
              lastIdx := frmCnv.lstPal.Items.Count-1;
          end;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
    if frmCnv.lstPal.Items.Count > 0 then
      frmCnv.lstPal.ItemIndex := lastIdx;
//    frmCnv.ParentWindow := MainhWnd;
    frmCnv.cmdGo.Tag := 0;
    frmCnv.Caption := DLNGStr('CNV000');
    frmCnv.grpPal.Caption := DLNGStr('CNV001');
    frmCnv.cmdAdd.Caption := DLNGStr('BUTADD');
    frmCnv.cmdGo.Caption := DLNGStr('BUTCNV');
    frmCnv.curPath := CurPath;
    frmCnv.errorMessage := DLNGstr('CNV900');
    frmCnv.successMessage := DLNGstr('CNV901');
    frmCnv.cnv990 := DLNGstr('CNV990');
    frmCnv.cnv991 := DLNGstr('CNV991');
    frmCnv.cnv120 := DLNGstr('CNV120');
    frmCnv.txtName.Text := frmCnv.cnv120;
    frmCnv.txtAuthor.Text := frmCnv.cnv120;
    frmCnv.lstPALFil := lstPALFil;
    frmCnv.grpAdd.Caption := DLNGstr('CNV100');
    frmCnv.lblSource.Caption := DLNGstr('CNV101');
    frmCnv.lblName.Caption := DLNGstr('CNV102');
    frmCnv.lblAuthor.Caption := DLNGstr('CNV103');
    frmCnv.lblFormat.Caption := DLNGstr('CNV104');
    frmCnv.cmdAddPal.Caption := DLNGstr('BUTPAL');
    frmCnv.cmdRemove.Caption := DLNGstr('BUTDEL');
    frmCnv.OpenDialog.Filter := 'Palettes|*.pcx;*.bmp;*.pal;*.psppalette;*.bin;*.raw|Windows BitMaP (*.BMP)|*.bmp|Microsoft Palette (*.PAL)|*.pal|Jasc PSP Palette (*.PSPPALETTE)|*.psppalette|'+DLNGStr('CNV110')+' (*.*)|*.*|ZSoft Paintbrush v5 (*.PCX)|*.pcx';
    frmCnv.cmdRemove.Visible := False;
    frmCnv.cmdAdd.Visible := true;
    frmCnv.Height := 87;
    frmCnv.ShowModal;
    if frmCnv.cmdGo.Tag = -1 then
    begin
      result := CurPath+lstPALFil.Strings[frmCnv.lstPal.ItemIndex];
      setLastPal(lstPALFil.Strings[frmCnv.lstPal.ItemIndex]);
    end;
  finally
    frmCnv.Release;
    lstPALFil.Free;
  end;
  Application.Handle := OApp;

end;

function Convert(src, dst, nam, fmt, cnv: ShortString; Offset: Int64; DataX, DataY: Integer; Silent: Boolean): integer; stdcall;
var Size: int64;
    hTMP: integer;
begin

  result := 0;

  if (fmt = 'WAD2') or (fmt = 'WAD3') then
  begin
    case DataX of
      66: begin
            if not(Silent) or (palfil = '') then
              palfil := SelectPal;
            result := ConvertWAD242(src,dst,palfil,cnv);
          end;
      67: result := ConvertWAD343(src,dst,cnv);
      68: begin
            hTMP := FileOpen(src,fmOpenRead);
            try
              Size := FileSeek(hTMP,0,2);
            finally
              FileClose(hTMP);
            end;
            if ((fmt = 'WAD2') and (Uppercase(LeftStr(nam,8))='CONCHARS') and (Size = 16384)) then
            begin
              if not(Silent) or (palfil = '') then
                palfil := SelectPal;
              result := ConvertWAD245(src,dst,palfil,cnv);
            end
            else
            begin
              if not(Silent) or (palfil = '') then
                palfil := SelectPal;
              result := ConvertWAD244(src,dst,palfil,cnv);
            end;
          end;
      69: begin
            if not(Silent) or (palfil = '') then
              palfil := SelectPal;
            result := ConvertWAD245(src,dst,palfil,cnv);
          end;
    end;
  end
  else if (fmt = 'POD3') and (uppercase(extractfileext(nam)) = '.TEX') then
  begin
    result := ConvertPOD3TEX(src,dst,cnv);
  end
  else if (fmt = 'ART') then
  begin
    if not(Silent) or (palfil = '') then
      palfil := SelectPal;
    result := ConvertART(src,dst,palfil,DataX,DataY,cnv);
  end;


end;

procedure InitPlugin(per: TPercentCallback; lngid: TLanguageCallback; DUP5Path: ShortString; AppHandle: THandle; AppOwner: TComponent); stdcall;
begin

  Percent := per;
  DLNGStr := lngid;
  CurPath := DUP5Path;
  AHandle := AppHandle;
  AOwner := AppOwner;

end;

procedure AboutBox; stdcall;
begin

  MessageBoxA(AHandle, PChar('Elbereth''s Picture/Textures convert plugin v'+getVersion(DRIVER_VERSION)+#10+
                          '(c)Copyright 2002-2004 Alexandre Devilliers'+#10+#10+
                          'Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+#10+#10+
                          DLNGStr('CNV010')
                          )
                        , 'About Elbereth''s Picture/Textures convert plugin...', MB_OK);

end;

procedure ConfigBox; stdcall;
var frmCnv: TfrmConvert;
    sr: TSearchRec;
    dpalnam: string;
    lstPALFil: TStringList;
    lastPal: string;
    lastIdx: integer;
    OApp: THandle;
begin

  lastIdx := 0;
  lastPal := getLastPal();
  OApp := Application.Handle;
  Application.Handle := AHandle;
  frmCnv := TfrmConvert.Create(AOwner);
  lstPALFil := TStringList.Create;
  try
    if FindFirst(CurPath+'*.dpal',faAnyFile,sr) = 0 then
    begin
      repeat
        if not((sr.Attr and faDirectory) = faDirectory) then
        begin
          dpalnam := GetDPALName(CurPath+sr.Name);
          if dpalnam <>'' then
          begin
            frmCnv.lstPal.Items.Add(dpalnam);
            lstPALFil.Add(sr.Name);
            if (sr.name = lastPal) then
              lastIdx := frmCnv.lstPal.Items.Count-1;
          end;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
    if frmCnv.lstPal.Items.Count > 0 then
      frmCnv.lstPal.ItemIndex := lastIdx;
//    frmCnv.ParentWindow := MainhWnd;
    frmCnv.cmdGo.Tag := 0;
    frmCnv.Caption := DLNGStr('CNV000');
    frmCnv.grpPal.Caption := DLNGStr('CNV001');
    frmCnv.cmdAdd.Caption := DLNGStr('BUTADD');
    frmCnv.cmdGo.Caption := DLNGStr('BUTOK');
    frmCnv.curPath := CurPath;
    frmCnv.errorMessage := DLNGstr('CNV900');
    frmCnv.successMessage := DLNGstr('CNV901');
    frmCnv.cnv990 := DLNGstr('CNV990');
    frmCnv.cnv991 := DLNGstr('CNV991');
    frmCnv.cnv992 := DLNGstr('CNV992');
    frmCnv.cnv120 := DLNGstr('CNV120');
    frmCnv.txtName.Text := frmCnv.cnv120;
    frmCnv.txtAuthor.Text := frmCnv.cnv120;
    frmCnv.lstPALFil := lstPALFil;
    frmCnv.grpAdd.Caption := DLNGstr('CNV100');
    frmCnv.lblSource.Caption := DLNGstr('CNV101');
    frmCnv.lblName.Caption := DLNGstr('CNV102');
    frmCnv.lblAuthor.Caption := DLNGstr('CNV103');
    frmCnv.lblFormat.Caption := DLNGstr('CNV104');
    frmCnv.cmdAddPal.Caption := DLNGstr('BUTPAL');
    frmCnv.cmdRemove.Caption := DLNGstr('BUTREM');
    frmCnv.OpenDialog.Filter := 'Palettes|*.pcx;*.bmp;*.pal;*.psppalette;*.bin;*.raw|Windows BitMaP (*.BMP)|*.bmp|Microsoft Palette (*.PAL)|*.pal|Jasc PSP Palette (*.PSPPALETTE)|*.psppalette|'+DLNGStr('CNV110')+' (*.*)|*.*|ZSoft Paintbrush v5 (*.PCX)|*.pcx';
    frmCnv.cmdRemove.Visible := true;
    frmCnv.cmdAdd.Visible := false;
    frmCnv.Height := 217;
    frmCnv.ShowModal;
    if frmCnv.cmdGo.Tag = -1 then
    begin
      setLastPal(lstPALFil.Strings[frmCnv.lstPal.ItemIndex]);
    end;
  finally
    frmCnv.Release;
    lstPALFil.Free;
  end;
  Application.Handle := OApp;

end;

exports
  DUCIVersion,
  Convert,
  GetFileConvert,
  IsFileCompatible,
  VersionInfo,
  InitPlugin,
  ConfigBox,
  AboutBox;

begin
end.
