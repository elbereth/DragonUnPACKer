library cnv_pictex;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is cnv_pictex.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

uses
  Windows,
  Forms,
  Graphics,
  StrUtils,
  SysUtils,
  Classes,
  Registry,
  Controls,
  AbArcTyp,
  AbGZTyp,
  class_Images in 'class_Images.pas',
  Convert in 'Convert.pas' {frmConvert},
  lib_version in '..\..\..\common\lib_version.pas',
  spec_HMC in '..\..\..\common\spec_HMC.pas',
  spec_DDS in '..\..\..\common\spec_DDS.pas',
  spec_DPAL in '..\..\..\common\spec_DPAL.pas',
  lib_BinUtils in '..\..\..\common\lib_BinUtils.pas';

{$E d5c}

{$R *.res}

{$Include datetime.inc}

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
     // Procedure to display a message box by using host application
     TMsgBoxCallback = procedure(const title, msg: AnsiString);

type SMISEKAPLDXTHeader = packed record
    FourCC: array[0..3] of char;
    Width: longword;
    Height: longword;
  end;

var Percent: TPercentCallback;
    DLNGStr: TLanguageCallback;
    CurPath: ShortString;
    SupportedDUCI: byte = 0;
    palfil: string;
    AHandle: THandle;
    AOwner: TComponent;
    ShowMsgBox : TMsgBoxCallback;

const
  DUCI_VERSION = 4;
  DUCI_VERSION_COMPATIBLE = 3;
  DRIVER_VERSION = 22240;
  DUP_VERSION = 57110;
  CurSVNRevision: String = '$Rev$';
  CurSVNDate: String = '$Date$';

{ * Version History:
  * v1.0.0 Alpha (10000): First version (never distributed)
  * v1.0.0 Beta  (10010): Renamed to Pictures/Textures convert plugin
  * v1.0.1 Beta  (10110): Now the plugins remind last used palette
  * v1.0.2 Beta  (10210): Added palette convertion
  * v1.0.3 Beta  (10310): Added Bloodrayne TEX support
  * v1.0.4 Beta  (10410): Using DUCI v2
  *                       Added palette management in config box
  * v1.0.5 Beta  (10510): Fixed some bugs in palette creator (author/name)
  * v1.0.6 Beta  (10610): Added Hitman: Contracts RGBA support
  * v1.0.7 Beta  (10710): Using class_Images from Glacier TEX Editor v3.1
  *                       (improved a lot...)
  * v1.0.7       (10740): Removed beta status for 5.0.0 release
  * v2.0.0 Beta  (20010): Updated to DUCI v3 (Streams support)
  * v2.0.1 Beta  (20110): Fixed some bugs
  * v2.0.1       (20140): Removed beta status for 5.2.0 release
  * v2.1.0 Beta  (21010): Using Imaging Lib now
  *                       Added DirectX Texture DDS support
  * v2.1.1 Beta  (21110): Added BMP as output for all formats (for previewing ability)
  * v2.1.1       (21140): Removed beta status for 5.4.0 release
  * v2.2.0 Beta  (22010): Using DUCI v4, backward compatible with v3
  *                       Removed Imaging Lib (feature to be integrated in Dragon UnPACKer)
  * v2.2.0       (22040): Removed beta status for 5.6.0 release
  * v2.2.1       (22140): Added Ghostbusters .TEX support
  * v2.2.1a      (22141): Changed about info for git instead of SVN
  * v2.2.2       (22240): Added Monkey Island Special Edition .DXT support
  * }

// Identifies the DLL as a Convert plugin (minimum version to load plugin)
// Exported
function DUCIVersion: Byte; stdcall;
begin
  Result := DUCI_VERSION_COMPATIBLE;
  SupportedDUCI := DUCI_VERSION_COMPATIBLE;
end;

// Indicate current DUCIVersion (should return 4 at minimum)
// Exported
function DUCIVersionEx(supported: byte): byte; stdcall;
begin
  result := DUCI_VERSION;
  SupportedDUCI := supported;
end;

// Returns Driver plugin version
// Exported
function VersionInfo2(): ConvertInfo; stdcall;
begin

  // Information about the plugin
  with result do
  begin
    Name := 'Elbereth''s Picture/Textures Convert Plugin';
    Version := getVersion(DRIVER_VERSION);
    Author := 'Alexandre Devilliers (aka Elbereth)';
    Comment := 'Converting pictures and textures? Yeah!';
    VerID := DRIVER_VERSION;
  end;

end;

function IsFileCompatible(nam: ShortString; Offset, Size: Int64; fmt: ShortString; DataX, DataY: Integer): boolean; stdcall;
begin

  result := false;

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
  else if ((fmt = 'POD3') or (fmt = 'POD5')) and (uppercase(extractfileext(nam)) = '.TEX') then
    result := true
  else if (fmt = 'KAPL') and (uppercase(extractfileext(nam)) = '.DXT') then
    result := true
  else if ((fmt = 'HMCTEX') or (fmt = 'GTEX')) and
          ((uppercase(extractfileext(nam)) = '.RGBA')
       or  (uppercase(extractfileext(nam)) = '.PALN')
       or  (uppercase(extractfileext(nam)) = '.DXT1')
       or  (uppercase(extractfileext(nam)) = '.DXT3')) then
    result := true
  else if (fmt = 'ART') then
    result := true;

