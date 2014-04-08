unit dup5drv_utils;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
