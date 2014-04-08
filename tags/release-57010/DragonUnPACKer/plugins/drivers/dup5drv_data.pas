unit dup5drv_data;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is dup5drv_data.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// ===========================================================
// Optional Data handling unit (Delphi 6 Source)
// Dragon UnPACKer v5.0.0                      Plugin SDK PR-2
// ===========================================================
// Stores Data for ReadFormat() and GetEntry().

interface

uses dup5drv_utils,
     spec_DUDI;


procedure FSE_add(Name: String; Offset, Size: Int64; DataX, DataY: integer);
function FSE_Read(): FormatEntry;

type FSE = ^element;
     element = record
        Name : String;
        Size : Int64;
        Offset : Int64;
        DataX : integer;
        DataY : integer;
        suiv : FSE;
     end;

implementation
var DataBloc: FSE;

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

function FSE_Read(): FormatEntry;
var a: FSE;
begin

  if DataBloc <> NIL then
  begin
    a := DataBloc;
    DataBloc := DataBloc^.suiv;
    FSE_Read.FileName := a^.Name;
    FSE_Read.Offset := a^.Offset;
    FSE_Read.Size := a^.Size;
    FSE_Read.DataX := a^.DataX;
    FSE_Read.DataY := a^.DataY;
    Dispose(a);
  end
  else
  begin
    FSE_Read.FileName := '';
    FSE_Read.Offset := 0;
    FSE_Read.Size := 0;
    FSE_Read.DataX := 0;
    FSE_Read.DataY := 0;
  end;

end;

end.
