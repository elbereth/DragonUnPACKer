unit MpegAudioOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Registry, JvSpin;

type
  TfrmOptMPEGa = class(TForm)
    grp1: TGroupBox;
    chkMP10_1: TCheckBox;
    chkMP10_2: TCheckBox;
    chkMP10_3: TCheckBox;
    chkMP20_1: TCheckBox;
    chkMP20_2: TCheckBox;
    chkMP20_3: TCheckBox;
    chkMP25_1: TCheckBox;
    chkMP25_2: TCheckBox;
    chkMP25_3: TCheckBox;
    cmdMP3: TButton;
    cmdMP1: TButton;
    cmdMP2: TButton;
    grp2: TGroupBox;
    grp3: TGroupBox;
    chkXingVBR: TCheckBox;
    chkID3Tag: TCheckBox;
    Bevel1: TBevel;
    chkFramesMin: TCheckBox;
    numFramesMin: TJvSpinEdit;
    lblFrameMin: TLabel;
    lblFrameMax: TLabel;
    numFramesMax: TJvSpinEdit;
    chkFramesMax: TCheckBox;
    chkSizeMin: TCheckBox;
    chkSizeMax: TCheckBox;
    numSizeMin: TJvSpinEdit;
    numSizeMax: TJvSpinEdit;
    lblSizeMax: TLabel;
    lblSizeMin: TLabel;
    cmdOk: TButton;
    lblVersion: TLabel;
    Bevel2: TBevel;
    Label5: TLabel;
    Label6: TLabel;
    lblUnof: TLabel;
    procedure cmdOkClick(Sender: TObject);
    procedure cmdMP1Click(Sender: TObject);
    procedure cmdMP2Click(Sender: TObject);
    procedure cmdMP3Click(Sender: TObject);
    procedure numFramesMaxChange(Sender: TObject);
    procedure numFramesMinChange(Sender: TObject);
    procedure chkFramesMinClick(Sender: TObject);
    procedure chkFramesMaxClick(Sender: TObject);
    procedure chkSizeMinClick(Sender: TObject);
    procedure chkSizeMaxClick(Sender: TObject);
    procedure numSizeMinChange(Sender: TObject);
    procedure numSizeMaxChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmOptMPEGa: TfrmOptMPEGa;

implementation

{$R *.dfm}

procedure TfrmOptMPEGa.cmdOkClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper\hr_default\MPEGAudio')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper\hr_default\MPEGAudio');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper\hr_default\MPEGAudio',True) then
    begin
      Reg.WriteInteger('FramesMin',Trunc(numFramesMin.Value));
      Reg.WriteInteger('FramesMax',Trunc(numFramesMax.Value));
      Reg.WriteInteger('SizeMin',Trunc(numSizeMin.Value));
      Reg.WriteInteger('SizeMax',Trunc(numSizeMax.Value));
      Reg.WriteBool('LimitFramesMin',chkFramesMin.Checked);
      Reg.WriteBool('LimitFramesMax',chkFramesMax.Checked);
      Reg.WriteBool('LimitSizeMin',chkSizeMin.Checked);
      Reg.WriteBool('LimitSizeMax',chkSizeMax.Checked);
      Reg.WriteBool('SpecialXingVBR',chkXingVBR.Checked);
      Reg.WriteBool('SpecialID3Tag',chkID3Tag.Checked);
      Reg.WriteBool('MP10_1',chkMP10_1.Checked);
      Reg.WriteBool('MP20_1',chkMP20_1.Checked);
      Reg.WriteBool('MP25_1',chkMP25_1.Checked);
      Reg.WriteBool('MP10_2',chkMP10_2.Checked);
      Reg.WriteBool('MP20_2',chkMP20_2.Checked);
      Reg.WriteBool('MP25_2',chkMP25_2.Checked);
      Reg.WriteBool('MP10_3',chkMP10_3.Checked);
      Reg.WriteBool('MP20_3',chkMP20_3.Checked);
      Reg.WriteBool('MP25_3',chkMP25_3.Checked);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  close;

end;

procedure TfrmOptMPEGa.cmdMP1Click(Sender: TObject);
begin

  if (chkMP10_1.Checked and chkMP20_1.Checked and chkMP25_1.Checked) then
  begin
    chkMP10_1.Checked := false;
    chkMP20_1.Checked := false;
    chkMP25_1.Checked := false;
  end
  else
  begin
    chkMP10_1.Checked := true;
    chkMP20_1.Checked := true;
    chkMP25_1.Checked := true;
  end;

end;

