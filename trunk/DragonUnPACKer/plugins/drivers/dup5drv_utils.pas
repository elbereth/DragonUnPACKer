unit dup5drv_utils;

// $Id: dup5drv_utils.pas,v 1.2 2010-02-27 15:57:50 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/drivers/dup5drv_utils.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is dup5drv_utils.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// ===========================================================
// DUP5 Driver Structures (Delphi 6 Unit)
// Dragon UnPACKer v5.0.0                      Plugin SDK PR-2
// ===========================================================

interface

uses spec_DUDI;

procedure addFormat(var drvInfo: DriverInfo; formatExts, formatName: string);
procedure addModifFormat(var drvModifInfo: DriverModifInfo; formatExt, formatName: string; canReplace: boolean = true; canReplaceExt: boolean = true; canAdd: boolean = true; canDel: boolean = true; canCreate: boolean = true);

implementation

procedure addFormat(var drvInfo: DriverInfo; formatExts, formatName: string);
begin

  inc(drvInfo.NumFormats);
  drvInfo.Formats[drvInfo.NumFormats].Extensions := formatExts;
  drvInfo.Formats[drvInfo.NumFormats].Name := formatName;

end;

procedure addModifFormat(var drvModifInfo: DriverModifInfo; formatExt, formatName: string; canReplace: boolean = true; canReplaceExt: boolean = true; canAdd: boolean = true; canDel: boolean = true; canCreate: boolean = true);
begin

  inc(drvModifInfo.NumFormats);
  drvModifInfo.Formats[drvModifInfo.NumFormats].Extension := formatExt;
  drvModifInfo.Formats[drvModifInfo.NumFormats].Name := formatName;
  drvModifInfo.Formats[drvModifInfo.NumFormats].Capability.CanReplace := canReplace;
  drvModifInfo.Formats[drvModifInfo.NumFormats].Capability.CanReplaceExtended := canReplaceExt;
  drvModifInfo.Formats[drvModifInfo.NumFormats].Capability.CanAdd := canAdd;
  drvModifInfo.Formats[drvModifInfo.NumFormats].Capability.CanDelete := canDel;
  drvModifInfo.Formats[drvModifInfo.NumFormats].Capability.CanCreate := canCreate;

end;


end.
