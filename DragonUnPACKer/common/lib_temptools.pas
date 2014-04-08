unit lib_temptools;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is lib_temptools.pas.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

function getTemporaryDir(): string;
function getTemporaryFilename(suffix: string = ''; prefix: string = 'dup5tmp'; separator: string = '-'): string;

implementation

uses Registry, Windows, SysUtils, lib_BinUtils;

function getTemporaryDir(): string;
var Reg: TRegistry;
    TempDir: array[0..MAX_PATH] of Char;
    testDir: string;
begin

  GetTempPath(MAX_PATH, @TempDir);
  result := Strip0(TempDir);

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      if Reg.ValueExists('UseAltTempDir') and Reg.ReadBool('UseAltTempDir') and Reg.ValueExists('AltTempDir') then
      begin
        testDir := Reg.ReadString('AltTempDir');
        if DirectoryExists(testDir) then
          result := testDir;
      end;
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

function getTemporaryFilename(suffix: string = ''; prefix: string = 'dup5tmp'; separator: string = '-'): string;
begin

  randomize;
  result := prefix+inttostr(GetTickCount)+separator+IntToStr(Random(99999999));
  if (suffix <> '') then
    result := result + separator + suffix;

end;

end.
 