library drv_zip;

// $Id: drv_zip.dpr,v 1.1.1.1 2004-05-08 10:26:54 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/drivers/zip/drv_zip.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is drv_zip.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

uses
  SysUtils,
  Windows,
  dup5drv_utils in '..\dup5drv_utils.pas',
  dup5drv_data in '..\dup5drv_data.pas',
  UnZip32 in 'UnZip32.pas',
  lib_version in '..\..\..\common\lib_version.pas';

{$E d5d}

{$R *.res}
type
   TPercentCallback = procedure (p: byte);
   TLanguageCallback = function (lngid: ShortString): ShortString;

{ /////////////////////////////////////////////////////////////////////////////

  10240  50012  Added Line of Sight: Vietnam .ZA to the supported file types
                Added Master of Orion 3 .MOB to the supported files types
  10340  50022  Added Hot Rod American Street Drag .ROD to the supported file types
  10440  50022  Added Call of Duty .PK3 to the supported games

  /////////////////////////////////////////////////////////////////////////////}
const DRIVER_VERSION = 10340;
      DUP_VERSION = 50040;

var CurFormat: Integer = 0;
    DrvInfo: CurrentDriverInfo;
    ErrInfo: ErrorInfo;
    NumEntry: integer = 0;
    UZfunc: TUserFunctions;
    UZDCL: TDCL;
    ZIPfile: string;
    DLLStatus: boolean = false;
    DLLFound: boolean = false;
    DLLHandle: THandle;
    DLLPath, DLLVersion: String;


procedure GetDLLVer();
var tmpI: PUzpVer;
begin

  if @UzpVersion <> Nil then
  begin
    tmpI := UzpVersion;
    DLLVersion := IntToStr(tmpI^.UnZip.Major)+'.'+IntToStr(tmpI^.UnZip.Minor)+'.'+IntToStr(tmpI^.UnZip.PatchLevel);
  end
  else
    DLLVersion := '';

end;

procedure LoadUNZipDLL();
begin

  if DLLFound then
  begin
    if Not(DLLStatus) then
      DLLHandle := LoadLibrary(PChar(DLLPath))
    else
    begin
      FreeLibrary(DLLHandle);
      DLLHandle := LoadLibrary(PChar(DLLPath));
    end;
    if DLLHandle <> 0 then
    begin
      @Wiz_SingleEntryUnZip := GetProcAddress(DLLHandle, 'Wiz_SingleEntryUnzip');
      @Wiz_Validate := GetProcAddress(DLLHandle, 'Wiz_Validate');
      @UzpVersion := GetProcAddress(DLLHandle, 'UzpVersion');
      DLLStatus := not(@Wiz_SingleEntryUnZip = Nil) and not(@Wiz_Validate = Nil);
      if Not(DLLStatus) then
      begin
        FreeLibrary(DLLHandle);
        DLLStatus := false;
      end
      else
        GetDLLVer;
    end
    else
      DLLStatus := False;
  end
  else
    DLLStatus := False;

end;

function IsValidZIP(fil: string): boolean;
var ID: array[0..3] of char;
    TestFile: integer;
begin

  Result := False;

  TestFile := FileOpen(fil, fmOpenRead);

  if TestFile > 0 then
  begin
    FileRead(TestFile,ID,4);
    Result := (ID[0] = 'P') and (ID[1] = 'K') and (ID[2] = #3) and (ID[3] = #4);
    FileClose(TestFile);
  end;

end;

{ ----------------------------------------------------------
    function - DUDIVersion()
  parameters - none
     returns - Byte
  ----------------------------------------------------------

  DO NOT CHANGE THIS FUNCTION.
  Dragon UnPACKer 5 won't recognize your driver if this
  function is missing or if return value is not 1.
}
function DUDIVersion: Byte; stdcall;
begin
  DUDIVersion := 1;
end;

function GetNumVersion: Integer; stdcall;
begin

  GetNumVersion := DRIVER_VERSION;

end;

{ ----------------------------------------------------------
    function - GetDriverInfo()
  parameters - none
     returns - DriverInfo record
  ----------------------------------------------------------

  This function is called by DUP5 for file associations and
  for Open dialog box file types.
}
function GetDriverInfo: DriverInfo; stdcall;
begin

  if DLLFound then
  begin
    if DLLStatus then
    begin
      GetDriverInfo.Name := 'InfoZip''s ZIP Driver (DLL wrapper)';
      GetDriverInfo.Version := GetVersion(DRIVER_VERSION)+' (DLL v'+DLLVersion+')';
    end
    else
    begin
      GetDriverInfo.Name := 'InfoZip''s ZIP Driver [BAD UNZIP32.DLL]';
      GetDriverInfo.Version := GetVersion(DRIVER_VERSION)+' (Bad DLL!)';
    end;
  end
  else
  begin
    GetDriverInfo.Name := 'InfoZip''s ZIP Driver [MISSING UNZIP32.DLL]';
    GetDriverInfo.Version := GetVersion(DRIVER_VERSION)+' (No DLL!)';
  end;
  GetDriverInfo.Author := 'Alexandre Devilliers (aka Elbereth)';
  GetDriverInfo.Comment := 'This Driver is a wrapper to the Info-ZIP UnZip32.DLL. Using UnZip32.pas by Theo Bebekis <bebekis@otenet.gr>.';
  if DLLStatus then
  begin
    GetDriverInfo.NumFormats := 11;
    GetDriverInfo.Formats[1].Extensions := '*.pk3';
    GetDriverInfo.Formats[1].Name := 'Call of Duty (*.PK3)|Quake 3 Arena (*.PK3)|Medal of Honor: Allied Assault (*.PK3)|American McGee Alice (*.PK3)|Jedi Knight 2: Jedi Outcast (*.PK3)|Heavy Metal: F.A.K.K.2 (*.PK3)';
    GetDriverInfo.Formats[2].Extensions := '*.rvi;*.rvm;*.rvr';
    GetDriverInfo.Formats[2].Name := 'Revenant (*.RVI;*.RVM;*.RVR)';
    GetDriverInfo.Formats[3].Extensions := '*.crf';
    GetDriverInfo.Formats[3].Name := 'System Shock 2 (*.CRF)|Thief (*.CRF)|Thief 2 (*.CRF)';
    GetDriverInfo.Formats[4].Extensions := '*.nob';
    GetDriverInfo.Formats[4].Name := 'Vampire: The Masquerade (*.NOB)';
    GetDriverInfo.Formats[5].Extensions := '*.gro';
    GetDriverInfo.Formats[5].Name := 'Serious Sam (*.GRO)|Serious Sam 2 (*.GRO)';
    GetDriverInfo.Formats[6].Extensions := '*.pac';
    GetDriverInfo.Formats[6].Name := 'Desperados: Wanted Dead or Alive (*.PAC)';
    GetDriverInfo.Formats[7].Extensions := '*.vl2';
    GetDriverInfo.Formats[7].Name := 'Tribes 2 (*.VL2)';
    GetDriverInfo.Formats[8].Extensions := '*.mgz';
    GetDriverInfo.Formats[8].Name := 'Metal Gear Solid (*.MGZ)';
    GetDriverInfo.Formats[9].Extensions := '*.za';
    GetDriverInfo.Formats[9].Name := 'Line of Sight: Vietnam (*.ZA)';
    GetDriverInfo.Formats[10].Extensions := '*.mob';
    GetDriverInfo.Formats[10].Name := 'Master of Orion 3 (*.MOB)';
    GetDriverInfo.Formats[11].Extensions := '*.rod';
    GetDriverInfo.Formats[11].Name := 'Hot Rod American Street Drag (*.ROD)';
  end
  else
    GetDriverInfo.NumFormats := 0;

end;

{ ----------------------------------------------------------
    function - ExtractFile()                     Facultative
  parameters - OutPutFile: ShortString
               EntryNam: ShortString
               Offset: Int64
               Size: Int64
               DataX: Integer
               DataY: Integer
     returns - Boolean
  ----------------------------------------------------------

  This function is called by DUP5 to extract files only if
  ExtractInternal is set to TRUE in CurrentDriverInfo.

  NOTE: Include it only if needed.
}
function ExtractFile(outputfile: ShortString; entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: Boolean): boolean; stdcall;
var retcode, ps: integer;
    TmpFil,SrcFil: string;
    FNV: array[0..0] of PChar;

begin

{  Buf.StrLength := Size;
  GetMem(Buf.StrPtr,Size);

  Wiz_Init(UZfunc,UZfunc);

  retcode := Wiz_UnzipToMemory(PChar(ZIPfile),PChar(String(entrynam)), UZfunc, Buf);

  if retcode = 0 then
  begin
    ShowMessage('Error'+#10+inttostr(Buf.StrLength)+#10+Trim(entrynam));
    ExtractFile := False;
  end
  else
  begin
    fil := FileCreate(outputfile,fmOpenRead or fmShareExclusive);

    FileWrite(fil,Buf.StrPtr^,Buf.StrLength);

    FileClose(fil);
    UzpFreeMemBuffer(Buf);

    ExtractFile := True;
  end;}

  tmpfil := ExtractFilePath(outputfile);

  GetMem(FNV[0], Length(entrynam)+1);
  StrPCopy(FNV[0], entrynam);

  with UZDCL do
  begin
    ExtractOnlyNewer  := Integer(False);  { true if you are to extract only newer }
    SpaceToUnderscore := Integer(False);  { true if convert space to underscore }
    PromptToOverwrite := Integer(False);  { true if prompt to overwrite is wanted }
    fQuiet            := 2;               { quiet flag. 1 = few messages, 2 = no messages, 0 = all messages }
    nCFlag            := Integer(False);   { write to stdout if true }
    nTFlag            := Integer(False);  { test zip file }
    nVFlag            := Integer(False);  { verbose listing }
    nUFlag            := Integer(False);   { "update" (extract only newer/new files) }
    nZFlag            := Integer(False);  { display zip file comment }
    nDFlag            := Integer(False);  { all args are files/dir to be extracted }
    nOFlag            := Integer(True);  { true if you are to always over-write files, false if not }
    nAFlag            := Integer(False);   { do end-of-line translation }
    nZIFlag           := Integer(False);  { get zip info if true }
    C_flag            := Integer(True);   { be case insensitive if TRUE }
    fPrivilege        := 2;               { 1 => restore Acl's, 2 => Use privileges }

    lpszExtractDir    := PChar(tmpfil);
    lpszZipFN         := PChar(ZIPfile);
  end;

  retcode := Wiz_SingleEntryUnzip(1, @FNV, 0, nil, UZDCL, UZfunc);

  if (retcode <> 0) and (retcode <> 80) then
  begin
    ExtractFile := False;
    //ShowMessage('error'+#10+EntryNam+#10+tmpfil+#10+inttostr(retcode));
  end
  else
  begin
    ps := PosRev('/',entrynam);
    if ps > 0 then
      SrcFil := Copy(entrynam,ps+1,length(entrynam)-ps)
    else
      SrcFil := EntryNam;
    SrcFil := TmpFil + SrcFil;
    if uppercase(SrcFil) <> Uppercase(outputfile) then
    begin
      RenameFile(SrcFil,Outputfile);
      //ShowMessage(srcfil+#10+outputfile);
    end;
    ExtractFile := True;
  end;

end;

{ ----------------------------------------------------------
    function - IsFormat()
  parameters - fil: ShortString
               Deeper: Boolean
     returns - Boolean
  ----------------------------------------------------------

  This function is called by DUP5 to know if your driver can
  open the file stored in Fil variable.
  The Deeper "switch" is here to indicate if you only need
  to test by extension or open file to check header.
  (Currently unused by DUP5)
}
function IsFormat(fil: ShortString; Deeper: Boolean): Boolean; stdcall;
var ext: string;
begin

  Result := false;

  if DLLStatus then
  begin
  // Put file extension uppercase form in ext var
    ext := ExtractFileExt(fil);
    if ext <> '' then
      ext := copy(ext,2,length(ext)-1);
    ext := UpperCase(ext);

    if Deeper then
      Result := IsValidZIP(fil)
    else
      if ext = 'PK3' then
        IsFormat := True
      else if ext = 'CRF' then
        IsFormat := True
      else if ext = 'GRO' then
        IsFormat := True
      else if ext = 'MOB' then
        IsFormat := True
      else if ext = 'NOB' then
        IsFormat := True
      else if ext = 'RVI' then
        IsFormat := True
      else if ext = 'RVM' then
        IsFormat := True
      else if ext = 'RVR' then
        IsFormat := True
      else if ext = 'VL2' then
        IsFormat := True
      else if ext = 'ZA' then
        IsFormat := True
      else if ext = 'ZIP' then
        IsFormat := True
      else
        IsFormat := False;

  end;

end;

{ ----------------------------------------------------------
    function - CloseFormat()
  parameters - none
     returns - nothing
  ----------------------------------------------------------

  This function is called by DUP5 to close an opened file.
  You should free all allocated stuff by ReadFile()
  function. And your driver must be able to handle a new
  call to ReadFile() just after a call to this function.
}
procedure CloseFormat; stdcall;
begin

  // This is an example
  // Change it the way you need
  DrvInfo.Sch := '';
  DrvInfo.ID := '';
  DrvInfo.FileHandle := 0;

end;

{ ----------------------------------------------------------
    function - GetCurrentDriverInfo()
  parameters - none
     returns - CurrentDriverInfo record
  ----------------------------------------------------------

  This function is called by DUP5 to current file format
  information (directory handling, file handle, internal
  extraction).
  It is called just after ReadFile().

  NOTE: You don't need to change this function if you want
        to use the same driver model as this example.
}
function GetCurrentDriverInfo(): CurrentDriverInfo; stdcall;
begin

  GetCurrentDriverInfo := DrvInfo;

end;

{ ----------------------------------------------------------
    function - GetEntry()
  parameters - none
     returns - FormatEntry record
  ----------------------------------------------------------

  This function is called by DUP5 to retrieve entries of the
  file parsed by ReadFile() function.
  It is called just after ReadFile() and N times (with N
  equal to the value returned by ReadFile).

  NOTE: You don't need to change this function if you want
        to use the same driver model as this example.
}
function GetEntry(): FormatEntry; stdcall;
begin

  GetEntry := FSE_Read;

end;

{ ----------------------------------------------------------
    function - GetErrorInfo()
  parameters - none
     returns - ErrorInfo record
  ----------------------------------------------------------

  This function is called by DUP5 when ReadFile() function
  returns an integer value of -3 (returns format info and
  game info).

  NOTE: You don't need to change this function if you want
        to use the same driver model as this example.
}
function GetErrorInfo(): ErrorInfo; stdcall;
begin

  GetErrorInfo := ErrInfo;

end;

function DLLprnt(Buffer: PChar; Size: ULONG): integer; stdcall;
var uZipInfo: string;
begin

  uZipInfo := strip0(Buffer);

  DLLprnt := Size;

end;

function DllPassword(P: PChar; N: Integer; M, Name: PChar): integer; stdcall;
begin

  DllPassword := 1;

end;

function DllService(CurFile: PChar; Size: ULONG): integer; stdcall;
begin

  DllService := 1;

end;

function DllReplace(FileName: PChar): integer; stdcall;
begin

  DllReplace := 104;

end;

procedure DllMessage(UnCompSize : ULONG;
                           CompSize   : ULONG;
                           Factor     : UINT;
                           Month      : UINT;
                           Day        : UINT;
                           Year       : UINT;
                           Hour       : UINT;
                           Minute     : UINT;
                           C          : Char;
                           FileName   : PChar;
                           MethBuf    : PChar;
                           CRC        : ULONG;
                           Crypt      : Char); stdcall;
var tmpStr: string;
//Var T: TextFile;
begin

  {AssignFile(T, 'd:\test.vision.txt');
  Append(T);}

  tmpStr := Strip0(FileName);
  {Write(T, tmpStr); }

  if Copy(tmpStr,length(tmpStr),1) <> '/' then
  begin
//    Write(T, ' - '+Copy(tmpStr,length(tmpStr)-1,1));
    Inc(NumEntry);
    FSE_Add(tmpStr,NumEntry,UnCompSize,CRC,0);
  end;
  {Writeln(T);

  Flush(T);
  CloseFile(T);}

end;

function OpenZipFile(fil: String): integer;
var retcode: integer;
begin

  with UZfunc do
  begin
    @Print := @DllPrnt;
    @Sound := nil;
    @Replace := @DllReplace;
    @Password := @DllPassword;
    @SendApplicationMessage := @DllMessage;
    @ServCallBk := @DllService;
  end;

  UZDCL.ExtractOnlyNewer := 0;
  UZDCL.SpaceToUnderscore := 0;
  UZDCL.PromptToOverwrite := 0;
  UZDCL.fQuiet := 2;
  UZDCL.nCFlag := 0;
  UZDCL.nTFlag := 0;
  UZDCL.nVFlag := 1;
  UZDCL.nUFlag := 0;
  UZDCL.nZFlag := 0;
  UZDCL.nDFlag := 1;
  UZDCL.nOFlag := 0;
  UZDCL.nAFlag := 1;
  UZDCL.nZIFlag := 0;
  UZDCL.C_flag := 1;
  UZDCL.fPrivilege := 2;
  ZIPfile := fil;
  UZDCL.lpszZipFN := PChar(fil);
  UZDCL.lpszExtractDir := nil;

  NumEntry := 0;
  retcode := Wiz_SingleEntryUnzip(0, nil, 0, nil, UZDCL, UZfunc);

  if retcode <> 0 then
  begin
    Result := -3;
    ErrInfo.Format := 'ZIP';
    ErrInfo.Games := 'Medal of Honor: Allied Assault, Quake 3 Arena, ...';
  end
  else
  begin
    DrvInfo.ID := 'ZIP';
    DrvInfo.Sch := '/';
    DrvInfo.FileHandle := 0;
    DrvInfo.ExtractInternal := True;
    Result := NumEntry;
  end;

end;
{ ----------------------------------------------------------
    function - ReadFormat()
  parameters - fil: ShortString
     returns - Integer value
  ----------------------------------------------------------

  This function opens file pointed by fil var and if:
  1) The file is good format:
     File is parsed and entries are stored (for future call
     by DUP5 to GetEntry() function).
     Integer value will have the total number of stored
     entries.
     DriverInfo must be setup for future call to
     GetCurrentDriverInfo() function by DUP5.
     CurrentDriverInfo structure:
       ID     - File ID (Appears on the status of DUP5)
       ASlash - Char used as separator for directories is
                Slash (\)      = TRUE
                Anti-Slash (/) = FALSE
       Sch    - Char used as separator for directories (\ or /)
       FileHandle - File Handle (Integer);
       ExtractInternal - If your Driver include an ExtractFile
                         function set this to TRUE
                         else set it to FALSE (DUP5 will handle
                         the file extraction).
  2) The file could not be opened:
     Integer value is set to -2.
  3) The file does not have expected format:
     Integer value is set to -3.
     Error information should be stored (for future call by
     DUP5 to GetErrorInfo() function).
  4) The file extension is unrecognized:
     Integer value is set to -1.
     (This should normally never happen is IsFormat()
     function is well coded).

 IMPORTANT:
 You must not close the file handle because DUP5 will use
 it for Extraction if your driver does not have ExtractFile
 function.
 File handle is an integer, meaning you must use FileOpen,
 FileClose, FileRead, FileWrite, etc..
 If you don't want to use those functions you must include
 an ExtractFile function to your driver.
 ----------------------------------------------------------
}
function ReadFormat(fil: ShortString; percent: TPercentCallback; Deeper: boolean): Integer; stdcall;
var ext: string;
begin

  if DLLStatus then
  begin

    ext := ExtractFileExt(fil);
    if ext <> '' then
      ext := copy(ext,2,length(ext)-1);
    ext := UpperCase(ext);

    if Deeper then
    begin
      if Not(IsValidZIP(fil)) then
      begin
        ReadFormat := -3;
        ErrInfo.Format := 'ZIP';
        ErrInfo.Games := 'Medal of Honor: Allied Assault, Quake 3 Arena, ...';
      end
      else
        Result := OpenZIPFile(fil);
    end
    else
      if (ext = 'PK3') or (ext = 'CRF') or (ext = 'RVI') or (ext = 'RVM')
      or (ext = 'RVR') or (ext = 'NOB') or (ext = 'ZIP') or (ext = 'GRO')
      or (ext = 'VL2') or (ext = 'ZA')  or (ext = 'MOB') then
        Result := OpenZIPFile(fil)
      else
        ReadFormat := -1;


  end
  else
  begin
    ReadFormat := -4;
    ErrInfo.Format := 'ZIP';
    ErrInfo.Games := 'UNZIP32.DLL';
  end;

