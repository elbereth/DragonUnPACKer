unit class_Images;

// $Id: class_Images.pas,v 1.1.1.1 2004-05-08 10:26:52 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/convert/pictex/class_Images.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is class_Images.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

type TCouleur = record
       R: byte;
       G: byte;
       B: byte;
       A: byte;
     end;
     DPALHeader = packed record
       ID: array[0..4] of char;
       Version: Byte;
       Game: array[0..99] of char;
       Author: array[0..99] of char;
       Reserved: array[1..50] of byte;
     end;
     BMPHeader = packed record
       ID: array[0..1] of char;
       Size: integer;
       Reserved1: word;
       Reserved2: word;
       Offset: integer;
       ID2: integer;
       Width: integer;
       height: integer;
       Planes: word;
       Bpp: word;
       Compression: integer;
       SizeImage: integer;
       XPPM: integer;
       YPPM: integer;
       ColorsUsed: integer;
       ColorsImportant: integer;
     end;
     TGAHeader = packed record
       IDFieldLength: byte;
       ColorMapType: byte;
       ImageType: byte;
       CMOrigin: word;
       CMLength: word;
       CMSize: byte;
       ImgXOrig: word;
       ImgYOrig: word;
       ImgWidth: word;
       ImgHeight: word;
       ImgPixelSize: byte;
       ImgDesc: byte;
     end;
     PCXHeaderWindow = packed record
       XMin: word;
       YMin: word;
       XMax: word;
       YMax: word;
     end;
     PCX_RGB = packed record
       R: byte;
       G: byte;
       B: byte;
     end;
     PCXHeader = packed record
       Manufacturer: byte;
       Version: byte;
       Encoding: byte;
       Bpp: byte;
       Window: PCXHeaderWindow;
       HRes: word;
       VRes: word;
       Colormap: array [0..15] of PCX_RGB;
       Reserved: byte;
       NPlanes: byte;
       BytesPerLine: word;
       PaletteInfo: word;
       Filler: array[1..58] of byte;
     end;
     WAD2MipMap = packed record
       FileName: array[0..15] of char;
       Width: integer;
       Height: integer;
       Q1Offset: integer;
       Q2Offset: integer;
       Q4Offset: integer;
       Q8Offset: integer;
     end;
     POD3TEXHeader = packed record
       ID: integer; // 2
       Unk1: Integer;
       Width: integer;
       Height: integer;
       Unk2: Integer;
       MipMap: integer;
     end;

type TSaveImage = class
    function LoadPAL(dpalfil: string): boolean;
    procedure SaveToBMP(fil: String);
    procedure SaveToPCX(fil: String);
    procedure SaveToTGA8(fil: String);
    procedure SaveToTGA24(fil: String);
    procedure SetSize(x, y: Integer);
    procedure SetMipMaps(n: Integer);
    procedure GenerateMipMaps();
    function Height(): Integer;
    function Weight(): Integer;
  private
    H: Integer;
    W: Integer;
  protected
  public
    Pixels: array of array of byte;
    MipMaps: array of array of array of byte;
    NumMM: integer;
    MMHeight: array of integer;
    MMWidth: array of integer;
    Palette: array[0..255] of TCouleur;
end;

implementation

uses SysUtils, Dialogs;

{ TSaveImage }

procedure TSaveImage.GenerateMipMaps;
begin

  // TO DO //

end;

function TSaveImage.Height: Integer;
begin

  Result := H;

end;

function TSaveImage.LoadPAL(dpalfil: string): boolean;
var dpal,x:integer;
    HDR: DPALHeader;
begin

  result := false;

  if FileExists(dpalfil) then
  begin
    dpal := FileOpen(dpalfil,fmOpenRead);
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
          for x := 0 to 255 do
          begin
            Palette[x].A := 0;
            FileRead(dpal,Palette[x].R,1);
            FileRead(dpal,Palette[x].G,1);
            FileRead(dpal,Palette[x].B,1);
          end;
          result := true;
        end;
      end;
    finally
      FileClose(dpal);
    end;
  end;

end;

procedure TSaveImage.SaveToBMP(fil: String);
var HDR: BMPHeader;
    x,y,bmp,atend,BufSize: integer;
    Buffer: PByteArray;
begin

  bmp := FileCreate(fil,fmOpenWrite or fmShareDenyWrite);

  try
    HDR.ID[0] := 'B';
    HDR.ID[1] := 'M';
    HDR.Size := (W * H) + 1078;
    HDR.Reserved1 := 0;
    HDR.Reserved2 := 0;
    HDR.Offset := 1078;
    HDR.ID2 := 40;
    HDR.Width := W;
    HDR.height := H;
    HDR.Planes := 1;
    HDR.Bpp := 8;
    HDR.Compression := 0;
    if (W - ((W div 4)*4)) > 0 then
      atend := 4 - (W - ((W div 4)*4))
    else
      atend := 0;
