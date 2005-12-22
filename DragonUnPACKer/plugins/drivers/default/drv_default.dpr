library drv_default;

// $Id: drv_default.dpr,v 1.20 2005-12-22 20:59:07 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/drivers/default/drv_default.dpr,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is drv_default.dpr, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

uses
//  Dialogs,
  Zlib,
  Classes,
  StrUtils,
  SysUtils,
  Windows,
  U_IntList in '..\..\..\common\U_IntList.pas',
  spec_HRF in '..\..\..\common\spec_HRF.pas',
  lib_version in '..\..\..\common\lib_version.pas';

{$E d5d}

{$R *.RES}

{$Include datetime.inc}

type EBadFormat = class(Exception);

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
   CurrentDriverInfo = record
     Sch : ShortString;
     ID : ShortString;
     FileHandle : Integer;
     ExtractInternal : Boolean;
   end;
   FormatInfo = record
     Extensions : ShortString;
     Name : ShortString;
   end;
   DriverInfo = record
     Name : ShortString;
     Author : ShortString;
     Version : ShortString;
     Comment : ShortString;
     NumFormats : Byte;
     Formats : array[1..255] of FormatInfo;
   end;
   ErrorInfo = record
     Format : ShortString;
     Games : ShortString;
   end;
   TPercentCallback = procedure (p: byte);
   TLanguageCallback = function (lngid: ShortString): ShortString;

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
        TODO --> Added Warrior Kings Battles BCP

  Possible bugs (TOCHECK):
  HPI Extraction when compression = 0 don't use HPIRead (no decryption of data)

  Known bugs/problems:
  Dungeon Keeper 2 DWFB files (.WAD) have compressed entries sometimes.
  (Those are not decompressed.. unknown compression used, maybe hauffman)

  Coded but disabled:
  Game                        Ext.   Description
  Heath: The Unchosen Path    NRM    Extraction problem (maybe some sort of RLE encoding)
                                     Need to fix the unamed file in root
  Vietcong                    CBF    Unknown decompression code

  //////////////////////////////////////////////////////////////////////////// }


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

type NRMHeader = packed record
       ID: array[0..17] of char;
     end;
     NRMEntry = packed record
       ID: array[0..4] of char;
       PacketSize: integer;
       Size: integer;
     end;
     // Get32 Filename

type M4BHeader = packed record
       SigSize: cardinal;
       SigName: array[0..10] of char;
     end;

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

type MTFCompress = packed record
        ID1: Byte;
        ID2: Byte;
        Reserved1 : Byte;
        Reserved2 : Byte;
        NumBlocks : integer ;
        Flags : integer;
     end;

type NascarDAT_Entry = packed record
       Unknow: word;
       Size: integer;
       Size2: integer;
       Filename: array[0..12] of char;
       Offset: integer;
     end;

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

type ARTHeader = packed record
       ARTVersion: integer;
       Numtiles: integer;
       LocalTileStart: integer;
       LocalTileEnd: integer;
     end;

type AWFEntry = packed record
       Offset: integer;
       Filename: array[0..259] of char;
     end;

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
     
type BIN_Entry = packed record
       Filename: array[0..15] of char;
       Offset: cardinal;
       Size: cardinal;
     end;

type BKF_Entry = packed record
       Filename: array[0..35] of char;
       Offset: integer;
       Size: integer;
     end;

type DIRIMG_Entry = packed record
       StartBlock: Longword;
       BlockCount: Longword;
       Name: array[0..23] of Char;
     end;

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

type FPKHeader = packed record
       Unknown1: Integer;
       ID: array[0..3] of char;
       Unknown2: Byte;
       NumEntries: integer;
     end;
     FPKEntry = packed record
       FileTime: Integer;
       Unknown: Integer;
       Size: Integer;
       Offset: Integer;
     end;

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
     SINHeader = packed record
        ID: array[1..4] of char;
        DirOffset: longword;
        DirNum: word;
     end;
     SINEntry = packed record
        Filename: array[1..120] of char;
        Offset: longword;
        Size: longword;
     end;

type PAKEntry = packed record
        Offset: longword;
        FileName: array[1..8] of Char;
     end;

type PKPAKHeader = packed record
        ID: byte;
        Offset: longword;
     end;

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
        Unknown: integer;
     end;

// Get0
type PBO_Entry = packed record
       EmptyVal: array[0..11] of byte;
       Unknown: integer;
       Size: integer;
     end;

type PCKEntry = packed record
       Name: array[0..35] of char;
       Flag: integer;              // $00 = File
                                   // $01 = Directory
                                   // $FF = End of directory
       Size: longword;             // $FFFFFFFF = Not a file
       Offset: longword;           // $FFFFFFFF = End of directory
     end;

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

type BW2STUFFEntry = packed record
       Filename: array[0..255] of char;  // Null terminated
       Offset: integer;
       Size: integer;
       CDateTime: integer;
     end;

type CBFHeader = packed record
        ID: array[1..8] of Char;  // BIGF 0x00 ZBL
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

type GRPHeader = packed record
        ID: Array[1..12] of Char;
        DirNum: Integer;
     end;
     GRPEntry = packed record
        FileName: Array[1..12] of Char;
        FileSize: integer;
     end;

const GRPID: String = 'KenSilverman';

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

type DGOBHeader = packed record
       ID: array[0..3] of char;
       DirOffset: integer;
     end;
     DGOBIndex = packed record
       Offset: integer;
       Size: integer;
       Name: array[0..12] of char;
     end;

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
       Empty: integer;
     end;

type H3SND_Index = packed record
       Filename: array[0..39] of char;
       Offset: integer;
       Size: integer;
     end;

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

type SDTIndex = packed record
       ISize: integer;
       Size: integer;
       Filename: array[0..15] of char;
       Unknow1: integer;
       Unknow2: integer;
       Unknow3: integer;
       Unknow4: integer;
     end;

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

type JFLHeader = packed record
       ID: array[0..3] of char;   // AP32
       Version: cardinal;         // 18
     end;
     JFLINDHeader = packed record
       ID: cardinal;              // 7
       NumEntries: cardinal;
     end;

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

type PODHeader = packed record
       Dirnum: integer;
       ID: array[0..79] of char;
     end;
     PODEntry = packed record
       Filename: array[0..31] of char;
       Size: integer;
       Offset: integer;
     end;

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

type PPRESIndex = packed record
       FileNameLength: byte;
       FileName: array[0..11] of char;
       Offset: longword;
       Length: longword;
       FileType: byte; // 1 = Text (sort of..)
                       // 2 = Binary
     end;
     PPXRSIndex = packed record
       FileNameLength: byte;
       FileName: array[0..11] of char;
       Offset: longword;
       Length: longword;
       Unknown: array[1..11] of byte; // DOS Date & Time + ???
     end;

type PRMHeader = packed record
       ID: cardinal;   // ID - Always $71E ?
       DirOffset: cardinal;
       DirOffset2: cardinal;
       NumEntries: cardinal;
     end;

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

type Version = packed record
       Major: Byte;
       Minor: Byte;
     end;
     HRF_Header = packed record
       ID: array[0..4] of char; // 'HRFi'+chr(26)
       Version: byte;           // 0 = Version 0 (No name change support)
                                // 1 = Version 1 (Default)
                                // 2 = Version 2 (Security + Infos)
       Filename: array[0..97] of char;
       FileSize: integer;
       HRipVer: Version;        // v0.0 = Version 32 (v2.1 Beta)
                                // v3.0 = Version 38 (v3.0 Beta)
                                // v3.1 = Version 39 (v3.1 Beta)
                                // v3.5 = Version 47 (v3.5 Beta)
                                // v4.0 = Version 71 (v4.0)
                                // v4.1 = Version 72 (v4.1)
                                // v4.2 = Version 74 (v4.2)
                                // --- Rewritted from scratch ---
                                // v5.0 = Version 5.0 Alpha
       Dirnum: integer;
     end;
     HRF_Infos_v0 = packed record
       InfoVer: byte;           // Version of Information chunk
                                // 0 = 2 bytes Information chunk
                                //     (only SecuritySize is present)
                                // 1 = 258 bytes Information chunk
       SecuritySize: byte;      // Max Size of Security Data in Directory v2
                                // Allowed values:
                                // 1,2,4,8 and 16
     end;
     HRF_Infos_v1 = packed record
       Author: array[0..63] of char;
       url: array[0..127] of char;
       Title: array[0..63] of char;
     end;
     HRF_Index_v0 = packed record
       FileType: byte;
       Offset: integer;
       Size: integer;
     end;
     HRF_Index_v1 = packed record
       Filename: array[0..31] of char;
       FileType: byte;
       Offset: integer;
       Size: integer;
     end;
     HRF_Index_v2 = packed record
       Filename: array[0..63] of char;
       FileType: byte;
       Offset: integer;
       Size: integer;
       Security: array[0..15] of byte;
     end;

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

type SAD_Header = packed record
       ID: array[0..31] of char;
       Size: integer;
     end;
     SAD_FileSegmentBankInfo = packed record
       Unknown: array[0..2] of integer;
       Comment: array[0..519] of char;
     end;
     SAD_Entry = packed record
       Filename: array[0..259] of char;
       NumID: integer;
       NumID2: integer;
       Size: integer;
       Offset: integer;
       Unknown: array[1..364] of byte;
     end;

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




type SAK_Header = packed record
       ID: array[0..3] of char;
       Version: integer;
       NumEntries: Word;
     end;

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

type RFH_Entry = packed record
       NameLength: integer;
       DateAdded: integer;
       IsPacked: integer;
       PackedSize: integer;
       OriginalSize: integer;
       Offset: integer;
     end;

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

const
  DRIVER_VERSION = 20040;
  DUP_VERSION = 52040;
  CVS_REVISION = '$Revision: 1.20 $';
  CVS_DATE = '$Date: 2005-12-22 20:59:07 $';
  BUFFER_SIZE = 4096;

  BARID : array[0..7] of char = #0+#0+#0+#0+#0+#0+#0+#0;
  REZID : String = #13+#10+'RezMgr Version 1 Copyright (C) 1995 MONOLITH INC.           '+#13+#10+'LithTech Resource File                                      '+#13+#10+#26;
  REZIDOld : String = #13+#10+'RezMgr Version 1 Copyright (C) 1995 MONOLITH INC.           '+#13+#10+'                                                            '+#13+#10+#26;
  DRSID : String = 'Copyright (c) 1997 Ensemble Studios.';
  DRSVer : String = '1.00';
  HOGID : String = 'DHF';
  HOG2ID : String = 'HOG2';
  NRMID : String = 'PakkaByRCL^DPL2000';
  FARID : String = 'FAR!';
  SLFID : array[0..11] of char = #255+#255+#0+#2+#1+#0+#0+#0+#0+#0+#0+#0;

  PKDECKEY : array[0..4] of integer = (-2, -1, 0, 1 ,2);