end;

function GetFileConvert(nam: ShortString; Offset, Size: Int64; fmt: ShortString; DataX, DataY: Integer): ConvertList; stdcall;
begin

  result.NumFormats := 0;

  if (fmt = 'WAD2') or (fmt = 'WAD3') then
  begin
    case DataX of
      66: begin
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
      67: begin
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
            result.List[4].Display := 'M8 - Heretic 2 MipMap (8bpp)';
            result.List[4].Ext := 'M8';
            result.List[4].ID := 'M8';
            result.List[5].Display := 'WAL - Quake  2 MipMap (8bpp)';
            result.List[5].Ext := 'WAL';
            result.List[5].ID := 'WAL';
          end;
      68: begin
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
      69: begin
            if ((Size = 16384) or (Size = 64000)) then
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
  else if (fmt = 'POD5') and (uppercase(extractfileext(nam)) = '.TEX') then
  begin
    result.NumFormats := 1;
    result.List[1].Display := 'DDS - Microsoft DirectDraw Surface';
    result.List[1].Ext := 'DDS';
    result.List[1].ID := 'DDS';
  end
  else if (fmt = 'KAPL') and (uppercase(extractfileext(nam)) = '.DXT') then
  begin
    result.NumFormats := 1;
    result.List[1].Display := 'DDS - Microsoft DirectDraw Surface';
    result.List[1].Ext := 'DDS';
    result.List[1].ID := 'DDS';
  end
  else if ((fmt = 'HMCTEX') or (fmt = 'GTEX')) then
  begin
    if (uppercase(extractfileext(nam)) = '.RGBA') then
    begin
      result.NumFormats := 1;
      result.List[1].Display := 'TGA - Targa (32bpp)';
      result.List[1].Ext := 'TGA';
      result.List[1].ID := 'TGA32';
    end
    else if (uppercase(extractfileext(nam)) = '.DXT1') then
    begin
      result.NumFormats := 1;
      result.List[1].Display := 'DDS - Microsoft DirectDraw Surface (DXT1)';
      result.List[1].Ext := 'DDS';
      result.List[1].ID := 'DDSDXT1';
    end
    else if (uppercase(extractfileext(nam)) = '.DXT3') then
    begin
      result.NumFormats := 1;
      result.List[1].Display := 'DDS - Microsoft DirectDraw Surface (DXT3)';
      result.List[1].Ext := 'DDS';
      result.List[1].ID := 'DDSDXT3';
    end
    else if (uppercase(extractfileext(nam)) = '.PALN') then
    begin
      result.NumFormats := 1;
      result.List[1].Display := 'TGA - Targa (32bpp)';
      result.List[1].Ext := 'TGA';
      result.List[1].ID := 'TGA32';
    end;
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

function ConvertARTStream(src, dst: TStream; pal: string; w, h: integer; cnv: String): integer;
var Img: TSaveImage;
    x,y: integer;
    Buffer: PByteArray;
begin

  result := 0;

  img := TSaveImage.Create;
  try
    img.LoadPAL(pal);
    GetMem(Buffer,W*H);
    try
      img.SetSize(W,H);
      src.ReadBuffer(Buffer^,W*H);
      for y := 0 to H-1 do
        for x := 0 to W-1 do
          img.Pixels[x][y] := Buffer[x*H+y];
      if cnv = 'BMP' then
        img.SaveToBMPStream(dst)
      else if cnv = 'TGA8' then
        img.SaveToTGA8Stream(dst)
      else if cnv = 'TGA24' then
        img.SaveToTGA24Stream(dst);
    finally
      FreeMem(Buffer);
    end;
  finally
    FreeAndNil(img);
  end;

end;

function ConvertWAD242Stream(src, dst: TStream; pal, cnv: String): integer;
var Img: TSaveImage;
    W,H,x,y: integer;
    Buffer: PByteArray;
begin

  result := 0;

  img := TSaveImage.Create;
  try
    img.LoadPAL(pal);
    src.ReadBuffer(W,4);
    src.ReadBuffer(H,4);
    img.SetSize(W,H);
    GetMem(Buffer,W*H);
    try
      src.ReadBuffer(Buffer^,W*H);
      for y := 0 to H-1 do
        for x := 0 to W-1 do
          img.Pixels[x][y] := Buffer[y*W+x];
    finally
      FreeMem(Buffer);
    end;
    if cnv = 'BMP' then
      img.SaveToBMPStream(dst)
    else if cnv = 'TGA8' then
      img.SaveToTGA8Stream(dst)
    else if cnv = 'TGA24' then
      img.SaveToTGA24Stream(dst);
  finally
    FreeAndNil(img);
  end;

