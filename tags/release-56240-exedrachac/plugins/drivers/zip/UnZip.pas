unit Unzip;

{
    Copyright (c) 2004 headcrash industries. All rights reserved.

    Author: Gerke Preussner <j3rky@gerke-preussner.de>

    This file belongs to the InfoZIP UnZip for Delphi Wrapper. Please read
    the license agreement in the readme.txt that comes with this package.
    Latest updates can be found at http://www.gerke-preussner.de
}

interface

type

{*
========================
   enums
========================
*}

{$Z4}

   ////////////////////
   //  callback returns
   ////////////////////

   EDllPassword =
   (
      IZ_PW_ENTERED =          0,   // got some PWD string, use/try it
      IZ_PW_NONE =             1,   
      IZ_PW_CANCEL =          -1,   // no password available (for this entry)
      IZ_PW_CANCELALL =       -2,   // no password, skip any further PWD request
      IZ_PW_ERROR =            5    // failure (no mem, no tty, ...
   );


   EDllPrint = Longint;


   EDllReplace =
   (
      IDM_REPLACE_NO =       100,   // skip this file
      IDM_REPLACE_TEXT =     101,   // open replace dialog?
      IDM_REPLACE_YES =      102,   // overwrite this file
      IDM_REPLACE_ALL =      103,   // always overwrite files
      IDM_REPLACE_NONE =     104,   // never overwrite files
      IDM_REPLACE_RENAME =   105,   // auto rename file
      IDM_REPLACE_HELP =     106
   );


   EDllService =
   (
      UZ_ST_CONTINUE =         0,   // continue unpacking
      UZ_ST_BREAK =            1    // cancel unpacking
   );


   ////////////////////
   //  parameters
   ////////////////////

   EGrepCmd =
   (
       UZ_GREP_NORMAL =        0,   // case insensitive substring search
       UZ_GREP_NORMALC =       1,   // case sensitive substring search
       UZ_GREP_WORDS =         2,   // case insensitive search for whole words
       UZ_GREP_WORDSC =        3    // case sensitive search for whole words
   );

{$Z1}


{*
========================
   prototypes
========================
*}

   ////////////////////
   //  callback
   ////////////////////

   DLLMESSAGE =    procedure (ucsize, csiz, cfactor, mo, dy, yr, hh, mm: Longword; c: Byte; fname, meth: PChar; crc: Longword; fCrypt: Byte); stdcall;
   DLLPASSWORD =   function (pwbuf: PChar; size: Longint; m, efn: PChar): EDllPassword; stdcall;
   DLLPRNT =       function (buffer: PChar; size: Longword): EDllPrint; stdcall;
   DLLREPLACE =    function (filename: PChar): EDllReplace; stdcall;
   DLLSERVICE =    function (efn: PChar; details: Longword): EDllService; stdcall;
   DLLSND =        procedure; stdcall;


