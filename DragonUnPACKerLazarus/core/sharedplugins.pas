// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

// ----------------------------------------------------------------------------
// Purpose
// ----------------------------------------------------------------------------
// This file creates/destroy the plugins of Dragon UnPACKer.
// Declare it in the use section to have access to plugins.
// ----------------------------------------------------------------------------

unit sharedplugins;

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses
  PluginsDrivers;

var
  DPlugins: TDragonUnPACKerDriverPlugins;

implementation

initialization
  DPlugins:=TDragonUnPACKerDriverPlugins.Create;
finalization
  DPlugins.Free;
end.
