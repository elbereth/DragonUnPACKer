unit HyperRipper;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is HyperRipper.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

{ * Version History:
  * 10000 Experimental HyperRipper plugin for DUP 5.0.0 Beta 2
  * 50042 Fixed a GUI glitch.
  *       Prepared for DUP v5.0.0 release.
  * 50140 Added Ogg stream support
  * 50141 Fixed Ogg Stream support
  * 50142 Fixed another bug in Ogg Stream support
  * 50143 Now using DUHI v2
  *       Option Panel is now child of main application (you can alt+tab without
  *       fear. :)
  * 50144 Fixed bug #1024855 (introduced by JVCL 2.10 -> 3.00 migration)
  *       Tweaked the posBuf function to be able to start checking from an specified offset of the buffer (should speed up RIFF/JFIF/GIF search)
  * 50240 Now using DUHI v3
  *       Added support for very big files
  *       Fixed bug #1118661 (Very big files failure)
  * 50340 Fixed bug #1428079 (missing bytes EOF on WAV files)
  * 51011 Working on bug #1729410 (extraction of mp3 subfiles creates incomplete files)
  *       Now using DUHI v4, need HyperRipper v5.5 (Dragon UnPACKer v5.3+)
  *       Added support for DDS file format (Feature Request #1639688)
  * 51012 Fixed MPEG Audio search (using posbuf again instead of BMFind)
  * 51013 Fixed possible error in BMFind function
  *       Added file size check to avoid false positives
  * 51021 Added TGA (RGB) support (patch from Psych0phobiA)
  * 51022 Fixed bug on missing 4 bytes at the end of AVI files
  *       Fixed BMFind function (was missing stuff)
  *       Improved speed & reliability by using direct searches instead of calling BMFind again:
  *         RIFF/WAVE RIFF/AVI PNG and JPEG/JFIF
  * 51040 Removed unstable status for Dragon UnPACKer v5.4.0 release
  * 51140 Removed JVCL use, changed to Delphi VCL (TSpinEdit)
  * 56011 Not a plugin anymore -> Merged with HyperRipper v55044
  * 56012 Fixed BMFind mistakes (many formats were unable to be found)
  *       Speed-up (on par or slightly faster than plugin version)
  * 56013 Fixed BigToLittle2
  *       Added support for Exif JPEG files (APP1 marker instead of APP0)
  * 56040 Removed unstable status for Dragon UnPACKer v5.6.0 release
  * 56041 Fixed the BIK sanity check
  * 56042 Removed use of TBufferedFS
  *       THandleStream is freed after use (no more memory leak)
  * 57040 Added AAC (ADTS) and MPEG-4 TS support
  * 57042 Added some more feedback when searching
  * 57043 Added WEBM/MKV support
  *
}

interface

uses
  Windows, Messages, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, lib_language, Registry, Math, spec_DDS,
  ExtCtrls, lib_utils, classFSE, spec_HRF, DateUtils, translation, U_IntList,
  StrUtils, MpegAudioOptions, dwTaskbarComponents, dwProgressBar, ImgList, SysUtils,
  Spec_DUDI, lib_binutils;

const MP_FRAMES_FLAG = 1;
      MP_BYTES_FLAG = 2;
      MP_TOC_FLAG = 4;
      MP_VBR_SCALE_FLAG = 8;

      HR_VERSION = 57043;	// HyperRipper version

type FormatsListElem = record
       GenType: Integer;
       Format: ShortString;
       Desc: ShortString;
       ID: Integer;
       IsConfig: Boolean;
       FalsePositives: Boolean;
     end;
     PFormatListElem = ^FormatsListElem;
     SearchFormatsList = record
       NumFormats :  Byte;
       FormatsList : array[1..255] of FormatsListElem;
     end;
     ExtSearchFormatsList = record
       NumFormats : Integer;
       FormatsList : array of FormatsListElem;
     end;
     FoundInfo64 = record
       Offset: int64;
       Size: int64;
       Ext: ShortString;
       GenType: integer;
     end;
     VersionInfo = record
       Name: ShortString;
       Author: ShortString;
       Comment: ShortString;
       Version: Integer;
     end;
     MPEGOptions = record
       MP10_1: boolean;
       MP20_1: boolean;
       MP25_1: boolean;
       MP10_2: boolean;
       MP20_2: boolean;
       MP25_2: boolean;
       MP10_3: boolean;
       MP20_3: boolean;
       MP25_3: boolean;
       LimitFramesMin: boolean;
       FramesMin: longword;
       LimitFramesMax: boolean;
       FramesMax: longword;
       LimitSizeMin: boolean;
       SizeMin: integer;
       LimitSizeMax: boolean;
       SizeMax: integer;
       XingVBR: boolean;
       ID3Tag: boolean;
     end;

     VOCHeader = packed record
       ID: array[0..18] of char;
       EOF: byte;
       BlockOffset: Word;
       Version: Word;
       CompVer: Word;
     end;

     MPTSAtomHeader = packed record
       size: longword;
       atomtype: array[0..3] of char;
     end;

     OGGHeader = packed record
       ID: array[0..3] of char;
       Revision: byte;            // Should be 0
       BitFlags: byte;            // 0x01: unset = fresh packet
                                  //         set = continued packet
                                  // 0x02: unset = not first page of logical bitstream
                                  //         set = first page of logical bitstream (bos)
                                  // 0x04: unset = not last page of logical bitstream
                                  //         set = last page of logical bitstream (eos)
       AbsoluteGranulePos: int64;
       StreamSerialNumber: integer;
       PageSeqNum: integer;
       PageChecksum: integer;
       NumPageSegments: byte;
     end;
     // array[1..NumPageSegments] of byte = Lacing values (sum = total page size)

     MIDIChunk = packed record
       ID: array[0..3] of char;
       Size: array[1..4] of byte;
     end;
     MIDIHeader = packed record
       FormatType: array[1..2] of byte;
       NumTracks: array[1..2] of byte;
       TimeDivision: array[1..2] of byte;
     end;

     F669Header = packed record
       ID: array[0..1] of char;
       SongMessage: array[0..107] of char;
       NOS: byte;
       NOP: byte;
       LoopOrderNumber: byte;
       Order: array[1..128] of byte;
       Tempo: array[1..128] of byte;
       BreakLocation: array[1..128] of byte;
     end;
     F669Sample = packed record
       filename: array[0..12] of char;
       length: longword;
       offsetbeginningloop: longword;
       offsetendloop: longword;
     end;

     XMHeader = packed record
       ID: array[0..16] of char;
       ModuleName: array[0..19] of char;
       EOF: byte;
       TrackerName: array[0..19] of char;
       Version: word;
       HeaderSize: longword;
       SongLength: word;
       RestartPos: word;
       NumChans: word;
       NumPat: word;
       NumIns: word;
       Flags: word;
       DefaultTempo: word;
       DefaultBPM: word;
       PatternOrder: array[1..256] of byte;
     end;
     XMPattern = packed record
       HeaderLength: longword;
       PackingType: byte;
       NumRows: word;
       Size: word;
     end;
     XMInstrumentHeader = packed record
       Size: longword;
       Name: array[0..21] of char;
       IType: byte;
       NumSamples: word;
     end;
     XMInstrument = packed record
       SampleHeaderSize: longword;
       SampleNumber: array[1..96] of byte;
       VolumeEnv: array[1..48] of byte;
       PanningEnv: array[1..48] of byte;
       NumVolPoints: byte;
       NumPanPoints: Byte;
       VolSustainPoint: byte;
       VolLoopStart: byte;
       VolLoopEnd: byte;
       PanSystainPoint: byte;
       PanLoopStart: byte;
       PanLoopEnd: byte;
       VolType: byte;
       PanType: byte;
       VibratoType: byte;
       VibratoSweep: byte;
       VibratoDepth: byte;
       VibratoRate: byte;
       VolFadeOut: word;
       Reserved: word;
     end;
     XMSampleHeader = packed record
       Length: longword;
       LoopStart: longword;
       LoopEnd: longword;
       Volume: byte;
       FineTune: byte;
       SType: byte;
       Panning: byte;
       RelativeNote: byte;
       Reserved: byte;
       SampleName: array[0..21] of char;
     end;

     BMPHeader = packed record
       ID: array[0..1] of char;   // BM
       Size: longword;
       Reserved1: word;
       Reserved2: word;
       Offset: longword;
       ID2: longword;
       Width: longword;
       height: longword;
       Planes: word;
       Bpp: word;
       Compression: longword;
       SizeImage: longword;
       XPPM: longword;
       YPPM: longword;
       ColorsUsed: longword;
       ColorsImportant: longword;
     end;

     EnhancedMetaHeader = packed record
       RecordType: longword;       // Record type
       RecordSize: longword;       // Size of the record in bytes
       BoundsLeft: longword;       // Left inclusive bounds
       BoundsRight: longword;      // inclusive bounds
       BoundsTop: longword;        // Top inclusive bounds
       BoundsBottom: longword;     // Bottom inclusive bounds
       FrameLeft: longword;        // Left side of inclusive picture frame
       FrameRight: longword;       // Right side of inclusive picture frame
       FrameTop: longword;         // Top side of inclusive picture frame
       FrameBottom: longword;      // Bottom side of inclusive picture frame
       Signature: array[0..3] of char;
       Version: longword;          // Version of the metafile
       Size: longword;             // Size of the metafile in bytes
       NumOfRecords: longword;     // Number of records in the metafile
       NumOfHandles: word;         // Number of handles in the handle table
       Reserved: word;             // Not used (always 0)
       SizeOfDescrip: longword;    // Size of description string in WORDs
       OffsOfDescrip: longword;    // Offset of description string in metafile
       NumPalEntries: longword;    // Number of color palette entries
       WidthDevPixels: longword;   // Width of reference device in pixels
       HeightDevPixels: longword;  // Height of reference device in pixels
       WidthDevMM: longword;       // Width of reference device in millimeters
       HeightDevMM: longword;      // Height of reference device in millimeters
     end;

     WindowsMetaHeader = packed record
       FileType: word;      // Type of metafile (0=memory, 1=disk) */
       HeaderSize: word;    // Size of header in WORDS (always 9)
       Version: word;       // Version of Microsoft Windows used
       FileSize: longword;  // Total size of the metafile in WORDs
       NumOfObjects: word;  // Number of objects in the file
       MaxRecordSize: longword;    // The size of largest record in WORDs
       NumOfParams: word;   // Not Used (always 0)
     end;
     PlaceableMetaHeader = packed record
       Key: longword;       // Magic number (always 9AC6CDD7h)
       Handle: word;        // Metafile HANDLE number (always 0)
       Left: word;          // Left coordinate in metafile units
       Top: word;           // Top coordinate in metafile units
       Right: word;         // Right coordinate in metafile units
       Bottom: word;        // Bottom coordinate in metafile units
       Inch: word;          // Number of metafile units per inch
       Reserved: longword;  // Reserved (always 0)
       Checksum: word;      // Checksum value for previous 10 WORDs
     end;

     GIFHeader = packed record
       ID: array[0..2] of char;      // "GIF"
       Version: array[0..2] of char; // "87a" "89a"
       Width: word;
       height: word;
       Flags: byte;        // 0 000 0 000
                           // M cr  0 Pixel
                           // M = 0 - No global color map
                           //     1 - Global color map follows
                           // cr+1=# bits of color resolution
                           // pixel+1=# bpp in image
       Background: byte;   // Background color number
       Padding: byte;      // 00000000
     end;
     GIFImageDescriptor = packed record
       Left: word;          // Start of image from left of screen
       Top: word;           // Start of image from top of screen
       Width: word;
       height: word;
       Flags: byte;         // 0 0 000 000
                            // M I 000 Pixel
                            // M = 0 - No local color map, ignore 'pixel'
                            //     1 - Local color map, use 'pixel'
                            // I = 0 - Sequential order
                            //     1 - Interlaced
                            // Pixel+1 = # Bpp of local image
     end;
{ Local Color Map ( 2^Bpp * 3 Entries )

  Code Size as Byte
  BlockByteCount as Byte                  \ Repeat n times
  DataBytes as String * BlockByteCount    /
  End when BlockByteCount = 0                                      }

     JPEG_APP0 = packed record
       Length: array[0..1] of byte;
       Identifier: array[0..3] of char;  // JFIF
       NulByte: byte;                    // chr(0)
       Version: word;                    // 1.00 / 1.01 / 1.02
       Units: byte;                      // 0:  no units, X and Y specify the pixel aspect ratio
                                         // 1:  X and Y are dots per inch
                                         // 2:  X and Y are dots per cm
       Xdensity: word;                   // H Pixel density
       Ydensity: word;                   // V Pixel density
       Xthumbnail: byte;                 // Thumbnail H Pixel count
       Ythumbnail: byte;                 // Thumbnail V Pixel count
     end;
     JPEGLength = array[0..1] of byte;


     FLIC_Header = packed record
       Size: longword;
       Magic: word;
       Frames: word;
       Width: word;
       Height: word;
       Depth: word;
       Flags: longword;
       Speed: word;
       Next: longword;
       Frit: longword;
       Expand: array[1..100] of byte;
     end;

     S3MHeader = packed record
       songName: array[1..28] of char;
       EOFM: byte;                 // &H1A
       Typ: byte;                  // 16
       Unknown1: word;
       OrdNum: word;
       InsNum: word;
       PatNum: word;
       Flags: word;
       Cwtv: word;
       FFV: word;
       ID: array[0..3] of char;     // "SCRM"
       GV: byte;
       ISS: byte;
       IT: byte;
       MV: byte;
       Unknown2: array[0..9] of byte;
       Special: word;
       ChanSettings: array[1..32] of byte;
     end;
     S3MSample = packed record
       T: byte;
       Filename: array[0..11] of char;
       Memseg: array[1..3] of byte;
       Length: longword;
       LoopBeg: longword;
       LoopEnd: longword;
       Vol: byte;
       xPF: array[1..3] of byte;
       C2Spd: longword;
       Reserved: longword;
       IntGP: word;
       Int512: word;
       IntLast: longword;
       SampleName: array[0..27] of char;
       ID: array[0..3] of char;       // "SCRS"
     end;

     ITHeader = packed record
       ID: array[0..3] of char;       // "IMPM"
       songName: array[0..25] of char;
       PHiligt: word;
       OrdNum: word;
       InsNum: word;
       SmpNum: word;
       PatNum: word;
       Cwtv: word;
       Cmwt: word;
       Flags: word;
       Special: word;
       GV: byte;
       MV: byte;
       ISS: byte;
       IT: byte;
       Sep: byte;
       PWD: byte;
       MsgLgth: word;
       MsgOffset: word;
       Reserved: longword;
       ChnlPan: array[1..64] of byte;
       ChnlVol: array[1..64] of byte;
     end;
     ITSample = packed record
       ID: array[0..3] of char;
       Filename: array[0..12] of char;
       GvL: byte;
       Flg: byte;
       Vol: byte;
       SampleName: array[0..25] of char;
       Cvt: byte;
       DfP: byte;
       Length: longword;
       LoopBegin: longword;
       LoopEnd: longword;
       C5Speed: longword;
       SusLoopBegin: longword;
       SusLoopEnd: longword;
       SamplePointer: longword;
       ViS: byte;
       ViD: byte;
       ViR: byte;
       ViT: byte;
     end;
     TGAHeader = packed record
       IDSize: byte;
       CMapType: byte;
       ImageType: byte;
       CMapStart: word;
       CMapSize: word;
       CMapBits: byte;
       XOrigin: word;
       YOrigin: word;
       Width: word;
       Height: word;
       Bits: byte;
       Descriptor: byte;
     end;
     TGAFooter = packed record
       ExtAreaOffset: integer;
       DevDirOffset: integer;
       Signature: array[0..15] of char;
       Dot: char;
       NullTerminator: byte;
     end;

     SearchItem = record
       DriverNum : integer;
       ID : integer;
     end;
     SearchList = record
       num: integer;
       items: array[1..1000] of SearchItem;
     end;
     PFoundItem = ^FoundItem;
     FoundItem = record
       Offset: int64;
       Index: integer;
     end;

  THyperRipperFormat = class(TObject)
  private
//    function BigToLittle2(src: array of byte): word;
//    function BigToLittle4(src: array of byte): integer;
//    function BMFind(szSubStr: PChar; buf: PByteArray; iBufSize: integer; iOffset: integer = 0): integer;
//    function posBuf(search: byte; buffer: PByteArray; bufSize: integer; startpos: integer = 0): integer;
    function getMPEGOptions(): MPEGOptions;
  protected
  public
    function GetFormatsList(): ExtSearchFormatsList;
    procedure showConfigBox(formatid: integer);
//    function findInBuffer(formatid: Integer; buffer: PByteArray; bufSize: integer): TIntList;
//    function verifyInStream(formatid: integer; inStm: TStream; offset: int64): FoundInfo64;
  end;
  TfrmHyperRipper = class(TForm)
    OpenDialog: TOpenDialog;
    PageControl: TPageControl;
    tabSearch: TTabSheet;
    tabFormats: TTabSheet;
    tabAdvanced: TTabSheet;
    lstResults: TListBox;
    cmdOk: TButton;
    cmdSearch: TButton;
    txtSource: TEdit;
    Progress: TdwProgressBar;
    cmdBrowse: TButton;
    Panel1: TPanel;
    lblHexDump: TLabel;
    strBufferSep: TLabel;
    lblBufferLength: TLabel;
    strSpeed: TLabel;
    lblSpeed: TLabel;
    strSource: TLabel;
    panHRF: TPanel;
    chkHRF: TCheckBox;
    txtHRF: TEdit;
    cmdHRFBrowse: TButton;
    lstFormats: TListView;
    lblFound: TLabel;
    strFound: TLabel;
    strSettings: TLabel;
    lblRollback: TLabel;
    cmdCancel: TButton;
    grpFormatting: TGroupBox;
    tabHRF: TTabSheet;
    GroupBox4: TGroupBox;
    grpHRFVersion: TGroupBox;
    radiov30: TRadioButton;
    imgBlood: TImage;
    tabAbout: TTabSheet;
    imgHR: TImage;
    Bevel1: TBevel;
    strHRVersion: TLabel;
    Panel3: TPanel;
    strNumFormats: TLabel;
    lblNumFormats: TLabel;
    chkHRFInfo: TCheckBox;
    Panel4: TPanel;
    strHRFTitle: TLabel;
    txtHRFTitle: TEdit;
    txtHRFAuthor: TEdit;
    strHRFAuthor: TLabel;
    strHRFURL: TLabel;
    txtHRFURL: TEdit;
    grpHRFOptions: TGroupBox;
    radiov10: TRadioButton;
    radiov20: TRadioButton;
    chkHRF3_NoPRGID: TCheckBox;
    chkHRF3_NoPRGVer: TCheckBox;
    SaveDialog: TSaveDialog;
    chkMakeDirs: TCheckBox;
    grpNaming: TGroupBox;
    chkNamingAuto: TRadioButton;
    chkNamingCustom: TRadioButton;
    txtNaming: TEdit;
    lblAboutInfo: TLabel;
    lblAboutBeware: TLabel;
    cmdConfig: TButton;
    cmdAll: TButton;
    cmdImage: TButton;
    cmdVideo: TButton;
    cmdAudio: TButton;
    lblNamingLegF: TLabel;
    lblNamingLegX: TLabel;
    lblNamingLegO: TLabel;
    lblNamingLegN: TLabel;
    lblNamingLegH: TLabel;
    panNamingExemple: TPanel;
    Panel2: TPanel;
    strMaxLength: TLabel;
    strCompatible: TLabel;
    lblMaxLength: TLabel;
    lblCompatible: TLabel;
    lblNamingLegL: TLabel;
    lblNamingLegS: TLabel;
    panNaming: TPanel;
    txtExample: TEdit;
    strScanned: TLabel;
    lblScanned: TLabel;
    lblHRVersion: TLabel;
    lblHRVersionShadow: TLabel;
    imgState: TImageList;
    Image1: TImage;
    chkExcludeFalsePositive: TCheckBox;
    grpAdv: TGroupBox;
    chkAutoClose: TCheckBox;
    chkForceBufferSize: TCheckBox;
    lblBufferSize: TLabel;
    butBufferSizeCheck: TButton;
    chkAutoStart: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    strLeftToScan: TLabel;
    lblLeftToScan: TLabel;
    strEstimated: TLabel;
    lblEstimated: TLabel;
    strElapsed: TLabel;
    lblElapsed: TLabel;
    procedure cmdOkClick(Sender: TObject);
    procedure cmdSearchClick(Sender: TObject);
    procedure cmdBrowseClick(Sender: TObject);
    procedure txtSourceChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure addResult(st: String);
    procedure lastResult(st: String);
    procedure saveSettings();
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure chkRollback0Click(Sender: TObject);
    procedure chkRollback1Click(Sender: TObject);
    procedure chkRollback2Click(Sender: TObject);
    procedure chkRollback3Click(Sender: TObject);
    procedure RunSearch(filename: String; slist: SearchList);
    procedure cmdCancelClick(Sender: TObject);
    procedure chkHRFClick(Sender: TObject);
    procedure chkHRFInfoClick(Sender: TObject);
    procedure txtHRFTitleChange(Sender: TObject);
    procedure txtHRFAuthorChange(Sender: TObject);
    procedure txtHRFURLChange(Sender: TObject);
    procedure txtHRFChange(Sender: TObject);
    procedure cmdHRFBrowseClick(Sender: TObject);
    procedure chkHRF3_NoPRGIDClick(Sender: TObject);
    procedure chkHRF3_NoPRGVerClick(Sender: TObject);
    procedure chkMakeDirsClick(Sender: TObject);
    procedure chkNamingCustomClick(Sender: TObject);
    procedure chkNamingAutoClick(Sender: TObject);
    procedure txtNamingChange(Sender: TObject);
    procedure lstFormatsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure cmdConfigClick(Sender: TObject);
    procedure cmdAllClick(Sender: TObject);
    procedure cmdImageClick(Sender: TObject);
    procedure cmdVideoClick(Sender: TObject);
    procedure cmdAudioClick(Sender: TObject);
    procedure lstFormatsCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lstFormatsColumnClick(Sender: TObject; Column: TListColumn);
    procedure radiov30Click(Sender: TObject);
    procedure radiov20Click(Sender: TObject);
    procedure radiov10Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkExcludeFalsePositiveClick(Sender: TObject);
    procedure lstFormatsClick(Sender: TObject);
    procedure chkForceBufferSizeClick(Sender: TObject);
    procedure butBufferSizeCheckClick(Sender: TObject);
    procedure chkAutoCloseClick(Sender: TObject);
    procedure chkAutoStartClick(Sender: TObject);
//    procedure sliderMTChange(Sender: TObject);
  private
    formats: THyperRipperFormat;
    SearchThread: TThread;
    SortType: integer;
    SortMode: boolean;
    procedure showExample(st: string);
//    procedure refreshMTText;
  public
    function getInfo(): DriverInfo;
    procedure stopSearch();
    { Déclarations publiques }
  end;
  THRipSearch = class(TThread)
  private
    MAXSIZE: integer;
    numThreads: Integer;
    filename: string;
    searchtime: string;
    size1: string;
    size2: string;
    size3: string;
    size8: string;
    size9: string;
    slist: SearchList;
    hrip: TfrmHyperRipper;
    cancel: boolean;
    function normalizePrefix(prefix: string): string;
    procedure doSearch;
  protected
    StartTime: integer;
    procedure Execute; override;
    function findInBuffer(formatid: Integer; buffer: PByteArray; bufSize: integer): TIntList;
    function verifyInStream(formatid: integer; inStm: TStream; offset: int64): FoundInfo64;
    function BMFind(szSubStr: PChar; buf: PByteArray; iBufSize: integer; iOffset: integer = 0): integer;
    function posBuf(search: byte; buffer: PByteArray; bufSize: integer; startpos: integer = 0): integer;
    function BigToLittle2(src: array of byte): word;
    function BigToLittle4(src: array of byte): integer;
    procedure displayInfo(buffer: pbytearray; curPos: int64; totSize: int64; displayHexDump: boolean = true);
    function EBMLElement(inStm: TStream; var eId, numbytes: int64): int64;
    function ArrayToString(const a: array of Char): string;
  public
    procedure setSearch(filnam: String; sl: SearchList; hr: TfrmHyperRipper; nThreads: integer);
    constructor Create(CreateSuspended: Boolean);
    procedure cancelSearch();
  end;

var
  frmHyperRipper: TfrmHyperRipper;

implementation

uses Main;

{$R *.dfm}

var prefix: string;
    numWAV: Integer;
    Loading: Boolean = True;
    numChecked: Integer;
//    counterMTOver: integer;

procedure TfrmHyperRipper.cmdOkClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('LastActiveTab',PageControl.ActivePageIndex);
      Reg.WriteString('Source',txtSource.text);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  frmHyperRipper.Close;

end;

function Fill0(st: string): string;
begin

  Fill0 := Copy('0000000000'+st,length(st)+1,10);

end;

procedure TfrmHyperRipper.cmdSearchClick(Sender: TObject);
var x: Integer;
    cformat: PFormatListElem;
    slist: SearchList;
begin

  numWAV := 0;
  numChecked := 0;
  prefix := ExtractFileName(txtSource.Text);
  lstResults.Items.Clear;

//  multiRead.BeginWrite;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    if (lstFormats.Items.Item[x].Checked) then
    begin
       cformat := lstFormats.Items.Item[x].Data;
       inc(numChecked);
       slist.items[numChecked].ID := cformat^.ID;
//       slist.items[numChecked].DriverNum := cformat.DriverNum;
    end;
  end;

  slist.num := numChecked;

//  multiRead.EndWrite;

  if FileExists(txtSource.Text) then
  begin
    if numChecked > 0 then
    begin
      if (Dup5Main.menuFichier_Fermer.Enabled) then
        Dup5Main.closeCurrent;
      RunSearch(txtSource.text, slist);
    end
    else
      addResult(DLNGstr('HRLG01'));
  end
  else
    addResult(ReplaceValue('%f',DLNGstr('HRLG02'),ExtractFileName(txtSource.Text)));

end;

procedure TfrmHyperRipper.cmdBrowseClick(Sender: TObject);
begin

  OpenDialog.FileName := txtSource.text;
  OpenDialog.Title := DLNGStr('HYPOPN');
  OpenDialog.Filter := DLNGStr('ALLFIL');
  if OpenDialog.Execute then
    txtSource.Text := OpenDialog.FileName;

end;

procedure TfrmHyperRipper.txtSourceChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
      begin
        Reg.WriteString('Source',txtSource.text);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

    txtHRF.text := ChangeFileExt(txtSource.Text,'.hrf');

  end;

end;

procedure TfrmHyperRipper.FormShow(Sender: TObject);
var Reg: TRegistry;
    cformat: PFormatListElem;
    x: integer;
begin

  translateHyperRipper;

  SortMode := true;
  SortType := 0;
  Loading := True;
  showExample('%f_%x-%n');
  lblMaxLength.Caption := ReplaceValue('%c',DLNGStr('HR3034'),'255');
  lblCompatible.Caption := ReplaceValue('%v',DLNGStr('HR3036'),'5.0.0.77');

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      if (length(txtSource.text) = 0) and Reg.ValueExists('Source') then
      begin
        txtSource.Text := Reg.ReadString('Source');
      end;
{      if Reg.ValueExists('NumThreads') then
        sliderMT.value := Reg.ReadInteger('NumThreads');
      refreshMTText;}
      if Reg.ValueExists('LastActiveTab') then
        PageControl.ActivePageIndex := Reg.ReadInteger('LastActiveTab')
      else
        PageControl.ActivePageIndex := 0;
      if Reg.ValueExists('ExcludeFalsePositive') then
        chkExcludeFalsePositive.Checked := Reg.ReadBool('ExcludeFalsePositive');
      if Reg.ValueExists('AutoClose') and (Reg.GetDataType('AutoClose') = rdInteger) then
        chkAutoClose.Checked := Reg.ReadBool('AutoClose')
      else
        chkAutoClose.Checked := false;
      if Reg.ValueExists('AutoStart') and (Reg.GetDataType('AutoStart') = rdInteger) then
        chkAutoStart.Checked := Reg.ReadBool('AutoStart')
      else
        chkAutoStart.Checked := false;
      if Reg.ValueExists('ForceBufferSize') and (Reg.GetDataType('ForceBufferSize') = rdInteger) then
        chkForceBufferSize.Checked := Reg.ReadBool('ForceBufferSize')
      else
        chkForceBufferSize.Checked := false;
      if Reg.ValueExists('CreateHRF') then
        chkHRF.Checked := Reg.ReadBool('CreateHRF');
      if Reg.ValueExists('HRF3_NoPRGID') then
        chkHRF3_NoPRGID.Checked := Reg.ReadBool('HRF3_NoPRGID');
      if Reg.ValueExists('HRF3_NoPRGVer') then
        chkHRF3_NoPRGVer.Checked := Reg.ReadBool('HRF3_NoPRGVer');
      if Reg.ValueExists('MakeDirs') then
        chkMakeDirs.Checked := Reg.ReadBool('MakeDirs');
      if Reg.ValueExists('HRF_IncludeInformations') then
        chkHRFInfo.Checked := Reg.ReadBool('HRF_IncludeInformations');
      if Reg.ValueExists('HRFAuthor') then
        txtHRFAuthor.Text := Reg.ReadString('HRFAuthor');
      if Reg.ValueExists('HRFTitle') then
        txtHRFTitle.Text := Reg.ReadString('HRFTitle');
      if Reg.ValueExists('HRFURL') then
        txtHRFURL.Text := Reg.ReadString('HRFURL');
      if Reg.ValueExists('Prefix') then
        case Reg.ReadInteger('Prefix') of
          1: chkNamingCustom.Checked := true;
        else
          chkNamingAuto.Checked := true;
        end;
      if Reg.ValueExists('PrefixPredef') then
        txtNaming.Text := Reg.ReadString('PrefixPredef');
      if Reg.ValueExists('HRF_Version') then
        case Reg.ReadInteger('HRF_Version') of
           1: radiov10.Checked := true;
           2: radiov20.Checked := true;
          30: radiov30.Checked := true;
        else
          radiov30.Checked := true;
        end;
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  if length(txtSource.Text) > 0 then
    txtHRF.text := ChangeFileExt(txtSource.Text,'.hrf');

{  for x := 1 to HPlug.NumPlugins do
    if not(@HPlug.Plugins[x].OptionPanel = nil) then
    begin
      NewTabSheet := TTabSheet.Create(PageControl);
      NewTabSheet.PageControl := PageControl;
      HPlug.Plugins[x].OptionPanel(self,NewTabSheet);
    end;}
  for x:=0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.Item[x].Data;
    lstFormats.Items.Item[x].Checked := not(cformat.FalsePositives and chkExcludeFalsePositive.Checked) and CheckRegistryHR('hr_default.d5h',cformat^.ID);
  end;

  Loading := False;

  if chkAutoStart.Checked and (Tag = 1) then
  begin
    PageControl.ActivePageIndex := 1;
    cmdSearch.Click;
  end;

end;

procedure TfrmHyperRipper.addResult(st: String);
begin

  if (lstResults.Items.Count = 5) then
    lstResults.Items.Delete(0);
  lstResults.Items.Add(st);
  dup5Main.writeLog(st);

end;

procedure TfrmHyperRipper.RunSearch(filename: String; slist: SearchList);
//var NumThreads: integer;
    //cxCPU: TcxCPU;
begin

  {cxCPU := TcxCPU.Create;
  try
    if (sliderMT.Value = 0) then
      NumThreads := cxCpu.ProcessorCount.Available.AsNumber
    else
      NumThreads := sliderMT.Value;
  finally
    FreeAndNil(cxCPU);
  end;}

  SearchThread := THripSearch.Create(true);
  (SearchThread as THripSearch).setSearch(filename,slist,Self,1);
  cmdOk.Enabled := false;
  cmdSearch.Visible := false;
  cmdCancel.Visible := true;
  Progress.ShowInTaskbar := true;
  SearchThread.Resume;

end;

procedure TfrmHyperRipper.lastResult(st: String);
begin

  lstResults.Items.Strings[lstResults.Items.Count-1] := st;

end;

procedure TfrmHyperRipper.saveSettings;
var x: integer;
    cformat: PFormatListElem;
begin

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.Item[x].Data;
    setRegistryHR('hr_default.d5h',cformat.ID,lstFormats.Items.Item[x].Checked);
  end;

end;

procedure TfrmHyperRipper.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

  saveSettings;

end;

procedure TfrmHyperRipper.chkRollback0Click(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('BufferRollback',0);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmHyperRipper.chkRollback1Click(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('BufferRollback',1);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmHyperRipper.chkRollback2Click(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('BufferRollback',2);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmHyperRipper.chkRollback3Click(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('BufferRollback',3);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

function FListCompare(Item1, Item2: Pointer): Integer;
var Elem1, Elem2: PFoundItem;
begin

  Elem1 := Item1;
  Elem2 := Item2;

  // Bug fixed by Psych0phobiA (order was reversed)
  result := Elem1^.Offset - Elem2^.Offset;

end;

procedure THRipSearch.cancelSearch;
begin

  cancel := true;

end;

constructor THRipSearch.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  Priority := tpNormal;
  FreeOnTerminate := true;
end;

procedure THRipSearch.Execute;
begin

  doSearch;

end;

procedure THRipSearch.doSearch;
var hSRC, x: integer;
    totsize,curpos,curposbuf: int64;
    buffer: PByteArray;
    bufsize: int64;
    testsize: integer;
    per, oldper: real;
    SomethingFound: Boolean;
    foundOffset: integer;
    found: FoundInfo64;
    numFound, rollback: integer;
    flisttot: TList;
    fitem: PFoundItem;
//    startTime: Cardinal;
    speedcalc: Integer;
    loadTime: integer;
    prgid: byte;
    prgver: integer;
    prefix, resprefix, fext, predir, prespeedcalc: string;
    lastTimer: TDateTime;
    hrfver: byte;
    intTmp1,intTmp2,absoluteOffset,lastOffset: int64;
    bufferOffset: int64;
    foundOffsets: TIntList;
    iNumOffset: Integer;
    tmpspeedcalc: single;
    itmX: Pointer;
    sSRC: THandleStream;
    sSRChandle: integer;
begin

  cancel := false;

  hrip.addResult(ReplaceValue('%f',DLNGstr('HRLG03'),ExtractFileName(filename)));

  if (hrip.chkNamingAuto.Checked) then
    prefix := '%f_%x-%n'
  else
    prefix := hrip.txtNaming.Text;

  prefix := NormalizePrefix(prefix);

  prefix := ReplaceValue('%f',prefix,changefileext(extractfilename(filename),''));

  fext := extractfileext(filename);
  if (Copy(fext,1,1) = '.') then
    fext := Copy(fext,2,length(fext)-1);

  prefix := ReplaceValue('%x',prefix,fext);

  startTime := GetTickCount;

  if hrip.chkForceBufferSize.Checked then
  begin
    hrip.butBufferSizeCheck.Click;
    MAXSIZE := hrip.chkForceBufferSize.Tag;
  end
  else
    // Best speed achieved with 128k (4x better than 8k)
    MAXSIZE := 131072;

  if MAXSIZE < 1024 then
    hrip.lblBufferLength.Caption := inttostr(MAXSIZE) +' B'
  else if MAXSIZE < 1048576 then
    hrip.lblBufferLength.Caption := inttostr(MAXSIZE div 1024) +' KiB'
  else
    hrip.lblBufferLength.Caption := inttostr(MAXSIZE div 1048576) +' MiB';

  hrip.Progress.Max := 100;
  OldPer := 0;
  numFound := 0;

  // Rollback to 32bytes, 128bytes was too high (no format needs more than 12 bytes actually...)
  rollback := 16;

  if rollback < 1024 then
    hrip.lblRollback.Caption := inttostr(rollback) +' B'
  else if rollback < 1048576 then
    hrip.lblRollback.Caption := inttostr(rollback div 1024) +' KiB'
  else
    hrip.lblRollback.Caption := inttostr(rollback div 1048576) +' MiB';

  hrip.lblFound.Caption := IntTostr(numFound);

  // Number of threads to use for buffer search
  //if (numThreads = 0) or (numThreads > 16) then
  numThreads := 1; // Always use single threaded, multi-threading just don't work yet..

  //hrip.lblNumThreads.Caption := inttostr(numThreads);

  try

    // Open the file
    sSRChandle := FileOpen(filename, fmOpenRead or fmShareDenyWrite);

    // If there was an error opening the file raise and error
    if sSRChandle = -1 then
        raise Exception.Create('FileOpen error');

    // Create the THandleStream object from the FileOpen handle
    sSRC := THandleStream.Create(sSRChandle);

    hrip.LastResult(ReplaceValue('%f',DLNGstr('HRLG03'),ExtractFileName(filename))+' '+DLNGstr('HRLG04'));
    hrip.AddResult(DLNGstr('HRLG05'));

    flisttot := TList.Create;

    curPos := 0;
    totsize := sSRC.Size;
    displayInfo(nil,curPos,totSize,false);
    getmem(Buffer,MAXSIZE);
    BufSize := MAXSIZE;
    try
     try
      dup5main.closeCurrent;
      Dup5Main.FSE.PrepareHyperRipper(frmHyperRipper.getInfo);
      CurPos := 0;
      lastTimer := now;
      hrip.LastResult(DLNGstr('HRLG05')+' '+DLNGstr('HRLG04'));
      hrip.AddResult(DLNGstr('HRLG06'));

      SomeThingFound := false;

      while (CurPos < TotSize) and not(cancel) do
      begin
        curPosBuf := 0;

        // If this is the first buffer from the file
        // We do not do rollback
        if curPos = 0 then
          curposbuf := 0
        else if not(SomethingFound) then
        begin
          // We do rollback ONLY if the last buffer used is MAXSIZE bytes
          if (bufsize = MAXSIZE) then
            dec(curPosBuf,rollback);
          // If last buffer not MAXSIZE then we reached end of file
        end;

        // Size of the buffer is:
        //   TotalSize of file - CurrentPosition in file - Previous Buffers
        bufsize := (TotSize - CurPos - CurPosBuf);

        // If the buffer size exceeds the maximum buffer size, we use MAXSIZE instead
        if bufsize > MAXSIZE then
          bufsize := MAXSIZE;

        // Only read buffer if there is still bytes to read
        if bufsize > 0 then
        begin
          // We seek into location
          // That is Current position in file + Current Buffer
          sSRC.Seek(CurPos+CurPosBuf,soBeginning);

          // We store the offset to data
          bufferOffset := curPos+curPosBuf;

          // We read the buffer
          TestSize := sSRC.Read(buffer^,bufsize);
          if (TestSize <> bufsize) then
            raise Exception.create(ReplaceValue('%b',DLNGstr('HRLG07'),inttostr(bufsize-TestSize)));

          // We increase the Previous Buffers size with current buffer size
          inc(CurPosBuf,bufsize);
        end;

        per := (CurPos / TotSize);
        per := per * 100;

        for x := 1 to slist.num do
        begin
//          foundOffsets := HPlug.searchBuffer(slist.items[x].DriverNum,slist.items[x].ID,buffer,bufsize);
          foundoffsets := findInBuffer(slist.items[x].ID,buffer,bufsize);

          if (foundOffsets is TIntList) and (foundOffsets.Count > 0) then
          begin
            for iNumOffset := 0 to foundOffsets.Count - 1 do
            begin
              new(fitem);
              fitem^.Offset := bufferOffset+foundOffsets.Integers[iNumOffset];
              fitem^.Index := x;
              flisttot.Add(fitem);
            end;
          end;
          FreeAndNil(foundOffsets);
        end;

        if (flisttot.Count > 0) then
          flisttot.sort(@FListCompare);

        SomeThingFound := false;
        LastOffset := -1;

        for x := 0 to flisttot.Count-1 do
        begin
          fitem := flisttot.Items[x];
          absoluteOffset := fitem^.offset;
//          absoluteOffset := absoluteOffset + bufferOffset + curPos;
          if absoluteOffset >= LastOffset then
          begin
            try
              Found := verifyInStream(slist.items[fitem^.Index].ID,sSRC,fitem^.Offset);
            except
              on ex: Exception do
              begin
                hrip.addResult(ex.ClassName + ': '+ex.Message);
                break;
              end;
            end;
            if cancel then
              break;
            if (Found.GenType <> HR_TYPE_ERROR) and (Found.Size > 0) then
            begin
              if (hrip.chkMakeDirs.Checked) then
              begin
                if Found.GenType = HR_TYPE_UNKNOWN then
                  predir := 'Unknown\'
                else if Found.GenType = HR_TYPE_AUDIO then
                  predir := 'Audio\'
                else if Found.GenType = HR_TYPE_VIDEO then
                  predir := 'Video\'
                else if Found.GenType = HR_TYPE_IMAGE then
                  predir := 'Image\'
                else
                  predir := '';
              end
              else
                predir := '';

              inc(numFound);
              if (slist.items[fitem^.Index].ID = 1006) or (slist.items[fitem^.Index].ID = 1010) then
                hrip.lastResult(ReplaceValue('%e',ReplaceValue('%a',ReplaceValue('%s',DLNGstr('HRLG08'),inttostr(Found.Size)),inttohex(Found.Offset,8)),Found.Ext))
              else
                hrip.addResult(ReplaceValue('%e',ReplaceValue('%a',ReplaceValue('%s',DLNGstr('HRLG08'),inttostr(Found.Size)),inttohex(Found.Offset,8)),Found.Ext));

              resprefix := ReplaceValue('%o',prefix,IntToStr(Found.Offset));
              resprefix := ReplaceValue('%h',resprefix,IntToHex(Found.Offset,16));
              // Feature request 1216790 //
              resprefix := ReplaceValue('%s',resprefix,IntToStr(Found.Size));
              resprefix := ReplaceValue('%l',resprefix,IntToHex(Found.Size,16));
              //\ Feature request 1216790 //\
              resprefix := ReplaceValue('%n',resprefix,Fill0(inttostr(numFound)));

              Dup5Main.FSE.addEntry(predir+resprefix+'.'+Found.Ext,Found.Offset,Found.Size,0,0);
              curPos := Found.Offset+Found.Size;
              SomethingFound := true;
              LastOffset := curPos;
              if Found.Size = 0 then
                inc(LastOffset);
//              break;
            end
            else if (Found.GenType = HR_TYPE_ERROR) and (Found.Size > 0) and (Found.Offset <> -1) then
            begin
              curPos := Found.Offset+Found.Size;
              SomethingFound := true;
              LastOffset := curPos;
            end;
          end;
        end;

        for x := 0 to flisttot.Count-1 do
        begin
          itmX := flisttot.Items[0];
          flisttot.Remove(itmX);
          Dispose(itmX);
        end;

        Application.ProcessMessages;

        if (Per >= (OldPer + 1)) or (SecondsBetween(lastTimer,now) > 1) then
        begin
          hrip.Progress.Position := Round(Per);
          hrip.lstResults.Refresh;
          hrip.lblFound.Caption := IntTostr(numFound);
          displayInfo(buffer,CurPos,TotSize);
          OldPer := Per;
          lastTimer := now;
        end;

        if Not(SomethingFound) then
          Inc(CurPos,CurPosBuf);

      end;

      hrip.lblFound.Caption := IntTostr(numFound);
      hrip.Progress.Position := 100;
      if (TotSize < 1024) then
        hrip.AddResult(ReplaceValue('%s',ReplaceValue('%t',DLNGstr('HRLG09'),floattostr(round((getTickCount-starttime)/100)/10)),inttostr(CurPos)+DLNGstr('HRLG10')))
      else if (TotSize < 1048576) then
        hrip.AddResult(ReplaceValue('%s',ReplaceValue('%t',DLNGstr('HRLG09'),floattostr(round((getTickCount-starttime)/100)/10)),inttostr(Round(CurPos / 1024))+DLNGstr('HRLG11')))
      else if (TotSize < 1073741824) then
        hrip.AddResult(ReplaceValue('%s',ReplaceValue('%t',DLNGstr('HRLG09'),floattostr(round((getTickCount-starttime)/100)/10)),inttostr(Round(CurPos / 1048576))+DLNGstr('HRLG12')))
      else
        hrip.AddResult(ReplaceValue('%s',ReplaceValue('%t',DLNGstr('HRLG09'),floattostr(round((getTickCount-starttime)/100)/10)),inttostr(Round(CurPos / 1073741824))+DLNGstr('HRLG13')));
      if (hrip.chkHRF.checked) then
      begin
        hrip.addResult(DLNGstr('HRLG14'));
        if hrip.chkHRF3_NoPRGID.Checked then
          prgid := 0
        else
          prgid := HR_ID;
        if hrip.chkHRF3_NoPRGVer.Checked then
          prgver := 0
        else
          prgver := HR_VERSION;
        if hrip.radiov30.Checked then
          hrfver := 3
        else if hrip.radiov20.Checked then
          hrfver := 2
        else
          hrfver := 1;
        Dup5Main.FSE.saveHRF(filename, hrip.txtHRF.Text, TotSize, prgver, prgid, hrfver, hrip.chkHRFInfo.Checked,hrip.txtHRFTitle.Text,hrip.txtHRFAuthor.text,hrip.txtHRFURL.Text);
        hrip.lastResult(DLNGstr('HRLG14')+' '+DLNGstr('HRLG04'));
      end;
      hrip.AddResult(DLNGstr('HRLG15'));
      hrip.Refresh;
      loadTime := getTickCount - startTime;
      Dup5Main.FSE.LoadHyperRipper(filename,sSRChandle,loadTime,hrip.chkMakeDirs.Checked);
  Dup5Main.menuFichier_Fermer.Enabled := True;
  dup5Main.Bouton_Fermer.Enabled := True;
  dup5Main.menuEdit.Visible := True;
  dup5Main.menuTools.Visible := True;
      hrip.LastResult(DLNGstr('HRLG15')+' '+DLNGstr('HRLG04'));
      if (Dup5Main.FSE.GetNumEntries > 0) and (hrip.chkAutoClose.Checked) then
      begin
        hrip.Close;
      end;
     except
      on e: exception do
      begin
        hrip.AddResult(DLNGstr('HRLG16')+' '+e.Message);
        if sSRC <> nil then
          FreeAndNil(sSRC);
        hrip.stopSearch;
      end;
     end;
    finally
      hrip.AddResult(DLNGstr('HRLG17'));
      displayInfo(nil,totSize,totSize,false);
      if (flisttot <> nil) then
      begin
        for x := 0 to flisttot.Count-1 do
          Dispose(flisttot.Items[x]);
        FreeAndNil(flisttot);
      end;
      if sSRC <> nil then
        FreeAndNil(sSRC);
      freemem(Buffer);
//      FileClose(hSRC);
      hrip.LastResult(DLNGstr('HRLG17')+' '+DLNGstr('HRLG04'));
      hrip.stopSearch;
    end;

  except
    hrip.LastResult(ReplaceValue('%f',DLNGstr('HRLG03'),ExtractFileName(filename))+' '+DLNGstr('HRLG18'));
    hrip.stopSearch;
  end;

end;

procedure THRipSearch.displayInfo(buffer: PByteArray; curPos: int64; totSize: int64; displayHexDump: boolean = true);
var x, speedcalc, secondsleft, daysleft, hoursleft, minutesleft: integer;
    tmpspeedcalc: extended;
    leftdisp,tmpdisp: string;
begin

  if (searchtime = '') then
  begin
    searchtime := DLNGstr('HR1030');
    size1 := DLNGstr('HR1020');
    size2 := DLNGstr('HR1021');
    size3 := DLNGstr('HR1022');
    size8 := DLNGstr('HR1028');
    size9 := DLNGstr('HR1029');
  end;

  if (displayHexDump) then
  begin
    hrip.lblHexDump.Caption := '';
    for x := 0 to 17 do
      hrip.lblHexDump.Caption := hrip.lblHexDump.Caption + IntToHex(buffer[x],2)+' ';
  end
  else
    hrip.lblHexDump.Caption := '00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00';
  if (GetTickCount - StartTime) > 0 then
  begin
    tmpspeedcalc := (CurPos / ((GetTickCount - StartTime) / 1000));
    if (tmpspeedcalc > 1048576) then
      tmpdisp := format('%.1f',[(tmpspeedcalc / 1048576)])+' '+size2
    else if (tmpspeedcalc > 1024) then
      tmpdisp := format('%.1f',[(tmpspeedcalc / 1024)])+' '+size1
    else
      tmpdisp := inttostr(round(tmpspeedcalc))+' ';
  end
  else
    tmpdisp := '0 ';
  hrip.lblSpeed.Caption := tmpdisp+size8+size9;

  if (CurPos > 1073741824) then
    tmpdisp := format('%.2f',[(CurPos / 1073741824)])+' '+size3
  else if (CurPos > 1048576) then
    tmpdisp := format('%.2f',[(CurPos / 1048576)])+' '+size2
  else if (CurPos > 1024) then
    tmpdisp := format('%.2f',[(CurPos / 1024)])+' '+size1
  else
    tmpdisp := inttostr(CurPos)+' ';
  hrip.lblScanned.Caption := tmpdisp+size8;

  if ((TotSize-CurPos) > 1073741824) then
    tmpdisp := format('%.2f',[((TotSize-CurPos) / 1073741824)])+' Gi'
  else if ((TotSize-CurPos) > 1048576) then
    tmpdisp := format('%.2f',[((TotSize-CurPos) / 1048576)])+' Mi'
  else if ((TotSize-CurPos) > 1024) then
    tmpdisp := format('%.2f',[((TotSize-CurPos) / 1024)])+' Ki'
  else
    tmpdisp := inttostr((TotSize-CurPos))+' ';
  hrip.lblLeftToScan.Caption := tmpdisp+size8;

  secondsleft := trunc((GetTickCount - StartTime)/1000);
  daysleft := trunc(secondsleft/86400);
  secondsleft := secondsleft mod 86400;
  hoursleft := trunc(secondsleft/3600);
  secondsleft := secondsleft mod 3600;
  minutesleft := trunc(secondsleft/60);
  secondsleft := secondsleft mod 60;
  tmpdisp := format(searchtime,[daysleft,hoursleft,minutesleft,secondsleft]);
  hrip.lblElapsed.Caption := tmpdisp;

  if (tmpspeedcalc > 0) then
  begin
    secondsleft := round((TotSize-CurPos)/ tmpspeedcalc);
    daysleft := trunc(secondsleft/86400);
    secondsleft := secondsleft mod 86400;
    hoursleft := trunc(secondsleft/3600);
    secondsleft := secondsleft mod 3600;
    minutesleft := trunc(secondsleft/60);
    secondsleft := secondsleft mod 60;
    tmpdisp := format(searchtime,[daysleft,hoursleft,minutesleft,secondsleft]);
  end
  else
    tmpdisp := '...';
  hrip.lblEstimated.Caption := tmpdisp;

  hrip.Refresh;

end;

function THRipSearch.normalizePrefix(prefix: string): string;
var x: integer;
    res: string;
begin

  res := '';

  for x := 1 to length(prefix) do
  begin
    if (prefix[x] = '/')
    or (prefix[x] = '\')
    or (prefix[x] = ':')
    or (prefix[x] = '*')
    or (prefix[x] = '?')
    or (prefix[x] = '"')
    or (prefix[x] = '<')
    or (prefix[x] = '>')
//    or (prefix[x] = '.')
    or (prefix[x] = '|') then
      res := res + '_'
    else
      res := res + prefix[x];
  end;

  result := res;

end;

procedure THRipSearch.setSearch(filnam: String; sl: SearchList; hr: TfrmHyperRipper; nThreads: integer);
begin

  filename := filnam;
  slist := sl;
  hrip := hr;
  numThreads := nThreads;

end;

procedure TfrmHyperRipper.stopSearch;
begin

  cmdOk.Enabled := true;
  cmdSearch.Visible := true;
  cmdCancel.Visible := false;
  Progress.ShowInTaskbar := false;

end;

procedure TfrmHyperRipper.cmdCancelClick(Sender: TObject);
begin

  (SearchThread as THRipSearch).cancelSearch;

end;

function TfrmHyperRipper.getInfo: DriverInfo;
begin

  result.Name := 'HyperRipper';
  result.Author := 'Alexandre Devilliers';
  result.Version := getHRVersion(HR_VERSION);
  result.Comment := '';
  result.NumFormats := 0;

end;

procedure TfrmHyperRipper.chkHRFClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('CreateHRF',chkHRF.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  txtHRF.Enabled := chkHRF.Checked;
  cmdHRFBrowse.Enabled := chkHRF.Checked;

end;

procedure TfrmHyperRipper.chkHRFInfoClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('HRF_IncludeInformations',chkHRFInfo.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  txtHRFTitle.Enabled := chkHRFInfo.Checked;
  txtHRFAuthor.Enabled := chkHRFInfo.Checked;
  txtHRFURL.Enabled := chkHRFInfo.Checked;

end;

procedure TfrmHyperRipper.txtHRFTitleChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteString('HRFTitle',txtHRFTitle.Text);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  end;

end;

procedure TfrmHyperRipper.txtHRFAuthorChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteString('HRFAuthor',txtHRFAuthor.Text);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  end;

end;

procedure TfrmHyperRipper.txtHRFURLChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteString('HRFURL',txtHRFURL.Text);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  end;

end;

procedure TfrmHyperRipper.txtHRFChange(Sender: TObject);
//var Reg: TRegistry;
begin

{  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteString('HRF_Filename',txtHRF.Text);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;}

end;

procedure TfrmHyperRipper.cmdHRFBrowseClick(Sender: TObject);
begin

  SaveDialog.Title := 'Make following HyperRIpper file...';
  SaveDialog.Filter := 'All files|*.*|HyperRipper File (*.HRF)|*.HRF';
  SaveDialog.FilterIndex := 2;

  if SaveDialog.Execute then
  begin
    txtHRF.Text := SaveDialog.FileName;

  end;

end;

procedure TfrmHyperRipper.chkHRF3_NoPRGIDClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('HRF3_NoPRGID',chkHRF3_NoPRGID.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmHyperRipper.chkHRF3_NoPRGVerClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('HRF3_NoPRGVer',chkHRF3_NoPRGVer.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmHyperRipper.chkMakeDirsClick(Sender: TObject);
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('MakeDirs',chkMakeDirs.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmHyperRipper.chkNamingCustomClick(Sender: TObject);
var Reg: TRegistry;
begin

  txtNaming.Enabled := true;
  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('Prefix',1);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  showExample(txtNaming.Text);
  
end;

procedure TfrmHyperRipper.chkNamingAutoClick(Sender: TObject);
var Reg: TRegistry;
begin

  txtNaming.Enabled := false;
  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteInteger('Prefix',0);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  showExample('%f_%x-%n');

end;

procedure TfrmHyperRipper.txtNamingChange(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteString('PrefixPredef',txtNaming.Text);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

    showExample(txtNaming.Text);
  end
  else if txtNaming.Enabled then
    showExample(txtNaming.Text);

end;

procedure TfrmHyperRipper.lstFormatsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
var cformat: PFormatListElem;
begin

  if not(loading) then
  begin

    if (lstFormats.ItemIndex > -1) then
    begin
      cformat := lstFormats.Selected.Data;

      if cformat.IsConfig then
        cmdConfig.Enabled := true
      else
        cmdConfig.Enabled := false;
    end
    else
      cmdConfig.Enabled := false;
      
  end
  else
    cmdConfig.Enabled := false;

end;

procedure TfrmHyperRipper.cmdConfigClick(Sender: TObject);
var cformat: PFormatListElem;
begin

  try
    cformat := lstFormats.Selected.Data;
    formats.showConfigBox(cformat.ID);
  except
    // une erreur..
  end;

end;

procedure TfrmHyperRipper.cmdAllClick(Sender: TObject);
var x, nc, excl: integer;
    cformat: PFormatListElem;
begin

  nc := 0;
  excl := 0;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if chkExcludeFalsePositive.Checked and cformat.FalsePositives then
      inc(excl)
    else if lstFormats.Items.Item[x].Checked then
      inc(nc);
  end;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if chkExcludeFalsePositive.Checked and cformat.FalsePositives then
      lstFormats.Items.Item[x].Checked := false
    else
      lstFormats.Items.Item[x].Checked := not(nc = (lstFormats.Items.Count - excl));
  end;

end;

procedure TfrmHyperRipper.cmdImageClick(Sender: TObject);
var x, nc, gt: integer;
    cformat: PFormatListElem;
begin

  gt := 0;
  nc := 0;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if ((chkExcludeFalsePositive.Checked and not(cformat.FalsePositives))
    or not(chkExcludeFalsePositive.Checked))
    and (cformat.GenType = HR_TYPE_IMAGE) then
    begin
      inc(gt);
      if lstFormats.Items.Item[x].Checked then
        inc(nc);
    end;
  end;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if chkExcludeFalsePositive.Checked and cformat.FalsePositives then
      lstFormats.Items.Item[x].Checked := false
    else if cformat.GenType = HR_TYPE_IMAGE then
      lstFormats.Items.Item[x].Checked := not(nc = gt);
  end;

end;

procedure TfrmHyperRipper.cmdVideoClick(Sender: TObject);
var x, nc, gt: integer;
    cformat: PFormatListElem;
begin

  gt := 0;
  nc := 0;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if ((chkExcludeFalsePositive.Checked and not(cformat.FalsePositives))
    or not(chkExcludeFalsePositive.Checked))
    and (cformat.GenType = HR_TYPE_VIDEO) then
    begin
      inc(gt);
      if lstFormats.Items.Item[x].Checked then
        inc(nc);
    end;
  end;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if chkExcludeFalsePositive.Checked and cformat.FalsePositives then
      lstFormats.Items.Item[x].Checked := false
    else if cformat.GenType = HR_TYPE_VIDEO then
      lstFormats.Items.Item[x].Checked := not(nc = gt);
  end;

end;

procedure TfrmHyperRipper.cmdAudioClick(Sender: TObject);
var x, nc, gt: integer;
    cformat: PFormatListElem;
begin

  gt := 0;
  nc := 0;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if ((chkExcludeFalsePositive.Checked and not(cformat.FalsePositives))
    or not(chkExcludeFalsePositive.Checked))
    and (cformat.GenType = HR_TYPE_AUDIO) then
    begin
      inc(gt);
      if lstFormats.Items.Item[x].Checked then
        inc(nc);
    end;
  end;

  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.item[x].Data;
    if chkExcludeFalsePositive.Checked and cformat.FalsePositives then
      lstFormats.Items.Item[x].Checked := false
    else if cformat.GenType = HR_TYPE_AUDIO then
      lstFormats.Items.Item[x].Checked := not(nc = gt);
  end;

end;

procedure TfrmHyperRipper.lstFormatsCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin

  case Data of
    0: begin
         if (Item1.Caption = Item2.Caption) then
           Compare := 0
         else if (Item1.Caption < Item2.Caption) then
           Compare := -1
         else
           Compare := 1;
       end;
    1: begin
         if (Item1.SubItems.Strings[0] = Item2.SubItems.Strings[0]) then
           Compare := 0
         else if (Item1.SubItems.Strings[0] < Item2.SubItems.Strings[0]) then
           Compare := -1
         else
           Compare := 1;
       end;
    2: begin
         if (Item1.SubItems.Strings[1] = Item2.SubItems.Strings[1]) then
           Compare := 0
         else if (Item1.SubItems.Strings[1] < Item2.SubItems.Strings[1]) then
           Compare := -1
         else
           Compare := 1;
       end;
  end;

//  ShowMessage(inttostr(data)+#10+inttostr(compare));

end;

procedure TfrmHyperRipper.lstFormatsColumnClick(Sender: TObject;
  Column: TListColumn);
begin

  lstFormats.CustomSort(nil,Column.Index); 

end;

procedure TfrmHyperRipper.radiov30Click(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin
    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
        Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
      begin
        Reg.WriteInteger('HRF_Version',30);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;
  end;

  lblMaxLength.Caption := ReplaceValue('%c',DLNGStr('HR3034'),'255');
  lblCompatible.Caption := ReplaceValue('%v',DLNGStr('HR3036'),'5.0.0.77');

  chkHRF3_NoPRGID.Enabled := true;
  chkHRFInfo.Enabled := true;
  txtHRFTitle.Enabled := true;
  txtHRFAuthor.Enabled := true;
  txtHRFURL.Enabled := true;

end;

procedure TfrmHyperRipper.radiov20Click(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin
    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
        Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
      begin
        Reg.WriteInteger('HRF_Version',2);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;
  end;

  lblMaxLength.Caption := ReplaceValue('%c',DLNGStr('HR3034'),'64');
  lblCompatible.Caption := ReplaceValue('%v',DLNGStr('HR3036'),'4.13.74');

  chkHRF3_NoPRGID.Enabled := false;
  chkHRFInfo.Enabled := true;
  txtHRFTitle.Enabled := true;
  txtHRFAuthor.Enabled := true;
  txtHRFURL.Enabled := true;

end;

procedure TfrmHyperRipper.radiov10Click(Sender: TObject);
var Reg: TRegistry;
begin

  if not(loading) then
  begin
    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
        Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
      begin
        Reg.WriteInteger('HRF_Version',1);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;
  end;

  lblMaxLength.Caption := ReplaceValue('%c',DLNGStr('HR3034'),'32');
  lblCompatible.Caption := ReplaceValue('%v',DLNGStr('HR3036'),'4.00.38');

  chkHRF3_NoPRGID.Enabled := false;
  chkHRFInfo.Enabled := false;
  txtHRFTitle.Enabled := false;
  txtHRFAuthor.Enabled := false;
  txtHRFURL.Enabled := false;

end;

procedure TfrmHyperRipper.showExample(st: string);
var res: string;
begin

  res := trim(st);
  res := ReplaceValue('%f',res,'exsounds');
  res := ReplaceValue('%x',res,'pak');
  res := ReplaceValue('%o',res,'9562');
  res := ReplaceValue('%h',res,'000000000000255A');
  // Feature request 1216790 //
  res := ReplaceValue('%s',res,'7890');
  res := ReplaceValue('%l',res,'0000000000001ED2');
  //\ Feature request 1216790 //\
  res := ReplaceValue('%n',res,'5');

  txtExample.Text := ' '+res+'.wav';

end;

{procedure TfrmHyperRipper.refreshMTText;
var cxCPU: TcxCPU;
begin

  if sliderMT.Value = 0 then
  begin
    cxCPU := TcxCPU.Create;
    try
      lblMTValue.Caption := 'Auto ('+inttostr(cxCpu.ProcessorCount.Available.AsNumber)+' threads)';
    finally
      FreeAndNil(cxCPU);
    end;
  end
  else if sliderMT.Value = 1 then
    lblMTValue.Caption := 'No (Single thread)'
  else
    lblMTValue.Caption := inttostr(sliderMT.Value)+' threads';

end;}

{procedure TfrmHyperRipper.sliderMTChange(Sender: TObject);
var Reg: TRegistry;
begin

  refreshMTText;

  if not(loading) then
  begin

    Reg := TRegistry.Create;
    Try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
        Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
      if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
      begin
        Reg.WriteInteger('NumThreads',sliderMT.Value);
        Reg.CloseKey;
      end;
    Finally
      FreeAndNil(Reg);
    end;

  end;


end;}

function THRipSearch.BigToLittle2(src: array of byte): word;
begin
  result := src[1] + src[0]*$100;
end;

function THRipSearch.BigToLittle4(src: array of byte): integer;
begin
  result := src[3] + src[2]*$100 + src[1]*$10000 + src[0]*$1000000;
end;

function THyperRipperFormat.getMPEGOptions(): MPEGOptions;
var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper\hr_default\MPEGAudio',True) then
    begin
      if Reg.ValueExists('FramesMin') then
      begin
        result.FramesMin := Reg.ReadInteger('FramesMin');
        if result.FramesMin < 2 then
          result.FramesMin := 2;
      end
      else
        result.FramesMin := 20;
      if Reg.ValueExists('FramesMax') then
        result.FramesMax := Reg.ReadInteger('FramesMax')
      else
        result.FramesMax := 30000;
      if result.FramesMax < result.FramesMin then
        result.FramesMax := result.FramesMin;
      if Reg.ValueExists('SizeMin') then
      begin
        result.SizeMin := Reg.ReadInteger('SizeMin');
        if result.SizeMin < 2048 then
          result.SizeMin := 2048;
      end
      else
        result.SizeMin := 2048;
      if Reg.ValueExists('SizeMax') then
        result.SizeMax := Reg.ReadInteger('SizeMax')
      else
        result.SizeMax := MaxInt;
      if result.SizeMax < result.SizeMin then
        result.SizeMax := result.SizeMin;
      if Reg.ValueExists('LimitFramesMin') then
        result.LimitFramesMin := Reg.ReadBool('LimitFramesMin')
      else
        result.LimitFramesMin := true;
      if Reg.ValueExists('LimitFramesMax') then
        result.LimitFramesMax := Reg.ReadBool('LimitFramesMax')
      else
        result.LimitFramesMax := false;
      if Reg.ValueExists('LimitSizeMin') then
        result.LimitSizeMin := Reg.ReadBool('LimitSizeMin')
      else
        result.LimitSizeMin := true;
      if Reg.ValueExists('LimitSizeMax') then
        result.LimitSizeMax := Reg.ReadBool('LimitSizeMax')
      else
        result.LimitSizeMax := false;
      if Reg.ValueExists('SpecialXingVBR') then
        result.XingVBR := Reg.ReadBool('SpecialXingVBR')
      else
        result.XingVBR := true;
      if Reg.ValueExists('SpecialID3Tag') then
        result.ID3Tag := Reg.ReadBool('SpecialID3Tag')
      else
        result.ID3Tag := true;
      if Reg.ValueExists('MP10_1') then
        result.MP10_1 := Reg.ReadBool('MP10_1')
      else
        result.MP10_1 := true;
      if Reg.ValueExists('MP20_1') then
        result.MP20_1 := Reg.ReadBool('MP20_1')
      else
        result.MP20_1 := false;
      if Reg.ValueExists('MP25_1') then
        result.MP25_1 := Reg.ReadBool('MP25_1')
      else
        result.MP25_1 := false;
      if Reg.ValueExists('MP10_2') then
        result.MP10_2 := Reg.ReadBool('MP10_2')
      else
        result.MP10_2 := true;
      if Reg.ValueExists('MP20_2') then
        result.MP20_2 := Reg.ReadBool('MP20_2')
      else
        result.MP20_2 := false;
      if Reg.ValueExists('MP25_2') then
        result.MP25_2 := Reg.ReadBool('MP25_2')
      else
        result.MP25_2 := false;
      if Reg.ValueExists('MP10_3') then
        result.MP10_3 := Reg.ReadBool('MP10_3')
      else
        result.MP10_3 := true;
      if Reg.ValueExists('MP20_3') then
        result.MP20_3 := Reg.ReadBool('MP20_3')
      else
        result.MP20_3 := true;
      if Reg.ValueExists('MP25_3') then
        result.MP25_3 := Reg.ReadBool('MP25_3')
      else
        result.MP25_3 := true;
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

function THRipSearch.posBuf(search: byte; buffer: PByteArray; bufSize: integer; startpos: integer = 0): integer;
var x: integer;
begin

  result := -1;
  for x := startpos to bufSize do
  begin
    if buffer[x] = search then
    begin
      result := x;
      break;
    end;
  end;

end;

function THRipSearch.BMFind(szSubStr: PChar; buf: PByteArray; iBufSize: integer; iOffset: integer = 0): integer;
{ Returns -1 if substring not found,
   or zero-based index into buffer if substring found }
var
   iSubStrLen: integer;
   skip: array [byte] of integer;
   found: boolean;
   iMaxSubStrIdx: integer;
   iSubStrIdx: integer;
   iBufIdx: integer;
   iScanSubStr: integer;
   mismatch: boolean;
   iBufScanStart: integer;
   ch: byte;
begin
   { Initialisations }
   found := False;
   Result := -1;

   { Check if trivial scan for empty string }
   iSubStrLen := StrLen(szSubStr);
   if iSubStrLen = 0 then
   begin
     Result := 0;
     Exit
   end;
   iMaxSubStrIdx := iSubStrLen - 1;

   { Initialise the skip table }
   for ch := Low(skip) to High(skip) do skip[ch] := iSubStrLen;
   for iSubStrIdx := 0 to (iSubStrLen - 1) do
     skip[ord(szSubStr[iSubStrIdx])] := Max(iMaxSubStrIdx - iSubStrIdx,1);

   { Scan the buffer, starting comparisons at the end of the substring }
   iBufScanStart := iOffset + iMaxSubStrIdx;
   while (not found) and (iBufScanStart < iBufSize) do
   begin
     iBufIdx := iBufScanStart;
     iScanSubStr := iMaxSubStrIdx;
     repeat
       mismatch := (ord(szSubStr[iScanSubStr]) <> buf[iBufIdx]);
       if not mismatch then
         if iScanSubStr > 0 then
         begin // more characters to scan
           Dec(iBufIdx); Dec(iScanSubStr)
         end
         else
           found := True;
     until mismatch or found;
     if found then
       Result := iBufIdx
     else
       iBufScanStart := iBufScanStart + skip[buf[iBufScanStart]];
   end;
end;

function THyperRipperFormat.GetFormatsList(): ExtSearchFormatsList;
var lngEXSND, lngEXIMG, lngEXVID: string;
begin

  lngEXSND := DLNGstr('HRTSND');
  lngEXIMG := DLNGstr('HRTIMG');
  lngEXVID := DLNGstr('HRTVID');

  result.NumFormats := 27;
  SetLength(result.FormatsList,result.NumFormats);
  result.FormatsList[1].GenType := HR_TYPE_AUDIO;
  result.FormatsList[1].Format := 'WAVE';
  result.FormatsList[1].Desc := 'Wave/RIFF';
  result.FormatsList[1].ID := 1000;
  result.FormatsList[1].IsConfig := False;
  result.FormatsList[1].FalsePositives := False;
  result.FormatsList[2].GenType := HR_TYPE_AUDIO;
  result.FormatsList[2].Format := 'VOC';
  result.FormatsList[2].Desc := 'Creative VOice';
  result.FormatsList[2].ID := 1001;
  result.FormatsList[2].IsConfig := False;
  result.FormatsList[2].FalsePositives := False;
  result.FormatsList[3].GenType := HR_TYPE_AUDIO;
  result.FormatsList[3].Format := 'MIDI';
  result.FormatsList[3].Desc := 'MIDI';
  result.FormatsList[3].ID := 1002;
  result.FormatsList[3].IsConfig := False;
  result.FormatsList[3].FalsePositives := False;
  result.FormatsList[4].GenType := HR_TYPE_AUDIO;
  result.FormatsList[4].Format := '669';
  result.FormatsList[4].Desc := '669';
  result.FormatsList[4].ID := 1003;
  result.FormatsList[4].IsConfig := False;
  result.FormatsList[4].FalsePositives := True;
  result.FormatsList[5].GenType := HR_TYPE_AUDIO;
  result.FormatsList[5].Format := '669 EXT.';
  result.FormatsList[5].Desc := 'Extended 669';
  result.FormatsList[5].ID := 1004;
  result.FormatsList[5].IsConfig := False;
  result.FormatsList[5].FalsePositives := True;
  result.FormatsList[6].GenType := HR_TYPE_AUDIO;
  result.FormatsList[6].Format := 'XM';
  result.FormatsList[6].Desc := 'eXtended Module/FT2';
  result.FormatsList[6].ID := 1005;
  result.FormatsList[6].IsConfig := False;
  result.FormatsList[6].FalsePositives := False;
  result.FormatsList[12].GenType := HR_TYPE_AUDIO;
  result.FormatsList[12].Format := 'MP3';
  result.FormatsList[12].Desc := 'MPEG-1/2 Audio';
  result.FormatsList[12].ID := 1006;
  result.FormatsList[12].IsConfig := True;
  result.FormatsList[12].FalsePositives := False;
  result.FormatsList[23].GenType := HR_TYPE_AUDIO;
  result.FormatsList[23].Format := 'AAC';
  result.FormatsList[23].Desc := 'AAC (ADTS)';
  result.FormatsList[23].ID := 1010;
  result.FormatsList[23].IsConfig := True;
  result.FormatsList[23].FalsePositives := False;
  result.FormatsList[19].GenType := HR_TYPE_AUDIO;
  result.FormatsList[19].Format := 'S3M';
  result.FormatsList[19].Desc := 'Scream Tracker 3 Module';
  result.FormatsList[19].ID := 1007;
  result.FormatsList[19].IsConfig := False;
  result.FormatsList[19].FalsePositives := False;
  result.FormatsList[20].GenType := HR_TYPE_AUDIO;
  result.FormatsList[20].Format := 'IT';
  result.FormatsList[20].Desc := 'Impulse Tracker Module';
  result.FormatsList[20].ID := 1008;
  result.FormatsList[20].IsConfig := False;
  result.FormatsList[20].FalsePositives := true;
  result.FormatsList[21].GenType := HR_TYPE_AUDIO;
  result.FormatsList[21].Format := 'OGG';
  result.FormatsList[21].Desc := 'Ogg Stream';
  result.FormatsList[21].ID := 1009;
  result.FormatsList[21].IsConfig := False;
  result.FormatsList[21].FalsePositives := False;
  result.FormatsList[24].GenType := HR_TYPE_AUDIO;
  result.FormatsList[24].Format := 'M4A';
  result.FormatsList[24].Desc := 'MPEG-4 Audio';
  result.FormatsList[24].ID := 1011;
  result.FormatsList[24].IsConfig := False;
  result.FormatsList[24].FalsePositives := False;

  result.FormatsList[13].GenType := HR_TYPE_VIDEO;
  result.FormatsList[13].Format := 'AVI';
  result.FormatsList[13].Desc := 'AVI/RIFF';
  result.FormatsList[13].ID := 2000;
  result.FormatsList[13].IsConfig := false;
  result.FormatsList[13].FalsePositives := False;
  result.FormatsList[16].GenType := HR_TYPE_VIDEO;
  result.FormatsList[16].Format := 'MOV';
  result.FormatsList[16].Desc := 'QuickTime Movie';
  result.FormatsList[16].ID := 2001;
  result.FormatsList[16].IsConfig := false;
  result.FormatsList[16].FalsePositives := False;
  result.FormatsList[17].GenType := HR_TYPE_VIDEO;
  result.FormatsList[17].Format := 'BIK';
  result.FormatsList[17].Desc := 'Bink/RAD';
  result.FormatsList[17].ID := 2002;
  result.FormatsList[17].IsConfig := false;
  result.FormatsList[17].FalsePositives := False;
  result.FormatsList[18].GenType := HR_TYPE_VIDEO;
  result.FormatsList[18].Format := 'FLIC';
  result.FormatsList[18].Desc := 'Autodesk Animator & EGI/DTA FLIC';
  result.FormatsList[18].ID := 2003;
  result.FormatsList[18].IsConfig := false;
  result.FormatsList[18].FalsePositives := true;
  result.FormatsList[25].GenType := HR_TYPE_VIDEO;
  result.FormatsList[25].Format := 'MP4';
  result.FormatsList[25].Desc := 'MPEG-4 Video';
  result.FormatsList[25].ID := 2004;
  result.FormatsList[25].IsConfig := False;
  result.FormatsList[25].FalsePositives := False;
  result.FormatsList[26].GenType := HR_TYPE_VIDEO;
  result.FormatsList[26].Format := 'MKV';
  result.FormatsList[26].Desc := 'Matroska/WebM';
  result.FormatsList[26].ID := 2005;
  result.FormatsList[26].IsConfig := False;
  result.FormatsList[26].FalsePositives := False;

  result.FormatsList[7].GenType := HR_TYPE_IMAGE;
  result.FormatsList[7].Format := 'BMP';
  result.FormatsList[7].Desc := 'Windows BitMaP';
  result.FormatsList[7].ID := 3000;
  result.FormatsList[7].IsConfig := False;
  result.FormatsList[7].FalsePositives := False;
  result.FormatsList[8].GenType := HR_TYPE_IMAGE;
  result.FormatsList[8].Format := 'EMF';
  result.FormatsList[8].Desc := 'Windows Enhanced MetaFile';
  result.FormatsList[8].ID := 3001;
  result.FormatsList[8].IsConfig := False;
  result.FormatsList[8].FalsePositives := False;
  result.FormatsList[9].GenType := HR_TYPE_IMAGE;
  result.FormatsList[9].Format := 'WMF';
  result.FormatsList[9].Desc := 'Windows MetaFile';
  result.FormatsList[9].ID := 3002;
  result.FormatsList[9].IsConfig := False;
  result.FormatsList[9].FalsePositives := False;
  result.FormatsList[10].GenType := HR_TYPE_IMAGE;
  result.FormatsList[10].Format := 'PNG';
  result.FormatsList[10].Desc := 'Portable Network Graphics';
  result.FormatsList[10].ID := 3003;
  result.FormatsList[10].IsConfig := False;
  result.FormatsList[10].FalsePositives := False;
  result.FormatsList[11].GenType := HR_TYPE_IMAGE;
  result.FormatsList[11].Format := 'GIF';
  result.FormatsList[11].Desc := 'Graphics Interchange Format';
  result.FormatsList[11].ID := 3004;
  result.FormatsList[11].IsConfig := False;
  result.FormatsList[11].FalsePositives := False;
  result.FormatsList[14].GenType := HR_TYPE_IMAGE;
  result.FormatsList[14].Format := 'LBM';
  result.FormatsList[14].Desc := 'LBM/EA IFF 1985';
  result.FormatsList[14].ID := 3005;
  result.FormatsList[14].IsConfig := False;
  result.FormatsList[14].FalsePositives := False;
  result.FormatsList[15].GenType := HR_TYPE_IMAGE;
  result.FormatsList[15].Format := 'JPEG';
  result.FormatsList[15].Desc := 'JPEG/JFIF';
  result.FormatsList[15].ID := 3006;
  result.FormatsList[15].IsConfig := False;
  result.FormatsList[15].FalsePositives := False;
  result.FormatsList[22].GenType := HR_TYPE_IMAGE;
  result.FormatsList[22].Format := 'DDS';
  result.FormatsList[22].Desc := 'DirectX Texture';
  result.FormatsList[22].ID := 3007;
  result.FormatsList[22].IsConfig := False;
  result.FormatsList[22].FalsePositives := False;
  // TGA RGB by Psych0phobiA -- Start //
  result.FormatsList[0].GenType := HR_TYPE_IMAGE;
  result.FormatsList[0].Format := 'TGA';
  result.FormatsList[0].Desc := 'TrueVision Targa (RGB)';
  result.FormatsList[0].ID := 3008;
  result.FormatsList[0].IsConfig := False;
  result.FormatsList[0].FalsePositives := False;
  // TGA RGB by Psych0phobiA -- End //

end;

function THRipSearch.findInBuffer(formatid: Integer; buffer: PByteArray; bufSize: integer): TIntList;
var tmpRes,tmpPos1,tmpPos2,tmpPosMax: integer;
//    memBuf: TMemoryStream;
    szFind: array [0..255] of char;
begin

    result := TIntList.Create;
//  memBuf := TMemoryStream.create();
//  try
//    memBuf.Write(buffer^,bufSize);

//    Application.ProcessMessages;

    tmpRes := 0;

    while (tmpRes <> -1) and (tmpRes <= bufSize) do
    begin

      case formatid of
        1000: begin
                strPCopy(szFind,'RIFF');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                  if ((tmpRes+11) <= bufSize) and (buffer[tmpRes+8] = 87)
                                              and (buffer[tmpRes+9] = 65)
                                              and (buffer[tmpRes+10] = 86)
                                              and (buffer[tmpRes+11] = 69) then
                  begin
                    // Add found offset to the list
                    result.Add(tmpRes);
                    // Next searchable offset is 12 bytes after the one found
                    inc(tmpRes,12);
                  end
                  else // Next searchable offset is 4 bytes after the last RIFF found
                    inc(tmpRes,4);
              end;
        1001: begin
                strPCopy(szFind,'Creative Voice File'+chr(26));
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 19 bytes after the one found
                  inc(tmpRes,19);
                end;
              end;
        1002: begin
                strPCopy(szFind,'MThd');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                  if (buffer[tmpRes+4] = 0) and
                     (buffer[tmpRes+5] = 0) and
                     (buffer[tmpRes+6] = 0) and
                     (buffer[tmpRes+7] = 6) then
                  begin
                    // Add found offset to the list
                    result.Add(tmpRes);
                    // Next searchable offset is 8 bytes after the one found
                    inc(tmpRes,8);
                  end
                  else
                    // Next searchable offset is 4 bytes after the one found
                    inc(tmpRes,4);
              end;
        1003: begin
                strPCopy(szFind,'if');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 2 bytes after the one found
                  inc(tmpRes,2);
                end;
              end;
        1004: begin
                strPCopy(szFind,'JN');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 2 bytes after the one found
                  inc(tmpRes,2);
                end;
              end;
        1005: begin
                strPCopy(szFind,'Extended Module: ');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 17 bytes after the one found
                  inc(tmpRes,17);
                end;
              end;
        1006: begin
                //strPCopy(szFind,char(255));
                //tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                tmpRes := posBuf(255,buffer,bufsize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  if ((tmpRes < (bufsize - 1))
                  and ((buffer[tmpRes+1] and 224) = 224))
                  or (tmpRes = (bufsize - 1)) then
                    // Add found offset to the list
                    result.Add(tmpRes);
                  // Next searchable offset is 1 byte after the one found
                  inc(tmpRes);
                end;
              end;
        1007: begin
                strPCopy(szFind,'SCRM');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 4 bytes after the one found
                  inc(tmpRes,4);
                end;
              end;
        1008: begin
                strPCopy(szFind,'IMPM');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 4 bytes after the one found
                  inc(tmpRes,4);
                end;
              end;
        1009: begin
                strPCopy(szFind,'OggS');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                  if (buffer[tmpRes+4] = 0) then
                  begin
                    // Add found offset to the list
                    result.Add(tmpRes);
                    // Next searchable offset is 5 bytes after the one found
                    inc(tmpRes,5);
                  end
                  else
                    // Next searchable offset is 4 bytes after the one found
                    inc(tmpRes,4);
              end;
        1010: begin
                //strPCopy(szFind,char(255));
                //tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                tmpRes := posBuf(255,buffer,bufsize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  if ((tmpRes < (bufsize - 1))
                  and ((buffer[tmpRes+1] and 240) = 240))
                  or (tmpRes = (bufsize - 1)) then
                    // Add found offset to the list
                    result.Add(tmpRes);
                  // Next searchable offset is 1 byte after the one found
                  inc(tmpRes);
                end;
              end;
        1011: begin
                strPCopy(szFind,'ftypM4');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                  if ((buffer[tmpRes+6] = 65) or (buffer[tmpRes+6] = 66) or (buffer[tmpRes+6] = 80)) and (buffer[tmpRes+7] = 32) then
                  begin
                    // Add found offset to the list
                    result.Add(tmpRes-4);
                    // Next searchable offset is 8 bytes after the one found
                    inc(tmpRes,8);
                  end
                  else
                    // Next searchable offset is 4 bytes after the one found
                    inc(tmpRes,4);
              end;

        2000: begin
                strPCopy(szFind,'RIFF');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                  if ((tmpRes+11) <= bufSize) and (buffer[tmpRes+8] = 65)
                                              and (buffer[tmpRes+9] = 86)
                                              and (buffer[tmpRes+10] = 73)
                                              and (buffer[tmpRes+11] = 32) then
                  begin
                    // Add found offset to the list
                    result.Add(tmpRes);
                    // Next searchable offset is 12 bytes after the one found
                    inc(tmpRes,12);
                  end
                  else // Next searchable offset is 4 bytes after the last RIFF found
                    inc(tmpRes,4);
              end;
        2001: begin
                strPCopy(szFind,'moov');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 4 bytes after the one found
                  inc(tmpRes,4);
                end;
              end;
        2002: begin
                strPCopy(szFind,'BIK');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 3 bytes after the one found
                  inc(tmpRes,3);
                end;
              end;
        2003: begin
                strPCopy(szFind,#17+#175);
                tmpPos1 := BMFind(szFind,buffer,bufSize,tmpRes);
                strPCopy(szFind,#18+#175);
                tmpPos2 := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpPos1 = -1) or ((tmpPos2 > -1) and (tmpPos2 < tmpPos1)) then
                  tmpPos1 := tmpPos2;
                tmpPosMax := max(tmpPos1,tmpPos2);
                strPCopy(szFind,#48+#175);
                tmpPos2 := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpPos1 = -1) or ((tmpPos2 > -1) and (tmpPos2 < tmpPos1)) then
                  tmpPos1 := tmpPos2;
                tmpPosMax := max(tmpPosMax,tmpPos2);
                strPCopy(szFind,#68+#175);
                tmpPos2 := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpPos2 > -1) and (tmpPos2 < tmpPos1) then
                  tmpPos1 := tmpPos2;
                tmpPosMax := max(tmpPosMax,tmpPos2);

                if tmpPos1 <> -1 then
                begin
                  result.Add(tmpPos1);

                  inc(tmpRes,tmpPosMax+2);
                end
                else
                  tmpRes := -1;

              end;
        2004: begin
                strPCopy(szFind,'ftypmp4');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                  if (buffer[tmpRes+7] = 49) or (buffer[tmpRes+7] = 50) then
                  begin
                    // Add found offset to the list
                    result.Add(tmpRes-4);
                    // Next searchable offset is 8 bytes after the one found
                    inc(tmpRes,8);
                  end
                  else
                    // Next searchable offset is 4 bytes after the one found
                    inc(tmpRes,4);
              end;
        2005: begin
                strPCopy(szFind, #26+#69+#223+#163);
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 8 bytes after the one found
                  inc(tmpRes,5);
                end
              end;

        3000: begin
                strPCopy(szFind,'BM');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 2 bytes after the one found
                  inc(tmpRes,2);
                end;
              end;
        3001: begin
                strPCopy(szFind,' EMF');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 4 bytes after the one found
                  inc(tmpRes,4);
                end;
              end;
        3002: begin
                strPCopy(szFind,'×ÍÆš');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 4 bytes after the one found
                  inc(tmpRes,4);
                end;
              end;
        3003: begin
                strPCopy(szFind,#137 + #80 + #78 + #71 + #13 + #10 + #26 + #10);
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 8 bytes after the one found
                  inc(tmpRes,8);
                end;
              end;
        3004: begin
                strPCopy(szFind,'GIF8');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 4 bytes after the one found
                  inc(tmpRes,4);
                end;
              end;
        3005: begin
                strPCopy(szFind,'FORM');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                // If magic ID is found
                if (tmpRes <> -1) then
                  // Check if +8 bytes after ILBM magic ID is found
                  if ((tmpRes+11) <= bufSize) and (buffer[tmpRes+8] = 73)
                                              and (buffer[tmpRes+9] = 76)
                                              and (buffer[tmpRes+10] = 66)
                                              and (buffer[tmpRes+11] = 77) then
                  begin
                    // Add found offset to the list
                    result.Add(tmpRes);
                    // Next searchable offset is 12 bytes after the one found
                    inc(tmpRes,12);
                  end
                  else
                    // Next searchable offset is 4 bytes after the one found
                    inc(tmpRes,4);
              end;
        3006: begin
                strPCopy(szFind,#255+#216+#255);
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  if ((tmpRes+9) <= bufsize) then
                  begin
                    // JPEG with APP0 marker (JFIF)
                    if (buffer[tmpRes+3] = 224) then
                    begin
                      if (buffer[tmpRes+6] = 74) and (buffer[tmpRes+7] = 70) and (buffer[tmpRes+8] = 73) and (buffer[tmpRes+9] = 70) then
                      begin
                       // Add found offset to the list
                       result.Add(tmpRes);
                       // Next searchable offset is 10 bytes after the one found
                       inc(tmpRes,10);
                      end
                      else
                        inc(tmpRes,4);
                    end
                    // JPEG with Exif (APP1 marker)
                    else if (buffer[tmpRes+3] = 225) then
                    begin
                      if (buffer[tmpRes+6] = 69) and (buffer[tmpRes+7] = 120) and (buffer[tmpRes+8] = 105) and (buffer[tmpRes+9] = 102) then
                      begin
                        // Add found offset to the list
                        result.Add(tmpRes);
                        // Next searchable offset is 10 bytes after the one found
                        inc(tmpRes,10);
                      end
                      else
                       inc(tmpRes,4);
                    end
                    else
                      inc(tmpRes,4);
                  end
                  else
                    inc(tmpRes,3);
                end
              end;
        3007: begin
                strPCopy(szFind,'DDS ');
                tmpRes := BMFind(szFind,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  // Add found offset to the list
                  result.Add(tmpRes);
                  // Next searchable offset is 4 bytes after the one found
                  inc(tmpRes,4);
                end;
              end;
        // TGA RGB search by Psych0phobiA -- Start //
        3008: begin
                tmpRes := posBuf(0,buffer,bufSize,tmpRes);
                if (tmpRes <> -1) then
                begin
                  if (tmpRes > (bufSize - 17)) then
                    tmpRes := -1
                  else
                  begin
                    if (buffer[tmpRes+1] = 0)
                    and (buffer[tmpRes+2] = 2)
                    and (buffer[tmpRes+3] = 0)
                    and (buffer[tmpRes+4] = 0)
                    and (buffer[tmpRes+5] = 0)
                    and (buffer[tmpRes+6] = 0)
                    and ( (buffer[tmpRes+7] = 0)
                       or (buffer[tmpRes+7] = 15)
                       or (buffer[tmpRes+7] = 16)
                       or (buffer[tmpRes+7] = 24)
                       or (buffer[tmpRes+7] = 32) )
                    and (buffer[tmpRes+8] = 0)
                    and (buffer[tmpRes+9] = 0)
                    and (buffer[tmpRes+10] = 0)
                    and (buffer[tmpRes+11] = 0)
                    and ( (buffer[tmpRes+12] <> 0)
                       or (buffer[tmpRes+13] <> 0) )
                    and ( (buffer[tmpRes+14] <> 0)
                       or (buffer[tmpRes+15] <> 0) )
                    and ( (buffer[tmpRes+16] = 8)
                       or (buffer[tmpRes+16] = 16)
                       or (buffer[tmpRes+16] = 24)
                       or (buffer[tmpRes+16] = 32) )
                    then
                    begin
                      // Add found offset to the list
                      result.Add(tmpRes);
                      // Next searchable offset is 17 bytes after the one found
                      inc(tmpRes,17);
                    end
                    else
                      inc(tmpRes, 1);
                  end;
                end;
              end;
        // TGA RGB search by Psych0phobiA -- End //
      else
        tmpRes := -1; // bad formatid
        dup5Main.writeLogVerbose(1,DLNGStr('ERR200'));
        dup5Main.colorLogVerbose(1,clRed);
      end;

    end;

//  finally
//    FreeAndNil(memBuf);
//  end;
end;

function THRipSearch.EBMLElement(inStm: TStream; var eId, numBytes: int64): int64;
var mask, maskIndex1, maskIndex2, tByte, numBytes1, numBytes2: byte;
    Size: int64;
begin

  mask := 128;
  inStm.ReadBuffer(tByte,1);
  inStm.position := inStm.position-1;
  numBytes := 0;
  eId := 0;

  for maskIndex1:=0 to 7 do
  begin
    if (tByte and (mask shr maskIndex1)) > 0 then
    begin
      numBytes1 := maskIndex1 + 1;
      eId := 0;
      inStm.ReadBuffer(eId,numBytes1);
      Inc(numBytes,numBytes1);
      inStm.ReadBuffer(tByte,1);
      inStm.position := inStm.position-1;
      for maskIndex2:=0 to 7 do
      begin
        if (tByte and (mask shr maskIndex2)) > 0 then
        begin
          numBytes2 := maskIndex2 + 1;
          Size := 0;
          inStm.ReadBuffer(Size,numBytes2);
          Size := SwapBytes64(Size,numBytes2);
          Inc(numBytes,numBytes2);
          Case numBytes2 of
            1: Size := (Size shr 56) AND 127;
            2: Size := (Size shr 48) AND 16383;
            3: Size := (Size shr 40) AND 2097151;
            4: Size := (Size shr 32) AND 268435455;
            5: Size := (Size shr 24) AND 34359738367;
            6: Size := (Size shr 16) AND 4398046511103;
            7: Size := (Size shr 8) AND 562949953421311;
            8: Size := Size AND 72057594037927935;
          end;
          break;
        end;
      end;
      break;
    end;
  end;

  result := Size;

end;

function THRipSearch.ArrayToString(const a: array of Char): string;
begin
  if Length(a)>0 then
//    SetString(Result, PChar(@a[0]), Length(a))
    Result := a
  else
    Result := '';
end;

function THRipSearch.verifyInStream(formatid: integer; inStm: TStream; offset: int64): FoundInfo64;
var buf1, buf2: array[1..4] of char;
    buf3: array[1..3] of char;
    jmark: array[1..2] of char;
    tByte, tByte2: byte;
    tWord: word;
    tInteger, x, y, curH, curW, minSize: integer;
    tChars: array[0..7] of char;
    tBytes4, tBytes4a: array[0..3] of byte;
    tBytes7: array[0..6] of byte;
    size, size2, offset2, COffset, CSize, tInt64: int64;
    BMPH: BMPHeader;
    EMFH: EnhancedMetaHeader;
    F669H: F669Header;
    F669S: F669Sample;
    GIFH: GIFHeader;
    GIFI: GIFImageDescriptor;
    MIDC: MIDIChunk;
    MIDH: MIDIHeader;
    MPTSAH: MPTSAtomHeader;
    OGGH: OGGHeader;
    VOCH: VOCHeader;
    WMFP: PlaceableMetaHeader;
    WMFH: WindowsMetaHeader;
    XMH: XMHeader;
    XMI: XMInstrument;
    XMIH: XMInstrumentHeader;
    XMP: XMPattern;
    XMSH: XMSampleHeader;
    good: boolean;
    totSize: int64;

    MP3Ver: byte;
    MP3Layer: byte;
//    MP3CRC: byte;
    MP3Padding: byte;
    MP3Rate: longword;
    MP3BitRate: longword;
    MP3FrameLen: longword;
    MP3Frames: longword;
    MPEGa: MPEGoptions;
    VBRFlags: longword;
    VBRNumFrames: longword;
    VBRFileSize: longword;
    OGGPageLen: longword;

    // ADTS / AAC
    ADTSProtection: boolean;
    ADTSMPEGVersion: byte;
    ADTSAACObjectType: byte;
    ADTSMP4SamplingFreq: byte;
    ADTSMP4ChannelConf: byte;
    ADTSFrameLen, TempFrameLen: word;
    ADTSFrames: longword;
    mdatfound: boolean;

    lastOffset: int64;

    JPGH: JPEG_APP0;
    PBuf: PByteArray;
    bufSize: longword;
    JPEGResult: integer;

    FLICH: FLIC_Header;

    S3MH: S3MHeader;
    S3MS: S3MSample;

    ITH: ITHeader;
    ITS: ITSample;
    MaxPointer: longword;

    DDSH: DDSHeader;

    mustBeStart: boolean;

    // TGA RGB searchFile by Psych0phobiA -- Start //
    TGAH: TGAHeader;
    TGAF: TGAFooter;
    // TGA RGB searchFile by Psych0phobiA -- End //

    szFind: array [0..255] of char;

    jpeglen: JPEGLength;
    jpeglencnv: int64;

    lastDisplayTime: TDateTime;

    firstDisplay: boolean;

    buffer: PByteArray;
    curPos: int64;

    curMP3result: string;

    elementID, elementSize, numBytes: int64;
    EBMLVersion, EBMLReadVersion, EBMLMaxIdLength, EBMLMaxSizeLength, EBMLDocTypeVersion, EBMLDocTypeReadVersion, EBMLHeaderSize: int64;
    EBMLDocType: String;

begin

  TotSize := inStm.Size;

  result.Offset := -1;
  result.Size := -1;
  result.Ext := '';
  result.GenType := HR_TYPE_ERROR;

  Application.ProcessMessages;

 try
  case formatid of
    1000: begin
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(buf1,4);
            inStm.ReadBuffer(Size,4);
            inStm.ReadBuffer(buf2,4);
            if (buf1 = 'RIFF') and (buf2 = 'WAVE') and ((Offset + Size + 8) <= TotSize) then
            begin
                result.Offset := offset;
                result.Size := Size+8;
                result.Ext := 'wav';
                result.GenType := HR_TYPE_AUDIO;
            end;
          end;
    1001: begin
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(VOCH,SizeOf(VOCHeader));
            if (VOCH.ID = 'Creative Voice File') and (VOCH.EOF = 26) then
            begin
              Size := VOCH.BlockOffset;
              COffset := VOCH.BlockOffset;
              COffset := COffset + Offset;
              while (true) do
              begin
                inStm.Seek(COffset,soBeginning);
                inStm.ReadBuffer(tByte,1);
                if TByte = 0 then
                  Break;
                inStm.ReadBuffer(tWord,2);
                inStm.ReadBuffer(tByte,1);
                CSize := tWord + ($10000 * tByte);
                Inc(COffset,CSize+4);
                Inc(Size,CSize+4);
              end;

              if ((Offset + Size) <= TotSize) then
              begin
                result.Offset := offset;
                result.Size := Size;
                result.Ext := 'voc';
                result.GenType := HR_TYPE_AUDIO;
              end;
            end;
          end;
    1002: begin
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(MIDC,SizeOf(MIDIChunk));
            if (MIDC.ID = 'MThd') and (BigToLittle4(MIDC.Size) = 6) then
            begin
              inStm.ReadBuffer(MIDH,SizeOf(MIDIHeader));
              tInteger := BigToLittle2(MIDH.NumTracks);
              if ((BigToLittle2(MIDH.FormatType) = 0) and (tInteger = 1))
              or ((BigToLittle2(MIDH.formatType) = 1) and (tInteger > 1))
              or ((BigToLittle2(MIDH.formatType) = 2) and (tInteger > 0))
              then
              begin
                size := 14;
                good := true;
                for x := 1 to tInteger do
                begin
                  inStm.ReadBuffer(MIDC,SizeOf(MIDIChunk));
                  if MIDC.ID <> 'MTrk' then
                  begin
                    good := false;
                    break;
                  end;
                  size := size + 8;
                  size2 := BigToLittle4(MIDC.Size);
                  size := size + size2;
                  inStm.Seek(offset+size,soBeginning);
                end;
                if good then
                begin
                  result.Offset := offset;
                  result.Size := Size;
                  result.Ext := 'mid';
                  result.GenType := HR_TYPE_AUDIO;
                end;
              end;
            end;
          end;
    1003..1004: begin
            totSize := inStm.Size;
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(F669H,SizeOf(F669Header));
            if ((F669H.ID = 'if') or (F669H.ID = 'JN'))
            and (F669H.NOS <= 64)
            and (F669H.NOP <= 128) then
            begin
              size := $1F1+F669H.NOS*$19+F669H.NOP*$600;
              good := true;
              for x := 1 to F669H.NOS do
              begin
                inStm.ReadBuffer(F669S,SizeOf(F669Sample));
                if F669S.length > (totSize - (offset+size)) then
                begin
                  good := false;
                  break;
                end;
                inc(size,F669S.length);
              end;
              if good then
              begin
                result.Offset := offset;
                result.Size := Size;
                result.Ext := '669';
                result.GenType := HR_TYPE_AUDIO;
              end;
            end;
          end;
    1005: begin
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(XMH,SizeOf(XMHeader));
            if (XMH.ID = 'Extended Module: ')
            and (XMH.EOF = $1A)
            and (XMH.NumIns <= 128)
            and (XMH.NumPat <= 256) then
            begin
              Size := XMH.HeaderSize + 60;
              for x:= 1 to XMH.NumPat do
              begin
                inStm.ReadBuffer(XMP,SizeOf(XMPattern));
                Inc(Size,XMP.HeaderLength+XMP.Size);
                inStm.Seek(Offset+Size,soBeginning);
              end;
              for x:= 1 to XMH.NumIns do
              begin
                inStm.ReadBuffer(XMIH,SizeOf(XMInstrumentHeader));
                Inc(Size,XMIH.Size);
                if XMIH.NumSamples > 0 then
                begin
                  inStm.ReadBuffer(XMI,SizeOf(XMInstrument));
                  inStm.Seek(Offset+Size,soBeginning);
                  for y := 1 to XMIH.NumSamples do
                  begin
                    inc(Size,XMI.SampleHeaderSize);
                    inStm.ReadBuffer(XMSH,SizeOf(XMSampleHeader));
                    Inc(size,XMSH.Length);
                    inStm.Seek(offset+size,soBeginning);
                  end;
                end;
                inStm.Seek(offset+size,soBeginning);
              end;
              if ((Offset + Size) <= TotSize) then
              begin
                result.Offset := offset;
                result.Size := Size;
                result.Ext := 'xm';
                result.GenType := HR_TYPE_AUDIO;
              end;
            end;
          end;
    1006: begin
            MPEGa := frmHyperRipper.formats.getMPEGOptions;
            totSize := inStm.Size;
            inStm.Seek(offset,soBeginning);
            Size := 0;
            MP3FrameLen := 0;
            MP3Frames := 0;
            MP3Layer := 0;
            lastOffset := Offset;
            lastDisplayTime := now;
            firstDisplay := true;
            curMP3Result := ReplaceValue('%e',ReplaceValue('%a',DLNGstr('HRLG08'),inttohex(Offset,8)),'mp3');
            repeat

              if (SecondsBetween(now,lastDisplayTime) >= 1) then
              begin
                hrip.Progress.Position := Round((inStm.Position / inStm.Size)*100);
                if firstDisplay then
                begin
                  hrip.addResult(ReplaceValue('%s',curMP3Result,inttostr(inStm.Position-Offset)));
                  firstDisplay := false;
                end
                else
                  hrip.lastResult(ReplaceValue('%s',curMP3Result,inttostr(inStm.Position-Offset)));
                lastDisplayTime := now;
                displayInfo(nil,inStm.Position,inStm.Size,false);
              end;

              inStm.ReadBuffer(tBytes4,4);
              if (tBytes4[0] = 255) and ((tBytes4[1] and 224) = 224) then
              begin

                // Version
                MP3Ver := tBytes4[1] And 24;
                case MP3Ver of
                  24: MP3Ver := 10;
                  16: MP3Ver := 20;
                   8: break;
                else
                  MP3Ver := 25;
                end;

                // Layer
                MP3Layer := tBytes4[1] and 6;
                case MP3Layer of
                   6: MP3Layer := 1;
                   4: MP3Layer := 2;
                   2: MP3Layer := 3;
                else
                  break;
                end;


                if (MPEGa.XingVBR) then
                begin
                  inStm.Seek(offset+36,soBeginning);
                  inStm.ReadBuffer(buf1,4);
                  if buf1 = 'Xing' then
                  begin
                    inStm.ReadBuffer(tBytes4a,4);
                    VBRFlags := BigToLittle4(tBytes4a);
                    inStm.ReadBuffer(tBytes4a,4);
                    VBRNumFrames := BigToLittle4(tBytes4a);
                    inStm.ReadBuffer(tBytes4a,4);
                    VBRFileSize := BigToLittle4(tBytes4a);

                    if (VBRFlags and MP_BYTES_FLAG) = MP_BYTES_FLAG then
                    begin
                      Size := VBRFileSize;
                      if (VBRFlags and MP_FRAMES_FLAG) = MP_FRAMES_FLAG then
                        MP3Frames := VBRNumFrames
                      else
                        MP3Frames := MPEGa.FramesMin;
                      break;
                    end;
                  end;
                end;

                // CRC
                //MP3CRC := tBytes4[1] and 1;

                // Padding
                MP3Padding := tBytes4[2] and 2;
                if MP3Padding = 2 then
                  MP3Padding := 1;

                MP3BitRate := tBytes4[2] And 240;
                MP3Rate := tBytes4[2] And 12;

                case MP3Ver of
                  10: begin
                        case MP3Rate of
                          0: MP3Rate := 44100;
                          4: MP3Rate := 48000;
                          8: MP3Rate := 32000;
                        else
                          break;
                        end;
                        case MP3Layer of
                          1: begin
                               if not(MPEGa.MP10_1) then
                                 break;
                               case MP3BitRate of
                                 16: MP3BitRate := 32;
                                 32: MP3BitRate := 64;
                                 48: MP3BitRate := 96;
                                 64: MP3BitRate := 128;
                                 80: MP3BitRate := 160;
                                 96: MP3BitRate := 192;
                                112: MP3BitRate := 224;
                                128: MP3BitRate := 256;
                                144: MP3BitRate := 288;
                                160: MP3BitRate := 320;
                                176: MP3BitRate := 352;
                                192: MP3BitRate := 384;
                                208: MP3BitRate := 416;
                                224: MP3BitRate := 448;
                               else
                                 break;
                               end;
                               MP3FrameLen := ((12000 * MP3BitRate) div MP3Rate + MP3Padding)*4;
                             end;
                          2: begin
                               if not(MPEGa.MP10_2) then
                                 break;
                               case MP3BitRate of
                                 16: MP3BitRate := 32;
                                 32: MP3BitRate := 48;
                                 48: MP3BitRate := 56;
                                 64: MP3BitRate := 64;
                                 80: MP3BitRate := 80;
                                 96: MP3BitRate := 96;
                                112: MP3BitRate := 112;
                                128: MP3BitRate := 128;
                                144: MP3BitRate := 160;
                                160: MP3BitRate := 192;
                                176: MP3BitRate := 224;
                                192: MP3BitRate := 256;
                                208: MP3BitRate := 320;
                                224: MP3BitRate := 384;
                               else
                                 break;
                               end;
                               MP3FrameLen := (144000 * MP3BitRate) div MP3Rate + MP3Padding;
                             end;
                          3: begin
                               if not(MPEGa.MP10_3) then
                                 break;
                               case MP3BitRate of
                                 16: MP3BitRate := 32;
                                 32: MP3BitRate := 40;
                                 48: MP3BitRate := 48;
                                 64: MP3BitRate := 56;
                                 80: MP3BitRate := 64;
                                 96: MP3BitRate := 80;
                                112: MP3BitRate := 96;
                                128: MP3BitRate := 112;
                                144: MP3BitRate := 128;
                                160: MP3BitRate := 160;
                                176: MP3BitRate := 192;
                                192: MP3BitRate := 224;
                                208: MP3BitRate := 256;
                                224: MP3BitRate := 320;
                               else
                                 break;
                               end;
                               MP3FrameLen := (144000 * MP3BitRate) div MP3Rate + MP3Padding;
                             end;
                          end;
                      end;
                  20, 25: begin
                        if MP3Ver = 20 then
                        begin
                          case MP3Rate of
                            0: MP3Rate := 22050;
                            4: MP3Rate := 24000;
                            8: MP3Rate := 16000;
                          else
                            break;
                          end;
                        end
                        else
                        begin
                          case MP3Rate of
                            0: MP3Rate := 11025;
                            4: MP3Rate := 12000;
                            8: MP3Rate := 8000;
                          else
                            break;
                          end;
                        end;

                        case MP3Layer of
                          1: begin
                               if (not(MPEGa.MP20_1) and (MP3Ver = 20))
                               or (not(MPEGa.MP25_1) and (MP3Ver = 25)) then
                                 break;
                               case MP3BitRate of
                                 16: MP3BitRate := 32;
                                 32: MP3BitRate := 48;
                                 48: MP3BitRate := 56;
                                 64: MP3BitRate := 64;
                                 80: MP3BitRate := 80;
                                 96: MP3BitRate := 96;
                                112: MP3BitRate := 112;
                                128: MP3BitRate := 128;
                                144: MP3BitRate := 144;
                                160: MP3BitRate := 160;
                                176: MP3BitRate := 176;
                                192: MP3BitRate := 192;
                                208: MP3BitRate := 224;
                                224: MP3BitRate := 256;
                               else
                                 break;
                               end;
                               MP3FrameLen := ((12000 * MP3BitRate) div MP3Rate + MP3Padding)*4;
                             end;
                        2,3: begin
                               if (not(MPEGa.MP20_2) and (MP3Ver = 20))
                               or (not(MPEGa.MP25_2) and (MP3Ver = 25))
                               or (not(MPEGa.MP20_3) and (MP3Ver = 20))
                               or (not(MPEGa.MP25_3) and (MP3Ver = 25)) then
                                 break;
                               case MP3BitRate of
                                 16: MP3BitRate := 8;
                                 32: MP3BitRate := 16;
                                 48: MP3BitRate := 24;
                                 64: MP3BitRate := 32;
                                 80: MP3BitRate := 40;
                                 96: MP3BitRate := 48;
                                112: MP3BitRate := 56;
                                128: MP3BitRate := 64;
                                144: MP3BitRate := 80;
                                160: MP3BitRate := 96;
                                176: MP3BitRate := 112;
                                192: MP3BitRate := 128;
                                208: MP3BitRate := 144;
                                224: MP3BitRate := 160;
                               else
                                 break;
                               end;
                               MP3FrameLen := (72000 * MP3BitRate) div MP3Rate + MP3Padding;
                             end;
                        end;


                  end;
                end;
                inc(Size,MP3FrameLen);
                if (Offset + Size) >= totSize then
                begin
                  Size := totSize - Offset;
                  break;
                end;
                if (lastOffset = (Offset+Size)) then
                  break;
                lastOffset := Offset+Size;
                inc(MP3Frames);
                if MP3Frames = 9790 then
                  MP3Frames := 9790;
                if MPEGa.LimitFramesMax and (MP3Frames = MPEGa.FramesMax) then
                  break;
                if MPEGa.LimitSizeMax and (Size >= MPEGa.SizeMax) then
                  break;
                inStm.Seek(Offset+Size,soBeginning);
              end
              else
                break;
            until cancel;

            if not(Cancel) and (Size > 0) then
            begin
              if ((MPEGa.LimitFramesMin and (MP3Frames >= MPEGa.FramesMin))
              or not(MPEGa.LimitFramesMin))
              and ((MPEGa.LimitSizeMin and (Size >= MPEGa.SizeMin))
              or not(MPEGa.LimitSizeMin)) then
              begin
                if MPEGa.ID3Tag then
                begin
                  inStm.Seek(offset+size,soBeginning);
                  if ((inStm.Size - (Offset+Size)) > 3) then
                  begin
                    inStm.ReadBuffer(buf3,3);
                    if buf3 = 'TAG' then
                      inc(Size,128);
                  end;
                end;
                result.Offset := offset;
                if Size > (inStm.Size - Offset) then
                  Size := inStm.Size - Offset;
                result.Size := Size;
                result.Ext := 'mp'+inttostr(MP3Layer);
                result.GenType := HR_TYPE_AUDIO;
                if firstDisplay then
                  hrip.addResult(ReplaceValue('%s',curMP3Result,inttostr(inStm.Position-Offset)));
              end
              else
              begin
                if Size > (inStm.Size - Offset) then
                  Size := inStm.Size - Offset;
                result.Size := Size;
                result.Offset := offset;
              end;
            end;

          end;
    1007: begin
            Dec(offset,44);
            if Offset >= 0 then
            begin
              totSize := inStm.Size;
              inStm.Seek(offset,soBeginning);
              inStm.ReadBuffer(S3MH,SizeOf(S3MHeader));

              CSize := 96+S3MH.OrdNum;
              Size := 96 + S3MH.OrdNum + S3MH.InsNum * 2 + S3MH.PatNum * 2;

              for x := 1 to S3MH.InsNum do
              begin
                inStm.Seek(offset+CSize,soBeginning);
                inStm.ReadBuffer(tWord,2);
                tInteger := tWord * 16;
                inStm.Seek(offset+tInteger,soBeginning);
                inStm.ReadBuffer(S3MS,SizeOf(S3MSample));
                if S3MS.T >= 2 then
                  Inc(Size,80)
                else
                begin
                  if (S3MS.Length mod 16) > 0 then
                    tInteger := ((S3MS.Length div 16)+1)*16
                  else
                    tInteger := S3MS.Length;
                  inc(Size,tInteger+80);
                end;
                inc(CSize,2);
              end;

              CSize := 96 + S3MH.OrdNum + 2 * S3MH.InsNum;
              for x := 1 to S3MH.PatNum do
              begin
                inStm.Seek(Offset+CSize,soBeginning);
                inStm.ReadBuffer(tWord,2);
                if tWord > 0 then
                begin
                  tInteger := tWord * 16;
                  inStm.Seek(Offset+tInteger,soBeginning);
                  inStm.ReadBuffer(tWord,2);
                  if (tWord mod 16) > 0 then
                    tInteger := ((tWord div 16)+1)*16
                  else
                    tInteger := tWord;
                  inc(Size,tInteger+2);
                end;
                inc(CSize,2);
              end;

              if (offset+size>totSize) then
                size := totSize - offset;

              result.Offset := offset;
              result.Size := Size;
              result.Ext := 's3m';
              result.GenType := HR_TYPE_AUDIO;
            end;
          end;
    1008: begin
            totSize := inStm.Size;
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(ITH,SizeOf(ITHeader));
            Size := 192 + ITH.OrdNum + ITH.InsNum * 4;
            MaxPointer := 0;
            CSize := 0;
            for x := 1 to ITH.SmpNum do
            begin
              inStm.Seek(offset+size,soBeginning);
              inStm.ReadBuffer(tInteger,4);
              inStm.Seek(offset+tInteger,soBeginning);
              inStm.ReadBuffer(ITS,SizeOf(ITSample));
              if (ITS.SamplePointer > MaxPointer) then
              begin
                MaxPointer := ITS.SamplePointer;
                CSize := ITS.Length;
              end;
              Inc(size,4);
            end;
            Size := MaxPointer + CSize;

            if (offset+size>totSize) then
              size := totSize - offset;

            result.Offset := offset;
            result.Size := Size;
            result.Ext := 'it';
            result.GenType := HR_TYPE_AUDIO;
          end;
    1009: begin
            inStm.Seek(offset,soBeginning);
            Size := 0;
            mustBeStart := true;
            repeat
              inStm.Read(OggH,SizeOf(OGGHeader));
              if (OggH.ID = 'OggS') and (OggH.Revision = 0) then
              begin
                if (mustBeStart and ((OggH.BitFlags and 2) = 2))
                or (not(MustBeStart) and ((OggH.BitFlags and 2) = 0)) then
                begin
                  OGGPageLen := 0;
                  for x := 1 to OggH.NumPageSegments do
                  begin
                    inStm.ReadBuffer(tbyte,1);
                    inc(OGGPageLen,tbyte);
                  end;
                  inc(Size,OGGPageLen+sizeof(OGGHeader)+OggH.NumPageSegments);
                  if ((OggH.BitFlags and 4) = 4) then
                    break;
                  inStm.Seek(Offset+Size,soBeginning);
                  mustBeStart := false;
                end
                else
                  break;
              end
              else
                break;
            until (false);

            if (Size > 0) and ((Offset + Size) <= Totsize) then
            begin
              result.Offset := offset;
              result.Size := Size;
              result.Ext := 'ogg';
              result.GenType := HR_TYPE_AUDIO;
            end;

          end;
    1010: begin
            MPEGa := frmHyperRipper.formats.getMPEGOptions;
            totSize := inStm.Size;
            inStm.Seek(offset,soBeginning);
            Size := 0;
            MP3FrameLen := 0;
            MP3Frames := 0;
            MP3Layer := 0;
            lastOffset := Offset;
            lastDisplayTime := now;
            firstDisplay := true;
            curMP3Result := ReplaceValue('%e',ReplaceValue('%a',DLNGstr('HRLG08'),inttohex(Offset,8)),'aac');
            repeat

              if (SecondsBetween(now,lastDisplayTime) >= 1) then
              begin
                hrip.Progress.Position := Round((inStm.Position / inStm.Size)*100);
                if firstDisplay then
                begin
                  hrip.addResult(ReplaceValue('%s',curMP3Result,inttostr(inStm.Position-Offset)));
                  firstDisplay := false;
                end
                else
                  hrip.lastResult(ReplaceValue('%s',curMP3Result,inttostr(inStm.Position-Offset)));
                lastDisplayTime := now;
                displayInfo(nil,inStm.Position,inStm.Size,false);
              end;

              inStm.ReadBuffer(tBytes7,7);
              if (tBytes7[0] = 255) and ((tBytes7[1] and 240) = 240) and ((tBytes7[1] and 6) = 0) and ((tBytes7[2] and 2) = 0) and ((tBytes7[3] and 60) = 0) and ((tBytes7[5] and 31) = 31) and ((tBytes7[6] and 252) = 252) and ((tBytes7[6] and 3) = 0) then
              begin

                // Version
                if (tBytes7[1] And 8) = 0 then
                  ADTSMPEGVersion := 4
                else
                  ADTSMPEGVersion := 2;

                // Protection Absent
                ADTSProtection := (tBytes7[1] And 1) = 0;

                // MPEG-4 Audio Object Types (AAC)
                // 0: AAC Main
                // 1: AAC LC (Low Complexity)
                // 2: AAC SSR (Scalable Sample Rate)
                // 3: AAC LTP (Long Term Prediction)
                ADTSAACObjectType := (tBytes7[2] And 192) shr 6;

                // Sampling Frequency Index
                // Value of 15 not possible
                ADTSMP4SamplingFreq := (tBytes7[2] And 60) shr 2;

                // Channel configuration
                ADTSMP4ChannelConf := ((tBytes7[2] And 1) shl 2) or ((tBytes7[3] And 192) shr 6);

                ADTSFrameLen := (tBytes7[3] And 3);
                ADTSFrameLen := ADTSFrameLen shl 11;
                TempFrameLen := tBytes7[4];
                TempFrameLen := TempFrameLen shl 3;
                ADTSFrameLen := ADTSFrameLen or TempFrameLen or ((tBytes7[5] and 224) shr 5);

                inc(Size,ADTSFrameLen);
                if (Offset + Size) >= totSize then
                begin
                  Size := totSize - Offset;
                  break;
                end;
                if (lastOffset = (Offset+Size)) then
                  break;
                lastOffset := Offset+Size;
                inc(ADTSFrames);
                if MPEGa.LimitFramesMax and (ADTSFrames = MPEGa.FramesMax) then
                  break;
                if MPEGa.LimitSizeMax and (Size >= MPEGa.SizeMax) then
                  break;
                inStm.Seek(Offset+Size,soBeginning);
              end
              else
                break;
            until cancel;

            if not(Cancel) and (Size > 0) then
            begin
              if ((MPEGa.LimitFramesMin and (ADTSFrames >= MPEGa.FramesMin))
              or not(MPEGa.LimitFramesMin))
              and ((MPEGa.LimitSizeMin and (Size >= MPEGa.SizeMin))
              or not(MPEGa.LimitSizeMin)) then
              begin
                result.Offset := offset;
                if Size > (inStm.Size - Offset) then
                  Size := inStm.Size - Offset;
                result.Size := Size;
                result.Ext := 'aac';
                result.GenType := HR_TYPE_AUDIO;
                if firstDisplay then
                  hrip.addResult(ReplaceValue('%s',curMP3Result,inttostr(inStm.Position-Offset)));
              end
              else
              begin
                if Size > (inStm.Size - Offset) then
                  Size := inStm.Size - Offset;
                result.Size := Size;
                result.Offset := offset;
              end;
            end;

          end;
    1011, 2004: begin
            Size := 0;
            mustBeStart := true;
            mdatfound := false;
            repeat
              inStm.Seek(offset+size,soBeginning);
              inStm.Read(MPTSAH,SizeOf(MPTSAtomHeader));
              MPTSAH.size := SwapBytes(MPTSAH.size);
              if ((Offset+MPTSAH.size) <= TotSize) then
              begin
                if mustBeStart then
                begin
                  if MPTSAH.atomtype = 'ftyp' then
                  begin
                    mustBeStart := false;
                    inc(Size,MPTSAH.size);
                  end
                  else
                    break;
                end
                else
                begin
                  mdatfound := mdatfound or (MPTSAH.atomtype = 'mdat');
                  if (MPTSAH.atomtype = 'free') or (MPTSAH.atomtype = 'skip') or (MPTSAH.atomtype = 'wide') or (MPTSAH.atomtype = 'mdat') or (MPTSAH.atomtype = 'moov') then
                    inc(Size,MPTSAH.size)
                  else
                    break;
                end;
              end
              else
                break;
            until (false);

            if (Size > 0) and ((Offset + Size) <= Totsize) and mdatfound then
            begin
              result.Offset := offset;
              result.Size := Size;
              result.Ext := 'm4a';
              result.GenType := HR_TYPE_AUDIO;
            end;

          end;

    2000: begin
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(buf1,4);
            inStm.ReadBuffer(Size,4);
            inStm.ReadBuffer(buf2,4);
            if (buf1 = 'RIFF') and (buf2 = 'AVI ') and ((Offset + Size + 8) <= Totsize) then
            begin
                result.Offset := offset;
                result.Size := Size+8;
                result.Ext := 'avi';
                result.GenType := HR_TYPE_VIDEO;
            end;
          end;
    2001: begin
            if (Offset-4)>=0 then
            begin
              Dec(Offset,4);
              totSize := inStm.Size;
              inStm.Seek(offset+Size,soBeginning);
              inStm.ReadBuffer(tBytes4,4);
              inStm.ReadBuffer(buf1,4);
              if (buf1 = 'moov') then
              begin
                Size := BigToLittle4(tBytes4);
                if (offset+Size+8)<=TotSize then
                begin
                  repeat
                    inStm.Seek(offset+size,soBeginning);
                    inStm.ReadBuffer(tBytes4,4);
                    inStm.ReadBuffer(buf1,4);
                    Inc(Size,BigToLittle4(tBytes4));
                  until (buf1 = 'mdat') or ((Offset+Size+8) >= totSize);
                  result.Offset := offset;
                  result.Size := Size;
                  result.Ext := 'mov';
                  result.GenType := HR_TYPE_VIDEO;
                end;
              end;
            end;
          end;
    2002: begin
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(buf1,4);
            inStm.ReadBuffer(Size,4);
            // Bug 1914923: Sanity check for BIK files (check that the size is not bigger than the source data file!)
            // Bug 59: With correct parenthesis it is better...
            if ((buf1 = 'BIKf') or (buf1 = 'BIKi')) and ((Offset + Size + 8) <= Totsize) then
            begin
                result.Offset := offset;
                result.Size := Size+8;
                result.Ext := 'bik';
                result.GenType := HR_TYPE_VIDEO;
            end;
          end;
    2003: begin
            totSize := inStm.Size ;
            Dec(offset,4);
            if (offset >= 0) then
            begin
              inStm.Seek(offset,soBeginning);
              inStm.ReadBuffer(FLICH,SizeOf(FLIC_Header));
              if (FLICH.Flags = 0) and (Offset+FLICH.Size <= totSize) then
              begin
                case FLICH.Magic of
                  $AF11: result.Ext := 'fli';
                  $AF12,$AF30,$AF44: result.Ext := 'flc';
                end;
                if (result.Ext = 'fli') or (result.ext = 'flc') and ((Offset + FLICH.Size) <= Totsize) then
                begin
                  result.Offset := offset;
                  result.Size := FLICH.Size;
                  result.GenType := HR_TYPE_VIDEO;
                end;
              end;
            end;
          end;
    2005: begin
            totSize := inStm.Size ;
            inStm.Seek(offset,soBeginning);
            Size := 0;
            EBMLHeaderSize := EBMLElement(inStm,elementId,numBytes);
            Inc(EBMLHeaderSize,numBytes);
            Inc(Size,EBMLHeaderSize);
            EBMLVersion := 0;
            EBMLReadVersion := 0;
            EBMLMaxIDLength := 0;
            EBMLMaxSizeLength := 0;
            FillChar(tChars,8,0);
            EBMLDocType := '';
            if (elementId = 2749318426) then // This is an EBML Header
            begin
              repeat
                CSize := EBMLElement(inStm,elementId,numBytes);
                Case elementId of
                  33346: begin  // DocType
                           inStm.ReadBuffer(tChars,CSize);
                           EBMLDocType := ArrayToString(tChars);
                         end;
                  34370: begin  // EBMLVersion
                           inStm.ReadBuffer(EBMLVersion,CSize);
                         end;
                  62018: begin  // EBMLMaxIDLength
                           inStm.ReadBuffer(EBMLMaxIDLength,CSize);
                         end;
                  62274: begin  // EBMLMaxSizeLength
                           inStm.ReadBuffer(EBMLMaxSizeLength,CSize);
                         end;
                  63298: begin  // EBMLReadVersion
                           inStm.ReadBuffer(EBMLReadVersion,CSize);
                         end;
                else
                  inStm.Position := inStm.Position+CSize;
                end;
              until (inStm.position>=(offset+EBMLHeaderSize));
            end;
            if ((EBMLDocType = 'matroska') or (EBMLDocType = 'webm')) then
            begin
              CSize := EBMLElement(inStm,elementId,numBytes);
              Inc(Size,CSize);
              Inc(Size,numBytes);
              if (elementId = 1736463128) then // This is an Matroska Segment
              begin
                result.Offset := offset;
                result.Size := Size;
                if (EBMLDocType = 'matroska') then
                  result.Ext := 'mkv'
                else
                  result.Ext := 'webm';
                result.GenType := HR_TYPE_VIDEO;
              end;
            end;
          end;

    3000: begin
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(BMPH,SizeOf(BMPHeader));
            if (BMPH.ID = 'BM') and (BMPH.ID2 = 40) and (BMPH.Size > 14) and ((Offset + BMPH.Size) <= Totsize) then
            begin
                result.Offset := offset;
                result.Size := BMPH.Size;
                result.Ext := 'bmp';
                result.GenType := HR_TYPE_IMAGE;
            end;
          end;
    3001: begin
            Dec(offset,40);
            if (offset >= 0) then
            begin
              inStm.Seek(offset,soBeginning);
              inStm.ReadBuffer(EMFH,SizeOf(EnhancedMetaHeader));
              if (EMFH.Signature = ' EMF') and (EMFH.RecordType = 1) and (EMFH.Reserved = 0) and ((Offset + EMFH.Size) <= Totsize) then
              begin
                  result.Offset := offset;
                  result.Size := EMFH.Size;
                  result.Ext := 'emf';
                  result.GenType := HR_TYPE_IMAGE;
              end;
            end;
          end;
    3002: begin
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(WMFP,SizeOf(PlaceableMetaHeader));
            inStm.ReadBuffer(WMFH,SizeOf(WindowsMetaHeader));
            if ((WMFH.FileType = 1) or (WMFH.FileType = 0))
            and (WMFP.Key = $D7CDC69A)
            and (WMFH.HeaderSize = 9) and (WMFH.NumOfParams = 0)
            and (WMFP.Handle = 0) and (WMFP.Reserved = 0)
            and ((Offset + WMFH.FileSize*2 + 44) <= Totsize) then
            begin
                result.Offset := offset;
                result.Size := WMFH.FileSize*2+44;
                result.Ext := 'wmf';
                result.GenType := HR_TYPE_IMAGE;
            end;
          end;
    3003: begin
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(tChars,8);
            Offset2 := offset + 8;
            if (tChars = #137 + 'PNG' + #13 + #10 + #26 + #10) then
            begin
              repeat
                inStm.Seek(offset2,soBeginning);
                inStm.ReadBuffer(tBytes4,4);
                CSize := BigToLittle4(tBytes4);
                inStm.ReadBuffer(buf2,4);
                inc(offset2,CSize+12);
              until (buf2 = 'IEND');

              size := Offset2 - Offset;

              result.Offset := offset;
              result.Size := size;
              result.Ext := 'png';
              result.GenType := HR_TYPE_IMAGE;
            end;
          end;
    3004: begin
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(GIFH,SizeOf(GIFHeader));
            if ((GIFH.Version = '87a') or (GIFH.Version = '89a'))
            and ((GIFH.Flags and $8) = 0)
            and (GIFH.Padding = 0) then
            begin
              Size := SizeOf(GIFHeader);
              if (GIFH.Flags and $80) > 0 then
              begin
                tByte := (GIFH.Flags and $7) + 1;
                Inc(Size,(Trunc(power(2,tByte))*3));
              end;
              repeat
                inStm.Seek(offset+size,soBeginning);
                inStm.ReadBuffer(tByte,1);
                inc(Size);
                case tbyte of
                  44: { , }
                      begin
                        inStm.ReadBuffer(GIFI,SizeOf(GIFImageDescriptor));
                        Inc(Size,SizeOf(GIFImageDescriptor)+1);
                        if (GIFI.Flags and $80) > 0 then
                        begin
                          tByte2 := (GIFI.Flags and 7) + 1;
                          Inc(Size,(Trunc(power(2,tByte2))*3));
                        end;

                        inStm.Seek(offset+size,soBeginning);
                        repeat
                          inStm.ReadBuffer(tByte2,1);
                          inc(size,tByte2+1);
                          inStm.Seek(offset+size,soBeginning);
                        until (tByte2 = 0);
                      end;
                  33: { ! }
                      begin
                        inc(Size);

                        inStm.Seek(offset+size,soBeginning);
                        repeat
                          inStm.ReadBuffer(tByte2,1);
                          inc(size,tByte2+1);
                          inStm.Seek(offset+size,soBeginning);
                        until (tByte2 = 0);
                      end;
                end;
              until (tByte = 59);

              result.Offset := offset;
              result.Size := size;
              result.Ext := 'gif';
              result.GenType := HR_TYPE_IMAGE;
            end;
          end;
    3005: begin
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(buf1,4);
            inStm.ReadBuffer(tBytes4,4);
            inStm.ReadBuffer(buf2,4);
            if (buf1 = 'FORM') and (buf2 = 'ILBM') and ((Offset + BigToLittle4(tBytes4)+8) <= Totsize) then
            begin
                result.Offset := offset;
                result.Size := BigToLittle4(tBytes4)+8;
                result.Ext := 'lbm';
                result.GenType := HR_TYPE_IMAGE;
            end;
          end;
    3006: begin
            totSize := inStm.Size;
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(jmark,2);
            Size := 2;
            if (jmark = #255+#216) then
            begin
              inStm.ReadBuffer(jmark,2);
              inc(Size,2);
              while (jmark <> #255+#217) do
              begin
                inStm.ReadBuffer(jpeglen,2);
                jpeglencnv := BigToLittle2(jpeglen);
                inc(Size,jpeglencnv);
                inStm.Seek(Offset+Size,soBeginning);
                inStm.ReadBuffer(jmark,2);
                inc(Size,2);
                if (jmark[1] <> #255) then
                begin
                  GetMem(PBuf,16384);
                  try
                    strPCopy(szFind,#255+#217);
                    while (offset+Size < totSize) do
                    begin
                      inStm.Seek(offset+size,soBeginning);
                      if (totSize-(offset+Size) < 16384) then
                        bufsize := totSize-offset-size
                      else
                        bufsize := 16384;
                      inStm.ReadBuffer(PBuf^,bufsize);
                      JPEGResult := BMFind(szFind,PBuf,bufSize);
                      if (JPEGResult > -1) then
                      begin
                        Inc(Size,JPEGResult+2);
                        break;
                      end
                      else
                        dec(bufsize);

                      inc(size,bufsize);

                      if (Offset+Size+1 >= totSize) then
                        break;

                    end;
                  finally
                    FreeMem(PBuf);
                  end;


                  break;
                end;
              end;
              result.Offset := offset;
              result.Size := Size;
              result.Ext := 'jpg';
              result.GenType := HR_TYPE_IMAGE;
            end;
          end;
    3007: begin
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(DDSH,SizeOf(DDSHeader));
            if (DDSH.ID = 'DDS ') and (DDSH.SurfaceDesc.dwSize = 124) and (DDSH.SurfaceDesc.ddpfPixelFormat.dwSize = 32) then
              if (DDSH.SurfaceDesc.dwFlags AND DDSD_LINEARSIZE) = DDSD_LINEARSIZE then
              begin
                Size := SizeOf(DDSHeader)+DDSH.SurfaceDesc.dwPitchOrLinearSize;
                if (leftstr(DDSH.SurfaceDesc.ddpfPixelFormat.dwFourCC,3) = 'DXT') or (leftstr(DDSH.SurfaceDesc.ddpfPixelFormat.dwFourCC,3) = 'ATI') then
                begin
                  if DDSH.SurfaceDesc.ddpfPixelFormat.dwFourCC[3] = '1' then
                    MinSize := 8
                  else
                    MinSize := 16;
                end
                else
                  MinSize := 0;
                CurH := DDSH.SurfaceDesc.dwPitchOrLinearSize;
                for x := 1 to DDSH.SurfaceDesc.dwMipMapCount-1 do
                begin
                  CurH := CurH div 4;
                  Inc(Size,Max(MinSize,CurH));
                end;
                result.Offset := offset;
                result.Size := Size;
                result.Ext := 'dds';
                result.GenType := HR_TYPE_IMAGE;
              end
              else if (DDSH.SurfaceDesc.dwFlags AND DDSD_PITCH) = DDSD_PITCH then
              begin
                Size := SizeOf(DDSHeader)+DDSH.SurfaceDesc.dwPitchOrLinearSize*DDSH.SurfaceDesc.dwHeight;
                CurH := DDSH.SurfaceDesc.dwPitchOrLinearSize*DDSH.SurfaceDesc.dwHeight;
                for x := 1 to DDSH.SurfaceDesc.dwMipMapCount-1 do
                begin
                  CurH := CurH div 4;
                  Inc(Size,Max(MinSize,CurH));
                end;
                result.Offset := offset;
                result.Size := Size;
                result.Ext := 'dds';
                result.GenType := HR_TYPE_IMAGE;
              end;
          end;
    // TGA RGB searchFile by Psych0phobiA -- Start //
    3008: begin
            inStm.Seek(offset,soBeginning);
            inStm.ReadBuffer(TGAH,SizeOf(TGAHeader));
            //Sanity check --
            //Next values represent the largest valid screen dimensions
            if (TGAH.Width <= 2560) and
               (TGAH.Height <= 2048) then
            begin
                Size := TGAH.Width * TGAH.Height * TGAH.Bits div 8;
                inStm.Seek(offset+size,soBeginning);
                inStm.ReadBuffer(TGAF,SizeOf(TGAFooter));
                if (TGAF.Signature = 'TRUEVISION-XFILE')
                and (TGAF.Dot = '.')
                and (TGAF.NullTerminator = 0) then
                  Inc(Size,Sizeof(TGAFooter));
                result.Offset := offset;
                result.Size := Size + SizeOf(TGAHeader);
                result.Ext := 'tga';
                result.GenType := HR_TYPE_IMAGE;
            end;
          end;
    // TGA RGB searchFile by Psych0phobiA -- End //

  else
    result.Offset := -1;
    result.Size := -1;
    result.Ext := '';
    result.GenType := HR_TYPE_ERROR;
  end;

 except

   on e: EReadError do
   begin
     result.Offset := -1;
     result.Size := -1;
     result.Ext := '';
     result.GenType := HR_TYPE_ERROR;
   end;

 end;

end;

procedure TfrmHyperRipper.FormCreate(Sender: TObject);
var List: ExtSearchFormatsList;
    itemx : TListItem;
    x : integer;
    cformat: PFormatListElem;
begin

  formats := THyperRipperFormat.Create;

  List := formats.GetFormatsList;

//  lblNumPlugs.Caption := inttostr(HPlug.NumPlugins);
  lblNumFormats.Caption := inttostr(List.NumFormats);
  lblHRVersion.Caption := getHRVersion(HR_VERSION);
  lblHRVersionShadow.Caption := lblHRVersion.Caption;
  frmHyperRipper.Caption := 'HyperRipper v'+lblHRVersion.Caption;

  lstFormats.Items.Clear;

  for x:=0 to List.NumFormats-1 do
  begin
    itemx := lstFormats.Items.Add;
    itemx.Caption := List.FormatsList[x].Format;
    case List.FormatsList[x].GenType of
      HR_TYPE_AUDIO: itemx.SubItems.Add (DLNGstr('HRTYP1'));
      HR_TYPE_VIDEO: itemx.SubItems.Add (DLNGstr('HRTYP2'));
      HR_TYPE_IMAGE: itemx.SubItems.Add (DLNGstr('HRTYP3'));
      HR_TYPE_OTHER: itemx.SubItems.Add (DLNGstr('HRTYPM'));
      HR_TYPE_UNKNOWN: itemx.SubItems.Add (DLNGstr('HRTYP0'));
    else
      itemx.SubItems.Add (ReplaceValue('%i',DLNGstr('HRTYPE'),inttostr(List.FormatsList[x].GenType)));
    end;
    itemx.SubItems.Add (List.FormatsList[x].Desc);
    if List.FormatsList[x].FalsePositives then
      itemx.ImageIndex := 0
    else
      itemx.ImageIndex := -1;
    GetMem(cformat,SizeOf(List.FormatsList[x]));
    cformat^.GenType := List.FormatsList[x].GenType;
    cformat^.ID := List.FormatsList[x].ID;
    cformat^.IsConfig := List.FormatsList[x].IsConfig;
    cformat^.FalsePositives := List.FormatsList[x].FalsePositives;
    itemx.Data := cformat;
  end;

end;

procedure TfrmHyperRipper.FormDestroy(Sender: TObject);
var x: integer;
    cformat: PFormatListElem;
begin

  FreeAndNil(formats);
  for x := 0 to lstFormats.Items.Count-1 do
  begin
    cformat := lstFormats.Items.Item[x].Data;
    FreeMem(cformat);
  end;

end;


procedure THyperRipperFormat.showConfigBox(formatid: integer);
var frmMpa: TfrmOptMPEGa;
    OApp: THandle;
begin

  if (formatid = 1006) or (formatid = 1010) then
  begin
            frmMpa := TfrmOptMPEGa.Create(frmHyperRipper);
            try
              with frmMpa do
              begin
                lblVersion.Caption := 'HyperRipper v'+GetHRVersion(HR_VERSION);
                Caption := DLNGstr('HRD000');
                grp1.Caption := DLNGstr('HRD100');
                lblUnof.Caption := '('+DLNGstr('HRD101')+')';
                grp2.Caption := DLNGstr('HRD200');
                chkFramesMin.Caption := DLNGstr('HRD211');
                chkFramesMax.Caption := DLNGstr('HRD212');
                lblFrameMin.Caption := DLNGstr('HRD213');
                lblFrameMax.Caption := DLNGstr('HRD213');
                chkSizeMin.Caption := DLNGstr('HRD221');
                chkSizeMax.Caption := DLNGstr('HRD222');
                lblSizeMin.Caption := DLNGstr('HRD223');
                lblSizeMax.Caption := DLNGstr('HRD223');
                grp3.Caption := DLNGstr('HRD300');
                chkXingVBR.Caption := DLNGstr('HRD301');
                chkID3Tag.Caption := DLNGstr('HRD302');
                ShowModal;
              end;
            finally
              FreeAndNil(frmMpa);
            end;
  end;

end;


procedure TfrmHyperRipper.chkExcludeFalsePositiveClick(Sender: TObject);
var Reg: TRegistry;
    x: integer;
    cformat: PFormatListElem;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('ExcludeFalsePositive',chkExcludeFalsePositive.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

  if chkExcludeFalsePositive.Checked then
  begin

    for x := 0 to lstFormats.Items.Count-1 do
    begin
      cformat := lstFormats.Items.item[x].Data;
      if cformat.FalsePositives then
        lstFormats.Items.Item[x].Checked := false
    end;

  end;

end;

procedure TfrmHyperRipper.lstFormatsClick(Sender: TObject);
var x: integer;
    cformat: PFormatListElem;
begin

  if chkExcludeFalsePositive.Checked then
  begin

    for x := 0 to lstFormats.Items.Count-1 do
    begin
      cformat := lstFormats.Items.item[x].Data;
      if cformat.FalsePositives then
        lstFormats.Items.Item[x].Checked := false
    end;

  end;

end;

procedure TfrmHyperRipper.chkForceBufferSizeClick(Sender: TObject);
  var Reg: TRegistry;
begin

  if chkForceBufferSize.Checked then
    butBufferSizeCheckClick(Sender);

  lblBufferSize.Visible := chkForceBufferSize.Checked;
  butBufferSizeCheck.Visible := chkForceBufferSize.Checked;

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('ForceBufferSize',chkForceBufferSize.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmHyperRipper.butBufferSizeCheckClick(Sender: TObject);
var Reg: TRegistry;
    testRegType: TRegDataType;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      if Reg.ValueExists('BufferSize') and (Reg.GetDataType('BufferSize') = rdInteger) then
        chkForceBufferSize.Tag := Reg.ReadInteger('BufferSize')
      else
        chkForceBufferSize.Tag := 131072;
    end;
  finally
    FreeAndNil(Reg);
  end;

  if chkForceBufferSize.Tag < 32 then
    chkForceBufferSize.Tag := 32
  else if chkforceBufferSize.Tag > 33554432 then
    chkForceBufferSize.Tag := 33554432;

  if chkForceBufferSize.Tag < 1024 then
    lblBufferSize.Caption := StringReplace(DLNGStr('OPT033'),'%d',inttostr(chkForceBufferSize.Tag),[rfReplaceAll])
  else if chkForceBufferSize.Tag < 1048576 then
    lblBufferSize.Caption := StringReplace(DLNGStr('OPT034'),'%d',floattostr(round((chkForceBufferSize.Tag / 1024)*10)/10),[rfReplaceAll])
  else
    lblBufferSize.Caption := StringReplace(DLNGStr('OPT035'),'%d',floattostr(round((chkForceBufferSize.Tag / 1048576)*10)/10),[rfReplaceAll]);


end;

procedure TfrmHyperRipper.chkAutoCloseClick(Sender: TObject);
  var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('AutoClose',chkAutoClose.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

procedure TfrmHyperRipper.chkAutoStartClick(Sender: TObject);
  var Reg: TRegistry;
begin

  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Not(Reg.KeyExists('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper')) then
      Reg.CreateKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper');
    if Reg.OpenKey('\Software\Dragon Software\Dragon UnPACKer 5\HyperRipper',True) then
    begin
      Reg.WriteBool('AutoStart',chkAutoStart.Checked);
      Reg.CloseKey;
    end;
  Finally
    FreeAndNil(Reg);
  end;

end;

end.
