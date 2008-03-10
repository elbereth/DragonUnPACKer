unit class_Images;

// $Id: class_Images.pas,v 1.4 2005-12-13 07:13:56 elbereth Exp $
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

uses SysUtils, Dialogs, Graphics, Classes;

const TGAORIGIN_BOTTOMLEFT = 0;
      TGAORIGIN_BOTTOMRIGHT = 16;
      TGAORIGIN_TOPLEFT = 32;
      TGAORIGIN_TOPRIGHT = 48;

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
     TGAFooter = packed record
       ExtAreaOffset: cardinal;
       DevDirOffset: cardinal;
       Signature: array[0..15] of char;
       ReservedChar: char;
       BZSTerminator: byte;
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
  // Physical bitmap pixel
  TColorRGB = packed record
    r, g, b	: BYTE;
  end;
  PColorRGB = ^TColorRGB;
  TRGBList = packed array[0..0] of TColorRGB;
  PRGBList = ^TRGBList;

type ESIBadFormat = class(Exception);

type TSaveImage = class
    constructor Create(x, y: Integer); overload;
    constructor Create(x, y, cmsize: Integer; cmalpha: boolean); overload;
    destructor Destroy; override;
    function LoadPAL(dpalfil: string): boolean;
    procedure SaveToBMP(fil: String);
    procedure SaveToBMPStream(stm: TStream);
    procedure SaveToPCX(fil: String);
    procedure SaveToPCXStream(stm: TStream);
    procedure SaveToTGA8(fil: String);
    procedure SaveToTGA8Stream(stm: TStream);
    procedure SaveToTGA24(fil: String);
    procedure SaveToTGA24Stream(stm: TStream);
    procedure SaveToTGA32(fil: String);
    procedure SaveToTGA32Stream(stm: TStream);
    procedure LoadFromTGA32(fil: String);
    procedure SetSize(x, y: Integer);
    procedure SetSizePal(x, y, cmsize: Integer; cmalpha: boolean);
    procedure SetMipMaps(n: Integer);
    procedure GenerateMipMaps();
    function AddColor(R,G,B,A: byte): byte;
    function Height(): Integer;
    function Width(): Integer;
  private
    H: Integer;
    W: Integer;
    CurPalSize: integer;
  protected
  public
    Pixels: array of array of byte;
    MipMaps: array of array of array of byte;
    NumMM: integer;
    MMHeight: array of integer;
    MMWidth: array of integer;
    Palette: array of TCouleur;
    PaletteSize: integer;
    PaletteAlpha: boolean;
end;

type TSaveImage32 = class
    procedure LoadFromTBitmap(src: TBitmap);
    procedure LoadFromTGA32(fil: String);
    procedure SaveToTGA24(fil: String);
    procedure SaveToTGA24Stream(stm: TStream);
    procedure SaveToTGA32(fil: String);
    procedure SaveToTGA32Stream(stm: TStream);
    procedure SetSize(x, y: Integer);
    function GetBitmap: TBitmap;
    function Height(): Integer;
    function Width(): Integer;
  private
    H: Integer;
    W: Integer;
  protected
  public
    Pixels: array of array of TCouleur;
end;

implementation

{ TSaveImage }

function TSaveImage.AddColor(R, G, B, A: byte): byte;
var x: integer;
begin

  for x := 0 to CurPalSize-1 do
  begin
    if ((Palette[x].R = R)
    and (Palette[x].G = G)
    and (Palette[x].B = B)
    and (Palette[x].A = A)) then
    begin
      result := x;
      exit;
    end;
  end;

  if CurPalSize = 256 then
    raise ESIBadFormat.Create('More than 256 unique colors. (Unsupported)')
  else
  begin
    Inc(CurPalSize);

    Palette[CurPalSize-1].R := R;
    Palette[CurPalSize-1].G := G;
    Palette[CurPalSize-1].B := B;
    Palette[CurPalSize-1].A := A;

    result := CurPalSize - 1;
  end;

end;

constructor TSaveImage.Create(x, y: Integer);
begin

  inherited Create;
  SetLength(Pixels,x,y);
  W := X;
  H := Y;
  SetLength(Palette,256);
  PaletteSize := 256;
  PaletteAlpha := false;

