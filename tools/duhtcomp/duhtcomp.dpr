program duhtcomp;

{$APPTYPE CONSOLE}

// $Id: duhtcomp.dpr,v 1.1.1.1 2004-05-08 10:27:03 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/tools/duhtcomp/duhtcomp.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is duhtcomp.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

uses
  SysUtils,
  spec_DUHT in '..\..\common\spec_DUHT.pas',
  DateUtils,
  StrUtils,
  zlib,
  classes,
  CRC32 in 'CRC32.pas';

const AppVersion = 20310;

type TEntryType = record
       ID: array[0..1] of char;
       FileSize: integer;
       Filename: string;
     end;

function getVersionFromInt(version: integer): string;
var majVer: integer;
    minVer: integer;
    revVer: integer;
    typVer: integer;
    valVer: integer;
    inStr: String;
    typStr: String;
    valStr: String;
begin

  if version >= 0 then
  begin
    inStr := IntToStr(version);

    if (length(inStr) >= 5) then
      majVer := StrToInt(LeftStr(inStr, length(inStr)-4))
    else
      majVer := 0;

    if (length(inStr) >= 4) then
      minVer := StrToInt(MidStr(inStr,length(inStr)-3,1))
    else
      minVer := 0;

    if (length(inStr) >= 3) then
      revVer := StrToInt(MidStr(inStr,length(inStr)-2,1))
    else
      revVer := 0;

    if (length(inStr) >= 2) then
      typVer := StrToInt(MidStr(inStr,length(inStr)-1,1))
    else
      typVer := 0;

    if (length(inStr) >= 5) then
      valVer := StrToInt(RightStr(inStr, 1))
    else
      valVer := 0;

    case typVer of
      0: typStr := 'Alpha';
      1: typStr := 'Beta';
      2: typStr := 'RC';
      3: typStr := 'Gold';
      4: typStr := '';
      5: typStr := '';
      6: typStr := '';
      7: typStr := 'Fix';
      8: typStr := 'Patch';
      9: typStr := 'Special';
    end;

    if (typVer = 4) and (valVer > 0) then
    begin
      typStr := 'Release';
      valStr := Chr(64+valVer);
    end
    else if (typVer = 5) then
    begin
      typStr := 'Release';
      valStr := Chr(74+valVer);
    end
    else if (typVer = 6) then
    begin
      typStr := 'Release';
      case valVer of
        7: valStr := '+';
        8: valStr := '++';
        9: valStr := '+++';
      else
        valStr := Chr(84+valVer);
      end;
    end
    else if (valVer > 0) then
      valStr := IntToStr(valVer)
    else
      valStr := '';

    result := TrimRight(IntToStr(majVer)+'.'+IntToStr(minVer)+'.'+IntToStr(revVer)+' '+typStr+ ' '+valStr);
  end
  else
    result := '???';

end;

function GetFileSize(fil: string): integer;
var hin: integer;
begin

  if FileExists(fil) then
  begin
    hin := FileOpen(fil,fmOpenRead);
    GetFileSize := FileSeek(hin,0,2);
    FileClose(hin);
  end
  else
    GetFileSize := -1;

end;

procedure Compile(sin: string);
var hin: TextFile;
    tmps,keyw,valu,outfil,iconfil: String;
    ent: array[1..100] of TEntryType;
    IsTSF, IsError, Compress: Boolean;
    numEnt, Cline, Uline, poseq, NumIM, x, y, ofil, ifil, tsize, excnum: integer;
    ErrInfo: string;
    HDR: DUHT_Header;
    HDRX: DUHT_HeaderX_v1;
    ENTRY: DUHT_Entry;
    Nom,Auteur,Email,Version,URL,Ext,ExtInfo: String;
    fnam: string;
    tbyt : byte;
    stime,etime: TDateTime;
    FSize, BufSize : integer;
    Buffer: PByteArray;
    OutputStream : TMemoryStream;
    InputStream : TCompressionStream;
