unit u_ListOfToolsDataStruct;

// $Id: cnv_exttools.dpr 616 2011-05-01 14:23:22Z elbereth $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is cnv_pictex.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

type
     TStrArray = array of string;
     TToolInfo = record
       enabled: boolean;
       name: string;
       author: string;
       url: string;
       comment: string;
       path: string;
       command: string;
       resultext: string;
       resultoktest: integer;
       resultok: integer;
       extensions: TStrArray;
     end;
     PToolInfo = ^TToolInfo;

implementation

end.
 