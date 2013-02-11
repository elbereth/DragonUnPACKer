unit dup5drv_utils;

// $Id: dup5drv_utils.pas,v 1.2 2010-02-27 15:57:50 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/plugins/drivers/dup5drv_utils.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is dup5drv_utils.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// ===========================================================
// DUP5 Driver Structures (Delphi 6 Unit)
// Dragon UnPACKer v5.0.0                      Plugin SDK PR-2
// ===========================================================

interface

type
   // Record to store current file format information
   CurrentDriverInfo = record
     Sch : ShortString;           // Directory parsing char (ex: \ or /) if
                                  // left blank then no directory parsing
     ID : ShortString;            // Identification string of the file format
                                  // Should be as unique and short as possible
                                  // because it is used by convert plugins to
                                  // identify the file format.
     FileHandle : Integer;        // Handle used to open and read file. Must be
                                  // set if ExtractInternal is set to "true".
     ExtractInternal : Boolean;   // Indicate if DUP5 should use the plugin
                                  // ExtractFile function or DUP5 own extract
                                  // function.
                                  // If set to "true" the plugin must export
                                  // the ExtractFile function.
   end;
   // Record to store a support file format
   FormatInfo = record
     Extensions : ShortString;    // List of extensions ";" separated
                                  // ex: *.PAK;*.WAD;*.EXT
     Name : ShortString;          // Name of the file format displayed in
                                  // DUP5 open dialog.
                                  // If multiple names separate them with a pipe
                                  // ex: Quake (*.PAK)|Quake 2 (*.PAK)
   end;
   // Record to store information about the driver
   DriverInfo = record
     Name : ShortString;          // Name of the driver (ex: Default Driver)
     Author : ShortString;        // Your name (or nickname)
     Version : ShortString;       // String representation of the version number
     Comment : ShortString;       // Any comment you want to add (like code
                                  // source from this guy, blah blah, etc..)
     NumFormats : Byte;           // Number of FormatInfo defined in Formats
                                  // array
     Formats : array[1..255] of FormatInfo;
   end;
   // Record to store error information
   ErrorInfo = record
     Format : ShortString;        // Format ID of the file (ex: PACK)
     Games : ShortString;         // Games associated to this ID (ex: Quake)
   end;
   // Record that stores an entry information
   FormatEntry = record
     FileName: ShortString;       // Filename of entry
     Offset, Size: Int64;         // Offset and Size of entry in currently
                                  // opened file format
                                  // 64bit integers
     DataX, DataY: Integer;       // Two integers to store anything you may
                                  // need (ex: pointers, uncompressed size,
                                  // compression method, etc..)
   end;
   // Procedure to set percent bar value in DUP5
   TPercentCallback = procedure (p: byte);
   // Function to get a string defined in the language strings of DUP5
   // You must know the language code (ex: MNU1S1).
   // If the language code doesn't exist this function returns "*Undefined*"
   TLanguageCallback = function (lngid: ShortString): ShortString;
   // Procedure to display a message box by using host application
   TMsgBoxCallback = procedure(const title, msg: AnsiString);
   // Procedure to add entries in the host application
   TAddEntryCallback = procedure (entrynam: ShortString; Offset: Int64; Size: Int64; DataX: integer; DataY: integer);

procedure addFormat(var drvInfo: DriverInfo; formatExts, formatName: string);

implementation

procedure addFormat(var drvInfo: DriverInfo; formatExts, formatName: string);
begin

  inc(drvInfo.NumFormats);
  drvInfo.Formats[drvInfo.NumFormats].Extensions := formatExts;
  drvInfo.Formats[drvInfo.NumFormats].Name := formatName;

end;

end.
