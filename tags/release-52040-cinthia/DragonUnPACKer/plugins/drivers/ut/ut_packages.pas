{-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License Version
1.1 (the "License"); you may not use this file except in compliance with
the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
for the specific language governing rights and limitations under the
License.

The Original Code is: ut_packages.pas, released on 2004-01-23.

The Initial Developer of the Original Code is Antonio Cordero Balcazar.

Portions created by the Initial Developer are Copyright (C) 2004
the Initial Developer. All Rights Reserved.

Contributor(s):          
Alexandre Devilliers (2005-12-13) - Added SaveToStream to Sound/Music object

-----------------------------------------------------------------------------}
unit ut_packages;
{
   UT Packages Delphi unit v2.3
   http://www.acordero.org
   http://www.sourceforge.net/projects/utpackages

   This unit allows you to read Unreal engine package files and their
   internal objects and extract information from them.

   Thanks to Epic Games and to everyone who helped.

   AAO 1.4 Decryption algorithm taken from "aaocrypt" utility.
}

interface

uses windows, types, math, sysutils, classes, graphics;

procedure Register2DClasses;
procedure Register3DClasses;
procedure RegisterSoundClasses;
procedure RegisterCodeClasses;
procedure RegisterOtherClasses;
procedure RegisterAllClasses;

{$IFDEF VER130} // for Delphi 5 compatibility
type
  TIntegerDynArray=array of integer;
{$ENDIF}

const
  // Package flags
  PKG_AllowDownload = $0001;            // Allow downloading package.
  PKG_ClientOptional = $0002;           // Purely optional for clients.
  PKG_ServerSideOnly = $0004;           // Only needed on the server side.
  PKG_BrokenLinks = $0008;              // Loaded from linker with broken import links.
  PKG_Unsecure = $0010;                 // Not trusted.
  PKG_Encrypted = $0020;                // Encrypted? (seen in Clive Barker's Undying; in UT2004 means another thing!)
  PKG_Need = $8000;                     // Client needs to download this package.

  // Extra Package Flags
  PKG_OTHER_FLAGS_AAOEncrypted = $00000001;     // File is encrypted with America's Army algorithm
  PKG_OTHER_FLAGS_Lineage2Encrypted = $00000002; // File is encrypted with Lineage2 algorithm

  // Object flags
  RF_Transactional = $00000001;         // Object is transactional.
  RF_Unreachable = $00000002;           // Object is not reachable on the object graph.
  RF_Public = $00000004;                // Object is visible outside its package.
  RF_TagImp = $00000008;                // Temporary import tag in load/save.
  RF_TagExp = $00000010;                // Temporary export tag in load/save.
  RF_SourceModified = $00000020;        // Modified relative to source files.
  RF_TagGarbage = $00000040;            // Check during garbage collection.
  RF_Private = $00000080;               // Object is private to its package
  RF_Unk_00000100 = $00000100;  {UT2003}// unknown but used in UT2003 (related to GUI objects?, maybe used for array referenced objects?)
  RF_NeedLoad = $00000200;              // During load, indicates object needs loading.
  RF_HighlightedName = $00000400;       // A hardcoded name which should be syntax-highlighted.
  RF_InSingularFunc = $00000800;        // In a singular function.
  RF_Suppress = $00001000;              // Suppressed log name.
  RF_InEndState = $00002000;            // Within an EndState call.
  RF_Transient = $00004000;             // Don't save object.
  RF_PreLoading = $00008000;            // Data is being preloaded from file.
  RF_LoadForClient = $00010000;         // In-file load for client.
  RF_LoadForServer = $00020000;         // In-file load for client.
  RF_LoadForEdit = $00040000;           // In-file load for client.
  RF_Standalone = $00080000;            // Keep object around for editing even if unreferenced.
  RF_NotForClient = $00100000;          // Don't load this object for the game client.
  RF_NotForServer = $00200000;          // Don't load this object for the game server.
  RF_NotForEdit = $00400000;            // Don't load this object for the editor.
  RF_Destroyed = $00800000;             // Object Destroy has already been called.
  RF_NeedPostLoad = $01000000;          // Object needs to be postloaded.
  RF_HasStack = $02000000;              // Has execution stack.
  RF_Native = $04000000;                // Native (UClass only).
  RF_Marked = $08000000;                // Marked (for debugging).
  RF_ErrorShutdown = $10000000;         // ShutdownAfterError called.
  RF_DebugPostLoad = $20000000;         // For debugging Serialize calls.
  RF_DebugSerialize = $40000000;        // For debugging Serialize calls.
  RF_DebugDestroy = $80000000;          // For debugging Destroy calls.
  // The following flags have duplicated values but they seem to be used only
  // at execution time and so they will not appear in packages.
  //RF_EliminateObject  = 0x00000400,   // NULL out references to this during garbage collecion.
  //RF_RemappedName     = 0x00000800,   // Name is remapped.
  //RF_StateChanged     = 0x00001000,   // Object did a state change.

  // Property types
  otNone = 0;
  otByte = 1;
  otInt = 2;
  otBool = 3;
  otFloat = 4;
  otObject = 5;
  otName = 6;
  otString = 7;                         // old type
  otClass = 8;                          
  otArray = 9;
  otStruct = 10;
  otVector = 11;                        // not implemented => only seen as struct...
  otRotator = 12;                       // not implemented => only seen as struct...
  otStr = 13;
  otMap = 14;                           // not implemented
  otFixedArray = 15;                    // not implemented
  // Extended value types
  otExtendedValue = $00000100;
  otBuffer = otExtendedValue or 0;
  otWord = otExtendedValue or 1;

type
  TUTPackage_GameHint = (
    UTPGH_NotSpecified,
    UTPGH_Unreal,
    UTPGH_UnrealTournament,
    UTPGH_TheWheelOfTime,
    UTPGH_KlingonHonorGuard,
    UTPGH_Rune,
    UTPGH_Undying,
    UTPGH_DeusEx,
    UTPGH_XComEnforcer,
    UTPGH_DeepSpaceNine,
    UTPGH_NerfArenaBlast,
    UTPGH_UnrealTournament2003,
    UTPGH_ArmyOperations,
    UTPGH_HarryPotterSorcerersStone,
    UTPGH_HarryPotterChamberSecrets,
    UTPGH_Unreal2,
    UTPGH_SplinterCell,
    UTPGH_Devastation,
    UTPGH_Rainbow6RavenShield,
    UTPGH_UnrealChampionship,
    UTPGH_Lineage2,
    UTPGH_Postal2,
    UTPGH_UnrealEngine2Runtime,
    UTPGH_DeusExInvisibleWar,
    UTPGH_DesertThunder,
    UTPGH_UnrealTournament2004,
    UTPGH_XIII
    );

const
  UTPackage_GameHintStrings: array[TUTPackage_GameHint] of string = (
    'Unknown',
    'Unreal',
    'Unreal Tournament',
    'The Wheel of Time',
    'Klingon Honor Guard',
    'Rune',
    'Clive Barker''s Undying',
    'Deus Ex',
    'XCom Enforcer',
    'Star Trek: Deep Space Nine',
    'Nerf Arena Blast',
    'Unreal Tournament 2003',
    'Army Operations',
    'Harry Potter and the Sorcerer''s Stone',
    'Harry Potter and the Chamber of Secrets',
    'Unreal 2',
    'Splinter Cell',
    'Devastation',
    'Rainbow Six RavenShield',
    'Unreal Championship',
    'Lineage 2',
    'Postal 2',
    'Unreal Engine 2 Runtime',
    'Deus Ex: Invisible War',
    'Desert Thunder',
    'Unreal Tournament 2004',
    'XIII'
    );

// constants for native function arrays
const
  nffFunction = 0;
  nffPreOperator = 1;
  nffPostOperator = 2;
  nffOperator = 3;

type
  EInvalidUTPackage = class(Exception);
  EProcessingUTPackage = class(Exception);
  EReadingUTProperty = class(Exception);
  EUnknownUTOpcode = class(Exception);
  EInvalidUTNativeIndex = class(Exception);
  EUnknownObjectFormat = class(Exception);

  // types for native function arrays
  TNativeFunction = record
    Index: integer;
    Format: byte;
    OperatorPrecedence: byte;
    Name: string;
  end;
  TNativeFunctions = array of TNativeFunction;

  TUTPackage = class;
  TUTObject = class;
  TUTPropertyType = DWORD;

  // TUTProperty
  TUTProperty = class
  private
    FIsInitialized: boolean;
    FOwner: TUTPackage;
    FOwnerObject: TUTObject;
    function GetArrayTypeLength: integer;
  protected
    FName: string;
    FArrayIndex: integer;
    FPropertyType: TUTPropertyType;
    FValue: array of byte;
    FTypeName: string;
    function GetFirstValue: variant; virtual;
    function GetTypeName: string; virtual;
    function GetDescription: string; virtual;
    function GetDescriptiveValue: string; virtual;
  public
    procedure SetOwnerObject(ownerobject: TUTObject);
    procedure SetProperty(Owner: TUTPackage; n: string; i: integer; t: TUTPropertyType; var value; valuesize: integer; _typename: string = ''); virtual;
    property Name: string read FName;
    property ArrayIndex: integer read FArrayIndex;
    property ArrayTypeLength: integer read GetArrayTypeLength;
    property Value: variant read GetFirstValue;
    property DescriptiveValue: string read GetDescriptiveValue;
    property PropertyType: TUTPropertyType read FPropertyType;
    property Description: string read GetDescription;
    property GenericTypeName: string read FTypeName;
    property SpecificTypeName: string read GetTypeName;
    function ValueCount:integer;
    procedure GetValue(ai,i: integer; var valuename: string; var value: variant; var descriptivevalue: string; var valuetype: TUTPropertyType;var valuetypename:string); virtual;
    function GetValueTypeName(t: TUTPropertyType): string; virtual;
  end;

  TUTPropertyClass = class of TUTProperty;

  // TUTPropertyList
  TUTPropertyList = class
  private
    FProperties: tlist;
    function GetProperty(i: integer): TUTProperty;
    function GetPropertyCount: integer;
    function NewProperty: TUTProperty;
    function GetPropertyByName(name: string): TUTProperty;
    function GetPropertyByNameValue(name: string): variant;
    function GetPropertyByNameValueDefault(name: string; adefault: variant): variant;
    function GetPropertyValueDefault(i: integer; adefault: variant): variant;
    function GetPropertyValue(i: integer): variant;
    function GetPropertyListDescriptions: string;
  public
    constructor Create;
    destructor Destroy; override;
    property New: TUTProperty read NewProperty;
    property Count: integer read GetPropertyCount;
    property PropertyByPosition[i: integer]: TUTProperty read GetProperty;
    property PropertyByName[name: string]: TUTProperty read GetPropertyByName;
    property PropertyByNameValue[name: string]: variant read GetPropertyByNameValue; default;
    property PropertyByNameValueDefault[name: string; adefault: variant]: variant read GetPropertyByNameValueDefault;
    property PropertyByPositionValue[i: integer]: variant read GetPropertyValue;
    property PropertyByPositionValueDefault[i: integer; adefault: variant]: variant read GetPropertyValueDefault;
    procedure Clear;
    property Descriptions: string read GetPropertyListDescriptions;
    procedure FixArrayIndices; virtual;
  end;

  // TUTObject : generic class for UT exported objects
  // Status: completed
  TUTObject = class
  private
    FStartInPackage: dword;
    Fowner: TUTPackage;
    Fexportedindex: integer;
    FHasBeenRead: boolean;
    FHasBeenInterpreted: boolean;
    FReadCount: integer;
    function Get_ClassName: string;
    function GetObjectname: string;
    function GetGroupName: string;
    function GetSuperName: string;
    function GetClassIndex: integer;
    function GetObjectIndex: integer;
    function GetGroupIndex: integer;
    function GetSuperIndex: integer;
    function GetSerialOffset: integer;
    function GetSerialSize: integer;
    function GetFlags: DWORD;
    function GetProperties: TUTPropertyList;
    procedure check_initialized;
    function GetFullName: string;
    function GetPosition: integer;
    procedure SetPosition(const Value: integer);
    function GetOwner: TUTPackage;
    function GetBufferPosition: integer;
  protected
    FProperties: TUTPropertyList;
    Buffer: TMemoryStream;
    FExtraDataCount: integer;
    procedure InitializeObject; virtual;
    procedure InterpretObject; virtual;
    procedure DoReleaseObject; virtual;
    procedure ReadProperties; virtual;
  public
    constructor create(owner: TUTPackage; exportedindex: integer); virtual;
    destructor destroy; override;
    procedure ReadObject(interpret: boolean = true);
    procedure ReleaseObject;
    procedure RawSaveToFile(filename: string);
    procedure RawSaveToStream(stream: TStream);
    function CheckArrayLength(size:integer):integer;
    property Owner: TUTPackage read GetOwner;
    property Position: integer read GetPosition write SetPosition;
    property HasBeenRead: boolean read FHasBeenRead;
    property HasBeenInterpreted: boolean read FHasBeenInterpreted;
    property ExportedIndex: integer read FExportedIndex;
    property Properties: TUTPropertyList read GetProperties;
    property UTObjectIndex: integer read GetObjectIndex;
    property UTClassIndex: integer read GetClassIndex;
    property UTGroupIndex: integer read GetGroupIndex;
    property UTSuperIndex: integer read GetSuperIndex;
    property UTSerialOffset: integer read GetSerialOffset;
    property UTSerialSize: integer read GetSerialSize;
    property UTFlags: DWORD read GetFlags;
    property UTObjectName: string read GetObjectname;
    property UTClassName: string read Get_ClassName;
    property UTGroupName: string read GetGroupName;
    property UTSuperName: string read GetSuperName;
    property UTFullName: string read GetFullName;
    property ExtraDataCount: integer read FExtraDataCount;
    property BufferPosition:integer read GetBufferPosition;
  end;

  TUTObjectClass = class of TUTObject;

  // TUTObjectClassField
  // Status: completed
  TUTObjectClassField = class(TUTObject)
  private
    FSuperField, FNext: integer;
    function GetNext: integer;
    function GetSuperField: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property SuperField: integer read GetSuperField;
    property Next: integer read GetNext;
  end;

  // TUTObjectClassEnum
  // Status: completed
  TUTObjectClassEnum = class(TUTObjectClassField)
  private
    FValues: array of integer;
    function GetCount: integer;
    function GetValue(i: integer): integer;
    function GetValueName(i: integer): string;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property Count: integer read GetCount;
    property EnumValue[i: integer]: integer read GetValue;
    property EnumName[i: integer]: string read GetValueName;
    function GetDeclaration: string;
  end;

  // TUTObjectClassConst
  // Status: completed
  TUTObjectClassConst = class(TUTObjectClassField)
  private
    FValue: string;
    function GetValue: string;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property Value: string read GetValue;
    function GetDeclaration: string;
  end;

  // TUTObjectClassProperty
  // Status: completed
  TUTObjectClassProperty = class(TUTObjectClassField)
  private
    FArrayDimension: integer;
    FElementSize: integer;
    FPropertyFlags: DWORD;
    FCategory: string;
    FRepOffset: word;
    FComment:string;{U2}
    function GetArrayDimension: integer;
    function GetCategory: string;
    function GetElementSize: integer;
    function GetPropertyFlags: DWORD;
    function GetRepOffset: word;
    function GetComment: string;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property ArrayDimension: integer read GetArrayDimension;
    property ElementSize: integer read GetElementSize;
    property PropertyFlags: DWORD read GetPropertyFlags;
    property Category: string read GetCategory;
    property ReplicationOffset: word read GetRepOffset;
    property Comment:string read GetComment;
    function GenericTypeName: string; virtual;
    function GetFlags(cn: string): string;
    function GetDeclaration(context, cn: string): string;
  end;

  // TUTObjectClassByteProperty
  // Status: completed
  TUTObjectClassByteProperty = class(TUTObjectClassProperty)
  private
    FEnum: integer;
    function GetEnum: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property Enum: integer read GetEnum;
    function GenericTypeName: string; override;
  end;

  // TUTObjectClassIntProperty
  // Status: completed
  TUTObjectClassIntProperty = class(TUTObjectClassProperty)
  private
    FMin:integer;
    FMax:integer;
    FIncrement:integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    function GenericTypeName: string; override;
    property Min:integer read FMin;
    property Max:integer read FMax;
    property Increment:integer read FIncrement;
  end;

  // TUTObjectClassBoolProperty
  // Status: completed
  TUTObjectClassBoolProperty = class(TUTObjectClassProperty)
  private
  protected
  public
    function GenericTypeName: string; override;
  end;

  // TUTObjectClassFloatProperty
  // Status: completed
  TUTObjectClassFloatProperty = class(TUTObjectClassProperty)
  private
    FMin:double;
    FMax:double;
    FIncrement:double;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    function GenericTypeName: string; override;
    property Min:double read FMin;
    property Max:double read FMax;
    property Increment:double read FIncrement;
  end;

  // TUTObjectClassNameProperty
  // Status: completed
  TUTObjectClassNameProperty = class(TUTObjectClassProperty)
  private
  protected
  public
    function GenericTypeName: string; override;
  end;

  // TUTObjectClassStrProperty
  // Status: completed
  TUTObjectClassStrProperty = class(TUTObjectClassProperty)
  private
  protected
  public
    function GenericTypeName: string; override;
  end;

  // TUTObjectClassStringProperty
  // Status: completed
  TUTObjectClassStringProperty = class(TUTObjectClassProperty)
  private
  protected
  public
    function GenericTypeName: string; override;
  end;

  // TUTObjectClassObjectProperty
  // Status: completed
  TUTObjectClassObjectProperty = class(TUTObjectClassProperty)
  private
    FObject: integer;
    function GetObject: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property UTObjectType: integer read GetObject;
    function GenericTypeName: string; override;
  end;

  // TUTObjectClassClassProperty
  // Status: completed
  TUTObjectClassClassProperty = class(TUTObjectClassObjectProperty)
  private
    FClass: integer;
    function GetClass: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property UTClassType: integer read GetClass;
    function GenericTypeName: string; override;
  end;

  // TUTObjectClassFixedArrayProperty
  // Status: complete
  TUTObjectClassFixedArrayProperty = class(TUTObjectClassProperty)
  private
    FInner: integer;
    FCount: integer;
    function GetCount: integer;
    function GetInner: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property ElementCount: integer read GetCount;
    property InnerProperty: integer read GetInner;
    function GenericTypeName: string; override;
  end;

  // TUTObjectClassArrayProperty
  // Status: completed
  TUTObjectClassArrayProperty = class(TUTObjectClassProperty)
  private
    FInner: integer;
    function GetInner: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property InnerProperty: integer read GetInner;
    function GenericTypeName: string; override;
  end;

  // TUTObjectClassMapProperty
  // Status: completed
  TUTObjectClassMapProperty = class(TUTObjectClassProperty)
  private
    FKey: integer;
    FValue: integer;
    function GetKey: integer;
    function GetValue: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property KeyProperty: integer read GetKey;
    property ValueProperty: integer read GetValue;
    function GenericTypeName: string; override;
  end;

  // TUTObjectClassStructProperty
  // Status: completed
  TUTObjectClassStructProperty = class(TUTObjectClassProperty)
  private
    FStruct: integer;
    function GetStruct: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property Struct: integer read GetStruct;
    function GenericTypeName: string; override;
  end;

  // TUTObjectClassDelegateProperty
  // Status: completed
  TUTObjectClassDelegateProperty = class(TUTObjectClassProperty)
  private
    FEvent:integer;
    function GetEvent: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property Event:integer read GetEvent;
    function GenericTypeName: string; override;
  end;

  // TUTObjectClassPointerProperty
  // Status: completed
  TUTObjectClassPointerProperty = class(TUTObjectClassProperty)
  private
  protected
  public
    function GenericTypeName: string; override;
  end;

  TUT_Struct_LabelEntry = record
    Name: integer;
    iCode: integer;
  end;

  // TUTObjectClassStruct
  // Status: completed
  TUTObjectClassStruct = class(TUTObjectClassField)
  private
    FScriptText: integer;
    FChildren: integer;
    FFriendlyName: string;
    FLine: DWORD;
    FTextPos: DWORD;
    FScriptSize: DWORD;
    prev_is_iteratornext:boolean;
    next_is_not_delegate:boolean;
    function GetChildren: integer;
    function GetFriendlyName: string;
    function GetLine: DWORD;
    function GetScriptSize: DWORD;
    function GetScriptText: integer;
    function GetTextPos: DWORD;
    function ReadStatement: string;
  protected
    FScriptStart: integer;
    jumplist, nest: tlist;
    endnestlist: tstringlist;
    labellist, indent_chars: string;
    need_semicolon, context_change: boolean;
    position_icode, last_position_icode: DWORD;
    indent_level: integer;
    FLabelTable: array of TUT_Struct_LabelEntry;
    procedure InitializeObject; override;
    procedure InterpretObject; override;
    procedure DoReleaseObject; override;
    function ReadStatements(beautify: boolean = true;showoffsets:boolean=false): string;overload;
    procedure ReadStatements(code:tstrings;beautify: boolean = true;showoffsets:boolean=false);overload;
    procedure SkipStatements;
  public
    property ScriptText: integer read GetScriptText;
    property FirstChild: integer read GetChildren;
    property FriendlyName: string read GetFriendlyName;
    property Line: DWORD read GetLine;
    property TextPos: DWORD read GetTextPos;
    property ScriptSize: DWORD read GetScriptSize;
    function GetDeclaration: string;
    function ReadToken(OuterOperatorPrecedence: byte = 255): string;
    function Decompile(beautify: boolean=true;showoffsets:boolean=false): string;overload;virtual;
    procedure Decompile(code:tstrings;beautify: boolean=true;showoffsets:boolean=false);overload;virtual;
  end;

  // TUTObjectClassState
  // Status: completed
  TUTObjectClassState = class(TUTObjectClassStruct)
  private
    FProbeMask: int64;
    FIgnoreMask: int64;
    FLabelTableOffset: word;
    FStateFlags: DWORD;
    function GetIgnoreMask: int64;
    function GetLabelTableOffset: word;
    function GetProbeMask: int64;
    function GetStateFlags: DWORD;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property ProbeMask: int64 read GetProbeMask;
    property IgnoreMask: int64 read GetIgnoreMask;
    property LabelTableOffset: word read GetLabelTableOffset;
    property StateFlags: DWORD read GetStateFlags;
    function Decompile(beautify: boolean = true;showoffsets:boolean=false): string;override;
    procedure Decompile(code:tstrings;beautify: boolean=true;showoffsets:boolean=false);override;
  end;

  TUT_Struct_Dependency = record
    _Class: integer;
    Deep: integer;
    ScriptTextCRC: integer;
  end;

  // TUTObjectClassClass
  // Status: completed
  TUTObjectClassClass = class(TUTObjectClassState)
  private
    FClassFlags: DWORD;
    FClassGuid: TGuid;
    FDependencies: array of TUT_Struct_Dependency;
    FPackageImports: array of integer;
    FClassWithin: integer;
    FClassConfigName: integer;
    FHideCategoriesList: array of integer;
    function GetDependencies(i: integer): TUT_Struct_Dependency;
    function GetPackageImports(i: integer): integer;
    function GetClassConfigName: integer;
    function GetClassFlags: DWORD;
    function GetClassGuid: TGuid;
    function GetClassWithin: integer;
    function GetDependencyCount: integer;
    function GetPackageImportsCount: integer;
    function GetHideCategoriesList(i: integer): integer;
    function GetHideCategoriesListCount: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    function Decompile(beautify: boolean = true;showoffsets:boolean=false): string;override;
    procedure Decompile(code:tstrings;beautify: boolean=true;showoffsets:boolean=false);override;
    function GetSource(beautify: boolean = true;showoffsets:boolean=false): string;
    procedure SaveToFile(Filename: string);
    property ClassFlags: DWORD read GetClassFlags;
    property ClassGuid: TGuid read GetClassGuid;
    property DependencyCount: integer read GetDependencyCount;
    property Dependencies[i: integer]: TUT_Struct_Dependency read GetDependencies;
    property PackageImportsCount: integer read GetPackageImportsCount;
    property PackageImports[i: integer]: integer read GetPackageImports;
    property ClassWithin: integer read GetClassWithin;
    property ClassConfigName: integer read GetClassConfigName;
    property HideCategoriesListCount:integer read GetHideCategoriesListCount;
    property HideCategoriesList[i: integer]: integer read GetHideCategoriesList;
  end;

  // TUTObjectClassPalette
  // Status: completed
  TUTObjectClassPalette = class(TUTObject)
  private
    FColorCount: integer;
    FColors: array of TRGBQuad;
    function GetColor(n: integer): TColor;
    function GetNewPalette: HPalette;
    function GetColorCount: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property ColorCount: integer read GetColorCount;
    property Color[n: integer]: TColor read GetColor;
    property GetPalette: HPalette read GetNewPalette;
  end;

  // TUTObjectClassSound
  // Status: completed
  TUTObjectClassSound = class(TUTObject)
  private
    FFormat: string;
    FData: string;
    function GetData: string;
    function GetFormat: string;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property Format: string read GetFormat;
    property Data: string read GetData;
    procedure SaveToFile(filename: string);
    procedure SaveToStream(stream: TStream);
  end;

  // TUTObjectClassProceduralSound
  // Status: completed
  TUTObjectClassProceduralSound = class(TUTObject)
  private
    FBaseSound:integer;
    FPitchModification:double;
    FVolumeModification:double;
    FPitchVariance:double;
    FVolumeVariance:double;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property BaseSound:integer read FBaseSound;
    property PitchModification:double read FPitchModification;
    property VolumeModification:double read FVolumeModification;
    property PitchVariance:double read FPitchVariance;
    property VolumeVariance:double read FVolumeVariance;
  end;

  // TUTObjectClassSoundGroup
  // Status: completed
  TUTObjectClassSoundGroup = class(TUTObject)
  private
    //FPackage:string;
    FSounds:array of integer;
    function GetSound(i: integer): integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    //property Package:string read FPackage; // only in the 927 build
    property Sounds[i:integer]:integer read GetSound;
    function SoundCount:integer;
  end;

  // TUTObjectClassMusic
  // Status: completed
  TUTObjectClassMusic = class(TUTObject)
  private
    FFormat: string;
    FData: string;
    function GetData: string;
    function GetFormat: string;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property Format: string read GetFormat;
    property Data: string read GetData;
    procedure SaveToFile(filename: string);
    procedure SaveToStream(stream: TStream);
  end;

  // TUTObjectClassTextBuffer
  // Status: completed
  TUTObjectClassTextBuffer = class(TUTObject)
  private
    FData: string;
    function GetData: string;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property Data: string read GetData;
    procedure SaveToFile(filename: string);
  end;

  TUT_Struct_FontCharacter = record
    Texture: integer;
    X, Y, W, H: integer;
  end;

  TUT_Struct_Map = record
    Key: string;
    Value: string;
  end;

  // TUTObjectClassFont
  // Status: completed
  TUTObjectClassFont = class(TUTObject)
  private
    FCharacters: array of TUT_Struct_FontCharacter;
    FCharRemap: array of TUT_Struct_Map;
    FIsRemapped: boolean;
    FCharactersPerPage: integer;
    FKerning: integer;
    FDropShadowX:integer;
    FDropShadowY:integer;
    FStyle:integer;
    FAntiAlias:boolean;
    function GetGetMapping(c: char): string;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    procedure GetCharacterInfo(i: integer; var texture, x, y, w, h: integer);
    property GetMapping[c: char]: string read GetGetMapping;
    property IsRemapped: boolean read FIsRemapped;
    property CharactersPerPage: integer read FCharactersPerPage;
    property Kerning:integer read FKerning;
    property DropShadowX:integer read FDropShadowX;
    property DropShadowY:integer read FDropShadowY;
    property Style:integer read FStyle;
    property AntiAlias:boolean read FAntiAlias;
  end;

  TUT_Struct_Vector = record
    X, Y, Z: single;
  end;

  TUT_Struct_Plane = record
    X, Y, Z, W: single;
  end;

  TUT_Struct_Rotator = record
    Yaw, Roll, Pitch: integer;
  end;

  TUT_Struct_Polygon = record
    Base, Normal, TextureU, TextureV: TUT_Struct_Vector;
    Vertex: array of TUT_Struct_Vector;
    PolyFlags, Actor, Texture, ItemName, iLink, iBrushPoly, pan_u, pan_v: integer;
  end;

  // Bitmap helper class
  TUTBitmap=class
  private
    FWidth,FHeight,FBPP:integer;
    FMasked:boolean;
    FData:pointer;
    FPalette:HPALETTE;
    FOriginalData:pointer;
    FOriginalDataSize:integer;
    FOriginalFormat:integer;
    function GetScanLine(y: integer): pointer;
    procedure SetPalette(const Value: HPALETTE);
  public
    constructor Create (width,height,bpp:dword;masked:boolean=false);
    destructor Destroy;override;
    property Width:integer read FWidth;
    property Height:integer read FHeight;
    property BPP:integer read FBPP;
    property Palette:HPALETTE read FPalette write SetPalette;
    property ScanLine[y:integer]:pointer read GetScanLine;
    function AsBitmap:TBitmap;
    function AsBitmapWithAlpha:TBitmap;
    function AsAlpha:TBitmap;
    procedure SetOriginal (format:integer;var buffer;size:int64);
    property OriginalData:pointer read FOriginalData;
    property OriginalDataSize:integer read FOriginalDataSize;
    property OriginalFormat:integer read FOriginalFormat;
  end;

  // TUTObjectClassTexture
  // Status: near completed
  //   Formats:
  //     TEXF_P8        : supported
  //     TEXF_RGBA7     : supported but not tested
  //     TEXF_RGB16     : supported but not tested
  //     TEXF_DXT1      : supported
  //     TEXF_RGB8      : supported but not tested
  //     TEXF_RGBA8     : supported
  //     TEXF_NODATA    : supported
  //     TEXF_DXT3      : supported
  //     TEXF_DXT5      : supported
  //     TEXF_L8        : supported but not tested
  //     TEXF_G16       : supported but not tested
  //     TEXF_RRRGGGBBB :
  TUTObjectClassTexture = class(TUTObject)
  private
    FMipMaps: array of TUTBitmap;
    FCompMipMaps: array of TUTBitmap;
    function GetMipMapCount: integer;
    function GetMipMap(i: integer): TUTBitmap;
    function GetCompMipMapCount: integer;
    function GetCompMipMap(i: integer): TUTBitmap;
    function GetGoodMipMap(i: integer): TUTBitmap;
    function GetGoodMipMapCount: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
    procedure DoReleaseObject; override;
  public
    property MipMapCount: integer read GetMipMapCount;
    property MipMap[i: integer]: TUTBitmap read GetMipMap;
    property CompMipMapCount: integer read GetCompMipMapCount;
    property CompMipMap[i: integer]: TUTBitmap read GetCompMipMap;
    property GoodMipMapCount: integer read GetGoodMipMapCount;
    property GoodMipMap[i: integer]: TUTBitmap read GetGoodMipMap;
    {procedure SaveMipMapToFile(mipmap: integer; filename: string); virtual;
    procedure SaveCompMipMapToFile(mipmap: integer; filename: string); virtual;
    procedure SaveGoodMipMapToFile(mipmap: integer; filename: string); virtual;}
  end;

  TUT_Struct_Spark = record
    SparkType, Heat: byte;
    X, Y: byte;
    X_Speed, Y_Speed: byte;
    Age, ExpTime: byte;
  end;

  // TUTObjectClassFireTexture
  // Status: completed.
  TUTObjectClassFireTexture = class(TUTObjectClassTexture)
  private
    FSparks: array of TUT_Struct_Spark;
    function GetSpark(i: integer): TUT_Struct_Spark;
    function GetSparkCount: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property SparkCount: integer read GetSparkCount;
    property Spark[i: integer]: TUT_Struct_Spark read GetSpark;
  end;

  // TUTObjectClassIceTexture
  // Status: completed.
  TUTObjectClassIceTexture = class(TUTObjectClassTexture);

  // TUTObjectClassWaterTexture
  // Status: completed.
  TUTObjectClassWaterTexture = class(TUTObjectClassTexture);

  // TUTObjectClassWetTexture
  // Status: completed.
  TUTObjectClassWetTexture = class(TUTObjectClassWaterTexture);

  // TUTObjectClassWaveTexture
  // Status: completed.
  TUTObjectClassWaveTexture = class(TUTObjectClassWaterTexture);

  // TUTObjectClassFluidTexture
  // Status: completed.
  TUTObjectClassFluidTexture = class(TUTObjectClassWaterTexture);

  // TUTObjectClassScriptedTexture
  // Status: completed.
  TUTObjectClassScriptedTexture = class(TUTObject);

  // TUTObjectClassMovieTexture
  // Status: completed
  TUTObjectClassMovieTexture = class(TUTObjectClassTexture);

  // TUTObjectClassCubeMap
  // Status: completed?
  TUTObjectClassCubeMap = class(TUTObjectClassTexture)
  private
    //FCubeMapRenderInterface:integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    //property CubeMapRenderInterface:integer read FCubeMapRenderInterface;
  end;

  TUT_Struct_BoundingBox = record // named Box in UT2003
    Min, Max: TUT_Struct_Vector;
    Valid: byte;
  end;

  TUT_Struct_BoundingSphere = record
    Center: TUT_Struct_Vector;
    Radius: single;
  end;

  // TUT_MeshExporter
  // Helper class. Requires unique (Vertex,UV) pairs (duplicated vertex or UV when needed).
  TUT_MeshExporter_Animation=(exp_anim_MixedInFile,exp_anim_MultiFile);
  TUT_MeshExporter_Material = record
    Name: string;
    DiffuseColor: array[0..2] of byte;
    Texture:string;
  end;
  TUT_MeshExporter_Vertex = record
    X, Y, Z: single;
    U, V: byte;
  end;
  TUT_MeshExporter_Face = record
    VertexIndex1, VertexIndex2, VertexIndex3: integer;
    MaterialIndex: integer;
    Flags: integer;                     // face material flags (if any)
  end;
  TUT_MeshExporter_Object = record
    Vertices: array of TUT_MeshExporter_Vertex;
    Faces: array of TUT_MeshExporter_Face;
    Materials: array of TUT_MeshExporter_Material;
    AnimationFrames: integer;
  end;
  TUT_MeshExporter = class
  public
    Objects:array of TUT_MeshExporter_Object;
    constructor Create;
    function AddObject:integer;
    function AllObjectsSameFrames:boolean;
    procedure Save(filename: string);virtual;abstract;
  end;
  TUT_3DStudioExporter_Smoothing = (exp3ds_smooth_None, exp3ds_smooth_One, exp3ds_smooth_exp3ds_smooth_ByMaterial);
  TUT_3DStudioExporter = class(TUT_MeshExporter)
  public
    Smoothing: TUT_3DStudioExporter_Smoothing;
    MirrorX: boolean;
    procedure Save(filename: string);override;
  end;
  TUT_Unreal3DExporter = class(TUT_MeshExporter)
  public
    CoordsDivisor: single;
    procedure Save(filename: string);override;
  end;

  // TUTObjectClassPrimitive
  // Status: completed
  TUTObjectClassPrimitive = class(TUTObject)
  protected
    FPrimitiveBoundingBox: TUT_Struct_BoundingBox;
    FPrimitiveBoundingSphere: TUT_Struct_BoundingSphere;
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property PrimitiveBoundingBox: TUT_Struct_BoundingBox read FPrimitiveBoundingBox;
    property PrimitiveBoundingSphere: TUT_Struct_BoundingSphere read FPrimitiveBoundingSphere;
  end;

  // TUTObjectClassIndexBuffer
  // Status: incomplete
  TUTObjectClassIndexBuffer = class (TUTObject)
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
  end;

  // TUTObjectClassVertexBuffer
  // Status: incomplete
  TUTObjectClassVertexBuffer = class (TUTObject)
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
  end;

  // TUTObjectClassPolys
  // Status: completed
  TUTObjectClassPolys = class(TUTObject)
  private
    FPolygons: array of TUT_Struct_Polygon;
    function GetPolygonCount: integer;
    function GetPolygon(n: integer): TUT_Struct_Polygon;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property PolygonCount: integer read GetPolygonCount;
    property Polygon[n: integer]: TUT_Struct_Polygon read GetPolygon;
    procedure PrepareExporter(exporter: TUT_MeshExporter; frames: TIntegerDynArray);virtual;
  end;

  // TUTObjectClassBrush
  // Status: complete
  TUTObjectClassBrush = class(TUTObject);

  // TUTObjectClassMover
  // Status: complete
  TUTObjectClassMover = class(TUTObjectClassBrush);

  // TUTObjectClassConvexVolume
  // Status: incomplete
  TUTObjectClassConvexVolume = class (TUTObjectClassPrimitive)
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
  end;

  TUT_Struct_FVert = record
    pVertex, iSide: integer;
  end;

  QWORD = int64;                        // TODO : change to an unsigned 64 bits type when available

  TUT_Struct_BspNode = record
    Plane: TUT_Struct_Plane;
    ZoneMask: QWORD;
    iVertPool: integer;
    iSurf: integer;
    iBack: integer;
    iFront: integer;
    iPlane: integer;
    iCollisionBound: integer;
    iRenderBound: integer;
    iZone: array[0..1] of byte;
    NumVertices: byte;
    NodeFlags: byte;
    iLeaf: array[0..1] of byte;
  end;

  {TUT_Struct_Decal=record
    Vertices:array[0..3] of TUT_Struct_Vector;
    Actor:integer;
    Nodes:array of integer;
  end;}

  TUT_Struct_BspSurf = record
    Texture: integer;
    PolyFlags: DWORD;
    pBase: integer;
    vNormal: integer;
    vTextureU: integer;
    vTextureV: integer;
    iLightMap: integer;
    iBrushPoly: integer;
    PanU: smallint;
    PanV: smallint;
    Actor: integer;
    //Decals:array of TUT_Struct_Decal;
    //Nodes:array of integer;
  end;

  TUT_Struct_LightMapIndex = record
    DataOffset: integer;
    iLightActors: integer;
    Pan: TUT_Struct_Vector;
    UScale, VSCale: single;
    UClamp, VClamp: integer;
    UBits, VBits: byte;
  end;

  TUT_Struct_Leaf = record
    iZone: integer;
    iPermeating: integer;
    iVolumetric: integer;
    VisibleZones: QWORD;
  end;

  TUT_Struct_ZoneProperties = record
    ZoneActor: integer;
    LastRenderTime: single;
    Connectivity: QWORD;
    Visibility: QWORD;
  end;

  // TUTObjectClassModel
  // Status: complete
  TUTObjectClassModel = class(TUTObjectClassPrimitive)
  private
    FVectors: array of TUT_Struct_Vector;
    FPoints: array of TUT_Struct_Vector;
    FVerts: array of TUT_Struct_FVert;
    FNodes: array of TUT_Struct_BspNode;
    FSurfs: array of TUT_Struct_BspSurf;
    FLightMap: array of TUT_Struct_LightMapIndex;
    FLightBits: array of byte;
    FBounds: array of TUT_Struct_BoundingBox;
    FLeafHulls: array of integer;
    FLeaves: array of TUT_Struct_Leaf;
    FLights: array of integer;
    FRootOutside: boolean;
    FLinked: boolean;
    FNumSharedSides: integer;
    FNumZones: integer;
    FPolys: integer;
    FZones: array of TUT_Struct_ZoneProperties;
    function GetBoundCount: integer;
    function GetLeafCount: integer;
    function GetLeafHullCount: integer;
    function GetLightBitCount: integer;
    function GetLightCount: integer;
    function GetLightMapCount: integer;
    function GetNodeCount: integer;
    function GetPointCount: integer;
    function GetSurfCount: integer;
    function GetVectorCount: integer;
    function GetVertCount: integer;
    function GetBound(n: integer): TUT_Struct_BoundingBox;
    function GetLeaf(n: integer): TUT_Struct_Leaf;
    function GetLeafHull(n: integer): integer;
    function GetLight(n: integer): integer;
    function GetLightBit(n: integer): byte;
    function GetLightMap(n: integer): TUT_Struct_LightMapIndex;
    function GetNode(n: integer): TUT_Struct_BspNode;
    function GetPoint(n: integer): TUT_Struct_Vector;
    function GetSurf(n: integer): TUT_Struct_BspSurf;
    function GetVector(n: integer): TUT_Struct_Vector;
    function GetVert(n: integer): TUT_Struct_FVert;
    function GetZone(n: integer): TUT_Struct_ZoneProperties;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property VectorCount: integer read GetVectorCount;
    property Vector[n: integer]: TUT_Struct_Vector read GetVector;
    property PointCount: integer read GetPointCount;
    property Point[n: integer]: TUT_Struct_Vector read GetPoint;
    property VertCount: integer read GetVertCount;
    property Vert[n: integer]: TUT_Struct_FVert read GetVert;
    property NodeCount: integer read GetNodeCount;
    property Node[n: integer]: TUT_Struct_BspNode read GetNode;
    property SurfCount: integer read GetSurfCount;
    property Surf[n: integer]: TUT_Struct_BspSurf read GetSurf;
    property LightMapCount: integer read GetLightMapCount;
    property LightMap[n: integer]: TUT_Struct_LightMapIndex read GetLightMap;
    property LightBitCount: integer read GetLightBitCount;
    property LightBit[n: integer]: byte read GetLightBit;
    property BoundCount: integer read GetBoundCount;
    property Bound[n: integer]: TUT_Struct_BoundingBox read GetBound;
    property LeafHullCount: integer read GetLeafHullCount;
    property LeafHull[n: integer]: integer read GetLeafHull;
    property LeafCount: integer read GetLeafCount;
    property Leaf[n: integer]: TUT_Struct_Leaf read GetLeaf;
    property LightCount: integer read GetLightCount;
    property Light[n: integer]: integer read GetLight;
    property RootOutside: boolean read FRootOutside;
    property Linked: boolean read FLinked;
    property NumSharedSides: integer read FNumSharedSides;
    property ZoneCount: integer read FNumZones;
    property Zone[n: integer]: TUT_Struct_ZoneProperties read GetZone;
    property Polys: integer read FPolys;
  end;

  TUT_Struct_URL = record
    Protocol: string;
    Host: string;
    Port: integer;
    Map: string;
    Options: array of string;
    Portal: string;
    Valid: boolean;
  end;

  // TUTObjectClassLevelBase
  // Status: complete
  TUTObjectClassLevelBase = class(TUTObject)
  private
    FActors: array of integer;
    FURL: TUT_Struct_URL;
    function GetActor(n: integer): integer;
    function GetActorCount: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property ActorCount: integer read GetActorCount;
    property Actor[n: integer]: integer read GetActor;
    property URL: TUT_Struct_URL read FURL;
  end;

  TUT_Struct_ReachSpec = record
    Distance: integer;
    Start, _End: integer;
    CollisionRadius: integer;
    CollisionHeight: integer;
    ReachFlags: integer;
    bPruned: byte;
  end;

  // TUTObjectClassLevel
  // Status: complete
  TUTObjectClassLevel = class(TUTObjectClassLevelBase)
  private
    FModel: integer;
    FReachSpecs: array of TUT_Struct_ReachSpec;
    FFirstDeleted: integer;
    FTextBlocks: array[0..15] of integer;
    FTravelInfo: array of TUT_Struct_Map;
    function GetReachSpec(n: integer): TUT_Struct_ReachSpec;
    function GetReachSpecCount: integer;
    function GetTextBlock(n: integer): integer;
    function GetTravelInfo(n: integer): TUT_Struct_Map;
    function GetTravelInfoCount: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property Model: integer read FModel;
    property ReachSpecCount: integer read GetReachSpecCount;
    property ReachSpec[n: integer]: TUT_Struct_ReachSpec read GetReachSpec;
    property FirstDeleted: integer read FFirstDeleted;
    property TextBlocks[n: integer]: integer read GetTextBlock;
    property TravelInfoCount: integer read GetTravelInfoCount;
    property TravelInfo[n: integer]: TUT_Struct_Map read GetTravelInfo;
  end;

  TUT_Struct_Vert = record
    X, Y, Z: single;
  end;

  TUT_Struct_Tri = record
    VertexIndex1, VertexIndex2, VertexIndex3: integer;
    U1, V1, U2, V2, U3, V3: byte;
    Flags, TextureIndex: integer;
  end;

  TUT_Struct_Texture = record
    Value: integer;
  end;

  TUT_Struct_AnimSeqNotify = record
    Time: single;
    _Function: integer;
  end;

  TUT_Struct_AnimSeq = record
    Name, Group: integer;
    StartFrame, NumFrames: integer;
    Notifys: array of TUT_Struct_AnimSeqNotify;
    Rate: single;
  end;

  TUT_Struct_Connects = record
    NumVertTriangles, TriangleListOffset: integer;
  end;

  // TUTObjectClassMesh
  // Status: completed
  TUTObjectClassMesh = class(TUTObjectClassPrimitive)
  private
    function GetAnimSeq(i: integer): TUT_Struct_AnimSeq;
    function GetAnimSeqCount: integer;
    function GetAnimFrames: integer;
    function GetBoundingBox(i: integer): TUT_Struct_BoundingBox;
    function GetBoundingBoxCount: integer;
    function GetBoundingSphere(i: integer): TUT_Struct_BoundingSphere;
    function GetBoundingSphereCount: integer;
    function GetConnect(i: integer): TUT_Struct_Connects;
    function GetConnectsCount: integer;
    function GetTexture(i: integer): TUT_Struct_Texture;
    function GetTextureLOD(i: integer): single;
    function GetTextureLODCount: integer;
    function GetTexturesCount: integer;
    function GetTri(i: integer): TUT_Struct_Tri;
    function GetTrisCount: integer;
    function GetVert(i: integer): TUT_Struct_Vert;
    function GetVertLink(i: integer): integer;
    function GetVertLinksCount: integer;
    function GetVertsCount: integer;
  protected
    FVerts: array of TUT_Struct_Vert;
    FTris: array of TUT_Struct_Tri;
    FTextures: array of TUT_Struct_Texture;
    FAnimSeqs: array of TUT_Struct_AnimSeq;
    FConnects: array of TUT_Struct_Connects;
    FBoundingBox: TUT_Struct_BoundingBox;
    FBoundingSphere: TUT_Struct_BoundingSphere;
    FVertLinks: array of integer;
    FBoundingBoxes: array of TUT_Struct_BoundingBox;
    FBoundingSpheres: array of TUT_Struct_BoundingSphere;
    FScale, FOrigin: TUT_Struct_Vector;
    FRotOrigin: TUT_Struct_Rotator;
    FFrameVerts, FAnimFrames: integer;
    FANDFlags, FORFlags:dword;
    FCurPoly, FCurVertex: integer;
    FTextureLOD: array of single;
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property VertCount: integer read GetVertsCount;
    property Verts[i: integer]: TUT_Struct_Vert read GetVert;
    property TrisCount: integer read GetTrisCount;
    property Tris[i: integer]: TUT_Struct_Tri read GetTri;
    property TextureCount: integer read GetTexturesCount;
    property Textures[i: integer]: TUT_Struct_Texture read GetTexture;
    property AnimSeqCount: integer read GetAnimSeqCount;
    property AnimSeqs[i: integer]: TUT_Struct_AnimSeq read GetAnimSeq;
    property ConnectCount: integer read GetConnectsCount;
    property Connects[i: integer]: TUT_Struct_Connects read GetConnect;
    property BoundingBox: TUT_Struct_BoundingBox read FBoundingBox;
    property BoundingSphere: TUT_Struct_BoundingSphere read FBoundingSphere;
    property VertLinksCount: integer read GetVertLinksCount;
    property VertLinks[i: integer]: integer read GetVertLink;
    property BoundingBoxCount: integer read GetBoundingBoxCount;
    property BoundingBoxes[i: integer]: TUT_Struct_BoundingBox read GetBoundingBox;
    property BoundingSphereCount: integer read GetBoundingSphereCount;
    property BoundingSpheres[i: integer]: TUT_Struct_BoundingSphere read GetBoundingSphere;
    property Scale: TUT_Struct_Vector read FScale;
    property Origin: TUT_Struct_Vector read FOrigin;
    property RotOrigin: TUT_Struct_Rotator read FRotOrigin;
    property FrameVerts: integer read FFrameVerts;
    property AnimFrames: integer read GetAnimFrames;
    property ANDFlags: dword read FANDFlags;
    property ORFlags: dword read FORFlags;
    property CurPoly: integer read FCurPoly;
    property CurVertex: integer read FCurVertex;
    property TextureLODCount: integer read GetTextureLODCount;
    property TextureLOD[i: integer]: single read GetTextureLOD;
    procedure Save_Unreal3D(filename: string); virtual;
    procedure Save_UnrealUC(filename: string); virtual;
    procedure PrepareExporter(exporter: TUT_MeshExporter; frames: TIntegerDynArray);virtual;
    procedure Save_3DS(filename: string; frames: TIntegerDynArray; mode:TUT_MeshExporter_Animation=exp_anim_MixedInFile; smoothing: TUT_3DStudioExporter_Smoothing = exp3ds_smooth_None; MirrorX: boolean = false); virtual;
  end;

  TUT_Struct_Wedge = record
    VertexIndex: integer;
    U, V: byte;
  end;

  TUT_Struct_Face = record
    WedgeIndex1, WedgeIndex2, WedgeIndex3, MatIndex: integer;
  end;

  TUT_Struct_Material = record
    Flags, TextureIndex: integer;
  end;

  // TUTObjectClassLodMesh
  // Status: completed
  TUTObjectClassLodMesh = class(TUTObjectClassMesh)
  private
    function GetCollapsePointThus(i: integer): word;
    function GetCollapsePointThusCount: integer;
    function GetCollapseWedgeThus(i: integer): word;
    function GetCollapseWedgeThusCount: integer;
    function GetFace(i: integer): TUT_Struct_Face;
    function GetFaceCount: integer;
    function GetFaceLevel(i: integer): word;
    function GetFaceLevelCount: integer;
    function GetMaterial(i: integer): TUT_Struct_Material;
    function GetMaterialCount: integer;
    function GetRemapAnimVerts(i: integer): word;
    function GetRemapAnimVertsCount: integer;
    function GetSpecialFace(i: integer): TUT_Struct_Face;
    function GetSpecialFaceCount: integer;
    function GetWedge(i: integer): TUT_Struct_Wedge;
    function GetWedgeCount: integer;
  protected
    FWedges: array of TUT_Struct_Wedge;
    FFaces: array of TUT_Struct_Face;
    FMaterials: array of TUT_Struct_Material;
    FCollapsePointThus: array of word;
    FFaceLevel: array of word;
    FCollapseWedgeThus: array of word;
    FSpecialFaces: array of TUT_Struct_Face;
    FRemapAnimVerts: array of word;
    FModelVerts, FSpecialVerts, FOldFrameVerts: integer;
    FMeshScaleMax, FLODHysteresis, FLODStrength, FLODMinVerts, FLODMorph, FLODZDisplace: single;
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property WedgeCount: integer read GetWedgeCount;
    property Wedges[i: integer]: TUT_Struct_Wedge read GetWedge;
    property FaceCount: integer read GetFaceCount;
    property Faces[i: integer]: TUT_Struct_Face read GetFace;
    property MaterialCount: integer read GetMaterialCount;
    property Materials[i: integer]: TUT_Struct_Material read GetMaterial;
    property CollapsePointThusCount: integer read GetCollapsePointThusCount;
    property CollapsePointThus[i: integer]: word read GetCollapsePointThus;
    property FaceLevelCount: integer read GetFaceLevelCount;
    property FaceLevel[i: integer]: word read GetFaceLevel;
    property CollapseWedgeThusCount: integer read GetCollapseWedgeThusCount;
    property CollapseWedgeThus[i: integer]: word read GetCollapseWedgeThus;
    property SpecialFaceCount: integer read GetSpecialFaceCount;
    property SpecialFaces[i: integer]: TUT_Struct_Face read GetSpecialFace;
    property RemapAnimVertsCount: integer read GetRemapAnimVertsCount;
    property RemapAnimVerts[i: integer]: word read GetRemapAnimVerts;
    property ModelVerts: integer read FModelVerts;
    property SpecialVerts: integer read FSpecialVerts;
    property OldFrameVerts: integer read FOldFrameVerts;
    property MeshScaleMax: single read FMeshScaleMax;
    property LODHysteresis: single read FLODHysteresis;
    property LODStrength: single read FLODStrength;
    property LODMinVerts: single read FLODMinVerts;
    property LODMorph: single read FLODMorph;
    property LODZDisplace: single read FLODZDisplace;
    procedure Save_UnrealUC(filename: string); override;
    procedure PrepareExporter(exporter: TUT_MeshExporter; frames: TIntegerDynArray);override;
  end;

  // TUTObjectClassVertMesh
  // Status: incomplete
  TUTObjectClassVertMesh = class (TUTObjectClassLODMesh);

  TUT_Struct_MeshFloatUV = record
    U, V: single;
  end;

  TUT_Struct_MeshExtWedge = record
    iVertex: word;
    Flags: word;
    TexUV: TUT_Struct_MeshFloatUV;
  end;

  TUT_Struct_Quat = record
    X, Y, Z, W: single;
  end;

  TUT_Struct_JointPos = record
    Orientation: TUT_Struct_Quat;
    Position: TUT_Struct_Vector;
    Length: single;
    XSize: single;
    YSize: single;
    ZSize: single;
  end;

  TUT_Struct_MeshBone = record
    Name: integer;
    Flags: DWORD;
    BonePos: TUT_Struct_JointPos;
    NumChildren: integer;
    ParentIndex: integer;
    //Depth:integer; // not serialized?
  end;

  TUT_Struct_BoneInfIndex = record
    WeightIndex: word;
    Number: word;
    DetailA: word;
    DetailB: word;
  end;

  TUT_Struct_BoneInfluence = record
    PointIndex: word;
    BoneWeight: word;
  end;

  TUT_Struct_Coords = record
    Origin: TUT_Struct_Vector;
    XAxis: TUT_Struct_Vector;
    YAxis: TUT_Struct_Vector;
    ZAXis: TUT_Struct_Vector;
  end;

  // TUTObjectClassStaticMesh
  // Status: incomplete
  TUTObjectClassStaticMesh = class (TUTObjectClassPrimitive)
  private
    function GetMaterial(i: integer): TUT_Struct_Material;
    function GetMaterialsCount: integer;
    function GetTriangle(i: integer): TUT_Struct_Face;
    function GetTrianglesCount: integer;
    function GetUV(i: integer): TUT_Struct_MeshFloatUV;
    function GetUVCount: integer;
    function GetVertex(i: integer): TUT_Struct_Vert;
    function GetVertexCount: integer;
  protected
    FMaterials:array of TUT_Struct_Material;
    FVertex:array of TUT_Struct_Vert;
    FUV:array of TUT_Struct_MeshFloatUV;
    FTriangles:array of TUT_Struct_Face;
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property MaterialsCount:integer read GetMaterialsCount;
    property Materials[i:integer]:TUT_Struct_Material read GetMaterial;
    property VertexCount:integer read GetVertexCount;
    property Vertex[i:integer]:TUT_Struct_Vert read GetVertex;
    property UVCount:integer read GetUVCount;
    property UV[i:integer]:TUT_Struct_MeshFloatUV read GetUV;
    property TrianglesCount:integer read GetTrianglesCount;
    property Triangles[i:integer]:TUT_Struct_Face read GetTriangle;
    procedure PrepareExporter(exporter: TUT_MeshExporter; frames: TIntegerDynArray);virtual;
    procedure Save_Unreal3D(filename: string); virtual;
    procedure Save_UnrealUC(filename: string); virtual;
    procedure Save_3DS(filename: string; frames: TIntegerDynArray; mode:TUT_MeshExporter_Animation=exp_anim_MixedInFile; smoothing: TUT_3DStudioExporter_Smoothing = exp3ds_smooth_None; MirrorX: boolean = false); virtual;
  end;

  // TUTObjectClassSkeletalMesh
  // Status: completed
  TUTObjectClassSkeletalMesh = class(TUTObjectClassLodMesh)
  private
    function GetBoneWeight(i: integer): TUT_Struct_BoneInfluence;
    function GetBoneWeightCount: integer;
    function GetBoneWeightIdx(i: integer): TUT_Struct_BoneInfIndex;
    function GetBoneWeightIdxCount: integer;
    function GetExtWedge(i: integer): TUT_Struct_MeshExtWedge;
    function GetExtWedgeCount: integer;
    function GetLocalPoint(i: integer): TUT_Struct_Vector;
    function GetLocalPointCount: integer;
    function GetPoint(i: integer): TUT_Struct_Vector;
    function GetPointCount: integer;
    function GetRefSkeleton(i: integer): TUT_Struct_MeshBone;
    function GetRefSkeletonCount: integer;
  protected
    FExtWedges: array of TUT_Struct_MeshExtWedge;
    FPoints: array of TUT_Struct_Vector;
    FRefSkeleton: array of TUT_Struct_MeshBone;
    FBoneWeightIdx: array of TUT_Struct_BoneInfIndex;
    FBoneWeights: array of TUT_Struct_BoneInfluence;
    FLocalPoints: array of TUT_Struct_Vector;
    FSkeletalDepth: integer;
    FDefaultAnimation: integer;
    FWeaponBoneIndex: integer;
    FWeaponAdjust: TUT_Struct_Coords;
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property ExtWedgeCount: integer read GetExtWedgeCount;
    property ExtWedges[i: integer]: TUT_Struct_MeshExtWedge read GetExtWedge;
    property PointCount: integer read GetPointCount;
    property Points[i: integer]: TUT_Struct_Vector read GetPoint;
    property RefSkeletonCount: integer read GetRefSkeletonCount;
    property RefSkeleton[i: integer]: TUT_Struct_MeshBone read GetRefSkeleton;
    property BoneWeightIdxCount: integer read GetBoneWeightIdxCount;
    property BoneWeightIdx[i: integer]: TUT_Struct_BoneInfIndex read GetBoneWeightIdx;
    property BoneWeightCount: integer read GetBoneWeightCount;
    property BoneWeights[i: integer]: TUT_Struct_BoneInfluence read GetBoneWeight;
    property LocalPointCount: integer read GetLocalPointCount;
    property LocalPoints[i: integer]: TUT_Struct_Vector read GetLocalPoint;
    property SkeletalDepth: integer read FSkeletalDepth;
    property DefaultAnimation: integer read FDefaultAnimation;
    property WeaponBoneIndex: integer read FWeaponBoneIndex;
    property WeaponAdjust: TUT_Struct_Coords read FWeaponAdjust;
    procedure Save_Unreal3D(filename: string); override;
    procedure Save_UnrealUC(filename: string); override;
    procedure PrepareExporter(exporter: TUT_MeshExporter; frames: TIntegerDynArray);override;
  end;

  TUT_Struct_NamedBone = record
    Name: integer;
    Flags: DWORD;
    ParentIndex: integer;
  end;

  TUT_Struct_AnalogTrack = record
    Flags: DWORD;
    KeyQuat: array of TUT_Struct_Quat;
    KeyPos: array of TUT_Struct_Vector;
    KeyTime: array of single;
  end;

  TUT_Struct_MotionChunk = record
    RootSpeed3D: TUT_Struct_Vector;
    TrackTime: single;
    StartBone: integer;
    Flags: DWORD;
    BoneIndices: array of integer;
    AnimTracks: array of TUT_Struct_AnalogTrack;
    RootTrack: TUT_Struct_AnalogTrack;
  end;

  // TUTObjectClassAnimation
  // Status: completed
  TUTObjectClassAnimation = class(TUTObject)
  private
    function GetAnimSeqs(i: integer): TUT_Struct_AnimSeq;
    function GetAnimSeqsCount: integer;
    function GetMoves(i: integer): TUT_Struct_MotionChunk;
    function GetMovesCount: integer;
    function GetRefBones(i: integer): TUT_Struct_NamedBone;
    function GetRefBonesCount: integer;
  protected
    FRefBones: array of TUT_Struct_NamedBone;
    FMoves: array of TUT_Struct_MotionChunk;
    FAnimSeqs: array of TUT_Struct_AnimSeq;
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property RefBones[i: integer]: TUT_Struct_NamedBone read GetRefBones;
    property RefBonesCount: integer read GetRefBonesCount;
    property Moves[i: integer]: TUT_Struct_MotionChunk read GetMoves;
    property MovesCount: integer read GetMovesCount;
    property AnimSeqs[i: integer]: TUT_Struct_AnimSeq read GetAnimSeqs;
    property AnimSeqsCount: integer read GetAnimSeqsCount;
  end;

  // TUTObjectClassMeshAnimation
  // Status : incomplete?
  TUTObjectClassMeshAnimation = class(TUTObjectClassAnimation);

  // TUTObjectClassFunction
  // Status: completed
  TUTObjectClassFunction = class(TUTObjectClassStruct)
  private
    FiNative: integer;
    FRepOffset: integer;
    FOperatorPrecedence: integer;
    FFunctionFlags: DWORD;
    function GetFunctionFlags: DWORD;
    function GetiNative: integer;
    function GetOperatorPrecedence: integer;
    function GetRepOffset: integer;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    function Decompile(beautify: boolean = true;showoffsets:boolean=false): string;override;
    procedure Decompile(code:tstrings;beautify: boolean=true;showoffsets:boolean=false);override;
    property NativeIndex: integer read GetiNative;
    property ReplicationOffset: integer read GetRepOffset;
    property OperatorPrecedence: integer read GetOperatorPrecedence;
    property FunctionFlags: DWORD read GetFunctionFlags;
  end;

  // TUTObjectClassPackageCheckInfo
  // Status: completed
  TUTObjectClassPackageCheckInfo = class(TUTObject)
  private
    FPackageMD5: string;
    FMD5:array of string;
    function GetMD5(i: integer): string;
  protected
    procedure InitializeObject; override;
    procedure InterpretObject; override;
  public
    property PackageMD5:string read FPackageMD5;
    property MD5[i:integer]:string read GetMD5;
    function MD5Count:integer;
  end;

  // ---

  TUTImportTableObjectData = class
  private
    FOwner: TUTPackage;
    FObjectIndex: integer;
    FClassPackageIndex: integer;
    FClassIndex: integer;
    FPackageIndex: integer;
    procedure SetObjectIndex(const Value: integer);
    procedure SetClassIndex(const Value: integer);
    procedure SetClassPackageIndex(const Value: integer);
    procedure SetPackageIndex(const Value: integer);
    function Get_ClassName: string;
    function GetClassPackageName: string;
    function GetObjectName: string;
    function GetPackageName: string;
  public
    property Owner: TUTPackage read FOwner write FOwner;
    // Read data
    property UTObjectIndex: integer read FObjectIndex write SetObjectIndex;
    property UTClassPackageIndex: integer read FClassPackageIndex write SetClassPackageIndex;
    property UTClassIndex: integer read FClassIndex write SetClassIndex;
    property UTPackageIndex: integer read FPackageIndex write SetPackageIndex;
    // Generated data
    property UTObjectName: string read GetObjectName;
    property UTClassPackageName: string read GetClassPackageName;
    property UTClassName: string read Get_ClassName;
    property UTPackageName: string read GetPackageName;
  end;

  TUTExportTableObjectData = class
  private
    FOwner: TUTPackage;
    FSerialOffset: integer;
    FClassIndex: integer;
    FObjectIndex: integer;
    FSerialSize: integer;
    FGroupIndex: integer;
    FSuperIndex: integer;
    FFlags: integer;
    FUTObject: TUTObject;
    FExportedIndex: integer;
    procedure SetClassIndex(const Value: integer);
    procedure SetFlags(const Value: integer);
    procedure SetObjectIndex(const Value: integer);
    procedure SetGroupIndex(const Value: integer);
    procedure SetSerialOffset(const Value: integer);
    procedure SetSerialSize(const Value: integer);
    procedure SetSuperIndex(const Value: integer);
    procedure SetUTObject(const Value: TUTObject);
    function Get_ClassName: string;
    function GetObjectName: string;
    function GetGroupName: string;
    function GetSuperName: string;
    function GetUTObject: TUTObject;
  public
    property Owner: TUTPackage read FOwner write FOwner;
    property ExportedIndex: integer read FExportedIndex write FExportedIndex;
    procedure CreateObject;
    procedure FreeObject;
    destructor Destroy; override;
    // Read data
    property UTObjectIndex: integer read FObjectIndex write SetObjectIndex;
    property UTClassIndex: integer read FClassIndex write SetClassIndex;
    property UTGroupIndex: integer read FGroupIndex write SetGroupIndex;
    property UTSuperIndex: integer read FSuperIndex write SetSuperIndex;
    property Flags: integer read FFlags write SetFlags;
    property SerialSize: integer read FSerialSize write SetSerialSize;
    property SerialOffset: integer read FSerialOffset write SetSerialOffset;
    // Resolved data
    property UTObjectName: string read GetObjectName;
    property UTClassName: string read Get_ClassName;
    property UTGroupName: string read GetGroupName;
    property UTSuperName: string read GetSuperName;
    property UTObject: TUTObject read GetUTObject write SetUTObject;
  end;

  TUTPackageObjectLocations = (utolNames, utolExports, utolImports);
  TUTPackageFindWhat = (utfwName, utfwGroup, utfwClass);
  TUTPackageFindWhatSet = set of TUTPackageFindWhat;
  TUT_OnProgressEvent = procedure(Sender: TObject; position: integer) of object;
  TUT_OnGetStringConst = function(s: string): string of object;
  TUT_OnGetUnicodeStringConst = function(s: widestring): widestring of object;
  TUT_OnPackageNeeded = procedure(var package: string) of object;
  TUTBasicDataTypes = (utbdBuffer,utbdASCIIZ,utbdBool,utbdFloat,utbdIndex,
                       utbdUInt8,utbdUInt16,utbdInt32,utbdUInt32,utbdUInt64,
                       utbdSizedASCII,utbdDoubleSizedASCIIZ,utbdSizedASCIIZ,
                       utbdGUID,utbdName,utbdProperty,utbdCodeStatement);
  TUTDataMeaningTypes = (utdmUnknown,utdmAsValue,utdmRefToName,utdmRefToObject,
                         utdmFlags,utdmOffset,utdmCRC);
  TUT_OnBasicData = procedure(package_position:int64;basicdatatype:TUTBasicDataTypes;
                              datameaning:TUTDataMeaningTypes;size:int64;const name:string) of object;
  TUT_OnGetGameHint = procedure(Sender:TObject;var GameHint:TUTPackage_GameHint) of object;
  TUT_OnProcessMessages = procedure(Sender:TObject) of object;

  TUTPackage_GenerationInfo = record
    ExportCount: integer;
    NameCount: integer;
  end;

  TUTPackageSectionPointer=^TUTPackageSection;
  TUTPackageSection = record
    Offset:cardinal;
    Size:cardinal;
  end;

  // TUTPackage
  // Status: completed
  TUTPackage = class
  private
    FOnProgress: TUT_OnProgressEvent;
    Fstr: TStream;
    FPackage: string;
    FVersion: word;
    FLicenseeMode: word;
    FFlags: DWORD;
    FReadingPackageCount: integer;
    FNameTableList: tstringlist;
    FImportTableList: tlist;
    FExportTableList: tlist;
    FHeritageTableList: array of TGUID;
    FGenerationInfo: array of TUTPackage_GenerationInfo;
    FAllowReadingOtherPackages: boolean;
    FOnGetStringConst: TUT_OnGetStringConst;
    FOnGetUnicodeStringConst: TUT_OnGetUnicodeStringConst;
    FOnPackageNeeded: TUT_OnPackageNeeded;
    FEnumCache: tstringlist;
    FGameHint: TUTPackage_GameHint;
    NativeFunctions: TNativeFunctions;
    FSaveOriginalTextureFormat:boolean;
    AAOEncrypted,LineageEncrypted:boolean;
    EncryptKey:byte;
    FCallOnBasicDataEvent: boolean;
    FInternalCallOnBasicDataEvent: boolean;
    FOnBasicData: TUT_OnBasicData;
    FOnGetGameHint: TUT_OnGetGameHint;
    FPackagePrefixSize:DWORD;
    FOnProcessMessages: TUT_OnProcessMessages;
    FOtherFlags: DWORD;
    FUnreferencedSections: tlist;
    FFileSize:cardinal;
    procedure Process;
    procedure DoOnProgress(position, maxposition: integer);
    function GetExport(i: integer): TUTExportTableObjectData;
    function GetHeritage(i: integer): TGUID;
    function GetImport(i: integer): TUTImportTableObjectData;
    function GetName(i: integer): string;
    function GetNameFlags(i: integer): integer;
    function GetExportCount: integer;
    function GetHeritageCount: integer;
    function GetImportCount: integer;
    function GetNameCount: integer;
    function GetPackagePosition: integer;
    function GetStream: TStream;
    function GetExportIndex(objectname, classname: string): integer;
    function GetNameIndex(objectname: string): integer;
    function GetGeneration(i: integer): TUTPackage_GenerationInfo;
    function GetGenerationCount: integer;
    function GetInitialized: boolean;
    procedure SetName(i: integer; const Value: string);
    function GetStringConst(s: string): string;
    function GetUnicodeStringConst(s: widestring): widestring;
    function ExistsImportedPackage(name: string): boolean;
    function AAODecrypt(EncryptedByte: byte; FilePos: int64; Key: byte): byte;
    procedure SetCallOnBasicDataEvent(const Value: boolean);
    procedure SetOnBasicData(const Value: TUT_OnBasicData);
    procedure SetOnGetGameHint(const Value: TUT_OnGetGameHint);
    procedure SetOnProcessMessages(const Value: TUT_OnProcessMessages);
    function GetUnreferencedSection(i: cardinal): TUTPackageSection;
    function GetUnreferencedSectionsCount: integer;
    procedure RemoveReferencedSection (offset, size:cardinal);
    procedure ClearUnreferencedSections;
  protected
    function IndentText(indent, txt: string): string;
    procedure DetectGamePreProcess; virtual;
    procedure DetectGameInProcess; virtual;
    procedure DetectGamePostProcess; virtual;
    procedure SetNativeFunctionArray(a: array of TNativeFunction);
    procedure SetNativeFunctionArrayFromHint;
  public
    property stream: TStream read GetStream;
    constructor Create;
    constructor CreateInternal(const package:string;other_pkg:TUTPackage);
    procedure Initialize(const package: string; GameHint: TUTPackage_GameHint = UTPGH_NotSpecified);
    property GameHint: TUTPackage_GameHint read FGameHint write FGameHint;
    destructor Destroy; override;
    property Package: string read FPackage;
    property FileSize: cardinal read FFileSize;
    property Initialized: boolean read GetInitialized;
    property OnProgress: TUT_OnProgressEvent read FOnProgress write FOnProgress;
    property Version: word read FVersion;
    property LicenseeMode: word read FLicenseeMode;
    property Flags: DWORD read FFlags;
    property OtherFlags: DWORD read FOtherFlags;
    property NameCount: integer read GetNameCount;
    property Names[i: integer]: string read GetName write SetName;
    property NameFlags[i: integer]: integer read GetNameFlags;
    function GetObjectFlagsText(const e: DWORD): string;
    property ExportedCount: integer read GetExportCount;
    property Exported[i: integer]: TUTExportTableObjectData read GetExport;
    property ImportedCount: integer read GetImportCount;
    property Imported[i: integer]: TUTImportTableObjectData read GetImport;
    property HeritageCount: integer read GetHeritageCount;
    property Heritages[i: integer]: TGUID read GetHeritage;
    property GenerationCount: integer read GetGenerationCount;
    property Generations[i: integer]: TUTPackage_GenerationInfo read GetGeneration;
    property ExportIndex[objectname, classname: string]: integer read GetExportIndex;
    property NameIndex[objectname: string]: integer read GetNameIndex;
    property UnreferencedSectionsCount:integer read GetUnreferencedSectionsCount;
    property UnreferencedSection[i: cardinal]: TUTPackageSection read GetUnreferencedSection;
    function IsPackageEncrypted:boolean;
    function FindObject(where: TUTPackageObjectLocations; what: TUTPackageFindWhatSet; packagename, objectname, classname: string; start: integer = 0): integer;
    procedure FindObjectRecursive (what:TUTPackageFindWhatSet;packagename,objectname,classname,associated_class:string;var found_pkg:TUTPackage;var found_index:integer);
    procedure FindObjectAndPackage (index:integer;var pkg:TUTPackage;var obj:TUTObject);
    procedure ReadAllObjects;
    procedure ReleaseAllObjects;
    function EncodeIndex(i: integer): string;
    procedure StartReadingPackage;
    procedure EndReadingPackage;
    property Position: integer read GetPackagePosition;
    procedure Seek(p: integer);
    function ReadProperty(prop: TUTProperty; stream: tstream): boolean;
    procedure SaveDataBlock(filename: string; position, size: integer);overload;
    procedure SaveDataBlock(strm: TStream; position, size: integer);overload;
    function GetObjectPath(limit, index: integer): string;
    //function GetObjectPath_Simple(const index: integer): string;
    procedure read_buffer(var buffer; const size: integer; stream: tstream;const name:string='');
    function read_asciiz(stream: tstream;const name:string=''): string;
    function read_bool(stream: tstream;const name:string=''): boolean;
    function read_byte(stream: tstream;datameaning:TUTDataMeaningTypes=utdmUnknown;const name:string=''): byte;
    function read_float(stream: tstream;const name:string=''): single;
    function read_idx(stream: tstream;datameaning:TUTDataMeaningTypes=utdmUnknown;const name:string=''): integer;
    function read_int(stream: tstream;datameaning:TUTDataMeaningTypes=utdmUnknown;const name:string=''): integer;
    function read_dword(stream: tstream;datameaning:TUTDataMeaningTypes=utdmUnknown;const name:string=''): dword;
    function read_qword(stream: tstream;datameaning:TUTDataMeaningTypes=utdmUnknown;const name:string=''): int64;
    function read_guid(stream: tstream;const name:string=''): TGuid;
    function read_sizedascii(stream: tstream;const name:string=''): string;
    function read_doublesizedasciiz(stream: tstream;const name:string=''): string;
    function read_sizedasciiz(stream: tstream;const name:string=''): string;
    function read_word(stream: tstream;datameaning:TUTDataMeaningTypes=utdmUnknown;const name:string=''): word;
    function Read_Name(stream: tstream;const name:string=''): string;
    function read_idx_from_buffer (buffer:pointer;var start:integer):integer;
    property CallOnBasicDataEvent:boolean read FCallOnBasicDataEvent write SetCallOnBasicDataEvent;
    property AllowReadingOtherPackages: boolean read FAllowReadingOtherPackages write FAllowReadingOtherPackages;
    property SaveOriginalTextureFormat:boolean read FSaveOriginalTextureFormat write FSaveOriginalTextureFormat;
    property OnGetStringConst: TUT_OnGetStringConst read FOnGetStringConst write FOnGetStringConst;
    property OnGetUnicodeStringConst: TUT_OnGetUnicodeStringConst read FOnGetUnicodeStringConst write FOnGetUnicodeStringConst;
    property OnPackageNeeded: TUT_OnPackageNeeded read FOnPackageNeeded write FOnPackageNeeded;
    property OnBasicData:TUT_OnBasicData read FOnBasicData write SetOnBasicData;
    property OnGetGameHint:TUT_OnGetGameHint read FOnGetGameHint write SetOnGetGameHint;
    property OnProcessMessages:TUT_OnProcessMessages read FOnProcessMessages write SetOnProcessMessages;
  end;

// Use this procedure to add classes to the package processor.
// You can override existing registered classes.
procedure RegisterUTObjectClass(classname: string; classclass: TUTObjectClass);
procedure AddUTClassEquivalence(classname, equivalentclass: string);
procedure ClearUTClassEquivalences;
function GetUTObjectClass(classname: string): TUTObjectClass;

// Use this procedures to register or get enum values
procedure RegisterKnownEnumValues(enumtype: string; values: array of string);
function GetKnownEnumValue(enumtype: string; index: integer): string;

// Use this procedure to register an array of native functions
procedure RegisterNativeFunctionArray (gamehint:TUTPackage_GameHint;const functions:array of TNativeFunction);

// Procedures used to return known struct information to speed up property reading
type
  TKnownStructElement=record
    Name,
    SpecificTypeName:string;
    ValueType:integer;
  end;
function IsKnownStruct (name:string):boolean;
function KnownStructElementCount(name:string):integer;
function KnownStructElement(name:string;i:integer):TKnownStructElement;

// Helper functions
function Read_Struct_Vector(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Vector;
function Read_Struct_Rotator(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Rotator;
function Read_Struct_Polygon(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Polygon;
function Read_Struct_Spark(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Spark;
function Read_Struct_BoundingBox(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_BoundingBox;
function Read_Struct_BoundingSphere(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_BoundingSphere;
function Read_Struct_Vert(owner: TUTPackage; buffer: TStream; highres: boolean;name:string=''): TUT_Struct_Vert;
function Read_Struct_Tri(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Tri;
function Read_Struct_Texture(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Texture;
function Read_Struct_AnimSeqNotify(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_AnimSeqNotify;
function Read_Struct_AnimSeq(owner: TUTPackage; buffer: TStream;name_:string=''): TUT_Struct_AnimSeq;
function Read_Struct_Connects(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Connects;
function Read_Struct_Wedge(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Wedge;
function Read_Struct_Face(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Face;
function Read_Struct_Material(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Material;
function Read_Struct_MeshFloatUV(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_MeshFloatUV;
function Read_Struct_MeshExtWedge(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_MeshExtWedge;
function Read_Struct_Quat(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Quat;
function Read_Struct_JointPos(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_JointPos;
function Read_Struct_MeshBone(owner: TUTPackage; buffer: TStream;name_:string=''): TUT_Struct_MeshBone;
function Read_Struct_BoneInfIndex(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_BoneInfIndex;
function Read_Struct_BoneInfluence(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_BoneInfluence;
function Read_Struct_Coords(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Coords;
function Read_Struct_NamedBone(owner: TUTPackage; buffer: TStream;name_:string=''): TUT_Struct_NamedBone;
function Read_Struct_AnalogTrack(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_AnalogTrack;
function Read_Struct_MotionChunk(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_MotionChunk;
function Read_Struct_Dependency(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Dependency;
function Read_Struct_LabelEntry(owner: TUTPackage; buffer: TStream;name_:string=''): TUT_Struct_LabelEntry;
function Read_Struct_BspNode(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_BspNode;
function Read_Struct_BspSurf(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_BspSurf;
function Read_Struct_FVert(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_FVert;
function Read_Struct_Zone(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_ZoneProperties;
function Read_Struct_LightMap(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_LightMapIndex;
function Read_Struct_Leaf(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Leaf;
function Read_Struct_URL(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_URL;
function Read_Struct_ReachSpec(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_ReachSpec;
function Read_Struct_Map(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Map;

const
  M3DMAGIC = $4D4D;
  M3D_VERSION = $0002;
  MDATA = $3D3D;
  MESH_VERSION = $3D3E;
  MAT_ENTRY = $AFFF;
  MAT_NAME = $A000;
  MAT_DIFFUSE = $A020;
  MAT_TEXMAP = $A200;
  MAT_MAPNAME = $A300;
  COLOR_24 = $0011;
  NAMED_OBJECT = $4000;
  N_TRI_OBJECT = $4100;
  POINT_ARRAY = $4110;
  TEX_VERTS = $4140;
  FACE_ARRAY = $4120;
  MSH_MAT_GROUP = $4130;
  SMOOTH_GROUP = $4150;
  KFDATA = $B000;
  KFHDR = $B00A;
  KFSEG = $B008;
  KFCURTIME = $B009;
  OBJECT_NODE_TAG = $B002;
  NODE_ID = $B030;
  NODE_HDR = $B010;
  PIVOT = $B013;
  POS_TRACK_TAG = $B020;
  ROT_TRACK_TAG = $B021;
  SCL_TRACK_TAG = $B022;
  HIDE_TRACK_TAG = $B029;
  FaceCAVisable3DS = $0001;
  FaceBCVisable3DS = $0002;
  FaceABVisable3DS = $0004;

  EX_LocalVariable = $00;
  EX_InstanceVariable = $01;
  EX_DefaultVariable = $02;
  EX_UnknownVariable =$03; // TODO : {UT2003} unknown opcode
  EX_Return = $04;
  EX_Switch = $05;
  EX_Jump = $06;
  EX_JumpIfNot = $07;
  EX_Stop = $08;
  EX_Assert = $09;
  EX_Case = $0A;
  EX_Nothing = $0B;
  EX_LabelTable = $0C;
  EX_GotoLabel = $0D;
  EX_EatString = $0E;
  EX_Let = $0F;
  EX_DynArrayElement = $10;
  EX_New = $11;
  EX_ClassContext = $12;
  EX_Metacast = $13;
  EX_LetBool = $14;
  EX_Unknown_jumpover = $15;            // ??? only seen on old packages (v61) at end of functions and in mid of code
  EX_EndFunctionParms = $16;
  EX_Self = $17;
  EX_Skip = $18;
  EX_Context = $19;
  EX_ArrayElement = $1A;
  EX_VirtualFunction = $1B;
  EX_FinalFunction = $1C;
  EX_IntConst = $1D;
  EX_FloatConst = $1E;
  EX_StringConst = $1F;
  EX_ObjectConst = $20;
  EX_NameConst = $21;
  EX_RotationConst = $22;
  EX_VectorConst = $23;
  EX_ByteConst = $24;
  EX_IntZero = $25;
  EX_IntOne = $26;
  EX_True = $27;
  EX_False = $28;
  EX_NativeParm = $29;
  EX_NoObject = $2A;
  EX_Unknown_jumpover2 = $2B;           // ??? only seen on old packages (v61)
  EX_IntConstByte = $2C;
  EX_BoolVariable = $2D;
  EX_DynamicCast = $2E;
  EX_Iterator = $2F;
  EX_IteratorPop = $30;
  EX_IteratorNext = $31;
  EX_StructCmpEq = $32;
  EX_StructCmpNe = $33;
  EX_UnicodeStringConst = $34;
  // =$35
  EX_StructMember = $36;
  EX_Length = $37; // UT2003
  EX_GlobalFunction = $38;
  EX_RotatorToVector = $39; // maybe it is another thing??? some flag to modify behavior of other conversion tokens?
  EX_ByteToInt = $3A;
  EX_ByteToBool = $3B;
  EX_ByteToFloat = $3C;
  EX_IntToByte = $3D;
  EX_IntToBool = $3E;
  EX_IntToFloat = $3F;
  EX_BoolToByte = $40;
  EX_BoolToInt = $41;
  EX_Remove    = $41; // redefined?
  EX_BoolToFloat = $42;
  EX_FloatToByte  = $43;
  EX_DelegateCall = $43; // redefined?
  EX_FloatToInt    = $44;
  EX_DelegateName = $44; // redefined?
  EX_FloatToBool    = $45;
  EX_DelegateAssign = $45; // redefined?
  EX_StringToName = $46;                // not defined in UT source, but used in unrealscript
  EX_ObjectToBool = $47;
  EX_NameToBool = $48;
  EX_StringToByte = $49;
  EX_StringToInt = $4A;
  EX_StringToBool = $4B;
  EX_StringToFloat = $4C;
  EX_StringToVector = $4D;
  EX_StringToRotator = $4E;
  EX_VectorToBool = $4F;
  EX_VectorToRotator = $50;
  EX_RotatorToBool = $51;
  EX_ByteToString = $52;
  EX_IntToString = $53;
  EX_BoolToString = $54;
  EX_FloatToString = $55;
  EX_ObjectToString = $56;
  EX_NameToString = $57;
  EX_VectorToString = $58;
  EX_RotatorToString = $59;
  EX_StringToName2 = $5A; // a duplicated opcode found in XIII
  EX_Unknown5B =$5B; // unknown opcode used in Devastation, seems to be an invisible conversion

  EX_ExtendedNative = $60;
  EX_FirstNative = $70;

  NEST_Foreach = 1;
  NEST_Switch = 2;
  NEST_If = 3;
  NEST_Else = 4;

const
  // Property Flags
  CPF_Edit = $00000001;                 // Property is user-settable in the editor.
  CPF_Const = $00000002;                // Actor's property always matches class's default actor property.
  CPF_Input = $00000004;                // Variable is writable by the input system.
  CPF_ExportObject = $00000008;         // Object can be exported with actor.
  CPF_OptionalParm = $00000010;         // Optional parameter (if CPF_Param is set).
  CPF_Net = $00000020;                  // Property is relevant to network replication.
  CPF_ConstRef = $00000040;             // Reference to a constant object.
  CPF_Parm = $00000080;                 // Function/When call parameter.
  CPF_OutParm = $00000100;              // Value is copied out after function call.
  CPF_SkipParm = $00000200;             // Property is a short-circuitable evaluation function parm.
  CPF_ReturnParm = $00000400;           // Return value.
  CPF_CoerceParm = $00000800;           // Coerce args into this function parameter.
  CPF_Native = $00001000;               // Property is native: C++ code is responsible for serializing it.
  CPF_Transient = $00002000;            // Property is transient: shouldn't be saved, zero-filled at load time.
  CPF_Config = $00004000;               // Property should be loaded/saved as permanent profile.
  CPF_Localized = $00008000;            // Property should be loaded as localizable text.
  CPF_Travel = $00010000;               // Property travels across levels/servers.
  CPF_EditConst = $00020000;            // Property is uneditable in the editor.
  CPF_GlobalConfig = $00040000;         // Load config from base class, not subclass.
  CPF_OnDemand = $00100000;             // Object or dynamic array loaded on demand only.
  CPF_New = $00200000;                  // Automatically create inner object.
  CPF_NeedCtorLink = $00400000;         // Fields need construction/destruction.
  // $01000000
  CPF_EditorData = $02000000;           // property has extra data to use in editor
  CPF_EditInlineUse = $14000000;
  CPF_EditInline = $04000000;
  CPF_Deprecated = $20000000;
  // NOTE : for vars with no category specified, the category name is the class

 // Function flags.
  FUNC_Final = $00000001;               // Function is final (prebindable, non-overridable function).
  FUNC_Defined = $00000002;             // Function has been defined (not just declared).
  FUNC_Iterator = $00000004;            // Function is an iterator.
  FUNC_Latent = $00000008;              // Function is a latent state function.
  FUNC_PreOperator = $00000010;         // Unary operator is a prefix operator.
  FUNC_Singular = $00000020;            // Function cannot be reentered.
  FUNC_Net = $00000040;                 // Function is network-replicated.
  FUNC_NetReliable = $00000080;         // Function should be sent reliably on the network.
  FUNC_Simulated = $00000100;           // Function executed on the client side.
  FUNC_Exec = $00000200;                // Executable from command line.
  FUNC_Native = $00000400;              // Native function.
  FUNC_Event = $00000800;               // Event function.
  FUNC_Operator = $00001000;            // Operator function.
  FUNC_Static = $00002000;              // Static function.
  FUNC_NoExport = $00004000;            // Don't export intrinsic function to C++.
  FUNC_Const = $00008000;               // Function doesn't modify this object.
  FUNC_Invariant = $00010000;           // Return value is purely dependent on parameters; no state dependencies or internal state changes.
  FUNC_Unk_00020000 = $00020000; {UT2003}
  FUNC_Delegate = $00100000; {UT2003}   // Function is a delegate
  FUNC_Unk_01000000 = $01000000; {Devastation}

  // Base flags.
  CLASS_Abstract = $00001;              // Class is abstract and can't be instantiated directly.
  CLASS_Compiled = $00002;              // Script has been compiled successfully.
  CLASS_Config = $00004;                // Load object configuration at construction time.
  CLASS_Transient = $00008;             // This object type can't be saved; null it out at save time.
  CLASS_Parsed = $00010;                // Successfully parsed.
  CLASS_Localized = $00020;             // Class contains localized text.
  CLASS_SafeReplace = $00040;           // Objects of this class can be safely replaced with default or NULL.
  CLASS_RuntimeStatic = $00080;         // Objects of this class are static during gameplay.
  CLASS_NoExport = $00100;              // Don't export to C++ header.
  CLASS_NoUserCreate = $00200;          // Don't allow users to create in the editor.
  // "NoUserCreate" seems to be called "Placeable" in UT2003
  CLASS_PerObjectConfig = $00400;       // Handle object configuration on a per-object basis, rather than per-class.
  CLASS_NativeReplication = $00800;     // Replication handled in C++
  // new for ut2003
  CLASS_EditInlineNew = $01000;
  CLASS_CollapseCategories = $02000;
  CLASS_ExportStructs = $04000;

  // State flags.
  STATE_Editable = $00000001;           // State should be user-selectable in UnrealEd.
  STATE_Auto = $00000002;               // State is automatic (the default state).
  STATE_Simulated = $00000004;          // State executes on client side.

  // Node Flags
  NF_NotCsg = $01;                      // Node is not a Csg splitter, i.e. is a transparent poly.
  NF_ShootThrough = $02;                // Can shoot through (for projectile solid ops).
  NF_NotVisBlocking = $04;              // Node does not block visibility, i.e. is an invisible collision hull.
  NF_PolyOccluded = $08;                // Node's poly was occluded on the previously-drawn frame.
  NF_BoxOccluded = $10;                 // Node's bounding box was occluded.
  NF_BrightCorners = $10;               // Temporary.
  NF_IsNew = $20;                       // Editor: Node was newly-added.
  NF_IsFront = $40;                     // Filter operation bounding-sphere precomputed and guaranteed to be front.
  NF_IsBack = $80;                      // Guaranteed back.
  NF_NeverMove = 0;                     // Bsp cleanup must not move nodes with these tags.

  // Reach Flags
  R_WALK = 1;                           //walking required
  R_FLY = 2;                            //flying required
  R_SWIM = 4;                           //swimming required
  R_JUMP = 8;                           // jumping required
  R_DOOR = 16;
  R_SPECIAL = 32;
  R_PLAYERONLY = 64;

  // Poly Flags
  PF_Invisible = $00000001;             // Poly is invisible.
  PF_Masked = $00000002;                // Poly should be drawn masked.
  PF_Translucent = $00000004;           // Poly is transparent.
  PF_NotSolid = $00000008;              // Poly is not solid, doesn't block.
  PF_Environment = $00000010;           // Poly should be drawn environment mapped.
  PF_ForceViewZone = $00000010;         // Force current iViewZone in OccludeBSP (reuse Environment flag)
  PF_Semisolid = $00000020;             // Poly is semi-solid = collision solid, Csg nonsolid.
  PF_Modulated = $00000040;             // Modulation transparency.
  PF_FakeBackdrop = $00000080;          // Poly looks exactly like backdrop.
  PF_TwoSided = $00000100;              // Poly is visible from both sides.
  PF_AutoUPan = $00000200;              // Automatically pans in U direction.
  PF_AutoVPan = $00000400;              // Automatically pans in V direction.
  PF_NoSmooth = $00000800;              // Don't smooth textures.
  PF_BigWavy = $00001000;               // Poly has a big wavy pattern in it.
  PF_SpecialPoly = $00001000;           // Game-specific poly-level render control (reuse BigWavy flag)
  PF_SmallWavy = $00002000;             // Small wavy pattern (for water/enviro reflection).
  PF_Flat = $00004000;                  // Flat surface.
  PF_LowShadowDetail = $00008000;       // Low detaul shadows.
  PF_NoMerge = $00010000;               // Don't merge poly's nodes before lighting when rendering.
  PF_CloudWavy = $00020000;             // Polygon appears wavy like clouds.
  PF_DirtyShadows = $00040000;          // Dirty shadows.
  PF_BrightCorners = $00080000;         // Brighten convex corners.
  PF_SpecialLit = $00100000;            // Only speciallit lights apply to this poly.
  PF_Gouraud = $00200000;               // Gouraud shaded.
  PF_NoBoundRejection = $00200000;      // Disable bound rejection in OccludeBSP (reuse Gourard flag)
  PF_Unlit = $00400000;                 // Unlit.
  PF_HighShadowDetail = $00800000;      // High detail shadows.
  PF_Portal = $04000000;                // Portal between iZones.
  PF_Mirrored = $08000000;              // Reflective surface.
  PF_Memorized = $01000000;             // Editor: Poly is remembered.
  PF_Selected = $02000000;              // Editor: Poly is selected.
  PF_Highlighted = $10000000;           // Editor: Poly is highlighted.
  PF_FlatShaded = $40000000;            // Editor: FPoly has been split by SplitPolyWithPlane.
  PF_EdProcessed = $40000000;           // Internal: FPoly was already processed in editorBuildFPolys.
  PF_EdCut = $80000000;                 // Internal: FPoly has been split by SplitPolyWithPlane.
  PF_RenderFog = $40000000;             // Internal: Render with fogmapping.
  PF_Occlude = $80000000;               // Internal: Occludes even if PF_NoOcclude.
  PF_RenderHint = $01000000;            // Internal: Rendering optimization hint.
  PF_NoOcclude = PF_Masked or PF_Translucent or PF_Invisible or PF_Modulated;
  PF_NoEdit = PF_Memorized or PF_Selected or PF_EdProcessed or PF_NoMerge or PF_EdCut;
  PF_NoImport = PF_NoEdit or PF_NoMerge or PF_Memorized or PF_Selected or PF_EdProcessed or PF_EdCut;
  PF_AddLast = PF_Semisolid or PF_NotSolid;
  PF_NoAddToBSP = PF_EdCut or PF_EdProcessed or PF_Selected or PF_Memorized;
  PF_NoShadows = PF_Unlit or PF_Invisible or PF_Environment or PF_FakeBackdrop;
  PF_Transient = PF_Highlighted;

const
  TEXF_P8 = 0;
  TEXF_RGBA7 = 1;
  TEXF_RGB16 = 2;
  TEXF_DXT1 = 3;
  TEXF_RGB8 = 4;
  TEXF_RGBA8 = 5;
  TEXF_NODATA = 6;
  TEXF_DXT3 = 7;
  TEXF_DXT5 = 8;
  TEXF_L8 = 9;
  TEXF_G16 = 10;
  TEXF_RRRGGGBBB = 11;

var
  UTPropertyClass: TUTPropertyClass;

implementation

resourcestring
  rsUnknownPropertyType = 'Unknown type 0x%-2.2x';
  rsUnknownStruct = 'Unknown struct "%s", scan stopped';
  rsErrorNoUTPackage = 'ERROR! This isn''t an Unreal package';
  rsErrorEncryptedUTPackage = 'ERROR! This package is encrypted';
  rsErrorCompressedUTPackage = 'ERROR! This package is compressed';
  rsExceptionProcessingPackage = 'Exception processing package %0:s'#13#10'%1:s';
  rsExceptionReadingProperty = 'Exception reading property %s';
  rsUnknown = 'Unknown';
  rsWarning = 'Warning!';
  rsNotImplemented = 'Not Implemented';
  rsUnknownOpcode = 'Unknown OpCode 0x%-2.2x. Will try to continue.';
  rsInvalidNativeIndex = 'Invalid native function index 0x%-2.2x';
  rsInvalidArrayLength = 'Invalid array length';
  rsUnknownTextureFormat = 'Unknown Texture format';
  rsInvalidStatement = 'Ibvalid statement';

type
  TUTClassRegistry = record
    class_name: string;
    class_class: TUTObjectClass;
  end;
  TUTClassEquivalence = record
    class_name: string;
    equivalent_class_name: string;
  end;
  TKnownEnumValues = record
    Enum: string;
    Values: array of string;
  end;
  TRegisteredNativeFunctionArray = record
    GameHint:TUTPackage_GameHint;
    Functions:array of TNativeFunction;
  end;

var
  RegisteredUTClasses: array of TUTClassRegistry;
  UTClassEquivalences: array of TUTClassEquivalence;
  KnownEnumValues: array of TKnownEnumValues;
  RegisteredNativeFunctionArrays: array of TRegisteredNativeFunctionArray;

procedure AddUTClassEquivalence(classname, equivalentclass: string);
begin
  setlength(UTClassEquivalences, length(UTClassEquivalences) + 1);
  with UTClassEquivalences[high(UTClassEquivalences)] do
    begin
      class_name := lowercase(classname);
      equivalent_class_name := lowercase(equivalentclass);
    end;
end;

procedure ClearUTClassEquivalences;
begin
  setlength(UTClassEquivalences, 0);
end;

procedure RegisterUTObjectClass(classname: string; classclass: TUTObjectClass);
var
  a, n: integer;
begin
  classname := lowercase(classname);
  a := 0;
  n := -1;
  while (a <= high(RegisteredUTClasses)) and (n = -1) do
    if RegisteredUTClasses[a].class_name = classname then
      n := a
    else
      inc(a);
  if n = -1 then
    begin
      setlength(RegisteredUTClasses, length(RegisteredUTClasses) + 1);
      n := high(RegisteredUTClasses);
    end;
  with RegisteredUTClasses[n] do
    begin
      class_name := classname;
      class_class := classclass;
    end;
end;

function GetUTObjectClass(classname: string): TUTObjectClass;
var
  a: integer;
begin
  classname := lowercase(classname);
  for a := 0 to high(UTClassEquivalences) do
    if UTClassEquivalences[a].class_name = classname then
      begin
        classname := UTClassEquivalences[a].equivalent_class_name;
        break;
      end;
  a := 0;
  result := TUTObject;
  while (a < length(RegisteredUTClasses)) do
    if RegisteredUTClasses[a].class_name = classname then
      begin
        result := RegisteredUTClasses[a].class_class;
        break;
      end
    else
      inc(a);
end;

{ TUTProperty }

function TUTProperty.GetDescription: string;
var
  vn, vd, vtn: string;
  vv: variant;
  vt: TUTPropertyType;
begin
  if not FIsInitialized then
    begin
      result := '';
      exit;
    end;
  result := name;
  if (FArrayIndex > -1) then
    result := result + format('[%d]', [FArrayIndex]);
  {if specifictypename <> '' then
    result := result + ' (' + specifictypename + ')';}
  if propertytype <> otNone then
    begin
      GetValue(-1, -1, vn, vv, vd, vt,vtn);
      result := result +' ('+vtn+') = ' + vd;
    end;
end;

function TUTProperty.GetFirstValue: variant;
var
  name, descriptive, tn: string;
  _type: TUTPropertyType;
begin
  GetValue(-1, -1, name, result, descriptive, _type,tn);
end;

function TUTProperty.GetValueTypeName(t: TUTPropertyType): string;
begin
  case t of
    otNone: result := '';
    otByte: result := 'Byte';
    otInt: result := 'Int';
    otBool: result := 'Bool';
    otFloat: result := 'Float';
    otObject: result := 'Object';
    otName: result := 'Name';
    otString: if FOwner.version>=120 then result:='Delegate' else result := 'String';
    otClass: result := 'Class';
    otArray: result := 'Array';
    otStruct: result := 'Struct';
    otVector: result := 'Vector';
    otRotator: result := 'Rotator';
    otStr: result := 'Str';
    otMap: result := 'Map';
    otFixedArray: result := 'FixedArray';
    otWord: result := 'Word';
    otBuffer:
      result := 'Buffer'
  else
    result := '';
  end;
end;

function TUTProperty.GetTypeName: string;
begin
  if FTypeName <> '' then
    result := FTypeName
  else
    result := GetValueTypeName(PropertyType);
end;

procedure TUTProperty.GetValue(ai,i: integer; var valuename: string;
  var value: variant; var descriptivevalue: string;
  var valuetype: TUTPropertyType;var valuetypename:string);
var
  ds: char;
  {rgba: array[0..3] of byte;
  vector: array[0..2] of single;
  plane: array[0..3] of single;
  rotator: array[0..2] of integer;
  pointregion: packed record
    zone: integer;
    ileaf: integer;
    zonenumber: integer;
  end;
  scale: packed record
    x, y, z, sheerrate: single;
    sheeraxis: byte;
  end;
  adropspark: packed record
    _type, heat: byte;
    x, y: byte;
    x_speed, y_speed: byte;
    Age, ExpTime: byte;
  end;}
  posvalue: integer;
  valuedescription:string;
  procedure GetPropertyValue(const usedpkg:TUTPackage;const ownerobject:TUTObject;
    var start: integer; ai, i: integer; var valuename, descriptivevalue, valuedescription: string;
    var value: variant; var valuetype: TUTPropertyType; var valuetypename:string;
    thetypename: string);
  var
    w: word;
    int: integer;
    s: single;
    dbl: double;
    t: string;
    bo: boolean;
    b: byte;
    enum: string;
    valuename2, descriptivevalue2, valuedescription2,valuetypename2: string;
    value2: variant;
    valuetype2,vt: TUTPropertyType;
    typename2, pkg: string;
    newpackage, newpackage2: TUTPackage;
    packagedescriptor, packagefile: string;
    p: integer;
    struct: TUTObjectClassStruct;
    prop: TUTObjectClassProperty;
    pr, prcount,prcount2,prmax,arraysize,arraycount: integer;
    complete_descriptivevalue, propclass, packagename, superobjectname,
      superpackagename: string;
    byteprop: TUTObjectClassByteProperty;
    enumprop: TUTObjectClassEnum;
    enumtype, parentobject: integer;
    cached_enum, varstr: string;
    utfw:TUTPackageFindWhatSet;
    uo:TUTObjectClassField;
    kse:TKnownStructElement;
    FValueStream:TMemoryStream;
    prop2:TUTProperty;
    arry:TUTObjectClassArrayProperty;
  begin
    valuetypename:=GetValueTypeName(valuetype);
    case valuetype of
      otNone:
        begin
          value := 0;
        end;
      otByte:
        begin
          b := FValue[start];
          inc(start);
          if (thetypename<>'') and (lowercase(thetypename)<>'byte') then
            begin
              valuetypename:=thetypename;
              enum:=GetKnownEnumValue (thetypename,b);
              if (enum='') then
                if (FOwner.FEnumCache.indexofname(valuename) >= 0) then
                  begin
                    valuetypename:='E'+valuename;
                    cached_enum := FOwner.FEnumCache.values[valuename] + ' ';
                    int := b;
                    repeat
                      p := pos(' ', cached_enum);
                      if p = 0 then
                        p := length(cached_enum) + 1;
                      enum := copy(cached_enum, 1, p - 1);
                      delete(cached_enum, 1, p);
                      dec(int);
                    until (int < 0) {or (int = b - 2)};
                    {if int <> b - 2 then
                      enum := '';}
                  end
                else
                  begin
                    // search the actual property variable inside the property owner object
                    // or its class or its parents and get the enum type from there.
                    newpackage := usedpkg;
                    int:=-1;
                    if OwnerObject<>nil then
                      begin
                        if (OwnerObject.UTClassName = '') or
                           (OwnerObject.UTClassName = 'Class') or
                           (OwnerObject.UTClassName = 'State') then
                          begin                   // the object is a class or state
                            packagename := OwnerObject.GetFullName;
                            parentobject := OwnerObject.UTSuperIndex;
                          end
                        else
                          begin                   // the object is an instance of a class so we get its class as first parent
                            packagename := OwnerObject.GetFullName;
                            parentobject := OwnerObject.UTClassIndex;
                          end;
                        utfw:=[utfwGroup, utfwName, utfwClass];
                        repeat
                          int := newpackage.FindObject(utolExports,
                              utfw, packagename, valuename, 'ByteProperty');
                          if int = -1 then
                            begin
                              // The byteproperty is not on this object, so we must search in its parent
                              if parentobject = 0 then
                                break
                              else
                                begin
                                  if parentobject > 0 then
                                    begin
                                      packagename := newpackage.Exported[parentobject - 1].UTGroupName;
                                      if packagename <> '' then packagename := packagename + '.';
                                      packagename := packagename + newpackage.Exported[parentobject - 1].UTObjectName;
                                      parentobject := newpackage.Exported[parentobject - 1].UTSuperIndex;
                                    end
                                  else if (parentobject < 0) and
                                    FOwner.AllowReadingOtherPackages then
                                    begin
                                      packagedescriptor := newpackage.imported[-parentobject - 1].UTPackageName;
                                      p := pos('.', packagedescriptor);
                                      if p = 0 then p := length(packagedescriptor) + 1;
                                      packagefile := copy(packagedescriptor, 1, p - 1);
                                      delete(packagedescriptor, 1, p);
                                      packagename := newpackage.imported[-parentobject - 1].UTObjectName;
                                      if packagedescriptor <> '' then packagename := packagedescriptor + '.' + packagename;
                                      pkg := extractfilepath(usedpkg.FPackage) + packagefile + '.u';
                                      if assigned(FOwner.OnPackageNeeded) then FOwner.OnPackageNeeded(pkg);
                                      if fileexists(pkg) then
                                        begin
                                          try
                                            if newpackage = usedpkg then
                                              newpackage := TUTPackage.createinternal(pkg, usedpkg)
                                            else
                                              newpackage.Initialize(pkg);
                                            superobjectname := packagename;
                                            p := length(superobjectname);
                                            while (p > 0) and (superobjectname[p] <> '.') do
                                              dec(p);
                                            superpackagename := copy(superobjectname, 1, p - 1);
                                            delete(superobjectname, 1, p);
                                            p := newpackage.FindObject(utolExports,
                                              [utfwGroup, utfwName],
                                              superpackagename, superobjectname, '');
                                            if p = -1 then
                                              parentobject := 0
                                            else
                                              parentobject := newpackage.Exported[p].UTSuperIndex;
                                          except
                                            newpackage.free;
                                            newpackage:=nil;
                                            parentobject:=0;
                                          end;
                                        end
                                      else
                                        break;
                                    end
                                  else
                                    break;
                                end;
                            end;
                        until (int <> -1);
                      end;
                    if int <> -1 then
                      begin                   // we found the property
                        byteprop := TUTObjectClassByteProperty(newpackage.Exported[int].UTObject);
                        byteprop.ReadObject;
                        enumtype := byteprop.Enum;
                        byteprop.ReleaseObject;
                      end
                    else                      // we didnt found the property...
                      begin                   // ...so we try searching the Enum type based on the property name
                        // (this should never happen if the needed packages exists)
                        int := newpackage.FindObject(utolExports,
                          [utfwName,utfwClass], 'E' + valuename, '', 'Enum');
                        if int <> -1 then
                          enumtype := int + 1 // found on this package
                        else
                          begin
                            int := newpackage.FindObject(utolImports,
                              [utfwName, utfwClass], 'E' + valuename, '', 'Enum');
                            if int <> -1 then
                              enumtype := -int - 1
                            else
                              enumtype := 0;  // not found
                          end;
                      end;
                    if enumtype > 0 then
                      begin                   // the Enum type is in the current package
                        enumprop := TUTObjectClassEnum(newpackage.Exported[enumtype - 1].UTObject);
                        enumprop.ReadObject;
                        enum := enumprop.GetValueName(b);
                        cached_enum := valuename + '=';
                        for p := 0 to enumprop.Count - 1 do
                          cached_enum := cached_enum + enumprop.GetValueName(p) + ' ';
                        delete(cached_enum, length(cached_enum), 1);
                        FOwner.FEnumCache.add(cached_enum);
                        enumprop.ReleaseObject;
                      end
                    else if (enumtype < 0) and usedpkg.AllowReadingOtherPackages then
                      begin                   // the Enum type is in an imported package
                        packagedescriptor := newpackage.imported[-enumtype - 1].UTPackageName;
                        p := pos('.', packagedescriptor);
                        if p = 0 then p := length(packagedescriptor) + 1;
                        packagefile := copy(packagedescriptor, 1, p - 1);
                        delete(packagedescriptor, 1, p);
                        pkg := extractfilepath(usedpkg.FPackage) + packagefile + '.u';
                        if assigned(FOwner.OnPackageNeeded) then
                          FOwner.OnPackageNeeded(pkg);
                        if fileexists(pkg) then
                          begin
                            try
                              newpackage2 := nil;
                              try
                                try
                                  newpackage2 := TUTPackage.createinternal(pkg, usedpkg);
                                  enumtype := newpackage2.FindObject(utolExports,
                                    [utfwName, utfwClass],
                                    '', newpackage.imported[-enumtype - 1].UTObjectName, 'Enum');
                                  enumprop := TUTObjectClassEnum(newpackage2.Exported[enumtype].UTObject);
                                  enumprop.ReadObject;
                                  enum := enumprop.GetValueName(b);
                                  cached_enum := valuename + '=';
                                  for p := 0 to enumprop.Count - 1 do
                                    cached_enum := cached_enum + enumprop.GetValueName(p) + ' ';
                                  delete(cached_enum, length(cached_enum), 1);
                                  FOwner.FEnumCache.add(cached_enum);
                                  enumprop.ReleaseObject;
                                except
                                end;
                              finally
                                newpackage2.free;
                              end;
                            except
                            end;
                          end;
                      end
                    else
                      FOwner.FEnumCache.add(valuename + '=');
                    if newpackage <> usedpkg then freeandnil(newpackage);
              end;
            end
          else
            enum:='';
          value := b;
          valuedescription := enum;
          if enum <> '' then
            descriptivevalue := enum
          else
            descriptivevalue := inttostr(b);
        end;
      otObject:
        begin
          int:=usedpkg.Read_idx_From_Buffer(pchar(FValue),start);
          value := int;
          if int = 0 then
            valuedescription := 'None'
          else
            begin
              if int >= 0 then
                valuedescription := FOwner.Exported[int - 1].UTClassName
              else
                valuedescription := FOwner.Imported[-int - 1].UTClassName;
              if valuedescription = '' then valuedescription := 'Class';
              valuedescription := valuedescription + '''' + FOwner.GetObjectPath(-1, int) + '''';
            end;
          descriptivevalue := valuedescription;
        end;
      otClass:
        begin
          int:=usedpkg.Read_idx_From_Buffer(pchar(FValue),start);
          value := int;
          if int = 0 then
            valuedescription := 'None'
          else
            begin
              valuedescription := 'Class''' + FOwner.GetObjectPath(-1, int) + '''';
            end;
          descriptivevalue := valuedescription;
        end;
      otInt:
        begin
          move(FValue[start], int, 4);
          inc(start, 4);
          value := int;
          descriptivevalue := inttostr(int);
        end;
      otFloat:
        begin
          move(FValue[start], s, 4);
          inc(start, 4);
          dbl := s;
          value := dbl;
          descriptivevalue := format('%f', [dbl]);
        end;
      otBool:
        begin
          move(FValue[start], bo, 1);
          inc(start, 1);
          value := bo;
          if bo then
            descriptivevalue := 'True'
          else
            descriptivevalue := 'False';
        end;
      otWord:
        begin
          move(FValue[start], w, 2);
          inc(start, 2);
          value := w;
          descriptivevalue := inttostr(w);
        end;
      otName:
        begin
          int:=usedpkg.Read_idx_From_Buffer(pchar(FValue),start);
          value := int;
          valuedescription := usedpkg.FNameTableList[int];
          descriptivevalue := valuedescription;
        end;
      otStr, otString:
        begin                           // TODO : check if the strings can be less than the total size
          if (valuetype=otString) and (FOwner.version>=120) then
            begin
              // seems to be a delegate
              int:=usedpkg.read_idx_from_buffer(pchar(FValue),start);
              t:=usedpkg.GetObjectPath (-1,int);
              int:=usedpkg.read_idx_from_buffer(pchar(FValue),start);
              t:=t+'.'+usedpkg.FNameTableList[int];
              value := t;
              descriptivevalue := FOwner.GetStringConst(t);
            end
          else
            begin
              // We suppose it is a Sized ASCIIZ string...
              int:=usedpkg.Read_idx_From_Buffer(pchar(FValue),start);
              setlength(t, int);
              move(FValue[start], t[1], int);
              inc(start, int);
              while (t <> '') and (t[length(t)] = #0) do
                delete(t, length(t), 1);
              value := t;
              descriptivevalue := FOwner.GetStringConst(t);
            end;
        end;
      otMap,otFixedArray, // TODO
      otBuffer:
        begin
          setlength(varstr, length(FValue));
          move(FValue[0], varstr[1], length(FValue));
          value := varstr;
          inc(start, length(FValue));
          descriptivevalue := '';
        end;
      otArray:
        begin
          FValueStream:=TMemoryStream.create;
          prop2:=TUTProperty.create;
          try
            FValueStream.write (FValue[0],length(FValue));
            FValueStream.Seek(start,soFromBeginning);

            // Find the type of the array
            // It should be the only *Property object inside an ArrayProperty object
            // named after the property name and inside the class of the property
            // or in an ancestor, and it should be interpreted.

            // search the array
            newpackage:=nil;
            int:=-1;
            usedpkg.FindObjectRecursive ([utfwName,utfwClass],
                                         '',ValueName,'arrayproperty',
                                         OwnerObject.UTClassName, newpackage, int);
            // TODO : should also search in the package on the Super class (recursively)
            typename2:='';
            if (int <> -1) and (newpackage <> nil) then
              begin
                arry := TUTObjectClassArrayProperty(newpackage.Exported[int].UTObject);
                arry.ReadObject;
                prop:=TUTObjectClassProperty(newpackage.Exported[arry.InnerProperty - 1].UTObject);
                prop.ReadObject;
                valuename2:=prop.UTObjectName;
                propclass:=prop.UTClassName;
                if propclass = 'ByteProperty' then
                  valuetype2 := otByte
                else if propclass = 'IntProperty' then
                  valuetype2 := otInt
                else if propclass = 'BoolProperty' then
                  valuetype2 := otBool
                else if propclass = 'FloatProperty' then
                  valuetype2 := otFloat
                else if propclass = 'ObjectProperty' then
                  begin
                    valuetype2 := otObject;
                    typename2:=newpackage.GetObjectPath (1,TUTObjectClassObjectProperty(prop).UTObjectType);
                  end
                else if propclass = 'ClassProperty' then
                  begin
                    valuetype2 := otClass;
                    typename2:=newpackage.GetObjectPath (1,TUTObjectClassClassProperty(prop).UTClassType);
                  end
                else if propclass = 'NameProperty' then
                  valuetype2 := otName
                else if propclass = 'StrProperty' then
                  valuetype2 := otStr
                else if propclass = 'StructProperty' then
                  begin
                    valuetype2 := otStruct;
                    typename2:=newpackage.GetObjectPath (1,TUTObjectClassStructProperty(prop).Struct);
                  end
                else if propclass = 'StringProperty' then
                  valuetype2 := otString
                else if propclass = 'MapProperty' then
                  valuetype2 := otMap
                else if propclass = 'ArrayProperty' then
                  valuetype2 := otArray
                else if propclass = 'FixedArrayProperty' then
                  valuetype2 := otFixedArray
                else
                  valuetype2 := otBuffer;

                prop.ReleaseObject;
                arry.ReleaseObject;
              end
            else
              begin
                // since we don't have info, we assume it is an struct (but it doesn't have to be)
                valuetype2 := otStruct;
                typename2:='?';
              end;

            if newpackage <> usedpkg then
              freeandnil(newpackage);

            if typename2='' then typename2:=GetValueTypeName(valuetype2);

            int:=usedpkg.Read_Idx_From_Buffer(pchar(FValue),start);

            if ai=-1 then valuetypename:='Array of '+typename2 else valuetypename:=typename2;
            complete_descriptivevalue := '';
            prcount:=0;
            vt:=ValueType2;
            try
              while prcount<int do
                begin
                  if ai=-1 then
                    complete_descriptivevalue := complete_descriptivevalue +'['+inttostr(prcount)+']='
                  else
                    complete_descriptivevalue := ''; // initialize for each array index

                  ValueType2:=vt;
                  if (valuetype2=otObject) or (valuetype2=otStruct) then
                    begin
                      FValueStream.Seek(start,soFromBeginning);
                      if (i=-1) or (prcount<>ai) then
                        begin // reading all parts or not the correct array index
                          complete_descriptivevalue := complete_descriptivevalue + '(';
                          repeat
                            usedpkg.ReadProperty (prop2,FValueStream);
                            if prop2.PropertyType<>otNone then
                              begin
                                descriptivevalue2:=prop2.Description;
                                complete_descriptivevalue := complete_descriptivevalue + descriptivevalue2+',';
                              end;
                          until prop2.PropertyType=otNone;
                          if copy(complete_descriptivevalue,length(complete_descriptivevalue)-1,1)=',' then
                            delete(complete_descriptivevalue,length(complete_descriptivevalue)-1,1);
                          complete_descriptivevalue := complete_descriptivevalue + '),';
                        end
                      else // correct array index and reading one part
                        begin
                          vt:=otNone;
                          complete_descriptivevalue:='';
                          prcount2:=0;
                          repeat
                            usedpkg.ReadProperty (prop2,FValueStream);
                            if (prop2.PropertyType<>otNone) and (prcount2=i) then
                              begin
                                valuename:=prop2.Name;
                                vt:=prop2.PropertyType;
                                value:=prop2.Value;
                                valuetypename:=prop2.SpecificTypeName;
                                complete_descriptivevalue := prop2.DescriptiveValue+',';
                              end;
                            inc(prcount2);
                          until prop2.PropertyType=otNone;
                        end;
                      start:=FValueStream.Position;
                    end
                  else
                    begin
                      if i=0 then
                        begin
                          GetPropertyValue (usedpkg, OwnerObject, start, -1, -1,
                                       valuename2, descriptivevalue2, valuedescription2,
                                       value2, valuetype2, valuetypename2, typename2);
                          vt:=valuetype2;
                          complete_descriptivevalue := complete_descriptivevalue + descriptivevalue2+',';
                        end
                      else
                        begin
                          vt:=otNone;
                          complete_descriptivevalue := '';
                        end;
                    end;

                  complete_descriptivevalue := copy(complete_descriptivevalue, 1,length(complete_descriptivevalue) - 1) +#13#10;
                  if prcount=ai then break; // exit if we have the correct array index
                  inc(prcount);
                  if assigned(FOwner.FOnProcessMessages) then FOwner.OnProcessMessages(FOwner);
                end;
              descriptivevalue := copy(complete_descriptivevalue, 1,length(complete_descriptivevalue) - 2);
            except
            end;
            value := descriptivevalue;
            if ai=-1 then valuetype := PropertyType else valuetype:=vt;
          finally
            FValueStream.free;
            prop2.free;
          end;
        end;
      otStruct{,otArray}:
        begin
          if valuetype=otArray then
            begin
              arraysize:=usedpkg.Read_Idx_From_Buffer(pchar(FValue),start);

              // TODO : read the new thetypename, it should be the name of the
              // array child object, or the typename of that property
              // (if it is an StructProperty)

            end
          else
            arraysize:=1;
          if IsKnownStruct (thetypename) then
            begin
              if valuetype=otArray then
                valuetypename:='Array of '+thetypename
              else
                valuetypename:=thetypename;
              descriptivevalue:='';
              prmax := KnownStructElementCount(thetypename);
              for arraycount:=0 to arraysize-1 do
                begin
                  prcount:=0;
                  complete_descriptivevalue := '';
                  while prcount<prmax do
                    begin
                      kse:=KnownStructElement(thetypename,prcount);
                      valuename2 := kse.Name;
                      typename2 := kse.SpecificTypeName;
                      valuetype2 := kse.ValueType;
                      if typename2='' then typename2:=GetValueTypeName(valuetype2);
                      GetPropertyValue(usedpkg, OwnerObject, start, -1, -1,
                            valuename2, descriptivevalue2, valuedescription2,
                            value2, valuetype2, valuetypename2, typename2);
                      if prcount = i then
                        begin
                          valuename := valuename2;
                          descriptivevalue := descriptivevalue2;
                          valuedescription := valuedescription2;
                          value := value2;
                          valuetype := valuetype2;
                          valuetypename:=valuetypename2;
                          break;
                        end;
                      complete_descriptivevalue := complete_descriptivevalue +
                            valuename2 + '=' + descriptivevalue2 + ',';
                      inc(prcount);
                      if assigned(FOwner.FOnProcessMessages) then FOwner.OnProcessMessages(FOwner);
                    end;
                  if i = -1 then
                    begin
                      descriptivevalue := descriptivevalue+
                        '(' + copy(complete_descriptivevalue, 1,
                        length(complete_descriptivevalue) - 1) + '),';
                    end;
                end;
              if copy(descriptivevalue,length(descriptivevalue)-1,1)=',' then
                delete(descriptivevalue,length(descriptivevalue)-1,1);
              value := descriptivevalue;
              valuetype := PropertyType;
            end
          else begin
              // Search the struct recursively
              newpackage:=nil;
              int:=-1;
              usedpkg.FindObjectRecursive ([utfwName,utfwClass],
                                           '',theTypeName,'struct',
                                           OwnerObject.UTClassName, newpackage, int);
              if (int <> -1) and (newpackage <> nil) then
                begin
                  struct := TUTObjectClassStruct(newpackage.Exported[int].UTObject);
                  struct.ReadObject;
                  if valuetype=otArray then
                    valuetypename:='Array of '+struct.FriendlyName
                  else
                    valuetypename:=struct.FriendlyName;
                  posvalue := 0;
                  for arraycount:=0 to arraysize-1 do
                    begin
                      pr := struct.FirstChild;
                      prcount := 0;
                      complete_descriptivevalue := '';
                      while pr <> 0 do
                        begin
                          uo:=TUTObjectClassField(newpackage.Exported[pr - 1].UTObject);
                          uo.ReadObject;
                          if uo is TUTObjectClassProperty then
                            begin
                              inc(prcount);
                              prop := TUTObjectClassProperty(uo);
                              valuename2 := prop.UTObjectName;
                              propclass := prop.UTClassName;
                              typename2 := prop.GenericTypeName;
                              if propclass = 'ByteProperty' then
                                valuetype2 := otByte
                              else if propclass = 'IntProperty' then
                                valuetype2 := otInt
                              else if propclass = 'BoolProperty' then
                                valuetype2 := otBool
                              else if propclass = 'FloatProperty' then
                                valuetype2 := otFloat
                              else if propclass = 'ObjectProperty' then
                                begin
                                valuetype2 := otObject;
                                typename2:=newpackage.GetObjectPath (1,TUTObjectClassObjectProperty(prop).UTObjectType);
                                end
                              else if propclass = 'ClassProperty' then
                                begin
                                valuetype2 := otClass;
                                typename2:=newpackage.GetObjectPath (1,TUTObjectClassClassProperty(prop).UTClassType);
                                end
                              else if propclass = 'NameProperty' then
                                valuetype2 := otName
                              else if propclass = 'StrProperty' then
                                valuetype2 := otStr
                              else if propclass = 'StructProperty' then
                                begin
                                valuetype2 := otStruct;
                                typename2:=newpackage.GetObjectPath (1,TUTObjectClassStructProperty(prop).Struct);
                                end
                              else if propclass = 'StringProperty' then
                                valuetype2 := otString
                              else if propclass = 'MapProperty' then
                                valuetype2 := otMap
                              else if propclass = 'ArrayProperty' then
                                valuetype2 := otArray
                              else if propclass = 'FixedArrayProperty' then
                                valuetype2 := otFixedArray
                              else
                                valuetype2 := otBuffer;
                              GetPropertyValue(newpackage, struct, start, -1, -1,
                                valuename2, descriptivevalue2, valuedescription2,
                                value2, valuetype2, valuetypename2, typename2);
                              if prcount - 1 = i then
                                begin
                                  valuename := valuename2;
                                  descriptivevalue := descriptivevalue2;
                                  valuedescription := valuedescription2;
                                  value := value2;
                                  valuetype := valuetype2;
                                  valuetypename:=valuetypename2;
                                  break;
                                end;
                              complete_descriptivevalue := complete_descriptivevalue +
                                valuename2 + '=' + descriptivevalue2 + ',';
                            end;
                          pr := uo.Next;
                          uo.ReleaseObject;
                        end;
                      if i = -1 then
                        begin
                          descriptivevalue := descriptivevalue+'(' + copy(complete_descriptivevalue, 1,
                            length(complete_descriptivevalue) - 1) + '),';
                        end;
                    end;
                  if copy(descriptivevalue,length(descriptivevalue)-1,1)=',' then
                    delete(descriptivevalue,length(descriptivevalue)-1,1);
                  value := descriptivevalue;
                  valuetype := PropertyType;
                  struct.ReleaseObject;
                end
              else
                begin
                  //valuename := 'unknown';
                  setlength(varstr, length(FValue));
                  move(FValue[0], varstr[1], length(FValue));
                  value := varstr;
                  inc(start, length(FValue));
                  valuetype := otBuffer;
                  descriptivevalue := '';
                end;
              if newpackage <> usedpkg then
                freeandnil(newpackage);
            end;
        end;
    else
      begin
        value := FValue;
        descriptivevalue := '';
      end;
    end;
  end;
begin
  if self = nil then
    exit;
  if not FIsInitialized then
    begin
      valuename := '';
      value := '0';
      descriptivevalue := '0';
      valuedescription := '';
      valuetype := otNone;
      exit;
    end;
  ds := DecimalSeparator;
  DecimalSeparator := '.';
  valuename := name;
  value := 0;
  descriptivevalue := '';
  valuedescription := '';
  valuetype := PropertyType;
  posvalue := 0;
  GetPropertyValue(FOwner, FOwnerObject, posvalue, ai, i, valuename,
    descriptivevalue, valuedescription, value, valuetype, valuetypename,
    FTypename);
  DecimalSeparator := ds;
end;

function TUTProperty.ValueCount: integer;
var
  struct: TUTObjectClassStruct;
  prop: TUTObjectClassProperty;
  pr, prcount, int: integer;
  newpackage:TUTPackage;
begin
  if not FIsInitialized then
    begin
      result := 0;
      exit;
    end;
  case PropertyType of
    otNone: result := 0;
    otStruct:
      begin
        result:=0;
        if IsKnownStruct(FTypeName) then
           result:=KnownStructElementCount(FTypeName);
        if result=0 then
          begin
            // Search the struct
            newpackage:=nil;
            int:=-1;
            FOwner.FindObjectRecursive([utfwName, utfwClass], '', FTypeName, 'struct','',newpackage,int);
            if int <> -1 then
              begin
                struct := TUTObjectClassStruct(newpackage.Exported[int].UTObject);
                struct.ReadObject;
                pr := struct.FirstChild;
                prcount := 0;
                while pr <> 0 do
                  begin
                    inc(prcount);
                    prop := TUTObjectClassProperty(newpackage.Exported[pr - 1].UTObject);
                    prop.ReadObject;
                    pr := prop.Next;
                    prop.ReleaseObject;
                  end;
                struct.ReleaseObject;
                result := prcount;
                if newpackage<>FOwner then newpackage.free;
              end
            else
              result:=0;
          end;
      end;
    otArray:
      begin
        result:=-1; // means read until valuetype=otNone
      end;
  else
    result := 0;
  end;
end;

procedure TUTProperty.SetProperty(Owner: TUTPackage; n: string; i: integer;
  t: TUTPropertyType; var value; valuesize: integer; _typename: string);
begin
  FOwner := owner;
  FName := n;
  FArrayIndex := i;
  FPropertyType := t;
  setlength(FValue, valuesize);
  if valuesize > 0 then move(value, FValue[0], valuesize);
  FTypeName := _typename;
  FIsInitialized := true;
end;

function TUTProperty.GetDescriptiveValue: string;
var
  name,tn: string;
  value: variant;
  _type: TUTPropertyType;
begin
  GetValue(-1, -1, name, value, result, _type,tn);
end;

procedure TUTProperty.SetOwnerObject(ownerobject: TUTObject);
begin
  FOwnerObject := ownerobject;
end;

function TUTProperty.GetArrayTypeLength: integer;
var start:integer;
begin
  if PropertyType<>otArray then
    result:=0
  else
    begin
      start:=0;
      result:=FOwner.Read_Idx_From_Buffer(pchar(FValue),start);
    end;
end;

{ TUTPropertyList }

constructor TUTPropertyList.Create;
begin
  FProperties := tlist.create;
end;

destructor TUTPropertyList.Destroy;
begin
  Clear;
  FProperties.free;
end;

procedure TUTPropertyList.Clear;
var
  a: integer;
begin
  for a := 0 to FProperties.count - 1 do
    TUTProperty(FProperties[a]).free;
  FProperties.clear;
end;

function TUTPropertyList.GetProperty(i: integer): TUTProperty;
begin
  try
    result := FProperties[i];
  except
    result := nil;
  end;
end;

function TUTPropertyList.GetPropertyCount: integer;
begin
  result := FProperties.count;
end;

function TUTPropertyList.NewProperty: TUTProperty;
begin
  FProperties.add(UTPropertyClass.create);
  result := FProperties[FProperties.count - 1];
end;

function TUTPropertyList.GetPropertyByName(name: string): TUTProperty;
var
  a, arrayindex: integer;
begin
  result := nil;
  name := lowercase(name);
  a := pos('[', name);
  if a = 0 then
    arrayindex := -1
  else
    begin
      arrayindex := strtointdef(copy(name, a + 1, length(name) - a - 1), 0);
      name := copy(name, 1, a - 1);
    end;
  a := 0;
  while a < FProperties.count do
    if (lowercase(TUTProperty(FProperties[a]).name) = name) and
      (TUTProperty(FProperties[a]).arrayindex = arrayindex) then
      begin
        result := FProperties[a];
        break;
      end
    else
      inc(a);
end;

function TUTPropertyList.GetPropertyListDescriptions: string;
var
  a: integer;
begin
  result := '';
  for a := 0 to FProperties.count - 1 do
    result := result + #1 + TUTProperty(FProperties[a]).Description;
  delete(result, 1, 1);
end;

procedure TUTPropertyList.FixArrayIndices;
var
  a, b: integer;
  more: boolean;
  function PropertyIsArray(const name: string): boolean;
  var
    a: integer;
  const
    // TODO : make array properties list global and complete them
    arrayprops: array[0..22] of string =
    ('paths', 'visnoreachpaths', 'upstreampaths', 'prunedpaths', 'aiprofile',
      'multiskins', 'lensaflare', 'lensflareoffset', 'lensflarescale', 'delay',
      'gain', 'outevents', 'outdelays', 'objshots', 'objdesc', 'damageevent',
      'damageeventthreshold', 'tags', 'events', 'opentimes', 'closetimes',
      'splats', 'internaltime');
  begin
    result := false;
    for a := 0 to high(arrayprops) do
      if arrayprops[a] = name then
        begin
          result := true;
          break;
        end;
  end;
begin
  // fix array index of first elements
  for a := 0 to FProperties.Count - 1 do
    if (PropertyByPosition[a].ArrayIndex = -1) then
      begin
        more := PropertyIsArray(PropertyByPosition[a].Name);
        if not more then
          for b := 0 to FProperties.Count - 1 do
            begin
              if (a <> b) and (PropertyByPosition[b].Name = PropertyByPosition[a].Name) then
                begin
                  more := true;
                  break;
                end;
            end;
        if more then
          PropertyByPosition[a].FArrayIndex := 0;
      end;
end;

function TUTPropertyList.GetPropertyByNameValue(name: string): variant;
var
  p: TUTProperty;
begin
  p := GetPropertyByName(name);
  if p = nil then
    result := 0
  else
    result := p.value;
end;

function TUTPropertyList.GetPropertyValue(i: integer): variant;
var
  p: TUTProperty;
begin
  p := GetProperty(i);
  if p = nil then
    result := 0
  else
    result := p.value;
end;

function TUTPropertyList.GetPropertyByNameValueDefault(name: string;
  adefault: variant): variant;
var
  p: TUTProperty;
begin
  p := GetPropertyByName(name);
  if p = nil then
    result := adefault
  else
    result := p.value;
end;

function TUTPropertyList.GetPropertyValueDefault(i: integer;
  adefault: variant): variant;
var
  p: TUTProperty;
begin
  p := GetProperty(i);
  if p = nil then
    result := adefault
  else
    result := p.value;
end;

{ TUTPackage }

procedure TUTPackage.read_buffer(var buffer; const size: integer; stream:tstream;const name:string='');
var a:integer;p:^byte;tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdBuffer,utdmAsValue,size,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  if stream = nil then
    stream := Fstr;
  fillchar(buffer, size, 0);
  stream.ReadBuffer(buffer, size);
  if AAOEncrypted and (stream=Fstr) then
    begin
      p:=@buffer;
      for a:=0 to size-1 do
        begin
          p^:=AAODecrypt(p^,stream.Position-size+a,EncryptKey);
          p:=pointer(integer(p)+1);
        end;
    end
  else if LineageEncrypted and (stream=Fstr) then
    begin
      p:=@buffer;
      for a:=0 to size-1 do
        begin
          p^:=p^ xor EncryptKey;
          p:=pointer(integer(p)+1);
        end;
    end;
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_asciiz(stream: tstream;const name:string=''): string;
var
  b: byte;tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdASCIIZ,utdmAsValue,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  result := '';
  repeat
    b := read_byte(stream);
    if b <> 0 then
      result := result + chr(b);
  until b = 0;
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_sizedascii(stream: tstream;const name:string=''): string;
var
  namesize: integer;tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdSizedASCII,utdmAsValue,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  namesize := read_idx(stream,utdmAsValue);
  setlength(result, namesize);
  read_buffer(result[1], namesize, stream);
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_sizedasciiz(stream: tstream;const name:string=''): string;
var tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdSizedASCIIZ,utdmAsValue,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  result := read_sizedascii(stream);
  setlength(result, length(result) - 1);
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_doublesizedasciiz(stream: tstream;const name:string=''): string;
var tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdDoubleSizedASCIIZ,utdmAsValue,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  read_idx(stream,utdmAsValue);                     // tamaño
  result := read_sizedasciiz(stream);
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_int(stream: tstream;datameaning:TUTDataMeaningTypes=utdmUnknown;const name:string=''): integer;
var tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdInt32,datameaning,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  read_buffer (result,4,stream);
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_word(stream: tstream;datameaning:TUTDataMeaningTypes=utdmUnknown;const name:string=''): word;
var tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdUInt16,datameaning,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  read_buffer (result,2,stream);
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_byte(stream: tstream;datameaning:TUTDataMeaningTypes=utdmUnknown;const name:string=''): byte;
var tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdUInt8,datameaning,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  read_buffer (result,1,stream);
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_bool(stream: tstream;const name:string=''): boolean;
var
  src: word;tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdBool,utdmAsValue,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  read_buffer (src,2,stream); // first byte=D3 (?), second byte=0 for True?
  result := ((src shr 8) = 0);
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_float(stream: tstream;const name:string=''): single;
var tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdFloat,utdmAsValue,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  read_buffer (result,4,stream);
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_idx(stream: tstream;datameaning:TUTDataMeaningTypes=utdmUnknown;const name:string=''): integer;
var
  b0, b1, b2, b3, b4: byte;tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdIndex,datameaning,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  result := 0;
  b0 := read_byte(stream);
  if (b0 and $40) <> 0 then
    begin
      b1 := read_byte(stream);
      if (b1 and $80) <> 0 then
        begin
          b2 := read_byte(stream);
          if (b2 and $80) <> 0 then
            begin
              b3 := read_byte(stream);
              if (b3 and $80) <> 0 then
                begin
                  b4 := read_byte(stream);
                  result := b4;
                end;
              result := (result shl 7) or (b3 and $7F);
            end;
          result := (result shl 7) or (b2 and $7F);
        end;
      result := (result shl 7) or (b1 and $7F);
    end;
  result := (result shl 6) or (b0 and $3F);
  if (b0 and $80) <> 0 then
    result := -result;
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_dword(stream: tstream;datameaning:TUTDataMeaningTypes=utdmUnknown;const name:string=''): dword;
var tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdUInt32,datameaning,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  read_buffer (result,4,stream);
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_qword(stream: tstream;datameaning:TUTDataMeaningTypes=utdmUnknown;const name:string=''): int64;
var tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdUInt64,datameaning,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  read_buffer (result,8,stream);
  {result := read_dword(stream,utdmAsValue);
  result := result shl 32;
  result := result or read_dword(stream,utdmAsValue);}
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_guid(stream: tstream;const name:string=''): TGuid;
var tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdGUID,utdmAsValue,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  read_buffer(result, sizeof(result), stream);
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.Read_Name(stream: tstream;const name:string=''): string;
var
  namesize: integer; tmp:boolean;
begin
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdName,utdmAsValue,-1,name);
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  if FVersion >= 64 then
    begin
      namesize := read_byte(stream);
      if FGameHint=UTPGH_UnrealChampionship then
        begin
          read_byte(stream); // 0x00
          inc(namesize);
        end;
      setlength(result, namesize);
      read_buffer(result[1], namesize, stream);
      setlength(result, length(result) - 1); // remove ending #0
    end
  else
    begin
      result := Read_ASCIIZ(stream);
    end;
  FInternalCallOnBasicDataEvent:=tmp;
end;

function TUTPackage.read_idx_from_buffer (buffer:pointer;var start:integer):integer;
var
  b0, b1, b2, b3, b4: byte;
begin
  result := 0;
  b0 := PByteArray(buffer)[start];
  inc(start);
  if (b0 and $40) <> 0 then
    begin
      b1 := PByteArray(buffer)[start];
      inc(start);
      if (b1 and $80) <> 0 then
        begin
          b2 := PByteArray(buffer)[start];
          inc(start);
          if (b2 and $80) <> 0 then
            begin
              b3 := PByteArray(buffer)[start];
              inc(start);
              if (b3 and $80) <> 0 then
                begin
                  b4 := PByteArray(buffer)[start];
                  inc(start);
                  result := b4;
                end;
              result := (result shl 7) or (b3 and $7F);
            end;
          result := (result shl 7) or (b2 and $7F);
        end;
      result := (result shl 7) or (b1 and $7F);
    end;
  result := (result shl 6) or (b0 and $3F);
  if (b0 and $80) <> 0 then
    result := -result;
end;

function TUTPackage.GetObjectFlagsText(const e: DWORD): string;
begin
  result := '';
  // TODO : add support for unknown flag bits
  // TODO : Use RTTI for FlagsText functions
  if (e and RF_LoadForClient) <> 0 then
    result := result + ', RF_LoadForClient';
  if (e and RF_NotForClient) <> 0 then
    result := result + ', RF_NotForClient';
  if (e and RF_LoadForServer) <> 0 then
    result := result + ', RF_LoadForServer';
  if (e and RF_NotForServer) <> 0 then
    result := result + ', RF_NotForServer';
  if (e and RF_LoadForEdit) <> 0 then
    result := result + ', RF_LoadForEdit';
  if (e and RF_NotForEdit) <> 0 then
    result := result + ', RF_NotForEdit';
  if (e and RF_Public) <> 0 then
    result := result + ', RF_Public';
  if (e and RF_Standalone) <> 0 then
    result := result + ', RF_Standalone';
  if (e and RF_Native) <> 0 then
    result := result + ', RF_Native';
  if (e and RF_SourceModified) <> 0 then
    result := result + ', RF_SourceModified';
  if (e and RF_Transactional) <> 0 then
    result := result + ', RF_Transactional';
  if (e and RF_HasStack) <> 0 then
    result := result + ', RF_HasStack';
  if (e and RF_Transient) <> 0 then
    result := result + ', RF_Transient';
  if (e and RF_Unreachable) <> 0 then
    result := result + ', RF_Unreachable';
  if (e and RF_TagImp) <> 0 then
    result := result + ', RF_TagImp';
  if (e and RF_TagExp) <> 0 then
    result := result + ', RF_TagExp';
  if (e and RF_TagGarbage) <> 0 then
    result := result + ', RF_TagGarbage';
  if (e and RF_NeedLoad) <> 0 then
    result := result + ', RF_NeedLoad';
  if (e and RF_HighlightedName) <> 0 then
    result := result + ', RF_HighlightedName';
  if (e and RF_InSingularFunc) <> 0 then
    result := result + ', RF_InSingularFunc';
  if (e and RF_Suppress) <> 0 then
    result := result + ', RF_Suppress';
  if (e and RF_InEndState) <> 0 then
    result := result + ', RF_InEndState';
  if (e and RF_PreLoading) <> 0 then
    result := result + ', RF_PreLoading';
  if (e and RF_Destroyed) <> 0 then
    result := result + ', RF_Destroyed';
  if (e and RF_NeedPostLoad) <> 0 then
    result := result + ', RF_NeedPostLoad';
  if (e and RF_Marked) <> 0 then
    result := result + ', RF_Marked';
  if (e and RF_ErrorShutdown) <> 0 then
    result := result + ', RF_ErrorShutdown';
  if (e and RF_DebugPostLoad) <> 0 then
    result := result + ', RF_DebugPostLoad';
  if (e and RF_DebugSerialize) <> 0 then
    result := result + ', RF_DebugSerialize';
  if (e and RF_DebugDestroy) <> 0 then
    result := result + ', RF_DebugDestroy';
  if (e and RF_Private) <> 0 then
    result := result + ', RF_Private';

  if (e and RF_Unk_00000100) <> 0 then
    result := result + ', RF_Unk_00000100';

  if result <> '' then
    delete(result, 1, 1);
end;

function TUTPackage.GetObjectPath(limit, index: integer): string;
var
  i: TUTImportTableObjectData;
  e: TUTExportTableObjectData;
  s: string;
begin
  result := '';
  while limit <> 0 do
    begin
      if index = 0 then
        break
      else if index < 0 then
        begin
          if - index - 1 < Fimporttablelist.count then
            begin
              i := TUTImportTableObjectData(Fimporttablelist[-index - 1]);
              s := Fnametablelist[i.UTObjectIndex] + '.';
              if index=i.UTpackageindex then index:=1 else index := i.UTpackageindex;
            end
          else
            begin
              s := '';
              result := '';
              limit := 1;
            end;
        end
      else if index > 0 then
        begin
          if index - 1 < Fexporttablelist.count then
            begin
              e := TUTExportTableObjectData(Fexporttablelist[index - 1]);
              s := Fnametablelist[e.UTObjectIndex] + '.';
              if index=e.UTgroupindex then index:=1 else index := e.UTgroupindex;
            end
          else
            begin
              s := '';
              result := '';
              limit := 1;
            end;
        end;
      result := s + result;
      dec(limit);
    end;
  if copy(result, length(result), 1) = '.' then
    setlength(result, length(result) - 1);
end;

function TUTPackage.AAODecrypt (EncryptedByte:byte;FilePos:int64;Key:byte):byte;
var tmp:byte;
begin
	tmp := ((FilePos shr 8) and $FF) xor (FilePos and $FF);
  result:=EncryptedByte xor tmp;
  if (tmp and $02)=0 then
    begin
      result:=result xor Key;
      exit;
    end;
  if (result shr 7)<>1 then
    begin
      result:=(result*2) xor Key;
      exit;
    end;
  result:=((result*2) or 1) xor Key;
end;

procedure TUTPackage.Process;
var
  name: string;
  int, i: integer;
  lw, namecount, nameoffset, exportcount, exportoffset, importcount,
    importoffset, heritagecount, heritageoffset, firstoffset: dword;
  guid: TGUID;
  id: TUTImportTableObjectData;
  ed: TUTExportTableObjectData;
  maxposition, position: integer;
  s:TUTPackageSectionPointer;
begin
  try
    maxposition := 100;
    try
      DoOnProgress(0, 100);
      StartReadingPackage;
      FOtherFlags := 0;
      AAOEncrypted:=false;
      LineageEncrypted:=false;
      FPackagePrefixSize:=0;
      EncryptKey:=0;
      new(s);
      s.Offset:=0;
      s.Size:=Fstr.size;
      ClearUnreferencedSections;
      FUnreferencedSections.Add(s);
      if FStr.size<4 then
        raise EInvalidUTPackage.create(rsErrorNoUTPackage);
      lw := read_dword(Fstr,utdmAsValue,'PackageId');
      if lw=$0069004C then
        begin
          LineageEncrypted:=true;
          FOtherFlags := FOtherFlags or PKG_OTHER_FLAGS_Lineage2Encrypted;
          Fstr.Seek(24,soFromCurrent); // jumps over "Lineage2Ver111" unicode text
          EncryptKey:=$C1 xor read_byte(Fstr);
          Fstr.Seek(-1,soFromCurrent); // go back 1 byte
          lw := read_dword(Fstr,utdmAsValue,'PackageId');
          FPackagePrefixSize:=28;
        end;
      if lw <> $9E2A83C1 then
        raise EInvalidUTPackage.create(rsErrorNoUTPackage);
      FVersion := read_word(Fstr,utdmAsValue,'Version');
      FLicenseeMode := read_word(FStr,utdmAsValue,'LicenseeMode');
      FFlags := read_dword(Fstr,utdmFlags,'Flags');
      DetectGameInProcess;
      Fnametablelist.clear;
      Fexporttablelist.clear;
      Fimporttablelist.clear;
      namecount := read_dword(Fstr,utdmAsValue,'NameTableCount');
      nameoffset := FPackagePrefixSize + read_dword(Fstr,utdmOffset,'NameTableOffset');
      exportcount := read_dword(Fstr,utdmAsValue,'ExportTableCount');
      exportoffset := FPackagePrefixSize + read_dword(Fstr,utdmOffset,'ExportTableOffset');
      importcount := read_dword(Fstr,utdmAsValue,'ImportTableCount');
      importoffset := FPackagePrefixSize + read_dword(Fstr,utdmOffset,'ImportTableOffset');
      setlength(Fheritagetablelist, 0);
      RemoveReferencedSection (0,Fstr.Position+1);
      if ((FFlags and PKG_Encrypted) = 0) or (FGameHint<>UTPGH_Undying) then
        begin
          firstoffset:=nameoffset;
          if FVersion < 68 then
            begin
              heritagecount := read_dword(Fstr,utdmAsValue,'HeritageTableCount');
              heritageoffset := read_dword(Fstr,utdmOffset,'HeritageTableOffset');
              if heritageoffset<firstoffset then firstoffset:=heritageoffset;
            end
          else
            begin
              int:=read_int(FStr,utdmAsValue);
              if int=$0FF0ADDE then
                begin
                  // Apparently a Splinter Cell file
                  repeat
                    // TODO : this data is unknown
                  until read_byte(FStr)=$FF;
                  if FGameHint=UTPGH_NotSpecified then FGameHint:=UTPGH_SplinterCell;
                end
              else if FGameHint<>UTPGH_DeusExInvisibleWar then // unknown DeusEx2 DWORD (0x00000000?)
                Fstr.Seek(-4,soFromCurrent);
              heritagecount := 1;
              heritageoffset := Fstr.Position;
              guid := read_guid(Fstr,'GUID');  // will be read again below
              int := read_dword(Fstr,utdmAsValue,'GenerationInfoCount');
              setlength(FGenerationInfo, int);
              for i := 0 to int - 1 do
                begin
                  FGenerationInfo[i].exportcount := read_dword(Fstr,utdmAsValue,format('GenerationInfo[%d].ExportCount',[i])); // number of exports
                  FGenerationInfo[i].namecount := read_dword(Fstr,utdmAsValue,format('GenerationInfo[%d].NameCount',[i]));   // number of names
                end;
            end;
          maxposition := namecount + exportcount {* 2} + importcount + heritagecount;
          position := 0;
          AAOEncrypted:=false;
          if (Fstr.position+4<=firstoffset) and (FGameHint in [UTPGH_NotSpecified,UTPGH_ArmyOperations]) then
            begin
              // Army Operations package
              if FGameHint=UTPGH_NotSpecified then FGameHint:=UTPGH_ArmyOperations;
              if FGameHint=UTPGH_ArmyOperations then
                begin
                  int:=read_dword(Fstr,utdmAsValue,'ArmyOperationsEncryptionCheck');
                  if int=0 then
                    begin // unencrypted
                      // 60 unknown bytes more
                      //   DWORD = 0x00000001
                      // 6xDWORD = 0x00000000
                      // 4xDWORD = could it be a GUID?
                      //   DWORD = 0x00000001
                      // 3xDWORD = 0x00000000
                      //for i:=1 to 15 do read_dword(Fstr);
                    end
                  else
                    begin // encrypted
                      //raise EInvalidUTPackage.create (rsErrorEncryptedUTPackage);
                      i:=read_byte (Fstr);
                      seek(FStr.position-1);
                      AAOEncrypted:=true; // from now on each byte read will be decrypted
                      FOtherFlags := FOtherFlags or PKG_OTHER_FLAGS_AAOEncrypted;
                      EncryptKey:=AAODecrypt (i,FStr.Position,$05);
                    end;
                end;
            end;
          RemoveReferencedSection (0,Fstr.Position+1);
          // name table
          Seek(nameoffset);
          for i := 1 to namecount do
            begin
              name := Read_Name(Fstr,format('NameTable[%d].Name',[i]));
              int := read_dword(Fstr,utdmFlags,format('NameTable[%d].Flags',[i]));
              //if (i=1) and (name<>'None') then raise EInvalidUTPackage.create (rsErrorCompressedUTPackage);
              Fnametablelist.AddObject(name, pointer(int));
              inc(position);
              DoOnProgress(position, maxposition);
            end;
          RemoveReferencedSection (nameoffset,Fstr.Position-nameoffset);
          // export table
          Seek(exportoffset);
          for i := 0 to Fexporttablelist.count - 1 do
            TUTExportTableObjectData(Fexporttablelist[i]).free;
          for i := 1 to exportcount do
            begin
              ed := TUTExportTableObjectData.create;
              ed.Owner := self;
              ed.ExportedIndex := i - 1;
              ed.UTClassIndex := read_idx(Fstr,utdmRefToName,format('ExportTable[%d].Class',[i])); // class index
              ed.UTSuperIndex := read_idx(Fstr,utdmRefToName,format('ExportTable[%d].Super',[i])); // super index
              ed.UTGroupIndex := read_dword(Fstr,utdmRefToName,format('ExportTable[%d].Group',[i])); // group index
              ed.UTObjectIndex := read_idx(Fstr,utdmRefToName,format('ExportTable[%d].Object',[i])); // object name
              ed.Flags := read_dword(Fstr,utdmFlags,format('ExportTable[%d].Flags',[i])); // object flags
              ed.SerialSize := read_idx(Fstr,utdmAsValue,format('ExportTable[%d].SerialSize',[i])); // serial size
              if ed.SerialSize > 0 then
                ed.SerialOffset := read_idx(Fstr,utdmAsValue,format('ExportTable[%d].SerialOffset',[i])) // serial offset
              else
                ed.SerialOffset := 0;
              ed.SerialOffset:=integer(FPackagePrefixSize) + ed.SerialOffset;
              FExportTableList.add(ed);
              RemoveReferencedSection (ed.SerialOffset,ed.SerialSize);
              inc(position);
              DoOnProgress(position, maxposition);
            end;
          RemoveReferencedSection (exportoffset,Fstr.Position-exportoffset);
          // import table
          Seek(importoffset);
          for i := 0 to Fimporttablelist.count - 1 do
            TUTImportTableObjectData(Fimporttablelist[i]).free;
          for i := 1 to importcount do
            begin
              id := TUTImportTableObjectData.create;
              id.Owner := self;
              id.UTClassPackageIndex := read_idx(Fstr,utdmRefToName,format('ImportTable[%d].ClassPackage',[i])); // ClassPackage
              id.UTClassIndex := read_idx(Fstr,utdmRefToName,format('ImportTable[%d].Class',[i])); // ClassName
              id.UTPackageIndex := read_int(Fstr,utdmRefToName,format('ImportTable[%d].Package',[i])); // PackageIndex
              id.UTObjectIndex := read_idx(Fstr,utdmRefToName,format('ImportTable[%d].Object',[i])); // ObjectName
              Fimporttablelist.add(id);
              inc(position);
              DoOnProgress(position, maxposition);
            end;
          RemoveReferencedSection (importoffset,Fstr.Position-importoffset);
          {if FVersion < 68 then
            begin}
          // heritage table
          Seek(heritageoffset);
          setlength(Fheritagetablelist, heritagecount);
          for i := 0 to heritagecount - 1 do
            begin
              guid := read_guid(Fstr,format('HeritageTable[%d].GUID',[i]));
              Fheritagetablelist[i] := guid;
              inc(position);
              DoOnProgress(position, maxposition);
            end;
          RemoveReferencedSection (heritageoffset,Fstr.Position-heritageoffset);
          {end;}

          {for i := 0 to Fexporttablelist.count - 1 do
            begin
              ed := TUTExportTableObjectData(Fexporttablelist[i]);
              ed.CreateObject;
              //ed.UTObject := GetUTObjectClass(ed.UTclassname).create(self, i);
              inc(position);
              DoOnProgress(position, maxposition);
            end;}
        end;
    finally
      EndReadingPackage;
      DoOnProgress(maxposition, maxposition);
    end;
  except
    on EInvalidUTPackage do raise;
    on e: exception do
      raise EProcessingUTPackage.create(format(rsExceptionProcessingPackage, [FPackage, e.message]));
  end;
end;

procedure TUTPackage.StartReadingPackage;
begin
  if (FReadingPackageCount = 0) then
    begin
      if not fileexists(FPackage) and assigned(FOnPackageNeeded) then
        FOnPackageNeeded(FPackage);
      Fstr := tfilestream.create(FPackage, fmOpenRead + fmShareDenyNone);
      FFileSize:=Fstr.size;
    end;
  inc(FReadingPackageCount);
end;

procedure TUTPackage.EndReadingPackage;
begin
  if FReadingPackageCount > 0 then
    begin
      dec(FReadingPackageCount);
      if (FReadingPackageCount = 0) then
        begin
          Fstr.free;
          Fstr := nil;
        end;
    end;
end;

function TUTPackage.ReadProperty(prop: TUTProperty; stream: tstream): boolean;
var
  n, nlc, struct, nstruct: string;
  b: integer;
  infobyte, info_type, info_size, index_b, index_c, index_d, index_e: byte;
  index, v, size: integer;
  info_array,tmp: boolean;
  buffer: array of byte;
begin
  result:=false;
  n := '<unknown>';
  tmp:=FInternalCallOnBasicDataEvent;
  if FInternalCallOnBasicDataEvent and assigned(FOnBasicData) then
    begin
      FInternalCallOnBasicDataEvent:=false;
      FOnBasicData (stream.Position,utbdProperty,utdmAsValue,-1,'Property');
    end
  else
    FInternalCallOnBasicDataEvent:=false;
  try
    try
      setlength(buffer, 256);
      b := read_idx(stream,utdmRefToName);
      n := inttostr(b);
      n := Fnametablelist[b];
      nlc := lowercase(n);
      index := -1;
      if nlc <> 'none' then               // do not localize properties names and types
        begin
          infobyte := read_byte(stream);
          info_type := infobyte and $0F;
          info_size := (infobyte shr 4) and 7;
          info_array := ((infobyte and $80) <> 0);

          if info_type = otStruct then
            begin
              struct := Fnametablelist[read_idx(stream,utdmRefToName)];
              nstruct := lowercase(struct);
            end;

          case info_size of
            0: size := 1;
            1: size := 2;
            2: size := 4;
            3: size := 12;
            4: size := 16;
            5: size := read_byte(stream);
            6: size := read_word(stream);
            7:
              size := read_dword(stream,utdmAsValue)
          else
            size := 0;
          end;

          // TODO : version 118 (or at least in ArmyOperations) has a sublist of properties when an struct type has a size type of 5.
          // could this be related to the otArray property problems?

          if info_array and (info_type <> otBool) then
            begin
              index_b := read_byte(stream);
              if (index_b and $80) = 0 then
                index := index_b
              else if (index_b and $C0) = $80 then
                begin
                  index_c := read_byte(stream);
                  index := ((index_b and $7F) shl 8) or index_c;
                end
              else
                begin
                  index_c := read_byte(stream);
                  index_d := read_byte(stream);
                  index_e := read_byte(stream);
                  index := ((index_b and $3F) shl 24) or (index_c shl 16) or (index_d shl 8) or index_e;
                end;
            end;

          case info_type of
            otBool:                       // Boolean special case
              begin
                if info_array then
                  v := 1
                else
                  v := 0;
                prop.SetProperty(self, n, index, otBool, v, 1);
              end;
            otByte,otInt,otFloat,otObject,otClass,otName,otString,otStr,otArray,otStruct,
            otVector,otRotator,otMap,otFixedArray: // ?
              begin
                setlength(buffer, size);
                read_buffer(buffer[0], size, stream);
                prop.SetProperty(self, n, index, info_type, buffer[0], size,struct);
              end
          else
            begin                         // Unknown type
              if size > length(buffer) then
                read_buffer(buffer[0], length(buffer), stream)
              else
                read_buffer(buffer[0], size, stream);
              prop.SetProperty(self, n, index, otBuffer, v, 0, format(rsUnknownPropertyType, [info_type]));
              //result := false;
              //exit;
            end;
          end;
        end
      else
        prop.SetProperty(self, n, index, otNone, v, 0);
      result := (nlc <> 'none');
    except
      on e: exception do
        raise EReadingUTProperty.create(format(rsExceptionReadingProperty, [n]));
    end;
  finally
    FInternalCallOnBasicDataEvent:=tmp;
  end;
end;

procedure TUTPackage.DetectGamePreProcess;
var
  ext: string;
begin
  // detect by extension
  //   Unreal : uxx, unr, umx, usa, uax, u, utx
  //   UT : uxx, unr, umx, usa, uax, u, utx
  //   UT2003 : uxx, ut2, umx?, usa, uax, u, utx, ukx, usx, upx
  //   Unreal2 : uxx, UN2, umx?, usa, uax, u, utx, ukx, usx, UGX, upx
  //   ArmyOps : AAO
  //   Rune : uxx, RUN, ums, umx, usa, RSA, uax, u, utx
  //   Undying: uxx, SAC, SAV, uax, u, utx, umx
  //   XCOM: XCM, utx
  //   Nerf: NRF, uax, u, utx
  //   WheelOfTime: WOT, uax, u, utx
  //   Splinter Cell: SCL
  //   Devastation: DVS
  //   DeusEx Invisible War: D2U, GMP
  //   Desert Thunder: DTS, DTA, DTM, DTT, DT
  if FGameHint<>UTPGH_NotSpecified then exit;
  ext := lowercase(ExtractFileExt(Fpackage));
  if (ext = '.sac') or (ext = '.sav') then
    FGameHint := UTPGH_Undying
  else if (ext = '.run') or (ext = '.rsa') then
    FGameHint := UTPGH_Rune
  else if (ext = '.xcm') then
    FGameHint := UTPGH_XCOMEnforcer
  else if (ext = '.nrf') then
    FGameHint := UTPGH_NerfArenaBlast
  else if (ext = '.wot') then
    FGameHint := UTPGH_TheWheelOfTime
  else if (ext = '.ut2') then
    FGameHint := UTPGH_UnrealTournament2003
  else if (ext = '.aao') then
    FGameHint := UTPGH_ArmyOperations
  else if (ext = '.un2') or (ext='.ugx') then
    FGameHint := UTPGH_Unreal2
  else if (ext = '.scl') then
    FGameHint := UTPGH_SplinterCell
  else if (ext = '.dvs') then
    FGameHint := UTPGH_Devastation
  else if (ext = '.rsm') then
    FGameHint := UTPGH_Rainbow6RavenShield
  else if (ext = '.d2u') or (ext = '.gmp') then
    FGameHint := UTPGH_DeusExInvisibleWar
  else if (ext = '.dt') or (ext = '.dta') or (ext = '.dtt') or (ext = '.dtm') or (ext = '.dts') then
    FGameHint := UTPGH_DesertThunder
  ;
end;

function TUTPackage.ExistsImportedPackage(name: string): boolean;
begin
  result := (FindObject(utolImports, [utfwName, utfwClass], '', name, 'Package') >= 0);
end;

procedure TUTPackage.DetectGameInProcess;
begin
  // You can only use FVersion, FLicenseeMode and FFlags here
  if FGameHint<>UTPGH_NotSpecified then exit;
  if LineageEncrypted then
    FGameHint:=UTPGH_Lineage2
  else if FLicenseeMode=0 then
    begin
      if FVersion=126 then
        FGameHint := UTPGH_DesertThunder
      else if FVersion=76 then
        FGameHint := UTPGH_HarryPotterSorcerersStone
      else if FVersion=79 then
        FGameHint := UTPGH_HarryPotterChamberSecrets
      {else if FVersion >= 73 then
        FGameHint := UTPGH_Undying}
      else if FVersion>=83 then
        FGameHint:=UTPGH_Undying
      else if (FFlags and PKG_Encrypted) <> 0 then
        FGameHint := UTPGH_Undying
      else if FVersion>=68 then
        FGameHint := UTPGH_UnrealTournament
      else
        FGameHint := UTPGH_Unreal;
      ;
    end
  else
    begin
      if (FLicenseeMode>=25) and (FLicenseeMode<=29) then
        begin
          if FVersion<122 then
            FGameHint:=UTPGH_UnrealTournament2003
          else
            FGameHint:=UTPGH_UnrealTournament2004;
        end
      else if (FLicenseeMode=2481) or (FLicenseeMode=1331) or (FLicenseeMode=1585){ v110 } or
              (FLicenseeMode=635) or (FLicenseeMode=763) { v83 } then
        FGameHint:=UTPGH_Unreal2
      else if (FVersion=118) and
              ((FLicenseeMode=8) or (FLicenseeMode=9) or
               ((FLicenseeMode>=16) and (FLicenseeMode<=19))) then
        FGameHint:=UTPGH_ArmyOperations // it can also be Rainbow Six!
      else if (FLicenseeMode=20) and (FVersion=123) then
        FGameHint:=UTPGH_Lineage2
      else if (FLicenseeMode=8) and (FVersion=120) then
        FGameHint:=UTPGH_Devastation
      else if (FLicenseeMode=30) and (FVersion=119) then
        FGameHint:=UTPGH_UnrealChampionship
      ;
    end;
end;

procedure TUTPackage.DetectGamePostProcess;
var
  p: string;
  function PackageOk(package: string): boolean;
  begin
    result := (p = lowercase(package)) or ExistsImportedPackage(package);
  end;
begin
  if FGameHint<>UTPGH_NotSpecified then exit;
  p := lowercase(ChangeFileExt(ExtractFilename(FPackage), ''));
  if PackageOk('Enforcer') then
    FGameHint := UTPGH_XCOMEnforcer
  else if PackageOk('RuneI') then
    FGameHint := UTPGH_Rune
  else if PackageOk('Aeons') then
    FGameHint := UTPGH_Undying
  else if PackageOk('Botpack') then
    FGameHint := UTPGH_UnrealTournament
  else if PackageOk('NerfI') then
    FGameHint := UTPGH_NerfArenaBlast
  else if PackageOk('WoT') then
    FGameHint := UTPGH_TheWheelOfTime
  else if PackageOk('R6SFX') then
    FGameHint:=UTPGH_Rainbow6RavenShield
  else if PackageOk('DTEngine') then
    FGameHint:=UTPGH_DesertThunder
  ;
end;

constructor TUTPackage.Create;
begin
  FGameHint := UTPGH_NotSpecified;
  FNameTablelist := tstringlist.create;
  FImportTablelist := tlist.create;
  FExportTablelist := tlist.create;
  setlength(FHeritageTableList, 0);
  FReadingPackageCount := 0;
  setlength(FGenerationInfo, 0);
  FUnreferencedSections:=tlist.create;
  Fstr := nil;
  FAllowReadingOtherPackages := true;
  FOnGetStringConst := nil;
  FOnGetUnicodeStringConst := nil;
  FOnGetGameHint := nil;
  FSaveOriginalTextureFormat:=true;
  FEnumCache := tstringlist.create;
  FPackage:='';
end;

destructor TUTPackage.Destroy;
var
  a: integer;
begin
  EndReadingPackage;
  Fnametablelist.free;
  for a := 0 to Fexporttablelist.count - 1 do
    TUTExportTableObjectData(Fexporttablelist[a]).free;
  Fexporttablelist.free;
  for a := 0 to Fimporttablelist.count - 1 do
    TUTImportTableObjectData(Fimporttablelist[a]).free;
  Fimporttablelist.free;
  setlength(FHeritageTableList, 0);
  setlength(FGenerationInfo, 0);
  ClearUnreferencedSections;
  FUnreferencedSections.free;
  FEnumCache.free;
  inherited;
end;

function TUTPackage.GetName(i: integer): string;
begin
  if (i >= 0) and (i < FNameTableList.count) then
    result := FNameTableList[i]
  else
    result := '';
end;

function TUTPackage.GetExport(i: integer): TUTExportTableObjectData;
begin
  if (i >= 0) and (i < FExportTableList.count) then
    result := TUTExportTableObjectData(FExportTableList[i])
  else
    result := nil;
end;

function TUTPackage.GetImport(i: integer): TUTImportTableObjectData;
begin
  if (i >= 0) and (i < FImportTableList.count) then
    result := TUTImportTableObjectData(FImportTableList[i])
  else
    result := nil;
end;

function TUTPackage.GetHeritage(i: integer): TGUID;
begin
  if (i >= 0) and (i < length(FHeritageTableList)) then
    result := FHeritageTableList[i]
  else
    fillchar(result, sizeof(TGUID), 0);
end;

procedure TUTPackage.Seek(p: integer);
begin
  Fstr.seek(p, soFromBeginning);
end;

procedure TUTPackage.Initialize(const package: string; GameHint: TUTPackage_GameHint = UTPGH_NotSpecified);
var
  a: integer;
begin
  ReleaseAllObjects;

  EndReadingPackage;
  Fnametablelist.clear;
  for a := 0 to Fexporttablelist.count - 1 do
    TUTExportTableObjectData(Fexporttablelist[a]).free;
  Fexporttablelist.clear;
  for a := 0 to Fimporttablelist.count - 1 do
    TUTImportTableObjectData(Fimporttablelist[a]).free;
  Fimporttablelist.clear;
  setlength(FHeritageTableList, 0);
  setlength(FGenerationInfo, 0);
  FEnumCache.clear;

  FGameHint := GameHint;
  FPackage := package;
  if FGameHint = UTPGH_NotSpecified then DetectGamePreProcess;
  if assigned(FOnGetGameHint) then FOnGetGameHint (self,FGameHint);
  Process;
  if FGameHint = UTPGH_NotSpecified then DetectGamePostProcess;
  SetNativeFunctionArrayFromHint;
end;

function TUTPackage.GetNameFlags(i: integer): integer;
begin
  if (i >= 0) and (i < FNameTableList.count) then
    result := integer(Fnametablelist.objects[i])
  else
    result := 0;
end;

function TUTPackage.GetExportCount: integer;
begin
  result := FExportTableList.count;
end;

function TUTPackage.GetHeritageCount: integer;
begin
  result := length(FHeritageTableList);
end;

function TUTPackage.GetImportCount: integer;
begin
  result := FImportTableList.count;
end;

function TUTPackage.GetNameCount: integer;
begin
  result := FNameTableList.count;
end;

procedure TUTPackage.SaveDataBlock(strm: TStream; position, size: integer);
var a:integer;x:byte;
begin
  Seek(position);
  if AAOEncrypted then
    begin
      for a:=0 to size-1 do
        begin
          FStr.read (x,1);
          x:=AAODecrypt(x,position+a,EncryptKey);
          strm.write (x,1);
        end;
    end
  else if LineageEncrypted then
    begin
      for a:=0 to size-1 do
        begin
          FStr.read (x,1);
          x:=x xor EncryptKey;
          strm.write (x,1);
        end;
    end
  else
    strm.CopyFrom(Fstr, size);
end;

procedure TUTPackage.SaveDataBlock(filename: string; position, size: integer);
var str2: tfilestream;
begin
  str2 := tfilestream.create(filename, fmCreate);
  try
    SaveDataBlock (str2,position,size);
  finally
    str2.free;
  end;
end;

function TUTPackage.GetPackagePosition: integer;
begin
  result := Fstr.position;
end;

function TUTPackage.GetStream: TStream;
begin
  result := Fstr;
end;

function TUTPackage.GetExportIndex(objectname, classname: string): integer;
var
  a: integer;
  found: boolean;
  ed: TUTExportTableObjectData;
begin
  a := 0;
  found := false;
  objectname := lowercase(objectname);
  classname := lowercase(classname);
  while not found and (a < Fexporttablelist.count) do
    begin
      ed := TUTExportTableObjectData(Fexporttablelist[a]);
      if (lowercase(ed.UTobjectname) = objectname) and (lowercase(ed.UTclassname) = classname) then
        found := true
      else
        inc(a);
    end;
  if found then
    result := a
  else
    result := -1;
end;

function TUTPackage.GetNameIndex(objectname: string): integer;
begin
  result := Fnametablelist.indexof(objectname);
end;

function TUTPackage.EncodeIndex(i: integer): string;
var
  v: integer;
  b0, b1, b2, b3, b4: byte;
begin
  result := '';
  v := abs(i);
  if i >= 0 then
    b0 := 0
  else
    b0 := $80;
  if v < $40 then
    b0 := b0 + v
  else
    b0 := b0 + $40 + (v and $3F);
  result := result + chr(b0);
  if (b0 and $40) <> 0 then
    begin
      v := v shr 6;
      if v < $80 then
        b1 := v
      else
        b1 := (v and $7F) + $80;
      result := result + chr(b1);
      if (b1 and $80) <> 0 then
        begin
          v := v shr 7;
          if v < $80 then
            b2 := v
          else
            b2 := (v and $7F) + $80;
          result := result + chr(b2);
          if (b2 and $80) <> 0 then
            begin
              v := v shr 7;
              if v < $80 then
                b3 := v
              else
                b3 := (v and $7F) + $80;
              result := result + chr(b3);
              if (b3 and $80) <> 0 then
                begin
                  v := v shr 7;
                  b4 := v;
                  result := result + chr(b4);
                end;
            end;
        end;
    end;
end;

function TUTPackage.FindObject(where: TUTPackageObjectLocations;
  what: TUTPackageFindWhatSet;
  packagename, objectname, classname: string; start: integer): integer;
var
  a: integer;
  ok: boolean;
begin
  objectname := lowercase(objectname);
  packagename := lowercase(packagename);
  classname := lowercase(classname);
  case where of
    utolNames:
      begin
        a := start;
        result := -1;
        while (a < FNameTableList.count) and (result = -1) do
          if (lowercase(FNameTableList[a]) = objectname) then
            result := a
          else
            inc(a);
      end;
    utolExports:
      begin
        a := start;
        result := -1;
        while (a < ExportedCount) and (result = -1) do
          begin
            ok := true;
            if (utfwName in what) then
              ok := ok and (lowercase(Exported[a].UTObjectName) = objectname);
            if (utfwClass in what) then
              ok := ok and (lowercase(Exported[a].UTClassName) = classname);
            if (utfwGroup in what) then
              ok := ok and (lowercase(Exported[a].UTGroupName) = packagename);
            if ok then
              result := a
            else
              inc(a);
          end;
      end;
    utolImports:
      begin
        a := start;
        result := -1;
        while (a < ImportedCount) and (result = -1) do
          begin
            ok := true;
            if (utfwName in what) then
              ok := ok and (lowercase(Imported[a].UTObjectName) = objectname);
            if (utfwClass in what) then
              ok := ok and (lowercase(Imported[a].UTClassName) = classname);
            if (utfwGroup in what) then
              ok := ok and (lowercase(Imported[a].UTPackageName) = packagename);
            if ok then
              result := a
            else
              inc(a);
          end;
      end
  else
    result := -1;
  end;
end;

procedure TUTPackage.ReadAllObjects;
var
  a, b: integer;
begin
  b := ExportedCount - 1;
  DoOnProgress(0, b);
  for a := 0 to b do
    begin
      Exported[a].UTObject.ReadObject;
      DoOnProgress(a, b);
    end;
end;

procedure TUTPackage.ReleaseAllObjects;
var
  a, b: integer;
begin
  b := ExportedCount - 1;
  //DoOnProgress(0, b);
  for a := 0 to b do
    begin
      if Exported[a].UTObject.HasBeenRead then
        Exported[a].UTObject.ReleaseObject;
      //DoOnProgress(a, b);
    end;
end;

procedure TUTPackage.DoOnProgress(position, maxposition: integer);
begin
  if assigned(FOnProgress) then
    if maxposition = 0 then
      FOnProgress(self, 0)
    else
      FOnProgress(self, position * 100 div maxposition);
end;

function TUTPackage.GetGeneration(i: integer): TUTPackage_GenerationInfo;
begin
  result := FGenerationInfo[i];
end;

function TUTPackage.GetGenerationCount: integer;
begin
  result := length(FGenerationInfo);
end;

function TUTPackage.IndentText(indent, txt: string): string;
var
  str: tstringlist;
  a: integer;
  ending_crlf: boolean;
begin
  ending_crlf := (copy(txt, length(txt) - 1, 2) = #13#10);
  str := tstringlist.create;
  str.text := txt;
  for a := 0 to str.count - 1 do
    str[a] := indent + str[a];
  result := str.text;
  str.free;
  if not ending_crlf then
    delete(result, length(result) - 1, 2);
end;

function TUTPackage.GetInitialized: boolean;
begin
  result := (FNameTableList.count > 0);
end;

procedure TUTPackage.SetName(i: integer; const Value: string);
begin
  FNameTableList[i] := value;
end;

function TUTPackage.GetStringConst(s: string): string;
begin
  if assigned(FOnGetStringConst) then
    result := FOnGetStringConst(s)
  else
    result := '"' + s + '"';
end;

function TUTPackage.GetUnicodeStringConst(s: widestring): widestring;
begin
  if assigned(FOnGetUnicodeStringConst) then
    result := FOnGetUnicodeStringConst(s)
  else
    result := '"' + s + '"';
end;

procedure TUTPackage.SetNativeFunctionArray(a: array of TNativeFunction);
var
  i: integer;
begin
  setlength(NativeFunctions, length(a));
  for i := 0 to high(a) do
    NativeFunctions[i] := a[i];
end;

procedure TUTPackage.SetNativeFunctionArrayFromHint;
var a:integer;
begin
  setlength(NativeFunctions,0);
  for a:=0 to high(RegisteredNativeFunctionArrays) do
    if RegisteredNativeFunctionArrays[a].GameHint=FGameHint then
      begin
        SetNativeFunctionArray (RegisteredNativeFunctionArrays[a].Functions);
        break;
      end;
end;

procedure TUTPackage.FindObjectRecursive(what: TUTPackageFindWhatSet;
  packagename, objectname, classname, associated_class: string;
  var found_pkg: TUTPackage; var found_index: integer);
var i,p:integer;newpackage:TUTPackage;packagedescriptor,packagefile,pkg:string;
begin
  // search in export list of current package
  i:=FindObject (utolExports,what,packagename,objectname,classname);
  if i<>-1 then
     begin
     found_pkg:=self;
     found_index:=i;
     end
  else if AllowReadingOtherPackages then
    begin // not found, so check if imported
      i := FindObject(utolImports, what, packagename, objectname, classname);
      if i <> -1 then
        begin // it is imported, so get its package and search recursively
          packagedescriptor := Imported[i].UTPackageName;
          p := pos('.', packagedescriptor);
          if p = 0 then p := length(packagedescriptor) + 1;
          packagefile := copy(packagedescriptor, 1, p - 1);
          delete(packagedescriptor, 1, p);
          pkg := extractfilepath(FPackage) + packagefile + '.u';
          if assigned(OnPackageNeeded) then OnPackageNeeded(pkg);
          if fileexists(pkg) then
            begin
              newpackage:=found_pkg;
              try
                newpackage := TUTPackage.createinternal(pkg, self);
                newpackage.FindObjectRecursive (what,packagename,objectname,classname,'',found_pkg,found_index);
              except
              end;
              if (found_pkg<>newpackage) then
                newpackage.free; // free an intermediate package
            end;
        end;
      if found_index=-1 then
        begin // not found, so try searching in the package of the associated class
          i := FindObject(utolImports, [utfwName, utfwClass], '', associated_class, 'Class');
          if i <> -1 then
            begin // found the associated class in the imports list, so get its package and search recursively
              packagedescriptor := Imported[i].UTPackageName;
              p := pos('.', packagedescriptor);
              if p = 0 then p := length(packagedescriptor) + 1;
              packagefile := copy(packagedescriptor, 1, p - 1);
              delete(packagedescriptor, 1, p);
              pkg := extractfilepath(FPackage) + packagefile + '.u';
              if assigned(OnPackageNeeded) then OnPackageNeeded(pkg);
              if fileexists(pkg) then
                begin
                  newpackage := TUTPackage.createinternal(pkg, self);
                  newpackage.FindObjectRecursive (what,packagename,objectname,classname,'',found_pkg,found_index);
                  if (found_pkg<>newpackage) then
                    newpackage.free; // free an intermediate package
                end;
            end;
        end;
    end;
end;

constructor TUTPackage.CreateInternal(const package: string; other_pkg: TUTPackage);
begin
  Create;
  if package<>'' then Initialize (package,other_pkg.gamehint);
  FAllowReadingOtherPackages:=other_pkg.FAllowReadingOtherPackages;
  FSaveOriginalTextureFormat:=other_pkg.FSaveOriginalTextureFormat;
  FOnGetStringConst:=other_pkg.FOnGetStringConst;
  FOnGetUnicodeStringConst:=other_pkg.FOnGetUnicodeStringConst;
  FOnPackageNeeded:=other_pkg.FOnPackageNeeded;
  FCallOnBasicDataEvent:=other_pkg.FCallOnBasicDataEvent;
  FInternalCallOnBasicDataEvent:=other_pkg.FInternalCallOnBasicDataEvent;
  FOnBasicData:=other_pkg.FOnBasicData;
end;

procedure TUTPackage.FindObjectAndPackage(index: integer;
  var pkg: TUTPackage; var obj: TUTObject);
var found_index,p:integer;packagedescriptor,packagefile,pkgname,objectname,classname:string;
begin
  pkg:=nil;
  obj:=nil;
  if index>=0 then
    begin
      pkg:=self;
      obj:=Exported[index-1].UTObject;
    end
  else if AllowReadingOtherPackages then
    begin
      objectname:=Imported[-index-1].UTObjectName;
      classname:=Imported[-index-1].UTClassName;
      if classname='Class' then classname:='';
      packagedescriptor := Imported[-index-1].UTPackageName;
      p := pos('.', packagedescriptor);
      if p = 0 then p := length(packagedescriptor) + 1;
      packagefile := copy(packagedescriptor, 1, p - 1);
      delete(packagedescriptor, 1, p);
      pkgname := extractfilepath(FPackage) + packagefile + '.u';
      if assigned(OnPackageNeeded) then OnPackageNeeded(pkgname);
      if fileexists(pkgname) then
        begin
          try
            pkg := TUTPackage.createinternal(pkgname, self);
            found_index:=pkg.FindObject (utolExports,[utfwGroup,utfwName,utfwClass],packagedescriptor,objectname,classname,0);
          except
            found_index:=-1;
          end;
          if found_index>=0 then
            Obj:=pkg.Exported[found_index].UTObject
          else
            pkg.free;
        end;
    end;
end;

procedure TUTPackage.SetCallOnBasicDataEvent(const Value: boolean);
begin
  FCallOnBasicDataEvent := Value;
  FInternalCallOnBasicDataEvent := FCallOnBasicDataEvent;
end;

procedure TUTPackage.SetOnBasicData(const Value: TUT_OnBasicData);
begin
  FOnBasicData := Value;
end;

procedure TUTPackage.SetOnGetGameHint(const Value: TUT_OnGetGameHint);
begin
  FOnGetGameHint := Value;
end;

procedure TUTPackage.SetOnProcessMessages(const Value: TUT_OnProcessMessages);
begin
  FOnProcessMessages := Value;
end;

function TUTPackage.GetUnreferencedSection(i: cardinal): TUTPackageSection;
begin
  result:=TUTPackageSectionPointer(FUnreferencedSections[i])^;
end;

function TUTPackage.GetUnreferencedSectionsCount: integer;
begin
  result:=FUnreferencedSections.count;
end;

procedure TUTPackage.RemoveReferencedSection(offset, size: cardinal);
var a:integer;s:TUTPackageSectionPointer;
begin
  a:=0;
  while a<FUnreferencedSections.count do
    begin
      if (TUTPackageSectionPointer(FUnreferencedSections[a]).Offset)>offset+size then
        begin
          // break the loop if we pass the offset+size point
          break;
        end
      else if (offset>TUTPackageSectionPointer(FUnreferencedSections[a]).Offset) and
              (offset+size<TUTPackageSectionPointer(FUnreferencedSections[a]).Offset+TUTPackageSectionPointer(FUnreferencedSections[a]).Size) then
        begin
          // current section contains the block
          new(s);
          FUnreferencedSections.Insert(a+1,s);
          s.Offset:=offset+size;
          s.Size:=TUTPackageSectionPointer(FUnreferencedSections[a]).Offset+TUTPackageSectionPointer(FUnreferencedSections[a]).Size-s.offset;
          TUTPackageSectionPointer(FUnreferencedSections[a]).Size:=offset-TUTPackageSectionPointer(FUnreferencedSections[a]).Offset+1;
          break;
        end
      else if (offset<=TUTPackageSectionPointer(FUnreferencedSections[a]).Offset) and
              (offset+size>=TUTPackageSectionPointer(FUnreferencedSections[a]).Offset+TUTPackageSectionPointer(FUnreferencedSections[a]).Size) then
        begin
          // current section is inside the block
          dispose(FUnreferencedSections[a]);
          FUnreferencedSections.Delete(a);
        end
      else if (offset<=TUTPackageSectionPointer(FUnreferencedSections[a]).Offset) and
              (offset+size>=TUTPackageSectionPointer(FUnreferencedSections[a]).Offset) then
        begin
          // current section starts with (part of) the block
          TUTPackageSectionPointer(FUnreferencedSections[a]).Size:=TUTPackageSectionPointer(FUnreferencedSections[a]).Offset+TUTPackageSectionPointer(FUnreferencedSections[a]).Size-(offset+size);
          TUTPackageSectionPointer(FUnreferencedSections[a]).Offset:=offset+size;
          break;
        end
      else if (offset>TUTPackageSectionPointer(FUnreferencedSections[a]).Offset) and
              (offset<TUTPackageSectionPointer(FUnreferencedSections[a]).Offset+TUTPackageSectionPointer(FUnreferencedSections[a]).Size) and
              (offset+size>=TUTPackageSectionPointer(FUnreferencedSections[a]).Offset+TUTPackageSectionPointer(FUnreferencedSections[a]).Size) then
        begin
          // current section ends with (part of) the block
          TUTPackageSectionPointer(FUnreferencedSections[a]).Size:=offset-TUTPackageSectionPointer(FUnreferencedSections[a]).Offset;
          inc(a);
        end
      else
        inc(a);
    end;
end;

procedure TUTPackage.ClearUnreferencedSections;
var a:integer;
begin
  for a:=0 to FUnreferencedSections.count-1 do
    dispose(TUTPackageSectionPointer(FUnreferencedSections[a]));
  FUnreferencedSections.clear;
end;

function TUTPackage.IsPackageEncrypted: boolean;
begin
  result:=((FOtherFlags and (PKG_OTHER_FLAGS_AAOEncrypted or PKG_OTHER_FLAGS_Lineage2Encrypted))<>0) or
          (((FFlags and PKG_Encrypted)<>0) and (FGameHint<>UTPGH_UnrealTournament2004));
end;

{ TUTObject }

constructor TUTObject.create(owner: TUTPackage; exportedindex: integer);
begin
  FOwner := owner;
  FExportedIndex := exportedindex;
  Buffer := nil;
  FExtraDataCount := -1;
  FProperties := TUTPropertyList.create;
  InitializeObject;
end;

destructor TUTObject.destroy;
begin
  ReleaseObject;
  FProperties.free;
  inherited;
end;

procedure TUTObject.ReadObject(interpret: boolean);
var
  p: integer;
begin
  inc(FReadCount);
  if not FHasBeenRead or (interpret and not FHasBeenInterpreted) then
    begin
      FOwner.StartReadingPackage;
      try
        if not FHasBeenRead then
          begin
            buffer := TMemoryStream.create;
            p := FOwner.Position;
            FStartInPackage := UTSerialOffset;
            if UTSerialSize > 0 then
              FOwner.SaveDataBlock(buffer,FStartInPackage,UTSerialSize);
            FOwner.Seek(p);
            buffer.Seek(0, soFromBeginning);
            FHasBeenRead := true;
          end;
        if interpret and (buffer.size > 0) then
          begin
            InitializeObject;
            InterpretObject;
            FExtraDataCount := buffer.size - buffer.position;
            buffer.Seek(0, soFromBeginning);
            FHasBeenInterpreted := true;
          end
        else
          FExtraDataCount := -1;
      finally
        FOwner.EndReadingPackage;
      end;
    end;
end;

procedure TUTObject.ReleaseObject;
begin
  dec(FReadCount);
  if FReadCount = 0 then
    begin
      if FHasBeenRead then DoReleaseObject;
      FHasBeenRead := false;
      FHasBeenInterpreted := false;
    end;
end;

procedure TUTObject.InitializeObject;
begin
  FProperties.clear;
end;

procedure TUTObject.InterpretObject;
var
  node,n,a: integer;
begin
  if (UTFlags and RF_HasStack) <> 0 then
    begin
      node := FOwner.read_idx(buffer,utdmUnknown,'StateFrame.Node');
      FOwner.read_idx(buffer,utdmUnknown,'StateFrame.StateNode');
      FOwner.read_qword(buffer,utdmAsValue,'StateFrame.ProbeMask');
      FOwner.read_dword(buffer,utdmUnknown,'StateFrame.LatentAction');
      if node <> 0 then
        FOwner.read_idx(buffer,utdmAsValue,'(StateFrame.Node.)?Offset');
    end;
  if (UTClassIndex <> 0) then
    ReadProperties
  else if (FOwner.GameHint=UTPGH_Unreal2) or (FOwner.GameHint=UTPGH_Devastation) then
    begin // or maybe just if version>=120 ?
      // TODO : unknown index array
      n:=FOwner.read_idx(buffer,utdmAsValue,'Unknown Array Count');
      for a:=0 to n-1 do
        FOwner.read_idx(buffer);
    end;
end;

procedure TUTObject.ReadProperties;
var
  more: boolean;
  prop: TUTProperty;
begin
  repeat
    prop := FProperties.New;
    prop.setownerobject(self);
    more := FOwner.ReadProperty(prop, buffer);
    if assigned(FOwner.FOnProcessMessages) then FOwner.OnProcessMessages(FOwner);
  until not more;
  FProperties.FixArrayIndices;
end;

function TUTObject.Get_ClassName: string;
begin
  result := FOwner.Exported[FExportedIndex].UTClassName;
end;

function TUTObject.GetObjectname: string;
begin
  result := FOwner.Exported[FExportedIndex].UTObjectName;
end;

function TUTObject.GetClassIndex: integer;
begin
  result := FOwner.Exported[FExportedIndex].UTClassIndex;
end;

function TUTObject.GetObjectIndex: integer;
begin
  result := FOwner.Exported[FExportedIndex].UTObjectIndex;
end;

function TUTObject.GetGroupIndex: integer;
begin
  result := FOwner.Exported[FExportedIndex].UTGroupIndex;
end;

function TUTObject.GetGroupName: string;
begin
  result := FOwner.Exported[FExportedIndex].UTGroupName;
end;

function TUTObject.GetSuperIndex: integer;
begin
  result := FOwner.Exported[FExportedIndex].UTSuperIndex;
end;

function TUTObject.GetSuperName: string;
begin
  result := FOwner.Exported[FExportedIndex].UTSuperName;
end;

function TUTObject.GetSerialOffset: integer;
begin
  result := FOwner.Exported[FExportedIndex].SerialOffset;
end;

function TUTObject.GetSerialSize: integer;
begin
  result := FOwner.Exported[FExportedIndex].SerialSize;
end;

function TUTObject.GetFlags: DWORD;
begin
  result := FOwner.Exported[FExportedIndex].Flags;
end;

procedure TUTObject.check_initialized;
begin
  assert(buffer <> nil, UTObjectName + ': ReadObject was not called for this object!');
  {if buffer = nil then
    raise EUTObjectNotRead.create(UTObjectName + ': ReadObject was not called for this object!');}
  // could also make the ReadObject call, but the programmer would not release the object
end;

function TUTObject.GetProperties: TUTPropertyList;
begin
  check_initialized;
  result := FProperties;
end;

function TUTObject.GetFullName: string;
begin
  result := FOwner.GetObjectPath(-1, FExportedIndex + 1);
end;

function TUTObject.GetPosition: integer;
begin
  result := buffer.position;
end;

procedure TUTObject.SetPosition(const Value: integer);
begin
  buffer.seek(value, soFromBeginning);
end;

procedure TUTObject.RawSaveToFile(filename: string);
begin
  buffer.SaveToFile(filename);
end;

procedure TUTObject.RawSaveToStream(stream: TStream);
begin
  buffer.SaveToStream(stream);
end;

procedure TUTObject.DoReleaseObject;
begin
  FreeAndNil(buffer);
  FProperties.clear;
end;

function TUTObject.GetOwner: TUTPackage;
begin
  result := FOwner;
end;

function TUTObject.CheckArrayLength(size: integer): integer;
begin
  result:=size;
  if (size<0) or (size>Buffer.Size) then raise Exception.Create(rsInvalidArrayLength);
end;

function TUTObject.GetBufferPosition: integer;
begin
  try
    result:=buffer.position;
  except
    result:=-1;
  end;
end;

{ TUTObjectClassPalette }

function TUTObjectClassPalette.GetColor(n: integer): TColor;
begin
  check_initialized;
  result := TColor(FColors[n]);
end;

function TUTObjectClassPalette.GetColorCount: integer;
begin
  check_initialized;
  result := FColorCount;
end;

function TUTObjectClassPalette.GetNewPalette: HPalette;
var
  palette_struct: PLogPalette;
  buffer: array[0..4 + 256 * 4 - 1] of byte;
  y: integer;
begin
  check_initialized;
  palette_struct := @buffer;
  palette_struct^.palVersion := $300;
  palette_struct^.palNumEntries := 256;
  {$IFOPT R+}
  {$DEFINE RangeCheck}
  {$ENDIF}
  {$R-}
  for y := 0 to 255 do
    begin
      move (FColors[y],palette_struct^.palPalEntry[y],3);
      palette_struct^.palPalEntry[y].peFlags := 0;
    end;
  {$IFDEF RangeCheck}
  {$R+}
  {$ENDIF}
  result := CreatePalette(palette_struct^);
end;

procedure TUTObjectClassPalette.InitializeObject;
begin
  inherited;
  FColorCount := 0;
  setlength(FColors, 0);
end;

procedure TUTObjectClassPalette.InterpretObject;
var
  a: integer;v:dword;
begin
  inherited;
  FColorCount := FOwner.read_idx(buffer,utdmAsValue,'ColorCount');
  setlength(FColors, CheckArrayLength(FColorCount));
  for a := 0 to FColorCount - 1 do
    begin
      v:=FOwner.read_dword(buffer,utdmAsValue,format('Color[%u]',[a]));
      move (v,FColors[a],4);
    end;
  if (FOwner.Version >= 75) and (FOwner.GameHint=UTPGH_Undying) then
    FOwner.read_dword(buffer);            // TODO : unknown palette info
end;

{ TUTObjectClassSound }

function TUTObjectClassSound.GetData: string;
begin
  check_initialized;
  result := FData;
end;

function TUTObjectClassSound.GetFormat: string;
begin
  check_initialized;
  result := FFormat;
end;

procedure TUTObjectClassSound.InitializeObject;
begin
  inherited;
  FFormat := '';
  FData := '';
end;

procedure TUTObjectClassSound.InterpretObject;
begin
  inherited;
  if (FOwner.GameHint = UTPGH_Rainbow6RavenShield) then
    raise EUnknownObjectFormat.create ('The Rainbow 6 RavenShield Sound format is unknown, but the sound is not in the packages.');
  if (FOwner.GameHint = UTPGH_SplinterCell) then
    begin
      // TODO : unknown format
      FOwner.read_idx(buffer);
      FOwner.read_idx(buffer);
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
      exit;
    end;
  if (FOwner.GameHint = UTPGH_ArmyOperations) then
    FOwner.read_dword(buffer); // TODO : unknown dword
  FFormat := FOwner.Names[FOwner.read_idx(buffer,utdmRefToName,'Format')];
  if (FOwner.GameHint = UTPGH_Undying) and (FOwner.Version >= 79) then
    begin // TODO : unknown sound info
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
      if FOwner.Version > 79 then
        FOwner.read_dword(buffer);
      if FOwner.Version > 81 {82?} then
        FOwner.read_dword(buffer);
    end;
  if ((FOwner.GameHint = UTPGH_UnrealTournament2003) or (FOwner.GameHint = UTPGH_UnrealTournament2004)) and (FOwner.Version >= 100) then
    begin
      FOwner.read_float (buffer); // TODO : (sound) unknown float = 1.0 ?
    end;
  if FOwner.Version >= 63 then
    FOwner.read_dword(buffer,utdmOffset,'NextObject?');            // next object offset
  setlength(FData, CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue,'SoundDataSize')));
  FOwner.read_buffer(FData[1], length(FData), buffer,'SoundData');
  if (FOwner.GameHint = UTPGH_Undying) and (FOwner.Version >= 79) then
    begin // TODO : unknown sound info
      FOwner.read_dword(buffer);
      FOwner.read_byte(buffer);
      if FOwner.Version >= 85 then
        FOwner.read_dword(buffer);       
    end;
end;

procedure TUTObjectClassSound.SaveToFile(filename: string);
var
  f: file;
begin
  check_initialized;
  assignfile(f, filename);
  try
    rewrite(f, 1);
    blockwrite(f, FData[1], length(FData));
  finally
    closefile(f);
  end;
end;

procedure TUTObjectClassSound.SaveToStream(stream: TStream);
begin
  check_initialized;
  stream.WriteBuffer(FData[1],length(FData)); 
end;

{ TUTObjectClassTextBuffer }

function TUTObjectClassTextBuffer.GetData: string;
begin
  check_initialized;
  result := FData;
end;

procedure TUTObjectClassTextBuffer.InitializeObject;
begin
  inherited;
  FData := '';
end;

procedure TUTObjectClassTextBuffer.InterpretObject;
begin
  inherited;
  FOwner.read_dword(buffer,utdmAsValue,'Pos');
  FOwner.read_dword(buffer,utdmAsValue,'Top');
  if FOwner.GameHint=UTPGH_Undying then
    begin
      FOwner.read_idx(buffer,utdmAsValue,'UncompressedDataSize');
      setlength(FData, CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue,'CompressedDataSize')));
      FOwner.read_buffer(FData[1], length(FData), buffer,'Data');
      setlength(FData, 0); // since we cannot decompress it, we discard it.
    end
  else //if (FOwner.Version < 85) or (FOwner.Version >= 117) then
    begin
      if FOwner.GameHint=UTPGH_DeusExInvisibleWar then
        begin
          FOwner.read_dword(buffer); // unknown (0x00000000?)
          FOwner.read_dword(buffer); // unknown (0x00000000?)
        end;
      setlength(FData, CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue,'DataSize')));
      FOwner.read_buffer(FData[1], length(FData), buffer,'Data');
      if FData[length(FData)]=#0 then delete(FData,length(FData),1);
    end;
end;

procedure TUTObjectClassTextBuffer.SaveToFile(filename: string);
var
  f: file;
begin
  check_initialized;
  assignfile(f, filename);
  try
    rewrite(f, 1);
    blockwrite(f, FData[1], length(FData));
  finally
    closefile(f);
  end;
end;

{ TUTObjectClassMusic }

function TUTObjectClassMusic.GetData: string;
begin
  check_initialized;
  result := FData;
end;

function TUTObjectClassMusic.GetFormat: string;
begin
  check_initialized;
  result := FFormat;
end;

procedure TUTObjectClassMusic.InitializeObject;
begin
  inherited;
  FFormat := '';
  FData := '';
end;

procedure TUTObjectClassMusic.InterpretObject;
begin
  FFormat := FOwner.Names[0];
  FOwner.Read_word(buffer,utdmAsValue,'NumChunks?');
  FOwner.read_dword(buffer,utdmOffset,'NextChunk?');
  setlength(FData, CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue,'DataSize')));
  FOwner.read_buffer(FData[1], length(FData), buffer,'Data');
end;

procedure TUTObjectClassMusic.SaveToFile(filename: string);
var
  f: file;
begin
  check_initialized;
  assignfile(f, filename);
  try
    rewrite(f, 1);
    blockwrite(f, FData[1], length(FData));
  finally
    closefile(f);
  end;
end;

// Added by Alexandre Devilliers for Dragon UnPACKer needs
procedure TUTObjectClassMusic.SaveToStream(stream: TStream);
begin
  check_initialized;
  stream.WriteBuffer(FData[1],length(FData));
end;
// END OF ADD //
{ TUTObjectClassFont }

procedure TUTObjectClassFont.GetCharacterInfo(i: integer; var texture, x,
  y, w, h: integer);
begin
  check_initialized;
  if (i >= 0) and (i <= high(FCharacters)) then
    begin
      texture := FCharacters[i].texture;
      x := FCharacters[i].x;
      y := FCharacters[i].y;
      w := FCharacters[i].w;
      h := FCharacters[i].h;
    end
  else
    begin
      texture := -1;
      x := -1;
      y := -1;
      w := -1;
      h := -1;
    end;
end;

procedure TUTObjectClassFont.InitializeObject;
begin
  inherited;
  setlength(FCharacters, 0);
  setlength(FCharRemap, 0);
  FIsRemapped := false;
  FCharactersPerPage := 0;
  FKerning:=0;
  FDropShadowX:=0;
  FDropShadowY:=0;
  FStyle:=0;
  FAntiAlias:=false;
end;

procedure TUTObjectClassFont.InterpretObject;
var
  numtextures, charidx, a, b, numchars, idx: integer;
  tmptex:array of integer;
begin
  inherited;
  if FOwner.Version > 120 then
    begin
      setlength(FCharacters, 256);
      numchars := FOwner.read_idx(buffer,utdmAsValue,'CharactersPerPage');
      FCharactersPerPage := numchars;
      setlength(FCharacters, CheckArrayLength(numchars));
      for b := 0 to numchars-1 do
        begin
          FCharacters[b].x := FOwner.read_dword(buffer,utdmAsValue,format('Characters[%u].X',[b]));
          FCharacters[b].y := FOwner.read_dword(buffer,utdmAsValue,format('Characters[%u].Y',[b]));
          FCharacters[b].w := FOwner.read_dword(buffer,utdmAsValue,format('Characters[%u].Width',[b]));
          FCharacters[b].h := FOwner.read_dword(buffer,utdmAsValue,format('Characters[%u].Height',[b]));
          FCharacters[b].texture := FOwner.read_byte(buffer,utdmAsValue,format('Characters[%u].Texture',[b]));
        end;
      numtextures:=FOwner.read_idx(buffer,utdmAsValue,'TexturesCount');
      setlength(tmptex,numtextures);
      for b:=0 to numtextures-1 do
        tmptex[b]:=FOwner.read_idx (buffer,utdmRefToObject,format('Textures[%u]',[b]));
      for b := 0 to numchars-1 do
        FCharacters[b].texture := tmptex[FCharacters[b].texture];

      FKerning:=FOwner.read_idx(buffer,utdmAsValue,'Kerning');
      // TODO : (font) 2 DWORDs unknown
      // DropShadowX, DropShadowY, Style, AntiAlias
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
      setlength(FCharRemap, 0);
      FIsRemapped := false;
    end
  else
    begin
      numtextures := FOwner.read_byte(buffer,utdmAsValue,'TexturesCount');
      setlength(FCharacters, 256);
      charidx := 0;
      for a := 1 to numtextures do
        begin
          idx := FOwner.read_idx(buffer,utdmRefToObject,format('Textures[%u].TextureIndex',[a]));
          numchars := FOwner.read_idx(buffer,utdmAsValue,format('Textures[%u].CharacterCount',[a]));
          for b := 1 to numchars do
            begin
              FCharacters[charidx].texture := idx;
              FCharacters[charidx].x := FOwner.read_dword(buffer,utdmAsValue,format('Textures[%u].Characters[%u].X',[a,b]));
              FCharacters[charidx].y := FOwner.read_dword(buffer,utdmAsValue,format('Textures[%u].Characters[%u].Y',[a,b]));
              FCharacters[charidx].w := FOwner.read_dword(buffer,utdmAsValue,format('Textures[%u].Characters[%u].Width',[a,b]));
              FCharacters[charidx].h := FOwner.read_dword(buffer,utdmAsValue,format('Textures[%u].Characters[%u].Height',[a,b]));
              inc(charidx);
            end;
        end;
      setlength(FCharacters, CheckArrayLength(charidx));
      FCharactersPerPage := FOwner.read_dword(buffer,utdmAsValue,'CharactersPerPage');
      if FOwner.Version >= 119{117} then
        begin
          FKerning:=FOwner.read_idx(buffer,utdmAsValue,'Kerning');
          // TODO : (font) 2 DWORDs unknown
          // DropShadowX, DropShadowY, Style, AntiAlias
          FOwner.read_dword(buffer);
          FOwner.read_dword(buffer);
          setlength(FCharRemap, 0);
          FIsRemapped := false;
        end
      else if FOwner.Version >= 69 then
        begin
          idx := FOwner.read_idx(buffer,utdmAsValue,'CharRemapCount');
          setlength(FCharRemap, CheckArrayLength(idx));
          for a := 0 to idx - 1 do
            begin
              FCharRemap[a].key := char(FOwner.read_byte(buffer,utdmAsValue,format('CharRemap[%u].Key',[a])));
              FCharRemap[a].value := char(FOwner.read_byte(buffer,utdmAsValue,format('CharRemap[%u].Value',[a])));
            end;
          FIsRemapped := (FOwner.read_dword(buffer,utdmAsValue,'IsRemapped') <> 0);
        end
      else
        begin
          setlength(FCharRemap, 0);
          FIsRemapped := false;
        end;
    end;
end;

function TUTObjectClassFont.GetGetMapping(c: char): string;
var
  a: integer;
begin
  result := '';
  for a := 0 to high(FCharRemap) do
    if FCharRemap[a].key = c then
      begin
        result := FCharRemap[a].Value;
        break;
      end;
end;

{ TUTObjectClassPolys }

function TUTObjectClassPolys.GetPolygonCount: integer;
begin
  check_initialized;
  result := length(FPolygons);
end;

function TUTObjectClassPolys.GetPolygon(n: integer): TUT_Struct_Polygon;
begin
  check_initialized;
  result := FPolygons[n];
end;

procedure TUTObjectClassPolys.InitializeObject;
begin
  inherited;
  setlength(FPolygons, 0);
end;

procedure TUTObjectClassPolys.InterpretObject;
var
  p: integer;
begin
  inherited;
  FOwner.read_dword(buffer,utdmAsValue,'NumPolys?');
  setlength(FPolygons, CheckArrayLength(Fowner.read_dword(buffer,utdmAsValue,'PolysCount')));
  for p := 0 to high(FPolygons) do
    FPolygons[p] := Read_Struct_Polygon(Fowner, buffer,'Polygons');
end;

procedure TUTObjectClassPolys.PrepareExporter(exporter: TUT_MeshExporter; frames: TIntegerDynArray);
const
  material_colors: array[0..5] of TColor = (clBlue, clRed, clLime, clYellow, clAqua, clSilver);
var
  o, m, v, f,fb,matidx: integer;tx:string;found:boolean;
begin
  check_initialized;
  o:=exporter.AddObject;
  exporter.Objects[o].AnimationFrames := 1;
  setlength(exporter.Objects[o].Faces,0);
  setlength(exporter.Objects[o].Vertices,0);
  for m:=0 to high(FPolygons) do
    begin
      tx:=FOwner.GetObjectPath(-1,FPolygons[m].Texture);
      matidx:=0;
      found:=false;
      for v:=0 to high(exporter.Objects[o].Materials) do
        if exporter.Objects[o].Materials[v].Texture=tx then
          begin
            matidx:=v;
            found:=true;
            break;
          end;
      if not found then
        begin
          matidx:=length(exporter.Objects[o].Materials);
          setlength(exporter.Objects[o].Materials, matidx+1);
          with exporter.Objects[o].Materials[matidx] do
            begin
              name := 'Material'+inttostr(matidx);
              if matidx<=high(material_colors) then
                begin
                  diffusecolor[0] := material_colors[matidx] and $FF;
                  diffusecolor[1] := (material_colors[matidx] shr 8) and $FF;
                  diffusecolor[2] := (material_colors[matidx] shr 16) and $FF;
                end
              else
                begin
                  diffusecolor[0] := random(256);
                  diffusecolor[1] := random(256);
                  diffusecolor[2] := random(256);
                end;
              Texture:=tx;
            end;
        end;
      fb:=length(exporter.Objects[o].Faces);
      v:=length(exporter.Objects[o].Vertices);
      setlength(exporter.Objects[o].Faces, length(exporter.Objects[o].Faces)+max(0,length(FPolygons[m].Vertex)-2));
      setlength(exporter.Objects[o].Vertices, length(exporter.Objects[o].Vertices)+(max(0,length(FPolygons[m].Vertex)-2))*3);
      // TODO : must set texture coordinates
      for f:=2 to high(FPolygons[m].Vertex) do
        begin
          with exporter.Objects[o].Vertices[v] do
            begin
              x := FPolygons[m].Vertex[0].X;
              y := FPolygons[m].Vertex[0].Y;
              z := FPolygons[m].Vertex[0].Z;
              U := 0;
              V := 0;
            end;
          inc(v);
          with exporter.Objects[o].Vertices[v] do
            begin
              x := FPolygons[m].Vertex[f].X;
              y := FPolygons[m].Vertex[f].Y;
              z := FPolygons[m].Vertex[f].Z;
              U := 0;
              V := 0;
            end;
          inc(v);
          with exporter.Objects[o].Vertices[v] do
            begin
              x := FPolygons[m].Vertex[f-1].X;
              y := FPolygons[m].Vertex[f-1].Y;
              z := FPolygons[m].Vertex[f-1].Z;
              U := 0;
              V := 0;
            end;
          inc(v);
          with exporter.Objects[o].Faces[fb] do
            begin
              VertexIndex1 := v - 3;
              VertexIndex2 := v - 2;
              VertexIndex3 := v - 1;
              MaterialIndex := matidx;
              Flags := 0;
            end;
          inc(fb);
        end;
      if assigned(FOwner.FOnProcessMessages) then FOwner.OnProcessMessages(FOwner);
    end;
(* TODO : Add option to create triangles using the polygon centroid:

FUNCTION PolygonCentroid(CONST Polygon:  ARRAY OF TXYPoint;
                           VAR Area:  DOUBLE):  TXYPoint;

    VAR
      aSum:  DOUBLE;
      i   :  INTEGER;
      j   :  INTEGER;
      Term:  DOUBLE;
      xSum:  DOUBLE;
      ySum:  DOUBLE;
  BEGIN
    IF   High(Polygon) < 3
    THEN RAISE EPolygonError.Create('PolygonCentroid:  Polygon is degenerate');

    aSum := 0.0;
    xSum := 0.0;
    ySum := 0.0;
    FOR i := 0 TO High(Polygon)-1 DO
    BEGIN
      j := i + 1;
      Term := Polygon[i].X * Polygon[j].Y  -  Polygon[j].X * Polygon[i].Y;
      aSum := aSum + Term;
      xSum := xSum + (Polygon[j].X + Polygon[i].X) * Term;
      ySum := ySum + (Polygon[j].Y + Polygon[i].Y) * Term
    END;

    Area := 0.5 * aSum;

    TRY
      RESULT.X := xSum / (3.0 * aSum);
      RESULT.Y := ySum / (3.0 * aSum);
    EXCEPT
      ON EZeroDivide DO RAISE EPolygonError.Create('PolygonCentroid:  Zero
Area.')
    END;

  END {PolygonCentroid};
*)
end;

{ TUTBitmap }

constructor TUTBitmap.Create (width,height,bpp:dword;masked:boolean=false);
begin
     FBPP:=bpp;
     FWidth:=width;
     FHeight:=height;
     FMasked:=masked;
     FPalette:=0;
     GetMem (FData,FWidth*FHeight*(FBPP div 8));
     FOriginalData:=nil;
     FOriginalDataSize:=0;
     FOriginalFormat:=-1;
end;

destructor TUTBitmap.Destroy;
begin
     FreeMem (FData);
     if FOriginalData<>nil then FreeMem(FOriginalData);
     inherited;
end;

function TUTBitmap.AsBitmap: TBitmap;
var pe:array[0..255] of PALETTEENTRY;y:integer;
begin
     result:=TBitmap.create;
     case FBPP of
       32:result.pixelformat:=pf32bit;
       24:result.pixelformat:=pf24bit;
       8:begin
         result.pixelformat:=pf8bit;
         if FPalette<>0 then
           begin
             GetPaletteEntries (FPalette,0,256,pe);
             SetPaletteEntries (result.palette,0,256,pe);
             result.PaletteModified:=true;
           end;
         end;
     end;
     result.width:=FWidth;
     result.Height:=FHeight;
     for y:=0 to FHeight-1 do
       move (scanline[y]^,result.scanline[y]^,FWidth*(FBPP div 8));
end;

function TUTBitmap.AsBitmapWithAlpha: TBitmap;
var pe:array[0..255] of PALETTEENTRY;c:byte;x,y,v:integer;
begin
     result:=TBitmap.create;
     case FBPP of
       24,32:
         begin
           if FBPP=32 then
             result.pixelformat:=pf32bit
           else
             result.pixelformat:=pf24bit;
           result.width:=FWidth;
           result.Height:=FHeight;
           for y:=0 to FHeight-1 do
             move (scanline[y]^,result.scanline[y]^,FWidth*(FBPP div 8));
           result.pixelformat:=pf32bit;
         end;
       8:begin
           result.pixelformat:=pf32bit;
           if FPalette<>0 then
             GetPaletteEntries (FPalette,0,256,pe);
           result.width:=FWidth;
           result.Height:=FHeight;
           for y:=0 to FHeight-1 do
             for x:=0 to FWidth-1 do
               begin
                 c:=PByteArray(scanline[y])^[x];
                 v:=(pe[c].peRed shl 16) or (pe[c].peGreen shl 8) or pe[c].peBlue;
                 if (c<>0) or not FMasked then v:=v or integer($FF000000) else v:=v and $00FFFFFF;
                 move (v,PByteArray(result.scanline[y])^[x*4],4);
               end;
         end;
     end;
end;

function TUTBitmap.AsAlpha: TBitmap;
var y,x,v:integer;
begin
     result:=TBitmap.create;
     result.pixelformat:=pf24bit;
     result.width:=FWidth;
     result.Height:=FHeight;
     if FBPP=32 then
       begin
         for y:=0 to FHeight-1 do
           for x:=0 to FWidth-1 do
             begin
               v:=PByteArray(scanline[y])^[x*4+3];
               v:=v or (v shl 8) or (v shl 16);
               move (v,PByteArray(result.scanline[y])^[x*3],3);
             end;
       end
     else if FBPP=8 then
       begin
         for y:=0 to FHeight-1 do
           for x:=0 to FWidth-1 do
             begin
               if (PByteArray(scanline[y])^[x]=0) and FMasked then v:=$000000 else v:=$FFFFFF;
               move (v,PByteArray(result.scanline[y])^[x*3],3);
             end;
       end
     else
       begin
         v:=$FFFFFF;
         for y:=0 to FHeight-1 do
           for x:=0 to FWidth-1 do
             move (v,PByteArray(result.scanline[y])^[x*3],3);
       end
end;

function TUTBitmap.GetScanLine(y: integer): pointer;
begin
  result:=pointer(integer(FData)+y*FWidth*(FBPP div 8));
end;

procedure TUTBitmap.SetPalette(const Value: HPALETTE);
begin
  if FPalette<>0 then DeleteObject(FPalette);
  FPalette := Value;
end;

procedure TUTBitmap.SetOriginal(format:integer;var buffer; size: int64);
begin
  if FOriginalData<>nil then FreeMem(FOriginalData);
  FOriginalFormat:=format;
  FOriginalDataSize:=size;
  GetMem (FOriginalData,size);
  move (buffer,FOriginalData^,size);
end;

{ TUTObjectClassTexture }

function TUTObjectClassTexture.GetCompMipMap(i: integer): TUTBitmap;
begin
  check_initialized;
  result := FCompMipMaps[i];
end;

function TUTObjectClassTexture.GetCompMipMapCount: integer;
begin
  check_initialized;
  result := length(FCompMipMaps);
end;

function TUTObjectClassTexture.GetMipMap(i: integer): TUTBitmap;
begin
  check_initialized;
  if (i >= 0) and (i < length(FMipMaps)) then
    result := FMipMaps[i]
  else
    result := nil;
end;

function TUTObjectClassTexture.GetMipMapCount: integer;
begin
  check_initialized;
  result := length(FMipMaps);
end;

procedure TUTObjectClassTexture.InitializeObject;
begin
  inherited;
  setlength(FMipMaps, 0);
  setlength(FCompMipMaps, 0);
end;

procedure TUTObjectClassTexture.InterpretObject;
var
  a, data_pos, block_size: integer;
  y,w,h: dword;
  compformat: integer;
  function GetRGBA(r, g, b, a: Byte): DWORD;
  begin
    Result := (r or (g shl 8) or (b shl 16) or (a shl 24));
  end;
  procedure ReadMipMapData(format, block_size, w, h: dword; var MipMap: TUTBitmap);
  var
    x, palette, bpp: integer;
    ed2: TUTExportTableObjectData;
    color: array[0..3] of word;
    yy: array[0..3] of byte;
    alpha:array[0..3,0..3] of byte;
    alphaDXT3_tmp:array[0..3] of word;
    alphaDXT5_base:array[0..1] of byte;
    alphaDXT5_index:array[0..3,0..3] of byte;
    alphaDXT5_values:array[0..7] of byte;
    real_color: array[0..3] of DWORD;
    y, c, bx, by, yd4, xd4,savepos: integer;
    yv: byte; av : word;
    rgba:array[0..3] of byte;
    block:pointer;
    alphaDXT5_basedw:dword;
    tmp:boolean;
  begin
    case format of
      TEXF_P8:
        bpp:=8;
      TEXF_RGB8, TEXF_RGB16,TEXF_L8,TEXF_G16:
        bpp:=24;
      TEXF_DXT1,TEXF_DXT3,TEXF_DXT5,TEXF_RGBA7,TEXF_RGBA8:
        bpp:=32;
      else //TEXF_NODATA, TEXF_RRRGGGBBB
        bpp:=24;
    end;
    MipMap := TUTBitmap.create (w,h,bpp,Properties['bMasked']);
    // Save original data
    if (block_size<>0) and FOwner.SaveOriginalTextureFormat then
      begin
        savepos:=buffer.Position;
        getmem(block,block_size);
        FOwner.read_buffer(block^,block_size,buffer,'MipMapData');
        MipMap.SetOriginal(format,block^,block_size);
        freemem(block);
        buffer.Seek(savepos,soFromBeginning);
      end;
    // Extract palette
    palette := Properties['palette']; // do not localize
    if palette > 0 then
      begin
        ed2 := FOwner.Exported[palette - 1];
        tmp:=FOwner.CallOnBasicDataEvent;
        FOwner.CallOnBasicDataEvent:=false;
        ed2.UTObject.ReadObject;
        FOwner.CallOnBasicDataEvent:=tmp;
        MipMap.Palette := TUTObjectClassPalette(ed2.UTObject).GetPalette;
        ed2.UTObject.ReleaseObject;
      end;
    //else : don't supports imported palettes
    // Extract bitmap
    if block_size <> 0 then             // block_size=0 in some Texture descendants
      begin
        tmp:=FOwner.CallOnBasicDataEvent;
        FOwner.CallOnBasicDataEvent:=false;
        case format of
          TEXF_P8:
            begin                       // Palettized
              for y := 0 to MipMap.height - 1 do
                FOwner.read_buffer(MipMap.scanline[y]^, MipMap.width, buffer);
            end;
          TEXF_DXT1, TEXF_DXT3, TEXF_DXT5:
            begin
              // The texture needs to have a size divisible by 4
              // DXT1 format allows for one transparent color and DXT3/DXT5 for
              // an alpha channel, but we dont use transparency.
              yd4 := (MipMap.height div 4);
              xd4 := (MipMap.width div 4);
              if yd4 = 0 then yd4 := 1;
              if xd4 = 0 then xd4 := 1;
              for y := 0 to yd4 - 1 do
                for x := 0 to xd4 - 1 do
                  begin
                    if format=TEXF_DXT3 then
                       begin
                         alphaDXT3_tmp[0]:=FOwner.read_word(buffer);
                         alphaDXT3_tmp[1]:=FOwner.read_word(buffer);
                         alphaDXT3_tmp[2]:=FOwner.read_word(buffer);
                         alphaDXT3_tmp[3]:=FOwner.read_word(buffer);
                         for by := 0 to 3 do
                           begin
                             av := alphaDXT3_tmp[by];
                             for bx := 0 to 3 do
                               begin
                                 alpha[by,bx]:=(av and $0F) shl 4; // scaling the 4 bits alpha value
                                 av := av shr 4;
                               end;
                           end;
                       end
                    else if format=TEXF_DXT5 then
                       begin
                         alphaDXT5_base[0]:=FOwner.read_byte(buffer);
                         alphaDXT5_base[1]:=FOwner.read_byte(buffer);
                         alphaDXT5_basedw:=FOwner.read_word(buffer);
                         alphaDXT5_basedw:=(dword(FOwner.read_byte(buffer)) shl 16) or alphaDXT5_basedw;
                         alphaDXT5_index[0,0]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[0,1]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[0,2]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[0,3]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[1,0]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[1,1]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[1,2]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[1,3]:=alphaDXT5_basedw and $07;
                         //alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_basedw:=FOwner.read_word(buffer);
                         alphaDXT5_basedw:=(dword(FOwner.read_byte(buffer)) shl 16) or alphaDXT5_basedw;
                         alphaDXT5_index[2,0]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[2,1]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[2,2]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[2,3]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[3,0]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[3,1]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[3,2]:=alphaDXT5_basedw and $07;
                         alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         alphaDXT5_index[3,3]:=alphaDXT5_basedw and $07;
                         //alphaDXT5_basedw:=alphaDXT5_basedw shr 3;
                         if (alphaDXT5_base[0] > alphaDXT5_base[1]) then
                           begin
                             alphaDXT5_values[0]:=alphaDXT5_base[0];
                             alphaDXT5_values[1]:=alphaDXT5_base[1];
                             for bx:=0 to 5 do
                               alphaDXT5_values[2+bx]:=(alphaDXT5_base[0]*(6-bx)+alphaDXT5_base[1]*(bx+1){+3}) div 7;
                           end
                         else
                           begin
                             alphaDXT5_values[0]:=alphaDXT5_base[0];
                             alphaDXT5_values[1]:=alphaDXT5_base[1];
                             for bx:=0 to 3 do
                               alphaDXT5_values[2+bx]:=(alphaDXT5_base[0]*(4-bx)+alphaDXT5_base[1]*(bx+1){+2}) div 5;
                             alphaDXT5_values[6]:=$00;
                             alphaDXT5_values[7]:=$FF;
                           end;
                         // get indexed alpha values
                         for by:=0 to 3 do
                           for bx:=0 to 3 do
                             alpha[by,bx]:=alphaDXT5_values[alphaDXT5_index[by,bx]];
                       end;
                    // read 4x4 block
                    color[0] := FOwner.read_word(buffer);
                    color[1] := FOwner.read_word(buffer);
                    yy[0] := FOwner.read_byte(buffer);
                    yy[1] := FOwner.read_byte(buffer);
                    yy[2] := FOwner.read_byte(buffer);
                    yy[3] := FOwner.read_byte(buffer);
                    // get colors
                    for c := 0 to 1 do
                      real_color[c] := GetRGBA(
                        ((color[c] and $001F) shl 3),
                        ((color[c] and $07E0) shr 3),
                        ((color[c] and $F800) shr 8),
                        $FF
                        );
                    if (color[0] > color[1]) or (format<>TEXF_DXT1) then
                      begin
                        real_color[2] := GetRGBA(
                          (2 * GetRValue(real_color[0]) + GetRValue(real_color[1])) div 3,
                          (2 * GetGValue(real_color[0]) + GetGValue(real_color[1])) div 3,
                          (2 * GetBValue(real_color[0]) + GetBValue(real_color[1])) div 3,
                          $FF);
                        real_color[3] := GetRGBA(
                          (GetRValue(real_color[0]) + 2 * GetRValue(real_color[1])) div 3,
                          (GetGValue(real_color[0]) + 2 * GetGValue(real_color[1])) div 3,
                          (GetBValue(real_color[0]) + 2 * GetBValue(real_color[1])) div 3,
                          $FF);
                      end
                    else
                      begin
                        real_color[2] := GetRGBA(
                          (GetRValue(real_color[0]) + GetRValue(real_color[1])) div 2,
                          (GetGValue(real_color[0]) + GetGValue(real_color[1])) div 2,
                          (GetBValue(real_color[0]) + GetBValue(real_color[1])) div 2,
                          $FF);
                        real_color[3] := GetRGBA(0,0,0,0); // transparent
                      end;
                    // get pixels
                    for by := 0 to 3 do
                      begin
                        yv := yy[by];
                        for bx := 0 to 3 do
                          begin
                            if (y * 4 + by < MipMap.height) and (x * 4 + bx < MipMap.width) then
                              begin
                              if format=TEXF_DXT1 then
                                move(real_color[yv and 3], PByteArray(MipMap.scanline[y * 4 + by])^[4 * (x * 4 + bx)], 4)
                              else if format=TEXF_DXT3 then
                                begin
                                  move(real_color[yv and 3], PByteArray(MipMap.scanline[y * 4 + by])^[4 * (x * 4 + bx)], 3);
                                  move(alpha[by,bx], PByteArray(MipMap.scanline[y * 4 + by])^[4 * (x * 4 + bx)+3], 1);
                                end
                              else if format=TEXF_DXT5 then
                                begin
                                  move(real_color[yv and 3], PByteArray(MipMap.scanline[y * 4 + by])^[4 * (x * 4 + bx)], 3);
                                  move(alpha[by,bx], PByteArray(MipMap.scanline[y * 4 + by])^[4 * (x * 4 + bx)+3], 1);
                                end;
                              end;
                            yv := yv shr 2;
                          end;
                      end;
                  end;
            end;
          TEXF_RGBA8:
            begin
              for y := 0 to MipMap.height - 1 do
                for x := 0 to MipMap.width - 1 do
                  begin
                    FOwner.read_buffer(rgba[0],4,buffer); // read RGBA values for this pixel
                    move (rgba,PByteArray(MipMap.scanline[y])^[4*x],4);
                  end;
            end;
          TEXF_RGB8: // not tested
            begin
              for y := 0 to MipMap.height - 1 do
                for x := 0 to MipMap.width - 1 do
                  begin
                    FOwner.read_buffer(rgba[0],3,buffer); // read RGB values for this pixel
                    move (rgba,PByteArray(MipMap.scanline[y])^[3*x],3); // copy only RGB values
                  end;
            end;
          TEXF_RGBA7: // not tested
            begin
              for y := 0 to MipMap.height - 1 do
                for x := 0 to MipMap.width - 1 do
                  begin
                    // read RGBA values for this pixel
                    FOwner.read_buffer(rgba[0],4,buffer);
                    // convert to 8 bit
                    rgba[0]:=rgba[0] shl 1;
                    rgba[1]:=rgba[1] shl 1;
                    rgba[2]:=rgba[2] shl 1;
                    rgba[3]:=rgba[3] shl 1;
                    // copy only RGB values
                    move (rgba,PByteArray(MipMap.scanline[y])^[4*x],4);
                  end;
            end;
          TEXF_RGB16: // not tested
            begin
              for y := 0 to MipMap.height - 1 do
                for x := 0 to MipMap.width - 1 do
                  begin
                    // read 16-bit RGB values for this pixel and convert to 8-bit values
                    rgba[0]:=FOwner.read_word(buffer) div 256;
                    rgba[1]:=FOwner.read_word(buffer) div 256;
                    rgba[2]:=FOwner.read_word(buffer) div 256;
                    // copy only RGB values
                    move (rgba,PByteArray(MipMap.scanline[y])^[3*x],3);
                  end;
            end;
          TEXF_L8: // not tested
            begin
              for y := 0 to MipMap.height - 1 do
                for x := 0 to MipMap.width - 1 do
                  begin
                    FOwner.read_buffer(rgba[0],1,buffer); // read Grayscale value for this pixel
                    rgba[1]:=rgba[0];
                    rgba[2]:=rgba[0];
                    move (rgba,PByteArray(MipMap.scanline[y])^[3*x],3); // copy only RGB values
                  end;
            end;
          TEXF_G16: // not tested
            begin
              for y := 0 to MipMap.height - 1 do
                for x := 0 to MipMap.width - 1 do
                  begin
                    // read 16-bit grayscale value for this pixel and convert to 8-bit value.
                    rgba[0]:=FOwner.read_word(buffer) div 256;
                    rgba[1]:=rgba[0];
                    rgba[2]:=rgba[0];
                    move (rgba,PByteArray(MipMap.scanline[y])^[3*x],3); // copy only RGB values
                  end;
            end;
          {TEXF_RRRGGGBBB: // not tested
            begin

            end;}
        else
          begin
            //buffer.Seek(block_size, soFromCurrent);
            raise Exception.create (rsUnknownTextureFormat);
          end;
        end;
        FOwner.CallOnBasicDataEvent:=tmp;
      end;
  end;

begin
  inherited;
  if FOwner.GameHint=UTPGH_ArmyOperations then
    FOwner.read_dword(buffer) // TODO : unknown dword in Army Operations
  else if FOwner.GameHint=UTPGH_Lineage2 then
    FOwner.read_dword(buffer) // TODO : unknown dword in Lineage 2
  else if FOwner.GameHint=UTPGH_Unreal2 then
    FOwner.read_byte(buffer); // TODO : unknown byte/index in Unreal 2
  // Read MipMaps
  setlength(FMipMaps, CheckArrayLength(FOwner.read_byte(buffer,utdmAsValue,'MipMapCount')));
  for a := 0 to high(FMipMaps) do
    begin
      if FOwner.Version >= 63 then
        begin
          y := FOwner.read_dword(buffer,utdmOffset,'PositionAfterBlock') - FStartInPackage;
          block_size := FOwner.read_idx(buffer,utdmAsValue,'BlockSize');
          data_pos := buffer.position;
          if FOwner.FGameHint=UTPGH_Lineage2 then y:=data_pos + block_size;
        end
      else
        begin
          block_size := FOwner.read_idx(buffer,utdmAsValue,'BlockSize');
          data_pos := buffer.position;
          y := data_pos + block_size;
        end;
      buffer.seek(y, soFromBeginning);
      w := FOwner.read_dword(buffer,utdmAsValue,'Width') and $2FFF;
      h := FOwner.read_dword(buffer,utdmAsValue,'Height') and $2FFF;
      buffer.seek(data_pos, soFromBeginning);
      compformat := Properties.GetPropertyByNameValueDefault('Format', TEXF_P8);
      ReadMipMapData(compformat, block_size, w, h, FMipMaps[a]);
      FOwner.read_dword(buffer,utdmAsValue,'Width');
      FOwner.read_dword(buffer,utdmAsValue,'Height');
      FOwner.read_byte(buffer,utdmAsValue,'WidthBits');
      FOwner.read_byte(buffer,utdmAsValue,'HeightBits');
      if assigned(FOwner.FOnProcessMessages) then FOwner.OnProcessMessages(FOwner);
    end;
  // Read Compressed MipMaps
  if Properties['bHasComp'] then
    begin
      compformat := Properties.GetPropertyByNameValueDefault('CompFormat', TEXF_DXT1);
      setlength(FCompMipMaps, CheckArrayLength(FOwner.read_byte(buffer,utdmAsValue,'CompressedMipMapCount')));
      for a := 0 to high(FCompMipMaps) do
        begin
          if FOwner.Version >= 63 then
            begin
              y := FOwner.read_dword(buffer,utdmOffset,'PositionAfterBlock') - FStartInPackage;
              block_size := FOwner.read_idx(buffer,utdmAsValue,'BlockSize');
              data_pos := buffer.position;
            end
          else
            begin
              block_size := FOwner.read_idx(buffer,utdmAsValue,'BlockSize');
              data_pos := buffer.position;
              y := data_pos + block_size;
            end;
          buffer.seek(y, soFromBeginning);
          w := FOwner.read_dword(buffer,utdmAsValue,'Width');
          h := FOwner.read_dword(buffer,utdmAsValue,'Height');
          buffer.seek(data_pos, soFromBeginning);
          ReadMipMapData(compformat, block_size, w,h, FCompMipMaps[a]);
          FOwner.read_dword(buffer,utdmAsValue,'Width');
          FOwner.read_dword(buffer,utdmAsValue,'Height');
          FOwner.read_byte(buffer,utdmAsValue,'WidthBits');
          FOwner.read_byte(buffer,utdmAsValue,'HeightBits');
          if assigned(FOwner.FOnProcessMessages) then FOwner.OnProcessMessages(FOwner);
        end;
    end;
end;

procedure TUTObjectClassTexture.DoReleaseObject;
var
  a: integer;
begin
  for a := 0 to high(FMipMaps) do
    FMipMaps[a].free;
  setlength(FMipMaps, 0);
  for a := 0 to high(FCompMipMaps) do
    FCompMipMaps[a].free;
  setlength(FCompMipMaps, 0);
  inherited;
end;
{
procedure TUTObjectClassTexture.SaveCompMipMapToFile(mipmap: integer;
  filename: string);
begin
  check_initialized;
  FCompMipMaps[mipmap].savetofile(filename);
  FCompMipMaps[mipmap].dormant;
end;

procedure TUTObjectClassTexture.SaveMipMapToFile(mipmap: integer;
  filename: string);
begin
  check_initialized;
  FMipMaps[mipmap].savetofile(filename);
  FMipMaps[mipmap].dormant;
end;

procedure TUTObjectClassTexture.SaveGoodMipMapToFile(mipmap: integer;
  filename: string);
begin
  check_initialized;
  GoodMipMap[mipmap].savetofile(filename);
  GoodMipMap[mipmap].dormant;
end;
}
function TUTObjectClassTexture.GetGoodMipMap(i: integer): TUTBitmap;
begin
  check_initialized;
  if {((Properties['format']=TEXF_NODATA) or (MipMapCount=0)) and} Properties['bhascomp'] then
    result:=CompMipMap[i]
  else
    result:=MipMap[i];
end;

function TUTObjectClassTexture.GetGoodMipMapCount: integer;
begin
  check_initialized;
  if ((Properties['format']=TEXF_NODATA) or (MipMapCount=0)) and Properties['bhascomp'] then
    result:=CompMipMapCount
  else
    result:=MipMapCount;
end;

{ TUTObjectClassPrimitive }

procedure TUTObjectClassPrimitive.InitializeObject;
begin
  inherited;
  fillchar(FPrimitiveBoundingBox, sizeof(FPrimitiveBoundingBox), 0);
  fillchar(FPrimitiveBoundingSphere, sizeof(FPrimitiveBoundingSphere), 0);
end;

procedure TUTObjectClassPrimitive.InterpretObject;
begin
  inherited;
  // UPrimitive.BoundingBox 
  FPrimitiveBoundingBox := Read_Struct_BoundingBox(FOwner, buffer,'PrimitiveBoundingBox');
  // UPrimitive.BoundingSphere
  FPrimitiveBoundingSphere := Read_Struct_BoundingSphere(FOwner, buffer,'PrimitiveBoundingSphere');
end;

{ TUTObjectClassMesh }

function TUTObjectClassMesh.GetAnimFrames: integer;
begin
  check_initialized;
  result := FAnimFrames;
end;

function TUTObjectClassMesh.GetAnimSeq(i: integer): TUT_Struct_AnimSeq;
begin
  check_initialized;
  result := FAnimSeqs[i];
end;

function TUTObjectClassMesh.GetAnimSeqCount: integer;
begin
  check_initialized;
  result := length(FAnimSeqs);
end;

function TUTObjectClassMesh.GetBoundingBox(i: integer): TUT_Struct_BoundingBox;
begin
  check_initialized;
  result := FBoundingBoxes[i];
end;

function TUTObjectClassMesh.GetBoundingBoxCount: integer;
begin
  check_initialized;
  result := length(FBoundingBoxes);
end;

function TUTObjectClassMesh.GetBoundingSphere(i: integer): TUT_Struct_BoundingSphere;
begin
  check_initialized;
  result := FBoundingSpheres[i];
end;

function TUTObjectClassMesh.GetBoundingSphereCount: integer;
begin
  check_initialized;
  result := length(FBoundingSpheres);
end;

function TUTObjectClassMesh.GetConnect(i: integer): TUT_Struct_Connects;
begin
  check_initialized;
  result := FConnects[i];
end;

function TUTObjectClassMesh.GetConnectsCount: integer;
begin
  check_initialized;
  result := length(FConnects);
end;

function TUTObjectClassMesh.GetTexture(i: integer): TUT_Struct_Texture;
begin
  check_initialized;
  result := FTextures[i];
end;

function TUTObjectClassMesh.GetTextureLOD(i: integer): single;
begin
  check_initialized;
  result := FTextureLOD[i];
end;

function TUTObjectClassMesh.GetTextureLODCount: integer;
begin
  check_initialized;
  result := length(FTextureLOD);
end;

function TUTObjectClassMesh.GetTexturesCount: integer;
begin
  check_initialized;
  result := length(FTextures);
end;

function TUTObjectClassMesh.GetTri(i: integer): TUT_Struct_Tri;
begin
  check_initialized;
  result := FTris[i];
end;

function TUTObjectClassMesh.GetTrisCount: integer;
begin
  check_initialized;
  result := length(FTris);
end;

function TUTObjectClassMesh.GetVert(i: integer): TUT_Struct_Vert;
begin
  check_initialized;
  result := FVerts[i];
end;

function TUTObjectClassMesh.GetVertLink(i: integer): integer;
begin
  check_initialized;
  result := FVertLinks[i];
end;

function TUTObjectClassMesh.GetVertLinksCount: integer;
begin
  check_initialized;
  result := length(FVertLinks);
end;

function TUTObjectClassMesh.GetVertsCount: integer;
begin
  check_initialized;
  result := length(FVerts);
end;

procedure TUTObjectClassMesh.InitializeObject;
begin
  inherited;
  setlength(FVerts, 0);
  setlength(FTris, 0);
  setlength(FTextures, 0);
  setlength(FAnimSeqs, 0);
  setlength(FConnects, 0);
  setlength(FBoundingBoxes, 0);
  setlength(FBoundingSpheres, 0);
  setlength(FVertLinks, 0);
  setlength(FTextureLOD, 0);
end;

procedure TUTObjectClassMesh.InterpretObject;
var
  a, seekpos, size, p: integer;
  highres: boolean;
begin
  inherited;
  // UMesh.Verts
  if FOwner.Version > 61 then
    seekpos := FOwner.read_dword(buffer,utdmOffset,'JumpOverArray') - FStartInPackage
  else
    seekpos := 0;
  size := FOwner.read_idx(buffer,utdmAsValue,'Verts Array Size');
  p := buffer.position;
  if (FOwner.GameHint = UTPGH_DeusEx) or
    ((size <> 0) and (seekpos > 0) and ((seekpos - p) div size = 8)) then
    highres := true                     // DeusEx
  else
    highres := false;                   // UT and others
  setlength(FVerts, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FVerts[a] := Read_Struct_Vert(FOwner, buffer, highres,'Verts');
  // UMesh.Tris
  if FOwner.Version > 61 then
    FOwner.read_dword(buffer,utdmOffset,'JumpOverArray');
  size := FOwner.read_idx(buffer,utdmAsValue,'Tris Array Size');
  setlength(FTris, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FTris[a] := Read_Struct_Tri(Fowner, buffer,'Tris');
  // UMesh.AnimSeqs
  size := FOwner.read_idx(buffer,utdmAsValue,'AnimSeqs Array Size');
  setlength(Fanimseqs, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FAnimSeqs[a] := Read_Struct_AnimSeq(FOwner, buffer,'AnimSeqs');
  // UMesh.Connects
  if FOwner.Version > 61 then
    FOwner.read_dword(buffer,utdmOffset,'JumpOverArray');
  size := FOwner.read_idx(buffer,utdmAsValue,'Connects Array Size');
  setlength(FConnects, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FConnects[a] := Read_Struct_Connects(FOwner, buffer,'Connects');
  // UMesh.BoundingBox
  FBoundingBox := Read_Struct_BoundingBox(FOwner, buffer,'BoundingBox');
  // UMesh.BoundingSphere
  FBoundingSphere := Read_Struct_BoundingSphere(FOwner, buffer,'BoundingSphere');
  // UMesh.VertLinks
  if FOwner.Version > 61 then
    FOwner.read_dword(buffer,utdmOffset,'JumpOverArray');
  size := FOwner.read_idx(buffer,utdmAsValue,'VertLinks Array Size');
  setlength(FVertLinks, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FVertLinks[a] := FOwner.read_dword(buffer,utdmAsValue,format('VertLink[%d]',[a]));
  // UMesh.Textures
  size := FOwner.read_idx(buffer,utdmAsValue,'Textures Array Size');
  setlength(FTextures, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FTextures[a] := Read_Struct_Texture(FOwner, buffer,'Textures');
  // UMesh.BoundingBoxes
  size := FOwner.read_idx(buffer,utdmAsValue,'BoundingBoxes Array Size');
  setlength(FBoundingBoxes, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FBoundingBoxes[a] := Read_Struct_BoundingBox(FOwner, buffer,'BoundingBoxes');
  // UMesh.BoundingSpheres
  size := FOwner.read_idx(buffer,utdmAsValue,'BoundingSpheres Array Size');
  setlength(FBoundingSpheres, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FBoundingSpheres[a] := Read_Struct_BoundingSphere(FOwner, buffer,'BoundingSpheres');
  // UMesh.FrameVerts
  FFrameVerts := FOwner.read_dword(buffer,utdmAsValue,'FrameVerts');
  // UMesh.AnimFrames
  FAnimFrames := FOwner.read_dword(buffer,utdmAsValue,'AnimFrames');
  // UMesh.ANDFlags
  FANDFlags := FOwner.read_dword(buffer,utdmAsValue,'ANDFlags');
  // UMesh.ORFlags
  FORFlags := FOwner.read_dword(buffer,utdmAsValue,'ORFlags');
  // UMesh.Scale
  FScale := Read_Struct_Vector(FOwner, buffer,'Scale');
  // UMesh.Origin
  FOrigin := Read_Struct_Vector(FOwner, buffer,'Origin');
  // UMesh.RotOrigin
  FRotOrigin := Read_Struct_Rotator(FOwner, buffer,'RotOrigin');
  // UMesh.CurPoly
  FCurPoly := FOwner.read_dword(buffer,utdmAsValue,'CurPoly');
  // UMesh.CurVertex
  FCurVertex := FOwner.read_dword(buffer,utdmAsValue,'CurVertex');
  // UMesh.TextureLOD
  if FOwner.Version >= 66 then
    begin
      size := FOwner.read_idx(buffer,utdmAsValue,'TextureLOD Array Size');
      setlength(FTextureLOD, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FTextureLOD[a] := FOwner.read_FLOAT(buffer,'TextureLOD');
    end
  else if FOwner.Version = 65 then
    begin
      setlength(FTextureLOD, 1);
      FTextureLOD[0] := FOwner.read_FLOAT(buffer,'TextureLOD');
    end;
end;

procedure TUTObjectClassMesh.PrepareExporter(exporter: TUT_MeshExporter; frames: TIntegerDynArray);
const
  material_colors: array[0..5] of TColor = (clBlue, clRed, clLime, clYellow, clAqua, clSilver);
var
  m, firstvert, v, f, o: integer;
begin
  check_initialized;
  if length(frames) = 0 then
    begin
      setlength(frames, 1);
      frames[0] := 0;
    end;
  o:=exporter.AddObject;
  setlength(exporter.Objects[o].Materials, length(FTextures));
  for m := 0 to high(FTextures) do
    begin
      exporter.Objects[o].Materials[m].name := 'Material' + inttostr(FTextures[m].Value);
      exporter.Objects[o].Materials[m].Texture:=FOwner.GetObjectPath(-1,FTextures[m].Value);
      if m <= high(material_colors) then
        begin
          exporter.Objects[o].Materials[m].diffusecolor[0] := material_colors[m] and $FF;
          exporter.Objects[o].Materials[m].diffusecolor[1] := (material_colors[m] shr 8) and $FF;
          exporter.Objects[o].Materials[m].diffusecolor[2] := (material_colors[m] shr 16) and $FF;
        end
      else
        begin
          exporter.Objects[o].Materials[m].diffusecolor[0] := random(256);
          exporter.Objects[o].Materials[m].diffusecolor[1] := random(256);
          exporter.Objects[o].Materials[m].diffusecolor[2] := random(256);
        end;
    end;
  exporter.Objects[o].AnimationFrames := length(frames);
  setlength(exporter.Objects[o].Faces, length(FTris));
  setlength(exporter.Objects[o].Vertices, 3 * length(frames) * length(FTris));
  v := 0;
  for f := 0 to high(frames) do
    begin
      firstvert := frames[f] * FFrameVerts;
      for m := 0 to high(FTris) do
        begin
          inc(v);
          with exporter.Objects[o].Vertices[v] do
            begin
              x := FVerts[firstvert + FTris[m].VertexIndex1].X;
              y := FVerts[firstvert + FTris[m].VertexIndex1].Y;
              z := FVerts[firstvert + FTris[m].VertexIndex1].Z;
              U := FTris[m].U1;
              V := FTris[m].V1;
            end;
          inc(v);
          with exporter.Objects[o].Vertices[v] do
            begin
              x := FVerts[firstvert + FTris[m].VertexIndex2].X;
              y := FVerts[firstvert + FTris[m].VertexIndex2].Y;
              z := FVerts[firstvert + FTris[m].VertexIndex2].Z;
              U := FTris[m].U2;
              V := FTris[m].V2;
            end;
          inc(v);
          with exporter.Objects[o].Vertices[v] do
            begin
              x := FVerts[firstvert + FTris[m].VertexIndex3].X;
              y := FVerts[firstvert + FTris[m].VertexIndex3].Y;
              z := FVerts[firstvert + FTris[m].VertexIndex3].Z;
              U := FTris[m].U3;
              V := FTris[m].V3;
            end;
          if f = 0 then
            begin
              with exporter.Objects[o].Faces[m] do
                begin
                  VertexIndex1 := v - 2;
                  VertexIndex2 := v - 1;
                  VertexIndex3 := v;
                  MaterialIndex := FTris[m].TextureIndex;
                  Flags := FTris[m].Flags;
                end;
            end;
        end;
      if assigned(FOwner.FOnProcessMessages) then FOwner.OnProcessMessages(FOwner);
    end;
end;

procedure TUTObjectClassMesh.Save_3DS(filename: string; frames: TIntegerDynArray;
  mode:TUT_MeshExporter_Animation = exp_anim_MixedInFile;
  smoothing: TUT_3DStudioExporter_Smoothing = exp3ds_smooth_None;
  MirrorX: boolean = false);
var
  exporter: TUT_3DStudioExporter;
  frame:TIntegerDynArray;
  a:integer;
begin
  check_initialized;
  case mode of
  exp_anim_MixedInFile:
    begin
      exporter := TUT_3DStudioExporter.create;
      PrepareExporter(exporter, frames);
      exporter.mirrorX := mirrorX;
      exporter.smoothing := smoothing;
      exporter.Save(filename);
      exporter.free;
    end;
  exp_anim_MultiFile:
    begin
      for a:=0 to high(frames) do
        begin
          exporter := TUT_3DStudioExporter.create;
          setlength(frame, 1);
          frame[0] := frames[a];
          PrepareExporter(exporter, frame);
          exporter.mirrorX := mirrorX;
          exporter.smoothing := smoothing;
          exporter.Save(changefileext(filename,'_'+inttostr(frame[0])+extractfileext(filename)));
          exporter.free;
        end;
    end;
  end;
end;

procedure TUTObjectClassMesh.Save_Unreal3D(filename: string);
var
  exporter: TUT_Unreal3DExporter;
  frames: TIntegerDynArray;
  a: integer;
begin
  check_initialized;
  exporter := TUT_Unreal3DExporter.create;
  setlength(frames, FAnimFrames);
  for a := 0 to FAnimFrames - 1 do
    frames[a] := a;
  PrepareExporter(exporter, frames);
  exporter.Save(filename);
  exporter.free;
end;

procedure TUTObjectClassMesh.Save_UnrealUC(filename: string);
var
  k: char;
  uc, parent_class, basename: string;
  a, b, script_idx: integer;
  ed2: TUTExportTableObjectData;
  id: TUTImportTableObjectData;
  str_uc: tfilestream;
begin
  check_initialized;
  // Find a class with the same name as the mesh
  a := FOwner.FindObject(utolExports, [utfwName, utfwClass, utfwGroup], '', UTobjectname, '');
  if a <> -1 then
    begin
      ed2 := FOwner.Exported[a];
      ed2.UTObject.ReadObject;
      parent_class := FOwner.GetObjectPath(1, TUTObjectClassClass(ed2.UTObject).SuperField);
      script_idx := TUTObjectClassClass(ed2.UTObject).ScriptText - 1;
      ed2.UTObject.ReleaseObject;
    end
  else
    begin
      parent_class := 'TournamentPlayer'; // do not localize these strings
      // Find the correct script object
      script_idx := FOwner.FindObject(utolExports,
          [utfwGroup, utfwName, utfwClass],
          UTobjectname, 'ScriptText', 'TextBuffer');
    end;
  if script_idx <> -1 then
    begin                               // the script was found
      ed2 := FOwner.Exported[script_idx];
      ed2.UTObject.ReadObject;
      TUTObjectClassTextBuffer(ed2.UTObject).SaveToFile(filename);
      ed2.UTObject.ReleaseObject;
    end
  else
    begin                               // the script wasn't found, we must recreate it
      k := DecimalSeparator;
      decimalSeparator := '.';
      basename := UTobjectname;
      // do not localize
      uc :='//============================================================================='#13#10;
      uc := uc + format('// %s.'#13#10, [basename]);
      uc := uc +'//============================================================================='#13#10;
      uc := uc + format('class %s extends %s;'#13#10#13#10, [basename, parent_class]);
      uc := uc + format('#exec MESH IMPORT MESH=%s ANIVFILE=MODELS\%s_a.3d DATAFILE=MODELS\%s_d.3d'
        {+' X=0 Y=0 Z=0'}, [basename, basename, basename]);
      uc := uc + ' MLOD=0'#13#10;
      uc := uc + format('#exec MESH ORIGIN MESH=%s X=%f Y=%f Z=%f YAW=%f ROLL=%f PITCH=%f'#13#10#13#10,
        [basename, FOrigin.x, FOrigin.y, FOrigin.z,
        FRotorigin.Yaw / 256, FRotOrigin.Roll / 256, FRotOrigin.Pitch / 256]);
      for a := 0 to high(FAnimSeqs) do
        begin
          uc := uc + format('#exec MESH SEQUENCE MESH=%s SEQ=%-9s STARTFRAME=%d NUMFRAMES=%d',
            [basename, FOwner.Names[FAnimSeqs[a].name], FAnimSeqs[a].startframe, FAnimSeqs[a].numframes]);
          if FAnimSeqs[a].rate <> 30 then
            uc := uc + format(' RATE=%f', [FAnimSeqs[a].rate]);
          if FOwner.Names[FAnimSeqs[a].group] <> 'None' then
            uc := uc + format(' GROUP=%s', [FOwner.Names[FAnimSeqs[a].group]]);
          uc := uc + #13#10;
        end;
      uc := uc + #13#10;
      for a := 0 to high(FTextures) do
        if FTextures[a].value > 0 then
          begin
            ed2 := FOwner.Exported[FTextures[a].value - 1];
            uc := uc + format('#exec TEXTURE IMPORT NAME=%s FILE=%s.PCX GROUP=%s'#13#10,
              [ed2.UTobjectname, ed2.UTobjectname, ed2.UTGroupName]);
            // TODO : TUTObjectClassMesh.Save_UnrealUC : FLAGS=%d should put correct flags...
          end
        else if FTextures[a].value < 0 then
          begin
            id := FOwner.Imported[-FTextures[a].value - 1];
            uc := uc + format('#exec OBJ LOAD FILE=%s.utx PACKAGE=%s'#13#10,
              [id.UTobjectname, id.UTpackagename]);
          end;
      uc := uc + #13#10;
      for a := 0 to high(FTextures) do
        if FTextures[a].value > 0 then
          begin
            ed2 := FOwner.Exported[FTextures[a].value - 1];
            uc := uc + format('#exec MESHMAP SETTEXTURE MESHMAP=%s NUM=%d TEXTURE=%s'#13#10,
              [basename, a, ed2.UTobjectname]);
          end
        else if FTextures[a].value < 0 then
          begin
            id := FOwner.Imported[-FTextures[a].value - 1];
            uc := uc + format('#exec MESHMAP SETTEXTURE MESHMAP=%s NUM=%d TEXTURE=%s'#13#10,
              [basename, a, id.UTpackagename + '.' + id.UTobjectname]);
          end;
      uc := uc + #13#10;
      //uc:=uc+format('#exec MESHMAP NEW   MESHMAP=%s MESH=%s'#13#10,[basename,basename]);
      if (FScale.x <> 0.1) or (FScale.y <> 0.1) or (FScale.z <> 0.2) then
        uc := uc + format('#exec MESHMAP SCALE MESHMAP=%s X=%f Y=%f Z=%f'#13#10#13#10,
          [basename, FScale.x, FScale.y, FScale.z]);
      // FScale is incorrect, sometimes is 0 and it shouldnt be.
      for a := 0 to high(FAnimSeqs) do
        for b := 0 to high(FAnimSeqs[a].notifys) do
          uc := uc + format('#exec MESH NOTIFY MESH=%s SEQ=%-9s TIME=%f FUNCTION=%s'#13#10,
            [basename, FOwner.Names[FAnimSeqs[a].name], FAnimSeqs[a].notifys[b].time,
            FOwner.Names[FAnimSeqs[a].notifys[b]._function]]);
      uc := uc + #13#10;
      (*uc:=uc+#13#10+
      'defaultproperties'#13#10+
      '{'#13#10+
      '    DrawType=DT_Mesh'#13#10+
      format('    Mesh=%s'#13#10,[basename])+
      '}'#13#10;*)
      DecimalSeparator := k;
      str_uc := tfilestream.create(filename, fmCreate);
      try
        str_uc.write(uc[1], length(uc));
      finally
        str_uc.free;
      end;
    end;
end;

{ TUTObjectClassLodMesh }

function TUTObjectClassLodMesh.GetCollapsePointThus(i: integer): word;
begin
  check_initialized;
  result := FCollapsePointThus[i];
end;

function TUTObjectClassLodMesh.GetCollapsePointThusCount: integer;
begin
  check_initialized;
  result := length(FCollapsePointThus);
end;

function TUTObjectClassLodMesh.GetCollapseWedgeThus(i: integer): word;
begin
  check_initialized;
  result := FCollapseWedgeThus[i];
end;

function TUTObjectClassLodMesh.GetCollapseWedgeThusCount: integer;
begin
  check_initialized;
  result := length(FCollapseWedgeThus);
end;

function TUTObjectClassLodMesh.GetFace(i: integer): TUT_Struct_Face;
begin
  check_initialized;
  result := FFaces[i];
end;

function TUTObjectClassLodMesh.GetFaceCount: integer;
begin
  check_initialized;
  result := length(FFaces);
end;

function TUTObjectClassLodMesh.GetFaceLevel(i: integer): word;
begin
  check_initialized;
  result := FFaceLevel[i];
end;

function TUTObjectClassLodMesh.GetFaceLevelCount: integer;
begin
  check_initialized;
  result := length(FFaceLevel);
end;

function TUTObjectClassLodMesh.GetMaterial(i: integer): TUT_Struct_Material;
begin
  check_initialized;
  result := FMaterials[i];
end;

function TUTObjectClassLodMesh.GetMaterialCount: integer;
begin
  check_initialized;
  result := length(FMaterials);
end;

function TUTObjectClassLodMesh.GetRemapAnimVerts(i: integer): word;
begin
  check_initialized;
  result := FRemapAnimVerts[i];
end;

function TUTObjectClassLodMesh.GetRemapAnimVertsCount: integer;
begin
  check_initialized;
  result := length(FRemapAnimVerts);
end;

function TUTObjectClassLodMesh.GetSpecialFace(i: integer): TUT_Struct_Face;
begin
  check_initialized;
  result := FSpecialFaces[i];
end;

function TUTObjectClassLodMesh.GetSpecialFaceCount: integer;
begin
  check_initialized;
  result := length(FSpecialFaces);
end;

function TUTObjectClassLodMesh.GetWedge(i: integer): TUT_Struct_Wedge;
begin
  check_initialized;
  result := FWedges[i];
end;

function TUTObjectClassLodMesh.GetWedgeCount: integer;
begin
  check_initialized;
  result := length(FWedges);
end;

procedure TUTObjectClassLodMesh.InitializeObject;
begin
  inherited;
  setlength(FWedges, 0);
  setlength(FFaces, 0);
  setlength(FMaterials, 0);
  setlength(FCollapsePointThus, 0);
  setlength(FFaceLevel, 0);
  setlength(FCollapseWedgeThus, 0);
  setlength(FSpecialFaces, 0);
  setlength(FRemapAnimVerts, 0);
end;

procedure TUTObjectClassLodMesh.InterpretObject;
var
  size, a: integer;
begin
  inherited;
  // ULodMesh.CollapsePointThus
  size := FOwner.read_idx(buffer,utdmAsValue,'CollapsePointThus Array Size');
  setlength(FCollapsePointThus, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FCollapsePointThus[a] := FOwner.read_WORD(buffer,utdmAsValue,'CollapsePointThus');
  // ULodMesh.FaceLevel
  size := FOwner.read_idx(buffer,utdmAsValue,'FaceLevel Array Size');
  setlength(FFaceLevel, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FFaceLevel[a] := FOwner.read_WORD(buffer,utdmAsValue,'FaceLevel');
  // UlodMesh.Faces
  size := FOwner.read_idx(buffer,utdmAsValue,'Faces Array Size');
  setlength(FFaces, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FFaces[a] := Read_Struct_Face(FOwner, buffer,'Faces');
  // ULodMesh.CollapseWedgeThus
  size := FOwner.read_idx(buffer,utdmAsValue,'CollapseWedgeThus Array Size');
  setlength(FCollapseWedgeThus, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FCollapseWedgeThus[a] := FOwner.read_WORD(buffer,utdmAsValue,'CollapseWedgeThus');
  // ULodMesh.Wedges
  size := FOwner.read_idx(buffer,utdmAsValue,'Wedges Array Size');
  setlength(FWedges, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FWedges[a] := Read_Struct_Wedge(FOwner, buffer,'Wedges');
  // ULodMesh.Materials
  size := FOwner.read_idx(buffer,utdmAsValue,'Materials Array Size');
  setlength(FMaterials, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FMaterials[a] := Read_Struct_Material(FOwner, buffer,'Materials');
  // ULodMesh.SpecialFaces
  size := FOwner.read_idx(buffer,utdmAsValue,'SpecialFaces Array Size');
  setlength(FSpecialFaces, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FSpecialFaces[a] := Read_Struct_Face(FOwner, buffer,'SpecialFaces');
  // ULodMesh.ModelVerts
  FModelVerts := FOwner.read_dword(buffer,utdmAsValue,'ModelVerts');
  // ULodMesh.SpecialVerts
  FSpecialVerts := FOwner.read_dword(buffer,utdmAsValue,'SpecialVerts');
  // ULodMesh.MeshScaleMax
  FMeshScaleMax := FOwner.read_FLOAT(buffer,'MeshScaleMax');
  // ULodMesh.LODHysteresis
  FLODHysteresis := FOwner.read_FLOAT(buffer,'LODHysteresis');
  // ULodMesh.LODStrength
  FLODStrength := FOwner.read_FLOAT(buffer,'LODStrength');
  // ULodMesh.LODMinVerts
  FLODMinVerts := FOwner.read_dword(buffer,utdmAsValue,'LODMinVerts');
  // ULodMesh.LODMorph
  FLODMorph := FOwner.read_FLOAT(buffer,'LODMorph');
  // ULodMesh.LODZDisplace
  FLODZDisplace := FOwner.read_FLOAT(buffer,'LODZDisplace');
  // ULodMesh.RemapAnimVerts
  size := FOwner.read_idx(buffer,utdmAsValue,'RemapAnimVerts Array Size');
  setlength(FRemapAnimVerts, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FRemapAnimVerts[a] := FOwner.read_WORD(buffer,utdmAsValue,'RemapAnimVerts');
  // ULodMesh.OldFrameVerts
  FOldFrameVerts := FOwner.read_dword(buffer,utdmAsValue,'OldFrameVerts');
end;

procedure TUTObjectClassLodMesh.PrepareExporter(exporter: TUT_MeshExporter; frames: TIntegerDynArray);
const
  material_colors: array[0..5] of TColor = (clBlue, clRed, clLime, clYellow, clAqua, clSilver);
var
  matname: string;
  m, n, firstvert, f, v, o: integer;
  weapon_material_exists: integer;
begin
  check_initialized;
  if length(frames) = 0 then
    begin
      setlength(frames, 1);
      frames[0] := 0;
    end;
  weapon_material_exists := -1;
  o:=exporter.AddObject;
  setlength(exporter.Objects[o].Materials, length(FMaterials));
  for m := 0 to high(FMaterials) do
    begin
      matname := 'SKIN' + inttostr(FMaterials[m].textureindex);
      if (FMaterials[m].flags and (PF_TwoSided or PF_Modulated)) = (PF_TwoSided or PF_Modulated) then
        matname := matname + '.MODU'    //LATED'
      else if (FMaterials[m].flags and (PF_TwoSided or PF_Translucent)) = (PF_TwoSided or PF_Translucent) then
        matname := matname + '.TRAN'    //SLUCENT'
      else if (FMaterials[m].flags and (PF_TwoSided or PF_Masked)) = (PF_TwoSided or PF_Masked) then
        matname := matname + '.MASK'    //ED'
      else if (FMaterials[m].flags and PF_TwoSided) = PF_TwoSided then
        matname := matname + '.TWOS'    //IDED'
      else if (FMaterials[m].flags and PF_NotSolid) = PF_NotSolid then
        begin
          matname := 'WEAPON';
          weapon_material_exists := m;
        end;
      matname := copy(matname, 1, 10);
      exporter.Objects[o].Materials[m].name := matname;
      exporter.Objects[o].Materials[m].Texture:=FOwner.GetObjectPath(-1,FTextures[FMaterials[m].TextureIndex].Value);
      if m <= high(material_colors) then
        begin
          exporter.Objects[o].Materials[m].diffusecolor[0] := material_colors[m] and $FF;
          exporter.Objects[o].Materials[m].diffusecolor[1] := (material_colors[m] shr 8) and $FF;
          exporter.Objects[o].Materials[m].diffusecolor[2] := (material_colors[m] shr 16) and $FF;
        end
      else
        begin
          exporter.Objects[o].Materials[m].diffusecolor[0] := random(256);
          exporter.Objects[o].Materials[m].diffusecolor[1] := random(256);
          exporter.Objects[o].Materials[m].diffusecolor[2] := random(256);
        end;
    end;
  if (weapon_material_exists = -1) and (length(FSpecialFaces) > 0) then
    begin
      m := length(FMaterials);
      weapon_material_exists := m;
      setlength(exporter.Objects[o].Materials, m + 1);
      exporter.Objects[o].Materials[m].name := 'WEAPON';
      exporter.Objects[o].Materials[m].Texture:='';
      if m <= high(material_colors) then
        begin
          exporter.Objects[o].Materials[m].diffusecolor[0] := material_colors[m] and $FF;
          exporter.Objects[o].Materials[m].diffusecolor[1] := (material_colors[m] shr 8) and $FF;
          exporter.Objects[o].Materials[m].diffusecolor[2] := (material_colors[m] shr 16) and $FF;
        end
      else
        begin
          exporter.Objects[o].Materials[m].diffusecolor[0] := random(256);
          exporter.Objects[o].Materials[m].diffusecolor[1] := random(256);
          exporter.Objects[o].Materials[m].diffusecolor[2] := random(256);
        end;
    end;
  exporter.Objects[o].AnimationFrames := length(frames);
  setlength(exporter.Objects[o].Vertices, (FSpecialVerts + length(FWedges)) * length(frames));
  for f := 0 to high(frames) do
    begin
      firstvert := frames[f] * FFrameVerts;
      for m := 0 to FSpecialVerts - 1 do
        begin
          v := f * (FSpecialVerts + length(FWedges)) + m;
          with exporter.Objects[o].Vertices[v] do
            begin
              n:=firstvert+m;
              if length(FRemapAnimVerts)<>0 then n:=FRemapAnimVerts[n];
              x := FVerts[n].X;
              y := FVerts[n].Y;
              z := FVerts[n].Z;
              U := 0;
              V := 0;
            end;
        end;
      for m := 0 to high(FWedges) do
        begin
          v := f * (FSpecialVerts + length(FWedges)) + FSpecialVerts + m;
          with exporter.Objects[o].Vertices[v] do
            begin
              n:=firstvert + FSpecialVerts + FWedges[m].VertexIndex;
              if length(FRemapAnimVerts)<>0 then n:=FRemapAnimVerts[n];
              x := FVerts[n].X;
              y := FVerts[n].Y;
              z := FVerts[n].Z;
              U := FWedges[m].U;
              V := FWedges[m].V;
            end;
        end;
      if assigned(FOwner.FOnProcessMessages) then FOwner.OnProcessMessages(FOwner);
    end;
  setlength(exporter.Objects[o].Faces, length(FFaces) + length(FSpecialFaces));
  for m := 0 to high(FFaces) do
    begin
      with exporter.Objects[o].Faces[m] do
        begin
          VertexIndex1 := FSpecialVerts + FFaces[m].WedgeIndex1;
          VertexIndex2 := FSpecialVerts + FFaces[m].WedgeIndex2;
          VertexIndex3 := FSpecialVerts + FFaces[m].WedgeIndex3;
          MaterialIndex := FFaces[m].MatIndex;
          Flags := FMaterials[FFaces[m].MatIndex].Flags;
        end;
    end;
  for m := 0 to high(FSpecialFaces) do
    begin
      with exporter.Objects[o].Faces[length(FFaces) + m] do
        begin
          VertexIndex1 := FSpecialFaces[m].WedgeIndex1;
          VertexIndex2 := FSpecialFaces[m].WedgeIndex2;
          VertexIndex3 := FSpecialFaces[m].WedgeIndex3;
          MaterialIndex := weapon_material_exists;
          Flags := PF_NotSolid;
        end;
    end;
end;

procedure TUTObjectClassLodMesh.Save_UnrealUC(filename: string);
var
  k: char;
  uc, parent_class, basename: string;
  a, b, script_idx: integer;
  ed2: TUTExportTableObjectData;
  id: TUTImportTableObjectData;
  str_uc: tfilestream;
begin
  check_initialized;
  a := FOwner.FindObject(utolExports, [utfwName, utfwClass, utfwGroup], '', UTobjectname, '');
  if a <> -1 then
    begin
      ed2 := FOwner.Exported[a];
      ed2.UTObject.ReadObject;
      parent_class := FOwner.GetObjectPath(1, TUTObjectClassClass(ed2.UTObject).SuperField);
      script_idx := TUTObjectClassClass(ed2.UTObject).ScriptText - 1;
      ed2.UTObject.ReleaseObject;
    end
  else
    begin
      parent_class := 'TournamentPlayer'; // do not localize these strings
      script_idx := FOwner.FindObject(utolExports, [utfwName, utfwClass, utfwGroup],
          UTobjectname, 'ScriptText', 'TextBuffer');
    end;
  if script_idx <> -1 then
    begin
      ed2 := FOwner.Exported[script_idx];
      ed2.UTObject.ReadObject;
      TUTObjectClassTextBuffer(ed2.UTObject).SaveToFile(filename);
      ed2.UTObject.ReleaseObject;
    end
  else
    begin
      k := DecimalSeparator;
      decimalSeparator := '.';
      basename := UTobjectname;
      // do not localize
      uc := '//============================================================================='#13#10;
      uc := uc + format('// %s.'#13#10, [basename]);
      uc := uc + '//============================================================================='#13#10;
      uc := uc + format('class %s extends %s;'#13#10#13#10, [basename, parent_class]);
      uc := uc + format('#exec MESH IMPORT MESH=%s ANIVFILE=MODELS\%s_a.3d DATAFILE=MODELS\%s_d.3d'
        {+' X=0 Y=0 Z=0'}, [basename, basename, basename]);
      uc := uc + #13#10;
      uc := uc + format('#exec MESH LODPARAMS MESH=%s HYSTERESIS=%f STRENGTH=%f MINVERTS=%f MORPH=%f ZDISP=%f'#13#10,
        [basename, FLODHysteresis, FLODStrength, FLODMinVerts, FLODMorph, FLODZDisplace]);
      uc := uc + format('#exec MESH ORIGIN MESH=%s X=%f Y=%f Z=%f YAW=%f ROLL=%f PITCH=%f'#13#10#13#10,
        [basename, FOrigin.x, FOrigin.y, FOrigin.z,
        FRotorigin.Yaw / 256, FRotOrigin.Roll / 256, FRotOrigin.Pitch / 256]);
      for a := 0 to high(FAnimSeqs) do
        begin
          uc := uc + format('#exec MESH SEQUENCE MESH=%s SEQ=%-9s STARTFRAME=%d NUMFRAMES=%d',
            [basename, FOwner.Names[FAnimSeqs[a].name], FAnimSeqs[a].startframe, FAnimSeqs[a].numframes]);
          if FAnimSeqs[a].rate <> 30 then
            uc := uc + format(' RATE=%f', [FAnimSeqs[a].rate]);
          if FOwner.Names[FAnimSeqs[a].group] <> 'None' then
            uc := uc + format(' GROUP=%s', [FOwner.Names[FAnimSeqs[a].group]]);
          uc := uc + #13#10;
        end;
      uc := uc + #13#10;
      for a := 0 to high(FTextures) do
        if FTextures[a].value > 0 then
          begin
            ed2 := FOwner.Exported[FTextures[a].value - 1];
            uc := uc + format('#exec TEXTURE IMPORT NAME=%s FILE=%s.PCX GROUP=%s'#13#10,
              [ed2.UTobjectname, ed2.UTobjectname, ed2.UTgroupname]);
            // TODO : TUTObjectClassLodMesh.Save_UnrealUC : FLAGS=%d should put correct flags...
          end
        else if FTextures[a].value < 0 then
          begin
            id := FOwner.Imported[-FTextures[a].value - 1];
            uc := uc + format('#exec OBJ LOAD FILE=%s.utx PACKAGE=%s'#13#10,
              [id.UTobjectname, id.UTpackagename]);
          end;
      uc := uc + #13#10;
      for a := 0 to high(FTextures) do
        if FTextures[a].value > 0 then
          begin
            ed2 := FOwner.Exported[FTextures[a].value - 1];
            uc := uc + format('#exec MESHMAP SETTEXTURE MESHMAP=%s NUM=%d TEXTURE=%s'#13#10,
              [basename, a, ed2.UTobjectname]);
          end
        else if FTextures[a].value < 0 then
          begin
            id := FOwner.Imported[-FTextures[a].value - 1];
            uc := uc + format('#exec MESHMAP SETTEXTURE MESHMAP=%s NUM=%d TEXTURE=%s'#13#10,
              [basename, a, id.UTpackagename + '.' + id.UTobjectname]);
          end;
      uc := uc + #13#10;
      //uc:=uc+format('#exec MESHMAP NEW   MESHMAP=%s MESH=%s'#13#10,[basename,basename]);
      if (FScale.x <> 0.1) or (FScale.y <> 0.1) or (FScale.z <> 0.2) then
        uc := uc + format('#exec MESHMAP SCALE MESHMAP=%s X=%f Y=%f Z=%f'#13#10#13#10,
          [basename, FScale.x, FScale.y, FScale.z]);
      // FScale is incorrect, sometimes is 0 and it shouldnt be.
      for a := 0 to high(FAnimSeqs) do
        for b := 0 to high(FAnimSeqs[a].notifys) do
          uc := uc + format('#exec MESH NOTIFY MESH=%s SEQ=%-9s TIME=%f FUNCTION=%s'#13#10,
            [basename, FOwner.Names[FAnimSeqs[a].name], FAnimSeqs[a].notifys[b].time,
              FOwner.Names[FAnimSeqs[a].notifys[b]._function]]);
      uc := uc + #13#10;
      (*uc:=uc+#13#10+
      'defaultproperties'#13#10+
      '{'#13#10+
      '    DrawType=DT_Mesh'#13#10+
      format('    Mesh=%s'#13#10,[basename])+
      '}'#13#10;*)
      DecimalSeparator := k;
      str_uc := tfilestream.create(filename, fmCreate);
      try
        str_uc.write(uc[1], length(uc));
      finally
        str_uc.free;
      end;
    end;
end;

{ TUTObjectClassFireTexture }

function TUTObjectClassFireTexture.GetSpark(i: integer): TUT_Struct_Spark;
begin
  check_initialized;
  result := FSparks[i];
end;

function TUTObjectClassFireTexture.GetSparkCount: integer;
begin
  check_initialized;
  result := length(FSparks);
end;

procedure TUTObjectClassFireTexture.InitializeObject;
begin
  inherited;
  setlength(FSparks, 0);
end;

procedure TUTObjectClassFireTexture.InterpretObject;
var
  s: integer;
begin
  inherited;
  setlength(FSparks, CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue,'Sparks Array Size')));
  for s := 0 to high(FSparks) do
    FSparks[s] := Read_Struct_Spark(FOwner, buffer,'Sparks');
end;

{ TUTObjectClassField }

function TUTObjectClassField.GetNext: integer;
begin
  check_initialized;
  result := FNext;
end;

function TUTObjectClassField.GetSuperField: integer;
begin
  check_initialized;
  result := FSuperField;
end;

procedure TUTObjectClassField.InitializeObject;
begin
  inherited;
  FSuperField := 0;
  FNext := 0;
end;

procedure TUTObjectClassField.InterpretObject;
var a,int:integer;
begin
  inherited;
  if FOwner.GameHint=UTPGH_DeusExInvisibleWar then
    begin
      // unknown index array
      int:=FOwner.read_dword(buffer,utdmAsValue,'unknown index array count');
      for a:=1 to int do
        FOwner.read_idx(buffer);
    end;
  FSuperField := FOwner.read_idx(buffer,utdmRefToObject,'SuperField');
  FNext := FOwner.read_idx(buffer,utdmRefToObject,'Next');
end;

{ TUTObjectEnum }

function TUTObjectClassEnum.GetCount: integer;
begin
  check_initialized;
  result := length(FValues);
end;

function TUTObjectClassEnum.GetDeclaration: string;
var
  a: integer;
begin
  check_initialized;
  result := '';
  for a := 0 to count - 1 do
    begin
      result := result + EnumName[a];
      if a < count - 1 then result := result + ',';
      result := result + #13#10;
    end;
  result := FOwner.IndentText(#9, result);
  result := 'enum ' + UTobjectname + ' {'#13#10 + result + '}';
end;

function TUTObjectClassEnum.GetValue(i: integer): integer;
begin
  check_initialized;
  if (i >= 0) and (i < length(FValues)) then
    result := FValues[i]
  else
    result := 0;
end;

function TUTObjectClassEnum.GetValueName(i: integer): string;
begin
  check_initialized;
  if (i >= 0) and (i < length(FValues)) then
    result := FOwner.Names[FValues[i]]
  else
    result := '';
end;

procedure TUTObjectClassEnum.InitializeObject;
begin
  inherited;
  setlength(FValues, 0);
end;

procedure TUTObjectClassEnum.InterpretObject;
var
  a: integer;
begin
  inherited;
  setlength(FValues, CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue,'Values Array Size')));
  for a := 0 to high(FValues) do
    FValues[a] := FOwner.read_idx(buffer,utdmRefToName,'Values');
end;

{ TUTObjectClassConst }

function TUTObjectClassConst.GetDeclaration: string;
begin
  check_initialized;
  result := 'const ' + UTobjectname + '=' + Value;
end;

function TUTObjectClassConst.GetValue: string;
begin
  check_initialized;
  result := FValue;
end;

procedure TUTObjectClassConst.InitializeObject;
begin
  inherited;
  FValue := '';
end;

procedure TUTObjectClassConst.InterpretObject;
begin
  inherited;
  FValue := FOwner.read_sizedasciiz(buffer,'Value');
end;

{ TUTObjectClassProperty }

function TUTObjectClassProperty.GetArrayDimension: integer;
begin
  check_initialized;
  result := FArrayDimension;
end;

function TUTObjectClassProperty.GetCategory: string;
begin
  check_initialized;
  result := FCategory;
end;

function TUTObjectClassProperty.GetDeclaration(context, cn: string): string;
var
  flags: string;
begin
  check_initialized;
  flags := GetFlags(cn);
  if (context <> '') and (copy(flags, 1, 1) <> '(') then
    context := context + ' ';
  result := format('%s%s%s %s', [context, flags, GenericTypeName, UTObjectName]);
  if FArrayDimension > 1 then
    result := result + format('[%d]', [FArrayDimension]);
end;

function TUTObjectClassProperty.GetElementSize: integer;
begin
  check_initialized;
  result := FElementSize;
end;

function TUTObjectClassProperty.GetFlags(cn: string): string;
var
  flags, varcategory: string;
begin
  check_initialized;
  flags := '';
  if (PropertyFlags and CPF_Edit) <> 0 then
    begin
      if category = cn then
        varcategory := ''
      else
        varcategory := category;
      varcategory := '(' + varcategory + ')';
      varcategory := varcategory + ' ';
    end
  else
    varcategory := '';
  if (PropertyFlags and CPF_Const) <> 0 then
    flags := flags + 'const ';
  if (PropertyFlags and CPF_Input) <> 0 then
    flags := flags + 'input ';
  if (PropertyFlags and CPF_ExportObject) <> 0 then
    flags := flags + 'export ';
  if (PropertyFlags and CPF_OptionalParm) <> 0 then
    flags := flags + 'optional ';
  //if (PropertyFlags and CPF_Net) <> 0 then flags := flags + 'net ';
  if (PropertyFlags and CPF_ConstRef) <> 0 then
    flags := flags + 'constref ';
  if ((PropertyFlags and CPF_OutParm) <> 0) and
    ((PropertyFlags and CPF_ReturnParm) = 0) then
    flags := flags + 'out ';
  if (PropertyFlags and CPF_SkipParm) <> 0 then
    flags := flags + 'skip ';
  if (PropertyFlags and CPF_CoerceParm) <> 0 then
    flags := flags + 'coerce ';
  if (PropertyFlags and CPF_Native) <> 0 then
    flags := flags + 'native ';
  if (PropertyFlags and CPF_Transient) <> 0 then
    flags := flags + 'transient ';
  if ((PropertyFlags and CPF_Config) <> 0) and
    ((PropertyFlags and CPF_GlobalConfig) = 0) then
    flags := flags + 'config ';
  if (PropertyFlags and CPF_Localized) <> 0 then
    flags := flags + 'localized ';
  if (PropertyFlags and CPF_Travel) <> 0 then
    flags := flags + 'travel ';
  if (PropertyFlags and CPF_EditConst) <> 0 then
    flags := flags + 'editconst ';
  if (PropertyFlags and CPF_GlobalConfig) <> 0 then
    flags := flags + 'globalconfig ';
  if (PropertyFlags and CPF_OnDemand) <> 0 then
    flags := flags + 'ondemand ';
  if (PropertyFlags and CPF_New) <> 0 then
    flags := flags + 'new ';
  if (PropertyFlags and CPF_EditInlineUse) <> 0 then
    flags := flags + 'editinlineuse '
  else if (PropertyFlags and CPF_EditInline) <> 0 then
    flags := flags + 'editinline '
  else if (PropertyFlags and CPF_Deprecated) <> 0 then
    flags := flags + 'deprecated '
  ;
  //if (variable.PropertyFlags and CPF_NeedCtorLink) <> 0 then flags := flags + 'needctorlink ';
  if ((UTflags and RF_Public) = 0) or ((UTFlags and RF_Private)<>0) then
    flags := flags + 'private ';
  result := varcategory + flags;
end;

function TUTObjectClassProperty.GetPropertyFlags: DWORD;
begin
  check_initialized;
  result := FPropertyFlags;
end;

function TUTObjectClassProperty.GetRepOffset: word;
begin
  check_initialized;
  result := FRepOffset;
end;

procedure TUTObjectClassProperty.InitializeObject;
begin
  inherited;
  FArrayDimension := 0;
  FElementSize := 0;
  FPropertyFlags := 0;
  FCategory := '';
  FRepOffset := $FFFF;
  FComment:='';
end;

procedure TUTObjectClassProperty.InterpretObject;
begin
  inherited;
  FArrayDimension := FOwner.read_word(buffer,utdmAsValue,'ArrayDimension');
  if FOwner.FGameHint<>UTPGH_SplinterCell then
    FElementSize := FOwner.read_word(buffer,utdmAsValue,'ElementSize');
  FPropertyFlags := FOwner.read_dword(buffer,utdmFlags,'PropertyFlags');
  if (FArrayDimension = $660D) {and  // special value?
     (FOwner.GameHint=UTPGH_ArmyOperations)} then
    begin
      FArrayDimension:=0;
      Fowner.read_dword (buffer); // TODO : unknown DWORD in Army Operations files
    end;
  FCategory := FOwner.Names[FOwner.read_idx(buffer,utdmRefToName,'Category')];
  if (FPropertyFlags and CPF_Net) <> 0 then
    FRepOffset := FOwner.read_word(buffer,utdmAsValue,'RepOffset');
  if ((FPropertyFlags and CPF_EditorData) <> 0) or
     (FOwner.FGameHint=UTPGH_Devastation) then
    FComment := FOwner.read_sizedasciiz(buffer,'Comment');
end;

function TUTObjectClassProperty.GenericTypeName: string;
begin
  check_initialized;
  result := 'property';
end;

function TUTObjectClassProperty.GetComment: string;
begin
  check_initialized;
  result := FComment;
end;

{ TUTObjectClassByteProperty }

function TUTObjectClassByteProperty.GetEnum: integer;
begin
  check_initialized;
  result := FEnum;
end;

procedure TUTObjectClassByteProperty.InitializeObject;
begin
  inherited;
  FEnum := 0;
end;

procedure TUTObjectClassByteProperty.InterpretObject;
begin
  inherited;
  FEnum := FOwner.read_idx(buffer,utdmRefToObject,'Enum');
end;

function TUTObjectClassByteProperty.GenericTypeName: string;
begin
  check_initialized;
  if FEnum = 0 then
    result := 'byte'
  else
    result := FOwner.GetObjectPath(1, FEnum);
end;

{ TUTObjectClassObjectProperty }

function TUTObjectClassObjectProperty.GetObject: integer;
begin
  check_initialized;
  result := FObject;
end;

procedure TUTObjectClassObjectProperty.InitializeObject;
begin
  inherited;
  FObject := 0;
end;

procedure TUTObjectClassObjectProperty.InterpretObject;
begin
  inherited;
  FObject := FOwner.read_idx(buffer,utdmRefToObject,'Object');
end;

function TUTObjectClassObjectProperty.GenericTypeName: string;
begin
  check_initialized;
  result := FOwner.GetObjectPath(1, FObject);
end;

{ TUTObjectClassFixedArrayProperty }

function TUTObjectClassFixedArrayProperty.GetCount: integer;
begin
  check_initialized;
  result := FCount;
end;

function TUTObjectClassFixedArrayProperty.GetInner: integer;
begin
  check_initialized;
  result := FInner;
end;

procedure TUTObjectClassFixedArrayProperty.InitializeObject;
begin
  inherited;
  FInner := 0;
  FCount := 0;
end;

procedure TUTObjectClassFixedArrayProperty.InterpretObject;
begin
  inherited;
  FInner := FOwner.read_idx(buffer,utdmRefToObject,'Inner');
  FCount := FOwner.read_idx(buffer,utdmAsValue,'Count');
end;

function TUTObjectClassFixedArrayProperty.GenericTypeName: string;
begin
  check_initialized;
  result := FOwner.GetObjectPath(1, FInner) + '[' + inttostr(FCount) + ']';
  // TODO : the variable name should go in-between?
end;

{ TUTObjectClassArrayProperty }

function TUTObjectClassArrayProperty.GetInner: integer;
begin
  check_initialized;
  result := FInner;
end;

procedure TUTObjectClassArrayProperty.InitializeObject;
begin
  inherited;
  FInner := 0;
end;

procedure TUTObjectClassArrayProperty.InterpretObject;
begin
  inherited;
  FInner := FOwner.read_idx(buffer,utdmRefToObject,'Inner');
end;

function TUTObjectClassArrayProperty.GenericTypeName: string;
var
  inner: string;
begin
  check_initialized;
  if (FInner<0) or (FInner>=FOwner.ExportedCount) then raise exception.create ('Invalid Array Inner Property');
  FOwner.Exported[FInner - 1].UTObject.ReadObject;
  inner := TUTObjectClassProperty(FOwner.Exported[FInner - 1].UTObject).GenericTypeName;
  FOwner.Exported[FInner - 1].UTObject.ReleaseObject;
  result := 'array<' + inner + '>';
end;

{ TUTObjectClassMapProperty }

function TUTObjectClassMapProperty.GetKey: integer;
begin
  check_initialized;
  result := FKey;
end;

function TUTObjectClassMapProperty.GetValue: integer;
begin
  check_initialized;
  result := FValue;
end;

procedure TUTObjectClassMapProperty.InitializeObject;
begin
  inherited;
  FKey := 0;
  FValue := 0;
end;

procedure TUTObjectClassMapProperty.InterpretObject;
begin
  inherited;
  FKey := FOwner.read_idx(buffer,utdmRefToName,'Key');
  FValue := FOwner.read_idx(buffer,utdmRefToName,'Value');
end;

function TUTObjectClassMapProperty.GenericTypeName: string;
begin
  check_initialized;
  result := 'map';                      // TODO : fix map typename
end;

{ TUTObjectClassClassProperty }

function TUTObjectClassClassProperty.GetClass: integer;
begin
  check_initialized;
  result := FClass;
end;

procedure TUTObjectClassClassProperty.InitializeObject;
begin
  inherited;
  FClass := 0;
end;

procedure TUTObjectClassClassProperty.InterpretObject;
begin
  inherited;
  FClass := FOwner.read_idx(buffer,utdmRefToObject,'Class');
end;

function TUTObjectClassClassProperty.GenericTypeName: string;
begin
  check_initialized;
  result := FOwner.GetObjectPath(1, FClass);
  if lowercase(result) = 'object' then
    result := ''
  else
    result := '<' + result + '>';
  result := inherited GenericTypeName + result;
end;

{ TUTObjectClassStructProperty }

function TUTObjectClassStructProperty.GetStruct: integer;
begin
  check_initialized;
  result := FStruct;
end;

procedure TUTObjectClassStructProperty.InitializeObject;
begin
  inherited;
  FStruct := 0;
end;

procedure TUTObjectClassStructProperty.InterpretObject;
begin
  inherited;
  FStruct := FOwner.read_idx(buffer,utdmRefToObject,'Struct');
end;

function TUTObjectClassStructProperty.GenericTypeName: string;
begin
  check_initialized;
  result := FOwner.GetObjectPath(1, FStruct);
end;

{ TUTObjectClassDelegateProperty }

function TUTObjectClassDelegateProperty.GetEvent: integer;
begin
  check_initialized;
  result:=FEvent;
end;

procedure TUTObjectClassDelegateProperty.InitializeObject;
begin
  inherited;
  FEvent:=0;
end;

procedure TUTObjectClassDelegateProperty.InterpretObject;
begin
  inherited;
  FEvent:=FOwner.read_idx (buffer,utdmRefToObject,'Event');
end;

function TUTObjectClassDelegateProperty.GenericTypeName: string;
begin
  check_initialized;
  result:='delegate'; // TODO : is this correct?
end;

{ TUTObjectClassStruct }

function TUTObjectClassStruct.GetDeclaration: string;
var
  c: integer;
  child: TUTObjectClassField;
  r: string;
begin
  check_initialized;
  r := '';
  c := FChildren;
  while c <> 0 do
    begin
      child := TUTObjectClassField(FOwner.Exported[c - 1].UTObject);
      child.ReadObject;
      try
        if child is TUTObjectClassProperty then
          r := r + TUTObjectClassProperty(child).GetDeclaration('var', UTObjectName) + ';'#13#10;
        if child is TUTObjectClassEnum then
          r := r + TUTObjectClassEnum(child).GetDeclaration + ';'#13#10;
        c := child.next;
      finally
        child.ReleaseObject;
      end;
    end;
  r := FOwner.IndentText(#9, r);
  result := 'struct ' + UTObjectName;
  if FSuperField = 0 then
    result := result + #13#10'{'#13#10
  else
    result := result + ' extends ' + FOwner.GetObjectPath(1, FSuperField) + #13#10'{'#13#10;
  result := result + r + '}';
end;

procedure TUTObjectClassStruct.InitializeObject;
begin
  inherited;
  FScriptText := 0;
  FChildren := 0;
  FFriendlyName := '';
  FLine := 0;
  FTextPos := 0;
  FScriptSize := 0;
  FScriptStart := 0;
  JumpList := nil;
  indent_level := 0;
  position_icode := 0;
  last_position_icode := 0;
  setlength(FLabelTable, 0);
end;

procedure TUTObjectClassStruct.InterpretObject;
begin
  inherited;
  FScriptText := FOwner.read_idx(buffer,utdmRefToObject,'ScriptText');
  FChildren := FOwner.read_idx(buffer,utdmRefToObject,'Children');
  FFriendlyName := FOwner.Names[FOwner.read_idx(buffer,utdmRefToName,'FriendlyName')];
  if FOwner.GameHint=UTPGH_Lineage2 then FOwner.read_idx(buffer); // TODO : unknown byte or index
  if ((FOwner.Version>=120) or (FOwner.GameHint=UTPGH_Unreal2)) and (FOwner.GameHint<>UTPGH_Lineage2) then
    begin
      if (FOwner.GameHint<>UTPGH_Devastation) and (FOwner.GameHint<>UTPGH_DesertThunder) then
        FOwner.read_dword (buffer) // TODO : unknown DWORD
      else
        FOwner.read_byte (buffer); // TODO : unknown BYTE
    end;
  FLine := FOwner.read_dword(buffer,utdmAsValue,'Line');
  FTextPos := FOwner.read_dword(buffer,utdmAsValue,'TextPos');
  FScriptSize := FOwner.read_dword(buffer,utdmAsValue,'ScriptSize');
  //if (FOwner.Version>=83{?}) and (FOwner.Version<117) then FScriptSize:=FOwner.read_dword(buffer,utdmAsValue); {U2alpha} // does not work with some other files in the version range
  FScriptStart := buffer.position;
  JumpList := tlist.create;
  position_icode := 0;
  last_position_icode := 0;
  indent_level := 0;
  setlength(FLabelTable, 0);
  //SkipStatements;
end;

procedure TUTObjectClassStruct.DoReleaseObject;
begin
  freeandnil(JumpList);
  inherited;
end;

function TUTObjectClassStruct.ReadToken(OuterOperatorPrecedence: byte): string;
var
  b,b2: byte;
  i1, i2, i3: integer;
  d1{, d2}: DWORD;
  f1, f2, f3: single;
  r1, r2, r3, r4, msg: string;
  o1: TUTObject;
  letmp: TUT_Struct_LabelEntry;
  ds: char;
  wc: widestring;
  prev_pos:int64;
  procedure read_parameters(var r: string);
  var
    r1: string;
  begin
    repeat
      r1 := ReadToken;
      if r1 = ')' then
        begin
          if copy(r, length(r), 1) = ',' then
            delete(r, length(r), 1);    // remove last comma
          r := r + r1;
        end
      else
        r := r + r1 + ',';
    until r1 = ')';
  end;
begin
  result := '';                         // gives a false warning
  check_initialized;
  if position_icode>=FScriptSize then raise exception.create (rsInvalidStatement);
  inc(indent_level);
  b := FOwner.read_byte(buffer,utdmAsValue,'Token');
  inc(position_icode);
  case b of
    EX_JumpIfNot:
      begin
        d1 := FOwner.read_word(buffer);
        inc(position_icode, 2);
        r1 := ReadToken(OuterOperatorPrecedence);
        //(0); // the zero precedence will make it include parenthesis if it is an expression
        if (nest <> nil) and (d1 > position_icode) then
          // we jump forward (the exclusion of an equal address is intentional)
          begin
            endnestlist.addobject('IF', pointer((position_icode shl 16) or d1));
            result := format('if ( %s )', [r1]);
            nest.add(pointer(NEST_If));
            need_semicolon := false;
          end
        else
          begin
            i2 := jumplist.indexof(pointer(d1));
            if i2 = -1 then i2 := jumplist.add(pointer(d1));
            //if copy(r1, 1, 1) <> '(' then r1 := '(' + r1 + ')';
            result := format('if (! %s ) goto JL%-4.4x', [r1, integer(jumplist[i2])]);
            need_semicolon := true;
          end;
      end;
    EX_LocalVariable, EX_InstanceVariable, EX_NativeParm: // EX_NativeParm will always be in the body of a native function
      begin
        i1 := FOwner.read_idx(buffer,utdmRefToObject);
        inc(position_icode, 4);
        if not next_is_not_delegate then
          begin
            if (i1>0) and (lowercase(FOwner.Exported[i1-1].UTClassName)='delegateproperty') then
              begin
                o1:=FOwner.Exported[i1-1].UTObject;
                o1.ReadObject;
                i1:=TUTObjectClassDelegateProperty(o1).Event;
                o1.ReleaseObject;
              end;
          end;
        result := FOwner.GetObjectPath(1, i1);
      end;
    EX_DefaultVariable:
      begin
        i1 := FOwner.read_idx(buffer,utdmRefToObject);
        inc(position_icode, 4);
        result := 'Default.' + FOwner.GetObjectPath(1, i1);
      end;
    EX_UnknownVariable:
      begin
        i1 := FOwner.read_idx(buffer,utdmRefToObject);
        inc(position_icode, 4);
        result := ReadToken(OuterOperatorPrecedence)+ '.' + FOwner.GetObjectPath(1, i1);
      end;
    EX_Return:
      begin
        if FOwner.Version > 61 then
          // version 61 packages seem to not have a return value (KHGdemo)
          result := ReadToken(OuterOperatorPrecedence);
        if result <> '' then
          result := ' ' + result;
        result := 'return' + result;
        need_semicolon := true;
      end;
    EX_Nothing:
      begin
        result := '';
      end;
    EX_Let, EX_LetBool:
      begin
        if (b = EX_LetBool {0x14}) and (FOwner.Version = 61) and (position_icode = 1) then
          begin
            // Jump over unknown data (maybe an obsolete label table?)
            repeat
              i1 := FOwner.read_byte(buffer);
              inc(position_icode);
              if i1 > 0 then
                begin
                  FOwner.read_byte(buffer);
                  inc(position_icode);
                end;
            until i1 = 0;
          end
        else
          begin
            r1 := ReadToken(OuterOperatorPrecedence);
            r2 := ReadToken(OuterOperatorPrecedence);
            result := r1 + ' = ' + r2;
            need_semicolon := true;
          end;
      end;
    EX_ClassContext, EX_Context:
      begin
        result := ReadToken(OuterOperatorPrecedence) + '.';
        // following fields only used when class context is null -> not needed for source code
        FOwner.read_word(buffer);
        inc(position_icode, 2);         // wSkip
        FOwner.read_byte(buffer);
        inc(position_icode);            // bSize
        context_change := true;
        result := result + ReadToken(OuterOperatorPrecedence);
        context_change := false;
      end;
    EX_Unknown_jumpover:
      begin
        // This opcode has an unknown meaning, so we jump over it.
        if FOwner.Version=$61 then
          begin
            // It has been seen in old packages (version 61, from the Klingon Honor Guard Demo)
            // at the end of functions and in the middle of some statements (if)
            // We treat it depending on the position.
            if indent_level = 1 then
              result := ''                  // do nothing
            else
              result := ReadToken(OuterOperatorPrecedence); // skip it
          end
        else
          begin
            // also seen on newer packages, as some type of invisible modifier
            FOwner.read_word(buffer); // TODO : unknown word in unrealscript
            result:='';
          end;
      end;
    EX_Unknown_jumpover2:
      begin
        // This opcode has an unknown meaning, so we jump over it.
        // It has been seen in old packages (version 61, from the Klingon Honor Guard Demo)
        // It seems to be some type of context change or type cast
        FOwner.read_byte(buffer);       // TODO : unknown byte in unrealscript
        inc(position_icode);
        result := ReadToken(OuterOperatorPrecedence);
      end;
    EX_EndFunctionParms:
      begin
        result := ')';
      end;
    EX_Self:
      begin
        result := 'self';
      end;
    EX_IntConst:
      begin
        result := format('%d', [FOwner.read_int(buffer,utdmAsValue)]);
        inc(position_icode, 4);
      end;
    EX_ByteConst, EX_IntConstByte:
      begin
        result := format('%d', [FOwner.read_byte(buffer)]);
        inc(position_icode);
      end;
    EX_FloatConst:
      begin
        ds := DecimalSeparator;
        DecimalSeparator := '.';
        result := format('%.8f', [FOwner.read_float(buffer)]);
        DecimalSeparator := ds;
        if result='3.14159274' then
          result:='Pi'
        else
          begin
            // remove trailing zeroes
            i1:=pos('.',result);
            i2:=length(result);
            while (i2>i1+1) do
              if result[i2]='0' then delete(result,i2,1) else dec(i2);
          end;
        inc(position_icode, 4);
      end;
    EX_ObjectConst:
      begin
        i1 := FOwner.read_idx(buffer,utdmRefToObject);
        if i1 > 0 then
          result := FOwner.exported[i1 - 1].UTclassname
        else
          result := FOwner.imported[-i1 - 1].UTclassname;
        if result = '' then
          result := 'Class';
        result := format('%s''%s''', [result, FOwner.GetObjectPath(1, i1)]);
        inc(position_icode, 4);
      end;
    EX_NameConst:
      begin
        result := format('''%s''', [FOwner.Names[FOwner.read_idx(buffer,utdmRefToName)]]);
        inc(position_icode, 4);
      end;
    EX_StringConst:
      begin
        r1 := FOwner.read_asciiz(buffer);
        result := FOwner.GetStringConst(r1);
        inc(position_icode, length(r1) + 1);
      end;
    EX_UnicodeStringConst:
      begin
        wc := '';
        repeat
          i1 := FOwner.read_word(buffer);
          inc(position_icode, 2);
          if i1 > 0 then
            wc := wc + widechar(i1);
        until i1 = 0;
        result := FOwner.GetUnicodeStringConst(wc);
      end;
    EX_EatString:
      begin
        result := ReadToken(OuterOperatorPrecedence);
      end;
    EX_RotationConst:
      begin
        i1 := FOwner.read_int(buffer,utdmAsValue);
        inc(position_icode, 4);
        i2 := FOwner.read_int(buffer,utdmAsValue);
        inc(position_icode, 4);
        i3 := FOwner.read_int(buffer,utdmAsValue);
        inc(position_icode, 4);
        result := format('rot(%d,%d,%d)', [i1, i2, i3]);
      end;
    EX_VectorConst:
      begin
        f1 := FOwner.read_float(buffer);
        inc(position_icode, 4);
        f2 := FOwner.read_float(buffer);
        inc(position_icode, 4);
        f3 := FOwner.read_float(buffer);
        inc(position_icode, 4);
        ds := DecimalSeparator;
        DecimalSeparator := '.';
        result := format('vect(%f,%f,%f)', [f1, f2, f3]);
        DecimalSeparator := ds;
      end;
    EX_IntZero:
      begin
        result := '0';
      end;
    EX_IntOne:
      begin
        result := '1';
      end;
    EX_True:
      begin
        result := 'True';
      end;
    EX_False:
      begin
        result := 'False';
      end;
    EX_NoObject:
      begin
        result := 'None';
      end;
    EX_DynamicCast:
      begin
        i1 := FOwner.read_idx(buffer,utdmRefToObject);
        inc(position_icode, 4);
        result := FOwner.GetObjectPath(1, i1) + '(' + ReadToken(OuterOperatorPrecedence) + ')';
      end;
    EX_MetaCast:
      begin
        i1 := FOwner.read_idx(buffer,utdmRefToObject);
        inc(position_icode, 4);
        result := 'Class<' + FOwner.GetObjectPath(1, i1) + '>(' + ReadToken(OuterOperatorPrecedence) + ')';
      end;
    EX_StructMember:
      begin
        i1 := FOwner.read_idx(buffer,utdmRefToObject);
        inc(position_icode, 4);
        result := ReadToken(OuterOperatorPrecedence) + '.' + FOwner.GetObjectPath(1, i1);
      end;
    EX_Length:
      begin
        result := ReadToken(OuterOperatorPrecedence) + '.Length';
      end;
    EX_Skip:
      begin
        FOwner.read_word(buffer);
        inc(position_icode, 2);         // jump address
        result := ReadToken(OuterOperatorPrecedence);
      end;
    EX_VectorToRotator, EX_StringToRotator:
      begin
        result := 'rotator(' + ReadToken(OuterOperatorPrecedence) + ')';
      end;
    EX_RotatorToVector,EX_Unknown5B:
      begin
        if FOwner.Version<120 then // TODO : which version is the correct?
          result := 'vector(' + ReadToken(OuterOperatorPrecedence) + ')'
        else
          begin
            next_is_not_delegate:=true;
            result:=ReadToken(OuterOperatorPrecedence); // since it seems to be an invisible conversion...
          end;
      end;
    EX_StringToVector:
      begin
        result := 'vector(' + ReadToken(OuterOperatorPrecedence) + ')';
      end;
    EX_ObjectToBool,EX_StringToBool, EX_VectorToBool, EX_RotatorToBool:
      begin
        // seen a 0x47 (EX_ObjectToBool) in UT2004Demo at end of parameters
        if (b=EX_ObjectToBool) {and (position_icode=FScriptSize)} then
          result:=''
        else
          result := 'bool(' + ReadToken(OuterOperatorPrecedence) + ')';
      end;
    EX_NameToBool:
      begin
        if FOwner.Version<120 then
          result := 'bool(' + ReadToken(OuterOperatorPrecedence) + ')'
        else
          begin
            // ?? operator
            r1:=ReadToken(OuterOperatorPrecedence);
            FOwner.read_word(buffer);
            inc(position_icode, 2);     // size for next operand (in script units)
            r2:=ReadToken(OuterOperatorPrecedence);
            FOwner.read_word(buffer);
            inc(position_icode, 2);     // size for next operand (in script units)
            r3:=ReadToken(OuterOperatorPrecedence);
            result:='('+r1+' ?? '+r2+' : '+r3+')';
          end;
      end;
    EX_StringToByte:
      begin
        if (FOwner.GameHint<>UTPGH_Devastation) {FOwner.Version<120} then
          result := 'byte(' + ReadToken(OuterOperatorPrecedence) + ')'
        else
          begin // seems to be a color constant
            inc(position_icode,4);
            i1:=FOwner.read_byte(buffer); // R
            i2:=FOwner.read_byte(buffer); // G
            i3:=FOwner.read_byte(buffer); // B
            FOwner.read_byte(buffer);  // A
            result := format('col(%d,%d,%d)',[i1,i2,i3]);
          end;
      end;
    EX_StringToInt:
      begin
        result := 'int(' + ReadToken(OuterOperatorPrecedence) + ')';
      end;
    EX_StringToFloat:
      begin
        result := 'float(' + ReadToken(OuterOperatorPrecedence) + ')';
      end;
    EX_ByteToString, EX_IntToString, EX_BoolToString, EX_FloatToString,
      EX_ObjectToString, EX_NameToString, EX_VectorToString, EX_RotatorToString:
      begin
        result := 'string(' + ReadToken(OuterOperatorPrecedence) + ')';
      end;
    EX_StringToName:
      begin
        if (FOwner.GameHint<>UTPGH_Devastation) {FOwner.Version<120} then
          result := 'name(' + ReadToken(OuterOperatorPrecedence) + ')'
        else
          result := ReadToken(OuterOperatorPrecedence)+'.Empty()';
      end;
    EX_StringToName2:
      begin
        result := 'name(' + ReadToken(OuterOperatorPrecedence) + ')';
      end;
    EX_BoolToInt{, EX_Remove}:  // same token
      begin
        //result := ReadToken(OuterOperatorPrecedence);
        result := ReadToken(OuterOperatorPrecedence) + '.Remove ('+ReadToken(OuterOperatorPrecedence)+','+ReadToken(OuterOperatorPrecedence)+');';
      end;
    EX_FloatToByte{, EX_DelegateCall}: // same token
      begin
        if next_is_not_delegate then
          result := 'byte('+ReadToken(OuterOperatorPrecedence)+')'
        else
          begin
            next_is_not_delegate:=false;
            FOwner.read_idx(buffer,utdmRefToObject); // delegate object
            inc(position_icode, 4);
            result:=result+FOwner.names[FOwner.read_idx(buffer,utdmRefToName)]+'('; // delegate name
            inc(position_icode, 4);
            read_parameters(result);
            need_semicolon := true;
          end;
      end;
    EX_FloatToInt{, EX_DelegateName}: // same token
      begin
        if next_is_not_delegate then
          result := 'int('+ReadToken(OuterOperatorPrecedence)+')'
        else
          begin
            next_is_not_delegate:=false;
            result:=FOwner.names[FOwner.read_idx(buffer,utdmRefToName)]; // delegate name
            inc(position_icode, 4);
          end;
      end;
    EX_FloatToBool{, EX_DelegateAssign}: // same token
      begin
        if next_is_not_delegate then
          result := 'bool('+ReadToken(OuterOperatorPrecedence)+')'
        else
          begin
            r1:=ReadToken(OuterOperatorPrecedence);
            next_is_not_delegate:=false;
            r2:=ReadToken(OuterOperatorPrecedence);
            result:=r1+' = '+r2;
            need_semicolon := true;
          end;
      end;
    EX_ByteToBool,EX_IntToBool:
      begin
        result := 'bool('+ReadToken(OuterOperatorPrecedence)+')';
      end;
    EX_ByteToInt,EX_IntToByte,EX_ByteToFloat,EX_IntToFloat:
      begin
        result := ReadToken(OuterOperatorPrecedence);
      end;
    EX_BoolToFloat:
      begin
        result := 'float('+ReadToken(OuterOperatorPrecedence)+')';
      end;
    EX_BoolToByte:
      begin
        result := 'byte('+ReadToken(OuterOperatorPrecedence)+')';
      end;
    EX_BoolVariable:
      begin
        result := ReadToken(OuterOperatorPrecedence);
      end;
    EX_Jump:
      begin
        i1 := FOwner.read_word(buffer);
        inc(position_icode, 2);         // jump address
        // check "If" case (end of if block)
        if (nest <> nil) and
          (nest.count > 0) and
          (endnestlist.count > 0) and
          (nest[nest.count - 1] = pointer(NEST_If)) and // we are inside an If statement
          (position_icode = (DWORD(endnestlist.objects[endnestlist.count - 1]) and $FFFF)) and // and we are at the end of the If block
          (position_icode - 3 > DWORD(endnestlist.objects[endnestlist.count - 1]) shr 16) and  // but we are not at the start (case of a break inside an if)
          (i1 >= integer(position_icode)) then     // and we jump forward
          begin
            result := #8'} else {';
            // the initial backspace is to correct indentation
            endnestlist[endnestlist.count - 1] := 'ELSE';
            endnestlist.objects[endnestlist.count - 1] :=
              pointer(integer((DWORD(endnestlist.objects[endnestlist.count - 1]) and $FFFF0000)) or i1);
            nest[nest.count - 1] := pointer(NEST_Else);
            need_semicolon := false;
          end
            // check "Switch" case (break statement -> end of switch block)
        else if (nest <> nil) and
          (nest.count > 0) and
          (nest[nest.count - 1] = pointer(NEST_Switch)) and // we are inside a Switch statement
          (i1 >= integer(position_icode)) then     // and we jump forward
          begin
            result := 'break';
            need_semicolon := true;
            if ((endnestlist.count = 0) or
              ((integer(endnestlist.objects[endnestlist.count - 1]) and $FFFF) <> i1)) then
              endnestlist.addobject('SWITCH-BREAK', pointer((integer(position_icode) shl 16) or i1));
          end
        else
          begin
            i2 := jumplist.indexof(pointer(i1));
            if i2 = -1 then
              i2 := jumplist.add(pointer(i1));
            result := format('goto JL%-4.4x', [integer(jumplist[i2])]);
            need_semicolon := true;
          end;
      end;
    EX_ArrayElement:
      begin
        r1 := ReadToken(OuterOperatorPrecedence); // index
        r2 := ReadToken(OuterOperatorPrecedence); // base element
        result := r2 + '[' + r1 + ']';
      end;
    EX_DynArrayElement:
      begin
        r1 := ReadToken(OuterOperatorPrecedence); // index
        r2 := ReadToken(OuterOperatorPrecedence);
        // base element: not checked ???
        result := r2 + '[' + r1 + ']';
      end;
    EX_Switch:
      begin
        if (FOwner.Version<120) or (FOwner.GameHint<>UTPGH_Devastation) then
          begin
            FOwner.read_byte(buffer);
            inc(position_icode);            // switch size
          end;
        r1 := ReadToken(OuterOperatorPrecedence); // switch expression
        if copy(r1, 1, 1) <> '(' then
          r1 := '(' + r1 + ')';
        result := 'switch ' + r1;
        need_semicolon := false;
        if nest <> nil then
          nest.add(pointer(NEST_Switch))
        else
          result := result + ' {';
      end;
    EX_Case:
      begin
        i1 := FOwner.read_word(buffer);
        inc(position_icode, 2);         // address of next case
        if i1 = $FFFF then
          begin
            result := 'default:';
            // add end of switch here is we had no break statements (but we could displace some default case statements)
            if (nest <> nil) and
              (nest.count > 0) and
              (nest[nest.count - 1] = pointer(NEST_Switch)) and // we are inside a Switch statement
              ((endnestlist.count = 0) or (endnestlist[endnestlist.count - 1] <> 'SWITCH-BREAK')) then // we dont have a previous switch end (by break)
              endnestlist.addobject('SWITCH', pointer((position_icode shl 16) or position_icode));
          end
        else
          result := 'case ' + ReadToken(OuterOperatorPrecedence) + ':';
        need_semicolon := false;
        // we dont know where the switch ends except for any "break" inside the cases
      end;
    EX_Iterator:
      begin
        r1 := ReadToken(OuterOperatorPrecedence);
        FOwner.read_word(buffer);
        inc(position_icode, 2);         // end of loop
        result := format('foreach %s', [r1]);
        need_semicolon := false;
        if nest <> nil then
          nest.add(pointer(NEST_Foreach))
        else
          result := result + ' {';
      end;
    EX_IteratorPop:
      begin
        // indicates an exit from an iterator (foreach), maybe caused by a return statement inside
        if not prev_is_iteratornext then
          result:='' // indicates that a return follows
        else if (nest <> nil) and (nest.count>0) then
          nest.delete(nest.count - 1)
        else
          result := '}';
      end;
    EX_IteratorNext:
      begin
        // unnecesary to generate if the iterator ends here
        prev_pos:=buffer.Position;
        b2 := FOwner.read_byte(buffer);
        buffer.Position:=prev_pos;
        if b2<>EX_IteratorPop then
          begin
            result:='continue';
            need_semicolon:=true;
          end
        else
          result:='';
      end;
    EX_Stop:
      begin
        result := 'stop';               // just to flag the end, then removed
      end;
    EX_Assert:
      begin
        FOwner.read_word(buffer);
        inc(position_icode, 2);         // line number
        result := 'assert (' + ReadToken(OuterOperatorPrecedence) + ')';
        need_semicolon := true;
      end;
    EX_GotoLabel:
      begin
        result := 'goto (' + ReadToken(OuterOperatorPrecedence) + ')';
        need_semicolon := true;
      end;
    EX_StructCmpEq:
      begin
        FOwner.read_idx(buffer);
        inc(position_icode, 4);
        r1 := ReadToken(OuterOperatorPrecedence);
        r2 := ReadToken(OuterOperatorPrecedence);
        result := r1 + '==' + r2;
      end;
    EX_StructCmpNe:
      begin
        FOwner.read_idx(buffer);
        inc(position_icode, 4);
        r1 := ReadToken(OuterOperatorPrecedence);
        r2 := ReadToken(OuterOperatorPrecedence);
        result := r1 + '!=' + r2;
      end;
    EX_New:
      begin
        r1 := ReadToken(OuterOperatorPrecedence); // outer
        r2 := ReadToken(OuterOperatorPrecedence); // name
        r3 := ReadToken(OuterOperatorPrecedence); // flags
        r4 := ReadToken(OuterOperatorPrecedence); // class
        if r2 <> '' then
          r2 := ',' + r2;
        if r3 <> '' then
          r3 := ',' + r3;
        if r4 <> '' then
          r4 := ',' + r4;
        r1:=r1 + r2 + r3 + r4;
        if copy(r1,1,1)=',' then delete(r1,1,1);
        result := 'new (' + r1 + ')';
      end;
    EX_LabelTable:
      begin
        // follows an EX_Stop, and it will be aligned to 4 (filled with EX_Nothing)
        repeat
          letmp := Read_Struct_LabelEntry(FOwner, buffer);
          inc(position_icode, 8);
          if (lowercase(FOwner.Names[letmp.name]) <> 'none') then
            begin
              setlength(FLabelTable, length(FLabelTable) + 1);
              FLabelTable[high(FLabelTable)] := letmp;
            end;
        until (lowercase(FOwner.Names[letmp.name]) = 'none');
      end;
    EX_VirtualFunction:
      begin
        i1:=FOwner.read_idx(buffer,utdmRefToName);
        if i1>0 { not "None" } then // TODO : this can't be right!
         // Instead of EX_VirtualFunction it is probably a WORD from the previous token
         // Seen in Devastation/Core.u/Object.IsValidState
          begin
            inc(position_icode, 4);
            result := FOwner.Names[i1] + '(';
            if (FOwner.GameHint=UTPGH_Devastation) {FOwner.version>=120} then
              begin
                FOwner.read_word(buffer); // seems to be related to the parameters
                inc(position_icode,2);
              end;
            read_parameters(result);
            need_semicolon := true;
          end
        else
          begin
            inc(position_icode,1);
            result:=ReadToken (OuterOperatorPrecedence);
            // TODO : may have an "Static." prefix
          end;
      end;
    EX_GlobalFunction:
      begin
        result := 'Global.' + FOwner.Names[FOwner.read_idx(buffer,utdmRefToName)] + '(';
        inc(position_icode, 4);
        if (FOwner.GameHint=UTPGH_Devastation) {FOwner.version>=120} then
          begin
            FOwner.read_word(buffer); // seems to be related to the parameters
            inc(position_icode,2);
          end;
        read_parameters(result);
        need_semicolon := true;
      end;
    EX_FinalFunction:
      begin
        i1 := FOwner.read_idx(buffer,utdmRefToObject);
        if (lowercase(FOwner.GetObjectPath(1, i1)) = lowercase(UTObjectName)) and
          (lowercase(FOwner.GetObjectPath(2, i1)) <> lowercase(FOwner.GetObjectPath(2, FExportedIndex))) then
          begin                         // If it is the same name as self but different owner
            // TODO : may fail if owner is an State ?
            // get called function owner
            r1 := FOwner.GetObjectPath(2, i1);
            i2 := pos('.', r1);
            r1 := copy(r1, 1, i2 - 1);
            // get owner from current function owner
            r2 := FOwner.GetObjectPath(2, FSuperField);
            i2 := pos('.', r2);
            r2 := copy(r2, 1, i2 - 1);
            // compare
            if lowercase(r1) = lowercase(r2) then
              result := 'Super.'
            else
              result := 'Super(' + r1 + ').';
          end
        else
          result := ''; // TODO : may have "Static." prefix?
        result := result + FOwner.GetObjectPath(1, i1) + '(';
        inc(position_icode, 4);
        if (FOwner.GameHint=UTPGH_Devastation) {FOwner.version>=120} then
          begin
            FOwner.read_word(buffer); // seems to be related to the parameters
            inc(position_icode,2);
          end;
        read_parameters(result);
        need_semicolon := true;
      end
  else
    begin
      if b < EX_ExtendedNative then
        begin
          msg := format(rsUnknownOpcode, [b]);
          //windows.messagebox(0, pchar(msg), pchar(rsWarning), mb_ok);
          result := format('UnknownOpcode0x%-2.2x(', [b]) + ReadToken(OuterOperatorPrecedence) + ')';
          // we suppose it has function/conversion format
          raise EUnknownUTOpcode.create(msg);
        end
      else                              // other native function
        begin
          if (b and $F0) = EX_ExtendedNative then // high native flag
            begin
              i1 := ((b - EX_ExtendedNative) shl 8) + FOwner.read_byte(buffer);
              inc(position_icode, 1);
            end
          else
            i1 := b;
          if i1 < EX_FirstNative then
            raise EInvalidUTNativeIndex.create(format(rsInvalidNativeIndex, [i1]));
          i3 := -1;
          for i2 := 0 to high(Owner.NativeFunctions) do
            if Owner.NativeFunctions[i2].index = i1 then
              begin
                i3 := i2;
                break;
              end;
          if i3 <> -1 then
            begin
              if lowercase(Owner.NativeFunctions[i3].Name) = lowercase(UTObjectName) then
                begin                   // If it is the same name as self. Could also be recursion.
                  result := 'Super.';
                end
              else
                result := '';
              case Owner.NativeFunctions[i3].Format of
                nffFunction:
                  begin
                    result := result + Owner.NativeFunctions[i3].Name + '(';
                    read_parameters(result);
                  end;
                nffPreOperator:
                  begin
                    result := result + Owner.NativeFunctions[i3].Name + ReadToken(OuterOperatorPrecedence);
                    ReadToken(OuterOperatorPrecedence); // end params
                    if indent_level > 1 then
                      result := ' ' + result;
                  end;
                nffPostOperator:
                  begin
                    result := ReadToken(OuterOperatorPrecedence) + result + Owner.NativeFunctions[i3].Name;
                    ReadToken(OuterOperatorPrecedence); // end params
                    if indent_level > 1 then
                      result := result + ' ';
                  end;
                nffOperator:
                  begin
                    r1 := ReadToken(Owner.NativeFunctions[i3].OperatorPrecedence);
                    r2 := ReadToken(Owner.NativeFunctions[i3].OperatorPrecedence);
                    ReadToken(OuterOperatorPrecedence); // end params
                    result := r1 + ' ' + result + Owner.NativeFunctions[i3].Name + ' ' + r2;
                    if indent_level > 1 then
                      if Owner.NativeFunctions[i3].OperatorPrecedence > OuterOperatorPrecedence then
                        result := '(' + result + ')';
                  end;
              end;
            end
          else
            begin
              result := result + format('UnknownFunction%d(', [i1]);
              read_parameters(result);
            end;
          need_semicolon := true;
        end;
    end;
  end;
  dec(indent_level);
  prev_is_iteratornext:=(b=EX_IteratorNext);
  next_is_not_delegate:=false;
end;

function TUTObjectClassStruct.ReadStatement: string;
var
  a, previous_nest_level, n: integer;
  s, comment: string;tmp:boolean;
begin
  tmp:=FOwner.FInternalCallOnBasicDataEvent;
  if FOwner.FInternalCallOnBasicDataEvent and assigned(FOwner.FOnBasicData) then
    begin
      FOwner.FInternalCallOnBasicDataEvent:=false;
      FOwner.FOnBasicData (buffer.Position,utbdCodeStatement,utdmAsValue,-1,'Code Statement');
    end
  else
    FOwner.FInternalCallOnBasicDataEvent:=false;
  if nest <> nil then
    previous_nest_level := nest.count
  else
    previous_nest_level := 0;
  last_position_icode := position_icode;
  next_is_not_delegate:=false;
  result := ReadToken;
  // remove backspaces (when it is an Else)
  s := indent_chars;
  while copy(result, 1, 1) = #8 do
    begin
      delete(s, length(s), 1);
      delete(result, 1, 1);
    end;
  // add indent and semicolon
  if (result <> '') then
    begin
      result := FOwner.indenttext(s, result);
      if need_semicolon then
        result := result + ';';
    end;

  // check jumps
  n := 0;
  if nest <> nil then
    begin
      for a := 0 to endnestlist.count - 1 do
        if (integer(last_position_icode) < integer(endnestlist.objects[a]) and $FFFF) and
          (integer(endnestlist.objects[a]) and $FFFF < integer(position_icode)) then
          inc(n);
    end
  else
    begin
      for a := 0 to jumplist.count - 1 do
        if (integer(last_position_icode) < integer(jumplist[a])) and
          (integer(jumplist[a]) < integer(position_icode)) then
          inc(n);
    end;
  if n > 0 then
    result := result + #13#10 + indent_chars + '// There are ' + inttostr(n) +
      ' jump destination(s) inside the last statement!';

  // change indent
  if nest <> nil then
    begin
      // add indenting and block open braces
      a := previous_nest_level;
      while a < nest.Count do
        begin
          if result <> '' then
            result := result + #13#10;
          result := result + indent_chars + '{';
          indent_chars := indent_chars + #9;
          inc(a);
        end;
      // decrease nest levels
      comment := '';
      while (endnestlist.count > 0) and
        (integer(endnestlist.objects[endnestlist.count - 1]) and $FFFF <= integer(position_icode)) do
        begin
          //if (integer(endnestlist.objects[endnestlist.count - 1]) and $FFFF < position_icode) then comment:=' // there is a jump destination in-between the last statement!';
          nest.delete(nest.count - 1);
          endnestlist.delete(endnestlist.count - 1);
        end;
      // add unindenting and block close braces
      a := previous_nest_level;
      while a > nest.Count do
        begin
          if result <> '' then
            result := result + #13#10;
          delete(indent_chars, length(indent_chars), 1);
          result := result + indent_chars + '}' + comment;
          comment := '';
          dec(a);
        end;
    end;
  FOwner.FInternalCallOnBasicDataEvent:=tmp;
end;

procedure TUTObjectClassStruct.ReadStatements(code:tstrings;beautify: boolean=true;showoffsets:boolean=false);
var
  a, i, ib, code_first: integer;
  stmt:tstringlist;
begin
  check_initialized;
  code_first:=code.count;
  jumplist.clear;
  setlength(FLabelTable, 0);
  // read code statements
  if beautify then
    begin
      nest := tlist.create;
      endnestlist := tstringlist.create;
    end;
  indent_chars := '';
  stmt:=tstringlist.create;
  try
    while position_icode < FScriptSize do
      begin
        need_semicolon := false;
        labellist := '';
        i := position_icode;
        ib:=buffer.Position;
        stmt.text := ReadStatement;
        if stmt.count>0 then
          begin
            if showoffsets then
              stmt[0]:=stmt[0]+format(' // 0x%-8.8x : 0x%-4.4x',[ib,i]);
            code.addobject(stmt[0], pointer(ib));
            for a:=1 to stmt.count-1 do
              code.addobject(stmt[a], pointer(-1));
          end;
      end;
  except
  end;
  stmt.free;
  if beautify then
    begin
      freeandnil(nest);
      freeandnil(endnestlist);
    end;
  // add labels and indent
  a := code_first;
  while a < code.count do
    begin
      if (integer(code.objects[a]) and $FFFF) >= 0 then
        begin
          // normal labels
          i := JumpList.indexof(pointer(integer(code.objects[a]) and $FFFF));
          if i >= 0 then
            begin
              code.InsertObject(a, format('JL%-4.4x:', [integer(code.objects[a]) and $FFFF]), pointer(-1));
              inc(a);
              jumplist.delete(i);
            end;
          // state labels
          for i := 0 to high(FLabelTable) do
            if FLabelTable[i].iCode = (integer(code.objects[a]) and $FFFF) then
              begin
                code.InsertObject(a, FOwner.Names[FLabelTable[i].name] + ':', pointer(-1));
                inc(a);
              end;
        end;
      code[a] := FOwner.indenttext(#9, code[a]);
      inc(a);
    end;
end;

function TUTObjectClassStruct.ReadStatements(beautify: boolean=true;showoffsets:boolean=false): string;
var sl:tstringlist;
begin
  sl:=tstringlist.create;
  ReadStatements (sl,beautify,showoffsets);
  result:=sl.text;
  sl.free;
end;

procedure TUTObjectClassStruct.SkipStatements;
begin
  check_initialized;
  while position_icode < FScriptSize do
    ReadStatement;//ReadToken;
  setlength(FLabelTable, 0);
  jumplist.clear;
end;

function TUTObjectClassStruct.GetChildren: integer;
begin
  check_initialized;
  result := FChildren;
end;

function TUTObjectClassStruct.GetFriendlyName: string;
begin
  check_initialized;
  result := FFriendlyName;
end;

function TUTObjectClassStruct.GetLine: DWORD;
begin
  check_initialized;
  result := FLine;
end;

function TUTObjectClassStruct.GetScriptSize: DWORD;
begin
  check_initialized;
  result := FScriptSize;
end;

function TUTObjectClassStruct.GetScriptText: integer;
begin
  check_initialized;
  result := FScriptText;
end;

function TUTObjectClassStruct.GetTextPos: DWORD;
begin
  check_initialized;
  result := FTextPos;
end;

function TUTObjectClassStruct.Decompile(beautify: boolean=true;showoffsets:boolean=false): string;
begin
 // do nothing
 result:='';
end;

procedure TUTObjectClassStruct.Decompile(code:tstrings;beautify: boolean=true;showoffsets:boolean=false);
begin
  // do nothing;
end;

{ TUTObjectClassFunction }

procedure TUTObjectClassFunction.InitializeObject;
begin
  inherited;
  FiNative := 0;
  FRepOffset := $FFFF;
  FOperatorPrecedence := 0;
  FFunctionFlags := 0;
end;

procedure TUTObjectClassFunction.InterpretObject;
begin
  inherited;
  try
    SkipStatements;
    if FOwner.Version <= 63 then
      FOwner.read_word(buffer,utdmAsValue,'ParmsSize');         // ParmsSize
    FiNative := FOwner.read_word(buffer,utdmAsValue,'iNative');
    if FOwner.Version <= 63 then
      FOwner.read_byte(buffer,utdmAsValue,'NumParms');         // NumParms
    FOperatorPrecedence := FOwner.read_byte(buffer,utdmAsValue,'OperatorPrecedence');
    if FOwner.Version <= 63 then
      FOwner.read_word(buffer,utdmAsValue,'ReturnValueOffset');         // ReturnValueOffset
    FFunctionFlags := FOwner.read_dword(buffer,utdmFlags,'FunctionFlags');
    if (FunctionFlags and FUNC_Net) <> 0 then
      FRepOffset := FOwner.read_word(buffer,utdmAsValue,'RepOffset');
  except
  end;
end;

procedure TUTObjectClassFunction.Decompile(code:tstrings;beautify: boolean=true;showoffsets:boolean=false);
const
  indentation = #9;
var
  function_name, parameters, result_type, function_flags: string;locals:tstringlist;
  c: integer;
  prop: TUTObjectClassProperty;
begin
  check_initialized;
  buffer.seek(FScriptStart, soFromBeginning);
  try
    function_name := FFriendlyName;
    result_type := '';
    parameters := '';
    locals:=tstringlist.create;
    function_flags := '';
    if (FFunctionFlags and FUNC_Native) <> 0 then
      begin
        if FiNative > 0 then
          function_flags := function_flags + format('native(%d) ', [FiNative])
        else
          function_flags := function_flags + 'native ';
      end;
    if (FFunctionFlags and FUNC_Static) <> 0 then
      function_flags := function_flags + 'static ';
    if (FFunctionFlags and FUNC_Final) <> 0 then
      function_flags := function_flags + 'final ';
    //if (FFunctionFlags and FUNC_Defined)<>0 then function_flags:=function_flags+'defined ';
    if (FFunctionFlags and FUNC_Iterator) <> 0 then
      function_flags := function_flags + 'iterator ';
    if (FFunctionFlags and FUNC_Latent) <> 0 then
      function_flags := function_flags + 'latent ';
    if (FFunctionFlags and FUNC_Singular) <> 0 then
      function_flags := function_flags + 'singular ';
    //if (FFunctionFlags and FUNC_Net) <> 0 then function_flags := function_flags + 'net ';
    //if (FFunctionFlags and FUNC_NetReliable) <> 0 then function_flags := function_flags + 'netreliable ';
    if (FFunctionFlags and FUNC_Simulated) <> 0 then
      function_flags := function_flags + 'simulated ';
    if (FFunctionFlags and FUNC_Exec) <> 0 then
      function_flags := function_flags + 'exec ';
    if (FFunctionFlags and FUNC_Event) <> 0 then
      function_flags := function_flags + 'event ';
    if (FFunctionFlags and FUNC_Delegate) <> 0 then
      function_flags := function_flags + 'delegate ';
    if (FFunctionFlags and FUNC_NoExport) <> 0 then
      function_flags := function_flags + 'noexport ';
    if (FFunctionFlags and FUNC_Const) <> 0 then
      function_flags := function_flags + 'const ';
    if (FFunctionFlags and FUNC_Invariant) <> 0 then
      function_flags := function_flags + 'invariant ';
    if (FFunctionFlags and FUNC_Operator) <> 0 then
      begin
        if (FFunctionFlags and FUNC_PreOperator) <> 0 then
          function_flags := function_flags + 'preoperator '
        else if FOperatorPrecedence = 0 then
          function_flags := function_flags + 'postoperator '
        else
          function_flags := function_flags + format('operator(%d) ',
            [FOperatorPrecedence]);
      end;
    if ((FFunctionFlags and FUNC_Operator) = 0) and
      ((FFunctionFlags and FUNC_Event) = 0) and
      ((FFunctionFlags and FUNC_Delegate) = 0) then
      function_flags := function_flags + 'function ';

    c := FChildren;
    while c <> 0 do
      begin
        dec(c);
        if not (FOwner.Exported[c].UTObject is TUTObjectClassProperty) then break;
        prop := TUTObjectClassProperty(FOwner.Exported[c].UTObject);
        try
          try
            prop.ReadObject;
            if (prop.PropertyFlags and CPF_Parm) <> 0 then
              begin                     // function parameter, could also be a return value
                if (prop.PropertyFlags and CPF_ReturnParm) <> 0 then
                  begin
                    result_type := prop.GetFlags(UTobjectname) + prop.GenericTypeName;
                  end
                else
                  begin
                    parameters := parameters + prop.GetDeclaration('', UTobjectname) + ', ';
                  end;
              end
            else
              begin                     // local variable
                locals.addobject (indentation + prop.GetDeclaration('local', UTobjectname) + ';',pointer(-1));
              end;
            c := prop.Next;
          finally
            prop.ReleaseObject;
          end;
        except
          c := 0;
        end;
      end;
    if parameters <> '' then
      delete(parameters, length(parameters) - 1, 2);
    if result_type <> '' then
      result_type := result_type + ' ';
    if locals.count > 0 then locals.addobject('',pointer(-1));
    if ((FFunctionFlags=0) and (FScriptSize>0)) or ((FFunctionFlags and FUNC_Defined) <> 0) then
      begin
        code.addobject (format('%s%s%s (%s)', [function_flags, result_type, function_name, parameters]),pointer(-1));
        position_icode := 0;
        code.addobject('{',pointer(-1));
        code.addstrings(locals);
        ReadStatements(code,beautify,showoffsets);
        // remove last "return;" line
        if copy(trim(code[code.count-1]),1,7)='return;' then code.delete(code.count-1);
        code.addobject('}',pointer(-1));
      end
    else
      code.addobject (format('%s%s%s (%s);', [function_flags, result_type, function_name, parameters]),pointer(-1));         // native functions do not have code
    locals.free;
  except
  end;
end;

function TUTObjectClassFunction.Decompile(beautify: boolean=true;showoffsets:boolean=false): string;
var sl:tstringlist;
begin
  sl:=tstringlist.create;
  Decompile (sl,beautify,showoffsets);
  result:=sl.text;
  sl.free;
end;

function TUTObjectClassFunction.GetFunctionFlags: DWORD;
begin
  check_initialized;
  result := FFunctionFlags;
end;

function TUTObjectClassFunction.GetiNative: integer;
begin
  check_initialized;
  result := FiNative;
end;

function TUTObjectClassFunction.GetOperatorPrecedence: integer;
begin
  check_initialized;
  result := FOperatorPrecedence;
end;

function TUTObjectClassFunction.GetRepOffset: integer;
begin
  check_initialized;
  result := FRepOffset;
end;

{ TUTObjectClassIntProperty }

procedure TUTObjectClassIntProperty.InitializeObject;
begin
  inherited;
  FMin:=0;
  FMax:=0;
  FIncrement:=0;
end;

procedure TUTObjectClassIntProperty.InterpretObject;
begin
  inherited;
  if ((FPropertyFlags and CPF_EditorData) <> 0) then
    begin
      FMin:=FOwner.read_int(buffer,utdmAsValue,'Min');
      FMax:=FOwner.read_int(buffer,utdmAsValue,'Max');
      FIncrement:=FOwner.read_int(buffer,utdmAsValue,'Increment');
    end;
end;

function TUTObjectClassIntProperty.GenericTypeName: string;
begin
  check_initialized;
  result := 'int';
end;

{ TUTObjectClassBoolProperty }

function TUTObjectClassBoolProperty.GenericTypeName: string;
begin
  check_initialized;
  result := 'bool';
end;

{ TUTObjectClassFloatProperty }

procedure TUTObjectClassFloatProperty.InitializeObject;
begin
  inherited;
  FMin:=0.0;
  FMax:=0.0;
  FIncrement:=0.0;
end;

procedure TUTObjectClassFloatProperty.InterpretObject;
begin
  inherited;
  if ((FPropertyFlags and CPF_EditorData) <> 0) then
    begin
      FMin:=FOwner.read_float(buffer,'Min');
      FMax:=FOwner.read_float(buffer,'Max');
      FIncrement:=FOwner.read_float(buffer,'Increment');
    end;
end;

function TUTObjectClassFloatProperty.GenericTypeName: string;
begin
  check_initialized;
  result := 'float';
end;

{ TUTObjectClassNameProperty }

function TUTObjectClassNameProperty.GenericTypeName: string;
begin
  check_initialized;
  result := 'name';
end;

{ TUTObjectClassStrProperty }

function TUTObjectClassStrProperty.GenericTypeName: string;
begin
  check_initialized;
  result := 'string';
end;

{ TUTObjectClassStringProperty }

function TUTObjectClassStringProperty.GenericTypeName: string;
begin
  check_initialized;
  result := 'string';                   // old fixed-length string type
end;

{ TUTObjectClassPointerProperty }

function TUTObjectClassPointerProperty.GenericTypeName: string;
begin
  check_initialized;
  result := 'pointer';
end;

{ TUTObjectClassState }

procedure TUTObjectClassState.Decompile(code:tstrings;beautify: boolean=true;showoffsets:boolean=false);
var
  c,code_first: integer;
  child: TUTObject;
  header,ignored_functions: string;
  result_str,var_block,tmp: tstringlist;
begin
  check_initialized;
  buffer.seek(FScriptStart, soFromBeginning);
  c := FChildren;
  code_first:=code.count;
  result_str:=tstringlist.create;
  var_block:=tstringlist.create;
  while c <> 0 do
    begin
      child := FOwner.Exported[c - 1].UTObject;
      try
        child.ReadObject;
        if child is TUTObjectClassField then
          begin
            if child is TUTObjectClassFunction then
              begin
                if (TUTObjectClassFunction(child).FunctionFlags and FUNC_Defined) <> 0 then
                  begin
                    tmp:=tstringlist.create;
                    TUTObjectClassFunction(child).Decompile(tmp,beautify,showoffsets);
                    tmp.add ('');
                    tmp.addstrings(result_str);
                    result_str.free;
                    result_str:=tmp;
                  end
                else
                  ignored_functions := ignored_functions + ', ' + TUTObjectClassFunction(child).UTObjectName;
              end
            else if child is TUTObjectClassProperty then
              begin                     // it is a variable (may not exist in states?)
                var_block.add(TUTObjectClassProperty(child).GetDeclaration('local', UTobjectname) + ';');
              end
            else if child is TUTObjectClassConst then
              begin                     // it is a const
                var_block.add(TUTObjectClassConst(child).GetDeclaration + ';');
              end
            else if child is TUTObjectClassEnum then
              begin                     // it is an enum
                var_block.addobject(TUTObjectClassEnum(child).GetDeclaration + ';',pointer(-1));
                var_block.add('');
              end
            else if (child is TUTObjectClassStruct) and
              not ((child is TUTObjectClassFunction) or
                   (child is TUTObjectClassState)) then
              begin                     // it is an struct
                var_block.add(TUTObjectClassStruct(child).GetDeclaration + ';');
                var_block.add('');
              end;
            c := TUTObjectClassField(child).Next;
          end
        else
          c := 0;
      finally
        child.ReleaseObject;
      end;
    end;

  if ignored_functions <> '' then
    begin
      delete(ignored_functions, 1, 1);
      ignored_functions := 'ignores ' + ignored_functions + ';';
    end;
  if var_block.count > 0 then var_block.add('');

  if ignored_functions<>'' then
    begin
      var_block.add (ignored_functions);
      var_block.add ('');
    end;
  var_block.addstrings(result_str);
  result_str.free;
  result_str:=var_block;

  position_icode := 0;
  header := '';
  if (FStateFlags and STATE_Auto) <> 0 then
    header := header + 'auto ';
  if (FStateFlags and STATE_Simulated) <> 0 then
    header := header + 'simulated ';
  if (FStateFlags and STATE_Editable) <> 0 then
    header := header + 'state() '
  else
    header := header + 'state ';
  header := header + UTObjectName;
  if SuperField <> 0 then
    header := header + ' extends ' + FOwner.GetObjectPath(1, SuperField);

  code.add(header);
  code.add('{');
  for c:=0 to result_str.count-1 do
    code.Add (#9+result_str[c]);

  // remove offsets until here
  for c:=code_first to code.count-1 do
    code.objects[c]:=pointer(-1);

  ReadStatements(code,beautify,showoffsets);
  code.delete(code.count - 1); // remove last "stop;" line
  code.addobject ('}',pointer(-1));
end;

function TUTObjectClassState.Decompile(beautify: boolean=true;showoffsets:boolean=false): string;
var sl:tstringlist;
begin
  sl:=tstringlist.create;
  Decompile (sl,beautify,showoffsets);
  result:=sl.Text;
  sl.free;
end;

function TUTObjectClassState.GetIgnoreMask: int64;
begin
  check_initialized;
  result := FIgnoreMask;
end;

function TUTObjectClassState.GetLabelTableOffset: word;
begin
  check_initialized;
  result := FLabelTableOffset;
end;

function TUTObjectClassState.GetProbeMask: int64;
begin
  check_initialized;
  result := FProbeMask;
end;

function TUTObjectClassState.GetStateFlags: DWORD;
begin
  check_initialized;
  result := FStateFlags;
end;

procedure TUTObjectClassState.InitializeObject;
begin
  inherited;
  FProbeMask := 0;
  FIgnoreMask := 0;
  FStateFlags := 0;
  FLabelTableOffset := 0;
end;

procedure TUTObjectClassState.InterpretObject;
begin
  inherited;
  SkipStatements;
  FProbeMask := FOwner.read_qword(buffer,utdmAsValue,'ProbeMask');
  FIgnoreMask := FOwner.read_qword(buffer,utdmAsValue,'IgnoreMask');
  FLabelTableOffset := FOwner.read_word(buffer,utdmAsValue,'LabelTableOffset');
  FStateFlags := FOwner.read_dword(buffer,utdmFlags,'StateFlags');
end;

{ TUTObjectClassClass }

function TUTObjectClassClass.GetSource(beautify: boolean = true;showoffsets:boolean=false): string;
var
  txtObj: TUTObjectClassTextBuffer;
  p: integer;
  pname, pdescvalue,pvaluetypename: string;
  pvalue: variant;
  pvaluetype: DWORD;
begin
  check_initialized;
  // First try and get the source from the associated TextBuffer
  result := '';
  if ScriptText > 0 then
    begin
      txtObj := TUTObjectClassTextBuffer(FOwner.Exported[ScriptText - 1].UTObject);
      if txtObj <> nil then
        begin
          txtObj.ReadObject;
          result := txtObj.Data;
          txtObj.ReleaseObject;
        end;
    end;
  if trim(result) <> '' then
    begin
      // Get the default Properties
      result := result + 'defaultproperties'#13#10'{'#13#10;
      for p := 0 to properties.count - 2 do
        begin
          properties.propertybyposition[p].GetValue(-1, -1, pname, pvalue, pdescvalue, pvaluetype,pvaluetypename);
          if properties.propertybyposition[p].arrayindex >= 0 then
            pname := pname + '(' + inttostr(properties.propertybyposition[p].arrayindex) + ')';
          if pdescvalue = '' then
            pdescvalue := pvalue;
          result := result + format('    %s=%s'#13#10, [pname, pdescvalue]);
        end;
      result := result + '}'#13#10;
    end
  else                                  // No Source.. decompile it
    result := Decompile(beautify,showoffsets);
end;

procedure TUTObjectClassClass.SaveToFile(Filename: string);
var
  f: TFileStream;
  s: string;
begin
  s := GetSource;
  if s <> '' then
    begin
      f := TFileStream.Create(Filename, fmCreate);
      f.Write(s[1], length(s));
      f.free;
    end;
end;

procedure TUTObjectClassClass.Decompile(code:tstrings;beautify: boolean=true;showoffsets:boolean=false);
type
  TUTGUID = record
    case byte of
      0: (guid: TGUID);
      1: (A, B, C, D: integer);
      2: (n: int64);
  end;
var
  a, b, c, o, offs, is_reliable: integer;
  child: TUTObject;
  var_block, func_block, replication_block,tmp:tstringlist;
  within, flags, rep_condition, n, rep_type, bars, pname, pdescvalue,pvaluetypename, showcat,hidecat,tmpstr: string;
  pvalue: variant;
  pvaluetype: DWORD;
  g: TUTGUID;
  replication_list: tstringlist;
  ThePackage:TUTPackage;TheObject:TUTObject;superflags:DWORD;
  superhidecategorieslist:array of string;
  found:boolean;
  code_first:integer;
  procedure WriteFlag (superflags,classflags,flag:DWORD;const name,noname:string;var flags:string);
  begin
    // flags shown depend on superclass flags
    //  if superclass flag XOR class flag = 0 -> do not write
    //  if superclass flag XOR class flag = 1 -> write depending on class flag
    if ((superflags and flag) xor (classflags and flag))<>0 then
      begin
        if (classflags and flag)=0 then
          begin
            if noname<>'' then flags:=flags+#9+noname+#13#10;
          end
        else
          begin
            if name<>'' then flags:=flags+#9+name+#13#10;
          end;
      end;
  end;
begin
  check_initialized;
  buffer.seek(FScriptStart, soFromBeginning);

  code_first:=code.Count;

  replication_list := tstringlist.create;

  // TODO : add "import" clause: import (enum|package) <name> [from <package>]

  // read functions & states
  func_block:=tstringlist.create;
  c := FChildren;
  while c <> 0 do
    begin
      child := FOwner.Exported[c - 1].UTObject;
      try
        child.ReadObject;
        if child is TUTObjectClassField then
          begin
            if child is TUTObjectClassState then
              begin
                tmp:=tstringlist.create;
                TUTObjectClassState(child).Decompile(tmp,beautify,showoffsets);
                tmp.add ('');
                tmp.addstrings(func_block);
                func_block.free;
                func_block:=tmp;
              end
            else if child is TUTObjectClassFunction then
              begin
                tmp:=tstringlist.create;
                TUTObjectClassFunction(child).Decompile(tmp,beautify,showoffsets);
                tmp.add ('');
                tmp.addstrings(func_block);
                func_block.free;
                func_block:=tmp;
                if ((TUTObjectClassFunction(child).functionflags and FUNC_Net) <> 0) and
                  (TUTObjectClassFunction(child).ReplicationOffset < $FFFF) then
                  if (TUTObjectClassFunction(child).functionflags and FUNC_NetReliable) <> 0 then
                    replication_list.addobject(TUTObjectClassFunction(child).UTobjectname,
                      pointer($C0000000 or DWORD(TUTObjectClassFunction(child).ReplicationOffset)))
                  else
                    replication_list.addobject(TUTObjectClassFunction(child).UTobjectname,
                      pointer($80000000 or DWORD(TUTObjectClassFunction(child).ReplicationOffset)));
              end;
            c := TUTObjectClassField(child).Next;
          end
        else
          c := 0;
      finally
        child.ReleaseObject;
      end;
    end;

  // read variable declarations
  var_block:=tstringlist.create;
  c := FChildren;
  while c <> 0 do
    begin
      child := FOwner.Exported[c - 1].UTObject;
      try
        child.ReadObject;
        if child is TUTObjectClassField then
          begin
            if (child is TUTObjectClassProperty) and not (child is TUTObjectClassDelegateProperty) then
              begin                     // it is a global variable
                var_block.addobject(TUTObjectClassProperty(child).GetDeclaration('var', UTobjectname) + ';',pointer(-1));
                if (TUTObjectClassProperty(child).propertyflags and CPF_Net) <> 0 then
                  begin
                    // TODO : get actual reliable flag
                    // try to find whether it is reliable based on functions with same RepOffset
                    is_reliable := $00000000; // default is unknown
                    for a := 0 to replication_list.count - 1 do
                      if (integer(replication_list.objects[a]) and $3FFFFFFF) =
                        TUTObjectClassProperty(child).ReplicationOffset then
                        begin
                          is_reliable := integer(replication_list.objects[a]) and $C0000000;
                          break;
                        end;
                    replication_list.addobject(TUTObjectClassProperty(child).UTobjectname, pointer(is_Reliable or TUTObjectClassProperty(child).ReplicationOffset));
                  end;
              end
            else if child is TUTObjectClassConst then
              begin                     // it is a const
                var_block.add(TUTObjectClassConst(child).GetDeclaration + ';');
              end
            else if child is TUTObjectClassEnum then
              begin                     // it is an enum
                var_block.add(TUTObjectClassEnum(child).GetDeclaration + ';');
                var_block.add('');
              end
            else if (child is TUTObjectClassStruct) and
              not ((child is TUTObjectClassFunction) or
                   (child is TUTObjectClassState)) then
              begin                     // it is an struct
                var_block.add(TUTObjectClassStruct(child).GetDeclaration + ';');
                var_block.add('');
              end;
            c := TUTObjectClassField(child).Next;
          end
        else
          c := 0;
      finally
        child.ReleaseObject;
      end;
    end;
  if var_block.count>0 then var_block.add ('');

  // construct the replication block
  replication_block:=tstringlist.create;
  while replication_list.count > 0 do
    begin
      o := integer(replication_list.objects[0]);
      offs := o and $3FFFFFFF;
      buffer.seek(FScriptStart, soFromBeginning);
      position_icode := 0;
      while integer(position_icode) <= offs do
        rep_condition := ReadToken;
      case (o and $C0000000) of
        $C0000000: rep_type := 'reliable';
        $80000000: rep_type := 'unreliable';
      else
        rep_type := 'un?reliable';
      end;
      n := '';
      b := replication_list.count - 1;
      while b > 0 do
        begin
          if replication_list.objects[b] = pointer(o) then
            begin
              n := replication_list[b] + ',' + n;
              replication_list.delete(b);
            end;
          dec(b);
        end;
      if n <> '' then
        n := ',' + copy(n, 1, length(n) - 1);
      n := replication_list[0] + n;
      replication_list.delete(0);
      replication_block.add(#9 + rep_type + ' if ( ' + rep_condition + ' )');
      replication_block.add(#9#9 + n + ';');
    end;
  if replication_block.count > 0 then
    begin
      replication_block.insert(0,'replication');
      replication_block.insert(1,'{');
      replication_block.add('}');
      replication_block.add('');
    end;
    
  superflags:=0;
  if SuperField<>0 then
    begin
      // get superclass flags
      FOwner.FindObjectAndPackage(SuperField,ThePackage,TheObject);
      if TheObject<>nil then
        begin
          if TheObject.UTClassName='' then
            begin
              TheObject.ReadObject;
              superflags:=TUTObjectClassClass(TheObject).ClassFlags;
              setlength(superhidecategorieslist,TUTObjectClassClass(TheObject).HideCategoriesListCount);
              for a:=0 to TUTObjectClassClass(TheObject).HideCategoriesListCount-1 do
                superhidecategorieslist[a]:=ThePackage.Names[TUTObjectClassClass(TheObject).HideCategoriesList[a]];
            end;
          if ThePackage<>FOwner then ThePackage.free;
        end;
    end;

  flags := #13#10;
  if (UTFlags and RF_Native) <> 0 then
    flags := flags + #9'Native'#13#10;

  if (ClassFlags and CLASS_Abstract) <> 0 then
    flags := flags + #9'Abstract'#13#10;
  //WriteFlag (superflags,classflags,CLASS_Abstract,'Abstract','',flags);

  WriteFlag (superflags,classflags,CLASS_NoExport,'NoExport','Export',flags);
  WriteFlag (superflags,classflags,CLASS_NativeReplication,'NativeReplication','NoNativeReplication',flags);
  WriteFlag (superflags,classflags,CLASS_PerObjectConfig,'PerObjectConfig','NoPerObjectConfig',flags);
  if FOwner.Version<117 then
    WriteFlag (superflags,classflags,CLASS_NoUserCreate,'NoUserCreate','UserCreate',flags)
  else
    WriteFlag (superflags,classflags,CLASS_NoUserCreate,'Placeable','NotPlaceable',flags);
  WriteFlag (superflags,classflags,CLASS_EditInLineNew,'EditInLineNew','NotEditInLineNew',flags);
  WriteFlag (superflags,classflags,CLASS_CollapseCategories,'CollapseCategories','DontCollapseCategories',flags);
  WriteFlag (superflags,classflags,CLASS_ExportStructs,'ExportStructs','DontExportStructs',flags);
  WriteFlag (superflags,classflags,CLASS_Transient,'Transient','NotTransient',flags);
  WriteFlag (superflags,classflags,CLASS_SafeReplace,'SafeReplace','NotSafeReplace',flags);
  WriteFlag (superflags,classflags,CLASS_Localized,'Localized','NotLocalized',flags);

  g.guid := FClassGuid;
  if g.n <> 0 then // {U2} seems to not be shown even if <>0 ?
    flags := flags + format(#9'guid(%d,%d,%d,%d)'#13#10, [g.A, g.B, g.C, g.D]);
  if ((ClassFlags and CLASS_Config) <> 0) and
    (lowercase(FOwner.Names[FClassConfigName]) <> 'system') then
    flags := flags + format(#9'Config(%s)'#13#10, [FOwner.Names[FClassConfigName]]);

  // cat is not in super and not in class -> inherited show, dont write
  // cat is not in super and in class     -> hide
  // cat is in super and not in class     -> show
  // cat is in super and in class         -> inherited hide, dont write
  // (not sure if it should check all the inheritance chain)
  showcat:='';
  hidecat:='';
  for a:=0 to high(superHideCategoriesList) do
    begin
      n:=superHideCategorieslist[a];
      found:=false;
      for b:=0 to high(Fhidecategorieslist) do
        if n=FOwner.Names[Fhidecategorieslist[b]] then
          begin
            found:=true;
            break;
          end;
      if not found then
        showcat:=showcat+n+',';
    end;
  for a:=0 to high(FHideCategoriesList) do
    begin
      n:=FOwner.Names[FHideCategoriesList[a]];
      found:=false;
      for b:=0 to high(superhidecategorieslist) do
        if n=superhidecategorieslist[b] then
          begin
            found:=true;
            break;
          end;
      if not found then
        hidecat:=hidecat+n+',';
    end;
  if hidecat<>'' then flags:=flags+#9'HideCategories('+copy(hidecat,1,length(hidecat)-1)+')'#13#10;
  if showcat<>'' then flags:=flags+#9'ShowCategories('+copy(showcat,1,length(showcat)-1)+')'#13#10;

  if flags <> '' then
    delete(flags, length(flags) - 1, 2);

  // TODO : should only show if super does not define the same
  within := '';
  if (FClassWithin <> 0) and (lowercase(FOwner.GetObjectPath(1, FClassWithin)) <> 'object') then
    within := ' within ' + FOwner.GetObjectPath(1, FClassWithin);

  setlength(bars, 80);
  fillchar(bars[1], 80, ord('='));

  code.Add('//'+bars);
  code.Add('// '+UTObjectName+'.');
  code.Add('//'+bars);
  code.Add('');

  tmpstr:='class '+UTObjectName;
  if SuperField <> 0 then
    tmpstr:=tmpstr+' extends '+FOwner.GetObjectPath(1,SuperField);
  tmpstr:=tmpstr+within+flags+';';
  code.Add(tmpstr);
  code.Add('');
  code.AddStrings(var_block);
  code.AddStrings(replication_block);
  code.AddStrings(func_block);

  if properties.count > 1 then
    begin
      code.Add('defaultproperties');
      code.add('{');
      for c := 0 to properties.count - 2 do
        begin
          properties.propertybyposition[c].GetValue(-1, -1, pname, pvalue, pdescvalue, pvaluetype,pvaluetypename);
          if properties.propertybyposition[c].arrayindex >= 0 then
            pname := pname + '(' + inttostr(properties.propertybyposition[c].arrayindex) + ')';
          if pdescvalue = '' then
            pdescvalue := pvalue;
          code.add(format('    %s=%s'#13#10, [pname, pdescvalue]));
        end;
      code.add('}');
    end;

  // remove all offsets
  for a:=code_first to code.count-1 do
    code.objects[a]:=pointer(-1);

  var_block.free;
  func_block.free;
  replication_block.free;

  replication_list.free;
end;

function TUTObjectClassClass.Decompile(beautify: boolean=true;showoffsets:boolean=false): string;
var sl:tstringlist;
begin
  sl:=tstringlist.create;
  Decompile (sl,beautify,showoffsets);
  result:=sl.text;
  sl.free;
end;

function TUTObjectClassClass.GetDependencyCount: integer;
begin
  check_initialized;
  result := length(FDependencies);
end;

function TUTObjectClassClass.GetClassConfigName: integer;
begin
  check_initialized;
  result := FClassConfigName;
end;

function TUTObjectClassClass.GetClassFlags: DWORD;
begin
  check_initialized;
  result := FClassFlags;
end;

function TUTObjectClassClass.GetClassGuid: TGuid;
begin
  check_initialized;
  result := FClassGuid;
end;

function TUTObjectClassClass.GetClassWithin: integer;
begin
  check_initialized;
  result := FClassWithin;
end;

function TUTObjectClassClass.GetDependencies(i: integer): TUT_Struct_Dependency;
begin
  check_initialized;
  result := FDependencies[i];
end;

function TUTObjectClassClass.GetPackageImports(i: integer): integer;
begin
  check_initialized;
  result := FPackageImports[i];
end;

procedure TUTObjectClassClass.InitializeObject;
begin
  inherited;
  FClassFlags := 0;
  fillchar(FClassGuid, sizeof(TGuid), 0);
  setlength(FDependencies, 0);
  setlength(FPackageImports, 0);
  setlength(FHideCategoriesList,0);
  FClassWithin := 0;
  FClassConfigName := 0;
end;

procedure TUTObjectClassClass.InterpretObject;
var
  a: integer;
begin
  inherited;
  SkipStatements;
  if FOwner.Version <= 61 then
    FOwner.read_dword(buffer,utdmAsValue,'OldClassRecordSize');
  if (FOwner.GameHint=UTPGH_ArmyOperations) or
     (FOwner.GameHint=UTPGH_Unreal2) then
    FOwner.read_dword(buffer); // TODO : unknown dword (maybe when version>=120?, not in Devastation!)
  FClassFlags := FOwner.read_dword(buffer,utdmFlags,'ClassFlags');
  FClassGuid := FOwner.read_guid(buffer,'ClassGUID');
  //if FOwner.Version >= 83 {?} then FOwner.read_dword(buffer); {U2}
  setlength(FDependencies, CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue,'Dependencies Array Size')));
  for a := 0 to high(FDependencies) do
    FDependencies[a] := Read_Struct_Dependency(Fowner, buffer,'Dependencies');
  setlength(FPackageImports, CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue,'PackageImports Array Size')));
  for a := 0 to high(FPackageImports) do
    FPackageImports[a] := FOwner.read_idx(buffer,utdmRefToName,'PackageImports');
  if FOwner.Version >= 62 then
    begin
      FClassWithin := FOwner.read_idx(buffer,utdmRefToObject,'ClassWithin');
      FClassConfigName := FOwner.read_idx(buffer,utdmRefToName,'ClassConfigName');
    end;
  if FOwner.Version>=100{117} then
    begin
      a:=CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue,'HideCategoriesList Array Size'));
      setlength(FHideCategoriesList,a);
      if a>0 then
        begin
          for a := 0 to high(FHideCategoriesList) do
            FHideCategoriesList[a]:=FOwner.read_idx(buffer,utdmRefToName,'HideCategoriesList');
        end;
    end;
  if (FOwner.Version >= 85) and (FOwner.Version < 117) and
     (FOwner.GameHint=UTPGH_Undying) then // maybe also other games?
    begin
      FOwner.read_dword(buffer);          // TODO : unknown dword in class
    end;
  if FOwner.GameHint=UTPGH_DeusExInvisibleWar then
    begin
      FOwner.read_sizedasciiz (buffer,'ClassRealName?'); // not sure
      if FOwner.read_dword (buffer)<>0 then // unknown, some type of flags?
        begin
          if FOwner.read_idx(buffer)<>0 then
            begin

            end;
          FOwner.read_dword(buffer);
          FOwner.read_dword(buffer);
        end;
    end;
  ReadProperties;
end;

function TUTObjectClassClass.GetPackageImportsCount: integer;
begin
  check_initialized;
  result := length(FPackageImports);
end;

function TUTObjectClassClass.GetHideCategoriesList(i: integer): integer;
begin
  Check_initialized;
  result:=FHideCategoriesList[i];
end;

function TUTObjectClassClass.GetHideCategoriesListCount: integer;
begin
  check_initialized;
  result:= length(FHideCategoriesList);
end;

{ TUTObjectClassSkeletalMesh }

function TUTObjectClassSkeletalMesh.GetBoneWeight(i: integer): TUT_Struct_BoneInfluence;
begin
  check_initialized;
  result := FBoneWeights[i];
end;

function TUTObjectClassSkeletalMesh.GetBoneWeightCount: integer;
begin
  check_initialized;
  result := length(FBoneWeights);
end;

function TUTObjectClassSkeletalMesh.GetBoneWeightIdx(i: integer): TUT_Struct_BoneInfIndex;
begin
  check_initialized;
  result := FBoneWeightIdx[i];
end;

function TUTObjectClassSkeletalMesh.GetBoneWeightIdxCount: integer;
begin
  check_initialized;
  result := length(FBoneWeightIdx);
end;

function TUTObjectClassSkeletalMesh.GetExtWedge(
  i: integer): TUT_Struct_MeshExtWedge;
begin
  check_initialized;
  result := FExtWedges[i];
end;

function TUTObjectClassSkeletalMesh.GetExtWedgeCount: integer;
begin
  check_initialized;
  result := length(FExtWedges);
end;

function TUTObjectClassSkeletalMesh.GetLocalPoint(
  i: integer): TUT_Struct_Vector;
begin
  check_initialized;
  result := FLocalPoints[i];
end;

function TUTObjectClassSkeletalMesh.GetLocalPointCount: integer;
begin
  check_initialized;
  result := length(FLocalPoints);
end;

function TUTObjectClassSkeletalMesh.GetPoint(i: integer): TUT_Struct_Vector;
begin
  check_initialized;
  result := FPoints[i];
end;

function TUTObjectClassSkeletalMesh.GetPointCount: integer;
begin
  check_initialized;
  result := length(FPoints);
end;

function TUTObjectClassSkeletalMesh.GetRefSkeleton(i: integer): TUT_Struct_MeshBone;
begin
  check_initialized;
  result := FRefSkeleton[i];
end;

function TUTObjectClassSkeletalMesh.GetRefSkeletonCount: integer;
begin
  check_initialized;
  result := length(FRefSkeleton);
end;

procedure TUTObjectClassSkeletalMesh.InitializeObject;
begin
  inherited;
  setlength(FExtWedges, 0);
  setlength(FPoints, 0);
  setlength(FRefSkeleton, 0);
  setlength(FBoneWeightIdx, 0);
  setlength(FBoneWeights, 0);
  setlength(FLocalPoints, 0);
  FSkeletalDepth := 0;
  FDefaultAnimation := 0;
  FWeaponBoneIndex := 0;
  fillchar(FWeaponAdjust, sizeof(TUT_Struct_Coords), 0);
end;

procedure TUTObjectClassSkeletalMesh.InterpretObject;
var
  size, a: integer;
begin
  if FOwner.Version=80 then
    begin
      inherited;
      FOwner.read_idx(buffer); // 0x00 InternalVersion?
      size := FOwner.read_idx(buffer,utdmAsValue,'Points Array Size');
      setlength(FPoints, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FPoints[a] := Read_Struct_Vector(FOwner, buffer,'Points');
      size := FOwner.read_idx(buffer,utdmAsValue,'RefSkeleton Array Size');
      setlength(FRefSkeleton, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FRefSkeleton[a] := Read_Struct_MeshBone(FOwner, buffer,'RefSkeleton');
      FDefaultAnimation := FOwner.read_idx(buffer,utdmRefToObject,'DefaultAnimation');
      FSkeletalDepth := FOwner.read_dword(buffer,utdmAsValue,'SkeletalDepth');
      FOwner.read_dword(buffer,utdmUnknown,'MultiBlends?');
      size := FOwner.read_idx(buffer,utdmAsValue,'BoneWeights Array Size'); // Weights
      setlength(FBoneWeights, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FBoneWeights[a] := Read_Struct_BoneInfluence(FOwner, buffer,'BoneWeights');
      // TagAliases...
      size := FOwner.read_idx(buffer,utdmAsValue,'count');
      for a := 0 to size - 1 do
        Read_Struct_Vector(FOwner, buffer,'vector');
      // TagNames
      // TagCoords
      if True{InternalVersion>=2} then
        begin
          // LODModels
          // DefaultRefMesh
          // RawVerts
          // RawWedges
          // RawFaces
          // RawInfluences
          // RawCollapseWedges
          // RawFaceLevel
        end
      else
        begin
          // TArray<FLODMeshSection> SmoothSections;
          // TArray<FLODMeshSection> StaticSections;
          // Ar << SmoothSections;
          // Ar << StaticSections;
          // TArray<_WORD> CollapseRemap;
          // Ar << CollapseRemap;
        end;
      if FOwner.Version>=120 then
        begin
          // AuthenticationKey
        end;
    end
  else if (FOwner.Version<100{117}) then
    begin
      inherited;
      size := FOwner.read_idx(buffer,utdmAsValue,'ExtWedges Array Size');
      setlength(FExtWedges, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FExtWedges[a] := Read_Struct_MeshExtWedge(FOwner, buffer,'ExtWedges');
      size := FOwner.read_idx(buffer,utdmAsValue,'Points Array Size');
      setlength(FPoints, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FPoints[a] := Read_Struct_Vector(FOwner, buffer,'Points');
      size := FOwner.read_idx(buffer,utdmAsValue,'RefSkeleton Array Size');
      setlength(FRefSkeleton, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FRefSkeleton[a] := Read_Struct_MeshBone(FOwner, buffer,'RefSkeleton');
      size := FOwner.read_idx(buffer,utdmAsValue,'BoneWeightIdx Array Size');
      setlength(FBoneWeightIdx, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FBoneWeightIdx[a] := Read_Struct_BoneInfIndex(FOwner, buffer,'BoneWeightIdx');
      size := FOwner.read_idx(buffer,utdmAsValue,'BoneWeights Array Size');
      setlength(FBoneWeights, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FBoneWeights[a] := Read_Struct_BoneInfluence(FOwner, buffer,'BoneWeights');
      size := FOwner.read_idx(buffer,utdmAsValue,'LocalPoints Array Size');
      setlength(FLocalPoints, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FLocalPoints[a] := Read_Struct_Vector(FOwner, buffer,'LocalPoints');
      FSkeletalDepth := FOwner.read_dword(buffer,utdmAsValue,'SkeletalDepth');
      FDefaultAnimation := FOwner.read_idx(buffer,utdmRefToObject,'DefaultAnimation');
      FWeaponBoneIndex := FOwner.read_dword(buffer,utdmAsValue,'WeaponBoneIndex');
      FWeaponAdjust := Read_Struct_Coords(FOwner, buffer,'WeaponAdjust');
    end
  else
    begin
      // TODO : unknown SkeletalMesh format for UT2003
      raise EUnknownObjectFormat.create ('The new (UT2003) SkeletalMesh format is unknown.');
    end;
end;

procedure TUTObjectClassSkeletalMesh.PrepareExporter(exporter: TUT_MeshExporter; frames: TIntegerDynArray);
const
  material_colors: array[0..5] of TColor = (clBlue, clRed, clLime, clYellow, clAqua, clSilver);
var
  matname: string;
  m, o, n: integer;
begin
  check_initialized;
  {if length(frames) = 0 then
    begin}
      setlength(frames, 1);
      frames[0] := 0;
    //end;
  o:=exporter.AddObject;
  setlength(exporter.Objects[o].Materials, length(FMaterials));
  for m := 0 to high(FMaterials) do
    begin
      matname := 'SKIN' + inttostr(FMaterials[m].textureindex);
      if (FMaterials[m].flags and (PF_TwoSided or PF_Modulated)) = (PF_TwoSided or PF_Modulated) then
        matname := matname + '.MODU'    //LATED'
      else if (FMaterials[m].flags and (PF_TwoSided or PF_Translucent)) = (PF_TwoSided or PF_Translucent) then
        matname := matname + '.TRAN'    //SLUCENT'
      else if (FMaterials[m].flags and (PF_TwoSided or PF_Masked)) = (PF_TwoSided or PF_Masked) then
        matname := matname + '.MASK'    //ED'
      else if (FMaterials[m].flags and PF_TwoSided) = PF_TwoSided then
        matname := matname + '.TWOS'    //IDED'
      else if (FMaterials[m].flags and PF_NotSolid) = PF_NotSolid then
        matname := 'WEAPON';
      matname := copy(matname, 1, 10);
      exporter.Objects[o].Materials[m].name := matname;
      exporter.Objects[o].Materials[m].Texture:=FOwner.GetObjectPath(-1,FTextures[FMaterials[m].TextureIndex].Value);
      if m <= high(material_colors) then
        begin
          exporter.Objects[o].Materials[m].diffusecolor[0] := material_colors[m] and $FF;
          exporter.Objects[o].Materials[m].diffusecolor[1] := (material_colors[m] shr 8) and $FF;
          exporter.Objects[o].Materials[m].diffusecolor[2] := (material_colors[m] shr 16) and $FF;
        end
      else
        begin
          exporter.Objects[o].Materials[m].diffusecolor[0] := random(256);
          exporter.Objects[o].Materials[m].diffusecolor[1] := random(256);
          exporter.Objects[o].Materials[m].diffusecolor[2] := random(256);
        end;
    end;
  setlength(exporter.Objects[o].Vertices, length(FWedges) * length(frames));
  exporter.Objects[o].AnimationFrames := 1;
  for m := 0 to high(FWedges) do
    begin
      with exporter.Objects[o].Vertices[m] do
        begin
          n:=FSpecialVerts + FWedges[m].VertexIndex;
          if length(FRemapAnimVerts)<>0 then n:=FRemapAnimVerts[n];
          x := FPoints[n].X;
          y := FPoints[n].Y;
          z := FPoints[n].Z;
          U := FWedges[m].U;
          V := FWedges[m].V;
        end;
    end;
  setlength(exporter.Objects[o].Faces, length(FFaces));
  for m := 0 to high(FFaces) do
    begin
      with exporter.Objects[o].Faces[m] do
        begin
          VertexIndex1 := FFaces[m].WedgeIndex1;
          VertexIndex2 := FFaces[m].WedgeIndex2;
          VertexIndex3 := FFaces[m].WedgeIndex3;
          MaterialIndex := FFaces[m].MatIndex;
          Flags := FMaterials[FFaces[m].MatIndex].Flags;
        end;
    end;
end;

procedure TUTObjectClassSkeletalMesh.Save_Unreal3D(filename: string);
var
  exporter: TUT_Unreal3DExporter;
  frames: TIntegerDynArray;
begin
  check_initialized;
  exporter := TUT_Unreal3DExporter.create;
  setlength(frames, 1);
  frames[0] := 0;
  PrepareExporter(exporter, frames);
  exporter.CoordsDivisor := 4;
  exporter.Save(filename);
  exporter.free;
end;

procedure TUTObjectClassSkeletalMesh.Save_UnrealUC(filename: string);
var
  parent_class, basename, uc: string;
  k: char;
  a, script_idx: integer;
  ed2: TUTExportTableObjectData;
  id: TUTImportTableObjectData;
  str_uc: tfilestream;
begin
  check_initialized;
  a := FOwner.FindObject(utolExports, [utfwName, utfwClass, utfwGroup], '', UTobjectname, '');
  if a <> -1 then
    begin
      ed2 := FOwner.Exported[a];
      ed2.UTObject.ReadObject;
      parent_class := FOwner.GetObjectPath(1, TUTObjectClassClass(ed2.UTObject).SuperField);
      script_idx := TUTObjectClassClass(ed2.UTObject).ScriptText - 1;
      ed2.UTObject.ReleaseObject;
    end
  else
    begin
      parent_class := 'TournamentPlayer'; // do not localize these strings
      script_idx := FOwner.FindObject(utolExports, [utfwName, utfwClass, utfwGroup],
          UTobjectname, 'ScriptText', 'TextBuffer');
    end;
  if script_idx <> -1 then
    begin
      ed2 := FOwner.Exported[script_idx];
      ed2.UTObject.ReadObject;
      TUTObjectClassTextBuffer(ed2.UTObject).SaveToFile(filename);
      ed2.UTObject.ReleaseObject;
    end
  else
    begin
      k := DecimalSeparator;
      decimalSeparator := '.';
      basename := UTobjectname;
      // do not localize
      uc := '//============================================================================='#13#10;
      uc := uc + format('// %s.'#13#10, [basename]);
      uc := uc + '//============================================================================='#13#10;
      uc := uc + format('class %s extends %s;'#13#10#13#10, [basename, parent_class]);
      if DefaultAnimation > 0 then
        begin
          uc := uc + format('#exec ANIM IMPORT ANIM=%s ANIMFILE=MODELS\%s.PSA'
            {+' COMPRESS=x IMPORTSEQS=x MAXKEYS=x'}+ #13#10,
            [FOwner.GetObjectPath(1, FDefaultAnimation), FOwner.GetObjectPath(1, FDefaultAnimation)]);
          uc := uc + #13#10;
        end;
      uc := uc + format('#exec MESH MODELIMPORT MESH=%s MODELFILE=MODELS\%s.PSK'
        {+' LODSTYLE=x X=x Y=x Z=x'}+ #13#10, [basename, basename]);
      {uc := uc + format('#exec MESH LODPARAMS MESH=%s HYSTERESIS=%f STRENGTH=%f MINVERTS=%f MORPH=%f ZDISP=%f'#13#10,
        [basename, FLODHysteresis, FLODStrength, FLODMinVerts, FLODMorph, FLODZDisplace]);}
      uc := uc + format('#exec MESH ORIGIN MESH=%s X=%f Y=%f Z=%f YAW=%f ROLL=%f PITCH=%f'#13#10#13#10,
        [basename, FOrigin.x, FOrigin.y, FOrigin.z,
        FRotorigin.Yaw / 256, FRotOrigin.Roll / 256, FRotOrigin.Pitch / 256]);
      uc := uc + format('#exec MESH WEAPONATTACH MESH=%s BONE="%s"'#13#10,
        [basename, FOwner.Names[RefSkeleton[WeaponBoneIndex].name]]);
      uc := uc + format('#exec MESH WEAPONPOSITION MESH=%s YAW=%f PITCH=%f ROLL=%f X=%f Y=%f Z=%f'#13#10, [basename,
        0.0, 0.0, 0.0, // TODO : get this from weaponadjust.Xaxis, Yaxis and Zaxis (but with some calculation)
        weaponadjust.origin.x, weaponadjust.origin.y, weaponadjust.origin.z]);
      uc := uc + #13#10;
      for a := 0 to high(FTextures) do
        if FTextures[a].value > 0 then
          begin
            ed2 := FOwner.Exported[FTextures[a].value - 1];
            uc := uc + format('#exec TEXTURE IMPORT NAME=%s FILE=%s.PCX GROUP=%s'#13#10,
              [ed2.UTobjectname, ed2.UTobjectname, ed2.UTgroupname]);
            // TODO : TUTObjectClassSkeletalMesh.Save_UnrealUC : FLAGS=%d should put correct flags...
          end
        else if FTextures[a].value < 0 then
          begin
            id := FOwner.Imported[-FTextures[a].value - 1];
            uc := uc + format('#exec OBJ LOAD FILE=%s.utx PACKAGE=%s'#13#10, [id.UTobjectname, id.UTpackagename]);
          end;
      uc := uc + #13#10;
      for a := 0 to high(FTextures) do
        if FTextures[a].value > 0 then
          begin
            ed2 := FOwner.Exported[FTextures[a].value - 1];
            uc := uc + format('#exec MESHMAP SETTEXTURE MESHMAP=%s NUM=%d TEXTURE=%s'#13#10,
              [basename, a, ed2.UTobjectname]);
          end
        else if FTextures[a].value < 0 then
          begin
            id := FOwner.Imported[-FTextures[a].value - 1];
            uc := uc + format('#exec MESHMAP SETTEXTURE MESHMAP=%s NUM=%d TEXTURE=%s'#13#10,
              [basename, a, id.UTpackagename + '.' + id.UTobjectname]);
          end;
      uc := uc + #13#10;
      //uc:=uc+format('#exec MESHMAP NEW   MESHMAP=%s MESH=%s'#13#10,[basename,basename]);
      if (FScale.x <> 0.1) or (FScale.y <> 0.1) or (FScale.z <> 0.2) then
        uc := uc + format('#exec MESHMAP SCALE MESHMAP=%s X=%f Y=%f Z=%f'#13#10#13#10,
          [basename, FScale.x, FScale.y, FScale.z]);
      // FScale is incorrect, sometimes is 0 and it shouldnt be.

      uc := uc + format('#exec MESH DEFAULTANIM MESH=%s ANIM=%s'#13#10,
        [basename, FOwner.GetObjectPath(1, FDefaultAnimation)]);
      uc := uc + #13#10;
      if DefaultAnimation > 0 then
        begin
          uc := uc + '// Animation sequences not generated.'#13#10;
          //#exec ANIM SEQUENCE ANIM=SkeletalAnimation1 SEQ=All STARTFRAME=0 NUMFRAMES=25 RATE=0.2 GROUP=Default
          uc := uc + #13#10;
          uc := uc + format('#exec ANIM DIGEST ANIM=%s VERBOSE'#13#10,
            [FOwner.GetObjectPath(1, FDefaultAnimation)]);
          uc := uc + #13#10;
          uc := uc + '// Animation notifications not generated.'#13#10;
          //#exec ANIM NOTIFY ANIM=RiotAnim SEQ=RunLG TIME=0.25 FUNCTION=PlayFootStep
          uc := uc + #13#10;
        end;
      (*uc:=uc+#13#10+
      'defaultproperties'#13#10+
      '{'#13#10+
      '    DrawType=DT_Mesh'#13#10+
      format('    Mesh=%s'#13#10,[basename])+
      '}'#13#10;*)
      DecimalSeparator := k;
      str_uc := tfilestream.create(filename, fmCreate);
      try
        str_uc.write(uc[1], length(uc));
      finally
        str_uc.free;
      end;
    end;
end;

{ TUT_3DStudioExporter }

procedure TUT_3DStudioExporter.Save(filename: string);
type
  P3DSChunk = ^T3DSChunk;
  T3DSChunk = packed record
    tag: word;
    size: DWORD;
    datasize: DWORD;
    data: pointer;
    subchunks: tlist;
  end;
var
  str: tfilestream;
  f, m, m2, n,vpf, o: integer;
  dummy: byte;
  matname, meshname: string;
  p: pointer;
  facelist: array of word;
  rootchunk, mdatachunk, matentrychunk, namedobjectchunk, ntriobjectchunk,
    faceschunk, diffusechunk, {kfdatachunk, objectnodetagchunk, } mapchunk, x: P3DSChunk;
  function new_chunk(tag: word; datasize: DWORD; hasvalue: boolean; var
    value): P3DSChunk;
  begin
    new(result);
    result^.tag := tag;
    result^.size := 0;
    result^.datasize := datasize;
    if datasize > 0 then
      begin
        getmem(result^.data, datasize);
        if hasvalue then
          move(value, result^.data^, datasize);
      end
    else
      result^.data := nil;
    result^.subchunks := tlist.create;
  end;
  procedure calculate_chunk_size(chunk: P3DSChunk);
  var
    a: integer;
  begin
    chunk.size := sizeof(word) + sizeof(DWORD) + chunk.datasize;
    for a := 0 to chunk.subchunks.count - 1 do
      begin
        calculate_chunk_size(chunk.subchunks[a]);
        inc(chunk.size, P3DSChunk(chunk.subchunks[a]).size);
      end;
  end;
  procedure save_chunk(str: tstream; chunk: P3DSChunk);
  var
    a: integer;
  begin
    str.Write(chunk.tag, sizeof(word));
    str.write(chunk.size, sizeof(DWORD));
    if chunk.data <> nil then
      str.write(chunk.data^, chunk.datasize);
    for a := 0 to chunk.subchunks.count - 1 do
      save_chunk(str, chunk.subchunks[a]);
  end;
  procedure free_chunk(chunk: P3DSChunk);
  var
    a: integer;
  begin
    if chunk.data <> nil then
      freemem(chunk.data, chunk.datasize);
    for a := chunk.subchunks.count - 1 downto 0 do
      free_chunk(chunk.subchunks[a]);
    chunk.subchunks.free;
    dispose(chunk);
  end;
  function put_integer(p: pointer; v: integer): pointer;
  begin
    move(v, p^, sizeof(integer));
    result := pointer(integer(p) + sizeof(integer));
  end;
  function put_single(p: pointer; v: single): pointer;
  begin
    move(v, p^, sizeof(single));
    result := pointer(integer(p) + sizeof(single));
  end;
  function put_smallint(p: pointer; v: smallint): pointer;
  begin
    move(v, p^, sizeof(smallint));
    result := pointer(integer(p) + sizeof(smallint));
  end;
  function put_word(p: pointer; v: word): pointer;
  begin
    move(v, p^, sizeof(word));
    result := pointer(integer(p) + sizeof(word));
  end;
  function put_string(p: pointer; v: string): pointer;
  begin
    move(v[1], p^, length(v) + 1);
    result := pointer(integer(p) + length(v) + 1);
  end;
begin

  // UT coordinate system is:
  //    Positive X to the left
  //    Positive Y is forward
  //    Positive Z is up

  // Generate chunk tree
  // main chunk
  rootchunk := new_chunk(M3DMAGIC, 0, false, dummy);
  try
    x := new_chunk(M3D_VERSION, sizeof(DWORD), false, dummy);
    put_integer(x.data, 3);
    rootchunk.subchunks.add(x);
    // mesh data chunk
    x := new_chunk(MDATA, 0, false, dummy);
    rootchunk.subchunks.add(x);
    mdatachunk := x;
    // mesh version chunk
    x := new_chunk(MESH_VERSION, sizeof(integer), false, dummy);
    put_integer(x.data, 3);
    mdatachunk.subchunks.add(x);

    // TODO : should do material reusing between objects when possible
    for o := 0 to high(Objects) do
      for m := 0 to high(Objects[o].Materials) do
        begin
          // material chunk
          x := new_chunk(MAT_ENTRY, 0, false, dummy);
          mdatachunk.subchunks.add(x);
          matentrychunk := x;
          matname := copy(Objects[o].Materials[m].name, 1, 4)+format('%-4.4x%-2.2x',[o,m]);
          // material name chunk
          x := new_chunk(MAT_NAME, length(matname) + 1, true, matname[1]);
          matentrychunk.subchunks.add(x);
          // TODO : must add support for material flags in parameters
          // material diffuse color chunk
          x := new_chunk(MAT_DIFFUSE, 0, false, dummy);
          matentrychunk.subchunks.add(x);
          diffusechunk := x;
          x := new_chunk(COLOR_24, 3, true, Objects[o].Materials[m].DiffuseColor[0]);
          diffusechunk.subchunks.add(x);
          // material texture name
          if Objects[o].Materials[m].Texture<>'' then
            begin
              x := new_chunk(MAT_TEXMAP, 0, false, dummy);
              matentrychunk.subchunks.add(x);
              mapchunk := x;
              x := new_chunk(MAT_MAPNAME, length(Objects[o].Materials[m].Texture)+1, true, Objects[o].Materials[m].Texture[1]);
              mapchunk.subchunks.add(x);
              // TODO : MAT_MAP_UOFFSET, MAT_MAP_VOFFSET ?
            end;
        end;

    for o:=0 to high(Objects) do
      for f:=0 to Objects[o].AnimationFrames-1 do
        begin
          // mesh chunk
          meshname := format('OBJ%-4.4x%-3.3d',[o,f]);
          x := new_chunk(NAMED_OBJECT, length(meshname) + 1, true, meshname[1]);
          mdatachunk.subchunks.add(x);
          namedobjectchunk := x;
          // triangles chunk
          x := new_chunk(N_TRI_OBJECT, 0, false, dummy);
          namedobjectchunk.subchunks.add(x);
          ntriobjectchunk := x;
          // vertices chunk
          vpf:=length(Objects[o].Vertices) div Objects[o].AnimationFrames;
          x := new_chunk(POINT_ARRAY, sizeof(word) + vpf * sizeof(single) * 3, false, dummy);
          p := put_word(x.data, vpf);
          for m := 0 to vpf-1 do
            begin
              if mirrorx then // Unreal X is the reversed
                p := put_single(p, Objects[o].Vertices[vpf*f+m].X)
              else
                p := put_single(p, -Objects[o].Vertices[vpf*f+m].X);
              p := put_single(p, Objects[o].Vertices[vpf*f+m].Y);
              p := put_single(p, Objects[o].Vertices[vpf*f+m].Z);
            end;
          ntriobjectchunk.subchunks.add(x);
          // texture coordinates chunk
          x := new_chunk(TEX_VERTS, sizeof(word) + vpf * sizeof(single) * 2, false, dummy);
          p := put_word(x.data, vpf);
          for m := 0 to vpf-1 do
            begin
              p := put_single(p, Objects[o].Vertices[vpf*f+m].U / 255);
              p := put_single(p, 1 - (Objects[o].Vertices[vpf*f+m].V / 255)); // reversed
            end;
          ntriobjectchunk.subchunks.add(x);
          // TODO : MESH_MATRIX chunk (not needed!?)
          // faces chunk
          x := new_chunk(FACE_ARRAY, sizeof(word) + length(Objects[o].Faces) * sizeof(word) * 4, false, dummy);
          p := put_word(x.data, length(Objects[o].Faces));
          for m := 0 to high(Objects[o].Faces) do
            begin
              if mirrorX then // winding should be reversed to account for reversed X
                begin
                  p := put_word(p, Objects[o].Faces[m].VertexIndex1);
                  p := put_word(p, Objects[o].Faces[m].VertexIndex2);
                  p := put_word(p, Objects[o].Faces[m].VertexIndex3);
                end
              else
                begin                         // change vertex winding
                  p := put_word(p, Objects[o].Faces[m].VertexIndex3);
                  p := put_word(p, Objects[o].Faces[m].VertexIndex2);
                  p := put_word(p, Objects[o].Faces[m].VertexIndex1);
                end;
              p := put_word(p, FaceCAVisable3DS or FaceBCVisable3DS or FaceABVisable3DS);
            end;
          ntriobjectchunk.subchunks.add(x);
          faceschunk := x;

          for m := 0 to high(Objects[o].Materials) do
            begin
              // face<->material chunk
              setlength(facelist, length(Objects[o].Faces));
              n := 0;
              for m2 := 0 to high(Objects[o].Faces) do
                begin
                  if Objects[o].Faces[m2].MaterialIndex = m then
                    begin
                      facelist[n] := m2;
                      inc(n);
                    end;
                end;
              setlength(facelist, n);
              if n > 0 then
                begin
                  matname := copy(Objects[o].Materials[m].name, 1, 4)+format('%-4.4x%-2.2x',[o,m]);
                  x := new_chunk(MSH_MAT_GROUP, length(matname) + 1 + sizeof(word) + length(facelist) * sizeof(word), false, dummy);
                  p := put_string(x.data, matname);
                  p := put_word(p, length(facelist));
                  for m2 := 0 to high(facelist) do
                    p := put_word(p, facelist[m2]);
                  faceschunk.subchunks.add(x);
                end;
            end;
          case smoothing of
            exp3ds_smooth_None: ;             // no smoothing groups
            exp3ds_smooth_One:
              begin                           // one smoothing group for all faces
                // Smooth Group chunk
                x := new_chunk(SMOOTH_GROUP, length(Objects[o].Faces) * sizeof(DWORD), false, dummy);
                p := x.data;
                for m := 0 to high(Objects[o].Faces) do
                  p := put_integer(p, 1);
                faceschunk.subchunks.add(x);
              end;
            exp3ds_smooth_exp3ds_smooth_ByMaterial:
              begin                           // one smoothing group for each material
                // Smooth Group chunk
                x := new_chunk(SMOOTH_GROUP, length(Objects[o].Faces) * sizeof(DWORD), false, dummy);
                p := x.data;
                for m := 0 to high(Objects[o].Faces) do
                  p := put_integer(p, 1 shl Objects[o].Faces[m].MaterialIndex);
                // one bit for each material
                faceschunk.subchunks.add(x);
              end;
          end;
        end;

    // keyframes chunk
      (*x := new_chunk(KFDATA, 0, false, dummy);
      rootchunk.subchunks.add(x);
      kfdatachunk := x;
      // keyframes header chunk
      name := 'MAXSCENE';
      x := new_chunk(KFHDR, sizeof(smallint) + length(name) + 1 + sizeof(integer), false, dummy);
      p := put_smallint(x.data, 5);
      p := put_string(p, name);
      {if allframes then
         put_integer(p, FAnimFrames)
      else}
      put_integer(p, 1);
      kfdatachunk.subchunks.add(x);
      // keyframes segments chunk
      x := new_chunk(KFSEG, sizeof(integer) + sizeof(integer), false, dummy);
      p := put_integer(x.data, 0);
      {if allframes then
         put_integer(p, FAnimFrames)
      else}
      put_integer(p, 1);
      kfdatachunk.subchunks.add(x);

      for frame := 0 to FAnimFrames - 1 do
        begin
          // keyframes current time chunk
          x := new_chunk(KFCURTIME, sizeof(integer), false, dummy);
          put_integer(x.data, frame);
          kfdatachunk.subchunks.add(x);
          // object node chunk
          x := new_chunk(OBJECT_NODE_TAG, 0, false, dummy);
          kfdatachunk.subchunks.add(x);
          objectnodetagchunk := x;
          // node id chunk
          x := new_chunk(NODE_ID, sizeof(smallint), false, dummy);
          put_smallint(x.data, frame);
          objectnodetagchunk.subchunks.add(x);
          // node header chunk
          meshname := extractfilename(filename);
          meshname:=copy(meshname,1,7);
          if allframes then meshname := meshname + format('%-3.3d', [frame]);
          x := new_chunk(NODE_HDR, length(meshname) + 1 + sizeof(word) + sizeof(word) + sizeof(smallint), false, dummy);
          p := put_string(x.data, meshname); // Mesh object
          p := put_word(p, $4000); // flags1=PRIMARY_NODE
          p := put_word(p, 0);     // flags2
          put_smallint(p, -1);     // Parent=No Parent
          objectnodetagchunk.subchunks.add(x);

          {
          // PIVOT chunk
          x := new_chunk(PIVOT, 3 * sizeof(single), false, dummy);
          p := put_single(x.data, 0);
          p := put_single(p, 0);
          put_single(p, 0);
          objectnodetagchunk.subchunks.add(x);
          // POS_TRACK_TAG chunk
          x := new_chunk(POS_TRACK_TAG, sizeof(word) + 3 * sizeof(integer) + 1 * (sizeof(integer) + sizeof(word) + 3 * sizeof(single)), false, dummy);
          p := put_word(x.data, 0);         // flags
          p := put_integer(p, 0);           // nu1
          p := put_integer(p, 0);           // nu2
          p := put_integer(p, 1);           // keycount
          // key 0
          p := put_integer(p, 0);           // time
          p := put_word(p, 0);              // rflags
          p := put_single(p, 0);            // point.X
          p := put_single(p, 0);            // point.Y
          put_single(p, 0);                 // point.Z
          objectnodetagchunk.subchunks.add(x);
          // ROT_TRACK_TAG chunk
          x := new_chunk(ROT_TRACK_TAG, sizeof(word) + 3 * sizeof(integer) + 1 * (sizeof(integer) + sizeof(word) + 4 * sizeof(single)), false, dummy);
          p := put_word(x.data, 0);         // flags
          p := put_integer(p, 0);           // nu1
          p := put_integer(p, 0);           // nu2
          p := put_integer(p, 1);           // keycount
          // key 0
          p := put_integer(p, 0);           // time
          p := put_word(p, 0);              // rflags
          p := put_single(p, 0);            // Angle
          p := put_single(p, 0);            // Axis.X
          p := put_single(p, 1);            // Axis.Y
          put_single(p, 0);                 // Axis.Z
          objectnodetagchunk.subchunks.add(x);
          // SCL_TRACK_TAG chunk
          x := new_chunk(SCL_TRACK_TAG, sizeof(word) + 3 * sizeof(integer) + 1 * (sizeof(integer) + sizeof(word) + 3 * sizeof(single)), false, dummy);
          p := put_word(x.data, 0);         // flags
          p := put_integer(p, 0);           // nu1
          p := put_integer(p, 0);           // nu2
          p := put_integer(p, 1);           // keycount
          // key 0
          p := put_integer(p, 0);           // time
          p := put_word(p, 0);              // rflags
          p := put_single(p, 1);            // scale.X
          p := put_single(p, 1);            // scale.Y
          put_single(p, 1);                 // scale.Z
          objectnodetagchunk.subchunks.add(x);
          }
          if not allframes then break;
        end;
      *)

      // calculate chunk sizes
    calculate_chunk_size(rootchunk);
    // Save chunk tree
    if lowercase(extractfileext(filename))<>'.3ds' then filename:=filename+'.3DS';
    str := tfilestream.create(filename, fmCreate);
    try
      save_chunk(str, rootchunk);
    finally
      str.free;
    end;
  finally
    // free chunks
    free_chunk(rootchunk);
  end;
end;

{ TUT_Unreal3DExporter }

procedure TUT_Unreal3DExporter.Save(filename: string);
var
  a, xyz, o,n,aa: integer;
  xx, yy, zz: single;
  data: word;
  str_d, str_a: tfilestream;
  // From 3DS2UNR
  _3D_dHeader: packed record
    NumPolygons: word;
    NumVertices: word;
    BogusRot: word;
    BogusFrame: word;
    BogusNormX: DWORD;
    BogusNormY: DWORD;
    BogusNormZ: DWORD;
    FixScale: DWORD;
    Unused: array[0..2] of DWORD;
    Unknown: array[0..11] of char;
  end;
  _3D_dPolygon: packed record
    mVertex: array[0..2] of word;       // Vertex indices.
    mType: byte;                        // James' mesh type.
    mColor: byte;                       // Color for flat and Gouraud shaded.
    mTex: array[0..2, 0..1] of byte;    // Texture UV coordinates.
    mTextureNum: byte;                  // Source texture offset.
    mFlags: byte;                       // Unreal mesh flags (currently unused).
  end;
begin
  if coordsdivisor < 1 then
    coordsdivisor := 1;
  filename := changefileext(filename, '');

  if not AllObjectsSameFrames then raise exception.create ('All objects must have the same number of frames to export in Unreal3D format.');

  // Create file _d.3d
  fillchar(_3D_dHeader, sizeof(_3D_dHeader), 0);
  with _3D_dHeader do
    begin
      NumPolygons:=0;
      NumVertices:=0;
      for o:=0 to high(Objects) do
        begin
          NumPolygons := NumPolygons + length(Objects[o].Faces);
          NumVertices := NumVertices + length(Objects[o].Vertices) div Objects[o].AnimationFrames;
        end;
    end;
  str_d := tfilestream.create(filename + '_d.3d', fmCreate);
  try
    str_d.Write(_3D_dHeader, sizeof(_3D_dHeader));
    for o := 0 to high(Objects) do
      for a := 0 to high(Objects[o].Faces) do
        begin
          fillchar(_3D_dPolygon, sizeof(_3D_dPolygon), 0);
          _3D_dPolygon.mVertex[0] := Objects[o].Faces[a].vertexindex1;
          _3D_dPolygon.mVertex[1] := Objects[o].Faces[a].vertexindex2;
          _3D_dPolygon.mVertex[2] := Objects[o].Faces[a].vertexindex3;
          if (Objects[o].Faces[a].flags and PF_NotSolid) = PF_NotSolid then
            _3D_dPolygon.mType := 8       // Weapon
          else if (Objects[o].Faces[a].flags and (PF_TwoSided or PF_Modulated)) = (PF_TwoSided or PF_Modulated) then
            _3D_dPolygon.mType := 4       // MODULATED 2-Sided
          else if (Objects[o].Faces[a].flags and (PF_TwoSided or PF_Translucent)) = (PF_TwoSided or PF_Translucent) then
            _3D_dPolygon.mType := 3       // TRANSLUCENT 2-Sided
          else if (Objects[o].Faces[a].flags and (PF_TwoSided or PF_Masked)) = (PF_TwoSided or PF_Masked) then
            _3D_dPolygon.mType := 2       // MASKED 2-Sided
          else if (Objects[o].Faces[a].flags and PF_TwoSided) <> 0 then
            _3D_dPolygon.mType := 1       // 2-Sided
          else
            _3D_dPolygon.mType := 0;
          if (Objects[o].Faces[a].flags and PF_Unlit) <> 0 then
            _3D_dPolygon.mType := _3D_dPolygon.mType or $10;
          if (Objects[o].Faces[a].flags and PF_Flat) <> 0 then
            _3D_dPolygon.mType := _3D_dPolygon.mType or $20;
          if (Objects[o].Faces[a].flags and PF_Environment) <> 0 then
            _3D_dPolygon.mType := _3D_dPolygon.mType or $40;
          if (Objects[o].Faces[a].flags and PF_NoSmooth) <> 0 then
            _3D_dPolygon.mType := _3D_dPolygon.mType or $80;
          _3D_dPolygon.mTextureNum := Objects[o].Faces[a].MaterialIndex;
          _3D_dPolygon.mTex[0, 0] := Objects[o].Vertices[Objects[o].Faces[a].vertexindex1].U;
          _3D_dPolygon.mTex[0, 1] := Objects[o].Vertices[Objects[o].Faces[a].vertexindex1].V;
          _3D_dPolygon.mTex[1, 0] := Objects[o].Vertices[Objects[o].Faces[a].vertexindex2].U;
          _3D_dPolygon.mTex[1, 1] := Objects[o].Vertices[Objects[o].Faces[a].vertexindex2].V;
          _3D_dPolygon.mTex[2, 0] := Objects[o].Vertices[Objects[o].Faces[a].vertexindex3].U;
          _3D_dPolygon.mTex[2, 1] := Objects[o].Vertices[Objects[o].Faces[a].vertexindex3].V;
          str_d.write(_3D_dPolygon, sizeof(_3D_dPolygon));
        end;
  finally
    str_d.free;
  end;

  // Create file _a.3d
  str_a := tfilestream.create(filename + '_a.3d', fmCreate);
  try
    data := Objects[0].AnimationFrames;
    str_a.Write(data, sizeof(data));
    data := _3D_dHeader.NumVertices*4;
    str_a.write(data, sizeof(data));
    for n:= 0 to Objects[0].AnimationFrames-1 do
      for o:=0 to high(Objects) do
        for a := 0 to (high(Objects[o].Vertices) div Objects[0].AnimationFrames)-1 do
          begin
            aa:=n*(high(Objects[o].Vertices) div Objects[0].AnimationFrames)+a;
            xx := Objects[o].Vertices[aa].x / CoordsDivisor;
            yy := Objects[o].Vertices[aa].y / CoordsDivisor;
            zz := Objects[o].Vertices[aa].z / CoordsDivisor;
            xyz := (trunc(xx * 8) and $7FF) or
              ((trunc(yy * 8) and $7FF) shl 11) or
              ((trunc(zz * 4) and $3FF) shl 22);
            str_a.Write(xyz, 4);
          end;
  finally
    str_a.free;
  end;
end;

{ TUTImportTableObjectData }

function TUTImportTableObjectData.Get_ClassName: string;
begin
  result := FOwner.names[UTClassIndex];
end;

function TUTImportTableObjectData.GetClassPackageName: string;
begin
  result := FOwner.names[UTClassPackageIndex];
end;

function TUTImportTableObjectData.GetObjectName: string;
begin
  result := FOwner.names[UTObjectIndex];
end;

function TUTImportTableObjectData.GetPackageName: string;
begin
  result := FOwner.GetObjectPath(-1, UTPackageIndex);
end;

procedure TUTImportTableObjectData.SetClassIndex(const Value: integer);
begin
  FClassIndex := Value;
end;

procedure TUTImportTableObjectData.SetClassPackageIndex(const Value: integer);
begin
  FClassPackageIndex := Value;
end;

procedure TUTImportTableObjectData.SetObjectIndex(const Value: integer);
begin
  FObjectIndex := Value;
end;

procedure TUTImportTableObjectData.SetPackageIndex(const Value: integer);
begin
  FPackageIndex := Value;
end;

{ TUTExportTableObjectData }

procedure TUTExportTableObjectData.CreateObject;
begin
  if FUTObject = nil then
    FUTObject := GetUTObjectClass(UTclassname).create(FOwner, FExportedIndex);
end;

destructor TUTExportTableObjectData.Destroy;
begin
  FreeObject;
end;

procedure TUTExportTableObjectData.FreeObject;
begin
  FreeAndNil(FUTObject);
end;

function TUTExportTableObjectData.Get_ClassName: string;
begin
  result := FOwner.GetObjectPath(1, UTClassIndex);
end;

function TUTExportTableObjectData.GetObjectName: string;
begin
  result := FOwner.names[UTObjectIndex];
end;

function TUTExportTableObjectData.GetGroupName: string;
begin
  result := FOwner.GetObjectPath(-1, UTGroupIndex);
end;

function TUTExportTableObjectData.GetSuperName: string;
begin
  result := FOwner.GetObjectPath(-1, UTSuperIndex);
end;

function TUTExportTableObjectData.GetUTObject: TUTObject;
begin
  CreateObject;
  result := FUTObject;
end;

procedure TUTExportTableObjectData.SetClassIndex(const Value: integer);
begin
  FClassIndex := Value;
end;

procedure TUTExportTableObjectData.SetFlags(const Value: integer);
begin
  FFlags := Value;
end;

procedure TUTExportTableObjectData.SetObjectIndex(const Value: integer);
begin
  FObjectIndex := Value;
end;

procedure TUTExportTableObjectData.SetGroupIndex(const Value: integer);
begin
  FGroupIndex := Value;
end;

procedure TUTExportTableObjectData.SetSerialOffset(const Value: integer);
begin
  FSerialOffset := Value;
end;

procedure TUTExportTableObjectData.SetSerialSize(const Value: integer);
begin
  FSerialSize := Value;
end;

procedure TUTExportTableObjectData.SetSuperIndex(const Value: integer);
begin
  FSuperIndex := Value;
end;

procedure TUTExportTableObjectData.SetUTObject(const Value: TUTObject);
begin
  FUTObject := Value;
end;

{ TUTObjectClassAnimation }

function TUTObjectClassAnimation.GetAnimSeqs(i: integer): TUT_Struct_AnimSeq;
begin
  check_initialized;
  result := FAnimSeqs[i];
end;

function TUTObjectClassAnimation.GetAnimSeqsCount: integer;
begin
  check_initialized;
  result := length(FAnimSeqs);
end;

function TUTObjectClassAnimation.GetMoves(i: integer): TUT_Struct_MotionChunk;
begin
  check_initialized;
  result := FMoves[i];
end;

function TUTObjectClassAnimation.GetMovesCount: integer;
begin
  check_initialized;
  result := length(FMoves);
end;

function TUTObjectClassAnimation.GetRefBones(i: integer): TUT_Struct_NamedBone;
begin
  check_initialized;
  result := FRefBones[i];
end;

function TUTObjectClassAnimation.GetRefBonesCount: integer;
begin
  check_initialized;
  result := length(FRefBones);
end;

procedure TUTObjectClassAnimation.InitializeObject;
begin
  inherited;
  setlength(FRefBones, 0);
  setlength(FMoves, 0);
  setlength(FAnimSeqs, 0);
end;

procedure TUTObjectClassAnimation.InterpretObject;
var
  size, a: integer;
begin
  inherited;
  size := FOwner.read_idx(buffer,utdmAsValue,'RefBones Array Size');
  setlength(FRefBones, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FRefBones[a] := Read_Struct_NamedBone(FOwner, buffer,'RefBones');
  size := FOwner.read_idx(buffer,utdmAsValue,'Moves Array Size');
  setlength(FMoves, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FMoves[a] := Read_Struct_MotionChunk(FOwner, buffer,'Moves');
  size := FOwner.read_idx(buffer,utdmAsValue,'AnimSeqs Array Size');
  setlength(Fanimseqs, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FAnimSeqs[a] := Read_Struct_AnimSeq(FOwner, buffer,'AnomSeqs');
end;

{ TUTObjectClassModel }

function TUTObjectClassModel.GetBound(n: integer): TUT_Struct_BoundingBox;
begin
  result := FBounds[n];
end;

function TUTObjectClassModel.GetBoundCount: integer;
begin
  result := length(FBounds);
end;

function TUTObjectClassModel.GetLeaf(n: integer): TUT_Struct_Leaf;
begin
  result := FLeaves[n];
end;

function TUTObjectClassModel.GetLeafCount: integer;
begin
  result := length(FLeaves);
end;

function TUTObjectClassModel.GetLeafHull(n: integer): integer;
begin
  result := FLeafHulls[n];
end;

function TUTObjectClassModel.GetLeafHullCount: integer;
begin
  result := length(FLeafHulls);
end;

function TUTObjectClassModel.GetLight(n: integer): integer;
begin
  result := FLights[n];
end;

function TUTObjectClassModel.GetLightBit(n: integer): byte;
begin
  result := FLightBits[n];
end;

function TUTObjectClassModel.GetLightBitCount: integer;
begin
  result := length(FLightBits);
end;

function TUTObjectClassModel.GetLightCount: integer;
begin
  result := length(FLights);
end;

function TUTObjectClassModel.GetLightMap(n: integer): TUT_Struct_LightMapIndex;
begin
  result := FLightMap[n];
end;

function TUTObjectClassModel.GetLightMapCount: integer;
begin
  result := length(FLightMap);
end;

function TUTObjectClassModel.GetNode(n: integer): TUT_Struct_BspNode;
begin
  result := FNodes[n];
end;

function TUTObjectClassModel.GetNodeCount: integer;
begin
  result := length(FNodes);
end;

function TUTObjectClassModel.GetPoint(n: integer): TUT_Struct_Vector;
begin
  result := FPoints[n];
end;

function TUTObjectClassModel.GetPointCount: integer;
begin
  result := length(FPoints);
end;

function TUTObjectClassModel.GetSurf(n: integer): TUT_Struct_BspSurf;
begin
  result := FSurfs[n];
end;

function TUTObjectClassModel.GetSurfCount: integer;
begin
  result := length(FSurfs);
end;

function TUTObjectClassModel.GetVector(n: integer): TUT_Struct_Vector;
begin
  result := FVectors[n];
end;

function TUTObjectClassModel.GetVectorCount: integer;
begin
  result := length(FVectors);
end;

function TUTObjectClassModel.GetVert(n: integer): TUT_Struct_FVert;
begin
  result := FVerts[n];
end;

function TUTObjectClassModel.GetVertCount: integer;
begin
  result := length(FVerts);
end;

function TUTObjectClassModel.GetZone(
  n: integer): TUT_Struct_ZoneProperties;
begin
  result := FZones[n];
end;

procedure TUTObjectClassModel.InitializeObject;
begin
  inherited;
  setlength(FVectors, 0);
  setlength(FPoints, 0);
  setlength(FVerts, 0);
  setlength(FNodes, 0);
  setlength(FSurfs, 0);
  setlength(FLightMap, 0);
  setlength(FLightBits, 0);
  setlength(FBounds, 0);
  setlength(FLeafHulls, 0);
  setlength(FLeaves, 0);
  setlength(FLights, 0);
  FRootOutside := false;
  FLinked := false;
  FNumSharedSides := 0;
  FNumZones := 0;
  FPolys := 0;
  setlength(FZones, 0);
end;

procedure TUTObjectClassModel.InterpretObject;
var
  size, a: integer;
begin
  inherited;
  if (FOwner.GameHint=UTPGH_ArmyOperations) then
    FOwner.read_dword (buffer); // TODO : unknown dword
  if FOwner.Version > 61 then
    begin
      size := FOwner.read_idx(buffer,utdmAsValue,'Vectors Array Size');
      setlength(FVectors, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FVectors[a] := Read_Struct_Vector(FOwner, buffer,'Vectors');
      size := FOwner.read_idx(buffer,utdmAsValue,'Points Array Size');
      setlength(FPoints, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FPoints[a] := Read_Struct_Vector(FOwner, buffer,'Points');
      size := FOwner.read_idx(buffer,utdmAsValue,'Nodes Array Size');
      setlength(FNodes, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FNodes[a] := Read_Struct_BspNode(FOwner, buffer,'Nodes');
      size := FOwner.read_idx(buffer,utdmAsValue,'Surfs Array Size');
      setlength(FSurfs, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FSurfs[a] := Read_Struct_BspSurf(FOwner, buffer,'Surfs');
      size := FOwner.read_idx(buffer,utdmAsValue,'Verts Array Size');
      setlength(FVerts, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FVerts[a] := Read_Struct_FVert(FOwner, buffer,'Verts');
      FNumSharedSides := FOwner.read_dword(buffer,utdmAsValue,'NumSharedSides');
      FNumZones := Fowner.read_dword(buffer,utdmAsValue,'NumZones Array Size');
      setlength(FZones, CheckArrayLength(FNumZones));
      for a := 0 to FNumZones - 1 do
        FZones[a] := Read_Struct_Zone(FOwner, buffer,'Zones');
    end
  else
    begin
      // TODO : fill model version <=60
    end;
  FPolys := FOwner.read_idx(buffer,utdmRefToObject,'Polys');
  size := FOwner.read_idx(buffer,utdmAsValue,'LightMap Array Size');
  setlength(FLightMap, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FLightMap[a] := Read_Struct_LightMap(FOwner, buffer,'LightMap');
  { Version >=117 (UT2003)
    There seems to be a new array here with this format:
      BYTE
      WORD
      INDEX \
      WORD  / repeated until the index is 0 in which case there is no WORD after it
      DWORD
      6x FLOAT
  }
  if FOwner.Version<117 then
    begin
      size := FOwner.read_idx(buffer,utdmAsValue,'LightBits Array Size');
      setlength(FLightBits, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FLightBits[a] := FOwner.read_byte(buffer,utdmAsValue,'LightBits');
      size := FOwner.read_idx(buffer,utdmAsValue,'Bounds Array Size');
      setlength(FBounds, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FBounds[a] := Read_Struct_BoundingBox(FOwner, buffer,'Bounds');
      size := FOwner.read_idx(buffer,utdmAsValue,'LeafHulls Array Size');
      setlength(FLeafHulls, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FLeafHulls[a] := FOwner.read_dword(buffer,utdmAsValue,'LeafHulls');
    end;
  size := FOwner.read_idx(buffer,utdmAsValue,'Leaves Array Size');
  setlength(FLeaves, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FLeaves[a] := Read_Struct_Leaf(FOwner, buffer,'Leaves');
  size := FOwner.read_idx(buffer,utdmAsValue,'Lights Array Size');
  setlength(FLights, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FLights[a] := FOwner.read_idx(buffer,utdmRefToObject,'Lights');
  FRootOutside := FOwner.read_dword(buffer,utdmAsValue,'RootOutside') <> 0;
  FLinked := FOwner.read_dword(buffer,utdmAsValue,'Linked') <> 0;
  // TODO : UT2003 has a lot more data at the end (maybe part of what has not been read before)
end;

{ TUTObjectClassLevelBase }

function TUTObjectClassLevelBase.GetActor(n: integer): integer;
begin
  result := FActors[n];
end;

function TUTObjectClassLevelBase.GetActorCount: integer;
begin
  result := length(FActors);
end;

procedure TUTObjectClassLevelBase.InitializeObject;
begin
  inherited;
  setlength(FActors, 0);
  FURL.Protocol := '';
  FURL.Host := '';
  FURL.Port := 0;
  FURL.Map := '';
  setlength(FURL.Options, 0);
  FURL.Portal := '';
  FURL.Valid := false;
end;

procedure TUTObjectClassLevelBase.InterpretObject;
var
  size, a: integer;
begin
  inherited;
  FOwner.read_dword(buffer);
  size := FOwner.read_dword(buffer,utdmAsValue,'Actors Array Size');
  setlength(FActors, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FActors[a] := FOwner.read_idx(buffer,utdmRefToObject,'Actors');
  FURL := Read_Struct_URL(FOwner, buffer,'URL');
end;

{ TUTObjectClassLevel }

function TUTObjectClassLevel.GetReachSpec(n: integer): TUT_Struct_ReachSpec;
begin
  result := FReachSpecs[n];
end;

function TUTObjectClassLevel.GetReachSpecCount: integer;
begin
  result := length(FReachSpecs);
end;

function TUTObjectClassLevel.GetTextBlock(n: integer): integer;
begin
  result := FTextBlocks[n];
end;

function TUTObjectClassLevel.GetTravelInfo(n: integer): TUT_Struct_Map;
begin
  result := FTravelInfo[n];
end;

function TUTObjectClassLevel.GetTravelInfoCount: integer;
begin
  result := length(FTravelInfo);
end;

procedure TUTObjectClassLevel.InitializeObject;
var
  a: integer;
begin
  inherited;
  FModel := 0;
  setlength(FReachSpecs, 0);
  FFirstDeleted := 0;
  for a := 0 to 15 do
    FTextBlocks[a] := 0;
  setlength(FTravelInfo, 0);
end;

procedure TUTObjectClassLevel.InterpretObject;
var
  a, size: integer;
  v: string;
begin
  inherited;
  FModel := FOwner.read_idx(buffer,utdmRefToObject,'Model');
  size := FOwner.read_idx(buffer,utdmAsValue,'ReachSpecs Array Size');
  setlength(FReachSpecs, CheckArrayLength(size));
  for a := 0 to size - 1 do
    FReachSpecs[a] := Read_Struct_ReachSpec(FOwner, buffer,'ReachSpecs');
  FOwner.read_float(buffer,'AproxTime');
  if (FOwner.GameHint=UTPGH_ArmyOperations) then
    begin // not sure if here of before previous float
      FOwner.read_dword (buffer); // TODO : unknown dword
    end;
  FFirstDeleted := FOwner.read_idx(buffer,utdmUnknown,'FirstDeleted');
  for a := 0 to 15 do
    FTextBlocks[a] := FOwner.read_idx(buffer,utdmRefToObject,'TextBlocks');
  if FOwner.Version >= 117 then
     // nothing?
  else if FOwner.Version > 62 then
    begin
      size := FOwner.read_idx(buffer,utdmAsValue,'TravelInfo Array Size');
      setlength(FTravelInfo, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FTravelInfo[a] := Read_Struct_Map(FOwner, buffer,'TravelInfo');
    end
  else if FOwner.Version >= 61 then
    begin
      size := FOwner.read_idx(buffer,utdmAsValue,'TravelInfo Key Array Size');
      setlength(FTravelInfo, CheckArrayLength(size));
      for a := 0 to size - 1 do
        FTravelInfo[a].Key := FOwner.read_sizedasciiz(buffer,'TravelInfo.Key');
      size := FOwner.read_idx(buffer,utdmAsValue,'TravelInfo Value Array Size');
      for a := 0 to size - 1 do
        begin
          v := FOwner.read_sizedasciiz(buffer,'TravelInfo.Value');
          if a <= high(FTravelInfo) then FTravelInfo[a].Value := v;
        end;
    end;
  // TODO : WoT levels seem to have one more byte (or index) at the end.
end;

{ TUTObjectClassStaticMesh }

function TUTObjectClassStaticMesh.GetMaterial(
  i: integer): TUT_Struct_Material;
begin
  check_initialized;
  result:=FMaterials[i];
end;

function TUTObjectClassStaticMesh.GetMaterialsCount: integer;
begin
  check_initialized;
  result:=length(FMaterials);
end;

function TUTObjectClassStaticMesh.GetTriangle(i: integer): TUT_Struct_Face;
begin
  check_initialized;
  result:=FTriangles[i];
end;

function TUTObjectClassStaticMesh.GetTrianglesCount: integer;
begin
  check_initialized;
  result:=length(FTriangles);
end;

function TUTObjectClassStaticMesh.GetUV(
  i: integer): TUT_Struct_MeshFloatUV;
begin
  check_initialized;
  result:=FUV[i];
end;

function TUTObjectClassStaticMesh.GetUVCount: integer;
begin
  check_initialized;
  result:=length(FUV);
end;

function TUTObjectClassStaticMesh.GetVertex(i: integer): TUT_Struct_Vert;
begin
  check_initialized;
  result:=FVertex[i];
end;

function TUTObjectClassStaticMesh.GetVertexCount: integer;
begin
  check_initialized;
  result:=length(FVertex);
end;

procedure TUTObjectClassStaticMesh.InitializeObject;
begin
  inherited;
end;

procedure TUTObjectClassStaticMesh.InterpretObject;
var count,count2,i,i2:integer;
begin
  inherited; // from Primitive inherits here a BoundingBox and a BoundingSphere

  // TODO : Splinter Cell StaticMeshes have different format

  if FOwner.GameHint=UTPGH_SplinterCell then
    begin
      count:=FOwner.read_idx(buffer,utdmAsValue);
      for i:=0 to count-1 do
        begin
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
        end;
      {FOwner.read_dword(buffer);
      // array of words
      FOwner.read_dword(buffer);
      // array of words
      FOwner.read_dword(buffer);}

      //raise EUnknownObjectFormat.create ('Cannot read StaticMeshes from Splinter Cell');
    end
  else if FOwner.GameHint=UTPGH_DeusExInvisibleWar then
    raise EUnknownObjectFormat.create ('Cannot read StaticMeshes from Deus Ex Invisible War')
  else
    begin
      setlength(FMaterials,CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue,'Material Count')));
      for i:=0 to high(FMaterials) do
        begin
          FMaterials[i].Flags:=0;
          // TODO : read values from properties
          FMaterials[i].TextureIndex:=0; //Properties.PropertyByName['Materials'].GetValue ();
          FOwner.read_dword(buffer); // = 00000000
          FOwner.read_word(buffer);  // \
          FOwner.read_word(buffer);  // +--> triplet of some kind
          FOwner.read_word(buffer);  // /  (last vertex?)
          FOwner.read_word(buffer);  // \  (triangle count?)
          FOwner.read_word(buffer);  // / pair of some kind (same value?)
        end;
      // next fields seem to be a BoundingBox
      Read_Struct_BoundingBox (FOwner,buffer,'BoundingBox');
      {FOwner.read_float(buffer);FOwner.read_float(buffer);FOwner.read_float(buffer);FOwner.read_float(buffer);FOwner.read_float(buffer);FOwner.read_float(buffer);FOwner.read_byte(buffer);}

      if FOwner.GameHint=UTPGH_UnrealChampionship then
        begin
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
        end;

      count:=FOwner.read_idx(buffer,utdmAsValue,'Vertex Count');
      for i:=1 to count do
        begin
          FOwner.read_float(buffer,'Vertex.X');
          FOwner.read_float(buffer,'Vertex.Y');
          FOwner.read_float(buffer,'Vertex.Z');

          FOwner.read_float(buffer,'Normal.X');
          FOwner.read_float(buffer,'Normal.Y');
          FOwner.read_float(buffer,'Normal.Z');
        end;
      FOwner.read_dword(buffer,utdmAsValue); // = 1 or 2
      count:=FOwner.read_idx(buffer,utdmAsValue,'Vertex Count');  // one of the following could be the Vertex Color array
      for i:=1 to count do
        FOwner.read_dword(buffer); // = FFFFFFFF
      FOwner.read_dword(buffer,utdmAsValue); // = 1 or 2
      count:=FOwner.read_idx(buffer,utdmAsValue,'Vertex Count');
      for i:=1 to count do
        FOwner.read_dword(buffer); // = FFFFFFFF
      FOwner.read_dword(buffer,utdmAsValue); // = 1 or 2
      count2:=FOwner.read_idx(buffer,utdmAsValue,'Layers Count?');
      for i2:=1 to count2 do
        begin
          count:=FOwner.read_idx(buffer,utdmAsValue,'Vertex Count');
          for i:=1 to count do
            begin
              if i2=1 then // only first layer seems to have valid floats (sometimes)
                begin
                  FOwner.read_float(buffer,'Vertex.U');
                  FOwner.read_float(buffer,'Vertex.V');
                end
              else
                begin
                  FOwner.read_dword(buffer,utdmAsValue,'Vertex.U?');
                  FOwner.read_dword(buffer,utdmAsValue,'Vertex.V?');
                end;
            end;
          FOwner.read_dword(buffer,utdmAsValue); // layer index?
          FOwner.read_dword(buffer,utdmAsValue); // = 1
        end;
      count:=FOwner.read_idx(buffer,utdmAsValue,'Unknown Array Count');
      for i:=1 to count do
        FOwner.read_word(buffer); // contains a vertex index
      FOwner.read_dword(buffer,utdmAsValue); // = 1 or 2
      count:=FOwner.read_idx(buffer,utdmAsValue,'Unknown Array Count');
      for i:=1 to count do
        FOwner.read_word(buffer); // contains a vertex index
      FOwner.read_dword(buffer,utdmAsValue); // = 1 or 2
      FOwner.read_idx(buffer,utdmAsValue); // Model object?

      if (FOwner.GameHint<>UTPGH_UnrealTournament2004) then
        begin
          count:=FOwner.read_idx(buffer,utdmAsValue,'Triangle Count');
          for i:=1 to count do
            begin
              FOwner.read_float(buffer);  // quaternions?
              FOwner.read_float(buffer);
              FOwner.read_float(buffer);
              FOwner.read_float(buffer);

              FOwner.read_float(buffer);
              FOwner.read_float(buffer);
              FOwner.read_float(buffer);
              FOwner.read_float(buffer);

              FOwner.read_float(buffer);
              FOwner.read_float(buffer);
              FOwner.read_float(buffer);
              FOwner.read_float(buffer);

              FOwner.read_float(buffer);
              FOwner.read_float(buffer);
              FOwner.read_float(buffer);
              FOwner.read_float(buffer);

              if FOwner.GameHint=UTPGH_UnrealChampionship then
                begin
                  FOwner.read_word(buffer,utdmAsValue,'Vertex1Index');
                  FOwner.read_word(buffer,utdmAsValue,'Vertex2Index');
                  FOwner.read_word(buffer,utdmAsValue,'Vertex3Index');
                  FOwner.read_word(buffer,utdmAsValue,'MaterialIndex');
                end
              else
                begin
                  FOwner.read_idx(buffer,utdmAsValue,'Vertex1Index');
                  FOwner.read_idx(buffer,utdmAsValue,'Vertex2Index');
                  FOwner.read_idx(buffer,utdmAsValue,'Vertex3Index');
                  FOwner.read_byte(buffer,utdmAsValue,'MaterialIndex');
                end;
            end;
          // TODO : Desert Thunder is different from here (?)
          count:=FOwner.read_idx(buffer,utdmAsValue,'Triangle Adjacencies Count?');
          for i:=1 to count do
            begin
              if FOwner.GameHint=UTPGH_UnrealChampionship then
                begin
                  FOwner.read_word(buffer); // this triangle index?
                  FOwner.read_word(buffer); // adjacent triangle index? can be FFFF
                  FOwner.read_word(buffer); // adjacent triangle index? can be FFFF
                  FOwner.read_word(buffer); // adjacent triangle index? can be FFFF

                  FOwner.read_word(buffer);
                  FOwner.read_word(buffer);
                  FOwner.read_word(buffer);

                  FOwner.read_word(buffer);
                  FOwner.read_word(buffer);
                  FOwner.read_word(buffer);
                end
              else
                begin
                  FOwner.read_idx(buffer,utdmAsValue); // this triangle index?
                  FOwner.read_idx(buffer,utdmAsValue); // adjacent triangle index? can be -1
                  FOwner.read_idx(buffer,utdmAsValue); // adjacent triangle index? can be -1
                  FOwner.read_idx(buffer,utdmAsValue); // adjacent triangle index? can be -1
                  // next fields seems to be a BoundingBox
                  Read_Struct_BoundingBox (FOwner,buffer,'BoundingBox');
                  {FOwner.read_float(buffer);FOwner.read_float(buffer);FOwner.read_float(buffer);FOwner.read_float(buffer);FOwner.read_float(buffer);FOwner.read_float(buffer);FOwner.read_byte(buffer);}
                end;
            end;
          if FOwner.GameHint=UTPGH_Devastation then FOwner.read_dword(buffer);
        end
      else
        begin
          count:=FOwner.read_idx(buffer,utdmAsValue,'Unknown Count');
          for i:=1 to count do
            begin
              FOwner.read_float(buffer);
              FOwner.read_float(buffer);
              FOwner.read_float(buffer);
              FOwner.read_float(buffer);
              FOwner.read_float(buffer);
              FOwner.read_float(buffer);
              FOwner.read_word(buffer); // material?
              FOwner.read_word(buffer); // vertexindex1?
              FOwner.read_word(buffer); // vertexindex2?
              FOwner.read_word(buffer); // vertexindex3?
            end;
          count:=FOwner.read_idx(buffer,utdmAsValue,'Triangle Count');
          for i:=1 to count do
            begin
              FOwner.read_word(buffer); // vertexindex1?
              FOwner.read_word(buffer); // vertexindex2?
              FOwner.read_word(buffer); // vertexindex3?
              FOwner.read_word(buffer); // material?
            end;
        end;
      FOwner.read_dword(buffer,utdmOffset,'Jump Over Next Array');
      setlength(FTriangles,CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue,'Triangle Count')));
      setlength(FVertex,length(FTriangles)*3);
      setlength(FUV,length(FTriangles)*3);
      for i:=0 to high(FTriangles) do
        begin

          FVertex[i*3].X:=FOwner.read_float(buffer,'Vertex1.X');
          FVertex[i*3].Y:=FOwner.read_float(buffer,'Vertex1.Y');
          FVertex[i*3].Z:=FOwner.read_float(buffer,'Vertex1.Z');

          FVertex[i*3+1].X:=FOwner.read_float(buffer,'Vertex2.X');
          FVertex[i*3+1].Y:=FOwner.read_float(buffer,'Vertex2.Y');
          FVertex[i*3+1].Z:=FOwner.read_float(buffer,'Vertex2.Z');

          FVertex[i*3+2].X:=FOwner.read_float(buffer,'Vertex3.X');
          FVertex[i*3+2].Y:=FOwner.read_float(buffer,'Vertex3.Y');
          FVertex[i*3+2].Z:=FOwner.read_float(buffer,'Vertex3.Z');

          FTriangles[i].WedgeIndex1:=i*3;
          FTriangles[i].WedgeIndex2:=i*3+1;
          FTriangles[i].WedgeIndex3:=i*3+2;

          count2:=FOwner.read_dword(buffer,utdmAsValue,'Layers Count?');
          for i2:=1 to count2 do
            begin
              if i2=1 then  // only first layer seems to have valid floats (sometimes)
                begin
                  FUV[i*3].U:=FOwner.read_float(buffer,'Vertex1.U');
                  FUV[i*3].V:=FOwner.read_float(buffer,'Vertex1.V');

                  FUV[i*3+1].U:=FOwner.read_float(buffer,'Vertex2.U');
                  FUV[i*3+1].V:=FOwner.read_float(buffer,'Vertex2.V');

                  FUV[i*3+2].U:=FOwner.read_float(buffer,'Vertex3.U');
                  FUV[i*3+2].V:=FOwner.read_float(buffer,'Vertex3.V');
                end
              else
                begin
                  FOwner.read_dword(buffer,utdmAsValue,'Vertex1.U?');
                  FOwner.read_dword(buffer,utdmAsValue,'Vertex1.V?');

                  FOwner.read_dword(buffer,utdmAsValue,'Vertex2.U?');
                  FOwner.read_dword(buffer,utdmAsValue,'Vertex2.V?');

                  FOwner.read_dword(buffer,utdmAsValue,'Vertex3.U?');
                  FOwner.read_dword(buffer,utdmAsValue,'Vertex3.V?');
                end;
            end;
          FOwner.read_dword(buffer,utdmAsValue); // = FFFFFFFF
          FOwner.read_dword(buffer,utdmAsValue); // = FFFFFFFF
          FOwner.read_dword(buffer,utdmAsValue); // = FFFFFFFF
          FTriangles[i].MatIndex:=FOwner.read_dword(buffer,utdmAsValue,'MaterialIndex');
          FOwner.read_dword(buffer,utdmAsValue); // flags?
        end;
      FOwner.read_dword(buffer); // = 10 o 11
      if FOwner.Version>118 then
        begin
          count:=FOwner.read_idx(buffer,utdmAsValue,'Unknown Array Count');
          for i:=1 to count do
            FOwner.read_float(buffer);
          if FOwner.GameHint=UTPGH_Rainbow6RavenShield then FOwner.read_idx(buffer);
        end;
      if FOwner.GameHint<>UTPGH_ArmyOperations then FOwner.read_idx(buffer,utdmRefToObject,'KarmaPropertiesObject');
      if FOwner.Version>=120 then FOwner.read_float(buffer);
      // TODO : Devastation has more data (but apparently always 0)
    end;
end;

{ // the following was got from somewhere, but dont remember where...
  FOwner.read_idx(buffer,utdmRefToObject); // VertexBuffer
  FOwner.read_idx(buffer,utdmRefToObject); // IndexBuffer
  count:=FOwner.read_idx(buffer,utdmAsValue);
  for i:=1 to count do
    begin
      FOwner.read_dword(buffer);
      FOwner.read_idx(buffer);
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
    end;
  for i:=1 to 3 do
    begin // may be three boundingboxes ?
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_byte(buffer);
    end;
  count:=FOwner.read_idx(buffer,utdmAsValue);
  for i:=1 to count do
    FOwner.read_dword(buffer);
  for i:=1 to count do
    begin
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_byte(buffer);
      FOwner.read_byte(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_byte(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
    end;
  FOwner.read_float(buffer);
  FOwner.read_float(buffer);
  FOwner.read_float(buffer);
  FOwner.read_float(buffer);
  FOwner.read_float(buffer);
  FOwner.read_float(buffer);
  count:=FOwner.read_idx(buffer,utdmAsValue);
  for i:=1 to count do
    FOwner.read_word (buffer);
  FOwner.read_idx(buffer,utdmRefToObject); // IndexBuffer
  count:=FOwner.read_idx(buffer,utdmAsValue);
  for i:=1 to count do
    begin
      for i2:=1 to 25 do
        FOwner.read_float(buffer);
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
      FOwner.read_idx(buffer);
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
    end;
  FOwner.read_dword(buffer);}

procedure TUTObjectClassStaticMesh.PrepareExporter(exporter: TUT_MeshExporter; frames: TIntegerDynArray);
const
  material_colors: array[0..5] of TColor = (clBlue, clRed, clLime, clYellow, clAqua, clSilver);
var
  m, o: integer;vv:double;
begin
  check_initialized;
  o:=exporter.AddObject;
  setlength(exporter.Objects[o].Materials, length(FMaterials));
  for m := 0 to high(FMaterials) do
    begin
      exporter.Objects[o].Materials[m].name := 'Material' + inttostr(m);
      exporter.Objects[o].Materials[m].Texture:=FOwner.GetObjectPath(-1,FMaterials[m].TextureIndex);
      if m <= high(material_colors) then
        begin
          exporter.Objects[o].Materials[m].diffusecolor[0] := material_colors[m] and $FF;
          exporter.Objects[o].Materials[m].diffusecolor[1] := (material_colors[m] shr 8) and $FF;
          exporter.Objects[o].Materials[m].diffusecolor[2] := (material_colors[m] shr 16) and $FF;
        end
      else
        begin
          exporter.Objects[o].Materials[m].diffusecolor[0] := random(256);
          exporter.Objects[o].Materials[m].diffusecolor[1] := random(256);
          exporter.Objects[o].Materials[m].diffusecolor[2] := random(256);
        end;
    end;
  exporter.Objects[o].AnimationFrames := 1;
  setlength(exporter.Objects[o].Faces, length(FTriangles));
  setlength(exporter.Objects[o].Vertices, 3 * length(FTriangles));
  for m:=0 to high(FVertex) do
    begin
      with exporter.Objects[o].Vertices[m] do
        begin
          X:=FVertex[m].X;
          Y:=FVertex[m].Y;
          Z:=FVertex[m].Z;
          vv:=FUV[m].U;while vv>1.0 do vv:=vv-1.0;while vv<0.0 do vv:=vv+1.0;
          U:=min(255,round(255*vv));
          vv:=FUV[m].V;while vv>1.0 do vv:=vv-1.0;while vv<0.0 do vv:=vv+1.0;
          V:=min(255,round(255*vv));
        end;
    end;
  for m := 0 to high(FTriangles) do
    begin
      with exporter.Objects[o].Faces[m] do
        begin
          VertexIndex1 := FTriangles[m].WedgeIndex1;
          VertexIndex2 := FTriangles[m].WedgeIndex2;
          VertexIndex3 := FTriangles[m].WedgeIndex3;
          MaterialIndex := FTriangles[m].MatIndex;
          Flags := 0;
        end;
    end;
end;

procedure TUTObjectClassStaticMesh.Save_3DS(filename: string; frames: TIntegerDynArray;
  mode:TUT_MeshExporter_Animation = exp_anim_MixedInFile;
  smoothing: TUT_3DStudioExporter_Smoothing = exp3ds_smooth_None;
  MirrorX: boolean = false);
var
  exporter: TUT_3DStudioExporter;
  frame:TIntegerDynArray;
begin
  check_initialized;
  case mode of
  exp_anim_MixedInFile:
    begin
      exporter := TUT_3DStudioExporter.create;
      PrepareExporter(exporter, frames);
      exporter.mirrorX := mirrorX;
      exporter.smoothing := smoothing;
      exporter.Save(filename);
      exporter.free;
    end;
  exp_anim_MultiFile:
    begin
      exporter := TUT_3DStudioExporter.create;
      setlength(frame,0);
      PrepareExporter(exporter, frame);
      exporter.mirrorX := mirrorX;
      exporter.smoothing := smoothing;
      exporter.Save(changefileext(filename,'_0'+extractfileext(filename)));
      exporter.free;
    end;
  end;
end;

procedure TUTObjectClassStaticMesh.Save_Unreal3D(filename: string);
var
  exporter: TUT_Unreal3DExporter;
  frames: TIntegerDynArray;
begin
  check_initialized;
  exporter := TUT_Unreal3DExporter.create;
  setlength(frames,0);
  PrepareExporter(exporter, frames);
  exporter.Save(filename);
  exporter.free;
end;

procedure TUTObjectClassStaticMesh.Save_UnrealUC(filename: string);
var
  k: char;
  uc, parent_class, basename: string;
  a, script_idx: integer;
  ed2: TUTExportTableObjectData;
  str_uc: tfilestream;
begin
  check_initialized;
  // Find a class with the same name as the mesh
  a := FOwner.FindObject(utolExports, [utfwName, utfwClass, utfwGroup], '', UTobjectname, '');
  if a <> -1 then
    begin
      ed2 := FOwner.Exported[a];
      ed2.UTObject.ReadObject;
      parent_class := FOwner.GetObjectPath(1, TUTObjectClassClass(ed2.UTObject).SuperField);
      script_idx := TUTObjectClassClass(ed2.UTObject).ScriptText - 1;
      ed2.UTObject.ReleaseObject;
    end
  else
    begin
      parent_class := 'Resource'; // do not localize these strings
      // Find the correct script object
      script_idx := FOwner.FindObject(utolExports,
          [utfwGroup, utfwName, utfwClass],
          UTobjectname, 'ScriptText', 'TextBuffer');
    end;
  if script_idx <> -1 then
    begin                               // the script was found
      ed2 := FOwner.Exported[script_idx];
      ed2.UTObject.ReadObject;
      TUTObjectClassTextBuffer(ed2.UTObject).SaveToFile(filename);
      ed2.UTObject.ReleaseObject;
    end
  else
    begin                               // the script wasn't found, we must recreate it
      k := DecimalSeparator;
      decimalSeparator := '.';
      basename := UTobjectname;
      // do not localize
      uc :='//============================================================================='#13#10;
      uc := uc + format('// %s.'#13#10, [basename]);
      uc := uc +'//============================================================================='#13#10;
      uc := uc + format('class %s extends %s;'#13#10#13#10, [basename, parent_class]);
      // #exec OBJ LOAD FILE %s.utx
      uc := uc + format('#exec STATICMESH IMPORT NAME=%s FILE=MODELS\%s_d.3d', [basename, basename]);
      // COLLISION=0
      uc := uc + #13#10;
      DecimalSeparator := k;
      str_uc := tfilestream.create(filename, fmCreate);
      try
        str_uc.write(uc[1], length(uc));
      finally
        str_uc.free;
      end;
    end;
end;

{ TUTObjectClassIndexBuffer }

procedure TUTObjectClassIndexBuffer.InitializeObject;
begin
  inherited;
end;

procedure TUTObjectClassIndexBuffer.InterpretObject;
var count,i:integer;
begin
  inherited;
  FOwner.read_dword (buffer);
  count:=FOwner.read_idx (buffer,utdmAsValue,'? Array Size');
  for i:=1 to count do
    FOwner.read_word (buffer);
end;

{ TUTObjectClassVertexBuffer }

procedure TUTObjectClassVertexBuffer.InitializeObject;
begin
  inherited;
end;

procedure TUTObjectClassVertexBuffer.InterpretObject;
var count,i:integer;
begin
  inherited;
  FOwner.read_dword(buffer);
  FOwner.read_dword(buffer);
  FOwner.read_dword(buffer);
  FOwner.read_dword(buffer);
  count:=FOwner.read_idx(buffer,utdmAsValue,'? Array Size');
  for i:=1 to count do
    begin
      Read_Struct_Vector (FOwner,buffer);
      Read_Struct_Vector (FOwner,buffer);
      Read_Struct_Vector (FOwner,buffer);
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
    end;
end;

{ TUTObjectClassCubeMap }

procedure TUTObjectClassCubeMap.InitializeObject;
begin
  inherited;
  //FCubeMapRenderInterface:=0;
end;

procedure TUTObjectClassCubeMap.InterpretObject;
//var a,size:integer;
begin
  inherited;
  {if (FOwner.Version>=120) and (Properties.PropertyByName['MinLOD']=nil) then
    begin
      // TODO : find what these arrays are (cubemap class only in UT2003)
      size:=CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue));
      for a:=1 to size do
        FOwner.read_word(buffer);
      size:=CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue));
      for a:=1 to size do
        FOwner.read_word(buffer);
    end;}
  //FCubeMapRenderInterface:=FOwner.read_byte(buffer);
end;

{ TUTObjectClassProceduralSound }

procedure TUTObjectClassProceduralSound.InitializeObject;
begin
  inherited;
  FBaseSound:=0;
  FPitchModification:=0.0;
  FVolumeModification:=0.0;
  FPitchVariance:=0.0;
  FVolumeVariance:=0.0;
end;

procedure TUTObjectClassProceduralSound.InterpretObject;
begin
  inherited;
  FOwner.read_float(buffer); // TODO : (proceduralsound) unknown float
  FBaseSound:=FOwner.read_idx(buffer,utdmRefToObject,'BaseSound');
  FPitchModification:=FOwner.read_float(buffer,'PitchModification');
  FVolumeModification:=FOwner.read_float(buffer,'VolumeModification');
  FPitchVariance:=FOwner.read_float(buffer,'PitchVariance');
  FVolumeVariance:=FOwner.read_float(buffer,'VolumeVariance');
end;

{ TUTObjectClassSoundGroup }

function TUTObjectClassSoundGroup.GetSound(i: integer): integer;
begin
  result:=FSounds[i];
end;

function TUTObjectClassSoundGroup.SoundCount: integer;
begin
  result:=length(FSounds);
end;

procedure TUTObjectClassSoundGroup.InitializeObject;
begin
  inherited;
  //FPackage:='';
  setlength (FSounds,0);
end;

procedure TUTObjectClassSoundGroup.InterpretObject;
var i:integer;
begin
  inherited;
  //FPackage:=FOwner.read_sizedasciiz (buffer);
  setlength(FSounds,CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue,'Sounds Array Size')));
  for i:=0 to high(FSounds) do
    FSounds[i]:=FOwner.read_idx(buffer,utdmRefToObject);
end;

{ TUTObjectClassPackageCheckInfo }

function TUTObjectClassPackageCheckInfo.GetMD5(i: integer): string;
begin
  check_initialized;
  result:=FMD5[i];
end;

procedure TUTObjectClassPackageCheckInfo.InitializeObject;
begin
  inherited;
  setlength(FMD5,0);
  FPackageMD5:='';
end;

procedure TUTObjectClassPackageCheckInfo.InterpretObject;
var i,size:integer;
begin
  {
  FPackageGUID:=FOwner.read_guid(buffer);
  size:=CheckArrayLength(FOwner.read_dword(buffer,utdmAsValue));
  setlength (FMD5,size);
  for i:=0 to size-1 do
    FMD5[i]:=FOwner.read_sizedasciiz(buffer);
  ReadProperties;
  }
  ReadProperties;
  FPackageMD5:=FOwner.read_sizedasciiz(buffer,'PackageMD5');
  size:=CheckArrayLength(FOwner.read_idx(buffer,utdmAsValue,'MD5 Array Size'));
  setlength (FMD5,size);
  for i:=0 to size-1 do
    FMD5[i]:=FOwner.read_sizedasciiz(buffer,'MD5');
  // TODO : unknown DWORDs
  FOwner.read_dword(buffer);
  FOwner.read_dword(buffer);
end;

function TUTObjectClassPackageCheckInfo.MD5Count: integer;
begin
  result:=length(FMD5);
end;

{ TUT_MeshExporter }

constructor TUT_MeshExporter.Create;
begin
  inherited;
  setlength(Objects,0);
end;

function TUT_MeshExporter.AddObject: integer;
begin
  setlength(Objects,length(Objects)+1);
  result:=high(Objects);
end;

function TUT_MeshExporter.AllObjectsSameFrames: boolean;
var a:integer;
begin
  result:=true;
  if length(Objects)=0 then exit;
  for a:=1 to high(Objects) do
    if Objects[a].AnimationFrames<>Objects[0].AnimationFrames then
      begin
        result:=false;
        break;
      end;
end;

{ TUTObjectClassConvexVolume }

procedure TUTObjectClassConvexVolume.InitializeObject;
begin
  inherited;

end;

procedure TUTObjectClassConvexVolume.InterpretObject;
var i,i2,a,a2:integer;
begin
  inherited;
  //FOwner.Seek(41);
  i:=FOwner.read_idx(buffer,utdmAsValue,'Array Size');
  for a:=1 to i do
    begin
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      FOwner.read_float(buffer);
      i2:=FOwner.read_idx(buffer,utdmAsValue,'Array Size');
      for a2:=1 to i2 do
        begin
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
          FOwner.read_float(buffer);
        end;
    end;
  i:=FOwner.read_idx(buffer,utdmAsValue,'Array Size');
  for a:=1 to i do
    begin
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
      FOwner.read_dword(buffer);
    end;
  Read_Struct_BoundingBox (FOwner,buffer,'BoundingBox');
end;

// Helper functions

function CheckArrayLength(size:integer;const buffer:tstream):integer;
begin
  result:=size;
  if size>buffer.Size then raise exception.create (rsInvalidArrayLength);
end;

function Read_Struct_Vector(owner: TUTPackage; buffer: TStream;name:string=''):
  TUT_Struct_Vector;
begin
  with result do
    begin
      x := owner.read_float(buffer,name+'.X');
      y := owner.read_float(buffer,name+'.Y');
      z := owner.read_float(buffer,name+'.Z');
    end;
end;

function Read_Struct_Plane(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Plane;
begin
  with result do
    begin
      x := owner.read_float(buffer,name+'.X');
      y := owner.read_float(buffer,name+'.Y');
      z := owner.read_float(buffer,name+'.Z');
      w := owner.read_float(buffer,name+'.W');
    end;
end;

function Read_Struct_Rotator(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Rotator;
begin
  with result do
    begin
      Yaw := owner.read_int(buffer,utdmAsValue,name+'.Yaw');
      Roll := owner.read_int(buffer,utdmAsValue,name+'.Roll');
      Pitch := owner.read_int(buffer,utdmAsValue,name+'.Pitch');
    end;
end;

function Read_Struct_Polygon(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Polygon;
var
  v: integer;
  function coord (n:string=''): single;
  var
    i: dword;
    sign: boolean;
  const
    sign_flag = $80000000;
  begin
    i := owner.read_dword(buffer,utdmAsValue,name+'.'+n);
    sign := (i and sign_flag) = sign_flag;
    i := i and not sign_flag;
    move(i, result, 4);
    if sign then
      result := -result;
  end;
begin
  with result do
    begin
      setlength(Vertex, CheckArrayLength(Owner.read_idx(buffer,utdmAsValue,name+'.Vertex Array Size'),buffer));
      Base.x := coord('Base.X');
      Base.y := coord('Base.Y');
      Base.z := coord('Base.Z');
      Normal.x := coord('Normal.X');
      Normal.y := coord('Normal.Y');
      Normal.z := coord('Normal.Z');
      TextureU.x := coord('TextureU.X');
      TextureU.y := coord('TextureU.Y');
      TextureU.z := coord('TextureU.Z');
      TextureV.x := coord('TextureV.X');
      TextureV.y := coord('TextureV.Y');
      TextureV.z := coord('TextureV.Z');
      for v := 0 to high(Vertex) do
        begin
          Vertex[v].x := coord('Vertex.X');
          Vertex[v].y := coord('Vertex.Y');
          Vertex[v].z := coord('Vertex.Z');
        end;
      PolyFlags := Owner.read_dword(buffer,utdmFlags,name+'.PolyFlags');
      Actor := Owner.read_idx(buffer,utdmRefToObject,name+'.Actor');
      Texture := Owner.read_idx(buffer,utdmRefToObject,name+'.Texture');
      ItemName := Owner.read_idx(buffer,utdmRefToName,name+'.ItemName');
      iLink := Owner.read_idx(buffer,utdmUnknown,name+'.iLink');
      iBrushPoly := Owner.read_idx(buffer,utdmRefToObject,name+'.iBrushPoly');
      if Owner.Version<100 then // checked only with XIII Polys
        begin // TODO : check with >117 polys
          pan_u := Owner.read_word(buffer,utdmAsValue,name+'.PanU');
          pan_v := Owner.read_word(buffer,utdmAsValue,name+'.PanV');
          if pan_u > $8000 then
            pan_u := integer($FFFF0000 or DWORD(pan_u));
          if pan_v > $8000 then
            pan_v := integer($FFFF0000 or DWORD(pan_v));
        end
      else if (Owner.GameHint=UTPGH_ArmyOperations) then
        begin
          Owner.read_dword (buffer); // TODO : unknown dword
          Owner.read_dword (buffer); // TODO : unknown dword
        end
      else if Owner.Version>=120 then
        begin
          Owner.read_dword(buffer); // TODO : unknown dword in v120 poly
        end;
    end;
end;

function Read_Struct_Spark(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Spark;
begin
  with result do
    begin
      SparkType := owner.read_byte(buffer,utdmAsValue,name+'.SparkType');
      Heat := owner.read_byte(buffer,utdmAsValue,name+'.Heat');
      X := owner.read_byte(buffer,utdmAsValue,name+'.X');
      Y := owner.read_byte(buffer,utdmAsValue,name+'.Y');
      X_Speed := owner.read_byte(buffer,utdmAsValue,name+'.X_Speed');
      Y_Speed := owner.read_byte(buffer,utdmAsValue,name+'.Y_Speed');
      Age := owner.read_byte(buffer,utdmAsValue,name+'.Age');
      ExpTime := owner.read_byte(buffer,utdmAsValue,name+'.ExpTime');
    end;
end;

function Read_Struct_BoundingBox(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_BoundingBox;
begin
  with result do
    begin
      Min := Read_Struct_Vector(owner, buffer,name+'.Min');
      Max := Read_Struct_Vector(owner, buffer,name+'.Max');
      Valid := Owner.read_byte(buffer,utdmAsValue,name+'.Valid');
    end;
end;

function Read_Struct_BoundingSphere(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_BoundingSphere;
begin
  with result do
    begin
      Center := Read_Struct_Vector(owner, buffer,name+'.Center');
      if Owner.Version > 61 then
        Radius := Owner.read_float(buffer,name+'.Radius')
      else
        Radius := -1;
    end;
end;

function Read_Struct_Vert(owner: TUTPackage; buffer: TStream; highres: boolean;name:string=''): TUT_Struct_Vert;
var
  x, y, z: double;
  xyz64: int64;
  xyz: DWORD;
begin
  if highres then
    begin                               // DeusEX vertices have more resolution
      Owner.read_buffer(xyz64, 8, buffer,name+'.XYZ');
      x := (xyz64 and $FFFF) / 256;
      y := ((xyz64 shr 16) and $FFFF) / 256;
      z := ((xyz64 shr 32) and $FFFF) / 256;
      if y > 128 then
        y := y - 256;
      if x > 128 then
        x := x - 256;
      if z > 128 then
        z := z - 256;
      result.x := x;
      result.y := y;
      result.z := z;
    end
  else
    begin                               // Epic standard
      Owner.read_buffer(xyz, 4, buffer,name+'.XYZ');
      x := (xyz and $7FF) / 8;
      y := ((xyz shr 11) and $7FF) / 8;
      z := ((xyz shr 22) and $3FF) / 4;
      if y > 128 then
        y := y - 256;
      if x > 128 then
        x := x - 256;
      if z > 128 then
        z := z - 256;
      result.x := x;
      result.y := y;
      result.z := z;
    end;
end;

function Read_Struct_Tri(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Tri;
begin
  with result do
    begin
      vertexindex1 := Owner.read_word(buffer,utdmAsValue,name+'.VertexIndex1');
      vertexindex2 := Owner.read_word(buffer,utdmAsValue,name+'.VertexIndex2');
      vertexindex3 := Owner.read_word(buffer,utdmAsValue,name+'.VertexIndex3');
      u1 := Owner.read_byte(buffer,utdmAsValue,name+'.U1');
      v1 := Owner.read_byte(buffer,utdmAsValue,name+'.V1');
      u2 := Owner.read_byte(buffer,utdmAsValue,name+'.U2');
      v2 := Owner.read_byte(buffer,utdmAsValue,name+'.V2');
      u3 := Owner.read_byte(buffer,utdmAsValue,name+'.U3');
      v3 := Owner.read_byte(buffer,utdmAsValue,name+'.V3');
      flags := Owner.read_dword(buffer,utdmFlags,name+'.Flags');
      textureindex := Owner.read_dword(buffer,utdmAsValue,name+'.TextureIndex');
    end;
end;

function Read_Struct_Texture(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Texture;
begin
  result.value := Owner.read_idx(buffer,utdmRefToObject,name+'.Value');
end;

function Read_Struct_AnimSeqNotify(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_AnimSeqNotify;
begin
  with result do
    begin
      time := Owner.read_float(buffer,name+'.Time');
      _function := Owner.read_idx(buffer,utdmRefToName,name+'.Function');
    end;
end;

function Read_Struct_AnimSeq(owner: TUTPackage; buffer: TStream;name_:string=''): TUT_Struct_AnimSeq;
var
  a2, size2: integer;
begin
  with result do
    begin
      name := Owner.read_idx(buffer,utdmRefToName,name_+'.Name');
      group := Owner.read_idx(buffer,utdmRefToName,name_+'.Group');
      startframe := Owner.read_dword(buffer,utdmAsValue,name_+'.StartFrame');
      numframes := Owner.read_dword(buffer,utdmAsValue,name_+'.NumFrames');
      size2 := Owner.read_idx(buffer,utdmAsValue,name_+'.Notifys Array Size');
      setlength(notifys, CheckArrayLength(size2,buffer));
      for a2 := 0 to size2 - 1 do
        Notifys[a2] := Read_Struct_AnimSeqNotify(owner, buffer,name_+'.Notifys');
      rate := Owner.read_float(buffer,name_+'.Rate');
    end;
end;

function Read_Struct_Connects(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Connects;
begin
  with result do
    begin
      NumVertTriangles := Owner.read_dword(buffer,utdmAsValue,name+'.NumVertTriangles');
      TriangleListOffset := Owner.read_dword(buffer,utdmOffset,name+'.TriangleListOffset');
    end;
end;

function Read_Struct_Wedge(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Wedge;
begin
  with result do
    begin
      VertexIndex := Owner.read_word(buffer,utdmAsValue,name+'.VertexIndex');
      U := Owner.read_byte(buffer,utdmAsValue,name+'.U');
      V := Owner.read_byte(buffer,utdmAsValue,name+'.V');
    end;
end;

function Read_Struct_Face(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Face;
begin
  with result do
    begin
      WedgeIndex1 := Owner.read_word(buffer,utdmAsValue,name+'.WedgeIndex1');
      WedgeIndex2 := Owner.read_word(buffer,utdmAsValue,name+'.WedgeIndex2');
      WedgeIndex3 := Owner.read_word(buffer,utdmAsValue,name+'.WedgeIndex3');
      MatIndex := Owner.read_word(buffer,utdmAsValue,name+'.MatIndex');
    end;
end;

function Read_Struct_Material(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Material;
begin
  with result do
    begin
      flags := Owner.read_dword(buffer,utdmFlags,name+'.Flags');
      textureindex := Owner.read_dword(buffer,utdmUnknown,name+'.TextureIndex');
    end;
end;

function Read_Struct_MeshFloatUV(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_MeshFloatUV;
begin
  with result do
    begin
      U := Owner.read_float(buffer,name+'.U');
      V := Owner.read_float(buffer,name+'.V');
    end;
end;

function Read_Struct_MeshExtWedge(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_MeshExtWedge;
begin
  with result do
    begin
      iVertex := Owner.read_word(buffer,utdmAsValue,name+'.iVertex');
      Flags := Owner.read_word(buffer,utdmAsValue,name+'.Flags');
      TexUV := Read_Struct_MeshFloatUV(owner, buffer,name+'.TexUV');
    end;
end;

function Read_Struct_Quat(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Quat;
begin
  with result do
    begin
      X := Owner.read_float(buffer,name+'.X');
      Y := Owner.read_float(buffer,name+'.Y');
      Z := Owner.read_float(buffer,name+'.Z');
      W := Owner.read_float(buffer,name+'.W');
    end;
end;

function Read_Struct_JointPos(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_JointPos;
begin
  with result do
    begin
      Orientation := Read_Struct_Quat(owner, buffer,name+'.Orientation');
      Position := Read_Struct_Vector(owner, buffer,name+'.Position');
      Length := Owner.read_float(buffer,name+'.Length');
      XSize := Owner.read_float(buffer,name+'.XSize');
      YSize := Owner.read_float(buffer,name+'.YSize'); // bug in UT? Y=X ?
      ZSize := Owner.read_float(buffer,name+'.ZSize');
    end;
end;

function Read_Struct_MeshBone(owner: TUTPackage; buffer: TStream;name_:string=''): TUT_Struct_MeshBone;
begin
  with result do
    begin
      Name := Owner.read_idx(buffer,utdmRefToName,name_+'.Name');
      Flags := Owner.read_dword(buffer,utdmFlags,name_+'.Flags');
      BonePos := Read_Struct_JointPos(owner, buffer,name_+'.BonePos');
      NumChildren := Owner.read_dword(buffer,utdmAsValue,name_+'.NumChildren');
      ParentIndex := Owner.read_dword(buffer,utdmAsValue,name_+'.ParentIndex');
    end;
end;

function Read_Struct_BoneInfIndex(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_BoneInfIndex;
begin
  with result do
    begin
      WeightIndex := Owner.read_word(buffer,utdmAsValue,name+'.WeightIndex');
      Number := Owner.read_word(buffer,utdmAsValue,name+'.Number');
      DetailA := Owner.read_word(buffer,utdmAsValue,name+'.DetailA');
      DetailB := Owner.read_word(buffer,utdmAsValue,name+'.DetailB');
    end;
end;

function Read_Struct_BoneInfluence(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_BoneInfluence;
begin
  with result do
    begin
      PointIndex := Owner.read_word(buffer,utdmAsValue,name+'.PointIndex');
      BoneWeight := Owner.read_word(buffer,utdmAsValue,name+'.BoneWeight');
    end;
end;

function Read_Struct_Coords(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Coords;
begin
  with result do
    begin
      Origin := Read_Struct_vector(owner, buffer,name+'.Origin');
      XAxis := Read_Struct_vector(owner, buffer,name+'.XAxis');
      YAxis := Read_Struct_vector(owner, buffer,name+'.YAxis');
      ZAXis := Read_Struct_vector(owner, buffer,name+'.ZAxis');
    end;
end;

function Read_Struct_NamedBone(owner: TUTPackage; buffer: TStream;name_:string=''): TUT_Struct_NamedBone;
begin
  with result do
    begin
      Name := owner.read_idx(buffer,utdmRefToName,name_+'.Name');
      Flags := Owner.read_dword(buffer,utdmFlags,name_+'.Flags');
      ParentIndex := Owner.read_dword(buffer,utdmAsValue,name_+'.ParentIndex');
    end;
end;

function Read_Struct_AnalogTrack(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_AnalogTrack;
var
  size3, c: integer;
begin
  with result do
    begin
      Flags := Owner.read_dword(buffer,utdmFlags,name+'.Flags');
      size3 := Owner.read_idx(buffer,utdmAsValue,name+'.KeyQuat Array Size');
      setlength(KeyQuat, CheckArrayLength(size3,buffer));
      for c := 0 to size3 - 1 do
        KeyQuat[c] := Read_Struct_Quat(owner, buffer,name+'.KeyQuat');
      size3 := Owner.read_idx(buffer,utdmAsValue,name+'.KeyPos Array Size');
      setlength(KeyPos, CheckArrayLength(size3,buffer));
      for c := 0 to size3 - 1 do
        KeyPos[c] := Read_Struct_Vector(owner, buffer,name+'.KeyPos');
      size3 := Owner.read_idx(buffer,utdmAsValue,name+'.KeyTime Array Size');
      setlength(KeyTime, CheckArrayLength(size3,buffer));
      for c := 0 to size3 - 1 do
        KeyTime[c] := owner.read_float(buffer,name+'.KeyTime');
    end;
end;

function Read_Struct_MotionChunk(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_MotionChunk;
var
  size2, b: integer;
begin
  with result do
    begin
      RootSpeed3D := Read_Struct_Vector(owner, buffer,name+'.RootSpeed3D');
      TrackTime := owner.read_float(buffer,name+'.TrackTime');
      StartBone := Owner.read_dword(buffer,utdmAsValue,name+'.StartBone');
      Flags := Owner.read_dword(buffer,utdmFlags,name+'.Flags');
      size2 := Owner.read_idx(buffer,utdmAsValue,name+'.BoneIndices Array Size');
      setlength(boneindices, CheckArrayLength(size2,buffer));
      for b := 0 to size2 - 1 do
        BoneIndices[b] := Owner.read_dword(buffer,utdmAsValue,name+'.BoneIndices');
      size2 := Owner.read_idx(buffer,utdmAsValue,name+'.AnimTracks Array Size');
      setlength(AnimTracks, CheckArrayLength(size2,buffer));
      for b := 0 to size2 - 1 do
        AnimTracks[b] := Read_Struct_AnalogTrack(owner, buffer,name+'.AnimTracks');
      RootTrack := Read_Struct_AnalogTrack(owner, buffer,name+'.RootTrack');
    end;
end;

function Read_Struct_Dependency(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Dependency;
begin
  with result do
    begin
      _Class := Owner.read_idx(buffer,utdmRefToObject,name+'.Class');
      Deep := Owner.read_dword(buffer,utdmAsValue,name+'.Deep');
      ScriptTextCRC := Owner.read_dword(buffer,utdmCRC,name+'.ScriptTextCRC');
    end;
end;

function Read_Struct_LabelEntry(owner: TUTPackage; buffer: TStream;name_:string=''): TUT_Struct_LabelEntry;
begin
  with result do
    begin
      Name := Owner.read_idx(buffer,utdmRefToName,name_+'.Name');
      iCode := Owner.read_dword(buffer,utdmOffset,name_+'.iCode');
    end;
end;

function Read_Struct_BspNode(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_BspNode;
begin
  with result do
    begin
      Plane := Read_Struct_Plane(owner, buffer,name+'.Plane');
      ZoneMask := owner.read_qword(buffer,utdmAsValue,name+'.ZoneMask');
      NodeFlags := owner.read_byte(buffer,utdmAsValue,name+'.NodeFlags');
      iVertPool := owner.read_idx(buffer,utdmAsValue,name+'.iVertPool');
      iSurf := owner.read_idx(buffer,utdmAsValue,name+'.iSurf');
      iFront := owner.read_idx(buffer,utdmAsValue,name+'.iFront');
      iBack := owner.read_idx(buffer,utdmAsValue,name+'.iBack');
      iPlane := owner.read_idx(buffer,utdmAsValue,name+'.iPlane');
      iCollisionBound := owner.read_idx(buffer,utdmAsValue,name+'.iCollisionBound');
      iRenderBound := owner.read_idx(buffer,utdmAsValue,name+'.iRenderBound');
      iZone[0] := owner.read_byte(buffer,utdmAsValue,name+'.iZone[0]');
      iZone[1] := owner.read_byte(buffer,utdmAsValue,name+'.iZone[1]');
      NumVertices := owner.read_byte(buffer,utdmAsValue,name+'.NumVertices');
      iLeaf[0] := owner.read_dword(buffer,utdmUnknown,name+'.iLeaf[0]');
      iLeaf[1] := owner.read_dword(buffer,utdmUnknown,name+'.iLeaf[1]');
      { Version 117 (UT2003)
        Plane
        QWORD
        2x DWORD
        4x FLOAT
        4x DWORD
        WORD
        BYTE/INDEX
        2x QWORD
        DWORD
      }
    end;
end;

function Read_Struct_BspSurf(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_BspSurf;
begin
  with result do
    begin
      Texture := owner.read_idx(buffer,utdmRefToObject,name+'.Texture');
      PolyFlags := owner.read_dword(buffer,utdmFlags,name+'.PolyFlags');
      pBase := owner.read_idx(buffer,utdmAsValue,name+'.pBase');
      vNormal := owner.read_idx(buffer,utdmAsValue,name+'.vNormal');
      vTextureU := owner.read_idx(buffer,utdmAsValue,name+'.vTextureU');
      vTextureV := owner.read_idx(buffer,utdmAsValue,name+'.vTextureV');
      iLightMap := owner.read_idx(buffer,utdmRefToObject,name+'.iLightMap');
      iBrushPoly := owner.read_idx(buffer,utdmRefToObject,name+'.iBrushPoly');
      PanU := owner.read_word(buffer,utdmAsValue,name+'.PanU');
      PanV := owner.read_word(buffer,utdmAsValue,name+'.PanV');
      Actor := owner.read_idx(buffer,utdmRefToObject,name+'.Actor');
      // Decals ?
      // Nodes ?
      { Version 117 (UT2003)
        Texture INDEX
        PolyFlags DWORD
        5x INDEX (pBase, vNormal, vTextureU, vTextureV, iLightMap ?)
        iBrushPoly INDEX
        5x FLOAT
      }
    end;
end;

function Read_Struct_FVert(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_FVert;
begin
  with result do
    begin
      pVertex := owner.read_idx(buffer,utdmAsValue,name+'.pVertex');
      iSide := owner.read_idx(buffer,utdmAsValue,name+'.iSide');
    end;
end;

function Read_Struct_Zone(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_ZoneProperties;
begin
  with result do
    begin
      ZoneActor := owner.read_idx(buffer,utdmRefToObject,name+'.ZoneActor');
      Connectivity := owner.read_qword(buffer,utdmAsValue,name+'.Connectivity');
      Visibility := owner.read_qword(buffer,utdmAsValue,name+'.Visibility');
      if owner.Version < 63 then        // TODO : fix this version?
        LastRenderTime := owner.read_float(buffer,name+'.LastRenderTime');
      if owner.Version>=117 then
        Owner.read_dword(buffer); // TODO : (Struct_Zone) unknown
    end;
end;

function Read_Struct_LightMap(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_LightMapIndex;
begin
  with result do
    begin
      DataOffset := owner.read_dword(buffer,utdmOffset,name+'.DataOffset');
      Pan := Read_Struct_Vector(owner, buffer,name+'.Pan');
      if owner.Version<117 then
        begin
          UClamp := owner.read_idx(buffer,utdmAsValue,name+'.UClamp');
          VClamp := owner.read_idx(buffer,utdmAsValue,name+'.VClamp');
        end;
      UScale := owner.read_float(buffer,name+'.UScale');
      VScale := owner.read_float(buffer,name+'.VScale');
      iLightActors := owner.read_dword(buffer,utdmAsValue,name+'.iLightActors');
    end;
end;

function Read_Struct_Leaf(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Leaf;
begin
  with result do
    begin
      iZone := owner.read_idx(buffer,utdmRefToObject,name+'.iZone');
      iPermeating := owner.read_idx(buffer,utdmAsValue,name+'.iPermeating');
      iVolumetric := owner.read_idx(buffer,utdmAsValue,name+'.iVolumetric');
      VisibleZones := owner.read_qword(buffer,utdmAsValue,name+'.VisibleZones');
    end;
end;

function Read_Struct_URL(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_URL;
var
  size, a: integer;
begin
  with result do
    begin
      Protocol := owner.read_sizedasciiz(buffer,name+'.Protocol');
      Host := owner.read_sizedasciiz(buffer,name+'.Host');
      Map := owner.read_sizedasciiz(buffer,name+'.Map');
      size := owner.read_idx(buffer,utdmAsValue,name+'.Options Array Size');
      setlength(Options, CheckArrayLength(size,buffer));
      for a := 0 to size - 1 do
        Options[a] := owner.read_sizedasciiz(buffer,name+'.Options');
      Portal := owner.read_sizedasciiz(buffer,name+'.Portal');
      Port := owner.read_dword(buffer,utdmAsValue,name+'.Port');
      Valid := owner.read_dword(buffer,utdmAsValue,name+'.Valid') <> 0;
    end;
end;

function Read_Struct_ReachSpec(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_ReachSpec;
begin
  with result do
    begin
      Distance := owner.read_dword(buffer,utdmAsValue,name+'.Distance');
      Start := owner.read_idx(buffer,utdmAsValue,name+'.Start');
      _End := owner.read_idx(buffer,utdmAsValue,name+'.End');
      CollisionRadius := owner.read_dword(buffer,utdmAsValue,name+'.CollisionRadius');
      CollisionHeight := owner.read_dword(buffer,utdmAsValue,name+'.CollisionHeight');
      ReachFlags := owner.read_dword(buffer,utdmFlags,name+'.ReachFlags');
      bPruned := owner.read_byte(buffer,utdmAsValue,name+'.bPruned');
    end;
end;

function Read_Struct_Map(owner: TUTPackage; buffer: TStream;name:string=''): TUT_Struct_Map;
begin
  with result do
    begin
      Key := owner.read_sizedasciiz(buffer,name+'.Key');
      Value := owner.read_sizedasciiz(buffer,name+'.Value');
    end;
end;

procedure RegisterKnownEnumValues(enumtype: string; values: array of string);
var
  i: integer;
begin
  setlength(KnownEnumValues, length(KnownEnumValues) + 1);
  KnownEnumValues[high(KnownEnumValues)].Enum := enumtype;
  setlength(KnownEnumValues[high(KnownEnumValues)].Values, length(values));
  for i := 0 to high(values) do
    KnownEnumValues[high(KnownEnumValues)].Values[i] := values[i];
end;

function GetKnownEnumValue(enumtype: string; index: integer): string;
var
  e: integer;
begin
  result := inttostr(index);
  for e := 0 to high(KnownEnumValues) do
    if lowercase(KnownEnumValues[e].Enum) = lowercase(enumtype) then
      begin
        if (index >= 0) and (index <= high(KnownEnumValues[e].Values)) then
          result := KnownEnumValues[e].Values[index];
        break;
      end;
end;

procedure RegisterNativeFunctionArray (gamehint:TUTPackage_GameHint;const functions:array of TNativeFunction);
var a,b:integer;
begin
  for a:=0 to high(RegisteredNativeFunctionArrays) do
    if RegisteredNativeFunctionArrays[a].GameHint=gamehint then exit;
  b:=length(RegisteredNativeFunctionArrays);
  setlength(RegisteredNativeFunctionArrays,b+1);
  RegisteredNativeFunctionArrays[b].GameHint:=gamehint;
  setlength(RegisteredNativeFunctionArrays[b].Functions,length(functions));
  for a:=0 to high(functions) do
    RegisteredNativeFunctionArrays[b].Functions[a]:=functions[a];
end;

procedure RegisterAllKnownEnumValues;
begin
  // This function registers some needed enums, the others can be read directly from the packages.
  RegisterKnownEnumValues('ESheerAxis', [
    'SHEER_None', 'SHEER_XY', 'SHEER_XZ', 'SHEER_YX', 'SHEER_YZ', 'SHEER_ZX', 'SHEER_ZY']);
  // the following two enums seems to be dropped in UT2003 in favor of others
  // declared normally, but since the others have other names (though same values)
  // these will stay for compatibility.
  RegisterKnownEnumValues('EDropType', [
    'DROP_FixedDepth', 'DROP_PhaseSpot', 'DROP_ShallowSpot', 'DROP_HalfAmpl',
      'DROP_RandomMover', 'DROP_FixedRandomMover', 'DROP_WhirlyThing', 'DROP_BigWhirly',
      'DROP_HorizontalLine', 'DROP_VerticalLine', 'DROP_DiagonalLine1',
      'DROP_DiagonalLine2', 'DROP_HorizontalOsc', 'DROP_VerticalOsc',
      'DROP_DiagonalOsc1', 'DROP_DiagonalOsc2', 'DROP_RainDrops', 'DROP_AreaClamp',
      'DROP_LeakyTap', 'DROP_DrippyTap']);
  RegisterKnownEnumValues('ESparkType', [
    'SPARK_Burn', 'SPARK_Sparkle', 'SPARK_Pulse', 'SPARK_Signal', 'SPARK_Blaze',
      'SPARK_OzHasSpoken', 'SPARK_Cone', 'SPARK_BlazeRight', 'SPARK_BlazeLeft',
      'SPARK_Cylinder', 'SPARK_Cylinder3D', 'SPARK_Lissajous', 'SPARK_Jugglers',
      'SPARK_Emit', 'SPARK_Fountain', 'SPARK_Flocks', 'SPARK_Eels', 'SPARK_Organic',
      'SPARK_WanderOrganic', 'SPARK_RandomCloud', ',SPARK_CustomCloud',
      'SPARK_LocalCloud', 'SPARK_Starts', 'SPARK_LineLightning',
      'SPARK_RampLightning', 'SPARK_SphereLightning', 'SPARK_Wheel', 'SPARK_Gametes',
      'SPARK_Sprinkler']);
  // following not used anymore
  {RegisterKnownEnumValues ('CsgOper',['CSG_Active', 'CSG_Add', 'CSG_Substract', 'CSG_Intersect', 'CSG_Deintersect']);
  RegisterKnownEnumValues ('DrawType',['DT_None', 'DT_Sprite', 'DT_Mesh', 'DT_Brush', 'DT_RopeSprite', 'DT_VerticalSprite', 'DT_TerraForm', 'DT_SpriteAnimOnce']);
  RegisterKnownEnumValues ('Style',['STY_None', 'STY_Normal', 'STY_Masked', 'STY_Translucent', 'STY_Modulated']);
  RegisterKnownEnumValues ('LightEffect',['LE_None', 'LE_TorchWaver', 'LE_FireWaver', 'LE_WateryShimmer', 'LE_Searchlight', 'LE_SlowWave', 'LE_FastWave', 'LE_CloudCast', 'LE_StaticSpot', 'LE_Shock', 'LE_Disco', 'LE_Warp', 'LE_Spotlight', 'LE_NonIncidence', 'LE_Shell', 'LE_OmniBumpMap', 'LE_Interference', 'LE_Cylinder', 'LE_Rotor', 'LE_Unused']);
  RegisterKnownEnumValues ('LightType',['LT_None', 'LT_Steady', 'LT_Pulse', 'LT_Blink', 'LT_Flicker', 'LT_Strobe', 'LT_BackdropLight', 'LT_SubtlePulse', 'LT_TexturePaletteOnce', 'LT_TexturePaletteLoop']);
  RegisterKnownEnumValues ('Physics',['PHYS_None', 'PHYS_Walking', 'PHYS_Falling', 'PHYS_Swimming', 'PHYS_Flying', 'PHYS_Rotating', 'PHYS_Projectile', 'PHYS_Rolling', 'PHYS_Interpolating', 'PHYS_MovingBrush', 'PHYS_Spider', 'PHYS_Trailer']);
  RegisterKnownEnumValues ('RemoteRole',['ROLE_None', 'ROLE_DumbProxy', 'ROLE_SimulatedProxy', 'ROLE_AutonomousProxy', 'ROLE_Authority']);
  RegisterKnownEnumValues ('DrawMode',['DRAW_Normal', 'DRAW_Lathe', 'DRAW_Lathe_2', 'DRAW_Lathe_3', 'DRAW_Lathe_4']);
  RegisterKnownEnumValues ('TimeDistribution',['DIST_Constant', 'DIST_Uniform', 'DIST_Gaussian']);
  RegisterKnownEnumValues ('AttitudeToPlayer',['ATTITUDE_Fear', 'ATTITUDE_Hate', 'ATTITUDE_Frenzy', 'ATTITUDE_Threaten', 'ATTITUDE_Ignore', 'ATTITUDE_Friendly', 'ATTITUDE_Follow']);
  RegisterKnownEnumValues ('Intelligence',['BRAINS_None', 'BRAINS_Reptile', 'BRAINS_Mammal', 'BRAINS_Human']);
  RegisterKnownEnumValues ('BumpType',['BT_PlayerBump', 'BT_PawnBump', 'BT_AnyBump']);
  RegisterKnownEnumValues ('MoverEncroachType',['ME_StopWhenEncroach', 'ME_ReturnWhenEncroach', 'ME_CrushWhenEncroach', 'ME_IgnoreWhenEncroach']);
  RegisterKnownEnumValues ('MoverGlideType',['MV_MoveByTime', 'MV_GlideByTime']);
  RegisterKnownEnumValues ('LODSet',['LODSET_None', 'LODSET_World', 'LODSET_Skin']);
  RegisterKnownEnumValues ('CompFormat',['TEXF_P8', 'TEXF_RGBA7', 'TEXF_RGB16', 'TEXF_DXT1', 'TEXF_RGB8', 'TEXF_RGBA8']);}
                        // could also be: TEXF_P8 ,  TEXF_RGB32 ,  TEXF_RGB64 ,  TEXF_DXT1 ,  TEXF_RGB24
end;

function KnownStructElementCount(name:string):integer;
begin
  name:=lowercase(name);
  if name = 'color' then
    result := 4
  else if name = 'vector' then
    result := 3
  else if name = 'pointregion' then
    result := 3
  else if name = 'rotator' then
    result := 3
  else if name = 'scale' then
    result := 3
  else if name = 'plane' then
    result := 4
  else if name = 'sphere' then
    result := 4
  else
    result:=0;
end;

function IsKnownStruct (name:string):boolean;
begin
  result:=KnownStructElementCount(name)>0;
end;

function KnownStructElement(name:string;i:integer):TKnownStructElement;
begin
  name:=lowercase(name);
  if name = 'color' then
    begin
      case i of
        0:result.Name:='R';
        1:result.Name:='G';
        2:result.Name:='B';
        3:result.Name:='A';
      end;
      result.SpecificTypeName:='';
      result.ValueType:=otByte;
    end
  else if name='vector' then
    begin
      case i of
        0:result.Name:='X';
        1:result.Name:='Y';
        2:result.Name:='Z';
      end;
      result.SpecificTypeName:='';
      result.ValueType:=otFloat;
    end
  else if name='rotator' then
    begin
      case i of
        0:result.Name:='Pitch';
        1:result.Name:='Yaw';
        2:result.Name:='Roll';
      end;
      result.SpecificTypeName:='';
      result.ValueType:=otInt;
    end
  else if (name='plane') or (name='sphere') then
    begin
      case i of
        0:result.Name:='X';
        1:result.Name:='Y';
        2:result.Name:='Z';
        3:result.Name:='W';
      end;
      result.SpecificTypeName:='';
      result.ValueType:=otFloat;
    end
  else if name='pointregion' then
    begin
      case i of
        0:begin
            result.Name:='Zone';
            result.SpecificTypeName:='ZoneInfo';
            result.ValueType:=otObject;
          end;
        1:begin
            result.Name:='iLeaf';
            result.SpecificTypeName:='';
            result.ValueType:=otInt;
          end;
        2:begin
           result.Name:='ZoneNumber';
           result.SpecificTypeName:='';
           result.ValueType:=otByte;
          end;
      end;
    end
  else if name='scale' then
    begin
      case i of
        0:begin
            result.Name:='Scale';
            result.SpecificTypeName:='Vector';
            result.ValueType:=otStruct;
          end;
        1:begin
            result.Name:='SheerRate';
            result.SpecificTypeName:='';
            result.ValueType:=otFloat;
          end;
        2:begin
           result.Name:='SheerAxis';
           result.SpecificTypeName:='ESheerAxis';
           result.ValueType:=otByte;
          end;
      end;
    end
end;

procedure Register2DClasses;
begin
  RegisterUTObjectClass('Palette', TUTObjectClassPalette);
  RegisterUTObjectClass('Font', TUTObjectClassFont);
  //RegisterUTObjectClass ('Bitmap',TUTObjectClassBitmap); {abstract}
  {****} RegisterUTObjectClass('Texture', TUTObjectClassTexture);
  {****}{****} RegisterUTObjectClass('Cubemap', TUTObjectClassCubeMap); {UT2003}
  {****}{****}// RegisterUTObjectClass('FractalTexture', TUTObjectClassFractalTexture); {abstract}
  {****}{****}{****} RegisterUTObjectClass('FireTexture', TUTObjectClassFireTexture);
  {****}{****}{****} RegisterUTObjectClass('IceTexture', TUTObjectClassIceTexture);
  {****}{****}{****} RegisterUTObjectClass('WaterTexture', TUTObjectClassWaterTexture);
  {****}{****}{****}{****} RegisterUTObjectClass('WaveTexture', TUTObjectClassWaveTexture);
  {****}{****}{****}{****} RegisterUTObjectClass('WetTexture', TUTObjectClassWetTexture);
  {****}{****}{****}{****} RegisterUTObjectClass('FluidTexture', TUTObjectClassFluidTexture);
  {****}{****}{****} RegisterUTObjectClass('MovieTexture', TUTObjectClassMovieTexture); // AA
  {****} RegisterUTObjectClass('ScriptedTexture', TUTObjectClassScriptedTexture);
end;

procedure Register3DClasses;
begin
  RegisterUTObjectClass('Primitive', TUTObjectClassPrimitive);
  {****} RegisterUTObjectClass('Mesh', TUTObjectClassMesh);
  {****}{****} RegisterUTObjectClass('LodMesh', TUTObjectClassLodMesh);
  {****}{****}{****} RegisterUTObjectClass('SkeletalMesh', TUTObjectClassSkeletalMesh);
  {****} RegisterUTObjectClass('VertMesh', TUTObjectClassVertMesh);{UT2003}
  {****} RegisterUTObjectClass('StaticMesh', TUTObjectClassStaticMesh);{UT2003}
  {****} RegisterUTObjectClass('ConvexVolume', TUTObjectClassConvexVolume);
  RegisterUTObjectClass('Animation', TUTObjectClassAnimation);
  RegisterUTObjectClass('MeshAnimation', TUTObjectClassMeshAnimation);{UT2003}

  RegisterUTObjectClass('IndexBuffer', TUTObjectClassIndexBuffer);{UT2003}
  RegisterUTObjectClass('VertexBuffer', TUTObjectClassVertexBuffer);{UT2003}

  RegisterUTObjectClass('Brush', TUTObjectClassBrush);
  {****} RegisterUTObjectClass('Mover', TUTObjectClassMover);
  RegisterUTObjectClass('Model', TUTObjectClassModel);
  RegisterUTObjectClass('Polys', TUTObjectClassPolys);
end;

procedure RegisterSoundClasses;
begin
  RegisterUTObjectClass('Sound', TUTObjectClassSound);
  RegisterUTObjectClass('SoundGroup', TUTObjectClassSoundGroup); {UT2003}
  RegisterUTObjectClass('ProceduralSound', TUTObjectClassProceduralSound); {UT2003}
  RegisterUTObjectClass('Music', TUTObjectClassMusic);
end;

procedure RegisterCodeClasses;
begin
  RegisterUTObjectClass('', TUTObjectClassClass); // special case, the class definitions do not have a class name
  RegisterUTObjectClass('TextBuffer', TUTObjectClassTextBuffer);
  RegisterUTObjectClass('Field', TUTObjectClassField);
  {****} RegisterUTObjectClass('Const', TUTObjectClassConst);
  {****} RegisterUTObjectClass('Enum', TUTObjectClassEnum);
  {****} RegisterUTObjectClass('Property', TUTObjectClassProperty);
  {****}{****} RegisterUTObjectClass('ByteProperty', TUTObjectClassByteProperty);
  {****}{****} RegisterUTObjectClass('IntProperty', TUTObjectClassIntProperty);
  {****}{****} RegisterUTObjectClass('BoolProperty', TUTObjectClassBoolProperty);
  {****}{****} RegisterUTObjectClass('FloatProperty', TUTObjectClassFloatProperty);
  {****}{****} RegisterUTObjectClass('ObjectProperty', TUTObjectClassObjectProperty);
  {****}{****}{****} RegisterUTObjectClass('ClassProperty', TUTObjectClassClassProperty);
  {****}{****} RegisterUTObjectClass('NameProperty', TUTObjectClassNameProperty);
  {****}{****} RegisterUTObjectClass('StructProperty', TUTObjectClassStructProperty);
  {****}{****} RegisterUTObjectClass('StrProperty', TUTObjectClassStrProperty);
  {****}{****} RegisterUTObjectClass('ArrayProperty', TUTObjectClassArrayProperty);
  {****}{****} RegisterUTObjectClass('FixedArrayProperty', TUTObjectClassFixedArrayProperty);
  {****}{****} RegisterUTObjectClass('MapProperty', TUTObjectClassMapProperty);
  {****}{****} RegisterUTObjectClass('StringProperty', TUTObjectClassStringProperty);
  {****}{****} RegisterUTObjectClass('DelegateProperty', TUTObjectClassDelegateProperty);
  {****}{****} RegisterUTObjectClass('PointerProperty', TUTObjectClassPointerProperty);
  {****} RegisterUTObjectClass('Struct', TUTObjectClassStruct);
  {****}{****} RegisterUTObjectClass('Function', TUTObjectClassFunction);
  {****}{****} RegisterUTObjectClass('State', TUTObjectClassState);
  {****}{****}{****} RegisterUTObjectClass('Class', TUTObjectClassClass);
end;

procedure RegisterOtherClasses;
begin
  RegisterUTObjectClass('Package', TUTObject);
  RegisterUTObjectClass('LevelBase', TUTObjectClassLevelBase);
  {****} RegisterUTObjectClass('Level', TUTObjectClassLevel);
  RegisterUTObjectClass('PackageCheckInfo', TUTObjectClassPackageCheckInfo);
end;

procedure RegisterAllClasses;
begin
  Register2DClasses;
  Register3DClasses;
  RegisterSoundClasses;
  RegisterCodeClasses;
  RegisterOtherClasses;
end;

initialization
  // do not localize class names
  UTPropertyClass := TUTProperty;
  ClearUTClassEquivalences;
  setlength(RegisteredUTClasses, 0);
  setlength(RegisteredNativeFunctionArrays, 0);
  RegisterAllKnownEnumValues;
end.