end;

constructor TSaveImage.Create(x, y, cmsize: Integer; cmalpha: boolean);
begin

  inherited Create;
  SetLength(Pixels,x,y);
  W := X;
  H := Y;
  SetLength(Palette,cmsize);
  PaletteSize := cmsize;
  PaletteAlpha := cmalpha;
  CurPalSize := 0;

end;

destructor TSaveImage.Destroy;
begin
  SetLength(Pixels,0,0);
  SetLength(Palette,0);
  inherited Destroy;
end;

procedure TSaveImage.GenerateMipMaps;
begin

  // TO DO //

end;

function TSaveImage.Height: Integer;
begin

  Result := H;

end;

procedure TSaveImage.LoadFromTGA32(fil: String);
var HDR: TGAHeader;
    x,y,tga,cpos: integer;
    Buffer: PByteArray;
begin

  tga := FileOpen(fil,fmOpenRead);
  try

    FileSeek(tga,0,0);

    FileRead(tga,HDR.IDFieldLength,1);
    FileRead(tga,HDR.ColorMapType,1);
    FileRead(tga,HDR.ImageType,1);
    FileRead(tga,HDR.CMOrigin,2);
    FileRead(tga,HDR.CMLength,2);
    FileRead(tga,HDR.CMSize,1);
    FileRead(tga,HDR.ImgXOrig,2);
    FileRead(tga,HDR.ImgYOrig,2);
    FileRead(tga,HDR.ImgWidth,2);
    FileRead(tga,HDR.ImgHeight,2);
    FileRead(tga,HDR.ImgPixelSize,1);
    FileRead(tga,HDR.ImgDesc,1);

    if (HDR.IDFieldLength <> 0)
    or (HDR.ColorMapType <> 0)
    or (HDR.ImageType <> 2)
    or (HDR.ImgPixelSize <> 32) then
    begin

      raise ESIBadFormat.Create('Source file is not a Targa 32bpp (w/alpha channel) file');

    end
    else
    begin

      SetSizePal(HDR.ImgWidth, HDR.ImgHeight,256,true);
      GetMem(Buffer,H*W*4);
      FileRead(tga,Buffer^,H*W*4);
      try
      for y := H-1 downto 0 do
        for x := 0 to W-1 do
        begin
          cpos := ((((H-1)-y)*W)+x);
          Pixels[x][y] := AddColor(Buffer[cpos*4+2],Buffer[cpos*4+1],Buffer[cpos*4],Buffer[cpos*4+3]);
        end;
      finally
        FreeMem(Buffer);
      end;

      SetLength(Palette,CurPalSize);
      PaletteSize := CurPalSize;

    end;

  finally
    FileClose(tga);
  end;

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
          SetLength(Palette,256);
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
var bmp: TFileStream;
begin

  bmp := TFileStream.Create(fil,fmCreate or fmShareDenyWrite);
  try
    SaveToBMPStream(bmp);
  finally
    bmp.Free;
  end;

end;

procedure TSaveImage.SaveToBMPStream(stm: TStream);
var HDR: BMPHeader;
    x,y,atend,BufSize: integer;
    Buffer: PByteArray;
//    Buffer: array of Byte;
begin

    HDR.ID[0] := 'B';
    HDR.ID[1] := 'M';
    if (W - ((W div 4)*4)) > 0 then
      atend := 4 - (W - ((W div 4)*4))
    else
      atend := 0;
    HDR.Size := ((W + atend) * H) + SizeOf(BMPHeader) + PaletteSize*4;
    HDR.Reserved1 := 0;
    HDR.Reserved2 := 0;
    HDR.Offset := SizeOf(BMPHeader) + PaletteSize*4;
    HDR.ID2 := 40;
    HDR.Width := W;
    HDR.height := H;
    HDR.Planes := 1;
    HDR.Bpp := 8;
    HDR.Compression := 0;
