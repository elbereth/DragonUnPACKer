unit spec_DUHT;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is spec_DUHT.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// Dragon Unpacker HTML Template [DUHT] types
// =============================================================================
//  
//  DUHT_Header
//  DUHT_HeaderX_v1
//  DUHT_Entry
//
// -----------------------------------------------------------------------------

interface

type DUHT_Header = packed record
      ID: array[0..4] of char;  //  'DUHT' + #26
      Version: Byte;            //  0 = Reservé
                                //  1 = *Obsolette*
                                //  2 = Version 2
      Revision: Byte;           //  0 = Revision 0 (17/11/2002)
                                //  1 = Revision 1 (11/03/2003)
      NumEntries: Integer;      //
      StartOffset: integer;
      ExtendedHeader: Byte;     //  0 = No extended header
                                //  1 = Extended Header v1
                                //  2 = Extended Header v2 (future use)
     end;
     DUHT_HeaderX_v1 = packed record
       CompID: array[0..1] of char;
       CompVersion: integer;
       DUPVersionID: byte;      //  3 = 5.0.0 Beta 3 +
       XORKey: byte;            // XOR Key for the Get8 strings
     end;
     // TemplateName As Get8
     // TemplateVersion As Get8
     // AuthorName As Get8
     // AuthorEmail As Get8
     // URL As Get8
     // DefaultExt As Get8   (Revision 1)
     // ExtInfo As Get8      (Revision 1)
     DUHT_Entry = packed record
       ID: array[0..1] of char; // ID of the Entry
       Size: integer;           // Size of data in file
       FileSize: integer;       // Size of the file when extracted
       Compression: byte;       // 0 = None
                                // 1 = Zlib
       CRC32: integer;          //
     end;
     // Possible Entries:
     // CM - Comment
     // HD - Header
     // HR - Header Root
     // VR - Variable
     // FT - Footer
     // FR - Footer Root
     // PV - Preview
     // IM - Image (Special Entry)
     //      get8 filename
     //      image as FileSize - len(Filename) - 1

implementation

begin

end.
