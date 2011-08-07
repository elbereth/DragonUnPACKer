unit BrowseForFolderU;

// Brian Cryer code (with help of Martin Birk)
// Found on http://www.cryer.co.uk/brian/delphi/howto_browseforfolder.htm

interface

function BrowseForFolder(const browseTitle: String;
  const initialFolder: String = '';
  mayCreateNewFolder: Boolean = False): String;

implementation

uses
  Windows, Forms, shlobj;

var
  lg_StartFolder: String;

// With later versions of Delphi you may not need these constants.
const
  BIF_NEWDIALOGSTYLE=$40;
  BIF_NONEWFOLDERBUTTON=$200;

////////////////////////////////////////////////////////////////////////
// Call back function used to set the initial browse directory.
////////////////////////////////////////////////////////////////////////
function BrowseForFolderCallBack(Wnd: HWND; uMsg: UINT; lParam,
lpData: LPARAM): Integer stdcall;
begin
  if uMsg = BFFM_INITIALIZED then
    SendMessage(Wnd,BFFM_SETSELECTION, 1, Integer(@lg_StartFolder[1]));
  result := 0;
end;

////////////////////////////////////////////////////////////////////////
// This function allows the user to browse for a folder
//
// Arguments:-
//         browseTitle : The title to display on the browse dialog.
//       initialFolder : Optional argument. Use to specify the folder
//                       initially selected when the dialog opens.
//  mayCreateNewFolder : Flag indicating whether the user can create a
//                       new folder.
//
// Returns: The empty string if no folder was selected (i.e. if the user
//          clicked cancel), otherwise the full folder path.
////////////////////////////////////////////////////////////////////////
function BrowseForFolder(const browseTitle: String;
  const initialFolder: String ='';
  mayCreateNewFolder: Boolean = False): String;
var
  browse_info: TBrowseInfo;
  folder: array[0..MAX_PATH] of char;
  find_context: PItemIDList;
begin
  //--------------------------
  // Initialise the structure.
  //--------------------------
  FillChar(browse_info,SizeOf(browse_info),#0);
  lg_StartFolder := initialFolder;
  browse_info.pszDisplayName := @folder[0];
  browse_info.lpszTitle := PChar(browseTitle);
  browse_info.ulFlags := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE;
  if not mayCreateNewFolder then
    browse_info.ulFlags := browse_info.ulFlags or BIF_NONEWFOLDERBUTTON;

  browse_info.hwndOwner := Application.Handle;
  if initialFolder <> '' then
    browse_info.lpfn := BrowseForFolderCallBack;
  find_context := SHBrowseForFolder(browse_info);
  if Assigned(find_context) then
  begin
    if SHGetPathFromIDList(find_context,folder) then
      result := folder
    else
      result := '';
    GlobalFreePtr(find_context);
  end
  else
    result := '';
end;

end.