//    Showmessage(inttostr(w)+#10+inttostr(atend)+#10+inttostr(W+Atend));
//    atend := 0;
    HDR.SizeImage := (W + atend) * H;
    HDR.XPPM := 0;
    HDR.YPPM := 0;
    HDR.ColorsUsed := PaletteSize;
    HDR.ColorsImportant := PaletteSize;

    stm.WriteBuffer(HDR.ID,2);
    stm.WriteBuffer(HDR.Size,4);
    stm.WriteBuffer(HDR.Reserved1,2);
    stm.WriteBuffer(HDR.Reserved2,2);
    stm.WriteBuffer(HDR.Offset,4);
    stm.WriteBuffer(HDR.ID2,4);
    stm.WriteBuffer(HDR.Width,4);
    stm.WriteBuffer(HDR.height,4);
    stm.WriteBuffer(HDR.Planes,2);
    stm.WriteBuffer(HDR.Bpp,2);
    stm.WriteBuffer(HDR.Compression,4);
    stm.WriteBuffer(HDR.SizeImage,4);
    stm.WriteBuffer(HDR.XPPM,4);
    stm.WriteBuffer(HDR.YPPM,4);
    stm.WriteBuffer(HDR.ColorsUsed,4);
    stm.WriteBuffer(HDR.ColorsImportant,4);

    BufSize := (W+atend)*H;
    if BufSize < (PaletteSize*4) then
      BufSize := (PaletteSize*4);

    GetMem(Buffer,BufSize);
//    New(Buffer);
//    SetLength(Buffer,BufSize);
    try
      for x := 0 to PaletteSize-1 do
      begin
        Buffer[(x*4)] := Palette[x].B;
        Buffer[(x*4)+1] := Palette[x].G;
        Buffer[(x*4)+2] := Palette[x].R;
        Buffer[(x*4)+3] := Palette[x].A;
      end;
      stm.WriteBuffer(Buffer^,(PaletteSize*4));
//      stm.WriteBuffer(Buffer[0],PaletteSize*4);

      for y := H-1 downto 0 do
      begin
        for x := 0 to W-1 do
          Buffer[(((H-1)-y)*(W+atend))+x] := Pixels[x][y];
        for x := 1 to atend do
          Buffer[(((H-1)-y)*(W+atend))+W-1+x] := 0;
      end;
      stm.WriteBuffer(Buffer^,(W+atend)*H);
//      stm.WriteBuffer(Buffer[0],(W+atend)*H);
    finally
      FreeMem(Buffer);
      //SetLength(Buffer,0);
      //Dispose(Buffer);
    end;

end;

procedure TSaveImage.SaveToPCX(fil: String);
var pcx: TFileStream;
begin

  pcx := TFileStream.Create(fil,fmCreate or fmShareDenyWrite);
  try
    SaveToPCXStream(pcx);
  finally
    pcx.free;
  end;

end;

procedure TSaveImage.SaveToPCXStream(stm: TStream);
var HDR: PCXHeader;
    x,y,i: integer;
    tmpb: byte;
begin

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
  stm.WriteBuffer(HDR.Manufacturer,1);
  stm.WriteBuffer(HDR.Version,1);
  stm.WriteBuffer(HDR.Encoding,1);
  stm.WriteBuffer(HDR.Bpp,1);
  stm.WriteBuffer(HDR.Window.XMin,2);
  stm.WriteBuffer(HDR.Window.YMin,2);
  stm.WriteBuffer(HDR.Window.XMax,2);
  stm.WriteBuffer(HDR.Window.YMax,2);
  stm.WriteBuffer(HDR.HRes,2);
  stm.WriteBuffer(HDR.VRes,2);
  stm.WriteBuffer(HDR.Colormap,48);
  stm.WriteBuffer(HDR.Reserved,1);
  stm.WriteBuffer(HDR.NPlanes,1);
  stm.WriteBuffer(HDR.BytesPerLine,2);
  stm.WriteBuffer(HDR.PaletteInfo,1);
  stm.WriteBuffer(HDR.Filler,58);

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
        stm.WriteBuffer(tmpb,1);
        stm.WriteBuffer(Pixels[x][y],1);
        Inc(X,I);
      end
      else
      begin
        if ((Pixels[x][y] and 192) = 192) then
        begin
          tmpb := 193;
          stm.WriteBuffer(tmpb,1);
        end;
        stm.WriteBuffer(Pixels[x][y],1);
        Inc(X);
      end;
    end;
  end;

  tmpb := 12;
  stm.WriteBuffer(tmpb,1);

  for x := 0 to PaletteSize do
  begin
    stm.WriteBuffer(Palette[x].R,1);
    stm.WriteBuffer(Palette[x].G,1);
    stm.WriteBuffer(Palette[x].B,1);
  end;

  tmpb := 0;
  for x := PaletteSize+1 to 255 do
  begin
    stm.WriteBuffer(tmpb,1);
    stm.WriteBuffer(tmpb,1);
    stm.WriteBuffer(tmpb,1);
  end;

