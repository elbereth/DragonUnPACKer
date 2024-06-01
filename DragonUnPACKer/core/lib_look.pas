unit lib_look;

{$MODE Delphi}

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is lib_look.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses windows, graphics;

Function GetLargeIconFromFile(FName : String; idx : Word; var Icon : TIcon) : Boolean;
Function GetSmallIconFromFile(FName : String; idx : Word; var Icon : TIcon) : Boolean;
Function GetIconCount(FName : String) : Integer;

implementation

uses Main, ShellAPI, classes,sysutils,forms,dialogs;

{
            // File types icons
            else if ENT.ID = 'TNON' then
            begin
              imgt := 0;
              imgl := 2;
            end
            else if ENT.ID = 'TWAV' then
            begin
              imgt := 1;
              imgl := 2;
            end
            else if ENT.ID = 'TBMP' then
            begin
              imgt := 2;
              imgl := 2;
            end
            else if ENT.ID = 'TTGA' then
            begin
              imgt := 3;
              imgl := 2;
            end
            else if ENT.ID = 'TTEX' then
            begin
              imgt := 4;
              imgl := 2;
            end
            else if ENT.ID = 'TTXT' then
            begin
              imgt := 5;
              imgl := 2;
            end
            else if ENT.ID = 'TCFG' then
            begin
              imgt := 6;
              imgl := 2;
            end
            else if ENT.ID = 'TM3D' then
            begin
              imgt := 7;
              imgl := 2;
            end
            else if ENT.ID = 'TSPR' then
            begin
              imgt := 8;
              imgl := 2;
            end
            else if ENT.ID = 'TBSP' then
            begin
              imgt := 9;
              imgl := 2;
            end
            else if ENT.ID = 'TANI' then
            begin
              imgt := 10;
              imgl := 2;
            end
            else if ENT.ID = 'TMUS' then
            begin
              imgt := 11;
              imgl := 2;
            end
            else if ENT.ID = 'TBIN' then
            begin
              imgt := 12;
              imgl := 2;
            end
            else if ENT.ID = 'TPCX' then
            begin
              imgt := 13;
              imgl := 2;
            end
            else if ENT.ID = 'TJPG' then
            begin
              imgt := 14;
              imgl := 2;
            end

 }

// Extract the large icon from an exe, dll or ico file.
// FName : String        // the file name
// Idx : Word            // the icon index to retrieve
// Icon : TIcon          // the icon will be placed here on success
// Return value:         // returns true on success, false on failure.
Function GetLargeIconFromFile(FName : String; idx : Word; var Icon : TIcon) : Boolean;
var
  LargeIcon : HICON;
  SmallIcon : HICON;
begin

  ExtractIconEx(PChar(FName), idx, LargeIcon, SmallIcon, 1);

  if LargeIcon <= 1 then
    Result := False
  else
  begin
     Icon.Handle := LargeIcon;
     Result := True
  end;

end;

Function GetSmallIconFromFile(FName : String; idx : Word; var Icon : TIcon) : Boolean;
var
  LargeIcon : Hicon;
  SmallIcon : Hicon;
begin

  ExtractIconEx(PChar(FName), idx, LargeIcon, SmallIcon, 1);

  if SmallIcon <= 1 then
    Result := False
  else
  begin
    Icon.Handle := SmallIcon;
    Result := True
  end;

end;

// returns the number of icons in an exe, dll or ico file.
Function GetIconCount(FName : String) : Integer;
var
  LargeIcon : Hicon;
  SmallIcon : HIcon;
begin

  Result := ExtractIconEx(PChar(FName), -1, LargeIcon, SmallIcon, 0);

end;

end.