(*

-----------------------------------------------------------------------------------------
                                     STATE
-----------------------------------------------------------------------------------------
 THIS SOFTWARE IS FREEWARE AND IS PROVIDED AS IS AND COMES WITH NO WARRANTY OF ANY
 KIND, EITHER EXPRESSED OR IMPLIED. IN NO EVENT WILL THE AUTHOR(S) BE LIABLE FOR
 ANY DAMAGES RESULTING FROM THE USE OF THIS SOFTWARE.
-----------------------------------------------------------------------------------------
                                  INFORMATION
-----------------------------------------------------------------------------------------
 Description : Info-Zip's header files for its UnZip32.dll ( version 5.4 ) translated to
               Pascal (Delphi)
 Tested      : Delphi 2, 3, 4, 5
 Author      : Theo Bebekis <bebekis@otenet.gr> 
 More info   : For more information and information regarding Copyright and Distribution
               rights of the Info-Zip's work contact Info-Zip at
               http://www.cdrom.com/pub/infozip/
               InfoZip provides the Wiz.exe, a Windows application for zipping and
               unzipping files. You can find examples for the dll calls in the Wiz.exe
               sources (C language) which you can obtain from the above site.
 License     : Check Info-Zip's license in the accompanying license.htm
 Thanks to   : Davide Moretti
	       Marcel van Brakel
	       Rudy Velthuis
	       Danny Thorpe
               from the Delphi-JEDI@onelist.com mailing list who helped me with their
               advises to finish this translation.
 JEDI        : http://www.delphi-jedi.org/
-----------------------------------------------------------------------------------------
                                     HISTORY
-----------------------------------------------------------------------------------------
 Version   Date          Changes - Additions                                By
-----------------------------------------------------------------------------------------
 0.01      30.06.1999    Initial Version                                    Theo Bebekis

-----------------------------------------------------------------------------------------
   
*)

unit UnZip32;



interface

uses
  Windows;

const
  UNZIP_DLL = 'UNZIP32.DLL';


{ unzver.h }
const
  UNZIP_DLL_VERSION = '5.42';
  COMPANY_NAME = 'Info-ZIP';  


{ windll.h }
const
  IDM_REPLACE_NO        = 100;
  IDM_REPLACE_TEXT      = 101;
  IDM_REPLACE_YES       = 102;
  IDM_REPLACE_ALL       = 103;
  IDM_REPLACE_NONE      = 104;
  IDM_REPLACE_RENAME    = 105;
  IDM_REPLACE_HELP      = 106;


{ structs.h }
const
  PATH_MAX = 260; { max total file or directory name path }

