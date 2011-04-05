unit Proxy;

// $Id: Proxy.pas,v 1.2 2009-06-26 21:06:05 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/tools/duppi/Proxy.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is Proxy.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Installer;

type
  TfrmProxy = class(TForm)
    strProxy: TLabel;
    txtProxy: TEdit;
    strProxyPort: TLabel;
    txtProxyPort: TEdit;
    cmdOk: TButton;
    chkUserPass: TCheckBox;
    txtProxyUser: TEdit;
    strProxyUser: TLabel;
    strProxyPass: TLabel;
    txtProxyPass: TEdit;
    procedure cmdOkClick(Sender: TObject);
    procedure chkUserPassClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmProxy: TfrmProxy;

implementation

{$R *.dfm}

uses Registry;

procedure TfrmProxy.cmdOkClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Duppi',True) then
    begin
      Reg.WriteString('Proxy',txtProxy.Text);
      Reg.WriteString('ProxyPort',txtProxyPort.Text);
      Reg.WriteString('ProxyUser',txtProxyUser.Text);
      Reg.WriteString('ProxyPass',txtProxyPass.Text);
      Reg.WriteBool('ProxyUserPass',chkUserPass.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  frmInstaller.proxy := txtProxy.Text;
  frmInstaller.proxyPort := txtProxyPort.Text;
  frmInstaller.proxyUser := txtProxyUser.Text;
  frmInstaller.proxyPass := txtProxyPass.Text;
  frmInstaller.proxyUserPass := chkUserPass.Checked;

end;

procedure TfrmProxy.chkUserPassClick(Sender: TObject);
begin

  txtProxyUser.Enabled := chkUserPass.Checked;
  txtProxyPass.Enabled := chkUserPass.Checked;

end;

end.
