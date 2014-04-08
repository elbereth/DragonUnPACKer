// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// This is somehow based on Delphi source code of Dragon UnPACKer 5:
// DragonUnPACKer\plugins\drivers\default\drv_default.dpr
// Released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

// ----------------------------------------------------------------------------
// Purpose
// ----------------------------------------------------------------------------
// This is the Default driver plugin of Dragon UnPACKer.
// The driver plugin architecture in Dragon UnPACKer 6 is object oriented.
// ----------------------------------------------------------------------------
// Revision Date     Description
//          20100606 Initial version, just a proof of concept:
//                   Driver exports only one function which returns the driver class

library drv_default;

{$mode objfpc}{$H+}

uses
  Classes;

Type

{ IDragonUnPACKerDriverPlugin }

IDragonUnPACKerDriverPlugin = interface
  function getDUDIVersion: Integer;
//    property LoadedFormatInfo: Integer;
//    function IsSupported(src: TStream; useSmart: boolean = true): integer;
//    function ReadFormat(src: TStream; useSmart: boolean = true): integer;
//    function CloseFormat: integer;
//    function Create(dupVersion: integer; DUDIVersionCompatible: Integer): IDragonUnPACKerDriverPlugin;
//    function GetInfo: TDriverInfo;
//    function GetSupportedFormats: TDriverFormatInfo;
//    function GetEntry: TDragonUnPACKerEntry;
end;

  { TDragonUnPACKerDriverPlugin }

  TDragonUnPACKerDriverPlugin = class(TInterfacedObject,IDragonUnPACKerDriverPlugin)
    private
      FDUDIVersion: integer;
    public
      function getDUDIVersion: Integer;
      constructor Create;
  end;

{ TDragonUnPACKerDriverPlugin }

function TDragonUnPACKerDriverPlugin.getDUDIVersion: Integer;
begin

  result := FDUDIVersion;

end;

constructor TDragonUnPACKerDriverPlugin.Create;
begin
  inherited;
  FDUDIVersion := 6;
end;

{$R *.res}

function getDUDIDriver: IDragonUnPACKerDriverPlugin;
begin

  result := TDragonUnPACKerDriverPlugin.Create;

end;

exports
  getDUDIDriver;

begin
end.

