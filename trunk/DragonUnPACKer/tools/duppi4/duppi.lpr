program duppi;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  lazcontrols,
  Installer,
  class_DuppiInternet,
  lib_binutils in '../../common/lib_binutils.pas',
  lib_crc in '../../common/lib_crc.pas',
  lib_language in '../../common/lib_language.pas',
  lib_version in '../../common/lib_version.pas',
  lib_zlib in '../../common/lib_zlib.pas',
  spec_DLNG in '../../common/spec_DLNG.pas'
  { you can add units after this };

{$R *.res}

begin
  Application.Title:='Dragon UnPACKer Package Installation';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmInstaller, frmInstaller);
  Application.Run;
end.

