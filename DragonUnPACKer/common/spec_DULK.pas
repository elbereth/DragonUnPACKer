unit spec_DULK;

// $Id$
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/common/spec_DULK.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is spec_DULK.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// Dragon Unpacker LooK [DULK] types & tools
// =============================================================================
//
//  Types:  
//  DULK_Header
//  DULK_IndexEntry
//  
//  Const:
//  DULK_Version
//  DULK_IndexNum
//  
//  Version history:
//  Initial version with support for DULK v1
//
// -----------------------------------------------------------------------------

interface

type
   DULK_Header = record
     ID: array[0..4] of char;  // Magic ID 'DULK'+#26
     Version: Byte;            // 1 = Version 1
     Manufacturer: Byte;       //  0 = Not available
                               // 10 = DLOOKC v1.0
     Attribs: Byte;            // Attributes
     IndexNum: Integer;        // Number of entries in DULK file
     IndexOffset: Integer;     // Offset to entries
   end;
type
   DULK_IndexEntry = record
     ID: array[1..4] of Char;  // Magic ID of entry
     Size: Integer;            // Size of entry
   end;

const DULK_Version : Byte = 1;
      DULK_IndexNum : Integer = 51;  // 51 entries needed in current version of Dragon UnPACKer (5.3.3 Beta+)

implementation

end.