end;

procedure TSaveImage.SaveToTGA24(fil: String);
var tga: TFileStream;
begin

  tga := TFileStream.Create(fil,fmCreate or fmShareDenyWrite);
  try
    SaveToTGA24Stream(tga);
  finally
    tga.free;
  end;

end;

procedure TSaveImage.SaveToTGA24Stream(stm: TStream);
var HDR: TGAHeader;
    FTR: TGAFooter;
    x,y,cpos: integer;
    Buffer: PByteArray;
begin

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

  stm.WriteBuffer(HDR.IDFieldLength,1);
  stm.WriteBuffer(HDR.ColorMapType,1);
  stm.WriteBuffer(HDR.ImageType,1);
  stm.WriteBuffer(HDR.CMOrigin,2);
  stm.WriteBuffer(HDR.CMLength,2);
  stm.WriteBuffer(HDR.CMSize,1);
  stm.WriteBuffer(HDR.ImgXOrig,2);
  stm.WriteBuffer(HDR.ImgYOrig,2);
  stm.WriteBuffer(HDR.ImgWidth,2);
  stm.WriteBuffer(HDR.ImgHeight,2);
  stm.WriteBuffer(HDR.ImgPixelSize,1);
  stm.WriteBuffer(HDR.ImgDesc,1);

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
    stm.WriteBuffer(Buffer^,H*W*3);
  finally
    FreeMem(Buffer);
  end;

  FillChar(FTR,sizeof(TGAFooter),0);
  FTR.Signature := 'TRUEVISION-XFILE';
  FTR.ReservedChar := '.';

  stm.WriteBuffer(FTR,SizeOf(TGAFooter));

end;

procedure TSaveImage.SaveToTGA32(fil: String);
var tga: TFileStream;
begin

  tga := TFileStream.Create(fil,fmOpenWrite or fmShareDenyWrite);

  try
    SaveToTGA32Stream(tga);
  finally
    tga.free;
  end;

end;

procedure TSaveImage.SaveToTGA32Stream(stm: TStream);
var HDR: TGAHeader;
    FTR: TGAFooter;
    x,y,cpos: integer;
    Buffer: PByteArray;
begin

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
  HDR.ImgPixelSize := 32;
  HDR.ImgDesc := 8;   // Fixed (Bit 3 set = useful Alpha channel data is present)

  stm.WriteBuffer(HDR.IDFieldLength,1);
  stm.WriteBuffer(HDR.ColorMapType,1);
  stm.WriteBuffer(HDR.ImageType,1);
  stm.WriteBuffer(HDR.CMOrigin,2);
  stm.WriteBuffer(HDR.CMLength,2);
  stm.WriteBuffer(HDR.CMSize,1);
  stm.WriteBuffer(HDR.ImgXOrig,2);
  stm.WriteBuffer(HDR.ImgYOrig,2);
  stm.WriteBuffer(HDR.ImgWidth,2);
  stm.WriteBuffer(HDR.ImgHeight,2);
  stm.WriteBuffer(HDR.ImgPixelSize,1);
  stm.WriteBuffer(HDR.ImgDesc,1);

  GetMem(Buffer,H*W*4);
  try
  for y := H-1 downto 0 do
    for x := 0 to W-1 do
    begin
      cpos := ((((H-1)-y)*W)+x);
      Buffer[cpos*4] := Palette[Pixels[x][y]].B;
      Buffer[cpos*4+1] := Palette[Pixels[x][y]].G;
      Buffer[cpos*4+2] := Palette[Pixels[x][y]].R;
      Buffer[cpos*4+3] := Palette[Pixels[x][y]].A;
    end;
    stm.WriteBuffer(Buffer^,H*W*4);
  finally
    FreeMem(Buffer);
  end;

  FillChar(FTR,sizeof(TGAFooter),0);
  FTR.Signature := 'TRUEVISION-XFILE';
  FTR.ReservedChar := '.';

  stm.WriteBuffer(FTR,SizeOf(TGAFooter));

