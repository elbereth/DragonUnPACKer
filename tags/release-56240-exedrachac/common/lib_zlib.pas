unit lib_zlib;

// $Id: lib_zlib.pas,v 1.1.1.1 2004-05-08 10:25:11 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/common/lib_zlib.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
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