//    Showmessage(inttostr(w)+#10+inttostr(atend)+#10+inttostr(W+Atend));
//    atend := 0;
    HDR.SizeImage := (W + atend) * H;
    HDR.XPPM := 0;
    HDR.YPPM := 0;
    HDR.ColorsUsed := 256;
    HDR.ColorsImportant := 256;

    FileWrite(bmp,HDR.ID,2);
    FileWrite(bmp,HDR.Size,4);
    FileWrite(bmp,HDR.Reserved1,2);
    FileWrite(bmp,HDR.Reserved2,2);
    FileWrite(bmp,HDR.Offset,4);
    FileWrite(bmp,HDR.ID2,4);
    FileWrite(bmp,HDR.Width,4);
    FileWrite(bmp,HDR.height,4);
    FileWrite(bmp,HDR.Planes,2);
    FileWrite(bmp,HDR.Bpp,2);
    FileWrite(bmp,HDR.Compression,4);
    FileWrite(bmp,HDR.SizeImage,4);
    FileWrite(bmp,HDR.XPPM,4);
    FileWrite(bmp,HDR.YPPM,4);
    FileWrite(bmp,HDR.ColorsUsed,4);
    FileWrite(bmp,HDR.ColorsImportant,4);

    BufSize := (W+atend)*H;
    if BufSize < 1024 then
      BufSize := 1024;

    GetMem(Buffer,BufSize);
    try
      for x := 0 to 255 do
      begin
        Buffer[(x*4)] := Palette[x].B;
        Buffer[(x*4)+1] := Palette[x].G;
        Buffer[(x*4)+2] := Palette[x].R;
        Buffer[(x*4)+3] := Palette[x].A;
      end;
      FileWrite(bmp,Buffer^,1024);

      for y := H-1 downto 0 do
      begin
        for x := 0 to W-1 do
          Buffer[(((H-1)-y)*(W+atend))+x] := Pixels[x][y];
        for x := 1 to atend do
          Buffer[(((H-1)-y)*(W+atend))+W-1+x] := 0;
      end;
      FileWrite(bmp,Buffer^,(W+atend)*H);
    finally
      FreeMem(Buffer);
    end;
  finally
    FileClose(bmp);
  end;

end;

procedure TSaveImage.SaveToPCX(fil: String);
var HDR: PCXHeader;
    x,y,i,pcx: integer;
    tmpb: byte;
begin

  pcx := FileCreate(fil,fmOpenWrite or fmShareDenyWrite);

  try
    HDR.Manufacturer := 10;
    HDR.Version := 5;
    HDR.Encoding := 1;
    HDR.Bpp := 8;
    HDR.Window.XMin := 0;
    HDR.Window.YMin := 0;
    HDR.Window.XMax := W-1;
    HDR.Window.YMax := H-1;
    HDR.HRes := 0;
    HDR.VRes := 0;
    HDR.NPlanes := 1;
    HDR.BytesPerLine := W;
    HDR.PaletteInfo := 1;
    FillChar(HDR.Colormap,48,0);
    HDR.Reserved := 0;
    FillChar(HDR.Filler,58,0);

    FileWrite(pcx,HDR.Manufacturer,1);
    FileWrite(pcx,HDR.Version,1);
    FileWrite(pcx,HDR.Encoding,1);
    FileWrite(pcx,HDR.Bpp,1);
    FileWrite(pcx,HDR.Window.XMin,2);
    FileWrite(pcx,HDR.Window.YMin,2);
    FileWrite(pcx,HDR.Window.XMax,2);
    FileWrite(pcx,HDR.Window.YMax,2);
    FileWrite(pcx,HDR.HRes,2);
    FileWrite(pcx,HDR.VRes,2);
    FileWrite(pcx,HDR.Colormap,48);
    FileWrite(pcx,HDR.Reserved,1);
    FileWrite(pcx,HDR.NPlanes,1);
    FileWrite(pcx,HDR.BytesPerLine,2);
    FileWrite(pcx,HDR.PaletteInfo,1);
    FileWrite(pcx,HDR.Filler,58);

    for y := 0 to H-1 do
    begin
      x := 0;
      while x <= (W-1) do
      begin
        i := 0;
        while ((x+i) <= (W-2)) and (i < 63) and (Pixels[x+i][y] = Pixels[x+i+1][y]) do
          inc(i);
        if i > 0 then
        begin
          //inc(i);
          tmpb := i or 192;
          FileWrite(pcx,tmpb,1);
          FileWrite(pcx,Pixels[x][y],1);
          Inc(X,I);
        end
        else
        begin
          if ((Pixels[x][y] and 192) = 192) then
          begin
            tmpb := 193;
            FileWrite(pcx,tmpb,1);
          end;
          FileWrite(pcx,Pixels[x][y],1);
          Inc(X);
        end;
      end;
    end;

    tmpb := 12;
    FileWrite(pcx,tmpb,1);

    for x := 0 to 255 do
    begin
      FileWrite(pcx,Palette[x].R,1);
      FileWrite(pcx,Palette[x].G,1);
      FileWrite(pcx,Palette[x].B,1);
    end;

  finally
    FileClose(pcx);
  end;

end;

