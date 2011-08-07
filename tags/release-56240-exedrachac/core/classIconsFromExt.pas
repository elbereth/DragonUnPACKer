unit classIconsFromExt;

// $Id: classIconsFromExt.pas,v 1.5 2009-06-26 21:05:31 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/classIconsFromExt.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is classIconsFromExt.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses SysUtils, lib_language, Windows, registry, ShellApi, forms, Graphics, Controls, Classes, StrUtils, lib_utils;

type
  PHICON = ^HICON;

type
  PIconNum = ^IconNum;
  IconNum = record
    ext: ShortString;
    num: Integer;
  end;

type TIconsFromExt = class
    procedure init(icList: TImageList);
    procedure close;
    function getIcon(ext: TFilename): Integer;
  private
    iconList: TImageList;
    iconNum: TList;
    procedure getAssociatedIcon(FileName: TFilename; PLargeIcon, PSmallIcon: PHICON);
    function findIcon(ext: string): Integer;
    function getExt(fileName: TFilename): string;
    function addIcon(ext: string; icon: TIcon): integer;
    function getInternalIcon(ext: string): integer;
    function useRegIcons(): boolean;
    function getWindowsSystemFolder(): string;
  public

  end;

implementation

function TIconsFromExt.getWindowsSystemFolder(): string;
var
  SysPath: array[0..MAX_PATH + 1] of char;
begin
  GetSystemDirectory(SysPath,MAX_PATH);
  result := SysPath;
end;

procedure TIconsFromExt.GetAssociatedIcon(FileName: TFilename; PLargeIcon, PSmallIcon: PHICON);
// Gets the icons of a given file
var
  IconIndex: word;  // Position of the icon in the file
  FileExt, FileType: string;
  Reg: TRegistry;
  p: integer;
  p1, p2: pchar;
label
  noassoc;
begin
  IconIndex := 0;
  // Get the extension of the file
  FileExt := UpperCase(ExtractFileExt(FileName));
  if ((FileExt <> '.EXE') and (FileExt <> '.ICO')) or
      not FileExists(FileName) then begin
    // If the file is an EXE or ICO and it exists, then
    // we will extract the icon from this file. Otherwise
    // here we will try to find the associated icon in the
    // Windows Registry...
    Reg := nil;
    try
      Reg := TRegistry.Create(KEY_QUERY_VALUE);
      Reg.RootKey := HKEY_CLASSES_ROOT;
      if FileExt = '.EXE' then FileExt := '.COM';
      if Reg.OpenKeyReadOnly(FileExt) then
        try
          FileType := Reg.ReadString('');
        finally
          Reg.CloseKey;
        end;
      if (FileType <> '') and Reg.OpenKeyReadOnly(
          FileType + '\DefaultIcon') then
        try
          FileName := Reg.ReadString('');
        finally
          Reg.CloseKey;
        end;
    finally
      FreeAndNil(Reg);
    end;

    // If we couldn't find the association, we will
    // try to get the default icons
    if FileName = '' then goto noassoc;

    // Get the filename and icon index from the
    // association (of form '"filaname",index')
    p1 := PChar(FileName);
    p2 := StrRScan(p1, ',');
    if p2 <> nil then begin
      p := p2 - p1 + 1; // Position of the comma
      IconIndex := StrToInt(Copy(FileName, p + 1,
        Length(FileName) - p));
      SetLength(FileName, p - 1);
    end;
  end;
  // Attempt to get the icon
  if ExtractIconEx(pchar(FileName), IconIndex,
      PLargeIcon^, PSmallIcon^, 1) <> 1 then
  begin
