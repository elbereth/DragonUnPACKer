library hr_default;

uses
  Forms,
  Math,
//  JvJCLUtils,
  StrUtils,
  SysUtils,
  Registry,
  Windows,
  Classes,
  lib_version in '..\..\..\common\lib_version.pas',
  MpegAudioOptions in 'MpegAudioOptions.pas' {frmOptMPEGa};

{$E d5h}

{$R *.res}

const HR_TYPE_ERROR = -1;
      HR_TYPE_UNKNOWN = 0;
      HR_TYPE_AUDIO = 1;
      HR_TYPE_VIDEO = 2;
      HR_TYPE_IMAGE = 3;
      HR_TYPE_OTHER = 9999;

      MP_FRAMES_FLAG = 1;
      MP_BYTES_FLAG = 2;
      MP_TOC_FLAG = 4;
      MP_VBR_SCALE_FLAG = 8;

type FormatsListElem = record
       GenType: Integer;
       Format: ShortString;
       Desc: ShortString;
       ID: Integer;
       IsConfig: Boolean;
     end;
     SearchFormatsList = record
       NumFormats :  Byte;
       FormatsList : array[1..255] of FormatsListElem;
     end;
     FormatsListElemEx = record
       GenType: Integer;
       Format: ShortString;
       Desc: ShortString;
       ID: Integer;
       DriverNum: Integer;
     end;
     ExtSearchFormatsList = record
       NumFormats : Integer;
       FormatsList : array[1..1000] of FormatsListElemEx;
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

type
  TPercentCallback = procedure (p: byte);
  TLanguageCallback = function (lngid: ShortString): ShortString;
//     EBadType = class(Exception);

var Percent: TPercentCallback;
    DLNGStr: TLanguageCallback;
    CurPath: ShortString;
    AHandle: THandle;
    AOwner: TComponent;

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
  * }

const DRIVER_VERSION = 50240;
      HR_VERSION = 50043;

function BigToLittle2(src: array of byte): word;
begin
  result := src[1] + src[0]*$FF;
end;

function BigToLittle4(src: array of byte): integer;
begin
  result := src[3] + src[2]*$100 + src[1]*$10000 + src[0]*$1000000;
end;

function getMPEGOptions(): MPEGOptions;
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
    Reg.Free;
  end;

end;

function ReplaceValue(substr: string; str: string; newval: string): string;
var possub: integer;
    res: string;
begin

  possub := Pos(substr,str);
  if possub > 0 then
  begin
    res := Copy(str,0,possub-1) + Copy(str,possub+length(substr),length(str)-length(substr)+1);
    Insert(newval,res,possub);
  end;

  ReplaceValue := res;

end;

function DUHIVersion: Byte; stdcall;
begin
  Result := 3;
end;

function GetVersionInfo(): VersionInfo; stdcall;
begin

  result.Name := 'Elbereth''s HyperRipper 5 plugin';
  result.Version := DRIVER_VERSION;
  result.Author := 'Alexandre Devilliers (aka Elbereth)';
  result.Comment := 'Can search all file formats that were available in HyperRipper v4.2 (Dragon UnPACKer 4.22a).'+#10+'More reliable and efficient than HyperRipper 4.';

end;

