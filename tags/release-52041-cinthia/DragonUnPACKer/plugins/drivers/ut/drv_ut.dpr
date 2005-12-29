library drv_ut;

// $Id: drv_ut.dpr,v 1.4 2005-12-14 16:51:37 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/drivers/ut/drv_ut.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is drv_ut.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// You need TUTPackage library (under Mozilla Public Licence 1.1) available
// here: http://sourceforge.net/projects/utpackages
//

uses
  SysUtils,
  Windows,
  Graphics,
  Classes,
  Forms,
  Registry,
  ComCtrls,
  lib_version in '..\..\..\common\lib_version.pas',
  ut_packages in 'ut_packages.pas',
  GameHint in 'GameHint.pas' {frmGameHint},
  UTConfig in 'UTConfig.pas' {frmUTConfig};

{$E d5d}

{$R *.res}

type CurrentDriverInfo = record
     Sch : ShortString;
     ID : ShortString;
     FileHandle : Integer;
     ExtractInternal : Boolean;
   end;
   FormatInfo = record
     Extensions : ShortString;
     Name : ShortString;
   end;
   DriverInfo = record
     Name : ShortString;
     Author : ShortString;
     Version : ShortString;
     Comment : ShortString;
     NumFormats : Byte;
     Formats : array[1..255] of FormatInfo;
   end;
   ErrorInfo = record
     Format : ShortString;
     Games : ShortString;
   end;

   TPercentCallback = procedure (p: byte);
   TLanguageCallback = function (lngid: ShortString): ShortString;

const DRIVER_VERSION = 23040;
      DUP_VERSION = 52040;
      TUTP_VERSION = '2.3-cvs (09/05/2004)';

var CurPos: integer = 0;
    DrvInfo: CurrentDriverInfo;
    Package: TUTPackage;
    ErrInfo: ErrorInfo;
    SetPercent: TPercentCallback;
    DLNGStr: TLanguageCallback;
    CurPath: string;
    AHandle : THandle;
    AOwner : TComponent;

function GetNumVersion: Integer; stdcall;
begin

  GetNumVersion := DRIVER_VERSION;

end;

function DUDIVersion: Byte; stdcall;
begin
  DUDIVersion := 4;
end;

function GetDriverInfo: DriverInfo; stdcall;
begin

  GetDriverInfo.Name := 'A.Cordero''s UT Package Driver';
  GetDriverInfo.Author := 'Alexandre Devilliers (aka Elbereth)';
  GetDriverInfo.Version := getVersion(DRIVER_VERSION);
  GetDriverInfo.Comment := 'Read/Extract from Unreal Tournament packages. Read/Extract code using UT Packages Delphi unit v'+TUTP_VERSION+' by Antonio Cordero Balcazar <http://www.acordero.org>.';
  GetDriverInfo.NumFormats := 2;
  GetDriverInfo.Formats[1].Extensions := '*.uax;*.umx;*.ums;*.utx';
  GetDriverInfo.Formats[1].Name := 'Unreal Tournament (*.UAX;*.UMX;*.UTX)|Rune (*.UAX;*.UMS;*.UTX)|Deus Ex (*.UAX;*.UMX;*.UTX)|Harry Potter (*.UAX;*.UMX;*.UTX)';
  GetDriverInfo.Formats[2].Extensions := '*.uax;*.utx';
  GetDriverInfo.Formats[2].Name := 'Undying (*.UAX;*.UTX)|Unreal Tournament 2003 (*.UAX;*.UTX)|Unreal Tournament 2004 (*.UAX;*.UTX)|Unreal 2 (*.UAX;*.UTX)';

end;

function strip0(str : string): string;
var pos0: integer;
begin

  pos0 := pos(chr(0),str);

  if pos0 > 0 then
    strip0 := copy(str, 1, pos0 - 1)
  else
    strip0 := str;

end;

function getGameHintIdx(pth: string): integer;
var Reg: TRegistry;
    x, NK: integer;
    testPth: string;
