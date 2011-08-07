unit spec_DPAL;

// $Id: spec_DPAL.pas,v 1.1.1.1 2004-05-08 10:25:11 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/common/spec_DPAL.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is spec_DPAL.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// Dragon Unpacker Palette [DPAL] types & tools
// =============================================================================
//
//  Types:
//  BMPHeader
//  DPALHeader
//  MSPAL_Header
//  PCX_RGB
//  PCXHeader
//  PCXHeaderWindow
//  
//  Classes:
//  TConvertPAL
//
// -----------------------------------------------------------------------------

interface

uses sysutils,
     dialogs;

type
TRGB = packed record
     R: byte;
     G: byte;
     B: byte;
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
  MSPAL_Header = packed record
    RIFFID: array[0..3] of char;   // 'RIFF'
    RIFFSize: cardinal;            // 1044
    ID: array[0..3] of char;       // 'PAL '
    ID2: array[0..3] of char;      // 'data'
    DataSize: integer;
    PalSize: integer;
    NumColors: integer;
  end;

type TConvertDPAL = class
    function LoadBMP(fil: string): boolean;
    function LoadPCX(fil: string): boolean;
    function LoadPAL(fil: string): boolean;
    function LoadPSPPALETTE(fil: string): boolean;
    function LoadRGB(fil: string): boolean;
    function LoadBGR(fil: string): boolean;
    procedure SaveToDPAL(fil: String);
    procedure setName(st: string);
    procedure setAuthor(st: string);
  private
    palette: array[0..255] of TRGB;
    name: string;
    author: string;
    procedure writeString(var ofil: array of char; st: string; size: byte);
  protected
  public


  end;

implementation

 { TConvertDPAL }

function TConvertDPAL.LoadBGR(fil: string): boolean;
var hBGR, fsize, x: integer;
    tbyt: byte;
begin

  if (FileExists(fil)) then
  begin
    hBGR := fileopen(fil, fmOpenRead);
    fsize := FileSeek(hBGR,0,2);
    FileSeek(hBGR,0,0);
    if (fsize > 768) then
    begin
      FileRead(hBGR,palette,768);
      for x := 0 to 255 do
      begin
        tbyt := palette[x].R;
        palette[x].R := palette[x].B;
        palette[x].B := tbyt;
      end;
      result := true;
    end
    else
      result := false;

    FileClose(hBGR);
  end
  else
    result := false;

end;

function TConvertDPAL.LoadBMP(fil: string): boolean;
var BMP: BMPHeader;
    hBMP, x: integer;
    tbyt: byte;
begin

  if (FileExists(fil)) then
  begin
    hBMP := fileopen(fil, fmOpenRead);
    FileRead(hBMP,BMP,SizeOf(BMPHeader));
    if (BMP.ID = 'BM') and (BMP.ID2 = 40) and (BMP.Bpp = 8) then
    begin
      For x := 0 To 255 do
      begin
        FileRead(hBMP,Palette[x].B,1);
        FileRead(hBMP,Palette[x].G,1);
        FileRead(hBMP,Palette[x].R,1);
        FileRead(hBMP,tbyt,1);
      end;
      result := true;
    end
    else
      result := false;

    FileClose(hBMP);
  end
  else
    result := false;

end;

function TConvertDPAL.LoadPAL(fil: string): boolean;
var HDR: MSPAL_Header;
    hPAL, x: integer;
    tbyt: byte;
begin

  if (FileExists(fil)) then
  begin
    hPAL := fileopen(fil, fmOpenRead);
    FileRead(hPAL,HDR,SizeOf(MSPAL_Header));
    if (HDR.RIFFID = 'RIFF') and (HDR.ID = 'PAL ') and (HDR.ID2 = 'data') and (HDR.RIFFSize = 1044) and (HDR.NumColors = 256) then
    begin
      For x := 0 To 255 do
      begin
        FileRead(hPAL,Palette[x].R,1);
        FileRead(hPAL,Palette[x].G,1);
        FileRead(hPAL,Palette[x].B,1);
        FileRead(hPAL,tbyt,1);
      end;
      result := true;
    end
    else
      result := false;

    FileClose(hPAL);
  end
  else
    result := false;

