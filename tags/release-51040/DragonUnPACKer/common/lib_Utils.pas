unit lib_Utils;

// $Id: lib_Utils.pas,v 1.3 2004-07-15 16:38:42 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/common/lib_Utils.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is lib_Utils.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// Most Common Tools library
// =============================================================================
//
//  Functions:
//  function BoolToStr(B: Boolean) : string;
//  function CheckOS(): boolean;
//  function CheckRegistryHR(prefix: string; ID: integer): Boolean;
//  function CheckRegistryType(ext: string): Boolean;
//  function DescFromExt(ext: string): string;
//  function Get0(src: integer): string;
//  function Get8(src: integer): string;
//  function Get8u(src: integer): string;
//  function Get8v(src: integer; size: byte): string;
//  function Get16v(src: integer; size: word): string;
//  function Get32(src: integer): string;
//  function GetAllSystemInfo(): TOSInfo;
//  function getOS(): integer;
//  function IconFromExt(ext: string): integer;
//  function PadRight(Data: string; PadWidth: integer) : string;
//  function posrev(substr: string; str: string): integer;
//  procedure put8(src: integer; val: string);
//  function revstr(str: string): string;
//  procedure SetRegistryDUP5();
//  procedure SetRegistryDUPPI();
//  procedure SetRegistryHR(prefix: string; ID: integer; value: boolean);
//  procedure SetRegistryType(ext: string);
//  function splitStr(Chaine: string; Casseur: string): TStringList;
//  function strip0(str : string): string;
//  procedure UnSetRegistryType(ext: string);
//
// -----------------------------------------------------------------------------

interface

uses classes, StrUtils;

type TOSInfo = record
    WinVersion: string;
    MemTotal: int64;
    MemAvailable: int64;
  end;

function BoolToStr(B: Boolean) : string;
function splitStr(Chaine: string; Casseur: string): TStringList;
function DescFromExt(ext: string): string;
function IconFromExt(ext: string): integer;
function CheckOS(): boolean;
function getOS(): integer;
function PadRight(Data: string; PadWidth: integer) : string;
procedure SetRegistryDUP5();
procedure SetRegistryDUPPI();
procedure SetRegistryType(ext: string);
procedure UnSetRegistryType(ext: string);
function CheckRegistryType(ext: string): Boolean;
function CheckRegistryHR(prefix: string; ID: integer): Boolean;
procedure SetRegistryHR(prefix: string; ID: integer; value: boolean);
function GetAllSystemInfo(): TOSInfo;

implementation

uses SysUtils, lib_language, Windows, registry, forms, lib_BinUtils;

function PadRight(Data: string; PadWidth: integer) : string;
begin
   result := data;
   while length(result) < PadWidth do
      result := result + ' ';
end;

function splitStr(Chaine: string; Casseur: string): TStringList;
var Start: integer;
    LeftString: string;
    TempString: string;
begin

  result := TStringList.Create();

  TempString := Chaine; //used to check if the last char from
                        // "Chaine" is the LineBreaker
  Delete(TempString,1,length(TempString)-1); // keep the last Char
  if TempString <> Casseur then
    Chaine := Chaine + Casseur;

  // if the last char is not "Casseur" then put it at the end
  repeat
    Start := Pos(Casseur,Chaine); // find the "casseur"
    LeftString := Chaine; // Create tempory handler
    Delete(LeftString,Start,Length(LeftString));// keep the LeftToken
    Delete(Chaine,1,Start); // keep the rest of "Chaine"
    Result.Add (LeftString);// Add the new Parse to "Retour"
  until Pos(Casseur,Chaine) = 0; // Reapet until end

end;

function BoolToStr(B: Boolean) : string;
begin
   case b of
      true: result := 'True';
      false: result := 'False';
   end;
end;

function CheckOS(): boolean;
var
   verinfo: TOSVersionInfo;
begin
   verinfo.dwOSVersionInfoSize := sizeof(TOSVersionInfo) ;
   GetVersionEX(verinfo) ;

   case verinfo.dwPlatformId of
      VER_PLATFORM_WIN32s:
         CheckOS := false;
      VER_PLATFORM_WIN32_WINDOWS:
         begin
            if ((verinfo.dwMajorVersion > 4) or
               ((verinfo.dwMajorVersion = 4) and (verinfo.dwMinorVersion >= 10) ) ) then
              CheckOS := false
            else
              CheckOS := false;
         end;
      VER_PLATFORM_WIN32_NT:
         begin
            if (verinfo.dwMajorVersion = 3) then
              CheckOS := false
            else if (verinfo.dwMajorVersion = 4) then
              CheckOS := false
            else if (verinfo.dwMajorVersion = 5) then
              CheckOS := true
            else
              CheckOS := false;
        end;
   else
     CheckOS := false;
   end;