end;

procedure AboutBox(hwnd: Integer; DLNGstr: TLanguageCallBack); stdcall;
var msg: string;
begin

      msg := 'InfoZip''s ZIP Driver v'+getVersion(DRIVER_VERSION)+#10+
                          '(c)Copyright 2002-2003 Alexandre Devilliers'+#10+#10+
                          'Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+#10+#10+
                          'This is a wrapper for the Info-ZIP UnZIP32.DLL.'+#10+
                          'Using UnZip32.pas by Theo Bebekis <bebekis@otenet.gr>.'+#10+#10+
                          'DLL Status:'+#10;

  if DLLFound then
    if DLLStatus then
      msg := msg + 'Loaded (Version '+DLLVersion+')'
    else
      msg := msg + 'Error (Bad DLL found!)'
  else
    msg := msg + 'Error (Missing DLL)';

  MessageBoxA(hwnd, PChar(msg), 'About InfoZip''s ZIP Driver...', MB_OK);

end;

// Exported functions
exports
  CloseFormat,
  DUDIVersion,
  ExtractFile,   // Export only if your program uses internal
                 // extraction.
  GetCurrentDriverInfo,
  GetDriverInfo,
  GetEntry,
  GetErrorInfo,
  GetNumVersion,
  IsFormat,
  ReadFormat,
  AboutBox;

function SearchDLL: string;
var
 iRes      : DWORD;
 pBuffer   : array[0..MAX_PATH - 1] of Char;
 pFilePart : PChar;
begin

  Result := '';

  iRes := SearchPath(nil,               { address of search path }
                    'unzip32',   { address of filename }
                    '.dll',             { address of extension }
                    MAX_PATH - 1,       { size, in characters, of buffer }
                    pBuffer,            { address of buffer for found filename }
                    pFilePart           { address of pointer to file component }
                    );

  if iRes <> 0 then
    result := Strip0(pBuffer);

end;

begin

  DLLPath := ExtractFilePath(ParamStr(0))+'data\drivers\unzip32.dll';
  DLLFound := IsExpectedUnzipDLLVersion(DLLPath);
  if not(DLLFound) then
  begin
    DLLPath := ExtractFilePath(ParamStr(0))+'unzip32.dll';
    DLLFound := IsExpectedUnzipDLLVersion(DLLPath);
    if not(DLLFound) then
    begin
      DLLPath := SearchDLL;
      DLLFound := IsExpectedUnzipDLLVersion(DLLPath);
    end;
  end;

  LoadUNZipDLL;

end.
