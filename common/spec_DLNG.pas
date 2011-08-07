unit spec_DLNG;

// $Id: spec_DLNG.pas,v 1.1.1.1 2004-05-08 10:25:11 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/common/spec_DLNG.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is spec_DLNG.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// Dragon LaNGuage [DLNG] types
// =============================================================================
//  
//  DLNG_Header_v3
//  DLNG_Header_v4
//  DLNG_ExtendedHeader
//  DLNG_IndexEntry_v3
//  DLNG_IndexEntry_v4
//
// -----------------------------------------------------------------------------

interface

type
   DLNG_Header_v4 = packed record
     ID: array[0..4] of Char;
     Version: Byte;
     PrgID: array[1..2] of Char;
     PrgVER: Byte;
     IndexOffSet: Integer;
     IndexNum: Integer;
     IndexCRC: Integer;
     DataOffSet: Integer;
     DataSize: Integer;
     DataCSize: Integer;
     DataCRC: Integer;
     Compression: Byte;     //  0 = None (Default & Faster)
                            //  1 = ZLib
     Manufacturer: Byte;    //  0 = Not available
                            // 40 = DLNGC v4.0
     ExtendedHeaderSize: integer;
     ExtendedHeaderCRC: integer;
     IconSize: integer;
   end;
   DLNG_Header_v3 = record
     ID: array[0..4] of Char;
     Version: Byte;
     PrgID: array[1..2] of Char;
     PrgVER: Byte;
     IndexOffSet: Integer;
     IndexNum: Integer;
     FileSize: Word;
     FileCRC: Integer;
     Manufacturer: Byte;    //  0 = Not available
                            // 30 = DLNGC v3.0
     ExtendedHeaderSize: integer;
     ExtendedHeaderCRC: integer;
     IconSize: integer;
   end;
   DLNG_ExtendedHeader = record
     Name: WideString;
     Author: WideString;
     URL: WideString;
     Email: WideString;
     FontName: WideString;
   end;
   DLNG_IndexEntry_v3 = record
     ID: array[1..6] of Char;
     Length: Word;
   end;
   DLNG_IndexEntry_v4 = packed record
     ID: array[1..6] of Char;
     Offset: Integer;
     Length: Word;
   end;

implementation

end.
