program dlngcomp;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  DateUtils,
  zlib,
  lib_utils in '..\..\common\lib_utils.pas',
  spec_DLNG in '..\..\common\spec_DLNG.pas',
  lib_BinUtils in '..\..\common\lib_BinUtils.pas',
  lib_zlib in '..\..\common\lib_zlib.pas',
  lib_crc in '..\..\common\lib_crc.pas';

const AppVersion : string = '4.0.0';
      AppEdit : string = '';
      DLNG_Version : Byte = 4;
      DLNG_Manufacturer : Byte = 30;

type
   Internal_Tab = record
     ID: string;
     Value: Widestring;
   end;
   LngTab = record
     Result: Boolean;
     Version: Byte;
     PrgID: ShortString;
     PrgVER: Byte;
     FileSize: Word;
     FileCRC: Integer;
     IndexOffSet: Integer;
     IndexNum: Integer;
     IndexCRC: Integer;
     DataOffSet: Integer;
     DataSize: Integer;
     DataCSize: Integer;
     DataCRC: Integer;
     ExtInfo: DLNG_ExtendedHeader;
     Compression: Byte;
     NoValueCompare: Boolean;
     Num: integer;
     Tab: array[1..2000] of Internal_Tab;
   end;

   DLNG_Header = packed record
     ID: array[0..4] of Char;
     Version: Byte;
     PrgID: array[1..2] of Char;
     PrgVER: Byte;
   end;

type LNGv1_Header = record
       ID: array[0..4] of char;
       Version: byte;
       PrgID: array[0..1] of char;
       PrgVer: byte;
       Compress: byte;
       Crypt: integer;
       Percent: byte;
       JamData: word;
       IndexOffSet: integer;
       IndexSize: integer;
     end;
     LNGv1_Index = record
       Nom: array[0..5] of char;
       Offset: integer;
       Size: word;
     end;
     LNGv1_Footer_v1 = record
       CheckSum: integer;
       Manufacturer: byte;
       Version: byte;
     end;
     LNGv1_Footer_v2 = record
       IndexChecksum: integer;
       BodyChecksum: integer;
       CheckSum: integer;
       Manufacturer: byte;
       Version: byte;
     end;

type LNGv2_Header = record
       ID: array[0..4] of char;
       Version: byte;
       PrgID: array[0..1] of char;
       PrgVer: byte;
       Compress: byte;
       Crypt: integer;
       JamData: integer;
       IndexOffSet: integer;
       IndexSize: integer;
       IndexChecksum: byte;
       BodySize: integer;
       BodyChecksum: byte;
       Manufacturer: byte;
     end;

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

procedure LoadLanguage(fil: string; out res: LngTab);
var HDR: DLNG_Header;
    HDR3: DLNG_Header_v3;
    HDR4: DLNG_Header_v4;
    HDRX: DLNG_ExtendedHeader;
    HDR1: LNGv1_Header;
    HDR2: LNGv2_Header;
    FOOT1: LNGv1_Footer_v1;
    FOOT2: LNGv1_Footer_v2;
    Idx1: LNGv1_Index;
    lng,x: integer;
    IDX3: DLNG_IndexEntry_v3;
    Idx4: array[1..1000] of DLNG_IndexEntry_v4;
    inpFileStm: THandleStream;
    dataStm: TMemoryStream;
    decompStm: TDecompressionStream;