end;

function ConvertWAD343Stream(src, dst: TStream; cnv: String): integer;
var Img: TSaveImage;
    W,H,x,y: integer;
    HDR: WAD2MipMap;
    //Buffer: PByteArray;
    Buffer: array of byte;
    cOffset: int64;
begin

  result := 0;

  cOffset := src.Seek(0,SoFromCurrent);
  src.ReadBuffer(HDR.FileName,16);
  src.ReadBuffer(HDR.Width,4);
  src.ReadBuffer(HDR.Height,4);
  src.ReadBuffer(HDR.Q1Offset,4);
  src.ReadBuffer(HDR.Q2Offset,4);
  src.ReadBuffer(HDR.Q4Offset,4);
  src.ReadBuffer(HDR.Q8Offset,4);

  W := HDR.Width;
  H := HDR.Height;

  img := TSaveImage.Create(W,H);
  try
    if (cnv = 'M8') or (cnv = 'WAL') then
      img.SetMipMaps(3);
    //GetMem(Buffer,W*H);
    if ((H*W) < 768) then
      SetLength(Buffer,768)
    else
      SetLength(Buffer,H*W);
    try
      src.Seek(cOffset + HDR.Q1Offset,soFromBeginning);
      //src.ReadBuffer(Buffer^,H*W);
      src.ReadBuffer(Buffer[0],H*W);
      for y := 0 to H-1 do
        for x := 0 to W-1 do
          img.Pixels[x][y] := Buffer[(y*W)+x];
      if (cnv = 'M8') or (cnv = 'WAL') then
      begin
        src.Seek(cOffset + HDR.Q2Offset,soFromBeginning);
        src.ReadBuffer(Buffer[0],(H div 2)*(W div 2));
        for y := 0 to (H div 2)-1 do
          for x := 0 to (W div 2)-1 do
            img.MipMaps[0][x][y] := Buffer[(y*W)+x];
        src.Seek(cOffset + HDR.Q4Offset,soFromBeginning);
        src.ReadBuffer(Buffer[0],(H div 4)*(W div 4));
        for y := 0 to (H div 4)-1 do
          for x := 0 to (W div 4)-1 do
            img.MipMaps[1][x][y] := Buffer[(y*W)+x];
        src.Seek(cOffset + HDR.Q8Offset,soFromBeginning);
        src.ReadBuffer(Buffer[0],(H div 8)*(W div 8));
        for y := 0 to (H div 8)-1 do
          for x := 0 to (W div 8)-1 do
            img.MipMaps[2][x][y] := Buffer[(y*W)+x];
      end;
      src.Seek(-770,soFromEnd);   // won't work if source stream is not a single asset
      src.ReadBuffer(Buffer[0],768);
      for x := 0 to 255 do
      begin
        img.Palette[x].R := Buffer[x*3];
        img.Palette[x].G := Buffer[(x*3)+1];
        img.Palette[x].B := Buffer[(x*3)+2];
      end;
    finally
//      FreeMem(Buffer);
      SetLength(Buffer,0);
    end;
    if cnv = 'BMP' then
      img.SaveToBMPStream(dst)
    else if cnv = 'TGA8' then
      img.SaveToTGA8Stream(dst)
    else if cnv = 'TGA24' then
      img.SaveToTGA24Stream(dst);
  finally
    FreeAndNil(img);
  end;

end;

function ConvertWAD244Stream(src, dst: TStream; pal, cnv: String): integer;
var Img: TSaveImage;
    W,H,x,y: integer;
    HDR: WAD2MipMap;
    Buffer: PByteArray;
    cOffset: int64;
