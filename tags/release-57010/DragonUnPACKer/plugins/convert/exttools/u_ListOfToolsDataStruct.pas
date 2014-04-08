unit u_ListOfToolsDataStruct;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

type
     TStrArray = array of string;
     TToolInfo = record
       iniFileName: string;
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
 