begin

  res.NoValueCompare := false;
  res.Result := false;

  if FileExists(fil) then
  begin
    lng := FileOpen(fil, (fmOpenRead or fmShareExclusive));
    try
      Write(' + Reading header... ');
      FileRead(lng,HDR,SizeOf(HDR));
      Writeln('OK');

      if HDR.ID <> 'DLNG'+chr(26) then
      begin
        Writeln(' - This is not a valid Dragon Software Language file.');
        res.Result := False;
      end
      else
        if (HDR.Version <> 3) and (HDR.Version <> 1) and (HDR.Version <> 4) then
        begin
          Writeln(' - Unsupported version of Dragon Software Language file. (version '+IntToStr(HDR.Version)+')');
          Writeln('   Supported versions include: v1 v3 v4');
          res.Result := False;
        end
        else
        begin

          case HDR.Version of
            4: begin

                 FileSeek(lng,0,0);
                 FileRead(lng,HDR4,SizeOf(HDR4));
                 res.Version := HDR4.Version;
                 res.PrgID := HDR4.PrgID;
                 res.PrgVER := HDR4.PrgVER;
                 res.FileSize := 0;
                 res.FileCRC := 0;
                 res.DataOffSet := HDR4.DataOffSet;
                 res.DataSize := HDR4.DataSize;
                 res.DataCSize := HDR4.DataCSize;
                 res.DataCRC := HDR4.DataCRC;
                 res.IndexOffSet := HDR4.IndexOffSet;
                 res.IndexNum := HDR4.IndexNum;
                 res.IndexCRC := HDR4.IndexCRC;

                 Write(' + Reading extended header... ');

                 res.ExtInfo.Name := Get8u(lng);
                 res.ExtInfo.Author := Get8u(lng);
                 res.ExtInfo.URL := Get8u(lng);
                 res.ExtInfo.Email := Get8u(lng);
                 res.ExtInfo.FontName := Get8u(lng);

                 Writeln('OK');

                 Write(' + Loading language data... ');

                 dataStm := TMemoryStream.Create;
                 try

                   inpFileStm := THandleStream.Create(lng);
                   try
                     inpFileStm.Seek(HDR4.DataOffSet,soFromBeginning);

                     if HDR4.Compression = 0 then
                     begin

                       dataStm.CopyFrom(inpFileStm, HDR4.DataSize);

                     end
                     else if HDR4.Compression = 99 then
                     begin

                       decompStm := TDecompressionStream.Create(inpFileStm);
                       dataStm.CopyFrom(decompStm,HDR4.DataSize);
                       decompStm.Free;

                     end;

                     dataStm.Seek(0,soFromBeginning);

                   finally
                     inpFileStm.Free;
                   end;

                   FileSeek(lng, HDR4.IndexOffSet,0);

                   res.Num := HDR4.IndexNum;

                   for x := 1 to HDR4.IndexNum do
                   begin
                     FillChar(Idx4[x],SizeOf(DLNG_IndexEntry_v4),0);
                     FileRead(lng,Idx4[x],SizeOf(DLNG_IndexEntry_v4));
                     res.Tab[x].ID := Idx4[x].ID;
                     dataStm.Seek(Idx4[x].Offset*2,soFromBeginning);
                     setLength(res.Tab[x].Value,Idx4[x].Length);
                     dataStm.ReadBuffer(res.Tab[x].Value[1],Idx4[x].Length*2);
                   end;

                 finally
                   dataStm.Free;
                 end;

                 writeln('OK ('+inttostr(res.Num)+' entries)');

                 res.Result := true;
               end;

            3: begin

                 FileSeek(lng,0,0);
                 FileRead(lng,HDR3,SizeOf(HDR3));
                 res.Version := HDR3.Version;
                 res.PrgID := HDR3.PrgID;
                 res.PrgVER := HDR3.PrgVER;
                 res.FileSize := HDR3.FileSize;
                 res.FileCRC := HDR3.FileCRC;

                 Write(' + Reading extended header... ');

                 res.ExtInfo.Name := Get8(lng);
                 res.ExtInfo.Author := Get8(lng);
                 res.ExtInfo.URL := Get8(lng);
                 res.ExtInfo.Email := Get8(lng);

                 Writeln('OK');

                 Write(' + Loading language data... ');

                 FileSeek(lng, HDR3.IndexOffSet,0);

                 res.Num := HDR3.IndexNum;

                 for x := 1 to HDR3.IndexNum do
                 begin
                   FillChar(idx3,8,0);
                   FileRead(lng,idx3,8);
                   res.Tab[x].ID := idx3.ID;
                   res.Tab[x].Value := Get16v(lng,idx3.Length);
                 end;

                 writeln('OK ('+inttostr(res.Num)+' entries)');

                 res.Result := true;
               end;
            1: begin

                 Write(' + Reading old header (DLNG v1)... ');

                 FileSeek(lng,0,0);
                 FileRead(lng,HDR1.ID,5);
                 FileRead(lng,HDR1.Version,1);
                 FileRead(lng,HDR1.PrgID,2);
                 FileRead(lng,HDR1.PrgVER,1);
                 FileRead(lng,HDR1.Compress,1);
                 FileRead(lng,HDR1.Crypt,4);
                 FileRead(lng,HDR1.Percent,1);
                 FileRead(lng,HDR1.JamData,2);
                 FileRead(lng,HDR1.IndexOffSet,4);
                 FileRead(lng,HDR1.IndexSize,4);

                 FileSeek(lng,FileSeek(lng,0,2)-6,0);
                 FileRead(lng,FOOT1.Checksum,4);
                 FileRead(lng,FOOT1.Manufacturer,1);
                 FileRead(lng,FOOT1.Version,1);

                 if (FOOT1.Version = 6) or
                    (FOOT1.Version = 11) or
                    (FOOT1.Version = 14) or
                    (FOOT1.Version = 21) then
                 begin

                   Write('OK (');

                   case FOOT1.Version of
                     6: write('Footer v1');
                    11: write('Footer v1.1');
                    14: write('Footer v2');
                    21: write('Footer v2.1');
                   end;

                   Write(' / ');

                   case FOOT1.Manufacturer of
                     1: write('DLNGC v1.0');
                    20: write('DLNGC v2.0');
                    99: write('DLNGC v1.1/v1.2');
                   end;

                   Writeln(')');
                 end
                 else
                   Writeln('OK');

                 if HDR1.Compress <> 0 then
                 begin
                   writeln(' - This file identify as a compressed DLNG v1 file.');
                   writeln('   Compression is broken in DLNG v1 file. Aborting.');
                 end
                 else
                 begin
                   if HDR1.Crypt <> 0 then
                   begin
                     writeln(' - This file is a crypted DLNG v1 file.');
                     writeln('   This program cannot decrypt old DLNG v1/v2 files.');
                     writeln('   Report won''t include value comparison.');
                     res.NoValueCompare := true;
                   end;

                   res.Version := HDR1.Version;
                   res.PrgID := HDR1.PrgID;
                   res.PrgVER := HDR1.PrgVER;
                   res.FileSize := 0;
                   res.FileCRC := 0;

                   Write(' + Loading language data... ');

                   FileSeek(lng,HDR1.IndexOffSet-1,0);
                   for x := 1 to HDR1.IndexSize do
                   begin
                     FileSeek(lng,HDR1.IndexOffSet+(x-1)*12-1,0);
                     FileRead(lng,Idx1.Nom,6);
                     res.Tab[x].ID := Idx1.Nom;
                     if not(res.NoValueCompare) then
                     begin
                       FileRead(lng,Idx1.Offset,4);
                       FileRead(lng,Idx1.Size,2);
                       FileSeek(lng,Idx1.Offset-1,0);
                       res.Tab[x].Value := Get16v(lng,Idx1.Size);
                     end;
                   end;

                   writeln('OK ('+inttostr(HDR1.IndexSize)+' entries)');

                   res.Num := HDR1.IndexSize;

                   res.Result := true;
                 end;

               end;
          end;
        end;

    finally
      write(' + Closing file... ');
      FileClose(lng);
      writeln('OK');
    end;
  end
  else
    writeln(' - File not found!');
