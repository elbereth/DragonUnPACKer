unit UTConfig;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is UTConfig.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Registry, GameHint, UT_Packages;

type
  TfrmUTConfig = class(TForm)
    lstGames: TListView;
    butRemove: TButton;
    butOK: TButton;
    lblVersion: TLabel;
    Bevel2: TBevel;
    butEdit: TButton;
    procedure butOKClick(Sender: TObject);
    procedure lstGamesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure butRemoveClick(Sender: TObject);
    procedure butEditClick(Sender: TObject);
  private
    procedure setGameHint(ix: integer; ordGH: integer; keep: boolean);
    { Private declarations }
  public
    { Public declarations }
    translationDUT201: string;
    translationDUT202: string;
    translationDUT203: string;
  end;

var
  frmUTConfig: TfrmUTConfig;

implementation

{$R *.dfm}

procedure TfrmUTConfig.butOKClick(Sender: TObject);
begin

  ModalResult := 1;

end;

procedure TfrmUTConfig.lstGamesSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin

  butEdit.Enabled := true;
  butRemove.Enabled := true;

end;

procedure TfrmUTConfig.butRemoveClick(Sender: TObject);
var Reg: TRegistry;
    ixdel: integer;
    deleteList: boolean;
begin

  deleteList := false;

  if not(lstGames.Selected = nil) then
  begin

    ixdel := strtoint(lstGames.Selected.Caption);

    Reg := TRegistry.Create;
    Try

      if Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d\'+inttohex(ixdel,8)) then
      begin
        if Reg.DeleteKey('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d\'+inttohex(ixdel,8)) then
        begin
          deleteList := true;
        end;
      end
      else
        deleteList := true;

      if deleteList then
      begin
        lstGames.Selected.Delete;
        butEdit.Enabled := false;
        butRemove.Enabled := false;
      end;
    Finally
      FreeAndNil(Reg);
    end;
  end
  else
  begin
    butEdit.Enabled := false;
    butRemove.Enabled := false;
  end;

end;

procedure TfrmUTConfig.butEditClick(Sender: TObject);
var frmGH: TfrmGameHint;
    GH: TUTPackage_GameHint;
    ix, z, curSel: integer;
    dontask: boolean;
    x: TUTPackage_GameHint;
begin

  if not(lstGames.Selected = nil) then
  begin

    ix := strtoint(lstGames.Selected.SubItems.Strings[3]);
    GH := Low(TUTPackage_GameHint);
    Inc(GH,ix);
    dontask := strtobool(lstGames.Selected.SubItems.Strings[2]);

    frmGH := TfrmGameHint.Create(self);
    try
      frmGH.Width := 326;
      frmGH.Height := 110;
      frmGH.lblOpening.Caption := translationDUT201;
      frmGH.chkDontAsk.Caption := translationDUT202;
      frmGH.chkDontAsk.Checked := dontask;
      with frmGH do
      begin

        curSel := 0;
        z := 0;
        for x := Low(TUTPackage_GameHint) to high(TUTPackage_GameHint) do
        begin
          if (x = Low(TUTPackage_GameHint)) then
            lstGameHints.Items.Add(translationDUT203)
          else
            lstGameHints.Items.Add(UTPackage_GameHintStrings[x]);
          if GH = x then
            curSel := z;
          inc(z);
        end;

        if lstGameHints.Items.Count > 0 then
          lstGameHints.ItemIndex := curSel;

        GH := Low(TUTPackage_GameHint);
        Inc(GH,frmGH.ShowModal-1);
        lstGames.Selected.SubItems.Strings[1] := UTPackage_GameHintStrings[GH];
        lstGames.Selected.SubItems.Strings[2] := BoolToStr(chkDontAsk.Checked, false);
        lstGames.Selected.SubItems.Strings[3] := inttostr(ord(GH));
        setGameHint(strtoint(lstGames.Selected.Caption),ord(GH),chkDontAsk.Checked);
      end;

        //setGameHint(fil,ord(GH),frmGH.chkDontAsk.checked);
    finally
      FreeAndNil(frmGH);
    end;

  end;


end;

procedure TfrmUTConfig.setGameHint(ix: integer; ordGH: integer; keep: boolean);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d\'+inttohex(ix,8),True) then
    begin
      Reg.WriteBool('DontAsk',keep);
      Reg.WriteInteger('GameHint',ordGH);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

end.