end;

procedure TSaveImage.SaveToTGA8(fil: String);
var tga: TFileStream;
begin

  tga := TFileStream.Create(fil,fmCreate or fmShareDenyWrite);

  try
    SaveToTGA8Stream(tga);
  finally
    tga.free;
  end;

end;

procedure TSaveImage.SaveToTGA8Stream(stm: TStream);
var HDR: TGAHeader;
    FTR: TGAFooter;
    x,y,BufSize,wSize: integer;
    Buffer: PByteArray;
begin

  HDR.IDFieldLength := 0;
  HDR.ColorMapType := 1;
  HDR.ImageType := 1;
  HDR.CMOrigin := 0;
  HDR.CMLength := PaletteSize;
  if PaletteAlpha then
    HDR.CMSize := 32
  else
    HDR.CMSize := 24;
  HDR.ImgXOrig := 0;
  HDR.ImgYOrig := 0;
  HDR.ImgWidth := W;
  HDR.ImgHeight := H;
  HDR.ImgPixelSize := 8;
  HDR.ImgDesc := 0;

  stm.WriteBuffer(HDR.IDFieldLength,1);
  stm.WriteBuffer(HDR.ColorMapType,1);
  stm.WriteBuffer(HDR.ImageType,1);
  stm.WriteBuffer(HDR.CMOrigin,2);
  stm.WriteBuffer(HDR.CMLength,2);
  stm.WriteBuffer(HDR.CMSize,1);
  stm.WriteBuffer(HDR.ImgXOrig,2);
  stm.WriteBuffer(HDR.ImgYOrig,2);
  stm.WriteBuffer(HDR.ImgWidth,2);
  stm.WriteBuffer(HDR.ImgHeight,2);
  stm.WriteBuffer(HDR.ImgPixelSize,1);
  stm.WriteBuffer(HDR.ImgDesc,1);

  BufSize := W*H;
  if BufSize < 1024 then
    BufSize := 1024;

  GetMem(Buffer,BufSize);
  try

    for x := 0 to PaletteSize-1 do
    begin
      if PaletteAlpha then
      begin
        Buffer[(x*4)] := Palette[x].B;
        Buffer[(x*4)+1] := Palette[x].G;
        Buffer[(x*4)+2] := Palette[x].R;
        Buffer[(x*4)+3] := Palette[x].A;
      end
      else
      begin
        Buffer[(x*3)] := Palette[x].B;
        Buffer[(x*3)+1] := Palette[x].G;
        Buffer[(x*3)+2] := Palette[x].R;
      end;
    end;
    if PaletteAlpha then
      wsize := PaletteSize*4
    else
      wsize := PaletteSize*3;
    stm.WriteBuffer(Buffer^,wsize);

    for y := H-1 downto 0 do
      for x := 0 to W-1 do
        Buffer[(((H-1)-y)*W)+x] := Pixels[x][y];
    stm.WriteBuffer(Buffer^,W*H);
  finally
    FreeMem(Buffer);
  end;

  FillChar(FTR,sizeof(TGAFooter),0);
  FTR.Signature := 'TRUEVISION-XFILE';
  FTR.ReservedChar := '.';

  stm.WriteBuffer(FTR,SizeOf(TGAFooter));

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
  SetLength(Palette,256);
  PaletteSize := 256;
  PaletteAlpha := false;

end;

procedure TSaveImage.SetSizePal(x, y, cmsize: Integer; cmalpha: boolean);
begin

  SetLength(Pixels,x,y);
  W := X;
  H := Y;
  SetLength(Palette,cmsize);
  PaletteSize := cmsize;
  PaletteAlpha := cmalpha;
  CurPalSize := 0;

end;

function TSaveImage.Width: Integer;
begin

  result := W;

end;

{ TSaveImage32 }

function TSaveImage32.GetBitmap: TBitmap;
var i, j: integer;
    color: TColorRGB;
    DestPixel : PColorRGB;
