unit sharedplugins;

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses
  {DupConvertPlugins,} PluginsDrivers;

var
  //CPlugins: TDragonUnPACKerConvertPlugins;
  DPlugins: TDragonUnPACKerDriverPlugins;

implementation

initialization
  DPlugins:=TDragonUnPACKerDriverPlugins.Create;
  //CPlugins:=TDragonUnPACKerConvertPlugins.Create;
finalization
  DPlugins.Free;
  //CPlugins.Free;
end.
