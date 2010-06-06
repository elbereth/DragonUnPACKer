// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

// ----------------------------------------------------------------------------
// Purpose
// ----------------------------------------------------------------------------
// Main windows of Dragon UnPACKer GUI.
// ----------------------------------------------------------------------------

unit Main;

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ComCtrls, ExtCtrls, VirtualTrees, logtreeview, SharedLogger, SharedPlugins;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    imgMenu: TImageList;
    LogView: TLogTreeView;
    menuMain_Tools_Find: TMenuItem;
    menuMain_Options_Basic: TMenuItem;
    menuMain_Options_Plugins: TMenuItem;
    menuMain_Options_FileAssociation: TMenuItem;
    menuMain_Options_Themes: TMenuItem;
    menuMain_Options_Preview: TMenuItem;
    menuMain_Options_Basic_Basic: TMenuItem;
    menuMain_Options_Plugins_Convert: TMenuItem;
    menuMain_Options_Plugins_Drivers: TMenuItem;
    menuMain_Options_Basic_Advanced: TMenuItem;
    menuMain_Options_Basic_Log: TMenuItem;
    menuMain_Tools_Separator1: TMenuItem;
    menuMain_Options: TMenuItem;
    menuMain_Tools: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    menuMain_Tools_List: TMenuItem;
    menuMain: TMainMenu;
    menuMain_File: TMenuItem;
    menuMain_File_Open: TMenuItem;
    menuMain_File_Close: TMenuItem;
    menuMain_File_Separator1: TMenuItem;
    menuMain_File_OpenRecent: TMenuItem;
    menuMain_File_Separator2: TMenuItem;
    menuMain_File_HyperRipper: TMenuItem;
    menuMain_File_Separator3: TMenuItem;
    menuMain_File_Quit: TMenuItem;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    StatusBar: TStatusBar;
    lstIndex: TVirtualStringTree;
    lstView: TVirtualStringTree;
    ToolBar1: TToolBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure loadTheme(theme: string = 'default');
    procedure loadThemeImage(theme, id: string; index: integer);
    function getBaseDir(): string;
    procedure LogViewAdvancedCustomDraw(Sender: TCustomTreeView;
      const ARect: TRect; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure LogViewAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure LogViewCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure menuMain_File_QuitClick(Sender: TObject);
  private
    baseDir: string;
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

// Retrieve the base directory of Dragon UnPACKer
function TfrmMain.getBaseDir(): string;
begin

  // If baseDir is not retrieved yet, we do it:
  // Extract the path from the Application Executable Name
  if (baseDir = '') then
    baseDir := extractFilePath(ParamStr(0));

  // Return the baseDir value
  result := baseDir;

end;

procedure TfrmMain.LogViewAdvancedCustomDraw(Sender: TCustomTreeView;
  const ARect: TRect; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
begin

end;

procedure TfrmMain.LogViewAdvancedCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
  var PaintImages, DefaultDraw: Boolean);
begin

end;

procedure TfrmMain.LogViewCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin

end;

procedure TfrmMain.menuMain_File_QuitClick(Sender: TObject);
begin

  // Close the application
  if MessageDlg('Exit Dragon UnPACKer?','Are you sure you want to exit Dragon UnPACKer?',mtConfirmation,[mbYes, mbNo],0) = mrYes then
    Application.Terminate;

end;

// Load a single theme image
procedure TfrmMain.loadThemeImage(theme, id: string; index: integer);
var pngImage: TPortableNetworkGraphic;
    x: integer;
begin

  Logger.EnterMethod('Loading theme image...');
  Logger.Send('Image: '+id);

  // Initialize the TPortableNetworkGraphic class that will be used to load
  // the image
  pngImage := TPortableNetworkGraphic.Create;
  try
    // Load image from PNG file
    pngImage.LoadFromFile(getBaseDir()+'themes\'+theme+'\'+id+'.png');
    // Replace it in the image list
    imgMenu.ReplaceMasked(index,pngImage,clLime);
    // Free the TPortableNetworkGraphic object
    pngImage.Free;
    Logger.Send('Successully loaded!');
  except
    on e:exception do
      Logger.SendException('Error loading',e);
  end;
  Logger.ExitMethod('Loading theme image...');

end;

// Load the images used by Dragon UnPACKer
procedure TfrmMain.loadTheme(theme: string = 'default');
var emptyImage: TBitmap;
    x: integer;
begin

  Logger.EnterMethod('Loading theme...');
  Logger.Send('Theme: '+theme);

  if not(DirectoryExists(getBaseDir()+'themes\'+theme)) then
  begin
    Logger.SendError('Theme directory not found: '+getBaseDir()+'themes\'+theme);
  end
  else
  begin

    // Initialize the TCustomBitmap class (empty image)
    emptyImage := TBitmap.Create;

    try
      // Reset the current image list
      imgMenu.Clear;
      // Insert empty images by default
      for x := 0 to 14 do
        imgMenu.InsertMasked(x,emptyImage,clLime);
      // Free the TBitmap empty image
      emptyImage.Free;
    except
      on e:Exception do
        Logger.SendException('Error resetting image list',e);
    end;

    loadThemeImage(theme,'OPEN', 0); // Menu Icon: Open
    loadThemeImage(theme,'CLOS', 1); // Menu Icon: Close
    loadThemeImage(theme,'HYPR', 2); // Menu Icon: HyperRipper
    loadThemeImage(theme,'QUIT', 3); // Menu Icon: Quit
    loadThemeImage(theme,'MRCH', 4); // Menu Icon: Find
    loadThemeImage(theme,'MOGN', 5); // Menu Icon: Options > Basic
    loadThemeImage(theme,'MOGA', 6); // Menu Icon: Options > Advanced
    loadThemeImage(theme,'MOGL', 7); // Menu Icon: Options > Log
    loadThemeImage(theme,'MOPL', 8); // Menu Icon: Plugins
    loadThemeImage(theme,'MOPC', 9); // Menu Icon: Plugins > Convert
    loadThemeImage(theme,'MOPD',10); // Menu Icon: Plugins > Drivers
    loadThemeImage(theme,'MOAS',11); // Menu Icon: File Association
    loadThemeImage(theme,'MOLK',12); // Menu Icon: Themes
    loadThemeImage(theme,'MPRE',13); // Menu Icon: Preview
    loadThemeImage(theme,'MABT',14); // Menu Icon: About

    Logger.Send('Theme '+theme+' loaded!');

  end;

  Logger.ExitMethod('Loading theme...');

end;

procedure TfrmMain.FormShow(Sender: TObject);
begin


end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin

  // Remove the logview channel from the logger
  Logger.Channels.Remove(LogView.Channel);

end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin

  // Add the logview channel to the logger
  Logger.Channels.Add(LogView.Channel);

  // Loading the theme (images, icons, etc..)
  loadTheme();

  // Refreshing the drivers
  DPlugins.refreshDrivers(getBaseDir());

end;

end.