noassoc:
    // The operation failed or the file had no associated
    // icon. Try to get the default icons from SHELL32.DLL

    try // to get the location of SHELL32.DLL
      FileName := IncludeTrailingPathDelimiter(GetWindowsSystemFolder)
        + 'SHELL32.DLL';
    except
      FileName := 'C:\WINDOWS\SYSTEM\SHELL32.DLL';
    end;

    case getOs of
      95: begin
            // Determine the default icon for the file extension
            if      (FileExt = '.DOC') then IconIndex := 1
            else if (FileExt = '.EXE')
                 or (FileExt = '.COM') then IconIndex := 2
            else if (FileExt = '.HLP') then IconIndex := 23
            else if (FileExt = '.INI')
                 or (FileExt = '.INF') then IconIndex := 58
            else if (FileExt = '.TXT') then IconIndex := 59
            else if (FileExt = '.BAT') then IconIndex := 60
            else if (FileExt = '.DLL')
                 or (FileExt = '.SYS')
                 or (FileExt = '.VBX')
                 or (FileExt = '.OCX')
                 or (FileExt = '.VXD') then IconIndex := 61
            else if (FileExt = '.FON') then IconIndex := 62
            else if (FileExt = '.TTF') then IconIndex := 63
            else if (FileExt = '.FOT') then IconIndex := 62
            else IconIndex := 0;
          end;
      98: begin
            // Determine the default icon for the file extension
            if      (FileExt = '.DOC') then IconIndex := 1
            else if (FileExt = '.EXE')
                 or (FileExt = '.COM') then IconIndex := 2
            else if (FileExt = '.HLP') then IconIndex := 23
            else if (FileExt = '.INI')
                 or (FileExt = '.INF') then IconIndex := 63
            else if (FileExt = '.TXT') then IconIndex := 64
            else if (FileExt = '.BAT') then IconIndex := 65
            else if (FileExt = '.DLL')
                 or (FileExt = '.SYS')
                 or (FileExt = '.VBX')
                 or (FileExt = '.OCX')
                 or (FileExt = '.VXD') then IconIndex := 66
            else if (FileExt = '.FON') then IconIndex := 67
            else if (FileExt = '.TTF') then IconIndex := 68
            else if (FileExt = '.FOT') then IconIndex := 69
            else IconIndex := 0;
          end;
      99: begin
            // Determine the default icon for the file extension
            if      (FileExt = '.DOC') then IconIndex := 1
            else if (FileExt = '.EXE')
                 or (FileExt = '.COM') then IconIndex := 2
            else if (FileExt = '.HLP') then IconIndex := 23
            else if (FileExt = '.INI')
                 or (FileExt = '.INF') then IconIndex := 66
            else if (FileExt = '.TXT') then IconIndex := 67
            else if (FileExt = '.BAT') then IconIndex := 68
            else if (FileExt = '.DLL')
                 or (FileExt = '.SYS')
                 or (FileExt = '.VBX')
                 or (FileExt = '.OCX')
                 or (FileExt = '.VXD') then IconIndex := 69
            else if (FileExt = '.FON') then IconIndex := 70
            else if (FileExt = '.TTF') then IconIndex := 71
            else if (FileExt = '.FOT') then IconIndex := 72
            else IconIndex := 0;
          end;
2000,2002: begin
            // Determine the default icon for the file extension
            if      (FileExt = '.DOC') then IconIndex := 1
            else if (FileExt = '.EXE')
                 or (FileExt = '.COM') then IconIndex := 2
            else if (FileExt = '.HLP') then IconIndex := 23
            else if (FileExt = '.INI')
                 or (FileExt = '.INF') then IconIndex := 69
            else if (FileExt = '.TXT') then IconIndex := 70
            else if (FileExt = '.BAT') then IconIndex := 71
            else if (FileExt = '.DLL')
                 or (FileExt = '.SYS')
                 or (FileExt = '.VBX')
                 or (FileExt = '.OCX')
                 or (FileExt = '.VXD') then IconIndex := 72
            else if (FileExt = '.FON') then IconIndex := 73
            else if (FileExt = '.TTF') then IconIndex := 74
            else if (FileExt = '.FOT') then IconIndex := 75
            else IconIndex := 0;
          end;
       else
         IconIndex := 0;
    end;

    // Attempt to get the icon.
    if (IconIndex = 0) or (ExtractIconEx(pchar(FileName), IconIndex,
        PLargeIcon^, PSmallIcon^, 1) <> 1) then
    begin
      // Failed to get the icon. Just "return" zeroes.
      if PLargeIcon <> nil then PLargeIcon^ := 0;
      if PSmallIcon <> nil then PSmallIcon^ := 0;
    end;
  end;
end;

procedure TIconsFromExt.init(icList: TImageList);
begin

  iconList := icList;
  iconNum := TList.Create;

  // TODO: Load Cache file

end;

procedure TIconsFromExt.close;
var x: integer;
    tmpIcon: PIconNum;