procedure TSaveImage.SaveToTGA24(fil: String);
var HDR: TGAHeader;
    x,y,tga,cpos: integer;
    Buffer: PByteArray;
begin

  tga := FileCreate(fil,fmOpenWrite or fmShareDenyWrite);

  try
    HDR.IDFieldLength := 0;
    HDR.ColorMapType := 0;
    HDR.ImageType := 2;
    HDR.CMOrigin := 0;
    HDR.CMLength := 0;
    HDR.CMSize := 0;
    HDR.ImgXOrig := 0;
    HDR.ImgYOrig := 0;
    HDR.ImgWidth := W;
    HDR.ImgHeight := H;
    HDR.ImgPixelSize := 24;
    HDR.ImgDesc := 0;

    FileWrite(tga,HDR.IDFieldLength,1);
    FileWrite(tga,HDR.ColorMapType,1);
    FileWrite(tga,HDR.ImageType,1);
    FileWrite(tga,HDR.CMOrigin,2);
    FileWrite(tga,HDR.CMLength,2);
    FileWrite(tga,HDR.CMSize,1);
    FileWrite(tga,HDR.ImgXOrig,2);
    FileWrite(tga,HDR.ImgYOrig,2);
    FileWrite(tga,HDR.ImgWidth,2);
    FileWrite(tga,HDR.ImgHeight,2);
    FileWrite(tga,HDR.ImgPixelSize,1);
    FileWrite(tga,HDR.ImgDesc,1);

    GetMem(Buffer,H*W*3);
    try
    for y := H-1 downto 0 do
      for x := 0 to W-1 do
      begin
        cpos := ((((H-1)-y)*W)+x);
        Buffer[cpos*3] := Palette[Pixels[x][y]].B;
        Buffer[cpos*3+1] := Palette[Pixels[x][y]].G;
        Buffer[cpos*3+2] := Palette[Pixels[x][y]].R;
      end;
      FileWrite(tga,Buffer^,H*W*3);
    finally
      FreeMem(Buffer);
    end;
  finally
    FileClose(tga);
  end;

end;

procedure TSaveImage.SaveToTGA8(fil: String);
var HDR: TGAHeader;
    x,y,tga,BufSize: integer;
    Buffer: PByteArray;
begin

  tga := FileCreate(fil,fmOpenWrite or fmShareDenyWrite);

  try
    HDR.IDFieldLength := 0;
    HDR.ColorMapType := 1;
    HDR.ImageType := 1;
    HDR.CMOrigin := 0;
    HDR.CMLength := 256;
    HDR.CMSize := 24;
    HDR.ImgXOrig := 0;
    HDR.ImgYOrig := 0;
    HDR.ImgWidth := W;
    HDR.ImgHeight := H;
    HDR.ImgPixelSize := 8;
    HDR.ImgDesc := 0;

    FileWrite(tga,HDR.IDFieldLength,1);
    FileWrite(tga,HDR.ColorMapType,1);
    FileWrite(tga,HDR.ImageType,1);
    FileWrite(tga,HDR.CMOrigin,2);
    FileWrite(tga,HDR.CMLength,2);
    FileWrite(tga,HDR.CMSize,1);
    FileWrite(tga,HDR.ImgXOrig,2);
    FileWrite(tga,HDR.ImgYOrig,2);
    FileWrite(tga,HDR.ImgWidth,2);
    FileWrite(tga,HDR.ImgHeight,2);
    FileWrite(tga,HDR.ImgPixelSize,1);
    FileWrite(tga,HDR.ImgDesc,1);

    BufSize := W*H;
    if BufSize < 1024 then
      BufSize := 1024;

    GetMem(Buffer,BufSize);
    try

      for x := 0 to 255 do
      begin
        Buffer[(x*3)] := Palette[x].B;
        Buffer[(x*3)+1] := Palette[x].G;
        Buffer[(x*3)+2] := Palette[x].R;
      end;
      FileWrite(tga,Buffer^,768);

      for y := H-1 downto 0 do
        for x := 0 to W-1 do
          Buffer[(((H-1)-y)*W)+x] := Pixels[x][y];
      FileWrite(tga,Buffer^,W*H);
    finally
      FreeMem(Buffer);
    end;

  finally
    FileClose(tga);
  end;

end;

procedure TSaveImage.SetMipMaps(n: Integer);
var x, LastW, LastH: integer;
begin

  NumMM := n;
  SetLength(MipMaps,n);
  SetLength(MMHeight,n);
  SetLength(MMWidth,n);
  LastW := W;
  LastH := H;
  for x := 0 to n-1 do
  begin
    MMHeight[x] := LastH div 2;
    MMWidth[x] := LastW div 2;
    SetLength(MipMaps[x],MMWidth[x],MMHeight[x]);
    LastH := MMHeight[x];
    LastW := MMWidth[x];
  end;

end;

procedure TSaveImage.SetSize(x, y: Integer);
begin

  SetLength(Pixels,x,y);
  W := X;
  H := Y;

end;

function TSaveImage.Weight: Integer;
begin

  result := W;

end;

end.
