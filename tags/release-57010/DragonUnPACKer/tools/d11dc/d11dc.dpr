program d11dc;

{$APPTYPE CONSOLE}

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is d11dc.dpr, released March 18, 2014.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

uses
  SysUtils,
  Classes,
  DateUtils,
  Zlib,
  spec_D11D in '..\..\common\spec_D11D.pas',
  lib_crc in '..\..\common\lib_crc.pas';

const AppVersion : string = '1.0.0';
      AppEdit : string = '';

function BoolToStr(B: Boolean) : string;
begin
   case b of
      true: result := 'True';
      false: result := 'False';
   end;
end;

function PadRight(Data: string; PadWidth: integer) : string;
begin
   result := data;
   while length(result) < PadWidth do
      result := result + ' ';
end;

procedure Compile(srcGJD, srcDIR, outFil: string; nocompress: boolean = false);
var HDR: D11D_Header;
    srcDIRstm, srcGJDstm, dstStm: TFileStream;
    dataMemStm,compressedDataMemStm: TMemoryStream;
    compressorStm: TCompressionStream;
begin

  writeln(' Compiling from:');
  write('  '+srcDIR);

  if Not(FileExists(srcDIR)) then
  begin
    writeln(' - Not found!');
    exit;
  end;
  writeln;
  writeln('  '+srcGJD);

  if Not(FileExists(srcGJD)) then
  begin
    writeln(' - Not found!');
    exit;
  end;
  writeln;

  writeln(' Compiling to: '+outfil );

  srcDIRstm := TFileStream.Create(srcDIR,fmOpenRead or fmShareDenyWrite);
  srcGJDstm := TFileStream.Create(srcGJD,fmOpenRead or fmShareDenyWrite);
  dstStm := TFileStream.Create(outfil,fmCreate);

  dataMemStm := TMemoryStream.Create;
  compressedDataMemStm := TMemoryStream.Create;

  FillChar(HDR,SizeOf(HDR),0);
  HDR.ID[0] := 'D';
  HDR.ID[1] := '1';
  HDR.ID[2] := '1';
  HDR.ID[3] := 'D';
  HDR.EOF := 25;
  HDR.Version := D11D_Version;
  HDR.Flags := D11D_FLAG_CRC;

  if not(nocompress) then
    HDR.Flags := HDR.Flags or D11D_FLAG_ZLIB;

  write(' - Reading GJD.GJD file.... ');
  writeln(inttostr(dataMemStm.CopyFrom(srcGJDstm,srcGJDstm.Size)) + ' byte(s)');
  HDR.SeparatorOffset := dataMemStm.Position;

  write(' - Reading DIR.RL file..... ');
  writeln(inttostr(dataMemStm.CopyFrom(srcDIRstm,srcDIRstm.Size)) + ' byte(s)');
  HDR.UncompressedSize := dataMemStm.Size;

  if not(nocompress) then
  begin
    write(' - Compressing with Zlib... ');
    compressorStm := TCompressionStream.Create(clMax,compressedDataMemStm);
    dataMemStm.Position := 0;
    compressorStm.CopyFrom(dataMemStm,dataMemStm.Size);
    compressorStm.Free;
    HDR.CompressedSize := compressedDataMemStm.Size;
    writeln(inttostr(HDR.CompressedSize)+' / '+inttostr(HDR.UncompressedSize)+' byte(s)');

    write(' - Calculating CRC-32...... ');
    compressedDataMemStm.Position := 0;
    HDR.CRC32 := GetStmCRC32(compressedDataMemStm,compressedDataMemStm.Size);
  end
  else
  begin
    HDR.CompressedSize := HDR.UncompressedSize;

    write(' - Calculating CRC-32...... ');
    dataMemStm.Position := 0;
    HDR.CRC32 := GetStmCRC32(dataMemStm,dataMemStm.Size);
  end;

  writeln(inttohex(HDR.CRC32,8));

  write(' - Writing file............ ');
  dstStm.WriteBuffer(HDR,SizeOf(HDR));
  if not(nocompress) then
  begin
    compressedDataMemStm.Position := 0;
    dstStm.CopyFrom(compressedDataMemStm,compressedDataMemStm.Size);
  end
  else
  begin
    dataMemStm.Position := 0;
    dstStm.CopyFrom(dataMemStm,dataMemStm.Size);
  end;
  writeln(inttostr(dstStm.Size)+' byte(s)');

end;

begin
  { TODO -oUser -cConsole Main : placez le code ici }

   writeln('Dragon 11th Hour Data Compiler          Version: '+AppVersion+' '+AppEdit);
   writeln('Created by Alexandre Devilliers             URL: http://www.elberethzone.net');
   writeln;

   if (ParamCount < 3) or (ParamCount > 4)then
   begin
     writeln(' This program will compile both GJD.GJD and DIR.RL from 11th Hour CDs to a');
     writeln(' Dragon 11th Hour Data (D11D) file.');
     writeln;
     writeln(' Usage: d11dc <gjd.gjd> <dir.rl> <output.d11d> [N]');
     writeln;
     writeln(' If parameter Z is added at the end the payload will not be Zlib compressed.');
     writeln;
     writeln(' Output format: D11D version '+inttostr(D11D_Version));
   end
   else
   begin
     Compile(ParamStr(1),ParamStr(2),ParamStr(3),(ParamCount = 4) and (ParamStr(4) = 'N'));
   end;

end.