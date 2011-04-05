unit spec_DDS;

// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is spec_DDS.pas, released May 30, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

// DDSURFACEDESC2 dwFlags
const DDSD_CAPS        = $00000001;
      DDSD_HEIGHT      = $00000002;
      DDSD_WIDTH       = $00000004;
      DDSD_PITCH       = $00000008;
      DDSD_PIXELFORMAT = $00001000;
      DDSD_MIPMAPCOUNT = $00020000;
      DDSD_LINEARSIZE  = $00080000;
      DDSD_DEPTH       = $00800000;

// DDSURFACEDESC2 ddpfPixelFormat
const DDPF_ALPHAPIXELS = $00000001;
      DDPF_FOURCC      = $00000004;
      DDPF_RGB         = $00000040;

// DDSCAPS2 dwCaps1
const DDSCAPS_COMPLEX  = $00000008;
      DDSCAPS_TEXTURE  = $00001000;
      DDSCAPS_MIPMAP   = $00400000;

// DDSCAPS2 dwCaps2
const DDSCAPS2_CUBEMAP           = $00000200;
      DDSCAPS2_CUBEMAP_POSITIVEX = $00000400;
      DDSCAPS2_CUBEMAP_NEGATIVEX = $00000800;
      DDSCAPS2_CUBEMAP_POSITIVEY = $00001000;
      DDSCAPS2_CUBEMAP_NEGATIVEY = $00002000;
      DDSCAPS2_CUBEMAP_POSITIVEZ = $00004000;
      DDSCAPS2_CUBEMAP_NEGATIVEZ = $00008000;
      DDSCAPS2_VOLUME            = $00200000;

type DDPIXELFORMAT = packed record
      dwSize: Cardinal;                      // Size of structure. This member must be set to 32.
      dwFlags: Cardinal;                     // Flags to indicate valid fields. Uncompressed formats will usually use DDPF_RGB to indicate an RGB format, while compressed formats will use DDPF_FOURCC with a four-character code.
      dwFourCC: array[0..3] of char;         // This is the four-character code for compressed formats. dwFlags should include DDPF_FOURCC in this case. For DXTn compression, this is set to "DXT1", "DXT2", "DXT3", "DXT4", or "DXT5".
      dwRGBBitCount: Cardinal;               // For RGB formats, this is the total number of bits in the format. dwFlags should include DDPF_RGB in this case. This value is usually 16, 24, or 32. For A8R8G8B8, this value would be 32.
      dwRBitMask: Cardinal;
      dwGBitMask: Cardinal;                  // For RGB formats, these three fields contain the masks for the red, green, and blue channels. For A8R8G8B8, these values would be 0x00ff0000, 0x0000ff00, and 0x000000ff respectively.
      dwBBitMask: Cardinal;
      dwRGBAlphaBitMask: Cardinal;           // For RGB formats, this contains the mask for the alpha channel, if any. dwFlags should include DDPF_ALPHAPIXELS in this case. For A8R8G8B8, this value would be 0xff000000.
    end;
    DDCAPS2 = packed record
      dwCaps1: Cardinal;                     // DDS files should always include DDSCAPS_TEXTURE. If the file contains mipmaps, DDSCAPS_MIPMAP should be set. For any .dds file with more than one main surface, such as a mipmaps, cubic environment map, or volume texture, DDSCAPS_COMPLEX should also be set.
      dwCaps2: Cardinal;                     // For cubic environment maps, DDSCAPS2_CUBEMAP should be included as well as one or more faces of the map (DDSCAPS2_CUBEMAP_POSITIVEX, DDSCAPS2_CUBEMAP_NEGATIVEX, DDSCAPS2_CUBEMAP_POSITIVEY, DDSCAPS2_CUBEMAP_NEGATIVEY, DDSCAPS2_CUBEMAP_POSITIVEZ, DDSCAPS2_CUBEMAP_NEGATIVEZ). For volume textures, DDSCAPS2_VOLUME should be included.
      Reserved: array[1..2] of Cardinal;     // Unused
    end;
type DDSURFACEDESC2 = packed record
      dwSize: Cardinal;                      // Size of structure. This member must be set to 124.
      dwFlags: Cardinal;                     // Flags to indicate valid fields. Always include DDSD_CAPS, DDSD_PIXELFORMAT, DDSD_WIDTH, DDSD_HEIGHT.
      dwHeight: Cardinal;                    // Height of the main image in pixels
      dwWidth: Cardinal;                     // Width of the main image in pixels
      dwPitchOrLinearSize: Cardinal;         // For uncompressed formats, this is the number of bytes per scan line (DWORD> aligned) for the main image. dwFlags should include DDSD_PITCH in this case. For compressed formats, this is the total number of bytes for the main image. dwFlags should be include DDSD_LINEARSIZE in this case.
      dwDepth: Cardinal;                     // For volume textures, this is the depth of the volume. dwFlags should include DDSD_DEPTH in this case.
      dwMipMapCount: Cardinal;               // For items with mipmap levels, this is the total number of levels in the mipmap chain of the main image. dwFlags should include DDSD_MIPMAPCOUNT in this case.
      dwReserved1: array[1..11] of Cardinal; // Unused	
      ddpfPixelFormat: DDPIXELFORMAT;        // 32-byte value that specifies the pixel format structure.
      ddsCaps: DDCAPS2;                      // 16-byte value that specifies the capabilities structure.
      dwReserved2: Cardinal;                 // Unused
    end;
type DDSHeader = packed record
      ID: array[0..3] of char;               // "DDS "
      SurfaceDesc: DDSURFACEDESC2;
     end;

implementation

end.
 