end;

function getOS(): integer;
var
   verinfo: TOSVersionInfo;
begin
   verinfo.dwOSVersionInfoSize := sizeof(TOSVersionInfo) ;
   GetVersionEX(verinfo) ;

   result := 95;

   case verinfo.dwPlatformId of
      VER_PLATFORM_WIN32s:
         result := 32;
      VER_PLATFORM_WIN32_WINDOWS:
         begin
          If verinfo.dwMajorVersion = 4 Then
          begin
            If verinfo.dwMinorVersion = 0 Then
              result := 95
            else if verinfo.dwMinorVersion < 90 then
              result := 98
            else
              result := 99;
          end
         end;
      VER_PLATFORM_WIN32_NT:
         begin
            if (verinfo.dwMajorVersion <= 4) then
              result := 95
            else
              If verinfo.dwMinorVersion = 0 Then
                result := 2000
              else if verinfo.dwMinorVersion = 1 then
                result := 2002
              else
                result := 2002;
        end;
   else
     result := 95;
   end;
end;

function DescFromExt(ext: string): string;
begin

  ext := AnsiUpperCase(ext);

  if (ext = 'ANI') or (ext = 'ANM') then
    DescFromExt := ReplaceValue('%e',DLNGStr('EXANIM'),ext)
  else if (ext = 'ART') then
    DescFromExt := DLNGStr('EXART')
  else if (ext = 'BIN') or (ext = 'DAT') then
    DescFromExt := ReplaceValue('%e',DLNGStr('EXBIN'),ext)
  else if (ext = 'BMP') then
    DescFromExt := ReplaceValue('%d',ReplaceValue('%e',DLNGStr('EXIMG'),ext),'Windows BitMaP')
  else if (ext = 'BSP') or (ext = 'MAP') then
    DescFromExt := ReplaceValue('%e',DLNGStr('EXMAP'),ext)
  else if (ext = 'CFG') or (ext = 'LST') or (ext = 'DEF') then
    DescFromExt := ReplaceValue('%e',DLNGStr('EXCFG'),ext)
  else if (ext = 'CON') then
    DescFromExt := ReplaceValue('%e',DLNGStr('EXSCRP'),ext)
  else if (ext = 'DLL') or (ext = 'LTO') then
    DescFromExt := DLNGStr('EXDLL')
  else if (ext = 'FIRE') then
    DescFromExt := DLNGStr('EXFIRE')
  else if (ext = 'IT') then
    DescFromExt := ReplaceValue('%d',DLNGStr('EXMUS'),'Impulse Tracker')
  else if (ext = 'JPG') or (ext = 'JPEG') then
    DescFromExt := ReplaceValue('%d',ReplaceValue('%e',DLNGStr('EXIMG'),ext),'JPEG')
  else if (ext = 'LMP') or (ext = 'DTX') then
    DescFromExt := ReplaceValue('%e',DLNGStr('EXTEX'),ext)
  else if (ext = 'MID') then
    DescFromExt := ReplaceValue('%d',DLNGStr('EXMUS'),'MIDI')
  else if (ext = 'MOD') then
    DescFromExt := ReplaceValue('%d',DLNGStr('EXMUS'),'Module')
  else if (ext = 'MPG') then
    DescFromExt := DLNGStr('EXMPEG')
  else if (ext = 'MDL') or (ext = 'SKL') or (ext = 'ABC') then
    DescFromExt := ReplaceValue('%e',DLNGStr('EXMDL'),ext)
  else if (ext = 'PAL') then
    DescFromExt := DLNGStr('EXPAL')
  else if (ext = 'PCX') then
    DescFromExt := ReplaceValue('%d',ReplaceValue('%e',DLNGStr('EXIMG'),ext),'Paintbrush PCX')
  else if (ext = 'S3M') then
    DescFromExt := ReplaceValue('%d',DLNGStr('EXMUS'),'Scream Tracker')
  else if (ext = 'SCC') then
    DescFromExt := ReplaceValue('%e',DLNGStr('EXBIN'),'Visual SourceSafe')
  else if (ext = 'SPR') then
    DescFromExt := DLNGStr('EXSPR')
  else if (ext = 'TGA') then
    DescFromExt := ReplaceValue('%d',ReplaceValue('%e',DLNGStr('EXIMG'),ext),'Targa')
  else if (ext = 'TXT') then
    DescFromExt := DLNGStr('EXTXT')
  else if (ext = 'VOC') then
    DescFromExt := ReplaceValue('%d',DLNGStr('EXSND'),'Creative Voice')
  else if (ext = 'WAV') then
    DescFromExt := ReplaceValue('%d',DLNGStr('EXSND'),'RIFF/WAVE')
  else if (ext = 'XM') then
    DescFromExt := ReplaceValue('%d',DLNGStr('EXMUS'),'Extended Module')
  else
    DescFromExt := ReplaceValue('%e',DLNGStr('EX'),ext);


