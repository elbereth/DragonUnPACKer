unit DrvInfo;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is DrvInfo.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmDrvInfo = class(TForm)
    Driver: TGroupBox;
    strName: TLabel;
    strAuthor: TLabel;
    strComment: TLabel;
    lblName: TLabel;
    lblAuthor: TLabel;
    lblVersion: TLabel;
    strVersion: TLabel;
    Fichier: TGroupBox;
    strFileFormat: TLabel;
    strFileEntries: TLabel;
    strFileSize: TLabel;
    strFileLoadTime: TLabel;
    lblFileFormat: TLabel;
    lblFileEntries: TLabel;
    lblFileSize: TLabel;
    lblFileLoadTime: TLabel;
    lblFileTotalTime: TLabel;
    bevComment: TBevel;
    lblComment: TLabel;
    procedure FormClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmDrvInfo: TfrmDrvInfo;

implementation

{$R *.dfm}

procedure TfrmDrvInfo.FormClick(Sender: TObject);
begin

frmDrvInfo.Close;

end;

end.
