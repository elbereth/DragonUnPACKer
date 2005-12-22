unit spec_DUPP;

// $Id: spec_DUPP.pas,v 1.1.1.1 2004-05-08 10:25:11 elbereth Exp $
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
    NeededVersion: smallint; //     0 = Any DUPPI version should work
                             // 20240 = If using the InstallDir extension
                             //         If using the Register ActiveX DLL feature
                             //         If embedding a custom banner
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

const D5PFILE_REGSVR32 = 1;

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
