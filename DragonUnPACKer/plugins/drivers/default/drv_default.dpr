library drv_default;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is drv_default.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

uses
  FastMM4,
  FastCode,
  FastMove,
  Zlib,
  Classes,
  StrUtils,
  Windows,
  SysUtils,
  ULZMADecoder,
  ULZMACommon,
  AbArcTyp,
  AbGZTyp,
  U_IntList in '..\..\..\common\U_IntList.pas',
  spec_DDS in '..\..\..\common\spec_DDS.pas',
  spec_HRF in '..\..\..\common\spec_HRF.pas',
  lib_BinUtils in '..\..\..\common\lib_BinUtils.pas',
  lib_bincopy in '..\..\..\common\lib_bincopy.pas',
  lib_version in '..\..\..\common\lib_version.pas' {,
  class_decompressRA in 'class_decompressRA.pas'},
  lib_unlzw in '..\..\..\common\lib_unlzw.pas',
  lib_crc in '..\..\..\common\lib_crc.pas',
  dup5drv_utils in '..\dup5drv_utils.pas',
  spec_DUDI in '..\..\..\common\spec_DUDI.pas',
  spec_D11D in '..\..\..\common\spec_D11D.pas';

{$E d5d}

{$R *.RES}

{$Include datetime.inc}

type EBadFormat = class(Exception);
     EDecompLZMAError = class(Exception);

type FSE = ^element;
     element = record
        Name : String;
        Size : Int64;
        Offset : Int64;
        DataX : integer;
        DataY : integer;
        suiv : FSE;
     end;
     TInts = ^TInt;
     TInt = record
        Value : Integer;
        suiv : TInts;
     end;

type
  TAbProgress = Class
    private
      _SetPercent: TPercentCallback;
      _LastProgress: byte;
    published
      constructor Create(SetPercent: TPercentCallback);
      procedure SetArchiveProgress(Sender : TObject; Progress : Byte; var Abort : Boolean);
      procedure SetProgress(Progress : Byte; var Abort : Boolean);
      procedure SetItemProgress(Sender : TObject; Item : TAbArchiveItem; Progress : Byte; var Abort : Boolean);
  end;

{ ////////////////////////////////////////////////////////////////////////////
  Driver History:
  Version   DUP5 Description
    10710 500a11
    10810 500a12
    11010  50011
    11110        Added Battlefield 1492 support
    11210        Added Sin .PAK support
    11310        Added Zanzarah .PAK support
    11410  50012 Added HyperRipper File v3.0 support
                 Fixed Novalogic PFF3 support
                 Added GTA3 IMG/DIR support
    11510        Added Age of Mythology BAR support
    11610        Added No One Lives for Ever 2 to the list of supported games
                 Added Postal .SAK support
    11710        Added James Bond NightFire 007 support (007 v1 [DEMO] and v3 [RETAIL])
    11810        Fixed RFH/RFD uncompressed entries extraction
    11910        Added BloodRayne POD support
    12010        Fixed James Bond NightFire 007 support (007 v3 [RETAIL] bug)
                 Added (Preliminary) NoX .BAG/IDX support (only GABA/Audio.bag&idx supported)
    12110        Fixed Jagged Alliance 2 SLF support (Writing test file on H:\ and Smart not coded)
    12112        Fixed Jagged Alliance 2 SLF support (Smart detection was broken)
    12201        Added PARTIAL Vietcong Demo CBF support ("DDC" compression unknown)
    12210  50013 Builded as Beta for DUP5 Beta 3 release [Nothing new]
    12310  50014 Added Port Royale CPR support
                 Added Purge REZ to the list of supported games
                 Added Harbinger SQH support
                 LongInt Swap function should be faster
                 Added Patrician II CPR to the list of supported games
    12410        Added Rage of Mages & Rage of Mages 2 RES support
    12520  50021 Changed name to Elbereth's Main Driver
    12620        Added Star Crusader PAK support
    12720        Added Tron 2.0 REZ in the list of supported games
                 [Added Heath: The Unchosen Path .PAXX.NRM support] (Removed because strange behaviour)
                 Fixed a bug in the GetSwapInt function.
                   (Fixed BUN support)
    12820  50022 Added support for retail version of Battlefield 1942
                 Added support for GTA: Vice City .ADF files
    12920  50023 Added support for Pixel Painters ressource files:
                 Electranoid .RES
                 Fuzzy's World of Miniature Space Golf .RES
                 Laser Light .RES
                 Xatax .RES
                 Added (partial?) support for Pixel Painters extended ressource files:
                 Dig It! .XRS
                 Maybe the files are crypted or compressed.. but not sure...
                 Added Command & Conquer: Generals .BIG support
                 Initial Commandos 3 .PCK support (unknown method to find the decryption key)
                 Initial Empires: Dawn of the Modern World .SSA support (some files use an unknown compression)
    13020        Added support for Spellforce .PAK files
                 Added support for Eve Online .STUFF files
    13120        Added support for Nocturne .POD files
                 Fixed the .POD extension running .007 open routine (which obviously won't work)
    13211        Fixed SCGL always opening files (even for WestWood TLK files).
    13220  50024 Added support for Painkiller .PAK files
    13340        Added support for Hitman: Contracts .TEX files
    13341        Added support for Hitman: Contracts .PRM files
    13440        Added support for CyberBykes .BIN files
                 Enhanced support for Glacier Engine .TEX files (previously Hitman: Contracts)
    13441  50040 Found the meaning of 8 bytes in the DWFBEntry structure.
    13442        Incorporated the Westwood PAK MIX detection fix from Felix Riemann
    13540        Some research on Transport Giant JFL/IND files.
                 Added support for Myst IV Revelation .M4B files
    13640        Added support for Leisure Suit Larry: Magna Cum Laude .JAM files.
    20010        Started to upgrade to new interface DUDI v4
    20011  51140 Upgraded to new interface DUDI v4
    20012  51240 Merged with 5.0 changes (see 13540 and 13640 version)
    20040  52040 Changed version number for 5.2 release
                 Added support for Age of Empires 3 .BAR files
                 Added support for Black & White 2 .STUFF files
                 Added support for Black & White 2 .LUG files
                 Added support for Civilization 4 .FPK files
                 Added support for Fable: The Lost Chapters .LUG files
                 Added support for F.E.A.R. .ARCH00 files
                 Added experimental support for Fable: The Lost Chapters .BIG files (this is not in the list of supported files)
                 Added support for LEGO Star Wars .DAT file (only SFX.DAT afaik)
                 Added support for The Movies .BIG files
                 Added support for The Movies .LUG files
                 Changed a bit the Command & Conquer: Generals .BIG code to support The Lord of the Rings: Battle for Middle Earth .BIG files
    20041        Fixed The Movies .PAK extraction
    20140        Added support for Assassin's Creed .FORGE files but not activated because looks strange...
                 Added support for The Elder Scroll 4: Oblivion .BSA files
                 Added support for UFO: Aftermath/Aftershock/Afterlight .VFS files
    20240        Added support for Act of War .DAT files
                 Added support for Dreamfall - The Longest Journey .PAK files
                 Added support for Sinking Island/L'Ile Noyée .OPK files
    20271        Added support for Starsiege: Tribes .VOL files (which was supposed to be already supported...)
    20340        Added support for Entropia Universe .BNT files
    20440        Added support for AGON .SFL files (still needs more work but usable)
    20511        Added support for Enclave & The Chronicles of Riddick: Butcher Bay .XWC & .XTC file format (MOS DATAFILE2.0)
                 This is a beta because the XWC/XTC support needs to be cleaned up and secured...
    20512        Improved Spellforce .PAK files support (directories are now shown) thanks to info from Anonimeitor
    20513        Added partial support for F-22 Air Dominance Fighter .DAT files
    20514        Improved Enclave & Riddick .XTC extraction of DXT1/DXT3 textures (MipMap is included now)
                 Added detection of DXT5 textures in .XTC files of Riddick
                 Fixed F-22 Air Dominance Fighter .DAT detection to work with did.dat of ADF & Total Air War
                 Added detection of Super EF2000 .DAT files (same structure than F-22 ADF)
    20515        Cleaned the code, using lib_BinUtils instead of local functions
                 All the types are now just before each function using them
                 Same goes for special functions
                 Improved detection of Riddick .XTC files (retail version of the game)
    20516        Improved LithTech .REZ support -> Fixes opening NOLF2 sound.rez
    20540  54040 Added support for Ascendancy .COB files
                 Added support for Florensia .PAK files
    20640  54041 Added support for The Fifth Element .MRC file
    20711        Added partial support for F1 Manager 2000 .RFC/.RFH/.RFD (unknown compression, not Zlib)
    20712        Added code to read Vietcong .CBF crypted files (based on GPL C code of Luigi Auriemma cbfext.c)
                 Added support for The Chronicles of Riddick: Dark Athena .XWC & XTC files (some textures are obviously not extracted
                    to DDS correctly but I don't know why, it is the best I can do...)
    20713        Added decompression code (LZW) for Vietcong CBF files
                 See lib_unlzw.pas in common folder (based on C source code unlzw.c v0.1.2 by Luigi Auriemma)
                                                               e-mail: aluigi@autistici.org web: aluigi.org
    20714        Fixed Vietcong CBF multi-block decompression (only first block was decompressed before).
    20715        Added support for Prototype .RCF files (thanks to specs by john_doe of Xentax forum)
    20740        Added much needed sanity checks to .BIN & .DAT file formats
    20741        Fixed Total Annihilation HPI extraction when compression is Zlib (Exception Access Violation)
    20742  55010 Replaced .free by FreeAndNil() to be more consistant (no more bad pointers)
    20743        Upgraded to new interface DUDI v5 (plugin is backward compatible to v4)
    20840        Merged Giants GZP plugin
                 Added Command & Conquer .MIX files support (based on info by Olaf van der Spek)
                   http://xhp.xwis.net/documents/MIX_Format.html
                  Encrypted files are not supported (yet?), don't hesitate in using the very good XCC-Utils
                  Thanks to this added support drv_mix.d5d from Felix Riemann is not needed anymore (way to go x64!!!)
                 Fixed realMyst 3D .DNI support (implemented zlib decompression of entries)
    20940  55210 Added Dragon Age: Origins .ERF files support
                 Added Battleforge .PAK files support
    21010  55210 Test for SVN Keywords
                 Test for Avatar THE GAME .PAK support
    21040  56040 Modified support for Civilization 4 .FPK files:
                  Now supports Civilization V .FPK files too (which fixes bug #3084576)
                 Removed Avatar preliminary/experimental support (quite complex format actually)
    21140  56140 Added Ghostbusters: The Video Game .POD files support (slightly modified BloodRayne .POD format)
                 Added Ghostbusters: Sanctum of Slime .PAK files support (with LZMA decompression)
    21210        Added preliminary The Witcher 2: Assassins of Kings .DZIP files support
    30010  57010 Upgraded to new interface DUDI v6 (plugin is not backward compatible to v4/v5)
                 Added Aliens vs Predator (2010) .ASR (Asura & AsuraZlb) support
                 Added Star Wars Starfighter .PAK support
    30110        Fixed EVE Online .STUFF support.
    30112        Really fixed the extraction of files (and not only EVE Online .STUFF)
    30113        Merged The 11th Hour .GJD support (drv_11th is not needed anymore)
                 Added The 7th Guest .GJD support (drv_11th never worked)...
    30114        Added sanity checks to Terminal Velocity .POD support
    30115  57110 Removed SVN keywords
                 Added Astebreed, Ether Vapor Remaster and Fairy Bloom Fresia .TGP support
    30116        Added Artifex Mundi .CUB support
    30117        Added Geometry Wars 3 Dimension Evolved .PAK support (no filenames)
                 Added The Secret of Monkey Island: Special Edition .PAK support
                 Added Monkey Island 2: Special Edition .PAK support
                 Added South Park: The Stick of Truth .OAF support
        TODO --> Added Warrior Kings Battles BCP

  Possible bugs (TOCHECK):
  HPI Extraction when compression = 0 don't use HPIRead (no decryption of data)

  Known bugs/problems:
  Dungeon Keeper 2 DWFB files (.WAD) have compressed entries sometimes.
  (Those are not decompressed.. unknown compression used, maybe hauffman)

  Coded but disabled (declare EXPFORMATS to enable them during compilation):
  Game                        Ext.   Description
  Assassin's Creed            FORGE  Looks strange...
  Heath: The Unchosen Path    NRM    Extraction problem (maybe some sort of RLE encoding)
                                     Need to fix the unamed file in root
  Heroes of Might & Magic 4   H4R    Unknown compression method

  //////////////////////////////////////////////////////////////////////////// }

const
  DUDI_VERSION = 6;
  DUDI_VERSION_COMPATIBLE = 6;
  DRIVER_VERSION = 30117;
  DUP_VERSION = 57110;
  BUFFER_SIZE = 8192;

var DataBloc: FSE;
    FHandle: Integer = 0;
    CurFormat: Integer = 0;
    DrvInfo: CurrentDriverInfo;
    TotFSize: Int64 = 0;
    CompressionWindow: Integer = 0; // For UFO Aftermath VFS only at the moment
    ErrInfo: ErrorInfo;
    SetPercent: TPercentCallback;
    Per: Byte = 0;
    OldPer: byte = 0;
    SupportedDUDI: byte = 0;
    DNISize : Integer;
    NumFSE: Integer;
    HPIKey: Integer;
    DLNGStr: TLanguageCallback;
    CurPath: string;
    AHandle : THandle;
    AOwner : TComponent;
    ShowMsgBox : TMsgBoxCallback;
    AddEntry : TAddEntryCallback;
    BufferStream : TMemoryStream;

// This function reverse a string
//  Ex: "abcd" becomes "dcba"
function revstr(str: string): string;
var res: string;
    x: integer;
begin

  res := '';

  for x := 1 to length(str) do
    res := str[x]+res;

  revstr := res;

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
    Name := 'Elbereth''s Main Driver';
    Author := 'Alexandre Devilliers (aka Elbereth)';
    Version := getVersion(DRIVER_VERSION);
    Comment := 'This driver support 87 different file formats. This is the official main driver.'+#10+'Check about box for more info.';
  end;

  // Supported file formats
  addFormat(result,'*.007','James Bond 007: NightFire (*.007)');
  addFormat(result,'*.ARCH00','F.E.A.R. (*.ARCH00)');
  addFormat(result,'*.ART','Blood (*.ART)');
  addFormat(result,'*.ASR','Aliens vs. Predator (*.ASR)');
  addFormat(result,'*.AWF','Qui veut gagner des millions (*.AWF)|Who wants to be a millionaire (*.AWF)');
  addFormat(result,'*.BAG;*.RFH','Emperor: Battle for Dune (*.BAG;*.RFH)');
  addFormat(result,'*.BAR','Age of Mythology (*.BAR)|Age of Empires 3 (*.BAR)');
  addFormat(result,'*.BIG','Command & Conquer: Generals (*.BIG)|Command & Conquer: Generals - Zero Hour (*.BIG)|The Lord of the Rings: Battle for Middle Earth (*.BIG)|Command & Conquer: Red Alert 3 (*.BIG)');
  addFormat(result,'*.BIN','CyberBykes: Shadow Racer VR (*.BIN)');
  addFormat(result,'*.BKF','Moto Racer (*.BKF)');
  addFormat(result,'*.BOX','Lemmings Revolution (*.BOX)');
  addFormat(result,'*.BNT','Entropia Universe (*.BNT)');
  addFormat(result,'*.BSA','The Elder Scrolls 4: Oblivion (*.BSA)');
  addFormat(result,'*.BUN','Monkey Island 3 (*.BUN)');
  addFormat(result,'*.CCX','Total Annihilation: Counter-Strike (*.CCX)');
  addFormat(result,'*.COB','Ascendancy (*.COB)');
  addFormat(result,'*.CPR','Port Royale (*.CPR)|Patrician II (*.CPR)');
  addFormat(result,'*.CUB','Artifex Mundi Games (*.CUB)|Nightmares from the Deep: The Cursed Heart (*.CUB)|Nightmares from the Deep 2: The Siren`s Call (*.CUB)|Nightmares from the Deep 3: Davy Jones (*.CUB)');
  addFormat(result,'*.DAT','Nascar Racing (*.DAT)|Gunlok (*.DAT)|LEGO Star Wars (*.DAT)|Act of War (*.DAT)|F-22 Air Dominance Fighter (*.DAT)|F-22 Total Air War (*.DAT)|Super EF2000 (*.DAT)');
  addFormat(result,'*.DNI','realMyst 3D (*.DNI)');
  addFormat(result,'*.DRS','Age of Empires 2: Age of Kings (*.DRS)');
  addFormat(result,'*.DTA','Hidden & Dangerous (*.DTA)');
  addFormat(result,'*.ERF','Dragon Age: Origins (*.ERF)');
  addFormat(result,'*.FAR','The Sims (*.FAR)');
  addFormat(result,'*.FFL','Aliens vs Predator (*.FFL)');
  addFormat(result,'*.FPK','Sid Meier''s Civilization 4 (*.FPK)|Sid Meier''s Civilization V (*.FPK)');
  addFormat(result,'*.GJD','The 11th Hour (*.GJD)');
  addFormat(result,'*.GOB','Dark Forces (*.GOB)|Indiana Jones 3D (*.GOB)|Jedi Knight: Dark Forces 2 (*.GOB)');
  addFormat(result,'*.GRP;*.ART','Duke Nukem 3D (*.GRP;*.ART)|Shadow Warrior (*.GRP;*.ART)');
  addFormat(result,'*.GZP','Giants: Citizen Kabuto (*.GZP)');
  addFormat(result,'*.HAL','Mortyr (*.HAL)');
  addFormat(result,'*.HOG;*.MN3','Descent (*.HOG)|Descent 2 (*.HOG)|Descent 3 (*.HOG;*.MN3)');
  addFormat(result,'*.HPI;*.UFO','Total Annihilation (*.HPI;*.UFO)');
  addFormat(result,'*.HRF','Dragon UnPACKer HyperRipper (*.HRF)');
  addFormat(result,'*.IMG;*.ADF','GTA3/Grand Theft Auto 3 (*.ADF;*.IMG)');
  addFormat(result,'*.JAM','Leisure Suite Larry: Magna Cum Laude (*.JAM)');
  addFormat(result,'*.LUG','Fable: The Lost Chapter (*.LUG)');
  addFormat(result,'*.LUG;*.BIG','The Movies (*.BIG;*.LUG)');
  addFormat(result,'*.M4B','Myst IV: Revelation (*.M4B)');
  addFormat(result,'*.MIX','Command & Conquer (*.MIX)');
  addFormat(result,'*.MIX;*.TLK','Blade Runner (*.MIX;*.TLK)');
  addFormat(result,'*.MRC','The Fifth Element (*.MRC)');
  addFormat(result,'*.MTF','Darkstone (*.MTF)');
  addFormat(result,'*.OAF','South Park: The Stick of Truth (*.OAF)');
  addFormat(result,'*.OPK','Sinking Island (*.OPK)|L''Ile Noyée (*.OPK)');
  // Avatar: The Game (*.PAK)
  addFormat(result,'*.PAK','Battleforge (*.PAK)|Daikatana (*.PAK)|Dune 2 (*.PAK)|Star Crusader (*.PAK)|Trickstyle (*.PAK)|Zanzarah (*.PAK)|Painkiller (*.PAK)|Dreamfall: The Longest Journey (*.PAK)|Florencia (*.PAK)|Ghostbusters: Sanctum of Slime (*.PAK)|Star Wars Starfighter (*.PAK)');
  addFormat(result,'*.PAK','The Secret of Monkey Island Special Edition (*.PAK)|Monkey Island 2 Special Edition (*.PAK)');
  addFormat(result,'*.PAK;*.TLK','Hands of Fate (*.PAK;*.TLK)|Lands of Lore (*.PAK;*.TLK)');
  addFormat(result,'*.PAK;*.WAD','Quake (*.PAK;*.WAD)|Quake 2 (*.PAK;*.WAD)|Half-Life (*.PAK;*.WAD)|Heretic 2 (*.PAK;*.WAD)');
  addFormat(result,'*.PBO','Operation Flashpoint (*.PBO)');
  addFormat(result,'*.PCK','Commandos 3 (*.PCK)');
  addFormat(result,'*.PFF','Comanche 4 (*.PFF)|Delta Force (*.PFF)|Delta Force 2 (*.PFF)|Delta Force: Land Warrior (*.PFF)|F-22 Lightning 3');
  addFormat(result,'*.PKR','Tony Hawk Pro Skater 2 (*.PKR)');
  addFormat(result,'*.POD','Terminal Velocity (*.POD)|BloodRayne (*.POD)|Nocturne (*.POD)|Ghostbusters: The Video Game (*.POD)');
  addFormat(result,'*.RCF','Prototype (*.RCF)|Scarface (*.RCF)');
  addFormat(result,'*.RES','Electranoid (*.RES)|Evil Islands (*.RES)|Fuzzy''s World of Miniature Space Golf (*.RES)|Laser Light (*.RES)|Rage of Mages 2 (*.RES)|Xatax (*.RES)');
  addFormat(result,'*.REZ','Aliens vs Predator 2 (*.REZ)|No One Lives Forever (*.REZ)|No One Lives Forever 2 (*.REZ)|Sanity Aiken''s Artifact (*.REZ)|Shogo: Mobile Armor Division (*.REZ)|Purge (*.REZ)|Tron 2.0 (*.REZ)');
  addFormat(result,'*.RFA','Battlefield 1942 (*.RFA)');
  addFormat(result,'*.SAD','Black & White (*.SAD)');
  addFormat(result,'*.SAK','Postal (*.SAK)');
  addFormat(result,'*.SFL','AGON: The Lost Sword of Toledo (*.SFL)');
  addFormat(result,'*.SIN','Sin (*.SIN)');
  addFormat(result,'*.SLF','Jagged Alliance 2 (*.SLF)');
  addFormat(result,'*.SND','Heroes of Might & Magic 3 (*.SND)');
  addFormat(result,'*.SNI','MDK (*.SNI)');
  addFormat(result,'*.SQH','Harbinger (*.SQH)');
  addFormat(result,'*.SSA','Empires: Dawn of the Modern World (*.SSA)');
  addFormat(result,'*.STUFF','Eve Online (*.STUFF)');
  addFormat(result,'*.STUFF;*.LUG','Black & White 2 (*.LUG;*.STUFF)');
  addFormat(result,'*.SYN','Breakneck (*.SYN)|Excessive Speed (*.SYN)|N.I.C.E.2 (*.SYN)');
  addFormat(result,'*.TEX;*.PRM','Freedom Fighters (*.TEX;*.PRM)|Hitman 2: Silent Assassin (*.TEX;*.PRM)|Hitman: Contracts (*.TEX;*.PRM)');
  addFormat(result,'*.TGP','Astebreed (*.TGP)|Ether Vapor Remaster (*.TGP)|Fairy Bloom Fresia (*.TGP)');
  addFormat(result,'*.VFS','UFO: Aftermath (*.VFS)|UFO: Aftershock (*.VFS)|UFO: Afterlight (*.VFS)');
  addFormat(result,'*.VOL','Earth Siege 2 (*.VOL)|Starsiege: Tribes (*.VOL)');
  addFormat(result,'*.VP','Conflict: Freespace (*.VP)|Freespace (*.VP)|Freespace 2 (*.VP)');
  addFormat(result,'*.WAD','Gunman Chronicle (*.WAD)|Geometry Wars 3: Dimension Evolved (*.PAK)');
  addFormat(result,'*.WAD;*.SDT;*.DWFB','Dungeon Keeper 2 (*.WAD;*.SDT;*.DWFB)|Theme Park World (*.WAD;*.SDT)');
  addFormat(result,'*.X13','Hooligans (*.X13)');
  addFormat(result,'*.XCR','Warlords Battlecry (*.XCR)|Warlords Battlecry 2 (*.XCR)');
  addFormat(result,'*.XRS','Dig It! (*.XRS)');
  addFormat(result,'*.XWC;.XTC','Enclave (*.XTC;*.XWC)|The Chronicles of Riddick: Butcher Bay (*.XTC;*.XWC)|The Chronicles of Riddick: Dark Athena (*.XTC;*.XWC)');
  addFormat(result,'*.ZFS','Interstate ''76 (*.ZFS)|Interstate ''82 (*.ZFS)');

{IFDEF EXPFORMATS}
  // Experimental formats (either not working at all or useless in actual form)
  addFormat(result,'*.FORGE','Assassin''s Creed (*.FORGE)');
  addFormat(result,'*.PAXX.NRM','Heath: The Unchosen Path (*.PAXX.NRM)');
  addFormat(result,'*.H4R','Heroes of Might & Magic 4 (*.H4R)');
{ENDIF}

end;

// Returns information about the driver creation capabilities (supported formats)
// Exported
function GetDriverModifInfo: DriverModifInfo; stdcall;
begin

  // Initialize output to 0 filled
  FillChar(result,SizeOf(DriverModifInfo),0);

  // Supported file formats
  addModifFormat(result,'*.PAK','Quake (*.PAK)');

end;

// Used to keep only all caracters up to the first chr(10) encountered
// Ex: 'this is a pchar in string'+chr(10) will return same without chr(10)
function strip0A(str : string): string;
var pos0: integer;
begin

  pos0 := pos(chr(10),str);

  if pos0 > 0 then
    result := copy(str, 1, pos0 - 1)
  else
    result := str;

end;

procedure FSE_updateOffsets(PlusOffset: integer);
var browseFSE: FSE;
begin

  browseFSE := DataBloc;

  while browseFSE <> nil do
  begin
    inc(browseFSE^.Offset,PlusOffset);
    browseFSE := browseFSE^.suiv;
  end;

end;

procedure FSE_free();
var a: FSE;
begin

  while DataBloc <> NIL do
  begin
    a := DataBloc;
    DataBloc := DataBloc^.suiv;
    Dispose(a);
  end;

end;

procedure FSE_add(Name: String; Offset, Size: Int64; DataX, DataY: integer);
var nouvFSE: FSE;
begin

  new(nouvFSE);
  nouvFSE^.Name := Name;
  nouvFSE^.Offset := Offset;
  nouvFSE^.Size := Size;
  nouvFSE^.DataX := DataX;
  nouvFSE^.DataY := DataY;
  nouvFSE^.suiv := DataBloc;
  DataBloc := nouvFSE;

  AddEntry(Name,Offset,Size,DataX,DataY);

end;

////////////////////////////////////////////////////////////////////////////////
// ========================================================================== //
// ==                                                                      == //
// ==  The following functions are the heart of this driver. Each one      == //
// ==  read/parse a format.                                                == //
// ==                                                                      == //
// ==  Some of them are commented (the newer ones), others are old and     == //
// ==  uncommented (sorry).                                                == //
// ==                                                                      == //
// ========================================================================== //
////////////////////////////////////////////////////////////////////////////////

// -------------------------------------------------------------------------- //
// 007: NightFire .007 support ============================================== //
// -------------------------------------------------------------------------- //

type N007Header = packed record
       Magic: Integer;   // Always 1 ?
       Version: Integer; // 1 = Used in Nightfire Demo
                         // 3 = Used in Nightfire Retail
       Magic2: Integer;
       ID: array[0..3] of char;
       NumRootDirs: Integer;
     end;
     // If version = 3 then following the header is an integer giving the number of entries
     // Get32 filename
     N007Entry = packed record
       Compressed: byte;
       Size: integer;
       CompSize: integer;
     end;
     // If version = 1 then follows Size bytes of data (if Compressed = 0) or CompSize (if Compressed = 1)

type
  PN007List = ^N007List;
  N007List = record
    Name: string;
    Size: integer;
    CompSize: integer;
    Compressed: byte;
    Offset: Integer;
  end;

function ReadNightFire007_Aux(cdir: string; numDirs: integer; totFSize: integer): integer;
var ENT: N007Entry;
    disp : string;
    check, curNumDirs: integer;
begin

  Result := 0;
  curNumDirs := numDirs;

  if (curNumDirs = 0) then
  begin
    Check := 1;
    while (FileSeek(FHandle,0,1) < TotFSize) and (Check <> 0) do
    begin
      FileRead(FHandle,Check,4);
      if Check = 0 then
      begin
        FileSeek(FHandle,-4,1);
      end
      else
      begin
        FileSeek(Fhandle,-4,1);
        disp := get32(FHandle);
        Fileread(FHandle,ENT,SizeOf(N007Entry));
        FSE_Add(cdir+disp,FileSeek(FHandle,0,1),ENT.Size,ENT.Compressed,ENT.CompSize);
        if ENT.Compressed = 0 then
          FileSeek(FHandle,ENT.Size,1)
        else
          FileSeek(Fhandle,ENT.CompSize,1);
        inc(Result);
      end;
    end;
  end
  else
    while (FileSeek(FHandle,0,1) < TotFSize) and (curNumDirs > 0) do
    begin
      FileRead(FHandle,Check,4);
      if Check = 0 then
      begin
        disp := get32(FHandle);
        FileRead(Fhandle,Check,4);
        inc(Result,ReadNightFire007_Aux(cdir+disp+'\',Check,totFSize));
        dec(curNumDirs);
      end
      else
      begin
        FileSeek(Fhandle,-4,1);
        disp := get32(FHandle);
        Fileread(FHandle,ENT,SizeOf(N007Entry));
        FSE_Add(cdir+disp,FileSeek(FHandle,0,1),ENT.Size,ENT.Compressed,ENT.CompSize);
        if ENT.Compressed = 0 then
          FileSeek(FHandle,ENT.Size,1)
        else
          FileSeek(Fhandle,ENT.CompSize,1);
        inc(Result);
      end;
    end;

end;

function ReadNightFire007_Aux_v3(EList: TList; cdir: string; numDirs: integer; numEnt: integer; totFSize: integer): integer;
var ENT: N007Entry;
    disp : string;
    check, checkEnt, curNumDirs: integer;
    ENTL: PN007List;
begin

  Result := 0;
  curNumDirs := numDirs;

  //ShowMessage('Start:'+#10+cdir+#10+inttostr(numDirs)+' '+inttostr(numEnt));

  if (curNumDirs = 0) then
  begin
    Check := 1;
    while (FileSeek(FHandle,0,1) < TotFSize) and (Check <> 0) do
    begin
      FileRead(FHandle,Check,4);
      if Check = 0 then
      begin
        FileSeek(FHandle,-4,1);
      end
      else
      begin
        FileSeek(Fhandle,-4,1);
        disp := get32(FHandle);
        Fileread(FHandle,ENT,SizeOf(N007Entry));
        New(ENTL);
        ENTL^.Name := cdir+disp;
        ENTL^.Size := ENT.Size;
        ENTL^.CompSize := ENT.CompSize;
        ENTL^.Compressed := ENT.Compressed;
        EList.Add(ENTL);
        inc(Result);
      end;
    end;
  end
  else
    while (FileSeek(FHandle,0,1) < TotFSize) and (curNumDirs > 0) do
    begin
      FileRead(FHandle,Check,4);
      if Check = 0 then
      begin
        disp := get32(FHandle);
        FileRead(Fhandle,Check,4);
        FileRead(Fhandle,CheckEnt,4);
        ReadNightFire007_Aux_v3(EList,cdir+disp+'\',Check,CheckEnt,totFSize);
        dec(curNumDirs);
      end
      else
      begin
        FileSeek(Fhandle,-4,1);
        disp := get32(FHandle);
        Fileread(FHandle,ENT,SizeOf(N007Entry));
        New(ENTL);
        ENTL^.Name := cdir +disp;
        ENTL^.Size := ENT.Size;
        ENTL^.CompSize := ENT.CompSize;
        ENTL^.Compressed := ENT.Compressed;
        EList.Add(ENTL);
        inc(Result);
      end;
    end;

end;

function ReadNightFire007(src: string): Integer;
var HDR: N007Header;
    NumE,HDR_NumE,DataOffset,y : integer;
    cdir : string;
    EList: TList;
    ENTL: PN007List;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, SizeOf(N007Header));

    Result := 0;

    if (HDR.Magic <> 1) or (HDR.ID <> 'ROOT') or ((HDR.Version <> 1) and (HDR.Version <> 3)) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := '007';
      ErrInfo.Games := 'James Bond Nightfire (Demo & Retail)';
    end
    else if (HDR.Version = 1) then
    begin
      cdir := '';

      NumE := ReadNightFire007_Aux(cdir,HDR.NumRootDirs, totFSize);

      //ShowMessage(IntTosTr(NumE));

      Result := NumE;

      DrvInfo.ID := '007';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end
    else if (HDR.Version = 3) then
    begin
      cdir := '';
      FileRead(FHandle,HDR_NumE,4);

      EList := TList.Create;
      try
        ReadNightFire007_Aux_v3(EList,cdir,HDR.NumRootDirs,HDR_NumE,totFSize);
        DataOffset := FileSeek(FHandle,0,1)+4;
        NumE := EList.Count;
        for y := 0 to EList.Count-1 do
        begin
          ENTL := EList.Items[y];
          FSE_Add(ENTL^.Name,DataOffset,ENTL^.Size,ENTL^.Compressed,ENTL^.CompSize);
          if (ENTL^.Compressed = 0) then
            inc(DataOffset,ENTL^.Size)
          else
            inc(DataOffset,ENTL^.CompSize);
          Dispose(ENTL);
        end;
      finally
        FreeAndNil(EList);
      end;

      //ShowMessage(IntTosTr(NumE));

      Result := NumE;

      DrvInfo.ID := '007';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Act of War .DAT support ================================================== //
// -------------------------------------------------------------------------- //

// Support added thanks to the Xentax wiki page:
// http://wiki.xentax.com/index.php?title=GRAF:Act_Of_War_DAT

type AOWHeader = packed record
       ID: array[0..3] of char;                // edat
       Version: integer;                       // Always 0x12?
       CreationDate: integer;                  // Date in a weird format: yyyymmdd (ex: 20050204 --> 0x0131F11C)
       Unknown1Null: integer;                  // Always 0?
       Unknown2Null: integer;                  // Always 0?
       Unknown3_65K: integer;                  // Always 65536?
       Unknown4Null: byte;                     // Always 0?
       DirOffset: integer;                     // Offset to entries directory
       DirSize: integer;                       // Size of directory entries
     end;
     AOWFileInfo = packed record
       LastFileIndicator: integer;
       Offset: integer;
       Size: integer;
       Unknown1Null: byte;
     end;

function ReadActOfWarDAT_aux(dirBuffer: TMemoryStream; EndOffset: Integer; curgroup: string): integer;
var FIL: AOWFileInfo;
    disp: string;
    indicator, groupSize, curOffset, oldOffset: integer;
begin

  result := 0;

  if (dirBuffer.Seek(0,1) < EndOffset) then
  repeat

    oldOffset := dirBuffer.Seek(0,1);
    dirBuffer.ReadBuffer(indicator,4);

    // This is a group
    if (indicator > 0) then
    begin
      dirBuffer.ReadBuffer(groupSize,4);
      disp := strip0(get0(dirBuffer));
      if odd(length(disp)+1) then
        dirBuffer.Seek(1,1);
      inc(result,ReadActOfWarDAT_aux(dirBuffer,dirBuffer.seek(0,1)+groupSize,curgroup+disp));
    end
    // This is a file
    else if (indicator = 0) then
    begin

      // We read the file info structure
      dirBuffer.ReadBuffer(FIL,SizeOf(AOWFileInfo));

      // Retrieve the filename
      disp := strip0(get0(dirBuffer));

      // If the length of the file is odd we skip one byte
      if odd(length(disp)+2) then
        dirBuffer.Seek(1,1);

      // Add the file to the list
      FSE_Add(curGroup+disp,FIL.Offset,FIL.Size,0,0);
      inc(result);

      // If the indicator is 0 then we get out of the group
      if (FIL.LastFileIndicator = 0) then
        break;
    end
    // This is a file re-using a previous filename
    else
    begin
      // We read the file info structure
      dirBuffer.ReadBuffer(FIL,SizeOf(AOWFileInfo));

      // Skip 1 bytes (padding)
      dirBuffer.Seek(1,1);

      // Store current offset
      curOffset := dirBuffer.Seek(0,1);

      // Seek to filename position (back in buffer)
      dirBuffer.Seek(oldOffset+indicator,0);

      // Retrieve the filename
      disp := strip0(get0(dirBuffer));

      // Add the file to the list
      FSE_Add(curGroup+disp,FIL.Offset,FIL.Size,0,0);
      inc(result);

      // Go back to current offset
      dirBuffer.Seek(curOffset,0);

      // If the indicator is 0 then we get out of the group
      if (FIL.LastFileIndicator = 0) then
        break;

    end;

  until (dirBuffer.Seek(0,1) >= EndOffset);

end;

function ReadActOfWarDAT(): Integer;
var HDR: AOWHeader;
    TotSize: Int64;
    handle_stm: THandleStream;
    dirBuffer: TMemoryStream;
begin

  TotSize := FileSeek(Fhandle, 0, 2);
  FileSeek(Fhandle,0,0);
  FileRead(FHandle, HDR, SizeOf(AOWHeader));

  // Some verifications of the header to be sure it is an Act of War .DAT file
  if (HDR.ID <> 'edat') or (HDR.Version <> $12) or (HDR.DirOffset > TotSize) or ((HDR.DirOffset + HDR.DirSize) <> TotSize) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'EDAT';
    ErrInfo.Games := 'Act of War';
  end
  else
  begin

    // Create a HandleStream from the source file
    handle_stm := THandleStream.Create(Fhandle);

    // Seek to the Directory Offset
    handle_stm.Seek(HDR.DirOffset,soBeginning);

    // Create the Directory buffer stream
    dirBuffer := TMemoryStream.Create;

    // Read the complete directory to the buffer
    dirBuffer.CopyFrom(handle_stm,HDR.DirSize);

    // Free the HandleStream as we don't need it anymore
    FreeAndNil(handle_stm);

    // Seek to the start of the buffer
    dirBuffer.Seek(0,soBeginning);

    Result := ReadActOfWarDAT_aux(dirBuffer,HDR.DirSize,'');

    DrvInfo.ID := 'EDAT';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// Age of Empire 2 .DRS support ============================================= //
// -------------------------------------------------------------------------- //

type DRSHeader = packed record
       ID: array[0..35] of Char;
       EndOfFile: Integer;
       Version: array[0..3] of char;
       Unknown1: array[0..11] of char;
       Unknown2: Integer;
       DataOffset: Integer;
       Unknown3: Integer;
       DirOffset: Integer;
       DirNum: integer;
     end;
     DRSEntry = packed record
       Unknown: integer;
       Offset: integer;
       Size: integer;
     end;

const
  DRSID : String = 'Copyright (c) 1997 Ensemble Studios.';
  DRSVer : String = '1.00';

function ReadAoe2DRS(src: string): Integer;
var HDR: DRSHeader;
    ENT: DRSEntry;
    disp: string;
    NumE, x: integer;
    BufTest: array[0..3] of Char;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    FileSeek(Fhandle,0,0);
    FileRead(FHandle,HDR.ID,36);
    FileRead(FHandle,HDR.EndOfFile,4);
    FileRead(FHandle,HDR.Version,4);
    FileRead(FHandle,HDR.Unknown1,12);
    FileRead(FHandle,HDR.Unknown2,4);
    FileRead(FHandle,HDR.DataOffset,4);
    FileRead(FHandle,HDR.Unknown3,4);
    FileRead(FHandle,HDR.DirOffset,4);
    FileRead(FHandle,HDR.DirNum,4);

    if HDR.ID <> DRSID then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadAoe2DRS := -3;
      ErrInfo.Format := 'DRS';
      ErrInfo.Games := 'Age of Empires 2: Age of Kings';
    end
    else
    begin

      NumE := HDR.DirNum;

      for x:= 1 to NumE do
      begin
        Per := ROund(((x / NumE)*100));
        SetPercent(Per);
        FileSeek(FHandle,HDR.DirOffset+(x-1)*12,0);
        FileRead(FHandle,ENT.Unknown,4);
        FileRead(FHandle,ENT.Offset,4);
        FileRead(FHandle,ENT.Size,4);
        disp := IntToStr(ENT.Unknown);
        disp := Copy('0000000000'+disp,length(disp)+1,10);

        FileSeek(FHandle,ENT.Offset,0);
        FileRead(FHandle,BufTest,4);

        if BufTest = '2.0N' then
          disp := disp + '.slp'
        else if BufTest = 'RIFF' then
        begin
          FileSeek(FHandle,ENT.Offset + 8,0);
          FileRead(FHandle,BufTest,4);
          if BufTest = 'WAVE' then
            disp := disp + '.wav'
          else
            disp := disp + '.raw';
        end
        else
          disp := disp + '.txt';

        FSE_Add(disp,ENT.Offset,ENT.Size,0,0);
      end;

      ReadAoe2DRS := NumE;

      DrvInfo.ID := 'DRS';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    ReadAoe2DRS := -2;

end;

// -------------------------------------------------------------------------- //
// Age of Empire 3 .BAR support ============================================= //
// -------------------------------------------------------------------------- //

type AOE3BAR_Header = packed record
       ID: array[0..3] of char;       // "ESPN"
       Unknown1: integer;             // Always 2 (version?)
       Unknown2: integer;             // Always 11 22 33 44 ?
       Unknown3: array[0..65] of integer;
       Unknown4: integer;
       NumEntries: integer;
       DirOffset: integer;
       Unknown6: integer;
     end;
     // BasedirName: get32w
     // NumEntries: integer;
     AOE3BAR_Entry = packed record
       Offset: integer;
       Size: integer;
       Size2: integer;                // Uncompressed size?
       Unknown1: integer;
       Unknown2: integer;
       Unknown3: integer;
       Unknown4: integer;
     end;
     // Filename: get32w

function Get32w(src: integer): string;
var wString: WideString;
    tint: Integer;
begin

  FileRead(src,tint,4);
  SetLength(wString,tint);
  FileRead(src,Pointer(wString)^,tint*2);

  result := UTF8Encode(wString);

end;

function ReadAgeOfEmpires3BAR: Integer;
var HDR: AOE3BAR_Header;
    ENT: AOE3BAR_Entry;
    disp, basedir: string;
    NumE, oldper, x: integer;
begin

  FileSeek(Fhandle,0,0);
  FileRead(FHandle,HDR,SizeOf(HDR));

  if HDR.ID <> 'ESPN' then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'AOE3BAR';
    ErrInfo.Games := 'Age of Empires 3';
  end
  else
  begin

    NumE := HDR.NumEntries;

    FileSeek(FHandle,HDR.DirOffset,0);
    basedir := Get32w(FHandle);
    FileSeek(FHandle,4,1);

    OldPer := 0;

    for x:= 1 to NumE do
    begin
      Per := ROund(((x / NumE)*100));
      if (Per > OldPer + 5) then
      begin
        SetPercent(Per);
        OldPer := Per;
      end;
      FileRead(FHandle,ENT,SizeOf(ENT));
      disp := get32w(FHandle);

      FSE_Add(basedir+disp,ENT.Offset,ENT.Size,0,0);
    end;

    Result := NumE;

    DrvInfo.ID := 'BAR';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// Age of Mythology .BAR support ============================================ //
// -------------------------------------------------------------------------- //

type BARHeader = packed record
       ID: array[0..7] of char;
       Unknown: integer;  // Checksum/CRC ?
       NumEntries: integer;
       DirSize: integer;
       DirOffset: integer;
       Unknown2: integer; // Always 8 .. flags ?
     end;
     BAREntry = packed record
       Offset: integer;
       Size: integer;
       Size2: integer;
       Unknow1: integer;
       Unknow2: integer;
     end;
     // get0 filename

const BARID : array[0..7] of char = #0+#0+#0+#0+#0+#0+#0+#0;

function ReadAgeOfMythologyBAR: Integer;
var HDR: BARHeader;
    ENT: BAREntry;
    disp: string;
    NumE, x: integer;
begin

  FileSeek(Fhandle,0,0);
  FileRead(FHandle,HDR,SizeOf(BARHeader));

  if HDR.ID <> BARID then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'BAR';
    ErrInfo.Games := 'Age of Mythology';
  end
  else
  begin

    NumE := HDR.NumEntries;

    FileSeek(FHandle,HDR.DirOffset+(4*NumE),0);

    for x:= 1 to NumE do
    begin
      Per := ROund(((x / NumE)*100));
      SetPercent(Per);
      FileRead(FHandle,ENT,SizeOf(BAREntry));
      disp := strip0(get0(FHandle));

      FSE_Add(disp,ENT.Offset,ENT.Size,ENT.Unknow1,ENT.Unknow2);
    end;

    Result := NumE;

    DrvInfo.ID := 'BAR';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// AGON .SFL ================================================================ //
// -------------------------------------------------------------------------- //

// Support added thanks to the Xentax wiki page:
// http://wiki.xentax.com/index.php?title=GRAF:AGON_SFL
type SFLHeader = packed record
       ID: array[0..4] of char;                // SFL10
       FoldersDirOffset: integer;              //
       FilesDirOffset: integer;                //
       FilenameDirOffset: integer;             //
       NumberOfFolders: integer;               //
       NumberOfFiles: integer;                 //
       FilenameDirLength: integer;             //
     end;

function ReadAgonSFL(src: string): Integer;
var HDR: SFLHeader;
    NameOffset, FileID, Offset, Size, TotSize, x: Integer;
//    ParentID, UnkID, y: integer;
    foldersBuffer, filesBuffer, nameBuffer: TMemoryStream;
    handle_stm: THandleStream;
//    dirNames: array of string;
    nameStr: string;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    TotSize := FileSeek(Fhandle, 0, 2);
    FileSeek(Fhandle,0,0);
    FileRead(FHandle, HDR, SizeOf(SFLHeader));

    // Some verifications of the header to be sure it is an AGON .SFL file
    if (HDR.ID <> 'SFL10') or (HDR.FoldersDirOffset > TotSize) or (HDR.FilesDirOffset > TotSize) or ((HDR.FilenameDirOffset + HDR.FilenameDirLength) > TotSize) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'SFL10';
      ErrInfo.Games := 'AGON';
    end
    else
    begin

      // Create a HandleStream from the source file
      handle_stm := THandleStream.Create(Fhandle);

      // Seek to the Folders Directory Offset
      handle_stm.Seek(HDR.FoldersDirOffset,soBeginning);

      // Create the Folders Directory buffer stream
      foldersBuffer := TMemoryStream.Create;

      // Read the complete folders directory to the buffer
      foldersBuffer.CopyFrom(handle_stm,(HDR.NumberOfFolders * 16)-4);

      // Seek to the Files Directory Offset
      handle_stm.Seek(HDR.FilesDirOffset,soBeginning);

      // Create the Files Directory buffer stream
      filesBuffer := TMemoryStream.Create;

      // Read the complete files directory to the buffer
      filesBuffer.CopyFrom(handle_stm,(HDR.NumberOfFiles * 17));

      // Seek to the Name Directory Offset
      handle_stm.Seek(HDR.FilenameDirOffset,soBeginning);

      // Create the Names Directory buffer stream
      nameBuffer := TMemoryStream.Create;

      // Read the complete names directory to the buffer
      nameBuffer.CopyFrom(handle_stm,HDR.FilenameDirLength);

      foldersBuffer.Seek(0,0);
      filesBuffer.Seek(0,0);
      nameBuffer.Seek(0,0);

// This is the directory names support, but I don't know how to link the directory with the filenames
{      setLength(dirNames,HDR.NumberOfFolders);

      for x := 0 to HDR.NumberOfFolders-1 do
      begin
        dirNames[x] := '';
      end;

      for x := 1 to HDR.NumberOfFolders do
      begin
        foldersBuffer.Read(NameOffset,4);
        nameBuffer.Seek(NameOffset,0);
        nameStr := strip0(get0(nameBuffer));
        dirNames[x-1] := dirNames[x-1]+'-'+nameStr;
        foldersBuffer.Read(FileID,4);
        foldersBuffer.Read(ParentID,4);
        if x <> HDR.NumberOfFolders then
        begin
          foldersBuffer.Read(UnkID,4);
        end
        else
          UnkID := -2;
        for y := 1 to ParentID do
          dirNames[x+y-1] := dirNames[x-1];
        FSE_Add('FOLDERS\'+dirNames[x-1]+' '+inttostr(FileID)+' '+inttostr(ParentID)+' '+inttostr(UnkID),x,1,-1,-1);
      end;}

      for x := 1 to HDR.NumberOfFiles do
      begin

        filesBuffer.Read(NameOffset,4);
        filesBuffer.Seek(1,1);
        nameBuffer.Seek(NameOffset,0);
        nameStr := strip0(get0(nameBuffer));
        filesBuffer.Read(FileID,4);
        filesBuffer.Read(Offset,4);
        filesBuffer.Read(Size,4);
        FSE_Add(nameStr,offset,Size,FileID,-1);
      end;

      result := HDR.NumberOfFiles;

      DrvInfo.ID := 'SFL10';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Aliens vs. Predator .ASR support ========================================= //
// -------------------------------------------------------------------------- //

// Structure of an uncompressed ASR file:
//    AsuraMagic
//    Blocks
//       Block 1 Header
//       Block 1 Content
//         ..
//       Final block header (filled with 0x00)

// Structure of an compressed ASR file:
//    AsuraZlbMagic
//    EmptyBytes : integer (= 0)
//    CompressedSize : integer
//    UncompressedSize : integer
//    Zlib compressed Asura file (see structure of uncompressed ASR file)

// Known (parsed) block types
//   ASTS - Contains all streaming sounds (Music/Ambient sounds)
//          NumberOfEntries : Integer;
//          Entries format:
//            Filename : Get0;
//            FilenamePadding = 4 - (length(Filename) mod 4) - 1;
//            FileSize : integer;
//            AbsoluteFileOffset : integer;
//          Data
//   RCSF - Contains a unique resource file
//          TypeOfResource : Integer;       // 2 = Texture  3 = Sound
//          Unknown : Integer;
//          FileSize : integer;
//          FileName : Get0;
//          FilenamePadding = 4 - (length(Filename) mod 4) - 1;
//          FileData : array[1..FileSize] of byte;
//   RSFL - Contains a list of resources with offsets relative to the RSFL block
//          NumberOfEntries : Integer;
//          Entries format:
//            Filename : Get0;
//            FilenamePadding = 4 - (length(Filename) mod 4) - 1;
//            FileSize : integer;
//            Unknown : integer;
//            RelativeFileOffset : integer;
//          Data

// Unknown block types (probably not complete):
//   apas
//   DLEV
//   FAAN
//   FACE
//   FNFO
//   FONT
//   FSX2
//   FXET
//   FXPT
//   FXST
//   HANM
//   HMPT
//   hpas
//   HSBB
//   HSKL
//   HSKN
//   HSND
//   MARE
//   MTRL
//   ppas
//   SDEV
//   SDSM
//   TXAN

const AsuraMagic = 'Asura   ';
const AsuraZlbMagic = 'AsuraZlb';
type AsuraBlockHeader = packed record
       BlockID: array[0..3] of Char;
       BlockSize: cardinal;          // Including header
       Unknown1: integer;
       Unknown2: integer;
     end;

function DecompressAzuraZToStream(FHandle: integer; OutputStream: TStream; Offset, Size: Int64) : Boolean;
var
  InputStream: THandleStream;
  DStream: TDecompressionStream;
  FinalSize: integer;
begin

  InputStream := THandleStream.Create(Fhandle);
  try
    InputStream.Seek(20, soBeginning);

    DStream := TDecompressionStream.Create(InputStream);
    try
      DStream.Seek(Offset,soFromBeginning);
      FinalSize := OutputStream.CopyFrom(DStream,Size);
    finally
      FreeAndNil(DStream);
    end

  finally
    FreeAndNil(InputStream);
  end;

  Result := FinalSize = Size;

End;

function ReadAvpAsuraStm(src: TStream; FileTotSize: int64; Compressed: Byte): integer;
var BlockHDR: AsuraBlockHeader;
    CurPos: int64;
    SeekResult, NumberOfEntries, TotalNumberOfEntries, x, NSize: integer;
    Offset, Size: cardinal;
    disp: string;
    OldPercent, SavedOldPercent: integer;
begin

  TotalNumberOfEntries := 0;
  SavedOldPercent := 0;
  OldPercent := -1;

  repeat

    // Store current position in stream
    CurPos := Src.Seek(0,soFromCurrent);

    // Read the block header
    Src.ReadBuffer(BlockHDR,SizeOf(AsuraBlockHeader));

    // This is a sound entries block
    if (BlockHDR.BlockID = 'ASTS') then
    begin

      // Retrieve the number of entries
      Src.ReadBuffer(NumberOfEntries,4);

      SavedOldPercent := OldPer;
      OldPercent := -1;

      // For each entry
      for x:= 1 to NumberOfEntries do
      begin

        // Percentage done display
        Per := ROund(((x / NumberOfEntries)*100));
        if (Per >= (OldPercent+1)) then
        begin
          SetPercent(Per);
          OldPercent := Per;
        end;

        // Get the entry name (0x00 ended)
        disp := Strip0(Get0(Src));

        // Calculate how many extra 0x00 are at the end of the entry
        // Seek to the new position if needed
        NSize := 4 - (length(disp) mod 4);
        if NSize > 0 then
          Src.Seek(NSize,soFromCurrent);

        // Read the Size
        Src.ReadBuffer(Size,4);

        // Read the Offset
        Src.ReadBuffer(Offset,4);

        // Add entry
        FSE_Add(disp,Offset,Size,Nsize,0);

      end;

      inc(TotalNumberOfEntries,NumberOfEntries);
      OldPercent := SavedOldPercent;

    end
    // RSFL - This is a ressource file list
    else if (BlockHDR.BlockID = 'RSFL') then
    begin

      // Retrieve the number of entries
      Src.ReadBuffer(NumberOfEntries,4);

      SavedOldPercent := OldPercent;
      OldPercent := -1;

      // For each entry
      for x:= 1 to NumberOfEntries do
      begin

        // Percentage done display
        Per := ROund(((x / NumberOfEntries)*100));
        if (Per >= (OldPercent+1)) then
        begin
          SetPercent(Per);
          OldPercent := Per;
        end;

        // Get the entry name (0x00 ended)
        disp := Strip0(Get0(Src));

        // Calculate how many extra 0x00 are at the end of the entry
        // Seek to the new position if needed
        NSize := 4 - (length(disp) mod 4) - 1;
        if NSize > 0 then
          Src.Seek(NSize,soFromCurrent);

        // Read the Offset
        Src.ReadBuffer(Offset,4);

        // Read the Size
        Src.ReadBuffer(Size,4);

        // Read unknown
        Src.ReadBuffer(NSize,4);

        // Add entry
        FSE_Add(disp,Offset+BlockHDR.BlockSize,Size,NSize,Compressed);

      end;

      inc(TotalNumberOfEntries,NumberOfEntries);
      OldPercent := SavedOldPercent;

    end
    // RSCF - This is a ressource file block
    else if (BlockHDR.BlockID = 'RSCF') then
    begin

      // Percentage parsed display
      Per := ROund(((CurPos / FileTotSize)*100));
      if (Per >= (OldPer+1)) then
      begin
        SetPercent(Per);
        OldPer := Per;
      end;

      // Bypass the 8 bytes we don't use
      Src.Seek(8,soFromCurrent);

      // Read the Size
      Src.ReadBuffer(Size,4);

      // Get the entry name (0x00 ended)
      disp := Strip0(Get0(Src));

      // Calculate how many extra 0x00 are at the end of the entry
      // Seek to the new position if needed
      NSize := 4 - (length(disp) mod 4) - 1;
      if NSize > 0 then
        Src.Seek(NSize,soFromCurrent);

      // Get the offset
      Offset := Src.Seek(0,soFromCurrent);

      // Add entry
      if leftstr(disp,1) = '\' then
        disp := RightStr(disp,length(disp)-1);

      FSE_Add(disp,Offset,Size,Nsize,Compressed);

      inc(TotalNumberOfEntries);

    end;

    // Go to next block
    SeekResult := Src.Seek(CurPos+BlockHDR.BlockSize,SoFromBeginning);

  // Stop when any of the following is true: the block is empty
  //                                         the block size is empty
  //                                         the new position after the current block is past the end of file
  //                                         the last seek action failed
  until ((BlockHDR.BlockID = chr(0)+chr(0)+chr(0)+chr(0))
      or (BlockHDR.BlockSize = 0)
      or ((BlockHDR.BlockSize + CurPos + SizeOf(AsuraBlockHeader)) >= FileTotSize)
      or (SeekResult = -1)
      or (SeekResult = FileTotSize));

  result := TotalNumberOfEntries;

end;

function ReadAvpAsura(src: string): integer;
var ID: array[0..7] of char;
    CompSize, DecompSize, checkVal: cardinal;
    decStm: TDecompressionStream;
    srcStm: THandleStream;
    FileTotSize: Int64;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    FileTotSize := FileSeek(Fhandle,0,2);
    FileSeek(Fhandle,0,0);
    FileRead(FHandle,ID,8);

    // There are 2 Asura formats
    // The first one is not compressed
    // So we pass it directly to ReadAvpAsuraStm() as a THandleStream
    if ID = AsuraMagic then
    begin
      srcStm := THandleStream.Create(FHandle);
      try
        result := ReadAvpAsuraStm(srcStm,FileTotSize,0);
      finally
        FreeAndNil(srcStm);
      end;

      DrvInfo.ID := 'Asura';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;
    end
    // The second one is Zlib compressed
    // So we pass it to ReadAvpAsuraStm() as a TDecompressionStream
    else if ID = AsuraZlbMagic then
    begin
      srcStm := THandleStream.Create(FHandle);
      try
        srcStm.ReadBuffer(CheckVal,4);
        srcStm.ReadBuffer(CompSize,4);
        srcStm.ReadBuffer(DecompSize,4);
        if (CheckVal <> 0) or ((CompSize+20) > FileTotSize) then
        begin
          FileClose(Fhandle);
          FHandle := 0;
          Result := -3;
          ErrInfo.Format := 'AsuraZ';
          ErrInfo.Games := 'Alien vs Predator';
        end
        else
        begin
          decStm := TDecompressionStream.Create(srcStm);
          try
            decStm.ReadBuffer(ID,8);
            if (ID <> AsuraMagic) then
            begin
              FileClose(Fhandle);
              FHandle := 0;
              Result := -3;
              ErrInfo.Format := 'AsuraZ';
              ErrInfo.Games := 'Alien vs Predator';
            end
            else
            begin
              result := ReadAvpAsuraStm(decStm,DecompSize-4,1);
              DrvInfo.ID := 'AsuraZ';
              DrvInfo.Sch := '\';
              DrvInfo.FileHandle := FHandle;
              DrvInfo.ExtractInternal := True;
            end;
          except
            FreeAndNil(decStm);
            FileClose(Fhandle);
            FHandle := 0;
            Result := -3;
            ErrInfo.Format := 'AsuraZ';
            ErrInfo.Games := 'Alien vs Predator';
          end;
        end;
      finally
        FreeAndNil(srcStm);
      end;
    end
    else
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'Asura';
      ErrInfo.Games := 'Alien vs Predator';
    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Alien vs Predator .FFL support =========================================== //
// -------------------------------------------------------------------------- //

function ReadAvpCFFL(): Integer;
var ENT: word;
    numE,offset,size: integer;
    disp: string;
    ID: array[0..3] of char;
begin

  FileSeek(FHandle,0,0);
  FileRead(Fhandle,ENT,2);
  numE := 0;

  while ENT <> 65535 do
  begin
    disp := strip0(get0(FHandle));
    Offset := FileSeek(FHandle,0,1);
    FileRead(FHandle,ID,4);
    FileRead(FHandle,Size,4);

    FSE_Add(disp,Offset,Size+8,0,0);

    inc(numE);
    FileSeek(FHandle,Size,1);
    FileRead(Fhandle,ENT,2);
  end;

  if numE = 0 then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    ReadAvpCFFL := -3;
    ErrInfo.Format := 'CFFL';
    ErrInfo.Games := 'Alien vs Predator';
  end
  else
  begin

    DrvInfo.ID := 'CFFL';
    DrvInfo.Sch := '';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

    ReadAvpCFFL := numE;

  end;

end;

type RFFLHeader = packed record
       ID: array[0..3] of Char;
       Version: integer;
       Dirnum: integer;
       DirSize: integer;
       DataSize: integer;
     end;
     RFFLEntry = packed record
       Offset: integer;
       Size: integer;
     end;

function ReadAvpRFFL(src: string): Integer;
var HDR: RFFLHeader;
    ENT: RFFLEntry;
    disp: string;
    NumE, x: integer;
    NSize: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    FileSeek(Fhandle,0,0);
    FileRead(FHandle,HDR.ID,4);
    FileRead(FHandle,HDR.Version,4);
    FileRead(FHandle,HDR.DirNum,4);
    FileRead(FHandle,HDR.DirSize,4);
    FileRead(FHandle,HDR.DataSize,4);

    if HDR.ID <> 'RFFL' then
    begin
      if Uppercase(ExtractFileName(src)) = 'COMMON.FFL' then
        ReadAvpRFFL := ReadAvpCFFL
      else
      begin
        FileClose(Fhandle);
        FHandle := 0;
        ReadAvpRFFL := -3;
        ErrInfo.Format := 'RFFL';
        ErrInfo.Games := 'Alien vs Predator';
      end;
    end
    else
    begin

      NumE := HDR.DirNum;

      for x:= 1 to NumE do
      begin
        Per := ROund(((x / NumE)*100));
        SetPercent(Per);
        FileRead(FHandle,ENT.Offset,4);
        FileRead(FHandle,ENT.Size,4);
        disp := Strip0(Get0(FHandle));

        if ((length(disp)+1) mod 4) > 0 then
        begin
          NSize := ((Trunc(((length(disp)+1) / 4)) + 1) * 4) - (length(disp)+1);
          FileSeek(FHandle,NSize,1);
        end;

        FSE_Add(disp,ENT.Offset,ENT.Size,0,0);
      end;

      ReadAvpRFFL := NumE;

      DrvInfo.ID := 'RFFL';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    ReadAvpRFFL := -2;

end;

// -------------------------------------------------------------------------- //
// Artifex Mundi .CUB support =============================================== //
// -------------------------------------------------------------------------- //

type CUBEHeader = packed record
        ID: array[0..3] of char;  // "cub" 0x00
        Version: array[0..3] of char;  // "1.0" 0x00
        NumEntries: longword;
        Description: array[0..255] of char;
     end;
     CUBEEntry = packed record
        FileName: array[0..255] of char;
        offset: longword;
        size: longword;
     end;
const CUBEXORByte: byte = $96;
      CUBEXORLongWord: longword = $96969696;

function UnXORstr(src: array of char; xorbyte: byte): string;
var x: integer;
begin

  result := '';

  for x := 0 to length(src)-1 do
    result := result + chr(ord(src[x]) xor xorbyte);

end;

function ReadArtifexMundiCUB(src: string): Integer;
var HDR: CUBEHeader;
    ENT: CUBEEntry;
    disp: string;
    x: integer;
    TotFSize: cardinal;
    memstm: TMemoryStream;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    TotFSize := FileSeek(FHandle,0,2);
    FileSeek(Fhandle,0,0);
    FileRead(FHandle,HDR,SizeOf(CUBEHeader));
    StrPLCopy(HDR.ID,UnXORStr(HDR.ID,CUBEXORByte),4);
    StrPLCopy(HDR.Version,UnXORStr(HDR.Version,CUBEXORByte),4);
    HDR.NumEntries := HDR.NumEntries xor CUBEXORLongWord;

    if (HDR.ID[0] <> 'c') and (HDR.ID[1] <> 'u') and (HDR.ID[2] <> 'b') and (ord(HDR.ID[3]) <> 0) and
       (HDR.Version[0] <> '1') and (HDR.Version[1] <> '.') and (HDR.Version[2] <> '0') and (ord(HDR.Version[3]) <> 0) and
       (((HDR.NumEntries * SizeOf(CUBEEntry))+SizeOf(CUBEHeader)) > TotFSize)
    then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'CUB';
      ErrInfo.Games := 'Artifex Mundi';
    end
    else
    begin

      memstm := TMemoryStream.Create;
      BinCopyToStream(FHandle,memstm,FileSeek(FHandle,0,1),SizeOf(CUBEEntry)*HDR.NumEntries,0,BUFFER_SIZE,false,setPercent,CUBEXorByte);

      for x:= 1 to HDR.NumEntries do
      begin
        memstm.Seek((x-1)*SizeOf(CUBEEntry),0);
        memstm.Read(ENT,SizeOf(ENT));
        disp := Strip0(ENT.FileName);
        FSE_Add(disp,ENT.Offset,ENT.Size,0,0);
      end;

      FreeAndNil(memstm);

      result := HDR.NumEntries;

      DrvInfo.ID := 'CUB';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Ascaron .CPR support ===================================================== //
// -------------------------------------------------------------------------- //

type CPRID = packed record
        ID: array[0..31] of char;  // "ASCARON_ARCHIVE V0.9" Right padded with 0x00
     end;
     CPRHeader = packed record
        SubID: integer;
        Size: integer;
        NumE: integer;
        NextRelOffset: integer;
     end;
     CPREntry = packed record
        offset: integer;
        size: integer;
        Unknown: integer;
     end;
     // Get0 FileName

function ReadAscaronCPR(src: string): Integer;
var ID: CPRID;
    HDR: CPRHeader;
    ENT: CPREntry;
    disp: string;
    NumE, x, smallerOffset, res, lastOffset: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    FileSeek(Fhandle,0,0);
    FileRead(FHandle,ID,SizeOf(ID));

    if ID.ID <> 'ASCARON_ARCHIVE V0.9' then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'CPR';
      ErrInfo.Games := 'Port Royale';
    end
    else
    begin


      NumE := 0;
      //lastOffset := 0;
      repeat
        lastOffset := FileSeek(FHandle,0,1);
        FileRead(FHandle,HDR,SizeOf(HDR));


      //  ShowMessage(inttostr(HDR.SubID));
        smallerOffset := HDR.NextRelOffset+HDR.Size+FileSeek(FHandle,0,1);

        for x:= 1 to HDR.NumE do
        begin
//        Per := ROund(((x / NumE)*100));
//        SetPercent(Per);
          FileRead(FHandle,ENT,SizeOf(ENT));
          disp := Strip0(get0(FHandle));

          if ENT.offset < smallerOffset then
            smallerOffset := ENT.offset;

          if length(disp) > 0 then
          begin
            inc(NumE);
            FSE_Add(disp,ENT.Offset,ENT.Size,ENT.Unknown,0);
          end;
        end;

        res := FileSeek(FHandle,HDR.NextRelOffset+smallerOffset,0);
      until ((res = -1) or (lastOffset = (HDR.NextRelOffset+smallerOffset)));

      result := NumE;

      DrvInfo.ID := 'CPR';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Ascendancy .COB ========================================================== //
// -------------------------------------------------------------------------- //

function ReadAscendancyCOB(src: string): Integer;
var entryList: array of Integer;
    nameList: array of string;
    headerBuffer: TMemoryStream;
    handle_stm: THandleStream;
    numEntries, TotSize, x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    TotSize := FileSeek(Fhandle, 0, 2);
    FileSeek(Fhandle,0,0);
    FileRead(FHandle, numEntries, 4);

    // A small verification (better sanity checks will be done after)
    if ((4+numEntries*54) >= TotSize) and (numEntries > 65535) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'COB';
      ErrInfo.Games := 'Ascendancy';
    end
    else
    begin

      // Create a HandleStream from the source file
      handle_stm := THandleStream.Create(Fhandle);

      // Seek to the Directory Offset
      handle_stm.Seek(4,soBeginning);

      // Create the Directory buffer stream
      headerBuffer := TMemoryStream.Create;

      // Read the complete directory to the buffer
      headerBuffer.CopyFrom(handle_stm,(numEntries*54));

      // Free the handle stream, useless now
      FreeAndNil(handle_stm);

      headerBuffer.Seek(0,0);

      SetLength(entryList,numEntries);
      SetLength(nameList,numEntries);

      for x := 0 to numEntries-1 do
      begin
        headerBuffer.Seek(x*50,0);
        nameList[x] := strip0(get0(headerBuffer));
      end;

      for x := 0 to numEntries-1 do
      begin
        headerBuffer.Seek((numEntries*50)+x*4,0);
        headerBuffer.Read(entryList[x],4);
        if (entryList[x] > TotSize) or ((x > 0) and (entryList[x-1] >= entryList[x])) then
        begin
          FileClose(Fhandle);
          FHandle := 0;
          Result := -3;
          ErrInfo.Format := 'COB';
          ErrInfo.Games := 'Ascendancy';
          Exit;
        end;
      end;

      for x := 1 to numEntries-1 do
        FSE_Add(nameList[x-1],entryList[x-1],entryList[x]-entryList[x-1],0,0);

      FSE_Add(nameList[numEntries-1],entryList[numEntries-1],Totsize-entryList[numEntries-1],0,0);

      SetLength(nameList,0);
      SetLength(entryList,0);

      result := numEntries;

      DrvInfo.ID := 'COB';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Assassin's Creed .FORGE support ================================== PARTIAL //
// -------------------------------------------------------------------------- //

{IFDEF EXPFORMATS}

type FORGEHeader = packed record
        MagicID: array[0..8] of char; // 'scimitar' + #0
        Unknown1: integer;
        OffsetToEntries: int64;
        Unknown2: integer;        // Always 0x10 ?
        Unknown3: integer;        // Alwars 0x1 ?
     end;
     FORGEHashHeader = packed record
        NumberOfEntries: integer;
        Unknown1: integer;
        Unknown200: integer;      // Always 0x00 00 00 00 ?
        Unknown300: integer;      // Always 0x00 00 00 00 ?
        Unknown4FF: integer;      // Always 0xFF FF FF FF ?
        Unknown5FF: integer;      // Always 0xFF FF FF FF ?
        Unknown6: integer;
        Unknown7: integer;
        Unknown8Offset: int64;
        NumberOfEntries2: integer;
        Unknown9: integer;
        OffsetToHashEntries: int64;
        Unknown10FF: integer;      // Always 0xFF FF FF FF ?
        Unknown11FF: integer;      // Always 0xFF FF FF FF ?
        Unknown1200: integer;      // Always 0x00 00 00 00 ?
        Unknown13: integer;
        OffsetToEntries: int64;
        Unknown14Offset: int64;    // Offset to somewhere after the Entries, but there do not seem to be anything interessant there...
     end;
     FORGEHashEntry = packed record
        OffsetToFileData: int64;
        EntryHash: integer;       // Entry Hash?
        SizeOfFileData: integer;
     end;
     FORGEEntry = packed record
        EntrySize: integer;
        Unknown2: integer;
        Unknown3: integer;
        UnknownEmpty1: integer;                  // Always 0 ?
        UnknownEmpty2: integer;                  // Always 0 ?
        UnknownEmpty3: integer;                  // Always 0 ?
        UnknownEmpty4: integer;                  // Always 0 ?
        EntryIndex1: integer;                    // Starts at 0 then 1, 2, 3, .. ,last entry is -1
        EntryIndex2: integer;                    // Starts at -1 then 0, 1, 2, .. ,last entry is NumberofEntries-2
        UnknownEmpty5: integer;                  // Always 0 ?
        EntryFileTime: integer;                  // t_time structure 32bits
        EntryName: array[0..127] of char;        // #0 terminated
        Unknown12: integer;
        Unknown13: integer;
        Unknown14: integer;
        Unknown15: integer;
     end;
     // 13CEE       EE 3C 01 00
     // 1C1800      00 18 1C 00
     // 03 38 21 E0     E0 21 38 03         54010336

const
  FORGEID : array[0..9] of char = 'scimitar'+#0;

function ReadAssassinsCreedFORGE(src: string): Integer;
var HDR: FORGEHeader;
    HashHDR: FORGEHashHeader;
    HashENT: FORGEHashEntry;
    ENT: FORGEEntry;
    disp: string;
    NumE, x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    FileSeek(Fhandle,0,0);
    FileRead(FHandle,HDR,SizeOf(FORGEHeader));

    if (LeftStr(HDR.MagicID,8) <> LeftStr(FORGEID,8))
    or (HDR.MagicID[8] <> FORGEID[8]) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'FORGE';
      ErrInfo.Games := 'Assassin''s Creed';
    end
    else
    begin

      FileSeek(Fhandle,HDR.OffsetToEntries,0);
      FileRead(Fhandle,HashHDR,SizeOf(FORGEHashHeader));

      NumE := HashHDR.NumberOfEntries2;

      for x:= 1 to NumE do
      begin
        Per := ROund(((x / NumE)*100));
        SetPercent(Per);
        FileSeek(Fhandle,HashHDR.OffsetToHashEntries+(x-1)*SizeOf(FORGEHashEntry),0);
        FileRead(FHandle,HashENT,SizeOf(FORGEHashEntry));
        FileSeek(Fhandle,HashHDR.OffsetToEntries+(x-1)*SizeOf(FORGEEntry),0);
        FileRead(FHandle,ENT,SizeOf(FORGEEntry));
        disp := strip0(ENT.EntryName);

        FSE_Add(disp,HashENT.OffsetToFileData,HashENT.SizeOfFileData,HashENT.EntryHash,0);
      end;

      Result := NumE;

      DrvInfo.ID := 'FORGE';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    Result := -2;

end;

{ENDIF}

// -------------------------------------------------------------------------- //
// Astebreed .TGP =========================================================== //
// -------------------------------------------------------------------------- //

type TGP0Header = packed record
        MagicID: array[0..3] of char; // 'TGP0'
        Version: Word;                // 1 or 2
     end;
     TGP0HeaderVersion1 = packed record
        Unused: Word;
        Flags: Cardinal;              // 0x01 = Encrypted Data (XOR 0x46)
        NumberOfEntries: cardinal;
     end;
     TGP0HeaderVersion2 = packed record
        Flags: Word;                  // 0x02 = Compressed Data (Entire data block is a gzip archive)
        NumberOfEntries: cardinal;
        UncompressedDataSize: cardinal;
     end;
     TGP0EntryVersion1 = packed record
        FileName: array[0..95] of char;
        Offset: cardinal;              // Relative to start of file
        Unknown1: cardinal;
        Size: cardinal;
        Unknown2: cardinal;
     end;
     TGP0EntryVersion2 = packed record
        FileName: array[0..95] of char;
        Offset: cardinal;              // Relative to data block offset
        Size: cardinal;
        Unknown1: cardinal;
        Unknown2: cardinal;
     end;

function ReadAstebreedTGP(src: string): Integer;
var ENT1: TGP0EntryVersion1;
    ENT2: TGP0EntryVersion2;
    headerBuffer: TMemoryStream;
    handle_stm: THandleStream;
    x, Offset: integer;
    TotSize: cardinal;
    HDR: TGP0Header;
    HDR1: TGP0HeaderVersion1;
    HDR2: TGP0HeaderVersion2;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);
  Result := -3;

  if FHandle > 0 then
  begin

    // Retrieve total size
    TotSize := FileSeek(Fhandle, 0, 2);

    // Retrieve header
    FileSeek(Fhandle,0,0);
    FileRead(FHandle, HDR, SizeOf(TGP0Header));

    // Sanity checks:
    //   Magic ID should be TGP0
    //   Only version 1 & 2 are supported
    if ((HDR.MagicID) <> 'TGP0') or ((HDR.Version <> 1) and (HDR.Version <> 2)) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'TGP0';
      ErrInfo.Games := 'Astebreed, Ether Vapor Remaster, Faery Bloom Fresia';
    end
    else if (HDR.Version = 1) then
    begin

      // Reading version 1 header
      FileRead(FHandle, HDR1, SizeOf(TGP0HeaderVersion1));

      //   Total Size of Directory + Header cannot be bigger than the full file size
      if ((HDR1.NumberOfEntries*SizeOf(TGP0EntryVersion1)+SizeOf(TGP0Header)+SizeOf(TGP0HeaderVersion1)) > TotSize) then
      begin

        FileClose(Fhandle);
        FHandle := 0;
        Result := -3;
        ErrInfo.Format := 'TGP0';
        ErrInfo.Games := 'Ether Vapor Remaster, Fairy Bloom Fresia';

      end
      else
      begin

        // Create a HandleStream from the source file
        handle_stm := THandleStream.Create(Fhandle);

        // Seek to the Directory Offset
        handle_stm.Seek(SizeOf(TGP0Header)+SizeOf(TGP0HeaderVersion1),soBeginning);

        // Create the Directory buffer stream
        headerBuffer := TMemoryStream.Create;

        // Read the complete directory to the buffer
        headerBuffer.CopyFrom(handle_stm,HDR1.NumberOfEntries*SizeOf(TGP0EntryVersion1));

        // Free the handle stream, useless now
        FreeAndNil(handle_stm);

        // Seek to the start of the stream
        headerBuffer.Seek(0,0);

        // Go through all entries
        for x := 0 to HDR1.NumberOfEntries-1 do
        begin
          // Seek to current position in Directory
          headerBuffer.Seek(x*SizeOf(TGP0EntryVersion1),0);

          // Read entry
          headerBuffer.Read(ENT1,SizeOf(TGP0EntryVersion1));

          // Add entry (storing header flags in DataX)
          FSE_Add(strip0(ENT1.FileName),ENT1.Offset,ENT1.Size,HDR1.Flags,0);
        end;

        result := HDR1.NumberOfEntries;

        // Extract from the plugin only if crypted or compressed
        DrvInfo.ID := 'TGP0';
        DrvInfo.Sch := '\';
        DrvInfo.FileHandle := FHandle;
        DrvInfo.ExtractInternal := (HDR2.Flags AND $1 = $1);
      end;
    end
    else if (HDR.Version = 2) then
    begin

      // Reading version 2 header
      FileRead(FHandle, HDR2, SizeOf(TGP0HeaderVersion2));

      //   Total Size of Directory + Header cannot be bigger than the full file size
      if ((HDR2.NumberOfEntries*SizeOf(TGP0EntryVersion2)+SizeOf(TGP0Header)+SizeOf(TGP0HeaderVersion2)) > TotSize) then
      begin

        FileClose(Fhandle);
        FHandle := 0;
        Result := -3;
        ErrInfo.Format := 'TGP0';
        ErrInfo.Games := 'Astebreed';

      end
      else
      begin

        // Create a HandleStream from the source file
        handle_stm := THandleStream.Create(Fhandle);

        // Seek to the Directory Offset
        handle_stm.Seek(SizeOf(TGP0Header)+SizeOf(TGP0HeaderVersion2),soBeginning);

        // Create the Directory buffer stream
        headerBuffer := TMemoryStream.Create;

        // Read the complete directory to the buffer
        headerBuffer.CopyFrom(handle_stm,HDR2.NumberOfEntries*SizeOf(TGP0EntryVersion2));

        // Free the handle stream, useless now
        FreeAndNil(handle_stm);

        // Seek to the start of the stream
        headerBuffer.Seek(0,0);

        // Go through all entries
        for x := 0 to HDR2.NumberOfEntries-1 do
        begin
          // Seek to current position in Directory
          headerBuffer.Seek(x*SizeOf(TGP0EntryVersion2),0);

          // Read entry
          headerBuffer.Read(ENT2,SizeOf(TGP0EntryVersion2));

          // If the file is compressed, keep offset relative to data block start
          if (HDR2.Flags AND $2 = $2) then
            Offset := ENT2.Offset
          else  // Else it is relative to start of file
            Offset := ENT2.Offset + SizeOf(TGP0Header)+ HDR2.NumberOfEntries*SizeOf(TGP0EntryVersion2);

          // Add entry (storing header flags in DataX)
          FSE_Add(strip0(ENT2.FileName),Offset,ENT2.Size,HDR2.Flags,0);
        end;

        result := HDR2.NumberOfEntries;

        // Extract from the plugin only if crypted or compressed
        DrvInfo.ID := 'TGP0';
        DrvInfo.Sch := '\';
        DrvInfo.FileHandle := FHandle;
        DrvInfo.ExtractInternal := (HDR2.Flags AND $2 = $2) OR (HDR2.Flags AND $1 = $1);
      end;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Avatar .PAK support ====================================================== //
// -------------------------------------------------------------------------- //

type AvatarPAKHeader = packed record
       ID: array[0..3] of char;     // Should be 'PAK!
       Version: cardinal;           // Should be 4
       DirOffset: cardinal;
       Unknown: cardinal;
     end;
     AvatarPAKBlockEntry = packed record
       DecOffset: cardinal;
       ComOffset: cardinal;         // Higher byte seems to always be $80
     end;

function ReadAvatarPAK(): Integer;
var HDR: AvatarPAKHeader;
    x: integer;
    inFile: THandleStream;
    decStm: TDecompressionStream;
    bufStm: TMemoryStream;
    outFile: TFileStream;
    CDirSize, NumBlocks: Cardinal;
    BlockSizes: array of AvatarPAKBlockEntry;
begin

  inFile := THandleStream.Create(Fhandle);
  inFile.Seek(0,0);
  inFile.ReadBuffer(HDR,SizeOf(AvatarPAKHeader));

  if (HDR.ID <> 'PAK!') or (HDR.Version <> 4) or (HDR.DirOffset > inFile.Size) then
  begin
    inFile.Free;
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'PAK!';
    ErrInfo.Games := 'Avatar: The Game, ..';
  end
  else
  begin

    inFile.Seek(HDR.DirOffset,0);
    inFile.ReadBuffer(CDirSize,4);
    inFile.Seek(HDR.DirOffset,0);

    bufStm := TMemoryStream.Create;
    bufStm.CopyFrom(inFile,CDirsize);

    inFile.ReadBuffer(NumBlocks,4);
    SetLength(BlockSizes,NumBlocks);

    for x := 0 to NumBlocks-1 do
    begin
      inFile.ReadBuffer(BlockSizes[x],SizeOf(AvatarPAKBlockEntry));
      BlockSizes[x].ComOffset := BlockSizes[x].ComOffset and $FFFFFF;
    end;

    outFile := TFileStream.Create('E:\test.bin',fmCreate);
    for x := 0 to NumBlocks-2 do
    begin
      bufStm.Seek(BlockSizes[x].ComOffset,0);
      decStm := TDecompressionStream.Create(bufStm);
      outFile.CopyFrom(decStm,BlockSizes[x+1].DecOffset-BlockSizes[x].DecOffset);
      decStm.Free;
    end;

    Result := 0;

    DrvInfo.ID := 'PAK!';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

    inFile.Free;
    outFile.Free;
    bufStm.Free;

  end;

end;

// -------------------------------------------------------------------------- //
// Battlefield 1942 .RFA support ============================================ //
// -------------------------------------------------------------------------- //

type RFA_Entry = packed record
       size: integer;
       ucsize: integer;
       offset: integer;
       unknown: array[0..2] of integer;
     end;
     RFA_DataHeader = packed record
       csize: longword;
       ucsize: longword;
       doffset: longword;
     end;

function ReadBattlefield1942(src: string): integer;
var ENT: RFA_Entry;
    disp: string;
    ID: array[0..27] of char;
    NumE, x: integer;
    Offset: integer;
    IsRetail, IsComp: boolean;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);
  IsComp := false;

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, ID, 28);
    IsRetail := false;

    if ID <> 'Refractor2 FlatArchive 1.1  ' then
    begin
      FileSeek(FHandle, 4, 0);
      FileRead(FHandle,Offset,4);
      FileSeek(FHandle, 0, 0);
      IsRetail := true;
    end;

    if (ID <> 'Refractor2 FlatArchive 1.1  ') and (offset <> 1) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'RFA';
      ErrInfo.Games := 'Battlefield 1942';
    end
    else
    begin
      FileRead(FHandle,Offset,4);
      FileSeek(FHandle,Offset,0);
      FileRead(FHandle,NumE,4);

      for x:= 1 to NumE do
      begin

        Per := Round(((x / NumE)*100));
        SetPercent(Per);
        disp := get32(FHandle);
        FileRead(Fhandle,ENT,24);
        disp := Strip0(disp);
        if IsRetail then
        begin
          if (ENT.ucsize = ENT.size) then
          begin
            FSE_Add(disp,ENT.offset,ENT.UcSize,0,ENT.size);
            IsComp := false;
          end
          else
          begin
            IsComp := true;
            FSE_Add(disp,ENT.offset,ENT.UcSize,1,ENT.size);
          end;
        end
        else
        begin
          FSE_Add(disp,ENT.offset,ENT.Size,0,0);
        end;
      end;

      Result := NumE;

      DrvInfo.ID := 'RFA';
      DrvInfo.Sch := '/';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := IsRetail and IsComp;

    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Battleforge .PAK support ================================================= //
// -------------------------------------------------------------------------- //

// Format is simple:
//   Header
//     ID      = PAK
//     Version = 1
//     Offset to directory of entries
//     Size of directory of entries
//     Compressed size of directory of entries (aka size in PAK file)
//   Data ...
//   Zlib Compressed Directory (at Header.offset)
//
//   Directory
//     Number of Entries
//     Entries ...
//
//   Entries
//     Size of filename (32 bits)
//     Filename
//     Offset start
//     Offset end

type HDRBattleforgePAK = packed record
        ID: array[1..3] of Char;
        Version: byte;
        DirOffset: cardinal;
        DirSize: cardinal;
        DirCompressedSize: cardinal;
     end;

function ReadBattleforgePAK(): Integer;
var HDR: HDRBattleforgePAK;
    totFSize: int64;
    stmDec : TDecompressionStream;
    stmSrc : THandleStream;
    stmMem : TMemoryStream;
    x, NumE: integer;
    size, offset: cardinal;
    disp: string;
begin

  TotFSize := FileSeek(Fhandle, 0, 2);
  FileSeek(Fhandle, 0, 0);
  FileRead(Fhandle, HDR, Sizeof(HDRBattleforgePAK));

  if (HDR.ID <> 'PAK') or (HDR.Version <> 1) or
     ((HDR.DirOffset + HDR.DirCompressedSize) > (TotFSize)) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'BFPAK';
    ErrInfo.Games := 'Battleforge';
  end
  else
  begin

    // We retrieve the directory and decompress it
    stmSrc := THandleStream.Create(FHandle);
    stmSrc.Seek(HDR.DirOffset,0);
    stmDec := TDecompressionStream.Create(stmSrc);
    stmMem := TMemoryStream.Create;
    try
      stmMem.CopyFrom(stmDec,HDR.DirSize);
    finally
      FreeAndNil(stmDec);
      FreeAndNil(stmSrc);
    end;

    // Now we parse the directory
    stmMem.seek(0,0);
    stmMem.ReadBuffer(NumE,4);

    for x := 1 to NumE do
    begin
      disp := get32(stmMem);
      stmMem.ReadBuffer(offset,4);
      stmMem.ReadBuffer(size,4);
      // Size if Offset end - Offset start
      FSE_Add(disp,Offset,Size-Offset,0,0);
    end;

    Result := NumE;
    
    DrvInfo.ID := 'BFPAK';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// Black & White, Black & White 2, Fable: The Lost Chapters .LUG support ==== //
// -------------------------------------------------------------------------- //

type LUG_Chunk = packed record
       ID: array[0..31] of char;
       Size: integer;
     end;
     LUG_LHAudioBankMetaData = packed record
       Unknown0: array[0..27] of byte;
       NumEntries: integer;
     end;
     // SampleID: Integer;
     // SampleName: get32
     LUG_LHAudioBankMetaData_Entry = packed record
       Size: Integer;
       Offset: Integer;
       Unknown1: integer;         // 01 00 01 00
       SampleRate: Integer;
       Unknown2: Integer;         // 00 00 00 00 or FF FF FF FF
       Unknown3: Integer;
     end;
     LUG_LHFileSegmentBankInfo = packed record
       TitleDescription: array[0..519] of char;
     end;
     LUG_LHAudioBankSampleTable = packed record
       NumEntries1: word;
       NumEntries2: word;         // Always identical to NumEntries1 ?
     end;
     LUG_LHAudioBankSampleTable_Entry = packed record
       SampleName: array[0..255] of char;
       Unknown1: integer;
       Unknown2a: integer;
       Unknown2b: integer;
       Size: integer;
       RelOffset: integer;        // Offset in WaveData of LHAudioWaveData bloc
       Unknown3: integer;
       Unknown4: integer;
       Unknown5: integer;
       Unknown6: integer;
       Unknown7: integer;
       SampleRate: integer;
       Unknown8: integer;
       Unknown9: integer;
       Unknown10: integer;
       Unknown11: integer;
       Unknown12: integer;
       SampleDescription: array[0..255] of char;
       Unknown13: array[0..75] of byte;
     end;

function ReadLionheadAudioBank(src: string): Integer;
var HDR: LUG_Chunk;
    ABST_HDR: LUG_LHAudioBankSampleTable;
    ABST_ENT: LUG_LHAudioBankSampleTable_Entry;
    ABST_ENT_Size, DirSize, DirNum: cardinal;
    IDst: array[0..7] of char;
    disp: string;
    NumE, x: integer;
    DataOffset, DirOffset, FLength, CurP, idx: integer;
    MusicOffset, MusicSize, OldPer, Per: integer;
    tagid, nam: string;
    IsMusic, IsFirst: boolean;
    StoredOffsets: TIntList;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    // We seek to start of file and read the 8 first bytes
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, IDst, 8);

    // Lionhead Audio Banks starts with "LiOnHeAd"
    if (IDst <> 'LiOnHeAd') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'LUG';
      ErrInfo.Games := 'Black & White, Black & White 2, Fable: The Lost Chapters, ..';
    end
    else
    begin

      // We initialize all variables
      DataOffset := 0;
      DirOffset := 0;
      DirSize := 0;
      DirNum := 0;

      // We retrieve the file size
      FLength := FileSeek(FHandle,0,2);
      // We seek to the first chunk
      FileSeek(FHandle,8,0);

      // We go through all chunks of data in the sound bank
      repeat

        FileRead(FHandle,HDR,SizeOf(HDR));

        // Current offset
        CurP := FileSeek(FHandle,0,1);

        // Chunk ID
        tagid := strip0(HDR.ID);

        // If we reached the sound data chunk we store the data offset
        if (tagid = 'LHAudioWaveData') then
        begin
          DataOffset := CurP;
        end
        // If we reached the sample table chunk
        else if (tagid = 'LHAudioBankSampleTable') then
        begin
          // Read the chunk header
          FileRead(FHandle,ABST_HDR,SizeOf(ABST_HDR));
          // We get the number of entries
          DirNum := ABST_HDR.NumEntries1;
          // Directory offset is current offset (therefore chunk data offset + 4)
          DirOffset := CurP + 4;
          // Directory size is chunk data - 4 (chunk header size)
          DirSize := HDR.Size - 4;
        end;

        // We go to next chunk
        FileSeek(FHandle,CurP + HDR.Size,0);

      until ((length(tagid) = 0) or (FileSeek(FHandle,0,1) >= FLength)) ;

      // If the 2 blocs we are using to read the sound bank don't exist then just exit
      //   LHAudioBankSampleTable   --> Directory
      //   LHAudioWaveData          --> Sound Data
      // We also checks if the integers have positive values
      if (DirOffset <= 0) or (DataOffset <= 0) or (DirSize <= 0) then
      begin
        FileClose(Fhandle);
        FHandle := 0;
        Result := -3;
        ErrInfo.Format := 'LUG';
        ErrInfo.Games := 'Black & White, Black & White 2, Fable: The Lost Chapters, ..';
      end
      else
      begin

        // Calculates the entry size
        ABST_ENT_Size := DirSize div DirNum;
        // I know at least those two values:
        //   640 for Black & White .SAD files
        //   652 for Black & White 2 and Fable: The Lost Chapters .LUG files
        // If the value is under 652, no problem we should be able to handle it
        // if not this will do a write access violation I think, so we better exit if it happen

        // Entry size must fill the sound bank table, if not something is wrong so we exit
        if (ABST_ENT_Size <= 652) and ((DirSize mod ABST_ENT_Size) <> 0) then
        begin
          FileClose(Fhandle);
          FHandle := 0;
          Result := -3;
          ErrInfo.Format := 'LUG';
          ErrInfo.Games := 'Black & White, Black & White 2, Fable: The Lost Chapters, ..';
        end
        else
        begin

          // We initialize the number of entries to 0
          NumE := 0;

          // We go to the directory offset
          FileSeek(FHandle,DirOffset,0);

          // We initialize music related variables
          MusicOffset := 0;
          MusicSize := 0;
          IsMusic := True;
          IsFirst := True;

          // Percentage of completion display
          OldPer := 0;

          // We will store offsets to be sure there is no duplicate entries
          StoredOffsets := TIntList.Create;

          try

            // For each entry in the directory
            for x:= 1 to DirNum do
            begin

              // Display percentage of completion
              Per := Round((x / DirNum)*100);
              if (Per >= OldPer + 5) then
              begin
                SetPercent(Per);
                OldPer := Per;
              end;

              // We read the entry
              FileRead(FHandle,ABST_ENT,ABST_ENT_Size);

              // We retrieve the sample name (filename) by stripping null chars at the end
              disp := strip0(ABST_ENT.SampleName);

              // If the filename is a full Windows path (which is always the case)
              //   i.e: C:\Temp\Toto.wav
              // Then we strip the 3 first chars
              //   i.e: Temp\Toto.wav
              if copy(disp,2,2) = ':\' then
                Disp := Copy(disp,4,length(disp)-3);

              // We extract the filename from the path
              //   i.e: Toto.wav
              nam := ExtractFileName(disp);

              // If size of entry is not zero
              if ABST_ENT.Size > 0 then
              begin
                // If this is the first time we see that offset
                if not(StoredOffsets.Find(ABST_ENT.RelOffset,idx)) then
                begin
                  // We store it
                  StoredOffsets.Add(ABST_ENT.RelOffset);

                  // We check if we are in a music audio bank
                  // filenames (without path) start with sect and end with .mpg
                  // Each sector of the video is therefore stored as different file (sometimes more than 400 files for a song..)
                  // so we basically join them as one file
                  IsMusic := IsMusic and (length(nam) >= 4) and (lowercase(Copy(nam,1,4)) = 'sect') and (lowercase(extractfileext(nam)) = '.mpg');
                  if IsMusic then
                  begin
                    // If this is the first entry
                    if IsFirst then
                    begin
                      // We store the offset of the music file (which should be DataOffset + 0 actually)
                      MusicOffset := ABST_ENT.RelOffset;
                      // We set IsFirst to false
                      IsFirst := Not(IsFirst);
                    end;
                    // We increase the size of the music file with the size of entry
                    Inc(MusicSize,ABST_ENT.Size);
                  end
                  // If this is not a music audio bank (used by Black & White .SAD files)
                  else
                  begin
                    // We store the entry path & name
                    // Offset is Data Offset + Relative Offset of the entry
                    FSE_Add(disp,ABST_ENT.RelOffset+DataOffset,ABST_ENT.Size,0,0);

                    // We increase by 1 the number of available entries
                    Inc(NumE);
                  end;
                end;
              end;
            end;
          finally // Finally we free the stored offsets because we don't need them anymore
            FreeAndNil(StoredOffsets);
          end;

          // If we detected a music audio bank
          If IsMusic then
          begin
            // We extract the currently opened filename
            // and we put '.mpg' as extension
            nam := ExtractFilename(src);
            nam := ChangeFileext(nam,'.mpg');
            // We store a unique entry with MusicOffset + DataOffset offset
            // and MusicSize size (sum of all single entries)
            FSE_Add(nam,MusicOffset+DataOffset,MusicSize,0,0);
            NumE := 1;
          end;

          // Final steps, we return the number of entries found
          Result := NumE;

          // Send identification
          DrvInfo.ID := 'LHAB';    // Lionhead Audio Bank
          // Directories are using '\' as separators
          DrvInfo.Sch := '\';
          DrvInfo.FileHandle := FHandle;
          // Entries are not compressed, nor crypted, extraction will be handled by Dragon UnPACKer (core) directly
          DrvInfo.ExtractInternal := False;

        end;
      end;
    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Black & White 2 .STUFF support =========================================== //
// -------------------------------------------------------------------------- //

type BW2STUFFEntry = packed record
       Filename: array[0..255] of char;  // Null terminated
       Offset: integer;
       Size: integer;
       CDateTime: integer;
     end;

function ReadBlackAndWhite2STUFF: Integer;
var NumE, x, TotFSize, DirOffset : integer;
    disp : string;
    ENT: BW2STUFFEntry;
begin

  TotFSize := FileSeek(FHandle,0,2);
  FileSeek(FHandle,TotFSize-4,0);
  FileRead(FHandle, DirOffset, 4);
  if (DirOffset <= 0) or (DirOffset >= TotFSize) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'BW2STUFF';
    ErrInfo.Games := 'Black & White 2';
  end
  else
  begin 

    NumE := (TotFSize - DirOffset - 4) div 268;
    FileSeek(FHandle,DirOffset,0);

    for x := 0 to NumE-1 do
    begin
      FileRead(FHandle,ENT,268);
      Disp := strip0(ENT.Filename);
      FSE_Add(disp,ENT.Offset,ENT.Size,ENT.CDateTime,0);
    end;

    Result := NumE;

    DrvInfo.ID := 'BW2STUFF';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// Bloodrayne .POD support ================================================== //
// -------------------------------------------------------------------------- //

type POD3Header = packed record
       ID: array[0..3] of char;
       Unknown1: integer;
       Description: array[0..79] of char;
       NumEntries: integer;
       Unknown3: integer;
       Unknown4: integer;
       Unknown5: integer;
       Empty: array[1..160] of byte;
       DirOffset: integer;
       Unknown6: integer;
       NamesSize: integer;
       Unknown8: integer;
       Unknown9: integer;
       UnknownA: integer;
     end;
     POD3Entry = packed record
       NameOffset: integer;
       Size: integer;
       Offset: integer;
       Unknown1: integer;
       Unknown2: integer;
     end;
     // For POD5, entries have 2 extras integers (probably a 64bits checksum?)

function ReadBloodRaynePOD(): Integer;
var HDR: POD3Header;
    ENT: POD3Entry;
    disp: string;
    x, EntrySize: integer;
    InputStream: THandleStream;
    NameStream, DirStream: TMemoryStream;
begin

  // Allocate the streams (Directory / Names / Input)
  NameStream := TMemoryStream.Create;
  DirStream := TMemoryStream.Create;
  InputStream := THandleStream.Create(Fhandle);

  try
    // Read the header of the file
    InputStream.Seek(0,0);
    InputStream.ReadBuffer(HDR, SizeOf(POD3Header));

    // Go to directory offset (usually near the end of the file, but could be anywhere)
    InputStream.Seek(HDR.DirOffset,0);

    // Setting the size of the directory
    // If POD3 then using POD3Entry (5 integers)
    // If POD5 then using POD5Entry (7 integers)
    if (HDR.ID[3] = #51) then // POD3
      EntrySize := SizeOf(POD3Entry)
    else // if (HDR.ID[3] = #53) then // POD5
      EntrySize := SizeOf(POD3Entry) + 8;

    // Retrieve the full directory to memory
    DirStream.CopyFrom(InputStream,HDR.NumEntries * EntrySize);
    DirStream.Seek(0,0);

    // Retrieve the names to memory
    InputStream.Seek(HDR.DirOffset+(EntrySize*HDR.NumEntries),0);
    NameStream.CopyFrom(InputStream,HDR.NamesSize);
    NameStream.Seek(0,0);

    for x := 1 to HDR.NumEntries do
    begin

      Per := ROund(((x / HDR.NumEntries)*100));
      SetPercent(Per);

      DirStream.Seek((x-1)*EntrySize,0);
      DirStream.ReadBuffer(ENT,SizeOf(POD3Entry));
      NameStream.Seek(ENT.NameOffset,0);
      disp := Get0(NameStream);

      FSE_Add(Strip0(disp),ENT.Offset,ENT.Size,0,0);

    end;

  finally
    FreeAndNil(NameStream);
    FreeAndNil(DirStream);
    FreeAndNil(InputStream);
  end;

  Result := HDR.NumEntries;

  DrvInfo.ID := HDR.ID;
  DrvInfo.Sch := '\';
  DrvInfo.FileHandle := FHandle;
  DrvInfo.ExtractInternal := False;

end;

// -------------------------------------------------------------------------- //
// Civilization IV & V .FPK support ========================================= //
// -------------------------------------------------------------------------- //

type FPKHeader = packed record
       Version: Integer;          // 4 = Civilisation IV
                                  // 6 = Civilisation V
       ID: array[0..3] of char;
       Scrambling: Byte;          // 1 = Filename scrambling used
                                  // 0 = Normal Filename
     end;
     // Unknown3: Byte;           // If Version = 6
     // NumEntries: integer;

     FPKEntry = packed record
       FileTime: Integer;
       Unknown: Integer;
       Size: Integer;
       Offset: Integer;
     end;

function Get32_FPK(src: integer): string;
var tchar: Pchar;
    tint, x: Integer;
    res: string;
begin

  FileRead(src,tint,4);
  if tint > 255 then
  begin
    raise Exception.Create('Get32_FPK / Sanity Check Failure / tint='+inttostr(tint)+' / offset='+inttostr(fileseek(FHandle,0,1)));
  end;
  GetMem(tchar,tint);
  FillChar(tchar^,tint,0);
  FileRead(src,tchar^,tint);
  for x := 0 to tint-1 do
  begin
    tchar[x] := chr(ord(tchar[x])-1);
  end;

  res := tchar;
  result := Copy(res,1,tint);

  FreeMem(tchar);

end;

function ReadCivilization4FPK(src: string): Integer;
var HDR: FPKHeader;
    ENT: FPKEntry;
    disp: string;
    NumE, x, NumTest, CurP: integer;
    NumDummy: byte;
    TotFSize: integer;
    OldPer: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    // We retrieve the full size of the file
    TotFSize := FileSeek(Fhandle,0,2);
    FileSeek(FHandle,0,0);

    // We read the header
    FileRead(FHandle,HDR,SizeOf(HDR));

    // ID must be "FPK_" and the only supported version is 4
    if (HDR.ID <> 'FPK_') or ((HDR.Version <> 4) and (HDR.Version <> 6)) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'FPK';
      ErrInfo.Games := 'Sid Meier''s Civilization 4, Sid Meier''s Civilization V';
    end
    else
    begin

      // If this is version 6 we need to skip 1 unknown byte
      if HDR.Version = 6 then
        FileSeek(FHandle,1,1);

      // We read the number of entries in the file
      FileRead(Fhandle,NumE,4);

      OldPer := 0;

      // We go throught the directory
      for x:= 1 to NumE do
      begin

        // Code to display the progress into Dragon UnPACKer
        // The If section is done so the update is not done too often
        // (which slows down everything)
        Per := ROund(((x / NumE)*100));
        if Per >= OldPer + 5 then
        begin
          SetPercent(Per);
          OldPer := Per;
        end;

        // We retrieve the filename, which is a Get32 format (32bit for size then the string)
        // But with an encryption (they added 1 to each char), so Get32_FPK is decrypting "on-the-fly" (lol)
        if HDR.Scrambling = 1 then
          disp := Strip0(Get32_FPK(FHandle))
        else
          disp := Strip0(Get32(FHandle));

        // We store current offset in directoy
        CurP := FileSeek(FHandle,0,1);

        // We read the entry information
        FileRead(FHandle,ENT,SizeOf(ENT));

        // We also read the 32bit integer of the next Get32 filename as a test number
        FileRead(FHandle,NumTest,4);

        // If the NumTest is more than 0 and less than MAXPATH (255 chars)
        // If the Offset is between start & end of file
        // If the Size is lower than whole file size
        // If the Offset + Size is not going over the end of file
        if (NumTest <= 255) and (NumTest >= 0) and (ENT.Offset > 12) and (ENT.Offset < TotFSize) and (ENT.Size < TotFSize) and (ENT.Offset + ENT.Size <= TotFSize) then
        begin

          // Then the Entry was read correctly so we just seek 4 bytes before (because of the NumTest reading)
          FileSeek(FHandle,-4,1);

        end
        // Else then the entry info is not directly after the filename, we then need
        // to read one byte with the length of that useless junk and skip that number of bytes
        else
        begin

          // We seek to the stored position
          FileSeek(FHandle,CurP,0);

          // We read how many dummy bytes we need to skip
          FileRead(FHandle,NumDummy,1);

          // We skip them (minus one because the dummy number is included in it)
          FileSeek(FHandle,NumDummy-1,1);

          // We read the entry info again
          FileRead(FHandle,ENT,SizeOf(ENT));

        end;

        // We store the entry
        FSE_Add(disp,ENT.Offset,ENT.Size,0,0);

      end;

      // We return the number of entries found
      Result := NumE;

      // ID is FPK
      DrvInfo.ID := 'FPK'+inttostr(HDR.Version);
      // Directory separator is '\'
      DrvInfo.Sch := '\';
      // Extraction will be handled by Dragon UnPACKer core
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Command & Conquer: Generals .BIG support ================================= //
// -------------------------------------------------------------------------- //

function revInt(tab: array of byte): integer;
begin

  result := tab[3] + tab[2] * $100 + tab[1] * $10000 + tab[0] * $1000000;

//  ShowMessage(inttostr(tab[0])+#10+inttostr(tab[1])+#10+inttostr(tab[2])+#10+inttostr(tab[3]));
end;

type BIGHeader = packed record
       ID: array[0..3] of char;  // BIGF
       TotFileSize: integer;
       NumFiles: array[0..3] of byte;   // Inverse Integer
       DataOffset: array[0..3] of byte; // Inverse Integer
     end;
     BIGEntry = packed record
       Offset: array[0..3] of byte; // Inverse Integer
       Size: array[0..3] of byte;   // Inverse Integer
     end;
     // Get0 filename

function ReadCommandAndConquerGeneralsBIG: Integer;
var HDR: BIGHeader;
    ENT: BIGEntry;
    disp: string;
    NumE, x, OldPer: integer;
    TotFSize: Integer;
    isAntiSlash: Boolean;
begin

  TotFSize := FileSeek(Fhandle,0,2);
  FileSeek(FHandle,0,0);
  FileRead(FHandle,HDR,SizeOf(HDR));

  if ((HDR.ID <> 'BIGF') and (HDR.ID <> 'BIG4')) or (TotFSize <> HDR.TotFileSize) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'BIGF';
    ErrInfo.Games := 'Command & Conquer: Generals, The Lord of the Rings: Battle for Middle Earth';
  end
  else
  begin

    NumE := revInt(HDR.NumFiles);
    OldPer := 0;

    isAntiSlash := false;

    for x:= 1 to NumE do
    begin
      Per := ROund(((x / NumE)*100));
      if Per >= (OldPer + 5) then
      begin
        SetPercent(Per);
        OldPer := Per;
      end;
      FileRead(FHandle,ENT,8);
      disp := Strip0(Get0(FHandle));
      if not(isAntiSlash) and (pos('/',disp) > 0) then
        isAntiSlash := true;
      FSE_Add(disp,revInt(ENT.Offset),revInt(ENT.Size),0,0);
    end;

    Result := NumE;

    DrvInfo.ID := 'BIGF';
    if isAntiSlash then
      DrvInfo.Sch := '/'
    else
      DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// Commandos 3 .PCK support ================================================= //
// -------------------------------------------------------------------------- //

type PCKEntry = packed record
       Name: array[0..35] of char;
       Flag: integer;              // $00 = File
                                   // $01 = Directory
                                   // $FF = End of directory
       Size: longword;             // $FFFFFFFF = Not a file
       Offset: longword;           // $FFFFFFFF = End of directory
     end;

function ReadCommandos3PCK_aux(curDir: string): Integer;
var ENT: PCKEntry;
    disp, disp2: string;
    tbyt,tmode: byte;
begin

  result := 0;

  repeat

    FileRead(FHandle,ENT,SizeOf(ENT));

    if (ENT.Flag = 0) then
    begin
      disp := strip0(ENT.Name);
      disp2 := Uppercase(ExtractFileExt(disp));
      tmode := 0;
      tbyt := 0;
      if disp2 = '.WAV' then
        tbyt := $52
      else if disp2 = '.STR' then
        tbyt := $FF
      else if disp2 = '.FAC' then
        tbyt := $5B
      else if disp2 = '.CFG' then
        tbyt := $5B
      else if disp2 = '.ABI' then
        tbyt := $4C
      else if disp2 = '.GRL' then
        tbyt := $47
      else if disp2 = '.MAN' then
        tbyt := $28
      else if disp2 = '.MAC' then
        tbyt := $54
      else if disp2 = '.TUT' then
        tbyt := $5B
      else if disp2 = '.MBI' then
        tbyt := $32
      else if disp2 = '.SEC' then
        tbyt := $2
      else if (disp2 = '.FNC') or (disp2 = '.FNM') then
        tmode := 1
      else if (disp2 = '.ANI') or (disp2 = '.AN2') or (disp2 = '.MSB') or (disp2 = '.BRI') or (uppercase(disp) = 'FILE.BIN') or (uppercase(disp) = 'CHUSMA.DAT') or (uppercase(disp) = 'BER2.MIS') then
        tbyt := $42
      else if (uppercase(disp) = 'VAR.DAT') then
        tbyt := $23
      else if (uppercase(disp) = 'MISIONES.DAT') then
        tbyt := $2F
      else if (uppercase(disp) = 'PRGE.DAT') then
        tbyt := $28
      else if (uppercase(disp) = 'PARGLOBAL.DAT') then
        tbyt := $5B
      else if disp2 = '.OGC' then
        tbyt := $20
      else if disp2 = '.MIS' then
        tbyt := $5B
      else if disp2 = '.LIS' then
        tbyt := $5B
      else if disp2 = '.GMT' then
        tbyt := $5B
      else if disp2 = '.MA2' then
        tbyt := $3
      else if (disp2 = '.GSC') or (disp2 = '.BAS') then
      begin
        tbyt := $5B;
        tmode := 2;
      end
      else
        tbyt := 0;
      FSE_Add(curDir+disp,ENT.Offset, ENT.Size,tbyt,tmode);
//      FSE_Add(curDir+strip0(ENT.Name),ENT.Offset, tbyt, tbyt,0);
//      FSE_Add(curDir+strip0(ENT.Name),curPos, tbyt, tbyt,0);
      inc(result);
    end
    else if (ENT.Flag = 1) then
    begin
      disp := curDir + strip0(ENT.Name)+'\';
      inc(result,readCommandos3PCK_aux(disp));
    end;

  until (ENT.Flag = $FF);

end;

function ReadCommandos3PCK(src: string): Integer;
var ENT: PCKEntry;
    disp: string;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    FileSeek(FHandle,0,0);

    FileRead(FHandle,ENT,SizeOf(ENT));

    if (ENT.Flag <> 1) or (ENT.Size <> $FFFFFFFF) or (ENT.Offset <> $30) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'PCK';
      ErrInfo.Games := 'Commandos 3';
    end
    else
    begin

      Disp := Strip0(ENT.Name);
      if length(Disp) > 0 then
        Disp := Disp + '\';

      Result := ReadCommandos3PCK_aux(Disp);

      DrvInfo.ID := 'PCK';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end;
  end
  else
    Result := -2;

end;


procedure DecryptPCKToStream(src : integer; dst : TStream; soff : Int64; ssize : Int64; seed: integer; silent: boolean);
var
  //sFileLength: Integer;
  Buffer: PByteArray;
  i,x,numbuf, restbuf: Integer;
  per, oldper, perstep: word;
  real1, real2: real;
  key: byte;
  skeleton: byte;
  foundkey: boolean;
begin

  //sFileLength := FileSeek(src,0,2);
  FileSeek(src,soff,0);
  numbuf := ssize div 1024;
  if (numbuf > 25000) then
    perstep := 2
  else if (numbuf > 12500) then
    perstep := 5
  else if (numbuf > 6000) then
    perstep := 10
  else
    perstep := 15;
  restbuf := ssize mod 1024;

  key := 0;
  skeleton := 0;
  foundkey := false;

  GetMem(Buffer,1024);
  try
    oldper := 0;

    for i := 1 to numbuf do
    begin
      FileRead(src, Buffer^, 1024);
      if not(foundkey) then
      begin
        key := buffer^[0] xor seed;
        foundkey := true;
      end;
      for x := 0 to (1023 div 16) do
      begin
        Buffer^[x*16] := Buffer^[x*16] xor (key+skeleton);
//      showmessage(inttostr(x*16)+' '+inttohex(key+skeleton,2));
        if (skeleton = 240) then
          skeleton := 0
        else
          inc(skeleton,16);
        inc(key);
        if (key = 7) then
          key := 8;
        if (key >= 15) then
          key := 0;
      end;
      dst.WriteBuffer(Buffer^,1024);
      if not silent then
      begin
        real1 := i;
        real2 := numbuf;
        real1 := (real1 / real2)*100;
        per := Round(real1);
        if per >= oldper + perstep then
        begin
          oldper := per;
          SetPercent(per);
        end;
      end;
    end;

    if not silent then
      SetPercent(100);

    FileRead(src, Buffer^, restbuf);
    for x := 0 to ((restbuf-1) div 16) do
    begin
      if not(foundkey) then
      begin
        key := buffer^[0] xor seed;
        foundkey := true;
      end;
      Buffer^[x*16] := Buffer^[x*16] xor (key+skeleton);
      if (skeleton = 240) then
        skeleton := 0
      else
        inc(skeleton,16);
      inc(key);
      if (key = 7) then
        key := 8;
      if (key >= 15) then
        key := 0;
    end;
    dst.WriteBuffer(Buffer^, restbuf);

  finally
    FreeMem(Buffer);
  end;

end;

// -------------------------------------------------------------------------- //
// Cyberbykes .BIN support ================================================== //
// -------------------------------------------------------------------------- //

type BIN_Entry = packed record
       Filename: array[0..15] of char;
       Offset: cardinal;
       Size: cardinal;
     end;

function ReadCyberBykesBIN(src: string): Integer;
var ENT: BIN_Entry;
    disp: string;
    x, preval: integer;
    curOffset: int64;
    NumE, TotFSize: cardinal;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    TotFSize := FileSeek(Fhandle,0,2);
    FileSeek(FHandle,0,0);
    FileRead(FHandle,NumE,4);

    if (((NumE*4)+4) > TotFSize) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'CBIN';
      ErrInfo.Games := 'CyberBykes, Shadow Racer VR';
    end
    else
    begin

      try

        for x:= 1 to NumE do
        begin
          Per := ROund(((x / NumE)*100));
          SetPercent(Per);
          FileRead(FHandle,ENT,SizeOf(BIN_Entry));
          CurOffset := FileSeek(FHandle,0,1);
          if (ENT.Offset > TotFSize) or ((ENT.Offset + ENT.Size) > TotFSize) then
          begin
            FileClose(Fhandle);
            FSE_Free;
            FHandle := 0;
            Result := -3;
            ErrInfo.Format := 'CBIN';
            ErrInfo.Games := 'CyberBykes, Shadow Racer VR';
            exit;
          end;
          FileSeek(FHandle,ENT.Offset,0);
          FileRead(FHandle,preval,4);
          FileSeek(FHandle,curOffset,0);
          disp := Strip0(ENT.Filename);
          FSE_Add(disp,ENT.Offset+4,ENT.Size-4,preval,0);
        end;

        Result := NumE;

        DrvInfo.ID := 'CBIN';
        DrvInfo.Sch := '';
        DrvInfo.FileHandle := FHandle;
        DrvInfo.ExtractInternal := False;

      except
        on E:EBadFormat do
        begin
          FileClose(Fhandle);
          FSE_Free;
          FHandle := 0;
          Result := -3;
          ErrInfo.Format := 'CBIN';
          ErrInfo.Games := 'CyberBykes, Shadow Racer VR';
        end;
        on E:Exception do
        begin
          raise e;
        end;
      end;
    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Dark Forces .GOB support ================================================= //
// -------------------------------------------------------------------------- //

type DGOBHeader = packed record
       ID: array[0..3] of char;
       DirOffset: integer;
     end;
     DGOBIndex = packed record
       Offset: integer;
       Size: integer;
       Name: array[0..12] of char;
     end;

function ReadDarkForcesGOB(): Integer;
var HDR: DGOBHeader;
    ENT: DGOBIndex;
    disp: string;
    NumE, x: integer;
begin

  FileSeek(Fhandle, 0, 0);
  FileRead(FHandle, HDR, 8);

  FileSeek(FHandle,HDR.DirOffset,0);
  FileRead(FHandle,NumE,4);

  for x:= 1 to NumE do
  begin

    Per := ROund(((x / NumE)*100));
    SetPercent(Per);
    FileRead(Fhandle,ENT.Offset,4);
    FileRead(Fhandle,ENT.Size,4);
    FileRead(Fhandle,ENT.Name,13);
    disp := Strip0(ENT.Name);

    FSE_Add(disp,ENT.Offset,ENT.Size,0,0);

  end;

  ReadDarkForcesGOB := NumE;

  DrvInfo.ID := 'DGOB';
  DrvInfo.Sch := '';
  DrvInfo.FileHandle := FHandle;
  DrvInfo.ExtractInternal := False;

end;

// -------------------------------------------------------------------------- //
// Darkstone .MTF support =================================================== //
// -------------------------------------------------------------------------- //

type MTFCompress = packed record
        ID1: Byte;
        ID2: Byte;
        Reserved1 : Byte;
        Reserved2 : Byte;
        NumBlocks : integer ;
        Flags : integer;
     end;

function ReadDarkstoneMTF(src: string): integer;
var filnam: string;
    NumE, x: word;
    Offset, Size, Per, PerOld: integer;
    //filesize: Cardinal;
begin

  FHandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(FHandle, 0, 0);
    FileRead(FHandle, NumE, 4);

    if NumE < 1 then
    begin
      FileClose(FHandle);
      FHandle := 0;
      ReadDarkstoneMTF := -3;
      ErrInfo.Format := 'MTF';
      ErrInfo.Games := 'Darkstone';
    end
    else
    begin

      PerOld := 0;

      for x:= 1 to NumE do
      begin
        Per := Round((x / NumE)*100);
        if Per >= PerOld + 5 then
        begin
          PerOld:= Per;
          SetPercent(Per);
        end;
        filnam := Get32(FHandle);
        FileRead(FHandle,Offset,4);
        FileRead(FHandle,Size,4);

        FSE_add(strip0(filnam),Offset,Size,0,0);
      end;

      ReadDarkstoneMTF := NumE;

      DrvInfo.ID := 'MTF';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;
    end;
  end
  else
    ReadDarkstoneMTF := -2;

end;

Function ReloadBuffer(Offset: int64; BufSize: integer; Buffer: PByteArray): integer;
begin

  FileSeek(FHandle,Offset,0);
  ReloadBuffer := FileRead(FHandle,Buffer^,BufSize);

end;

function Puiss2(x: byte): integer;
begin
  Result := 0;

  case x of
    0: Puiss2 := 1;
    1: Puiss2 := 2;
    2: Puiss2 := 4;
    3: Puiss2 := 8;
    4: Puiss2 :=16;
    5: Puiss2 :=32;
    6: Puiss2 :=64;
    7: Puiss2 :=128;
  end;

end;

procedure DecompressMTFToStream(outputstream: TStream; Offset, Size: int64);
var
  Buf: PByteArray;
  BufEnd: PByteArray;
  CurPos: int64;
  BufPos, DstPos, tmpL, Copie, Retour, y: integer;
  x, tmpb: byte;
//  T: TextFile;
begin

//  AssignFile(T, 'h:\testmtf.log');
//  Rewrite(T);

  CurPos := Offset;

  GetMem(Buf,16384);
  GetMem(BufEnd,Size);

  CurPos := CurPos + ReloadBuffer(Offset,16384,Buf);
  BufPos := 0;
  DstPos := 0;

  repeat

    tmpb := Buf^[BufPos];
//    Writeln(T,IntToStr(BufPos)+'/16384 = '+IntToStr(tmpb));

    for x:=0 to 7 do
      if (tmpb and Puiss2(x)) = Puiss2(x) then
      begin
//       Write(T,' for-if -> '+inttostr(x)+' '+inttostr(Puiss2(x)));
        //ShowMessage(IntToStr(BufPos));
        BufPos := BufPos + 1;
        if BufPos = 16384 then
        begin
//          Write(T,'<REBUFFERING> '+inttostr(CurPos));
          CurPos := CurPos + ReloadBuffer(CurPos,16384,Buf);
//          Writeln(' '+inttostr(CurPos));
          BufPos := 0;
        end;
        BufEnd^[DstPos] := Buf^[BufPos];
        DstPos := DstPos + 1;
//        Writeln(T,' end-for-if');
      end
      else
      begin
//        Write(T,' for-else -> '+inttostr(x)+' '+inttostr(Puiss2(x)));
        BufPos := BufPos + 1;
        if BufPos = 16384 then
        begin
//          Write(T,'<REBUFFERING> '+inttostr(CurPos));
          CurPos := CurPos + ReloadBuffer(CurPos,16384,Buf);
//          Writeln(T,' '+inttostr(CurPos));
          BufPos := 0;
        end;
        TmpL := Integer(Buf^[BufPos]);
        BufPos := BufPos + 1;
        if BufPos = 16384 then
        begin
//          Write(T,'<REBUFFERING> '+inttostr(CurPos));
          CurPos := CurPos + ReloadBuffer(CurPos,16384,Buf);
//          Writeln(T,' '+inttostr(CurPos));
          BufPos := 0;
        end;
        TmpL := TmpL + 256 * Integer(Buf^[BufPos]);
        Copie := TmpL div 1024;
        Retour := TmpL mod 1024;
//        ShowMessage(IntToStr(TmpB)+#10+IntToStr(BufPos)+#10+IntToStr(DstPos)+#10+IntToStr(TmpL)+#10+IntToStr(Copie)+#10+IntToStr(Retour));
        For y := 1 to Copie + 3 do
        begin
          BufEnd^[DstPos] := BufEnd^[DstPos - Retour];
          Inc(DstPos);
        end;
//        Writeln(T,' end-for-else');
      end;

    Inc(BufPos);
    if BufPos = 16384 then
    begin
//      Write(T,'<REBUFFERING> '+inttostr(CurPos));
      CurPos := CurPos + ReloadBuffer(CurPos,16384,Buf);
//      Writeln(T,' '+inttostr(CurPos));
      BufPos := 0;
    end;
//    ShowMessage(IntToStr(DstPos) + #10 + IntToStr(Size) + #10);
  until (DstPos > Size);

//  CloseFile(T);

  outputstream.WriteBuffer(BufEnd^, Size);

  FreeMem(Buf);
  FreeMem(BufEnd);

end;

// -------------------------------------------------------------------------- //
// Descent .HOG support ===================================================== //
// -------------------------------------------------------------------------- //

type HOGEntry = packed record
       Filename: array[0..12] of char;
       FileSize: integer;
     end;
     HOG2Header = packed record
       NumFiles: integer;
       Offset: integer;
       FillData: array[0..55] of byte;
     end;
     HOG2Entry = packed record
       Filename: array[0..35] of char;
       Unknown: integer;
       FileSize: integer;
       Timestamp: integer;
     end;

const
  HOGID : String = 'DHF';
  HOG2ID : String = 'HOG2';

function ReadDescentHOG(src: string): Integer;
var HDR: HOG2Header;
    ENT: HOGEntry;
    ENT2: HOG2Entry;
    disp: string;
    NumE, TotSize, CurPos, x: integer;
    ID: array[0..2] of char;
    IDF: array[0..3] of char;
    PerInfo: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, ID, 3);
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, IDF, 4);

    if ID = HOGID then
    begin

      CurPos := 3;
      TotSize := FileSeek(FHandle,0,2);
      PerInfo := TotSize - CurPos; 
      NumE := 0;

      repeat
        Per := ROund((((PerInfo) / TotSize)*100));
        SetPercent(Per);
        FileSeek(FHandle,CurPos,0);

        FileRead(FHandle,ENT.Filename,13);
        FileRead(FHandle,ENT.FileSize,4);

        CurPos := CurPos + 17;
        disp := Strip0(ENT.Filename);

        FSE_Add(disp,CurPos,ENT.FileSize,0,0);
        Inc(NumE);

        CurPos := CurPos + ENT.FileSize;
      until (CurPos >= TotSize);

      ReadDescentHOG := NumE;

      DrvInfo.ID := 'HOG';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end
    else if IDF = HOG2ID then
    begin

      FileRead(FHandle,HDR,64);
      CurPos := HDR.Offset;
      NumE := HDR.NumFiles;

      for x := 1 to NumE do
      begin
        Per := ROund(((x / NumE)*100));
        SetPercent(Per);
        FileRead(FHandle,ENT2,48);

        disp := strip0(ENT2.Filename);

        FSE_add(disp,CurPos+48,ENT2.FileSize,0,0);

        CurPos := CurPos + ENT2.FileSize;
      end;

      ReadDescentHOG := NumE;

      DrvInfo.ID := 'HOG2';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end
    else
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadDescentHOG := -3;
      ErrInfo.Format := 'HOG';
      ErrInfo.Games := 'Descent, Descent 2, Descent 3';
    end;
  end
  else
    ReadDescentHOG := -2;

end;

// -------------------------------------------------------------------------- //
// Dragon Age: Origins .ERF support ========================================= //
// -------------------------------------------------------------------------- //

type HDRDragonAgeOriginsERF = packed record
       ID: array[0..7] of widechar;
       NumberOfEntries: cardinal;
       Unknown1: cardinal;
       Unknown2: cardinal;
       Unknown3: cardinal;
     end;
     ENTDragonAgeOriginsERF = packed record
       UnicodeName: array[0..31] of widechar;
       Offset: cardinal;
       Size: cardinal;
     end;

function ReadDragonAgeOriginsERF(filename: string): integer;
var HDR: HDRDragonAgeOriginsERF;
    ENT: ENTDragonAgeOriginsERF;
    x: cardinal;
    disp: ansistring;
begin

  Fhandle := FileOpen(filename, fmOpenRead or fmShareDenyWrite);

  if (FHandle > 0) then
  begin

    FileSeek(Fhandle, 0, 0);
    FileRead(Fhandle, HDR, Sizeof(HDRDragonAgeOriginsERF));

    if HDR.ID <> 'ERF V2.0' then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'ERF';
      ErrInfo.Games := 'Dragon Age: Origins';
    end
    else
    begin

      OldPer := 0;
      SetPercent(0);
      for x:= 1 to HDR.NumberOfEntries do
      begin

        Per := ROund(((x / HDR.NumberOfEntries)*100));
        if (Per > OldPer) then
        begin
          SetPercent(Per);
          OldPer := Per;
        end;

        FileRead(Fhandle, ENT, Sizeof(ENTDragonAgeOriginsERF));

        disp := ENT.UnicodeName;

        FSE_Add(strip0(disp),ENT.Offset,ENT.Size,0,0);

      end;

      Result := HDR.NumberOfEntries;

      DrvInfo.ID := 'ERF';
      DrvInfo.Sch := '/';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    result := -2;

end;

// -------------------------------------------------------------------------- //
// Dreamfall .PAK support =================================================== //
// -------------------------------------------------------------------------- //

type HDRDreamfallTLJPAK = packed record
       ID: array[0..11] of char;
       NumberOfEntries: integer;
       Unknown2: integer;
       Unknown3: integer;
     end;
     ENTDreamfallTLJPAK = packed record
       Offset: integer;
       Size: integer;
       Unknown1: integer;
       Unknown2: integer;
       Unknown3: integer;
     end;

function ReadDreamfallTLJPAK(filename: string): integer;
var HDR: HDRDreamfallTLJPAK;
    ENT: ENTDreamfallTLJPAK;
    x, NumE, tmpInt, MaxLength: integer;
    ENTBuffer: TMemoryStream;
    TmpBuffer: THandleStream;
    Disp, DispPre, DispFill: String;
begin

  FileSeek(Fhandle, 0, 0);
  FileRead(Fhandle, HDR, Sizeof(HDRDreamfallTLJPAK));

  if HDR.ID <> 'tlj_pack0001' then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'TLJPAK';
    ErrInfo.Games := 'Dreamfall: The Longest Journey';
  end
  else
  begin

    TmpBuffer := THandleStream.Create(FHandle);
    ENTBuffer := TMemoryStream.Create;
    ENTBuffer.CopyFrom(TmpBuffer,HDR.NumberOfEntries * SizeOf(ENTDreamfallTLJPAK));
    ENTBuffer.Seek(0,0);
    FreeAndNil(TmpBuffer);

    NumE := 0;
    DispPre := ExtractFileExt(filename);
    if (length(DispPre) > 1) then
      DispPre := '_'+rightstr(DispPre,length(DispPre)-1)
    else
      DispPre := '';
    DispPre := ChangeFileExt(ExtractFileName(filename),DispPre);

    MaxLength := length(inttostr(HDR.NumberOfEntries));
    DispFill := stringofchar('0',MaxLength);

    for x:= 1 to HDR.NumberOfEntries do
    begin

      Per := ROund(((x / HDR.NumberOfEntries)*100));
      SetPercent(Per);

      ENTBuffer.ReadBuffer(ENT,Sizeof(ENTDreamfallTLJPAK));

      if (ENT.Size > 0) then
      begin
        FileSeek(FHandle,ENT.Offset,0);
        FileRead(FHandle,tmpInt,4);
        if (tmpInt = $20534444) then
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.dds'
        else if ((tmpInt and $E0FF) = $E0FF) then
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.mp3'
        else if (tmpInt = $73760A0D) or (tmpInt = $312E7376) or (tmpInt = $31157376) or (tmpInt = $315F7376) then
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.vs1'
        else if (tmpInt = $322E7376) or (tmpInt = $6E69203B) then
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.vs2'
        else if (tmpInt = $0A0D2F2F) then
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.vsc'
        else if (tmpInt = $312E7370) or (tmpInt = $696C203B) or (tmpInt = $6576203B) then
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.ps1'
        else if (tmpInt = $322E7370) or (tmpInt = $6170203B) then
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.ps2'
        else if (tmpInt = $615F7376) or (tmpInt = $332E7370) then
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.ps3'
        else if (tmpInt = $5367674F) then
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.ogg'
        else if (tmpInt = $626A6C74) then
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.tljbone2d'
        else if (tmpInt = $55465453) then
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.stfu'
        else if (tmpInt = $72616873) then
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.shark3d'
        else if (tmpInt = $46464952) then
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.wav'
        else
          Disp := DispPre + '-'+RightStr(DispFill+inttostr(x),MaxLength)+'.unk'+inttohex(tmpInt,8);
        // This below I used to identify more easily the file types
        // inttohex(x,8)+'-'+inttohex(ENT.Unknown1,8)+'-'+inttohex(ENT.Unknown2,8)+'-'+inttohex(ENT.Unknown3,8)+ '.'+inttohex(tmpInt,8);
        FSE_Add(disp,ENT.Offset,ENT.Size,0,0);
        Inc(NumE);
      end;

    end;

    FreeAndNil(ENTBuffer);

    Result := NumE;

    DrvInfo.ID := 'TLJPAK';
    DrvInfo.Sch := '/';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// Duke Nukem 3D .ART support =============================================== //
// -------------------------------------------------------------------------- //

type ARTHeader = packed record
       ARTVersion: integer;
       Numtiles: integer;
       LocalTileStart: integer;
       LocalTileEnd: integer;
     end;

function ReadDuke3DART(src: string): Integer;
var HDR: ARTHeader;
    NumE, x: integer;
    Offset: integer;
    XList: array of word;
    YList: array of word;
    PicAnm: array of integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle,HDR.ARTVersion,4);
    FileRead(FHandle,HDR.Numtiles,4);
    FileRead(FHandle,HDR.LocalTileStart,4);
    FileRead(FHandle,HDR.LocalTileEnd,4);

    if HDR.ARTVersion <> 1 then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'ART';
      ErrInfo.Games := 'Duke Nukem 3D & Shadow Warrior';
    end
    else
    begin

      NumE := HDR.LocalTileEnd - HDR.LocalTileStart + 1;
      Offset := 16 + NumE * 8;

      SetLength(XList,NumE);
      SetLength(YList,NumE);
      SetLength(PicAnm,NumE);

      for x:=0 to NumE-1 do
        FileRead(FHandle,XList[x],2);
      for x:=0 to NumE-1 do
        FileRead(FHandle,YList[x],2);
      for x:=0 to NumE-1 do
        FileRead(FHandle,PicAnm[x],4);

//      ShowMessage(IntToStr(NumE)+#10+IntToStr(Offset)+#10+inttostr(FileSeek(FHandle,0,1)));

      for x:= 0 to NumE-1 do
      begin

        Per := ROund(((x / NumE)*100));
        SetPercent(Per);

        if (XList[x]*YList[x]) > 0 then
        begin
          FSE_Add('texture #'+RightStr('00000'+IntToStr(x + HDR.LocalTileStart),6)+'.tex',Offset,(XList[x]*YList[x]),XList[x],YList[x]);
          Inc(Offset,(XList[x]*YList[x]));
        end;
      end;

      Result := NumE;

      DrvInfo.ID := 'ART';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Duke Nukem 3D .GRP support =============================================== //
// -------------------------------------------------------------------------- //

type GRPHeader = packed record
        ID: Array[1..12] of Char;
        DirNum: Integer;
     end;
     GRPEntry = packed record
        FileName: Array[1..12] of Char;
        FileSize: integer;
     end;

const GRPID: String = 'KenSilverman';

function ReadDuke3DGRP(src: string): Integer;
var HDR: GRPHeader;
    ENT: GRPEntry;
    disp: string;
    NumE, x: integer;
    Offset: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, 16);

    if HDR.ID <> GRPID then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadDuke3DGRP := -3;
      ErrInfo.Format := 'GRP';
      ErrInfo.Games := 'Duke Nukem 3D & Shadow Warrior';
    end
    else
    begin

      NumE := HDR.DirNum;
      Offset := NumE * 16 + 16;

      for x:= 1 to NumE do
      begin

        Per := ROund(((x / NumE)*100));
        SetPercent(Per);
        FileRead(Fhandle,ENT,16);
        disp := Strip0(ENT.FileName);

        FSE_Add(disp,Offset,ENT.FileSize,0,0);

        Offset := Offset + ENT.FileSize;
      end;

      ReadDuke3DGRP := NumE;

      DrvInfo.ID := 'KSGRP';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    ReadDuke3DGRP := -2;

end;

// -------------------------------------------------------------------------- //
// Dune 3 .RFH support ====================================================== //
// -------------------------------------------------------------------------- //

type RFH_Entry = packed record
       NameLength: integer;
       DateAdded: integer;
       IsPacked: integer;
       PackedSize: integer;
       OriginalSize: integer;
       Offset: integer;
     end;

type RFC_Entry = packed record
       Unknown1: integer;
       IsPacked: integer;
       PackedSize: integer;
       OriginalSize: integer;
       Offset: integer;
       Unknown2: integer;
       NameLength: integer;
     end;

function ReadDune3RFH(src: string): Integer;
var ENT: RFH_Entry;
    ENTC: RFC_Entry;
    disp,dfil,cfil: string;
    NumE: integer;
    Hhandle, Chandle: integer;
    NumEntries, x: integer;
    EndSize, CSize: int64;
    IsError: Boolean;
begin

  Hhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);
  Result := -4;
  NumE := 0;

  if Hhandle >= 0 then
  begin

    dfil := ChangeFileExt(src,'.rfd');
    cfil := ChangeFileExt(src,'.rfc');

    if not(FileExists(dfil)) then
    begin
      FileClose(Hhandle);
      FHandle := 0;
      Result := -4;
      ErrInfo.Format := 'RFH/RFD';
      ErrInfo.Games := dfil;
    end
    else if FileExists(cfil) then
    begin
      FileClose(Hhandle);
      Fhandle := FileOpen(dfil, fmOpenRead or fmShareDenyWrite);

      if Fhandle < 0 then
      begin
        FHandle := 0;
        Result := -4;
        ErrInfo.Format := 'RFH/RFD';
        ErrInfo.Games := dfil;
      end
      else
      begin

        Chandle := FileOpen(cfil, fmOpenRead or fmShareDenyWrite);

        if Chandle < 0 then
        begin
          FileClose(FHandle);
          FHandle := 0;
          Result := -4;
          ErrInfo.Format := 'RFH/RFD';
          ErrInfo.Games := cfil;
        end
        else
        begin

          CSize := FileSeek(CHandle, 0,2);
          FileSeek(CHandle, 0, 0);
          EndSize := FileSeek(FHandle, 0,2);
          FileSeek(FHandle, 0, 0);

          FileRead(CHandle,numEntries,4);

          if (numEntries * SizeOf(RFC_Entry)) > CSize then
          begin
            FileClose(Fhandle);
            FileClose(Chandle);
            FileClose(Hhandle);
            FHandle := 0;
            Result := -3;
            ErrInfo.Format := 'RFH/RFD';
            ErrInfo.Games := 'F1 Manager 2000';
          end
          else
          begin

            IsError := false;

            for x := 1 to NumEntries do
            begin
              FileRead(CHandle,ENTC,SizeOf(RFC_Entry));
              if (ENTC.Offset > EndSize) or ((Int64(ENTC.Offset) + Int64(ENTC.PackedSize)) > EndSize) then
              begin
                FSE_free;
                NumE := 0;
                Result := -3;
                IsError := true;
                ErrInfo.Format := 'RFH/RFD';
                ErrInfo.Games := 'Emperor: Battle for Dune';
                break;
              end;
              disp := Get32(Chandle,ENTC.NameLength);
              if (ENTC.IsPacked <> 0) then
                FSE_Add(disp+'.cmp'+inttostr(ENTC.IsPacked),ENTC.Offset,ENTC.PackedSize,ENTC.IsPacked,ENTC.PackedSize)
              else
                FSE_Add(disp,ENTC.Offset,ENTC.OriginalSize,ENTC.IsPacked,ENTC.PackedSize);
              Inc(NumE);
            end;

            FileClose(Chandle);

            if not(IsError) then
            begin
              Result := NumE;

              DrvInfo.ID := 'RFH/RFD';
              DrvInfo.Sch := '\';
              DrvInfo.FileHandle := FHandle;
              DrvInfo.ExtractInternal := True;
            end;

          end;
        end;
      end;
    end
    else
    begin
      Fhandle := FileOpen(dfil, fmOpenRead or fmShareDenyWrite);

      EndSize := FileSeek(FHandle, 0,2);
      FileSeek(FHandle, 0, 0);

      NumE := 0;
      IsError := false;

      while FileSeek(Hhandle,0,1) < EndSize do
      begin
        Per := ROund(((EndSize / (FileSeek(Hhandle,0,1)+1))*100));
        SetPercent(Per);
        FileRead(Hhandle, ENT, 24);
        // Sanity checks
        if (ENT.Offset > EndSize) or ((Int64(ENT.Offset) + Int64(ENT.PackedSize)) > EndSize) then
        begin
          FSE_free;
          NumE := 0;
          Result := -3;
          IsError := true;
          ErrInfo.Format := 'RFH/RFD';
          ErrInfo.Games := 'Emperor: Battle for Dune';
          break;
        end;
        disp := Strip0(Get0(Hhandle));
        FSE_Add(disp,ENT.Offset,ENT.OriginalSize,ENT.IsPacked,ENT.PackedSize);
        Inc(NumE);
      end;

      FileClose(Hhandle);

      if not(IsError) then
      begin
        Result := NumE;

        DrvInfo.ID := 'RFH/RFD';
        DrvInfo.Sch := '\';
        DrvInfo.FileHandle := FHandle;
        DrvInfo.ExtractInternal := True;
      end;

    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Dune 3 .BAG support ====================================================== //
// -------------------------------------------------------------------------- //

type BAGHeader = packed record
        ID: array[0..3] of char;
        Unknown1: integer;
        DirNum: integer;
        EntrySize: integer;
     end;
     BAGEntry = packed record
        FileName: array[0..31] of char;
        Offset: integer;
        Size: integer;
        Freq: integer;
        MType: integer;
        Unknown: array[1..4] of integer;
     end;
     BAGEntry16 = packed record
        FileName: array[0..15] of char;
        Offset: integer;
        Size: integer;
        Freq: integer;
        MType: integer;
        Unknown: integer;
     end;

function ReadDune3BAG(src: string): Integer;
var HDR: BAGHeader;
    ENT: BAGEntry;
    ENT16: BAGEntry16;
    NumE,x,hIDX : integer;
    ext: string;
    IsIDX: Boolean;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    IsIDX := FileExists(ChangeFileExt(src,'.idx'));

    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR.ID, 4);
    FileRead(FHandle, HDR.Unknown1, 4);
    FileRead(FHandle, HDR.DirNum, 4);
    FileRead(FHandle, HDR.EntrySize, 4);

    if (HDR.ID = 'GABA') then
    begin
      if (HDR.EntrySize <> 64) then
      begin
        FileClose(Fhandle);
        FHandle := 0;
        Result := -3;
        ErrInfo.Format := 'BAG';
        ErrInfo.Games := 'Emperor: Battle for Dune, Nox';
      end
      else
      begin
        NumE := HDR.DirNum;

        for x := 1 to NumE do
        begin
          FileRead(FHandle,ENT.FileName, 32);
          FileRead(FHandle,ENT.Offset,4);
          FileRead(FHandle,ENT.Size,4);
          FileRead(FHandle,ENT.Freq,4);
          FileRead(FHandle,ENT.MType,4);
          FileRead(FHandle,ENT.Unknown,16);

          case ENT.MType of
            2: ext := 'w';
            6: ext := 'w';
            12: ext := 'cmp';
            28: ext := 'cmp';
            37: ext := 'mp3';
            else
              ext := 'raw';
          end;

          FSE_Add(Strip0(ENT.FileName)+'.'+ext,ENT.Offset,ENT.Size,0,0);

        end;

      //ShowMessage(IntTosTr(NumE));

        Result := NumE;

        DrvInfo.ID := 'BAG';
        DrvInfo.Sch := '';
        DrvInfo.FileHandle := FHandle;
        DrvInfo.ExtractInternal := False;

      end;
    end
    else if IsIDX then
    begin
      FileSeek(Fhandle, 0, 0);
      hIDX := FileOpen(ChangeFileExt(src,'.idx'),fmOpenRead or fmShareDenyWrite);

      FileSeek(hIDX, 0, 0);
      FileRead(hIDX, HDR.ID, 4);
      FileRead(hIDX, HDR.Unknown1, 4);
      FileRead(hIDX, HDR.DirNum, 4);

      if HDR.ID = 'GABA' then
      begin

        NumE := HDR.DirNum;

        for x := 1 to NumE do
        begin
          FileRead(hIDX,ENT16,SizeOf(ENT16));

          case ENT16.MType of
            2: ext := 'w';
            6: ext := 'w';
            12: ext := 'cmp';
            28: ext := 'cmp';
            37: ext := 'mp3';
            else
              ext := 'raw';
          end;

          FSE_Add(Strip0(ENT16.FileName)+'.'+ext,ENT16.Offset,ENT16.Size,0,0);

        end;

      //ShowMessage(IntTosTr(NumE));

        Result := NumE;

        DrvInfo.ID := 'BAG';
        DrvInfo.Sch := '';
        DrvInfo.FileHandle := FHandle;
        DrvInfo.ExtractInternal := False;

      end
{      else if (HDR.ID[0] = #235) and (HDR.ID[1] = #188) and (HDR.ID[2] = #237) and (HDR.ID[3] = #250) then
      begin



      end}
      else
      begin
        FileClose(Fhandle);
        FileClose(hIDX);
        FHandle := 0;
        Result := -3;
        ErrInfo.Format := 'BAG';
        ErrInfo.Games := 'Emperor: Battle for Dune, Nox';
      end;
    end
    else
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'BAG';
      ErrInfo.Games := 'Emperor: Battle for Dune, Nox';
    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Dungeon Keeper 2 .WAD support ==================================== PARTIAL //
// -------------------------------------------------------------------------- //

type DWFBHeader = packed record
       ID: array[0..3] of char;
       Version: integer;
       Filler: array[0..63] of byte;
       Dirnum: integer;
       NameOffset: integer;
       NameSize: integer;
       Unknown: integer;
     end;
     DWFBEntry = packed record
       Unknown: integer;
       NameOffset: integer;
       NameSize: integer;
       Offset: integer;
       Size: integer;        // Compressed size in bytes
       CompMethod: integer;  // Compression method: 0 = None
                             //                     4 = Unknown compression method
       UncompSize: integer;  // Decompressed size in bytes
       Filler: array[0..11] of byte;
     end;

function ReadDungeonKeeper2DWFB(): Integer;
var HDR: DWFBHeader;
    ENT: DWFBEntry;
    disp: string;
    NumE, x: integer;
begin

  FileSeek(Fhandle, 0, 0);
  FileRead(Fhandle, HDR, 88);

  if HDR.ID <> 'DWFB' then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    ReadDungeonKeeper2DWFB := -3;
    ErrInfo.Format := 'DWFB';
    ErrInfo.Games := 'Dungeon Keeper 2, ..';
  end
  else
  begin

    NumE := HDR.Dirnum;

    str(NumE, disp);

    for x:= 1 to NumE do
    begin

      Per := ROund(((x / NumE)*100));
      SetPercent(Per);
      FileSeek(Fhandle, SizeOf(DWFBHeader) + (x - 1) * SizeOf(DWFBEntry), 0);
      FileRead(Fhandle, ENT, 40);

      FileSeek(FHandle, ENT.NameOffset,0);
      disp := Get32(FHandle,ENT.NameSize);

      FSE_Add(Strip0(disp),ENT.Offset,ENT.Size,ENT.CompMethod,ENT.UncompSize);

    end;

    ReadDungeonKeeper2DWFB := NumE;

    DrvInfo.ID := 'DWFB';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// Dungeon Keeper 2 .SDT support ============================================ //
// -------------------------------------------------------------------------- //

type SDTIndex = packed record
       ISize: integer;
       Size: integer;
       Filename: array[0..15] of char;
       Unknow1: integer;
       Unknow2: integer;
       Unknow3: integer;
       Unknow4: integer;
     end;

function ReadDungeonKeeper2SDT(src: string): Integer;
var ENT: SDTIndex;
    disp: string;
    NumE, x: integer;
    Offset: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, NumE, 4);

    if NumE <= 0 then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadDungeonKeeper2SDT := -3;
      ErrInfo.Format := 'SDT';
      ErrInfo.Games := 'Dungeon Keeper 2';
    end
    else
    begin

      for x:= 1 to NumE do
      begin

        Per := ROund(((x / NumE)*100));
        SetPercent(Per);
        FileSeek(FHandle,x*4,0);
        FileRead(FHandle,Offset,4);
        FileSeek(FHandle,Offset,0);
        FileRead(Fhandle,ENT,40);
        Offset := Offset + ENT.ISize;
        disp := Strip0(ENT.Filename);
        disp := ChangeFileExt(disp,'.mp2');

        FSE_Add(disp,Offset,ENT.Size,0,0);

      end;

      ReadDungeonKeeper2SDT := NumE;

      DrvInfo.ID := 'SDT';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    ReadDungeonKeeper2SDT := -2;

end;

// -------------------------------------------------------------------------- //
// Earth Siege 2 .VOL support =============================================== //
// -------------------------------------------------------------------------- //

type VOL_Header = packed record
       ID: array[0..3] of char;
       Version: integer;
       Unknow: word;
     end;
//get16 DirList$
     VOL_Header2 = packed record
       DirNum: word;
       ENTSize: Integer;
     end;
     VOL_Entry = packed record
       Filename: array[0..11] of char;
       Unknow: byte;
       DirIndex: byte;
       Offset: integer;
     end;

function ReadEarthSiege2VOL: Integer;
var HDR: VOL_Header;
    HDR2: VOL_Header2;
    ENT, OLD: VOL_Entry;
    NumE,x,p: integer;
    BufNam: string;
    EList: TStringList;
    FSize: word;
begin

    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR.ID, 4);
    FileRead(FHandle, HDR.Version, 4);
    FileRead(FHandle, HDR.Unknow, 2);

    if (HDR.ID <> 'VOLN') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'VOL';
      ErrInfo.Games := 'Earth Siege 2';
    end
    else
    begin
      FileRead(FHandle,FSize,2);
//      BufNam := Get16(FHandle);

      EList := TStringList.Create;
      try
        p := 0;
        while p <= FSize do
        begin
          BufNam := Get0(FHandle);
          Inc(p,Length(BufNam));
          EList.Add(Strip0(BufNam));
        end;

        FileSeek(FHandle, 12+FSize,0);

        FileRead(FHandle, HDR2.DirNum, 2);
        FileRead(FHandle, HDR2.ENTSize, 4);

        NumE := HDR2.DirNum;

        for x := 1 to NumE do
        begin
          FileRead(FHandle,ENT.Filename,12);
          FileRead(FHandle,ENT.Unknow,1);
          FileRead(FHandle,ENT.DirIndex,1);
          FileRead(FHandle,ENT.Offset,4);

          if x>1 then
          begin
            FSE_Add(EList.Strings[OLD.DirIndex]+Strip0(OLD.Filename),OLD.Offset,ENT.Offset-OLD.Offset,OLD.Unknow,0);
          end;

          OLD.Filename := ENT.Filename;
          OLD.Unknow := ENT.Unknow;
          OLD.DirIndex := ENT.DirIndex;
          OLD.Offset := ENT.Offset;
        end;
        FSE_Add(EList.Strings[ENT.DirIndex]+Strip0(ENT.Filename),ENT.Offset,TotFSize-ENT.Offset,ENT.Unknow,0);
      finally
        FreeAndNil(EList);
      end;

      //ShowMessage(IntTosTr(NumE));

      Result := NumE;

      DrvInfo.ID := 'VOL';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

end;

// -------------------------------------------------------------------------- //
// Empires: Dawn of the Modern World .SSA support =========================== //
// -------------------------------------------------------------------------- //

type SSAHeader = packed record
       ID: array[0..3] of char;  // rass
       Version: integer;         // 1 ?
       Unknown: integer;
       DirSize: integer;         // Without the header
     end;
     SSAEntry = packed record
       // get16 filename
       Offset: integer;
       EndOffset: integer;
       Size: integer;
     end;
     SSACompress = packed record
       ID: array[0..3] of char;  // PK01
       DecompSize: integer;
       Unknown1: integer;
       Unknown2: word;
     end;

function ReadEmpiresDawnOfTheModernWorldSSA(src: string): Integer;
var HDR: SSAHeader;
    ENT: SSAEntry;
    NumE, curPos: integer;
    disp: string;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, SizeOf(HDR));

    if (HDR.ID <> 'rass') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'SSA';
      ErrInfo.Games := 'Empires: Dawn of the Modern World';
    end
    else
    begin
      curPos := FileSeek(FHandle,0,1);
      NumE := 0;

      while curPos < (HDR.DirSize + 12) do
      begin
        disp := strip0(get32(FHandle));
        FileRead(FHandle,ENT,SizeOf(ENT));
        inc(NumE);
        FSE_Add(disp,ENT.Offset,ENT.Size,0,0);
        curPos := FileSeek(FHandle,0,1);
      end;

      Result := NumE;

      DrvInfo.ID := 'SSA';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Enclave & Riddick .XWC/.XTC support ====================================== //
// -------------------------------------------------------------------------- //

type MOSChunk = packed record
       ID: array[0..23] of char;
       NextChunkOffset: integer;
     end;
     MOSSoundEntry = packed record
       Offset: integer;
       Size: integer;
     end;
     MOSTextureEntry_Init = packed record
       Unk1: integer;   // Always 0?
       MipMapNum: integer;        // Number of mipmap entries
       Unk3: integer;   // Always 512?
       Unk4: integer;
       FirstMipMapSize: integer;
       Width: integer;
       Height: integer;
     end;
     // Riddick have an integer here for unknown purpose...
     MOSTextureEntry_End = packed record
       TextureType: integer;
       Offset: integer;
       Unk10: integer;
       Unk11: integer;
       Unk12: integer;
       Unk13: integer;
       Unk14: integer;
       Unk15: integer;
       Unk16: word;
     end;
     MOSTextureEntry2_Init = packed record
       StopIndicator: integer;      // FFFFFFFF = Not end
       Empty: Integer;              // Always 0?
       NameLength: Integer;
     end;
     // Get32 texture name padded with spaces to 4 multiple
     MOSTextureEntry2_Start = packed record
       MipMapNum: integer;      // Number of mipmap entries
       Unk: array[1..2] of integer;
       FirstMipMapSize: integer;
       Width: integer;
       Height: integer;
       Unk2: integer;
       TextureType: integer;
       Unk3: integer;
       Unk4: integer;
     end;
     // Offsets: array[1..MipMapNum] of integer;    // Offsets to each mipmap (last offset is always wrong?)
     MOSTextureEntry2_End = packed record
       Unk2: array[1..4] of integer;
       Unk3: word;
     end;

type MOSDTextureLocalHeader_Init = packed record
       Unk1: integer;
       Unk2: integer;
       Unk3: integer;
       Width: integer;
       Height: integer;
     end;
     // Riddick have an integer here for unknown purpose...
     MOSDTextureLocalHeader_End = packed record
       Unk4: integer;      // Depth?
       TextureType: integer;
       Size: integer;
       Unk6: integer;
       Unk7: integer;
     end;

// MOS DATAFILE2.0 support
// Only WAVEDATA and TEXTURES are supported (XWC and XTC)
// In order to speed up reading from XTC files there is a buffering of the whole directory
// and then a parse through the directory
function ReadEnclaveMOS(src: string): Integer;
var HDR: MOSChunk;
    SND: MOSSoundEntry;
    TEX1: MOSTextureEntry_Init;
    TEX2: MOSTextureEntry_End;
    TEXHDR1: MOSDTextureLocalHeader_Init;
    TEXHDR2: MOSDTextureLocalHeader_End;
    TEXDA1: MOSTextureEntry2_Init;
    TEXDA2: MOSTextureEntry2_Start;
    TEXDA3: MOSTextureEntry2_End;
    DirCache: TMemoryStream;
    DirFile: THandleStream;
    disp: string;
    NumE, x, DirOffset, DirNum, NextOffset, Offset, Per, OldPer, FormatCheck, EntrySize, TextureOffset, MipMapOffset: integer;
//    fileType, Test1, Test2: integer;
    OggCheck: array[0..3] of char;
    isWave: boolean;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, SizeOf(MOSChunk));

    if strip0(HDR.ID) <> 'MOS DATAFILE2.0' then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'MOSD';
      ErrInfo.Games := 'Enclave, The Chronicles of Riddick: Butcher Bay';
    end
    else
    begin

      NumE := 0;

      isWave := false;

      repeat
        Fileseek(FHandle, HDR.NextChunkOffset, 0);
        FileRead(FHandle, HDR, SizeOf(MOSChunk));
        if (strip0(HDR.ID) = 'WAVEDATA') then
        begin
          FileSeek(FHandle,8,1);
          FileRead(Fhandle,DirOffset,4);
          FileRead(Fhandle,DirNum,4);
          NextOffset := DirOffset+48;
          for x := 1 to DirNum do
          begin
            FileSeek(FHandle,NextOffset,0);
            FileRead(Fhandle,SND,SizeOf(MOSSoundEntry));
            disp := Get32(Fhandle);
            if (length(disp) mod 4) <> 0 then
              NextOffset := FileSeek(Fhandle,4 - (Length(disp) mod 4),1)
            else
              NextOffset := FileSeek(Fhandle,0,1);
            if SND.Size >= 40 then
            begin
              FileSeek(Fhandle,SND.Offset+36,0);
              FileRead(Fhandle,OggCheck,4);
              if strip0(OggCheck) = 'OggS' then // Enclave
              begin
                disp := disp + '.ogg';
                dec(SND.Size,36);
                inc(SND.Offset,36);
              end
              else if SND.Size >= 44 then // Chronicles of Riddick
              begin
                FileSeek(Fhandle,SND.Offset+40,0);
                FileRead(Fhandle,OggCheck,4);
                if strip0(OggCheck) = 'OggS' then
                begin
                  disp := disp + '.ogg';
                  dec(SND.Size,40);
                  inc(SND.Offset,40);
                end
                else if SND.Size >= 52 then // Assault on Dark Athena
                begin
                  FileSeek(Fhandle,SND.Offset+48,0);
                  FileRead(Fhandle,OggCheck,4);
                  if strip0(OggCheck) = 'OggS' then
                  begin
                    disp := disp + '.ogg';
                    dec(SND.Size,48);
                    inc(SND.Offset,48);
                  end;
                end;
              end;
            end;
            FSE_Add(disp,SND.Offset,SND.Size,0,0);
            inc(NumE);
          end;
          isWave := true;
        end
        else if (strip0(HDR.ID) = 'TEXTURES') then
        begin
          FileSeek(FHandle,8,1);
          FileRead(Fhandle,DirOffset,4);
          FileRead(Fhandle,DirNum,4);
          DirFile := THandleStream.Create(Fhandle);
          Offset := DirFile.Seek(0,1);
          DirFile.Seek(DirOffset,0);
          DirFile.Read(FormatCheck,4);  // 512 = Enclave?    Else = Riddick?
          DirFile.Seek(52,1);
          DirCache := TMemoryStream.Create;
          DirCache.CopyFrom(DirFile,Offset-DirOffset-24-56);
          NextOffset := 0;
          OldPer := -6;
          EntrySize := SizeOf(MOSTextureEntry_Init)+SizeOf(MOSTextureEntry_End);
          if FormatCheck <> 512 then // Riddick?
            inc(EntrySize,4);
          for x := 1 to DirNum do
          begin
            Per := ROund(((x / DirNum)*100));
            if (Per > OldPer + 5) then
            begin
              SetPercent(Per);
              OldPer := Per;
            end;
            Dircache.Seek(NextOffset,0);
//            FileSeek(FHandle,NextOffset,0);
            disp := Get32(DirCache);
            if (length(disp) mod 4) <> 0 then
              NextOffset := Dircache.Seek(4 - (Length(disp) mod 4),1)+EntrySize
            else
              NextOffset := DirCache.Seek(0,1)+EntrySize;
            Dircache.Read(TEX1,SizeOf(MOSTextureEntry_Init));
            if FormatCheck <> 512 then // Riddick?
              Dircache.Seek(4,1);
            Dircache.Read(TEX2,SizeOf(MOSTextureEntry_End));
            inc(NumE);
            FileSeek(Fhandle,TEX2.Offset,0);
            FileRead(Fhandle,Offset,4);
            FileSeek(Fhandle,Offset,0);
            FileRead(FHandle,TEXHDR1,SizeOf(MOSDTextureLocalHeader_Init));
            if FormatCheck <> 512 then // Riddick?
              FileSeek(Fhandle,4,1);
            FileRead(FHandle,TEXHDR2,SizeOf(MOSDTextureLocalHeader_End));

            if (TEXHDR1.Width > 0) and (TEXHDR1.Height > 0) and ((TEXHDR2.TextureType = 0) or (TEXHDR2.TextureType = 2) or (TEXHDR2.TextureType = 4)) then
              FSE_Add(disp+'.dds',TEX2.Offset,TEX1.FirstMipMapSize,1,TEX1.MipMapNum)
            else
              FSE_Add(disp,TEX2.Offset,TEX1.FirstMipMapSize,0,0)
          end;
        end
        else if (strip0(HDR.ID) = 'IMAGELIST') then  // Textures for The Chronicles of Riddick Assault on Dark Athena
        begin
          FormatCheck := 512; // To avoid being detected as Riddick by extraction routine
          FileSeek(FHandle,4,1);
          FileRead(Fhandle,DirOffset,4);
          DirFile := THandleStream.Create(Fhandle);
          Offset := DirFile.Seek(0,1);
          DirFile.Seek(DirOffset,0);
          DirFile.Read(TEXDA1,SizeOf(TEXDA1));
          while TEXDA1.StopIndicator = -1 do
          begin
            disp := Get32(DirFile,TEXDA1.NameLength);
            if (TEXDA1.NameLength mod 4) > 0 then
              DirFile.Seek((((Trunc(TEXDA1.NameLength / 4)+1) * 4) - TEXDA1.NameLength),1);
            MipMapOffset := DirFile.Seek(0,1);
            DirFile.Read(TEXDA2,SizeOf(TEXDA2));
            DirFile.Read(TextureOffset,4);
            inc(NumE);
            if (TEXDA2.Width > 0) and (TEXDA2.Height > 0) and ((TEXDA2.TextureType = 0) or (TEXDA2.TextureType = 2) or (TEXDA2.TextureType = 4)) then
              FSE_Add(disp+'.dds',TextureOffset,TEXDA2.FirstMipMapSize,2,MipMapOffset)
            else
              FSE_Add(disp,TextureOffset,TEXDA2.FirstMipMapSize,0,0);
            DirFile.Seek(4*(TEXDA2.MipMapNum-1),1);
            DirFile.Read(TEXDA3,SizeOf(TEXDA3));
            DirFile.Read(TEXDA1,SizeOf(TEXDA1));
          end;

{          DirCache := TMemoryStream.Create;
          DirCache.CopyFrom(DirFile,Offset-DirOffset-24-56);
          NextOffset := 0;
          OldPer := -6;
          EntrySize := SizeOf(MOSTextureEntry_Init)+SizeOf(MOSTextureEntry_End);
          if FormatCheck <> 512 then // Riddick?
            inc(EntrySize,4);
          for x := 1 to DirNum do
          begin
            Per := ROund(((x / DirNum)*100));
            if (Per > OldPer + 5) then
            begin
              SetPercent(Per);
              OldPer := Per;
            end;
            Dircache.Seek(NextOffset,0);
//            FileSeek(FHandle,NextOffset,0);
            disp := Get32(DirCache);
            if (length(disp) mod 4) <> 0 then
              NextOffset := Dircache.Seek(4 - (Length(disp) mod 4),1)+EntrySize
            else
              NextOffset := DirCache.Seek(0,1)+EntrySize;
            Dircache.Read(TEX1,SizeOf(MOSTextureEntry_Init));
            if FormatCheck <> 512 then // Riddick?
              Dircache.Seek(4,1);
            Dircache.Read(TEX2,SizeOf(MOSTextureEntry_End));
            inc(NumE);
            FileSeek(Fhandle,TEX2.Offset,0);
            FileRead(Fhandle,Offset,4);
            FileSeek(Fhandle,Offset,0);
            FileRead(FHandle,TEXHDR1,SizeOf(MOSDTextureLocalHeader_Init));
            if FormatCheck <> 512 then // Riddick?
              FileSeek(Fhandle,4,1);
            FileRead(FHandle,TEXHDR2,SizeOf(MOSDTextureLocalHeader_End));

            if (TEXHDR1.Width > 0) and (TEXHDR1.Height > 0) and ((TEXHDR2.TextureType = 0) or (TEXHDR2.TextureType = 2) or (TEXHDR2.TextureType = 4)) then
              FSE_Add(disp+'.dds',TEX2.Offset,TEX1.FirstMipMapSize,1,TEX1.MipMapNum)
            else
              FSE_Add(disp,TEX2.Offset,TEX1.FirstMipMapSize,0,0)
          end;}
        end;
      until HDR.NextChunkOffset = 0;

      Result := NumE;

      if Result = 0 then
      begin

        DrvInfo.Sch := '';
        DrvInfo.ID := '';
        DrvInfo.FileHandle := 0;

        if FHandle <> 0 then
          FileClose(FHandle);

        FHandle := 0;
        CompressionWindow := 0;

      end
      else
      begin

        if isWave then
        begin
          DrvInfo.ID := 'MOSD';
          DrvInfo.ExtractInternal := False;
        end
        else
        begin
          if formatCheck <> 512 then
            DrvInfo.ID := 'MOSDr'
          else
            DrvInfo.ID := 'MOSDe';
          DrvInfo.ExtractInternal := True;
        end;

        DrvInfo.Sch := '';
        DrvInfo.FileHandle := FHandle;

      end;

    end;
  end
  else
    Result := -2;

end;

// Function to extract textures from MOS DATAFILE2.0 to DDS
// Only supports textures types 0, 2 & 4 (DXT1, DXT3 & DXT5)
// If something weird is found, just do a BinCopy extraction (there are some weird entries in those files...)
function ExtractMOSDTextureToDDS(outputstream: TStream; Offset, Size: int64; MipMapnum: integer; BufferSize: integer; silent, isRiddick, isDarkAthena: boolean): boolean;
var DDS: DDSHeader;
    TEXHDR1: MOSDTextureLocalHeader_Init;
    TEXHDR2: MOSDTextureLocalHeader_End;
    TEXDA2: MOSTextureEntry2_Start;
    MipMapOffsets: array of integer;
    inFile: THandleStream;
    x: integer;
begin

  SetLength(MipMapOffsets, MipMapNum);

  inFile := THandleStream.Create(FHandle);

  if isDarkAthena then
  begin
    inFile.Seek(MipMapNum,0);
    inFile.Read(TEXDA2,SizeOf(TEXDA2));
    MipMapNum := TEXDA2.MipMapNum;
  end
  else
  begin
    inFile.Seek(Offset,0);
  end;

  for x := 0 to MipMapNum - 1 do
    inFile.Read(MipMapOffsets[x],4);

  inFile.Seek(MipMapOffsets[0],0);
  inFile.Read(TEXHDR1,SizeOf(MOSDTextureLocalHeader_Init));
  if isRiddick then
    inFile.Seek(4,1);
  inFile.Read(TEXHDR2,SizeOf(MOSDTextureLocalHeader_End));

  // Sanity checks, if they fail, we just extract a BinCopy
  if (TEXHDR1.Width <= 0) or (TEXHDR1.Height <= 0) or (TEXHDR2.Size <= 0) or ((TEXHDR2.TextureType <> 0) and (TEXHDR2.TextureType <> 2) and (TEXHDR2.TextureType <> 4)) then
  begin

    FreeAndNil(inFile);
    BinCopyToStream(Fhandle,outputstream,Offset,Size,0,BufferSize,silent,SetPercent);

  end
  else
  begin

    //MipMapNum := 1;

    FillChar(DDS,SizeOf(DDSHeader),0);
    DDS.ID[0] := 'D';
    DDS.ID[1] := 'D';
    DDS.ID[2] := 'S';
    DDS.ID[3] := ' ';
    DDS.SurfaceDesc.dwSize := 124;
    DDS.SurfaceDesc.dwFlags := DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or DDSD_PIXELFORMAT or DDSD_LINEARSIZE;
    if MipMapNum > 1 then
      DDS.SurfaceDesc.dwFlags := DDS.SurfaceDesc.dwFlags or DDSD_MIPMAPCOUNT;
    DDS.SurfaceDesc.dwHeight := TEXHDR1.Height;
    DDS.SurfaceDesc.dwWidth := TEXHDR1.Width;
    DDS.SurfaceDesc.dwPitchOrLinearSize := TEXHDR2.Size;
    DDS.SurfaceDesc.dwMipMapCount := MipMapnum;
    DDS.SurfaceDesc.ddpfPixelFormat.dwSize := 32;
    DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_FOURCC;
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[0] := 'D';
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[1] := 'X';
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[2] := 'T';
    if (TEXHDR2.TextureType = 4) then
      DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[3] := '5'
    else if (TEXHDR2.TextureType = 2) then
      DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[3] := '3'
    else
      DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[3] := '1';
    DDS.SurfaceDesc.ddsCaps.dwCaps1 := DDSCAPS_TEXTURE;
    if MipMapNum > 1 then
      DDS.SurfaceDesc.ddsCaps.dwCaps1 := DDS.SurfaceDesc.ddsCaps.dwCaps1 or DDSCAPS_COMPLEX or DDSCAPS_MIPMAP;

    outputstream.Write(DDS,SizeOf(DDSHeader));

    for x := 0 to MipMapNum - 2 do
    begin
      inFile.Seek(MipMapOffsets[x],0);
      inFile.Read(TEXHDR1,SizeOf(MOSDTextureLocalHeader_Init));
      if isRiddick then
        inFile.Seek(4,1);
      inFile.Read(TEXHDR2,SizeOf(MOSDTextureLocalHeader_End));
      if isDarkAthena then
        if TEXHDR1.Unk2 = 0 then
          inFile.seek(MipMapOffsets[x]+36,0)
        else
          inFile.Seek(12,1);
      outputstream.CopyFrom(inFile,TEXHDR2.Size);
    end;

    FreeAndNil(inFile);

  end;

  result := true;

end;

// -------------------------------------------------------------------------- //
// Entropia Universe .BNT support =========================================== //
// -------------------------------------------------------------------------- //

// Go end of file, the 8 last bytes are:
//   Index of Directory entries (4 bytes - Interger/Cardinal)
//   Magic ID (4 bytes - "BNT2")

type BNT2Entry = packed record
      Size: integer;
      Offset: integer;
      Unknown01CRC: integer;   // CRC or Checksum?
      Unknown02Null: integer;  // 00 00 00 00
    end;

function ReadEntropiaUniverseBNT(src: string): Integer;
var ID: array[0..3] of char;
    DirOffset: integer;
    ENT: BNT2Entry;
    NumE, x: integer;
    disp: string;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    // Go to end of file minus 4 bytes
    FileSeek(Fhandle, -4, 2);

    // Read the ID
    FileRead(FHandle, ID, 4);

    // If the ID is not BNT2 then this is not an Entropia Universe BNT file
    if (ID <> 'BNT2') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'BNT2';
      ErrInfo.Games := 'Entropia Universe';
    end
    else
    begin

      // Go to end of file minus 8 bytes
      FileSeek(FHandle,-8,2);

      // Read the directory offset
      FileRead(FHandle,DirOffset,4);

      // Go to directory offset
      FileSeek(FHandle,DirOffset,0);

      // Read number of entries in the file
      FileRead(FHandle,NumE,4);

      // Read each entry
      for x := 1 to NumE do
      begin

        // Filename (ending with 0x0A)
        disp := strip0A(get0A(FHandle));

        // Entry info
        FileRead(FHandle,ENT,SizeOf(ENT));

        // Add entry to FSE
        FSE_Add(disp,ENT.Offset,ENT.Size,ENT.Unknown01CRC,ENT.Unknown02Null);

      end;

      Result := NumE;

      DrvInfo.ID := 'BNT2';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// EVE Online .STUFF support ================================================ //
// -------------------------------------------------------------------------- //

type
  STUFFList = record
    Name: string;
    Size: integer;
  end;

function ReadEveOnlineSTUFF : Integer;
var NumE,Size,DataOffset,x : integer;
    disp : string;
    ENTL: array of STUFFList;
begin

  TotFSize := FileSeek(FHandle,0,2);

  FileSeek(Fhandle, 0, 0);
  FileRead(FHandle, NumE, 4);

//  Result := 0;

  if (NumE > TotFSize) or (NumE < 1) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'STUFF';
    ErrInfo.Games := 'Eve Online';
  end
  else
  begin

    SetLength(ENTL,NumE);
    for x := 0 to NumE-1 do
    begin
      FileRead(FHandle,Size,4);
      FileSeek(FHandle,4,1);
      Disp := strip0(get0(Fhandle));
      ENTL[x].Name := Disp;
      ENTL[x].Size := Size;
    end;

    DataOffset := FileSeek(FHandle,0,1);

    for x := 0 to NumE-1 do
    begin
      FSE_Add(ENTL[x].Name,DataOffset,ENTL[x].Size,0,0);
      inc(DataOffset,ENTL[x].Size);
    end;

    SetLength(ENTL,0);

    Result := NumE;

    DrvInfo.ID := 'STUFF';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// Evil Islands .RES support ================================================ //
// -------------------------------------------------------------------------- //

Type EIRES_Header = packed record
       ID: integer;      // &H19CE23C
       DirNum: integer;
       DirOffset: integer;
       NameSt: integer;
     end;
     EIRES_Entry = packed record
       Unknown1: integer;
       Size: integer;
       Offset: integer;
       Unknown2: integer;
       NameSize: word;
       NameOffset: integer;
     end;

function ReadEvilIslandsRES(): Integer;
var HDR: EIRES_Header;
    ENT: EIRES_Entry;
    NumE,x,z : integer;
    BufName: PChar;
    nam: string;
begin

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR.ID, 4);
    FileRead(FHandle, HDR.DirNum, 4);
    FileRead(FHandle, HDR.DirOffset, 4);
    FileRead(FHandle, HDR.NameSt, 4);

    if (IntToHex(HDR.ID,7) <> '19CE23C') or (HDR.DirOffset > TotFSize) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'EIRES';
      ErrInfo.Games := 'Evil Islands';
    end
    else
    begin
      GetMem(BufName,HDR.NameSt);
      try
        FileSeek(FHandle,TotFSize-HDR.NameSt,0);
        FileRead(FHandle,BufName^,HDR.NameSt);

        FileSeek(FHandle,HDR.DirOffset,0);

        NumE := HDR.DirNum;

        for x := 1 to NumE do
        begin

          FileRead(FHandle,ENT.Unknown1, 4);
          FileRead(FHandle,ENT.Size,4);
          FileRead(FHandle,ENT.Offset,4);
          FileRead(FHandle,ENT.Unknown2, 4);
          FileRead(FHandle,ENT.NameSize,2);
          FileRead(FHandle,ENT.NameOffset,4);

          nam := '';
          for z := ENT.NameOffset to ENT.NameOffset + ENT.NameSize-1 do
            nam := nam + BufName[z];

          FSE_Add(Strip0(nam),ENT.Offset,ENT.Size,0,0);

      end;
      finally
        Freemem(BufName);
      end;

      //ShowMessage(IntTosTr(NumE));

      Result := NumE;

      DrvInfo.ID := 'EIRES';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// F-22 Advanced Dominance Fighter .DAT support ============================= //
// F-22 Total Air War .DAT support ========================================== //
// Super EF2000 .DAT support ================================================ //
// -------------------------------------------------------------------------- //

// Experimental and PARTIAL F-22 Advanced Dominance Fighter .DAT files
// The filenames are stored in the EXE files of the game
// The DAT file only use some sort of Hash value, this function only retrieve
// the hash and that's all... It is dirty but better than nothing! :)

type F22adfDAT_Entry = packed record
       Hash: integer;
       Offset: integer;
       Size: integer;
     end;

// The DecompressRA class do not work yet (my Delphi translation from C++ is obviously wrong)
// Will be reactivated when I get time to check what I did wrong
{procedure DecompressF22DAT(FHandle: integer; outputstream: TStream; offset,size: int64; silent: boolean);
var DEC: DecompressRA;
    inMem: TStream;
    inHandle: THandleStream;
begin

  inMem := TMemoryStream.Create;
  inHandle := THandleStream.Create(FHandle);
  inMem.CopyFrom(inHandle,size);

  DEC := DecompressRA.Create;

  inMem.Seek(0,0);
  if DEC.isRA(inMem) then
  begin
    DEC.decompress(inMem,outputstream);
  end
  else
  begin
    inMem.Seek(0,0);
    outputstream.CopyFrom(inMem,inMem.Size); 
  end;

  FreeAndNil(DEC);

  FreeAndNil(inHandle);
  FreeAndNil(InMem);

end;}

function ReadF22adfDAT(): Integer;
var ENT: F22adfDAT_Entry;
    DirNames: array of string;
    ExtNames: array of string;
    test: array[0..1] of char;
    DirOffset,EntOffset,NumE,x : integer;
    DirNum,NameSize,DirNameNum,ExtNameNum : word;
    Per, OldPer: Byte;
begin

  FileSeek(Fhandle, 0, 0);

  // Read & seek to the offset to the directory structure
  FileRead(FHandle, DirOffset, 4);

  // Sanity check
  if (DirOffset <= 4) or (DirOffset > TotFSize) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'F22DAT';
    ErrInfo.Games := 'F22 ADF';
    exit;
  end;

  FileSeek(Fhandle, DirOffset,0);

  // Read the number of entries
  FileRead(FHandle, DirNum,2);
  // Read the number of directory names
  FileRead(FHandle, DirNameNum,2);
  // Read the number of extension names
  FileRead(FHandle, ExtNameNum,2);
  // Read the size of the directory+extension names block
  FileRead(FHandle, NameSize,2);

  // Sanity check
  if (DirOffset+NameSize+8) > TotFSize then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'F22DAT';
    ErrInfo.Games := 'F22 ADF';
    exit;
  end;

  // Read the directory names
  setLength(DirNames,DirNameNum);
  for x := 1 to DirNameNum do
    DirNames[x-1] := Get8(Fhandle);

  // Read the extension names
  setLength(ExtNames,ExtNameNum);
  for x := 1 to ExtNameNum do
    ExtNames[x-1] := Get8(Fhandle);

  // Sanity check
  if (FileSeek(FHandle,0,1) > DirOffset+NameSize+8) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'F22DAT';
    ErrInfo.Games := 'F22 ADF';
    exit;
  end;

  // Just to be sure, we calculate the offset of the entries and seek there
  EntOffset := DirOffset+NameSize+8;
  fileSeek(FHandle,EntOffset,0);

  // For each entry read the hash, offset and size
  NumE := DirNum;

  OldPer := 0;
  SetPercent(0);

  for x := 1 to NumE do
  begin

    Per := round((x / NumE) * 100);
    if (Per > OldPer + 5) then
    begin
      OldPer := Per;
      SetPercent(Per);
    end;

    FileSeek(FHandle,EntOffset+(x-1)*SizeOf(F22adfDAT_Entry),0);
    FileRead(FHandle,ENT,SizeOf(F22adfDAT_Entry));
    FileSeek(FHandle,ENT.Offset,0);
    FileRead(FHandle,test,2);

    // Sanity check
    if (ENT.Offset < 0) or (ENT.Offset > TotFSize)
    or (ENT.Size < 0) or (ENT.Size > TotFSize) or ((ENT.Offset + ENT.Size) > TotFSize) then
    begin
      FileClose(Fhandle);
      FSE_Free();
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'F22DAT';
      ErrInfo.Games := 'F22 ADF';
      exit;
    end;

    if test = 'RA' then
      FSE_Add(IntToHex(ENT.Hash,8)+'.RA',ENT.Offset,ENT.Size,0,0)
    else
      FSE_Add(IntToHex(ENT.Hash,8),ENT.Offset,ENT.Size,0,0);

  end;

  Result := NumE;

  DrvInfo.ID := 'F22DAT';
  DrvInfo.Sch := '';
  DrvInfo.FileHandle := FHandle;
  // RA decompression do not work yet...
  DrvInfo.ExtractInternal := false;

end;

// -------------------------------------------------------------------------- //
// Fable: The Lost Chapters .BIG support ======================= EXPERIMENTAL //
// -------------------------------------------------------------------------- //

     // Fable BIGB files
type FBIG_Header = packed record
       ID: array[0..3] of char;              // "BIGB"
       Unknown: integer;                     // Always 0x64 ?
       FooterOffset: Integer;
     end;
     // EntryName: Get0
     FBIG_FooterEntry = packed record
       Unknown1: Integer;
       NumEntries: Integer;
       Offset: Integer;
       Unknown2: Integer;
       Unknown3: Integer;
     end;
     // NumUnknownEntries: integer;
     FBIG_EntryUnknown = packed record
       Unknown1: integer;
       Unknown2: integer;
     end;
     FBIG_Entry = packed record
       Unknown1: integer;                  // 0x2A ?
       Unknown2: integer;                  // Counter
       Unknown3: integer;
       Size: integer;
       Offset: integer;
       Unknown4: integer;                  // Probably a checksum of some sort
     end;
     // EntryName: Get32
     // Unknown5: integer;
     // Unknown6: integer;
     // DescriptionName: Get32

// This is experimental, I don't think it is working correctly, but I keep it
// activated if someone is willing to use it, to figure it out a little bit more
// There is so many fields I am just skipping...
function ReadFableTheLostChaptersBIG: Integer;
var HDR: FBIG_Header;
    FTR: FBIG_FooterEntry;
//    UNK: FBIG_EntryUnknown;
    ENT: FBIG_Entry;
    base, disp: string;
    NumE, x, y, z, NumFooter, NumDesc, SizeDesc, CurP, Unknown5, UnknownJunkSize, NumUnknownEntries: integer;
    TotFSize: integer;
begin

  TotFSize := FileSeek(Fhandle,0,2);
  FileSeek(FHandle,0,0);
  FileRead(FHandle,HDR,SizeOf(HDR));

  if (HDR.ID <> 'BIGB') or (TotFSize < HDR.FooterOffset) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'BIGB';
    ErrInfo.Games := 'Fable: The Lost Chapters';
  end
  else
  begin

    FileSeek(FHandle,HDR.FooterOffset,0);
    FileRead(FHandle,NumFooter,4);

    NumE := 0;

    for x := 1 to NumFooter do
    begin
      base := strip0(get0(FHandle));
      FileRead(FHandle,FTR,SizeOf(FTR));
      CurP := FileSeek(FHandle,0,1);
      FileSeek(FHandle,FTR.Offset,0);
      FileRead(FHandle,NumUnknownEntries,4);
      FileSeek(FHandle,NumUnknownEntries*8,1);
      for y := 1 to FTR.NumEntries do
      begin
        FileRead(FHandle,ENT,SizeOf(ENT));
        disp := Get32(FHandle);
        FileRead(FHandle,Unknown5,4);
        FileRead(FHandle,NumDesc,4);
        for z := 1 to NumDesc do
        begin
          FileRead(FHandle,SizeDesc,4);
          FileSeek(FHandle,SizeDesc,1);
        end;
        FileRead(FHandle,UnknownJunkSize,4);
        FileSeek(Fhandle,UnknownJunkSize,1);
        FSE_Add(base+'\'+disp,ENT.Offset,ENT.Size,ENT.Unknown2,ENT.Unknown4);
        inc(NumE);
      end;
      FileSeek(FHandle,CurP,0);
    end;

    Result := NumE;

    DrvInfo.ID := 'BIGB';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// F.E.A.R. .ARCH00 support ================================================= //
// -------------------------------------------------------------------------- //

type ARCH00_Header = packed record
       ID: array[0..3] of char;     // LTAR
       Unknown1: Integer;           // Always 3 ? Version ?
       NameSize: Integer;
       NumDirectories: Integer;
       NumEntries: Integer;
       Unknown3: Integer;
       Unknown4: Integer;
       Unknown5: Integer;
       Unknown6: Integer;
       Unknown7: Integer;
       Unknown8: Integer;
       Unknown9: Integer;
     end;
     ARCH00_Entry = packed record
       NamePos: Integer;
       Offset: Int64;
       Size: Int64;
       Size2: Int64;       // UncSize ?
       Dummy: Integer;
     end;
     ARCH00_Directory = packed record
       NamePos: Integer;
       Unknown1: Integer;
       Unknown2: Integer;
       NumEntries: Integer;
     end;

function ReadFearARCH00(src: string): Integer;
var HDR: ARCH00_Header;
    ENT: ARCH00_Entry;
    DIR: ARCH00_Directory;
    disp, dirname: string;
    NumE, x, curDir, curP, oldPer: integer;
    namStream, dirStream: TMemoryStream;
    filStream: THandleStream;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    // We read the header
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, SizeOf(HDR));

    // If the ID in the header is not LTAR, then this is not a FEAR .ARCH00 file
    if (HDR.ID <> 'LTAR') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'LTAR';
      ErrInfo.Games := 'F.E.A.R.';
    end
    else
    begin

      // We will first store both name chunks and whole directory chunk
      // in two TMemoryStreams for later use
      namStream := TMemoryStream.Create;
      dirStream := TMemoryStream.Create;

      try

        // We will enclose the handle in a THandleStream so we can copy from it
        filStream := THandleStream.Create(FHandle);

        try

          // We copy the names chunk to the memory stream
          namStream.CopyFrom(filStream,HDR.NameSize);

          // We store current offset
          curP := filStream.Seek(0,soFromCurrent);

          // We seek to the directory chunk offset
          filStream.Seek(HDR.NumEntries*SizeOf(ENT),soFromCurrent);

          // We copy the directory chunk to the memory stream
          dirStream.CopyFrom(filStream,SizeOf(DIR)*HDR.NumDirectories);

          // We go back to the stored offset
          filStream.Seek(curP,soBeginning);

        finally

          // We free the handle stream
          FreeAndNil(filStream);

        end;

        NumE := HDR.NumEntries;

        // This variable will be used to know in which directory we are
        // we start at -1 in advance for the forced first update
        curDir := -1;

        // We fill the directory entry variable with zeros to force an update
        // on first "for" run
        FillChar(DIR,SizeOf(DIR),0);

        OldPer := 0;

        // We will go through all entries
        for x := 1 to HDR.NumEntries do
        begin

          // Display progress
          Per := ROund(((x / HDR.NumEntries)*100));
          if (Per >= OldPer + 5) then
          begin
            SetPercent(Per);
            OldPer := Per;
          end;

          // This is used to retrieve current directory entry
          // It is enclosed in a while-do structure instead of if structure
          // because some directory entries have the NumEntries field already
          // at zero in the file...
          while (DIR.NumEntries = 0) do
          begin

            // We go to the next entry
            inc(curDir);
            dirStream.Seek(curDir*SizeOf(DIR),soBeginning);

            // We read it
            dirStream.ReadBuffer(DIR,SizeOf(DIR));

            // We retrieve the name
            namStream.Seek(DIR.NamePos,soBeginning);
            dirname := strip0(get0(namStream));

            // We include the trailing slash is needed
            if length(dirname)>0 then
              dirname := dirname + '\';

          end;

          // We read the entry
          FileRead(FHandle,ENT,SizeOf(ENT));

          // We retrieve the name
          namStream.Seek(ENT.NamePos,soBeginning);
          disp := strip0(get0(namStream));

          // We store the entry
          FSE_Add(dirname+disp,ENT.Offset,ENT.Size,0,0);

          // We decrease the directory entry counter
          dec(DIR.NumEntries);

        end;

      finally

        // We free both memory streams
        FreeAndNil(namStream);
        FreeAndNil(dirStream);

      end;

      Result := NumE;

      DrvInfo.ID := 'LTAR';
      DrvInfo.Sch := '\';
      // Extraction will be handled by Dragon UnPACKer core
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Florencia .PAK support =================================================== //
// -------------------------------------------------------------------------- //

type FlorensiaPAK_Entry = packed record
       Filename: array[0..255] of char;
       Empty: integer;
       Offset: integer;
       Size: integer;
       Unknown: array[0..6] of integer;
     end;

function checkFlorensiaPAK(inFile: integer): boolean;
var inStm: THandleStream;
    numEntries, testOffset, testSize, x: integer;
    totSize: int64;
    isFormat: boolean;
begin

  isFormat := false;

  inStm := THandleStream.Create(inFile);
  try
    inStm.Seek(0,soBeginning);
    inStm.Read(numEntries,4);
    totSize := (numEntries * SizeOf(FlorensiaPAK_Entry)) + 4;
    if (totSize < inStm.Size) and (numEntries > 0) then
    begin
      isFormat := true;
      for x := 0 to numEntries-1 do
      begin
        inStm.Seek(260,soFromCurrent);
        inStm.Read(testOffset,4);
        inStm.Read(testSize,4);
        inStm.Seek(28,soFromCurrent);
        inc(totSize,testSize);
        if ((testOffset + testSize) > inStm.Size) or (testOffset < 0) or (testSize < 0) or (totSize > inStm.Size) then
        begin
          isFormat := false;
          break;
        end;
      end;
      isFormat := isFormat and (totSize = inStm.Size);
    end;
  finally
    FreeAndNil(inStm);
  end;

  result := isFormat;

end;

function readFlorensiaPAK(): Integer;
var ENT: FlorensiaPAK_Entry;
    disp: string;
    NumE, x: integer;
begin

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, NumE, 4);

    for x:= 1 to NumE do
    begin

      Per := ROund(((x / NumE)*100));
      SetPercent(Per);
      FileRead(Fhandle,ENT,SizeOf(FlorensiaPAK_Entry));
      disp := Strip0(ENT.Filename);

      FSE_Add(disp,ENT.Offset,ENT.Size,0,0);

    end;

    Result := NumE;

    DrvInfo.ID := 'FLPAK';
    DrvInfo.Sch := '';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Freespace/Conflict: Freespace .VP support ================================ //
// -------------------------------------------------------------------------- //

type VPHeader = packed record
       Signature: array[0..3] of char;
       Version: integer;
       DirOffset: integer;
       DirNum: integer;
     end;
     VPEntry = packed record
       Offset: integer;
       Size: integer;
       Filename: array[0..31] of char;
       Timestamp: integer;
     end;

function ReadFreespaceVP(src: string): Integer;
var HDR: VPHeader;
    ENT: VPEntry;
    disp, currep: string;
    NumE, x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, 16);

    if (HDR.Signature <> 'VPVP') or (HDR.Version <> 2) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadFreespaceVP := -3;
      ErrInfo.Format := 'VP';
      ErrInfo.Games := 'Conflict Freespace, Freespace 2';
    end
    else
    begin

      FileSeek(FHandle,HDR.DirOffset,0);
      CurRep := '';
      NumE := 0;

      for x:= 1 to HDR.DirNum do
      begin

        Per := ROund(((x / HDR.DirNum)*100));
        SetPercent(Per);
        FileRead(Fhandle,ENT,44);
        disp := Strip0(ENT.Filename);

        if ENT.Size = 0 then
        begin
          if disp = '..' then
          begin
            CurRep := Copy(CurRep,1,length(CurRep)-1);
            if Pos('\',CurRep) > 0 then
              CurRep := Copy(CurRep,1,PosRev('\',CurRep))
            else
              CurRep := '';
          end
          else
            CurRep := CurRep + disp + '\';
        end
        else
        begin
          inc(NumE);
          FSE_Add(CurRep + disp,ENT.Offset,ENT.Size,0,0);
        end;

      end;

      ReadFreespaceVP := NumE;

      DrvInfo.ID := 'VP';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    ReadFreespaceVP := -2;

end;

function ReadGTA3ADF(src: string): Integer;
var test: byte;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, test, 1);

    if (test <> $DD) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'ADF';
      ErrInfo.Games := 'GTA: Vice City';
    end
    else
    begin

      FSE_Add(ChangeFileExt(extractfilename(src),'.mp3'),0,TotFSize,0,0);

      //ShowMessage(IntTosTr(NumE));

      Result := 1;

      DrvInfo.ID := 'ADF';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end;

  end
  else
    Result := -2;

end;

procedure DecryptADFToStream(src : integer; dst : TStream; soff : Int64; ssize : Int64; bufsize : Integer; silent: boolean);
var
  //sFileLength: Integer;
  Buffer: PByteArray;
  i,x,numbuf, restbuf: Integer;
  per, oldper, perstep: word;
  real1, real2: real;
begin

  //sFileLength := FileSeek(src,0,2);
  FileSeek(src,soff,0);
  numbuf := ssize div bufsize;
  if (numbuf > 25000) then
    perstep := 2
  else if (numbuf > 12500) then
    perstep := 5
  else if (numbuf > 6000) then
    perstep := 10
  else
    perstep := 15;
  restbuf := ssize mod bufsize;

  GetMem(Buffer,bufsize);
  try
    oldper := 0;

    for i := 1 to numbuf do
    begin
      FileRead(src, Buffer^, bufsize);
      for x := 0 to bufsize do
      begin
        Buffer^[x] := Buffer^[x] xor $22;
      end;
      dst.WriteBuffer(Buffer^, bufsize);
      if not silent then
      begin
        real1 := i;
        real2 := numbuf;
        real1 := (real1 / real2)*100;
        per := Round(real1);
        if per >= oldper + perstep then
        begin
          oldper := per;
          SetPercent(per);
        end;
      end;
    end;

    if not silent then
      SetPercent(100);

    FileRead(src, Buffer^, restbuf);
    for x := 0 to restbuf do
    begin
      Buffer^[x] := Buffer^[x] xor $22;
    end;
    dst.WriteBuffer(Buffer^, restbuf);

  finally
    FreeMem(Buffer);
  end;

end;

// -------------------------------------------------------------------------- //
// Geometry Wars 3: Dimensions Evolved .WAD support ========================= //
// -------------------------------------------------------------------------- //

type GW3DAWLHeader = packed record
    ID: array[0..3] of char;          // DAWL
    MajorVersion: longword;           // Always 1?
    MinorVersion: longword;           // Always 1?
  end;
  // To Offset 2048
  //   NumIndex as longword
  //   NumIndex times GW3DAWLIndex
type GW3DAWLIndex = packed record
    Unknown1: longword;
    Unknown2: longword;
  end;
  //   NumEntries as longword
  //   NumEntries times GW3DAWLEntry
type GW3DAWLEntry = packed record
    Unknown1: longword;
    Unknown2: longword;
    EntryType: longword;              // $2F = PNG
    Unknown3: longword;
    Offset: Int64;
    Size: Int64;
    Size2: Int64;
    Empty: int64;
  end;
  // Data

function ReadGeometryWars3DAWL(): Integer;
var HDR: GW3DAWLHeader;
    ENT: GW3DAWLEntry;
    disp: string;
    NumE, NumI, x, oldper: integer;
    TotFSize: int64;
    memstm: TMemoryStream;
    srcstm: THandleStream;
    test32: longword;
begin

  TotFSize := FileSeek(Fhandle, 0, 2);

  FileSeek(Fhandle, 0, 0);
  FileRead(Fhandle, HDR, SizeOf(GW3DAWLHeader));

  if (HDR.ID <> 'DAWL') and (HDR.MajorVersion <> 1) and (HDR.MinorVersion <> 1) and (TotFSize < 2048) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    ReadGeometryWars3DAWL := -3;
    ErrInfo.Format := 'DAWL';
    ErrInfo.Games := 'Geometry Wars 3 Dimension Evolved';
  end
  else
  begin

    FileSeek(Fhandle, 2048, 0);
    FileRead(Fhandle, NumI,4);

    if (NumI*8+4+2048) > TotFSize then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadGeometryWars3DAWL := -3;
      ErrInfo.Format := 'DAWL';
      ErrInfo.Games := 'Geometry Wars 3 Dimension Evolved';
    end
    else
    begin

      FileSeek(Fhandle, 2048+4+NumI*8, 0);
      FileRead(Fhandle, NumE,4);

      memstm := TMemoryStream.Create;
      srcstm := THandleStream.Create(Fhandle);

      try

      memstm.CopyFrom(srcstm,NumE*SizeOf(GW3DAWLEntry));
      memstm.Seek(0,0);

      OldPer := 0;
      for x:= 1 to NumE do
      begin

        Per := ROund(((x / NumE)*100));
        if (OldPer <> Per) then
        begin
          SetPercent(Per);
          OldPer := Per;
        end;
        memstm.ReadBuffer(ENT, SizeOf(GW3DAWLEntry));

        disp := inttostr(ENT.EntryType)+'-'+inttohex(ENT.Unknown1,8)+'-'+inttohex(ENT.Unknown2,8)+'-'+inttohex(ENT.Unknown3,8);

        case ENT.EntryType of
          2: disp := 'XML\SurfaceMesh\'+ disp + '.xml';
          3: begin
            srcstm.Seek(ENT.Offset,0);
            srcstm.ReadBuffer(test32,4);
            if (test32 = 4) then
              disp := StringReplace(get32(srcstm),'/','\',[rfReplaceAll]) + '.model'
            else
              disp := 'Entities\'+ disp + '.tga';
          end;
          4: disp := 'Textures\'+ inttostr(ENT.EntryType)+'\' + disp + '.tga';
//          5: disp := 'Scripts\' + disp + '.luac';
          5..15: begin
            srcstm.Seek(ENT.Offset,0);
            srcstm.ReadBuffer(test32,4);
            if (test32 = $61754C1B) then
            begin
              srcstm.Seek(8,1);
              disp := strip0(get32(srcstm));
              if (Length(disp)>37) and (LeftStr(disp,29) = '@..\..\Image\DontShip\Common\') then
                disp := RightStr(disp,length(disp)-29);
              disp := StringReplace(disp,'\\','\',[rfReplaceAll]) + 'c';
            end
            else
              disp := 'Entities\'+ disp + '.' + inttostr(ENT.EntryType);
          end;
{           disp := 'Scripts\Entities\' + disp + '.luac';
          7: disp := 'Scripts\GameModes\' + disp + '.luac';
          8: disp := 'Scripts\Levels\' + disp + '.luac';
          9: disp := 'Scripts\LevelsDLC1\' + disp + '.luac';
          10: disp := 'Scripts\LevelsHC\' + disp + '.luac';
          11: disp := 'Scripts\LevelsMobile\' + disp + '.luac';
          12: disp := 'Scripts\LevelsMobile\Boss\' + disp + '.luac';
          13: disp := 'Scripts\LevelsMobile\Classic\' + disp + '.luac';
          14: disp := 'Scripts\LevelsMobile\HardCore\' + disp + '.luac';
          15: disp := 'Scripts\LevelsMobile\Ultimate\' + disp + '.luac';}
          16: disp := 'XML\LineMesh\'+ disp + '.xml';
          17..19, 21..29, 34..41, 46..48: disp := 'Textures\'+ inttostr(ENT.EntryType)+'\' + disp + '.png';
          20: begin
            srcstm.Seek(ENT.Offset,0);
            srcstm.ReadBuffer(test32,4);
            disp := 'Textures\Fonts\'+ disp;
            if (test32 = $474E5089) then
              disp := disp + '.png'
            else if (test32 = $6F666E69) then
              disp := disp + '.txt'
            else
              disp := disp + '.20';
          end;
          30: disp := 'XML\'+ disp + '.xml';
          31, 42, 50: disp := disp + '.csv';
          43..44: disp := disp + '.kslf';
          49: begin
            srcstm.Seek(ENT.Offset,0);
            srcstm.ReadBuffer(test32,4);
            disp := 'Sounds\'+ disp;
            if (test32 = $46464952) then
              disp := disp + '.fev'
            else if (test32 = $35425346) then
              disp := disp + '.fsb'
            else
              disp := disp + '.49';
          end;

        else
          disp := disp + '.'+inttohex(ENT                                                                                                                                                                                                                .EntryType,3);
        end;

        FSE_Add(disp,ENT.Offset,ENT.Size,0,0);

      end;

      finally
        FreeAndNil(srcstm);
        FreeAndNil(memstm);
      end;

      ReadGeometryWars3DAWL := NumE;

      DrvInfo.ID := 'DAWL';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end;

end;

// -------------------------------------------------------------------------- //
// Ghostbusters: Sanctum of Slime .PAK support ============================== //
// -------------------------------------------------------------------------- //

type TongasPAKHeader = packed record
    ID: array[0..17] of char;
    NumberOfEntries: integer;
    HeaderSize: integer;
  end;
  TongasPAKEntry = packed record
    Offset: integer;
    Size: integer;
    Compressed: integer;
  end;
  // Get32 filename

function ReadGhostbustersSoSPAK(): Integer;
var HDR: TongasPAKHeader;
    ENT: TongasPAKEntry;
    DirStream: TMemoryStream;
    InputStream: THandleStream;
    Name: string;
    x, Per, PerOld: integer;
begin

  // Instantiate the needed streams
  DirStream := TMemoryStream.Create;
  InputStream := THandleStream.Create(FHandle);

  try
    // Seek to start of input and read the header
    InputStream.Seek(0,0);
    InputStream.ReadBuffer(HDR,SizeOf(TongasPAKHeader));

    // Buffer the full directory into memory
    DirStream.CopyFrom(InputStream,HDR.HeaderSize);
    DirStream.Seek(0,0);

    // Start at 0 percent (for progress bar)
    PerOld := 0;
    SetPercent(PerOld);

    // Parse directory
    for x := 1 to HDR.NumberOfEntries do
    begin

      // Get entry data
      DirStream.ReadBuffer(ENT,SizeOf(TongasPAKEntry));

      // Get entry filename
      Name := Get32(DirStream);

      // We are displaying the compressed size but going throught the whole
      // file to retrieve sizes takes forever
      FSE_Add(Name,ENT.Offset,ENT.Size,ENT.Compressed,0);

      Per := Round((x / HDR.NumberOfEntries)*100);
      if Per >= PerOld + 5 then
      begin
        SetPercent(Per);
        PerOld := Per;
      end;

    end;

  finally
    // We don't need the streams anymore, so we free them
    FreeAndNil(InputStream);
    FreeAndNil(DirStream);
  end;

  Result := HDR.NumberOfEntries;

  DrvInfo.ID := 'tonga';
  DrvInfo.Sch := '/';
  DrvInfo.FileHandle := FHandle;
  DrvInfo.ExtractInternal := True;

end;

// -------------------------------------------------------------------------- //
// Giants: Citizen Kabuto .GZP support ====================================== //
// -------------------------------------------------------------------------- //

type GZPEntry = record
    size : integer;
    size_uncmp :integer;
    datetime :integer;    // can be ignored
    start :integer;       // start position of block
    compr :byte;          // 1: compressed, 2: not compressed
    namelength :byte;
   end;
   GZPHeader = record
    ID : integer;   // &H6608F101
    Offset : integer;
    Unknown1 : integer;
    Unknown2 : integer;
    Unknown3 : integer;
    Unknown4 : integer;
   end;

function ReadGiantsGZP(src: string): Integer;
var HDR: GZPHeader;
    ENT: GZPEntry;
    Name: string;
    NumE, x, Per, PerOld: integer;
begin

  FHandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(FHandle, 0, 0);
    FileRead(FHandle, HDR, SizeOf(HDR));

    if HDR.ID <> $6608F101 then
    begin
      FileClose(FHandle);
      FHandle := 0;
      ReadGiantsGZP := -3;
      ErrInfo.Format := 'GZP';
      ErrInfo.Games := 'Giants: Citizen Kabuto';
    end
    else
    begin

      FileSeek(FHandle, HDR.Offset+4, 0);
      FileRead(FHandle, NumE,4);

      PerOld := 0;

      for x:= 1 to NumE do
      begin

        Per := Round((x / NumE)*100);
        if Per >= PerOld + 5 then
        begin
          SetPercent(Per);
          PerOld := Per;
        end;

        FileRead(FHandle, ENT, 18);
        Name := Strip0(Get8v(FHandle,ENT.namelength));

        FSE_add(Name,ENT.start+16,ENT.size_uncmp,ENT.size,ENT.compr);

      end;

      Result := NumE;

      DrvInfo.ID := 'GZP';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end;
  end
  else
    ReadGiantsGZP := -2;

end;

function DecompressGZP(buf :PByteArray; start,len,finalsize:longint):PByteArray;
var
  i,j,vbufstart,decbits,decpos,declen :longint;
  decbyte :byte;
  res: PByteArray;
begin

  GetMem(res,finalsize);

  i := 0;
  j := 0;
  vbufstart := $FEE;
  decbits := 8;
  decbyte := 0;

  while j<finalsize do begin
    if decbits=8 then begin
      decbyte := buf^[i];
      inc(i);
      decbits := 0;
    end;
    if (decbyte shr decbits) and 1=0 then begin
      decpos := (buf^[i]+longint(buf^[i+1]) and $F0 shl 4-vbufstart-j) and $FFF-$1000+j;
      declen := buf^[i+1] and $F+3;
      inc(i,2);
      while declen>0 do begin
        if decpos>=0 then
          res^[j] := res^[decpos]
        else
          res^[j] := 32;
        inc(j);
        inc(decpos);
        dec(declen)
      end
    end
    else begin
      res^[j] := buf^[i];
      inc(i);
      inc(j);
    end;
    inc(decbits);
  end;

  result := res;

end;

// -------------------------------------------------------------------------- //
// Grand Theft Auto 3 .IMG/.DIR support ===================================== //
// -------------------------------------------------------------------------- //

type DIRIMG_Entry = packed record
       StartBlock: Longword;
       BlockCount: Longword;
       Name: array[0..23] of Char;
     end;

function ReadGTA3IMGDIR(src: string): Integer;
var ENT: DIRIMG_Entry;
    dirfile, imgfile, disp: string;
    NumE,x,totFSize,totDSize: integer;
    Offset, Size: int64;
    Dhandle: integer;
begin

  if (uppercase(ExtractFileExt(src)) = '.DIR') then
  begin
    dirfile := src;
    imgfile := ChangeFileExt(src,'.img');
  end
  else
  begin
    imgfile := src;
    dirfile := ChangeFileExt(src,'.dir');
  end;

  if not(FileExists(dirfile)) then
  begin
    FHandle := 0;
    Result := -4;
    ErrInfo.Format := 'DIR/IMG';
    ErrInfo.Games := dirfile;
  end
  else if not(FileExists(imgfile)) then
  begin
    FHandle := 0;
    Result := -4;
    ErrInfo.Format := 'DIR/IMG';
    ErrInfo.Games := imgfile;
  end
  else
  begin
    DHandle := FileOpen(dirfile, fmOpenRead or fmShareDenyWrite);
    FHandle := FileOpen(imgfile, fmOpenRead or fmShareDenyWrite);

    if (DHandle > 0) and (FHandle > 0) then
    begin
      TotDSize := FileSeek(DHandle,0,2);
      TotFSize := FileSeek(FHandle,0,2);
      if ((TotDSize mod 32) <> 0) or ((TotFSize mod 2048) <> 0) then
      begin
        FileClose(Dhandle);
        FileClose(Fhandle);
        FHandle := 0;
        Result := -3;
        ErrInfo.Format := 'DIR/IMG';
        ErrInfo.Games := 'GTA3/Grand Theft Auto 3';
      end
      else
      begin
        FileSeek(DHandle,0,0);
        FileSeek(FHandle,0,0);

        NumE := TotDSize div 32;

        for x := 1 to NumE do
        begin
          FileRead(DHandle,ENT,SizeOf(ENT));
          disp := Strip0(ENT.Name);
          Per := Round((x / NumE)*100);
          SetPercent(Per);
          Offset := ENT.StartBlock * 2048;
          Size := ENT.BlockCount * 2048;
          FSE_Add(disp,Offset,Size,0,0)
        end;

        FileClose(Dhandle);

        Result := NumE;

        DrvInfo.ID := 'DIR/IMG';
        DrvInfo.Sch := '';
        DrvInfo.FileHandle := FHandle;
        DrvInfo.ExtractInternal := True;
      end;
    end
    else if (FHandle > 0) then
    begin
      FileClose(FHandle);
      Result := -2;
    end
    else if (DHandle > 0) then
    begin
      FileClose(DHandle);
      Result := -2;
    end
    else
    begin
      Result := -2;
    end;
  end;

end;

// -------------------------------------------------------------------------- //
// Gunlok .GDA support ====================================================== //
// -------------------------------------------------------------------------- //

type GDATHeader = packed record
       ID: array[0..7] of char;
       FileSize: Integer;
       Unknown1: integer;
       NumEntries: integer;
     end;
     GDATEntry = packed record
       Unknown1: integer;
       Unknown2: integer;
       WAVCHUNKPos: integer;
     end;
     GDATWAVEEntry = packed record
       ID: array[0..7] of char;
       ChunkSize: Integer;
       Unknown1: integer;
       Unknown2: integer;
       Unknown3: integer;
       Unknown4: integer;
       Unknown5: integer;
       Unknown6: integer;
       Unknown7: integer;
       Unknown8: integer;
       CHUNKType: array[0..3] of char;
     end;

function ReadGunlokDAT(): Integer;
var HDR: GDATHeader;
    ENT: GDATEntry;
    WCHK: GDATWAVEEntry;
    disp: string;
    NumE, NumEbis, x, CPos: integer;
begin

  FileSeek(Fhandle, 0, 0);
  FileRead(FHandle, HDR, 20);

  if HDR.ID <> 'FILECHNK' then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'DAT';
    ErrInfo.Games := 'Gunlok';
  end
  else
  begin

    NumE := HDR.NumEntries;
    NumEbis := 0;

    for x:= 1 to NumE do
    begin

      Per := Round(((x / NumE)*100));
      SetPercent(Per);
      disp := get32(FHandle);
      FileRead(Fhandle,ENT,12);

      CPos := FileSeek(FHandle,0,1);

      FileSeek(FHandle,ENT.WAVCHUNKPos,0);
      FileRead(FHandle,WCHK,48);
      FileSeek(FHandle,CPos,0);

      if (WCHK.CHUNKType = 'RIFF') then
      begin
        inc(numEbis);
        FSE_Add(disp,ENT.WAVCHUNKPos+44,WCHK.ChunkSize-48,0,0);
      end;

    end;

    Result := NumEbis;

    DrvInfo.ID := 'DAT';
    DrvInfo.Sch := '';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// Hardbinger .SQH support ================================================== //
// -------------------------------------------------------------------------- //

function ReadHarbingerSQH_Aux(cdir: string; totalOffset: integer; limitOffset: integer): integer;
var disp: string;
    offset,size,test: integer;
begin

  result := 0;

  while ((FileSeek(FHandle,0,1) < limitOffset) and (FileSeek(FHandle,0,1) < totalOffset)) do
  begin
    disp := strip0(get8(Fhandle));
//    FileRead(FHandle,test,4);
    test := GetSwapInt(FHandle);
    if (pos('.',disp) = 0) then
    begin
      if cdir = '' then
        disp := disp + '\'
      else
        disp := cdir + disp + '\';
  //    if (test = -1) then ShowMessage(disp);
      if (test = -1) then
        inc(result,ReadHarbingerSQH_Aux(disp,totalOffset,limitOffset))
      else
        inc(result,ReadHarbingerSQH_Aux(disp,totalOffset,FileSeek(FHandle,0,1)+test));
    end
    else
    begin
      offset := GetSwapInt(FHandle);
      size := GetSwapInt(FHandle);
      FSE_Add(cdir+disp,offset,size,0,0);
      inc(result);
    end;
  end;

end;

function ReadHarbingerSQH(src: string): Integer;
var NumE: integer;
    limitOffset: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, limitOffset, 4);

    if (limitOffset >= TotFSize) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'SQH';
      ErrInfo.Games := 'Harbinger';
    end
    else
    begin

      NumE := ReadHarbingerSQH_Aux('',limitOffset,limitOffset);

      Result := NumE;

      DrvInfo.ID := 'SQH';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Heath .NRM support ======================================================= //
// -------------------------------------------------------------------------- //

{IFDEF EXPFORMATS}

type NRMHeader = packed record
       ID: array[0..17] of char;
     end;
     NRMEntry = packed record
       ID: array[0..4] of char;
       PacketSize: integer;
       Size: integer;
     end;
     // Get32 Filename

const
  NRMID : String = 'PakkaByRCL^DPL2000';

function ReadHeathNRM(src: string): Integer;
var HDR: NRMHeader;
    ENT: NRMEntry;
    NumE,offset : integer;
    nam: string;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, SizeOf(NRMHeader));

    if (HDR.ID <> NRMID) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'NRM';
      ErrInfo.Games := 'Heath: The Unchosen Path';
    end
    else
    begin

      NumE := 0;

      while (TotFSize > FileSeek(FHandle,0,1)) do
      begin

        FileRead(FHandle,ENT,SizeOf(NRMEntry));
        nam := Get32(FHandle);
        Offset := FileSeek(FHandle,0,1);

        FSE_Add(nam,Offset,ENT.PacketSize - Length(Nam),0,0);

        FileSeek(FHandle,ENT.PacketSize - Length(Nam),1);
        Inc(NumE);

      end;

      Result := NumE;

      DrvInfo.ID := 'NRM';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

{ENDIF}

// -------------------------------------------------------------------------- //
// Heroes of Might & Magic 3 .SND support =================================== //
// -------------------------------------------------------------------------- //

type H3SND_Index = packed record
       Filename: array[0..39] of char;
       Offset: integer;
       Size: integer;
     end;

function ReadHeroesOfMightAndMagic3SND(src: string): Integer;
var ENT: H3SND_Index;
    NumE,x,z : integer;
    ext, nam: string;
    next: boolean;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, NumE, 4);

    if (NumE > 10000) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'H3SND';
      ErrInfo.Games := 'Heroes of Might & Magic 3';
    end
    else
    begin
      for x := 1 to NumE do
      begin

        FileRead(FHandle,ENT.Filename,40);

        z := 0;
        ext := '';
        nam := '';
        next := false;
        while z <= 39 do
        begin
          if next then
          begin
            if (ENT.Filename[z] = #0) then
              z := 40
            else
              ext := ext + ENT.Filename[z];
          end
          else
          begin
            if (ENT.Filename[z] = #0) then
              next := true
            else
              nam := nam + ENT.Filename[z];
          end;
          inc(z);
        end;

        FileRead(FHandle,ENT.Offset,4);
        FileRead(FHandle,ENT.Size,4);

        FSE_Add(nam + '.'+ ext,ENT.Offset,ENT.Size,0,0);

      end;

      Result := NumE;

      DrvInfo.ID := 'H3SND';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Heroes of Might & Magic 4 .H4R support =================================== //
// -------------------------------------------------------------------------- //

{IFDEF EXPFORMATS}

type H4R_Header = packed record
       ID: array[0..3] of char;
       DirOffset: integer;
     end;
     H4R_Index = packed record
       Offset: integer;
       Size: integer;
       DSize: integer;
       Unk: integer;  // Always 9C 73 86 3C
     end;
     // get16 filenameID
     // get16 source directory
     // 2 bytes 00 00
     // Integer (Storage/Compression?)

function ReadHeroesOfMightAndMagic4H4R(src: string): Integer;
var HDR: H4R_Header;
    ENT: H4R_Index;
    NumE,x, compress : integer;
    nam, dir: string;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, 8);

    if ((HDR.ID[0] <> #72) or (HDR.ID[1] <> #52) or (HDR.ID[2] <> #82) or (HDR.ID[3] <> #5)) or (HDR.DirOffset > FileSeek(FHandle,0,2)) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'H4R';
      ErrInfo.Games := 'Heroes of Might & Magic 4';
    end
    else
    begin

      FileSeek(FHandle,HDR.DirOffset,0);
      FileRead(FHandle,NumE,4);

      for x := 1 to NumE do
      begin

        FileRead(FHandle,ENT,16);
        nam := get16(FHandle);

        dir := get16(FHandle);
        if (length(dir) > 0) then
        begin
          FileSeek(FHandle,2,1);
          FileRead(FHandle,compress,4);
          FSE_Add(nam,ENT.Offset,ENT.Size,compress,ENT.DSize);
        end
        else
          dir := get16(FHandle);

      end;

      Result := NumE;

      DrvInfo.ID := 'H4R';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end;

  end
  else
    Result := -2;

end;

{ENDIF}

// -------------------------------------------------------------------------- //
// Hidden and Dangerous .DTA/.CNT support =================================== //
// -------------------------------------------------------------------------- //

type DTA_CNT_Header = packed record
       ID: array[0..7] of char;
       DTASize: integer;
       Unknown1: integer;
       Unknown2: integer;
       Dirnum: integer;
     end;
     DTA_CNT_Entry = packed record
       Offset: integer;
       Size: integer;
     end;

function ReadHiddenAndDangerousDTA(src: string): Integer;
var HDR: DTA_CNT_Header;
    ENT: DTA_CNT_Entry;
    disp,cfil: string;
    NumE,x: integer;
    Chandle: integer;
    ID: array[0..3] of char;
begin

  FHandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,4);

    if ID <> 'DTA_' then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'DTA/CNT';
      ErrInfo.Games := 'Hidden & Dangerous';
    end
    else
    begin

      TotFSize := FileSeek(FHandle,0,2);

      cfil := ChangeFileExt(src,'.cnt');

      if not(FileExists(cfil)) then
      begin
        FileClose(Fhandle);
        FHandle := 0;
        Result := -4;
        ErrInfo.Format := 'DTA/CNT';
        ErrInfo.Games := cfil;
      end
      else
      begin
        Chandle := FileOpen(cfil, fmOpenRead or fmShareDenyWrite);

        FileRead(CHandle,HDR.ID,8);
        FileRead(CHandle,HDR.DTASize,4);
        FileRead(CHandle,HDR.Unknown1,4);
        FileRead(CHandle,HDR.Unknown2,4);
        FileRead(CHandle,HDR.DirNum,4);

        if (HDR.ID <> 'COMPCNT4') or (HDR.DTASize <> TotFSize) then
        begin
          FileClose(Fhandle);
          FileClose(Chandle);
          FHandle := 0;
          Result := -3;
          ErrInfo.Format := 'DTA/CNT';
          ErrInfo.Games := 'Hidden & Dangerous';
        end
        else
        begin

          NumE := HDR.Dirnum;

          for x := 1 to NumE do
          begin
            FileRead(CHandle,ENT.Offset,4);
            FileRead(CHandle,ENT.Size,4);
            disp := Get16(CHandle);
            Per := Round((x / NumE)*100);
            SetPercent(Per);
            if ENT.Size > 0 then
              FSE_Add(disp,ENT.Offset,ENT.Size,0,0)
            else
              Dec(NumE);
          end;

          FileClose(Chandle);

          Result := NumE;

          DrvInfo.ID := 'DTA/CNT';
          DrvInfo.Sch := '\';
          DrvInfo.FileHandle := FHandle;
          DrvInfo.ExtractInternal := True;
        end;
      end;
    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Hitman: Contracts .PRM support =========================================== //
// -------------------------------------------------------------------------- //

type PRMHeader = packed record
       ID: cardinal;   // ID - Always $71E ?
       DirOffset: cardinal;
       DirOffset2: cardinal;
       NumEntries: cardinal;
     end;

function ReadHitmanContractsPRM(src: string): Integer;
var HDR: PRMHeader;
    x: integer;
    nam, prenam: string;
    offsets: array of cardinal;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, Sizeof(PRMHeader));

    if ((HDR.ID <> $71E) or (HDR.DirOffset >= TotFSize) or (HDR.DirOffset2 >= TotFSize)) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'PRM';
      ErrInfo.Games := 'Freedom Fighters, Hitman 2: Silent Assassin, Hitman: Contracts, ...';
    end
    else
    begin
      SetLength(offsets,HDR.NumEntries+1);
      offsets[HDR.NumEntries] := HDR.DirOffset;

      FileSeek(FHandle,HDR.DirOffset,0);

      for x := 0 to HDR.NumEntries -1 do
        FileRead(FHandle,Offsets[x],4);

      prenam := StringReplace(ExtractFilename(src),'.','_',[rfReplaceAll])+'_';

      for x := 0 to HDR.NumEntries-1 do
      begin

        nam := inttostr(x+1);

        FSE_Add(prenam+rightstr('00000000'+nam,8)+'.raw',Offsets[x],Offsets[x+1]-Offsets[x],0,0);

      end;

      Result := HDR.NumEntries;

      DrvInfo.ID := 'HMCPRM';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Hitman: Contracts .TEX support =========================================== //
// -------------------------------------------------------------------------- //

type TEX_Header = packed record
       IndexOffset: cardinal;
       UnknownOffset: cardinal;
       ID3: cardinal;   // 3
       ID4: cardinal;   // 4
     end;
     TEX_Entry = packed record
       Size: cardinal;
       Type1: array[0..3] of char;
       Type2: array[0..3] of char;
       Unknown1: Cardinal;
       Unknown2: word;
       Unknown3: word;
       Unknown: array[1..4] of Cardinal;
     end;

function ReadHitmanContractsTEX(src: string): Integer;
var HDR: TEX_Header;
    ENT: TEX_Entry;
    NumE: cardinal;
    x, y: integer;
    nam: string;
    offsets: array of cardinal;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, Sizeof(TEX_Header));

    if ((HDR.ID3 <> 3) or (HDR.ID4 <> 4) or (HDR.IndexOffset >= TotFSize) or (HDR.UnknownOffset >= TotFSize) or (HDR.UnknownOffset >= totFSize) or ((HDR.UnknownOffset-HDR.IndexOffset) <> $2000)) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'GTEX';
      ErrInfo.Games := 'Hitman 2, Hitman: Contracts, Freedom Fighters, ...';
    end
    else
    begin

      FileSeek(FHandle,HDR.IndexOffset,0);

      setlength(Offsets,(HDR.UnknownOffset - HDR.IndexOffset) div 4);

      x := 0;

      for y := 0 to high(Offsets) do
      begin
        inc(x);
        FileRead(FHandle,Offsets[x],4);
        if (Offsets[x] = 0) then
          dec(x);
      end;

      NumE := x;

      for x := 1 to NumE do
      begin

        Fileseek(FHandle,offsets[x],0);
        FileRead(FHandle,ENT,SizeOf(TEX_Entry));
        nam := Strip0(Get0(Fhandle));

        FSE_Add(StringReplace(nam,'/','\',[rfReplaceAll])+'.'+revstr(ent.Type1),Offsets[x],ENT.Size,0,0);

      end;

      Result := NumE;

      DrvInfo.ID := 'GTEX';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// HyperRipper .HRF support ================================================= //
// -------------------------------------------------------------------------- //

function ReplacePoints(src: string): string;
var x: integer;
begin

  x := Pos('.',src);
  while (x > 0) do
  begin
    src := Copy(src,1,x-1)+'_'+Copy(src,x+1,length(src)-x);
    x := Pos('.',src);
  end;

  ReplacePoints := src;

end;

function GetHRFExt(ftype: byte): string;
begin

  case ftype of
    0: GetHRFExt := '.raw';
    1: GetHRFExt := '.bmp';
    2: GetHRFExt := '.iff';
    3: GetHRFExt := '.png';
    4: GetHRFExt := '.gif';
    5: GetHRFExt := '.wmf';
    6: GetHRFExt := '.emf';
    7: GetHRFExt := '.jpg';
  100: GetHRFExt := '.mid';
  101: GetHRFExt := '.voc';
  102: GetHRFExt := '.wav';
  103: GetHRFExt := '.669';
  104: GetHRFExt := '.xm';
  105: GetHRFExt := '.it';
  106: GetHRFExt := '.s3m';
  111: GetHRFExt := '.mp1';
  112: GetHRFExt := '.mp2';
  113: GetHRFExt := '.mp3';
  199: GetHRFExt := '';
  200: GetHRFExt := '.avi';
  201: GetHRFExt := '.mov';
  202: GetHRFExt := '.fli';
  203: GetHRFExt := '.flc';
  204: GetHRFExt := '.bik';
  else
    GetHRFExt := '.unk'+inttostr(ftype);
  end;

end;

function NumberPadding(src: integer): string;
var res: string;
    x: integer;
begin

  res := inttostr(src);
  if length(res) < 10 then
    for x := 1 to 10-length(res) do
      res := '0'+res;

  NumberPadding := res;

end;

function CompareBytes(buf1, buf2: array of byte; size: byte): boolean;
var res : boolean;
    x: byte;
begin

  res := buf1[0] = buf2[0];
  x := 1;

  while res and (x < size) do
  begin
    res := buf1[x] = buf2[x];
    Inc(x);
  end;

  CompareBytes := res;

end;

function ReadHyperRipperHRF(src: string): Integer;
var HDR: HRF_Header;
    HDR3: HRF3_Header;
    INF0: HRF_Infos_v0;
    INF1: HRF_Infos_v1;
//    INF3: HRF3_Info;
    IDX0: HRF_Index_v0;
    IDX1: HRF_Index_v1;
    IDX2: HRF_Index_v2;
    IDX3: HRF3_Index;
    disp,efil,cfil: string;
    NumE, x: integer;
    FileIsGood, TestFile: boolean;
    NumFil: array[0..255] of integer;
    TestBuf: array[0..15] of byte;
    Chandle: integer;
begin

  Chandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if CHandle > 0 then
  begin
    FileSeek(CHandle, 0, 0);
    FileRead(CHandle, HDR.ID, 5);
    FileRead(CHandle, HDR.Version, 1);

    if (HDR.ID <> ('HRFi'+chr(26))) or (HDR.Version > 3) then
    begin
      FileClose(Chandle);
      FHandle := 0;
      ReadHyperRipperHRF := -3;
      ErrInfo.Format := 'HRF';
      ErrInfo.Games := 'Dragon UnPACKer HyperRipper';
    end
    else
      case HDR.Version of
        3: begin
             FileSeek(CHandle,0,0);
             FileRead(Chandle,HDR3,SizeOf(HRF3_Header));

             cfil := TrimRight(Strip0(HDR3.Filename));
             cfil := ExtractFilePath(src) + cfil;

             if not(FileExists(cfil)) then
             begin
               FileClose(Chandle);
               FHandle := 0;
               ReadHyperRipperHRF := -4;
               ErrInfo.Format := 'HRF3';
               ErrInfo.Games := TrimRight(Strip0(HDR3.Filename));
             end
             else if HDR3.NumEntries <= 0 then
             begin
               FileClose(Chandle);
               FHandle := 0;
               ReadHyperRipperHRF := -3;
               ErrInfo.Format := 'HRF';
               ErrInfo.Games := 'Dragon UnPACKer HyperRipper';
             end
             else
             begin

               Fhandle := FileOpen(cfil, fmOpenRead or fmShareDenyWrite);

               if FHandle <= 0 then
               begin
                 FileClose(Chandle);
                 FHandle := 0;
                 ReadHyperRipperHRF := -4;
                 ErrInfo.Format := 'HRF3';
                 ErrInfo.Games := TrimRight(Strip0(HDR3.Filename));
               end
               else
               begin
                 FileSeek(CHandle,HDR3.OffsetIndex,0);
                 for x := 1 to HDR3.NumEntries do
                 begin
                   FileRead(Chandle,IDX3,SizeOf(IDX3));
                   FSE_Add(TrimRight(Strip0(IDX3.Filename)),IDX3.Offset, IDX3.Size, 0, 0);
                 end;
                 NumE := HDR3.NumEntries; 

                 FileClose(Chandle);

                 ReadHyperRipperHRF := NumE;

                 DrvInfo.ID := 'HRF3';
                 DrvInfo.Sch := '\';
                 DrvInfo.FileHandle := FHandle;
                 DrvInfo.ExtractInternal := False;

               end;
             end;
           end;
      else
      begin

        FileRead(Chandle,HDR.Filename, 98);
        FileRead(CHandle,HDR.FileSize,4);
        FileRead(CHandle,HDR.HRipVer.Major,1);
        FileRead(CHandle,HDR.HRipVer.Minor,1);
        FileRead(CHandle,HDR.DirNum,4);

        cfil := TrimRight(HDR.Filename);
        cfil := ExtractFilePath(src) + cfil;

        if not(FileExists(cfil)) then
        begin
          FileClose(Chandle);
          FHandle := 0;
          ReadHyperRipperHRF := -4;
          ErrInfo.Format := 'HRF'+inttostr(HDR.Version);
          ErrInfo.Games := TrimRight(HDR.Filename);
        end
        else
        begin

          Fhandle := FileOpen(cfil, fmOpenRead or fmShareDenyWrite);

          if FHandle <= 0 then
          begin
            FileClose(Chandle);
            FHandle := 0;
            ReadHyperRipperHRF := -4;
            ErrInfo.Format := 'HRF'+inttostr(HDR.Version);
            ErrInfo.Games := TrimRight(HDR.Filename);
          end
          else
          begin

            FillChar(NumFil,1024,0);
            NumE := HDR.Dirnum;
            efil := ReplacePoints(ExtractFilename(TrimRight(HDR.Filename)));
            efil := efil + '_';

            case HDR.Version of
              0: begin
                   for x:= 1 to NumE do
                   begin
                     Per := ROund(((x / NumE)*100));
                     SetPercent(Per);
                     FileRead(Chandle,IDX0.FileType,1);
                     FileRead(Chandle,IDX0.Offset,4);
                     FileRead(Chandle,IDX0.Size,4);
                     inc(NumFil[IDX0.FileType]);
                     disp := efil + NumberPadding(NumFil[IDX0.FileType]) + GetHRFExt(IDX0.FileType);
                     FSE_Add(disp,IDX0.Offset-1,IDX0.Size,0,0);
                   end;
                   DrvInfo.Sch := '';
                 end;
              1: begin
                   for x:= 1 to NumE do
                   begin
                     Per := ROund(((x / NumE)*100));
                     SetPercent(Per);
                     FileRead(Chandle,IDX1.Filename,32);
                     FileRead(Chandle,IDX1.FileType,1);
                     FileRead(Chandle,IDX1.Offset,4);
                     FileRead(Chandle,IDX1.Size,4);
                     inc(NumFil[IDX1.FileType]);
                     disp := TrimRight(IDX1.Filename) + GetHRFExt(IDX1.FileType);
                     FSE_Add(disp,IDX1.Offset-1,IDX1.Size,0,0);
                   end;
                   DrvInfo.Sch := '\';
                 end;
              2: begin
                   FileRead(Chandle,INF0,2);
                   if INF0.InfoVer = 1 then
                     FileRead(Chandle,INF1,256);

                   TestFile := INF0.SecuritySize > 0;
                   FileIsGood := True;

                   for x:= 1 to HDR.Dirnum do
                   begin
                     Per := ROund(((x / HDR.Dirnum)*100));
                     SetPercent(Per);

                     FileRead(Chandle,IDX2.Filename,64);
                     FileRead(Chandle,IDX2.FileType,1);
                     FileRead(Chandle,IDX2.Offset,4);
                     FileRead(Chandle,IDX2.Size,4);
                     FileRead(Chandle,IDX2.Security,16);
                     if TestFile then
                     begin
                       FileSeek(FHandle,IDX2.Offset-1,0);
                       FileIsGood := FileRead(Fhandle,TestBuf,INF0.SecuritySize) = INF0.SecuritySize;
                       if FileIsGood then
                       FileIsGood := CompareBytes(TestBuf, IDX2.Security, INF0.SecuritySize)
                     end;
                     if FileIsGood then
                     begin
                       inc(NumFil[IDX2.FileType]);
                       disp := TrimRight(IDX2.Filename) + GetHRFExt(IDX2.FileType);
                       FSE_Add(disp,IDX2.Offset-1,IDX2.Size,0,0);
                     end
                     else
                       Dec(NumE);
                   end;
                   DrvInfo.Sch := '\';
                 end;
              end;

            FileClose(Chandle);

            ReadHyperRipperHRF := NumE;

            DrvInfo.ID := 'HRF'+inttostr(HDR.Version);
            DrvInfo.FileHandle := FHandle;
            DrvInfo.ExtractInternal := False;
          end;
        end;
      end;
    end;
  end
  else
    ReadHyperRipperHRF := -2;

end;

// -------------------------------------------------------------------------- //
// Indiana Jones 3D .GOB support ============================================ //
// -------------------------------------------------------------------------- //

type I3DGOBHeader = packed record
       ID: array[0..3] of char;
       Version: integer;
       Unknown2: integer;
       Dirnum: integer;
     end;
     I3DGOBIndex = packed record
       Offset: integer;
       Size: integer;
       Name: array[0..127] of char;
     end;

function ReadIndianaJones3dGOB(): Integer;
var HDR: I3DGOBHeader;
    ENT: I3DGOBIndex;
    disp: string;
    NumE, x: integer;
begin

  FileSeek(Fhandle, 0, 0);
  FileRead(FHandle, HDR, 16);

  if HDR.Version <> 20 then
    ReadIndianaJones3dGOB := -3
  else
  begin

    NumE := HDR.Dirnum;

    for x:= 1 to NumE do
    begin

      Per := ROund(((x / NumE)*100));
      SetPercent(Per);

      FileRead(Fhandle,ENT,136);
      disp := Strip0(ENT.Name);

      FSE_Add(disp,ENT.Offset,ENT.Size,0,0);

    end;

    ReadIndianaJones3dGOB := NumE;

    DrvInfo.ID := 'GOB';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// Interstate .ZFS support ================================================== //
// -------------------------------------------------------------------------- //

type ZFSHeader = packed record
       ID: array[0..3] of char;
       Version: integer;
       Unknown1: integer;
       DirSize: integer;
       Dirnum: integer;
       Unknown3: integer;
       Unknown4: integer;
       NextOffset: integer;
     end;
     ZFSEntry = packed record
       Filename: array[0..15] of char;
       Offset: integer;
       Unknown1: integer;
       Size: integer;
       Unknown2: integer;
       Unknown3: integer;
     end;

function ReadInterstateZFS(src: string): Integer;
var HDR: ZFSHeader;
    ENT: ZFSEntry;
    disp: string;
    NumE, x, glop: integer;
    Offset: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, 32);

    if (HDR.ID <> 'ZFSF') and (HDR.ID <> 'ZFS3') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadInterstateZFS := -3;
      ErrInfo.Format := 'ZFS';
      ErrInfo.Games := 'Interstate ''76 & Interstate ''82';
    end
    else
    begin

      NumE := HDR.DirNum;
      Offset := HDR.NextOffset;
      Glop := 0;

      for x:= 1 to NumE do
      begin

        Per := ROund(((x / NumE)*100));
        SetPercent(Per);

        FileRead(Fhandle,ENT,36);
        disp := Strip0(ENT.Filename);
        Inc(Glop);
        if Glop = HDR.DirSize then
        begin
          FileSeek(FHandle,Offset,0);
          Glop := 0;
          Fileread(FHandle,offset,4);
        end;

        FSE_Add(disp,ENT.Offset,ENT.Size,0,0);

      end;

      ReadInterstateZFS := NumE;

      DrvInfo.ID := 'ZFS';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    ReadInterstateZFS := -2;

end;

// -------------------------------------------------------------------------- //
// Jagged Alliance 2 .SLF support =========================================== //
// -------------------------------------------------------------------------- //

type SLFHeader = packed record
       FileName: array[0..255] of char;
       Directory: array[0..255] of char;
       NumEntries: integer;
       NumEntries2: integer;
       ID: array[0..11] of char;
     end;
     SLFEntry = packed record
       Filename: array[0..255] of char;
       Offset: integer;
       Size: integer;
       Unknown: array[1..16] of byte;
     end;

const
  SLFID : array[0..11] of char = #255+#255+#0+#2+#1+#0+#0+#0+#0+#0+#0+#0;

function ReadJaggedAlliance2SLF(src: string): Integer;
var HDR: SLFHeader;
    ENT: SLFEntry;
    disp: string;
    x, DirOffset: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, 532);

    disp := '';

    for x := 0 to 11 do
      disp := disp +IntToStr(Ord(HDR.ID[x]))+' ';

    if (HDR.ID <> SLFID) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'SLF';
      ErrInfo.Games := 'Jagged Alliance 2';
    end
    else
    begin

      DirOffset := FileSeek(FHandle,0,2) - HDR.NumEntries * 280;
      FileSeek(FHandle,DirOffset,0);

      disp := Strip0(HDR.Directory);

      for x:= 1 to HDR.NumEntries do
      begin

        Per := ROund(((x / HDR.NumEntries)*100));
        SetPercent(Per);

        FileRead(Fhandle,ENT,280);

        FSE_Add(disp + strip0(ENT.Filename),ENT.Offset,ENT.Size,0,0);

      end;

      Result := HDR.NumEntries;

      DrvInfo.ID := 'SLF';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// LEGO Star Wars .DAT support ============================================== //
// -------------------------------------------------------------------------- //

type LEGODAT_Header = packed record
       DirOffset: Integer;
       DirSize: Integer;
     end;
     LEGODAT_Entry = packed record
       Offset: Integer;
       Size: Integer;
       Size2: Integer;
       Unknown: Integer;
     end;
     LEGODAT_Directory = packed record
       Info1: Word;
       Info2: Word;
       NamePos: Integer;
     end;

function ReadLegoStarWarsDAT: Integer;
var HDR: LEGODAT_Header;
    stmNames: TMemoryStream;
    stmSource: THandleStream;
    disp: string;
    x, y, EntrySize, DirTableSize, NamesSize, TotFSize: integer;
    ENT: array of LEGODAT_Entry;
    DIR: array of LEGODAT_Directory;
    dirname: array of string;
begin

  TotFSize := FileSeek(FHandle, 0, 2);
  FileSeek(Fhandle, 0, 0);
  FileRead(FHandle, HDR, 8);

  if (HDR.DirOffset+4 > TotFSize) or (HDR.DirSize < 0) or (HDR.DirOffset < 0)
  or ((HDR.DirOffset+HDR.DirSize) > TotFSize) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'LEGODAT';
    ErrInfo.Games := 'LEGO Star Wars';
    exit;
  end;

  FileSeek(FHandle,HDR.DirOffset+4,0);
  FileRead(FHandle,EntrySize,4);

  // Sanity check entries should be between 1 and 100000
  if (EntrySize <= 0) or (EntrySize > 100000) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'LEGODAT';
    ErrInfo.Games := 'LEGO Star Wars';
    exit;
  end;

  setLength(ENT,EntrySize);

  for x := 0 to EntrySize-1 do
  begin
    FileRead(FHandle,ENT[x],16);
    // Sanity check, the Offset & Size of the entry should be into the file
    if (ENT[x].Offset > TotFSize) or (ENT[x].Size < 0) or (ENT[x].Offset < 0)
    or ((ENT[x].Offset+ENT[x].Size) > TotFSize) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'LEGODAT';
      ErrInfo.Games := 'LEGO Star Wars';
      exit;
    end;
  end;

  //FileSeek(FHandle,EntrySize*16,1);
  FileRead(FHandle,DirTableSize,4);

  // Sanity check DirTableSize should be between 1 and 100000
  if (DirTableSize <= 0) or (DirTableSize > 100000) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'LEGODAT';
    ErrInfo.Games := 'LEGO Star Wars';
    exit;
  end;

  setLength(DIR,DirTableSize);

  for x := 0 to DirTableSize-1 do
  begin
    FileRead(FHandle,DIR[x],8);
  end;

  FileRead(FHandle,NamesSize,4);

  // NamesSize should not exceed EOF
  if (NamesSize < 0) or (NamesSize > TotFSize) or ((FileSeek(FHandle,0,1)+NamesSize) > TotFSize) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'LEGODAT';
    ErrInfo.Games := 'LEGO Star Wars';
    exit;
  end;

  stmNames := TMemoryStream.Create;
  stmSource := THandleStream.Create(FHandle);

  try

    stmNames.CopyFrom(stmSource,NamesSize);

  finally

    FreeAndNil(stmSource);

  end;

  setLength(DirName,DirTableSize);

  for x := 0 to DirTableSize-1 do
  begin
    stmNames.Seek(DIR[x].NamePos,soBeginning);
    disp := Strip0(Get0(stmNames));
    if length(DirName[x]) = 0 then
      DirName[x] := disp
    else
      DirName[x] := DirName[x] + '\' + disp;
    if pos('.',disp) = 0 then
    begin
      for y := x+1 to DIR[x].Info1 do
        if pos('.',DirName[y]) = 0 then
          DirName[y] := DirName[x];
    end
    else
    begin
      DIR[x].Info1 := (DIR[x].Info1 xor $FFFF) + 1;
      FSE_Add(DirName[x],ENT[DIR[x].Info1].Offset,ENT[DIR[x].Info1].Size,0,0);
    end;
  end;

  setlength(DirName,0);
  setLength(DIR,0);
  FreeAndNil(stmNames);

  Result := EntrySize;

  DrvInfo.ID := 'LEGODAT';
  DrvInfo.Sch := '\';
  DrvInfo.FileHandle := FHandle;
  DrvInfo.ExtractInternal := False;

end;

// -------------------------------------------------------------------------- //
// Leisure Suit Larry Magna Cum Laude .JAM support ========================== //
// -------------------------------------------------------------------------- //

type JAM2Header = packed record
       ID: array[0..3] of char;   // JAM2
       CreationDateTime: integer;
       OffsetFirstEntry: cardinal;
       UnknownString: array[0..15] of char;  // always "none"+chr(0)+.. ?
       NumFiles: word;
       NumExts: word;
     end;
     JAM2DirIndex = packed record
       FileIdx: word;
       ExtIdx: word;
       Offset: cardinal;
     end;
     JAM2Entry = packed record
       Size: cardinal;
       SizeAlt: cardinal;
       Unknown: array[1..6] of cardinal;  // FF    2D    42    53    8B    A2
     end;

// Auxiliary function that will recursevely read the directory index of a JAM2 file
function ReadLeisureSuitLarryMagnaCumLaudeJAM_alt(curDir: string; OList: TIntList; firstData: cardinal; FList, EList: TStringList): Integer;
var cOffset, x, oldOffset: cardinal;
    ENT: JAM2Entry;
    DIR: JAM2DirIndex;
    newDir: string;
    numDirs: integer;
    res : integer;
begin

  result := 0;

  // Get current offset in source file
  cOffset := FileSeek(FHandle,0,1);

  if (cOffset < firstData) then      // If current offset is not before firstData then something is wrong
  begin                              // there is no Directory data after firstData offset..

    // Reading directory index information
    FileRead(FHandle,DIR,SizeOf(DIR));

    // If before firstData then it is a directory
    if DIR.Offset < firstData then
    begin

      // Calculate how many entries in this directory
      numDirs := ((DIR.FileIdx and $F000) shr 12) + DIR.ExtIdx div $20;

      // Sometimes numDirs is 0, but there is one entry (strangely enough)
      // I am not really sure about this one, but I keep it anyway...
      if numDirs = 0 then
        numDirs := 1;

      // Get the "true" file index by filtering the 4 bits used for numDirs
      DIR.FileIdx := DIR.FileIdx and $FFF;

      // This is if something goes wrong to prevent an index out of bounds
      // this part should never be triggered
      // If into bounds then use the folder name in JAM2 file
      if DIR.FileIdx > (FList.Count -1) then
      begin
        if length(curDir) = 0 then
          newDir := 'UNK-'+inttohex(DIR.FileIdx,4)
        else
          newDir := curDir + '\' + 'UNK-'+inttohex(DIR.FileIdx,4);
      end
      else
      begin
        if length(curDir) = 0 then
          newDir := FList.Strings[DIR.FileIdx]
        else
          newDir := curDir + '\' + FList.Strings[DIR.FileIdx];
      end;

      // Go through the entries in the directory
      for x := 1 to numDirs do
      begin

        // If new index is after firstData, stop the FOR-loop
        if (DIR.Offset+(x-1)*8) >= firstData then
          break;

        // Seek into position!
        fileseek(FHandle,DIR.Offset+(x-1)*8,0);

        // Recursively call the function at new offset
        res := ReadLeisureSuitLarryMagnaCumLaudeJAM_alt(newDir,OList,firstData,FList,EList);

        // If the function call returned no new file, then no need to continue (waste of time)
        if res = 0 then
          break;

        // Increase number of found files
        inc(result,res);

      end;

    end
    else  // Then it is a file! :p
    begin

      // We are seeking to offset, but we want to keep current offset
      OldOffset := FileSeek(FHandle,0,1);
      FileSeek(FHandle,DIR.Offset,0);

      // Here is the information we are looking for (size of file)
      FileRead(FHandle,ENT,SizeOf(ENT));

      // Go back to previous offset
      FileSeek(FHandle,OldOffset,0);

      // Add new entry to the list!
      if length(curDir) > 0 then
        FSE_Add(curDir+'\'+FList.Strings[DIR.FileIdx]+'.'+EList.Strings[DIR.ExtIdx],DIR.Offset+$20,ENT.Size,0,0)
      else
        FSE_Add(FList.Strings[DIR.FileIdx]+'.'+EList.Strings[DIR.ExtIdx],DIR.Offset+$20,ENT.Size,0,0);
      inc(result);

    end;
  end;

end;

function ReadLeisureSuitLarryMagnaCumLaudeJAM(src: string): Integer;
var HDR: JAM2Header;
    NumE,x,OldOffset : integer;
    FList: TStringList;
    EList: TStringList;
    OList: TIntList;
    tmpChar: array[0..7] of char;
    tmpExt: array[0..3] of char;
    unkVal: word;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, Sizeof(HDR));

    if (HDR.ID <> 'JAM2') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'JAM2';
      ErrInfo.Games := 'Leisure Suit Larry: Magna Cum Laude';
    end
    else
    begin

      NumE := 0;

      // Preparing lists
      EList := TStringList.Create;
      FList := TStringList.Create;
      OList := TIntList.Create;
      try

        // We are reading the filenames (without extensions)
        // (8 characters, padded with trailing zeroes!)
        for x := 1 to HDR.NumFiles do
        begin
          FileRead(FHandle,tmpChar,8);
          FList.Add(strip0(tmpChar));
        end;

        // And now reading the extensions
        // (4 characters, padded with trailing zeroes!)
        for x := 1 to HDR.NumExts do
        begin
          FileRead(FHandle,tmpExt,4);
          EList.Add(strip0(tmpExt));
        end;

        FileRead(FHandle,unkval,2);
        FileSeek(FHandle,2,1);
        OldOffset := FileSeek(FHandle,0,1);

        // Go through initial (root) folder
        // and then recursively through all the folders
        for x := 1 to unkVal do
        begin
          fileseek(FHandle,OldOffset+(x-1)*8,0);
          inc(NumE,ReadLeisureSuitLarryMagnaCumLaudeJAM_alt('',OList,HDR.OffsetFirstEntry,FList,EList));
        end;

        // Below is a VERY VERY UGLY method to read JAM2 files
        // (doesn't take into account the folders structures)!!!
        // ----Kept here for debug purposes---
{
        FSE_Add('00-'+inttohex(FList.Count-1,4)+'-'+inttohex(EList.Count -1,4),1,1,0,0);
        FSE_Add('01-'+inttohex(unkval,8),1,1,0,0);
        inc(NumE,2);

        while FileSeek(FHandle,0,1) < HDR.OffsetFirstEntry do
        begin
          FileRead(Fhandle,DIR,SizeOf(DIR));

          if (DIR.offset < HDR.OffsetFirstEntry) then
          begin

            FSE_Add('06-'+inttohex(DIR.FileIdx,4)+'-'+inttohex(DIR.ExtIdx,4)+'-'+inttohex(DIR.Offset,8)+'-'+booltostr((DIR.FileIdx and $1000)=$1000,true),FileSeek(FHandle,0,1)-8,1,0,0);
            inc(numE);

          end
          else if (DIR.FileIdx and $1000) = $1000 then
          begin

            // Directory.. unhandled

            if (DIR.FileIdx xor $1000) > (FList.Count-1) then
            begin
              FSE_Add('03-'+inttohex((DIR.FileIdx xor $1000),4)+'-'+inttohex(DIR.ExtIdx,4),DIR.Offset,1,0,0);
            end
            else
              FSE_Add('02-'+FList.Strings[(DIR.FileIdx xor $1000)]+'-'+inttohex((DIR.FileIdx xor $1000),4)+'-'+inttohex(DIR.ExtIdx,4),DIR.Offset,1,0,0);
            inc(NumE);

          end
          else
          begin
            if DIR.FileIdx <= (FList.Count-1) then
            begin
              OldOffset := FileSeek(FHandle,0,1);
              FileSeek(FHandle,DIR.Offset,0);
              FileRead(FHandle,ENT,SizeOf(ENT));
              FileSeek(FHandle,OldOffset,0);
              if DIR.ExtIdx > (EList.Count-1) then
              begin
                //showmessage(inttostr(DIR.FileIdx,4)+' '+inttostr(DIR.ExtIdx));
                FSE_Add('04-'+FList.Strings[DIR.FileIdx]+'-'+inttohex(DIR.FileIdx,4)+'-'+inttohex(DIR.ExtIdx,4),DIR.Offset,ENT.Size,0,0);
              end
              else
                FSE_Add('05-'+inttohex(DIR.FileIdx,4)+'-'+inttohex(DIR.ExtIdx,4)+'-'+FList.Strings[DIR.FileIdx]+'.'+EList.Strings[DIR.ExtIdx],DIR.Offset+$20,ENT.Size,0,0);
              inc(NumE);
            end;
          end;

        end;
 }
      finally  // We are done.. free lists
        FreeAndNil(EList);
        FreeAndNil(FList);
        FreeAndNil(OList);
      end;

      Result := NumE;

      DrvInfo.ID := 'JAM2';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Lemmings Revolution .BOX support ========================================= //
// -------------------------------------------------------------------------- //

type LEMBOXHeader = packed record
       ID: array[0..5] of char;
       Dirnum: integer;
       DirSize: integer;
     end;
// DirNum * Get32
// n as Long (n = DirNum)
// DirNum * Entry
     LEMBOXEntry = record
       Offset: integer;
     end;

function ReadLemmingsRevolutionBOX(src: string): Integer;
var HDR: LEMBOXHeader;
    ENT: LEMBOXEntry;
    NumE,x,OldOffset : integer;
    EList: TStringList;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR.ID, 6);
    FileRead(FHandle, HDR.DirNum, 4);
    FileRead(FHandle, HDR.DirSize, 4);

    if (HDR.ID <> 'LEMBOX') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'BOX';
      ErrInfo.Games := 'Lemmings Revolution';
    end
    else
    begin
      TotFSize := FileSeek(FHandle,0,2);
      FileSeek(FHandle,14,0);
      EList := TStringList.Create;
      try
        NumE := HDR.DirNum;

        for x := 1 to NumE do
          EList.Add(Get32(FHandle));

        OldOffset := 0;

        for x := 1 to NumE do
        begin
          FileRead(FHandle,ENT.Offset,4);

          if x>1 then
          begin
            FSE_Add(Strip0(EList.Strings[x-2]),OldOffset,ENT.Offset-OldOffset,0,0);
          end;

          OldOffset := ENT.Offset;
        end;
        FSE_Add(Strip0(EList.Strings[NumE-1]),OldOffset,TotFSize-OldOffset,0,0);
      finally
        FreeAndNil(EList);
      end;

      //ShowMessage(IntTosTr(NumE));

      Result := NumE;

      DrvInfo.ID := 'BOX';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;


// -------------------------------------------------------------------------- //
// LithTech .REZ support ==================================================== //
// -------------------------------------------------------------------------- //

// Improved in 20516: Now using max offsets instead of reading everything
//                    dumbly... Fixes NOLF2 sound.rez and is much more reliable

type REZHeader = packed record
        ID: array[0..126] of Char;
        Version: Integer;
        DirOffset: Integer;
        DirSize: Integer;
        Empty1: Integer;
        IdxOffset: Integer;
        DateTime: Integer;
        Empty2: Integer;
        LongestFoldernameLength: Integer;
        LongestFilenameLength: Integer;
     end;
     REZEntry = packed record
       EntryType: Integer;
       Offset: Integer;
       Size: Integer;
       DateTime: Integer;
     end;

const
  REZID : String = #13+#10+'RezMgr Version 1 Copyright (C) 1995 MONOLITH INC.           '+#13+#10+'LithTech Resource File                                      '+#13+#10+#26;
  REZIDOld : String = #13+#10+'RezMgr Version 1 Copyright (C) 1995 MONOLITH INC.           '+#13+#10+'                                                            '+#13+#10+#26;

function Parse_REZ(offset, maxoffset: integer; cdir: string): integer;
var ENT: REZEntry;
    tstr,nam,ext,pcdir,fcdir: string;
    tint,res,nextoffset: integer;
    extbuf: array[1..4] of Char;
begin

  res := 0;

  if Offset < TotFSize then
  begin

    nextoffset := offset;
    repeat
      FileSeek(FHandle,nextoffset,0);
      FileRead(FHandle,ENT,SizeOf(REZEntry));
      inc(nextoffset,SizeOf(REZEntry));

      case ENT.EntryType of
        1: begin
             pcdir := cdir;
             tstr := Strip0(Get0(FHandle));
             inc(nextoffset,length(tstr)+1);
             if ENT.Size > 0 then
             begin
               fcdir := cdir + tstr + '\';
               inc(res,Parse_REZ(ENT.Offset,ENT.Offset+ENT.Size,fcdir));
             end;
             Per := Per + 1;
             if Per > 100 then
               Per := 0;
             SetPercent(Per);
           end;
        0: begin
             FileRead(FHandle,tint,4);  // Numeric ID
             inc(nextoffset,4);
             FileRead(Fhandle,extbuf,4);
             inc(nextoffset,length(extbuf)+1);
             ext := extbuf;
             ext := RevStr(Strip0(ext));
             FileRead(FHandle,tint,4);  // Blank
             inc(nextoffset,4);
             nam := Strip0(Get0(FHandle));
             inc(nextoffset,length(nam)+1);
             if (length(nam) > 0) and (ENT.Offset > 0) and (ENT.Size > 0) and (extbuf[4] = #0) and (ENT.Offset < TotFSize) and (ENT.Offset + ENT.Size < TotFSize) and (ENT.Offset > 162) then
             begin
               if (ext = '') then
                 tstr := cdir + nam
               else
                 tstr := cdir + nam + '.' + ext;
               FSE_Add(tstr,ENT.Offset,ENT.Size,0,0);
               Inc(Res);
             end;
           end;
      end;

    until nextoffset >= maxoffset;

    Parse_REZ := res;
  end
  else
    Parse_REZ := 0;

end;

function ReadLithTechREZ(src: string): Integer;
var HDR: REZHeader;
    NumE: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR.ID, 127);
    FileRead(FHandle, HDR.Version, 4);
    FileRead(FHandle, HDR.DirOffset, 4);
    FileRead(FHandle, HDR.DirSize, 4);
    FileRead(FHandle, HDR.Empty1, 4);
    FileRead(FHandle, HDR.IdxOffset, 4);
    FileRead(FHandle, HDR.DateTime, 4);
    FileRead(FHandle, HDR.Empty2, 4);
    FileRead(FHandle, HDR.LongestFoldernameLength, 4);
    FileRead(FHandle, HDR.LongestFilenameLength, 4);

    if ((HDR.ID <> REZID) and (HDR.ID <> REZIDOld)) or (HDR.Version <> 1) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadLithTechREZ := -3;
      ErrInfo.Format := 'REZ';
      ErrInfo.Games := 'Alien vs Predator 2, No One Lives Forever, Shogo, ..';
    end
    else
    begin
      NumE := Parse_REZ(HDR.DirOffset,HDR.DirOffset+HDR.DirSize,'');

      ReadLithTechREZ := NumE;

      DrvInfo.ID := 'REZ';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    ReadLithTechREZ := -2;

end;

// -------------------------------------------------------------------------- //
// MDK .SNI support ========================================================= //
// -------------------------------------------------------------------------- //

type MDK1Header = packed record
       Magic: integer;
       Filename: array[0..11] of char;
       TestOffset: integer;
       Dirnum: integer;
     end;
     MDK1Index = record
       Filename: array[0..11] of char;
       Flag: integer;
       Offset: integer;
       Size: integer;
     end;

function ReadMDKSNI(src: string): Integer;
var HDR: MDK1Header;
    ENT: MDK1Index;
    disp, extf: string;
    NumE, x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle,HDR.Magic,4);
    FileRead(FHandle,HDR.Filename,12);
    FileRead(FHandle,HDR.TestOffset,4);
    FileRead(FHandle,HDR.Dirnum,4);

    if HDR.Magic <> (FileSeek(FHandle,0,2)-4) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'SNI';
      ErrInfo.Games := 'MDK';
    end
    else
    begin

      extf := Uppercase(ExtractFileExt(Strip0(HDR.Filename)));
      if extf = '.SND' then
        extf := '.WAV';

      FileSeek(FHandle,24,0);

      NumE := HDR.DirNum;

      for x:= 1 to NumE do
      begin

        Per := ROund(((x / NumE)*100));
        SetPercent(Per);

        FileRead(Fhandle,ENT.Filename,12);
        FileRead(Fhandle,ENT.Flag,4);
        FileRead(Fhandle,ENT.Offset,4);
        FileRead(Fhandle,ENT.Size,4);
        disp := Strip0(ENT.FileName);

        FSE_Add(disp+extf,ENT.Offset+4,ENT.Size,0,0);
      end;

      Result := NumE;

      DrvInfo.ID := 'SNI';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Monkey Island 3 .BUN support ============================================= //
// -------------------------------------------------------------------------- //

type BUNHeader = packed record
        ID: array[1..4] of Char;
        DirOffset: longword;
        DirSize: longword;
        CreationDate: integer;
     end;
     BUNEntry = packed record
        FileName: Array[1..8] of Char;
        Ext: Array[1..4] of char;
     end;

function ReadMonkeyIsland3BUN(src: string): Integer;
var HDR: BUNHeader;
    ENT: BUNEntry;
    disp: string;
    NumE, x: integer;
    Offset: integer;
    Size: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR.ID, 4);
    HDR.DirOffset := GetSwapInt(FHandle);
    HDR.DirSize := GetSwapInt(FHandle);
    HDR.CreationDate := GetSwapInt(FHandle);

    if HDR.ID <> 'LB83' then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadMonkeyIsland3BUN := -3;
      ErrInfo.Format := 'BUN';
      ErrInfo.Games := 'Monkey Island 3';
    end
    else
    begin

      NumE := HDR.DirSize;

      FileSeek(Fhandle, HDR.DirOffset, 0);

      for x:= 1 to NumE do
      begin

        Per := ROund(((x / NumE)*100));
        SetPercent(Per);

        FileRead(Fhandle,ENT,12);
        disp := Strip0(ENT.FileName)+'.'+Strip0(ENT.Ext);
        Offset := GetSwapInt(FHandle);
        Size := GetSwapInt(FHandle);

        FSE_Add(disp,Offset,Size,0,0);

      end;

      ReadMonkeyIsland3BUN := NumE;

      DrvInfo.ID := 'BUN';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    ReadMonkeyIsland3BUN := -2;

end;

// -------------------------------------------------------------------------- //
// Mortyr .HAL support ====================================================== //
// -------------------------------------------------------------------------- //

type APUKHeader = packed record
       ID: array[0..3] of char;
       Dirnum: integer;
       Unknown: array[1..24] of byte;
     end;
     APUKEntry = packed record
       Size: integer;
       Offset: integer;
       Unknown1: integer;
       Unknown2: integer;
       Filename: array[0..15] of char;
     end;

function ReadMortyrHAL(src: string): Integer;
var HDR: APUKHeader;
    ENT: APUKEntry;
    NumE,x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR.ID, 4);
    FileRead(FHandle, HDR.DirNum, 4);
    FileRead(FHandle, HDR.Unknown, 24);

    if (HDR.ID <> 'APUK') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'HAL';
      ErrInfo.Games := 'Mortyr';
    end
    else
    begin
      NumE := HDR.DirNum;

      //ShowMessage(IntToStr(NumE));

      for x := 1 to NumE do
      begin

        FileRead(FHandle,ENT.Size,4);
        FileRead(FHandle,ENT.Offset,4);
        FileRead(FHandle,ENT.Unknown1, 4);
        FileRead(FHandle,ENT.Unknown2, 4);
        FileRead(FHandle,ENT.Filename,16);

        FSE_Add(Strip0(ENT.Filename),ENT.Offset,ENT.Size,ENT.Unknown1,ENT.Unknown2);

      end;

      Result := NumE;

      DrvInfo.ID := 'HAL';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Moto Racer .BKF support ================================================== //
// -------------------------------------------------------------------------- //

type BKF_Entry = packed record
       Filename: array[0..35] of char;
       Offset: integer;
       Size: integer;
     end;

function ReadMotoRacerBKF(src: string): Integer;
var ENT: BKF_Entry;
    NumE,x, DirNum: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, DirNum, 4);

    NumE := DirNum;

    for x := 1 to NumE do
    begin
      FileRead(FHandle,ENT.Filename, 36);
      FileRead(FHandle,ENT.Offset,4);
      FileRead(FHandle,ENT.Size,4);

      FSE_Add(Strip0(ENT.Filename),ENT.Offset,ENT.Size,0,0);

    end;

    Result := NumE;

    DrvInfo.ID := 'BKF';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Myst IV: Revelation .M4B support ========================================= //
// -------------------------------------------------------------------------- //

function ReadMystIVRevelationM4B_Alt(dir: string): Integer;
var tByt, x: Byte;
    y, NumE, Size, Offset, tInt: cardinal;
    disp: string;
begin

  result := 0;

  FileRead(FHandle,tByt,1);

  if tByt = 0 then
  begin
    FileRead(FHandle,NumE,4);
    for y := 1 to NumE do
    begin
      disp := strip0(get32(FHandle));
      FileRead(FHandle,Size,4);
      FileRead(FHandle,Offset,4);
      FSE_Add(dir + '\' + disp,offset,size,0,0);
    end;
    inc(result,NumE);
  end
  else
  begin
    for x := 1 to tByt do
    begin
      FileRead(FHandle,tInt,4);
      if (tInt > 65535) then
        raise EOverflow.Create(inttostr(tInt));
      disp := Strip0(Get32(FHandle,tInt));
      if length(dir) > 0 then
        disp := dir + '\' + disp;
      inc(result,ReadMystIVRevelationM4B_Alt(disp));
    end;
    FileRead(FHandle,tInt,4);
    inc(tInt);
    dec(tInt);
  end;

end;

type M4BHeader = packed record
       SigSize: cardinal;
       SigName: array[0..10] of char;
     end;

function ReadMystIVRevelationM4B(src: string): Integer;
var HDR: M4BHeader;
    tInt: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, SizeOf(HDR));

    if (HDR.SigSize <> $B) and (strip0(HDR.SigName) <> 'UBI_BF_SIG') then
    begin

      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'M4B';
      ErrInfo.Games := 'Myst IV: Revelation';

    end
    else
    begin

      FileRead(FHandle,tInt,4);  // Should be 1
      FileRead(FHandle,tInt,4);  // Should be 0

      Result := ReadMystIVRevelationM4B_Alt('');

      DrvInfo.ID := 'M4B';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;


// -------------------------------------------------------------------------- //
// Nascar .DAT support ====================================================== //
// -------------------------------------------------------------------------- //

type NascarDAT_Entry = packed record
       Unknow: word;
       Size: integer;
       Size2: integer;
       Filename: array[0..12] of char;
       Offset: integer;
     end;

function ReadNascarDAT(): Integer;
var ENT: NascarDAT_Entry;
    NumE,x : integer;
    DirNum : word;
begin

  TotFSize := FileSeek(FHandle,0,2);

  FileSeek(Fhandle, 0, 0);
  FileRead(FHandle, DirNum, 2);

  if ((DirNum * SizeOf(NascarDAT_Entry)) > TotFSize) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'DAT';
    ErrInfo.Games := 'Nascar Racing';
  end
  else
  begin
    NumE := DirNum;

    for x := 1 to NumE do
    begin

      FileRead(FHandle,ENT.Unknow,2);
      FileRead(FHandle,ENT.Size,4);
      FileRead(FHandle,ENT.Size2,4);
      FileRead(FHandle,ENT.Filename,13);
      FileRead(FHandle,ENT.Offset,4);

      if (ENT.Offset > TotFSize) or (ENT.Offset < (2+SizeOf(NascarDAT_Entry)*NumE)) or (ENT.Size < 0)
      or (ENT.Offset + ENT.Size > TotFSize) then
      begin
        FileClose(Fhandle);
        FHandle := 0;
        Result := -3;
        ErrInfo.Format := 'DAT';
        ErrInfo.Games := 'Nascar Racing';
        FSE_Free();
        exit;
      end;

      FSE_Add(Strip0(ENT.Filename),ENT.Offset,ENT.Size,0,0);

    end;

    Result := NumE;

    DrvInfo.ID := 'DAT';
    DrvInfo.Sch := '';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// N.I.C.E. 2 .SYN support ================================================== //
// -------------------------------------------------------------------------- //

type SYN_Header = packed record
       ID: array[0..3] of char;
       DirNum: integer;
       Reserved: array[1..8] of byte;
     end;
     SYN_Entry = packed record
       Filename: array[0..23] of char;
       Offset: integer;
       Size: integer;
     end;

function ReadNICE2SYN(src: string): Integer;
var HDR: SYN_Header;
    ENT: SYN_Entry;
    NumE,x : integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR.ID, 4);
    FileRead(FHandle, HDR.DirNum, 4);
    FileRead(FHandle, HDR.Reserved, 8);

    if (HDR.ID <> 'FNYS') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'SYN';
      ErrInfo.Games := 'Breakneck, N.I.C.E.2, ..';
    end
    else
    begin
      NumE := HDR.DirNum;

      for x := 1 to NumE do
      begin
          FileRead(FHandle,ENT.FileName, 24);
          FileRead(FHandle,ENT.Offset,4);
          FileRead(FHandle,ENT.Size,4);

          FSE_Add(Strip0(ENT.FileName),ENT.Offset,ENT.Size,0,0);

      end;

      //ShowMessage(IntTosTr(NumE));

      Result := NumE;

      DrvInfo.ID := 'SYN';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Nocturne .POD support ==================================================== //
// -------------------------------------------------------------------------- //

type POD2Header = packed record
       ID: array[0..3] of char;
       Unknown1: integer;
       Description: array[0..79] of char;
       NumEntries: integer;
       Unknown3: integer;
     end;
     POD2Entry = packed record
       NameOffset: integer;
       Size: integer;
       Offset: integer;
       Unknown1: integer;
       Unknown2: integer;
     end;

function ReadNocturnePOD(): Integer;
var HDR: POD2Header;
    ENT: POD2Entry;
    disp: string;
    NumE, x, NamesSize: integer;
    buf: PByteArray;
    NameStream: TMemoryStream;
begin

  FileSeek(Fhandle, 0, 0);
  FileRead(Fhandle, HDR, SizeOf(POD2Header));

  FileRead(FHandle, ENT, SizeOf(POD2Entry));

  NamesSize := ENT.Offset - ($60+HDR.NumEntries*SizeOf(POD2Entry));

  GetMem(buf,NamesSize);
  NameStream := TMemoryStream.Create;
  try
    FileSeek(FHandle,$60+HDR.NumEntries*SizeOf(POD2Entry),0);
    FileRead(FHandle,Buf^,NamesSize);
    NameStream.Write(buf^,NamesSize);
    NameStream.Seek(0,0);
  finally
    FreeMem(buf);
  end;

  NumE := HDR.NumEntries;

  FileSeek(Fhandle, $60, 0);

  for x := 1 to NumE do
  begin

    Per := ROund(((x / NumE)*100));
    SetPercent(Per);

    FileRead(Fhandle, ENT, SizeOf(POD2Entry));
    NameStream.Seek(ENT.NameOffset,0);
    disp := Get0(NameStream);

    FSE_Add(Strip0(disp),ENT.Offset,ENT.Size,0,0);

  end;

  FreeAndNil(NameStream);

  Result := NumE;

  DrvInfo.ID := 'POD2';
  DrvInfo.Sch := '\';
  DrvInfo.FileHandle := FHandle;
  DrvInfo.ExtractInternal := False;

end;

// -------------------------------------------------------------------------- //
// Novalogic PFF support (PFF3 only) ======================================== //
// -------------------------------------------------------------------------- //

type PFFHeader = packed record
        DataOffset: Integer;     // Should be &H14
        ID: Array[1..4] of Char; // "PFF3"
        DirNum: Integer;         // Number of entries
        DirEntrySize: Integer;   // Known values:
                                 // 32 & 36
        DirOffset: Integer;      // Offset to index
     end;
     PFFEntry = packed record
        Unknown1: Integer;       // Always 0 ?
        Offset: Integer;         //
        Size: Integer;
        Unknown2: Integer;
        FileName: Array[1..16] of Char;
     end;

function ReadNovalogicPFF3(src: string): Integer;
var HDR: PFFHeader;
    ENT: PFFEntry;
    disp: string;
    NumE, x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, 20);

    if (HDR.ID <> 'PFF3') or (HDR.DirEntrySize < 32) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadNovalogicPFF3 := -3;
      ErrInfo.Format := 'PFF3';
      ErrInfo.Games := 'Comanche 4, Delta Force 1/2, Delta Force: Land Warrior, ..';
    end
    else
    begin

      NumE := HDR.DirNum;

      for x:= 1 to NumE do
      begin

        Per := ROund(((x / NumE)*100));
        SetPercent(Per);

        FileSeek(Fhandle,HDR.DirOffset+((x-1)*HDR.DirEntrySize),0);
        FileRead(Fhandle,ENT,32);
        disp := Strip0(ENT.FileName);

        FSE_Add(disp,ENT.Offset,ENT.Size,0,0);
      end;

      ReadNovalogicPFF3 := NumE;

      DrvInfo.ID := 'PFF3';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    ReadNovalogicPFF3 := -2;

end;

// -------------------------------------------------------------------------- //
// Operation: Flashpoint .PBO support ======================================= //
// -------------------------------------------------------------------------- //

// Get0
type PBO_Entry = packed record
       EmptyVal: array[0..11] of byte;
       Unknown: integer;
       Size: integer;
     end;

function ReadOperationFlashpointPBO(src: string): Integer;
var ENT: array[1..2000] of PBO_Entry;
    NumE,x, coffset : integer;
    nam: string;
    EList: TStringList;
    SlashMode: boolean;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    EList := TStringList.Create;
    try

      TotFSize := FileSeek(FHandle,0,2);

      FileSeek(Fhandle, 0, 0);
      NumE := 0;
      SlashMode := true;

      repeat
        nam := Strip0(Get0(FHandle));
        if SlashMode And (Pos('\',nam) > 0) Then
          SlashMode := False;
        EList.Add(nam);
        Inc(NumE);
        FileRead(FHandle,ENT[NumE].EmptyVal,12);
        FileRead(FHandle,ENT[NumE].Unknown,4);
        FileRead(FHandle,ENT[NumE].Size,4);
      until nam='';

      Dec(NumE);

      coffset := FileSeek(FHandle,0,1);

      for x := 1 to NumE do
      begin

        FSE_Add(EList.Strings[x-1],COffset,ENT[x].Size,0,0);
        Inc(COffset,ENT[x].Size);

      end;
     //ShowMessage(IntTosTr(NumE));

      Result := NumE;

      DrvInfo.ID := 'PBO';
      if SlashMode then
        DrvInfo.Sch := '/'
      else
        DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;
    finally
      FreeAndNil(EList);
    end;

  end
  else
    Result := -2;

end;


// -------------------------------------------------------------------------- //
// Overlord .PRP/.PVP research ============================================== //
// -------------------------------------------------------------------------- //

type RPK_Header = packed record
       ID: array[0..3] of char;
       Unknown1: word;
       Unknown2: word;
       NumEntries: cardinal;
       DataSize: cardinal;
       Description: array[0..159] of char;  // Text + 0x0 Fill
       Unknown3: cardinal;                  // Offset?
       Unknown4: array[0..2] of cardinal;
     end;
     // RelOffset: cardinal (relative to end of header + offset list)
     // Unknown: cardinal (counter?) not present at last iteration
     // Uses Get32 structure for strings
     // Does not make much sense to me... Looks like serialized stuff


// -------------------------------------------------------------------------- //
// Painkiller .PAK support ================================================== //
// -------------------------------------------------------------------------- //

type PKPAKHeader = packed record
        ID: byte;
        Offset: longword;
     end;

const
  PKDECKEY : array[0..4] of integer = (-2, -1, 0, 1 ,2);

function ReadPainKillerPAK(): Integer;
var HDR: PKPAKHeader;
    FileName: string;
    x,y,z, FileSize, FileOffset: integer;
    nbfatentry, filenamesize, numE, EmbedSize: integer;
    HF: THandleStream;
    FileNameKey, FileNameCrypted: array of byte;
    PreKey: array[0..15,0..15] of integer;
begin

  FileSeek(Fhandle, 0, 0);
  FileRead(Fhandle, HDR, SizeOf(HDR));

  if ((HDR.ID <> 0) and (HDR.ID <> 1)) or (HDR.Offset < TotFSize) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'PKPAK';
    ErrInfo.Games := 'Painkiller';
  end
  else
  begin

    // Generating PreKey array

    z := 0;

    for x := 0 to 15 do
      for y := 0 to 15 do
      begin
        PreKey[x,y] := PKDECKEY[z];
        Inc(z);
        if z = 5 then
          z := 0;
      end;

    HF := THandleStream.Create(FHandle);
    try

      // Seek to index
      HF.Seek(HDR.Offset,soBeginning);

      // Read number of entries in index
      HF.Read(NbFatEntry,4);

      // Setting number of entries
      NumE := NbFatEntry;

      // Parse the index
      for x := 1 to NbFatEntry do
      begin
        // Read filename size
        HF.Read(FileNameSize,4);

        // Allocating memory
        SetLength(FileNameCrypted,FileNameSize);
        SetLength(FileNameKey,FileNameSize);

        // Reading crypted content
        HF.Read(FileNameCrypted[0],FileNameSize);

        // Calculating Initial Key
        FileNameKey[0] := (FileNameSize * 2 + 1 + PreKey[(FileNameSize and $F0) shr 4,FileNameSize and $F] + x) and $FF;
        // Calculating Full Key
        for y := 1 to FileNameSize - 1 do
          FileNameKey[y] := ((FileNameKey[y-1] + 2) and $FF);

        // Decrypting filename
        FileName := '';
        for y := 0 to FileNameSize - 1 do
          FileName := FileName + chr(FileNameCrypted[y] xor FileNameKey[y]);

        // Reading offset and size of file
        HF.Read(FileOffset,4);
        HF.Read(FileSize,4);
        HF.Read(EmbedSize,4);

        if (FileOffset = 0) or (FileSize = 0) then
          Dec(NumE)
        else
          FSE_Add(FileName,FileOffset,FileSize,EmbedSize,0);
      end;

    finally
      FreeAndNil(HF);
    end;

    Result := NumE;

    DrvInfo.ID := 'PKPAK';
    DrvInfo.Sch := '/';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := true;

  end;

end;

// -------------------------------------------------------------------------- //
// Pixel Painters .RES support ============================================== //
// -------------------------------------------------------------------------- //

type PPRESIndex = packed record
       FileNameLength: byte;
       FileName: array[0..11] of char;
       Offset: longword;
       Length: longword;
       FileType: byte; // 1 = Text (sort of..)
                       // 2 = Binary
     end;

function ReadPixelPaintersRES(): Integer;
var ENT: PPRESIndex;
    NumFiles: word;
    GoodFormat: boolean;
    Per: byte;
    x: integer;
begin

  SetPercent(0);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, NumFiles, 2);

    GoodFormat := True;

    for x := 1 to NumFiles do
    begin
      FileRead(FHandle,ENT,SizeOf(ENT));
      FSE_Add(LeftStr(ENT.FileName,ENT.FileNameLength),ENT.Offset,ENT.Length,ENT.FileType,0);
      GoodFormat := GoodFormat and (ENT.FileNameLength <= 12) and ((ENT.FileType = 1) or (ENT.FileType = 2));
      Per := ROund(((x / NumFiles)*100));
      SetPercent(Per);
    end;

    if GoodFormat then
    begin

      Result := NumFiles;

      DrvInfo.ID := 'PPRES';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end
    else
    begin
      FSE_free;
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'PPRES';
      ErrInfo.Games := 'Electranoid, Fuzzy''s World of Miniature Space Golf, Laser Light & Xatax';
    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Pixel Painters .XRS support ============================================== //
// -------------------------------------------------------------------------- //

type PPXRSIndex = packed record
       FileNameLength: byte;
       FileName: array[0..11] of char;
       Offset: longword;
       Length: longword;
       Unknown: array[1..11] of byte; // DOS Date & Time + ???
     end;

function ReadPixelPaintersXRS(src: string): Integer;
var ENT: PPXRSIndex;
    NumFiles: word;
    GoodFormat: boolean;
    Per: byte;
    x: integer;
begin

  SetPercent(0);

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, NumFiles, 2);

    GoodFormat := True;

    for x := 1 to NumFiles do
    begin
      FileRead(FHandle,ENT,SizeOf(ENT));
      FSE_Add(LeftStr(ENT.FileName,ENT.FileNameLength),ENT.Offset,ENT.Length,0,0);
      GoodFormat := GoodFormat and (ENT.FileNameLength <= 12);
      Per := ROund(((x / NumFiles)*100));
      SetPercent(Per);
    end;

    if GoodFormat then
    begin

      Result := NumFiles;

      DrvInfo.ID := 'PPXRS';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end
    else
    begin
      FSE_free;
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'PPXRS';
      ErrInfo.Games := 'Dig It!';
    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Postal .SAK support ====================================================== //
// -------------------------------------------------------------------------- //

type
  PPostalList = ^PostalList;
  PostalList = record
    Name: string;
    Offset: Integer;
  end;

function PostalListCompare(Item1, Item2: Pointer): Integer;
var PItem1, PItem2: PPostalList;
begin

  PItem1 := Item1;
  PItem2 := Item2;
  result := PItem1^.Offset - PItem2^.Offset;

end;

type SAK_Header = packed record
       ID: array[0..3] of char;
       Version: integer;
       NumEntries: Word;
     end;

function ReadPostalSAK(src: string): Integer;
var HDR: SAK_Header;
    disp, oldDisp: string;
    NumE, x, CurOffset, OldOffset, TotSize: integer;
    EList: TList;
    ENT: PPostalList;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, 10);

    if (HDR.ID <> 'SAK ') or (HDR.Version <> 1) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'SAK';
      ErrInfo.Games := 'Postal';
    end
    else
    begin

      EList := TList.Create;
      try

        TotSize := FileSeek(Fhandle,0,2);
        FileSeek(FHandle,10,0);
        OldOffset := 0;

        NumE := HDR.NumEntries;

        for x := 1 to HDR.NumEntries do
        begin
          disp := strip0(get0(FHandle));
          FileRead(Fhandle,CurOffset,4);
          New(ENT);
          ENT^.Name := disp;
          ENT^.Offset := CurOffset;
          EList.Add(ENT);
        end;

        EList.Sort(@PostalListCompare);

        for x := 0 to NumE-1 do
        begin
          ENT := EList.Items[x];
          if x > 0 then
          begin
            FSE_Add(OldDisp,OldOffset,ENT^.Offset - OldOffset,0,0);
            if x = NumE-1 then
              FSE_Add(ENT^.Name,ENT^.Offset,TotSize-ENT^.Offset,0,0);
          end;
          OldDisp := ENT^.Name;
          OldOffset := ENT^.Offset;
          Dispose(ENT);
        end;
      finally
        FreeAndNil(EList);
      end;

      Result := NumE;

      DrvInfo.ID := 'SAK';
      DrvInfo.Sch := '/';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Prototype .RCF support =================================================== //
// -------------------------------------------------------------------------- //

type RCFHeader = packed record
       ID: array[0..31] of char;
       Unknown1: cardinal;
       Unknown2: cardinal;
       Unknown3: cardinal;
       NameOffset: cardinal;
       Unknown4: cardinal;
       Unknown5: cardinal;
       FileCount: cardinal;
     end;
     RCFFileBlock = packed record
       Unknown: cardinal;
       Offset: cardinal;
       Size: cardinal;
     end;
     RCFFileHeader = packed record
       ID: array[0..7] of char;
       OriginalSize: int64;
     end;

procedure RCFFileBlockSort(var A: array of RCFFileBlock; iLo, iHi: cardinal) ;
var
  Lo, Hi, Pivot: cardinal;
  T: RCFFileBlock;
begin
  Lo := iLo;
  Hi := iHi;
  Pivot := A[(Lo + Hi) div 2].Offset;
  repeat
    while A[Lo].Offset < Pivot do Inc(Lo) ;
    while A[Hi].Offset > Pivot do Dec(Hi) ;
    if Lo <= Hi then
    begin
      T := A[Lo];
      A[Lo] := A[Hi];
      A[Hi] := T;
      Inc(Lo) ;
      Dec(Hi) ;
    end;
  until Lo > Hi;
  if Hi > iLo then RCFFileBlockSort(A, iLo, Hi) ;
  if Lo < iHi then RCFFileBlockSort(A, Lo, iHi) ;
end;

function ReadPrototypeRCF(src: string): integer;
var HDR: RCFHeader;
    FileBlock: array of RCFFileBlock;
    inFile: THandleStream;
    Buffer: TMemoryStream;
    x, namelen: cardinal;
    disp: string;
    compressedEntries: boolean;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    inFile := THandleStream.Create(FHandle);
    inFile.ReadBuffer(HDR, SizeOf(RCFHeader));

    if (Strip0(HDR.ID) <> 'ATG CORE CEMENT LIBRARY') or (HDR.ID[31] <> #0)
    or (HDR.ID[23] <> #0) or (HDR.ID[24] <> #0) or (HDR.ID[25] <> #0) or (HDR.ID[26] <> #0)
    or (HDR.ID[27] <> #0) or (HDR.ID[28] <> #0) or (HDR.ID[29] <> #0) or (HDR.ID[30] <> #0)
    or (HDR.NameOffset > inFile.Size) or ((HDR.NameOffset + (HDR.FileCount * SizeOf(RCFFileBlock))) > inFile.Size) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'RCF';
      ErrInfo.Games := 'Prototype, Scarface, The Incredible Hulk: Ultimate Destruction';
    end
    else
    begin

      Setlength(FileBlock,HDR.FileCount);

      Buffer := TMemoryStream.Create;
      Buffer.CopyFrom(inFile,HDR.FileCount * SizeOf(RCFFileBlock));
      Buffer.Seek(0,0);

      for x := 0 to HDR.FileCount-1 do
        Buffer.ReadBuffer(FileBlock[x],SizeOf(RCFFileBlock));

      RCFFileBlockSort(FileBlock,Low(FileBlock),High(Fileblock));

      inFile.Seek(HDR.NameOffset+4,0);

      compressedEntries := false;

      for x := 0 to HDR.FileCount-1 do
      begin
        inFile.Seek(16,1);
        inFile.ReadBuffer(nameLen,4);
        disp := get32(inFile,nameLen-1);
        if (disp[1] = '\') then
          disp := RightStr(disp,Length(Disp)-1);
        if lowercase(RightStr(disp,3)) = '.rz' then
        begin
          compressedEntries := true;
          disp := Leftstr(disp,length(disp)-3);
          FSE_Add(Disp,FileBlock[x].Offset,FileBlock[x].Size,1,0);
        end
        else
          FSE_Add(Disp,FileBlock[x].Offset,FileBlock[x].Size,0,0);
      end;

      Result := HDR.FileCount;

      DrvInfo.ID := 'RCF';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := compressedEntries;

    end;

    FreeAndNil(inFile);
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Quake .PAK support ======================================================= //
// -------------------------------------------------------------------------- //

type PACKHeader = packed record
        ID: array[1..4] of Char;
        DirOffset: longword ;
        DirSize : longword;
     end;
     PACKEntry = packed record
        FileName: array[1..56] of Char;
        Offset: longword;
        Size: longword;
     end;
     PACKEntryX = packed record
        Unknown1: longword;
        Unknown2: longword;
     end;

function ReadQuakePAK(): Integer;
var HDR: PACKHeader;
    ENT: PACKEntry;
//    ENTX: PACKEntryX;
    disp: string;
    NumE, x: integer;
    rest: longword;
begin

  FileSeek(Fhandle, 0, 0);
  FileRead(Fhandle, HDR, 12);

  if HDR.ID <> 'PACK' then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    ReadQuakePAK := -3;
    ErrInfo.Format := 'PACK';
    ErrInfo.Games := 'Half-Life, Quake, Quake 2, Trickstyle, ..';
  end
  else
  begin

    rest := HDR.DirSize mod 64;
    if rest <> 0 then
    begin
      rest := HDR.DirSize mod 72;
      if rest <> 0 then
        Rest := 0
      else
        Rest := 72;
    end
    else
      rest := 64;

    if rest > 0 then
    begin

      NumE := HDR.DirSize div rest;

      FileSeek(Fhandle, HDR.DirOffset, 0);
      str(NumE, disp);

      for x:= 1 to NumE do
      begin

        Per := ROund(((x / NumE)*100));
        SetPercent(Per);

        FileRead(Fhandle, ENT, 64);
        if rest = 72 then
          FileSeek(Fhandle,8,1);
//          FileRead(Fhandle, ENTX, 8);
      //ShowMessage(ENT.FileName);

        FSE_Add(Strip0(ENT.FileName),ENT.Offset,ENT.Size,0,0);

      end;

      ReadQuakePAK := NumE;

      DrvInfo.ID := 'PACK';
      DrvInfo.Sch := '/';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end
    else
    begin
      FileClose(FHandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'PACK';
      ErrInfo.Games := 'Half-Life, Quake, Quake 2, Trickstyle, ..';
    end;

  end;

end;

// -------------------------------------------------------------------------- //
// Quake .WAD support ======================================================= //
// -------------------------------------------------------------------------- //

type WAD2Header = packed record
       ID: array[0..3] of char;
       DirNum: integer;
       DirOffset: integer;
     end;
     WAD2Entry = packed record
       Offset: integer;
       DSize: integer;
       Size: integer;
       FType: byte;
       Compression: byte;
       Dummy: word;
       FileName: array[0..15] of char;
     end;

function ReadQuakeWAD2(): Integer;
var HDR: WAD2Header;
    ENT: WAD2Entry;
//    ENTX: PACKEntryX;
    ext: string;
    NumE, x: integer;
begin

  FileSeek(Fhandle, 0, 0);
  FileRead(Fhandle, HDR, 12);

  if (HDR.ID <> 'WAD2') and (HDR.ID <> 'WAD3') then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'WAD2/WAD3';
    ErrInfo.Games := 'Quake, Quake 2, Half-Life, ..';
  end
  else
  begin

    NumE := HDR.DirNum;

    FileSeek(FHandle,HDR.DirOffset,0);

    for x:= 1 to NumE do
    begin

      FileRead(FHandle,ENT.Offset,4);
      FileRead(FHandle,ENT.DSize,4);
      FileRead(FHandle,ENT.Size,4);
      FileRead(FHandle,ENT.FType,1);
      FileRead(FHandle,ENT.Compression,1);
      FileRead(FHandle,ENT.Dummy,2);
      FileRead(FHandle,ENT.FileName,16);

      Per := ROund(((x / NumE)*100));
      SetPercent(Per);

      case ENT.FType of
        64: ext := 'pal';
        66: ext := 'psb';
        67: ext := 'pmm';
        68: ext := 'mm';
        69: ext := 'cp';
        70: ext := 'pcp';
        else
          ext := 'unk'+IntToHex(ENT.FType,2);
      end;


      FSE_Add(Strip0(ENT.FileName)+'.'+ext,ENT.Offset,ENT.Size,ENT.FType,ENT.Compression);

    end;

    Result := NumE;

    DrvInfo.ID := HDR.ID;
    DrvInfo.Sch := '';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// Qui Veut Gagner des Millions .AWF support ================================ //
// -------------------------------------------------------------------------- //

type AWFEntry = packed record
       Offset: integer;
       Filename: array[0..259] of char;
     end;

function ReadQuiVeutGagnerDesMillionsAWF(src: string): Integer;
var ENT: AWFEntry;
    NumE,x,OldOffset : integer;
    nam: string;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, NumE, 4);

    OldOffset := 0;

    for x := 1 to NumE do
    begin
      FileRead(FHandle,ENT.Offset,4);
      FileRead(FHandle,ENT.Filename,260);
      if x > 1 then
        FSE_Add(nam,OldOffset,ENT.Offset - OldOffset,0,0);

      nam := strip0(ENT.Filename);
      OldOffset := ENT.Offset;

    end;

    FSE_Add(nam,ENT.Offset,TotFSize-ENT.Offset,0,0);

      //ShowMessage(IntTosTr(NumE));

    Result := NumE;

    DrvInfo.ID := 'AWF';
    DrvInfo.Sch := '';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Rage of Mages 2 .RES support ============================================= //
// -------------------------------------------------------------------------- //

type ROM2RES_Header = packed record
       ID: array[0..3] of char;       // &H31415926
       RootRelativeOffset: integer;
       RootSize: integer;
       Unknown3: integer;
       DirOffset: integer;
       DirSize: integer;
     end;
     ROM2RES_Index = packed record
       Unknown1: integer;
       Offset: integer;
       Size: integer;
       Flags: integer;       // DIR or File ?
       FileName: array[0..15] of char;
     end;

function ReadRageOfMages2RES_Aux(cdir: string; startoffset: integer; reloffset: integer; localNumE: integer): integer;
var ENT: ROM2RES_Index;
    disp : string;
    x: integer;
begin

  Result := 0;

  for x := 1 to localNumE do
  begin
    FileSeek(FHandle,startOffset+((RelOffset+x-1)*SizeOf(ROM2RES_Index)),0);
    FileRead(FHandle,ENT,SizeOf(ROM2RES_Index));
    if (ENT.Flags = 1) then
    begin
      disp := strip0(ent.FileName);
      inc(result,ReadRageOfMages2RES_Aux(cdir+disp+'\',startoffset,ENT.Offset,ENT.Size));
    end
    else
    begin
      inc(result);
      FSE_Add(cdir+strip0(ENT.FileName),ENT.Offset,ENT.Size,ENT.Unknown1,ENT.Flags);
    end;
  end;

//  ShowMessage(cdir+' = '+inttostr(result)+' files');

end;

function ReadRageOfMages2RES(): Integer;
var HDR: ROM2RES_Header;
    numE: integer;
    cdir : string;
begin

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, SizeOf(ROM2RES_Header));

    if (HDR.ID <> '&YA1') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'RoM2RES';
      ErrInfo.Games := 'Rage of Mages 2';
    end
    else
    begin
      cdir := '';

      NumE := ReadRageOfMages2RES_Aux(cdir,HDR.DirOffset,HDR.RootRelativeOffset, HDR.RootSize);

      //ShowMessage(IntTosTr(NumE));

      Result := NumE;

      DrvInfo.ID := 'RoM2RES';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// realMyst 3D DNI support ================================================== //
// -------------------------------------------------------------------------- //

type DNIHeader = packed record
       ID: array[0..3] of char;
       Version: integer; // &H100
       DIROffset: integer; // &H1C
       FTOffset: integer;
       NLOffset: integer;
       DataOffset: integer;
       FTOffsetA: integer;
     end;
     DNIDir = packed record
       Offset: integer;
       NumObj: integer;
     end;
     DNIFile = packed record
       OffsetName: integer;
       OffsetNameNext: integer;
       Length: integer;
       Offset: integer;
       CompressedLength: integer;
     end;

procedure DNIDirectory(cdir: string; coffset: integer; ftoffset:integer);
var DIR: DNIDir;
    FIL: DNIFile;
    cdir2, cdirp, nam: string;
    x, ObjOffset: integer;
begin

  FileSeek(FHandle, coffset,0);

  FileRead(FHandle,DIR,SizeOf(DNIDir));

  FileSeek(FHandle,DIR.Offset,0);

  cdir2 := strip0(Get0(Fhandle));
  cdirp := cdir + cdir2 + '\';
  if cdirp = '\' then
    cdirp := '';

  inc(coffset,8);

  for x := 1 to DIR.NumObj do
  begin
    FileSeek(FHandle,coffset,0);
    FileRead(FHandle, ObjOffset, 4);
    if ObjOffset < FTOffset then
      DNIDirectory(cdirp,ObjOffset,FTOffset)
    else
    begin
      FileSeek(FHandle,ObjOffset,0);
      FileRead(FHandle,FIL, SizeOf(DNIFile));
      FileSeek(FHandle,FIL.OffsetName,0);
      nam := strip0(get0(FHandle));
      Inc(DNISize);
      FSE_Add(cdir + nam,FIL.Offset, FIL.Length, FIL.CompressedLength, 0);
    end;
    Inc(coffset,4);
  end;

end;

function ReadRealMystDNI(src: string): Integer;
var HDR: DNIHeader;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, SizeOf(DNIHeader));

    if (HDR.ID <> 'Dirt') or (HDR.Version <> 65536) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'DNI';
      ErrInfo.Games := 'realMyst 3D';
    end
    else
    begin

      DNISize := 0;

      DNIDirectory('',HDR.DIROffset,HDR.FTOffset);
      //ShowMessage(IntTosTr(NumE));

      Result := DNISize;

      DrvInfo.ID := 'DNI';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := true;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Sin .SIN support ========================================================= //
// -------------------------------------------------------------------------- //

type SINHeader = packed record
        ID: array[1..4] of char;
        DirOffset: longword;
        DirNum: word;
     end;
     SINEntry = packed record
        Filename: array[1..120] of char;
        Offset: longword;
        Size: longword;
     end;

function ReadSinSIN(src: string): Integer;
var HDR: SINHeader;
    ENT: SINEntry;
    disp: string;
    NumE, x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, 10);

    if HDR.ID <> 'SPAK' then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'SIN';
      ErrInfo.Games := 'Sin';
    end
    else
    begin

      NumE := HDR.DirNum;
      FileSeek(FHandle,HDR.DirOffset,0);

      for x:= 1 to NumE do
      begin

        Per := ROund(((x / NumE)*100));
        SetPercent(Per);
        FileRead(Fhandle,ENT.Filename,120);
        FileRead(Fhandle,ENT.Offset,4);
        FileRead(Fhandle,ENT.Size,4);
        disp := Strip0(ENT.FileName);

        FSE_Add(disp,ENT.Offset,ENT.Size,0,0);
      end;

      Result := NumE;

      DrvInfo.ID := 'SIN';
      DrvInfo.Sch := '/';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Spellforce .PAK support ================================================== //
// -------------------------------------------------------------------------- //

type MFHeader = packed record
        VersionNum: integer;
        ID: array[0..23] of char;  // 'MASSIVE PAKFILE V 4.0'
        Unknown: array[0..43] of byte;
        Unknown2: integer;
        NbFatEntry: integer;
        Unknown3: integer;
        DataOffset: integer;
        FileSize: integer;
     end;
     MFEntry = packed record
        Size: integer;
        RelOffset: integer;
        NameOffset: integer;
        DirNameOffset: integer;
     end;

function ReadSpellforcePAK(): Integer;
var HDR: MFHeader;
    ENT: MFEntry;
    disp: string;
    x: integer;
    nameoffset: integer;
    HF: THandleStream;
    FAT: TMemoryStream;
begin

  FileSeek(Fhandle, 0, 0);
  FileRead(Fhandle, HDR, SizeOf(HDR));

  if (HDR.VersionNum <> 4) or (HDR.ID <> 'MASSIVE PAKFILE V 4.0'+#13+#10) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'MPF4';
    ErrInfo.Games := 'Spellforce';
  end
  else
  begin

    HF := THandleStream.Create(FHandle);
    FAT := TMemoryStream.Create;
    try
      FAT.CopyFrom(HF,HDR.NbFatEntry*16);
      FAT.Seek(0,0);
      nameoffset := 92+HDR.NbFatEntry*16;
      for x := 1 to HDR.NbFatEntry do
      begin
        FAT.Read(ENT,SizeOf(ENT));
        ENT.NameOffset := ENT.NameOffset and $FFFFFF;
        ENT.DirNameOffset := ENT.DirNameOffset and $FFFFFF;

        FileSeek(FHandle,ENT.NameOffset+nameoffset+2,0);
        disp := revstr(Strip0(Get0(FHandle)));

        FileSeek(FHandle,ENT.DirNameOffset+nameoffset,0);
        disp := revstr(Strip0(Get0(FHandle)))+'\'+disp;

        FSE_Add(disp,ENT.RelOffset+HDR.DataOffset,ENT.Size,0,0);
      end;

    finally
      FreeAndNil(HF);
      FreeAndNil(FAT);
    end;

    Result := HDR.NbFatEntry;

    DrvInfo.ID := 'MPF4';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// Star Crusader .PAK support =============================================== //
// -------------------------------------------------------------------------- //

function isStarCrusaderPAK(Offset, TotSize: integer): boolean;
var SaveOffset: integer;
    NumE: word;
    DirOffset: integer;
begin

  SaveOffset := FileSeek(FHandle,0,1);
  FileSeek(FHandle,Offset,0);
  FileRead(FHandle,NumE,2);
  FileRead(FHandle,DirOffset,4);

  result := ((DirOffset + NumE*12) <= TotSize);

  FileSeek(FHandle,SaveOffset,0);

end;

type PAKEntry = packed record
        Offset: longword;
        FileName: array[1..8] of Char;
     end;

function ReadStarCrusaderPAK(IsGL: Boolean): Integer;
var disp: string;
    NumE: word;
    x, Offset, OldOffset, TotSize: cardinal;
    ENT: PAKEntry;
begin

  TotSize := FileSeek(FHandle, 0,2);
  FileSeek(Fhandle, 0, 0);
  FileRead(Fhandle,NumE,2);
  FileRead(Fhandle,Offset,4);

  if ((Offset + NumE*12) > TotSize) then
  begin
    if (IsGL) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
    end;
    Result := -3;
    ErrInfo.Format := 'GL';
    ErrInfo.Games := 'Star Crusader';
  end
  else
  begin

    FileSeek(Fhandle, Offset, 0);
    OldOffset := Offset;

    for x := 1 to NumE do
    begin
      FileRead(Fhandle,ENT,12);
      if (x > 1) then
      begin
        if (IsGl and isStarCrusaderPAK(OldOffset,ENT.Offset-OldOffset)) then
        begin
          disp := ChangeFileExt(disp,'.gl');
        end;
        FSE_Add(disp,OldOffset,ENT.Offset-OldOffset,0,0);
      end;
      OldOffset := ENT.Offset;
      if (IsGL) then
        disp := strip0(ENT.FileName)
      else
        disp := strip0(ENT.FileName)+'.wav';
      if TotFSize < Offset then
        break;
    end;
    FSE_Add(disp,OldOffset,Offset-OldOffset,0,0);

    if TotFSize < Offset then
    begin

      FSE_free;
      FileClose(FHandle);
      FHandle := 0;
      result := -3;
      ErrInfo.Format := 'GL';
      ErrInfo.Games := 'Star Crusader';

    end
    else
    begin

      result := NumE;

      if (IsGL) then
        DrvInfo.ID := 'SCPAK'
      else
        DrvInfo.ID := 'SCGL';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end;

end;

// -------------------------------------------------------------------------- //
// Sinking Island/L'Ile Noyée .OPK support ================================== //
// -------------------------------------------------------------------------- //

// Very easy format:
//   Header (see below OPKHeader structure)
//   N times: (N times entries as stated in the Header)
//     Entry header
//     Null terminated string representing filename
//     Padding (compute it with Entry header "EntrySize" and substracting the size of entry header and null terminated string)
//   Data

type OPKHeader = packed record
       ID: array[0..3] of char;           // 'PAK '
       NumEntries: integer;
       SizeOfDir: integer;                // SizeOf(OPKHeader) + OPKHeader.SizeOfDir = Start of Data
       Unknown: integer;                  // Always 0?
     end;
     OPKEntry = packed record
       Offset: integer;                   // Absolute offset
       Size: integer;
       EntrySizeNoFilename: integer;      // Size of the entry in directory (without filename) --> Always 32?
       EntrySize: integer;                // Size of the entry in directory (filename included)
       FileTime: Int64;                   // Date/File of entry (Windows FiLETIME structure)
     end;

function ReadSinkingIslandOPK(src: string): Integer;
var HDR: OPKHeader;
    ENT: OPKEntry;
    disp: string;
    x, per, oldper: integer;
    rest: longword;
begin

  // Open the file for reading
  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    // Read the header
    FileRead(Fhandle, HDR, SizeOf(OPKHeader));

    // If the header ID is not the one expected
    // Execution stops with error -3
    if HDR.ID <> 'PAK ' then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'OPK';
      ErrInfo.Games := 'Sinking Island, L''Ile Noyée';
    end
    else
    begin

      // Progress indicator
      OldPer := 0;

      // For each entry in the file
      for x:= 1 to HDR.NumEntries do
      begin

        // Calculates current progress
        Per := ROund(((x / HDR.NumEntries)*100));
        if (Per > (OldPer+1)) then
        begin
          SetPercent(Per);
          OldPer := Per;
        end;

        // Read the file entry
        FileRead(Fhandle, ENT, SizeOf(OPKEntry));

        // Retrieve the filename
        disp := get0(Fhandle);

        // Calculates padding size to skip for next entry
        rest := ENT.EntrySize - (length(disp) + SizeOf(OPKEntry));

        // If padding is more than 0 bytes we skip that many bytes
        if rest > 0 then
          FileSeek(Fhandle,rest,1);

        // Add entry to the list
        FSE_Add(Strip0(disp),ENT.Offset,ENT.Size,0,0);

      end;

      // Entries found (return Header info)
      Result := HDR.NumEntries;

      // Driver ID is OPK
      // Directories parsing is '\'
      // Extraction is dealed by Dragon UnPACKer 
      DrvInfo.ID := 'OPK';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// South Park: The Stick of Truth .OAF support ============================== //
// -------------------------------------------------------------------------- //

type OAFHeader = packed record
       ID: array[0..3] of char;  // 'OAF!'
       Unknown1: cardinal;
       Unknown2: cardinal;
       NameBlockOffset: int64;
       NumEntries: cardinal;
     end;
//   Name: Get8 (0x00 terminated)
type OAFEntry = packed record
       Unknown1: cardinal;          // Some sort of hash
       Offset: int64;
       Size: int64;
     end;

function ReadSouthParkTheStickOfTruthOAF(src: string): Integer;
var HDR: OAFHeader;
    ENT: OAFEntry;
    disp: string;
    x, per, oldper: integer;
    rest: longword;
    indexstm, namestm: TMemoryStream;
    srcstm: THandleStream;
begin

  // Open the file for reading
  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);
  TotFSize := FileSeek(Fhandle,0,2);

  if FHandle > 0 then
  begin

    // Read the header
    FileSeek(Fhandle,0,0);
    FileRead(Fhandle, HDR, SizeOf(OAFHeader));

    // If the header ID is not the one expected
    // Execution stops with error -3
    if (HDR.ID <> 'OAF!') or (HDR.NameBlockOffset > TotFSize) or (((HDR.NumEntries*SizeOf(OAFEntry))+SizeOf(OAFHeader)) > TotFSize) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'OAF';
      ErrInfo.Games := 'South Park: The Stick of Truth';
    end
    else
    begin

      // Progress indicator
      OldPer := 0;

      indexstm := TMemoryStream.Create;
      namestm := TMemoryStream.Create;
      srcstm := THandleStream.Create(Fhandle);

      try

        // Read and buffer to memory the indexes
        indexstm.CopyFrom(srcstm,HDR.NumEntries*SizeOf(OAFEntry));
        indexstm.Seek(0,0);

        // Read and buffer to memory the filenames
        srcstm.Seek(HDR.NameBlockOffset,0);
        namestm.CopyFrom(srcstm,TotFSize-HDR.NameBlockOffset);
        namestm.Seek(0,0);

        // For each entry in the file
        for x:= 1 to HDR.NumEntries do
        begin

          // Calculates current progress
          Per := ROund(((x / HDR.NumEntries)*100));
          if (Per > (OldPer+1)) then
          begin
            SetPercent(Per);
            OldPer := Per;
          end;

          // Read the file entry
          indexstm.Read(ENT,SizeOf(OAFEntry));

          // Retrieve the filename
          disp := strip0(get0(namestm));

          // Add entry to the list
          FSE_Add(disp,ENT.Offset,ENT.Size,0,0);

        end;

      finally
        FreeAndNil(indexstm);
        FreeAndNil(namestm);
        FreeAndNil(srcstm);
      end;

      // Entries found (return Header info)
      Result := HDR.NumEntries;

      // Driver ID is OAF
      // Directories parsing is '\'
      // Extraction is dealed by Dragon UnPACKer
      DrvInfo.ID := 'OAF';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Star Wars Starfighter .PAK support ======================================= //
// -------------------------------------------------------------------------- //

const StarWarsStarfighterMagicID = 'Europa Packfile';
type EuropaPackfile_Header = packed record
       ID: array[0..14] of char;  // 'Europa Packfile'
       ID0: byte;
       Unknown1: integer;
       Unknown2: byte;
       OffsetToEntriesBlock: integer;
       SizeOfEntriesBlock: integer;
       NumberOfEntries: integer;
     end;
//   Name: Get8 (0x00 terminated)
type EuropaPackfile_Entry = packed record
       Offset: integer;
       Size: integer;
       Unknown: integer;
     end;

function ReadStarWarsStarfighterPAK: Integer;
var HDR: EuropaPackfile_Header;
    ENT: EuropaPackfile_Entry;
    // The buffer will hold the entries block
    EntriesBlock: TMemoryStream;
    // In order to work with the TMemoryStreams the source file is to be wrapped
    // into a THandleStream.
    FileSource: THandleStream;
    x: integer;
    disp: string;
begin

  // Wrap the source file in the THandleStream
  FileSource := THandleStream.Create(FHandle);
  FileSource.Seek(0,soFromBeginning);

  // Create the TMemoryStream buffer
  EntriesBlock := TMemoryStream.Create;

  // try finally to always free the 3 objects, if something goes wrong
  try

    // Read the header
    FileSource.ReadBuffer(HDR, SizeOf(EuropaPackfile_Header));

    if (HDR.ID <> StarWarsStarfighterMagicID)
    or (HDR.ID0 <> 0)
    or ((HDR.OffsetToEntriesBlock+HDR.SizeOfEntriesBlock) > FileSource.Size) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'Europa';
      ErrInfo.Games := 'Star Wars Starfighter';
    end
    else
    begin

      // Seek to entries block
      FileSource.Seek(HDR.OffsetToEntriesBlock,soBeginning);

      // Copy the block to the buffer
      EntriesBlock.CopyFrom(FileSource,HDR.SizeOfEntriesBlock);
      EntriesBlock.Seek(0,soFromBeginning);

      // Parse the entries
      for x := 1 to HDR.NumberOfEntries do
      begin

        // Retrieve filename from first buffer
        disp := strip0(get8(EntriesBlock));

        // Retrieve the rest of the entry
        EntriesBlock.ReadBuffer(ENT,SizeOf(EuropaPackfile_Entry));

        // Add the entry to FSE
        FSE_Add(disp,ENT.Offset,ENT.Size,ENT.Unknown,0);

      end;

      // Retrieved NumE entries for the format
      Result := HDR.NumberOfEntries;
      DrvInfo.ID := 'Europa';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;
    end;
  finally
    FreeAndNil(FileSource);
    FreeAndNil(EntriesBlock);
  end;

end;

// -------------------------------------------------------------------------- //
// Starsiege: Tribes .VOL support =========================================== //
// -------------------------------------------------------------------------- //

// Completely coded thanks to the information found on:
// http://wiki.xentax.com/index.php?title=Star_Siege

// Index entry structure
type PVOL_Entry = packed record
       Unknown1Null: Integer;
       Unknown2FileID: Integer;
       FileOffset: Integer;
       FileSize: Integer;
       Unknown3Null: Byte;
     end;

function ReadStarsiegeTribesVOL: Integer;
var ID: array[0..3] of char;
    // The two buffers will hold the filenames directory and the offset directory
    BufferNam, BufferIdx: TMemoryStream;
    // In order to work with the TMemoryStreams the source file is to be wrapped
    // into a THandleStream.
    FileSource: THandleStream;
    ENT: PVOL_Entry;
    MaxOffset, Offset, Size: Integer;
    NumE,x: integer;
    disp: string;
begin

  // Wrap the source file in the THandleStream
  FileSource := THandleStream.Create(FHandle);

  // Create the two TMemoryStream buffers
  BufferNam := TMemoryStream.Create;
  BufferIdx := TMemoryStream.Create;

  // try finally to always free the 3 objects, if something goes wrong
  try

    // Maximum possible offset is... End of file! :)
    MaxOffset := FileSource.Seek(0,sofromEnd);

    // Seek back to the beginning of file
    FileSource.Seek(0,soBeginning);

    // Read the ID (4 bytes)
    FileSource.Read(ID,4);

    // Read the offset to directory
    FileSource.Read(Offset,4);

    // Sanity checks:
    //   ID must be 'PVOL'
    //   Offset + 8 cannot be bigger than MaxOffset
    if (ID <> 'PVOL') or ((Offset + 8) > MaxOffset) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'PVOL';
      ErrInfo.Games := 'Starsiege: Tribes';
    end
    else
    begin

      // Seek to directory
      FileSource.Seek(Offset,soBeginning);

      // Read the block ID (4 bytes)
      FileSource.Read(ID,4);

      // Read the size of the filename directory
      FileSource.Read(Size,4);

      // Sanity checks:
      //   ID must be 'vols'
      //   Offset + 8 + Size cannot be bigger than MaxOffset
      if (ID <> 'vols') or ((Offset + 8 + Size) > MaxOffset) then
      begin
        FileClose(Fhandle);
        FHandle := 0;
        Result := -3;
        ErrInfo.Format := 'PVOL';
        ErrInfo.Games := 'Starsiege: Tribes';
      end
      else
      begin

        // Load the full directory filename in the first buffer
        BufferNam.CopyFrom(FileSource,Size);
        BufferNam.Seek(0,soBeginning);

        // Next offset is at Offset plus:
        //      8 bytes
        //   Size bytes (directory size)
        //      1 byte (Only if Size is not a multiple of 2)
        Inc(Offset,8);
        Inc(Offset,Size);
        Inc(Offset,Size mod 2);

        // Go to that new offset
        FileSource.Seek(Offset,soBeginning);

        // Read the block ID
        FileSource.Read(ID,4);

        // Read the block size
        FileSource.Read(Size,4);

        // Sanity checks:
        //   ID must be 'voli'
        //   Offset + 8 + Size cannot be bigger than MaxOffset
        if (ID <> 'voli') or ((Offset + 8 + Size) > MaxOffset) then
        begin
          FileClose(Fhandle);
          FHandle := 0;
          Result := -3;
          ErrInfo.Format := 'PVOL';
          ErrInfo.Games := 'Starsiege: Tribes';
        end
        else
        begin

          // Load the full directory entries in the second buffer
          BufferIdx.CopyFrom(FileSource,Size);
          BufferIdx.Seek(0,soBeginning);

          // Calculate the number of entries
          NumE := Size div SizeOf(PVOL_Entry);

          // Parse the entries
          for x := 1 to NumE do
          begin

            // Retrieve filename from first buffer
            disp := strip0(get0(BufferNam));

            // Retrieve Offset & Size from second buffer
            BufferIdx.Read(ENT,SizeOf(PVOL_Entry));

            // Add the entry to FSE
            FSE_Add(disp,ENT.FileOffset+8,ENT.FileSize,ENT.Unknown2FileID,0);

          end;

          // Retrieved NumE entries for the format
          Result := NumE;
          DrvInfo.ID := 'PVOL';
          DrvInfo.Sch := '';
          DrvInfo.FileHandle := FHandle;
          DrvInfo.ExtractInternal := False;
        end;
      end;
    end;
  finally
    FreeAndNil(FileSource);
    FreeAndNil(BufferNam);
    FreeAndNil(BufferIdx);
  end;

end;

// -------------------------------------------------------------------------- //
// Terminal Velocity .POD support =========================================== //
// -------------------------------------------------------------------------- //

type PODHeader = packed record
       Dirnum: integer;
       ID: array[0..79] of char;
     end;
     PODEntry = packed record
       Filename: array[0..31] of char;
       Size: integer;
       Offset: integer;
     end;

function ReadTerminalVelocityPOD(): Integer;
var HDR: PODHeader;
    ENT: PODEntry;
    disp: string;
    NumE, x: integer;
    EndOfHeaderOffset, SanityCheck, FSize: Int64;
begin

  if FHandle > 0 then
  begin
    FSize := FileSeek(Fhandle,0,2);
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, 84);

    EndOfHeaderOffset := HDR.Dirnum;
    EndOfHeaderOffset := EndOfHeaderOffset * SizeOf(PODEntry);

    if (HDR.Dirnum < 1) or (EndOfHeaderOffset > FSize) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadTerminalVelocityPOD := -3;
      ErrInfo.Format := 'POD';
      ErrInfo.Games := 'Terminal Velocity';
    end
    else
    begin

      NumE := HDR.DirNum;

      for x:= 1 to NumE do
      begin

        Per := ROund(((x / NumE)*100));
        SetPercent(Per);

        FileRead(Fhandle,ENT,40);

        SanityCheck := ENT.Offset;
        Inc(SanityCheck,ENT.Size);
        if (ENT.Offset < EndOfHeaderOffset) or (ENT.Size < 0) or (SanityCheck > FSize) then
        begin
          FileClose(Fhandle);
          FHandle := 0;
          ReadTerminalVelocityPOD := -3;
          ErrInfo.Format := 'POD';
          ErrInfo.Games := 'Terminal Velocity';
          exit;
        end;

        disp := Strip0(ENT.FileName);

        FSE_Add(disp,ENT.Offset,ENT.Size,0,0);

      end;

      Result := NumE;

      DrvInfo.ID := 'POD';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// The 7th Guest .GJD support =============================================== //
// -------------------------------------------------------------------------- //

type GJD_Entry_7 = packed record       // 20 Bytes
    Filename: array[1..12] of char;
    Offset: longword;
    Size: longword;
  end;

function Read7thGuestGJD(src, comprl: string): Integer;
var NumE: integer;
    x, totent: integer;
    ENT: GJD_Entry_7;
    entrylist: TStream;
begin

  FHandle := FileOpen(src,fmOpenRead);

  if FHandle > 0 then
  begin

    TotFSize := FileSeek(FHandle,0,2);

    // Open compagnon file
    entrylist := TFileStream.Create(comprl,fmOpenRead or fmShareDenyWrite);

    // Total number of entries is the entrylist file size divided by 20
    totent := entrylist.Size div 20;
    entrylist.Position := 0;
    NumE := 0;

    // Go through all entries and only select the one related to the found index
    for x := 1 to totent do
    begin
      entrylist.ReadBuffer(ENT,20);
      if (ENT.Offset + ENT.Size) <= TotFSize then
      begin
        Inc(NumE);
        FSE_Add(Strip0(ENT.Filename),ENT.Offset,ENT.Size,0,0);
      end;
      SetPercent(round((x / totent)*100));
    end;
    freeandnil(entrylist);

    DrvInfo.ID := 'GJD';
    DrvInfo.Sch := '';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

    result := NumE;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// The 11th Hour .GJD support =============================================== //
// -------------------------------------------------------------------------- //

// Data file is expected in plugin's folder with following name:
const
    D11D_DATA_FILENAME : string = 'drv_default_d11d.dat';

type GJD_Entry = packed record         // 32 Bytes
    Unknown: integer;
    Offset: longword;
    Size: longword;
    Index: word;
    Filename: array[1..18] of char;
  end;

// Data file can be created from any The 11th Hour CD-Rom using d11dc tool
// with files from the CD (path relative to root):
//   \GROOVIE\GJD.GJD
//   \GROOVIE\DIR.RL

// This function checks the data file is correct (header, size and CRC-32 of
// the payload) and returns both files (DIR.RL = fileindex and GJD.GJD = entrylist)
// as TMemoryStreams.
// Supports uncompressed & Zlib compressed payload 
function get11thHourData(retrieveData: boolean; var fileindex, entrylist: TStream): boolean;
var HDR: D11D_Header;
    D11Dstm: TFileStream;
    testcrc: longint;
    decompressorStm: TDecompressionStream;
    tmpStm: TMemoryStream;
begin

  result := FileExists(CurPath+D11D_DATA_FILENAME);

  if result then
  begin
    result := false;
    D11Dstm := TFileStream.Create(CurPath+D11D_DATA_FILENAME,fmOpenRead or fmShareDenyWrite);
    try
      if (D11Dstm.Size >= SizeOf(HDR)) then
      begin
        D11Dstm.ReadBuffer(HDR,sizeof(HDR));
        if (HDR.ID = 'D11D') and (HDR.EOF = 25) and (HDR.Version = D11D_Version)
        and ((HDR.Flags and D11D_FLAG_CRC) = D11D_FLAG_CRC)
        and (D11Dstm.Size = (SizeOf(HDR) + HDR.CompressedSize)) then
        begin
          tmpStm := TMemoryStream.Create;
          tmpStm.CopyFrom(D11Dstm,HDR.CompressedSize);
          tmpStm.Position := 0;
          testcrc := GetStmCRC32(tmpStm,HDR.CompressedSize);
          result := testcrc = HDR.CRC32;
          if (retrieveData) then
          begin
            tmpStm.Position := 0;
            fileindex := TMemoryStream.Create;
            entrylist := TMemoryStream.Create;
            if ((HDR.Flags and D11D_FLAG_ZLIB) = D11D_FLAG_ZLIB) then
            begin
              decompressorStm := TDecompressionStream.Create(tmpStm);
              try
                fileindex.CopyFrom(decompressorStm,HDR.SeparatorOffset);
                entrylist.CopyFrom(decompressorStm,HDR.UncompressedSize - HDR.SeparatorOffset);
              finally
                FreeAndNil(decompressorStm);
              end;
            end
            else
            begin
              fileindex.CopyFrom(tmpStm,HDR.SeparatorOffset);
              entrylist.CopyFrom(tmpStm,HDR.UncompressedSize - HDR.SeparatorOffset);
            end;
          end;
          freeandnil(tmpStm);
        end;
      end;
    finally
      FreeAndNil(D11Dstm);
    end;
  end;

end;

// Wrapper to the data retrieval to just check if the data file is present and
// correct (header, size & CRC-32)
function get11thHourStatus(): Boolean;
var test1, test2: tstream;
begin

  result := get11thHourData(false,test1,test2);

end;

function Read11thHourGJD(src: string): Integer;
var NumE, infil: integer;
    x, totent, curidx: integer;
    ENT: GJD_Entry;
    filelist, entrylist: TStream;
    fnlist: TStringList;
    fnliststring, filename, srcfilename: string;
begin

  FHandle := FileOpen(src,fmOpenRead);

  if FHandle > 0 then
  begin

    // We can only continue is the data file is correct & loaded
    if (get11thHourData(true,filelist,entrylist)) then
    begin

      // Total number of entries is the entrylist file size divided by 32
      totent := entrylist.Size div 32;
      entrylist.Position := 0;
      NumE := 0;

      // Explode the file list into a StringList
      filelist.Position := 0;
      SetLength(fnliststring,filelist.size);
      filelist.ReadBuffer(fnliststring[1],filelist.Size);
      FreeAndNil(Filelist);
      fnlist := TStringList.Create;
      fnlist.Delimiter := #10;
      fnlist.DelimitedText := fnliststring;

      // Go through the StringList to retrieve the filename index
      infil := -1;
      curidx := 0;
      srcfilename := ExtractFilename(src);
      while (infil = -1) and (curidx < fnlist.Count) do
      begin
        filename := fnlist.Strings[curidx];
        if stricomp(Pchar(filename),PChar(srcfilename)) = 0 then
          infil := strtoint(fnlist.Strings[curidx+1]);
        inc(curidx,2);
      end;
      freeandnil(fnlist);

      // Go through all entries and only select the one related to the found index
      for x := 1 to totent do
      begin
        entrylist.ReadBuffer(ENT,32);
        if (ENT.Index = infil) then
        begin
          Inc(NumE);
          FSE_Add(Strip0(ENT.Filename),ENT.Offset,ENT.Size,ENT.Unknown,0);
        end;
        SetPercent(round((x / totent)*100));
      end;
      freeandnil(entrylist);

      DrvInfo.ID := '11TH';
      DrvInfo.Sch := '';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

      result := NumE;

    end
    else
      Result := -2;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// The Elder Scrolls IV: Oblivion .BSA support ============================== //
// -------------------------------------------------------------------------- //

type TES4BSAHeader = packed record
        Field: array[0..3] of char; // 'BSA' + #0
        Version: cardinal;          // 103
        Offset: cardinal;
        ArchiveFlags: integer;      // 0x01 Archive has names for directories
                                    // 0x02 Archive has names for files
                                    // 0x04 Files are by default compressed
        FolderCount: cardinal;
        FileCount: cardinal;
        TotalFolderNameLength: cardinal;
        TotalFileNameLength: cardinal;
        FileFlags: cardinal;
     end;
     TES4BSAFolderRecord = packed record
        NameHash: int64;
        Count: cardinal;            // Amount of files in this folder
        Offset: cardinal;           // Offset to Folder name + File Records
                                    // (To get actual offset from start of file: Offset - TES4BSAHeader.TotalFileNameLength)
     end;
     TES4BSAFileRecord = packed record
        NameHash: int64;
        Size: cardinal;
        Offset: cardinal;
     end;
const TES4BSA_FILECOMPRESSED: cardinal = $40000000;
      TES4BSA_SIZEMASK: cardinal = $3FFFFFFF;

function ReadTheElderScrolls4OblivionBSA(src: string): integer;
var HDR: TES4BSAHeader;
    FolderENT: TES4BSAFolderRecord;
    FileENT: TES4BSAFileRecord;
    curDir: string;
    NumE, x, y, OffsetToNames, originalsize, perc, oldperc: cardinal;
    DefaultCompressed, FileCompressed: boolean;
    FileNames: TStringList;
    Buffer: TMemoryStream;
    SHandle: THandleStream;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, Sizeof(TES4BSAHeader));

    if (LeftStr(HDR.Field,3) <> 'BSA') or (HDR.Field[3] <> #0) or (HDR.Version <> 103) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'BSA';
      ErrInfo.Games := 'The Elder Scrolls 4: Oblivion';
    end
    else
    begin

      NumE := 0;

      DefaultCompressed := (HDR.ArchiveFlags AND 4) = 4;

      OffsetToNames := HDR.Offset + HDR.FolderCount * (SizeOf(TES4BSAFolderRecord)+1) + HDR.FileCount * Sizeof(TES4BSAFileRecord) + HDR.TotalFolderNameLength;
//      FileSeek(FHandle,OffsetToNames,0);

      FileNames := TStringList.Create;

      try

        // Speed up filename reading
        // 1. Reads all block to memory
        Buffer := TMemoryStream.Create;
        SHandle := THandleStream.Create(FHandle);
        SHandle.Seek(OffsetToNames,0);
        Buffer.CopyFrom(SHandle,HDR.TotalFileNameLength);
        Buffer.Seek(0,0);
        FreeAndNil(SHandle);

        // 2. Parse filenames to the TStringList
        for x := 1 to HDR.FileCount do
        begin
          FileNames.Add(strip0(Get0(Buffer)));
        end;

        // 3. Free the buffer as we don't need it anymore
        FreeAndNil(Buffer);

        oldperc := 0;

        // Go throw the Folder records
        for x := 1 to HDR.FolderCount do
        begin

          // We seek each time to the offset of the folder record
          FileSeek(FHandle,HDR.Offset+(x-1)*SizeOf(TES4BSAFolderRecord),0);
          // We read the Folder Record
          FileRead(FHandle,FolderENT,Sizeof(TES4BSAFolderRecord));
          // We go read the Folder name
          FileSeek(FHandle,FolderENT.Offset - HdR.TotalFileNameLength,0);
          curDir := strip0(get8(FHandle));

          // We go throw the File records of the folder
          for y := 1 to FolderENT.Count do
          begin

            // We seek each time to the offset of the file record
            FileSeek(FHandle,FolderENT.Offset - HdR.TotalFileNameLength +((y-1)*SizeOf(TES4BSAFileRecord))+Length(curDir)+2,0);
            // We read the file record
            FileRead(FHandle,FileENT,Sizeof(TES4BSAFileRecord));
            // We verify the compression flag (bit 30 of the file size)
            FileCompressed := FileENT.Size AND TES4BSA_FILECOMPRESSED = TES4BSA_FILECOMPRESSED;
            // We remove bit 30-32 from size
            FileENT.Size := FileENT.Size AND TES4BSA_SIZEMASK;

            // If the archive is compressed and the file compression flag is NOT set
            // of if the archive is not compressed and the file compression flag is set
            // that means the file data is compressed
            if (DefaultCompressed and Not(FileCompressed))
            or (Not(DefaultCompressed) and FileCompressed) then
            begin
              // We go to the file data offset
              FileSeek(FHandle,FileENT.Offset,0);
              // We read the original size of the file
              FileRead(FHandle,OriginalSize,4);
              // We add to FSE the file we just found, specifying it is compressed (DataX = 1 and DataY is compressed size)
              FSE_Add(curDir+'\'+FileNames.Strings[NumE],FileENT.Offset+4,OriginalSize,1,FileENT.Size-4)
            end
            else
              // If the file is not compressed we only add it to FSE, specifying it is NOT compressed (DataX = 0)
              FSE_Add(curDir+'\'+FileNames.Strings[NumE],FileENT.Offset,FileENT.Size,0,0);

            Inc(NumE);

            // Progress display (can be slow to read throw a compressed archive
            perc := round((NumE / HDR.FileCount)*100);
            if (perc = oldperc + 5) then
            begin
              SetPercent(perc);
              OldPerc := perc;
            end;

          end;

        end;

      finally
        FreeAndNil(FileNames);
      end;

      Result := NumE;

      // Driver ID is BSA, directories are using \ in their names
      // and we need to handle extraction in the plugin because of compression
      DrvInfo.ID := 'BSA';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// The Fifth Element .MRC support =========================================== //
// -------------------------------------------------------------------------- //
// This is a standard RIFF file with blocks (and sub blocks).
// The type of "RIFF" is "mmRC" (position 8-11).
// The block "FInf" is only 1 longint large with value 1 (unknown purpose)
// The blocks "LIST" looks like RIFF files themselves, they have the same
//   structure and contains sub blocks
//    There are 2 types of "LIST" blocks:
//      "FSys" which contains:
//             "DLst" - The directory list
//             "FLst" - The file list
//             "NLst" - The name list
//      "FSto" which contains "FILE" blocks (the content of the files)

type RIFF_Header = packed record
       ID: array[0..3] of char;
       Size: integer;
       ID2: array[0..3] of char;
     end;
     RIFF_Block = packed record
       ID: array[0..3] of char;
       Size: integer;
     end;
     MRC_FLstEntry = packed record
       RelNameOffset: integer;
       Size: integer;
       RelOffset: Integer;
       Empty: Integer;     // Always 0?
     end;
     MRC_DLstEntry = packed record
       RelDirNameOffset: integer;
       NumSubDirs: integer;
       StartDirNum: integer;
       NumEntries: integer;
       StartFileNum: integer;
     end;
     MRC_DirList = record
       StartDirNum: Integer;
       EndDirNum: Integer;
       Name: String;
       StartFileNum: Integer;
       EndFileNum: Integer;
     end;

function ReadTheFifthElementMRC(): Integer;
var HDR: RIFF_Header;
    BLK,SubBLK: RIFF_Block;
    ID: array[0..3] of char;
    FLstENT: MRC_FLstEntry;
    DLstENT: MRC_DLstEntry;
    DirList: array of MRC_DirList;
    TotSize, check, nextOffset, nextSubOffset, FStoOffset: Int64;
    NumE, NumD, x, y: Integer;
    handle_stm: THandleStream;
    DLstBuffer, NLstBuffer, FLstBuffer: TMemoryStream;
    EName: String;
begin

  TotSize := FileSeek(Fhandle, 0, soFromEnd);
  FileSeek(Fhandle,0,0);
  FileRead(FHandle, HDR, SizeOf(RIFF_Header));

  // Some verifications of the header to be sure it is an .MRC file from The Fifth Element
  if (HDR.ID <> 'RIFF') or (HDR.ID2 <> 'mmRC') or (HDR.Size <> (TotSize-8)) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'mmRC';
    ErrInfo.Games := 'The Fifth Element';
  end
  else
  begin

    // Create a HandleStream from the source file
    handle_stm := THandleStream.Create(Fhandle);

    // Create memory streams to buffer Directory/File/Names sub blocks
    DLstBuffer := TMemoryStream.Create;
    FLstBuffer := TMemoryStream.Create;
    NLstBuffer := TMemoryStream.Create;

    FStoOffset := 0;

    // Try/Finally to free all streams objects at the end
    try

      // Read all blocks in RIFF
      repeat

        // Read the block header
        handle_stm.Read(BLK,SizeOf(RIFF_Block));

        // Next block offset calculation
        nextOffset := handle_stm.position + BLK.Size;

        // Sanity check: If current block size is less than 0 then we have a
        // problem
        if BLK.Size < 0 then
        begin
          FileClose(Fhandle);
          FHandle := 0;
          Result := -3;
          ErrInfo.Format := 'mmRC';
          ErrInfo.Games := 'The Fifth Element';
          Exit;
        end;

        // If the block ID is LIST
        if BLK.ID = 'LIST' then
        begin

          // Read the sub ID of the LIST block
          handle_stm.Read(ID,4);

          // Index sub block
          if ID = 'FSys' then
          begin

            // Go through all FSys sub blocks
            repeat

              // Read the sub block header
              handle_stm.Read(SubBLK,SizeOf(RIFF_Block));

              // Calculate offset to next sub block
              nextSubOffset := handle_stm.position + SubBLK.Size;

              // For each sub block type, buffer it to memory
              if SubBLK.ID = 'DLst' then
                DLstBuffer.CopyFrom(handle_stm,SubBLK.Size)
              else if SubBLK.ID = 'FLst' then
                FLstBuffer.CopyFrom(handle_stm,SubBLK.Size)
              else if SubBLK.ID = 'NLst' then
                NLstBuffer.CopyFrom(handle_stm,SubBLK.Size)
              else
              // Any other sub block type means we are reading a file of another format, therefore we quit
              begin
                FileClose(Fhandle);
                FHandle := 0;
                Result := -3;
                ErrInfo.Format := 'mmRC';
                ErrInfo.Games := 'The Fifth Element';
                Exit;
              end;

              // Move to end of sub block
              check := handle_stm.Seek(nextSubOffset,soBeginning);

            until (check <> nextSubOffset) or (handle_stm.Position >= nextOffset);

          end
          // Content sub block
          else if ID = 'FSto' then
            FStoOffset := handle_stm.Position

          // Any other sub block type means we are reading a file of another format, therefore we quit
          else
          begin
            FileClose(Fhandle);
            FHandle := 0;
            Result := -3;
            ErrInfo.Format := 'mmRC';
            ErrInfo.Games := 'The Fifth Element';
            Exit;
          end;

        end;

        // Move to end of block
        check := handle_stm.Seek(nextOffset,soBeginning);

      until (check <> nextOffset) or (handle_stm.Position >= TotSize);

      // If the content offset was found and all needed lists are buffered
      if (FStoOffset > 0) and (DLstBuffer.Size > 0) and (FLstBuffer.Size > 0) and (NLstBuffer.Size > 0) then
      begin

        // Verify the size of the DLstbuffer is a multiple of 20 (size of 1 entry)
        if (DLstBuffer.Size mod 20) <> 0 then
        begin
          FileClose(Fhandle);
          FHandle := 0;
          Result := -3;
          ErrInfo.Format := 'mmRC';
          ErrInfo.Games := 'The Fifth Element';
          Exit;
        end;

        // Calculate the number of directories
        NumD := DLstBuffer.Size div 20;

        // Size the DirList array
        SetLength(DirList,NumD);

        DLstBuffer.Seek(0,soBeginning);

        // For each directory entry
        for x := 0 to NumD-1 do
        begin
          // Read entries values
          DLstBuffer.Read(DLstENT,SizeOf(MRC_DLstEntry));
          // Seek to filename in buffer
          NLstBuffer.Seek(DLstENT.RelDirNameOffset,soBeginning);
          // Add entry
          DirList[x].Name := Strip0(get0(NLstBuffer));
          // This directory has following files as children
          DirList[x].StartFileNum := DLstENT.StartFileNum+1;
          DirList[x].EndFileNum := DLstENT.StartFileNum + DLstENT.NumEntries;
          // This directory is the parent of following directories
          DirList[x].StartDirNum := DLstENT.StartDirNum;
          DirList[x].EndDirNum := DLstENT.StartDirNum+DLstENT.NumSubDirs-1;
        end;

        // Expand directories (parent/child names aggregation)
        for x := 0 to NumD-1 do
          if DirList[x].StartDirNum < DirList[x].EndDirNum then
          begin
            for y := DirList[x].StartDirNum to DirList[x].EndDirNum do
              DirList[y].Name := DirList[x].Name + '\' + DirList[y].Name;
          end;

        // Verify the size of the FLstbuffer is a multiple of 16 (size of 1 entry)
        if (FLstBuffer.Size mod 16) <> 0 then
        begin
          FileClose(Fhandle);
          FHandle := 0;
          Result := -3;
          ErrInfo.Format := 'mmRC';
          ErrInfo.Games := 'The Fifth Element';
          Exit;
        end;

        // Calculate the number of entries
        NumE := FLstBuffer.Size div 16;

        FLstBuffer.Seek(0,soBeginning);

        // For each entry
        for x := 1 to NumE do
        begin
          // Read entries values
          FLstBuffer.Read(FLstENT,SizeOf(MRC_FLstEntry));
          // Seek to filename in buffer
          NLstBuffer.Seek(FLstENT.RelNameOffset,soBeginning);
          EName := '';
          for y := 0 to NumD-1 do
            if (DirList[y].StartFileNum <= x) and (DirList[y].EndFileNum >= x) then
            begin
              EName := DirList[y].Name+'\';
              break;
            end;
          EName := EName + Strip0(get0(NLstBuffer));
          // Add entry
          FSE_Add(EName,FLstENT.RelOffset+FStoOffset,FLstENT.Size,0,0);
        end;

        result := NumE;

      end
      // Info is missing, we quit
      else
      begin
        FileClose(Fhandle);
        FHandle := 0;
        Result := -3;
        ErrInfo.Format := 'mmRC';
        ErrInfo.Games := 'The Fifth Element';
        Exit;
      end;

    finally

      FreeAndNil(handle_stm);
      FreeAndNil(DLstBuffer);
      FreeAndNil(FLstBuffer);
      FreeAndNil(NLstBuffer);

    end;

    DrvInfo.ID := 'mmRC';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

// -------------------------------------------------------------------------- //
// The Movies .PAK support ================================================== //
// -------------------------------------------------------------------------- //

type TMPAK_Header = packed record
       ID: integer;            // 0x05 00 00 00
       DataOffset: Integer;
       Unknown1: integer;
       NumEntries: Integer;
       DirTableNum: Integer;
       DirNum: Integer;
       DirSize: Integer;
       Unknown5: Integer;     // Always Null ?
       Unknown6: Integer;     // Always Null ?
       Unknown7: Integer;     // Always Null ?
       Unknown8: Integer;     // Always 0x34 ?
       DirTableOffset: Integer;
       DirOffset: Integer;
     end;
     TMPAK_Entry = packed record
       Unknown1: Integer;
       Unknown2: Integer;
       Offset: integer;
       CmpSize: Integer;
       UncSize: Integer;
       DirPos: Integer;
       EntryName: array[0..31] of char;   // Null terminated
     end;
     TMPAK_CompHeader = packed record
       TotSize: Integer;   // Size of compressed data + header
       UncSize: Integer;   // Size of uncompressed data
       CmpSize: integer;   // Size of compressed data alone
       NotCompressed: Integer;   // 1 = True, 0 = False
     end;

function ReadTheMoviesPAK: Integer;
var HDR: TMPAK_Header;
    ENT: TMPAK_Entry;
    disp: string;
    NumE, x, OldPer, CurP: integer;
    DirData: TMemoryStream;
    FilData: THandleStream;
begin

  // We retrieve the total file size
  TotFSize := FileSeek(FHandle,0,2);
  FileSeek(Fhandle, 0, 0);

  // We read the header
  FileRead(FHandle, HDR, SizeOf(HDR));

  // We check that we are really reading a The Movie .PAK file
  //   ID = 5
  // And obviously all Offset must be lower than total size
  if (HDR.ID <> 5) and (HDR.DataOffset <= TotFSize) and (HDR.DirOffset <= TotFSize) and (HDR.DirTableOffset <= TotFSize) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'TMPAK';
    ErrInfo.Games := 'The Movies';
  end
  else
  begin

    // We are first going to retrieve the directory names chunk
    // For that we instanciate a MemoryStream which will hold the chunk for future use
    DirData := TMemoryStream.Create;

    // We keep the offset
    CurP := FileSeek(FHandle,0,1);

    // We instanciate a stream from the file handle
    FilData := THandleStream.Create(FHandle);

    try

      // We seek to the offset of the directory chunk
      FilData.Seek(HDR.DirOffset,soBeginning);

      // We copy the chunk to the memory stream
      DirData.CopyFrom(FilData,HDR.DirSize);

    finally

      // We free the handle stream
      FreeAndNil(FilData);

      // We seek to the stored offset
      FileSeek(FHandle,CurP,0);

    end;

    try

      NumE := HDR.NumEntries;
      OldPer := 0;

      // For each entry in the file
      for x:= 1 to NumE do
      begin

        // Display progress
        Per := ROund(((x / NumE)*100));
        if (Per >= OldPer + 5) then
        begin
          SetPercent(Per);
          OldPer := Per;
        end;

        // We read the entry
        FileRead(Fhandle,ENT,SizeOf(ENT));

        // We retrieve the directory
        // The DirPos integer needs to be "decoded"
        // Only 15 bits are relevant
        // We seek to that offset in the directory chunk
        DirData.Seek((ENT.DirPos and $7FFF) shr 1, soBeginning);

        // We get the directory (null terminated)
        disp := Strip0(Get0(DirData));

        // We concatenate the directory and the entry name
        disp := disp + strip0(ENT.EntryName);

        // We store the result
        FSE_Add(disp,ENT.Offset,ENT.UncSize,ENT.CmpSize,0);

      end;

    finally

      // We free the directory chunk
      FreeAndNil(DirData);

    end;

    Result := NumE;

    DrvInfo.ID := 'TMPAK';
    DrvInfo.Sch := '\';
    // Extraction will be handled by this plugin because it needs some processing (Zlib decompression)
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := True;

  end;

end;

// -------------------------------------------------------------------------- //
// The Secret of Monkey Island: Special Edition .PAK support ================ //
// -------------------------------------------------------------------------- //

type SMISEKAPLHeader = packed record
    ID: array[0..3] of char;          // KAPL
    Unknown1: longword;
    UnknownBlockOffset: longword;
    IndexBlockOffset: longword;
    NamesBlockOffset: longword;
    DataBlockOffset: longword;
    UnknownBlockSize: longword;
    IndexBlockSize: longword;
    NamesBlockSize: longword;
    DataBlockSize: longword;
  end;
type SMISEKAPLIndex = packed record
    DataOffset: longword;
    NameOffset: longword;
    Size: longword;
    Size2: longword;
    Unknown: longword;
  end;
  // NameBlock is get0 from NameOffset

type SMISEKAPLDXTHeader = packed record
    FourCC: array[0..3] of char;
    Width: longword;
    Height: longword;
  end;

function ReadTheSecretOfMonkeyIslandSEKAPL(): Integer;
var HDR: SMISEKAPLHeader;
    ENT: SMISEKAPLIndex;
    disp: string;
    NumE, x, oldper: integer;
    TotFSize: int64;
    namestm, indexstm: TMemoryStream;
    srcstm: THandleStream;
    curoffset: longword;
begin

  TotFSize := FileSeek(Fhandle, 0, 2);

  FileSeek(Fhandle, 0, 0);
  FileRead(Fhandle, HDR, SizeOf(SMISEKAPLHeader));

  if (HDR.ID <> 'KAPL') and ((HDR.UnknownBlockOffset+HDR.UnknownBlockSize) <= TotFSize) and ((HDR.IndexBlockOffset+HDR.IndexBlockSize) <= TotFSize)
                        and ((HDR.NamesBlockOffset+HDR.NamesBlockSize) <= TotFSize) and ((HDR.DataBlockOffset+HDR.DataBlockSize) <= TotFSize) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    ReadTheSecretOfMonkeyIslandSEKAPL := -3;
    ErrInfo.Format := 'KAPL';
    ErrInfo.Games := 'The Secret of Monkey Island Special Edition';
  end
  else
  begin

    // Create TStream objects
    srcstm := THandleStream.Create(Fhandle);
    indexstm := TMemoryStream.Create;
    namestm := TMemoryStream.Create;

    try

      // Retrieve index block
      srcstm.Seek(HDR.IndexBlockOffset,0);
      indexstm.CopyFrom(srcstm,HDR.IndexBlockSize);
      indexstm.Seek(0,0);

      // Retrieve filenames block
      srcstm.Seek(HDR.NamesBlockOffset,0);
      namestm.CopyFrom(srcstm,HDR.NamesBlockSize);
      namestm.Seek(0,0);

      // Force the first display of progress
      OldPer := 255;

      // Compute how many entries we expect
      NumE := HDR.IndexBlockSize div SizeOf(SMISEKAPLIndex);

      curoffset := 0;

      // For each entry
      for x:= 1 to NumE do
      begin

        // Increase progress when needed
        Per := ROund(((x / NumE)*100));
        if (OldPer <> Per) then
        begin
          SetPercent(Per);
          OldPer := Per;
        end;

        // Get the entry structure filled
        indexstm.ReadBuffer(ENT, SizeOf(SMISEKAPLIndex));

        // Retrieve the filename from name block
//        namestm.Seek(ENT.NameOffset,0);
        namestm.Seek(curoffset,0);
        disp := strip0(get0(namestm));
        inc(curoffset,length(disp)+1);
        if (ExtractFileExt(disp) = '.dxt') then
          disp := disp + '.dds';

        // Add entry to FSE
        FSE_Add(disp,HDR.DataBlockOffset+ENT.DataOffset,ENT.Size,ENT.Size2,ENT.Unknown);

      end;

    finally
      // Free all TStream objects
      FreeAndNil(srcstm);
      FreeAndNil(indexstm);
      FreeAndNil(namestm);
    end;

    // Return the number of entries
    ReadTheSecretOfMonkeyIslandSEKAPL := NumE;

    // Driver info, directories with '/', no need for internal extraction
    DrvInfo.ID := 'KAPL';
    DrvInfo.Sch := '/';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := true;

  end;

end;

// Function to extract textures from KAPL to DDS
// Only supports DXT textures
// If something weird is found, just do a BinCopy extraction
function ExtractKAPLDXTToDDS(outputstream: TStream; Offset, Size: int64; BufferSize: integer; silent: boolean): boolean;
var DDS: DDSHeader;
    DXTHDR: SMISEKAPLDXTHeader;
    inFile: THandleStream;
    CStream, DStream: TMemoryStream;
    gz: TAbGZipArchive;
    abprogress: TAbProgress;
    csize: integer;
    GZIPTEST: word;
begin

  inFile := THandleStream.Create(FHandle);
  inFile.Seek(Offset,0);

  FillChar(DXTHDR,SizeOf(SMISEKAPLDXTHeader),0);
  if (Size > 12) then
    inFile.ReadBuffer(DXTHDR,SizeOf(SMISEKAPLDXTHeader));

  // Sanity checks, if they fail, we just extract a BinCopy
  if (DXTHDR.FourCC = 'DXT5') or (DXTHDR.FourCC = 'DXT1') then
  begin

    // Compute size from expected compressed texture type
    //  DXT5 is 8 bits per pixel
    if DXTHDR.FourCC[3] = #53 then
      csize := DXTHDR.Width*DXTHDR.Height
    //  DXT1 is 4 bits per pixel
    else
      csize := (DXTHDR.Width*DXTHDR.Height) div 2;

    // Fill the header of the texture
    FillChar(DDS,SizeOf(DDSHeader),0);
    DDS.ID[0] := 'D';
    DDS.ID[1] := 'D';
    DDS.ID[2] := 'S';
    DDS.ID[3] := ' ';
    DDS.SurfaceDesc.dwSize := 124;
    DDS.SurfaceDesc.dwFlags := DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or DDSD_PIXELFORMAT or DDSD_LINEARSIZE;
    DDS.SurfaceDesc.dwHeight := DXTHDR.Height;
    DDS.SurfaceDesc.dwWidth := DXTHDR.Width;
    DDS.SurfaceDesc.dwPitchOrLinearSize := csize;
    DDS.SurfaceDesc.dwMipMapCount := 0;
    DDS.SurfaceDesc.ddpfPixelFormat.dwSize := 32;
    DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_FOURCC;
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[0] := 'D';
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[1] := 'X';
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[2] := 'T';
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[3] := DXTHDR.FourCC[3];
    DDS.SurfaceDesc.ddsCaps.dwCaps1 := DDSCAPS_TEXTURE;

    // Read 2 bytes for gzip magic id
    inFile.ReadBuffer(gziptest,2);

    // Go back to start of data
    inFile.Seek(Offset+12,0);

    // If the marker for gzip is found, we gunzip (MI2)
    if (gziptest = $8B1F) then
    begin

      // Extract gzipped data
      CStream := TMemoryStream.Create;
      try
        CStream.CopyFrom(inFile,Size-12);
        CStream.Seek(0, soBeginning);
        gz := TAbGZipArchive.CreateFromStream(CStream,'datablock.gzip');
        abprogress := TAbProgress.Create(SetPercent);
        DStream := TMemoryStream.Create;
        try
          gz.OnArchiveItemProgress := abprogress.SetItemProgress;
          gz.Load;
          gz.ExtractToStream('unknown',DStream);
          DStream.Seek(0,0);
          // Write DDS header
          outputstream.Write(DDS,SizeOf(DDSHeader));
          // Write decompressed data
          outputstream.CopyFrom(DStream,DStream.Size);
        finally
          FreeAndNil(gz);
          FreeAndNil(abprogress);
          FreeAndNil(CStream);
          FreeAndNil(DStream);
        end;
      finally
        FreeAndNil(CStream);
        FreeAndNil(inFile);
      end

    end
    // Else the exact data size is found (MI1)
    else if (csize+SizeOf(SMISEKAPLDXTHeader)) = Size then
    begin

      // Write the DDS header
      outputstream.Write(DDS,SizeOf(DDSHeader));
      // Write the data directly
      outputstream.CopyFrom(inFile,Size-12);
      FreeAndNil(inFile);

    end
    // Unknown case, we bincopy the data
    else
    begin

      FreeAndNil(inFile);
      BinCopyToStream(Fhandle,outputstream,Offset,Size,0,BufferSize,silent,SetPercent);

    end;

  end
  // Unknown case, we bincopy the data
  else
  begin

    FreeAndNil(inFile);
    BinCopyToStream(Fhandle,outputstream,Offset,Size,0,BufferSize,silent,SetPercent);

  end;


  result := true;

end;

// -------------------------------------------------------------------------- //
// The Sims .FAR support ==================================================== //
// -------------------------------------------------------------------------- //

type FARHeader = packed record
       ID: array[0..3] of char;
       Author: array[0..3] of char;
       Version: integer;
       Offset: integer;
     end;
     FAREntry = packed record
       FileSize: integer;
       ExtSize: integer;
       Offset: integer;
     end;

const
   FARID : String = 'FAR!';

function ReadTheSimsFAR(src: string): Integer;
var HDR: FARHeader;
    ENT: FAREntry;
    disp: string;
    NumE, x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, 16);

    if (HDR.ID <> FARID) and (HDR.Author <> 'byAZ') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadTheSimsFAR := -3;
      ErrInfo.Format := 'FAR';
      ErrInfo.Games := 'The Sims';
    end
    else
    begin

      FileSeek(FHandle,HDR.Offset,0);
      FileRead(FHandle,NumE,4);

      for x:= 1 to NumE do
      begin

        Per := ROund(((x / NumE)*100));
        SetPercent(Per);

        FileRead(Fhandle,ENT,12);
        disp := Get32(FHandle);

        FSE_Add(disp,ENT.Offset,ENT.FileSize,0,0);

      end;

      ReadTheSimsFAR := NumE;

      DrvInfo.ID := 'FAR';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;
  end
  else
    ReadTheSimsFAR := -2;

end;

// -------------------------------------------------------------------------- //
// The Witcher 2: Assassins of Kings .DZIP support ========================== //
// -------------------------------------------------------------------------- //

type DZIP_Header = packed record
       ID: array[0..3] of char;
       Version: integer;
       NumEntries: integer;
       Unknown: integer;
       EntriesOffset: int64;
     end;
     // Get16 EntryName
     DZIP_Entry = packed record
       Unknown1: int64;
       UncompressedSize: int64;
       Offset: int64;
       Size: int64;
     end;

function ReadTheWitcher2DZIP(src: string): Integer;
var HDR: DZIP_Header;
    ENT: DZIP_Entry;
    NumE,NumErrors,x : integer;
    stmInput: THandleStream;
    strName: String;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    stmInput := THandleStream.Create(Fhandle);

    TotFSize := stmInput.Size;
    stmInput.Seek(0,soBeginning);
    stmInput.ReadBuffer(HDR, Sizeof(DZIP_Header));

    if (HDR.ID <> 'DZIP') and (HDR.Version <> 2) and (HDR.EntriesOffset > TotFSize) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'DZIP';
      ErrInfo.Games := 'The Witcher 2: Assassins of Kings';
    end
    else
    begin

      stmInput.Seek(HDR.EntriesOffset,soBeginning);
      NumE := 0;

      for x := 1 to HDR.NumEntries do
      begin
        strName := get16(stmInput);
        stmInput.ReadBuffer(ENT,SizeOf(DZIP_Entry));
        if (ENT.Offset + ENT.Size) <= TotFSize then
        begin
          FSE_Add(Strip0(strName),ENT.Offset,ENT.Size,ENT.Unknown1,ENT.UncompressedSize);
          Inc(NumE);
        end
        else
          inc(NumErrors);
      end;

      Result := NumE;

      DrvInfo.ID := 'DZIP';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

    FreeAndNil(stmInput);

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Tony Hawk Pro Skater 2 .PKR support ====================================== //
// -------------------------------------------------------------------------- //

type PKR_Header = packed record
       ID: array[0..3] of char;
       Version: integer;
       DirNum: integer;
       FilNum: integer;
     end;
     PKR_Dir = packed record
       Filename: array[0..31] of char;
       Unknown: integer;
       NumFiles: integer;
     end;
     PKR_Entry = packed record
       Filename: array[0..31] of char;
       Unknown: integer;
       Offset: integer;
       Size: integer;
       Size2: integer;
     end;

function ReadTonyHawkPKR(src: string): Integer;
var HDR: PKR_Header;
    DIR: PKR_Dir;
    ENT: PKR_Entry;
    NumE,x,cdir : integer;
    EList: TStringList;
    DList: array[0..1000] of Integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR.ID, 4);
    FileRead(FHandle, HDR.Version, 4);
    FileRead(FHandle, HDR.DirNum, 4);
    FileRead(FHandle, HDR.FilNum, 4);

    if (HDR.ID <> 'PKR2') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'PKR';
      ErrInfo.Games := 'Tony Hawk Pro Skater 2';
    end
    else
    begin
      EList := TStringList.Create;
      try
        for x := 1 to HDR.DirNum do
        begin
          FileRead(FHandle,DIR.Filename,32);
          FileRead(FHandle,DIR.Unknown,4);
          FileRead(FHandle,DIR.NumFiles,4);
          EList.Add(Strip0(DIR.Filename));
          DList[x] := DIR.NumFiles;
        end;

        NumE := HDR.FilNum;
        cdir := 1;

        for x := 1 to NumE do
        begin

          FileRead(FHandle,ENT.Filename,32);
          FileRead(FHandle,ENT.Unknown,4);
          FileRead(FHandle,ENT.Offset,4);
          FileRead(FHandle,ENT.Size,4);
          FileRead(FHandle,ENT.Size2,4);

          if DList[cdir] = 0 then
            inc(cdir);

          FSE_Add(EList.Strings[cdir-1] + Strip0(ENT.Filename),ENT.Offset,ENT.Size,0,0);

          Dec(DList[cdir]);

        end;
      finally
        FreeAndNil(EList);
      end;

      //ShowMessage(IntTosTr(NumE));

      Result := NumE;

      DrvInfo.ID := 'PKR';
      DrvInfo.Sch := '/';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Total Annihilation .HPI support ========================================== //
// -------------------------------------------------------------------------- //

function HPIRead(fpos: integer; buff: PByteArray; Size: integer; key: integer): integer;
var count, tkey: integer;
begin

  FileSeek(FHandle, fpos, 0);

  result := FileRead(FHandle,buff^,Size);

  if (key <> 0) then
    for count := 0 to Size-1 do
    begin
      tkey := (fpos + count) xor Key;
      Buff[count] := tkey xor not(Buff[Count]);
    end;

end;

procedure HPIProcessFile(Name: String; Offset: integer; Buffer: TMemoryStream);
var DataOffset, FileSize: integer;
    Flag: byte;
begin

  Buffer.Seek(Offset,0);
  Buffer.read(DataOffset,4);
  Buffer.Read(FileSize,4);
  Buffer.Read(Flag,1);

  Inc(NumFSE);
  FSE_Add(Name,DataOffset,FileSize,Flag,0);

end;

procedure HPITraverseTree(ParentName: String; Offset: integer; Buffer: TMemoryStream);
var x, Entries, EntryOffset, NameOffset, DataOffset: integer;
    Flag: Byte;
    Name: string;
    c: Char;
begin

  Buffer.Seek(Offset,0);
  Buffer.Read(Entries,4);
  Buffer.Read(EntryOffset,4);

  for x := 1 to Entries do
  begin
    Buffer.Seek(EntryOffset,0);
    Buffer.Read(NameOffset,4);
    Buffer.Read(DataOffset,4);
    Buffer.Read(Flag,1);

    Name := '';
    Buffer.Seek(NameOffset,0);
    repeat
      Buffer.Read(c,1);
      if (c <> #0) then
        Name := Name + c;
    until c = #0;

    if ParentName <> '' then
      Name := ParentName + '\' + name;

    if Flag = 1 then
      HPITraverseTree(Name,DataOffset,Buffer)
    else
      HPIProcessFile(Name,DataOffset,Buffer);

//    ShowMessage(Name);

    Inc(EntryOffset,9)

  end;

//  ShowMessage(IntToStr(Entries)+#10+IntToStr(EntryOffset));

end;

type HPIHeader = packed record
       HPIMarker: array[0..3] of char;
       SaveMarker: array[0..3] of char;
       DirectorySize: integer;
       HeaderKey: integer;
       Start: integer;
     end;
     HPIEntry = packed record
       NameOffset : integer;
       DirDataOffset : integer;
       Flag : byte;
     end;
     HPIFileData = packed record
       DataOffset : integer;
       FileSize : integer;
       Flag : byte;
     end;
     HPIChunk = packed record
       Marker : array[0..3] of char;
       Unknown1 : byte;
       CompMethod : byte;
       Encrypt : byte;
       CompressedSize : integer;
       DecompressedSize : integer;
       Checksum : integer;
     end;

function ReadTotalAnnihilationHPI(src: string): Integer;
var HDR: HPIHeader;
    key: integer;
    Buffer, BufEmpty: PByteArray;
    BufMem: TMemoryStream;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, 20);

    if (HDR.HPIMarker <> 'HAPI') or (HDR.SaveMarker = 'BANK') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'HPI';
      ErrInfo.Games := 'Total Annihilation';
    end
    else
    begin
//      HDR.HeaderKey := $7D;

      if HDR.HeaderKey <> 0 then
      begin
        Key := not((HDR.HeaderKey * 4) or (HDR.HeaderKey shr 6));
        HPIKey := Key;
      end
      else
      begin
        Key := 0;
        HPIKey := 0;
      end;

      NumFSE := 0;

      GetMem(Buffer,HDR.DirectorySize);
      GetMem(BufEmpty,20);
      try
         HPIRead(HDR.Start,Buffer,HDR.DirectorySize-20,Key);
         BufMem := TMemoryStream.create;
         try
           FillChar(BufEmpty^,20,0);
           BufMem.Write(BufEmpty^, 20);
           BufMem.Write(Buffer^,HDR.DirectorySize-20);
           HPITraverseTree('', HDR.Start, BufMem);
         finally
           BufMem.Destroy;
         end;
      finally
         FreeMem(Buffer);
      end;

{
      test := FileCreate('h:\testhpi.bin', fmOpenWrite);
      GetMem(Buffer,FileSeek(FHandle,0,2));
      try
        HPIRead(0,Buffer,FileSeek(FHandle,0,2),Key);
        FileWrite(test,Buffer^,FileSeek(FHandle,0,2));
      finally
        FreeMem(Buffer);
        FileClose(test);
      end;
}

      Result := NumFSE;

      DrvInfo.ID := 'HPI';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end;
  end
  else
    Result := -2;

end;

function DecompressLZ77(outbuf: PByteArray; inbuf: PByteArray; len: integer): integer;
var x,outbufptr,mask,tag,inptr,outptr,count,inbufptr: integer;
    Window: array[0..4095] of byte;
    Done: boolean;
begin

  done := false;
  inptr := 0;
  outptr := 0;
  outbufptr := 1;
  mask := 1;
  tag := inbuf^[inptr];
  inc(inptr);

  while not(done) do
  begin
    if (mask and tag) = 0 then
    begin
      outbuf^[outptr] := inbuf^[inptr];
      inc(outptr);
      Window[outbufptr] := inbuf^[inptr];
      outbufptr := (outbufptr + 1) and $FFF;
      inc(inptr);
    end
    else
    begin
      count := inbuf^[inptr] + inbuf^[inptr+1]*$100;
      inc(inptr,2);
      inbufptr := (count and $FFF0) shr 4;
      if (inbufptr = 0) then
        Done := true
      else
      begin
        count := (count and $F) + 2;
        if (count >= 0) then
          for x := 0 to count-1 do
          begin
            outbuf^[outptr] := Window[inbufptr];
            inc(outptr);
            Window[outbufptr] := Window[inbufptr];
            outbufptr := (outbufptr + 1) and $FFF;
            inbufptr := (inbufptr + 1) and $FFF;
          end;
      end;
    end;
    mask := mask * 2;
    if (mask and $100) = $100 then
    begin
      mask := 1;
      tag := inbuf^[inptr];
      inc(inptr);
    end;
    done := done or (inptr > len-1);
  end;

  if (inptr >= len-1) then
    result := len
  else
    result := inptr+1;

end;

procedure DecompressHPIToStream(outputstream: TStream; Offset, Size: int64; Comp: integer; silent: boolean);
var chunks, x,y: integer;
    HDR: HPIChunk;
    Buffer: PByteArray;
    DecompBuffer: PByteArray;
    BufMem: TMemoryStream;
    c: Byte;
   // ftmp: integer;
    ChunkSize: array of Integer;
//    OutputStream: TMemoryStream;
    DStream: TDecompressionStream;
    per, oldper: word;
    real1, real2: real;
begin

  chunks := Size div 65536;
  if (Size mod 65536) <> 0 then
    inc(chunks);

  BufMem := TMemoryStream.Create;
  try

  SetLength(ChunkSize,chunks);

  GetMem(Buffer,chunks*4);
  HPIRead(Offset,Buffer,chunks*4,HPIKey);
  BufMem.Write(Buffer^,chunks*4);
  BufMem.Seek(0,0);
  for x := 1 to chunks do
    BufMem.Read(ChunkSize[x-1],4);

  FreeMem(Buffer);
  BufMem.Clear;

  Inc(Offset,chunks*4);

  OldPer := 0;

  for x := 1 to chunks do
    begin
      GetMem(Buffer,19);
      try
        HPIRead(Offset,Buffer,19,HPIKey);

        BufMem.Clear;
        BufMem.Write(Buffer^,19);
        BufMem.Seek(0,0);
        BufMem.Read(HDR.Marker,4);
        BufMem.Read(HDR.Unknown1,1);
        BufMem.Read(HDR.CompMethod,1);
        BufMem.Read(HDR.Encrypt,1);
        BufMem.Read(HDR.CompressedSize,4);
        BufMem.Read(HDR.DecompressedSize,4);
        BufMem.Read(HDR.Checksum,4);

//        ShowMessage(inttostr(x)+#10+HDR.Marker+#10+inttostr(ChunkSize[x-1]));

        FreeMem(Buffer);
        GetMem(Buffer,HDR.CompressedSize);
        HPIRead(Offset+19,Buffer,HDR.CompressedSize,HPIKey);

        BufMem.Clear;
        BufMem.Write(Buffer^,HDR.CompressedSize);
        BufMem.Seek(0,0);

//        BufMem.SaveToFile('h:\testhpi-zlib-'+inttostr(x)+'-U.bin');

        if (HDR.Encrypt = 1) then
        begin
          for y := 0 to HDR.CompressedSize-1 do
          begin
            BufMem.Seek(y,0);
            BufMem.Read(c,1);
            BufMem.Seek(y,0);
            c := (c - y) xor y;
            BufMem.Write(c,1);
          end;
        end;

        if (HDR.CompMethod = 1) then
        begin
          BufMem.Seek(0,0);
          BufMem.Read(Buffer^,HDR.CompressedSize);
          GetMem(DecompBuffer,HDR.DecompressedSize);
          DecompressLZ77(DecompBuffer,Buffer,HDR.CompressedSize);
          outputstream.WriteBuffer(DecompBuffer^,HDR.DecompressedSize);
          FreeMem(DecompBuffer);
        end
        else
        begin

  //        BufMem.SaveToFile('h:\testhpi-zlib-'+inttostr(x)+'.bin');
//          OutputStream := TMemoryStream.Create;
          try
            BufMem.Seek(0,0);
            DStream := TDecompressionStream.Create(BufMem);
            try
//              DStream.Read(TestID,2);
  //            ShowMessage(IntToStr(TestID));
              OutputStream.CopyFrom(DStream,HDR.DecompressedSize);
            finally
              FreeAndNil(DStream);
            end;
//            GetMem(DecompBuffer,HDR.DecompressedSize);
//            OutputStream.SaveToFile('h:\testhpi-zlib-'+inttostr(x)+'-decomp.bin');
//            OutputStream.Seek(0,0);
//            OutputStream.Read(DecompBuffer^,HDR.DecompressedSize);
//            FileWrite(fil,DecompBuffer^,HDR.DecompressedSize);
//            FreeMem(DecompBuffer);
          finally
            //FreeAndNil(OutputStream);
          end;
          //ShowMessage(IntToStr(FinalSize));
        end;

        Inc(Offset,ChunkSize[x-1]);
      finally
        FreeMem(Buffer);
      end;

      if not silent then
      begin
        real1 := x;
        real2 := chunks;
        real1 := (real1 / real2)*100;
        per := Round(real1);
        if per >= oldper + 10 then
        begin
          SetPercent(per);
          oldper := per;
        end;
      end;
    end;

    if not silent then
      SetPercent(100);

  finally
    BufMem.Destroy;
  end;

end;

// -------------------------------------------------------------------------- //
// UFO Aftermath/Aftershock/Afterlight .VFS support ========================= //
// -------------------------------------------------------------------------- //

type VFSHeader = packed record     // Some of the info from http://wiki.xentax.com --> WATTO <-- (Thanks!)
       VersionID: Single;          // $0000803F
       BlockSize: Cardinal;        // Block size for padding (ex: 160 bytes / 4096 bytes)
       PlacementEntries: integer;  // Position in file of first entry (PlacementEntries * 8 + SizeOf(VFSHeader)
       FirstNumberOfEntries: integer;   // Number of file entries in first block
       Unknown01Null: integer;          // $00000000
       MaximumFilenameLength: integer;  // Always $00000040 = 64?
       CompressionWindow: integer;      // Always 50000? (Compression windows from Wiki) - Files are compressed by this original size blocks
       MD5Hash: array[0..15] of byte;   // MD5 Hash of File Header?
       ExtraInfoSize: integer;          // Size of extra info
     end;
     // Read ExtraInfoSize bytes (usually a null terminated string)
     // Read number of file pre-entries
     //VFSFilePreEntry = packed record
     //  RelativeOffset: Integer;           // Relative Offset (by number of blocks (see VFSHeader.BlockSize)
     //  Size: integer;                     // Size (in bytes)
     //end;

     VFSFileEntry = packed record
       Filename: array[0..63] of char;    // Null terminated filename
       Unknown1: integer;
       EntryType: integer;                // Type of entry:
                                          // $00000001 = File
                                          // $00000002 = Directory
                                          // $00000009 = Compressed file
                                          // Maybe this should be read as flags:
                                          // $00000001 = File
                                          // $00000002 = Directory
                                          // $00000008 = Compressed data?
                                          // Therefore compressed file would be $00000009
       Unknown2FF: integer;               // Always $FFFFFFFF (-1)
       RelativeOffset: Integer;           // Relative Offset (by number of blocks (see VFSHeader.BlockSize)
       Size: integer;                     // Size (in bytes)
       OriginalSize: integer;             // Original Size (in bytes) <--> Uncompressed size
     end;

// UFO: Aftermath/Aftershock/Afterlight .VFS
// Auxiliary recursive function to deal with nested directories
//      BlockSize is the HDR.BlockSize (needed to calculate Offsets)
//    StartOffset is the calculated Starting offset from all header information (also needed to calculate Offsets)
//      EntrySize is the number of entries in the current directory
//         curDir is a string representing current directory path (ex: share\textures)
//         Offset is current offset
function ReadUFOAftermathVFS_aux(BlockSize, StartOffset, EntrySize: integer; curDir: string; offset: integer): integer;
var ENT: VFSFileEntry;
    newDir: string;
    x, numFSE: integer;
begin

  // If curDir is empty then this is the first recursion (from root directory)
  // therefore we don't add trailing slash else we do..
  if length(curDir) = 0 then
    newDir := ''
  else
    newDir := curDir + '\';

  NumFSE := 0;

  // We parse the directory
  for x := 1 to EntrySize do
  begin

    // We seek into position, we need to it every loop because we could have
    // gone into recursion
    FileSeek(Fhandle,Offset+(x-1)*SizeOf(VFSFileEntry),0);

    // We read that entry
    FileRead(FHandle,ENT,SizeOf(VFSFileEntry));

    // Three options for that entry (actually 4, sort of):
    // Either it is a plain non-compressed file
    //   In that case we just calculate the Offset and add it to FSE list and increment the file counter
    if (ENT.EntryType = 1) then
    begin
      FSE_Add(newDir+strip0(ENT.Filename),StartOffset + ((ENT.RelativeOffset-1)*BlockSize),ENT.Size,0,0);
      Inc(NumFSE);
    end
    // Or it is a directory
    //   In that case we calculate the Offset and recurse into that directory
    else if (ENT.EntryType = 2) then
    begin
      Inc(NumFSE,ReadUFOAftermathVFS_aux(BlockSize,StartOffset,ENT.Size div SizeOf(VFSFileEntry),newDir+strip0(ENT.Filename),StartOffset + ((ENT.RelativeOffset-1)*BlockSize)));
    end
    // Or it is a Zlib-compressed file
    //   In that case we calculate the Offset and add it to FSE list indicating it is compressed and the compressed size, then increment the file counter
    else if (ENT.EntryType = 9) then
    begin
      FSE_Add(newDir+strip0(ENT.Filename),StartOffset + ((ENT.RelativeOffset-1)*BlockSize),ENT.OriginalSize,1,ENT.Size);
      Inc(NumFSE);
    end
    else  // Finally this is needed to avoid wrong entries, we get out of the loop in any other case
          // The problem is real unhandled/unknown entry types will also break processing of the current directory
      break;
  end;

  Result := NumFSE;

end;

// UFO: Aftermath/Aftershock/Afterlight .VFS
// Main parse function
//   This took a lot of research to finally be able to read and extract data!!
//   Information found there helped to start (thanks WATTO):
//     http://wiki.xentax.com/index.php?title=UFO_Aftershock
//   Unfortunately that was not enough to be able to understand everything!
//   I wonder if it is because Aftermath is the prequel of Aftershock? ;)
//   Well here it is! Check auxiliary function for comments!
function ReadUFOAftermathVFS(src: string): Integer;
var HDR: VFSHeader;
    ENT: VFSFileEntry;
    RootOffset, StartOffset, x, numFSE: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin

    // We read the header
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, SizeOf(VFSHeader));

    // We check this looks like a genuine VFS file format that we can handle
    //   MaximumFilenameLength must be 64, the code was not made to handle other values
    //   Could be done, but I found no file that had another value so why bother.. ;)
    if (HDR.VersionID = 1.0) and (HDR.Unknown01Null = 0) and (HDR.MaximumFilenameLength = 64) then
    begin

      // We calculate the RootOffset (where the Root directory file entries are)
      //   This was the hardest to find! Grrr...
      RootOffset := (HDR.PlacementEntries * 8) + SizeOf(VFSHeader) + HDR.ExtraInfoSize + 4;

      // We calculate the StartOffset (where the first "normal" block starts)
      //   This was required because the first block is not the same size than
      //   other blocks, only god knows why...
      StartOffset := RootOffset + (HDR.FirstNumberOfEntries * SizeOf(VFSFileEntry));

      NumFSE := 0;

      // We store CompressionWindow to be able to decompress bigger than <CompressionWindow> bytes
      // files. The only value I found in that field is 50000. But the plugin can deal
      // with any value!
      // Compressed files are break into data chunks of <CompressionWindow> bytes then Zlib compressed
      // Check DecompressZlibVFSChunksToStream function for more details on how to decompress files
      CompressionWindow := HDR.CompressionWindow;

      // We parse the root directory
      // This is identical to auxiliary function so check there for comments ;)
      for x := 1 to HDR.FirstNumberOfEntries do
      begin
        FileSeek(Fhandle,RootOffset+(x-1)*SizeOf(VFSFileEntry),0);
        FileRead(FHandle,ENT,SizeOf(VFSFileEntry));
        if (ENT.EntryType = 1) then
        begin
          FSE_Add(strip0(ENT.Filename),StartOffset + ((ENT.RelativeOffset-1)*HDR.BlockSize),ENT.Size,0,0);
          Inc(NumFSE);
        end
        else if (ENT.EntryType = 2) then
        begin
          Inc(NumFSE,ReadUFOAftermathVFS_aux(HDR.BlockSize,StartOffset,ENT.Size div SizeOf(VFSFileEntry),Strip0(ENT.Filename),StartOffset + ((ENT.RelativeOffset-1)*HDR.BlockSize)));
        end
        else if (ENT.EntryType = 9) then
        begin
          FSE_Add(strip0(ENT.Filename),StartOffset + ((ENT.RelativeOffset-1)*HDR.BlockSize),ENT.OriginalSize,1,ENT.Size);
          Inc(NumFSE);
        end
        else
          break;
      end;

      // We return the number of files found
      Result := NumFSE;

      DrvInfo.ID := 'VFS';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      // Extraction is handled by plugin because of compression used by some files
      DrvInfo.ExtractInternal := True;

    end
    else
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'VFS';
      ErrInfo.Games := 'UFO: Aftermath, UFO: Aftershock, UFO: Afterlight';
    end;
  end
  else
    Result := -2;

end;

// UFO: Aftermath/Aftershock/Afterlight .VFS
// Decompression function
//   Compressed file data in UFO: Aftermath/Aftershock/Afterlight .VFS file is break down into chunks
//   So we just go through that chunks decompressing each one separatly
//   But we skip the 8 bytes chunks which purpose is unknown and occurs every
//   2 "normal" compressed chunks
//   Here is the process for a 3 chunks entry:
//     Read ChunkSize (Integer)
//     Read ChunkZlibData array[1..ChunkSize] of Byte
//       Decompress ChunkZlibData (original size of the chunk is CompressionWindow [usually 50000, check header of VFS])
//       Decrease still to be read data by Chunksize + 4
//       Decrease still to be decompressed original data by CompressionWindow
//     Read ChunkSize (Integer)
//     Read ChunkZlibData array[1..ChunkSize] of Byte
//       Decompress ChunkZlibData (original size of the chunk is CompressionWindow [usually 50000, check header of VFS])
//       Decrease still to be read data by Chunksize + 4
//       Decrease still to be decompressed original data by CompressionWindow
//     Read ChunkSize (Integer) [8 bytes]
//     Read Unknown1 (Integer)
//     Read Unknown2 (Integer)
//       Decrease still to be read data by Chunksize + 4
//     Read ChunkSize (Integer)
//     Read ChunkZlibData array[1..ChunkSize] of Byte
//       Decompress ChunkZlibData (original size of the chunk is still to be decompressed size)
//       Decrease still to be read data by Chunksize + 4
//       Decrease still to be decompressed original data by CompressionWindow
// Enjoy... ;)
function DecompressZlibVFSChunksToStream(OutputStream: TStream; Offset: Int64; Size:  Int64; OSize: Int64) : Boolean;
var
  Buf: PChar;
  InputStream: TMemoryStream;
  DStream: TDecompressionStream;
  FinalSize, chunkSize,checkValue: integer;
begin

  FinalSize := 0;

  GetMem(Buf,Size);
  try

      FileSeek(FHandle,Offset,0);

      repeat
        FileRead(FHandle,chunkSize,4);
        if (chunkSize = 8) then
        begin
          FileRead(Fhandle,checkValue,4);
          FileRead(Fhandle,checkValue,4);
        end
        else
        begin
          FileRead(FHandle,Buf^,chunkSize);
          InputStream := TMemoryStream.Create;
          try
            InputStream.Write(Buf^,chunkSize);
            InputStream.Seek(0, soBeginning);

            DStream := TDecompressionStream.Create(InputStream);
            try
              if (OSize < CompressionWindow) then
                FinalSize := OutputStream.CopyFrom(DStream,OSize)
              else
                FinalSize := OutputStream.CopyFrom(DStream,CompressionWindow);
            finally
              FreeAndNil(DStream);
            end

          finally
            FreeAndNil(InputStream);
          end;

          Dec(OSize,CompressionWindow);

        end;
        Dec(Size,chunkSize+4);
      until Size = 0;
  finally
    FreeMem(Buf);
  end;

  Result := FinalSize = OSize;

End;

// -------------------------------------------------------------------------- //
// Vietcong .CBF support ==================================================== //
// -------------------------------------------------------------------------- //

type CBFHeader = packed record
        ID: array[1..8] of Char;  // BIGF 0x00 ZBL for uncrypted form
                                  // BIGF 0x01 ZBL for crypted form
        FileSize: int64;
        DirNum: integer;
        DirOffset: int64;
        DirSize: int64;
        Unknown: array[1..7] of integer;
     end;
     CBFEntry = packed record
        Offset: int64;
        Unknown1: integer;
        FileTime: int64;   // CRC/Date??
        Size: int64;
        CompSize: integer;
        CompType: integer;
        Unknown2: integer; // 0x24
     end;
     // Get0 FileName

function ReadVietcongCBF(src: string): Integer;
var HDR: CBFHeader;
    ENT: CBFEntry;
    disp: string;
    x: integer;
    TotSize: int64;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, SizeOf(CBFHeader));
    TotSize := FileSeek(FHandle,0,2);

    if (HDR.ID = 'BIGF'+#0+'ZBL') and (HDR.FileSize = TotSize) then
    begin

      FileSeek(FHandle,HDR.DirOffset,0);

      for x := 1 to HDR.DirNum do
      begin
        Per := ROund(((x / HDR.DirNum)*100));
        FileRead(FHandle,ENT,SizeOf(ENT));
        disp := Strip0(get0(FHandle));
//        if ENT.CompType <>0 then
//          disp := disp + '.ddc';
        FSE_Add(disp,ENT.Offset,ENT.Size,ENT.CompSize,ENT.CompType);
      end;

      Result := HDR.DirNum;

      DrvInfo.ID := 'CBF0';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end
    else
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'CBF0';
      ErrInfo.Games := 'Vietcong MP Demo';
    end;
  end
  else
    Result := -2;

end;

// CBF Decryption routines --------------------------------------------------------------------------- START //
//   cbf_head_dec will decrypt header chunks (file info)
//   cbf_file_dec will decrypt non compressed file data
// Both procedures are adapted from source code cbfext.c v0.2.1 by Luigi Auriemma
// Was downloaded from http://aluigi.altervista.org/papers.htm
// Original source code is licenced under GPL v2 or +.

procedure cbf_head_dec(var chunk: TMemoryStream);
const key: array[0..15] of byte = (
                $32, $f3, $1e, $06,
                $45, $70, $32, $aa,
                $55, $3f, $f1, $de,
                $a3, $44, $21, $b4);
var e, e2, posdata, t: integer;
    data: byte;
begin

  posdata := 0;
  e2 := chunk.Size;
  for e := chunk.Size downto 1 do
  begin
    chunk.Seek(posdata,0);
    chunk.ReadBuffer(data,1);
    t := data;
    data := data xor key[e2 and 15];
    chunk.Seek(posdata,0);
    chunk.WriteBuffer(data,1);
    e2 := t;
    inc(posdata);
  end;

end;

procedure cbf_file_dec(var chunk: TMemoryStream; totalsize: integer);
var t1, t2, data: byte;
    limit, datapos: integer;
begin

  t1 := totalsize;
  t2 := 90 - t1;
  limit := chunk.Size;

  for datapos := 0 to limit-1 do
  begin
    chunk.Seek(datapos,0);
    chunk.ReadBuffer(data,1);
    data := (data - t2) xor t1;
    chunk.Seek(datapos,0);
    chunk.WriteBuffer(data,1);
  end;

end;

// CBF Decryption routines ----------------------------------------------------------------------------- END //

procedure DecryptCBFToStream(src : integer; dst : TStream; soff : Int64; ssize : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback);
var InFile: THandleStream;
    Chunk: TMemoryStream;
    nbchunks,rest,x: integer;
    per, oldper: byte;
begin

  InFile := THandleStream.Create(src);
  InFile.Seek(sOff,0);
  Chunk := TMemoryStream.Create;
  nbchunks := sSize div bufsize;
  rest := sSize - (nbchunks * bufsize);
  oldper := 0;
  for x := 1 to nbchunks do
  begin
    per := Round((x / nbchunks) * 100);
    if (per > oldper) then
    begin
      DisplayPercent(per);
      oldper := per;
    end;
    Chunk.Clear;
    Chunk.CopyFrom(InFile,bufSize);
    cbf_file_dec(Chunk,Ssize);
    Chunk.Seek(0,0);
    dst.CopyFrom(chunk,bufSize);
  end;
  if rest > 0 then
  begin
    Chunk.Clear;
    Chunk.CopyFrom(InFile,rest);
    cbf_file_dec(Chunk,Ssize);
    Chunk.Seek(0,0);
    dst.CopyFrom(chunk,rest);
  end;
  DisplayPercent(100);
  FreeAndNil(Chunk);
  FreeAndNil(InFile);

end;

procedure DecompressCBFToStream(src : integer; dst : TStream; soff : Int64; ssize, totsize : Int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback);
var InFile: THandleStream;
    Chunk, OutChunk: TMemoryStream;
    CSize,OSize,OSizeCheck, CopySizeCheck: integer;
    Magic: array[0..3] of char;
    outsize: int64;
begin

  InFile := THandleStream.Create(src);
  InFile.Seek(sOff,0);
  outsize := 0;
  Dst.Size := TotSize;
  Dst.seek(0,0);
  OutChunk := TMemoryStream.Create;
  while (outsize <> totsize) and (infile.Position < (soff + ssize)) do
  begin
    InFile.ReadBuffer(Magic,4);
    InFile.ReadBuffer(CSize,4);
    InFile.ReadBuffer(OSize,4);
    if Magic <> '[..]' then
      Exception.Create('Decompression error: Wrong Magic ID');
    Chunk := TMemoryStream.Create;
    Chunk.CopyFrom(InFile,CSize);
    Chunk.Seek(0,0);
    OutChunk.SetSize(OSize);
    OSizeCheck := UnLzw(Chunk,OutChunk);
    if (OSizeCheck <> OSize) then
      Exception.Create('Decompression error in UnLzw() (expected: '+inttostr(OSize)+' bytes / extracted: '+inttostr(OSizecheck)+')');
    OutChunk.Seek(0,0);
    CopysizeCheck := dst.CopyFrom(OutChunk,OSize);
    if (CopysizeCheck <> OSize) then
      Exception.Create('Decompression error while Copying from buffer (expected: '+inttostr(OSize)+' bytes / copied: '+inttostr(CopySizecheck)+')');
    inc(outsize,Osize);
    FreeAndNil(Chunk);
  end;
  if (outsize <> totSize) then
    Exception.Create('Decompression error in DecompressCBFToStream() (expected: '+inttostr(totsize)+' bytes / extracted: '+inttostr(outsize)+')');
  FreeAndNil(InFile);
  FreeAndNil(OutChunk);

end;

function ReadVietcongCryptedCBF(src: string): Integer;
var HDR: CBFHeader;
    ENT: CBFEntry;
    disp: string;
    x: integer;
    TotSize: int64;
    Entrysize: word;
    InFile: THandleStream;
    Entry: TMemoryStream;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    InFile := THandleStream.Create(FHandle);
    Entry := TMemoryStream.Create;
    try
      InFile.Seek(0,0);
      InFile.ReadBuffer(HDR,SizeOf(CBFHeader));
      TotSize := InFile.Size;

      if (HDR.ID = 'BIGF'+#1+'ZBL') and (HDR.FileSize = TotSize) then
      begin

        InFile.Seek(HDR.DirOffset,0);

        for x := 1 to HDR.DirNum do
        begin
          Per := ROund(((x / HDR.DirNum)*100));
          InFile.ReadBuffer(EntrySize,2);
          Entry.Clear;
          Entry.CopyFrom(InFile,EntrySize);
          cbf_head_dec(Entry);
          Entry.Seek(0,0);
          Entry.Read(ENT,SizeOf(ENT));
          disp := Strip0(get0(Entry));
//          if ENT.CompType <>0 then
//            disp := disp + '.ddc';
          FSE_Add(disp,ENT.Offset,ENT.Size,ENT.CompSize,ENT.CompType);
        end;

        Result := HDR.DirNum;

        DrvInfo.ID := 'CBF1';
        DrvInfo.Sch := '\';
        DrvInfo.FileHandle := FHandle;
        DrvInfo.ExtractInternal := True;

      end
      else
      begin
        FileClose(Fhandle);
        FHandle := 0;
        Result := -3;
        ErrInfo.Format := 'CBF1';
        ErrInfo.Games := 'Vietcong, Vietcong 2';
      end;
    finally
      FreeAndNil(InFile);
      FreeAndNil(Entry);
    end;
  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Warlords Battlecry .XCR support ========================================== //
// -------------------------------------------------------------------------- //

type XCR_Header = packed record
       ID: array[0..12] of char;
       Empty: array[1..7] of Byte;
       DirNum: integer;
       FilSize: integer;
     end;
     XCR_Entry = packed record
       Filename: array[0..255] of char;
       FilenameDir: array[0..255] of char;
       Offset: integer;
       Size: integer;
       Unknown: array[1..12] of Byte;
     end;

function ReadWarlordsBattlecryXCR(src: string): Integer;
var HDR: XCR_Header;
    ENT: XCR_Entry;
    NumE,x : integer;
    nam: string;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR.ID, 13);
    FileRead(FHandle, HDR.Empty, 7);
    FileRead(FHandle, HDR.DirNum, 4);
    FileRead(FHandle, HDR.FilSize, 4);

    if (HDR.ID <> 'xcr File 1.00') or (HDR.FilSize <> TotFSize) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'XCR';
      ErrInfo.Games := 'Warlords Battlecry, Warlords Battlecry 2';
    end
    else
    begin

      NumE := HDR.DirNum;

      for x := 1 to NumE do
      begin
        FileRead(FHandle,ENT.Filename,256);
        FileRead(FHandle,ENT.FilenameDir,256);
        FileRead(FHandle,ENT.Offset,4);
        FileRead(FHandle,ENT.Size,4);
        FileRead(FHandle,ENT.Unknown, 12);

        nam := Strip0(ENT.FilenameDir);

        if MidStr(nam,2,2) = ':\' then
          nam := RightStr(nam,length(nam)-3);

        FSE_Add(nam,ENT.Offset,ENT.Size,0,0);

      end;

      Result := NumE;

      DrvInfo.ID := 'XCR';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// West Wood .MIX support =================================================== //
// -------------------------------------------------------------------------- //

type WestwoodMIX_Header = packed record
       NumFiles: Word;
       Size: cardinal;
     end;
     WestwoodMIX_Entry = packed record
       ID: cardinal;
       offset: cardinal;
       size: cardinal;
     end;
     WestwoodMIX_IDNames = record
       Names: array of string;
       Hash1: array of cardinal;
       Hash2: array of cardinal;
       Size: cardinal;
       SourceAge: integer;
       SourceSize: cardinal;
     end;
     WestwoodMIX_SHP_Header = packed record
       NumImages: word;    {Number of images}
       A,B: word;    {Unknown}
       Width, Height: word;    {Width and Height of the images}
       C: longint; {Unknown}
     end;
     WestwoodMIX_SHP_Entry = packed record
       Offset  : cardinal;  {Offset and format of image in file}
       RefOffs : cardinal;  {Offset and format of image on which it is based}
     end;

type WestwoodMIX_DBHeader = packed record
       ID: array[0..3] of char;
       Eof: byte;
       Version: byte;
       Empty: word;
       SourceDate: integer;
       SourceSize: cardinal;
       NumEntries: cardinal;
     end;

const WSMIX_DB_ID = 'DMD';
      WSMIX_DBS_ID = WSMIX_DB_ID+'S';
      WSMIX_DB1_ID = WSMIX_DB_ID+'1';
      WSMIX_DB2_ID = WSMIX_DB_ID+'2';
      WSMIX_DB_VER = 1;
      WSMIX_DB_EOF = 26;

var MIXNames: WestwoodMIX_IDNames;
    MIXNamesLoaded: boolean = false;

function getRedAlertAndTiberianSunID(name: string): cardinal;
var i, l: cardinal;
    a: integer;
begin

  l := length(name);
  name := uppercase(name);

  a := l shr 2;

  if (l and 3) > 0 then
  begin
    name := name + chr(l - (a shl 2));
    i := 3 - (l and 3);
    while i > 0 do
    begin
      dec(i);
      name := name + name[(a shl 2)+1];
    end;
  end;

  result := GetStrCRC32(name);

end;

function getCommandAndConquerID(name: string): cardinal;
var a, i, j, l, id: cardinal;
begin

  i := 1;
  id := 0;
  l := length(name);
  name := uppercase(name);

  while (i <= l) do
  begin
    a := 0;
    for j := 0 to 3 do
    begin
      a := a shr 8;
      if (i <= l) then
      begin
        inc(a,cardinal(ord(name[i])) shl 24);
        inc(i);
      end;
    end;
    id := (id shl 1) or (id shr 31) +a;
  end;

  result := id;

end;

function findNameByID(ID: cardinal; RAorTS: boolean = false): string;
var x: integer;
    found: boolean;
begin

  result := inttohex(ID,8);
  found := false;

  if MIXNamesLoaded then
  begin
    for x := 0 to MIXNames.Size - 1 do
    begin
      if (not(RAorTS) and (ID = MIXNames.Hash1[x]))
      or ((RAorTS) and (ID = MIXNames.Hash2[x])) then
      begin
        if not(found) then
          result := '';
        result := result + MIXNames.Names[x];
//        exit;
      end;
    end;
  end;

end;

function GetFSize(filnam: string): Int64;
var
  sr : TSearchRec;
begin

  if FindFirst(filNam, faAnyFile, sr ) = 0 then
     result := Int64(sr.FindData.nFileSizeHigh) shl Int64(32) + Int64(sr.FindData.nFileSizeLow)
  else
     result := -1;

  FindClose(sr) ;

end;

function createWestWoodMIXDatabase: boolean;
var LstFile: TextFile;
    Line: String;
    DBNameNum, x: Cardinal;
    Buffer: TMemoryStream;
    HDR: WestwoodMIX_DBHeader;
    Per, Empty: byte;
    UpdateTrigger, UpdateCount: cardinal;
const DBINCNUM = 10000;
begin

  result := false;

  if FileExists(CurPath+'drv_default_mix.lst') then
  begin

    try
      FillChar(HDR,SizeOf(WestwoodMIX_DBHeader),0);

      AssignFile(LstFile, CurPath+'drv_default_mix.lst');
      Reset(LstFile);

      DBNameNum := 0;
      while not(Eof(LstFile)) do
      begin
        Readln(LstFile, Line);
        Line := Trim(Line);
        if (Line[1] <> '/') and (Line[2] <> '/') then
        begin
          if Length(MIXNames.Names) < (DBNameNum + 1) then
          SetLength(MIXNames.Names,length(MIXNames.Names)+DBINCNUM);
          MIXNames.Names[DBNameNum] := Line;
          Inc(DBNameNum);
        end;
      end;
      CloseFile(LstFile);

      MIXNames.Size := DBNameNum;

      setLength(MIXNames.Names,MIXNames.Size);
      setLength(MIXNames.Hash1,MIXNames.Size);
      setLength(MIXNames.Hash2,MIXNames.Size);

      Buffer := TMemoryStream.Create;

      HDR.ID := WSMIX_DBS_ID;
      HDR.Eof := WSMIX_DB_EOF;
      HDR.Version := WSMIX_DB_VER;
      HDR.SourceDate := FileAge(CurPath+'drv_default_mix.lst');
      HDR.SourceSize := GetFSize(CurPath+'drv_default_mix.lst');
      HDR.NumEntries := DBNameNum;

      MIXNames.SourceAge := HDR.SourceDate;
      MIXNames.SourceSize := HDR.SourceSize;

      Buffer.WriteBuffer(HDR,SizeOf(WestwoodMIX_DBHeader));

      Empty := 0;
      UpdateTrigger := DBNameNum div 33;
      UpdateCount := 0;
      Per := 0;
      SetPercent(0);
      for x := 0 to DBNameNum - 1 do
      begin
        Buffer.WriteBuffer(MIXNames.Names[x][1],Length(MIXNames.Names[x]));
        Buffer.WriteBuffer(Empty,1);
        inc(UpdateCount);
        if UpdateCount = UpdateTrigger then
        begin
          UpdateCount := 0;
          Inc(Per);
          SetPercent(Per);
        end;
      end;

      Buffer.SaveToFile(CurPath+'drv_default_mix.dbs');

      result := true;
      MIXNamesLoaded := true;

    finally
      if Buffer <> Nil then
        FreeAndNil(Buffer);
    end;

  end;

end;

procedure dumpWestWoodMIX_XCCDatabase;
var XCCDATFile: TFileStream;
    Buffer: TMemoryStream;
    NumE: integer;
    DBNameNum, x: cardinal;
    DBNameString: array of string;
    Per, OldPer: byte;
    CrLf: array[0..1] of char;
begin

  if FileExists(CurPath+'global mix database.dat') then
  begin

    try

      XCCDATFile := TFileStream.Create(CurPath+'global mix database.dat',fmOpenRead or fmShareDenyWrite);
      Buffer := TMemoryStream.Create;

      Buffer.CopyFrom(XCCDATFile,XCCDATFile.Size);
      Buffer.Seek(0,0);

      DBNameNum := 0;
      OldPer := 0;
      SetPercent(0);
      while (Buffer.Seek(0,1) < Buffer.Size) do
      begin
        Per := Round((Buffer.Seek(0,1) / Buffer.Size)*100);
        if Per >= OldPer + 1 then
        begin
          SetPercent(Per);
          OldPer := Per;
        end;
        Buffer.ReadBuffer(NumE,4);
        SetLength(DBNameString,DBNameNum+NumE);
//        SetLength(DBNameHash1,DBNameNum+NumE);
//        SetLength(DBNameHash2,DBNameNum+NumE);
        for x := 0 to NumE-1 do
        begin
          DBNameString[DBNameNum+x] := Strip0(Get0(Buffer));
//          DBNameHash1[DBNameNum+x] := getCommandAndConquerID(DBNameString[DBNameNum+x]);
//          DBNameHash2[DBNameNum+x] := getRedAlertAndTiberianSunID(DBNameString[DBNameNum+x]);
          // Useless description
          Get0(Buffer);
        end;
        inc(DBNameNum,NumE);
      end;

      Buffer.Clear;

      CrLf := chr(13)+chr(10);
      for x := 0 to DBNameNum - 1 do
      begin
        Buffer.WriteBuffer(DBNameString[x][1],Length(DBNameString[x]));
        Buffer.WriteBuffer(CrLf,2);
      end;

      Buffer.SaveToFile(CurPath+'global mix database.txt');

    finally

      if XCCDATFile <> nil then
        FreeAndNil(XCCDATFile);
      if Buffer <> nil then
        FreeAndNil(Buffer);

    end;
  end;

end;

function loadWestWoodMIXDatabase: boolean;
var DATFile: TFileStream;
    Buffer: TMemoryStream;
    x: cardinal;
    CreateHashDB,SkipLoadStringDB: boolean;
    DBSHDR, DB1HDR, DB2HDR: WestwoodMIX_DBHeader;
    Per: Byte;
    UpdateTrigger, UpdateCount: cardinal;
    SourceAge: integer;
    SourceSize: cardinal;
begin

  if FileExists(CurPath+'drv_default_mix.dbs') or FileExists(CurPath+'drv_default_mix.lst') then
  begin

    try

      Buffer := TMemorystream.Create;

      if FileExists(CurPath+'drv_default_mix.dbs') then
      begin

        DATFile := TFileStream.Create(CurPath+'drv_default_mix.dbs',fmOpenRead or fmShareDenyWrite);

        Buffer.CopyFrom(DATFile,DATFile.Size);
        FreeAndNil(DATFile);

        Buffer.Seek(0,0);

        Buffer.ReadBuffer(DBSHDR,SizeOf(WestwoodMIX_DBHeader));

        SkipLoadStringDB := false;

        SourceAge := FileAge(CurPath+'drv_default_mix.lst');
        SourceSize := GetFSize(CurPath+'drv_default_mix.lst');
        // Sanity checks
        if (DBSHDR.ID <> WSMIX_DBS_ID) or (DBSHDR.Eof <> 26)
        or (DBSHDR.Version <> WSMIX_DB_VER) or (DBSHDR.Empty <> 0)
        // If source file has changed Database needs to be rebuilded
        or (SourceAge <> DBSHDR.SourceDate)
        or (SourceSize <> DBSHDR.SourceSize) then
        begin
          if not(createWestWoodMIXDatabase) then
          begin
            result := false;
            exit;
          end;
          SkipLoadStringDB := true;
        end;

        if not(SkipLoadStringDB) then
        begin

          // If data is already loaded, no need to do it again
          if (MIXNames.SourceAge = SourceAge)
          and (MIXNames.SourceSize = SourceSize) then
          begin
            result := true;
            exit;
          end;

          MIXNames.SourceAge := SourceAge;
          MIXNames.SourceSize := SourceSize;

          MIXNames.Size := DBSHDR.NumEntries;

          setLength(MIXNames.Names,MIXNames.Size);
          setLength(MIXNames.Hash1,MIXNames.Size);
          setLength(MIXNames.Hash2,MIXNames.Size);

          UpdateTrigger := (MIXNames.Size - 1) div 33;
          Per := 0;
          Updatecount := 0;
          for x := 0 to MIXNames.Size - 1 do
          begin
            MIXNames.Names[x] := Strip0(Get0(Buffer));
            if (Buffer.Seek(0,1) > Buffer.Size) then
            begin
              result := false;
              exit;
            end;
            Inc(UpdateCount);
            if UpdateCount = UpdateTrigger then
            begin
              UpdateCount := 0;
              Inc(Per);
              SetPercent(Per);
            end;
          end;
        end;

        Buffer.Clear;

      end
      else if not(createWestWoodMIXDatabase) then
      begin
        result := false;
        exit;
      end;

      CreateHashDB := not(FileExists(CurPath+'drv_default_mix.db1'));

      if not(CreateHashDB) then
      begin

        DATFile := TFileStream.Create(CurPath+'drv_default_mix.db1',fmOpenRead or fmShareDenyWrite);

        Buffer.CopyFrom(DATFile,DATFile.Size);
        Buffer.Seek(0,0);

        Buffer.ReadBuffer(DB1HDR,SizeOf(WestwoodMIX_DBHeader));

        // Create the Hash DB if sanity checks fail
        CreateHashDB := (DB1HDR.ID <> WSMIX_DB1_ID) or (DB1HDR.Eof <> 26)
                     or (DB1HDR.Version <> WSMIX_DB_VER) or (DB1HDR.Empty <> 0)
        // or if string DB has changed and Hash DB needs to be rebuilded
                     or (DB1HDR.SourceDate <> MIXNames.SourceAge)
                     or (DB1HDR.SourceSize <> MIXNames.SourceSize);

        if not(CreateHashDB) then
        begin

          try
            for x := 0 to MIXNames.Size - 1 do
              Buffer.ReadBuffer(MIXNames.Hash1[x],4);
          except
            on E: Exception do
              CreateHashDB := true;
          end;

        end;

        FreeAndNil(DATFile);
        Buffer.Clear;

      end;

      if CreateHashDB then
      begin

        if FileExists(CurPath+'drv_default_mix.db1') then
          DeleteFile(CurPath+'drv_default_mix.db1');

        FillChar(DB1HDR,SizeOf(WestwoodMIX_DBHeader),0);
        DB1HDR.ID := WSMIX_DB1_ID;
        DB1HDR.Eof := WSMIX_DB_EOF;
        DB1HDR.Version := WSMIX_DB_VER;
        DB1HDR.SourceDate := DBSHDR.SourceDate;
        DB1HDR.SourceSize := DBSHDR.SourceSize;
        DB1HDR.NumEntries := DBSHDR.NumEntries;

        Buffer.WriteBuffer(DB1HDR,SizeOf(WestwoodMIX_DBHeader));

        Per := 33;
        Updatecount := 0;
        UpdateTrigger := (MIXNames.Size - 1) div 33;
        for x := 0 to MIXNames.Size - 1 do
        begin
          MIXNames.Hash1[x] := getCommandAndConquerID(MIXNames.Names[x]);
          Buffer.WriteBuffer(MIXNames.Hash1[x],4);
          inc(UpdateCount);
          if UpdateCount = UpdateTrigger then
          begin
            UpdateCount := 0;
            Inc(Per);
            SetPercent(Per);
          end;
        end;

        Buffer.SaveToFile(CurPath+'drv_default_mix.db1');

        Buffer.Clear;
        
      end;

      FreeAndNil(DATFile);

      CreateHashDB := not(FileExists(CurPath+'drv_default_mix.db2'));

      if not(CreateHashDB) then
      begin

        DATFile := TFileStream.Create(CurPath+'drv_default_mix.db2',fmOpenRead or fmShareDenyWrite);

        Buffer.CopyFrom(DATFile,DATFile.Size);
        Buffer.Seek(0,0);

        Buffer.ReadBuffer(DB2HDR,SizeOf(WestwoodMIX_DBHeader));

        // Create the Hash DB if sanity checks fail
        CreateHashDB := (DB2HDR.ID <> WSMIX_DB2_ID) or (DB2HDR.Eof <> 26)
                     or (DB2HDR.Version <> WSMIX_DB_VER) or (DB2HDR.Empty <> 0)
        // or if string DB has changed and Hash DB needs to be rebuilded
                     or (DB2HDR.SourceDate <> MIXNames.SourceAge)
                     or (DB2HDR.SourceSize <> MIXNames.SourceSize);

        if not(CreateHashDB) then
        begin

          try
            for x := 0 to MIXNames.Size - 1 do
              Buffer.ReadBuffer(MIXNames.Hash2[x],4);
          except
            on E: Exception do
              CreateHashDB := true;
          end;

        end;

        FreeAndNil(DATFile);
        Buffer.Clear;

      end;

      if CreateHashDB then
      begin

        if FileExists(CurPath+'drv_default_mix.db2') then
          DeleteFile(CurPath+'drv_default_mix.db2');

        FillChar(DB2HDR,SizeOf(WestwoodMIX_DBHeader),0);
        DB2HDR.ID := WSMIX_DB2_ID;
        DB2HDR.Eof := WSMIX_DB_EOF;
        DB2HDR.Version := WSMIX_DB_VER;
        DB2HDR.SourceDate := DBSHDR.SourceDate;
        DB2HDR.SourceSize := DBSHDR.SourceSize;
        DB2HDR.NumEntries := DBSHDR.NumEntries;

        Buffer.WriteBuffer(DB2HDR,SizeOf(WestwoodMIX_DBHeader));

        UpdateTrigger := (MIXNames.Size - 1) div 33;
        Per := 66;
        UpdateCount := 0;
        for x := 0 to MIXNames.Size - 1 do
        begin
          MIXNames.Hash2[x] := getRedAlertAndTiberianSunID(MIXNames.Names[x]);
          Buffer.WriteBuffer(MIXNames.Hash2[x],4);
          inc(UpdateCount);
          if UpdateCount = UpdateTrigger then
          begin
            UpdateCount := 0;
            Inc(Per);
            SetPercent(Per);
          end;
        end;

        Buffer.SaveToFile(CurPath+'drv_default_mix.db2');

        Buffer.Clear;
        
      end;

      MIXNamesLoaded := true;
      Result := MIXNamesLoaded;

      FreeAndNil(DATFile);

    finally

      if DATFile <> nil then
        FreeAndNil(DATFile);
      if Buffer <> nil then
        FreeAndNil(Buffer);

    end;

  end;

end;

function GetWestwoodMIXExt(srcHandle: integer; offset, size: integer): string;
var curOffset: integer;
    Char4: array[0..3] of char;
    Char8: array[0..7] of char;
    Char12: array[0..11] of char;
    Num4, Num4b, x: cardinal;
    Num2: word;
    Num1: byte;
    SHP_HDR: WestwoodMIX_SHP_Header;
    SHP_ENT: WestwoodMIX_SHP_Entry;
    IsSHP: boolean;
begin

  result := '';
  curOffset := FileSeek(srcHandle,0,1);
  FileSeek(srcHandle,offset,0);

  FileRead(srcHandle,Char4,4);

  if Char4 = 'FORM' then
  begin
    FileSeek(srcHandle,4,1);
    FileRead(srcHandle,Char8,8);
    if Char8 = 'WVQAVQHD' then
      result := '.vqa';
  end;
  if (result = '') and (Char4 = 'Voxe') then
  begin
    FileSeek(srcHandle,Offset+4,0);
    FileRead(srcHandle,Char12,12);
    if Char12 = 'l Animation' then
      result := '.vxl';
  end;
  if (result = '') then
  begin
    Fileseek(srcHandle,offset,0);
    Fileread(srcHandle,Num2,2);
    if (Num2 = Size) then
    begin
      Fileread(srcHandle,Num2,2);
      if Num2 = $0500 then
      begin
        Fileread(srcHandle,Num2,2);
        if Num2 = $000E then
        begin
          Fileread(srcHandle,Num2,2);
          if Num2 = $0014 then
            result := '.fnt';
        end;
      end;
    end
    else if (Num2 = (Size-2)) then
    begin
      Fileread(srcHandle,Num2,2);
      if Num2 = $0004 then
      begin
        Fileread(srcHandle,Num2,2);
        if Num2 = $FA00 then
          result := '.cps';
      end;
    end;
    if result = '' then
    begin
      Fileseek(srcHandle,offset+2,0);
      Fileread(srcHandle,Num4,4);
      if (Num2 <= 44100) and ((Num4+12) = Size) then
      begin
        Fileread(srcHandle,Num4b,4);
        if (Num4b >= Num4) then
        begin
          FileSeek(srcHandle,1,1);
          Fileread(srcHandle,Num1,1);
          if (Num1 = 0) or (Num1 = 1) or (Num1 = 99) then
            result := '.aud';
        end;
      end;
      if result = '' then
      begin
        Fileseek(srcHandle,offset+8,0);
        Fileread(srcHandle,Num4,4);
        if Num4 = 48 then
        begin
          Fileread(srcHandle,Num4,4);
          if Num4 = 24 then
            result := '.tmp';
        end;
      end;
    end;
  end;

  if (result = '') then
  begin
    FileSeek(srcHandle,Offset,0);
    FileRead(srcHandle,SHP_HDR,SizeOf(WestwoodMIX_SHP_Header));
    if (SHP_HDR.NumImages > 0) then
    begin
      IsSHP := true;
      for x := 0 to SHP_HDR.NumImages-1 do
      begin
        FileRead(srcHandle,SHP_ENT,SizeOf(WestwoodMIX_SHP_Entry));
        IsSHP := IsSHP and (((SHP_ENT.Offset and $00FFFFFF)<Size))
                       and ( (((SHP_ENT.offset and $FF000000) = $80000000) and (SHP_ENT.RefOffs = 0) )
                        or   (((SHP_ENT.offset and $FF000000) = $40000000) and ((SHP_ENT.RefOffs and $00FFFFFF)<Size) )
                        or   (((SHP_ENT.offset and $FF000000) = $20000000) and ((SHP_ENT.RefOffs and $FF000000) = $48000000) )
                        or   ((SHP_ENT.offset and $FF000000) = 0));
      end;
      if IsSHP then
        result := '.shp';
    end;
    if (result = '') and (size = 768) then
      result := '.pal';
  end;

  FileSeek(srcHandle,curOffset,0);

end;

function readWestWoodMIX(fil: string): integer;
var HDR: WestwoodMIX_Header;
    ENT: WestwoodMIX_Entry;
//    Flag: cardinal;    // For encrypted MIX files (unsupported yet)
    x, BodyOffset: cardinal;
    Per, OldPer: byte;
    disp: string;
begin

  Fhandle := FileOpen(fil, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
//    FileRead(FHandle,Flag,4);
    FileRead(FHandle, HDR, Sizeof(WestwoodMIX_Header));

    if (HDR.NumFiles = 0) or ((HDR.Size + HDR.NumFiles*12 + 6) <> TotFSize) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'MIX';
      ErrInfo.Games := 'Command & Conquer';
    end
    else
    begin

      // Load filenames Database and generate IDs
      // Database will be created if needed
      loadWestWoodMIXDatabase;
      // In any case if database is not loaded the name will be the hexa ID

      OldPer := 0;
      BodyOffset := (HdR.NumFiles * 12) + 6;

      for x := 1 to HDR.NumFiles do
      begin

        FileRead(FHandle,ENT,SizeOf(WestwoodMIX_Entry));
        disp := findNameByID(ENT.ID);
        if pos('.',disp) = 0 then
          disp := disp + GetWestwoodMIXExt(FHandle,ENT.offset+BodyOffset,ENT.size);
        FSE_Add(disp,ENT.offset+BodyOffset,ENT.size,0,0);
        Per := Round((x / HDR.NumFiles)*100);
        if Per >= OldPer + 1 then
        begin
          SetPercent(Per);
          OldPer := Per;
        end;

      end;

      Result := HDR.NumFiles;

      DrvInfo.ID := 'MIX';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// West Wood .PAK support =================================================== //
// -------------------------------------------------------------------------- //

function ReadWestWoodPAK(): Integer;
var disp: string;
    NumE: integer;
    Offset, OldOffset, FileSize, TotSize: integer;
    pakerr: boolean;
begin

  TotSize := FileSeek(FHandle, 0,2);
  FileSeek(Fhandle, 0, 0);
  NumE := 0;
  OldOffset := 0;

  repeat
    FileRead(FHandle, Offset, 4);
    // Felix Riemann / dup5-westwood-pak-mix-detection-fix.patch / START //
    // REMOVED // pakerr := ((Offset < OldOffset) and (Offset <> 0));
    pakerr := (((Offset < OldOffset) or (OffSet > TotSize)) and (Offset <> 0));
    // Felix Riemann / dup5-westwood-pak-mix-detection-fix.patch / END //
    if not(pakerr) then
    begin
      if (OldOffset > 0) then
      begin
        if Offset = 0 then
          FileSize := TotSize - OldOffset
        else
          FileSize := Offset - OldOffset;
        Inc(NumE);
        FSE_add(disp,OldOffset,FileSize,0,0);
      end;
      if ((Offset > 0) and (TotSize > Offset)) then
        disp := strip0(get0(Fhandle));
    end;
    OldOffset := offset;
  until ((Offset = 0) or (TotSize = Offset) or pakerr);

  if not(pakerr) then
  begin

    ReadWestWoodPAK := NumE;

    DrvInfo.ID := 'WWPAK';
    DrvInfo.Sch := '';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end
  else
    ReadWestWoodPAK := -3;

end;

// -------------------------------------------------------------------------- //
// Worms Armageddon .DIR support ============================================ //
// -------------------------------------------------------------------------- //

type WADIR_Header = packed record
       ID: array[0..3] of char;
       FileSize: integer;
       DirOffset: integer;
     end;
     WADIR_Entry = packed record
       Filename: array[0..29] of char;
       Offset: integer;
       Size: integer;
     end;

function ReadWormsArmageddonDIR(src: string): Integer;
var HDR: WADIR_Header;
    ENT: WADIR_Entry;
    NumE: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR.ID, 4);
    FileRead(FHandle, HDR.FileSize, 4);
    FileRead(FHandle, HDR.DirOffset, 4);

    if (HDR.ID <> ('DIR'+#26)) or (HDR.FileSize <> TotFSize) then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'DIR';
      ErrInfo.Games := 'Worms Armageddon';
    end
    else
    begin

      FileSeek(FHandle, HDR.DirOffset + 4104, 0);

      NumE := 0;

      while (FIleSeek(FHandle, 0,1) < TotFSize) do
      begin
        FileRead(FHandle,ENT.Filename,30);
        FileRead(FHandle,ENT.Offset,4);
        FileRead(FHandle,ENT.Size,4);
      end;

//      NumE := HDR.DirNum;

{      for x := 1 to NumE do
      begin
        FileRead(FHandle,ENT.Filename,256);
        FileRead(FHandle,ENT.Offset,4);
        FileRead(FHandle,ENT.Size,4);
//        FileRead(FHandle,ENT.Unknown, 12);

        nam := Strip0(ENT.FilenameDir);

        if MidStr(nam,2,2) = ':\' then
          nam := RightStr(nam,length(nam)-3);

        FSE_Add(nam,ENT.Offset,ENT.Size,0,0);

      end;
 }
      Result := NumE;

      DrvInfo.ID := 'DIR';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

// -------------------------------------------------------------------------- //
// Zanzarah .PAK support ==================================================== //
// -------------------------------------------------------------------------- //

function ReadZanzarahPAK(): Integer;
var disp: string;
    NumE: integer;
    Offset, x, FileSize, PlusOffset: integer;
begin

  FileSeek(Fhandle, 4, 0);
  FileRead(Fhandle,numE,4);

  if (NumE > 0) then
  begin
    for x := 1 to numE do
    begin
      disp := get32(FHandle);
      FileRead(FHandle,Offset,4);
      FileRead(FHandle,FileSize,4);
      if (LeftStr(disp,3) = '..\') then
        disp := RightStr(disp,length(disp)-3);
      FSE_add(disp,Offset,FileSize,0,0);
    end;

    PlusOffset := FileSeek(FHandle, 0,1)+4;
    FSE_updateOffsets(PlusOffset);

    Result := NumE;

    DrvInfo.ID := 'ZPAK';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end
  else
    Result := -3;

end;

// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //

function ReadHubBAR(src: String): Integer;
var ID: array[0..3] of char;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,4);
    if ID = 'ESPN' then
      res := ReadAgeOfEmpires3BAR
    else
      res := ReadAgeOfMythologyBAR;

    if res = -3 then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'BAR';
      ErrInfo.Games := 'Age of Mythology, Age of Empires 3';
    end
    else
      Result := res;
  end
  else
    Result := -2;

end;

function ReadHubBIG(src: String): Integer;
var ID: array[0..3] of char;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,4);
    if ID = 'BIGF' then
      res := ReadCommandAndConquerGeneralsBIG
    else if ID = 'BIGB' then
      res := ReadFableTheLostChaptersBIG
    else
      res := -3;

    if res = -3 then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'BIG';
      ErrInfo.Games := 'Command & Conquer: Generals, Fable: The Lost Chapters';
    end
    else
      Result := res;
  end
  else
    Result := -2;

end;

function ReadHubDAT(src: String): Integer;
var ID: array[0..7] of char;
    res,test1,test2,test3: integer;
    test4,test5: word;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,8);
    if ID = 'FILECHNK' then
      res := ReadGunlokDAT
    else if leftstr(ID,4) = 'edat' then
      res := ReadActOfWarDAT
    else
    begin
      TotFSize := FileSeek(FHandle,0,2);
      FileSeek(FHandle,0,0);
      FileRead(FHandle,test1,4);
      FileRead(FHandle,test2,4);
      if ((test1+test2) = TotFSize) then
      begin
        FileSeek(FHandle,test1,0);
        FileRead(FHandle,test3,4);
        if test3 = -1 then
          res := ReadLegoStarWarsDAT
        else
          res := ReadNascarDAT;
      end
      else if test1+8 < TotFSize then
      begin
//        FileRead(FHandle,test3,4);
        FileSeek(FHandle,test1,0);
        fileRead(FHandle,test4,2);
        FileSeek(FHandle,4,1);
        fileRead(FHandle,test5,2);
        // Checks to try to be sure this is an F-22 ADF/TAW or EF2000 .DAT (DID)
        // test1 should be offset to directory
        // test4 should be number of entries (one entry is 3 integers therefore 12 bytes)
        // test5 should be the size of the name dir
        // Therefore if we do the calculation the result should be under the total file size
        // test2 seems to be always the same value for the 3 .dat files of F-22 ADF/TAW I inspected ($50001)
        //       and for EF2000 it seems to be $2004152
        // This is dirty but can avoid wrong identifications
        if ((test1+(test4*12)+test5+8) <= TotFSize) and ((test2 = $50001) or (test2 = $2004152)) then
          res := ReadF22adfDAT
        else
          res := ReadNascarDAT;
      end
      else
        res := ReadNascarDAT;
    end;

    if res = -3 then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadHubDAT := -3;
      ErrInfo.Format := 'DAT';
      ErrInfo.Games := 'Gunlok, LEGO Star Wars, Nascar Racing, ..';
    end
    else
      ReadHubDAT := res;
  end
  else
    ReadHubDAT := -2;

end;

function ReadHubGJD(src: String): Integer;
var compagnonFile: string;
    res: integer;
begin

  compagnonFile := ChangeFileExt(src,'.rl');

  if fileexists(compagnonFile) then
    res := Read7thGuestGJD(src,compagnonFile)
  else
    res := Read11thHourGJD(src);

  Result := res;
  
  if res = -3 then
  begin
    FHandle := 0;
    ErrInfo.Format := 'GJD';
    ErrInfo.Games := 'The 7th Guest & The 11th Hour';
  end;

end;

function ReadHubGOB(src: String): Integer;
var ID: array[0..3] of char;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,4);
    if ID = ('GOB'+#10) then
      res := ReadDarkForcesGOB
    else if ID = ('GOB ') then
      res := ReadIndianaJones3dGOB
    else
      res := -3;

    if res = -3 then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadHubGOB := -3;
      ErrInfo.Format := 'GOB';
      ErrInfo.Games := 'Dark Forces, Indiana Jones 3D, ..';
    end
    else
      ReadHubGOB := res;
  end
  else
    ReadHubGOB := -2;

end;

function ReadHubRES(src: String): Integer;
var ID: array[0..3] of char;
    IDI: integer;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,4);
    FileSeek(FHandle,0,0);
    FileRead(FHandle,IDI,4);
    if ID = '&YA1' then
      res := ReadRageOfMages2RES
    else if (IntToHex(IDI,7) = '19CE23C') then
      res := ReadEvilIslandsRES
    else
      res := ReadPixelPaintersRES;

    if res = -3 then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'RES';
      ErrInfo.Games := 'Evil Island, Rage of Mages, Rage of Mages 2';
    end
    else
      Result := res;
  end
  else
    Result := -2;

end;

function ReadHubPAK(src: String): Integer;
var ID: array[0..3] of char;
    ID12: array[0..11] of char;
    ID15: array[0..14] of char;
    ID18: array[0..17] of char;
    ID21P4: array[0..20] of char;
    res,Test1,Test3,testpko,FSize: integer;
    Test2: Word;
    testpk: byte;
    mixtest1: word;
    mixtest2,mixtest3: cardinal;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,4);
    FSize := FileSeek(FHandle,0,2);
    FileSeek(FHandle,0,4);
    FileRead(FHandle,ID21P4,21);
    // Check if Dreamfall: TLJ .PAK
    FileSeek(Fhandle,0,0);
    FileRead(FHandle,ID12,12);
    FileSeek(Fhandle,0,0);
    FileRead(FHandle,ID15,15);
    FileSeek(Fhandle,0,0);
    FileRead(FHandle,ID18,18);
    FileSeek(FHandle,0,0);
    FileRead(Fhandle,testpk,1);
    FileRead(Fhandle,testpko,4);
    FileSeek(FHandle,0,0);
    FileRead(FHandle,Test2,2);
    FileRead(FHandle,Test1,4);
    FileSeek(FHandle,0,0);
    FileRead(FHandle,Test3,4);
    FileSeek(FHandle,0,0);
    FileRead(FHandle,mixtest1,2);
    FileRead(FHandle,mixtest2,4);
    FileSeek(FHandle,0,0);
    FileRead(FHandle,mixtest3,4);
    if ID = 'PACK' then
      res := ReadQuakePAK
    else if ID = 'PAK'+#1 then
      res := ReadBattleforgePAK
    else if ID = 'KAPL' then
      res := ReadTheSecretOfMonkeyIslandSEKAPL
//    else if ID = 'PAK!' then
//      res := ReadAvatarPAK
    else if ID12 = 'tlj_pack0001' then
      res := ReadDreamfallTLJPAK(src)
    else if (ID21P4 = 'MASSIVE PAKFILE V 4.0') then
      res := ReadSpellforcePAK
    else if (ID15 = StarWarsStarfighterMagicID) then
      res := ReadStarWarsStarfighterPAK
    else if (ID18 = 'tongas_pack_v30000') then
      res := ReadGhostbustersSoSPAK
    else if ((mixtest1 = 0) and ((mixtest3 = $20000) or (mixtest3 = $30000)))
         or ((mixtest1 > 0) and ((mixtest2 + mixtest1*12 + 6) = FSize)) then
    begin
      FileClose(FHandle);
      res := ReadWestwoodMIX(src);
    end
    else if (ID[0] = #5) and (ID[1] = #0) and (ID[2] = #0) and (ID[3] = #0) then
      res := ReadTheMoviesPAK
    else if (ID[0] = #0) and (ID[1] = #0) and (ID[2] = #0) and (ID[3] = #0) then
      res := ReadZanzarahPAK
    else if checkFlorensiaPAK(FHandle) then
      res := ReadFlorensiaPAK
    else if ((testpk = 0) or (testpk = 1)) and (testpko <= FSize) and (testpko > 0) then
      res := ReadPainKillerPAK
    else if ((Test1 + Test2*12) <= FSize) and ((Test1 + Test2*12) > 0) then
    begin
      res := ReadStarCrusaderPAK(false);
      if (res < 0) then
      begin
        res := ReadWestWoodPAK
      end;
    end
    else
      res := ReadWestWoodPAK;

    if res = -3 then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadHubPAK := -3;
      ErrInfo.Format := 'PAK';
      ErrInfo.Games := 'Dune 2, Half-Life, Hooligans, Quake, Quake 2, Star Crusader, The Secret of Monkey Island SE, Trickstyle, Zanzarah, ..';
    end
    else
      ReadHubPAK := res;
  end
  else
    ReadHubPAK := -2;

end;

function ReadHubPOD(src: String): Integer;
var ID: array[0..3] of char;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,4);
    if (ID = 'POD3') or (ID = 'POD5') then
      res := ReadBloodRaynePOD
    else if ID = 'POD2' then
      res := ReadNocturnePOD
    else
      res := ReadTerminalVelocityPOD;

    if res = -3 then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'POD';
      ErrInfo.Games := 'BloodRayne, Nocturne, Terminal Velocity';
    end
    else
      Result := res;
  end
  else
    Result := -2;

end;

function ReadHubSTUFF(src: String): Integer;
var ID64: array[0..63] of char;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID64,64);
    if (ID64[0] = #1) and (ID64[1] = #0) and (ID64[2] = #0) and (ID64[3] = #0)
    and (ID64[4] = #0) and (ID64[5] = #0) and (ID64[6] = #0) and (ID64[7] = #0)
    and (ID64[8] = #0) and (ID64[9] = #0) and (ID64[10] = #0) and (ID64[11] = #0)
    and (ID64[12] = #0) and (ID64[13] = #0) and (ID64[14] = #0) and (ID64[15] = #0)
    and (ID64[16] = #0) and (ID64[17] = #0) and (ID64[18] = #0) and (ID64[19] = #0)
    and (ID64[20] = #0) and (ID64[21] = #0) and (ID64[22] = #0) and (ID64[23] = #0)
    and (ID64[24] = #0) and (ID64[25] = #0) and (ID64[26] = #0) and (ID64[27] = #0)
    and (ID64[28] = #0) and (ID64[29] = #0) and (ID64[30] = #0) and (ID64[31] = #0)
    and (ID64[32] = #0) and (ID64[33] = #0) and (ID64[34] = #0) and (ID64[35] = #0)
    and (ID64[36] = #0) and (ID64[37] = #0) and (ID64[38] = #0) and (ID64[39] = #0)
    and (ID64[40] = #0) and (ID64[41] = #0) and (ID64[42] = #0) and (ID64[43] = #0)
    and (ID64[44] = #0) and (ID64[45] = #0) and (ID64[46] = #0) and (ID64[47] = #0)
    and (ID64[48] = #0) and (ID64[49] = #0) and (ID64[50] = #0) and (ID64[51] = #0)
    and (ID64[52] = #0) and (ID64[53] = #0) and (ID64[54] = #0) and (ID64[55] = #0)
    and (ID64[56] = #0) and (ID64[57] = #0) and (ID64[58] = #0) and (ID64[59] = #0)
    and (ID64[60] = #0) and (ID64[61] = #0) and (ID64[62] = #0) and (ID64[63] = #0) then
      res := ReadBlackAndWhite2STUFF
    else
      res := ReadEveOnlineSTUFF;

    if res = -3 then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'STUFF';
      ErrInfo.Games := 'Eve Online, Black & White 2';
    end
    else
      Result := res;
  end
  else
    Result := -2;

end;

function ReadHubVOL(src: String): Integer;
var ID: array[0..3] of char;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,4);
    if ID = 'VOLN' then
      res := ReadEarthSiege2VOL
    else if ID = 'PVOL' then
      res := ReadStarsiegeTribesVOL
    else
      res := -3;

    if res = -3 then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'VOL';
      ErrInfo.Games := 'Earth Siege 2, Starsiege: Tribes';
    end
    else
      Result := res;
  end
  else
    Result := -2;

end;

function ReadHubWAD(src: String): Integer;
var ID: array[0..3] of char;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead or fmShareDenyWrite);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,4);
    if ID = 'DWFB' then
      res := ReadDungeonKeeper2DWFB
    else if (ID = 'DAWL') then
      res := ReadGeometryWars3DAWL
    else if (ID = 'WAD2') or (ID = 'WAD3') then
      res := ReadQuakeWAD2
    else
      res := -3;

    if res = -3 then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      ReadHubWAD := -3;
      ErrInfo.Format := 'WAD';
      ErrInfo.Games := 'Dungeon Keeper 2, Geometry Wars 3, Quake';
    end
    else
      ReadHubWAD := res;
  end
  else
    ReadHubWAD := -2;

end;

function ReadFormat(fil: ShortString; Deeper: boolean): Integer; stdcall;
var ext: string;
    ID4: array[0..3] of char;
    ID4Last: array[0..3] of char;
    ID6: array[0..5] of char;
    ID8: array[0..7] of char;
    ID12: array[0..11] of char;
    ID12SLF: array[0..11] of char;
    ID18: array[0..17] of char;
    ID21P4: array[0..20] of char;
    ID23: array[0..22] of char;
    ID28: array[0..27] of char;
    ID36: array[0..35] of char;
    ID127: array[0..126] of char;
    fsize: integer;
    mixtest1: word;
    mixtest2,mixtest3: cardinal;
begin

  SetPercent(0);

  ext := ExtractFileExt(fil);

  if ext <> '' then
    ext := copy(ext,2,length(ext)-1);

  ext := UpperCase(ext);

  if IsConsole then
    writeln('ReadFormat: '+fil+' ('+ext+')');

  Result := 0;

  if Deeper then
  begin

    FHandle := FileOpen(fil, fmOpenRead or fmShareDenyWrite);

    if FHandle > 0 then
    begin
      FileRead(FHandle,ID127,127);
      FSize := FileSeek(FHandle,0,2);
      FileSeek(FHandle,0,0);
      FileRead(FHandle,mixtest1,2);
      FileRead(FHandle,mixtest2,4);
      FileSeek(FHandle,0,0);
      FileRead(FHandle,mixtest3,4);
      FileSeek(FHandle,520,0);
      FileRead(FHandle,ID12SLF,12);
      FileSeek(FHandle,-4,2);
      FileRead(FHandle,ID4Last,4);

      // Copy values to the different magic IDs lengths
      Move(ID127[0],ID4,4);
      Move(ID127[0],ID8,8);
      Move(ID127[0],ID12,12);
      Move(ID127[0],ID18,18);
      Move(ID127[0],ID23,23);
      Move(ID127[0],ID28,28);
      Move(ID127[0],ID36,36);
      Move(ID127[4],ID21P4,21);

      if ID4 = ('GOB'+#10) then
        Result := ReadDarkForcesGOB
      else if ID12 = GRPID then
      begin
        FileClose(FHandle);
        Result := ReadDuke3DGRP(fil);
      end
      // Myst IV: Revelation .M4B file
      else if (ID23[0] = #11) and (ID23[1] = #0) and (ID23[2] = #0) and (ID23[3] = #0)
          and (ID23[4] = 'U') and (ID23[5] = 'B') and (ID23[6] = 'I') and (ID23[7] = '_')
          and (ID23[8] = 'B') and (ID23[9] = 'F') and (ID23[10] = '_') and (ID23[11] = 'S')
          and (ID23[12] = 'I') and (ID23[13] = 'G') and (ID23[14] = #0) then
      begin
        FileClose(Fhandle);
        Result := ReadMystIVRevelationM4B(fil);
      end
      // Alien vs Predator .ASR
      else if (ID8 = AsuraMagic) or (ID8 = AsuraZlbMagic) then
      begin
        FileClose(Fhandle);
        Result := ReadAvpAsura(fil);
      end
      // Black & White 2 .STUFF file (Everything.stuff)
      else if (ID127[0] = #1) and (ID127[1] = #0) and (ID127[2] = #0) and (ID127[3] = #0)
          and (ID127[4] = #0) and (ID127[5] = #0) and (ID127[6] = #0) and (ID127[7] = #0)
          and (ID127[8] = #0) and (ID127[9] = #0) and (ID127[10] = #0) and (ID127[11] = #0)
          and (ID127[12] = #0) and (ID127[13] = #0) and (ID127[14] = #0) and (ID127[15] = #0)
          and (ID127[16] = #0) and (ID127[17] = #0) and (ID127[18] = #0) and (ID127[19] = #0)
          and (ID127[20] = #0) and (ID127[21] = #0) and (ID127[22] = #0) and (ID127[23] = #0)
          and (ID127[24] = #0) and (ID127[25] = #0) and (ID127[26] = #0) and (ID127[27] = #0)
          and (ID127[28] = #0) and (ID127[29] = #0) and (ID127[30] = #0) and (ID127[31] = #0)
          and (ID127[32] = #0) and (ID127[33] = #0) and (ID127[34] = #0) and (ID127[35] = #0)
          and (ID127[36] = #0) and (ID127[37] = #0) and (ID127[38] = #0) and (ID127[39] = #0)
          and (ID127[40] = #0) and (ID127[41] = #0) and (ID127[42] = #0) and (ID127[43] = #0)
          and (ID127[44] = #0) and (ID127[45] = #0) and (ID127[46] = #0) and (ID127[47] = #0)
          and (ID127[48] = #0) and (ID127[49] = #0) and (ID127[50] = #0) and (ID127[51] = #0)
          and (ID127[52] = #0) and (ID127[53] = #0) and (ID127[54] = #0) and (ID127[55] = #0)
          and (ID127[56] = #0) and (ID127[57] = #0) and (ID127[58] = #0) and (ID127[59] = #0)
          and (ID127[60] = #0) and (ID127[61] = #0) and (ID127[62] = #0) and (ID127[63] = #0) then
        Result := ReadBlackAndWhite2STUFF
      else if (ID4[0] = #1) and (ID4[1] = #0) and (ID4[2] = #0) and (ID4[3] = #0)
           and (ID28[12] = 'R') and (ID28[13] = 'O') and (ID28[14] = 'O') and (ID28[15] = 'T') then
      begin
        FileClose(FHandle);
        Result := ReadNightFire007(fil);
      end
      // Artifex Mundi .CUB file
      else if (ID4[0] = #245) and (ID4[1] = #227) and (ID4[2] = #244) and (ID4[3] = #150) then
      begin
        FileClose(FHandle);
        Result := ReadArtifexMundiCUB(fil);
      end
      // Civilization 4 .FPK file
      else if (ID8[4] = 'F') and (ID8[5] = 'P') and (ID8[6] = 'K') and (ID8[7] = '_') then
      begin
        FileClose(FHandle);
        Result := ReadCivilization4FPK(fil);
      end
      // Entropia Universe .BNT file
      else if (ID4Last = 'BNT2') then
      begin
        FileClose(FHandle);
        Result := ReadEntropiaUniverseBNT(fil);
      end
      // The Witcher 2: Assassins of Kings .DZIP file
      else if (ID4 = 'DZIP') then
      begin
        FileClose(FHandle);
        Result := ReadTheWitcher2DZIP(fil);
      end
      // Hitman: Contracts .PRM file
      else if (ID4[0] = #30) and (ID4[1] = #7) and (ID4[2] = #0) and (ID4[3] = #0) then
      begin
        FileClose(FHandle);
        Result := ReadHitmanContractsPRM(fil);
      end
      // Fable: The Lost Chapter .BIG file
      else if (ID4 = 'BIGB') then
        Result := ReadFableTheLostChaptersBIG
      // F.E.A.R. .ARCH00 file
      else if (ID4 = 'LTAR') then
      begin
        FileClose(FHandle);
        Result := ReadFearARCH00(fil);
      end
      // Geometry Wars 3: Dimension Evolved .WAD file
      else if (ID4 = 'DAWL') then
        Result := ReadGeometryWars3DAWL
      // South Park: The Stick of Truth .OAF file
      else if (ID4 = 'OAF!') then
      begin
        FileClose(FHandle);
        Result := ReadSouthParkTheStickOfTruthOAF(fil);
      end
      // The Secret of Monkey Island: Special Edition .PAK file
      else if (ID4 = 'KAPL') then
        Result := ReadTheSecretOfMonkeyIslandSEKAPL
      // Dreamfall: The Longest Journey
      else if ID12 = 'tlj_pack0001' then
        Result := ReadDreamfallTLJPAK(fil)
      // AGON .SFL file
      else if (ID4 = 'SFL1') and (ID6[4] = '0') then
      begin
        Fileclose(Fhandle);
        Result := ReadAgonSFL(fil);
      end
      else if ID8 = 'LiOnHeAd' then
      begin
        FileClose(FHandle);
//        Result := ReadBlackAndWhiteSAD(fil);
        Result := ReadLionheadAudioBank(fil);
      end
      else if ID6 = 'LEMBOX' then
      begin
        FileClose(FHandle);
        Result := ReadLemmingsRevolutionBOX(fil);
      end
      else if ID4 = 'Dirt' then
      begin
        FileClose(FHandle);
        Result := ReadRealMystDNI(fil);
      end
      else if ID4 = ('GOB ') then
        Result := ReadIndianaJones3dGOB
      // Sinking Island/L'Ile Noyée .OPK
      else if ID4 = ('PAK ') then
      begin
        FileClose(FHandle);
        Result := ReadSinkingIslandOPK(fil);
      end
      else if ID4 = ('PACK') then
        Result := ReadQuakePAK
//      else if ID4 = ('PAK!') then
//        Result := ReadAvatarPAK
      else if ID4 = ('POD2') then
        Result := ReadNocturnePOD
      else if (ID4 = ('POD3')) or (ID4 = ('POD5')) then
        Result := ReadBloodRaynePOD
      else if ID8 = ('FILECHNK') then
        Result := ReadGunlokDAT
      else if ID4 = ('GABA') then
      begin
        FileClose(FHandle);
        Result := ReadDune3BAG(fil);
      end
      else if (ID4[0] = #60) and (ID4[1] = #226) and (ID4[2] = #156) and (ID4[3] = #1) then
      begin
        Result := ReadEvilIslandsRES;
      end
      // Giants: Citizen Kabuto
      else if (ID4[3] = #$66) and (ID4[2] = #8) and (ID4[1] = #$F1) and (ID4[0] = #1) then
      begin
        FileClose(FHandle);
        Result := ReadGiantsGZP(fil);
      end
      else if (ID12 = 'xcr File 1.0') and (ID36[12] = #48) then
      begin
        FileClose(FHandle);
        Result := ReadWarlordsBattlecryXCR(fil);
      end
      else if ID4 = ('PKR2') then
      begin
        FileClose(FHandle);
        Result := ReadTonyHawkPKR(fil);
      end
      else if ID4 = ('APUK') then
      begin
        FileClose(FHandle);
        Result := ReadMortyrHAL(fil);
      end
      else if ID4 = ('PAK'+#1) then
        Result := ReadBattleforgePAK
      else if ID4 = ('ESPN') then
        Result := ReadAgeOfEmpires3BAR
      else if ID4 = ('VOLN') then
        Result := ReadEarthSiege2VOL
      else if ID4 = ('PVOL') then
        Result := ReadStarsiegeTribesVOL
      else if ID4 = ('rass') then
      begin
        FileClose(FHandle);
        Result := ReadEmpiresDawnOfTheModernWorldSSA(fil);
      end
      else if ID4 = ('HAPI') then
      begin
        FileClose(FHandle);
        Result := ReadTotalAnnihilationHPI(fil);
      end
      else if ID4 = ('JAM2') then
      begin
        FileClose(FHandle);
        Result := ReadLeisureSuitLarryMagnaCumLaudeJAM(fil);
      end
      else if ID4 = ('DTA_') then
      begin
        FileClose(FHandle);
        Result := ReadHiddenAndDangerousDTA(fil);
      end
      else if ID28 = ('Refractor2 FlatArchive 1.1  ') then
      begin
        FileClose(FHandle);
        Result := ReadBattlefield1942(fil);
      end
      else if ID4 = ('FNYS') then
      begin
        FileClose(FHandle);
        Result := ReadNICE2SYN(fil);
      end
      else if ID4 = ('SPAK') then
      begin
        FileClose(FHandle);
        Result := ReadSinSIN(fil);
      end
      else if ID4 = ('LB83') then
      begin
        FileClose(FHandle);
        Result := ReadMonkeyIsland3BUN(fil);
      end
      else if (ID8[4] = #80) and (ID8[5] = #70) and (ID8[6] = #70) and (ID8[7] = #51) then
      begin
        FileClose(FHandle);
        Result := ReadNovalogicPFF3(fil)
      end
      else if (ID4 = 'RFFL') or (ID4 = 'CFFL') then
      begin
        FileClose(FHandle);
        Result := ReadAvPRFFL(fil)
      end
      else if ID4 = ('DWFB') then
        Result := ReadDungeonKeeper2DWFB
      else if ID4 = ('WAD2') then
        Result := ReadQuakeWAD2
      else if ID4 = ('WAD3') then
        Result := ReadQuakeWAD2
      else if ID4 = ('VPVP') then
      begin
        FileClose(FHandle);
        Result := ReadFreespaceVP(fil)
      end
      else if ID4 = ('HRFi') then
      begin
        FileClose(FHandle);
        Result := ReadHyperRipperHRF(fil)
      end
      else if ID4 = ('HOG2') then
      begin
        FileClose(FHandle);
        Result := ReadDescentHOG(fil)
      end
      else if ID4 = ('FAR!') then
      begin
        FileClose(FHandle);
        Result := ReadTheSimsFAR(fil)
      end
      else if ID4 = ('TGP0') then
      begin
        FileClose(FHandle);
        Result := ReadAstebreedTGP(fil)
      end
      else if (ID21P4 = 'MASSIVE PAKFILE V 4.0') then
        Result := ReadSpellforcePAK
      else if ID4 = ('edat') then
        Result := ReadActOfWarDAT
      else if ID4 = ('SAK ') then
      begin
        FileClose(FHandle);
        Result := ReadPostalSAK(fil);
      end
      else if (ID4 = 'ZFSF') or (ID4 = 'ZFS3') then
      begin
        FileClose(FHandle);
        Result := ReadInterstateZFS(fil);
      end
      else if (ID4[0] = 'D') and (ID4[1] = 'H') and (ID4[2] = 'F') then
      begin
        FileClose(FHandle);
        Result := ReadDescentHOG(fil);
      end
      else if strip0(ID23) = 'MOS DATAFILE2.0' then
      begin
        FileClose(FHandle);
        Result := ReadEnclaveMOS(fil)
      end
      else if ID36 = DRSID then
      begin
        FileClose(FHandle);
        Result := ReadAoe2DRS(fil);
      end
      else if ID12SLF = SLFID then
      begin
        FileClose(FHandle);
        Result := ReadJaggedAlliance2SLF(fil);
      end
      else if (ID4 = ('BIGF')) and (ID8[4] = #0) and (ID8[5] = 'Z') and (ID8[6] = 'B') and (ID8[7] = 'L') then
      begin
        FileClose(FHandle);
        Result := ReadVietcongCBF(fil);
      end
      else if (ID4 = ('BIGF')) and (ID8[4] = #1) and (ID8[5] = 'Z') and (ID8[6] = 'B') and (ID8[7] = 'L') then
      begin
        FileClose(FHandle);
        Result := ReadVietcongCryptedCBF(fil);
      end
      else if (ID4 = ('BIGF')) or (ID4 = ('BIG4')) then
        Result := ReadCommandAndConquerGeneralsBIG
      else if (ID4 = ('DATA')) then
      begin
        FileClose(FHandle);
        Result := ReadCommandos3PCK(fil);
      end
      // Dragon Age: Origins .ERF
      else if (ID28[0] = 'E') and (ID28[1] = #0) and (ID28[2] = 'R') and (ID28[3] = #0) and (ID28[4] = 'F') and (ID28[5] = #0)
        and (ID28[6] = ' ') and (ID28[7] = #0) and (ID28[8] = 'V') and (ID28[9] = #0) and (ID28[10] = '2') and (ID28[11] = #0)
        and (ID28[12] = '.') and (ID28[13] = #0) and (ID28[14] = '0') and (ID28[15] = #0) then
      begin
        FileClose(FHandle);
        Result := ReadDragonAgeOriginsERF(fil);
      end
      else if (ID4 = ('&YA1')) then
      begin
        Result := ReadRageOfMages2RES;
      end
      else if (ID127 = REZID) or (ID127 = REZIDold) then
      begin
        FileClose(FHandle);
        Result := ReadLithTechREZ(fil);
      end
      else if Strip0(ID36) = 'ASCARON_ARCHIVE V0.9' then
      begin
        FileClose(FHandle);
        Result := ReadAscaronCPR(fil);
      end
{IFDEF EXPFORMATS}
      // Deactivated Assassin's Creed .FORGE support due to incompleteness (usefullness?)
      else if (LeftStr(ID8,8) = 'scimitar')
          and (ID127[8] = #0) then
      begin
        FileClose(FHandle);
        Result := ReadAssassinsCreedFORGE(fil);
      end
      else if ID23 = NRMID then
      begin
        FileCLose(FHandle);
        Result := ReadHeathNRM(fil);
      end
      else if (ID4[0] = #72) and (ID4[1] = #52) and (ID4[2] = #82) and (ID4[3] = #5) then
      begin
        FileClose(FHandle);
        Result := ReadHeroesOfMightAndMagic4H4R(fil);
      end
{ENDIF}
      // Hitman: Contracts - TEX
      else if (ID127[8] = #3) and (ID127[9] = #0) and (ID127[10] = #0) and (ID127[11] = #0)
          and (ID127[12] = #4) and (ID127[13] = #0) and (ID127[14] = #0) and (ID127[15] = #0) then
      begin
        FileClose(FHandle);
        Result := ReadHitmanContractsTEX(fil);
      end
      else if (ID4[0] = 'B') and (ID4[1] = 'S') and (ID4[2] = 'A') and (ID4[3] = #0) then
      begin
        FileClose(FHandle);
        Result := ReadTheElderScrolls4OblivionBSA(fil)
      end
      else if (ID4 = ('RIFF')) and (ID12[8] = 'm') and (ID12[9] = 'm') and (ID12[10] = 'R') and (ID12[11] = 'C') then
        Result := ReadTheFifthElementMRC
      else if (ID4[0] = #0) and (ID4[1] = #0) and (ID4[2] = #128) and (ID4[3] = #63) then
      begin
        FileClose(FHandle);
        ReadFormat := ReadUFOAftermathVFS(fil);
      end
      // Scarface & Prototype .RCF
      else if (ID23 = 'ATG CORE CEMENT LIBRARY')
          and (ID36[24] = #0) and (ID36[25] = #0) and (ID36[26] = #0) and (ID36[27] = #0) and (ID36[28] = #0)
          and (ID36[29] = #0) and (ID36[30] = #0) and (ID36[31] = #0) and (ID36[23] = #0) then
      begin
        FileClose(FHandle);
        Result := ReadPrototypeRCF(fil)
      end
      else if (ext = 'MIX') or (ext = 'TLK') then
      begin
        if ((mixtest1 = 0) and ((mixtest3 = $20000) or (mixtest3 = $30000)))
             or ((mixtest1 > 0) and ((mixtest2 + mixtest1*12 + 6) = FSize)) then
          FileClose(FHandle);
          Result := ReadWestwoodMIX(fil);
      end
      else
      begin
        Result := 0;
        FileClose(FHandle);
      end;
    end;
  end;

  if (Result = 0) or not(Deeper) then
  begin
    if ext = 'PAK' then
      ReadFormat := ReadHubPAK(fil)
    else if ext = '007' then
      ReadFormat := ReadNightFire007(fil)
    else if ext = 'ADF' then
      ReadFormat := ReadGTA3ADF(fil)
    // Alien vs Predator .ASR
    else if ext = 'ASR' then
      Result := ReadAvpAsura(fil)
    else if ext = 'AWF' then
      ReadFormat := ReadQuiVeutGagnerDesMillionsAWF(fil)
    else if ext = 'ARCH00' then
      ReadFormat := ReadFearARCH00(fil)
    else if ext = 'ART' then
      ReadFormat := ReadDuke3DART(fil)
    else if ext = 'BAG' then
      ReadFormat := ReadDune3BAG(fil)
    else if ext = 'BAR' then
      ReadFormat := ReadHubBAR(fil)
    else if ext = 'BIG' then
      ReadFormat := ReadHubBIG(fil)
    else if ext = 'BIN' then
      ReadFormat := ReadCyberBykesBIN(fil)
    else if ext = 'BKF' then
      ReadFormat := ReadMotoRacerBKF(fil)
    else if ext = 'BOX' then
      ReadFormat := ReadLemmingsRevolutionBOX(fil)
    else if ext = 'BSA' then
      ReadFormat := ReadTheElderScrolls4OblivionBSA(fil)
    else if ext = 'BUN' then
      ReadFormat := ReadMonkeyIsland3BUN(fil)
    else if ext = 'COB' then
      ReadFormat := ReadAscendancyCOB(fil)
    else if ext = 'CBF' then
      ReadFormat := ReadVietcongCBF(fil)
    else if ext = 'CPR' then
      ReadFormat := ReadAscaronCPR(fil)
    else if ext = 'CUB' then
      ReadFormat := ReadArtifexMundiCUB(fil)
    else if ext = 'DAT' then
      ReadFormat := ReadHubDAT(fil)
    else if ext = 'DIR' then
      ReadFormat := ReadGTA3IMGDIR(fil)
    else if ext = 'DNI' then
      ReadFormat := ReadRealMystDNI(fil)
    else if ext = 'DRS' then
      ReadFormat := ReadAoe2DRS(fil)
    else if ext = 'DTA' then
      ReadFormat := ReadHiddenAndDangerousDTA(fil)
    else if ext = 'DZIP' then
      ReadFormat := ReadTheWitcher2DZIP(fil)
    else if ext = 'ERF' then
      Result := ReadDragonAgeOriginsERF(fil)
    else if ext = 'FAR' then
      ReadFormat := ReadTheSimsFAR(fil)
    else if ext = 'FFL' then
      ReadFormat := ReadAvPRFFL(fil)
    else if ext = 'FPK' then
      Result := ReadCivilization4FPK(fil)
    else if ext = 'GJD' then
      ReadFormat := ReadHubGJD(fil)
    else if ext = 'GL' then
    begin
      FHandle := FileOpen(fil, fmOpenRead or fmShareDenyWrite);
      ReadFormat := ReadStarCrusaderPAK(true);
    end
    else if ext = 'GRP' then
      ReadFormat := ReadDuke3DGRP(fil)
    else if ext = 'GOB' then
      ReadFormat := ReadHubGOB(fil)
    else if ext = 'GZP' then
      Result := ReadGiantsGZP(fil)
    else if ext = 'HAL' then
      ReadFormat := ReadMortyrHAL(fil)
    else if (ext = 'HOG') or (ext = 'MN3') then
      ReadFormat := ReadDescentHOG(fil)
    else if (ext = 'HPI') or (ext = 'UFO') or (ext = 'CCX') then
      ReadFormat := ReadTotalAnnihilationHPI(fil)
    else if ext = 'HRF' then
      ReadFormat := ReadHyperRipperHRF(fil)
    else if ext = 'IMG' then
      ReadFormat := ReadGTA3IMGDIR(fil)
    else if ext = 'JAM' then
      Result := ReadLeisureSuitLarryMagnaCumLaudeJAM(fil)
    else if ext = 'M4B' then
      Result := ReadMystIVRevelationM4B(fil)
    else if ext = 'MIX' then
      Result := ReadWestwoodMIX(fil)
    // The Fifth Element .MRC
    else if ext = 'MRC' then
    begin
      FHandle := FileOpen(fil, fmOpenRead or fmShareDenyWrite);
      Result := ReadTheFifthElementMRC;
    end
    else if ext = 'MTF' then
      ReadFormat := ReadDarkstoneMTF(fil)
{IFDEF EXPFORMATS}
    else if ext = 'FORGE' then
      ReadFormat := ReadAssassinsCreedFORGE(fil)
    else if ext = 'NRM' then
      ReadFormat := ReadHeathNRM(fil)
    else if ext = 'H4R' then
      ReadFormat := ReadHeroesOfMightAndMagic4H4R(fil)
{ENDIF}
    // Sinking Island/L'Ile Noyée .OPK
    else if ext = 'OPK' then
      Result := ReadSinkingIslandOPK(fil)
    else if ext = 'PBO' then
      ReadFormat := ReadOperationFlashpointPBO(fil)
    else if ext = 'PCK' then
      ReadFormat := ReadCommandos3PCK(fil)
    else if ext = 'PFF' then
      ReadFormat := ReadNovalogicPFF3(fil)
    else if ext = 'PKR' then
      ReadFormat := ReadTonyHawkPKR(fil)
    else if ext = 'POD' then
      ReadFormat := ReadHubPOD(fil)
    else if ext = 'PRM' then
      Result := ReadHitmanContractsPRM(fil)
    // Scarface & Prototype .RCF
    else if ext = 'RCF' then
      Result := ReadPrototypeRCF(fil)
    else if ext = 'RES' then
      ReadFormat := ReadHubRES(fil)
    else if ext = 'REZ' then
      ReadFormat := ReadLithTechREZ(fil)
    else if ext = 'RFA' then
      ReadFormat := ReadBattlefield1942(fil)
    else if ext = 'RFH' then
      ReadFormat := ReadDune3RFH(fil)
    else if ext = 'SAD' then
      ReadFormat := ReadLionheadAudioBank(fil)
    else if ext = 'SAK' then
      ReadFormat := ReadPostalSAK(fil)
    else if ext = 'SDT' then
      ReadFormat := ReadDungeonKeeper2SDT(fil)
    else if ext = 'SFL' then
      ReadFormat := ReadAgonSFL(fil)
    else if ext = 'SIN' then
      ReadFormat := ReadSinSIN(fil)
    else if ext = 'SLF' then
      ReadFormat := ReadJaggedAlliance2SLF(fil)
    else if ext = 'SND' then
      ReadFormat := ReadHeroesOfMightAndMagic3SND(fil)
    else if ext = 'SNI' then
      ReadFormat := ReadMDKSNI(fil)
    else if ext = 'SQH' then
      ReadFormat := ReadHarbingerSQH(fil)
    else if ext = 'SSA' then
      Result := ReadEmpiresDawnOfTheModernWorldSSA(fil)
    else if ext = 'STUFF' then
      Result := ReadHubSTUFF(fil)
    else if ext = 'SYN' then
      ReadFormat := ReadNICE2SYN(fil)
    else if ext = 'TEX' then
      ReadFormat := ReadHitmanContractsTEX(fil)
    else if ext = 'TGP' then
      ReadFormat := ReadAstebreedTGP(fil)
    else if ext = 'TLK' then
      ReadFormat := ReadHubPAK(fil)
    else if ext = 'VFS' then
      ReadFormat := ReadUFOAftermathVFS(fil)
    else if ext = 'VOL' then
      ReadFormat := ReadHubVOL(fil)
    else if ext = 'VP' then
      ReadFormat := ReadFreespaceVP(fil)
    else if ext = 'WAD' then
      ReadFormat := ReadHubWAD(fil)
    else if ext = 'X13' then
      ReadFormat := ReadHubPAK(fil)
    else if ext = 'XCR' then
      ReadFormat := ReadWarlordsBattlecryXCR(fil)
    else if ext = 'XRS' then
      ReadFormat := ReadPixelPaintersXRS(fil)
    // Enclave
    else if (ext = 'XTC') or (ext = 'XWC')then
      Result := ReadEnclaveMOS(fil)
    else if ext = 'ZFS' then
      ReadFormat := ReadInterstateZFS(fil)
    else
      ReadFormat := -1;
  end;

end;

procedure CloseFormat; stdcall;
begin

  DrvInfo.Sch := '';
  DrvInfo.ID := '';
  DrvInfo.FileHandle := 0;

  if FHandle <> 0 then
    FileClose(FHandle);

  FHandle := 0;
  CompressionWindow := 0;
  if (BufferStream <> Nil) then
    FreeAndNil(BufferStream);

end;

function GetEntry(): FormatEntry; stdcall;
var a: FSE;
begin

  if DataBloc <> NIL then
  begin
    a := DataBloc;
    DataBloc := DataBloc^.suiv;
    GetEntry.FileName := a^.Name;
    GetEntry.Offset := a^.Offset;
    GetEntry.Size := a^.Size;
    GetEntry.DataX := a^.DataX;
    GetEntry.DataY := a^.DataY;
    Dispose(a);
  end
  else
  begin
    GetEntry.FileName := '';
    GetEntry.Offset := 0;
    GetEntry.Size := 0;
    GetEntry.DataX := 0;
    GetEntry.DataY := 0;
  end;

end;

function GetCurrentDriverInfo(): CurrentDriverInfo; stdcall;
begin

  GetCurrentDriverInfo := DrvInfo;

end;

function GetErrorInfo(): ErrorInfo; stdcall;
begin

  GetErrorInfo := ErrInfo;

end;

function IsFormatSMART(fil: String): boolean;
var ID4: array[0..3] of char;
    ID4Last: array[0..3] of char;
    ID6: array[0..5] of char;
    ID8: array[0..7] of char;
    ID12: array[0..11] of char;
    ID12SLF: array[0..11] of char;
    ID18: array[0..17] of char;
    ID21P4: array[0..20] of char;
    ID23: array[0..22] of char;
    ID28: array[0..27] of char;
    ID36: array[0..35] of char;
    ID127: array[0..126] of char;
    TestFile,fsize: integer;
    mixtest1: word;
    mixtest2,mixtest3: cardinal;
    ext: string;
begin

  Result := False;

  TestFile := FileOpen(fil, fmOpenRead or fmShareDenyWrite);

  ext := ExtractFileExt(fil);

  if ext <> '' then
    ext := copy(ext,2,length(ext)-1);

  ext := UpperCase(ext);

  if TestFile > 0 then
  begin
    FileRead(TestFile,ID127,127);
    FSize := FileSeek(Testfile,0,2);
    FileSeek(TestFile,0,0);
    FileRead(TestFile,mixtest1,2);
    FileRead(TestFile,mixtest2,4);
    FileSeek(TestFile,0,0);
    FileRead(TestFile,mixtest3,4);
    FileSeek(TestFile,520,0);
    FileRead(TestFile,ID12SLF,12);
    FileSeek(TestFile,-4,2);
    FileRead(TestFile,ID4Last,4);

    // Copy values to the different magic IDs lengths
    Move(ID127[0],ID4,4);
    Move(ID127[0],ID8,8);
    Move(ID127[0],ID12,12);
    Move(ID127[0],ID18,18);
    Move(ID127[0],ID23,23);
    Move(ID127[0],ID28,28);
    Move(ID127[0],ID36,36);
    Move(ID127[4],ID21P4,21);

    FileClose(TestFile);

    if ID4 = ('GOB'+#10) then
      Result := true
    // Myst IV: Revelation .M4B file
    else if (ID23[0] = #11) and (ID23[1] = #0) and (ID23[2] = #0) and (ID23[3] = #0)
        and (ID23[4] = 'U') and (ID23[5] = 'B') and (ID23[6] = 'I') and (ID23[7] = '_')
        and (ID23[8] = 'B') and (ID23[9] = 'F') and (ID23[10] = '_') and (ID23[11] = 'S')
        and (ID23[12] = 'I') and (ID23[13] = 'G') and (ID23[14] = #0) then
      Result := true
    // Alien vs Predator .ASR
    else if (ID8 = AsuraMagic) or (ID8 = AsuraZlbMagic) then
      Result := true
    // Black & White 2 .STUFF file (Everything.stuff)
    else if (ID127[0] = #1) and (ID127[1] = #0) and (ID127[2] = #0) and (ID127[3] = #0)
        and (ID127[4] = #0) and (ID127[5] = #0) and (ID127[6] = #0) and (ID127[7] = #0)
        and (ID127[8] = #0) and (ID127[9] = #0) and (ID127[10] = #0) and (ID127[11] = #0)
        and (ID127[12] = #0) and (ID127[13] = #0) and (ID127[14] = #0) and (ID127[15] = #0)
        and (ID127[16] = #0) and (ID127[17] = #0) and (ID127[18] = #0) and (ID127[19] = #0)
        and (ID127[20] = #0) and (ID127[21] = #0) and (ID127[22] = #0) and (ID127[23] = #0)
        and (ID127[24] = #0) and (ID127[25] = #0) and (ID127[26] = #0) and (ID127[27] = #0)
        and (ID127[28] = #0) and (ID127[29] = #0) and (ID127[30] = #0) and (ID127[31] = #0)
        and (ID127[32] = #0) and (ID127[33] = #0) and (ID127[34] = #0) and (ID127[35] = #0)
        and (ID127[36] = #0) and (ID127[37] = #0) and (ID127[38] = #0) and (ID127[39] = #0)
        and (ID127[40] = #0) and (ID127[41] = #0) and (ID127[42] = #0) and (ID127[43] = #0)
        and (ID127[44] = #0) and (ID127[45] = #0) and (ID127[46] = #0) and (ID127[47] = #0)
        and (ID127[48] = #0) and (ID127[49] = #0) and (ID127[50] = #0) and (ID127[51] = #0)
        and (ID127[52] = #0) and (ID127[53] = #0) and (ID127[54] = #0) and (ID127[55] = #0)
        and (ID127[56] = #0) and (ID127[57] = #0) and (ID127[58] = #0) and (ID127[59] = #0)
        and (ID127[60] = #0) and (ID127[61] = #0) and (ID127[62] = #0) and (ID127[63] = #0) then
      Result := true
    // Artifex Mundi .CUB file
    else if (ID4[0] = #245) and (ID4[1] = #227) and (ID4[2] = #244) and (ID4[3] = #150) then
      Result := true
    // Civilization 4 .FPK file
    else if (ID8[4] = 'F') and (ID8[5] = 'P') and (ID8[6] = 'K') and (ID8[7] = '_') then
      Result := true
    // Entropia Universe .BNT file
    else if (ID4Last = 'BNT2') then
      Result := true
    // The Witcher 2: Assassins of Kings .DZIP file
    else if (ID4 = 'DZIP') then
      Result := true
    // Hitman: Contracts .PRM file
    else if (ID4[0] = #30) and (ID4[1] = #7) and (ID4[2] = #0) and (ID4[3] = #0) then
      Result := true
    // Fable: The Lost Chapter .BIG file
    else if (ID4 = 'BIGB') then
      Result := true
    // The Movies .PAK files
    else if (ID4[0] = #5) and (ID4[1] = #0) and (ID4[2] = #0) and (ID4[3] = #0) then
      Result := true
    // FEAR .ARCH00 file
    else if (ID4 = 'LTAR') then
      Result := true
    // AGON .SFL file
    else if (ID4 = 'SFL1') and (ID6[4] = '0') then
      Result := true
    else if ID12 = GRPID then
      Result := true
    // Dreamfall: The Longest Journey
    else if ID12 = 'tlj_pack0001' then
      Result := true
    // Ghostbusters: Sanctum of Slime .PAK file
    else if (ID18 = 'tongas_pack_v30000') then
      Result := true
    // Giants: Citizen Kabuto
    else if (ID4[3] = #$66) and (ID4[2] = #$08) and (ID4[1] = #$F1) and (ID4[0] = #$01) then
      Result := true
    // Geometry Wars 3: Dimension Evolved .WAD file
    else if (ID4 = 'DAWL') then
      Result := true
    // The Secret of Monkey Island: Special Edition .PAK file
    else if (ID4 = 'KAPL') then
      Result := true
    // South Park: The Stick of Truth .OAF file
    else if (ID4 = 'OAF!') then
      Result := true
    else if (ID4[0] = #60) and (ID4[1] = #226) and (ID4[2] = #156) and (ID4[3] = #1) then
      Result := true
    else if (ID4[0] = #1) and (ID4[1] = #0) and (ID4[2] = #0) and (ID4[3] = #0)
         and (ID28[12] = 'R') and (ID28[13] = 'O') and (ID28[14] = 'O') and (ID28[15] = 'T') then
      Result := true
    else if (ID12 = 'xcr File 1.0') and (ID36[12] = #48) then
      Result := true
    else if ID28 = 'Refractor2 FlatArchive 1.1  ' then
      Result := true
    else if ID8 = 'LiOnHeAd' then
      Result := true
    else if ID8 = 'FILECHNK' then
      Result := true
    // Scarface & Prototype .RCF
    else if (ID23 = 'ATG CORE CEMENT LIBRARY')
        and (ID36[24] = #0) and (ID36[25] = #0) and (ID36[26] = #0) and (ID36[27] = #0) and (ID36[28] = #0)
        and (ID36[29] = #0) and (ID36[30] = #0) and (ID36[31] = #0) and (ID36[23] = #0) then
      Result := true
    else if ID4 = ('JAM2') then     // Leisure Suit Larry - Magna Cum Laude
      Result := true
    else if ID4 = ('DTA_') then
      Result := true
    else if ID4 = ('ESPN') then     // Age of Empire 3 .BAR
      Result := true
    else if ID4 = ('rass') then
      Result := true
    else if ID4 = ('FNYS') then
      Result := true
    else if ID4 = ('Dirt') then
      Result := true
    else if ID6 = ('LEMBOX') then
      Result := true
    else if ID4 = ('GABA') then
      Result := true
    else if ID4 = ('GOB ') then
      Result := true
{IFDEF EXPFORMATS}
    // Assassin's Creed
    else if (LeftStr(ID8,8) = 'scimitar')
          and (ID127[8] = #0) then
      Result := true
    else if ID18 = NRMID then
      Result := true
    // H4R
    else if (ID4[0] = #72) and (ID4[1] = #52) and (ID4[2] = #82) and (ID4[3] = #5) then
      Result := true
{ENDIF}
    else if ID4 = ('PAK'+#1) then
      Result := true
    else if ID4 = ('HAPI') then
      Result := true
    else if (ID21P4 = 'MASSIVE PAKFILE V 4.0') then
      Result := true
    // Sinking Island/L'Ile Noyée .OPK
    else if ID4 = ('PAK ') then
      Result := true
    else if ID4 = ('PACK') then
      Result := true
    // Avatar: The Game .PAK
//    else if ID4 = ('PAK!') then
//      Result := true
    else if ID4 = ('edat') then
      Result := true
    else if ID4 = ('POD5') then
      Result := true
    else if ID4 = ('POD3') then
      Result := true
    else if ID4 = ('POD2') then
      Result := true
    else if ID4 = ('PSAR') then
      Result := true
    else if ID4 = ('LB83') then
      Result := true
    else if (ID8[4] = #80) and (ID8[5] = #70) and (ID8[6] = #70) and (ID8[7] = #51) then
      Result := true
    else if ID4 = ('PKR2') then
      Result := true
    else if ID4 = ('APUK') then
      Result := true
    else if ID4 = ('RFFL') then
      Result := true
    else if ID4 = ('CFFL') then
      Result := true
    else if ID4 = ('DWFB') then
      Result := true
    else if ID4 = ('VOLN') then
      Result := true
    // Starsiege: Tribes .VOL
    else if ID4 = ('PVOL') then
      Result := true
    else if ID4 = ('VPVP') then
      Result := true
    else if ID4 = ('HRFi') then
      Result := true
    else if ID4 = ('HOG2') then
      Result := true
    else if ID4 = ('FAR!') then
      Result := true
    else if ID4 = ('TGP0') then
      Result := true
    else if ID4 = ('WAD2') then
      Result := true
    else if ID4 = ('WAD3') then
      Result := true
    else if ID4 = ('ZFSF') then
      Result := true
    else if ID4 = ('SAK ') then
      Result := true
    else if ID4 = ('SPAK') then
      Result := true
    else if ID4 = ('ZFS3') then
      Result := true
    else if ID4 = ('&YA1') then
      Result := true
    // Enclave .XTC .XWC
    else if strip0(ID23) = 'MOS DATAFILE2.0' then
      Result := true
    else if (ID4[0] = #0) and (ID4[1] = #0) and (ID4[2] = #128) and (ID4[3] = #63) then
      Result := true
    else if (ID4[0] = 'B') and (ID4[1] = 'S') and (ID4[2] = 'A') and (ID4[3] = #0) then
      Result := true
    else if (ID4[0] = 'D') and (ID4[1] = 'H') and (ID4[2] = 'F') then
      Result := true
    else if ID36 = DRSID then
      Result := true
//    else if (ID4 = ('BIGF')) and (ID8[4] = #0) and (ID8[5] = 'Z') and (ID8[6] = 'B') and (ID8[7] = 'L') then
//      Result := true
    else if (ID4 = ('BIGF')) or (ID4 = ('BIG4')) then
      Result := true
    else if (ID4 = ('DATA')) then
      Result := true
    // Dragon Age: Origins .ERF
    else if (ID28[0] = 'E') and (ID28[1] = #0) and (ID28[2] = 'R') and (ID28[3] = #0) and (ID28[4] = 'F') and (ID28[5] = #0)
        and (ID28[6] = ' ') and (ID28[7] = #0) and (ID28[8] = 'V') and (ID28[9] = #0) and (ID28[10] = '2') and (ID28[11] = #0)
        and (ID28[12] = '.') and (ID28[13] = #0) and (ID28[14] = '0') and (ID28[15] = #0) then
      Result := true
    else if (ID4 = ('RIFF')) and (ID12[8] = 'm') and (ID12[9] = 'm') and (ID12[10] = 'R') and (ID12[11] = 'C') then
      Result := true
    else if ID12SLF = SLFID then
      Result := true
    else if (ID127 = REZID) or (ID127 = REZIDold) then
      Result := true
    else if (Strip0(ID36)) = 'ASCARON_ARCHIVE V0.9' then
      Result := true
    // Hitman: Contracts - TEX file
    else if (ID127[8] = #3) and (ID127[9] = #0) and (ID127[10] = #0) and (ID127[11] = #0)
        and (ID127[12] = #4) and (ID127[13] = #0) and (ID127[14] = #0) and (ID127[15] = #0) then
      Result := true
    else if (ext = 'MIX') or (ext = 'TLK') then
    begin
      result := ((mixtest1 = 0) and ((mixtest3 = $20000) or (mixtest3 = $30000)))
             or ((mixtest1 > 0) and ((mixtest2 + mixtest1*12 + 6) = FSize));
    end
    else
      Result := False;
  end;

end;

function IsFormat(fil: ShortString; Deeper: Boolean): Boolean; stdcall;
var ext: string;
begin

  ext := ExtractFileExt(fil);

  if ext <> '' then
    ext := copy(ext,2,length(ext)-1);

  ext := UpperCase(ext);

  if Deeper then
    IsFormat := IsFormatSMART(fil) or (ext = 'POD') or (ext = 'PAK') or (ext = 'TLK') or (ext = 'SDT') or (ext = 'RFH') or (ext = 'MTF') or (ext = 'BKF') or (ext = 'DAT') or (ext = 'PBO') or (ext = 'AWF') or (ext = 'SND') or (ext = 'ART') or (ext = 'SNI') or (ext = 'DIR') or (ext = 'IMG') or (ext = 'BAR') or (ext = 'BAG') or (ext = 'SQH') or (ext = 'GL') or (ext = 'RFA') or (ext = 'ADF') or (ext = 'RES') or (ext = 'XRS') or (ext = 'STUFF') or (ext = 'BIN') or (ext = 'COB') or (ext = 'GJD')
  else
    if ext = 'PAK' then
      IsFormat := True
    else if ext = '007' then
      IsFormat := True
    else if ext = 'ADF' then
      IsFormat := True
    else if ext = 'ASR' then     // Alien vs Predator
      IsFormat := True
    else if ext = 'AWF' then
      IsFormat := True
    else if ext = 'ARCH00' then
      IsFormat := True
    else if ext = 'ART' then
      IsFormat := True
    else if ext = 'BKF' then
      IsFormat := True
    else if ext = 'BAG' then
      IsFormat := True
    else if ext = 'BAR' then
      IsFormat := True
    else if ext = 'BIG' then
      IsFormat := True
    else if ext = 'BIN' then
      IsFormat := True
    else if ext = 'BNT' then    // Entropia Universe
      IsFormat := True
    else if ext = 'BOX' then
      IsFormat := True
    else if ext = 'BSA' then
      IsFormat := True
    else if ext = 'BUN' then
      IsFormat := True
    else if ext = 'CBF' then
      IsFormat := True
    else if ext = 'CCX' then
      IsFormat := True
    else if ext = 'COB' then   // Ascendancy
      IsFormat := True
    else if ext = 'CPR' then
      IsFormat := True
    // Artifex Mundi .CUB
    else if ext = 'CUB' then
      IsFormat := True
    else if ext = 'DAT' then
      IsFormat := True
    else if ext = 'DIR' then
      IsFormat := True
    else if ext = 'DNI' then
      IsFormat := True
    else if ext = 'DRS' then
      IsFormat := True
    else if ext = 'DTA' then
      IsFormat := True
    // The Witcher 2: Assassins of Kings .DZIP
    else if ext = 'DZIP' then
      IsFormat := True
    // Dragon Age: Origins .ERF
    else if ext = 'ERF' then
      IsFormat := True
    else if ext = 'FAR' then
      IsFormat := True
    else if ext = 'FFL' then
      IsFormat := True
    else if ext = 'FPK' then   // Civilization 4
      IsFormat := True
    else if ext = 'GL' then
      IsFormat := True
    else if ext = 'GOB' then
      IsFormat := True
    else if ext = 'GRP' then
      IsFormat := True
    // Giants: Citizen Kabuto
    else if ext = 'GZP' then
      IsFormat := True
    else if ext = 'HAL' then
      IsFormat := True
    else if ext = 'HOG' then
      IsFormat := True
    else if ext = 'HPI' then
      IsFormat := True
    else if ext = 'HRF' then
      IsFormat := True
    else if ext = 'IMG' then
      IsFormat := True
    else if ext = 'JAM' then
      IsFormat := True
    else if ext = 'M4B' then
      IsFormat := True
    // Westwood Studios .MIX files (C&C)
    else if ext = 'MIX' then
      IsFormat := True
    else if ext = 'MN3' then
      IsFormat := True
    // The Fifth Element .MRC
    else if ext = 'MRC' then
      IsFormat := True
    else if ext = 'MTF' then
      IsFormat := True
{IFDEF EXPFORMATS}
    else if ext = 'FORGE' then
      IsFormat := True
    else if ext = 'NRM' then
      IsFormat := True
    else if ext = 'H4R' then
      IsFormat := True
{ENDIF}
    // Sinking Island/L'Ile Noyée .OPK
    else if ext = 'OPK' then
      IsFormat := True
    else if ext = 'PBO' then
      IsFormat := True
    else if ext = 'PCK' then
      IsFormat := True
    else if ext = 'PFF' then
      IsFormat := True
    else if ext = 'PKR' then
      IsFormat := True
    else if ext = 'POD' then
      IsFormat := True
    // Hitman: Contracts .PRM
    else if ext = 'PRM' then
      IsFormat := True
    // Scarface & Prototype .RCF
    else if ext = 'RCF' then
      IsFormat := True
    else if ext = 'RES' then
      IsFormat := True
    else if ext = 'REZ' then
      IsFormat := True
    else if ext = 'RFA' then
      IsFormat := True
    else if ext = 'RFH' then
      IsFormat := True
    else if ext = 'SAD' then
      IsFormat := True
    else if ext = 'SAK' then
      IsFormat := True
    else if ext = 'SDT' then
      IsFormat := True
    else if ext = 'SFL' then
      IsFormat := True
    else if ext = 'SIN' then
      IsFormat := True
    else if ext = 'SND' then
      IsFormat := True
    else if ext = 'SNI' then
      IsFormat := True
    else if ext = 'SLF' then
      IsFormat := True
    else if ext = 'SQH' then
      IsFormat := True
    else if ext = 'SSA' then
      IsFormat := True
    else if ext = 'STUFF' then
      IsFormat := True
    else if ext = 'SYN' then
      IsFormat := True
    else if ext = 'TEX' then
      IsFormat := True
    else if ext = 'TGP' then
      IsFormat := True
    else if ext = 'TLK' then
      IsFormat := True
    else if ext = 'UFO' then
      IsFormat := True
    else if ext = 'VFS' then
      IsFormat := True
    else if ext = 'VOL' then
      IsFormat := True
    else if ext = 'VP' then
      IsFormat := True
    else if ext = 'WAD' then
      IsFormat := True
    else if ext = 'X13' then
      IsFormat := True
    else if ext = 'XCR' then
      IsFormat := True
    else if ext = 'XTC' then
      IsFormat := True
    else if ext = 'XWC' then
      IsFormat := True
    else if ext = 'XRS' then
      IsFormat := True
    else if ext = 'ZFS' then
      IsFormat := True
    else
      IsFormat := False;

end;

function RFA_Decomp(SBuff: PByteArray; OBuff: PByteArray; SBSize: longword; OBSize: longword): integer;
var cb1, cbc1, distance, length, length2, sbend: integer;
    sb1, ob1, ob1b, ob2, ob2b: integer;
    x: integer;
label endfunc, start, firstcontrol;
begin

//  distance := 0;
//  length := 0;
//  sb1 := SBuff;
  ob1 := 0;
//  ob2 := 0;

  sb1 := 0;
  sbend := sbsize - 3;

  cb1 := SBuff^[sb1];
  inc(sb1);

  if (cb1>17) then
  begin
//    writeln(T,'  {CB1>17 = '+inttostr(cb1)+'}');
    Dec(cb1,14);
    if ((ob1+(cb1-3)) > obsize) then
    begin
      result := -5;
      goto endfunc;
    end;
    if ((sb1+(cb1-3)) > obsize) then
    begin
      result := -4;
      goto endfunc;
    end;
    cbc1 := cb1 shr 2;
    cb1 := cb1 xor 3;
    cb1 := cb1 and 3;
    for x := cbc1 downto 1 do
    begin
      OBuff^[ob1] := SBuff^[sb1];
      OBuff^[ob1+1] := SBuff^[sb1+1];
      OBuff^[ob1+2] := SBuff^[sb1+2];
      OBuff^[ob1+3] := SBuff^[sb1+3];
      Inc(ob1,4);
      Inc(sb1,4);
    end;
    sb1 := sb1 - cb1;
    ob1 := ob1 - cb1;
    cb1 := SBuff^[sb1];
    inc(sb1);
  end
  else
    goto firstcontrol;

start:
  while (true) do
  begin
    if (cb1 >= $40) then
    begin
//      writeln(T,'  {CB1>=0x40 = '+inttostr(cb1)+'}');
      distance := ((cb1 shr 2) and 7) + (SBuff^[sb1])*8;
//      writeln(T,'    {distance='+inttostr(distance)+'}');
      inc(sb1);
      length := (cb1 shr 5) + 1;
//      writeln(T,'    {length='+inttostr(length)+'}');
      ob2 := ob1 - (distance+1);
      if (ob2 < 0) then
      begin
        // 00B
        result := -6;
        goto endfunc;
      end;
      if ((ob1 + length) > obsize) then
      begin
        result := -5;
        goto endfunc;
      end;
      for x := length downto 1 do
      begin
        OBuff^[ob1] := OBuff^[ob2];
        inc(ob1);
        inc(ob2);
      end;
//      length := 0;
//      distance := 0;
    end
    else if (cb1 >= $20) then
    begin
//      writeln(T,'  {CB1>=0x20 = '+inttostr(cb1)+'}');
      length := cb1 and 31;
		  if(length = 0) then
      begin
        while (SBuff^[sb1] = 0) do
        begin
          inc(sb1);
          inc(Length,255);
          if ((sb1 + 3) > sbend) then
          begin
            result := -4;
            goto endfunc;
          end;
        end;
        inc(length,SBuff^[sb1]+33);
        inc(sb1);
      end
      else
        inc(length,2);
//      writeln(T,'    {length='+inttostr(length)+'}');
//      distance := Integer(SBuff^[sb1+1]) * 255 + SBuff^[sb1];
//      distance := distance shr 2;
      distance := (((SBuff^[sb1] shr 2) and 63) or ((SBuff^[sb1+1] shl 6) and 192)) + ((SBuff^[sb1+1] and 252) shr 2) * 256;
//      distance := longword(SBuff^[sb1]) shr 2;
      inc(sb1,2);
      ob2 := ob1 - (distance+1);
//      writeln(T,'    {distance='+inttostr(distance)+'}');
      if (ob2 < 0) then
      begin
        result := -6;
        goto endfunc;
      end;
      if (ob1+length > obsize) then
      begin
        result := -5;
        goto endfunc;
      end;
      for x := length downto 1 do
      begin
        OBuff^[ob1] := OBuff^[ob2];
        inc(ob1);
        inc(ob2);
      end;
//      length := 0;
//      distance := 0;
    end
    else if (cb1 >= $10) then
    begin
//      writeln(T,'  {CB1>=0x10 = '+inttostr(cb1)+'}');
      length := cb1 and 7;
		  if(length = 0) then
      begin
        while (SBuff^[sb1] = 0) do
        begin
          inc(sb1);
          inc(Length,255);
          if ((sb1 + 3) > sbend) then
          begin
            // 00B
            result := -14;
            goto endfunc;
          end;
        end;
        inc(length,SBuff^[sb1]+9);
        inc(sb1);
      end
      else
        inc(length,2);
//      writeln(T,'    {length='+inttostr(length)+'}');
      distance := (Integer(SBuff^[sb1+1]) * 256 + SBuff^[sb1]);
//      writeln(T,'    {1st distance='+inttostr(distance)+'}');
      distance := distance and 65532;
//      distance := (((SBuff^[sb1] shr 2) and 63) or ((SBuff^[sb1+1] shl 6) and 192)) + ((SBuff^[sb1+1] and 252) shr 2) * 256;
//      distance := (((SBuff^[sb1] shr 2) and 63) or ((SBuff^[sb1+1] shl 6) and 192)) + ((SBuff^[sb1+1] and 252) shr 2) * 256;
      inc(sb1,2);
      ob2 := ob1 - 16384;
      distance := distance shr 2;
      if distance = 0 then
      begin
        if (sb1 = (sbend + 3)) then
          result := -12
        else if (ob1 = obsize) then
          result := -12
        else if (ob1 > obsize) then
          result := -5
        else if (sb1 > sbend) then
          result := -4
        else
          result := -8;
        goto endfunc;
      end;
//      writeln(T,'    {2nd distance='+inttostr(distance)+'}');
 	    dec(ob2,distance);
      length2 := length + 3;
      length2 := length2 shr 2;
      ob1b := ob1;
      ob2b := ob2;
      for x := length2 downto 1 do
      begin
        OBuff^[ob1b] := OBuff^[ob2b];
        OBuff^[ob1b+1] := OBuff^[ob2b+1];
        OBuff^[ob1b+2] := OBuff^[ob2b+2];
        OBuff^[ob1b+3] := OBuff^[ob2b+3];
        Inc(ob1b,4);
        Inc(ob2b,4);
      end;
      inc(ob1,length);
//      length := 0;
//      distance := 0;
    end
    else if (cb1 < $10) then
    begin
//      writeln(T,'  {CB1<0x10='+inttostr(cb1)+'}');
      if (ob1 > obsize) then
      begin
        // 00B
        result := -5;
        goto endfunc;
      end;
      distance := (cb1 shr 2) + SBuff^[sb1]*4;
//      writeln(T,'    {distance='+inttostr(distance)+'}');
      inc(sb1);
      ob2 := ob1 - (distance + 1);
      if (ob2 < 0) then
      begin
        // 00B
        result := -6;
        goto endfunc;
      end;
      OBuff^[ob1] := OBuff^[ob2];
      OBuff^[ob1+1] := OBuff^[ob2+1];
      inc(ob1,2);
    end;

    cb1 := SBuff^[sb1-2] and 3;

    while (cb1 = 0) do
    begin
//      writeln(T,'  {CB1='+inttostr(cb1)+'}');
//      if (sb1 > 34000)
      if (sb1 > sbend) then
      begin
        // 00B
        result := -4;
        goto endfunc;
      end;
      cb1 := SBuff^[sb1];
      inc(sb1);
firstcontrol:
       if (cb1 >= $10) then
         goto start;
       if (cb1 = 0) then
       begin
         while (SBuff^[sb1] = 0) do
         begin
           inc(sb1);
           inc(cb1,255);
           if ((sb1+cb1+18) > sbend) then
           begin
             // 00B
             result := -4;
             goto endfunc;
           end;
         end;
         inc(cb1,SBuff^[sb1]+21);
         inc(sb1);
       end
       else
         inc(cb1,6);
       if (ob1+cb1-3) > obsize then
       begin
         // 00B
         result := -5;
         goto endfunc;
       end;
       if (sb1+cb1-3) > sbend then
       begin
         // 00B
         result := -4;
         goto endfunc;
       end;
       length := cb1 shr 2;
//       writeln(T,'  {CB1='+inttostr(cb1)+' / length='+inttostr(length)+'}');
       cb1 := cb1 xor 3;
       cb1 := cb1 and 3;
       length := (length*4)-cb1;
//       writeln(T,'  {CB1='+inttostr(cb1)+' / length='+inttostr(length)+'}');
       for x := 1 to length do
       begin
         OBuff^[ob1] := SBuff^[sb1];
         inc(ob1);
         inc(sb1);
       end;
//       inc(ob1,length);
//       inc(sb1,length);
//       length := 0;
       cb1 := SBuff^[sb1];
       inc(sb1);
//       writeln(T,'  {CB1='+inttostr(cb1)+'}');
       if (cb1 >= $10) then
         goto start;
       if (ob1+3) > obsize then
       begin
         // 00B
         result := -5;
         goto endfunc;
       end;
       distance := (cb1 shr 2) + (SBuff^[sb1]*4);
//        writeln(T,'    {distance='+inttostr(distance)+'}');
       inc(sb1);
       ob2 := ob1 - (distance+1)-2048;
       if (ob2 < 0) then
       begin
         // 00B
         result := -6;
         goto endfunc;
       end;
       OBuff^[ob1] := OBuff^[ob2];
       OBuff^[ob1+1] := OBuff^[ob2+1];
       OBuff^[ob1+2] := OBuff^[ob2+2];
       OBuff^[ob1+3] := OBuff^[ob2+3];
       inc(ob1,3);
       cb1 := SBuff^[sb1-2] and 3;
     end;

     if(ob1+cb1) > obsize then
     begin
       // 00B
       result := -5;
       goto endfunc;
     end;

     if(sb1+cb1) > sbend then
     begin
       // 00B
       result := -4;
       goto endfunc;
     end;

     OBuff^[ob1] := SBuff^[sb1];
     OBuff^[ob1+1] := SBuff^[sb1+1];
     OBuff^[ob1+2] := SBuff^[sb1+2];
     OBuff^[ob1+3] := SBuff^[sb1+3];
     inc(sb1,cb1);
     inc(ob1,cb1);
     cb1 := SBuff^[sb1];
     inc(sb1);
  end;

  result := 0;
  
endfunc:

end;

// Decompression of LZMA file at Offset and Size bytes
//
// This is almost a cut & paste of the ULZMAAlone.pas in LZMA SDK.
//
// NOTE: The full LZMA file is buffered in memory, shouldn't be a problem
//       as it is only used for Ghostbusters: Sanctum of Slime .PAK files
//       and the biggest file is 220MB but still... Could be a problem so
//       should implement a fallback to temporary file if it is too big.
procedure DecompressLZMAToStream(outStream: TStream; Offset, Size: int64; silent: boolean);
var properties:array[0..4] of byte;
    inStreamFull:THandleStream;
    inStream:TMemoryStream;
    decoder:TLZMADecoder;
    outSize:int64;
    i:byte;
    v:ShortInt;
begin

  inStreamFull := THandleStream.Create(FHandle);
  inStream := TMemoryStream.Create;
  decoder := TLZMADecoder.Create;

  try
    inStreamFull.Seek(Offset,0);
    inStream.CopyFrom(inStreamFull,Size);
    inStream.Seek(0,0);
    if inStream.read(properties, 5) <> 5 then
      raise EDecompLZMAError.Create('input LZMA is too short');
    if not decoder.SetDecoderProperties(properties) then
      raise EDecompLZMAError.Create('Incorrect stream properties');
    outSize := 0;
    for i := 0 to 7 do
    begin
      v := shortint(ReadByte(inStream));
      if v < 0 then
        raise EDecompLZMAError.Create('Can''t read stream size');
      outSize := outSize or v shl (8 * i);
    end;
    if not decoder.Code(inStream, outStream, outSize) then
      raise EDecompLZMAError.Create('Error in data stream');
  finally
    FreeAndNil(decoder);
    FreeAndNil(inStream);
    FreeAndNil(inStreamFull);
  end;

end;

procedure DecompressRFAToStream(outputstream: TStream; Offset, Size: int64; silent: boolean);
var
  SBuff: PByteArray;
  OBuff: PByteArray;
  res: integer;
  per, oldper, perstep: word;
  real1, real2: real;

  DataH: array of RFA_DataHeader;
  x, Segments: longword;
begin

{  FileMode := fmOpenWrite;
  Assign(T,'h:\result-delphi.txt');
  Rewrite(T);}

  segments := 0;
  FileSeek(FHandle, offset,0);
  FileRead(FHandle,segments,4);

  SetLength(DataH,Segments);

  for x := 0 to Segments-1 do
  begin
    FileRead(FHandle,DataH[x].csize,4);
    FileRead(FHandle,DataH[x].ucsize,4);
    FileRead(FHandle,DataH[x].doffset,4);
  end;

  oldper := 0;
  perstep := 5;

  for x := 0 to Segments-1 do
  begin
//    writeln(T,'{HEADI='+inttostr(x+1)+'}');

    GetMem(SBuff,DataH[x].csize);
    GetMem(OBuff,DataH[x].ucsize);
    FileSeek(FHandle,Offset+(segments*12)+DataH[x].doffset+4,0);
		FileRead(FHandle,SBuff^,DataH[x].csize);
    res := RFA_Decomp(SBuff,OBuff,DataH[x].csize,DataH[x].ucsize);
    if res <> -12 then
    begin
      FreeMem(SBuff);
      FreeMem(OBuff);
      Break;
    end;
    outputstream.WriteBuffer(OBuff^, DataH[x].ucsize);
    FreeMem(SBuff);
    FreeMem(OBuff);
    if not silent then
    begin
      real1 := x+1;
      real2 := Segments;
      real1 := (real1 / real2)*100;
      per := Round(real1);
      if per >= oldper + perstep then
      begin
        oldper := per;
        SetPercent(per);
      end;
    end;
//    writeln(T,'{/HEADI}');
  end;

  if not silent then
    SetPercent(100);

//  CloseFile(T);

end;

function DecompressRFDToStream(outputstream: TStream; Size:  Int64; OSize: Int64) : Boolean;
var
  Buf: PChar;
  InputStream: TMemoryStream;
  DStream: TDecompressionStream;
  FinalSize: integer;
begin

  GetMem(Buf,Size-4);
  try
    FileSeek(FHandle,4,1);
    FileRead(FHandle,Buf^,Size-4);

    InputStream := TMemoryStream.Create;
    try
      InputStream.Write(Buf^,Size-4);
      InputStream.Seek(0, soBeginning);

      DStream := TDecompressionStream.Create(InputStream);
      try
        FinalSize := OutputStream.CopyFrom(DStream,OSize);
      finally
        FreeAndNil(DStream);
      end

    finally
      FreeAndNil(InputStream);
    end
  finally
    FreeMem(Buf);
  end;

  Result := FinalSize = OSize;

End;

function DecompressZlibToStream(OutputStream: TStream; Size:  Int64; OSize: Int64) : Boolean;
var
  Buf: PChar;
  InputStream: TMemoryStream;
  DStream: TDecompressionStream;
  FinalSize: integer;
begin

  GetMem(Buf,Size);
  try
    FileRead(FHandle,Buf^,Size);

    InputStream := TMemoryStream.Create;
    try
      InputStream.Write(Buf^,Size);
      InputStream.Seek(0, soBeginning);

      DStream := TDecompressionStream.Create(InputStream);
      try
        FinalSize := OutputStream.CopyFrom(DStream,OSize);
      finally
        FreeAndNil(DStream);
      end

    finally
      FreeAndNil(InputStream);
    end
  finally
    FreeMem(Buf);
  end;

  Result := FinalSize = OSize;

End;

constructor TAbProgress.Create(SetPercent: TPercentCallback);
begin

  _LastProgress := 255;
  _SetPercent := SetPercent;

end;

procedure TAbProgress.SetArchiveProgress(Sender : TObject; Progress : Byte; var Abort : Boolean);
begin

  if (_LastProgress <> Progress) then
  begin
    _LastProgress := Progress;
    SetPercent(Progress);
  end;

end;

procedure TAbProgress.SetItemProgress(Sender : TObject; Item : TAbArchiveItem; Progress : Byte; var Abort : Boolean);
begin

  if (_LastProgress <> Progress) then
  begin
    _LastProgress := Progress;
    SetPercent(Progress);
  end;

end;

procedure TAbProgress.SetProgress(Progress : Byte; var Abort : Boolean);
begin

  if (_LastProgress <> Progress) then
  begin
    _LastProgress := Progress;
    SetPercent(Progress);
  end;

end;

// Decompression of TGP0 (version 2)
//   Data block is gzipped, so first time a file is asked for extraction
//   We decompress the full data block to memory (BufferStream)
//   Then we extract the single entry
//   Following calls just extracts as the datablock is in memory
function DecompressTGP0ToStream(OutputStream: TStream; Offset:  Int64; OSize: Int64) : Boolean;
var
  Buf: PChar;
  CStream: TMemoryStream;
  FinalSize: integer;
  HDR: TGP0Header;
  HDR2: TGP0HeaderVersion2;
  gz : TAbGZipArchive;
  abprogress : TAbProgress;
  totsize: cardinal;
begin

  if (BufferStream = Nil) then
  begin
    totsize := FileSeek(FHandle,0,2);
    FileSeek(FHandle,0,0);
    FileRead(FHandle,HDR,SizeOf(TGP0Header));
    FileRead(FHandle,HDR2,SizeOf(TGP0HeaderVersion2));

    GetMem(Buf,totsize-HDR2.NumberOfEntries*SizeOf(TGP0EntryVersion2)-SizeOf(TGP0Header)-SizeOf(TGP0HeaderVersion2));
    try
      FileSeek(FHandle,HDR2.NumberOfEntries*SizeOf(TGP0EntryVersion2)+SizeOf(TGP0Header)+SizeOf(TGP0HeaderVersion2),0);
      FileRead(FHandle,Buf^,totsize-HDR2.NumberOfEntries*SizeOf(TGP0EntryVersion2)-SizeOf(TGP0Header)-SizeOf(TGP0HeaderVersion2));

      CStream := TMemoryStream.Create;
      try
        CStream.Write(Buf^,totsize-HDR2.NumberOfEntries*SizeOf(TGP0EntryVersion2)-SizeOf(TGP0Header)-SizeOf(TGP0HeaderVersion2));
        CStream.Seek(0, soBeginning);
        gz := TAbGZipArchive.CreateFromStream(CStream,'datablock.gzip');
        abprogress := TAbProgress.Create(SetPercent);
        try
          gz.OnArchiveItemProgress := abprogress.SetItemProgress;
          gz.Load;
          gz.Items[0].FileName;
          BufferStream := TMemoryStream.Create;
          gz.ExtractToStream('unknown',BufferStream);
        finally
          FreeAndNil(gz);
          FreeAndNil(abprogress);
          FreeAndNil(CStream);
        end;
      finally
        FreeAndNil(CStream);
      end
    finally
      FreeMem(Buf);
    end;
  end;

  try
    BufferStream.Seek(Offset,soFromBeginning);
    FinalSize := OutputStream.CopyFrom(BufferStream,OSize);
  except
    FinalSize := 0;
  end;

  Result := FinalSize = OSize;

End;

// Decryption of TGP0 with flag $1 is easy, entries are xored to 0x46
function DecryptTGP0ToStream(OutputStream: TStream; Offset:  Int64; OSize: Int64) : Boolean;
var
  Buf: array of byte;
  x, FinalSize: cardinal;
begin

  SetLength(Buf, OSize);
  FileSeek(Fhandle,Offset,0);
  FileRead(Fhandle,Buf[0],OSize);

  for x := 0 to OSize - 1 do
    Buf[x] := Buf[x] xor $46;

  try
    FinalSize := OutputStream.Write(Buf[0],OSize);
  except
    FinalSize := 0;
  end;

  Result := FinalSize = OSize;

End;

function DecompressRCFToStream(outputstream: TStream; offset,size: int64; bufsize : Integer; silent: boolean; DisplayPercent: TPercentCallback): boolean;
var HDR: RCFFileHeader;
begin

  FileSeek(FHandle,Offset,0);
  FileRead(FHandle,HDR,SizeOf(RCFFileHeader));
  if (strip0(HDR.ID) = 'RZ') and (HDR.ID[2] = #0) and (HDR.ID[3] = #0)
  and (HDR.ID[4] = #0) and (HDR.ID[5] = #0) and (HDR.ID[6] = #0) and (HDR.ID[7] = #0) then
    result := DecompressZlibToStream(outputstream,offset+16,HDR.OriginalSize)
  else
  begin
    BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
    result := true;
  end;

end;

procedure AboutBox; stdcall;
var aboutText, status11thHour: string;
begin

  if get11thHourStatus then
    status11thHour := DLNGStr('11TH07')
  else
    status11thHour := DLNGStr('11TH06');

  status11thHour := StringReplace(StringReplace(DLNGStr('11TH05'),'%s',status11thHour,[rfReplaceAll]),#10,'\par'+#10,[rfReplaceAll]);

  aboutText := '{\rtf1\ansi\ansicpg1252\deff0\deflang1036{\fonttbl{\f0\fswiss\fcharset0 Arial;}}'+#10+
                 '\viewkind4\uc1\pard\qc\ul\b\f0\fs24\par Elbereth''s Main Driver plugin v'+getVersion(DRIVER_VERSION)+'\par'+#10+
                 '\ulnone\b0\i\fs22 Created by \b Alexandre Devilliers (aka Elbereth/Piecito)\par'+#10+
                 '\par'+#10+
                 '\b0\i0\fs20 Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+'\par'+#10+
                 'Driver Interface [DUDI] v'+inttostr(DUDI_VERSION)+' (v'+inttostr(DUDI_VERSION_COMPATIBLE)+' compatible) [using v'+inttostr(SupportedDUDI)+']\par'+#10+
                 'Compiled the '+DateToStr(CompileTime)+' at '+TimeToStr(CompileTime)+'\par'+#10+
                 '\par'+#10+
                 '\ul 11th Hour (.GJD):\par'+#10+
                 '\ulnone '+status11thHour+'\par'+#10+
                 '\par'+#10+
                 '\ul Limitations:\par'+#10+
                 '\ulnone Breakneck .SYN files are not decrypted (useless support?)\par'+#10+
                 'Commandos 3 .PCK decryption is experimental.\par'+#10+
                 'Daikatana .PAK files: No extraction is possible.\par'+#10+
                 'Empires: Dawn of the Modern World SSA support is partial.\par'+#10+
                 'Novalogic .PFF files: Only PFF3 can be loaded.\par'+#10+
                 '\par'+#10+
                 '\ul Credits:\par'+#10+
                 '\ulnone realMyst 3D DNI support code based on source of:\par dniExtract by {\b Ken Taylor}\par'+#10+
                 'Darkstone MTF decompression code based on infos by:\par {\b Guy Ratajczak}\par'+#10+
                 'GTA3 IMG/DIR support based on specs and infos by:\par {\b Dan Strandberg} of Game-Editing.net\par'+#10+
                 'Spellforce PAK and Eve Online STUFF support based on infos by:\par {\b DaReverse}\par'+#10+
                 'Painkiller PAK support partially based on infos by:\par {\b MrMouse}\par'+#10+
                 'The Elder Scrolls 4: Oblivion BSA support based on infos found on:\par'+#10+
                 '{\b http://www.uesp.net/wiki/Tes4Mod:BSA_File_Format}\par'+#10+
                 'Giants .GZP decompression code based on infos by:\par'+#10+
                 '{\b Thilo Girmann (Nullpointer)}\par'+#10+
                 'Command & Conquer .MIX infos by:\par'+#10+
                 '{\b Olaf van der Spek}\par'+#10+
                 '{\b http://xhp.xwis.net/documents/MIX_Format.html}\par'+#10+
                 'Some file formats support based on info found on:\par'+#10+
                 '{\b http://wiki.xentax.com\par}'+
                 '}'+#10;

  // Dump XCC-Util .DAT filename database for Westwood MIX games if found
  dumpWestWoodMIX_XCCDatabase;

  showMsgBox('About Elbereth''s Main Driver plugin...',aboutText);

end;

function ExtractFileToStream(outputstream: TStream; entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: boolean): boolean; stdcall;
var ENT: MTFCompress;
    SSA: SSACompress;
    TMH: TMPAK_CompHeader;
    tbyt,key: byte;
    ID: array[0..2] of char;
    ID4: array[0..3] of char;
    Buf: PByteArray;
    BufEnd: PByteArray;
    ext: string;
begin

  ext := Uppercase(ExtractFileExt(entrynam));

  if DrvInfo.ID = 'AsuraZ' then
  begin
    result := DecompressAzuraZToStream(FHandle,outputstream,offset,Size);
    exit;
  end;

  FileSeek(FHandle,Offset,0);

  if DrvInfo.ID = '007' then
  begin
    if (DataX = 1) then
      DecompressZlibToStream(outputstream, DataY, Size)
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

  else if DrvInfo.ID = 'ADF' then
    DecryptADFToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent)

  else if DrvInfo.ID = 'BSA' then
  begin
    if (DataX = 1) then
    begin
      FileSeek(FHandle,Offset,0);
      DecompressZlibToStream(outputstream, DataY, Size);
    end
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

  else if DrvInfo.ID = 'CBF0' then
  begin
    if (DataY = 1) then
      DecompressCBFToStream(FHandle,outputstream,offset,DataX,Size,BUFFER_SIZE,silent,SetPercent)
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

  else if DrvInfo.ID = 'CBF1' then
  begin
    if (DataY = 1) then
      DecompressCBFToStream(FHandle,outputstream,offset,DataX,Size,BUFFER_SIZE,silent,SetPercent)
    else
      DecryptCBFToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent,SetPercent);
  end

  else if DrvInfo.ID = 'CUB' then
  begin
    BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent,CUBEXORByte);
  end

  else if DrvInfo.ID = 'DNI' then
  begin
    if (DataX > 0) then
      DecompressZlibToStream(outputstream, DataX, Size)
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

{  else if DrvInfo.ID = 'F22DAT' then
  begin
    DecompressF22DAT(FHandle,outputstream,offset,size,silent);
  end}

  else if DrvInfo.ID = 'GZP' then
  begin
    if (DataY = 1) then
    begin
      GetMem(Buf,DataX);
      try
        FileRead(FHandle,Buf^,DataX);
        BufEnd := DecompressGZP(Buf,Offset,DataX,Size);
        Outputstream.WriteBuffer(BufEnd^,Size);
        FreeMem(BufEnd);
      finally
        FreeMem(Buf);
      end;
    end
    else
      BinCopyToStream(FHandle,outputstream,offset,DataX,0,BUFFER_SIZE,silent,SetPercent);
  end

{IFDEF EXPFORMATS}
  else if DrvInfo.ID = 'H4R' then
  begin
// TODO //
//    if (DataX = 3) then
//    begin
//      ShowMessage(inttostr(DataX));
//      DecompressH4R(fil, Size, DataY);
{    end
    else
    begin
      GetMem(Buf,DataX);
      FileRead(FHandle,Buf^,DataX);
      FileWrite(fil,Buf^,DataX);
      FreeMem(Buf);
    end;}
  end
{ENDIF}

  // Total Annihilation .HPI
  else if DrvInfo.ID = 'HPI' then
  begin
    if (DataX = 2) or (DataX = 1) then
      DecompressHPIToStream(outputstream,Offset,Size,DataX,silent)
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

  else if Leftstr(DrvInfo.ID,4) = 'MOSD' then
  begin
    if (DataX = 1) or (DataX = 2) then
      ExtractMOSDTextureToDDS(outputstream,Offset,Size,DataY,BUFFER_SIZE,silent,Rightstr(DrvInfo.ID,1)='r',DataX=2)
    else
      BinCopyToStream(FHandle,outputstream,offset,size,0,BUFFER_SIZE,silent,SetPercent);
  end

  else if DrvInfo.ID = 'KAPL' then
    ExtractKAPLDXTToDDS(outputstream,Offset,Size,BUFFER_SIZE,silent)

  // Darkstone .MTF
  else if DrvInfo.ID = 'MTF' then
  begin
    FileRead(FHandle,ENT,12);
    if (ENT.ID2 = 190) and ((ENT.ID1 = 174) or (ENT.ID1 = 175)) then
      DecompressMTFToStream(outputstream, Offset+12,Size)
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

  else if DrvInfo.ID = 'PCK' then
  begin
    if (DataY = 1) then
    begin
      FileSeek(FHandle,offset+16,0);
      FileRead(FHandle,tbyt,1);
      tbyt := (tbyt xor $2C) - $10;
      if (tbyt = 0) then
        tbyt := $E
      else if (tbyt = 8) then
        tbyt := 6
      else
        dec(tbyt);
      key := tbyt;
      FileSeek(FHandle,offset,0);
      FileRead(FHandle,tbyt,1);
      tbyt := tbyt xor key;
      DecryptPCKToStream(FHandle,outputstream,offset,size,tbyt,silent);
    end
    else if (DataY = 2) or (DataX <> 0) then
    begin
      FileSeek(FHandle,offset+1,0);
      FileRead(FHandle,ID,3);
      FileSeek(FHandle,offset,0);
      if (ID = 'IFF') then
        DataX := $52
      else if (ID = 'DMB') then
        DataX := $4C
      else if (ID = 'FRL') then
        DataX := $47
      else if (ID = 'SMB') then
        DataX := $42;
      DecryptPCKToStream(FHandle,outputstream,offset,size,DataX,silent);
    end
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

  else if DrvInfo.ID = 'PKPAK' then
  begin
    if DataX <> Size then
      DecompressZlibToStream(outputstream, DataX, Size)
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

  else if DrvInfo.ID = 'TGP0' then
  begin
    // Compressed (only in v2)
    if DataX AND $2 = $2 then
      DecompressTGP0ToStream(outputstream, Offset, Size)
    // Encrypted (only in v1?) -- Only textures
    else if (DataX AND $1 = $1) then // and ((ext = 'BMP') or (ext = 'DDS') or (ext = 'JPEG') or (ext = 'JPG') or (ext = 'PNG') or (ext = 'TGA')) then
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent,$46)
    // In all other cases, simple binary copy
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

  // Ghostbusters: Sanctum of Slime .PAK decompression handling
  else if DrvInfo.ID = 'tonga' then
  begin
    if DataX = 1 then
      DecompressLZMAToStream(outputstream,offset,Size,silent)
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

  // The Movies .PAK decompression handling
  else if DrvInfo.ID = 'TMPAK' then
  begin

    // We go to offset and retrieve the compression header
    FileSeek(FHandle,Offset,0);
    FileRead(Fhandle,TMH,SizeOf(TMH));

    // We verify that everything is as expected
    if (TMH.TotSize = DataX) and (TMH.UncSize = Size) then
    begin

      // If the file is not compressed we just copy 1:1 starting from offset+16 (without the header)
      if (TMH.NotCompressed = 1) then
      begin

        // We check if there is a 2nd compression header (which only happens is first one is not compressed afaik)
        // -- Thanks to the Xentax wiki for the information --
        FileRead(FHandle,ID4,4);

        if (ID4 = 'zcmp') then
        begin
          // Then we read the second header
          FileRead(FHandle,TMH,SizeOf(TMH));

          // If the file is not compressed we just copy 1:1 starting from offset+16 (without the header)
          if (TMH.NotCompressed = 1) then
            BinCopyToStream(FHandle,outputstream,offset+16,Size,0,BUFFER_SIZE,silent,SetPercent)
          // Else we decompress the zlib data
          else
            DecompressZlibToStream(outputstream, TMH.CmpSize, Size);

        end
        else
          BinCopyToStream(FHandle,outputstream,offset+16,Size,0,BUFFER_SIZE,silent,SetPercent);

      end
      // Else we decompress the zlib data
      else
        DecompressZlibToStream(outputstream, TMH.CmpSize, Size);

    end
    // If something is not as expected we just copy 1:1
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);

  end

  else if DrvInfo.ID = 'RCF' then
  begin
    if (DataX = 1) then
      DecompressRCFToStream(outputstream,offset,size,BUFFER_SIZE,silent,SetPercent)
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

  else if DrvInfo.ID = 'RFA' then
  begin
    if (DataX = 0) then
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent)
    else if (DataX = 1) then
      DecompressRFAToStream(outputstream,Offset,Size,silent);
  end

  else if DrvInfo.ID = 'RFH/RFD' then
  begin
    if (DataX = 2) then
      DecompressRFDToStream(outputstream, DataY, Size)
    else if (DataX = 1) then
      BinCopyToStream(FHandle,outputstream,offset,DataY,0,BUFFER_SIZE,silent,SetPercent)
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

  else if DrvInfo.ID = 'SSA' then
  begin
    FileSeek(FHandle,offset,0);
    FileRead(FHandle,SSA,SizeOf(SSA));
    if SSA.ID = 'PK01' then
      DecompressZlibToStream(outputstream, Size, SSA.DecompSize)
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

  else if DrvInfo.ID = 'VFS' then
  begin
    if (DataX > 0) then
      DecompressZlibVFSChunksToStream(outputstream,offset,DataY,Size)
    else
      BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);
  end

  else
    BinCopyToStream(FHandle,outputstream,offset,Size,0,BUFFER_SIZE,silent,SetPercent);

  result := true;

end;

function ExtractFile(outputfile: ShortString; entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: boolean): boolean; stdcall;
var outStm: TFileStream;
begin

  outStm := TFileStream.Create(outputfile,fmCreate or fmShareExclusive);
  result := ExtractFileToStream(outStm,entrynam,offset,size,datax,datay,silent);
  FreeAndNil(outStm);

end;

procedure InternalMsgBox(const title, msg: AnsiString);
begin

  MessageBoxA(AHandle, PChar(msg), PChar(title), MB_OK);

end;

procedure InitPlugin(per: TPercentCallback; lngid: TLanguageCallback; DUP5Path: ShortString; AppHandle: THandle; AppOwner: TComponent); stdcall;
begin

  SetPercent := per;
  DLNGStr := lngid;
  CurPath := DUP5Path;
  AHandle := AppHandle;
  AOwner := AppOwner;
  showMsgBox := InternalMsgBox;

end;

procedure InitPluginEx5(MsgBox: TMsgBoxCallback); stdcall;
begin

  showMsgBox := MsgBox;

end;

procedure InitPluginEx6(AddEntryCB: TAddEntryCallback); stdcall;
begin

  addEntry := AddEntryCB;

end;

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

begin
end.
