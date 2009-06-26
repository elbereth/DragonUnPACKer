unit spec_DUPP;

// $Id: spec_DUPP.pas,v 1.4 2009-04-26 12:17:47 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/common/spec_DUPP.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is spec_DUPP.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// Dragon UnPacker Package [DUPP] types and tools
// =============================================================================
//  
//  Types:
//  DUP5PACK_Header
//  DUP5PACK_Info
//  DUP5PACK_Info_v1
//  DUP5PACK_File
//  
//  Const:
//  D5PFILE_REGSVR32
//  
//  Functions:
//  function getVersionFromInt(version: integer): string;
//
//  Version history:
//  Updated for support of DUPP v2
//
// -----------------------------------------------------------------------------

interface

uses SysUtils, StrUtils, lib_version;
  
function getVersionFromInt(version: integer): string;

type
  DUP5PACK_Header = packed record
    ID: array[0..3] of char; // DUPP
    EOF: byte;               // 26
    Version: byte;           // 1 = First Version
                             // 2 = Same structure as version 1 but different meaning.
                             // 3 = "Fixed" CRC calculation (sort of)
                             // 4 = SHA-512 hash instead of CRC
    NeededVersion: smallint; //     0 = Any DUPPI version should work
                             // 20240 = If using the InstallDir extension
                             //         If using the Register ActiveX DLL feature
                             //         If embedding a custom banner
                             // 22040 = If using "good" CRC calculation
                             // 30040 = For v4
                             // NOTE: Duppi check this field only since 20240.
                             // Please note that all Duppi version will be able
                             // to read and install v1 DUPP files but they won't
                             // understand or use all the information in those
                             // files.
  end;
  DUP5PACK_Info = packed record     // v0
    NumVer: integer;
    DUP5VerTest: integer;           // Test DUP5 version
    DUP5VerValue: integer;          // Value to test against DUP5 version
    PictureSize: integer;
    NumFiles: integer;
  end;
  DUP5PACK_Info_v1 = packed record
    Reserved: array[1..3] of byte;
    PictureCompressed: byte;
    PictureCompressedSize: integer;
  end;
  // get8 Packname
  // get8 PackURL
  // get8 PackAuthor
  // get8 PackComment
  // get(PictureSize) BitMap
  DUP5PACK_File = packed record
    Size: integer;
    DSize: integer;
    DateT: integer;
    Hidden: byte;
    ReadOnly: byte;
    Flags: byte;               // 00000000 Description
                               //        1 Register ActiveX DLL/OCX
    UpdateOnly: byte;
    Version: integer;
    CompressionType: integer;  // 0 = No compression
                               // 1 = Zlib compression
    BaseInstallDir: integer;
    CRC: integer;
  end;
  // get8 Filename
  // get8 InstallDir
  // array of bytes (File)



  // v4 structure:
  //    Header
  //    Offsets
  //      Information
  //      Information text
  //      Entry directory block
  //      Name directory block
  //      Data block
  //    Footer

  DUP5PACK_Header_v4 = packed record
    ID: array[0..3] of char; // DUPP
    EOF: byte;               // 26
    Version: byte;           // 1 = First Version
                             // 2 = Same structure as version 1 but different meaning.
                             // 3 = "Fixed" CRC calculation (sort of)
                             // 4 = New structure, LZMA compression & SHA-512 hash instead of CRC
    NeededVersion: smallint; //     0 = Any DUPPI version should work
                             // 20240 = If using the InstallDir extension
                             //         If using the Register ActiveX DLL feature
                             //         If embedding a custom banner
                             // 22040 = If using "good" CRC calculation
                             // 30040 = For v4
                             // NOTE: Duppi check this field only since 20240.
                             // Please note that all Duppi version will be able
                             // to read and install all DUPP files but they won't
                             // understand or use all the information in those
                             // files.
    NumOffsets: integer;
  end;

  DUP5PACK_Offsets_v4 = packed record
    ID: byte;                //   1 = Information block
                             //  10 = Banner block (companion of ID 1)
                             //   2 = Entries directory block
                             //  20 = Name block (companion of ID 2)
                             //  21 = Data block (companion of ID 2)
    OptionsFlags: byte;      // $01 Compressed entry (OptionsParams[1])
                             // $20 Companion block
                             // $40 Block entry (BlockEntries will contain the number of entries in the block
                             // $80 Unimportant entry (not a problem if not recognized)
    CompressionType: byte;   // 1 - CompressionType:
                             //     0 = None (Can only/Must be zero if the flag is not set)
                             //     1 = Zlib (Usually this is faster than LZMA)
                             //     2 = LZMA (Compress better than Zlib but slower)
    CompanionOfID: byte;     // Companion block ID (if companion block flag is set)
    NumEntries: Integer;     // Number of entries (only if Block entry flag is set)
    Offset: int64;           // Offset in file
    Size: int64;             // Size in file
    DSize: int64;            // Decompressed size (in case of Compression), 0 otherwise
    Hash: array[0..31] of byte;
                             // SHA-256 Hash of the entry (as stored in the file)
  end;

  DUP5PACK_Info_v4 = packed record
    NumVer: integer;
    DUP5VerTest: integer;           // Test DUP5 version
    DUP5VerValue: integer;          // Value to test against DUP5 version
  end;
  // get8 Packname
  // get8 PackURL
  // get8 PackAuthor
  // get32 PackComment

  DUP5PACK_File_v4 = packed record
    RelOffset: int64;          // This is relative to the start of the Data block offset
    Size: int64;
    DSize: int64;
    DateT: integer;
    Flags: byte;               // 00000000     Description
                               //        1 $01 Register ActiveX DLL/OCX
                               //       1  $02 Hidden
                               //      1   $04 Read Only
                               //     1    $08 Update Only
                               //    1     $10 Compressed
                               //   1      $20 x64/AMD64     // Not in original v4 spec
    CompressionType: byte;     // 0 = No compression
                               // 1 = Zlib compression
                               // 2 = LZMA compression <-- Default
    BaseInstallDir: byte;      // 0 = Dup5Path + 'data\convert\'
                               // 1 = Dup5Path + 'data\'
                               // 2 = Dup5Path + 'data\drivers\'
                               // 3 = Dup5Path + 'data\hyperripper\'
                               // 4 = Dup5Path;
                               // 5 = Dup5Path + 'utils\';
                               // 6 = Dup5Path + 'utils\templates\';
                               // 7 = Dup5Path + 'utils\translation\';
                               // 8 = Dup5Path + 'utils\data\';
                               // 255 = Windows
                               // 256 = Windows\System
    NameID: integer;           // Index number in Name block
    Version: integer;          // File version
    HashType: byte;            // 0 = MD5
                               // 1 = SHA-1
                               // 2 = SHA-256
                               // 3 = SHA-512    <-- Default
                               // 4 = RIPEMD160
    Hash: array[0..63] of byte;
  end;

  // Name block
  //   get8 filename

  DUP5PACK_Footer_v4 = packed record
    HashHeaderOffsets: array[0..31] of byte;  // SHA-256 of Header block (Header+Offsets)
    SignatureVersion: smallint;       // Program version that made the D5P file
    SignatureID: Byte;                // Program ID that made the D5P file
                                      //    0 = Not indicated
                                      //    1 = DPACKC
                                      // If you create a program either set 0 or use a number greater than 128
    Flags: Byte;                      // Footer flags
    Version: Byte;                    // 1 = Footer v1
    EOF: Byte;                        // End of file (=26)
    ID: array[0..3] of char;          // "PPUD"
  end;

