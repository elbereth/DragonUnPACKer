{$define debug}
unit HashTrie;

{$MODE Delphi}

{
  Delphi implementation of HashTrie dynamic hashing method
  Full description available on www.softlab.od.ua

  Delphi 2,3,4,5
  Freware with source. 

  Copyright (c) 2000, Andre N Belokon, SoftLab
  Web     http://softlab.od.ua/
  Email   support@softlab.od.ua

  THIS SOFTWARE AND THE ACCOMPANYING FILES ARE DISTRIBUTED 
  "AS IS" AND WITHOUT WARRANTIES AS TO PERFORMANCE OF MERCHANTABILITY OR 
  ANY OTHER WARRANTIES WHETHER EXPRESSED OR IMPLIED.
  NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS OFFERED.
  THE USER MUST ASSUME THE ENTIRE RISK OF USING THE ACCOMPANYING CODE.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions: 

  1. The origin of this software must not be misrepresented, you must 
     not claim that you wrote the original software. If you use this software 
     in a product, an acknowledgment in the product documentation 
     would be appreciated but is not required. 
  2. Altered source versions must be plainly marked as such, and must not be 
     misrepresented as being the original software.
  3. Original copyright may not be removed or altered from any source 
     distribution.
  4. All copyright of HashTrie dynamic hashing method belongs to Andre N Belokon, 
     SoftLab MIL-TEC Ltd.
}


interface

uses Windows, SysUtils;

const
  // DON'T CHANGE LeafSize VALUE !!! MUST BE EQ 256
  // because some code optimization used
  LeafSize = 256;
  // determines max length of the list
  // very big|small values decrease performance
  // optimum value in range 4..16
  BucketSize = 8;

type
  TLinkedItem = class
  public
    destructor Destroy; override;
  private
    Value: DWORD;
    Data: DWORD;
    Next: TLinkedItem;
    constructor Create(FValue,FData: DWORD; FNext: TLinkedItem);
  end;

  THashTrie = class; // forward
  TTraverseProc = procedure (UserData,UserProc: Pointer;
    Value,Data: DWORD; var Done: Boolean) of object;

  TTreeItem = class
  public
    destructor Destroy; override;
  private
    Owner: THashTrie;
    Level: integer;
    Filled: integer;
    Items: array[0..LeafSize-1] of TObject;
    constructor Create(AOwner: THashTrie);
    function ROR(Value: DWORD): DWORD;
    function RORN(Value: DWORD; Level: integer): DWORD;
    procedure AddDown(Value,Data,Hash: DWORD);
    procedure Delete(Value,Hash: DWORD);
    function Find(Value,Hash: DWORD; var Data: DWORD): Boolean;
    function Traverse(UserData,UserProc: Pointer; TraverseProc: TTraverseProc): Boolean;
  end;

  THashTrie = class
  private
    Root: TTreeItem;
  protected
    function HashValue(Value: DWORD): DWORD; virtual; abstract;
    procedure DestroyItem(var Value,Data: DWORD); virtual; abstract;
    function CompareValue(Value1,Value2: DWORD): Boolean; virtual; abstract;
    procedure AddDown(Value,Data,Hash: DWORD);
    procedure Delete(Value,Hash: DWORD);
    function Find(Value,Hash: DWORD; var Data: DWORD): Boolean;
    procedure Traverse(UserData,UserProc: Pointer; TraverseProc: TTraverseProc);
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TStrHashTraverseProc = procedure (UserData: Pointer; const Value: string;
    Data: TObject; var Done: Boolean);
  TStrHashTraverseMeth = procedure (UserData: Pointer; const Value: string;
    Data: TObject; var Done: Boolean) of object;

  TStringHashTrie = class(THashTrie)
  private
    FCaseSensitive: Boolean;
    FAutoFreeObjects: Boolean;
  protected
    function HashValue(Value: DWORD): DWORD; override;
    procedure DestroyItem(var Value,Data: DWORD); override;
    function CompareValue(Value1,Value2: DWORD): Boolean; override;
    function HashStr(const S: string): DWORD;
    procedure TraverseProc(UserData,UserProc: Pointer;
      Value,Data: DWORD; var Done: Boolean);
    procedure TraverseMeth(UserData,UserProc: Pointer;
      Value,Data: DWORD; var Done: Boolean);
  public
    constructor Create; override;
    procedure Add(const S: string; Data: TObject);
    procedure Delete(const S: string);
    function Find(const S: string; var Data: TObject): Boolean;
    procedure Traverse(UserData: Pointer; UserProc: TStrHashTraverseProc); overload;
    procedure Traverse(UserData: Pointer; UserProc: TStrHashTraverseMeth); overload;
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive default False;
    property AutoFreeObjects: Boolean read FAutoFreeObjects write FAutoFreeObjects default False;
  end;