end;

function TConvertDPAL.LoadPCX(fil: string): boolean;
var PCX: PCXHeader;
    bTest: byte;
    hPCX: integer;
begin

  if (FileExists(fil)) then
  begin
    hPCX := fileopen(fil, fmOpenRead);
    FileRead(hPCX,PCX,SizeOf(PCXHeader));
    if (PCX.Manufacturer = 10) and (PCX.Version = 5) and (PCX.Bpp = 8) then
    begin
      FileSeek(hPCX,-769,2);
      FileRead(hPCx,bTest,1);
      if (bTest = 12) then
      begin
        FileRead(hPCX,palette,768);
        result := true;
      end
      else
        result := false;
    end
    else
      result := false;

    FileClose(hPCX);
  end
  else
    result := false;

end;

function TConvertDPAL.LoadPSPPALETTE(fil: string): boolean;
var F: TextFile;
    S: String;
    x, ctoken: integer;
begin

  if (fileexists(fil)) then
  begin
    try
      AssignFile(F,fil);
      FileMode := fmOpenRead;
      Reset(F);
      ReadLn(F,S);
      if (S = 'JASC-PAL') then
      begin
        ReadLn(F,S);
        if (S = '0100') then
        begin
          ReadLn(F,S);
          if (S = '256') then
          begin
            for x := 0 to 255 do
            begin
              ReadLn(F,S);
              ctoken := pos(' ',S);
              palette[x].R := StrToInt(Trim(Copy(S,1,ctoken)));
              S := Trim(copy(S,ctoken+1,length(S)-ctoken));
              ctoken := pos(' ',S);
              palette[x].G := StrToInt(Trim(Copy(S,1,ctoken)));
              S := Trim(copy(S,ctoken+1,length(S)-ctoken));
              palette[x].B := StrToInt(S);
            end;
            result := true;
          end
          else
            result := false;
        end
        else
          result := false;
      end
      else
        result := false;

      CloseFile(F);
    except
      on e:Exception do
        begin
          result := false;
        end;
    end;
  end
  else
    result := false;

end;

function TConvertDPAL.LoadRGB(fil: string): boolean;
var hRGB, fsize: integer;
begin

  if (FileExists(fil)) then
  begin
    hRGB := fileopen(fil, fmOpenRead);
    fsize := FileSeek(hRGB,0,2);
    FileSeek(hRGB,0,0);
    if (fsize > 768) then
    begin
      FileRead(hRGB,palette,768);
      result := true;
    end
    else
      result := false;

    FileClose(hRGB);
  end
  else
    result := false;

end;

procedure TConvertDPAL.SaveToDPAL(fil: String);
var PAL: DPALHeader;
   hPAL: integer;
begin

  hPAL := filecreate(fil,fmOpenWrite);
  if (hPAL >= 0) then
  begin
    FillChar(PAL,SizeOf(DPALHeader),0);
    PAL.ID := 'DPAL' + #26;
    PAL.Version := 1;
    if (length(name) > 0) then
      writeString(PAL.Game,name,100)
    else
      writeString(PAL.Game,ChangeFileExt(extractfilename(fil),''),100);

    writeString(PAL.Author,author,100);

    FileWrite(hPAL,PAL,SizeOf(DPALHeader));
    FileWrite(hPAL,palette,768);
    FileClose(hPAL);
  end;

end;

procedure TConvertDPAL.setAuthor(st: string);
begin

  author := st;

end;

procedure TConvertDPAL.setName(st: string);
begin

  name := st;

end;

procedure TConvertDPAL.writeString(var ofil: array of char; st: string; size: byte);
var tbyt, len, x : byte;
begin

  len := length(st);
  for x := 1 to len do
    ofil[x-1] := st[x];
  tbyt := 32;
  for x := len+1 to size do
    ofil[x-1] := char(tbyt);

end;

end.