procedure TfrmOptMPEGa.cmdMP2Click(Sender: TObject);
begin

  if (chkMP10_2.Checked and chkMP20_2.Checked and chkMP25_2.Checked) then
  begin
    chkMP10_2.Checked := false;
    chkMP20_2.Checked := false;
    chkMP25_2.Checked := false;
  end
  else
  begin
    chkMP10_2.Checked := true;
    chkMP20_2.Checked := true;
    chkMP25_2.Checked := true;
  end;

end;

procedure TfrmOptMPEGa.cmdMP3Click(Sender: TObject);
begin

  if (chkMP10_3.Checked and chkMP20_3.Checked and chkMP25_3.Checked) then
  begin
    chkMP10_3.Checked := false;
    chkMP20_3.Checked := false;
    chkMP25_3.Checked := false;
  end
  else
  begin
    chkMP10_3.Checked := true;
    chkMP20_3.Checked := true;
    chkMP25_3.Checked := true;
  end;

end;

procedure TfrmOptMPEGa.numFramesMaxChange(Sender: TObject);
begin

  numFramesMin.MaxValue := numFramesMax.Value;

end;

procedure TfrmOptMPEGa.numFramesMinChange(Sender: TObject);
begin

  numFramesMax.MinValue := numFramesMin.Value;

end;

procedure TfrmOptMPEGa.chkFramesMinClick(Sender: TObject);
begin

  numFramesMin.Enabled := chkFramesMin.Checked;

end;

procedure TfrmOptMPEGa.chkFramesMaxClick(Sender: TObject);
begin

  numFramesMax.Enabled := chkFramesMax.Checked;

end;

procedure TfrmOptMPEGa.chkSizeMinClick(Sender: TObject);
begin

  numSizeMin.Enabled := chkSizeMin.Checked;

end;

procedure TfrmOptMPEGa.chkSizeMaxClick(Sender: TObject);
begin

  numSizeMax.Enabled := chkSizeMax.Checked;

end;

procedure TfrmOptMPEGa.numSizeMinChange(Sender: TObject);
begin


  numSizeMax.MinValue := numSizeMin.Value;

end;

procedure TfrmOptMPEGa.numSizeMaxChange(Sender: TObject);
begin

  numSizeMin.MaxValue := numSizeMax.Value;

end;

procedure TfrmOptMPEGa.FormShow(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper\hr_default\MPEGAudio',True) then
    begin
      if Reg.ValueExists('FramesMin') then
        numFramesMin.Value := Reg.ReadInteger('FramesMin');
      if Reg.ValueExists('FramesMax') then
        numFramesMax.Value := Reg.ReadInteger('FramesMax');
      if Reg.ValueExists('SizeMin') then
        numSizeMin.Value := Reg.ReadInteger('SizeMin');
      if Reg.ValueExists('SizeMax') then
        numSizeMax.Value := Reg.ReadInteger('SizeMax');
      if Reg.ValueExists('LimitFramesMin') then
        chkFramesMin.Checked := Reg.ReadBool('LimitFramesMin');
      if Reg.ValueExists('LimitFramesMax') then
        chkFramesMax.Checked := Reg.ReadBool('LimitFramesMax');
      if Reg.ValueExists('LimitSizeMin') then
        chkSizeMin.Checked := Reg.ReadBool('LimitSizeMin');
      if Reg.ValueExists('LimitSizeMax') then
        chkSizeMax.Checked := Reg.ReadBool('LimitSizeMax');
      if Reg.ValueExists('SpecialXingVBR') then
        chkXingVBR.Checked := Reg.ReadBool('SpecialXingVBR');
      if Reg.ValueExists('SpecialID3Tag') then
        chkID3Tag.Checked := Reg.ReadBool('SpecialID3Tag');
      if Reg.ValueExists('MP10_1') then
        chkMP10_1.Checked := Reg.ReadBool('MP10_1');
      if Reg.ValueExists('MP20_1') then
        chkMP20_1.Checked := Reg.ReadBool('MP20_1');
      if Reg.ValueExists('MP25_1') then
        chkMP25_1.Checked := Reg.ReadBool('MP25_1');
      if Reg.ValueExists('MP10_2') then
        chkMP10_2.Checked := Reg.ReadBool('MP10_2');
      if Reg.ValueExists('MP20_2') then
        chkMP20_2.Checked := Reg.ReadBool('MP20_2');
      if Reg.ValueExists('MP25_2') then
        chkMP25_2.Checked := Reg.ReadBool('MP25_2');
      if Reg.ValueExists('MP10_3') then
        chkMP10_3.Checked := Reg.ReadBool('MP10_3');
      if Reg.ValueExists('MP20_3') then
        chkMP20_3.Checked := Reg.ReadBool('MP20_3');
      if Reg.ValueExists('MP25_3') then
        chkMP25_3.Checked := Reg.ReadBool('MP25_3');
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

end.