end;


procedure Compare(sin1, sin2, rep: string);
var stime,etime: TDateTime;
    lng1, lng2: LngTab;
    hTxt: TextFile;
    tmps: string;
    x,y,diff,totdiff: integer;
    res: boolean;
    disp1,disp2: string;
begin

  stime := now;

  writeln(' Loading '+ExtractFilename(sin1)+'...');
  LoadLanguage(sin1, lng1);

  if lng1.Result then
  begin
    writeln(' Loading '+ExtractFilename(sin2)+'...');
    LoadLanguage(sin2, lng2);
    if lng2.Result then
    begin

      writeln(' Creating report file... ');
      if FileExists(rep) then
      begin
        write(' + Exist... Deleting... ');
        DeleteFile(rep);
        writeln('OK');
      end;

      Assign(hTxt, rep);
      Rewrite(hTxt);

      DateTimeToString(tmps,'dd/mm/yyyy hh:nn:ss',now);

      disp1 := ExtractFileName(sin1);
      disp2 := ExtractFileName(sin2);

      Writeln(hTxt,'Language Compare Report created '+tmps+' using DLNGComp v'+AppVersion+' '+AppEdit);
      Writeln(hTxt,'===============================================================================');
      Writeln(hTxt);
      Writeln(hTxt,'Language file 1: '+disp1+' (DLNG v'+inttostr(lng1.Version)+' - '+inttostr(lng1.Num)+' entries)');
      Writeln(hTxt,'Language file 2: '+disp2+' (DLNG v'+inttostr(lng2.Version)+' - '+inttostr(lng2.Num)+' entries)');
      Writeln(hTxt);
      Writeln(hTxt,'Entries difference: '+IntToStr(abs(lng1.Num - lng2.Num)));
      Writeln(hTxt);
      Writeln(hTxt,'-------------------------------------------------------------------------------');
      Writeln(hTxt);

      write(' + Comparing infos... ');

      Writeln(hTxt,'Basic comparison:');
      Writeln(hTxt,'-----------------');
      Writeln(hTxt);

      diff := 0;

      Write(hTxt,'Program ID     : ');

      if lng1.PrgID = lng2.PrgID then
        Writeln(hTxt,lng1.PrgID + ' (Both)')
      else
      begin
        Writeln(hTxt,lng1.prgID+' ('+disp1+') / '+lng2.prgID+' ('+disp2+')');
        inc(diff);
      end;
      Write(hTxt,'Program Version: ');
      if lng1.PrgVER = lng2.PrgVER then
        Writeln(hTxt,inttostr(lng1.PrgVER) + ' (Both)')
      else
      begin
        Writeln(hTxt,inttostr(lng1.prgVER)+' ('+disp1+') / '+inttostr(lng2.prgVER)+' ('+disp2+')');
        inc(diff);
      end;
      {
      Write(hTxt,'Info (Name)    : ');
      if lng1.ExtInfo.Name = lng2.ExtInfo.Name then
        Writeln(hTxt,lng1.ExtInfo.Name + ' (Both)')
      else
      begin
        Writeln(hTxt,lng1.ExtInfo.Name+' ('+disp1+') / '+lng2.ExtInfo.Name+' ('+disp2+')');
        inc(diff);
      end;
      Write(hTxt,'Info (Author)  : ');
      if lng1.ExtInfo.Author = lng2.ExtInfo.Author then
        Writeln(hTxt,lng1.ExtInfo.Author + ' (Both)')
      else
      begin
        Writeln(hTxt,lng1.ExtInfo.Author+' ('+disp1+') / '+lng2.ExtInfo.Author+' ('+disp2+')');
        inc(diff);
      end;
      Write(hTxt,'Info (Email)   : ');
      if lng1.ExtInfo.Email = lng2.ExtInfo.Email then
        Writeln(hTxt,lng1.ExtInfo.Email + ' (Both)')
      else
      begin
        Writeln(hTxt,lng1.ExtInfo.Email+' ('+disp1+') / '+lng2.ExtInfo.Email+' ('+disp2+')');
        inc(diff);
      end;
      Write(hTxt,'Info (URL)     : ');
      if lng1.ExtInfo.URL = lng2.ExtInfo.URL then
        Writeln(hTxt,lng1.ExtInfo.URL + ' (Both)')
      else
      begin
        Writeln(hTxt,lng1.ExtInfo.URL+' ('+disp1+') / '+lng2.ExtInfo.URL+' ('+disp2+')');
        inc(diff);
      end;
      }
      writeln(hTxt);
      writeln(hTxt,'  Total: '+inttostr(diff));
      Writeln(hTxt);
      Writeln(hTxt);

      totdiff := totdiff + diff;

      writeln('OK');
      write(' + Comparing entries... ');

      Writeln(hTxt,'Entries comparison:');
      Writeln(hTxt,'-------------------');
      Writeln(hTxt);
      Writeln(hTxt,'Entries found in '+disp1+' but not in '+disp2+':');
      Writeln(hTxt);

      diff := 0;

      for x := 1 to lng1.num do
      begin
        res := false;
        y := 1;

        while (y <= lng2.Num) and not(res) do
        begin
          res := lng1.Tab[x].ID = lng2.Tab[y].ID;
          inc(y);
        end;

        if not(res) then
        begin
          inc(diff);
          if lng1.NoValueCompare then
            Writeln(hTxt, TrimRight(lng1.tab[x].ID))
          else
            Writeln(hTxt, TrimRight(lng1.tab[x].ID) + '=' + lng1.tab[x].Value);
        end;

      end;

      totdiff := totdiff + diff;
      
      writeln(hTxt);
      writeln(hTxt,'  Total: '+inttostr(diff));

      Writeln(hTxt);
      Writeln(hTxt,'Entries found in '+disp2+' but not in '+disp1+':');
      Writeln(hTxt);

      diff := 0;

      for x := 1 to lng2.num do
      begin
        res := false;
        y := 1;

        while (y <= lng1.Num) and not(res) do
        begin
          res := lng2.Tab[x].ID = lng1.Tab[y].ID;
          inc(y);
        end;

        if not(res) then
        begin
          inc(diff);
          if lng2.NoValueCompare then
            Writeln(hTxt, TrimRight(lng2.tab[x].ID))
          else
            Writeln(hTxt, TrimRight(lng2.tab[x].ID) + '=' + lng2.tab[x].Value);
        end;

      end;

      writeln(hTxt);
      writeln(hTxt,'  Total: '+inttostr(diff));
      Writeln(hTxt);
      Writeln(hTxt);

      totdiff := totdiff + diff;

      writeln('OK');

      if (not(lng1.NoValueCompare) and not(lng2.NoValueCompare)) then
      begin
        write(' + Comparing values... ');

        Writeln(hTxt,'Values comparison:');
        Writeln(hTxt,'------------------');
        Writeln(hTxt);
        Writeln(hTxt,'Values modified between '+disp1+' (1) and '+disp2+' (2):');
        Writeln(hTxt);
        diff := 0;

        for x := 1 to lng1.num do
        begin
          res := false;
          y := 1;

          while (y <= lng2.Num) and not(res) do
          begin
            res := lng1.Tab[x].ID = lng2.Tab[y].ID;
            if not(res) then
              inc(y);
          end;

          if res then
            if lng1.tab[x].Value <> lng2.Tab[y].Value then
            begin
              inc(diff);
              Writeln(hTxt, '(1) '+TrimRight(lng1.tab[x].ID)+'='+lng1.tab[x].Value);
              Writeln(hTxt, '(2) '+TrimRight(lng2.tab[y].ID)+'='+lng2.tab[y].Value);
            end;

        end;

        writeln(hTxt);
        writeln(hTxt,'  Total: '+inttostr(diff));

        totdiff := totdiff + diff;

        writeln('OK');

        writeln(hTxt);

      end;

      Writeln(hTxt,'===============================================================================');
      tmps := 'Found '+inttostr(totdiff)+' difference(s)';

      writeln(hTxt,Copy('                                                                               '+tmps,length(tmps)+1,79));

      write(' + Closing file... ');

      Close(hTxt);

      writeln('OK');
      writeln(' Finished!');

    end;
  end;

