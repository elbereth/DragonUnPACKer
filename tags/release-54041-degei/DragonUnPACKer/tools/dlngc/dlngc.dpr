program dlngc;

{$APPTYPE CONSOLE}

// $Id: dlngc.dpr,v 1.3 2008-11-11 15:52:46 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/tools/dlngc/dlngc.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is dlngc.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

uses
  SysUtils,
  Classes,
  DateUtils,
  Zlib,
  spec_DLNG in '..\..\common\spec_DLNG.pas';

const AppVersion : string = '4.1.1';
      AppEdit : string = '';
      DLNG_Version : Byte = 4;
      DLNG_Manufacturer : Byte = 41;

{CRC32}
type
   crc32tabletype = array[0..255] of longint;
var
   fcrctable: crc32tabletype;

function crc32gen: crc32tabletype;
var
   crc, poly: longint;
   i, j: integer;
   crc32table: crc32tabletype;
begin
   fillchar(crc32table, sizeof(crc32table) , 0) ;
   poly := longint($EDB88320) ;
   for i := 0 to 255 do
   begin
      crc := i;
      for j := 8 downto 1 do
      begin
         if (crc and 1) = 1 then
            crc := (crc shr 1) xor poly
         else
            crc := crc shr 1;
      end;
      crc32table[i] := crc;
   end;
   result := crc32table;
end;

function GetStrCRC32(Data: string) : longint;
var
   crc: longint;
   index, datalength: integer;
begin
   crc := longint($FFFFFFFF) ;

   datalength := length(data) ;
   index := 1;
   while index <= datalength do
   begin
      crc := ((crc shr 8) and $FFFFFF) xor fcrctable[(crc xor byte(data[index]) ) and $FF];
      inc(index) ;
   end;
   result := (crc xor Integer($FFFFFFFF) ) ;
end;

function GetStrmCRC32(Data: TStream) : longint;
var
   crc: longint;
   db: byte;
begin
   Data.Position := 0;

   crc := longint($FFFFFFFF) ;

   while data.Position < data.size do
   begin
      Data.ReadBuffer(db, 1) ;
      crc := ((crc shr 8) and $FFFFFF) xor fcrctable[(crc xor db) and $FF];
   end;
   result := (crc xor longint($FFFFFFFF) ) ;
end;

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

procedure Compile(sin: string; NoCRC, NoIcon, PascalOutput, PascalOutputInclude: boolean);
var hin: TextFile;
    tmps,keyw,valu,outfil,iconfil: String;
    idx: array[1..2000] of DLNG_IndexEntry_v4;
    str: array[1..2000] of WideString;
    IsHeader, IsBody, IsLSF, IsError: Boolean;
    Cline, Uline, poseq, NumIDX, x,tsize: integer;
    ErrInfo, strTmp: string;
    HDR: DLNG_Header_v4;
    HDRX: DLNG_ExtendedHeader;
    tbyt : byte;
//    Buffer: Pchar;
    outFileStm: TFileStream;
    iconFileStm: TFileStream;
    iconMemStm: TMemoryStream;
    bufMemStm: TMemoryStream;
    bufMemStm2: TMemoryStream;
    compStm: TCompressionStream;
    stime,etime: TDateTime;
    curOffset: integer;
    buffer: PByteArray;