begin

  stime := now;

  writeln(' Compiling from '+sin+'...');

  if FileExists(sin) then
  begin
    AssignFile(hin, sin);
    Reset(hin);

    IsTSF := False;
    IsError := False;
    Compress := False;
    cline := 0;
    uline := 0;
    BufSize := 0;
    excnum := -1;
    numim := 0;
    numEnt := 0;
    IconFil := '';

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
          if tmps = '{TSF}' then
            IsTSF := True
          else if IsTSF and (tmps = '{/TSF}') then
            IsTSF := False
          else
          begin
            IsError := True;
            ErrInfo := 'Unknown tag or forbidden here - '+tmps;
          end;
        end
        else
          if IsTSF then
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
              keyw := uppercase(keyw);
              if keyw = 'NAME' then
                Nom := valu
              else if keyw = 'URL' then
                URL := valu
              else if keyw = 'EMAIL' then
                Email := valu
              else if keyw = 'AUTHOR' then
                Auteur := valu
              else if keyw = 'VERSION' then
                Version := valu
              else if keyw = 'COMPRESSION' then
                Compress := StrToBool(UpperCase(TrimRight(valu)))
              else if keyw = 'OUTFILE' then
                outfil := valu
              else if keyw = 'DEFAULTEXT' then
                ext := valu
              else if keyw = 'EXTINFO' then
                extinfo := valu
              else if keyw = 'HEADERFILE' then
              begin
                inc(numEnt);
                ent[numEnt].ID[0] := 'H';
                ent[numEnt].ID[1] := 'D';
                ent[numEnt].FileSize := getFileSize(valu);
                ent[numEnt].Filename := valu;
              end
              else if keyw = 'FOOTERFILE' then
              begin
                inc(numEnt);
                ent[numEnt].ID[0] := 'F';
                ent[numEnt].ID[1] := 'T';
                ent[numEnt].FileSize := getFileSize(valu);
                ent[numEnt].Filename := valu;
              end
              else if keyw = 'VARIABLEFILE' then
              begin
                inc(numEnt);
                ent[numEnt].ID[0] := 'V';
                ent[numEnt].ID[1] := 'R';
                ent[numEnt].FileSize := getFileSize(valu);
                ent[numEnt].Filename := valu;
              end
              else if keyw = 'PREVIEW' then
              begin
                inc(numEnt);
                ent[numEnt].ID[0] := 'P';
                ent[numEnt].ID[1] := 'V';
                ent[numEnt].FileSize := getFileSize(valu);
                ent[numEnt].Filename := valu;
              end
              else if keyw = 'INCLUDEFILE' then
              begin
              begin
                inc(numEnt);
                ent[numEnt].ID[0] := 'I';
                ent[numEnt].ID[1] := 'M';
                ent[numEnt].FileSize := getFileSize(valu);
                ent[numEnt].Filename := valu;
              end
              end
              else
              begin
                IsError := True;
                ErrInfo := 'Unknown header keyword ['+keyw+']';
              end
            end
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
      writeln('   State: IsLSF='+BoolToStr(IsTSF));
    end
    else
    begin
      writeln('OK ['+IntToStr(Cline)+' lines - '+IntToStr(ULine)+' used]');
      writeln(' - Writing file..... '+outfil);
      ofil := FileCreate(outfil);

      if ofil <> 0 then
      begin

        // Header
        HDR.ID[0] := 'D';
        HDR.ID[1] := 'U';
        HDR.ID[2] := 'H';
        HDR.ID[3] := 'T';
        HDR.ID[4] := #26;

        HDR.Version := 2;
        HDR.Revision := 1;

        HDR.NumEntries := numEnt;
        HDR.ExtendedHeader := 1;
        HDR.StartOffset := SizeOf(DUHT_HeaderX_v1)+SizeOf(DUHT_Header)+
                           length(Auteur)+length(email)+length(version)+
                           length(nom)+length(URL)+length(ext)+length(extinfo)+7;

        write('   Header........... ');

        FileWrite(ofil,HDR,SizeOf(HDR));

        writeln('OK ['+inttostr(SizeOf(HDR))+' bytes]');

        write('   Extended Header.. ');

        // Extended Header
        HDRX.CompID[0] := 'D';
        HDRX.CompID[1] := 'U';
        HDRX.CompVersion := AppVersion;
        HDRX.DUPVersionID := 3;
