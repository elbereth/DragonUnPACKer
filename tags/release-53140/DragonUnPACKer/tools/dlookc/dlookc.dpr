program dlookc;

{$APPTYPE CONSOLE}

// $Id: dlookc.dpr,v 1.1.1.1 2004-05-08 10:26:55 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/tools/dlookc/dlookc.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is dlookc.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

uses
  SysUtils, DateUtils, spec_DULK in '..\..\common\spec_DULK.pas';

const AppVersion = '1.1.1';
      AppEdit = 'Beta';

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
    idx: array[1..100] of DULK_IndexEntry;
    str: array[1..100] of String;
    exc: array[1..100] of String;
    IsHeader, IsBody, IsLOOK, IsError, XP: Boolean;
    Cline, Uline, poseq, NumIDX, x, ofil, ifil, tsize, excnum: integer;
    ErrInfo: string;
    HDR: DULK_Header0;
    Nom,Auteur,Email,Comment: String;
    tbyt : byte;
    Buffer: Pchar;
    stime,etime: TDateTime;
    FSize, BufSize : integer;
begin

  stime := now;

  writeln(' Compiling from '+sin+'...');

  if FileExists(sin) then
  begin
    AssignFile(hin, sin);
    Reset(hin);

    IsHeader := False;
    IsBody := False;
    IsLOOK := False;
    IsError := False;
    XP := False;
    cline := 0;
    uline := 0;
    BufSize := 0;
    NumIdx := 0;
    excnum := -1;
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
          if tmps = '{LOOK}' then
            IsLOOK := True
          else if IsLOOK and Not(IsBody) and (tmps = '{HEADER}') then
            IsHeader := True
          else if IsLOOK and Not(IsHeader) and (tmps = '{BODY}') then
            IsBody := True
          else if IsLOOK and IsHeader and (tmps = '{/HEADER}') then
            IsHeader := False
          else if IsLOOK and IsBody and (tmps = '{/BODY}') then
            IsBody := False
          else if IsLOOK and Not(IsBody) and Not(IsHeader) and (tmps = '{/LOOK}') then
            IsLOOK := False
          else
          begin
            IsError := True;
            ErrInfo := 'Unknown tag or forbidden here - '+tmps;
          end;
        end
        else
          if IsLOOK then
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
                    Nom := valu
                  else if keyw = 'EMAIL' then
                    Email := valu
                  else if keyw = 'AUTHOR' then
                    Auteur := valu
                  else if keyw = 'COMMENT' then
                    Comment := valu
                  else if keyw = 'XP' then
                    XP := StrToBool(UpperCase(TrimRight(valu)))
                  else if keyw = 'OUTFILE' then
                    outfil := valu
                  else
                  begin
                    IsError := True;
                    ErrInfo := 'Unknown header keyword ['+keyw+']';
                  end
                end
                else
                begin
                  NumIdx := NumIdx + 1;
                  FSize := GetFileSize(valu);
                  if FSize > 0 then
                  begin
                    FillChar(Idx[NumIdx].ID,4,32);
                    for x := 1 to length(keyw) do
                      Idx[NumIdx].ID[x] := keyw[x];
                    Idx[NumIdx].Size := FSize;
                    Str[NumIdx] := valu;
                    if FSize > BufSize then
                      BufSize := FSize;
                  end
                  else
                  begin
                    NumIdx := NumIdx - 1;
                    inc(excnum);
                    exc[excnum] := 'Line #'+inttostr(cline)+': '+valu;
                    if (FSize = 0) then
                      exc[excnum] := exc[excnum] + ' (File is empty)'
                    else
                      exc[excnum] := exc[excnum] + ' (File not found)';
                  end;
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
      writeln('   State: IsLSF='+BoolToStr(IsLOOK)+' IsHeader='+BoolToStr(IsHeader)+' IsBody='+BoolToStr(IsBody));
    end
    else
    begin
      if (excnum > -1) then
      begin
        writeln('WARNING ['+IntToStr(Cline)+' lines - '+IntToStr(ULine)+' used - '+inttostr(Excnum+1)+' warnings]');
        for x := 0 to excnum do
          writeln('   '+exc[x]);
      end
      else
        writeln('OK ['+IntToStr(Cline)+' lines - '+IntToStr(ULine)+' used]');
      writeln(' - Writing file..... '+outfil);
      ofil := FileCreate(outfil);

      if ofil <> 0 then
      begin

        HDR.ID[0] := 'D';
        HDR.ID[1] := 'U';
        HDR.ID[2] := 'L';
        HDR.ID[3] := 'K';
        HDR.ID[4] := #26;

        HDR.Version := 1;

        HDR.Attribs := 0;

        if XP then
          HDR.Attribs := HDR.Attribs or 1;

        HDR.Manufacturer := 11;

        HDR.IndexNum := NumIdx;
        HDR.IndexOffset := SizeOf(HDR)+length(Nom)+length(Auteur)+length(Email)+length(Comment)+4;

        write('   Header........... ');

        FileWrite(ofil,HDR,SizeOf(HDR));

        writeln('OK ['+inttostr(SizeOf(HDR))+' bytes]');

        write('   Extended Header.. ');

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

        tbyt := length(Comment);
        FileWrite(ofil,tbyt,1);
        for x := 1 to Length(Comment) do
          FileWrite(ofil,Comment[x],1);

{        if FileExists(iconfil) and Not(NoIcon) then
        begin
          ifil := FileOpen(iconfil,fmOpenRead);
          try
            HDR.IconSize := FileSeek(ifil,0,2);
            FileSeek(ifil,0,0);
            GetMem(Buffer,HDR.IconSize);
            FileRead(ifil,Buffer^,HDR.IconSize);
          finally
            FileClose(ifil);
          end;
        end;}

        writeln('OK ['+inttostr(length(Nom)+length(Auteur)+length(Email)+length(Comment)+4)+' bytes]');

        write('   Index............ ');

        GetMem(Buffer,BufSize);

        FSize := 0;
        for x := 1 to NumIdx do
        begin
          FileWrite(ofil,Idx[x],8);
          ifil := FileOpen(Str[x],fmOpenRead);
          try
            FileSeek(ifil,0,0);
            FileRead(ifil,Buffer^,Idx[x].Size);
            FileWrite(ofil,Buffer^,Idx[x].Size);
          finally
            FileClose(ifil);
          end;
          FSize := FSize + Idx[x].Size + 8;
        end;

        FreeMem(Buffer);

        writeln('OK ['+inttostr(FSize)+' bytes]');

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
  { TODO -oUser -cConsole Main : placez le code ici }

   writeln('Dragon Software - DUP5 LOOK Compiler           Version: '+AppVersion+' '+AppEdit);
   writeln('(c)Copyright 2001-2002 Alexandre Devilliers        URL: http://www.drgsoft.com/');
   writeln;

   if ParamCount = 0 then
   begin
     writeln(' This program will compile a Dragon UnPACKer LOOK source file (plus BMP files)');
     writeln(' to a DUP5 compiled LOOK file (DULK).');
     writeln;
     writeln(' Usage: dlookc <sourcefile.look> [options]');
     writeln;
     writeln(' Output format: DULK version 1.1 (v1 compatible)');
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
 