{*
========================
   structs
========================
*}

   ////////////////////
   //  USERFUNCTIONS
   ////////////////////

   USERFUNCTIONS = packed record

      print:                    DLLPRNT;                // print callback routine
      sound:                    DLLSND;                 // sound callback routine
      replace:                  DLLREPLACE;             // replace callback routine
      password:                 DLLPASSWORD;            // password callback routine
      SendApplicationMessage:   DLLMESSAGE;             // message callback routine
      ServCallBk:               DLLSERVICE;             // service callback routine
      TotalSizeComp:            Longword;               // result: total size of archive
      TotalSize:                Longword;               // result: total size of files in the archive
      CompFactor:               Longword;               // result: compression factor
      NumMembers:               Longword;               // result: number of files in the archive
      cchComment:               Word;                   // result: length of comment

   end;


   ////////////////////
   //  DCL
   ////////////////////

   DCL = packed record

      ExtractOnlyNewer:         Longint;                // 1 - extract only newer
      SpaceToUnderscore:        Longint;                // 1 - convert space to underscore
      PromptToOverwrite:        Longint;                // 1 - prompt before overwrite
      fQuiet:                   Longint;                // 0 - return all messages, 1 = fewer messages, 2 = no messages
      ncflag:                   Longint;                // 1 - write to stdout
      ntflag:                   Longint;                // 1 - test zip file
      nvflag:                   Longint;                // 1 - give a verbose listing
      nfflag:                   Longint;                // 1 - freshen existing files only
      nzflag:                   Longint;                // 1 - display a zip file comment
      ndflag:                   Longint;                // >0 - recreate directories, <2 - skip "../"
      noflag:                   Longint;                // 1 - over-write all files
      naflag:                   Longint;                // 1 - convert CR to CRLF
      nZIflag:                  Longint;                // 1 - verbose zip info
      C_flag:                   Longint;                // 0 - case sensitive, 1 - case insensitive
      fPrivilege:               Longint;                // 1 - ACL, 2 - priv
      lpszZipFN:                PChar;                  // archive name
      lpszExtractDir:           PChar;                  // target directory, NULL - current directory

   end;


   ////////////////////
   //  UzpBuffer
   ////////////////////

   UzpBuffer = packed record

      strlength:                Longword;               // length of buffer
      strptr:                   PChar;                  // buffer

   end;


   ////////////////////
   //  _version_type
   ////////////////////

   _version_type = packed record

      major:                    Byte;                   // major version number
      minor:                    Byte;                   // minor version number
      patchlevel:               Byte;                   // patch level
      not_used:                 Byte;

   end;


   ////////////////////
   //  UzpVer
   ////////////////////

   UzpVer = packed record

      structlen:                Longword;               // length of the struct being passed
      flag:                     Longword;               // bit 0: is_beta   bit 1: uses_zlib
      betalevel:                PChar;                  // e.g., "g BETA" or ""
      date:                     PChar;                  // e.g., "4 Sep 95" (beta) or "4 September 1995"
      zlib_version:             PChar;                  // e.g., "0.95" or NULL
      unzip:                    _version_type;
      zipinfo:                  _version_type;
      os2dll:                   _version_type;
      windll:                   _version_type;

   end;

   PUzpVer = ^UzpVer;


   ////////////////////
   //  UzpVer2
   ////////////////////

   UzpVer2 = packed record

      structlen:                Longword;               // length of the struct being passed
      flag:                     Longword;               // bit 0: is_beta   bit 1: uses_zlib
      betalevel:                array[0..9] of Char;    // e.g., "g BETA" or ""
      date:                     array[0..19] of Char;   // e.g., "4 Sep 95" (beta) or "4 September 1995"
      zlib_version:             array[0..9] of Char;    // e.g., "0.95" or NULL
      unzip:                    _version_type;
      zipinfo:                  _version_type;
      os2dll:                   _version_type;
      windll:                   _version_type;

   end;

{*
========================
   functions
========================
*}

   ////////////////////
   //  imports
   ////////////////////

{$IFNDEF dyn_unzip32}

   procedure UzpFreeMemBuffer (var UzpBuffer); stdcall;
   function UzpVersion: PUzpVer; stdcall;
   procedure UzpVersion2 (var version: UzpVer2); stdcall;
   function Wiz_Grep (archive, fname, pattern: PChar; cmd: EGrepCmd; skipbin: Longbool; var ufunc: USERFUNCTIONS): Longint; stdcall;
   function Wiz_Init (var pG: Pointer; var ufunc: USERFUNCTIONS): LongBool; stdcall;
   procedure Wiz_NoPrinting (noprint: Longbool); stdcall;
   function Wiz_SetOpts (var pG: Pointer; var c: DCL): Longbool; stdcall;
   function Wiz_SingleEntryUnzip (ifnc: Longint; var ifnv: PChar; xfnc: Longint; var xfnv: PChar; var c: DCL; var ufunc: USERFUNCTIONS): Longint; stdcall;
   function Wiz_Unzip (var pG: Pointer; ifnc: Longint; var ifnv: PChar; xfnc: Longint; var xfnv: PChar): Longint; stdcall;
   function Wiz_UnzipToMemory (zip, fname: PChar; var ufunc: USERFUNCTIONS; var retstr: UzpBuffer): Longint; stdcall;
   function Wiz_Validate (archive: PChar; AllCodes: Longint): Longint; stdcall;

{$ELSE}

   PROCUzpFreeMemBuffer = procedure (var UzpBuffer); stdcall;
   PROCUzpVersion = function: PUzpVer; stdcall;
   PROCUzpVersion2 = procedure (var version: UzpVer2); stdcall;
   PROCWiz_Grep = function (archive, fname, pattern: PChar; cmd: EGrepCmd; skipbin: Longbool; var ufunc: USERFUNCTIONS): Longint; stdcall;
   PROCWiz_Init = function (var pG: Pointer; var ufunc: USERFUNCTIONS): Longbool; stdcall;
   PROCWiz_NoPrinting = procedure (noprint: Longbool); stdcall;
   PROCWiz_SetOpts = function (var pG: Pointer; var c: DCL): LongBool; stdcall;
   PROCWiz_SingleEntryUnzip = function (ifnc: Longint; var ifnv: PChar; xfnc: Longint; var xfnv: PChar; var c: DCL; var ufunc: USERFUNCTIONS): Longint; stdcall;
   PROCWiz_Unzip = function (var pG: Pointer; ifnc: Longint; var ifnv: PChar; xfnc: Longint; var xfnv: PChar): Longint; stdcall;
   PROCWiz_UnzipToMemory = function (zip, fname: PChar; var ufunc: USERFUNCTIONS; var retstr: UzpBuffer): Longint; stdcall;
   PROCWiz_Validate = function (archive: PChar; AllCodes: Longint): Longint; stdcall;

