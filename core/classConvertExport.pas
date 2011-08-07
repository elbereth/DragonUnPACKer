unit classConvertExport;

// $Id: classConvertExport.pas,v 1.1 2010-04-21 16:23:52 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/classConvertExport.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
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
 