const D5PFILE_REGSVR32 = $1;
      D5PFILE_HIDDEN = $2;
      D5PFILE_READONLY = $4;
      D5PFILE_UPDATEONLY = $8;
      D5PFILE_COMPRESSED = $10;
      D5PFILE_X64 = $20;

      D5PID_INFORMATION = 1;
      D5PID_BANNER = 10;
      D5PID_ENTRIES = 2;
      D5PID_NAMES = 20;
      D5PID_DATA = 21;

      D5PBLOCK_COMPRESSED = $1;
      D5PBLOCK_COMPANION = $20;
      D5PBLOCK_ENTRIES = $40;
      D5PBLOCK_UNIMPORTANT = $80;

      D5PCOMPRESSION_NONE = 0;
      D5PCOMPRESSION_ZLIB = 1;
      D5PCOMPRESSION_LZMA = 2;

      D5PHASH_MD5 = 0;
      D5PHASH_SHA1 = 1;
      D5PHASH_SHA256 = 2;
      D5PHASH_SHA512 = 3;
      D5PHASH_RIPEMD160 = 4;

type
     ConvertInfo = record
       Name: ShortString;
       Version: ShortString;
       Author: ShortString;
       Comment: ShortString;
       VerID: Integer;
     end;
     VersionInfo = record
       Name: ShortString;
       Author: ShortString;
       Comment: ShortString;
       Version: Integer;
     end;
  TDUDIVersion = function(): Byte; stdcall;
  TGetConvertVersion = function(): ConvertInfo;
  TGetHRVersion = function(): VersionInfo; stdcall;
  TGetNumVersion = function(): Integer; stdcall;

implementation

function getVersionFromInt(version: integer): string;
begin

  if version >= 0 then
  begin

    result := getVersion(version);

  end
  else
    result := '???';

end;

end.
