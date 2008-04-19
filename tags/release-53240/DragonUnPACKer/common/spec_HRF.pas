unit spec_HRF;

// $Id: spec_HRF.pas,v 1.7 2008-03-24 14:06:57 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/common/spec_HRF.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is spec_HRF.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// HyperRipper File [HRF] types
// =============================================================================
//
//  Types:  
//  HRF3_Header
//  HRF3_Info
//  HRF3_Index
//  HRF_Header
//  HRF_Infos_v0
//  HRF_Infos_v1
//  HRF_Index_v1
//  HRF_Index_v2
//  
//  Const:
//  DULK_Version
//  DULK_IndexNum
//  
//  Functions:
//  procedure LoadLook(fil: string);
//
// -----------------------------------------------------------------------------

interface

const HR_VERSION = 55042;	// HyperRipper version
      HR_ID = 1;

      HR_TYPE_ERROR = -1;
      HR_TYPE_UNKNOWN = 0;
      HR_TYPE_AUDIO = 1;
      HR_TYPE_VIDEO = 2;
      HR_TYPE_IMAGE = 3;
      HR_TYPE_OTHER = 9999;

type HRF3_Header = packed record	// Header of HRF file v3
       ID: array[1..5] of char;		// Magic ID 'HRFi'+#26
       MajorVersion: byte;		// Major version (must be 3)
       MinorVersion: byte;		// Minor version : 0 = Initial v3 revision
       PrgVersion: integer;		// Created with program version
       PrgID: byte;			// Created with program ID :
       					// 1 = HyperRipper
       Attribs: byte;			// Attributes
       Filename: array[1..255] of char; // Data compagnon file
       Filesize: int64;			// Size of compagnon file
       NumEntries: integer;		// Number of entries
       OffsetIndex: integer;		// Offset to index of entries
    end;
    HRF3_Info = packed record		// Information chunk v3
       InfoType: byte;
       Author: array[1..64] of char;
       URL: array[1..128] of char;
       Title: array[1..64] of char;
    end;
    HRF3_Index = packed record		// Index chunk v3 (repeated for each entry in file)
       Filename: array[1..255] of char;
//       GenType: integer;
       Offset: int64;
       Size: int64;
    end;

type Version = packed record
       Major: Byte; 
       Minor: Byte;
     end;
     HRF_Header = packed record
       ID: array[0..4] of char; // 'HRFi'+chr(26)
       Version: byte;           // 0 = Version 0 (No name change support)
                                // 1 = Version 1 (Default)
                                // 2 = Version 2 (Security + Infos)
       Filename: array[0..97] of char;
       FileSize: integer;
       HRipVer: Version;        // v0.0 = Version 32 (v2.1 Beta)
                                // v3.0 = Version 38 (v3.0 Beta)
                                // v3.1 = Version 39 (v3.1 Beta)
                                // v3.5 = Version 47 (v3.5 Beta)
                                // v4.0 = Version 71 (v4.0)
                                // v4.1 = Version 72 (v4.1)
                                // v4.2 = Version 74 (v4.2)
                                // --- Rewritted from scratch ---
                                // v5.0 = Version 5.0 Alpha
       Dirnum: integer;
     end;
     HRF_Infos_v0 = packed record
       InfoVer: byte;           // Version of Information chunk
                                // 0 = 2 bytes Information chunk
                                //     (only SecuritySize is present)
                                // 1 = 258 bytes Information chunk
       SecuritySize: byte;      // Max Size of Security Data in Directory v2
                                // Allowed values:
                                // 1,2,4,8 and 16
     end;
     HRF_Infos_v1 = packed record
       Author: array[0..63] of char;
       url: array[0..127] of char;
       Title: array[0..63] of char;
     end;
     HRF_Index_v1 = packed record
       Filename: array[0..31] of char;
       FileType: byte;
       Offset: integer;
       Size: integer;
     end;
     HRF_Index_v2 = packed record
       Filename: array[0..63] of char;
       FileType: byte;
       Offset: integer;
       Size: integer;
       Security: array[0..15] of byte;
     end;


function getHRVersion(version: integer): string;

implementation

uses SysUtils, StrUtils;

function getHRVersion(version: integer): string;
var majVer: integer;
    minVer: integer;
//    revVer: integer;
    typVer: integer;
    valVer: integer;
    inStr: String;
    typStr: String;
    valStr: String;
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

{  if (length(inStr) >= 3) then
    revVer := StrToInt(MidStr(inStr,length(inStr)-2,1))
  else
    revVer := 0;}

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
    typStr := '';
    valStr := Chr(96+valVer);
  end
  else if (typVer = 5) then
  begin
    typStr := '';
    valStr := Chr(106+valVer);
  end
  else if (typVer = 6) then
  begin
    typStr := 'Release';
    case valVer of
      7: valStr := '+';
      8: valStr := '++';
      9: valStr := '+++';
    else
      valStr := Chr(116+valVer);
    end;
  end
  else if (valVer > 0) then
    valStr := IntToStr(valVer)
  else
    valStr := '';

  result := TrimRight(IntToStr(majVer)+'.'+IntToStr(minVer)+valStr);

end;

end.
