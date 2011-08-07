unit WindowsEx;

// $Id: WindowsEx.pas,v 1.1.1.1 2004-05-08 10:26:53 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/drivers/11th/WindowsEx.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is WindowsEx.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//


interface

uses Windows;

CONST 
   OFN_LONGNAMES = $00200000; 

TYPE 
  W32TOpenFileName = packed record 
    lStructSize:        LongInt; 
    hwndOwner:          LongInt; 
    hInstance:          LongInt; 
    lpstrFilter:        PChar; 
    lpstrCustomFilter:  PChar; 
    nMaxCustFilter:     LongInt; 
    nFilterIndex:       LongInt; 
    lpstrFile:          PChar; 
    nMaxFile:           LongInt; 
    lpstrFileTitle:     PChar; 
    nMaxFileTitle:      LongInt; 
    lpstrInitialDir:    PChar; 
    lpstrTitle:         PChar; 
    Flags:              LongInt; 
    nFileOffset:        Word; 
    nFileExtension:     Word; 
    lpstrDefExt:        PChar; 
    lCustData:          LongInt; 
    lpfnHook:           function(Wnd: LongInt; Msg: LongInt; WP: LongInt; LP: LongInt): 
Longint; 
    lpTemplateName:     PChar; 
  end;


const
  comdlg32  = 'comdlg32.dll';

function GetOpenFileName(OpenFile: Pointer): integer; external comdlg32 name 'GetOpenFileNameA';

implementation

end.