end;

function IconFromExt(ext: string): integer;
begin

  ext := AnsiUpperCase(ext);
  if (ext = 'WAV') or (ext = 'VOC') or (ext = 'MP3') or (ext = 'MPG') then
    IconFromExt := 1
  else if ext = 'BMP' then
    IconFromExt := 2
  else if ext = 'TGA' then
    IconFromExt := 3
  else if (ext = 'LMP') or (ext = 'ART') or (ext = 'FIRE') or (ext = 'DTX') then
    IconFromExt := 4
  else if ext = 'TXT' then
    IconFromExt := 5
  else if (ext = 'CFG') or (ext = 'LST') or (ext = 'CON') or (ext = 'DEF') then
    IconFromExt := 6
  else if (ext = 'MDL') or (ext = 'SKL') or (ext = 'ABC') then
    IconFromExt := 7
  else if ext = 'SPR' then
    IconFromExt := 8
  else if (ext = 'BSP') or (ext = 'MAP') then
    IconFromExt := 9
  else if (ext = 'ANM') or (ext = 'ANI') or (ext = 'MOV') or (ext = 'AVI') or (ext = 'BIK') or (ext = 'SMK') then
    IconFromExt := 10
  else if (ext = 'MID') or (ext = 'RMI') or (ext = 'MUS') or (ext = 'MOD') or (ext = 'IT') or (ext = 'S3M') or (ext = 'XM') then
    IconFromExt := 11
  else if (ext = 'BIN') or (ext = 'DAT') or (ext = 'PAL') or (ext = 'SCC') or (ext = 'DLL') or (ext = 'LTO') then
    IconFromExt := 12
  else if ext = 'PCX' then
    IconFromExt := 13
  else if (ext = 'JPG') or (ext = 'JPEG') then
    IconFromExt := 14
  else
    IconFromExt := 0;

end;

procedure SetRegistryDUP5();
var reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    if Not(Reg.KeyExists('DUP5.Files\DefaultIcon')) then
      Reg.CreateKey('DUP5.Files\DefaultIcon');
    if Not(Reg.KeyExists('DUP5.Files\shell\open\command')) then
      Reg.CreateKey('DUP5.Files\shell\open\command');
    if Reg.OpenKey('DUP5.Files\DefaultIcon',True) then
    begin
      Reg.WriteString('',chr(34)+Application.ExeName+chr(34)+',1');
      Reg.CloseKey;
    end;
    if Reg.OpenKey('DUP5.Files',True) then
    begin
      Reg.WriteString('','Dragon UnPACKer 5 Archive');
      Reg.CloseKey;
    end;
    if Reg.OpenKey('DUP5.Files\shell',True) then
    begin
      Reg.WriteString('','open');
      Reg.CloseKey;
    end;
    if Reg.OpenKey('DUP5.Files\shell\open\command',True) then
    begin
      Reg.WriteString('','"'+Application.ExeName+'" "%1"');
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure SetRegistryDUPPI();
var reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    if Not(Reg.KeyExists('DUP5.Packages\DefaultIcon')) then
      Reg.CreateKey('DUP5.Packages\DefaultIcon');
    if Not(Reg.KeyExists('DUP5.Packages\shell\open\command')) then
      Reg.CreateKey('DUP5.Packages\shell\open\command');
    if Reg.OpenKey('DUP5.Packages\DefaultIcon',True) then
    begin
      Reg.WriteString('',chr(34)+ExtractFilePath(Application.ExeName)+'utils\duppi.exe'+chr(34)+',0');
      Reg.CloseKey;
    end;
    if Reg.OpenKey('DUP5.Packages',True) then
    begin
      Reg.WriteString('','Dragon UnPACKer 5 Package');
      Reg.CloseKey;
    end;
    if Reg.OpenKey('DUP5.Packages\shell',True) then
    begin
      Reg.WriteString('','open');
      Reg.CloseKey;
    end;
    if Reg.OpenKey('DUP5.Packages\shell\open\command',True) then
    begin
      Reg.WriteString('','"'+ExtractFilePath(Application.ExeName)+'utils\duppi.exe" "%1"');
      Reg.CloseKey;
    end;
    if Not(Reg.KeyExists('.d5p')) then
      Reg.CreateKey('.d5p');
    if Reg.OpenKey('.d5p',True) then
    begin
      if Reg.ValueExists('') then
        if (Reg.ReadString('') <> 'DUP5.Packages') then
          Reg.WriteString('DUP5.Backup',Reg.ReadString(''));
      Reg.WriteString('','DUP5.Packages');
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure SetRegistryType(ext: string);
var reg: TRegistry;
begin

  ext := lowercase(ext);

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    if Not(Reg.KeyExists('.'+ext)) then
      Reg.CreateKey('.'+ext);
    if Reg.OpenKey('.'+ext,True) then
    begin
      if Reg.ValueExists('') then
        if (Reg.ReadString('') <> 'DUP5.Files') then
          Reg.WriteString('DUP5.Backup',Reg.ReadString(''));
      Reg.WriteString('','DUP5.Files');
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