function GetSearchFormats(): SearchFormatsList; stdcall;
var lngEXSND, lngEXIMG, lngEXVID: string;
begin

  lngEXSND := DLNGstr('HRTSND');
  lngEXIMG := DLNGstr('HRTIMG');
  lngEXVID := DLNGstr('HRTVID');

  result.NumFormats := 21;
  result.FormatsList[1].GenType := HR_TYPE_AUDIO;
  result.FormatsList[1].Format := 'WAVE';
  result.FormatsList[1].Desc := 'Wave/RIFF';
  result.FormatsList[1].ID := 1000;
  result.FormatsList[1].IsConfig := False;
  result.FormatsList[2].GenType := HR_TYPE_AUDIO;
  result.FormatsList[2].Format := 'VOC';
  result.FormatsList[2].Desc := 'Creative VOice';
  result.FormatsList[2].ID := 1001;
  result.FormatsList[2].IsConfig := False;
  result.FormatsList[3].GenType := HR_TYPE_AUDIO;
  result.FormatsList[3].Format := 'MIDI';
  result.FormatsList[3].Desc := 'MIDI';
  result.FormatsList[3].ID := 1002;
  result.FormatsList[3].IsConfig := False;
  result.FormatsList[4].GenType := HR_TYPE_AUDIO;
  result.FormatsList[4].Format := '669';
  result.FormatsList[4].Desc := '669';
  result.FormatsList[4].ID := 1003;
  result.FormatsList[4].IsConfig := False;
  result.FormatsList[5].GenType := HR_TYPE_AUDIO;
  result.FormatsList[5].Format := '669 EXT.';
  result.FormatsList[5].Desc := 'Extended 669';
  result.FormatsList[5].ID := 1004;
  result.FormatsList[5].IsConfig := False;
  result.FormatsList[6].GenType := HR_TYPE_AUDIO;
  result.FormatsList[6].Format := 'XM';
  result.FormatsList[6].Desc := 'eXtended Module/FT2';
  result.FormatsList[6].ID := 1005;
  result.FormatsList[6].IsConfig := False;
  result.FormatsList[12].GenType := HR_TYPE_AUDIO;
  result.FormatsList[12].Format := 'MPEG Audio';
  result.FormatsList[12].Desc := 'MPEG Audio';
  result.FormatsList[12].ID := 1006;
  result.FormatsList[12].IsConfig := True;
  result.FormatsList[19].GenType := HR_TYPE_AUDIO;
  result.FormatsList[19].Format := 'S3M';
  result.FormatsList[19].Desc := 'Scream Tracker 3 Module';
  result.FormatsList[19].ID := 1007;
  result.FormatsList[19].IsConfig := False;
  result.FormatsList[20].GenType := HR_TYPE_AUDIO;
  result.FormatsList[20].Format := 'IT';
  result.FormatsList[20].Desc := 'Impulse Tracker Module';
  result.FormatsList[20].ID := 1008;
  result.FormatsList[20].IsConfig := False;
  result.FormatsList[21].GenType := HR_TYPE_AUDIO;
  result.FormatsList[21].Format := 'OGG';
  result.FormatsList[21].Desc := 'Ogg Stream';
  result.FormatsList[21].ID := 1009;
  result.FormatsList[21].IsConfig := False;

  result.FormatsList[13].GenType := HR_TYPE_VIDEO;
  result.FormatsList[13].Format := 'AVI';
  result.FormatsList[13].Desc := 'AVI/RIFF';
  result.FormatsList[13].ID := 2000;
  result.FormatsList[13].IsConfig := false;
  result.FormatsList[16].GenType := HR_TYPE_VIDEO;
  result.FormatsList[16].Format := 'MOV';
  result.FormatsList[16].Desc := 'QuickTime Movie';
  result.FormatsList[16].ID := 2001;
  result.FormatsList[16].IsConfig := false;
  result.FormatsList[17].GenType := HR_TYPE_VIDEO;
  result.FormatsList[17].Format := 'BIK';
  result.FormatsList[17].Desc := 'Bink/RAD';
  result.FormatsList[17].ID := 2002;
  result.FormatsList[17].IsConfig := false;
  result.FormatsList[18].GenType := HR_TYPE_VIDEO;
  result.FormatsList[18].Format := 'FLIC';
  result.FormatsList[18].Desc := 'Autodesk Animator & EGI/DTA FLIC';
  result.FormatsList[18].ID := 2003;
  result.FormatsList[18].IsConfig := false;

  result.FormatsList[7].GenType := HR_TYPE_IMAGE;
  result.FormatsList[7].Format := 'BMP';
  result.FormatsList[7].Desc := 'Windows BitMaP';
  result.FormatsList[7].ID := 3000;
  result.FormatsList[7].IsConfig := False;
  result.FormatsList[8].GenType := HR_TYPE_IMAGE;
  result.FormatsList[8].Format := 'EMF';
  result.FormatsList[8].Desc := 'Windows Enhanced MetaFile';
  result.FormatsList[8].ID := 3001;
  result.FormatsList[8].IsConfig := False;
  result.FormatsList[9].GenType := HR_TYPE_IMAGE;
  result.FormatsList[9].Format := 'WMF';
  result.FormatsList[9].Desc := 'Windows MetaFile';
  result.FormatsList[9].ID := 3002;
  result.FormatsList[9].IsConfig := False;
  result.FormatsList[10].GenType := HR_TYPE_IMAGE;
  result.FormatsList[10].Format := 'PNG';
  result.FormatsList[10].Desc := 'Portable Network Graphics';
  result.FormatsList[10].ID := 3003;
  result.FormatsList[10].IsConfig := False;
  result.FormatsList[11].GenType := HR_TYPE_IMAGE;
  result.FormatsList[11].Format := 'GIF';
  result.FormatsList[11].Desc := 'Graphics Interchange Format';
  result.FormatsList[11].ID := 3004;
  result.FormatsList[11].IsConfig := False;
  result.FormatsList[14].GenType := HR_TYPE_IMAGE;
  result.FormatsList[14].Format := 'LBM';
  result.FormatsList[14].Desc := 'LBM/EA IFF 1985';
  result.FormatsList[14].ID := 3005;
  result.FormatsList[14].IsConfig := False;
  result.FormatsList[15].GenType := HR_TYPE_IMAGE;
  result.FormatsList[15].Format := 'JPEG';
  result.FormatsList[15].Desc := 'JPEG/JFIF';
  result.FormatsList[15].ID := 3006;
  result.FormatsList[15].IsConfig := False;