//        Randomize;
//        HDRX.XORKey := Random(255);
        HDRX.XORKey := 0;

        FileWrite(ofil,HDRX,SizeOf(HDRX));

        writeln('OK ['+inttostr(SizeOf(HDRX))+' bytes]');

        write('   Extra Info....... ');

        tbyt := length(Nom);
        FileWrite(ofil,tbyt,1);
        for x := 1 to Length(Nom) do
          FileWrite(ofil,Nom[x],1);

        tbyt := length(Auteur);
        FileWrite(ofil,tbyt,1);
        for x := 1 to Length(Auteur) do
          FileWrite(ofil,Auteur[x],1);

        tbyt := length(Email);
        FileWrite(ofil,tbyt,1);
        for x := 1 to Length(Email) do
          FileWrite(ofil,Email[x],1);

        tbyt := length(Version);
        FileWrite(ofil,tbyt,1);
        for x := 1 to Length(Version) do
          FileWrite(ofil,Version[x],1);

        tbyt := length(URL);
        FileWrite(ofil,tbyt,1);
        for x := 1 to Length(URL) do
          FileWrite(ofil,URL[x],1);

        tbyt := length(ext);
        FileWrite(ofil,tbyt,1);
        for x := 1 to Length(ext) do
          FileWrite(ofil,ext[x],1);

        tbyt := length(extinfo);
        FileWrite(ofil,tbyt,1);
        for x := 1 to Length(extinfo) do
          FileWrite(ofil,extinfo[x],1);


        writeln('OK ['+inttostr(length(URL)+length(Nom)+length(Auteur)+length(Email)+length(Version)+length(ext)+length(extinfo)+7)+' bytes]');

        writeln('   Entries:');

        BufSize := 0;
        for x := 1 to NumEnt do
          if ent[x].FileSize > BufSize then
            BufSize := ent[x].FileSize;

        GetMem(Buffer,BufSize);

        FSize := 0;
        for x := 1 to NumEnt do
        begin
          if ent[x].ID = 'IM' then
            fnam := leftstr(ExtractFileName(ent[x].Filename)+'                       ',26)
          else if ent[x].ID = 'HD' then
            fnam := leftstr('{HD:Header}               ',26)
          else if ent[x].ID = 'VR' then
            fnam := leftstr('{VR:Variable}             ',26)
          else if ent[x].ID = 'FT' then
            fnam := leftstr('{FT:Footer}               ',26)
          else if ent[x].ID = 'PV' then
            fnam := leftstr('{PV:Preview}              ',26)
          else
            fnam := leftstr('{'+ent[x].ID+'}                      ',26);
          write('    '+fnam+' ('+rightstr('      '+inttostr(ent[x].FileSize),6)+' bytes)  CRC: ');
          ENTRY.ID[0] := ent[x].ID[0];
          ENTRY.ID[1] := ent[x].ID[1];
          ENTRY.FileSize := ent[x].FileSize;

          ifil := FileOpen(ent[x].Filename, fmOpenRead);
          FileRead(ifil,Buffer^,ent[x].FileSize);

          ENTRY.CRC32 := CalculateCRC32(Buffer^,ent[x].FileSize);
          write(inttohex(ENTRY.CRC32,8)+'  Comp: ');

          if not(Compress) then
          begin
            ENTRY.Compression := 0;
            ENTRY.Size := ENTRY.FileSize;
            write('None - ');
            FileWrite(ofil,ENTRY,SizeOf(ENTRY));
            if ENTRY.ID = 'IM' then
            begin
              fnam := extractfilename(ent[x].Filename);
              tbyt := length(fnam);
              FileWrite(ofil,tbyt,1);
              for y := 1 to Length(fnam) do
                FileWrite(ofil,fnam[y],1);
              inc(Fsize,tbyt+1);
            end;
            FileWrite(ofil,Buffer^,ENTRY.FileSize);
          end
          else
          begin
            ENTRY.Compression := 1;
            OutputStream := TMemoryStream.Create;
            try
              InputStream := TCompressionStream.Create(clMax, OutputStream);
              try
                InputStream.Write(buffer^, ENTRY.FileSize)
              finally
                InputStream.Free
              end;
              if Outputstream.Size < ENTRY.FileSize then
              begin
                ENTRY.Size := Outputstream.Size;
                OutputStream.Seek(0, soFromBeginning);
                OutputStream.Read(buffer^, ENTRY.Size);
                write(rightstr('   '+inttostr(Round(ENTRY.Size * 100 / ENTRY.FileSize)),3)+'% - ');
              end
              else
              begin
                ENTRY.Compression := 0;
                ENTRY.Size := ENTRY.FileSize;
                write('None - ');
              end;
            finally
              OutputStream.Free
            end;
            //Compress buffer
            FileWrite(ofil,ENTRY,SizeOf(ENTRY));
            if ENTRY.ID = 'IM' then
            begin
              fnam := extractfilename(ent[x].Filename);
              tbyt := length(fnam);
              FileWrite(ofil,tbyt,1);
              for y := 1 to Length(fnam) do
                FileWrite(ofil,fnam[y],1);
              inc(Fsize,tbyt+1);
            end;
            FileWrite(ofil,Buffer^,ENTRY.Size);
          end;

          writeln('OK');
          FileClose(ifil);

          inc(FSize,ENTRY.Size+SizeOf(ENTRY));

        end;

        FreeMem(Buffer);

        writeln('     OK  ('+rightstr('   '+inttostr(numEnt),3)+' entries writed)  ['+rightstr('      '+inttostr(FSize),6)+' bytes]');

        tsize := FileSeek(ofil,0,2);
        FileClose(ofil);
        etime := now;

        writeln(' - Compiled successfully! ['+inttostr(tsize)+' bytes] ['+Format('%3.3f',[MillisecondsBetween(etime, stime)/1000])+' secs]');
      end
    else
      writeln('   Error could not create/open the file.. Aborting!');
    end
  end
  else
    writeln('  - File not found.. Aborting!');

end;

var xp: integer;
begin
  { TODO -oUser -cConsole Main : Insert code here }

   writeln('Dragon Software - DUP5 UHT Compiler            Version: '+GetVersionFromInt(AppVersion));
   writeln('(c)Copyright 2002-2003 Alexandre Devilliers        URL: http://www.drgsoft.com/');
   writeln;

   if ParamCount = 0 then
   begin
     writeln(' This program will compile a Dragon UnPACKer TS source file (plus include');
     writeln(' files) to a DUP5 compiled HTML template file (DUHT).');
     writeln;
     writeln(' Usage: duhtcomp <sourcefile.ts> [options]');
     writeln;
     writeln(' Output format: DUHT version 2 revision 1');
     writeln;
     writeln(' Options:  None');
   end
   else
   begin
     writeln(' Parsing parameters...');
     xp := 2;
     while (xp <= ParamCount) do
     begin
       writeln('  - Unknown parameter: ' + ParamStr(xp));
       xp := xp + 1;
     end;
     Compile(ParamStr(1));
   end;


end.