begin

  result := 0;

  img := TSaveImage.Create;
  try
    img.LoadPAL(pal);
    cOffset := src.Seek(0,SoFromCurrent);
    src.ReadBuffer(HDR.FileName,16);
    src.ReadBuffer(HDR.Width,4);
    src.ReadBuffer(HDR.Height,4);
    src.ReadBuffer(HDR.Q1Offset,4);
    src.ReadBuffer(HDR.Q2Offset,4);
    src.ReadBuffer(HDR.Q4Offset,4);
    src.ReadBuffer(HDR.Q8Offset,4);
    src.ReadBuffer(HDR.Q1Offset,0);
    W := HDR.Width;
    H := HDR.Height;
    img.SetSize(W,H);
    if (cnv = 'M8') or (cnv = 'WAL') then
      img.SetMipMaps(3);
    GetMem(Buffer,W*H);
    try
      src.Seek(cOffset + HDR.Q1Offset,soFromBeginning);
      src.ReadBuffer(Buffer^,H*W);
      for y := 0 to H-1 do
        for x := 0 to W-1 do
          img.Pixels[x][y] := Buffer[(y*W)+x];
      if (cnv = 'M8') or (cnv = 'WAL') then
      begin
        src.Seek(cOffset + HDR.Q2Offset,soFromBeginning);
        src.ReadBuffer(Buffer^,(H div 2)*(W div 2));
        for y := 0 to (H div 2)-1 do
          for x := 0 to (W div 2)-1 do
            img.MipMaps[0][x][y] := Buffer[(y*W)+x];
        src.Seek(cOffset + HDR.Q4Offset,soFromBeginning);
        src.ReadBuffer(Buffer^,(H div 4)*(W div 4));
        for y := 0 to (H div 4)-1 do
          for x := 0 to (W div 4)-1 do
            img.MipMaps[1][x][y] := Buffer[(y*W)+x];
        src.Seek(cOffset + HDR.Q8Offset,soFromBeginning);
        src.ReadBuffer(Buffer^,(H div 8)*(W div 8));
        for y := 0 to (H div 8)-1 do
          for x := 0 to (W div 8)-1 do
            img.MipMaps[2][x][y] := Buffer[(y*W)+x];
      end;
    finally
      FreeMem(Buffer);
    end;
    if cnv = 'BMP' then
      img.SaveToBMPStream(dst)
      else if cnv = 'TGA8' then
        img.SaveToTGA8Stream(dst)
      else if cnv = 'TGA24' then
        img.SaveToTGA24Stream(dst);
  finally
    FreeAndNil(img);
  end;

end;

function ConvertWAD245Stream(src, dst: TStream; pal, cnv: String): integer;
var Img: TSaveImage;
    W,H,x,y: integer;
    Buffer: PByteArray;
begin

  result := 0;

  img := TSaveImage.Create;
  try
    img.LoadPAL(pal);
    case src.Seek(0,soFromEnd) of
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
    src.Seek(0, soFromBeginning);
    img.SetSize(W,H);
    GetMem(Buffer,W*H);
    try
      src.ReadBuffer(Buffer^,H*W);
      for y := 0 to H-1 do
        for x := 0 to W-1 do
          img.Pixels[x][y] := Buffer[(y*W)+x];
    finally
      FreeMem(Buffer);
    end;
    if cnv = 'BMP' then
      img.SaveToBMPStream(dst)
    else if cnv = 'TGA8' then
      img.SaveToTGA8Stream(dst)
    else if cnv = 'TGA24' then
      img.SaveToTGA24Stream(dst);
  finally
    FreeAndNil(img);
  end;

end;

function ConvertKAPLDXTStream(src, dst: TStream; cnv: String): integer;
var DDS: DDSHeader;
    DXTHDR: SMISEKAPLDXTHeader;
    CStream, DStream: TMemoryStream;
    gz: TAbGZipArchive;
    csize: integer;
    GZIPTEST: word;
begin

  result := 0;

  FillChar(DXTHDR,SizeOf(SMISEKAPLDXTHeader),0);
  src.Seek(0, soFromBeginning);
  if (src.Size > 12) then
    src.ReadBuffer(DXTHDR,SizeOf(SMISEKAPLDXTHeader));

  // Sanity checks, if they fail, we just extract a BinCopy
  if (DXTHDR.FourCC = 'DXT5') or (DXTHDR.FourCC = 'DXT1') then
  begin

    // Compute size from expected compressed texture type
    //  DXT5 is 8 bits per pixel
    if DXTHDR.FourCC[3] = #53 then
      csize := DXTHDR.Width*DXTHDR.Height
    //  DXT1 is 4 bits per pixel
    else
      csize := (DXTHDR.Width*DXTHDR.Height) div 2;

    // Fill the header of the texture
    FillChar(DDS,SizeOf(DDSHeader),0);
    DDS.ID[0] := 'D';
    DDS.ID[1] := 'D';
    DDS.ID[2] := 'S';
    DDS.ID[3] := ' ';
    DDS.SurfaceDesc.dwSize := 124;
    DDS.SurfaceDesc.dwFlags := DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or DDSD_PIXELFORMAT or DDSD_LINEARSIZE;
    DDS.SurfaceDesc.dwHeight := DXTHDR.Height;
    DDS.SurfaceDesc.dwWidth := DXTHDR.Width;
    DDS.SurfaceDesc.dwPitchOrLinearSize := csize;
    DDS.SurfaceDesc.dwMipMapCount := 0;
    DDS.SurfaceDesc.ddpfPixelFormat.dwSize := 32;
    DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_FOURCC;
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[0] := 'D';
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[1] := 'X';
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[2] := 'T';
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[3] := DXTHDR.FourCC[3];
    DDS.SurfaceDesc.ddsCaps.dwCaps1 := DDSCAPS_TEXTURE;

    // Read 2 bytes for gzip magic id
    src.ReadBuffer(gziptest,2);

    // Go back to start of data
    src.Seek(12,soFromBeginning);

    // If the marker for gzip is found, we gunzip (MI2)
    if (gziptest = $8B1F) then
    begin

      // Extract gzipped data
      CStream := TMemoryStream.Create;
      try
        CStream.CopyFrom(src,src.Size-12);
        CStream.Seek(0, soFromBeginning);
        gz := TAbGZipArchive.CreateFromStream(CStream,'datablock.gzip');
        DStream := TMemoryStream.Create;
        try
          gz.Load;
          gz.ExtractToStream('unknown',DStream);
          DStream.Seek(0,0);
          // Write DDS header
          dst.Write(DDS,SizeOf(DDSHeader));
          // Write decompressed data
          dst.CopyFrom(DStream,DStream.Size);
        finally
          FreeAndNil(gz);
          FreeAndNil(CStream);
          FreeAndNil(DStream);
        end;
      finally
        FreeAndNil(CStream);
      end

    end
    // Else the exact data size is found (MI1)
    else if (csize+SizeOf(SMISEKAPLDXTHeader)) = src.Size then
    begin

      // Write the DDS header
      dst.Write(DDS,SizeOf(DDSHeader));
      // Write the data directly
      dst.CopyFrom(src,src.Size-12);

    end;

  end;

