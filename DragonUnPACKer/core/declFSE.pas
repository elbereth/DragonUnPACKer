unit declFSE;

// $Id: declFSE.pas,v 1.1.1.1.2.1 2004-10-03 17:11:10 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/declFSE.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is declFSE.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).


interface
uses classFSE, classConvert, classHyperRipper;

var FSE: TDrivers;
    CPlug: TPlugins;
    HPlug: THRPlugins;

function FSEInit(): TDrivers;
function CPlugInit(): TPlugins;
function HPlugInit(): THRPlugins;

implementation

function FSEInit(): TDrivers;
begin

  FSEInit := TDrivers.Create;

end;

function CPlugInit(): TPlugins;
begin

  Result := TPlugins.Create;

end;

function HPlugInit(): THRPlugins;
begin

  Result := THRPlugins.Create;

end;

end.
