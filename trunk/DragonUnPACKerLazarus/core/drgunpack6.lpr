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
// Dragon UnPACKer 6 project for Lazarus.
// ----------------------------------------------------------------------------

program drgunpack6;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, virtualtreeview_package, multiloglaz, Main, const_version,
  SharedLogger, FileChannel,
  sharedplugins, pluginsdrivers;

{$R *.res}

begin
  Application.Title:='Dragon UnPACKer v'+DRAGONUNPACKER_VERSION+DRAGONUNPACKER_EDITION;
  Application.Initialize;
  Logger.Channels.Add(TFileChannel.Create('drgunpack6.log'));
  Application.CreateForm(TfrmMain, frmMain);
  frmMain.Caption:=Application.Title;
  Application.Run;
end.

