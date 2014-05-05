program dlngd;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes,
  SysUtils,
  CustApp,
  { you can add units after this }
  zstream,
  dateutils,
  spec_DLNG in '../../common/spec_DLNG.pas',
  lib_binutils in '../../common/lib_binutils.pas';

const
  DLNGD_VERSION: string = '4.0.0';
  DLNGD_EDIT: string = 'Beta';
  DLNG_VERSION: byte = 4;

type

  { TDLNGDecompiler }

  TDLNGDecompiler = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure DecompileDLNG(fil: string);
  end;

  { TDLNGDecompiler }

  procedure TDLNGDecompiler.DoRun;
  var
    ErrorMsg: string;
  begin

    writeln('Dragon LaNGuage De-Compiler                Version: ' +
      DLNGD_VERSION + ' ' + DLNGD_EDIT);
    writeln('Created by Alexandre Devilliers                URL: http://www.elberethzone.net');
    writeln;

    if ParamCount <> 1 then
    begin
      WriteHelp;
      Terminate;
      Exit;
    end;

    { add your program here }
    DecompileDLNG(ParamStr(1));

    // stop program loop
    Terminate;
  end;

  constructor TDLNGDecompiler.Create(TheOwner: TComponent);
  begin
    inherited Create(TheOwner);
    StopOnException := True;
  end;

  destructor TDLNGDecompiler.Destroy;
  begin
    inherited Destroy;
  end;

  procedure TDLNGDecompiler.WriteHelp;
  begin
    { add your help code here }
    writeln(' This program will decompile a Dragon LaNGuage file [DLNG] to');
    writeln(' Dragon LaNGuage source file [LSF] (plus BMP flag file).');
    writeln;
    writeln(' Usage: dlookd <sourcefile.dulk> [options]');
    writeln;
    writeln(' Input format: DLNG version ' + IntToStr(DLNG_VERSION));
    writeln;
    writeln(' Output format: LSF + associated BMP flag file');
    writeln;
    writeln(' Options:  None');
  end;

  procedure TDLNGDecompiler.DecompileDLNG(fil: string);
  var
    HDR: DLNG_Header_v4;
    HDRX: DLNG_ExtendedHeader;
    lng, icon: TFileStream;
    x: integer;
    Idx: array[1..1000] of DLNG_IndexEntry_v4;
    dataStm: TMemoryStream;
    decompStm: TDecompressionStream;
    strvalue: WideString;
    basefil, outfil, outfilbmp: string;
    stime, etime: TDateTime;
    hin: TextFile;
    buffer: PChar;
  begin

    // Store current DateTime (for duration calculation)
    stime := now;

    writeln(' - Decompiling ' + fil + '...');

    if FileExists(fil) then
    begin

      lng := TFileStream.Create(fil, fmOpenRead);
      try
        Write(' - Reading header....: ');
        lng.ReadBuffer(HDR, SizeOf(HDR));

        if HDR.ID <> 'DLNG' + chr(26) then
        begin
          writeln('ERROR');
          writeln('This is not a valid Dragon Software Language file.');
        end
        else
        if HDR.Version <> DLNG_VERSION then
        begin
          writeln('ERROR');
          writeln('Unsupported version of Dragon Software Language file.');
          writeln(' Needed: version ' + IntToStr(DLNG_VERSION));
          writeln('   File: version ' + IntToStr(HDR.Version));
        end
        else
        begin
          HDRX.Name := Get8u(lng);
          HDRX.Author := Get8u(lng);
          HDRX.URL := Get8u(lng);
          HDRX.Email := Get8u(lng);
          HDRX.FontName := Get8u(lng);

          writeln('OK');
          writeln('   Program ID........: ' + HDR.PrgID);
          writeln('   Program version...: ' + IntToStr(HDR.PrgVer));

          Write(' - Reading BMP flag..: ');
          outfilbmp := changefileext(fil, '.bmp');
          if HDR.IconSize > 0 then
          begin
            icon := TFileStream.Create(outfilbmp, fmCreate);
            icon.CopyFrom(lng, HDR.IconSize);
            writeln('OK (' + IntToStr(HDR.IconSize) + ' bytes in '+extractfilename(outfilbmp)+')');
            FreeAndNil(icon);
          end
          else
            writeln('No flag');

          dataStm := TMemoryStream.Create;
          try

            lng.Seek(HDR.DataOffSet, soBeginning);

            if HDR.Compression = 0 then
            begin

              dataStm.CopyFrom(lng, HDR.DataSize);

            end
            else if HDR.Compression = 99 then
            begin

              decompStm := TDecompressionStream.Create(lng);
              dataStm.CopyFrom(decompStm, HDR.DataSize);
              FreeAndNil(decompStm);

            end;

            dataStm.Seek(0, soBeginning);

            lng.Seek(HDR.IndexOffSet, 0);
            outfil := changefileext(fil, '.ls');

            Write(' - Creating LSF file ' + outfil + '... ');

            if FileExists(outfil) then
            begin

              writeln(' ERROR');
              writeln(' ! File already exists (Will not overwrite -> Terminate)');
              Terminate;
              Exit;

            end
            else
            begin

              // Assign output file to the TextFile handle
              AssignFile(hin, outfil);

              // Open for writing
              Rewrite(hin);

              writeln('OK');
              Write(' - Header............: ');
              writeln(hin, '# Language Source File (for DLNGC v4.0)');
              WriteLn(hin,
                '# =============================================================================');
              WriteLn(hin, '# Decompiled on ' + DateTimeToStr(now) + ' from ' + fil);
              WriteLn(hin, '# By Dragon LaNGuage Decompiler v' + trim(
                DLNGD_VERSION + ' ' + DLNGD_EDIT));
              WriteLn(hin,
                '# -----------------------------------------------------------------------------');
              writeln(hin, '{LSF}');
              writeln(hin, '{HEADER}');
              writeln(hin, 'Name = ' + HDRX.Name);
              writeln(hin, 'Author = ' + HDRX.Author);
              writeln(hin, 'Email = ' + HDRX.Email);
              writeln(hin, 'URL = ' + HDRX.URL);
              writeln(hin, 'ProgramID = ' + HDR.PrgID);
              writeln(hin, 'ProgramVer = ' + IntToStr(HDR.PrgVER));
              if HDR.IconSize > 0 then
                writeln(hin, 'IconFile = ' + extractfilename(outfilbmp));
              writeln(hin, 'OutFile = ' + extractfilename(fil));
              if HDRX.FontName <> '' then
                writeln(hin, 'FontName = ' + HDRX.FontName);
              writeln(hin, 'Compression = 99');
              writeln(hin, '{/HEADER}');
              writeln('OK');
              Write(' - Body..............: ');
              writeln(hin, '{BODY}');

              for x := 1 to HDR.IndexNum do
              begin
                FillChar(Idx[x], SizeOf(DLNG_IndexEntry_v4), 0);
                lng.Read(Idx[x], SizeOf(DLNG_IndexEntry_v4));
                dataStm.Seek(Idx[x].Offset * 2, soBeginning);
                setLength(strValue, Idx[x].Length);
                dataStm.ReadBuffer(strValue[1], Idx[x].Length * 2);
                writeln(Hin, Trim(Idx[x].ID) + '=' + strValue);
              end;
              writeln(hin, '{/BODY}');
              writeln('OK (' + IntToStr(HDR.IndexNum) + ' entries)');
              CloseFile(hin);

              // Store the DateTime value
              etime := now;

              writeln(' - Decompiled successfully! [' + Format(
                '%3.3f', [MillisecondsBetween(etime, stime) / 1000]) + ' secs]');

            end;

          finally
            FreeAndNil(dataStm);
          end;

        end;

      finally
        FreeAndNil(lng);
      end;
    end;

  end;

var
  Application: TDLNGDecompiler;
begin
  Application := TDLNGDecompiler.Create(nil);
  Application.Title := 'Dragon LaNGuage De-Compiler';
  Application.Run;
  Application.Free;
end.