begin

  result := -1;

  Reg := TRegistry.Create;
  Try
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d',True) then
    begin
      if Reg.ValueExists('CurrentID') then
        NK := Reg.ReadInteger('CurrentID')
      else
        exit;

      Reg.CloseKey;

      testPth := uppercase(extractfilepath(pth));

      for x := 1 to NK do
      begin
        if Reg.OpenKeyReadOnly('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d\'+inttohex(x,8)) then
        begin
          if Reg.ValueExists('Directory') then
            if (uppercase(Reg.ReadString('Directory')) = testPth) then
            begin
              result := x;
              exit;
            end;
          Reg.CloseKey;
        end;
      end;

    end;
  Finally
    Reg.Free;
  end;

end;

function getGameHintFreeIdx(): integer;
var Reg: TRegistry;
    x, MaxK: integer;
begin

  result := 1;

  Reg := TRegistry.Create;
  Try
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d',True) then
    begin
      if Reg.ValueExists('CurrentID') then
      begin
        MaxK := Reg.ReadInteger('CurrentID');
        Reg.CloseKey;

        result := MaxK + 1;
        for x := 1 to MaxK do
        begin
          if not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d\'+inttohex(x,8))) then
          begin
            Result := x;
            break;
          end;
        end;
        if result = MaxK + 1 then
        begin
          if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d',True) then
          begin
            Reg.WriteInteger('CurrentID',result);
            Reg.CloseKey;
          end;
        end;

      end
      else
      begin
        Reg.CloseKey;
      end;
    end;
  Finally
    Reg.Free;
  end;

end;

function getGHDontAsk(ix: integer): boolean;
var Reg: TRegistry;
begin

  result := false;

  Reg := TRegistry.Create;
  Try

    if Reg.OpenKeyReadOnly('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d\'+inttohex(ix,8)) then
    begin
      if Reg.ValueExists('DontAsk') then
        result := Reg.ReadBool('DontAsk');
    end;
  Finally
    Reg.Free;
  end;

end;

function getGameHint(ix: integer): TUTPackage_GameHint;
var Reg: TRegistry;
begin

  result := Low(TUTPackage_GameHint);

  Reg := TRegistry.Create;
  Try

    if Reg.OpenKeyReadOnly('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d\'+inttohex(ix,8)) then
    begin
      if Reg.ValueExists('GameHint') then
        inc(result,Reg.ReadInteger('GameHint'));
    end;
  Finally
    Reg.Free;
  end;

end;

function getGameHintV(ix: integer): integer;
var Reg: TRegistry;
begin

  result := 0;

  Reg := TRegistry.Create;
  Try

    if Reg.OpenKeyReadOnly('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d\'+inttohex(ix,8)) then
    begin
      if Reg.ValueExists('GameHint') then
        result := Reg.ReadInteger('GameHint');
    end;
  Finally
    Reg.Free;
  end;

end;

procedure setGameHint(pth: string; ordGH: integer; keep: boolean);
var Reg: TRegistry;
    GHix, NK: integer;
begin

  Reg := TRegistry.Create;
  Try
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d',True) then
    begin
      GHix := getGameHintIdx(pth);

      if GHix > -1 then
      begin

        NK := GHix;

      end
      else
      begin

        NK := getGameHintFreeIdx;

      end;

      Reg.CloseKey;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d\'+inttohex(NK,8),True) then
      begin
        Reg.WriteBool('DontAsk',keep);
        Reg.WriteString('Directory',extractfilepath(pth));
        Reg.WriteInteger('GameHint',ordGH);
        Reg.CloseKey;
      end;
    end;
  Finally
    Reg.Free;
  end;

end;

function ReadFormat(fil: ShortString; Deeper: boolean): Integer; stdcall;
var ext: string;
    OldH: THandle;
    frmGH: TfrmGameHint;
    GH: TUTPackage_GameHint;
    ix, z, curSel: integer;
    dontask: boolean;
    x: TUTPackage_GameHint;
begin

  ext := ExtractFileExt(fil);

  if ext <> '' then
    ext := copy(ext,2,length(ext)-1);

  ext := UpperCase(ext);

  if IsConsole then
    writeln('ReadFormat: '+fil+' ('+ext+')');

  if (Pos('_',ext) > 0) then
    ext := Copy(ext,Pos('_',ext)+1,length(ext)-Pos('_',ext));

  if (ext = 'USX') or (ext = 'UKX') or (ext = 'UMOD') or (ext = 'U') or (ext = 'UAX') or (ext = 'UTX') or (ext = 'UMX') or (ext = 'UMS') then
  begin

    OldH := Application.Handle;
    Application.Handle := AHandle;

//    dontask := false;

    ix := getGameHintIdx(fil);

    if ix > -1 then
    begin
      GH := getGameHint(ix);
      dontask := getGHDontAsk(ix);
    end
    else
    begin
      GH := Low(TUTPackage_GameHint);
      dontask := false;
    end;

    if not(dontask) then
    begin
      frmGH := TfrmGameHint.Create(AOwner);
      try
        frmGH.Width := 326;
        frmGH.Height := 110;
        frmGH.lblOpening.Caption := DLNGStr('DUT201');
        frmGH.chkDontAsk.Caption := DLNGStr('DUT202');
        frmGH.chkDontAsk.Checked := dontask;
        with frmGH do
        begin

          curSel := 0;
          z := 0;
          for x := Low(TUTPackage_GameHint) to high(TUTPackage_GameHint) do
          begin
            if (x = Low(TUTPackage_GameHint)) then
              lstGameHints.Items.Add(DLNGStr('DUT203'))
            else
              lstGameHints.Items.Add(UTPackage_GameHintStrings[x]);
            if GH = x then
              curSel := z;
            inc(z);
          end;

          if lstGameHints.Items.Count > 0 then
            lstGameHints.ItemIndex := curSel;

        end;
        GH := Low(TUTPackage_GameHint);
        Inc(GH,frmGH.ShowModal-1);
        setGameHint(fil,ord(GH),frmGH.chkDontAsk.checked);
      finally
        frmGH.Free;
      end;

      Application.Handle := OldH;
    end;

    try
      package.Initialize(fil, GH);
      DrvInfo.ID := 'UTPKG';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := 0;
      DrvInfo.ExtractInternal := True;
      ReadFormat := package.ExportedCount;
    except
      ErrInfo.Format := 'UTPKG';
      ErrInfo.Games := 'Unreal, Unreal Tournament, Rune, Deus Ex, ..';
      ReadFormat := -3;
    end;
  end
  else
    ReadFormat := -1;

end;

function IsFormat(fil: ShortString; Deeper: Boolean): Boolean; stdcall;
var ext: string;
begin

  ext := ExtractFileExt(fil);

  if ext <> '' then
    ext := copy(ext,2,length(ext)-1);

  ext := UpperCase(ext);

  if (Pos('_',ext) > 0) then
    ext := Copy(ext,Pos('_',ext)+1,length(ext)-Pos('_',ext));

  if (ext = 'USX') or (ext = 'UKX') or (ext = 'UMOD') or (ext = 'U') or (ext = 'UAX') or (ext = 'UTX') or (ext = 'UMX') or (ext = 'UMS') then
    IsFormat := True
  else
    IsFormat := False;

end;

procedure CloseFormat; stdcall;
begin

  DrvInfo.Sch := '';
  DrvInfo.ID := '';
  DrvInfo.FileHandle := 0;

  CurPos := 0;
//  Package.ReleaseAllObjects;
  Package.Free;
  Package := TUTPackage.Create;

end;

type
  FormatEntry = record
    FileName: ShortString;
    Offset, Size: Int64;
    DataX, DataY: Integer;
  end;

function GetUTExtension(desc: string): string;
begin

  if (desc = 'Sound') then
    GetUTExtension := 'wav'
  else if (desc = 'Music') then
    GetUTExtension := ''
  else if (desc = 'Texture') then
    GetUTExtension := 'bmp'
  else if (desc = 'Palette') then
    GetUTExtension := 'pal'
  else if (desc = 'SkelModel') then
    GetUTExtension := 'skl'
  else if (desc = 'FireTexture') then
    GetUTExtension := 'fire'
  else
    GetUTExtension := desc;

end;

function GetEntry(): FormatEntry; stdcall;
var Obj: TUTObject;
begin

  if (CurPos < Package.ExportedCount) then
  begin
    if (Package.Exported[CurPos].UTClassName = 'Package') then
    begin
      GetEntry.FileName := '';
      GetEntry.Offset := 0;
      GetEntry.Size := 0;
    end
    else if (Package.Exported[CurPos].UTClassName = 'Music') then
    begin
      Obj:=Package.Exported[CurPos].UTObject;
      if Obj<>nil then
      begin
        Obj.ReadObject;
        GetEntry.FileName := Package.Exported[CurPos].UTObjectName +'.'+TUTObjectClassMusic(Obj).format;
        obj.ReleaseObject;
      end
      else
        GetEntry.FileName := Package.Exported[CurPos].UTObjectName +'.music';
      GetEntry.Size := Package.Exported[CurPos].UTObject.UTSerialSize;
      GetEntry.Offset := Package.Exported[CurPos].UTObject.UTSerialOffset;
    end
    else
    begin
      GetEntry.FileName := Package.Exported[CurPos].UTObjectName +'.'+GetUTExtension(Package.Exported[CurPos].UTClassName);
      GetEntry.Size := Package.Exported[CurPos].UTObject.UTSerialSize;
      GetEntry.Offset := Package.Exported[CurPos].UTObject.UTSerialOffset;
    end;
    GetEntry.DataX := CurPos;
    GetEntry.DataY := 0;
    Inc(CurPos);
  end
  else
  begin
    GetEntry.FileName := '';
    GetEntry.Offset := 0;
    GetEntry.Size := 0;
    GetEntry.DataX := 0;
    GetEntry.DataY := 0;
  end;

end;

function GetCurrentDriverInfo(): CurrentDriverInfo; stdcall;
begin

  GetCurrentDriverInfo := DrvInfo;

end;

function ExtractFileToStream(outputstream: TStream; entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: boolean): boolean; stdcall;
var Obj: TUTObject;
    Bmp: TBitmap;
begin

  Obj:=Package.Exported[DataX].UTObject;
  if Obj<>nil then
  begin
    Obj.ReadObject;
    if (Package.Exported[DataX].UTClassName = 'Sound') then
    begin
      TUTObjectClassSound(Obj).SaveToStream(outputstream);
//      ShowMessage(TUTObjectClassSound(Obj).Format+#10+TUTObjectClassSound(Obj).Data+#10+BoolToStr(TUTObjectClassSound(Obj).HasBeenRead,true)+#10+BoolToStr(TUTObjectClassSound(Obj).HasBeenInterpreted,true));
//      TUTObjectClassSound(Obj).RawSaveToFile('h:\test'+ExtractFileName(outputfile)+'.wav');
    end
    else if (Package.Exported[DataX].UTClassName = 'Music') then
      TUTObjectClassMusic(Obj).SaveToStream(outputstream)
    else if (Package.Exported[DataX].UTClassName = 'Texture') then
    begin
      if TUTObjectClassTexture(Obj).GoodMipMapCount > 0 then
      begin
        Bmp := TUTObjectClassTexture(Obj).GoodMipMap[0].AsBitmap;
        Bmp.SaveToStream(outputstream);
      end;
    end
    else
      Obj.RawSaveToStream(outputstream);
    obj.ReleaseObject;
    //obj.Free;
  end;

  result := true;

end;

function ExtractFile(outputfile: shortstring; entrynam: shortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: boolean): boolean; stdcall;
var Obj: TUTObject;
    Bmp: TBitmap;
begin

  Obj:=Package.Exported[DataX].UTObject;
  if Obj<>nil then
  begin
    Obj.ReadObject;
    if (Package.Exported[DataX].UTClassName = 'Sound') then
    begin
      TUTObjectClassSound(Obj).SaveToFile(outputfile);
//      ShowMessage(TUTObjectClassSound(Obj).Format+#10+TUTObjectClassSound(Obj).Data+#10+BoolToStr(TUTObjectClassSound(Obj).HasBeenRead,true)+#10+BoolToStr(TUTObjectClassSound(Obj).HasBeenInterpreted,true));
//      TUTObjectClassSound(Obj).RawSaveToFile('h:\test'+ExtractFileName(outputfile)+'.wav');
    end
    else if (Package.Exported[DataX].UTClassName = 'Music') then
      TUTObjectClassMusic(Obj).SaveToFile(outputfile)
    else if (Package.Exported[DataX].UTClassName = 'Texture') then
    begin
      if TUTObjectClassTexture(Obj).GoodMipMapCount > 0 then
      begin
        Bmp := TUTObjectClassTexture(Obj).GoodMipMap[0].AsBitmap;
        Bmp.SaveToFile(outputfile)
      end;
    end
    else
      Obj.RawSaveToFile(outputfile);
    obj.ReleaseObject;
    //obj.Free;
  end;

  ExtractFile := true;

end;

function GetErrorInfo(): ErrorInfo; stdcall;
begin

  GetErrorInfo := ErrInfo;

end;

procedure AboutBox; stdcall;
begin

  MessageBoxA(AHandle, PChar('A.Cordero''s UT Package Driver v'+getVersion(DRIVER_VERSION)+#10+
                          '(c)Copyright 2003-2005 Alexandre Devilliers'+#10+#10+
                          'Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+#10+#10+
                          'Uses UT Packages Delphi unit v'+TUTP_VERSION+' by Antonio Cordero Balcazar.'+#10+#10+
                          'Size of entries may not be accurate.')
                        , 'About A.Cordero''s UT Package Driver...', MB_OK);

end;

procedure ConfigBox; stdcall;
var OldH: THandle;
    frmUTC: TfrmUTConfig;
    Reg: TRegistry;
    x, NK: integer;
    itmX: TListItem;
begin

  OldH := Application.Handle;
  Application.Handle := AHandle;

  frmUTC := TfrmUTConfig.Create(AOwner);
  try

    frmUTC.Caption := 'A.Cordero''s UT Package Driver - '+DLNGStr('DUT100');
    frmUTC.lstGames.Columns.Items[0].Caption := DLNGStr('DUT110');
    frmUTC.lstGames.Columns.Items[1].Caption := DLNGStr('DUT111');
    frmUTC.lstGames.Columns.Items[2].Caption := DLNGStr('DUT112');
    frmUTC.lstGames.Columns.Items[3].Caption := DLNGStr('DUT113');
    frmUTC.lstGames.Columns.Items[4].Caption := DLNGStr('DUT114');
    frmUTC.butOK.Caption := DLNGStr('BUTOK');
    frmUTC.butRemove.Caption := DLNGStr('BUTREM');
    frmUTC.butEdit.Caption := DLNGStr('BUTEDT');
    frmUTC.lblVersion.Caption :=  'v'+getVersion(DRIVER_VERSION)+' - '+DLNGStr('DUT101')+' v'+TUTP_VERSION;
    frmUTC.translationDUT201 := DLNGStr('DUT201');
    frmUTC.translationDUT202 := DLNGStr('DUT202');
    frmUTC.translationDUT203 := DLNGStr('DUT203');

    Reg := TRegistry.Create;
    Try
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d',True) then
      begin
        if Reg.ValueExists('CurrentID') then
        begin
          NK := Reg.ReadInteger('CurrentID');

          Reg.CloseKey;

          for x := 1 to NK do
          begin
            if Reg.OpenKeyReadOnly('\Software\Dragon Software\Dragon UnPACKer 5\Plugins\drv_ut.d5d\'+inttohex(x,8)) then
            begin
              if Reg.ValueExists('Directory') then
              begin
                itmX := frmUTC.lstGames.Items.Add;
                itmX.Caption := IntTostr(x);
                itmX.SubItems.Add(Reg.ReadString('Directory'));
                itmX.SubItems.Add(UTPackage_GameHintStrings[getGameHint(x)]);
                itmX.SubItems.Add(BoolToStr(getGHDontAsk(x),false));
                itmX.SubItems.Add(inttostr(getGameHintV(x)));
                Reg.CloseKey;
              end;
            end;
          end;
        end;
      end;
    Finally
      Reg.Free;
    end;

    frmUTC.ShowModal;
  finally
    frmUTC.free;
  end;

  Application.Handle := OldH;

end;

procedure InitPlugin(per: TPercentCallback; lngid: TLanguageCallback; DUP5Path: ShortString; AppHandle: THandle; AppOwner: TComponent); stdcall;
begin

  SetPercent := per;
  DLNGStr := lngid;
  CurPath := DUP5Path;
  AHandle := AppHandle;
  AOwner := AppOwner;

end;

exports
  DUDIVersion,
  ReadFormat,
  CloseFormat,
  GetEntry,
  GetDriverInfo,
  GetCurrentDriverInfo,
  GetNumVersion,
  ExtractFile,
  ExtractFileToStream,
  GetErrorInfo,
  AboutBox,
  ConfigBox,
  IsFormat,
  InitPlugin;

begin

RegisterAllClasses;
package := TUTPackage.Create;

end.

