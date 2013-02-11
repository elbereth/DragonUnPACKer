unit cls_duplog;

// $Id: Main.pas 632 2013-01-29 18:50:13Z elbereth $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/Main.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is cls_duplog.pas, released January 31, 2013.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses Controls, Graphics, SysUtils;

type TDupLogMessageSeverity = (sevDebug=0, sevHigh=1, sevMedium=2, sevLow=3);

type TDupLogMessage = class(TObject)
     private
       _Date: TDateTime;
       _FontColor: TColor;
       _Level: TDupLogMessageSeverity;
       _Message: String;
       function getLevelHR(): char;
     public
       property Date: TDateTime read _Date;
       property FontColor: TColor read _FontColor write _FontColor;
       property Level: TDupLogMessageSeverity read _Level write _Level;
       property LevelHR: Char read getLevelHR;
       property Message: String read _Message write _Message;
       constructor Create(Message : String; Level: TDupLogMessageSeverity = sevMedium);
     end;

type TDupLog = class(TObject)
     private
       _Messages: array of TDupLogMessage;
       _BlockSize: integer;
       _MessageIndex: integer;
       _FlushAfter: integer;
       _FlushAtClose: boolean;
       _FlushedIndex: integer;
       _LogFilename: String;
       _LogFile: TextFile;
       function getNumMessages(): integer;
     public
       property Count: Integer read getNumMessages;
     published
       constructor Create(Filename : String);
       destructor Destroy; override;
       procedure addMessage(Message: String);
       procedure flushMessages;
     end;

implementation

constructor TDupLogMessage.create(Message : String; Level: TDupLogMessageSeverity = sevMedium);
begin

  _Date := Now();
  _FontColor := clBlack;
  _Level := Level;
  _Message := Message;

end;

function TDupLogMessage.getLevelHR: Char;
begin

  case _Level of
    sevDebug:
      result := 'D';
    sevHigh:
      result := 'H';
    sevMedium:
      result := 'M';
    sevLow:
      result := 'L';
  else
      result := '?';
  end;

end;

procedure TDupLog.flushMessages;
var x: integer;
begin

  for x := _FlushedIndex+1 to _MessageIndex do
    WriteLn(_LogFile,FormatDateTime('yyyy/mm/dd" "hh:nn:ss"."zzz',_Messages[x].Date)+' ['+_Messages[x].LevelHR+'] '+_Messages[x].Message);

  _FlushedIndex := _MessageIndex;

end;

function TDupLog.getNumMessages(): integer;
begin

  result := _MessageIndex + 1;

end;

constructor TDupLog.create(Filename: string);
begin

  _FlushAfter := 1;
  _FlushAtClose := true;
  _FlushedIndex := -1;
  _BlockSize := 100;
  _MessageIndex := -1;
  SetLength(_Messages,_BlockSize);
  _LogFilename := Filename;

  AssignFile(_LogFile, _LogFilename);
  if FileExists(_LogFilename) then
    Append(_LogFile)
  else
    Rewrite(_LogFile);

end;

destructor TDupLog.Destroy;
var x: integer;
begin

  if _FlushAtClose then
    flushMessages;

  CloseFile(_LogFile);

  if _Messages <> nil then
  begin
    for x := Low(_Messages) to High(_Messages) do
      FreeAndNil(_Messages[x]);
  end;

  inherited Destroy;

end;

procedure TDupLog.addMessage(Message: String);
begin

  Inc(_MessageIndex);
  if (_MessageIndex > High(_Messages)) then
    SetLength(_Messages,Length(_Messages)+_BlockSize);
  _Messages[_MessageIndex] := TDupLogMessage.Create(Message,sevDebug);

  if (_MessageIndex - _FlushedIndex) >= _FlushAfter then
    FlushMessages;

end;

end.
