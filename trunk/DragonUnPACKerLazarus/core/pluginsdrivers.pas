// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// This is somehow based on Delphi source code of Dragon UnPACKer 5:
// DragonUnPACKer/core/classFSE.pas
// Released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

// ----------------------------------------------------------------------------
// Purpose
// ----------------------------------------------------------------------------
// This file contains the TDragonUnPACKerDriverPlugins class. This is truly the
// core of Dragon UnPACKer as it is this class that loads driver plugins, parse
// results and prepare everything for display (normal display, directory
// specific, search results, etc..).
// ----------------------------------------------------------------------------

unit PluginsDrivers;

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses
  Classes, SysUtils, commonTypes, DynLibs, SharedLogger;

type TDragonUnPACKerDriverPlugins = TObject;

implementation

end.

