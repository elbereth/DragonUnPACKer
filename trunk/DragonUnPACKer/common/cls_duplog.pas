unit cls_duplog;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is cls_duplog.pas, released January 31, 2013.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses Controls, Graphics, SysUtils, StdCtrls, ComCtrls, ShellApi;

// Enum type for the message severity
type TDupLogMessageSeverity = (sevDebug=0, sevLow=1, sevMedium=2, sevHigh=3, sevError=4);

// The class that stores the message
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
       procedure appendMessage(Suffix: String);
     end;

// The class for the actual logging facility
type TDupLog = class(TObject)
     private
       _Messages: array of TDupLogMessage;
       _BlockSize: integer;
       _MessageIndex: integer;
       _FlushAfter: integer;
       _FlushAtClose: boolean;
       _FlushedIndex: integer;
       _LogIntoFile: boolean;
       _LogIntoMemo: boolean;
       _LogIntoRichEdit: boolean;
       _LogFilename: String;
       _LogFile: TextFile;
       _LogMemo: TMemo;
       _LogRichEdit: TRichEdit;
       _LogRichEditMinLevel: TDupLogMessageSeverity;
       function getNumMessages(): integer;
     public
       property Count: Integer read getNumMessages;
     published
       constructor Create();
       destructor Destroy; override;
       procedure enableLogIntoFile(Filename: string);
       procedure enableLogIntoMemo(Memo: TMemo);
       procedure enableLogIntoRichEdit(RichEdit: TRichEdit; minLevel: TDupLogMessageSeverity = sevLow);
       procedure setRichLogMinLevel(minLevel: TDupLogMessageSeverity = sevLow);
       procedure addMessage(Message: String; Level: TDupLogMessageSeverity = sevMedium);
       procedure appendMessage(Suffix: String);
       procedure appendMessageIf(Suffix: String; MinLevel: TDupLogMessageSeverity);
       procedure flushMessages;
     end;

implementation

uses Main;

// Create a Log Message, by default uses todays date and if level is not specified it will have sevMedium level
constructor TDupLogMessage.create(Message : String; Level: TDupLogMessageSeverity = sevMedium);
begin

  _Date := Now();
  _FontColor := clBlack;
  _Level := Level;
  _Message := Message;

end;

procedure TDupLogMessage.appendMessage(Suffix: String);
begin

  _Message := _Message + ' ' + Suffix;

end;

// Returns the severity level as a displayable char
function TDupLogMessage.getLevelHR: Char;
begin

  case _Level of
    sevError:
      result := 'E';
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

procedure TDupLog.appendMessage(Suffix: string);
begin

  _Messages[_MessageIndex].appendMessage(Suffix);
  if (_MessageIndex <= _FlushedIndex) then
  begin
    if _LogIntoFile then
      Write(_LogFile,' '+Suffix);

    if _LogIntoRichEdit and (_Messages[_MessageIndex].Level >= _LogRichEditMinLevel) then
    begin
      _LogRichEdit.Lines.Strings[_LogRichEdit.Lines.Count-1] := _LogRichEdit.Lines.Strings[_LogRichEdit.Lines.Count-1]+' '+Suffix;
      _LogRichEdit.Refresh;
    end;
  end;

end;

procedure TDupLog.appendMessageIf(Suffix: String; MinLevel: TDupLogMessageSeverity);
begin

  if (_Messages[_MessageIndex].Level >= MinLevel) then
    appendMessage(Suffix);

end;

// Flush the messages into the respective logging destinations (file, TRichEdit, TMemo, ..)
procedure TDupLog.flushMessages;
var x: integer;
    dateMsg: string;
