program DuppiInstall;

// $Id: DuppiInstall.dpr,v 1.1 2008-09-27 16:32:32 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/tools/duppi/DuppiInstall.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
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

var closemsg: string;
    x, waitresult,hwnd: integer;
begin

  // Sanity checks:
  //   4 parameters expected
  //   3rd and 4th are existing files
  //   3rd is duppi.exe
  //   4th is duppi.exe.new
  if (ParamCount = 2) and FileExists(ParamStr(1))
                      and FileExists(ParamStr(2))
                      and SameText(ExtractFilename(ParamStr(1)),'duppi.exe')
                      and SameText(ExtractFilename(ParamStr(2)),'duppi.exe.new') then
  begin

//    ShowMessage('OK 0');

    // Find the Duppi Windows handle
//    hwnd := FindWindow('TfrmInstaller', nil);

//    ShowMessage(inttostr(hwnd)+' '+ParamStr(1));

    // Sanity check 2: Verify the handle is the same than parameter 1
//    if (hwnd = strtoint(ParamStr(1))) then
//    begin

      // Send close message back to Duppi
{      closemsg := ParamStr(2);
      for x:=1 to length(closemsg) do
      begin
        PostMessage(strtoint(ParamStr(1)), wm_User, ord(closemsg[x]), 0);
      end;
      PostMessage(strtoint(ParamStr(1)), wm_User, 0, 0);}

      // Wait until Duppi is closed (if needed)
      //WaitResult := WaitForSingleObject(strtoint(ParamStr(3)),INFINITE);

      for x := 0 to 600 do
      begin
        // Delete old & rename new
        if DeleteFile(ParamStr(1)) then
        begin
          RenameFile(ParamStr(2),ParamStr(1));

          // Execute Duppi to tell the user everything is done
          ShellExecute(0,nil,PChar(ParamStr(1)),PChar('/InstalledOK'),nil,SW_SHOW);

          Break;
        end;
        Sleep(100);
      end;

//    end;

  end;

end.