end;

function posBuf(st: String; buffer: PByteArray; bufSize: integer; startpos: integer = 0): integer;
var x, lenst: integer;
    memBuf: TMemoryStream;
    buf: array[1..24] of Char;
    test: string;
begin

  lenst := length(st);

  result := -1;

  memBuf := TMemoryStream.create();
  try
    memBuf.Write(buffer^,bufSize);
    for x := startpos to bufSize-1-lenst do
    begin
      memBuf.Position := x;
      memBuf.ReadBuffer(buf,lenst);
      test := LeftStr(buf,lenst);
      if test = st then
      begin
        result := x;
        break;
      end;
    end;
  finally
    memBuf.free;
  end;

end;

function SearchBuffer(format: integer; buffer: PByteArray; bufSize: integer): integer; stdcall;
var tmpRes: integer;
begin

  case format of
    1000: begin
            result := posBuf('RIFF',buffer, bufSize);
            if (result <> -1) and not(posBuf('WAVE',buffer,bufSize,result+8) = (result + 8)) then
              result := -1;
          end;
    1001: result := posBuf('Creative Voice File'+chr(26),buffer, bufSize);
    1002: result := posBuf('MThd'+chr(0)+chr(0)+chr(0)+chr(6),buffer, bufSize);
    1003: result := posBuf('if',buffer, bufSize);
    1004: result := posBuf('JN',buffer, bufSize);
    1005: result := posBuf('Extended Module: ',buffer, bufSize);
    1006: result := posBuf(#255,buffer, bufSize);
    1007: result := posBuf('SCRM',buffer, bufSize);
    1008: result := posBuf('IMPM',buffer, bufSize);
    1009: result := posBuf('OggS'+chr(0),buffer, bufSize);

    2000: begin
            result := posBuf('RIFF',buffer, bufSize);
            if (result <> -1) and not(posBuf('AVI ',buffer,bufSize,result+8) = (result + 8)) then
              result := -1;
          end;
    2001: result := posBuf('moov',buffer, bufSize);
    2002: result := posBuf('BIK',buffer, bufSize);
    2003: begin
            result := posBuf(#17+#175,buffer,bufSize);
            tmpRes := posBuf(#18+#175,buffer,bufSize);
            if (result = -1) or ((tmpRes > -1) and (tmpRes < result)) then
              result := tmpRes;
            tmpRes := posBuf(#48+#175,buffer,bufSize);
            if (result = -1) or ((tmpRes > -1) and (tmpRes < result)) then
              result := tmpRes;
            tmpRes := posBuf(#68+#175,buffer,bufSize);
            if (tmpRes > -1) and (tmpRes < result) then
              result := tmpRes;
          end;

    3000: result := posBuf('BM',buffer, bufSize);
    3001: result := posBuf(' EMF',buffer, bufSize);
    3002: result := posBuf('×ÍÆš',buffer, bufSize);
    3003: result := posBuf(#137 + #80 + #78 + #71 + #13 + #10 + #26 + #10,buffer,bufSize);
    3004: result := posBuf('GIF8',buffer, bufSize);
    3005: begin
            result := posBuf('FORM',buffer, bufSize);
            if (result <> -1) and not(posBuf('ILBM',buffer,bufSize,result+8) = (result + 8)) then
              result := -1;
          end;
    3006: begin
            result := posBuf(#255+#216+#255+#224,buffer, bufSize);
            if (result <> -1) and not(posBuf('JFIF'+chr(0),buffer,bufSize,result+6) = (result + 6)) then
              result := -1;
          end;

  else
    result := -1;
  end;

end;

function SearchFile64(format: integer; handle: integer; offset: int64): FoundInfo64; stdcall;
var buf1, buf2: array[1..4] of char;
    buf3: array[1..3] of char;
    tByte, tByte2: byte;
    tWord: word;
    tInteger, x, y: integer;
    tChars: array[0..7] of char;
    tBytes4, tBytes4a: array[0..3] of byte;
    size, size2, offset2, COffset, CSize: int64;
    BMPH: BMPHeader;
    EMFH: EnhancedMetaHeader;
    F669H: F669Header;
    F669S: F669Sample;
    GIFH: GIFHeader;
    GIFI: GIFImageDescriptor;
    MIDC: MIDIChunk;
    MIDH: MIDIHeader;
    VOCH: VOCHeader;
    WMFP: PlaceableMetaHeader;
    WMFH: WindowsMetaHeader;
    XMH: XMHeader;
    XMI: XMInstrument;
    XMIH: XMInstrumentHeader;
    XMP: XMPattern;
    XMSH: XMSampleHeader;
    OGGH: OGGHeader;
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

    mustBeStart: boolean;
begin

  result.Offset := -1;
  result.Size := -1;
  result.Ext := '';
  result.GenType := HR_TYPE_ERROR;

  case format of
    1000: begin
            FileSeek(handle,offset,0);
            FileRead(handle,buf1,4);
            FileRead(handle,Size,4);
            FileRead(handle,buf2,4);
            if (buf1 = 'RIFF') and (buf2 = 'WAVE') then
            begin
                result.Offset := offset;
                result.Size := Size+4;
                result.Ext := 'wav';
                result.GenType := HR_TYPE_AUDIO;
            end;
          end;
    1001: begin
            FileSeek(handle,offset,0);
            FileRead(handle,VOCH,SizeOf(VOCHeader));
            if (VOCH.ID = 'Creative Voice File') and (VOCH.EOF = 26) then
            begin
              Size := VOCH.BlockOffset;
              COffset := VOCH.BlockOffset;
              COffset := COffset + Offset;
              while (true) do
              begin
                FileSeek(handle,COffset,0);
                FileRead(handle,tByte,1);
                if TByte = 0 then
                  Break;
                FileRead(handle,tWord,2);
                FileRead(handle,tByte,1);
                CSize := tWord + ($10000 * tByte);
                Inc(COffset,CSize+4);
                Inc(Size,CSize+4);
              end;

              result.Offset := offset;
              result.Size := Size;
              result.Ext := 'voc';
              result.GenType := HR_TYPE_AUDIO;
            end;
          end;
    1002: begin
            FileSeek(handle,offset,0);
            FileRead(handle,MIDC,SizeOf(MIDIChunk));
            if (MIDC.ID = 'MThd') and (BigToLittle4(MIDC.Size) = 6) then
            begin
              FileRead(handle,MIDH,SizeOf(MIDIHeader));
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
                  FileRead(handle,MIDC,SizeOf(MIDIChunk));
                  if MIDC.ID <> 'MTrk' then
                  begin
                    good := false;
                    break;
                  end;
                  size := size + 8;
                  size2 := BigToLittle4(MIDC.Size);
                  size := size + size2;
                  FileSeek(handle,offset+size,0);
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
            COffset := 0;
            totSize := FileSeek(handle,COffset,2);
            FileSeek(handle,offset,0);
            FileRead(handle,F669H,SizeOf(F669Header));
            if ((F669H.ID = 'if') or (F669H.ID = 'JN'))
            and (F669H.NOS <= 64)
            and (F669H.NOP <= 128) then
            begin
              size := $1F1+F669H.NOS*$19+F669H.NOP*$600;
              good := true;
              for x := 1 to F669H.NOS do
              begin
                FileRead(handle,F669S,SizeOf(F669Sample));
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
            FileSeek(handle,offset,0);
            FileRead(handle,XMH,SizeOf(XMHeader));
            if (XMH.ID = 'Extended Module: ')
            and (XMH.EOF = $1A)
            and (XMH.NumIns <= 128)
            and (XMH.NumPat <= 256) then
            begin
              Size := XMH.HeaderSize + 60;
              for x:= 1 to XMH.NumPat do
              begin
                FileRead(handle,XMP,SizeOf(XMPattern));
                Inc(Size,XMP.HeaderLength+XMP.Size);
                FileSeek(handle,Offset+Size,0);
              end;
              for x:= 1 to XMH.NumIns do
              begin
                FileRead(handle,XMIH,SizeOf(XMInstrumentHeader));
                Inc(Size,XMIH.Size);
                if XMIH.NumSamples > 0 then
                begin
                  FileRead(handle,XMI,SizeOf(XMInstrument));
                  FileSeek(handle,Offset+Size,0);
                  for y := 1 to XMIH.NumSamples do
                  begin
                    inc(Size,XMI.SampleHeaderSize);
                    FileRead(handle,XMSH,SizeOf(XMSampleHeader));
                    Inc(size,XMSH.Length);
                    FileSeek(handle,offset+size,0);
                  end;
                end;
                FileSeek(handle,offset+size,0);
              end;
              result.Offset := offset;
              result.Size := Size;
              result.Ext := 'xm';
              result.GenType := HR_TYPE_AUDIO;
            end;
          end;
    1006: begin
            MPEGa := getMPEGOptions;
            COffset := 0;
            totSize := FileSeek(handle,COffset,2);
            FileSeek(handle,offset,0);
            Size := 0;
            MP3FrameLen := 0;
            MP3Frames := 0;
            MP3Layer := 0;
            lastOffset := Offset;
            repeat
              FileRead(handle,tBytes4,4);
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
                  FileSeek(handle,offset+36,0);
                  FileRead(handle,buf1,4);
                  if buf1 = 'Xing' then
                  begin
                    FileRead(handle,tBytes4a,4);
                    VBRFlags := BigToLittle4(tBytes4a);
                    FileRead(handle,tBytes4a,4);
                    VBRNumFrames := BigToLittle4(tBytes4a);
                    FileRead(handle,tBytes4a,4);
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
                FileSeek(handle,Offset+Size,0);
              end
              else
                break;
            until (false);

            if Size > 0 then
            begin
              if ((MPEGa.LimitFramesMin and (MP3Frames >= MPEGa.FramesMin))
              or not(MPEGa.LimitFramesMin))
              and ((MPEGa.LimitSizeMin and (Size >= MPEGa.SizeMin))
              or not(MPEGa.LimitSizeMin)) then
              begin
                if MPEGa.ID3Tag then
                begin
                  FileSeek(handle,offset+size,0);
                  FileRead(handle,buf3,3);
                  if buf3 = 'TAG' then
                    inc(Size,128);
                end;
                result.Offset := offset;
                result.Size := Size;
                result.Ext := 'mp'+inttostr(MP3Layer);
                result.GenType := HR_TYPE_AUDIO;
              end;
            end;

          end;
    1007: begin
            Dec(offset,44);
            if Offset >= 0 then
            begin
              COffset := 0;
              totSize := FileSeek(handle,COffset,2);
              FileSeek(handle,offset,0);
              FileRead(handle,S3MH,SizeOf(S3MHeader));

              CSize := 96+S3MH.OrdNum;
              Size := 96 + S3MH.OrdNum + S3MH.InsNum * 2 + S3MH.PatNum * 2;

              for x := 1 to S3MH.InsNum do
              begin
                FileSeek(handle,offset+CSize,0);
                FileRead(handle,tWord,2);
                tInteger := tWord * 16;
                FileSeek(handle,offset+tInteger,0);
                FileRead(handle,S3MS,SizeOf(S3MSample));
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
                FileSeek(handle,Offset+CSize,0);
                FileRead(handle,tWord,2);
                if tWord > 0 then
                begin
                  tInteger := tWord * 16;
                  FileSeek(handle,Offset+tInteger,0);
                  FileRead(handle,tWord,2);
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
            COffset := 0;
            totSize := FileSeek(handle,COffset,2);
            FileSeek(handle,offset,0);
            FileRead(handle,ITH,SizeOf(ITHeader));
            Size := 192 + ITH.OrdNum + ITH.InsNum * 4;
            MaxPointer := 0;
            CSize := 0;
            for x := 1 to ITH.SmpNum do
            begin
              FileSeek(handle,offset+size,0);
              FileRead(handle,tInteger,4);
              FileSeek(handle,offset+tInteger,0);
              FileRead(handle,ITS,SizeOf(ITSample));
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
            FileSeek(handle,offset,0);
            Size := 0;
            mustBeStart := true;
            repeat
              FileRead(handle,OggH,SizeOf(OggH));
              if (OggH.ID = 'OggS') and (OggH.Revision = 0) then
              begin
                if (mustBeStart and ((OggH.BitFlags and 2) = 2))
                or (not(MustBeStart) and ((OggH.BitFlags and 2) = 0)) then
                begin
                  OGGPageLen := 0;
                  for x := 1 to OggH.NumPageSegments do
                  begin
                    FileRead(handle,tbyte,1);
                    inc(OGGPageLen,tbyte);
                  end;
                  inc(Size,OGGPageLen+sizeof(OggH)+OggH.NumPageSegments);
                  if ((OggH.BitFlags and 4) = 4) then
                    break;
                  cOffset := OGGPageLen;
                  FileSeek(handle,cOffset,1);
                  mustBeStart := false;
                end
                else
                  break;
              end
              else
                break;
            until (false);

            if Size > 0 then
            begin
              result.Offset := offset;
              result.Size := Size;
              result.Ext := 'ogg';
              result.GenType := HR_TYPE_AUDIO;
            end;

          end;

    2000: begin
            FileSeek(handle,offset,0);
            FileRead(handle,buf1,4);
            FileRead(handle,Size,4);
            FileRead(handle,buf2,4);
            if (buf1 = 'RIFF') and (buf2 = 'AVI ') then
            begin
                result.Offset := offset;
                result.Size := Size+4;
                result.Ext := 'avi';
                result.GenType := HR_TYPE_VIDEO;
            end;
          end;
    2001: begin
            if (Offset-4)>=0 then
            begin
              Dec(Offset,4);
              cOffset := 0;
              totSize := FileSeek(handle,cOffset,2);
              FileSeek(handle,offset+Size,0);
              FileRead(handle,tBytes4,4);
              FileRead(handle,buf1,4);
              if (buf1 = 'moov') then
              begin
                Size := BigToLittle4(tBytes4);
                repeat
                  FileSeek(handle,offset+size,0);
                  FileRead(handle,tBytes4,4);
                  FileRead(handle,buf1,4);
                  Inc(Size,BigToLittle4(tBytes4));
                until (buf1 = 'mdat') or (Offset+Size >= totSize);
                result.Offset := offset;
                result.Size := Size;
                result.Ext := 'mov';
                result.GenType := HR_TYPE_VIDEO;
              end;
            end;
          end;
    2002: begin
            FileSeek(handle,offset,0);
            FileRead(handle,buf1,4);
            FileRead(handle,Size,4);
            if (buf1 = 'BIKf') or (buf1 = 'BIKi') then
            begin
                result.Offset := offset;
                result.Size := Size+8;
                result.Ext := 'bik';
                result.GenType := HR_TYPE_VIDEO;
            end;
          end;
    2003: begin
            cOffset := 0;
            totSize := FileSeek(handle,cOffset,2);
            Dec(offset,4);
            if (offset >= 0) then
            begin
              FileSeek(handle,offset,0);
              FileRead(handle,FLICH,SizeOf(FLIC_Header));
              if (FLICH.Flags = 0) and (Offset+FLICH.Size <= totSize) then
              begin
                case FLICH.Magic of
                  $AF11: result.Ext := 'fli';
                  $AF12,$AF30,$AF44: result.Ext := 'flc';
                end;
                if (result.Ext = 'fli') or (result.ext = 'flc') then
                begin
                  result.Offset := offset;
                  result.Size := FLICH.Size;
                  result.GenType := HR_TYPE_VIDEO;
                end;
              end;
            end;
          end;

    3000: begin
            FileSeek(handle,offset,0);
            FileRead(handle,BMPH,SizeOf(BMPHeader));
            if (BMPH.ID = 'BM') and (BMPH.ID2 = 40) and (BMPH.Size > 14) then
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
              FileSeek(handle,offset,0);
              FileRead(handle,EMFH,SizeOf(EnhancedMetaHeader));
              if (EMFH.Signature = ' EMF') and (EMFH.RecordType = 1) and (EMFH.Reserved = 0) then
              begin
                  result.Offset := offset;
                  result.Size := EMFH.Size;
                  result.Ext := 'emf';
                  result.GenType := HR_TYPE_IMAGE;
              end;
            end;
          end;
    3002: begin
            FileSeek(handle,offset,0);
            FileRead(handle,WMFP,SizeOf(PlaceableMetaHeader));
            FileRead(handle,WMFH,SizeOf(WindowsMetaHeader));
            if ((WMFH.FileType = 1) or (WMFH.FileType = 0))
            and (WMFP.Key = $D7CDC69A)
            and (WMFH.HeaderSize = 9) and (WMFH.NumOfParams = 0)
            and (WMFP.Handle = 0) and (WMFP.Reserved = 0) then
            begin
                result.Offset := offset;
                result.Size := WMFH.FileSize*2+44;
                result.Ext := 'wmf';
                result.GenType := HR_TYPE_IMAGE;
            end;
          end;
    3003: begin
            FileSeek(handle,offset,0);
            FileRead(handle,tChars,8);
            Offset2 := offset + 8;
            if (tChars = #137 + 'PNG' + #13 + #10 + #26 + #10) then
            begin
              repeat
                FileSeek(handle,offset2,0);
                FileRead(handle,tBytes4,4);
                CSize := BigToLittle4(tBytes4);
                FileRead(handle,buf2,4);
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
            FileSeek(handle,offset,0);
            FileRead(handle,GIFH,SizeOf(GIFHeader));
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
                FileSeek(handle,offset+size,0);
                FileRead(handle,tByte,1);
                inc(Size);
                case tbyte of
                  44: { , }
                      begin
                        FileRead(handle,GIFI,SizeOf(GIFImageDescriptor));
                        Inc(Size,SizeOf(GIFImageDescriptor)+1);
                        if (GIFI.Flags and $80) > 0 then
                        begin
                          tByte2 := (GIFI.Flags and 7) + 1;
                          Inc(Size,(Trunc(power(2,tByte2))*3));
                        end;

                        FileSeek(handle,offset+size,0);
                        repeat
                          FileRead(handle,tByte2,1);
                          inc(size,tByte2+1);
                          FileSeek(handle,offset+size,0);
                        until (tByte2 = 0);
                      end;
                  33: { ! }
                      begin
                        inc(Size);

                        FileSeek(handle,offset+size,0);
                        repeat
                          FileRead(handle,tByte2,1);
                          inc(size,tByte2+1);
                          FileSeek(handle,offset+size,0);
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
            FileSeek(handle,offset,0);
            FileRead(handle,buf1,4);
            FileRead(handle,tBytes4,4);
            FileRead(handle,buf2,4);
            if (buf1 = 'FORM') and (buf2 = 'ILBM') then
            begin
                result.Offset := offset;
                result.Size := BigToLittle4(tBytes4)+8;
                result.Ext := 'lbm';
                result.GenType := HR_TYPE_IMAGE;
            end;
          end;
    3006: begin
            cOffset := 0;
            totSize := FileSeek(handle,cOffset,2);
            FileSeek(handle,offset,0);
            FileRead(handle,Buf1,4);
            if (Buf1 = #255+#216+#255+#224) then
            begin
              FileRead(handle,JPGH,SizeOf(JPEG_APP0));
              if (JPGH.Identifier = 'JFIF') and (JPGH.NulByte = 0) then
              begin
                Size := 4 + BigToLittle2(JPGH.Length);
                GetMem(PBuf,16384);
                try
                  while (offset+Size < totSize) do
                  begin
                    FileSeek(handle,offset+size,0);
                    if (totSize-(offset+Size-1) < 16384) then
                      bufsize := totSize-offset-size+1
                    else
                      bufsize := 16384;
                    FileRead(handle,PBuf^,bufsize);
                    JPEGResult := PosBuf(#255+#217,PBuf,bufsize);
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
                result.Offset := offset;
                result.Size := Size;
                result.Ext := 'jpg';
                result.GenType := HR_TYPE_IMAGE;
              end;
            end;
          end;

  else
    result.Offset := -1;
    result.Size := -1;
    result.Ext := '';
    result.GenType := HR_TYPE_ERROR;
  end;

end;

procedure InitPlugin(per: TPercentCallback; lngid: TLanguageCallback; DUP5Path: ShortString; AppHandle: THandle; AppOwner: TComponent); stdcall;
begin

  Percent := per;
  DLNGStr := lngid;
  CurPath := DUP5Path;
  AHandle := AppHandle;
  AOwner := AppOwner;

end;

procedure ShowOptionPanel(DriverID: integer);
var frmMpa: TfrmOptMPEGa;
    OApp: THandle;
begin

  case DriverID of
    1006: begin
            OApp := Application.Handle;
            Application.Handle := AHandle;
            frmMpa := TfrmOptMPEGa.Create(AOwner);
            try
              with frmMpa do
              begin
                lblVersion.Caption := 'Elbereth''s HyperRipper Plugin v'+GetVersion(DRIVER_VERSION);
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
              frmMpa.Free;
            end;
            Application.Handle := OApp;
          end;
  end;

end;

procedure AboutBox; stdcall;
begin

  MessageBoxA(AHandle, PChar('Elbereth''s HyperRipper plugin v'+getVersion(DRIVER_VERSION)+#10+
                          '(c)Copyright 2002-2005 Alexandre Devilliers'+#10+#10+
                          'Designed for HyperRipper v'+getVersion(HR_VERSION)
                          )
                        , 'About Elbereth''s HyperRipper plugin...', MB_OK);

end;

exports
  DUHIVersion,
  SearchBuffer,
  SearchFile64,
  GetSearchFormats,
  GetVersionInfo,
  InitPlugin,
  AboutBox,
  ShowOptionPanel;

begin
end.
