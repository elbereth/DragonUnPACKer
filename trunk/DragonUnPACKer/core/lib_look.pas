unit lib_look;

// $Id: lib_look.pas,v 1.3 2008-04-17 19:14:16 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/lib_look.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is lib_look.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses windows, graphics;

procedure LoadLook(fil: string);
Function GetLargeIconFromFile(FName : String; idx : Word; var Icon : TIcon) : Boolean;
Function GetSmallIconFromFile(FName : String; idx : Word; var Icon : TIcon) : Boolean;
Function GetIconCount(FName : String) : Integer;

implementation

uses main, ShellAPI, spec_DULK, classes,sysutils,forms,dialogs;

procedure LoadLook(fil: string);
var Icn, IcnMask: TBitmap;
    Stm: TMemoryStream;
    Buffer: PChar;
    Hin,x,imgt,imgl: Integer;
    HDR: DULK_Header;
    ENT: DULK_IndexEntry;
begin

  if FileExists(ExtractFilePath(Application.ExeName)+'Data\'+fil) then
  begin
    Hin := FileOpen(ExtractFilePath(Application.ExeName)+'Data\'+fil,fmOpenRead);
    if Hin > 0 then
    begin
      FileRead(hin,HDR,SizeOf(HDR));
      if (HDR.ID = 'DULK'+#26) and (HDR.Version = DULK_Version) and (HDR.IndexNum = DULK_IndexNum) then
      begin

{        if (HDR.Attribs and 1) = 1 then
          Dup5Main.XPMenu.Active := true
        else
          Dup5Main.XPMenu.Active := false;}

        FileSeek(hin,HDR.IndexOffset,0);

        stm := TMemoryStream.Create;
        icn := TBitmap.Create;
        icnMask := TBitmap.Create;

        for x:=1 to HDR.IndexNum do
        begin
          FileRead(hin,ENT,8);
          if ENT.ID = 'OPEN' then
          begin
            imgt := 0;
            imgl := 0;
          end
          else if ENT.ID = 'CLOS' then
          begin
            imgt := 1;
            imgl := 0;
          end
          else if ENT.ID = 'HRIP' then
          begin
            imgt := 2;
            imgl := 0;
          end
          else if ENT.ID = 'QUIT' then
          begin
            imgt := 3;
            imgl := 0;
          end
          else if ENT.ID = 'MRCH' then
          begin
            imgt := 4;
            imgl := 0;
          end
          else if ENT.ID = 'MOGN' then
          begin
            imgt := 5;
            imgl := 0;
          end
          else if ENT.ID = 'MOPL' then
          begin
            imgt := 6;
            imgl := 0;
          end
          else if ENT.ID = 'MOAS' then
          begin
            imgt := 7;
            imgl := 0;
          end
          else if ENT.ID = 'MOLK' then
          begin
            imgt := 8;
            imgl := 0;
          end
          else if ENT.ID = 'MOPC' then
          begin
            imgt := 9;
            imgl := 0;
          end
          else if ENT.ID = 'MOPD' then
          begin
            imgt := 10;
            imgl := 0;
          end
          else if ENT.ID = 'MOPH' then
          begin
            imgt := 11;
            imgl := 0;
          end
          else if ENT.ID = 'MABT' then
          begin
            imgt := 12;
            imgl := 0;
          end
          else if ENT.ID = 'OPTN' then
          begin
            imgt := 13;
            imgl := 0;
          end
          else if ENT.ID = 'EXTR' then
          begin
            imgt := 14;
            imgl := 0;
          end
          else if ENT.ID = 'MOGA' then
          begin
            imgt := 15;
            imgl := 0;
          end
          else if ENT.ID = 'MOGL' then
          begin
            imgt := 16;
            imgl := 0;
          end
          else if ENT.ID = 'FOPN' then
          begin
            imgt := 0;
            imgl := 1;
          end
          else if ENT.ID = 'FCLO' then
          begin
            imgt := 1;
            imgl := 1;
          end
          else if ENT.ID = 'FROT' then
          begin
            imgt := 2;
            imgl := 1;
          end
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

          else if ENT.ID = 'PIIN' then
          begin
            imgt := 0;
            imgl := 3;
          end
          else if ENT.ID = 'PICA' then
          begin
            imgt := 1;
            imgl := 3;
          end
          else if ENT.ID = 'PIXA' then
          begin
            imgt := 2;
            imgl := 3;
          end
          else if ENT.ID = 'PIXT' then
          begin
            imgt := 3;
            imgl := 3;
          end
          else if ENT.ID = 'PIXD' then
          begin
            imgt := 4;
            imgl := 3;
          end

          else if ENT.ID = 'PCOP' then
          begin
            imgt := 0;
            imgl := 4;
          end
          else if ENT.ID = 'PCSX' then
          begin
            imgt := 1;
            imgl := 4;
          end
          else if ENT.ID = 'PCMX' then
          begin
            imgt := 2;
            imgl := 4;
          end
          else if ENT.ID = 'PCWC' then
          begin
            imgt := 3;
            imgl := 4;
          end


          else
          begin
            imgt := -1;
            imgl := -1;
          end;

          if imgt > -1 then
          begin
            GetMem(Buffer,ENT.Size);
            FileRead(hin,Buffer^,ENT.Size);
            stm.Clear;
            stm.WriteBuffer(Buffer^, ENT.Size);
            stm.Seek(0,soFromBeginning);
            icn.LoadFromStream(stm);
            icn.TransparentMode := tmFixed;
            icn.TransparentColor := $0000FF00;
            icn.Transparent := true;
            stm.Seek(0,soFromBeginning);
            IcnMask.LoadFromStream(stm);
            icnMask.Mask($0000FF00);
            if imgl = 0 then
              dup5Main.imgLook.Replace(imgt,icn,IcnMask)
            else if imgl = 1 then
              dup5Main.imgIndex.Replace(imgt,icn,IcnMask)
            else if imgl = 2 then
              dup5Main.imgContents.Replace(imgt,icn,IcnMask)
            else if imgl = 3 then
              dup5Main.imgPopup1.Replace(imgt,icn,IcnMask)
            else if imgl = 4 then
              dup5Main.imgPopup2.Replace(imgt,icn,IcnMask);
            FreeMem(buffer);
          end
          else
            FileSeek(hin,ENT.Size,1);

        end;

        stm.Free;
        Icn.Free;
        IcnMask.Free;

      end;
      FileClose(Hin);

    end;
  end;

end;

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