function CalcStrCRC32(const S: string): DWORD;
  
{$ifdef debug}
type
  TLenStat = array[1..BucketSize] of integer;

procedure Stat(ht: THashTrie; var MaxLevel, PeakCnt, FillCnt, EmptyCnt: integer;
  var LenStat: TLenStat);
{$endif}

implementation

{$ifdef debug}
procedure Stat(ht: THashTrie; var MaxLevel, PeakCnt, FillCnt, EmptyCnt: integer;
  var LenStat: TLenStat);

  procedure TreeStat(ht: TTreeItem);
  var j,i: integer;
      LinkedItem: TLinkedItem;
  begin
    Inc(PeakCnt);
    if ht.Level+1 > MaxLevel then
      MaxLevel:=ht.Level+1;
    for j:=0 to LeafSize-1 do
      if ht.Items[j] <> nil then begin
        Inc(FillCnt);
        if ht.Items[j] is TTreeItem then begin
          TreeStat(TTreeItem(ht.Items[j]));
        end else begin
          i:=0;
          LinkedItem:=TLinkedItem(ht.Items[j]);
          while LinkedItem <> nil do begin
            Inc(i);
            LinkedItem:=LinkedItem.Next;
          end;
          LenStat[i]:=LenStat[i]+1;
        end;
      end else
        Inc(EmptyCnt);
  end;
begin
  if ht.Root <> nil then
    TreeStat(ht.Root);
end;
{$endif}

{ TTreeItem }

procedure TTreeItem.AddDown(Value, Data, Hash: DWORD);
var i,j: integer;
    TreeItem: TTreeItem;
    LinkedItem: TLinkedItem;
begin
  i:=Hash and $FF;
  if Items[i] = nil then begin
    Items[i]:=TLinkedItem.Create(Value,Data,nil);
    Inc(Filled);
  end else if Items[i] is TTreeItem then begin
    TTreeItem(Items[i]).AddDown(Value,Data,ROR(Hash));
  end else begin
    j:=0;
    LinkedItem:=TLinkedItem(Items[i]);
    while LinkedItem <> nil do begin
      if Owner.CompareValue(LinkedItem.Value,Value) then begin
        // found
        LinkedItem.Data:=Data;
        Exit;
      end;
      LinkedItem:=LinkedItem.Next;
      Inc(j)
    end;
    if j >= BucketSize then begin
      // full
      TreeItem:=TTreeItem.Create(Owner);
      TreeItem.Level:=Level+1;
      LinkedItem:=TLinkedItem(Items[i]);
      while LinkedItem <> nil do begin
        TreeItem.AddDown(LinkedItem.Value, LinkedItem.Data,
                         RORN(Owner.HashValue(LinkedItem.Value), Level+1));
        LinkedItem:=LinkedItem.Next;
      end;
      TreeItem.AddDown(Value,Data,ROR(Hash));
      FreeAndNil(TLinkedItem(Items[i]));
      Items[i]:=TreeItem;
    end else
      Items[i]:=TLinkedItem.Create(Value,Data,TLinkedItem(Items[i]));
  end;
end;

constructor TTreeItem.Create(AOwner: THashTrie);
var j: integer;
begin
  Owner:=AOwner;
  Level:=0;
  Filled:=0;
  for j:=0 to LeafSize-1 do Items[j]:=nil;