begin

  stime := now;

  writeln(' Compiling from '+sin+'...');

  if FileExists(sin) then
  begin
    AssignFile(hin, sin);
    Reset(hin);

    IsHeader := False;
    IsBody := False;
    IsLSF := False;
    IsError := False;
    cline := 0;
    uline := 0;
    NumIdx := 0;
    IconFil := '';

    HDRX.FontName := '';

    FillChar(HDR,SizeOf(HDR),0);

    write(' - Reading file..... ');

    while (not(eof(hin)) and Not(IsError)) do
    begin
      cline := cline + 1;
      ReadLn(hin, tmps);
      tmps := TrimLeft(tmps);
      if (Copy(tmps,1,1) <> '#') and (length(tmps) > 0) then
      begin
        uline := uline + 1;
        if Copy(tmps,1,1) = '{' then
        begin
          tmps := TrimRight(tmps);
          tmps := UpperCase(tmps);
          if tmps = '{LSF}' then
            IsLSF := True
          else if IsLSF and Not(IsBody) and (tmps = '{HEADER}') then
            IsHeader := True
          else if IsLSF and Not(IsHeader) and (tmps = '{BODY}') then
            IsBody := True
          else if IsLSF and IsHeader and (tmps = '{/HEADER}') then
            IsHeader := False
          else if IsLSF and IsBody and (tmps = '{/BODY}') then
            IsBody := False
          else if IsLSF and Not(IsBody) and Not(IsHeader) and (tmps = '{/LSF}') then
            IsLSF := False
          else
          begin
            IsError := True;
            ErrInfo := 'Unknown tag or forbidden here - '+tmps;
          end;
        end
        else
          if IsLSF then
            if IsHeader or IsBody then
            begin
              poseq := pos('=',tmps);
              if poseq = 0 then
              begin
                IsError := True;
                ErrInfo := 'Equal (=) symbol not found but needed';
              end
              else
              begin
                keyw := TrimRight(Copy(tmps,1,poseq-1));
                valu := TrimLeft(Copy(tmps,poseq+1,length(tmps)-poseq));
                if IsHeader then
                begin
                  keyw := uppercase(keyw);
                  if keyw = 'NAME' then
                    HDRX.Name := valu
                  else if keyw = 'EMAIL' then
                    HDRX.Email := valu
                  else if keyw = 'URL' then
                    HDRX.URL := valu
                  else if keyw = 'AUTHOR' then
                    HDRX.Author := valu
                  else if keyw = 'FONTNAME' then
                    HDRX.FontName := valu
                  else if keyw = 'ICONFILE' then
                    iconfil := valu
                  else if keyw = 'OUTFILE' then
                    outfil := valu
                  else if keyw = 'PROGRAMVER' then
                    HDR.PrgVER := StrToInt(valu)
                  else if keyw = 'COMPRESSION' then
                    HDR.Compression := StrToInt(valu)
                  else if keyw = 'PROGRAMID' then
                    if length(valu) = 2 then
                    begin
                      HDR.PrgID[1] := valu[1];
                      HDR.PrgID[2] := valu[2];
                    end
                    else
                    begin
                      IsError := True;
                      ErrInfo := 'ProgramID must be 2 chars wide';
                    end
                  else
                  begin
                    IsError := True;
                    ErrInfo := 'Unknown header keyword ['+keyw+']';
                  end
                end
                else
                begin
                  NumIdx := NumIdx + 1;
                  FillChar(Idx[NumIdx].ID,6,32);
                  for x := 1 to length(keyw) do
                    Idx[NumIdx].ID[x] := keyw[x];
                  Idx[NumIdx].Length := length(valu);
                  Str[NumIdx] := valu;
                end;
              end;
            end
            else
            begin
              IsError := True;
              ErrInfo := 'Instruction not in header or body';
            end
          else
          begin
            IsError := True;
            ErrInfo := 'Not a LSF file';
          end;

      end;
    end;

    CloseFile(hin);

    if IsError then
    begin
      writeln('Error line '+IntToStr(CLine));
      writeln('    Info: '+errinfo);
      writeln('   State: IsLSF='+BoolToStr(IsLSF)+' IsHeader='+BoolToStr(IsHeader)+' IsBody='+BoolToStr(IsBody));
    end
    else if (HDR.Compression <> 0) and (HDR.Compression <> 99) then
    begin
      writeln('Unknown compression type ['+inttostr(HDR.Compression)+']. Valid values are:');
      writeln('    0 : No compression (Default and Fastest)');
      writeln('   99 : ZLib compression [level 9]');
    end
    else
    begin
      writeln('OK ['+IntToStr(Cline)+' lines - '+IntToStr(ULine)+' used]');
      writeln(' - Writing file..... '+outfil);

      if PascalOutput then
        outfil := ExtractFilePath(outfil)+'lib_language_internal.pas'
      else if PascalOutputInclude then
        outfil := ChangeFileExt(outfil,'.'+HDR.PrgID+'.inc');

      outFileStm := TFileStream.Create(outfil, fmCreate);