var DataBloc: FSE;
    OffsetList: TInts;
    FHandle: Integer = 0;
    CurFormat: Integer = 0;
    DrvInfo: CurrentDriverInfo;
    TotFSize: Integer = 0;
    ErrInfo: ErrorInfo;
    SetPercent: TPercentCallback;
    Per: Byte = 0;
    OldPer: byte = 0;
    DNISize : Integer;
    NumFSE: Integer;
    HPIKey: Integer;
    DLNGStr: TLanguageCallback;
    CurPath: string;
    AHandle : THandle;
    AOwner : TComponent;

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

// Identifies the DLL as a Driver plugin
// Exported
function DUDIVersion: Byte; stdcall;
begin
  DUDIVersion := 4;
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

  GetDriverInfo.Name := 'Main Driver';
  GetDriverInfo.Author := 'Dragon UnPACKer project team';
  GetDriverInfo.Version := getVersion(DRIVER_VERSION);
  GetDriverInfo.Comment := 'This driver support 75 different file formats. This is the official main driver.'+#10+'Some Delta Force PFF (PFF2) files are not supported. N.I.C.E.2 SYN files are not decompressed/decrypted.';
  GetDriverInfo.NumFormats := 63;
  GetDriverInfo.Formats[1].Extensions := '*.pak';
  GetDriverInfo.Formats[1].Name := 'Daikatana (*.PAK)|Dune 2 (*.PAK)|Star Crusader (*.PAK)|Trickstyle (*.PAK)|Zanzarah (*.PAK)|Painkiller (*.PAK)';
  GetDriverInfo.Formats[2].Extensions := '*.bun';
  GetDriverInfo.Formats[2].Name := 'Monkey Island 3 (*.BUN)';
  GetDriverInfo.Formats[3].Extensions := '*.grp;*.art';
  GetDriverInfo.Formats[3].Name := 'Duke Nukem 3D (*.GRP;*.ART)|Shadow Warrior (*.GRP;*.ART)';
  GetDriverInfo.Formats[4].Extensions := '*.pff';
  GetDriverInfo.Formats[4].Name := 'Comanche 4 (*.PFF)|Delta Force (*.PFF)|Delta Force 2 (*.PFF)|Delta Force: Land Warrior (*.PFF)|F33 Lightning 3';
  GetDriverInfo.Formats[5].Extensions := '*.rez';
  GetDriverInfo.Formats[5].Name := 'Alien vs Predator 2 (*.REZ)|No One Lives Forever (*.REZ)|No One Lives Forever 2 (*.REZ)|Sanity Aiken''s Artifact (*.REZ)|Shogo: Mobile Armor Division (*.REZ)|Purge (*.REZ)|Tron 2.0 (*.REZ)';
  GetDriverInfo.Formats[6].Extensions := '*.drs';
  GetDriverInfo.Formats[6].Name := 'Age of Empires 2: Age of Kings (*.DRS)';
  GetDriverInfo.Formats[7].Extensions := '*.ffl';
  GetDriverInfo.Formats[7].Name := 'Alien vs Predator (*.FFL)';
  GetDriverInfo.Formats[8].Extensions := '*.gob';
  GetDriverInfo.Formats[8].Name := 'Dark Forces (*.GOB)|Indiana Jones 3D (*.GOB)|Jedi Knight: Dark Forces 2 (*.GOB)';
  GetDriverInfo.Formats[9].Extensions := '*.hog;*.mn3';
  GetDriverInfo.Formats[9].Name := 'Descent (*.HOG)|Descent 2 (*.HOG)|Descent 3 (*.HOG;*.MN3)';
  GetDriverInfo.Formats[10].Extensions := '*.pak;*.tlk';
  GetDriverInfo.Formats[10].Name := 'Hands of Fate (*.PAK;*.TLK)|Lands of Lore (*.PAK;*.TLK)';
  GetDriverInfo.Formats[11].Extensions := '*.wad;*.sdt';
  GetDriverInfo.Formats[11].Name := 'Dungeon Keeper 2 (*.WAD;*.SDT)|Theme Park World (*.WAD;*.SDT)';
  GetDriverInfo.Formats[12].Extensions := '*.vp';
  GetDriverInfo.Formats[12].Name := 'Conflict: Freespace (*.VP)|Freespace 2 (*.VP)';
  GetDriverInfo.Formats[13].Extensions := '*.zfs';
  GetDriverInfo.Formats[13].Name := 'Interstate ''76 (*.ZFS)|Interstate ''82 (*.ZFS)';
  GetDriverInfo.Formats[14].Extensions := '*.pod';
  GetDriverInfo.Formats[14].Name := 'Terminal Velocity (*.POD)|BloodRayne (*.POD)|Nocturne (*.POD)';
  GetDriverInfo.Formats[15].Extensions := '*.hrf';
  GetDriverInfo.Formats[15].Name := 'Dragon UnPACKer HyperRipper (*.HRF)';
  GetDriverInfo.Formats[16].Extensions := '*.far';
  GetDriverInfo.Formats[16].Name := 'The Sims (*.FAR)';
  GetDriverInfo.Formats[17].Extensions := '*.sad';
  GetDriverInfo.Formats[17].Name := 'Black & White (*.SAD)';
  GetDriverInfo.Formats[18].Extensions := '*.x13';
  GetDriverInfo.Formats[18].Name := 'Hooligans (*.X13)';
  GetDriverInfo.Formats[19].Extensions := '*.slf';
  GetDriverInfo.Formats[19].Name := 'Jagged Alliance 2 (*.SLF)';
  GetDriverInfo.Formats[20].Extensions := '*.bag;*.rfh';
  GetDriverInfo.Formats[20].Name := 'Emperor: Battle for Dune (*.BAG;*.RFH)';
  GetDriverInfo.Formats[21].Extensions := '*.mtf';
  GetDriverInfo.Formats[21].Name := 'Darkstone (*.MTF)';
  GetDriverInfo.Formats[22].Extensions := '*.syn';
  GetDriverInfo.Formats[22].Name := 'Breakneck (*.SYN)|Excessive Speed (*.SYN)|N.I.C.E.2 (*.SYN)';
  GetDriverInfo.Formats[23].Extensions := '*.res';
  GetDriverInfo.Formats[23].Name := 'Electranoid (*.RES)|Evil Islands (*.RES)|Fuzzy''s World of Miniature Space Golf (*.RES)|Laser Light (*.RES)|Rage of Mages 2 (*.RES)|Xatax (*.RES)';
  GetDriverInfo.Formats[24].Extensions := '*.dta';
  GetDriverInfo.Formats[24].Name := 'Hidden & Dangerous (*.DTA)';
  GetDriverInfo.Formats[25].Extensions := '*.box';
  GetDriverInfo.Formats[25].Name := 'Lemmings Revolution (*.BOX)';
  GetDriverInfo.Formats[26].Extensions := '*.hal';
  GetDriverInfo.Formats[26].Name := 'Mortyr (*.HAL)';
  GetDriverInfo.Formats[27].Extensions := '*.bkf';
  GetDriverInfo.Formats[27].Name := 'Moto Racer (*.BKF)';
  GetDriverInfo.Formats[28].Extensions := '*.dat';
  GetDriverInfo.Formats[28].Name := 'Nascar Racing (*.DAT)|Gunlok (*.DAT)|LEGO Star Wars (*.DAT)';
  GetDriverInfo.Formats[29].Extensions := '*.pbo';
  GetDriverInfo.Formats[29].Name := 'Operation Flashpoint (*.PBO)';
  GetDriverInfo.Formats[30].Extensions := '*.awf';
  GetDriverInfo.Formats[30].Name := 'Qui veut gagner des millions (*.AWF)|Who wants to be a millionaire (*.AWF)';
  GetDriverInfo.Formats[31].Extensions := '*.pkr';
  GetDriverInfo.Formats[31].Name := 'Tony Hawk Pro Skater 2 (*.PKR)';
  GetDriverInfo.Formats[32].Extensions := '*.xcr';
  GetDriverInfo.Formats[32].Name := 'Warlords Battlecry (*.XCR)|Warlords Battlecry 2 (*.XCR)';
  GetDriverInfo.Formats[33].Extensions := '*.snd';
  GetDriverInfo.Formats[33].Name := 'Heroes of Might & Magic 3 (*.SND)';
  GetDriverInfo.Formats[34].Extensions := '*.art';
  GetDriverInfo.Formats[34].Name := 'Blood (*.ART)';
  GetDriverInfo.Formats[35].Extensions := '*.pak;*.wad';
  GetDriverInfo.Formats[35].Name := 'Quake (*.PAK;*.WAD)|Quake 2 (*.PAK;*.WAD)|Half-Life (*.PAK;*.WAD)|Heretic 2 (*.PAK;*.WAD)';
  GetDriverInfo.Formats[36].Extensions := '*.sni';
  GetDriverInfo.Formats[36].Name := 'MDK (*.SNI)';
  GetDriverInfo.Formats[37].Extensions := '*.wad';
  GetDriverInfo.Formats[37].Name := 'Gunman Chronicle (*.WAD)';
  GetDriverInfo.Formats[38].Extensions := '*.hpi;*.ufo';
  GetDriverInfo.Formats[38].Name := 'Total Annihilation (*.HPI;*.UFO)';
  GetDriverInfo.Formats[39].Extensions := '*.ccx';
  GetDriverInfo.Formats[39].Name := 'Total Annihilation: Counter-Strike (*.CCX)';
  GetDriverInfo.Formats[40].Extensions := '*.dni';
  GetDriverInfo.Formats[40].Name := 'realMyst 3D (*.DNI)';
  GetDriverInfo.Formats[41].Extensions := '*.vol';
  GetDriverInfo.Formats[41].Name := 'Earth Siege 2 (*.VOL)|Starsiege: Tribes (*.VOL)';
  GetDriverInfo.Formats[42].Extensions := '*.rfa';
  GetDriverInfo.Formats[42].Name := 'Battlefield 1942 (*.RFA)';
  GetDriverInfo.Formats[43].Extensions := '*.sin';
  GetDriverInfo.Formats[43].Name := 'Sin (*.SIN)';
  GetDriverInfo.Formats[44].Extensions := '*.img;*.adf';
  GetDriverInfo.Formats[44].Name := 'GTA3/Grand Theft Auto 3 (*.ADF;*.IMG)';
  GetDriverInfo.Formats[45].Extensions := '*.bar';
  GetDriverInfo.Formats[45].Name := 'Age of Mythology (*.BAR)|Age of Empires 3 (*.BAR)';
  GetDriverInfo.Formats[46].Extensions := '*.sak';
  GetDriverInfo.Formats[46].Name := 'Postal (*.SAK)';
  GetDriverInfo.Formats[47].Extensions := '*.007';
  GetDriverInfo.Formats[47].Name := 'James Bond 007: NightFire (*.007)';
  GetDriverInfo.Formats[48].Extensions := '*.CPR';
  GetDriverInfo.Formats[48].Name := 'Port Royale (*.CPR)|Patrician II (*.CPR)';
  GetDriverInfo.Formats[49].Extensions := '*.SQH';
  GetDriverInfo.Formats[49].Name := 'Harbinger (*.SQH)';
  GetDriverInfo.Formats[50].Extensions := '*.XRS';
  GetDriverInfo.Formats[50].Name := 'Dig It! (*.XRS)';
  GetDriverInfo.Formats[51].Extensions := '*.BIG';
  GetDriverInfo.Formats[51].Name := 'Command & Conquer: Generals (*.BIG)|Command & Conquer: Generals - Zero Hour (*.BIG)';
  GetDriverInfo.Formats[52].Extensions := '*.PCK';
  GetDriverInfo.Formats[52].Name := 'Commandos 3 (*.PCK)';
  GetDriverInfo.Formats[53].Extensions := '*.SSA';
  GetDriverInfo.Formats[53].Name := 'Empires: Dawn of the Modern World (*.SSA)';
  GetDriverInfo.Formats[54].Extensions := '*.STUFF';
  GetDriverInfo.Formats[54].Name := 'Eve Online (*.STUFF)';
  GetDriverInfo.Formats[55].Extensions := '*.TEX;*.PRM';
  GetDriverInfo.Formats[55].Name := 'Freedom Fighters (*.TEX;*.PRM)|Hitman 2: Silent Assassin (*.TEX;*.PRM)|Hitman: Contracts (*.TEX;*.PRM)';
  GetDriverInfo.Formats[56].Extensions := '*.BIN';
  GetDriverInfo.Formats[56].Name := 'CyberBykes: Shadow Racer VR (*.BIN)';
  GetDriverInfo.Formats[57].Extensions := '*.M4B';
  GetDriverInfo.Formats[57].Name := 'Myst IV: Revelation (*.M4B)';
  GetDriverInfo.Formats[58].Extensions := '*.JAM';
  GetDriverInfo.Formats[58].Name := 'Leisure Suite Larry: Magna Cum Laude (*.JAM)';
  GetDriverInfo.Formats[59].Extensions := '*.LUG';
  GetDriverInfo.Formats[59].Name := 'Fable: The Lost Chapter (*.LUG)';
  GetDriverInfo.Formats[60].Extensions := '*.STUFF;*.LUG';
  GetDriverInfo.Formats[60].Name := 'Black & White 2 (*.LUG;*.STUFF)';
  GetDriverInfo.Formats[61].Extensions := '*.FPK';
  GetDriverInfo.Formats[61].Name := 'Civilization 4 (*.FPK)';
  GetDriverInfo.Formats[62].Extensions := '*.LUG;*.BIG';
  GetDriverInfo.Formats[62].Name := 'The Movies (*.BIG;*.LUG)';
  GetDriverInfo.Formats[63].Extensions := '*.ARCH00';
  GetDriverInfo.Formats[63].Name := 'F.E.A.R. (*.ARCH00)';
