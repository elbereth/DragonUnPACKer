program DuppiInstall;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is DuppiInstall.dpr, released September 27, 2008.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

uses
  Windows,
  Messages,
  ShellAPI,
  SysUtils;

//{$R *.res}

function sleepDelete(oldfile, newfile: string): boolean;
var x: integer;
begin

  result := false;

  if (FileExists(newfile)) then
  begin
    for x := 0 to 600 do
    begin
      // Delete old (if exists) & rename new
      if (FileExists(oldfile) and DeleteFile(oldfile)) or not(FileExists(oldfile)) then
      begin
        result := RenameFile(newfile,oldfile);
        Break;
      end;
      Sleep(100);
    end;
  end;

end;

var closemsg,oldname: string;
    sr: TSearchRec;
    FileAttrs: Integer;
    checkDelete: integer;
begin

  // Sanity checks for mode 1 (only Duppi is updated -- Old mode):
  //   2 parameters expected
  //   1st and 2nd are existing files
  //   1st is duppi.exe
  //   2nd is duppi.exe.new
  if (ParamCount = 2) and FileExists(ParamStr(1))
                      and FileExists(ParamStr(2))
                      and SameText(ExtractFilename(ParamStr(1)),'duppi.exe')
                      and SameText(ExtractFilename(ParamStr(2)),'duppi.exe.new') then
  begin

     if sleepDelete(ParamStr(1),ParamStr(2)) then
     begin
       // Execute Duppi to tell the user everything is done
       ShellExecute(0,nil,PChar(ParamStr(1)),PChar('/InstalledOK'),nil,SW_SHOW);
     end;

  end
  // Sanity checks for mode 2 (all .new files in directory are updated):
  //   3 parameters expected
  //   1st & 2nd are "X" "X"
  //   3rd is Duppi's directory (it will check for Duppi.exe in that directory)
  else if (ParamCount = 3) and DirectoryExists(ParamStr(3))
                      and FileExists(ParamStr(3)+'duppi.exe')
                      and (ParamStr(1) = 'X')
                      and (ParamStr(2) = 'X') then
  begin
    FileAttrs := 0;
    checkDelete := 0;
    if FindFirst(ParamStr(3)+'*.new',FileAttrs,sr) = 0 then
    begin
      repeat
        if (sr.Attr and FileAttrs) = FileAttrs then
        begin
          oldname := ChangeFileExt(sr.Name,'');
          if sleepDelete(ParamStr(3)+oldname,ParamStr(3)+sr.Name) then
            inc(checkDelete);
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;

    if checkDelete > 0 then
    begin
      // Execute Duppi to tell the user everything is done
      ShellExecute(0,nil,PChar(ParamStr(3)+'duppi.exe'),PChar('/InstalledOK'),nil,SW_SHOW);
    end;

  end;

end.