//      ofil := FileCreate(outfil);

      if outFileStm.Handle <> 0 then
      begin

        if PascalOutput or PascalOutputInclude then
        begin

          write('   Entries.......... ');


          strTmp := '// ============================================================================='+#13+#10+'//    WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING'+#13+#10+'// ============================================================================='+#13+#10+'//  This file was created automatically from:'+#13+#10+'//  '+sin+#13+#10+'//  With Dragon Language Compiler v'+AppVersion+' '+AppEdit+#13+#10+'//'+#13+#10+'// DO NOT CHANGE THIS FILE MANUALLY, EDIT THE SOURCE FILE AND RECOMPILE IT WITH'+#13+#10;
          outFileStm.WriteBuffer(strTmp[1],length(strTmp));
          strTmp := '// DLOOKC <file> /I';
          if PascalOutput then
            strTmp := strTmp + 'L'
          else
            strTmp := strTmp + 'N';
          outFileStm.WriteBuffer(strTmp[1],length(strTmp));
          strTmp := #13+#10+'//'+#13+#10+'// -----------------------------------------------------------------------------'+#13+#10+#13+#10;
          outFileStm.WriteBuffer(strTmp[1],length(strTmp));
          if PascalOutput then
          begin
            strTmp := 'unit lib_language_internal;'+#13+#10+#13+#10+'interface'+#13+#10+#13+#10+'function DLNGInternalStr(sch: string): string;'+#13+#10+#13+#10+'implementation'+#13+#10+#13+#10;
            outFileStm.WriteBuffer(strTmp[1],length(strTmp));
          end;
          strTmp := 'function DLNGInternalStr(sch: string): string;'+#13+#10+'begin'+#13+#10+#13+#10;
          outFileStm.WriteBuffer(strTmp[1],length(strTmp));

          for x := 1 to NumIdx do
          begin
            if x = 1 then
              strTmp := '  if sch = '+QuotedStr(TrimRight(idx[x].ID))+' then'+#13+#10+'    result := '+QuotedStr(str[x])+#13+#10
            else
              strTmp := '  else if sch = '+QuotedStr(TrimRight(idx[x].ID))+' then'+#13+#10+'    result := '+QuotedStr(str[x])+#13+#10;
            outFileStm.WriteBuffer(strTmp[1],length(strTmp));
          end;

          strTmp := '  else'+#13+#10+'    result := '+QuotedStr('--Non défini--')+#13+#10+#13+#10+'end;'+#13+#10;
          outFileStm.WriteBuffer(strTmp[1],length(strTmp));

          if PascalOutput then
            strTmp := #13+#10+'end.'+#13+#10;

          writeln('OK ['+InttoStr(NumIdx)+' entries]');
          tsize := outFileStm.Size;

//        FileClose(ofil);
          etime := now;

          writeln(' - Compiled successfully! ['+inttostr(tsize)+' bytes] ['+Format('%3.3f',[MillisecondsBetween(etime, stime)/1000])+' secs]');

        end
        else
        begin

        HDR.ID[0] := 'D';
        HDR.ID[1] := 'L';
        HDR.ID[2] := 'N';
        HDR.ID[3] := 'G';
        HDR.ID[4] := #26;

        HDR.Version := DLNG_Version;

        iconMemStm := TMemoryStream.Create;
        HDR.IconSize := 0;

        if FileExists(iconfil) and Not(NoIcon) then
        begin
          iconFileStm := TFileStream.Create(iconfil,fmOpenRead);
          try
            HDR.IconSize := iconFileStm.Size;
            iconMemStm.CopyFrom(iconFileStm,HDR.IconSize);
            iconMemStm.Position := 0;
            // FileSeek(ifil,0,2);
            //FileSeek(ifil,0,0);
//            GetMem(Buffer,HDR.IconSize);
//            FileRead(ifil,Buffer^,HDR.IconSize);
          finally
            //FileClose(ifil);
            iconFileStm.Free;
          end;
        end;

        HDR.ExtendedHeaderSize := Length(HDRX.Name)*2+Length(HDRX.Author)*2+Length(HDRX.URL)*2+Length(HDRX.Email)*2+Length(HDRX.FontName)*2+5;
        HDR.IndexOffSet := SizeOf(HDR) + HDR.ExtendedHeaderSize + HDR.IconSize;
        HDR.IndexNum := NumIdx;
        HDR.DataOffSet := HDR.IndexOffSet + NumIdx * SizeOf(DLNG_IndexEntry_v4);
        HDR.Manufacturer := DLNG_Manufacturer;

        write('   Header........... ');

        outFileStm.WriteBuffer(HDR,SizeOf(HDR));
//        FileWrite(ofil,HDR,SizeOf(HDR));

        writeln('OK ['+inttostr(SizeOf(HDR))+' bytes]');

        write('   Extended Header.. ');

        bufMemStm := TMemoryStream.Create;

        try

          tbyt := length(HDRX.Name);