begin

  if _LogIntoFile or _LogIntoRichEdit or _LogIntoMemo then
  begin

    for x := _FlushedIndex+1 to _MessageIndex do
    begin

      dateMsg := FormatDateTime('yyyy/mm/dd" "hh:nn:ss"."zzz',_Messages[x].Date);

      if _LogIntoFile then
      begin
        WriteLn(_LogFile);
        Write(_LogFile,dateMsg+' ['+_Messages[x].LevelHR+'] '+_Messages[x].Message);
      end;

      if _LogIntoRichEdit and (_Messages[x].Level >= _LogRichEditMinLevel) then
      begin
        if _LogRichEdit.Lines.Count >= 32760 then
        _LogRichEdit.Lines.Delete(0);

        _LogRichEdit.Lines.Add(dateMsg+' ['+_Messages[x].LevelHR+'] '+_Messages[x].Message);
        _LogRichEdit.SelStart := _LogRichEdit.GetTextLen;
        _LogRichEdit.SelLength := 0;
        _LogRichEdit.ScrollBy(0,_LogRichEdit.Lines.Count);
        _LogRichEdit.Refresh;
        // EM_LINESCROLL = $00B6;
        _LogRichEdit.Perform($00B6,0,1);
      end;
    end;

    _FlushedIndex := _MessageIndex;

  end;

end;

// This will return the current number of messages in the log facility
function TDupLog.getNumMessages(): integer;
begin

  result := _MessageIndex + 1;

end;

// Creation of the logging facility (by default no logging destinations)
constructor TDupLog.create();
begin

  _FlushAfter := 1;
  _FlushAtClose := true;
  _FlushedIndex := -1;
  _BlockSize := 100;
  _MessageIndex := -1;
  SetLength(_Messages,_BlockSize);

  _LogIntoFile := false;
  _LogIntoMemo := false;
  _LogIntoRichEdit := false;

end;

// Destruction of the logging facility
destructor TDupLog.Destroy;
var x: integer;
begin

  if _FlushAtClose then
    flushMessages;

  if (_LogIntoFile) then
    CloseFile(_LogFile);

  if _Messages <> nil then
  begin
    for x := Low(_Messages) to High(_Messages) do
      FreeAndNil(_Messages[x]);
  end;

  inherited Destroy;

end;

// Add a message to the logging facility, by default uses sevMedium level
procedure TDupLog.addMessage(Message: String; Level: TDupLogMessageSeverity = sevMedium);
begin

  Inc(_MessageIndex);
  if (_MessageIndex > High(_Messages)) then
    SetLength(_Messages,Length(_Messages)+_BlockSize);
  _Messages[_MessageIndex] := TDupLogMessage.Create(Message,Level);

  if (_MessageIndex - _FlushedIndex) >= _FlushAfter then
    FlushMessages;

end;

// Enable the file logging destination
procedure TDupLog.enableLogIntoFile(Filename: String);
begin

  _LogFilename := Filename;

  AssignFile(_LogFile, _LogFilename);
  if FileExists(_LogFilename) then
    Append(_LogFile)
  else
    Rewrite(_LogFile);

  _LogIntoFile := true;

end;

// Enable the TRichEdit logging destination
// TODO Find replacement for Lazarus
procedure TDupLog.enableLogIntoRichEdit(RichEdit: TRichEdit; minLevel: TDupLogMessageSeverity = sevLow);
begin

  if Assigned(RichEdit) then
  begin
    _LogRichEdit := RichEdit;
    _LogRichEditMinLevel := minLevel;
    _LogIntoRichEdit := true;
  end;

end;

// Enable the TMemo logging destination
// Fallback from TRichEdit for a possible switch to Lazarus
procedure TDupLog.enableLogIntoMemo(Memo: TMemo);
begin

  if Assigned(Memo) then
  begin
    _LogMemo := Memo;
    _LogIntoMemo := true;
  end;

end;

// Set the minimum message severity to log to the TRichEdit destination
procedure TDupLog.setRichLogMinLevel(minLevel: TDupLogMessageSeverity = sevLow);
begin

  _LogRichEditMinLevel := minLevel;

end;

end.
