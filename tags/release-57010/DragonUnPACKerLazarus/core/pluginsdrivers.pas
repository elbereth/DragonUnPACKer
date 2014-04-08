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

type

  { TDragonUnPACKerDriverPlugin }
  TDriverInfo = record
    Name : String;          // Name of the driver (ex: Default Driver)
    Author : String;        // Your name (or nickname)
    Version : String;       // String representation of the version number
    VersionID : Integer;    // Version number in numeric format (a new version
                            // must always have a higher VersionID)
    Comment : String;       // Any comment you want to add (like code
                            // source from this guy, blah blah, etc..)
  end;

  // Record to store a support file format
  TSupportedFormatInfo = record
     Extensions : String;   // List of extensions ";" separated
                            // ex: *.PAK;*.WAD;*.EXT
     Name : String;         // Name of the file format displayed in
                            // DUP6 open dialog.
                            // If multiple names separate them with a pipe
                            // ex: Quake (*.PAK)|Quake 2 (*.PAK)
  end;

  TDriverFormatInfo = array of TSupportedFormatInfo;

  TDriverLoadedFormatInfo = record
     Sch : String;          // Directory parsing char (ex: \ or /) if
                            // left blank then no directory parsing
     ID : String;           // Identification string of the file format
                            // Should be as unique and short as possible
                            // because it is used by convert plugins to
                            // identify the file format.
     ExtractInternal : Boolean;   // Indicate if DUP should use the plugin
                                  // ExtractFile function or DUP own extract
                                  // function.
   end;

  TDragonUnPACKerEntry = record
    FileName: string;
    Offset: int64;
    Size: int64;
    Data: array of int64;
  end;
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

  TProcGetDUDIDriver = function(): IDragonUnPACKerDriverPlugin;

type

  { TDragonUnPACKerDriverPlugins }

  TDragonUnPACKerDriverPlugins = class(TObject)
  private
    Driver: TList;
  public
    constructor create;
    destructor destroy;
    function refreshDrivers(path: string): integer;
  end;



implementation

{ TDragonUnPACKerDriverPlugins }

constructor TDragonUnPACKerDriverPlugins.create;
begin

  inherited;
  Driver := TList.Create;

end;

destructor TDragonUnPACKerDriverPlugins.destroy;
begin

  FreeAndNil(Driver);
  inherited;

end;

function TDragonUnPACKerDriverPlugins.refreshDrivers(path: string): integer;
var test: TlibHandle;
    func: TProcGetDUDIDriver;
    test2: IDragonUnPACKerDriverPlugin;
begin

  test := SafeLoadLibrary(path+'\plugins\drv_default.d6d');
  func := TProcGetDUDIDriver(GetProcedureAddress(test,'getDUDIDriver'));
  Logger.Send('Test',test);
  if (@func = nil) then
    Logger.Send('Test ERROR')
  else
    test2 := func();

  Logger.Send('Test DUDIVersion: ',test2.getDUDIVersion());

end;

end.

