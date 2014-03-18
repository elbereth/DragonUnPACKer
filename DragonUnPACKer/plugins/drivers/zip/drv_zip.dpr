library drv_zip;

// $Id: drv_zip.dpr,v 1.9 2010-02-27 15:58:54 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/drivers/zip/drv_zip.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is drv_zip.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

uses
  FastMM4,
  FastCode,
  FastMove,
  SysUtils,
  Windows,
  Classes,
  AbArcTyp, AbZipTyp, AbZipPrc, AbUnzPrc, AbUtils,
  dup5drv_utils in '..\dup5drv_utils.pas',
  dup5drv_data in '..\dup5drv_data.pas',
  spec_DUDI in '..\..\..\common\spec_DUDI.pas',
  UnZip in 'UnZip.pas',
  lib_version in '..\..\..\common\lib_version.pas',
  lib_BinUtils in '..\..\..\common\lib_binutils.pas';

{$E d5d}

{$R *.res}

{$Include datetime.inc}

type
  TZipHelper = class
  public
    _SetPercent: TPercentCallback;
    procedure UnzipToStreamProc( Sender : TObject; Item : TAbArchiveItem; OutStream : TStream );
    procedure ZipProc( Sender : TObject; Item : TAbArchiveItem; OutStream : TStream );
    procedure ArchiveItemProgress( Sender: TObject;
                                   Item: TAbArchiveItem;
                                   Progress: Byte;
                                   var Abort: Boolean);
  end;
{ /////////////////////////////////////////////////////////////////////////////

  10240  50012  Added Line of Sight: Vietnam .ZA to the supported file types
                Added Master of Orion 3 .MOB to the supported files types
  10340  50022  Added Hot Rod American Street Drag .ROD to the supported file types
                Added Call of Duty .PK3 to the supported games
  11040  52040  Updated to DUDI v4
                Added Doom 3 & Quake 4 .PK4 to the supported file types
                Added Serious Sam 2 .GRO to the supported file types
                Added Call of Duty 2 .IWD to the supported file types
  11140  52040  Added a lot of supported file types thanks to Z0oMiK
  11240  54040  Added Call of Duty 5: World at War .IWD to the supported file types
  11340  55240  Added Heroes of Might & Magic 5 .PAK to the supported file types
  11341  56040  This is the same version as the original 11340 without the
                bad modifications released with 5.6.0 Exedra
  20011  57010  Updated to DUDI v6 and now using Abbrevia

  /////////////////////////////////////////////////////////////////////////////}
const DRIVER_VERSION = 20011;
      DUP_VERSION = 57010;
      DUDI_VERSION = 6;
      DUDI_VERSION_COMPATIBLE = 6;
      SVN_REVISION = '$Rev: 671 $';
      SVN_DATE = '$Date: 2014-03-18 08:22:21 +0100 (mar., 18 mars 2014) $';

var CurFormat: Integer = 0;
    DrvInfo: CurrentDriverInfo;
    ErrInfo: ErrorInfo;
    NumEntry: integer = 0;
    DLLStatus: boolean = false;
    DLLFound: boolean = false;
    SetPercent: TPercentCallback;
    DLNGStr: TLanguageCallback;
    CurPath: string;
    AHandle : THandle;
    AOwner : TComponent;
    SupportedDUDI: byte = 0;
    Helper: TZipHelper;
    Archive: TAbZipArchive;
    ShowMsgBox : TMsgBoxCallback;
    AddEntry : TAddEntryCallback;


procedure TZipHelper.ArchiveItemProgress( Sender: TObject;
  Item: TAbArchiveItem; Progress: Byte; var Abort: Boolean);
type
  TMethodStrings = array [ cmStored..cmDCLImploded ] of string;
const
  MethodStrings : TMethodStrings = ('UnStoring', 'UnShrinking', 'UnReducing',
                                    'UnReducing', 'UnReducing', 'UnReducing',
                                    'Exploding', 'DeTokenizing', 'Inflating',
                                    'Enhanced Inflating', 'DCL Exploding');
var
  ActionString : string;
  CompMethod: TAbZipCompressionMethod;
begin
  case Item.Action of

    aaAdd : ActionString := 'Adding  ';
    aaFreshen : ActionString := 'Freshening  ';
    else begin
      CompMethod := (Item as TAbZipItem).CompressionMethod;
      if CompMethod in [cmStored..cmDCLImploded] then
        ActionString := MethodStrings[(Item as TAbZipItem).CompressionMethod] +
          '  '
      else
        ActionString := 'Decompressing  ';
    end;
  end;
  _SetPercent(Progress);
end;

procedure TZipHelper.UnzipToStreamProc( Sender : TObject; Item : TAbArchiveItem; OutStream : TStream );
begin
  AbUnzipToStream( Sender, TAbZipItem(Item), OutStream );
end;

procedure TZipHelper.ZipProc( Sender : TObject; Item : TAbArchiveItem; OutStream : TStream );
begin
  AbZip( TAbZipArchive(Sender), TAbZipItem(Item), OutStream );
end;

function IsValidZIP(fil: string): boolean;
var ID: array[0..3] of char;
    TestFile: integer;
begin

  Result := False;

  TestFile := FileOpen(fil, fmOpenRead);

  if TestFile > 0 then
  begin
    FileRead(TestFile,ID,4);
    Result := (ID[0] = 'P') and (ID[1] = 'K') and (ID[2] = #3) and (ID[3] = #4);
    FileClose(TestFile);
  end;

end;

// Identifies the DLL as a Driver plugin (minimum version to load plugin)
// Exported
function DUDIVersion: Byte; stdcall;
begin
  result := DUDI_VERSION_COMPATIBLE;
  SupportedDUDI := DUDI_VERSION_COMPATIBLE;
end;

// Indicate current DUDIVersion (should return 5 at minimum)
// Exported
function DUDIVersionEx(supported: byte): byte; stdcall;
begin
  result := DUDI_VERSION;
  SupportedDUDI := supported;
end;

// Returns Driver plugin version
// Exported
function GetNumVersion: Integer; stdcall;
begin

  GetNumVersion := DRIVER_VERSION;

end;

// Returns information about the driver (mainly supported files list)
// Exported
function GetDriverInfo: DriverInfo; stdcall;
begin

  // Initialize output to 0 filled
  FillChar(result,SizeOf(DriverInfo),0);

  // Information about the plugin
  with result do
  begin
    Name := 'Elbereth''s ZIP Driver';
    Author := 'Alexandre Devilliers (aka Elbereth)';
    Version := getVersion(DRIVER_VERSION);
    Comment := 'This driver uses TAbUnzip from Abbrevia to support all ZIP file formats.'+#10+'This is the official ZIP driver. Check about box for more info.';
  end;

//  result.Comment := 'This Driver is a wrapper to the Info-ZIP UnZip32.DLL. Using UnZip.pas by Gerke Preussner <j3rky@gerke-preussner.de>. Note: Password for Paradise Cracked files is "stereosystem".';

  result.NumFormats := 0;
  AddFormat(result,'*.A','Hellhog XP (*.A)');
  AddFormat(result,'*.ABZ','Alpha Black Zero (*.ABZ)');
  AddFormat(result,'*.ARF','Packmania 2 (*.ARF)');
  AddFormat(result,'*.ARH','El Airplane (*.ARH)');
  AddFormat(result,'*.BND','Neighbours From Hell (*.BND)|Neighbours From Hell 2 (*.BND)');
  AddFormat(result,'*.BOS','Fallout Tactics (*.BOS)');
  AddFormat(result,'*.BOT','Team Factor (*.BOT)');
  AddFormat(result,'*.BOX','Cellblock Squadrons (*.BOX)');
  AddFormat(result,'*.BIN','X-Men Legends 2 (*.BIN)|XPand Rally (*.BIN)');
  AddFormat(result,'*.CAB','Microsoft Flight Simulator 2004 (*.CAB)');
  AddFormat(result,'*.CRF','System Shock 2 (*.CRF)|Thief (*.CRF)|Thief 2 (*.CRF)');
  AddFormat(result,'*.CSC','18 Wheels Of Steel Pedal To The Metal (*.CSC)');
  AddFormat(result,'*.CTP','Call To Power (*.CTP)');
  AddFormat(result,'*.DAT','Against Rome (*.DAT)|Defiance (*.DAT)|Ricochet Lost Worlds Recharged (*.DAT)|Ricochet Xtreme (*.DAT)|Star Wolves (*.DAT)|Uplink (*.DAT)');
  AddFormat(result,'*.DLU','Dirty Little Helper 98(*.DLU)');
  AddFormat(result,'*.FBZ','Shadowgrounds (*.FBZ)');
  AddFormat(result,'*.FF','Freedom Force (*.FF)|Freedom Force vs The 3rd Reich (*.FF)');
  AddFormat(result,'*.FLMOD','Freelancer (*.FLMOD)');
  AddFormat(result,'*.GRO','Serious Sam (*.GRO)|Serious Sam 2 (*.GRO)');
  AddFormat(result,'*.IWD','Call of Duty 2 (*.IWD)|Call of Duty 3 (*.IWD)|Call of Duty 4: Modern Warfare (*.IWD)|Call of Duty: World at War (*.IWD)');
  AddFormat(result,'*.LZP','Law And Order 3 Justice Is Served (*.LZP)');
  AddFormat(result,'*.MGZ','Metal Gear Solid (*.MGZ)');
  AddFormat(result,'*.MOB','Master of Orion 3 (*.MOB)');
  AddFormat(result,'*.NOB','Vampire: The Masquerade (*.NOB)|Vampire The Masquerade Redemption (*.NOB)');
  AddFormat(result,'*.PAC','Desperados: Wanted Dead or Alive (*.PAC)');
  AddFormat(result,'*.PAK','Blitzkrieg (*.PAK)|Blitzkrieg Burning Horizon (*.PAK)|Blitzkrieg Rolling Thunder (*.PAK)|Brothers Pilots 4 (*.PAK)|Call of Juarez (*.PAK)|Far Cry (*.PAK)|Heroes of Might & Magic 5 (*.PAK)|Maximus XV (*.PAK)|Monte Cristo (*.PAK)|Outfront (*.PAK)');
  AddFormat(result,'*.PAK','Paradise Cracked (*.PAK)|Perimeter (*.PAK)');
  AddFormat(result,'*.PK1;*.PK2','XS Mark (*.PK1;*.PK2)');
  AddFormat(result,'*.PK3','Call of Duty (*.PK3)|Quake 3 Arena (*.PK3)|Medal of Honor: Allied Assault (*.PK3)|American McGee Alice (*.PK3)|Jedi Knight 2: Jedi Outcast (*.PK3)|Heavy Metal: F.A.K.K.2 (*.PK3)');
  AddFormat(result,'*.PK4','Doom 3 (*.PK4)|Quake 4 (*.PK4)|Doom 3 Resurrection Of Evil (*.PK4)');
  AddFormat(result,'*.POD','Hoyle Games 2005 (*.POD)|Terminator 3 (*.POD)');
  AddFormat(result,'*.PSH','Itch (*.PSH)|Pusher (*.PSH)');
  AddFormat(result,'*.RBZ','Richard Burns Rally (*.RBZ)');
  AddFormat(result,'*.RES','Swat 3 Close Quarters Battle (*.RES)');
  AddFormat(result,'*.ROD','Hot Rod American Street Drag (*.ROD)');
  AddFormat(result,'*.RVI;*.RVM;*.RVR','Revenant (*.RVI;*.RVM;*.RVR)');
  AddFormat(result,'*.SAB','Sabotain (*.SAB)');
  AddFormat(result,'*.SCS','Hunting Unlimited 3 (*.SCS)');
  AddFormat(result,'*.SXT','Singles Flirt Up Your Life (*.SXT)');
  AddFormat(result,'*.TEXTUREPACK;*.DATA','Arena Wars (*.TEXTUREPACK;*.DATA)');
  AddFormat(result,'*.Vl2','Tribes 2 (*.VL2)');
  AddFormat(result,'*.ZA','Elite Warriors (*.ZA)|Line of Sight: Vietnam (*.ZA)|Deadly Dozen (*.ZA)|Deadly Dozen 2 Pacific Theater (*.ZA)');
  AddFormat(result,'*.ZIP','Dethkarz (*.ZIP)|Battlefield 2 (*.ZIP)|Empire Earth 2 (*.ZIP)|Falcon 4 (*.ZIP)|Fire Starter (*.ZIP)|Freedom Fighters (*.ZIP)|Hitman Contracts (*.ZIP)|Hitman Bloodmoney (*.ZIP)|Hitman 2 Silent Assasin (*.ZIP)|Slave Zero (*.ZIP)');
  AddFormat(result,'*.ZIPFS','18 Wheels Of Steel Across America (*.ZIPFS)|Duke Nukem - Manhattan Project (*.ZIPFS)');
  AddFormat(result,'*.ZTD','Dinosaur Digs (*.ZTD)|Marine Mania (*.ZTD)');

  //--------------------------------------------------------------------------
  //NOTE only for Paradise Cracked
  //The game Paradise Cracked using default ZIP files + password
  //The password for archives -> stereosystem
  //--------------------------------------------------------------------------

end;

function ExtractFileToStream(outputstream: TStream; entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: boolean): boolean; stdcall;
begin

  Archive.ExtractToStream(entrynam,outputstream);
  result := True;

end;

{ ----------------------------------------------------------
    function - ExtractFile()                     Facultative
  parameters - OutPutFile: ShortString
               EntryNam: ShortString
               Offset: Int64
               Size: Int64
               DataX: Integer
               DataY: Integer
     returns - Boolean
  ----------------------------------------------------------

  This function is called by DUP5 to extract files only if
  ExtractInternal is set to TRUE in CurrentDriverInfo.

  NOTE: Include it only if needed.
}
function ExtractFile(outputfile: ShortString; entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: Boolean): boolean; stdcall;
var fil: Integer;
    outStm: THandleStream;
begin

  fil := FileCreate(outputfile,fmOpenRead or fmShareExclusive);
  outStm := THandleStream.Create(fil);
  result := ExtractFileToStream(outStm,entrynam,offset,size,datax,datay,silent);
  FreeAndNil(outStm);
  FileClose(fil);

end;

{ ----------------------------------------------------------
    function - IsFormat()
  parameters - fil: ShortString
               Deeper: Boolean
     returns - Boolean
  ----------------------------------------------------------

  This function is called by DUP5 to know if your driver can
  open the file stored in Fil variable.
  The Deeper "switch" is here to indicate if you only need
  to test by extension or open file to check header.
  (Currently unused by DUP5)
}
function IsFormat(fil: ShortString; Deeper: Boolean): Boolean; stdcall;
var ext: string;
begin

  ext := ExtractFileExt(fil);
  if ext <> '' then
    ext := copy(ext,2,length(ext)-1);
  ext := UpperCase(ext);

  if Deeper then
    Result := IsValidZIP(fil)
  else
  begin
    if ext = 'PK3' then
      IsFormat := True
    else if ext = 'A' then
      IsFormat := True
    else if ext = 'ABZ' then
      IsFormat := True
    else if ext = 'ARF' then
      IsFormat := True
    else if ext = 'ARH' then
      IsFormat := True
    else if ext = 'BND' then
      IsFormat := True
    else if ext = 'BIN' then
      IsFormat := True
    else if ext = 'BOS' then
      IsFormat := True
    else if ext = 'BOT' then
      IsFormat := True
    else if ext = 'BOX' then
      IsFormat := True
    else if ext = 'CAB' then
      IsFormat := True
    else if ext = 'CRF' then
      IsFormat := True
    else if ext = 'CSC' then
      IsFormat := True
    else if ext = 'CTP' then
      IsFormat := True
    else if ext = 'DATA' then
      IsFormat := True
    else if ext = 'DLU' then
      IsFormat := True
    else if ext = 'FBZ' then
      IsFormat := True
    else if ext = 'FF' then
      IsFormat := True
    else if ext = 'FLMOD' then
      IsFormat := True
    else if ext = 'GRO' then
      IsFormat := True
    else if ext = 'IWD' then
      IsFormat := True
    else if ext = 'LZP' then
      IsFormat := True
    else if ext = 'MOB' then
      IsFormat := True
    else if ext = 'NOB' then
      IsFormat := True
    else if ext = 'PAK' then
      IsFormat := True
    else if ext = 'PK1' then
      IsFormat := True
    else if ext = 'PK2' then
      IsFormat := True
    else if ext = 'PK4' then
      IsFormat := True
    else if ext = 'POD' then
      IsFormat := True
    else if ext = 'ROD' then
      IsFormat := True
    else if ext = 'RVI' then
      IsFormat := True
    else if ext = 'RVM' then
      IsFormat := True
    else if ext = 'RVR' then
      IsFormat := True
    else if ext = 'SCS' then
      IsFormat := True
    else if ext = 'SXT' then
      IsFormat := True
    else if ext = 'TEXTUREPACK' then
      IsFormat := True
    else if ext = 'VL2' then
      IsFormat := True
    else if ext = 'ZA' then
      IsFormat := True
    else if ext = 'ZIP' then
      IsFormat := True
    else if ext = 'ZIPFS' then
      IsFormat := True
    else if ext = 'ZTD' then
      IsFormat := True
    else
      IsFormat := False;
  end;

end;

{ ----------------------------------------------------------
    function - CloseFormat()
  parameters - none
     returns - nothing
  ----------------------------------------------------------

  This function is called by DUP5 to close an opened file.
  You should free all allocated stuff by ReadFile()
  function. And your driver must be able to handle a new
  call to ReadFile() just after a call to this function.
}
procedure CloseFormat; stdcall;
begin

  DrvInfo.Sch := '';
  DrvInfo.ID := '';
  DrvInfo.FileHandle := 0;

end;

{ ----------------------------------------------------------
    function - GetCurrentDriverInfo()
  parameters - none
     returns - CurrentDriverInfo record
  ----------------------------------------------------------

  This function is called by DUP5 to current file format
  information (directory handling, file handle, internal
  extraction).
  It is called just after ReadFile().

  NOTE: You don't need to change this function if you want
        to use the same driver model as this example.
}
function GetCurrentDriverInfo(): CurrentDriverInfo; stdcall;
begin

  GetCurrentDriverInfo := DrvInfo;

end;

{ ----------------------------------------------------------
    function - GetEntry()
  parameters - none
     returns - FormatEntry record
  ----------------------------------------------------------

  This function is called by DUP5 to retrieve entries of the
  file parsed by ReadFile() function.
  It is called just after ReadFile() and N times (with N
  equal to the value returned by ReadFile).

  NOTE: You don't need to change this function if you want
        to use the same driver model as this example.
}
function GetEntry(): FormatEntry; stdcall;
begin

  GetEntry := FSE_Read;

end;

{ ----------------------------------------------------------
    function - GetErrorInfo()
  parameters - none
     returns - ErrorInfo record
  ----------------------------------------------------------

  This function is called by DUP5 when ReadFile() function
  returns an integer value of -3 (returns format info and
  game info).

  NOTE: You don't need to change this function if you want
        to use the same driver model as this example.
}
function GetErrorInfo(): ErrorInfo; stdcall;
begin

  GetErrorInfo := ErrInfo;

end;

{ ----------------------------------------------------------
    function - ReadFormat()
  parameters - fil: ShortString
     returns - Integer value
  ----------------------------------------------------------

  This function opens file pointed by fil var and if:
  1) The file is good format:
     File is parsed and entries are stored (for future call
     by DUP5 to GetEntry() function).
     Integer value will have the total number of stored
     entries.
     DriverInfo must be setup for future call to
     GetCurrentDriverInfo() function by DUP5.
     CurrentDriverInfo structure:
       ID     - File ID (Appears on the status of DUP5)
       ASlash - Char used as separator for directories is
                Slash (\)      = TRUE
                Anti-Slash (/) = FALSE
       Sch    - Char used as separator for directories (\ or /)
       FileHandle - File Handle (Integer);
       ExtractInternal - If your Driver include an ExtractFile
                         function set this to TRUE
                         else set it to FALSE (DUP5 will handle
                         the file extraction).
  2) The file could not be opened:
     Integer value is set to -2.
  3) The file does not have expected format:
     Integer value is set to -3.
     Error information should be stored (for future call by
     DUP5 to GetErrorInfo() function).
  4) The file extension is unrecognized:
     Integer value is set to -1.
     (This should normally never happen is IsFormat()
     function is well coded).

 IMPORTANT:
 You must not close the file handle because DUP5 will use
 it for Extraction if your driver does not have ExtractFile
 function.
 File handle is an integer, meaning you must use FileOpen,
 FileClose, FileRead, FileWrite, etc..
 If you don't want to use those functions you must include
 an ExtractFile function to your driver.
 ----------------------------------------------------------
}
function ReadFormat(fil: ShortString; percent: TPercentCallback; Deeper: boolean): Integer; stdcall;
var x: integer;
begin

  if Not(IsValidZIP(fil)) then
  begin
    ReadFormat := -3;
    ErrInfo.Format := 'ZIP';
    ErrInfo.Games := 'Medal of Honor: Allied Assault, Quake 3 Arena, ...';
  end
  else
  begin

    if (Archive <> nil) then
      FreeAndNil(Archive);
      
    Archive := TAbZipArchive.Create(fil,fmOpenReadWrite or fmShareDenyWrite);
    Archive.ExtractToStreamHelper := Helper.UnzipToStreamProc;
    Archive.OnArchiveItemProgress := Helper.ArchiveItemProgress;
    Archive.Load;

    for x := 0 to Archive.Count-1 do
      AddEntry(Archive.Items[x].FileName,Archive.Items[x].RelativeOffset,Archive.Items[x].UncompressedSize,x,0);

    DrvInfo.Sch := '/';
    DrvInfo.ID := 'ZIP';
    DrvInfo.FileHandle := 0;
    DrvInfo.ExtractInternal := true;

    Result := Archive.Count;
  end;