begin

  result := TBitmap.Create;
  with result do
  begin
    pixelformat := pf24bit;
    Height := H;
    Width := W;
    for i := 0 to H-1 do
    begin
      DestPixel := ScanLine[i];
      for j := 0 to W-1 do
      begin
        color.r := pixels[j,i].B;
        color.g := pixels[j,i].G;
        color.b := pixels[j,i].R;
        DestPixel^ := color;
        inc(DestPixel);
      end;
    end;
  end;

end;

function TSaveImage32.Height: Integer;
begin

  Result := H;

end;

procedure TSaveImage32.LoadFromTBitmap(src: TBitmap);
var i, j: integer;
    color: TColorRGB;
    SrcPixel : PColorRGB;
begin

  SetSize(src.Width, src.Height);

  with src do
  begin
    pixelformat := pf24bit;
    for i := 0 to H-1 do
    begin
      SrcPixel := ScanLine[i];
      for j := 0 to W-1 do
      begin
        color := SrcPixel^;
        pixels[j,i].B := color.r;
        pixels[j,i].G := color.g;
        pixels[j,i].R := color.b;
        inc(SrcPixel);
      end;
    end;
  end;

end;

procedure TSaveImage32.LoadFromTGA32(fil: String);
var HDR: TGAHeader;
    x,y,tga,cpos,origtype: integer;
    Buffer: PByteArray;
begin

  tga := FileOpen(fil,fmOpenRead);
  try

    FileSeek(tga,0,0);

    FileRead(tga,HDR.IDFieldLength,1);
    FileRead(tga,HDR.ColorMapType,1);
    FileRead(tga,HDR.ImageType,1);
    FileRead(tga,HDR.CMOrigin,2);
    FileRead(tga,HDR.CMLength,2);
    FileRead(tga,HDR.CMSize,1);
    FileRead(tga,HDR.ImgXOrig,2);
    FileRead(tga,HDR.ImgYOrig,2);
    FileRead(tga,HDR.ImgWidth,2);
    FileRead(tga,HDR.ImgHeight,2);
    FileRead(tga,HDR.ImgPixelSize,1);
    FileRead(tga,HDR.ImgDesc,1);

    if (HDR.IDFieldLength <> 0)
    or (HDR.ColorMapType <> 0)
    or (HDR.ImageType <> 2)
    or (HDR.ImgPixelSize <> 32) then
    begin

      raise ESIBadFormat.Create('Source file is not an uncompressed Targa 32bpp (w/alpha channel) file');

    end
    else
    begin

      if (HDR.ImgDesc AND 48) = TGAORIGIN_BOTTOMRIGHT then
        origtype := 1
      else if (HDR.ImgDesc AND 48) = TGAORIGIN_TOPLEFT then
        origtype := 2
      else if (HDR.ImgDesc AND 48) = TGAORIGIN_TOPRIGHT then
        origtype := 3
      else
        origtype := 0;

      SetSize(HDR.ImgWidth, HDR.ImgHeight);
      GetMem(Buffer,H*W*4);
      FileRead(tga,Buffer^,H*W*4);
      try
      cpos := 0;
      for y := H-1 downto 0 do
        for x := 0 to W-1 do
        begin
          case origtype of
            0: cpos := ((((H-1)-y)*W)+x);
            1: cpos := ((((H-1)-y)*W)+((W-1)-x));
            2: cpos := ((y*W)+x);
            3: cpos := ((y*W)+((W-1)-x));
          end;
          Pixels[x][y].B := Buffer[cpos*4];
          Pixels[x][y].G := Buffer[cpos*4+1];
          Pixels[x][y].R := Buffer[cpos*4+2];
          Pixels[x][y].A := Buffer[cpos*4+3];
        end;
      finally
        FreeMem(Buffer);
      end;

    end;

  finally
    FileClose(tga);
  end;

end;

procedure TSaveImage32.SaveToTGA24(fil: String);
var tga: TFileStream;
begin

  tga := TFilestream.Create(fil,fmCreate or fmShareDenyWrite);

  try
    SaveToTGA24Stream(tga);
  finally
    tga.free;
  end;

end;

procedure TSaveImage32.SaveToTGA24Stream(stm: TStream);
var HDR: TGAHeader;
    FTR: TGAFooter;
    x,y,cpos: integer;
    Buffer: PByteArray;
