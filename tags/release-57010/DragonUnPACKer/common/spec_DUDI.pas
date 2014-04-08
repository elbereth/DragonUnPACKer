unit spec_DUDI;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is dup5drv_utils.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// ===========================================================
// DUP5 Driver Interface Structures (Delphi 7 Unit)
// Dragon UnPACKer v5.7.0                      Plugin SDK PR-3
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
   // Record to store current file format modifications supported information
   CurrentDriverModifInfo = record
     CanReplace : Boolean;        // Can replace entry?
     CanReplaceExtended : Boolean;// Can replace entry with any size file (=true)?
                                  // Or only (=false) with same size input file
     CanAdd : Boolean;            // Can add files
     CanDelete : Boolean;         // Can delete files
     CanCreate : Boolean;         // Can create the file format
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
   // Record to store a modification support file format
   FormatModifInfo = record
     Extension : ShortString;     // Extension
                                  // ex: *.PAK
     Name : ShortString;          // Name of the file format displayed in
                                  // DUP5 open dialog.
                                  // ex: Quake (*.PAK)
     Capability : CurrentDriverModifInfo; // Modification capability of current format
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
   // Record to store information about the driver capabilities for modification
   DriverModifInfo = record
     NumFormats : Byte;           // Number of FormatModifInfo defined in Formats
                                  // array
     Formats : array[1..255] of FormatModifInfo;
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

implementation

end.
 