end;

procedure TTreeItem.Delete(Value, Hash: DWORD);
var i: integer;
//    TreeItem: TTreeItem;
    PrevLinkedItem,LinkedItem: TLinkedItem;
begin
  i:=Hash and $FF;
  if Items[i] = nil then begin
    Exit;
  end else if Items[i] is TTreeItem then begin
    TTreeItem(Items[i]).Delete(Value,ROR(Hash));
    if TTreeItem(Items[i]).Filled = 0 then begin
      FreeAndNil(TTreeItem(Items[i]));
      Items[i]:=nil;
    end;
  end else begin
    PrevLinkedItem:=nil;
    LinkedItem:=TLinkedItem(Items[i]);
    while LinkedItem <> nil do begin
      if Owner.CompareValue(LinkedItem.Value,Value) then begin
        // found
        if PrevLinkedItem = nil then begin
          Items[i]:=LinkedItem.Next;
          if Items[i] = nil then
            Dec(Filled);
        end else
          PrevLinkedItem.Next:=LinkedItem.Next;
        LinkedItem.Next:=nil;
        Owner.DestroyItem(LinkedItem.Value,LinkedItem.Data);
        FreeAndNil(LinkedItem);
        Exit;
      end;
      PrevLinkedItem:=LinkedItem;
      LinkedItem:=LinkedItem.Next;
    end;
  end;
end;

destructor TTreeItem.Destroy;
var j: integer;
    LinkedItem: TLinkedItem;
begin
  for j:=0 to LeafSize-1 do
    if Items[j] <> nil then
      if Items[j] is TTreeItem then
        TTreeItem(Items[j]).Free
      else begin
        LinkedItem:=TLinkedItem(Items[j]);
        while LinkedItem <> nil do begin
          Owner.DestroyItem(LinkedItem.Value,LinkedItem.Data);
          LinkedItem:=LinkedItem.Next;
        end;
        FreeAndNil(TLinkedItem(Items[j]));
      end;
  inherited;
end;

function TTreeItem.Find(Value, Hash: DWORD; var Data: DWORD): Boolean;
var i: integer;
//    TreeItem: TTreeItem;
    LinkedItem: TLinkedItem;
begin
  Result:=False;
  i:=Hash and $FF;
  if Items[i] = nil then begin
    Exit;
  end else if Items[i] is TTreeItem then begin
    Result:=TTreeItem(Items[i]).Find(Value,ROR(Hash),Data);
  end else begin
    LinkedItem:=TLinkedItem(Items[i]);
    while LinkedItem <> nil do begin
      if Owner.CompareValue(LinkedItem.Value,Value) then begin
        // found
        Data:=LinkedItem.Data;
        Result:=True;
        Exit;
      end;
      LinkedItem:=LinkedItem.Next;
    end;
  end;
end;

function TTreeItem.ROR(Value: DWORD): DWORD;
begin
  Result:=((Value and $FF) shl 24) or ((Value shr 8) and $FFFFFF);
end;

function TTreeItem.RORN(Value: DWORD; Level: integer): DWORD;
begin
  Result:=Value;
  while Level > 0 do begin
    Result:=ROR(Result);
    Dec(Level);
  end;
end;

function TTreeItem.Traverse(UserData,UserProc: Pointer;
  TraverseProc: TTraverseProc): Boolean;
var j: integer;
    LinkedItem: TLinkedItem;
begin
  Result:=False;
  for j:=0 to LeafSize-1 do
    if Items[j] <> nil then begin
      if Items[j] is TTreeItem then begin
        Result:=TTreeItem(Items[j]).Traverse(UserData,UserProc,TraverseProc);
      end else begin
        LinkedItem:=TLinkedItem(Items[j]);
        while LinkedItem <> nil do begin
          TraverseProc(UserData,UserProc,LinkedItem.Value,LinkedItem.Data,Result);
          LinkedItem:=LinkedItem.Next;
        end;
      end;
      if Result then Exit;
    end;