end;

function ConvertPOD3TEXStream(src, dst: TStream; cnv: String): integer;
var Img: TSaveImage;
    W,H,x,y: integer;
    HDR: POD3TEXHeader;
    Buffer: PByteArray;
begin

  result := 0;

  img := TSaveImage.Create;
  try
    src.ReadBuffer(HDR,SizeOf(HDR));
    W := HDR.Width;
    H := HDR.Height;
    img.SetSize(W,H);
    GetMem(Buffer,W*H);
    try
      src.ReadBuffer(Buffer^,768);
      for x := 0 to 255 do
      begin
        img.Palette[x].R := Buffer[x*3];
        img.Palette[x].G := Buffer[(x*3)+1];
        img.Palette[x].B := Buffer[(x*3)+2];
      end;
      src.ReadBuffer(Buffer^,H*W);
      for y := 0 to H-1 do
        for x := 0 to W-1 do
          img.Pixels[x][y] := Buffer[(y*W)+x];
    finally
      FreeMem(Buffer);
    end;
    if cnv = 'BMP' then
      img.SaveToBMPStream(dst)
    else if cnv = 'TGA8' then
      img.SaveToTGA8Stream(dst)
    else if cnv = 'TGA24' then
      img.SaveToTGA24Stream(dst);
  finally
    FreeAndNil(img);
  end;

end;

//
//  Based on Ghostbusters texture converter (c++ code)
//	Copyright 2010 Jonathan Wilson
//
function ConvertPOD5TEXStream(src, dst: TStream; cnv: String): integer;
var W,H,x,y: integer;
    fsize: cardinal;
    HDR: POD5TEXHeader;
    Buffer: PByteArray;
    DDS: DDSHeader;
begin

  result := 0;

  try
    src.ReadBuffer(HDR,SizeOf(HDR));

    FillChar(DDS,SizeOf(DDSHeader),0);
    DDS.ID[0] := 'D';
    DDS.ID[1] := 'D';
    DDS.ID[2] := 'S';
    DDS.ID[3] := ' ';
    DDS.SurfaceDesc.dwSize := 124;
    DDS.SurfaceDesc.dwFlags := DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or DDSD_PIXELFORMAT;
    DDS.SurfaceDesc.ddsCaps.dwCaps1 := DDSCAPS_TEXTURE;
    if HDR.MipMap > 0 then
    begin
      DDS.SurfaceDesc.dwFlags := DDS.SurfaceDesc.dwFlags or DDSD_MIPMAPCOUNT;
      DDS.SurfaceDesc.ddsCaps.dwCaps1 := DDS.SurfaceDesc.ddsCaps.dwCaps1 or DDSCAPS_MIPMAP or DDSCAPS_COMPLEX;
      DDS.SurfaceDesc.dwMipMapCount := HDR.MipMap + 1;
    end;
    DDS.SurfaceDesc.dwHeight := HDR.Height;
    DDS.SurfaceDesc.dwWidth := HDR.Width;
    fsize := src.Size - src.Seek(0,soFromCurrent);
