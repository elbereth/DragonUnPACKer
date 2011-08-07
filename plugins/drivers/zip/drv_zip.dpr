library drv_zip;

// $Id: drv_zip.dpr,v 1.9 2010-02-27 15:58:54 elbereth Exp $
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
  Classes,
  dup5drv_utils in '..\dup5drv_utils.pas',
  dup5drv_data in '..\dup5drv_data.pas',
  UnZip in 'UnZip.pas',
  lib_version in '..\..\..\common\lib_version.pas',
  lib_BinUtils in '..\..\..\common\lib_binutils.pas';

{$E d5d}

{$R *.res}

{$Include datetime.inc}

type
   TPercentCallback = procedure (p: byte);
   TLanguageCallback = function (lngid: ShortString): ShortString;

{ /////////////////////////////////////////////////////////////////////////////

  10240  50012  Added Line of Sight: Vietnam .ZA to the supported file types
                Added Master of Orion 3 .MOB to the supported files types
  10340  50022  Added Hot Rod American Street Drag .ROD to the supported file types
                Added Call of Duty .PK3 to the supported games
  11040  52040  Updated to DUDI v4
                Added Doom 3 & Quake 4 .PK4 to the supported file types
                Added Serious Sam 2 .GRO to the supported file types
                Added Call of Duty 2 .IWD to the supported file types
  11140  52040  Added a lot of supported file types thanks to Z0oMiK
  11240  54040  Added Call of Duty 5: World at War .IWD to the supported file types
  11340  55240  Added Heroes of Might & Magic 5 .PAK to the supported file types
  11341  56040  This is the same version as the original 11340 without the
                bad modifications released with 5.6.0 Exedra

  /////////////////////////////////////////////////////////////////////////////}
const DRIVER_VERSION = 11341;
      DUP_VERSION = 56040;
      COMPANY_NAME = 'Info-ZIP';

var CurFormat: Integer = 0;
    DrvInfo: CurrentDriverInfo;
    ErrInfo: ErrorInfo;
    NumEntry: integer = 0;
    DCList: DCL;
    ZIPfile: string;
    DLLStatus: boolean = false;
    DLLFound: boolean = false;
    DLLHandle: THandle;
    DLLPath, DLLVersion: String;
    SetPercent: TPercentCallback;
    DLNGStr: TLanguageCallback;
    CurPath: string;
    AHandle : THandle;
    AOwner : TComponent;
    UFuncs : USERFUNCTIONS;
    UzpFreeMemBuffer : PROCUzpFreeMemBuffer;
    UzpVersion : PROCUzpVersion;
    Wiz_UnzipToMemory : PROCWiz_UnzipToMemory;
    Wiz_SingleEntryUnzip : PROCWiz_SingleEntryUnzip;
    Loading : Boolean;

type
 TFVISubBlock = (sbCompanyName, sbFileDescription, sbFileVersion, sbInternalName, sbLegalCopyright,
   sbLegalTradeMarks, sbOriginalFilename, sbProductName, sbProductVersion, sbComments);


{----------------------------------------------------------------------------------
 Description    : retrieves selected version information from the specified
                  version-information resource. True on success
 Parameters     :
                  const FullPath : string;        the exe or dll full path
                  SubBlock       : TFVISubBlock;  the requested sub block information ie sbCompanyName
                  var sValue     : string         the returned string value
 Error checking : YES
 Notes          :
                  1. 32bit only ( It does not work with 16-bit Windows file images )
                  2. TFVISubBlock is declared as
                     TFVISubBlock = (sbCompanyName, sbFileDescription, sbFileVersion, sbInternalName,
                                     sbLegalCopyright, sbLegalTradeMarks, sbOriginalFilename,
                                     sbProductName, sbProductVersion, sbComments);
 Tested         : in Delphi 4 only
 Author         : Theo Bebekis <bebekis@otenet.gr>
-----------------------------------------------------------------------------------}
function Get_FileVersionInfo(const FullPath: string; SubBlock: TFVISubBlock; var sValue: string):boolean;
const
 arStringNames : array[sbCompanyName..sbComments] of string =
  ('CompanyName', 'FileDescription', 'FileVersion', 'InternalName', 'LegalCopyright',
   'LegalTradeMarks', 'OriginalFilename', 'ProductName', 'ProductVersion', 'Comments');
var
  Dummy       : DWORD;
  iLen        : DWORD;
  pData       : PChar;
  pVersion    : Pointer;
  pdwLang     : PDWORD;
  sLangID     : string;
  sCharsetID  : string;
  pValue      : PChar;
begin

  Result := False;

  { get the size of the size in bytes of the file's version information}
  iLen := GetFileVersionInfoSize(PChar(FullPath), Dummy);
  if iLen = 0 then Exit;


  { get the information }
  pData := StrAlloc(iLen + 1);
  if not GetFileVersionInfo(PChar(FullPath),  { pointer to filename string }
                            0,                { ignored }
                            iLen,             { size of buffer }
                            pData)            { pointer to buffer to receive file-version info }
  then Exit;


  { get the national ID.
    retrieve a pointer to an array of language and
    character-set identifiers. Use these identifiers
    to create the name of a language-specific
    structure in the version-information resource}
  if not VerQueryValue(pData,                       { address of buffer for version resource (in)}
                       '\VarFileInfo\Translation',  { address of value to retrieve (in) }
                       pVersion,                    { address of buffer for version pointer (out)}
                       iLen )                       { address of version-value length buffer (out)}
  then Exit;

  { analyze it }
  pdwLang    := pVersion;
  sLangID    := IntToHex(pdwLang^, 8);
  sCharsetID := Copy(sLangID, 1, 4);
  sLangID    := Copy(sLangID, 5, 4);


  { get the info for the requested sub block }
  if not VerQueryValue(pData,
                       PChar('\StringFileInfo\' + sLangID + sCharsetID + '\' + arStringNames[SubBlock]),
                       pVersion,
                       iLen)
  then Exit;     

  { copy it to sValue }
  pValue := StrAlloc(iLen + 1);
  StrLCopy(pValue, pVersion, iLen);
  sValue := String(pValue);
  StrDispose(pValue);

  Result := True;
end;      
{----------------------------------------------------------------------------------
 NOTE : this function uses the SearchPath WinAPI call to locate the dll and
        then checks up for the version info using the above Get_FileVersionInfo
        to get both the version number and the company name.
        The dll's UzpVersion function does not check for the CompanyName.
        I recommend to call the IsExpectedUnZipDllVersion function as the very
        first step to ensure that is the right dll and not any other with a
        similar name etc.
        This function is more usefull when link the dll dynamically
----------------------------------------------------------------------------------}
function IsExpectedUnZipDllVersion(dllpath: string): boolean;
var
 sCompany  : string;
begin

  Result := FileExists(dllpath);

  if Result then
    if Get_FileVersionInfo(dllpath, sbCompanyName, sCompany) then
      Result :=  (sCompany = COMPANY_NAME);

end;

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
      @UzpFreeMemBuffer := GetProcAddress(DLLHandle, 'UzpFreeMemBuffer');
      @Wiz_SingleEntryUnzip := GetProcAddress(DLLHandle, 'Wiz_SingleEntryUnzip');
      @Wiz_UnzipToMemory := GetProcAddress(DLLHandle, 'Wiz_UnzipToMemory');
      @UzpVersion := GetProcAddress(DLLHandle, 'UzpVersion');
      DLLStatus := not(@UzpFreeMemBuffer = Nil) and not(@Wiz_SingleEntryUnzip = Nil) and not(@Wiz_UnzipToMemory = Nil) and not(@UzpVersion = Nil);
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
}
function DUDIVersion: Byte; stdcall;
begin
  DUDIVersion := 4;
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

  // Initialize result to 0
  FillChar(result,SizeOf(DriverInfo),0);

  if DLLFound then
  begin
    if DLLStatus then
    begin
      result.Name := 'InfoZip''s ZIP Driver (DLL wrapper)';
      result.Version := GetVersion(DRIVER_VERSION)+' (DLL v'+DLLVersion+')';
    end
    else
    begin
      result.Name := 'InfoZip''s ZIP Driver [BAD UNZIP32.DLL]';
      result.Version := GetVersion(DRIVER_VERSION)+' (Bad DLL!)';
    end;
  end
  else
  begin
    result.Name := 'InfoZip''s ZIP Driver [MISSING UNZIP32.DLL]';
    result.Version := GetVersion(DRIVER_VERSION)+' (No DLL!)';
  end;
  result.Author := 'Alexandre Devilliers (aka Elbereth/Piecito)';
  result.Comment := 'This Driver is a wrapper to the Info-ZIP UnZip32.DLL. Using UnZip.pas by Gerke Preussner <j3rky@gerke-preussner.de>. Note: Password for Paradise Cracked files is "stereosystem".';
  if DLLStatus then
  begin
    result.NumFormats := 0;
    AddFormat(result,'*.A','Hellhog XP (*.A)');
    AddFormat(result,'*.ABZ','Alpha Black Zero (*.ABZ)');
    AddFormat(result,'*.ARF','Packmania 2 (*.ARF)');
    AddFormat(result,'*.ARH','El Airplane (*.ARH)');
    AddFormat(result,'*.BND','Neighbours From Hell (*.BND)|Neighbours From Hell 2 (*.BND)');
    AddFormat(result,'*.BOS','Fallout Tactics (*.BOS)');
    AddFormat(result,'*.BOT','Team Factor (*.BOT)');
    AddFormat(result,'*.BOX','Cellblock Squadrons (*.BOX)');
    AddFormat(result,'*.BIN','X-Men Legends 2 (*.BIN)|XPand Rally (*.BIN)');
    AddFormat(result,'*.CAB','Microsoft Flight Simulator 2004 (*.CAB)');
    AddFormat(result,'*.CRF','System Shock 2 (*.CRF)|Thief (*.CRF)|Thief 2 (*.CRF)');
    AddFormat(result,'*.CSC','18 Wheels Of Steel Pedal To The Metal (*.CSC)');
    AddFormat(result,'*.CTP','Call To Power (*.CTP)');
    AddFormat(result,'*.DAT','Against Rome (*.DAT)|Defiance (*.DAT)|Ricochet Lost Worlds Recharged (*.DAT)|Ricochet Xtreme (*.DAT)|Star Wolves (*.DAT)|Uplink (*.DAT)');
    AddFormat(result,'*.DLU','Dirty Little Helper 98(*.DLU)');
    AddFormat(result,'*.FBZ','Shadowgrounds (*.FBZ)');
    AddFormat(result,'*.FF','Freedom Force (*.FF)|Freedom Force vs The 3rd Reich (*.FF)');
    AddFormat(result,'*.FLMOD','Freelancer (*.FLMOD)');
    AddFormat(result,'*.GRO','Serious Sam (*.GRO)|Serious Sam 2 (*.GRO)');
    AddFormat(result,'*.IWD','Call of Duty 2 (*.IWD)|Call of Duty 3 (*.IWD)|Call of Duty 4: Modern Warfare (*.IWD)|Call of Duty: World at War (*.IWD)');
    AddFormat(result,'*.LZP','Law And Order 3 Justice Is Served (*.LZP)');
    AddFormat(result,'*.MGZ','Metal Gear Solid (*.MGZ)');
    AddFormat(result,'*.MOB','Master of Orion 3 (*.MOB)');
    AddFormat(result,'*.NOB','Vampire: The Masquerade (*.NOB)|Vampire The Masquerade Redemption (*.NOB)');
    AddFormat(result,'*.PAC','Desperados: Wanted Dead or Alive (*.PAC)');
    AddFormat(result,'*.PAK','Blitzkrieg (*.PAK)|Blitzkrieg Burning Horizon (*.PAK)|Blitzkrieg Rolling Thunder (*.PAK)|Brothers Pilots 4 (*.PAK)|Call of Juarez (*.PAK)|Far Cry (*.PAK)|Heroes of Might & Magic 5 (*.PAK)|Maximus XV (*.PAK)|Monte Cristo (*.PAK)|Outfront (*.PAK)');
    AddFormat(result,'*.PAK','Paradise Cracked (*.PAK)|Perimeter (*.PAK)');
    AddFormat(result,'*.PK1;*.PK2','XS Mark (*.PK1;*.PK2)');
    AddFormat(result,'*.PK3','Call of Duty (*.PK3)|Quake 3 Arena (*.PK3)|Medal of Honor: Allied Assault (*.PK3)|American McGee Alice (*.PK3)|Jedi Knight 2: Jedi Outcast (*.PK3)|Heavy Metal: F.A.K.K.2 (*.PK3)');
    AddFormat(result,'*.PK4','Doom 3 (*.PK4)|Quake 4 (*.PK4)|Doom 3 Resurrection Of Evil (*.PK4)');
    AddFormat(result,'*.POD','Hoyle Games 2005 (*.POD)|Terminator 3 (*.POD)');
    AddFormat(result,'*.PSH','Itch (*.PSH)|Pusher (*.PSH)');
    AddFormat(result,'*.RBZ','Richard Burns Rally (*.RBZ)');
    AddFormat(result,'*.RES','Swat 3 Close Quarters Battle (*.RES)');
    AddFormat(result,'*.ROD','Hot Rod American Street Drag (*.ROD)');
    AddFormat(result,'*.RVI;*.RVM;*.RVR','Revenant (*.RVI;*.RVM;*.RVR)');
    AddFormat(result,'*.SAB','Sabotain (*.SAB)');
    AddFormat(result,'*.SCS','Hunting Unlimited 3 (*.SCS)');
    AddFormat(result,'*.SXT','Singles Flirt Up Your Life (*.SXT)');
    AddFormat(result,'*.TEXTUREPACK;*.DATA','Arena Wars (*.TEXTUREPACK;*.DATA)');
    AddFormat(result,'*.Vl2','Tribes 2 (*.VL2)');
    AddFormat(result,'*.ZA','Elite Warriors (*.ZA)|Line of Sight: Vietnam (*.ZA)|Deadly Dozen (*.ZA)|Deadly Dozen 2 Pacific Theater (*.ZA)');
    AddFormat(result,'*.ZIP','Dethkarz (*.ZIP)|Battlefield 2 (*.ZIP)|Empire Earth 2 (*.ZIP)|Falcon 4 (*.ZIP)|Fire Starter (*.ZIP)|Freedom Fighters (*.ZIP)|Hitman Contracts (*.ZIP)|Hitman Bloodmoney (*.ZIP)|Hitman 2 Silent Assasin (*.ZIP)|Slave Zero (*.ZIP)');
    AddFormat(result,'*.ZIPFS','18 Wheels Of Steel Across America (*.ZIPFS)|Duke Nukem - Manhattan Project (*.ZIPFS)');
    AddFormat(result,'*.ZTD','Dinosaur Digs (*.ZTD)|Marine Mania (*.ZTD)');
    //--------------------------------------------------------------------------
    //NOTE only for Paradise Cracked
    //The game Paradise Cracked using default ZIP files + password
    //The password for archives -> stereosystem
    //--------------------------------------------------------------------------
  end
  else
    GetDriverInfo.NumFormats := 0;

end;

function ExtractFileToStream(outputstream: TStream; entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: boolean): boolean; stdcall;
var Buf: UzpBuffer;
    retcode: longint;
begin

  Buf.StrLength := 0;
  Buf.StrPtr := nil;

  retcode := Wiz_UnzipToMemory(PChar(ZIPfile),PChar(String(entrynam)), UFuncs, Buf);

  if retcode = 0 then
  begin
    result := False;
  end
  else
  begin
    outputstream.WriteBuffer(Buf.StrPtr^,Buf.StrLength);

    UzpFreeMemBuffer(Buf);

    result := True;
  end;

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
var fil: Integer;
    outStm: THandleStream;
begin

  fil := FileCreate(outputfile,fmOpenRead or fmShareExclusive);
  outStm := THandleStream.Create(fil);
  result := ExtractFileToStream(outStm,entrynam,offset,size,datax,datay,silent);
  FreeAndNil(outStm);
  FileClose(fil);

end;
{
var retcode, ps: integer;
    TmpFil,SrcFil: string;
    FNV: array[0..0] of PChar;

begin

  tmpfil := ExtractFilePath(outputfile);

  GetMem(FNV[0], Length(entrynam)+1);
  StrPCopy(FNV[0], entrynam);

  with UZDCL do
  begin
    ExtractOnlyNewer  := Integer(False);
    SpaceToUnderscore := Integer(False);
    PromptToOverwrite := Integer(False);
    fQuiet            := 2;
    nCFlag            := Integer(False);
    nTFlag            := Integer(False);
    nVFlag            := Integer(False);
    nUFlag            := Integer(False);
    nZFlag            := Integer(False);
    nDFlag            := Integer(False);
    nOFlag            := Integer(True);
    nAFlag            := Integer(False);
    nZIFlag           := Integer(False);
    C_flag            := Integer(True);
    fPrivilege        := 2;

    lpszExtractDir    := PChar(tmpfil);
    lpszZipFN         := PChar(ZIPfile);
  end;

  retcode := Wiz_SingleEntryUnzip(1, @FNV, 0, nil, UZDCL, Ufuncs);

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

end;            }

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
      else if ext = 'A' then
        IsFormat := True
      else if ext = 'ABZ' then
        IsFormat := True
      else if ext = 'ARF' then
        IsFormat := True
      else if ext = 'ARH' then
        IsFormat := True
      else if ext = 'BND' then
        IsFormat := True
      else if ext = 'BIN' then
        IsFormat := True
      else if ext = 'BOS' then
        IsFormat := True
      else if ext = 'BOT' then
        IsFormat := True
      else if ext = 'BOX' then
        IsFormat := True
      else if ext = 'CAB' then
        IsFormat := True
      else if ext = 'CRF' then
        IsFormat := True
      else if ext = 'CSC' then
        IsFormat := True
      else if ext = 'CTP' then
        IsFormat := True
      else if ext = 'DATA' then
        IsFormat := True
      else if ext = 'DLU' then
        IsFormat := True
      else if ext = 'FBZ' then
        IsFormat := True
      else if ext = 'FF' then
        IsFormat := True
      else if ext = 'FLMOD' then
        IsFormat := True
      else if ext = 'GRO' then
        IsFormat := True
      else if ext = 'IWD' then
        IsFormat := True
      else if ext = 'LZP' then
        IsFormat := True
      else if ext = 'MOB' then
        IsFormat := True
      else if ext = 'NOB' then
        IsFormat := True
      else if ext = 'PAK' then
        IsFormat := True
      else if ext = 'PK1' then
        IsFormat := True
      else if ext = 'PK2' then
        IsFormat := True
      else if ext = 'PK4' then
        IsFormat := True
      else if ext = 'POD' then
        IsFormat := True
      else if ext = 'ROD' then
        IsFormat := True
      else if ext = 'RVI' then
        IsFormat := True
      else if ext = 'RVM' then
        IsFormat := True
      else if ext = 'RVR' then
        IsFormat := True
      else if ext = 'SCS' then
        IsFormat := True
      else if ext = 'SXT' then
        IsFormat := True
      else if ext = 'TEXTUREPACK' then
        IsFormat := True
      else if ext = 'VL2' then
        IsFormat := True
      else if ext = 'ZA' then
        IsFormat := True
      else if ext = 'ZIP' then
        IsFormat := True
      else if ext = 'ZIPFS' then
        IsFormat := True
      else if ext = 'ZTD' then
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

function CallbackPassword (pwbuf: PChar; size: Longint; m, efn: PChar): EDllPassword; stdcall;
begin
  Result := IZ_PW_NONE;
end;

function CallbackPrint (buffer: PChar; size: Longword): EDllPrint; stdcall;
begin
   Result := size;
end;

function CallbackReplace (filename: PChar): EDllReplace; stdcall;
begin
  Result := IDM_REPLACE_NONE;
end;

function CallbackService (efn: PChar; details: Longword): EDllService; stdcall;
begin
  Result := UZ_ST_CONTINUE;
end;

procedure CallbackMessage (ucsize, csiz, cfactor, mo, dy, yr, hh, mm: Longword; c: Byte; fname, meth: PChar; crc: Longword; fCrypt: Byte); stdcall;
var tmpStr: string;
//Var T: TextFile;
begin

  if Loading then
  begin
    tmpStr := Strip0(fname);

    if Copy(tmpStr,length(tmpStr),1) <> '/' then
    begin
      Inc(NumEntry);
      FSE_Add(tmpStr,NumEntry,ucsize,crc,0);
    end;
  end;

end;

function OpenZipFile(fil: String): integer;
var retcode: integer;
   incl:      PChar;
   excl:      PChar;
begin

  with Ufuncs do
  begin
      print := CallbackPrint;
      sound := nil;
      replace := CallbackReplace;
      password := CallbackPassword;
      SendApplicationMessage := CallbackMessage;
      ServCallBk := CallbackService;
  end;

  with DCList do
  begin
    ExtractOnlyNewer := 0;
    SpaceToUnderscore := 0;
    PromptToOverwrite := 0;
    fQuiet := 2;
    nCFlag := 0;
    nTFlag := 0;
    nVFlag := 1;
    nFFlag := 0;
    nZFlag := 0;
    nDFlag := 1;
    nOFlag := 0;
    nAFlag := 1;
    nZIFlag := 0;
    C_flag := 1;
    fPrivilege := 2;
    lpszZipFN := PChar(fil);
    lpszExtractDir := nil;
  end;

  ZIPfile := fil;

  incl := nil;
  excl := nil;

  NumEntry := 0;
  Loading := true;
  retcode := Wiz_SingleEntryUnzip(0, incl, 0, excl, DCList, Ufuncs);
  Loading := false;

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
    else if isFormat(fil,false) then
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

procedure InitPlugin(per: TPercentCallback; lngid: TLanguageCallback; DUP5Path: ShortString; AppHandle: THandle; AppOwner: TComponent); stdcall;
begin

  SetPercent := per;
  DLNGStr := lngid;
  CurPath := DUP5Path;
  AHandle := AppHandle;
  AOwner := AppOwner;

  DLLPath := ExtractFilePath(CurPath)+'data\drivers\unzip32.dll';
  DLLFound := IsExpectedUnzipDLLVersion(DLLPath);
  if not(DLLFound) then
  begin
    DLLPath := ExtractFilePath(CurPath)+'unzip32.dll';
    DLLFound := IsExpectedUnzipDLLVersion(DLLPath);
    if not(DLLFound) then
    begin
      DLLPath := SearchDLL;
      DLLFound := IsExpectedUnzipDLLVersion(DLLPath);
    end;
  end;

  LoadUNZipDLL;

end;

procedure AboutBox; stdcall;
var msg: string;
begin

      msg := 'InfoZip''s ZIP Driver v'+getVersion(DRIVER_VERSION)+' ('+DateToStr(compileTime)+ ' '+TimeToStr(compileTime)+')'+#10+
                          'Created by Alexandre Devilliers'+#10+#10+
                          'Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+#10+#10+
                          'This is a wrapper for the Info-ZIP UnZIP32.DLL.'+#10+
                          'Using UnZip.pas by Gerke Preussner <j3rky@gerke-preussner.de>.'+#10+#10+
                          'DLL Status:'+#10;

  if DLLFound then
    if DLLStatus then
      msg := msg + 'Loaded (Version '+DLLVersion+')'
    else
      msg := msg + 'Error (Bad DLL found!)'
  else
    msg := msg + 'Error (Missing DLL)';

  MessageBoxA(AHandle, PChar(msg), 'About InfoZip''s ZIP Driver...', MB_OK);

end;

// Exported functions
exports
  CloseFormat,
  DUDIVersion,
  ExtractFile,   // Export only if your program uses internal
                 // extraction.
  GetCurrentDriverInfo,
  InitPlugin,
  GetDriverInfo,
  GetEntry,
  GetErrorInfo,
  GetNumVersion,
  IsFormat,
  ReadFormat,
  ExtractFileToStream,
  AboutBox;


end.