end;

{ TLinkedItem }

constructor TLinkedItem.Create(FValue,FData: DWORD; FNext: TLinkedItem);
begin
  Value:=FValue;
  Data:=FData;
  Next:=FNext;
end;

destructor TLinkedItem.Destroy;
begin
  if Next <> nil then
    FreeAndNil(Next);
end;

{ THashTrie }

procedure THashTrie.AddDown(Value,Data,Hash: DWORD);
begin
  if Root = nil then
    Root:=TTreeItem.Create(Self);
  Root.AddDown(Value,Data,Hash);
end;

procedure THashTrie.Delete(Value,Hash: DWORD);
begin
  if Root <> nil then
    Root.Delete(Value,Hash);
end;

function THashTrie.Find(Value,Hash: DWORD; var Data: DWORD): Boolean;
begin
  if Root <> nil then
    Result:=Root.Find(Value,Hash,Data)
  else
    Result:=False;
end;

constructor THashTrie.Create;
begin
  inherited;
  Root:=nil;
end;

destructor THashTrie.Destroy;
begin
  if Root <> nil then FreeAndNil(Root);
  inherited;
end;

procedure THashTrie.Traverse(UserData, UserProc: Pointer;
  TraverseProc: TTraverseProc);
begin
  if Root <> nil then
    Root.Traverse(UserData, UserProc, TraverseProc);
end;

{ TStringHashTrie }

procedure TStringHashTrie.Add(const S: string; Data: TObject);
begin
  AddDown(DWORD(NewStr(S)),DWORD(Data),HashStr(S));
end;

function TStringHashTrie.CompareValue(Value1, Value2: DWORD): Boolean;
begin
  if FCaseSensitive then
    Result:=PString(Value1)^ = PString(Value2)^
  else
    Result:=ANSICompareText(PString(Value1)^,PString(Value2)^) = 0;
end;

constructor TStringHashTrie.Create;
begin
  inherited;
  FCaseSensitive:=False;
  FAutoFreeObjects:=False;
end;

procedure TStringHashTrie.Delete(const S: string);
begin
  inherited Delete(DWORD(@S),HashStr(S));
end;

procedure TStringHashTrie.DestroyItem(var Value,Data: DWORD);
begin
  DisposeStr(PString(Value));
  if FAutoFreeObjects then
    FreeAndNil(TObject(Data));
  Value:=0;
  Data:=0;
end;

function TStringHashTrie.Find(const S: string; var Data: TObject): Boolean;
begin
  Result:=inherited Find(DWORD(@S),HashStr(S),DWORD(Data));
end;

function TStringHashTrie.HashStr(const S: string): DWORD;
{var i: integer;}
begin
  if CaseSensitive then
    Result:=CalcStrCRC32(S)
  else
    Result:=CalcStrCRC32(ANSIUpperCase(S));

{ another hash fucn with good performance
  see code at the end of this unit
  if CaseSensitive then
    Result:=HashP2Str(S)
  else
    Result:=HashP2Str(ANSIUpperCase(S));
}

{ simple hash-func. don't use it !!!
  result:=Length(S);
  for i:=1 to Length(S) do
    if CaseSensitive then
      Result:= ((Result shl 5) xor (Result shr 27)) xor Ord(S[i])
    else
      Result:= ((Result shl 5) xor (Result shr 27)) xor Ord(ANSIUpperCase(S)[i]);
}
end;

function TStringHashTrie.HashValue(Value: DWORD): DWORD;
begin
  Result:=HashStr(PString(Value)^);
end;

procedure TStringHashTrie.Traverse(UserData: Pointer;
  UserProc: TStrHashTraverseProc);
begin
  inherited Traverse(UserData,@UserProc,TraverseProc);
end;

procedure TStringHashTrie.TraverseProc(UserData, UserProc: Pointer; Value,
  Data: DWORD; var Done: Boolean);
begin
  TStrHashTraverseProc(UserProc)(UserData,PString(Value)^,TObject(Data),Done);
end;