//    DDS.SurfaceDesc.dwPitchOrLinearSize := fsize;
    DDS.SurfaceDesc.ddpfPixelFormat.dwSize := 32;
    case HDR.Format of
      3: begin
        DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_RGB or DDPF_ALPHAPIXELS;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRGBBitCount := 32;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRBitMask := $00ff0000;
        DDS.SurfaceDesc.ddpfPixelFormat.dwGBitMask := $0000ff00;
        DDS.SurfaceDesc.ddpfPixelFormat.dwBBitMask := $000000ff;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRGBAlphaBitMask := $ff000000;
      end;
      4: begin
        DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_RGB;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRGBBitCount := 16;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRBitMask := $0000f800;
        DDS.SurfaceDesc.ddpfPixelFormat.dwGBitMask := $000007e0;
        DDS.SurfaceDesc.ddpfPixelFormat.dwBBitMask := $0000001f;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRGBAlphaBitMask := $00000000;
      end;
      5: begin
        DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_RGB or DDPF_ALPHAPIXELS;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRGBBitCount := 16;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRBitMask := $00000f00;
        DDS.SurfaceDesc.ddpfPixelFormat.dwGBitMask := $000000f0;
        DDS.SurfaceDesc.ddpfPixelFormat.dwBBitMask := $0000000f;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRGBAlphaBitMask := $0000f000;
      end;
      23: begin
        DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_FOURCC;
        DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[0] := 'D';
        DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[1] := 'X';
        DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[2] := 'T';
        DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[3] := '3';
      end;
      24: begin
        DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_RGB or DDPF_ALPHAPIXELS;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRGBBitCount := 32;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRBitMask := $00ff0000;
        DDS.SurfaceDesc.ddpfPixelFormat.dwGBitMask := $0000ff00;
        DDS.SurfaceDesc.ddpfPixelFormat.dwBBitMask := $000000ff;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRGBAlphaBitMask := $ff000000;
        DDS.SurfaceDesc.ddsCaps.dwCaps1 := DDSCAPS_COMPLEX;
        DDS.SurfaceDesc.ddsCaps.dwCaps2 := DDSCAPS2_CUBEMAP_POSITIVEX or DDSCAPS2_CUBEMAP_NEGATIVEX or DDSCAPS2_CUBEMAP_POSITIVEY or DDSCAPS2_CUBEMAP_NEGATIVEY or DDSCAPS2_CUBEMAP_POSITIVEZ or DDSCAPS2_CUBEMAP_NEGATIVEZ;
      end;
      43: begin
        DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_FOURCC;
        DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[0] := 'D';
        DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[1] := 'X';
        DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[2] := 'T';
        DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[3] := '1';
      end;
      46: begin
        DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_FOURCC;
        DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[0] := 'q';
      end;
      47: begin
        DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_LUMINANCE or DDPF_ALPHAPIXELS;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRGBBitCount := 16;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRBitMask := $000000ff;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRGBAlphaBitMask := $ff00;
      end;
      50: begin
        DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_FOURCC;
        DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[0] := 'D';
        DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[1] := 'X';
        DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[2] := 'T';
        DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[3] := '5';
      end;
      55: begin
        DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_LUMINANCE;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRGBBitCount := 8;
        DDS.SurfaceDesc.ddpfPixelFormat.dwRBitMask := $000000ff;
      end;
      else
        raise Exception.Create('Unknown format '+inttostr(HDR.Format)+'!');
    end;
    dst.Write(DDS,SizeOf(DDSHeader));
    dst.CopyFrom(src,fsize);
  finally
  end;

end;

function ConvertHMC_TEX_RGBAStream(texFile, dst: TStream): integer;
var x, y, W, H, fsize: integer;
    img: TSaveImage32;
    HDR: HMC_TEX_Entry;
    Buffer: PByteArray;
begin

  result := 0;

  texFile.Read(HDR,SizeOf(HMC_Tex_Entry));
  Get0(texFile);

  if (HDR.Type1 <> 'ABGR') or (HDR.Type2 <> 'ABGR') then
    raise Exception.Create('Not an RGBA texture!');

  texFile.Read(fsize,4);
  W := HDR.Width;
  H := HDR.Height;

  img := TSaveImage32.Create;
  try
    img.SetSize(W,H);
    GetMem(Buffer,W*H*4);
    try
      texFile.Read(Buffer^,H*W*4);
      for y := 0 to H-1 do
        for x := 0 to W-1 do
        begin
          img.Pixels[x][y].R := Buffer[(y*W*4)+x*4];
          img.Pixels[x][y].G := Buffer[(y*W*4)+x*4+1];
          img.Pixels[x][y].B := Buffer[(y*W*4)+x*4+2];
          img.Pixels[x][y].A := Buffer[(y*W*4)+x*4+3];
        end;
    finally
      FreeMem(Buffer);
    end;
    img.SaveToTGA32Stream(dst);
  finally
    FreeAndNil(img);
  end;

end;

function ConvertHMC_TEX_DXTStream(texFile, outFile: TStream; dxtchar: char): integer;
var HDR: HMC_TEX_Entry;
    DDS: DDSHeader;
    fsize: cardinal;
    x: integer;
