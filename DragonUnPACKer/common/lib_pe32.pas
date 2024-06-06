unit lib_pe32;

{$mode objfpc}{$H+}

// Delphi - Linker Timestamp von Delphi Images
// ----------------------------------------------------------------------------
// Original code by Michael Puff
// http://www.michael-puff.de/Programmierung/Delphi/Code-Snippets/GetImageLinkTimeStamp.shtml
//
// Get the 'link time stamp' of an portable executable image file (PE32)
// (written for Delphi 5, some types missing in Windows.pas of Delphi 4)

interface

uses SysUtils, Windows;

type ELinkDateRetrievalError = Exception;

function GetImageLinkDateTime(const FileName: string): TDateTime;
function GetExecutableCompilationDateTime(): TDateTime;

implementation

 // Get the 'link time stamp' of an portable executable image file (PE32)
// (written for Delphi 5, some types missing in Windows.pas of Delphi 4)

function GetImageLinkTimeStamp(const FileName: string): DWORD;
const
  INVALID_SET_FILE_POINTER = DWORD(-1);
  BorlandMagicTimeStamp = $2A425E19;  // Delphi 4-6 (and above?)
  FileTime1970: TFileTime = (dwLowDateTime:$D53E8000; dwHighDateTime:$019DB1DE);
type
  PImageSectionHeaders = ^TImageSectionHeaders;
  TImageSectionHeaders = array [Word] of TImageSectionHeader;
type
  PImageResourceDirectory = ^TImageResourceDirectory;
  TImageResourceDirectory = packed record
    Characteristics: DWORD;
    TimeDateStamp: DWORD;
    MajorVersion: Word;
    MinorVersion: Word;
    NumberOfNamedEntries: Word;
    NumberOfIdEntries: Word;
  end;
var
  FileHandle: THandle;
  BytesRead: DWORD;
  ImageDosHeader: TImageDosHeader;
  ImageNtHeaders: TImageNtHeaders;
  SectionHeaders: PImageSectionHeaders;
  Section: Word;
  ResDirRVA: DWORD;
  ResDirSize: DWORD;
  ResDirRaw: DWORD;
  ResDirTable: TImageResourceDirectory;
  FileTime: TFileTime;