end;

var xp: integer;
var NoCRC,NoDisplay,NoIcon: boolean;
var report: string;
begin
  { TODO -oUser -cConsole Main : placez le code ici }

   writeln('Dragon Software - Language Compare             Version: '+AppVersion+' '+AppEdit);
   writeln('(c)Copyright 2002 Alexandre Devilliers             URL: http://www.drgsoft.com/');
   writeln;

   if (ParamCount < 2) or (ParamCount > 3) then
   begin
     writeln(' This program will compare two Dragon Software Language files (LNG) and');
     writeln(' create a detailled report of differences.');
     writeln;
     writeln(' Usage: dlngcomp <srcfile1.lng> <srcfile2.lng> [reportfile.txt]');
     writeln;
     writeln(' Input formats: DLNG version 1 (without encryption)');
     writeln('                DLNG version 3');
     writeln('                DLNG version 4');
   end
   else
   begin
     writeln(' Parsing parameters...');
     if ParamCount = 2 then
     begin
       report := 'report.txt';
       writeln('  - Report file set to default (report.txt)');
     end
     else
     begin
       report := ParamStr(3);
       writeln('  - Report file set to '+ParamStr(3));
     end;
     fcrctable := crc32gen;
     Compare(ParamStr(1),ParamStr(2),report);
   end;

end.