{ user functions for use with the TUserFunctions structure }  
type
  TDllPrnt = function(Buffer: PChar; Size: ULONG): integer; stdcall;
  TDllPassword = function(P: PChar; N: Integer; M, Name: PChar): integer; stdcall;
  TDllService = function (CurFile: PChar; Size: ULONG): integer; stdcall;
  TDllSnd = procedure; stdcall;
  TDllReplace = function(FileName: PChar): integer; stdcall;
  TDllMessage = procedure (UnCompSize : ULONG;
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



type
  PUserFunctions = ^TUserFunctions;
  USERFUNCTIONS = record
    Print                  : TDllPrnt;
    Sound                  : TDllSnd;
    Replace                : TDllReplace;
    Password               : TDllPassword;
    SendApplicationMessage : TDllMessage;
    ServCallBk             : TDllService;
    TotalSizeComp          : ULONG;
    TotalSize              : ULONG;
    CompFactor             : Integer;
    NumMembers             : UINT;
    cchComment             : UINT;
  end;
  TUserFunctions = USERFUNCTIONS;


  { unzip options }
type
  PDCL = ^TDCL;
  DCL = record
    ExtractOnlyNewer  : Integer; { true if you are to extract only newer }
    SpaceToUnderscore : Integer; { true if convert space to underscore }
    PromptToOverwrite : Integer; { true if prompt to overwrite is wanted }
    fQuiet            : Integer; { quiet flag. 1 = few messages, 2 = no messages, 0 = all messages }
    nCFlag            : Integer; { write to stdout if true }
    nTFlag            : Integer; { test zip file }
    nVFlag            : Integer; { verbose listing }
    nUFlag            : Integer; { "update" (extract only newer/new files) }
    nZFlag            : Integer; { display zip file comment }
    nDFlag            : Integer; { all args are files/dir to be extracted }
    nOFlag            : Integer; { true if you are to always over-write files, false if not }
    nAFlag            : Integer; { do end-of-line translation }
    nZIFlag           : Integer; { get zip info if true }
    C_flag            : Integer; { be case insensitive if TRUE }
    fPrivilege        : Integer; { 1 => restore Acl's, 2 => Use privileges }
    lpszZipFN         : PChar;   { zip file name }
    lpszExtractDir    : PChar;   { Directory to extract to. NULL for the current directory }
  end ;
  TDCL = DCL;


{ unzip.h }
type
  _UzpBuffer = record        { rxstr }
    StrLength : ULONG;       { length of string }
    StrPtr    : PChar;       { pointer to string }
  end ;
  TUzpBuffer = _UzpBuffer;
  
type
{  intended to be a private struct  }
  _ver = record
    Major      : UCHAR;        { e.g., integer 5 }
    Minor      : UCHAR;        { e.g., 2 }
    PatchLevel : UCHAR;        { e.g., 0 }
    Not_Used   : UCHAR;
  end ;
  TVersionType = _ver;

type
  PUzpVer = ^TUzpVer;  
  _UzpVer = record
    StructLen    : ULONG;          { length of the struct being passed }
    Flag         : ULONG;          { bit 0: is_beta bit 1: uses_zlib }
    BetaLevel    : PChar;          { e.g., "g BETA" or "" }
    Date         : PChar;          { e.g., "4 Sep 95" (beta) or "4 September 1995" }
    ZLib_Version : PChar;          { e.g., "0.95" or NULL }
    UnZip        : TVersionType;
    ZipInfo      : TVersionType;
    OS2Dll       : TVersionType;
    WinDll       : TVersionType;
  end;
  TUzpVer = _UzpVer;

{ for Visual BASIC access to Windows DLLs }
type
  _UzpVer2 = record
    StructLen     : ULONG;                    { length of the struct being passed }
    Flag          : ULONG;                    { bit 0: is_beta bit 1: uses_zlib }
    BetaLevel     : array[0..10-1] of Char;   { e.g., "g BETA" or "" }
    Date          : array[0..20-1] of Char;   { e.g., "4 Sep 95" (beta) or "4 September 1995" }
    ZLib_Version  : array[0..10-1] of Char;   { e.g., "0.95" or NULL }
    UnZip         : TVersionType;
    ZipInfo       : TVersionType;
    OS2Dll        : TVersionType;
    WinDll        : TVersionType;
  end ;
  TUzpVer2 = _UzpVer2;

const
  UZPVER_LEN = SizeOf(TUzpVer); 

{ Return (and exit) values of the public UnZip API functions. }
const
{ external return codes  }       
  PK_OK                 = 0; { no error }
  PK_COOL               = 0; { no error }
  PK_GNARLY             = 0; { no error }
  PK_WARN               = 1; { warning error }
  PK_ERR                = 2; { error in zipfile }
  PK_BADERR             = 3; { severe error in zipfile }
  PK_MEM                = 4; { insufficient memory (during initialization) }
  PK_MEM2               = 5; { insufficient memory (password failure) }
  PK_MEM3               = 6; { insufficient memory (file decompression) }
  PK_MEM4               = 7; { insufficient memory (memory decompression) }
  PK_MEM5               = 8; { insufficient memory (not yet used) }
  PK_NOZIP              = 9; { zipfile not found }
  PK_PARAM              = 10; { bad or illegal parameters specified }
  PK_FIND               = 11; { no files found }
  PK_DISK               = 50; { disk full }
  PK_EOF                = 51; { unexpected EOF }

  IZ_CTRLC              = 80; { user hit ^C to terminate }
  IZ_UNSUP              = 81; { no files found: all unsup. compr/encrypt. }
  IZ_BADPWD             = 82; { no files found: all had bad password }

{ internal and DLL-only return codes  }
  IZ_DIR                = 76; { potential zipfile is a directory }
  IZ_CREATED_DIR        = 77; { directory created: set time and permissions }
  IZ_VOL_LABEL          = 78; { volume label, but can't set on hard disk }
  IZ_EF_TRUNC           = 79; { local extra field truncated (PKZIP'd) }

{ return codes of password fetches (negative = user abort; positive = error)  }
  IZ_PW_ENTERED          = 0; { got some password string; use/try it }
  IZ_PW_CANCEL           = -1; { no password available (for this entry) }
  IZ_PW_CANCELALL        = -2; { no password, skip any further pwd. request }
  IZ_PW_ERROR            = 5; { = PK_MEM2 : failure (no mem, no tty, ...) }

{ flag values for status callback function  }
  UZ_ST_START_EXTRACT    = 1;
  UZ_ST_IN_PROGRESS      = 2;
  UZ_ST_FINISH_MEMBER    = 3;

{ return values of status callback function  }
  UZ_ST_CONTINUE         = 0;
  UZ_ST_BREAK            = 1;


type
  PPChar = ^PChar;

var Wiz_SingleEntryUnzip: function(ifnc: Integer; ifnv: PPChar; xfnc: Integer;
                                xfnv: PPChar; var Options: TDCL;
                                var UserFunc: TUserFunctions): Integer; stdcall;

    UzpVersion: function(): PUzpVer; stdcall;
    Wiz_Validate: function(Archive: PChar;  AllCodes: Integer): Integer; stdcall;


  { dll prototypes }

  { decs.h }
{procedure  Wiz_NoPrinting(Flag: Integer); stdcall;
function   Wiz_Validate(Archive: PChar;  AllCodes: Integer): Integer; stdcall;
function   Wiz_Init(var pG; var UserFunc: TUserFunctions): Bool; stdcall;
function   Wiz_SetOpts(var pG; var Options: TDCL): Bool; stdcall;
function   Wiz_Unzip(var pG; ifnc: Integer; ifnv: PPChar; xfnc: Integer; xfnv: PPChar): Integer; stdcall;
}
{function   Wiz_SingleEntryUnzip(ifnc: Integer; ifnv: PPChar; xfnc: Integer;
                                xfnv: PPChar; var Options: TDCL;
                                var UserFunc: TUserFunctions): Integer; stdcall;
}
{function   Wiz_UnzipToMemory(Zip: PChar;  FileName: PChar; var UserFunctions: TUserFunctions;
                             var RetStr: TUzpBuffer): Integer; stdcall;
function   Wiz_Grep(Archive: PChar; FileName: PChar; Pattern: PChar; Cmd: Integer;
                    SkipBin: Integer; var UserFunctions: TUserFunctions): Integer; stdcall;
}
  { unzip.h }
{procedure  UzpFreeMemBuffer(var RetStr: TUzpBuffer); stdcall;
function   UzpVersion: PUzpVer; stdcall;
procedure  UzpVersion2(var Version: TUzpVer2); stdcall;
}
  { helper }
function IsExpectedUnZipDllVersion(dllpath: string): boolean;




implementation




uses
 SysUtils;


  { dll routines }

  { decs.h } 
//procedure  Wiz_NoPrinting; external UNZIP_DLL name 'Wiz_NoPrinting';
//function   Wiz_Validate; external UNZIP_DLL name 'Wiz_Validate';
//function   Wiz_Init; external UNZIP_DLL name 'Wiz_Init';
//function   Wiz_SetOpts; external UNZIP_DLL name 'Wiz_SetOpts';
//function   Wiz_Unzip; external UNZIP_DLL name 'Wiz_Unzip';
//function   Wiz_SingleEntryUnzip; external UNZIP_DLL name 'Wiz_SingleEntryUnzip';
//function   Wiz_UnzipToMemory; external UNZIP_DLL name 'Wiz_UnzipToMemory';
//function   Wiz_Grep; external UNZIP_DLL name 'Wiz_Grep';

  { unzip.h }
//procedure  UzpFreeMemBuffer; external UNZIP_DLL name 'UzpFreeMemBuffer';
//function   UzpVersion; external UNZIP_DLL name 'UzpVersion';
//procedure  UzpVersion2; external UNZIP_DLL name 'UzpVersion2';





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

end.