begin
  Result := 0;
  // Open file for read access
  FileHandle := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, 0, 0);
  if (FileHandle <> INVALID_HANDLE_VALUE) then
  try
    // Read MS-DOS header to get the offset of the PE32 header
    // (not required on WinNT based systems - but mostly available)
    if not ReadFile(FileHandle, ImageDosHeader, SizeOf(TImageDosHeader),
      BytesRead, nil) or (BytesRead <> SizeOf(TImageDosHeader)) or
      (ImageDosHeader.e_magic <> IMAGE_DOS_SIGNATURE) then
    begin
      ImageDosHeader._lfanew := 0;
    end;
    // Read PE32 header (including optional header
    if (SetFilePointer(FileHandle, ImageDosHeader._lfanew, nil, FILE_BEGIN) =
      INVALID_SET_FILE_POINTER) then
    begin
      Exit;
    end;
    if not(ReadFile(FileHandle, ImageNtHeaders, SizeOf(TImageNtHeaders),
      BytesRead, nil) and (BytesRead = SizeOf(TImageNtHeaders))) then
    begin
      Exit;
    end;
    // Validate PE32 image header
    if (ImageNtHeaders.Signature <> IMAGE_NT_SIGNATURE) then
    begin
      Exit;
    end;
    // Seconds since 1970 (UTC)
    Result := ImageNtHeaders.FileHeader.TimeDateStamp;

    // Check for Borland's magic value for the link time stamp
    // (we take the time stamp from the resource directory table)
    if (ImageNtHeaders.FileHeader.TimeDateStamp = BorlandMagicTimeStamp) then
    with ImageNtHeaders, FileHeader, OptionalHeader do
    begin
      // Validate Optional header
      if (SizeOfOptionalHeader < IMAGE_SIZEOF_NT_OPTIONAL_HEADER) or
        (Magic <> IMAGE_NT_OPTIONAL_HDR_MAGIC) then
      begin
        Exit;
      end;
      // Read section headers
      SectionHeaders :=
        GetMemory(NumberOfSections * SizeOf(TImageSectionHeader));
      if Assigned(SectionHeaders) then
      try
        if (SetFilePointer(FileHandle,
          SizeOfOptionalHeader - IMAGE_SIZEOF_NT_OPTIONAL_HEADER, nil,
          FILE_CURRENT) = INVALID_SET_FILE_POINTER) then
        begin
          Exit;
        end;
        if not(ReadFile(FileHandle, SectionHeaders^, NumberOfSections *
          SizeOf(TImageSectionHeader), BytesRead, nil) and (BytesRead =
          NumberOfSections * SizeOf(TImageSectionHeader))) then
        begin
          Exit;
        end;
        // Get RVA and size of the resource directory
        with DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE] do
        begin
          ResDirRVA := VirtualAddress;
          ResDirSize := Size;
        end;
        // Search for section which contains the resource directory
        ResDirRaw := 0;
        for Section := 0 to NumberOfSections - 1 do
        with SectionHeaders^[Section] do
          if (VirtualAddress <= ResDirRVA) and
            (VirtualAddress + SizeOfRawData >= ResDirRVA + ResDirSize) then
          begin
            ResDirRaw := PointerToRawData - (VirtualAddress - ResDirRVA);
            Break;
          end;
        // Resource directory table found?
        if (ResDirRaw = 0) then
        begin
          Exit;
        end;
        // Read resource directory table
        if (SetFilePointer(FileHandle, ResDirRaw, nil, FILE_BEGIN) =
          INVALID_SET_FILE_POINTER) then
        begin
          Exit;
        end;
        if not(ReadFile(FileHandle, ResDirTable,
          SizeOf(TImageResourceDirectory), BytesRead, nil) and
          (BytesRead = SizeOf(TImageResourceDirectory))) then
        begin
          Exit;
        end;
        // Convert from DosDateTime to SecondsSince1970
        if DosDateTimeToFileTime(HiWord(ResDirTable.TimeDateStamp),
          LoWord(ResDirTable.TimeDateStamp), FileTime) then
        begin
          // FIXME: Borland's linker uses the local system time
          // of the user who linked the executable image file.
          // (is that information anywhere?)
          Result := (ULARGE_INTEGER(FileTime).QuadPart -
            ULARGE_INTEGER(FileTime1970).QuadPart) div 10000000;
        end;
      finally
        FreeMemory(SectionHeaders);
      end;
    end;
  finally
    CloseHandle(FileHandle);
  end;
end;

function UnixTimeToDateTime(UnixTime: DWORD): TDateTime;
begin
  Result := EncodeDate(1970, 1, 1) + UnixTime / 86400;
end;

function GetImageLinkDateTime(const FileName: string): TDateTime;
var TimeStamp: DWORD;
begin

  TimeStamp := GetImageLinkTimeStamp(FileName);
  if TimeStamp = 0 then
  begin
    // sometimes compilation time in header may be 0: https://learn.microsoft.com/en-us/windows/win32/debug/pe-format
    // instead of raising error let's default to compialtion time
    // raise ELinkDateRetrievalError.Create('')
    // TODO: check out how to make Lazarus output correct compilation time in the executable header
    result := GetExecutableCompilationDateTime();
  end
  else
    result := UnixTimeToDateTime(TimeStamp);

end;


function GetExecutableCompilationDateTime(): TDateTime;
var
  fs: TFormatSettings;
begin
  fs.ShortDateFormat:= 'yyyy mm dd';
  fs.DateSeparator:= '/';
  fs.TimeSeparator:=':';
  fs.LongTimeFormat := 'hh:nn';
  // date in a 2024/06/01 13:52:52 format
  result := StrToDateTime({$I %DATE%} + ' ' + {$I %TIME%}, fs);

end;

end.

