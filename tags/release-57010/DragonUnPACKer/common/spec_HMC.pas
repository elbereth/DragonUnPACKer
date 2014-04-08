unit spec_HMC;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is spec_HMC.pas, released May 29, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

type TEX_Header = packed record
       IndexOffset: cardinal;
       UnknownOffset: cardinal;
       ID3: cardinal;   // 3
       ID4: cardinal;   // 4
     end;
     TEX_Entry = packed record
       Size: cardinal;
       Type1: array[0..3] of char;
       Type2: array[0..3] of char;
       Index: Cardinal;
       Height: word;
       Width: word;
       NumMipMap: cardinal;
       Unknown: array[1..3] of Cardinal;
     end;
     HMC_TEX_Entry = TEX_Entry;

implementation

end.
 