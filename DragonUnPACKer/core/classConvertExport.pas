unit classConvertExport;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is classConvert.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

// ============================================================================
// classConvertExport unit / Shared definitions
// ============================================================================

interface

type ConvertInfoEx = record
       Name: String;
       Version: String;
       Author: String;
       Comment: String;
       VerID: Integer;
       DUCIVersion: byte;
       Filename: String;
       isAboutBox: boolean;
       isConfigBox: boolean;
     end;

implementation

end.
 