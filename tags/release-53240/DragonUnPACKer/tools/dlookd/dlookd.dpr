program dlookd;

{$APPTYPE CONSOLE}

// $Id: dlookd.dpr,v 1.2 2008-04-17 19:18:08 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/tools/dlookd/dlookd.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is dlookd.dpr, released April 15, 2008.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

uses
  SysUtils, DateUtils, spec_DULK in '..\..\common\spec_DULK.pas', Classes;

const AppVersion = '1.0.0';
      AppEdit = '';

// =============================================================================
//  Get8_Stream                                                        function
// -----------------------------------------------------------------------------
// Returns a string read from the stream & size passed in parameter.
// =============================================================================
function Get8_Stream(src: TStream): string;
var tbyte: Byte;
begin

  // Read 1 byte (size of following string)
  // Then read the string
  src.ReadBuffer(tbyte,1);
  SetLength(result,tbyte);
  src.ReadBuffer(result[1],tbyte);

end;

// =============================================================================
//  DecompileDULK                                                     procedure
// -----------------------------------------------------------------------------
// Decompile the source file (if DULK v1 format).
// Result is a .look file along with .bmp files of all entries of .dulk.
// =============================================================================
procedure DecompileDULK(sin: string);
var hin: TextFile;
    x, maxLen, maxLenX: integer;
    HDR: DULK_Header;
    ENT: DULK_IndexEntry;
    outfil,Nom,Auteur,Email,Comment: String;
    stime,etime: TDateTime;
    stmIn, stmOut: TFileStream;