begin

  result := 0;

  texFile.Read(HDR,SizeOf(HMC_Tex_Entry));
  Get0(texFile);

  if (HDR.Type1 <> (dxtchar+'TXD')) or (HDR.Type2 <> (dxtchar+'TXD')) then
    raise Exception.Create('Not an DXT'+dxtchar+' texture!');

  texFile.Read(fsize,4);
  FillChar(DDS,SizeOf(DDSHeader),0);
  DDS.ID[0] := 'D';
  DDS.ID[1] := 'D';
  DDS.ID[2] := 'S';
  DDS.ID[3] := ' ';
  DDS.SurfaceDesc.dwSize := 124;
  DDS.SurfaceDesc.dwFlags := DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or DDSD_PIXELFORMAT or DDSD_LINEARSIZE;
  if HDR.NumMipMap > 1 then
    DDS.SurfaceDesc.dwFlags := DDS.SurfaceDesc.dwFlags or DDSD_MIPMAPCOUNT;
  DDS.SurfaceDesc.dwHeight := HDR.Height;
  DDS.SurfaceDesc.dwWidth := HDR.Width;
  DDS.SurfaceDesc.dwPitchOrLinearSize := fsize;
  DDS.SurfaceDesc.dwMipMapCount := HDR.NumMipMap;
  DDS.SurfaceDesc.ddpfPixelFormat.dwSize := 32;
  DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_FOURCC;
  DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[0] := 'D';
  DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[1] := 'X';
  DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[2] := 'T';
  DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[3] := dxtchar;
  DDS.SurfaceDesc.ddsCaps.dwCaps1 := DDSCAPS_TEXTURE;
  if HDR.NumMipMap > 1 then
    DDS.SurfaceDesc.ddsCaps.dwCaps1 := DDS.SurfaceDesc.ddsCaps.dwCaps1 or DDSCAPS_COMPLEX or DDSCAPS_MIPMAP;
  outFile.Write(DDS,SizeOf(DDSHeader));
  outFile.CopyFrom(texFile,fsize);
  for x := 2 to HDR.NumMipMap do
  begin
    texFile.Read(fsize,4);
    outFile.CopyFrom(texFile,fsize);
  end;

end;

function ConvertHMC_TEX_PALNStream(texFile, dst: TStream): integer;
var x, y, W, H, fsize: integer;
    img8: TSaveImage;
    HDR: HMC_TEX_Entry;
    Buffer: PByteArray;
begin

  result := 0;

  texFile.Read(HDR,SizeOf(HMC_Tex_Entry));
  Get0(texFile);
  texFile.Read(fsize,4);

  if (HDR.Type1 <> 'NLAP') or (HDR.Type2 <> 'NLAP') then
    raise Exception.Create('Not an PALN texture!');

  img8 := TSaveImage.Create;
  GetMem(Buffer,fsize);
  try
    texFile.Read(Buffer^,fsize);
    texFile.Read(fsize,4);

    img8.SetSizePal(HDR.Width, HDR.Height,fsize,true);

    W := HDR.Width;
    H := HDR.Height;

    for y := 0 to H-1 do
      for x := 0 to W-1 do
        img8.Pixels[x][y] := Buffer[(y*W)+x];

    texFile.Read(Buffer^,fsize*4);

    for y := 0 to fsize-1 do
    begin
      img8.Palette[y].R := Buffer[(y*4)];
      img8.Palette[y].G := Buffer[(y*4)+1];
      img8.Palette[y].B := Buffer[(y*4)+2];
      img8.Palette[y].A := Buffer[(y*4)+3];
    end;

    img8.SaveToTGA32Stream(dst);
  finally
    FreeMem(Buffer);
    FreeAndNil(img8);
  end;

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
    FreeAndNil(Reg);
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
    FreeAndNil(Reg);
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
    FreeAndNil(lstPALFil);
  end;
  Application.Handle := OApp;

end;

function ConvertStream(src, dst: TStream; nam, fmt, cnv: ShortString; Offset: Int64; DataX, DataY: Integer; Silent: Boolean): integer; stdcall;
var Size: int64;
begin

  result := 0;

  if (fmt = 'WAD2') or (fmt = 'WAD3') then
  begin
    case DataX of
      66: begin
            if not(Silent) or (palfil = '') then
              palfil := SelectPal;
            result := ConvertWAD242Stream(src,dst,palfil,cnv);
          end;
      67: result := ConvertWAD343Stream(src,dst,cnv);
      68: begin
            Size := src.Size;
            if ((fmt = 'WAD2') and (Uppercase(LeftStr(nam,8))='CONCHARS') and (Size = 16384)) then
            begin
              if not(Silent) or (palfil = '') then
                palfil := SelectPal;
              result := ConvertWAD245Stream(src,dst,palfil,cnv);
            end
            else
            begin
              if not(Silent) or (palfil = '') then
                palfil := SelectPal;
              result := ConvertWAD244Stream(src,dst,palfil,cnv);
            end;
          end;
      69: begin
            if not(Silent) or (palfil = '') then
              palfil := SelectPal;
            result := ConvertWAD245Stream(src,dst,palfil,cnv);
          end;
    end;
  end
  else if (fmt = 'POD3') and (uppercase(extractfileext(nam)) = '.TEX') then
  begin
    result := ConvertPOD3TEXStream(src,dst,cnv);
  end
  else if (fmt = 'POD5') and (uppercase(extractfileext(nam)) = '.TEX') then
  begin
    result := ConvertPOD5TEXStream(src,dst,cnv);
  end
  else if (fmt = 'KAPL') and (uppercase(extractfileext(nam)) = '.DXT') then
  begin
    result := ConvertKAPLDXTStream(src,dst,cnv);
  end
  else if ((fmt = 'GTEX') or (fmt = 'HMCTEX')) and (uppercase(extractfileext(nam)) = '.RGBA') then
  begin
    result := ConvertHMC_TEX_RGBAStream(src,dst);
  end
  else if ((fmt = 'GTEX') or (fmt = 'HMCTEX')) and (uppercase(extractfileext(nam)) = '.PALN') then
  begin
    result := ConvertHMC_TEX_PALNStream(src,dst);
  end
  else if ((fmt = 'GTEX') or (fmt = 'HMCTEX')) and (uppercase(extractfileext(nam)) = '.DXT1') then
  begin
    result := ConvertHMC_TEX_DXTStream(src,dst,'1');
  end
  else if ((fmt = 'GTEX') or (fmt = 'HMCTEX')) and (uppercase(extractfileext(nam)) = '.DXT3') then
  begin
    result := ConvertHMC_TEX_DXTStream(src,dst,'3');
  end
  else if (fmt = 'ART') then
  begin
    if not(Silent) or (palfil = '') then
      palfil := SelectPal;
    result := ConvertARTStream(src,dst,palfil,DataX,DataY,cnv);
  end;