//        FileWrite(ofil,tbyt,1);
          bufMemStm.WriteBuffer(tbyt,1);
          bufMemStm.WriteBuffer(HDRX.Name[1],tbyt*2);
//        for x := 1 to Length(HDRX.Name) do
//          FileWrite(ofil,HDRX.Name[x],1);

          tbyt := length(HDRX.Author);
          bufMemStm.WriteBuffer(tbyt,1);
          bufMemStm.WriteBuffer(HDRX.Author[1],tbyt*2);
{        FileWrite(ofil,tbyt,1);
        for x := 1 to Length(HDRX.Author) do
          FileWrite(ofil,HDRX.Author[x],1);}

          tbyt := length(HDRX.URL);
          bufMemStm.WriteBuffer(tbyt,1);
          bufMemStm.WriteBuffer(HDRX.URL[1],tbyt*2);
{        FileWrite(ofil,tbyt,1);
        for x := 1 to Length(HDRX.URL) do
          FileWrite(ofil,HDRX.URL[x],1);}

          tbyt := length(HDRX.Email);
          bufMemStm.WriteBuffer(tbyt,1);
          bufMemStm.WriteBuffer(HDRX.Email[1],tbyt*2);
{        FileWrite(ofil,tbyt,1);
        for x := 1 to Length(HDRX.Email) do
          FileWrite(ofil,HDRX.Email[x],1);}

          tbyt := length(HDRX.FontName);
          bufMemStm.WriteBuffer(tbyt,1);
          bufMemStm.WriteBuffer(HDRX.FontName[1],tbyt*2);
{        FileWrite(ofil,tbyt,1);
        for x := 1 to Length(HDRX.FontName) do
          FileWrite(ofil,HDRX.FontName[x],1);}

          bufMemStm.Position := 0;
          outFileStm.CopyFrom(bufMemStm,HDR.ExtendedHeaderSize);
          bufMemStm.Position := 0;

          write('OK ['+inttostr(HDR.ExtendedHeaderSize)+' bytes]');

          if NoCRC then
          begin
            HDR.ExtendedHeaderCRC := 0;
            writeln;
          end
          else
          begin
            HDR.ExtendedHeaderCRC := getStrmCrc32(bufMemStm);
            writeln(' [CRC '+inttohex(HDR.ExtendedHeaderCRC,8)+']');
          end;

        finally
          bufMemStm.Free;
        end;

        write('   Icon............. ');

        if (HDR.IconSize > 0) then
        begin
          outFileStm.CopyFrom(iconMemStm,HDR.IconSize);
//          FileWrite(ofil,Buffer^,HDR.IconSize);
//          FreeMem(Buffer);
          iconMemStm.Free;
          writeln('OK ['+inttostr(HDR.IconSize)+' bytes]');
        end
        else
          writeln('NO');

        write('   Index............ ');

        bufMemStm := TMemoryStream.Create;
        try

          curOffset := 0;
          for x := 1 to NumIdx do
          begin
            Idx[x].Offset := curOffset;
//          FileWrite(ofil,Idx[x],sizeOf(DLNG_IndexEntry_v4));
            bufMemStm.WriteBuffer(Idx[x],SizeOf(DLNG_IndexEntry_v4));
            inc(curOffset,Idx[x].Length);
          end;

          curOffset := NumIdx * SizeOf(DLNG_IndexEntry_v4);
          bufMemStm.Position := 0;
          outFileStm.CopyFrom(bufMemStm,curOffset);
          bufMemStm.Position := 0;

          write(inttostr(NumIdx)+' entries ['+inttostr(bufMemStm.Size)+' bytes]');

          if NoCRC then
            writeln
          else
          begin
            write(' [CRC ');

            HDR.IndexCRC := GetStrmCRC32(bufMemStm);

            writeln(inttohex(HDR.IndexCRC,8)+']');
          end;
        finally
          bufMemStm.Free;
        end;

        write('   Data............. ');

        bufMemStm := TMemoryStream.Create;
        try

          for x := 1 to NumIdx do