begin

  // Store current DateTime (for duration calculation)
  stime := now;

  writeln(' - Decompiling '+sin+'...');

  // Check if source file exists
  if FileExists(sin) then
  begin

    // Create the TFileStream object for the source file
    stmIn := TFileStream.Create(sin,fmOpenRead);
    try
      outfil := ChangeFileExt(sin,'.look');

      write(' - Creating LOOK file '+outfil+'...');

      if FileExists(outfil) then
      begin

        writeln(' ERROR');
        writeln(' ! File already exists (Will not overwrite -> Terminate)');

      end
      else
      begin

        // Assign output file to the TextFile handle
        AssignFile(hin, outfil);

        // Open for writing
        Rewrite(hin);

        writeln('OK');
        write(' - Header............: ');

        // Will be used for the fancy display in a few lines
        maxLen := stmIn.Seek(0,2);
        stmIn.Seek(0,0);

        // Read the header
        stmIn.ReadBuffer(HDR,SizeOf(DULK_Header));

        // Some sanity checks to avoid reading further if not DULK file
        if (HDR.ID = 'DULK'+#26) and (HDR.Version = DULK_Version) then
        begin

          // This is just for fancy display (like StrPad of PHP)
          // There might be easier way to do it but I went for this dirty one ;)
          maxLen := maxLen - HDR.IndexOffset;
          if maxLen < 10 then
            maxLen := 1
          else if maxLen < 100 then
            maxLen := 2
          else if maxLen < 1000 then
            maxLen := 3
          else if maxLen < 10000 then
            maxLen := 4
          else if maxLen < 100000 then
            maxLen := 5
          else if maxLen < 1000000 then
            maxLen := 6
          else if maxLen < 10000000 then
            maxLen := 7
          else if maxLen < 100000000 then
            maxLen := 8
          else
            maxLen := 9;

          writeln('OK');
          write(' - Extended Header...: ');

          // Retrieve extended header (4 get8 strings)
          Nom := get8_stream(stmIn);
          Auteur := get8_stream(stmIn);
          Email := get8_stream(stmIn);
          Comment := get8_stream(stmIn);

          writeln('OK');

          // Write LOOK file header
          WriteLn(hin,'{LOOK}');
          WriteLn(hin,'{HEADER}');
          WriteLn(hin,'# Dragon UnPACKer 5 LooK (DULK) source');
          WriteLn(hin,'# =============================================================================');
          WriteLn(hin,'# Decompiled on '+DateTimeToStr(now)+' from '+sin);
          WriteLn(hin,'# By Dragon LOOK Decompiler v'+AppVersion+' '+AppEdit);
          WriteLn(hin,'# -----------------------------------------------------------------------------');
          WriteLn(hin,'Name='+Nom);
          WriteLn(hin,'Author='+Auteur);
          WriteLn(hin,'Email='+Email);
          WriteLn(hin,'Comment='+Comment);
          if (HDR.Attribs and 1) = 1 then
            WriteLn(hin,'XP=true')
          else
            WriteLn(hin,'XP=false');

          WriteLn(hin,'Outfile='+extractfilename(sin));

          // Write the end of header & start of body to the LOOK file
          WriteLn(hin,'{/HEADER}');
          WriteLn(hin,'{BODY}');

          writeln(' - Images data.......: '+inttostr(HDR.IndexNum));

          // Seek to the first entry position
          stmIn.Seek(HDR.IndexOffset,soFromBeginning);

          // This is again just for fancy display
          if HDR.IndexNum < 10 then
            maxLenX := 1
          else if HDR.IndexNum < 100 then
            maxLenX := 2
          else if HDR.IndexNum < 1000 then
            maxLenX := 3
          else if HDR.IndexNum < 10000 then
            maxLenX := 4
          else if HDR.IndexNum < 100000 then
            maxLenX := 5
          else if HDR.IndexNum < 1000000 then
            maxLenX := 6
          else if HDR.IndexNum < 10000000 then
            maxLenX := 7
          else if HDR.IndexNum < 100000000 then
            maxLenX := 8
          else
            maxLenX := 9;

          // Go through all entries
          for x:=1 to HDR.IndexNum do
          begin

            write('   ['+Copy(StringOfChar(' ',maxLenX-Length(inttostr(x)))+inttostr(x),1,maxLenX)+'] ');

            // Read the entry header
            stmIn.ReadBuffer(ENT,8);

            // Display some info to the user
            write('ID='+ENT.ID+' / Size='+Copy(StringOfChar(' ',maxLen-Length(inttostr(ENT.Size)))+inttostr(ENT.Size),1,maxLen)+' bytes - Extracting... ');

            // Extract the file by doing a CopyFrom between two TFileStream
            stmOut := TFileStream.Create(ExtractFilePath(sin)+ENT.ID+'.bmp',fmCreate);
            stmOut.CopyFrom(stmIn,ENT.Size);
            stmOut.Free;

            // Write the entry into the LOOK file
            WriteLn(hin,ENT.ID+'='+ENT.ID+'.bmp');

            writeln('OK');

          end;

        end
        else // DULK file is wrong
        begin
          writeln('ERROR');
          writeln(' ! Input file does not appear to be a valid DULK v1 file.');
        end;

        // Finish writing & close the LOOK file
        writeln(hin,'{/BODY}');
        writeln(hin,'{/LOOK}');
        CloseFile(hin);

        // Store the DateTime value
        etime := now;

        writeln(' - Decompiled successfully! ['+Format('%3.3f',[MillisecondsBetween(etime, stime)/1000])+' secs]');
      end;

    except
      // Deal with the unhandled exceptions
      on E: Exception do
      begin
        writeln;
        writeln(' ! Unhandled exception '+E.ClassName+' with message:');
        writeln('   '+E.Message);
      end;
    end;

    // Finally free the TFileStream object
    stmIn.Free;

  end
  else
    writeln('  - File not found.. Aborting!');

end;

var xp: integer;
begin

   writeln('Dragon UnPACKer 5 LOOK Decompiler          Version: '+AppVersion+' '+AppEdit);
   writeln('Created by Alexandre Devilliers                URL: http://www.elberethzone.net');
   writeln;

   if ParamCount = 0 then
   begin
     writeln(' This program will decompile a DUP5 compiled LOOK file (DULK) to');
     writeln(' Dragon UnPACKer LOOK source file (plus BMP files).');
     writeln;
     writeln(' Usage: dlookd <sourcefile.dulk> [options]');
     writeln;
     writeln(' Input format: DULK version 1');
     writeln;
     writeln(' Output format: LOOK [v1.1] + associated BMP files');
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
     DecompileDULK(ParamStr(1));
   end;

end.
