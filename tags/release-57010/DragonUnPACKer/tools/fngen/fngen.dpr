program fngen;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

{$APPTYPE CONSOLE}

uses
  SysUtils;

const VERSION = '1';
      CHARLIST : array[0..36] of char = (
        '0','1','2','3','4','5','6','7','8','9',
        'a','b','c','d','e','f','g','h','i','j',
        'k','l','m','n','o','p','q','r','s','t',
        'u','v','w','x','y','z','-'
      );

var F: TextFile;
    curdatetime,disp,disptot,prefix,suffix: string;
    x1,x2,x3,x4,calc: integer;
begin

  write('fngen v'+VERSION+' by Elbereth');

  if (ParamCount <> 2) then
  begin
    writeln(' - usage: fngen <prefix> <suffix>');
    write('result: drv_default_mix_<timestamp>.lst file containing generated files.');
    exit;
  end;

  writeln;
  prefix := ParamStr(1);
  suffix := ParamStr(2);
  disp := '';
  for x1 := 0 to High(CHARLIST) do
    disp := disp + CHARLIST[x1];
  writeln('Prefix: '+prefix+ ' / Suffix: '+suffix+' / Charlist: '+disp);

  AssignFile(F, 'drv_default_mix.lst');
  Rewrite(F);
  datetimetostring(curdatetime,'yyyy-mm-dd hh:nn:ss',now);
  Writeln(F, '// Generated by fngen v'+VERSION+' on '+curdatetime);
  Writeln(F, '// Prefix: '+prefix);
  Writeln(F, '// Suffix: '+suffix);
  Writeln(F, '// Charlist: '+disp);
  Writeln(F, '//====START====//');

  writeln('Progress:');

  calc := Length(CHARLIST)*Length(CHARLIST);
  disptot := inttostr(calc*Length(CHARLIST));

  for x1 := 0 to High(CHARLIST) do
  begin
    write('[');
    Writeln(F, prefix+CHARLIST[x1]+suffix);
    for x2 := 0 to High(CHARLIST) do
    begin
      Writeln(F, prefix+CHARLIST[x1]+CHARLIST[x2]+suffix);
      for x3 := 0 to High(CHARLIST) do
      begin
        Writeln(F, prefix+CHARLIST[x1]+CHARLIST[x2]+CHARLIST[x3]+suffix);
        for x4 := 0 to High(CHARLIST) do
          Writeln(F, prefix+CHARLIST[x1]+CHARLIST[x2]+CHARLIST[x3]+CHARLIST[x4]+suffix);
      end;
      write('*');
    end;
    writeln('] '+inttostr(round(((x1+1)/Length(CHARLIST))*100))+'%');
  end;

  Writeln(F, '//=====END=====//');
  CloseFile(F);

end.