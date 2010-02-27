unit DrvInfo;

// $Id: DrvInfo.pas,v 1.1.1.1 2004-05-08 10:25:29 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/DrvInfo.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
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
    { D�clarations priv�es }
  public
    { D�clarations publiques }
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