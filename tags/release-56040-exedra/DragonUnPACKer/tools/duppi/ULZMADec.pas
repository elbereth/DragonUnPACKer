unit ULZMADec;

// Unit taken from cpatch

interface

uses ULZMADecoder, UBufferedFS, ULZMACommon, Classes, SysUtils;

function lzma_decode(const infile, outfile: string): boolean; overload;
function lzma_decode(instream, outstream: TStream): boolean; overload;

implementation

function lzma_decode(const infile, outfile: string): boolean;
var
  inStream:TBufferedFS;
  outStream:TBufferedFS;
begin
  inStream:=TBufferedFS.Create(infile, fmOpenRead or fmsharedenynone);
  outStream:=TBufferedFS.Create(outfile, fmcreate);
  result := lzma_decode(instream, outstream);
  outStream.Free;
  inStream.Free;
end;

function lzma_decode(instream, outstream: TStream): boolean; overload;
var
  properties:array[0..4] of byte;
  decoder:TLZMADecoder;
  outSize:int64;
const
  propertiessize = 5;

begin
  result := false;
  decoder := TLZMADecoder.Create;

  if inStream.read(properties, propertiesSize) <> propertiesSize then
  begin
    decoder.Free;
    Exit;
  end;
  if not decoder.SetDecoderProperties(properties) then
  begin
    decoder.Free;
    Exit;
  end;
  outsize := 0;
  inStream.Read(outSize, 4);
  if not decoder.Code(inStream, outStream, outSize) then
  begin
    decoder.Free;
    Exit;
  end;
  result := true;
  decoder.Free;
end;

end.