end;

  // Obsolete Convert, so we wrap it to the ConvertStream version
function Convert(src, dst, nam, fmt, cnv: ShortString; Offset: Int64; DataX, DataY: Integer; Silent: Boolean): integer; stdcall;
var src_stm, dst_stm: TFileStream;
begin

  src_stm := TFileStream.Create(src,fmOpenRead or fmShareDenyWrite);
  dst_stm := TFileStream.Create(dst,fmCreate or fmShareDenyWrite);

  try
    result := ConvertStream(src_stm, dst_stm,nam,fmt,cnv,Offset,DataX,DataY,Silent);
  finally
    FreeAndNil(src_stm);
    FreeAndNil(dst_stm);
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

procedure InitPluginEx4(MsgBox: TMsgBoxCallback); stdcall;
begin

  showMsgBox := MsgBox;

end;

procedure AboutBox; stdcall;
var aboutText: string;
begin

  if (SupportedDUCI >= 4) then
  begin

    aboutText := '{\rtf1\ansi\ansicpg1252\deff0\deflang1036{\fonttbl{\f0\fswiss\fcharset0 Arial;}}'+#10+
                 '\viewkind4\uc1\pard\qc\ul\b\f0\fs24\par Elbereth''s Picture/Textures Convert plugin v'+getVersion(DRIVER_VERSION)+'\par'+#10+
                 '\ulnone\b0\i\fs22 Created by \b Alexandre Devilliers (aka Elbereth/Piecito)\par'+#10+
                 '\par'+#10+
                 '\b0\i0\fs20 Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+'\par'+#10+
                 'Driver Interface [DUCI] v'+inttostr(DUCI_VERSION)+' (v'+inttostr(DUCI_VERSION_COMPATIBLE)+' compatible) [using v'+inttostr(SupportedDUCI)+']\par'+#10+
                 'Compiled the '+DateToStr(CompileTime)+' at '+TimeToStr(CompileTime)+'\par'+#10+
                 'Based on git commit '+getSVNRevision(CurSVNRevision)+' ('+getSVNDate(CurSVNDate)+')\par'+#10+
                 '\par'+#10+StringReplace(DLNGStr('CNV010'),#10,'\par'+#10,[rfReplaceAll])+'}'+#10;

  end
  else
  begin
    aboutText := 'Elbereth''s Picture/Textures Convert plugin v'+getVersion(DRIVER_VERSION)+#10+
                 'Created by \b Alexandre Devilliers (aka Elbereth/Piecito)'+#10+#10+
                 'Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+#10+
                 'Driver Interface [DUCI] v'+inttostr(DUCI_VERSION)+' (v'+inttostr(DUCI_VERSION_COMPATIBLE)+' compatible) [using v'+inttostr(SupportedDUCI)+#10+
                 'Compiled the '+DateToStr(CompileTime)+' at '+TimeToStr(CompileTime)+#10+
                 'Based on git commit '+getSVNRevision(CurSVNRevision)+' ('+getSVNDate(CurSVNDate)+')'+#10+
                 #10+DLNGStr('CNV010')+#10;
  end;

  showMsgBox('About Elbereth''s Picture/Textures Convert Plugin...',aboutText);

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
    FreeAndNil(lstPALFil);
  end;
  Application.Handle := OApp;

end;

exports
  DUCIVersion,
  DUCIVersionEx,
  Convert,
  ConvertStream,
  GetFileConvert,
  IsFileCompatible,
  VersionInfo2,
  InitPlugin,
  InitPluginEx4,
  ConfigBox,
  AboutBox;

begin
end.