//            for y := 1 to Idx[x].Length do
            bufMemStm.WriteBuffer(str[x][1],Idx[x].Length*2);

          HDR.DataSize := bufMemStm.Size;

          if HDR.Compression = 0 then
          begin

            bufMemStm.Position := 0;
            outFileStm.CopyFrom(bufMemStm,HDR.DataSize);
            write('OK ['+inttostr(HDR.DataSize)+' bytes]');

          end
          else if HDR.Compression = 99 then
          begin

            write(inttostr(HDR.DataSize)+' bytes... Zlib: ');
            bufMemStm2 := TMemoryStream.Create;
            getMem(buffer,HDR.DataSize);
            try
              bufMemStm.Seek(0, soFromBeginning);
              bufMemStm.Read(buffer^,HDR.DataSize);
              compStm := TCompressionStream.Create(clMax,bufMemStm2);
              try
                compStm.Write(buffer^,HDR.DataSize);
              finally
                compStm.Free;
              end;
//            compStm.CopyFrom(bufMemStm,bufMemStm.Size);
              HDR.DataCSize := bufMemStm2.Size;
              bufMemStm2.Seek(0, soFromBeginning);
              outFileStm.CopyFrom(bufMemStm2,HDR.DataCSize);
  //          outFileStm.CopyFrom(bufMemStm,bufMemStm.Size);
            finally
              bufMemStm2.Free;
              FreeMem(buffer);
            end;
            bufMemStm.Position := 0;
            write('OK ['+inttostr(HDR.DataCSize)+' bytes - '+inttostr(round(((HDR.DataSize-HDR.DataCSize)/HDR.DataSize)*100))+'%] ');
          end;

          if NoCRC then
            writeln
          else
          begin
            write(' [CRC ');

            HDR.DataCRC := GetStrmCRC32(bufMemStm);

            writeln(inttohex(HDR.DataCRC,8)+']');
          end;
        finally
          bufMemStm.Free;
        end;

//        FileSeek(ofil,0,0);
        outFileStm.Position := 0;
        outFileStm.WriteBuffer(HDR,SizeOf(HDR));
//        FileWrite(ofil,HDR,SizeOf(HDR));
        tsize := outFileStm.Size;

//        FileClose(ofil);
        etime := now;

        writeln(' - Compiled successfully! ['+inttostr(tsize)+' bytes] ['+Format('%3.3f',[MillisecondsBetween(etime, stime)/1000])+' secs]');
        end
      end
    else
      writeln('   Error could not create/open the file.. Aborting!');
    end
  end
  else
    writeln('  - File not found.. Aborting!');
    
end;

var xp: integer;
var NoCRC,NoIcon,PascalOutput,PascalOutputInclude: boolean;
begin
  { TODO -oUser -cConsole Main : placez le code ici }

   writeln('Dragon Language Compiler                Version: '+AppVersion+' '+AppEdit);
   writeln('Created by Alexandre Devilliers             URL: http://www.elberethzone.net');
   writeln;

   if ParamCount = 0 then
   begin
     writeln(' This program will compile a Dragon Language Source File (LSF) to a');
     writeln(' Dragon LaNGuage compiled file (LNG).');
     writeln;
     writeln(' Usage: dlngc <sourcefile.ls> [options]');
     writeln;
     writeln(' Output format: DLNG version 4');
     writeln('      Optional: DLNG version 4 for Delphi inclusion');
     writeln;
     writeln(' Options:  /nocrc or /nc       Don''t compute CRCs');
     writeln('           /noicon or /ni      Force no icon in DLNG');
     writeln('           /internal or /il    Output Delphi inclusion code (v5.3.x)');
     writeln('           /include or /in     Output Delphi include code (v5.4.0+)');
   end
   else
   begin
     NoCRC := false;
//     NoDisplay := false;
     NoIcon := false;
     PascalOutput := false;
     PascalOutputInclude := false;
     writeln(' Parsing parameters...');
     xp := 2;
     while (xp <= ParamCount) do
     begin
       if (lowercase(ParamStr(xp)) = '/nc') or (lowercase(ParamStr(xp)) = '/nocrc') then
         NoCRC := true;
       if (lowercase(ParamStr(xp)) = '/ni') or (lowercase(ParamStr(xp)) = '/noicon') then
         NoIcon := true;
       if (lowercase(ParamStr(xp)) = '/il') or (lowercase(ParamStr(xp)) = '/internal') then
         PascalOutput := true;
       if (lowercase(ParamStr(xp)) = '/in') or (lowercase(ParamStr(xp)) = '/include') then
         PascalOutputInclude := true;
       writeln(' - Unknown parameter: ' + ParamStr(xp));
       xp := xp + 1;
     end;
     fcrctable := crc32gen;
     Compile(ParamStr(1),NoCRC,NoIcon,PascalOutput,PascalOutputInclude);
   end;

end.