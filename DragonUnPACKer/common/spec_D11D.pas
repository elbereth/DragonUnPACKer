unit spec_D11D;

// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is spec_D11D.pas, released March 21, 2014.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

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