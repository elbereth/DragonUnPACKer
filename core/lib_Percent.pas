unit lib_Percent;

// $Id: lib_Percent.pas,v 1.1.1.1 2004-05-08 10:25:48 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/lib_Percent.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is lib_Percent.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface
procedure DisplayPercent(valu: integer);
procedure SetState(valu: string);
procedure SetFormat(valu: string);

implementation

uses Main;

procedure DisplayPercent(valu: integer);
begin

  dup5Main.Percent.Position := valu;

end;

procedure SetState(valu: string);
begin

  dup5Main.Status.Panels.Items[2].Text := valu;

end;

procedure SetFormat(valu: string);
begin

  dup5Main.Status.Panels.Items[3].Text := valu;

end;

end.
 