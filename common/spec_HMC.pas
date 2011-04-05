unit spec_HMC;

// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
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
 