//  GetDriverInfo.Formats[50].Extensions := '*.PAXX.NRM';
//  GetDriverInfo.Formats[50].Name := 'Heath: The Unchosen Path (*.PAXX.NRM)'
//  GetDriverInfo.Formats[41].Extensions := '*.h4r';
//  GetDriverInfo.Formats[41].Name := 'Heroes of Might & Magic 4 (*.H4R)';

end;

// Used to keep only all caracters up to the first chr(0) encountered
// Ex: 'this is a pchar in string'+chr(0) will return same without chr(0)
function strip0(str : string): string;
var pos0: integer;
begin

  pos0 := pos(chr(0),str);

  if pos0 > 0 then
    strip0 := copy(str, 1, pos0 - 1)
  else
    strip0 := str;

end;

function Get0_Stream(src: TMemoryStream): string;
var tchar: Char;
    res: string;
begin

  repeat
    src.Read(tchar,1);
    res := res + tchar;
  until tchar = chr(0);

  Get0_Stream := res;

end;

function Get0(src: integer): string;
var tchar: Char;
    res: string;
begin

  repeat
    FileRead(src,tchar,1);
    res := res + tchar;
  until tchar = chr(0);

  Get0 := res;

end;

function Get8(src: integer): string;
var tchar: Pchar;
    tbyte: Byte;
    res: string;
begin

  FileRead(src,tbyte,1);
  GetMem(tchar,tbyte);
  FillChar(tchar^,tbyte,0);
  FileRead(src,tchar^,tbyte);

  res := tchar;
  result := Copy(res,1,tbyte);

  FreeMem(tchar);

end;

function Get16(src: integer): string;
var tchar: Pchar;
    tword: Word;
    res: string;
begin

  FileRead(src,tword,2);
  GetMem(tchar,tword);
  FillChar(tchar^,tword,0);
  FileRead(src,tchar^,tword);

  res := tchar;
  Get16 := Copy(res,1,tword);

  FreeMem(tchar);

end;

function Get32(src: integer): string;
var tchar: Pchar;
    tint: Integer;
    res: string;