procedure UnSetRegistryType(ext: string);
var reg: TRegistry;
begin

  ext := lowercase(ext);

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    if Not(Reg.KeyExists('.'+ext)) then
      Reg.CreateKey('.'+ext);
    if Reg.OpenKey('.'+ext,True) then
    begin
      if Reg.ValueExists('DUP5.Backup') then
      begin
        Reg.WriteString('',Reg.ReadString('DUP5.Backup'));
        Reg.DeleteValue('DUP5.Backup');
      end
      else
        Reg.DeleteValue('');
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

function CheckRegistryType(ext: string): Boolean;
var reg: TRegistry;
    res: boolean;
begin

  ext := lowercase(ext);
  res := false;

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    if Not(Reg.KeyExists('.'+ext)) then
      Reg.CreateKey('.'+ext);
    if Reg.OpenKey('.'+ext,True) then
    begin
      if Reg.ValueExists('') then
        res := (Reg.ReadString('') = 'DUP5.Files')
      else
        res := False;
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  CheckRegistryType := res;

end;

function CheckRegistryHR(prefix: string; ID: integer): Boolean;
var reg: TRegistry;
    res: boolean;
    IDstr: string;
begin

  IDstr := lowercase(prefix) + '_'+inttohex(ID,8);

  res := false;

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper\Formats')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper\Formats');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper\Formats',True) then
    begin
      if Reg.ValueExists(IDstr) then
        res := Reg.ReadBool(IDstr)
      else
        res := False;
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

  result := res;

end;

procedure SetRegistryHR(prefix: string; ID: integer; value: boolean);
var reg: TRegistry;
    IDstr: string;
begin

  IDstr := lowercase(prefix) + '_'+inttohex(ID,8);

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper\Formats')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper\Formats');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper\Formats',True) then
    begin
      Reg.WriteBool(IDstr,value);
      Reg.CloseKey;
    end;
  Finally
    Reg.Free;
  end;

end;

function GetAllSystemInfo(): TOSInfo;
var OS: TOSVersionInfo;
//    SI: TSystemInfo;
    MS: TMemoryStatus;
begin

    // get win plattform & version
    OS.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
    if GetVersionEx(OS) then
    begin
      case OS.dwPlatformId of
        VER_PLATFORM_WIN32s: result.WinVersion := 'Win32s on Windows ';
        VER_PLATFORM_WIN32_WINDOWS: begin
          If OS.dwMajorVersion = 4 Then
          begin
            If OS.dwMinorVersion = 0 Then
              result.WinVersion := 'Windows 95 v'
            else if OS.dwMinorVersion < 90 then
              result.WinVersion := 'Windows 98 v'
            else
              result.WinVersion := 'Windows ME v';
          end
          else
            result.WinVersion := 'Windows v';
          result.WinVersion := result.WinVersion+inttostr(OS.dwMajorVersion)+'.'+inttostr(OS.dwMinorVersion)+' build '+inttostr(OS.dwBuildNumber and $FFFF)+' '+OS.szCSDVersion;
        end;
        VER_PLATFORM_WIN32_NT: begin
          If OS.dwMajorVersion = 5 Then
          begin
            If OS.dwMinorVersion = 0 Then
              result.WinVersion := 'Windows 2000 v'
            else if OS.dwMinorVersion = 1 then
              result.WinVersion := 'Windows XP v'
            else
              result.WinVersion := 'Windows NT v';
          end
          else
            result.WinVersion := 'Windows NT v';
          result.WinVersion := result.WinVersion+inttostr(OS.dwMajorVersion)+'.'+inttostr(OS.dwMinorVersion)+' build '+inttostr(OS.dwBuildNumber and $FFFF)+' '+OS.szCSDVersion;
        end;
      else
        result.WinVersion := 'Unknown v'+inttostr(OS.dwMajorVersion)+'.'+inttostr(OS.dwMinorVersion)+' build '+inttostr(OS.dwBuildNumber and $FFFF)+' '+OS.szCSDVersion;
      end;
    end; // with OS

    MS.dwLength := SizeOf(TMemoryStatus);
    GlobalMemoryStatus(MS);
    Result.MemTotal := MS.dwTotalPhys;
    Result.MemAvailable := MS.dwAvailPhys;

end; {.GetAllSystemInfo}

end.
