unit ULZMAEnc;

// Unit taken from cpatch

interface

uses ULZMAEncoder,UBufferedFS, ULZMACommon, Classes, SysUtils;

function lzma_encode(const infile, outfile: string): boolean; overload;
function lzma_encode(instream, outstream: TStream): boolean; overload;

implementation

function lzma_encode(const infile, outfile: string): boolean;
var
  inStream:TBufferedFS;
  outStream:TBufferedFS;
begin
  inStream:=TBufferedFS.Create(infile, fmOpenRead or fmsharedenynone);
  outStream:=TBufferedFS.Create(outfile, fmcreate);
  result := lzma_encode(instream, outstream);
  outStream.Free;
  inStream.Free;
end;

function lzma_encode(instream, outstream: TStream): boolean; overload;
var
  encoder:TLZMAEncoder;
  filesize:int64;
const
  propertiessize = 5;

begin
  encoder := TLZMAEncoder.Create;
  encoder.SetAlgorithm(2);
  encoder.SetDictionarySize(1 shl 25);
  encoder.SeNumFastBytes(273);
  encoder.SetMatchFinder(1);
  encoder.SetLcLpPb(3, 0, 2);
  encoder.SetEndMarkerMode(false);
  encoder.WriteCoderProperties(outStream);
  fileSize := inStream.Size;
  outStream.Write(filesize, 4);
  encoder.Code(inStream, outStream, -1, -1);
  result := true;
  encoder.Free;
end;

end.