begin

  FileRead(src,tint,4);
  if tint > 255 then
  begin
    raise Exception.Create(inttostr(tint)+' octets! t''es fou ?!'+#10+inttostr(fileseek(FHandle,0,1))+#10+inttohex(fileseek(FHandle,0,1),8));
  end;
  GetMem(tchar,tint);
  FillChar(tchar^,tint,0);
  FileRead(src,tchar^,tint);

  res := tchar;
  Get32 := Copy(res,1,tint);

  FreeMem(tchar);

end;

function Get32_FPK(src: integer): string;
var tchar: Pchar;
    tint, x: Integer;
    res: string;
begin

  FileRead(src,tint,4);
  if tint > 255 then
  begin
    raise Exception.Create(inttostr(tint)+' octets! t''es fou ?!'+#10+inttostr(fileseek(FHandle,0,1))+#10+inttohex(fileseek(FHandle,0,1),8));
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

function Get32v(src: integer; size: integer): string;
var tchar: PChar;
    res: string;
    x: integer;
begin

  GetMem(tchar,size);

  FillChar(tchar^,size,0);
  FileRead(src,tchar^,size);

  for x := 0 to size-1 do
    res := res + tchar[x];

  FreeMem(tchar);

  Get32v := Copy(res,1,size);

end;

function Get32w(src: integer): string;
var wString: WideString;
    tint: Integer;
begin

  FileRead(src,tint,4);
  SetLength(wString,tint);
  FileRead(src,Pointer(wString)^,tint*2);

  result := UTF8Encode(wString);

end;

function posrev(substr: string; str: string): integer;
var res,x : integer;
begin

  res := 0;
  x := (length(str) - length(substr) + 1);

  while (x >= 1) and (res = 0) do
  begin

    if copy(str,x, length(substr)) = substr then
      res := x;

    x := x - 1;

  end;

  posrev := res;

end;

function GetSwapInt(src: integer): Integer;
var tint: integer;
begin
  FileRead(src,tint,4);
  result := swap(tint shr 16) or
           (longint(swap(tint and $ffff)) shl 16);
end;

{  FileRead(src,tbyt,4);
  cc := 1;
  res := 0;
  for x := 3 downto 0 do
  begin
    res := res + cc * tbyt[x];
//    ShowMessage(IntToStr(tbyt[x])+#10+IntToStr(res));
    cc := cc * 256;
  end;

  GetSwapInt := res;
end;
 }

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

end;

procedure Offset_add(Offset: Integer);
var nouvL: TInts;
begin

  new(nouvL);
  nouvL^.Value := Offset;
  nouvL^.suiv := OffsetList;
  OffsetList := nouvL;

end;

procedure Offset_clear();
var a: TInts;
begin

  while OffsetList <> NIL do
  begin
    a := OffsetList;
    OffsetList := OffsetList^.suiv;
    Dispose(a);
  end;

end;

function Offset_check(Offset: Integer): Boolean;
var a: TInts;
    res: Boolean;
begin

  a := OffsetList;
  res := false;

  while (a <> NIL) and not(res) do
  begin
    res := (a^.Value = Offset);
    a := a^.suiv;
  end;

  Offset_check := res;

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

function ReadAoe2DRS(src: string): Integer;
var HDR: DRSHeader;
    ENT: DRSEntry;
    disp: string;
    NumE, x: integer;
    BufTest: array[0..3] of Char;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadAscaronCPR(src: string): Integer;
var ID: CPRID;
    HDR: CPRHeader;
    ENT: CPREntry;
    disp: string;
    NumE, x, smallerOffset, res, lastOffset: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
    ErrInfo.Format := 'FFL';
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

function ReadAvpRFFL(src: string): Integer;
var HDR: RFFLHeader;
    ENT: RFFLEntry;
    disp: string;
    NumE, x: integer;
    NSize: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function revInt(tab: array of byte): integer;
begin

  result := tab[3] + tab[2] * $100 + tab[1] * $10000 + tab[0] * $1000000;

//  ShowMessage(inttostr(tab[0])+#10+inttostr(tab[1])+#10+inttostr(tab[2])+#10+inttostr(tab[3]));
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

  Fhandle := FileOpen(src, fmOpenRead);

  if FHandle > 0 then
  begin

    // We retrieve the full size of the file
    TotFSize := FileSeek(Fhandle,0,2);
    FileSeek(FHandle,0,0);

    // We read the header
    FileRead(FHandle,HDR,SizeOf(HDR));

    // If the ID is "FPK_"
    if (HDR.ID <> 'FPK_') then
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'FPK';
      ErrInfo.Games := 'Cibilization 4';
    end
    else
    begin

      // We store number of entries
      NumE := HDR.NumEntries;

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
        disp := Strip0(Get32_FPK(FHandle));

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
      DrvInfo.ID := 'FPK';
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

function ReadCommandAndConquerGeneralsBIG: Integer;
var HDR: BIGHeader;
    ENT: BIGEntry;
    disp: string;
    NumE, x, OldPer: integer;
    TotFSize: Integer;
begin

  TotFSize := FileSeek(Fhandle,0,2);
  FileSeek(FHandle,0,0);
  FileRead(FHandle,HDR,SizeOf(HDR));

  if (HDR.ID <> 'BIGF') or (TotFSize <> HDR.TotFileSize) then
  begin
    FileClose(Fhandle);
    FHandle := 0;
    Result := -3;
    ErrInfo.Format := 'BIGF';
    ErrInfo.Games := 'Command & Conquer: Generals';
  end
  else
  begin

    NumE := revInt(HDR.NumFiles);
    OldPer := 0;

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
      FSE_Add(disp,revInt(ENT.Offset),revInt(ENT.Size),0,0);
    end;

    Result := NumE;

    DrvInfo.ID := 'BIGF';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

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

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadCyberBykesBIN(src: string): Integer;
var ENT: BIN_Entry;
    disp: string;
    NumE, x, preval: integer;
    curOffset: int64;
    TotFSize: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

  if FHandle > 0 then
  begin

    TotFSize := FileSeek(Fhandle,0,2);
    FileSeek(FHandle,0,0);
    FileRead(FHandle,NumE,4);

    if (((NumE*4)+4) > TotFSize) or (NumE < 0) then
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

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadDuke3DART(src: string): Integer;
var HDR: ARTHeader;
    NumE, x: integer;
    Offset: integer;
    XList: array of word;
    YList: array of word;
    PicAnm: array of integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadDuke3DGRP(src: string): Integer;
var HDR: GRPHeader;
    ENT: GRPEntry;
    disp: string;
    NumE, x: integer;
    Offset: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
      disp := Get32v(FHandle,ENT.NameSize);

      FSE_Add(Strip0(disp),ENT.Offset,ENT.Size,ENT.CompMethod,ENT.UncompSize);

    end;

    ReadDungeonKeeper2DWFB := NumE;

    DrvInfo.ID := 'DWFB';
    DrvInfo.Sch := '\';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

function ReadDungeonKeeper2SDT(src: string): Integer;
var ENT: SDTIndex;
    disp: string;
    NumE, x: integer;
    Offset: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadEarthSiege2VOL(src: string): Integer;
var HDR: VOL_Header;
    HDR2: VOL_Header2;
    ENT, OLD: VOL_Entry;
    NumE,x,p: integer;
    BufNam: string;
    EList: TStringList;
    FSize: word;
begin

  Fhandle := FileOpen(src, fmOpenRead);

  if FHandle > 0 then
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
        EList.Free;
      end;

      //ShowMessage(IntTosTr(NumE));

      Result := NumE;

      DrvInfo.ID := 'VOL';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

end;

function ReadEmpiresDawnOfTheModernWorldSSA(src: string): Integer;
var HDR: SSAHeader;
    ENT: SSAEntry;
    NumE, curPos: integer;
    disp: string;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
    DrvInfo.ExtractInternal := True;

  end;

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

function ReadFearARCH00(src: string): Integer;
var HDR: ARCH00_Header;
    ENT: ARCH00_Entry;
    DIR: ARCH00_Directory;
    disp, dirname: string;
    NumE, x, curDir, curP, oldPer: integer;
    namStream, dirStream: TMemoryStream;
    filStream: THandleStream;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
          filStream.Seek(curP,soFromBeginning);

        finally

          // We free the handle stream
          filStream.Free;

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
            dirStream.Seek(curDir*SizeOf(DIR),soFromBeginning);

            // We read it
            dirStream.ReadBuffer(DIR,SizeOf(DIR));

            // We retrieve the name
            namStream.Seek(DIR.NamePos,soFromBeginning);
            dirname := strip0(get0_Stream(namStream));

            // We include the trailing slash is needed
            if length(dirname)>0 then
              dirname := dirname + '\';

          end;

          // We read the entry
          FileRead(FHandle,ENT,SizeOf(ENT));

          // We retrieve the name
          namStream.Seek(ENT.NamePos,soFromBeginning);
          disp := strip0(get0_Stream(namStream));

          // We store the entry
          FSE_Add(dirname+disp,ENT.Offset,ENT.Size,0,0);

          // We decrease the directory entry counter
          dec(DIR.NumEntries);

        end;

      finally

        // We free both memory streams
        namStream.Free;
        dirStream.Free;

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

function ReadFreespaceVP(src: string): Integer;
var HDR: VPHeader;
    ENT: VPEntry;
    disp, currep: string;
    NumE, x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadBattlefield1942(src: string): integer;
var ENT: RFA_Entry;
    disp: string;
    ID: array[0..27] of char;
    NumE, x: integer;
    Offset: integer;
    IsRetail, IsComp: boolean;
begin

  Fhandle := FileOpen(src, fmOpenRead);
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

function ReadLionheadAudioBank(src: string): Integer;
var HDR: LUG_Chunk;
    ABST_HDR: LUG_LHAudioBankSampleTable;
    ABST_ENT: LUG_LHAudioBankSampleTable_Entry;
    ABST_ENT_Size: cardinal;
    IDst: array[0..7] of char;
    disp: string;
    NumE, x: integer;
    DataOffset, DirOffset, DirNum, DirSize, FLength, CurP, idx: integer;
    MusicOffset, MusicSize, OldPer, Per: integer;
    tagid, nam: string;
    IsMusic, IsFirst: boolean;
    StoredOffsets: TIntList;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
            StoredOffsets.Free;
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

function ReadBloodRaynePOD(): Integer;
var HDR: POD3Header;
    ENT: POD3Entry;
    disp: string;
    NumE, x: integer;
    buf: PByteArray;
    NameStream: TMemoryStream;
begin

  FileSeek(Fhandle, 0, 0);
  FileRead(Fhandle, HDR, SizeOf(POD3Header));

  GetMem(buf,HDR.NamesSize);
  NameStream := TMemoryStream.Create;
  try
    FileSeek(FHandle,HDR.DirOffset+HDR.NumEntries*SizeOf(POD3Entry),0);
    FileRead(FHandle,Buf^,HDR.NamesSize);
    NameStream.Write(buf^,HDR.NamesSize);
    NameStream.Seek(0,0);
  finally
    FreeMem(buf);
  end;

  NumE := HDR.NumEntries;

  FileSeek(Fhandle, HDR.DirOffset, 0);

  for x := 1 to NumE do
  begin

    Per := ROund(((x / NumE)*100));
    SetPercent(Per);

    FileRead(Fhandle, ENT, SizeOf(POD3Entry));
    NameStream.Seek(ENT.NameOffset,0);
    disp := Get0_Stream(NameStream);

    FSE_Add(Strip0(disp),ENT.Offset,ENT.Size,0,0);

  end;

  NameStream.Free;

  Result := NumE;

  DrvInfo.ID := 'POD3';
  DrvInfo.Sch := '\';
  DrvInfo.FileHandle := FHandle;
  DrvInfo.ExtractInternal := False;

end;

function ReadGTA3ADF(src: string): Integer;
var test: byte;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
    DHandle := FileOpen(dirfile, fmOpenRead);
    FHandle := FileOpen(imgfile, fmOpenRead);

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

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadHeathNRM(src: string): Integer;
var HDR: NRMHeader;
    ENT: NRMEntry;
    NumE,offset : integer;
    nam: string;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadHeroesOfMightAndMagic3SND(src: string): Integer;
var ENT: H3SND_Index;
    NumE,x,z : integer;
    ext, nam: string;
    next: boolean;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadHeroesOfMightAndMagic4H4R(src: string): Integer;
var HDR: H4R_Header;
    ENT: H4R_Index;
    NumE,x, compress : integer;
    nam, dir: string;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadHiddenAndDangerousDTA(src: string): Integer;
var HDR: DTA_CNT_Header;
    ENT: DTA_CNT_Entry;
    disp,cfil: string;
    NumE,x: integer;
    Chandle: integer;
    ID: array[0..3] of char;
begin

  FHandle := FileOpen(src, fmOpenRead);

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
        Chandle := FileOpen(cfil, fmOpenRead);

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

function ReadHitmanContractsPRM(src: string): Integer;
var HDR: PRMHeader;
    x: integer;
    nam, prenam: string;
    offsets: array of cardinal;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadHitmanContractsTEX(src: string): Integer;
var HDR: TEX_Header;
    ENT: TEX_Entry;
    NumE: cardinal;
    x, y: integer;
    nam: string;
    offsets: array of cardinal;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

  Chandle := FileOpen(src, fmOpenRead);

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
             FileRead(Chandle,HDR3,SizeOf(HDR3));

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
             else
             begin

               Fhandle := FileOpen(cfil, fmOpenRead);

               if FHandle <= 0 then
               begin
                 FileClose(Chandle);
                 FHandle := 0;
                 ReadHyperRipperHRF := -4;
                 ErrInfo.Format := 'HRF3';
                 ErrInfo.Games := TrimRight(HDR.Filename);
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

          Fhandle := FileOpen(cfil, fmOpenRead);

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

function ReadDune3RFH(src: string): Integer;
var ENT: RFH_Entry;
    disp,dfil: string;
    NumE: integer;
    Chandle: integer;
    EndSize: integer;
begin

  Chandle := FileOpen(src, fmOpenRead);

  if CHandle > 0 then
  begin
    dfil := ChangeFileExt(src,'.rfd');

    if not(FileExists(dfil)) then
    begin
      FileClose(Chandle);
      FHandle := 0;
      Result := -4;
      ErrInfo.Format := 'RFH/RFD';
      ErrInfo.Games := dfil;
    end
    else
    begin
      Fhandle := FileOpen(dfil, fmOpenRead);

      EndSize := FileSeek(CHandle, 0,2);
      FileSeek(CHandle, 0, 0);

      NumE := 0;

      while FileSeek(CHandle,0,1) < EndSize do
      begin
        Per := ROund(((EndSize / (FileSeek(CHandle,0,1)+1))*100));
        SetPercent(Per);
        FileRead(CHandle, ENT, 24);
        disp := Strip0(Get0(CHandle));
        FSE_Add(disp,ENT.Offset,ENT.OriginalSize,ENT.IsPacked,ENT.PackedSize);
        Inc(NumE);
      end;

      FileClose(Chandle);

      Result := NumE;

      DrvInfo.ID := 'RFH/RFD';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end;
  end
  else
    Result := -2;

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

function ReadInterstateZFS(src: string): Integer;
var HDR: ZFSHeader;
    ENT: ZFSEntry;
    disp: string;
    NumE, x, glop: integer;
    Offset: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadJaggedAlliance2SLF(src: string): Integer;
var HDR: SLFHeader;
    ENT: SLFEntry;
    disp: string;
    x, DirOffset: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadLegoStarWarsDAT: Integer;
var HDR: LEGODAT_Header;
    stmNames: TMemoryStream;
    stmSource: THandleStream;
    disp: string;
    x, y, EntrySize, DirTableSize, NamesSize: integer;
    ENT: array of LEGODAT_Entry;
    DIR: array of LEGODAT_Directory;
    dirname: array of string;
begin

  FileSeek(Fhandle, 0, 0);
  FileRead(FHandle, HDR, 8);

  FileSeek(FHandle,HDR.DirOffset+4,0);
  FileRead(FHandle,EntrySize,4);

  setLength(ENT,EntrySize);

  for x := 0 to EntrySize-1 do
    FileRead(FHandle,ENT[x],16);

  //FileSeek(FHandle,EntrySize*16,1);
  FileRead(FHandle,DirTableSize,4);

  setLength(DIR,DirTableSize);

  for x := 0 to DirTableSize-1 do
  begin
    FileRead(FHandle,DIR[x],8);
  end;

  FileRead(FHandle,NamesSize,4);

  stmNames := TMemoryStream.Create;
  stmSource := THandleStream.Create(FHandle);

  try

    stmNames.CopyFrom(stmSource,NamesSize);

  finally

    stmSource.Free;

  end;

  setLength(DirName,DirTableSize);

  for x := 0 to DirTableSize-1 do
  begin
    stmNames.Seek(DIR[x].NamePos,soFromBeginning);
    disp := Strip0(Get0_Stream(stmNames));
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
  stmNames.Free;

  Result := EntrySize;

  DrvInfo.ID := 'LEGODAT';
  DrvInfo.Sch := '\';
  DrvInfo.FileHandle := FHandle;
  DrvInfo.ExtractInternal := False;

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

  Fhandle := FileOpen(src, fmOpenRead);

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
        EList.Free;
        FList.Free;
        OList.Free;
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

function ReadLemmingsRevolutionBOX(src: string): Integer;
var HDR: LEMBOXHeader;
    ENT: LEMBOXEntry;
    NumE,x,OldOffset : integer;
    EList: TStringList;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
        EList.Free;
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

function ReadQuiVeutGagnerDesMillionsAWF(src: string): Integer;
var ENT: AWFEntry;
    NumE,x,OldOffset : integer;
    nam: string;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

procedure DNIDirectory(cdir: string; coffset: integer; ftoffset:integer);
var DIR: DNIDir;
    FIL: DNIFile;
    cdir2, cdirp, nam: string;
    x, ObjOffset: integer;
begin

  FileSeek(FHandle, coffset,0);

  FileRead(FHandle,DIR.Offset,4);
  FileRead(FHandle,DIR.NumObj,4);

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
      FileRead(FHandle,FIL.OffsetName, 4);
      FileRead(FHandle,FIL.OffsetNameNext, 4);
      FileRead(FHandle,FIL.Length, 4);
      FileRead(FHandle,FIL.Offset, 4);
      FileRead(FHandle,FIL.Empty, 4);
      FileSeek(FHandle,FIL.OffsetName,0);
      nam := strip0(get0(FHandle));
      Inc(DNISize);
      FSE_Add(cdir + nam,FIL.Offset, FIL.Length, 0, 0);
    end;
    Inc(coffset,4);
  end;

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

function ReadRealMystDNI(src: string): Integer;
var HDR: DNIHeader;
begin

  Fhandle := FileOpen(src, fmOpenRead);

  if FHandle > 0 then
  begin
    TotFSize := FileSeek(FHandle,0,2);

    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR.ID, 4);
    FileRead(FHandle, HDR.Version, 4);
    FileRead(FHandle, HDR.DIROffset, 4);
    FileRead(FHandle, HDR.FTOffset, 4);
    FileRead(FHandle, HDR.NLOffset, 4);
    FileRead(FHandle, HDR.DataOffset, 4);
    FileRead(FHandle, HDR.FTOffsetA, 4);

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
      DrvInfo.ExtractInternal := False;

    end;

  end
  else
    Result := -2;

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
    disp := Get0_Stream(NameStream);

    FSE_Add(Strip0(disp),ENT.Offset,ENT.Size,0,0);

  end;

  NameStream.Free;

  Result := NumE;

  DrvInfo.ID := 'POD2';
  DrvInfo.Sch := '\';
  DrvInfo.FileHandle := FHandle;
  DrvInfo.ExtractInternal := False;

end;

function ReadNovalogicPFF3(src: string): Integer;
var HDR: PFFHeader;
    ENT: PFFEntry;
    disp: string;
    NumE, x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadSinSIN(src: string): Integer;
var HDR: SINHeader;
    ENT: SINEntry;
    disp: string;
    NumE, x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
      nameoffset := 94+HDR.NbFatEntry*16;
      for x := 1 to HDR.NbFatEntry do
      begin
        FAT.Read(ENT,SizeOf(ENT));
        if (ENT.NameOffset and $FF000000) <> 0 then
          ENT.NameOffset := ENT.NameOffset and $FFFFFF;

        FileSeek(FHandle,ENT.NameOffset+nameoffset,0);
        disp := revstr(Strip0(Get0(FHandle)));

        FSE_Add(disp,ENT.RelOffset+HDR.DataOffset,ENT.Size,0,0);
      end;

    finally
      HF.Free;
      FAT.Free;
    end;

    Result := HDR.NbFatEntry;

    DrvInfo.ID := 'MPF4';
    DrvInfo.Sch := '/';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

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

function ReadStarCrusaderPAK(IsGL: Boolean): Integer;
var disp: string;
    NumE: word;
    x, Offset, OldOffset, TotSize: integer;
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

function ReadMDKSNI(src: string): Integer;
var HDR: MDK1Header;
    ENT: MDK1Index;
    disp, extf: string;
    NumE, x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadMonkeyIsland3BUN(src: string): Integer;
var HDR: BUNHeader;
    ENT: BUNEntry;
    disp: string;
    NumE, x: integer;
    Offset: integer;
    Size: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadMortyrHAL(src: string): Integer;
var HDR: APUKHeader;
    ENT: APUKEntry;
    NumE,x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadMotoRacerBKF(src: string): Integer;
var ENT: BKF_Entry;
    NumE,x, DirNum: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
      disp := Strip0(Get32(FHandle));
      if length(dir) > 0 then
        disp := dir + '\' + disp;
      inc(result,ReadMystIVRevelationM4B_Alt(disp));
    end;
    FileRead(FHandle,tInt,4);
    inc(tInt);
    dec(tInt);
  end;

end;

function ReadMystIVRevelationM4B(src: string): Integer;
var HDR: M4BHeader;
    tInt: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadNascarDAT(): Integer;
var ENT: NascarDAT_Entry;
    NumE,x : integer;
    DirNum : word;
begin

  TotFSize := FileSeek(FHandle,0,2);

  FileSeek(Fhandle, 0, 0);
  FileRead(FHandle, DirNum, 2);

  if ((DirNum > 1000) or (DirNum < 1)) then
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

      FSE_Add(Strip0(ENT.Filename),ENT.Offset,ENT.Size,0,0);

    end;

    Result := NumE;

    DrvInfo.ID := 'DAT';
    DrvInfo.Sch := '';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := False;

  end;

end;

function ReadNICE2SYN(src: string): Integer;
var HDR: SYN_Header;
    ENT: SYN_Entry;
    NumE,x : integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

type
  PN007List = ^N007List;
  N007List = record
    Name: string;
    Size: integer;
    CompSize: integer;
    Compressed: byte;
    Offset: Integer;
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

  Fhandle := FileOpen(src, fmOpenRead);

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
        EList.Free;
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

function ReadOperationFlashpointPBO(src: string): Integer;
var ENT: array[1..2000] of PBO_Entry;
    NumE,x, coffset : integer;
    nam: string;
    EList: TStringList;
    SlashMode: boolean;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
      EList.Free;
    end;

  end
  else
    Result := -2;

end;

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
      HF.Seek(HDR.Offset,soFromBeginning);

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
      HF.Free;
    end;

    Result := NumE;

    DrvInfo.ID := 'PKPAK';
    DrvInfo.Sch := '/';
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := true;

  end;

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

function ReadPixelPaintersXRS(src: string): Integer;
var ENT: PPXRSIndex;
    NumFiles: word;
    GoodFormat: boolean;
    Per: byte;
    x: integer;
begin

  SetPercent(0);

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadPostalSAK(src: string): Integer;
var HDR: SAK_Header;
    disp, oldDisp: string;
    NumE, x, CurOffset, OldOffset, TotSize: integer;
    EList: TList;
    ENT: PPostalList;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
        EList.Free;
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

function ReadTerminalVelocityPOD(): Integer;
var HDR: PODHeader;
    ENT: PODEntry;
    disp: string;
    NumE, x: integer;
begin

  if FHandle > 0 then
  begin
    FileSeek(Fhandle, 0, 0);
    FileRead(FHandle, HDR, 84);

    if HDR.Dirnum < 1 then
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
        disp := Strip0(ENT.FileName);

        //owMessage(ENT.Filename+#10+disp);

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
      FilData.Seek(HDR.DirOffset,soFromBeginning);

      // We copy the chunk to the memory stream
      DirData.CopyFrom(FilData,HDR.DirSize);

    finally

      // We free the handle stream
      FilData.Free;

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
        DirData.Seek((ENT.DirPos and $7FFF) shr 1, soFromBeginning);

        // We get the directory (null terminated)
        disp := Strip0(Get0_Stream(DirData));

        // We concatenate the directory and the entry name
        disp := disp + strip0(ENT.EntryName);

        // We store the result
        FSE_Add(disp,ENT.Offset,ENT.UncSize,ENT.CmpSize,0);

      end;

    finally

      // We free the directory chunk
      DirData.Free;

    end;

    Result := NumE;

    DrvInfo.ID := 'TMPAK';
    DrvInfo.Sch := '\';
    // Extraction will be handled by this plugin because it needs some processing (Zlib decompression)
    DrvInfo.FileHandle := FHandle;
    DrvInfo.ExtractInternal := True;

  end;

end;

function ReadTheSimsFAR(src: string): Integer;
var HDR: FARHeader;
    ENT: FAREntry;
    disp: string;
    NumE, x: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadTonyHawkPKR(src: string): Integer;
var HDR: PKR_Header;
    DIR: PKR_Dir;
    ENT: PKR_Entry;
    NumE,x,cdir : integer;
    EList: TStringList;
    DList: array[0..1000] of Integer; 
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
        EList.Free;
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

function ReadTotalAnnihilationHPI(src: string): Integer;
var HDR: HPIHeader;
    key: integer;
    Buffer, BufEmpty: PByteArray;
    BufMem: TMemoryStream;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadVietcongCBF(src: string): Integer;
var HDR: CBFHeader;
    ENT: CBFEntry;
    disp: string;
    x: integer;
    TotSize: int64;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
        if ENT.CompType <>0 then
          disp := disp + '.ddc';
        FSE_Add(disp,ENT.Offset,ENT.Size,ENT.CompSize,ENT.CompType);
      end;

      Result := HDR.DirNum;

      DrvInfo.ID := 'CBF';
      DrvInfo.Sch := '\';
      DrvInfo.FileHandle := FHandle;
      DrvInfo.ExtractInternal := True;

    end
    else
    begin
      FileClose(Fhandle);
      FHandle := 0;
      Result := -3;
      ErrInfo.Format := 'CBF';
      ErrInfo.Games := 'Vietcong MP Demo';
    end;
  end
  else
    Result := -2;

end;

function ReadWarlordsBattlecryXCR(src: string): Integer;
var HDR: XCR_Header;
    ENT: XCR_Entry;
    NumE,x : integer;
    nam: string;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadWormsArmageddonDIR(src: string): Integer;
var HDR: WADIR_Header;
    ENT: WADIR_Entry;
    NumE: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function Parse_REZ(offset: integer; cdir: string): integer;
var ENT: REZEntry;
    tstr,nam,ext,pcdir: string;
    tint,res: integer;
    extbuf: array[1..4] of Char;
begin

  res := 0;

  if Offset < FileSeek(FHandle,0,2) then
  begin

    FileSeek(FHandle,Offset,0);
    FileRead(FHandle,ENT,16);

    case ENT.EntryType of
      1: begin
           pcdir := cdir;
           tstr := Strip0(Get0(FHandle));
           if ENT.Size > 0 then
             if Not(Offset_check(ENT.Offset)) then
             begin
               cdir := cdir + tstr + '\';
               Offset_add(ENT.Offset);
               res := Parse_REZ(ENT.Offset,cdir);
             end;
           res := res + Parse_REZ(Offset + 16 + Length(tstr) + 1,pcdir);
           Per := Per + 1;
           if Per > 100 then
             Per := 0;
           SetPercent(Per);
         end;
      0: begin
           FileRead(FHandle,tint,4);  // Numeric ID
           FileRead(Fhandle,extbuf,4);
           ext := extbuf;
           ext := RevStr(Strip0(ext));
           FileRead(FHandle,tint,4);  // Blank
           nam := Strip0(Get0(FHandle));
           if (length(nam) > 0) and (ENT.Offset > 0) and (ENT.Size > 0) and (extbuf[4] = #0) and (ENT.Offset < TotFSize) and (ENT.Offset + ENT.Size < TotFSize) and (ENT.Offset > 162) then
           begin
             if (ext = '') then
               tstr := cdir + nam
             else
               tstr := cdir + nam + '.' + ext;
//             ShowMessage('File'+#10+cdir+nam+'.'+ext+#10+inttoStr(ENT.Offset)+#10+inttostr(ENT.Size));
             FSE_Add(tstr,ENT.Offset,ENT.Size,0,0);
           end;
           Inc(Res);
           res := res + Parse_REZ(Offset + 30 + Length(nam),cdir);
         end;
    end;

    Parse_REZ := res;
  end
  else
    Parse_REZ := 0;

end;

function ReadLithTechREZ(src: string): Integer;
var HDR: REZHeader;
    NumE: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
      NumE := Parse_REZ(HDR.DirOffset,'');

      Offset_clear;
      //ShowMessage(IntTosTr(NumE));

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

function ReadDune3BAG(src: string): Integer;
var HDR: BAGHeader;
    ENT: BAGEntry;
    ENT16: BAGEntry16;
    NumE,x,hIDX : integer;
    ext: string;
    IsIDX: Boolean;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
      hIDX := FileOpen(ChangeFileExt(src,'.idx'),fmOpenRead);

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

function ReadDarkstoneMTF(src: string): integer;
var filnam: string;
    NumE, x: word;
    Offset, Size, Per, PerOld: integer;
    //filesize: Cardinal;
begin

  FHandle := FileOpen(src, fmOpenRead);

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

function ReadHubGOB(src: String): Integer;
var ID: array[0..3] of char;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadHubBAR(src: String): Integer;
var ID: array[0..3] of char;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

  Fhandle := FileOpen(src, fmOpenRead);

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
begin

  Fhandle := FileOpen(src, fmOpenRead);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,8);
    if ID = 'FILECHNK' then
      res := ReadGunlokDAT
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

function ReadHubRES(src: String): Integer;
var ID: array[0..3] of char;
    IDI: integer;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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
    ID21P4: array[0..20] of char;
    res,Test1,testpko,FSize: integer;
    Test2: Word;
    testpk: byte;
begin

  Fhandle := FileOpen(src, fmOpenRead);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,4);
    FSize := FileSeek(FHandle,0,2);
    FileSeek(FHandle,0,4);
    FileRead(FHandle,ID21P4,21);
    FileSeek(FHandle,0,0);
    FileRead(Fhandle,testpk,1);
    FileRead(Fhandle,testpko,4);
    FileSeek(FHandle,0,0);
    FileRead(FHandle,Test2,2);
    FileRead(FHandle,Test1,4);
    if ID = 'PACK' then
      res := ReadQuakePAK
    else if (ID[0] = #5) and (ID[1] = #0) and (ID[2] = #0) and (ID[3] = #0) then
      res := ReadTheMoviesPAK
    else if (ID[0] = #0) and (ID[1] = #0) and (ID[2] = #0) and (ID[3] = #0) then
      res := ReadZanzarahPAK
    else if (ID21P4 = 'MASSIVE PAKFILE V 4.0') then
      res := ReadSpellforcePAK
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
      ErrInfo.Games := 'Dune 2, Half-Life, Hooligans, Quake, Quake 2, Star Crusader, Trickstyle, Zanzarah, ..';
    end
    else
      ReadHubPAK := res;
  end
  else
    ReadHubPAK := -2;

end;

function ReadHubSTUFF(src: String): Integer;
var ID64: array[0..63] of char;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

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

function ReadHubPOD(src: String): Integer;
var ID: array[0..3] of char;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,4);
    if ID = 'POD3' then
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

function ReadHubWAD(src: String): Integer;
var ID: array[0..3] of char;
    res: integer;
begin

  Fhandle := FileOpen(src, fmOpenRead);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID,4);
    if ID = 'DWFB' then
      res := ReadDungeonKeeper2DWFB
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
      ErrInfo.Games := 'Dungeon Keeper 2, Quake';
    end
    else
      ReadHubWAD := res;
  end
  else
    ReadHubWAD := -2;