procedure TStringHashTrie.Traverse(UserData: Pointer; UserProc: TStrHashTraverseMeth);
begin
  inherited Traverse(UserData,@TMethod(UserProc),TraverseMeth);
end;

procedure TStringHashTrie.TraverseMeth(UserData, UserProc: Pointer; Value,
  Data: DWORD; var Done: Boolean);
type
  PTStrHashTraverseMeth = ^TStrHashTraverseMeth;
begin
  PTStrHashTraverseMeth(UserProc)^(UserData,PString(Value)^,TObject(Data),Done);
end;

{ dynamic crc32 table }

const
  CRC32_POLYNOMIAL = $EDB88320;
var
  Ccitt32Table: array[0..255] of DWORD;

function CalcStrCRC32(const S: string): DWORD;
var j: integer;
begin
  Result:=$FFFFFFFF;
  for j:=1 to Length(S) do
    Result:= (((Result shr 8) and $00FFFFFF) xor (Ccitt32Table[(Result xor byte(S[j])) and $FF]));
end;

procedure BuildCRCTable;
var i, j: longint;
    value: DWORD;
begin
  for i := 0 to 255 do begin
    value := i;
    for j := 8 downto 1 do
      if ((value and 1) <> 0) then
        value := (value shr 1) xor CRC32_POLYNOMIAL
      else
        value := value shr 1;
    Ccitt32Table[i] := value;
  end
end;

{ another hash func with good performance
  but more slow than CRC32

function HashP2(const Buff; buffLen: integer; initval: DWORD): DWORD;
var a,b,c: DWORD;  // the internal state
    len: integer;  // how many key bytes still need mixing
    k: PDWORD;
    kc: PByte;
  procedure hash_mix(var a,b,c: DWORD);
  begin
    a := a-b;  a := a-c;  a := a xor (c shr 13);
    b := b-c;  b := b-a;  b := b xor (a shl 8);
    c := c-a;  c := c-b;  c := c xor (b shr 13);
    a := a-b;  a := a-c;  a := a xor (c shr 12);
    b := b-c;  b := b-a;  b := b xor (a shl 16);
    c := c-a;  c := c-b;  c := c xor (b shr 5);
    a := a-b;  a := a-c;  a := a xor (c shr 3);
    b := b-c;  b := b-a;  b := b xor (a shl 10);
    c := c-a;  c := c-b;  c := c xor (b shr 15);
  end;
begin
   // Set up the internal state
   len := buffLen;
   k := PDWORD(@Buff);
   a := $9E3779B9;  // the golden ratio; an arbitrary value
   b := a;
   c := initval;    // variable initialization of internal state
   //---------------------------------------- handle most of the key
   while len >= 12 do begin
      a:=a+k^; Inc(k);
      b:=b+k^; Inc(k);
      c:=c+k^; Inc(k);
      hash_mix(a,b,c);
      Dec(len,12);
   end;
   //------------------------------------- handle the last 11 bytes
   c := c+DWORD(buffLen);
   kc := PByte(integer(k)+len-1);
   while len > 0 do begin
     case len of  // all the case statements fall through
       11: c := c+(kc^ shl 24);
       10: c := c+(kc^ shl 16);
       9 : c := c+(kc^ shl 8);
        // the first byte of c is reserved for the Len 
       8 : b := b+(kc^ shl 24);
       7 : b := b+(kc^ shl 16);
       6 : b := b+(kc^ shl 8);
       5 : b := b+kc^;
       4 : a := a+(kc^ shl 24);
       3 : a := a+(kc^ shl 16);
       2 : a := a+(kc^ shl 8);
       1 : a := a+kc^;
     end;
     Dec(len); Dec(kc);
   end;
   hash_mix(a,b,c);
   //-------------------------------------------- report the result
   Result := c;
end;

function HashP2Str(const Str: string): DWORD;
var S: string;
begin
  S:=ANSIUpperCase(Str);
  Result:=HashP2(S[1],Length(S),0);
end; }

initialization
  BuildCRCTable;
end.