end;

procedure InitPlugin(per: TPercentCallback; lngid: TLanguageCallback; DUP5Path: ShortString; AppHandle: THandle; AppOwner: TComponent); stdcall;
begin

  SetPercent := per;
  DLNGStr := lngid;
  CurPath := DUP5Path;
  AHandle := AppHandle;
  AOwner := AppOwner;

  Helper := TZipHelper.Create;
  Helper._SetPercent := per;
  Archive := nil;

end;

procedure InitPluginEx5(MsgBox: TMsgBoxCallback); stdcall;
begin

  showMsgBox := MsgBox;

end;

procedure InitPluginEx6(AddEntryCB: TAddEntryCallback); stdcall;
begin

  addEntry := AddEntryCB;

end;

procedure AboutBox; stdcall;
var aboutText: string;
begin

    aboutText := '{\rtf1\ansi\ansicpg1252\deff0\deflang1036{\fonttbl{\f0\fswiss\fcharset0 Arial;}}'+#10+
                 '\viewkind4\uc1\pard\qc\ul\b\f0\fs24\par Elbereth''s ZIP Driver plugin v'+getVersion(DRIVER_VERSION)+'\par'+#10+
                 '\ulnone\b0\i\fs22 Created by \b Alexandre Devilliers (aka Elbereth/Piecito)\par'+#10+
                 '\par'+#10+
                 '\b0\i0\fs20 Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+'\par'+#10+
                 'Driver Interface [DUDI] v'+inttostr(DUDI_VERSION)+' (v'+inttostr(DUDI_VERSION_COMPATIBLE)+' compatible) [using v'+inttostr(SupportedDUDI)+']\par'+#10+
                 'Compiled the '+DateToStr(CompileTime)+' at '+TimeToStr(CompileTime)+'\par'+#10+
                 'Based on SVN rev '+getSVNRevision(SVN_REVISION)+' ('+getSVNDate(SVN_DATE)+')\par'+#10+
                 '\par'+#10+
                 '\ul Credits:\par'+#10+
                 '\ulnone Abbrevia for all ZIP operations:\par'+#10+'\b http://tpabbrevia.sourceforge.net/\par'+#10+
                 '}'+#10;

  showMsgBox('About Elbereth''s ZIP Driver plugin...',aboutText);

end;

// Returns information about the driver creation capabilities (supported formats)
// Exported
function GetDriverModifInfo: DriverModifInfo; stdcall;
begin

  // Initialize output to 0 filled
  FillChar(result,SizeOf(DriverModifInfo),0);

end;

// Exported functions
exports
  DUDIVersion,
  DUDIVersionEx,
  ExtractFile,
  ExtractFileToStream,
  ReadFormat,
  CloseFormat,
  GetEntry,
  GetDriverInfo,
  GetDriverModifInfo,
  GetNumVersion,
  GetCurrentDriverInfo,
  GetErrorInfo,
  AboutBox,
  InitPlugin,
  InitPluginEx5,
  InitPluginEx6,
  IsFormat;

{procedure LibExit(Reason: Integer);
begin
  if Reason = DLL_PROCESS_DETACH then
  begin
  ...  // library exit code
  end;
  SaveDllProc(Reason);  // call saved entry point procedure
end;
begin
  ...  // library initialization code
  SaveDllProc := DllProc;  // save exit procedure chain
  DllProc := @LibExit;  // install LibExit exit procedure

end.}

end.
