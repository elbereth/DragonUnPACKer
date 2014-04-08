unit lib_zlib;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is lib_zlib.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// ZLib To/From String compression Library
// =============================================================================
//
//  Functions:
//  function zlibCompressStr(const S: string) : string;
//  function zlibDecompressStr(const S: string) : string;
//
// -----------------------------------------------------------------------------

interface
function zlibCompressStr(const S: string) : string;
function zlibDecompressStr(const S: string) : string;

implementation

uses zlib, classes;

function zlibCompressStr(const S: string) : string;
var
  InputStream: TCompressionStream;
  OutputStream: TMemoryStream;
  Size: Integer;
begin 
  OutputStream := TMemoryStream.Create;

  try 
    InputStream := TCompressionStream.Create(clMax, OutputStream);
    try 
      Size := Length(S);
      InputStream.Write(Size, SizeOf(Size));
      InputStream.Write(S[1], Size)
    finally 
      InputStream.Free
    end;

    SetLength(Result, OutputStream.Size);
    OutputStream.Seek(0, soBeginning);
    OutputStream.Read(Result[1], Length(Result))

  finally 
    OutputStream.Free
  end 
end;

function zlibDecompressStr(const S: string) : string;
var
  InputStream: TMemoryStream;
  OutputStream: TDecompressionStream;
  Size: Integer;
begin 
  InputStream := TMemoryStream.Create;

  try 
    InputStream.Write(S[1], Length(S));
    InputStream.Seek(0, soBeginning);

    OutputStream := TDecompressionStream.Create(InputStream);
    try 
      OutputStream.Read(Size, SizeOf(Size));
      SetLength(Result, Size);
      OutputStream.Read(Result[1], Size)

    finally 
      OutputStream.Free
    end 

  finally 
    InputStream.Free
  end 
end;

end.