{$ENDIF}


   ////////////////////
   //  tools
   ////////////////////

   function Wiz_ErrorToStr (code: Longint): String;


{*
========================
   consts
========================
*}

const

   ////////////////////
   //  return codes
   ////////////////////

   PK_OK =                 0;   // no error
   PK_COOL =               0;   // no error
   PK_WARN =               1;   // warning error
   PK_ERR =                2;   // error in zipfile
   PK_BADERR =             3;   // severe error in zipfile
   PK_MEM =                4;   // insufficient memory (during initialization)
   PK_MEM2 =               5;   // insufficient memory (password failure)
   PK_MEM3 =               6;   // insufficient memory (file decompression)
   PK_MEM4 =               7;   // insufficient memory (memory decompression)
   PK_MEM5 =               8;   // insufficient memory (not yet used)
   PK_NOZIP =              9;   // zipfile not found
   PK_PARAM =             10;   // bad or illegal parameters specified
   PK_FIND =              11;   // no files found
   PK_DISK =              50;   // disk full
   PK_EOF =               51;   // unexpected EOF

   IZ_CTRLC =             80;   // user hit ^C to terminate
   IZ_UNSUP =             81;   // no files found: all unsup. compr/encrypt.
   IZ_BADPWD =            82;   // wrong password


   ////////////////////
   //  version flags
   ////////////////////

   UZ_VERFLAG_ISBETA =     1;   // this version is a beta
   UZ_VERFLAG_USESZLIB =   2;   // this version uses ZLib
   

   ////////////////////
   //  misc
   ////////////////////

   UNZIP32 = 'unzip32.dll';


implementation

{*
========================
   imports
========================
*}

{$IFNDEF dyn_unzip32}

   procedure UzpFreeMemBuffer (var UzpBuffer); external UNZIP32 name 'UzpFreeMemBuffer';
   function UzpVersion: PUzpVer; external UNZIP32 name 'UzpVersion';
   procedure UzpVersion2 (var version: UzpVer2); external UNZIP32 name 'UzpVersion2';
   function Wiz_Grep (archive, fname, pattern: PChar; cmd: EGrepCmd; SkipBin: Longbool; var ufunc: USERFUNCTIONS): Longint; external UNZIP32 name 'Wiz_Grep';
   function Wiz_Init (var pG: Pointer; var ufunc: USERFUNCTIONS): Longbool; external UNZIP32 name 'Wiz_Init';
   procedure Wiz_NoPrinting (noprint: Longbool); external UNZIP32 name 'Wiz_NoPrinting';
   function Wiz_SetOpts (var pG: Pointer; var c: DCL): LongBool; external UNZIP32 name 'Wiz_SetOpts';
   function Wiz_SingleEntryUnzip (ifnc: Longint; var ifnv: PChar; xfnc: Longint; var xfnv: PChar; var c: DCL; var ufunc: USERFUNCTIONS): Longint; external UNZIP32 name 'Wiz_SingleEntryUnzip';
   function Wiz_Unzip (var pG: Pointer; ifnc: Longint; var ifnv: PChar; xfnc: Longint; var xfnv: PChar): Longint; external UNZIP32 name 'Wiz_Unzip';
   function Wiz_UnzipToMemory (zip, fname: PChar; var ufunc: USERFUNCTIONS; var retstr: UzpBuffer): Longint; external UNZIP32 name 'Wiz_UnzipToMemory';
   function Wiz_Validate (archive: PChar; AllCodes: Longint): Longint; external UNZIP32 name 'Wiz_Validate';

{$ENDIF}


{*
========================
   tools
========================
*}

function Wiz_ErrorToStr (code: Longint): String;
begin
   case code of
      PK_OK:          Result := 'Operation completed successfully';
      PK_WARN:        Result := 'Warnings occurred on one or more files';
      PK_ERR:         Result := 'Errors occurred on one or more files';
      PK_BADERR:      Result := 'Sever error in archive';
      PK_MEM,
      PK_MEM2,
      PK_MEM3,
      PK_MEM4,
      PK_MEM5:        Result := 'Insufficient memory';
      PK_NOZIP:       Result := 'Archive not found';
      PK_PARAM:       Result := 'Bad or illegal parameters specified';
      PK_FIND:        Result := 'No files found';
      PK_DISK:        Result := 'Disk full';
      PK_EOF:         Result := 'Unexpected end of file';
      IZ_CTRLC:       Result := 'Canceled by user';
      IZ_UNSUP:       Result := 'No files found: All unsupported';
      IZ_BADPWD:      Result := 'No files found: Bad password';
   else
      Result := 'Unknown error';
   end;
end;





end.

