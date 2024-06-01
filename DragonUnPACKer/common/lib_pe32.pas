unit lib_pe32;

{$MODE Delphi}

interface

uses SysUtils, Types, Windows;

type ELinkDateRetrievalError = Exception;

function GetExecutableCompilationDateTime(): TDateTime;

implementation

function GetExecutableCompilationDateTime(): TDateTime;
var
  fs: TFormatSettings;
begin
  fs.ShortDateFormat:= 'yyyy mm dd';
  fs.DateSeparator:= '/';
  fs.TimeSeparator:=':';
  fs.LongTimeFormat := 'hh:nn';
  // date in a 2024/06/01 13:52:52 format
  result := StrToDateTime({$I %DATE%} + ' ' + {$I %TIME%}, fs);

end;

end.
