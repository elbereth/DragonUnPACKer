unit Proxy;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