begin

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

  stm.WriteBuffer(HDR.IDFieldLength,1);
  stm.WriteBuffer(HDR.ColorMapType,1);
  stm.WriteBuffer(HDR.ImageType,1);
  stm.WriteBuffer(HDR.CMOrigin,2);
  stm.WriteBuffer(HDR.CMLength,2);
  stm.WriteBuffer(HDR.CMSize,1);
  stm.WriteBuffer(HDR.ImgXOrig,2);
  stm.WriteBuffer(HDR.ImgYOrig,2);
  stm.WriteBuffer(HDR.ImgWidth,2);
  stm.WriteBuffer(HDR.ImgHeight,2);
  stm.WriteBuffer(HDR.ImgPixelSize,1);
  stm.WriteBuffer(HDR.ImgDesc,1);

  GetMem(Buffer,H*W*3);
  try
  for y := H-1 downto 0 do
    for x := 0 to W-1 do
    begin
      cpos := ((((H-1)-y)*W)+x);
      Buffer[cpos*3] := Pixels[x][y].B;
      Buffer[cpos*3+1] := Pixels[x][y].G;
      Buffer[cpos*3+2] := Pixels[x][y].R;
    end;
    stm.WriteBuffer(Buffer^,H*W*3);
  finally
    FreeMem(Buffer);
  end;

  FillChar(FTR,sizeof(TGAFooter),0);
  FTR.Signature := 'TRUEVISION-XFILE';
  FTR.ReservedChar := '.';

  stm.WriteBuffer(FTR,SizeOf(TGAFooter));

end;

procedure TSaveImage32.SaveToTGA32(fil: String);
var tga: TFileStream;
begin

  tga := TFileStream.Create(fil,fmCreate or fmShareDenyWrite);

  try
    SaveToTGA32Stream(tga);
  finally
    tga.free;
  end;

end;

procedure TSaveImage32.SaveToTGA32Stream(stm: TStream);
var HDR: TGAHeader;
    FTR: TGAFooter;
    x,y,cpos: integer;
    Buffer: PByteArray;
begin

  FillChar(HDR,sizeof(TGAHeader),0);
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
  HDR.ImgPixelSize := 32;
  HDR.ImgDesc := 8;   // Fixed (Bit 3 set = useful Alpha channel data is present)

  stm.WriteBuffer(HDR.IDFieldLength,1);
  stm.WriteBuffer(HDR.ColorMapType,1);
  stm.WriteBuffer(HDR.ImageType,1);
  stm.WriteBuffer(HDR.CMOrigin,2);
  stm.WriteBuffer(HDR.CMLength,2);
  stm.WriteBuffer(HDR.CMSize,1);
  stm.WriteBuffer(HDR.ImgXOrig,2);
  stm.WriteBuffer(HDR.ImgYOrig,2);
  stm.WriteBuffer(HDR.ImgWidth,2);
  stm.WriteBuffer(HDR.ImgHeight,2);
  stm.WriteBuffer(HDR.ImgPixelSize,1);
  stm.WriteBuffer(HDR.ImgDesc,1);

  GetMem(Buffer,H*W*4);
  try
  for y := H-1 downto 0 do
    for x := 0 to W-1 do
    begin
      cpos := ((((H-1)-y)*W)+x);
      Buffer[cpos*4] := Pixels[x][y].B;
      Buffer[cpos*4+1] := Pixels[x][y].G;
      Buffer[cpos*4+2] := Pixels[x][y].R;
      Buffer[cpos*4+3] := Pixels[x][y].A;
    end;
    stm.WriteBuffer(Buffer^,H*W*4);
  finally
    FreeMem(Buffer);
  end;

  FillChar(FTR,sizeof(TGAFooter),0);
  FTR.Signature := 'TRUEVISION-XFILE';
  FTR.ReservedChar := '.';

  stm.WriteBuffer(FTR,SizeOf(TGAFooter));

end;

procedure TSaveImage32.SetSize(x, y: Integer);
begin

  SetLength(Pixels,x,y);
  W := X;
  H := Y;

end;

function TSaveImage32.Width: Integer;
begin

  result := W;

end;

end.