end;

{function ReadFormatSMART(fil: String): integer;
var ID4: array[0..3] of char;
    ID36: array[0..35] of char;
    ID127: array[0..126] of char;
    TestFile,x: integer;
begin

  Result := -1;

  FHandle := FileOpen(fil, fmOpenRead);

  if FHandle > 0 then
  begin
    FileRead(FHandle,ID127,127);
    FileSeek(FHandle,0,0);
    for x := 0 to 3 do
    begin
      ID4[x] := ID127[x];
      ID36[x] := ID127[x];
    end;
    for x := 4 to 35 do
      ID36[x] := ID127[x];

    if ID4 = ('GOB'+#10) then
      Result := true
    else if ID4 = ('GOB ') then
      Result := true
    else if ID4 = ('PACK') then
      Result := ReadQuakePAK;
    else if ID4 = ('LB83') then
      Result := true
    else if ID4 = ('PFF3') then
      Result := true
    else if ID4 = ('RFFL') then
      Result := true
    else if ID4 = ('CFFL') then
      Result := true
    else if ID4 = ('DWFB') then
      Result := true
    else if ID4 = ('VPVP') then
      Result := true
    else if ID4 = ('HRFi') then
      Result := true
    else if ID4 = ('HOG2') then
      Result := true
    else if ID4 = ('FAR!') then
      Result := true
    else if (ID4[0] = 'D') and (ID4[1] = 'H') and (ID4[2] = 'F') then
      Result := true
    else if ID36 = DRSID then
      Result := true
    else if (ID127 = REZID) or (ID127 = REZIDold) then
      Result := true
    else
      Result := False;
  end;


end;
}
//function ReadFormat(fil: ShortString; percent: TPercentCallback; Deeper: boolean): Integer; stdcall;
function ReadFormat(fil: ShortString; Deeper: boolean): Integer; stdcall;
var ext: string;
    ID4: array[0..3] of char;
    ID6: array[0..5] of char;
    ID8: array[0..7] of char;
    ID12: array[0..11] of char;
    ID12SLF: array[0..11] of char;
    ID21P4: array[0..20] of char;
    ID23: array[0..22] of char;
    ID28: array[0..27] of char;
    ID36: array[0..35] of char;
    ID127: array[0..126] of char;
    x: integer;
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

    FHandle := FileOpen(fil, fmOpenRead);

    if FHandle > 0 then
    begin
      FileRead(FHandle,ID127,127);
      FileSeek(FHandle,520,0);
      FileRead(FHandle,ID12SLF,12);
      for x := 0 to 3 do
      begin
        ID4[x] := ID127[x];
        ID8[x] := ID127[x];
        ID12[x] := ID127[x];
        ID23[x] := ID127[x];
        ID28[x] := ID127[x];
        ID36[x] := ID127[x];
      end;
      for x := 4 to 5 do
      begin
        ID6[x] := ID127[x];
        ID8[x] := ID127[x];
        ID12[x] := ID127[x];
        ID23[x] := ID127[x];
        ID28[x] := ID127[x];
        ID36[x] := ID127[x];
        ID21P4[x-4] := ID127[x];
      end;
      for x := 6 to 7 do
      begin
        ID8[x] := ID127[x];
        ID12[x] := ID127[x];
        ID23[x] := ID127[x];
        ID28[x] := ID127[x];
        ID36[x] := ID127[x];
        ID21P4[x-4] := ID127[x];
      end;
      for x := 8 to 11 do
      begin
        ID12[x] := ID127[x];
        ID23[x] := ID127[x];
        ID28[x] := ID127[x];
        ID36[x] := ID127[x];
        ID21P4[x-4] := ID127[x];
      end;
      for x := 12 to 22 do
      begin
        ID23[x] := ID127[x];
        ID28[x] := ID127[x];
        ID36[x] := ID127[x];
        ID21P4[x-4] := ID127[x];
      end;
      for x := 23 to 27 do
      begin
        ID28[x] := ID127[x];
        ID36[x] := ID127[x];
        if x < 27 then
          ID21P4[x-4] := ID127[x];
      end;
      for x := 28 to 35 do
        ID36[x] := ID127[x];

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
      // Civilization 4 .FPK file
      else if (ID8[4] = 'F') and (ID8[5] = 'P') and (ID8[6] = 'K') and (ID8[7] = '_') then
      begin
        FileClose(FHandle);
        Result := ReadCivilization4FPK(fil);
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
      // Fable: The Lost Chapter .BIG file
      else if (ID4 = 'LTAR') then
      begin
        FileClose(FHandle);
        Result := ReadFearARCH00(fil);
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
      else if ID4 = ('PACK') then
        Result := ReadQuakePAK
      else if ID4 = ('POD2') then
        Result := ReadNocturnePOD
      else if ID4 = ('POD3') then
        Result := ReadBloodRaynePOD
      else if ID8 = ('FILECHNK') then
        Result := ReadGunlokDAT
{      else if ID23 = NRMID then
      begin
        FileCLose(FHandle);
        Result := ReadHeathNRM(fil);
      end}
      else if ID4 = ('GABA') then
      begin
        FileClose(FHandle);
        Result := ReadDune3BAG(fil);
      end
      else if (ID4[0] = #60) and (ID4[1] = #226) and (ID4[2] = #156) and (ID4[3] = #1) then
      begin
        Result := ReadEvilIslandsRES;
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
      else if ID4 = ('ESPN') then
        Result := ReadAgeOfEmpires3BAR
      else if ID4 = ('VOLN') then
      begin
        FileClose(FHandle);
        Result := ReadEarthSiege2VOL(fil);
      end
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
 {     else if (ID4[0] = #72) and (ID4[1] = #52) and (ID4[2] = #82) and (ID4[3] = #5) then
      begin
        FileClose(FHandle);
        Result := ReadHeroesOfMightAndMagic4H4R(fil);
      end}
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
      else if (ID21P4 = 'MASSIVE PAKFILE V 4.0') then
        Result := ReadSpellforcePAK
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
      else if (ID4 = ('BIGF')) then
        Result := ReadCommandAndConquerGeneralsBIG
      else if (ID4 = ('DATA')) then
      begin
        FileClose(FHandle);
        Result := ReadCommandos3PCK(fil);
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
      // Hitman: Contracts - TEX
      else if (ID127[8] = #3) and (ID127[9] = #0) and (ID127[10] = #0) and (ID127[11] = #0)
          and (ID127[12] = #4) and (ID127[13] = #0) and (ID127[14] = #0) and (ID127[15] = #0) then
      begin
        FileClose(FHandle);
        Result := ReadHitmanContractsTEX(fil);
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
    else if ext = 'BUN' then
      ReadFormat := ReadMonkeyIsland3BUN(fil)
    else if ext = 'CBF' then
      ReadFormat := ReadVietcongCBF(fil)
    else if ext = 'CPR' then
      ReadFormat := ReadAscaronCPR(fil)
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
    else if ext = 'FAR' then
      ReadFormat := ReadTheSimsFAR(fil)
    else if ext = 'FFL' then
      ReadFormat := ReadAvPRFFL(fil)
    else if ext = 'FPK' then
      Result := ReadCivilization4FPK(fil)
    else if ext = 'GL' then
    begin
      FHandle := FileOpen(fil, fmOpenRead);
      ReadFormat := ReadStarCrusaderPAK(true);
    end
    else if ext = 'GRP' then
      ReadFormat := ReadDuke3DGRP(fil)
    else if ext = 'GOB' then
      ReadFormat := ReadHubGOB(fil)
//    else if ext = 'H4R' then
//      ReadFormat := ReadHeroesOfMightAndMagic4H4R(fil)
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
    else if ext = 'MTF' then
      ReadFormat := ReadDarkstoneMTF(fil)
{    else if ext = 'NRM' then
      ReadFormat := ReadHeathNRM(fil)}
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
    else if ext = 'TLK' then
      ReadFormat := ReadHubPAK(fil)
    else if ext = 'VOL' then
      ReadFormat := ReadEarthSiege2VOL(fil)
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

end;

type
  FormatEntry = record
    FileName: ShortString;
    Offset, Size: Int64;
    DataX, DataY: Integer;
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
    ID6: array[0..5] of char;
    ID8: array[0..7] of char;
    ID12: array[0..11] of char;
    ID12SLF: array[0..11] of char;
//    ID18: array[0..17] of char;
    ID21P4: array[0..20] of char;
    ID23: array[0..27] of char;
    ID28: array[0..27] of char;
    ID36: array[0..35] of char;
    ID127: array[0..126] of char;
    TestFile,x: integer;
begin

  Result := False;

  TestFile := FileOpen(fil, fmOpenRead);

  if TestFile > 0 then
  begin
    FileRead(TestFile,ID127,127);
    FileSeek(TestFile,520,0);
    FileRead(TestFile,ID12SLF,12);
    for x := 0 to 3 do
    begin
      ID4[x] := ID127[x];
      ID8[x] := ID127[x];
      ID12[x] := ID127[x];
      ID23[x] := ID127[x];
      ID28[x] := ID127[x];
      ID36[x] := ID127[x];
    end;
    for x := 4 to 5 do
    begin
      ID6[x] := ID127[x];
      ID8[x] := ID127[x];
      ID12[x] := ID127[x];
      ID23[x] := ID127[x];
      ID28[x] := ID127[x];
      ID36[x] := ID127[x];
      ID21P4[x-4] := ID127[x];
    end;
    for x := 6 to 7 do
    begin
      ID8[x] := ID127[x];
      ID12[x] := ID127[x];
      ID23[x] := ID127[x];
      ID28[x] := ID127[x];
      ID36[x] := ID127[x];
      ID21P4[x-4] := ID127[x];
    end;
    for x := 8 to 11 do
    begin
      ID12[x] := ID127[x];
      ID23[x] := ID127[x];
      ID28[x] := ID127[x];
      ID36[x] := ID127[x];
      ID21P4[x-4] := ID127[x];
    end;
    for x := 12 to 22 do
    begin
      ID23[x] := ID127[x];
      ID28[x] := ID127[x];
      ID36[x] := ID127[x];
      if (x < 22) then
        ID21P4[x-4] := ID127[x];
    end;
    for x := 23 to 27 do
    begin
      ID28[x] := ID127[x];
      ID36[x] := ID127[x];
    end;
    for x := 28 to 35 do
      ID36[x] := ID127[x];
    FileClose(TestFile);

    if ID4 = ('GOB'+#10) then
      Result := true
    // Myst IV: Revelation .M4B file
    else if (ID23[0] = #11) and (ID23[1] = #0) and (ID23[2] = #0) and (ID23[3] = #0)
        and (ID23[4] = 'U') and (ID23[5] = 'B') and (ID23[6] = 'I') and (ID23[7] = '_')
        and (ID23[8] = 'B') and (ID23[9] = 'F') and (ID23[10] = '_') and (ID23[11] = 'S')
        and (ID23[12] = 'I') and (ID23[13] = 'G') and (ID23[14] = #0) then
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
    // Civilization 4 .FPK file
    else if (ID8[4] = 'F') and (ID8[5] = 'P') and (ID8[6] = 'K') and (ID8[7] = '_') then
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
    else if ID12 = GRPID then
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
//    else if ID18 = NRMID then
//      Result := true
    else if ID8 = 'LiOnHeAd' then
      Result := true
    else if ID8 = 'FILECHNK' then
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
// H4R
//    else if (ID4[0] = #72) and (ID4[1] = #52) and (ID4[2] = #82) and (ID4[3] = #5) then
//      Result := true
    else if ID4 = ('HAPI') then
      Result := true
    else if (ID21P4 = 'MASSIVE PAKFILE V 4.0') then
      Result := true
    else if ID4 = ('PACK') then
      Result := true
    else if ID4 = ('POD3') then
      Result := true
    else if ID4 = ('POD2') then
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
    else if ID4 = ('VPVP') then
      Result := true
    else if ID4 = ('HRFi') then
      Result := true
    else if ID4 = ('HOG2') then
      Result := true
    else if ID4 = ('FAR!') then
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
    else if (ID4[0] = 'D') and (ID4[1] = 'H') and (ID4[2] = 'F') then
      Result := true
    else if ID36 = DRSID then
      Result := true
//    else if (ID4 = ('BIGF')) and (ID8[4] = #0) and (ID8[5] = 'Z') and (ID8[6] = 'B') and (ID8[7] = 'L') then
//      Result := true
    else if (ID4 = ('BIGF')) then
      Result := true
    else if (ID4 = ('DATA')) then
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
    IsFormat := IsFormatSMART(fil) or (ext = 'POD') or (ext = 'PAK') or (ext = 'TLK') or (ext = 'SDT') or (ext = 'RFH') or (ext = 'MTF') or (ext = 'BKF') or (ext = 'DAT') or (ext = 'PBO') or (ext = 'AWF') or (ext = 'SND') or (ext = 'ART') or (ext = 'SNI') or (ext = 'DIR') or (ext = 'IMG') or (ext = 'BAR') or (ext = 'BAG') or (ext = 'SQH') or (ext = 'GL') or (ext = 'RFA') or (ext = 'ADF') or (ext = 'RES') or (ext = 'XRS') or (ext = 'STUFF') or (ext = 'BIN')
  else
    if ext = 'PAK' then
      IsFormat := True
    else if ext = '007' then
      IsFormat := True
    else if ext = 'ADF' then
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
    else if ext = 'BOX' then
      IsFormat := True
    else if ext = 'BUN' then
      IsFormat := True
    else if ext = 'CBF' then
      IsFormat := True
    else if ext = 'CCX' then
      IsFormat := True
    else if ext = 'CPR' then
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
//    else if ext = 'H4R' then
//      IsFormat := True
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
    else if ext = 'MN3' then
      IsFormat := True
    else if ext = 'MTF' then
      IsFormat := True
//    else if ext = 'NRM' then
//      IsFormat := True
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
    else if ext = 'TLK' then
      IsFormat := True
    else if ext = 'UFO' then
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
    else if ext = 'XRS' then
      IsFormat := True
    else if ext = 'ZFS' then
      IsFormat := True
    else
      IsFormat := False;

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
      InputStream.Seek(0, soFromBeginning);

      DStream := TDecompressionStream.Create(InputStream);
      try
        FinalSize := OutputStream.CopyFrom(DStream,OSize);
      finally
        DStream.Free;
      end

    finally
      InputStream.Free;
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
      InputStream.Seek(0, soFromBeginning);

      DStream := TDecompressionStream.Create(InputStream);
      try
        FinalSize := OutputStream.CopyFrom(DStream,OSize);
      finally
        DStream.Free;
      end

    finally
      InputStream.Free;
    end
  finally
    FreeMem(Buf);
  end;

  Result := FinalSize = OSize;

End;

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
              DStream.Free;
            end;
//            GetMem(DecompBuffer,HDR.DecompressedSize);
//            OutputStream.SaveToFile('h:\testhpi-zlib-'+inttostr(x)+'-decomp.bin');
//            OutputStream.Seek(0,0);
//            OutputStream.Read(DecompBuffer^,HDR.DecompressedSize);
//            FileWrite(fil,DecompBuffer^,HDR.DecompressedSize);
//            FreeMem(DecompBuffer);
          finally
            OutputStream.Free;
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

procedure AboutBox; stdcall;
begin

  MessageBoxA(AHandle, PChar('Main Driver plugin v'+getVersion(DRIVER_VERSION)+#10+
                          '(c)Copyright 2002-2006 Alexandre Devilliers'+#10+#10+
                          'Designed for Dragon UnPACKer v'+getVersion(DUP_VERSION)+#10+
                          'Compiled the '+DateToStr(CompileTime)+' at '+TimeToStr(CompileTime)+#10+
                          'Based on CVS rev '+getCVSRevision(CVS_REVISION)+' ('+getCVSDate(CVS_DATE)+')'+#10+#10+
                          'Limitations:'+#10+
                          'Breakneck .SYN files are not decrypted (useless support?)'+#10+
                          'Commandos 3 .PCK decryption is experimental.'+#10+
                          'Daikatana .PAK files: No extraction is possible.'+#10+
                          'Empires: Dawn of the Modern World SSA support is partial.'+#10+
                          'Novalogic .PFF files: Only PFF3 can be loaded.'+#10+#10+
                          'Credits:'+#10+
                          'realMyst 3D DNI support code based on source of: dniExtract by Ken Taylor'+#10+
                          'Darkstone MTF decompression code based on infos by: Guy Ratajczak'+#10+
                          'GTA3 IMG/DIR support based on specs and infos by: Dan Strandberg of Game-Editing.net'+#10+
                          'Spellforce PAK and Eve Online STUFF support based on infos by: DaReverse'+#10+
                          'Painkiller PAK support partially based on infos by: MrMouse'
                          )
                        , 'About Main Driver plugin...', MB_OK);

end;

procedure BinCopy(src : integer; dst : integer; soff : Int64; ssize : Int64; bufsize : Integer);
var
  //sFileLength: Integer;
  Buffer: PByteArray;
  i,numbuf, restbuf: Integer;
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
    FileWrite(dst, Buffer^, bufsize);
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

  SetPercent(100);

  FileRead(src, Buffer^, restbuf);
  FileWrite(dst, Buffer^, restbuf);

finally
  FreeMem(Buffer);
end;

end;

procedure BinCopyToStream(src : integer; dst: TStream; soff : Int64; ssize : Int64; bufsize : Integer; silent: boolean);
var
  //sFileLength: Integer;
  Buffer: PChar;
  i,numbuf, restbuf: Integer;
  per, oldper: word;
  real1, real2: real;
begin

  //sFileLength := FileSeek(src,0,2);
  FileSeek(src,soff,0);
  numbuf := ssize div bufsize;
  restbuf := ssize mod bufsize;

  GetMem(Buffer,bufsize);

  try

    oldper := 0;

    for i := 1 to numbuf do
    begin
      FileRead(src, Buffer^, bufsize);
      dst.WriteBuffer(Buffer^, bufsize);
      if not(silent) then
      begin
        real1 := i;
        real2 := numbuf;
        real1 := (real1 / real2)*100;
        per := Round(real1);
        if per >= oldper + 10 then
        begin
          SetPercent(per);
          oldper := per;
        end;
      end;
    end;

    if not(silent) then
      SetPercent(100);

    FileRead(src, Buffer^, restbuf);
    dst.WriteBuffer(Buffer^, restbuf);

  finally
    FreeMem(Buffer);
  end;

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

function ExtractFileToStream(outputstream: TStream; entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: boolean): boolean; stdcall;
var ENT: MTFCompress;
    SSA: SSACompress;
    TMH: TMPAK_CompHeader;
    tbyt,key: byte;
    ID: array[0..2] of char;
begin

  FileSeek(FHandle,Offset,0);

//  ShowMessage(DrvInfo.ID+' '+Inttostr(DataX)+' '+Inttostr(DataY)+' '+Inttostr(Size));

  if DrvInfo.ID = 'RFH/RFD' then
  begin
    if (DataX = 2) then
    begin
      DecompressRFDToStream(outputstream, DataY, Size);
    end
    else
    begin
      BinCopyToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent);
    end;
  end
  else if DrvInfo.ID = '007' then
  begin
    if (DataX = 1) then
    begin
      DecompressZlibToStream(outputstream, DataY, Size);
    end
    else
    begin
      BinCopyToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent);
    end;
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
        BinCopyToStream(FHandle,outputstream,offset+16,Size,BUFFER_SIZE,silent)
      // Else we decompress the zlib data
      else
        DecompressZlibToStream(outputstream, TMH.CmpSize, Size);

    end
    // If something is not as expected we just copy 1:1
    else
    begin
      BinCopyToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent);
    end;

  end
  else if DrvInfo.ID = 'ADF' then
  begin
    DecryptADFToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent);
  end
  else if DrvInfo.ID = 'CBF' then
  begin
    if (DataY = 1) then
    begin
//      FileSeek(FHandle,Offset+12,0);
//      DecompressZlib(fil, DataX-12, Size);
      BinCopyToStream(FHandle,outputstream,offset,DataX,BUFFER_SIZE,silent);
    end
    else
    begin
      BinCopyToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent);
    end;
  end
//  else if DrvInfo.ID = 'H4R' then
//  begin
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
//  end
  else if DrvInfo.ID = 'MTF' then
  begin
    FileRead(FHandle,ENT,12);
    if (ENT.ID2 = 190) and ((ENT.ID1 = 174) or (ENT.ID1 = 175)) then
    begin
      DecompressMTFToStream(outputstream, Offset+12,Size);
    end
    else
    begin
      BinCopyToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent);
    end;
  end
  else if DrvInfo.ID = 'HPI' then
  begin
    if (DataX = 2) or (DataX = 1) then
    begin
      DecompressHPIToStream(outputstream,Offset,Size,DataX,silent);
    end
    else
    begin
      BinCopyToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent);
    end;
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
    begin
      BinCopyToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent);
    end;
  end
  else if DrvInfo.ID = 'RFA' then
  begin
    if (DataX = 0) then
    begin
      BinCopyToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent);
    end
    else if (DataX = 1) then
    begin
      DecompressRFAToStream(outputstream,Offset,Size,silent);
    end;
  end
  else if DrvInfo.ID = 'SSA' then
  begin
    FileSeek(FHandle,offset,0);
    FileRead(FHandle,SSA,SizeOf(SSA));
    if SSA.ID = 'PK01' then
    begin
      DecompressZlibToStream(outputstream, Size, SSA.DecompSize);
    end
    else
    begin
      BinCopyToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent);
    end;
  end
  else if DrvInfo.ID = 'PKPAK' then
  begin
    if DataX <> Size then
    begin
      DecompressZlibToStream(outputstream, DataX, Size);
    end
    else
    begin
      BinCopyToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent);
    end;
  end
  else
  begin
    BinCopyToStream(FHandle,outputstream,offset,Size,BUFFER_SIZE,silent);
  end;

  result := true;

end;

function ExtractFile(outputfile: ShortString; entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer; Silent: boolean): boolean; stdcall;
var fil: Integer;
    outStm: THandleStream;
begin

  fil := FileCreate(outputfile,fmOpenRead or fmShareExclusive);
  outStm := THandleStream.Create(fil);
  result := ExtractFileToStream(outStm,entrynam,offset,size,datax,datay,silent);
  outStm.Free;
  FileClose(fil);

end;

procedure InitPlugin(per: TPercentCallback; lngid: TLanguageCallback; DUP5Path: ShortString; AppHandle: THandle; AppOwner: TComponent); stdcall;
begin

  SetPercent := per;
  DLNGStr := lngid;
  CurPath := DUP5Path;
  AHandle := AppHandle;
  AOwner := AppOwner;

end;

exports
  DUDIVersion,
  ExtractFile,
  ExtractFileToStream,
  ReadFormat,
  CloseFormat,
  GetEntry,
  GetDriverInfo,
  GetNumVersion,
  GetCurrentDriverInfo,
  GetErrorInfo,
  AboutBox,
  InitPlugin,
  IsFormat;

begin
end.