begin

  // TODO: Save Cache file

  for x := 0 to (iconNum.Count-1) do
  begin
    tmpIcon := iconNum.Items[x];
    Dispose(tmpIcon);
  end;

  FreeAndNil(iconNum);
  iconList.Clear;

end;

function TIconsFromExt.getIcon(ext: TFilename): Integer;
var sicon: HICON;
    tmpIcon: TIcon;
    idxIcon: integer;
begin

//  idxIcon := getInternalIcon(ext);

  if not(useRegIcons) then
  begin
    idxIcon := getInternalIcon(ext);
  end
  else
  begin
    idxIcon := findIcon(ext);

    if idxIcon = -1 then
    begin
      getAssociatedIcon(ext,nil,@sicon);
      if sIcon <> 0 then
      begin
        tmpIcon := TIcon.Create;
        tmpIcon.Handle := sIcon;
        idxIcon := addIcon(ext,tmpIcon);
      end
      else
        idxIcon := -1;

      if idxIcon < 0 then
        idxIcon := getInternalIcon(ext);
    end;
  end;

  result := idxIcon;

end;

function TIconsFromExt.findIcon(ext: string): Integer;
var x: integer;
    IconRec: PIconNum;
begin

  ext := getExt(ext);
  result := -1;

  for x := 0 to (iconNum.Count -1) do
  begin
    IconRec := iconNum.Items[x];
    if IconRec^.ext = ext then
    begin
      result := IconRec^.num;
      break;
    end;
  end;

end;

function TIconsFromExt.getExt(fileName: TFilename): string;
var ext: string;
begin

  ext := uppercase(extractfileext(fileName));
  if LeftStr(ext,1) = '.' then
    ext := RightStr(ext,length(ext)-1);

  result := ext;

end;

function TIconsFromExt.addIcon(ext: string; icon: TIcon): integer;
var IconRec: PIconNum;
begin

  New(IconRec);
  IconRec^.ext := getExt(ext);
  IconRec^.num := iconList.AddIcon(icon);
  if IconRec^.num > 0 then
  begin
    iconNum.Add(IconRec);
    result := IconRec^.num;
  end
  else
  begin
    Dispose(IconRec);
    result := -1;
  end;

end;

function TIconsFromExt.getInternalIcon(ext: string): integer;
begin

  ext := extractfileext(ext);

  if (leftstr(ext,1) = '.') then
    ext := rightstr(ext, length(ext)-1);

  ext := AnsiUpperCase(ext);
  if (ext = 'WAV') or (ext = 'VOC') or (ext = 'MP3') or (ext = 'MPG') then
    result := 1
  else if ext = 'BMP' then
    result := 2
  else if ext = 'TGA' then
    result := 3
  else if (ext = 'LMP') or (ext = 'ART') or (ext = 'FIRE') or (ext = 'DTX') then
    result := 4
  else if ext = 'TXT' then
    result := 5
  else if (ext = 'CFG') or (ext = 'LST') or (ext = 'CON') or (ext = 'DEF') then
    result := 6
  else if (ext = 'MDL') or (ext = 'SKL') or (ext = 'ABC') then
    result := 7
  else if ext = 'SPR' then
    result := 8
  else if (ext = 'BSP') or (ext = 'MAP') then
    result := 9
  else if (ext = 'ANM') or (ext = 'ANI') or (ext = 'MOV') or (ext = 'AVI') or (ext = 'BIK') or (ext = 'SMK') then
    result := 10
  else if (ext = 'MID') or (ext = 'RMI') or (ext = 'MUS') or (ext = 'MOD') or (ext = 'IT') or (ext = 'S3M') or (ext = 'XM') then
    result := 11
  else if (ext = 'BIN') or (ext = 'DAT') or (ext = 'PAL') or (ext = 'SCC') or (ext = 'DLL') or (ext = 'LTO') then
    result := 12
  else if ext = 'PCX' then
    result := 13
  else if (ext = 'JPG') or (ext = 'JPEG') then
    result := 14
  else
    result := 0;

end;

function TIconsFromExt.useRegIcons: boolean;
var Reg: TRegistry;
begin

  result := true;

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\StartUp',True) then
    begin
      if Reg.ValueExists('RegistryIcons') then
        result := Reg.ReadBool('RegistryIcons');
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

end.
