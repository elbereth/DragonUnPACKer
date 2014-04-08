unit spec_D11D;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is spec_D11D.pas, released March 21, 2014.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
//
// =============================================================================
// Dragon UnPACKer 11th Hour Data file [D11D] Specification
// =============================================================================
//
// D11DHeader
// Data (CompressedSize bytes) --> (Raw or Zlib)
//   
// -----------------------------------------------------------------------------

interface

const
      D11D_Version : Byte = 1;
      D11D_FLAG_CRC = $0001;
      D11D_FLAG_ZLIB = $0002;

type
     D11D_Header = packed record
      ID: array[0..3] of char;
      EOF: byte;   // 25
      Version: byte;
      Flags: Word;
      UncompressedSize: Cardinal;
      CompressedSize: Cardinal;
      CRC32: longint;
      SeparatorOffset: Cardinal;
      Unused: array[0..1] of Cardinal;
     end;

implementation

end.