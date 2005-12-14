unit lib_language;

// $Id: lib_language.pas,v 1.5 2005-12-14 16:53:29 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/common/lib_language.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is lib_language.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//
// =============================================================================
// Language (DLNG) Management Library
// =============================================================================
//
//  Functions:
//  function DLNGStr(sch: string): string;
//  function GetFont(): String;
//  function GetIcon(fil: string): TBitmap;
//  function GetLanguageInfo(fil: string; out Name, Author, URL, Email,
//                           FontName: String; out IsIcon: boolean): Boolean;
//  procedure LoadInternalLanguage();
//  procedure LoadLanguage(fil: string);
//  function ReplaceValue(substr: string; str: string; newval: string): string;
//
// -----------------------------------------------------------------------------

interface
uses Graphics, Zlib;

function GetIcon(fil: string): TBitmap;
function GetFont(): String;
function GetLanguageInfo(fil: string; out Name, Author, URL, Email, FontName: String; out IsIcon: boolean): Boolean;
procedure LoadLanguage(fil: string);
procedure LoadInternalLanguage();
function DLNGStr(sch: string): string;
function ReplaceValue(substr: string; str: string; newval: string): string;

var curlanguage : string = '';

implementation

uses SysUtils, forms,Dialogs,lib_zlib,lib_crc,spec_DLNG,Classes,lib_binutils;

type
   Internal_Tab = record
     ID: string;
     Value: WideString;
   end;

const DLNG_VERSION : byte = 4;
      DLNG_PRGVER : byte = 9;

var tabLNG: array[1..1000] of Internal_Tab;
    numLNG: integer = 0;
    UseInternalLanguage: Boolean = True;
    SelectedFontName: String;

procedure LoadLanguage(fil: string);
var HDR: DLNG_Header_v4;
    HDRX: DLNG_ExtendedHeader;
    lng,x: integer;
    Idx: array[1..1000] of DLNG_IndexEntry_v4;
    inpFileStm: THandleStream;
    dataStm: TMemoryStream;
    decompStm: TDecompressionStream;
begin

  if FileExists(fil) then
  begin
    lng := FileOpen(fil, (fmOpenRead or fmShareExclusive));
    try
      FileRead(lng,HDR,SizeOf(HDR));

      if HDR.ID <> 'DLNG'+chr(26) then
        MessageDlg('This is not a valid Dragon Software Language file.'+chr(10)+'Please remove this file:'+chr(10)+chr(10)+fil,mtWarning,[mbOk],0)
      else
        if HDR.Version <> DLNG_VERSION then
          MessageDlg('Unsupported version of Dragon Software Language file.'+chr(10)+chr(10)+'Needed: version 4'+chr(10)+'File: version '+IntToStr(HDR.Version),mtWarning,[mbok],0)
        else
          if HDR.PrgID <> 'UP' then
            MessageDlg('This Language file is not for Dragon UnPACKer.',mtWarning,[mbok],0)
          else
            if HDR.PrgVER <> DLNG_PRGVER then
              MessageDlg('This Language file is not for this version of Dragon UnPACKer.',mtWarning,[mbok],0)
            else
            begin

//  MessageDlg(HDR.ID,mtInformation,[mbOk],0);

              HDRX.Name := Get8u(lng);
              HDRX.Author := Get8u(lng);
              HDRX.URL := Get8u(lng);
              HDRX.Email := Get8u(lng);
              HDRX.FontName := Get8u(lng);
              SelectedFontName := HDRX.FontName;
//      messagedlg(HDRX.Name + chr(10) + HDRX.Author + chr(10) + HDRX.URL + chr(10) + HDRX.Email  ,mtInformation,[mbOk],0);

//      messagedlg(inttostr(HDR.BodySizeComp),mtInformation,[mbOk],0);

//      crc := getstrCrc32(HDRX.Name + HDRX.Author + HDRX.URL + HDRX.Email + BigStr);

//      MessageDlg(IntToStr(crc)+chr(10)+IntToStr(HDR.FileCRC),mtInformation,[mbok],0);

              dataStm := TMemoryStream.Create;
              try

                inpFileStm := THandleStream.Create(lng);
                try
                  inpFileStm.Seek(HDR.DataOffSet,soFromBeginning);

                  if HDR.Compression = 0 then
                  begin

                    dataStm.CopyFrom(inpFileStm, HDR.DataSize);

                  end
                  else if HDR.Compression = 99 then
                  begin

                    decompStm := TDecompressionStream.Create(inpFileStm);
                    dataStm.CopyFrom(decompStm,HDR.DataSize);
                    decompStm.Free;

                  end;

                  dataStm.Seek(0,soFromBeginning);

                finally
                  inpFileStm.Free;
                end;

                FileSeek(lng, HDR.IndexOffSet,0);

                numLNG := HDR.IndexNum;

                for x := 1 to HDR.IndexNum do
                begin
                  FillChar(Idx[x],SizeOf(DLNG_IndexEntry_v4),0);
                  FileRead(lng,Idx[x],SizeOf(DLNG_IndexEntry_v4));
                  tabLNG[x].ID := Idx[x].ID;
                  dataStm.Seek(Idx[x].Offset*2,soFromBeginning);
                  setLength(tabLNG[x].Value,Idx[x].Length);
                  dataStm.ReadBuffer(tabLNG[x].value[1],Idx[x].Length*2);
//                  ShowMessage(Idx[x].ID+' '+inttostr(Idx[x].Offset)+' '+inttostr(Idx[x].Length)+' '+tabLNG[x].value);
//                tabLNG[x].Value :=  Get16v(lng,);
//        if length(tabLNG[x].Value) > 100 then
                end;

              finally
                dataStm.Free;
              end;


//      messagedlg(bigstr,mtInformation,[mbOk],0);

              UseInternalLanguage := False;
              curlanguage := ExtractFileName(fil);

            end;

    finally
      FileClose(lng);
    end;
  end
  else
  begin
    MessageDlg('Warning the language file you where using before could not be found.'+chr(10)+chr(10)+'The program will continue in french.',mtWarning,[mbOk],0);
    LoadInternalLanguage;
  end;
end;

procedure LoadInternalLanguage();
begin

  CurLanguage := '*';
  UseInternalLanguage := True;
  SelectedFontName := '';

end;

function GetFont(): String;
begin

  result := SelectedFontname;

end;

function GetIcon(fil: string): TBitmap;
var icn: TBitmap;
    stm: TMemoryStream;
    res : boolean;
    lng : integer;
    HDR: DLNG_Header_v4;
    buffer: pchar;
begin

//  Randomize;
//  tmpfil := ExtractFilePath(Application.ExeName)+'data\tmp_dlng_icn'+ IntToStr(random(99999))+'.bmp';

  icn := TBitmap.Create;

//  if FileExists(tmpfil) then
//    DeleteFile(tmpfil);

  if FileExists(fil) then
  begin
    lng := FileOpen(fil, (fmOpenRead or fmShareExclusive));
    try
      FileRead(lng,HDR,SizeOf(HDR));

      res := (HDR.ID = 'DLNG'+chr(26)) and (HDR.Version = DLNG_VERSION) and (HDR.PrgID = 'UP') and (HDR.PrgVER = DLNG_PRGVER);

      if res then
      begin

        FileSeek(lng,HDR.ExtendedHeaderSize,1);
//        tmps := Get8u(lng);
//        tmps := Get8u(lng);
//        tmps := Get8u(lng);
//        tmps := Get8u(lng);
//        tmps := Get8u(lng);

        if HDR.IconSize > 0 then
        begin
          stm := TMemoryStream.Create;
          GetMem(buffer,HDR.IconSize);
          FileRead(lng,Buffer^,HDR.IconSize);
          stm.WriteBuffer(Buffer^, HDR.IconSize);
          stm.Seek(0,soFromBeginning);
          icn.LoadFromStream(stm);
          stm.Free;
          FreeMem(buffer);
        end;
      end;

    finally
      FileClose(lng);
    end;
  end;

  GetIcon := icn;

end;

function GetLanguageInfo(fil: string; out Name, Author, URL, Email, FontName: String; out IsIcon: boolean): Boolean;
var HDR: DLNG_Header_v4;
    lng: integer;
    res: boolean;
begin

  res := false;

  if FileExists(fil) then
  begin
    IsIcon := false;
    lng := FileOpen(fil, (fmOpenRead or fmShareExclusive));
    try
      FileRead(lng,HDR,SizeOf(HDR));

      res := (HDR.ID = 'DLNG'+chr(26)) and (HDR.Version = DLNG_VERSION) and (HDR.PrgID = 'UP') and (HDR.PrgVER = DLNG_PRGVER);

      if res then
      begin
        Name := Get8u(lng);
        Author := Get8u(lng);
        URL := Get8u(lng);
        Email := Get8u(lng);
        FontName := Get8u(lng);
        IsIcon := HDR.IconSize > 0;
      end;

    finally
      FileClose(lng);
    end;
  end;

  GetLanguageInfo := res;

end;

function DLNGInternalStr(sch: string): string;
var res: string;
begin

  if sch = 'MNU1' then
    res := '&Fichier'
  else if sch = 'MNU1S1' then
    res := '&Ouvrir...'
  else if sch = 'MNU1S2' then
    res := '&Fermer'
  else if sch = 'MNU1S3' then
    res := '&Quitter'
  else if sch = 'MNU4' then
    res := '&Edition'
  else if sch = 'MNU4S1' then
    res := '&Rechercher'
  else if sch = 'MNU5' then
    res := '&Outils'
  else if sch = 'MNU5S1' then
    res := 'Créer une liste d''entrées...'
  else if sch = 'MNU2' then
    res := '&Options'
  else if sch = 'MNU2S1' then
    res := 'Générales'
  else if sch = 'MNU2S2' then
    res := 'Drivers'
  else if sch = 'MNU2S3' then
    res := 'Icônes/Look'
  else if sch = 'MNU2S4' then
    res := 'Associations'
  else if sch = 'MNU2S5' then
    res := 'Convertion'
  else if sch = 'MNU2S6' then
    res := 'Plugins'
  else if sch = 'MNU3' then
    res := '&?'
  else if sch = 'MNU3S1' then
    res := 'A Propos de'
  else if sch = 'LSTCP1' then
    res := 'Fichier'
  else if sch = 'LSTCP2' then
    res := 'Taille (Octets)'
  else if sch = 'LSTCP3' then
    res := 'Position'
  else if sch = 'LSTCP4' then
    res := 'Description'
  else if sch = 'STAT10' then
    res := 'objet(s)'
  else if sch = 'STAT20' then
    res := 'octet(s)'

  else if sch = 'ABT001' then
    res := 'Open Source / Mozilla Public Licence 1.1'
  else if sch = 'ABT002' then
    res := 'Contactez moi:'
  else if sch = 'ABT003' then
    res := 'Page Internet:'
  else if sch = 'ABT004' then
    res := 'Dragon UnPACKer utilise:'
  else if sch = 'ABT005' then
    res := 'Equipe de Beta testeurs:'
  else if sch = 'ABT006' then
    res := 'Remerciements spéciaux a tous les traducteurs:'

  else if sch = 'INFO99' then
    res := 'Informations'
  else if sch = 'INFO00' then
    res := 'Driver'
  else if sch = 'INFO01' then
    res := 'Nom:'
  else if sch = 'INFO02' then
    res := 'Auteur:'
  else if sch = 'INFO03' then
    res := 'Commentaire:'
  else if sch = 'INFO04' then
    res := 'Version:'
  else if sch = 'INFO05' then
    res := 'E-mail:'
  else if sch = 'INFO10' then
    res := 'Fichier'
  else if sch = 'INFO11' then
    res := 'Format:'
  else if sch = 'INFO12' then
    res := 'Entrées:'
  else if sch = 'INFO13' then
    res := 'Taille:'
  else if sch = 'INFO14' then
    res := 'Chargement:'
  else if sch = 'INFO20' then
    res := 'Nom du plugin'
  else if sch = 'INFO21' then
    res := 'Version'
  else if sch = 'INFO22' then
    res := 'Informations Avancées'
  else if sch = 'INFO23' then
    res := 'Ver.Int.:'
  else if sch = 'SCHTIT' then
    res := 'Rechercher'
  else if sch = 'SCHGRP' then
    res := 'Options'
  else if sch = 'SCH001' then
    res := 'Faire la différence entre Majuscules et Minuscules'
  else if sch = 'SCH002' then
    res := 'Tous les fichiers'
  else if sch = 'SCH003' then
    res := 'Répertoire actuel uniquement'
  else if sch = 'SCH004' then
    res := 'objet(s) trouvé(s)'
  else if sch = 'DIRTIT' then
    res := 'Choisissez le répertoire...'
  else if sch = 'POP1S1' then
    res := 'Extraire le fichier vers...'
  else if sch = 'PSUB01' then
    res := 'Sans convertion'
  else if sch = 'PSUB02' then
    res := 'Convertir vers %d'
  else if sch = 'POP1S2' then
    res := 'Extraire les fichiers vers...'
  else if sch = 'POP1S3' then
    res := 'Ouvrir'
  else if sch = 'POP1S4' then
    res := 'Sans Convertion'
  else if sch = 'POP2S1' then
    res := 'Extraire tout vers...'
  else if sch = 'POP2S2' then
    res := 'Extraire les sous-répertoires vers...'
  else if sch = 'POP2S3' then
    res := 'Informations'
  else if sch = 'POP2S4' then
    res := 'Développer tout'
  else if sch = 'POP2S5' then
    res := 'Replier tout'
  else if sch = 'POP3S1' then
    res := 'Afficher le journal'
  else if sch = 'POP3S2' then
    res := 'Cacher le journal'
  else if sch = 'POP3S3' then
    res := 'Effacer le journal'

  else if sch = 'OPTTIT' then
    res := 'Configuration'
  else if sch = 'OPT100' then
    res := 'Options générales'
  else if sch = 'OPT110' then
    res := 'Langue'
  else if sch = 'OPT120' then
    res := 'Options'
  else if sch = 'OPT121' then
    res := 'Ne pas afficher d''écran de démarrage'
  else if sch = 'OPT122' then
    res := 'Permettre seulement une instance du programme a la fois'
  else if sch = 'OPT123' then
    res := 'Détection intelligente des formats de fichiers'
  else if sch = 'OPT124' then
    res := 'Prendre les icones dans le registre Windows (plus lent)'
  else if sch = 'OPT125' then
    res := 'Utiliser l''HyperRipper si aucun plugin n''arrive à ouvrir le fichier'
  else if sch = 'OPT126' then
    res := 'Afficher le journal d''exécution'
  else if sch = 'OPT200' then
    res := 'Drivers'
  else if sch = 'OPT201' then
    res := 'A Propos..'
  else if sch = 'OPT202' then
    res := 'Configurer'
  else if sch = 'OPT203' then
    res := 'Drivers:'
  else if sch = 'OPT210' then
    res := 'Informations'
  else if sch = 'OPT220' then
    res := 'Priorité :'
  else if sch = 'OPT221' then
    res := 'Rafraîchir la liste'
  else if sch = 'OPT300' then
    res := 'Icones/Look'
  else if sch = 'OPT310' then
    res := 'Informations'
  else if sch = 'OPT320' then
    res := 'Fichiers de Look:'
  else if sch = 'OPT330' then
    res := 'Options de Look:'
  else if sch = 'OPT331' then
    res := 'Style XP pour les menus et la barre d''outils'
  else if sch = 'OPT400' then
    res := 'Types de fichiers'
  else if sch = 'OPT410' then
    res := 'Extensions associées'
  else if sch = 'OPT411' then
    res := 'Aucune'
  else if sch = 'OPT412' then
    res := 'Toutes'
  else if sch = 'OPT500' then
    res := 'Convertion'
  else if sch = 'OPT501' then
    res := 'Plugins de convertion:'
  else if sch = 'OPT510' then
    res := 'Informations'
  else if sch = 'OPT600' then
    res := 'Plugins'
  else if sch = 'OPT701' then
    res := 'Plugins HyperRipper:'
  else if sch = 'OPT710' then
    res := 'Informations'
  else if sch = 'OPT800' then
    res := 'Journal d''exécution'
  else if sch = 'OPT810' then
    res := 'Options du journal d''exécution'
  else if sch = 'OPT840' then
    res := 'Niveau de détail'
  else if sch = 'OPT841' then
    res := 'Sélectionnez le niveau de détail pour le journal d''exécution:'
  else if sch = 'OPT850' then
    res := 'Bas - Aucune information supplémentaire'
  else if sch = 'OPT851' then
    res := 'Moyen - Affichage de plus d''informations'
  else if sch = 'OPT852' then
    res := 'Haut - Affichage du maximum d''informations'
  else if sch = 'OPEN00' then
    res := 'Ouvrir un fichier...'
  else if sch = 'XTRCAP' then
    res := 'Extraction en cour...'
  else if sch = 'XTRSTA' then
    res := 'Extraction de %f...'
  else if sch = 'ALLCMP' then
    res := 'Tous les fichiers compatibles'
  else if sch = 'ALLFIL' then
    res := 'Tous les fichiers'
  else if sch = 'BUTSCH' then
    res := 'Chercher'
  else if sch = 'BUTOK' then
    res := 'Ok'
  else if sch = 'BUTGO' then
    res := 'Go!'
  else if sch = 'BUTDIR' then
    res := 'Nouveau Dossier'
  else if sch = 'BUTDET' then
    res := 'Details'
  else if sch = 'BUTDEL' then
    res := 'Supprimer'
  else if sch = 'BUTADD' then
    res := 'Ajouter'
  else if sch = 'BUTCNV' then
    res := 'Convertir'
  else if sch = 'BUTCAN' then
    res := 'Annuler'
  else if sch = 'BUTINS' then
    res := 'Installer'
  else if sch = 'BUTCLO' then
    res := 'Terminer'
  else if sch = 'BUTCON' then
    res := 'Continuer'
  else if sch = 'BUTNEX' then
    res := 'Suivant'
  else if sch = 'BUTPAL' then
    res := 'Ajouter Palette'
  else if sch = 'BUTREF' then
    res := 'Rafraichir'
  else if sch = 'BUTREM' then
    res := 'Supprimer'
  else if sch = 'BUTEDT' then
    res := 'Editer'
  else if sch = 'HYPAD' then
    res := 'Cette pre-version ne cherche que les fichiers sons WAVE.'
  else if sch = 'HYPFIN' then
    res := 'Type %t (Position %o / %s octets)'
  else if sch = 'HYPOPN' then
    res := 'Choisissez le fichier a scanner...'
  else if sch = 'HR0000' then
    res := 'A Propos...'
  else if sch = 'HR0001' then
    res := 'Le HyperRipper permet de rechercher des formats de fichiers "standard"'+#10+'dans d''autres fichiers non supportés directement par Dragon UnPACKer.'
  else if sch = 'HR0002' then
    res := 'ATTENTION: Pour utilisateurs experts uniquement!'
  else if sch = 'HR0003' then
    res := 'Nombre de plugins chargés:'
  else if sch = 'HR0004' then
    res := 'Nombre total de formats:'
  else if sch = 'HR1000' then
    res := 'Rechercher'
  else if sch = 'HR1001' then
    res := 'Source:'
  else if sch = 'HR1002' then
    res := 'Créer un fichier HyperRipper (HRF):'
  else if sch = 'HR1003' then
    res := 'Annuler / Arreter'
  else if sch = 'HR1011' then
    res := 'Taille du buffer:'
  else if sch = 'HR1012' then
    res := 'Taille du rollback:'
  else if sch = 'HR1013' then
    res := 'Vitesse de recherche:'
  else if sch = 'HR1014' then
    res := 'Fichiers trouvées:'
  else if sch = 'HR2000' then
    res := 'Formats'
  else if sch = 'HR2011' then
    res := 'Format'
  else if sch = 'HR2012' then
    res := 'Type'
  else if sch = 'HR2021' then
    res := 'Configurer'
  else if sch = 'HR2022' then
    res := 'Tous/Aucun'
  else if sch = 'HR3000' then
    res := 'Fichier HyperRipper'
  else if sch = 'HR3010' then
    res := 'Inclure les informations suivantes:'
  else if sch = 'HR3011' then
    res := 'Titre:'
  else if sch = 'HR3012' then
    res := 'URL:'
  else if sch = 'HR3020' then
    res := 'Version HRF'
  else if sch = 'HR3021' then
    res := 'Version'
  else if sch = 'HR3030' then
    res := 'Options'
  else if sch = 'HR3031' then
    res := 'Ne pas identifier le programme (anonyme)'
  else if sch = 'HR3032' then
    res := 'Ne pas indiquer la version du programme'
  else if sch = 'HR3033' then
    res := 'Taille maximum du nom d''une entrée:'
  else if sch = 'HR3034' then
    res := '%c caractères'
  else if sch = 'HR3035' then
    res := 'Compatible avec version:'
  else if sch = 'HR3036' then
    res := '%v et plus recentes'
  else if sch = 'HR4000' then
    res := 'Options Avancées'
  else if sch = 'HR4010' then
    res := 'Tampon mémoire'
  else if sch = 'HR4011' then
    res := 'Koctets'
  else if sch = 'HR4012' then
    res := 'octets'
  else if sch = 'HR4020' then
    res := 'Rollback de mémoire'
  else if sch = 'HR4021' then
    res := 'Pas de Rollback (non recommandé)'
  else if sch = 'HR4022' then
    res := 'Rollback par défaut (128 octets)'
  else if sch = 'HR4023' then
    res := 'Grand Rollback (1/4 du tampon)'
  else if sch = 'HR4024' then
    res := 'Enorme Rollback (1/2 du tampon)'
  else if sch = 'HR4030' then
    res := 'Formattage des entrées'
  else if sch = 'HR4031' then
    res := 'Faire des répertoires grâce au type retourné par le plugin'
  else if sch = 'HR4050' then
    res := 'Nommage'
  else if sch = 'HR4051' then
    res := 'Automatique'
  else if sch = 'HR4052' then
    res := 'Personnalisé'
  else if sch = 'HR4053' then
    res := 'Exemple'

  else if sch = 'HRLEGF' then
    res := 'fichier'
  else if sch = 'HRLEGN' then
    res := 'nombre'
  else if sch = 'HRLEGX' then
    res := 'extension'
  else if sch = 'HRLEGO' then
    res := 'position (Dec)'
  else if sch = 'HRLEGH' then
    res := 'position (Hex)'

{  else if sch = 'HR4040' then
    res := 'Préfixe'
  else if sch = 'HR4041' then
    res := 'Préfixe Automatique'
  else if sch = 'HR4042' then
    res := 'Préfixe Pré-Défini (manuel)}
  else if sch = 'HRLG01' then
    res := 'Pas de formats sélectionnées...'
  else if sch = 'HRLG02' then
    res := 'Fichier %f introuvable!'
  else if sch = 'HRLG03' then
    res := 'Ouverture de %f...'
  else if sch = 'HRLG04' then
    res := 'Fait!'
  else if sch = 'HRLG05' then
    res := 'Allocation mémoire...'
  else if sch = 'HRLG06' then
    res := 'Recherche des formats dans le fichier...'
  else if sch = 'HRLG07' then
    res := 'Impossible de lire %b octets dans le fichier...'
  else if sch = 'HRLG08' then
    res := 'Format %e trouvé @ %a (%s octets)'
  else if sch = 'HRLG09' then
    res := 'Scanné %s en %t secs!'
  else if sch = 'HRLG10' then
    res := 'octets'
  else if sch = 'HRLG11' then
    res := 'Ko'
  else if sch = 'HRLG12' then
    res := 'Mo'
  else if sch = 'HRLG13' then
    res := 'Go'
  else if sch = 'HRLG14' then
    res := 'Sauvegarde HRF...'
  else if sch = 'HRLG15' then
    res := 'Affichage du résultat dans Dragon UnPACKer...'
  else if sch = 'HRLG16' then
    res := 'Erreur pendant la recherche... Annulation...'
  else if sch = 'HRLG17' then
    res := 'Libération de la mémoire...'
  else if sch = 'HRLG18' then
    res := 'Erreur!'
  else if sch = 'HRTYP0' then
    res := 'Inconnu'
  else if sch = 'HRTYP1' then
    res := 'Audio'
  else if sch = 'HRTYP2' then
    res := 'Video'
  else if sch = 'HRTYP3' then
    res := 'Image'
  else if sch = 'HRTYPM' then
    res := 'Autre'
  else if sch = 'HRTYPE' then
    res := 'Type (%i)'
  else if sch = 'HRD000' then
    res := 'Options MPEG Audio'
  else if sch = 'HRD100' then
    res := 'Formats MPEG Audio à rechercher'
  else if sch = 'HRD101' then
    res := 'Non standard'
  else if sch = 'HRD200' then
    res := 'Limitations'
  else if sch = 'HRD211' then
    res := 'Nombre de frames minimum:'
  else if sch = 'HRD212' then
    res := 'Nombre de frames maximum:'
  else if sch = 'HRD213' then
    res := 'frame(s)'
  else if sch = 'HRD221' then
    res := 'Taille minimum:'
  else if sch = 'HRD222' then
    res := 'Taille maximum:'
  else if sch = 'HRD223' then
    res := 'octet(s)'
  else if sch = 'HRD300' then
    res := 'Spécial'
  else if sch = 'HRD301' then
    res := 'Rechercher entête Xing VBR'
  else if sch = 'HRD302' then
    res := 'Rechercher ID3Tag v1.0/1.1'

  else if sch = 'LST000' then
    res := 'Créer une liste'
  else if sch = 'LST001' then
    res := 'Trier'
  else if sch = 'LST100' then
    res := 'Modèle'
  else if sch = 'LST101' then
    res := 'Version:'
  else if sch = 'LST102' then
    res := 'Auteur:'
  else if sch = 'LST103' then
    res := 'Email:'
  else if sch = 'LST104' then
    res := 'URL:'
  else if sch = 'LST200' then
    res := 'Liste'
  else if sch = 'LST201' then
    res := 'Entrées sélectionnées'
  else if sch = 'LST202' then
    res := 'Toutes les entrées'
  else if sch = 'LST203' then
    res := 'Répertoire actuel'
  else if sch = 'LST204' then
    res := 'Inclure les sous-répertoires'
  else if sch = 'LST300' then
    res := 'Ordre de tri'
  else if sch = 'LST301' then
    res := 'Alphabétique'
  else if sch = 'LST302' then
    res := 'Taille'
  else if sch = 'LST303' then
    res := 'Position'
  else if sch = 'LST304' then
    res := 'Décroissant'
  else if sch = 'LST400' then
    res := 'ATTENTION: Activer le tri ralentira enormement le traitement...'
  else if sch = 'LST500' then
    res := 'Sauvegarder la liste vers...'
  else if sch = 'LST501' then
    res := 'Récuperation de l''entête du modèle...'
  else if sch = 'LST502' then
    res := 'Récuperation du footer du modèle...'
  else if sch = 'LST503' then
    res := 'Récuperation de l''élement variable du modèle...'
  else if sch = 'LST504' then
    res := 'Récuperation de la liste d''entrées...'
  else if sch = 'LST505' then
    res := 'Tri de la liste de %v entrées...'
  else if sch = 'LST506' then
    res := 'Création de la liste de %v entrées... %p%'
  else if sch = 'LST507' then
    res := 'Sauvegarde du fichier de liste...'
  else if sch = 'LST508' then
    res := 'Extraction des fichiers supplémentaires du modèle...'
  else if sch = 'LST509' then
    res := 'Terminé!'

  else if sch = 'CNV000' then
    res := 'Convertion d''une image/texture...'
  else if sch = 'CNV001' then
    res := 'Palette'
  else if sch = 'CNV010' then
    res := 'Note:%nUtilisez la boite de configuration pour%ngérer (ajouter ou supprimer) des palettes.'

  else if sch = 'CNV100' then
    res := 'Ajout d''une nouvelle palette'
  else if sch = 'CNV101' then
    res := 'Source:'
  else if sch = 'CNV102' then
    res := 'Titre:'
  else if sch = 'CNV103' then
    res := 'Auteur:'
  else if sch = 'CNV104' then
    res := 'Format:'
  else if sch = 'CNV110' then
    res := 'Palette de données brutes (RAW) 768octets'
  else if sch = 'CNV120' then
    res := 'Inconnu'
  else if sch = 'CNV900' then
    res := 'Une erreur est survenue durant la création de la palette.%n%nFichier source: %f%nFormat source: %t%n%nErreur: %e%n%nImpossible d''ajouter la palette.'
  else if sch = 'CNV901' then
    res := 'La palette a été convertie avec succés!%nVous pouvez désormais la sélectionner dans la liste.'
  else if sch = 'CNV990' then
    res := 'Le nom de palette spécifié existe déjà.'
  else if sch = 'CNV991' then
    res := 'Format inconnu (essayez de changer le format).'
  else if sch = 'CNV992' then
    res := 'Etes-vous sur de vouloir supprimer la palette?'

  else if sch = 'PI0000' then
    res := 'Version de DUP5 detectée:'
  else if sch = 'PI0001' then
    res := 'Titre'
  else if sch = 'PI0002' then
    res := 'Auteur'
  else if sch = 'PI0003' then
    res := 'Commentaire'
  else if sch = 'PI0004' then
    res := 'URL'
  else if sch = 'PI0005' then
    res := 'Informations sur le package'
  else if sch = 'PI0006' then
    res := 'Veuillez patientez pendant l''installation du package...'
  else if sch = 'PI0007' then
    res := 'Ce programme va installer le package suivant dans le répertoire de Dragon UnPACKer.'
  else if sch = 'PI0008' then
    res := 'Dragon UnPACKer 5 doit être fermé pour continuer.'
  else if sch = 'PI0009' then
    res := 'Statut:'
  else if sch = 'PI0010' then
    res := 'En attente de l''utilisateur...'
  else if sch = 'PI0011' then
    res := 'Etes-vous sur de vouloir quitter?'
  else if sch = 'PI0012' then
    res := 'Erreur... DUP5 est lancé...'
  else if sch = 'PI0013' then
    res := 'Erreur Dragon UnPACKer 5 est lancé...%nFermez le puis ré-essayez.'
  else if sch = 'PI0014' then
    res := 'Erreur fatale.. Version non supportée de Package Dragon UnPACKer 5 (.D5P) [version %v]'
  else if sch = 'PI0015' then
    res := 'Erreur fatale.. Ceci n''est pas un fichier de Package Dragon UnPACKer 5 (.D5P)'
  else if sch = 'PI0016' then
    res := 'Utilisation: duppi <fichier.d5p>%n%nCeci installera le package fichier.d5p dans le répertoire de Dragon UnPACKer 5.'
  else if sch = 'PI0017' then
    res := 'Fichier introuvable!%n%f'
  else if sch = 'PI0018' then
    res := 'Lecture du package...'
  else if sch = 'PI0019' then
    res := 'Le fichier suivant existe déjà et est plus récent (ou le même) que le fichier que vous essayez d''installer:%n%n%f%n%nVersion actuelle: %1%nFichier du package: %2%n%nInstaller quand même?'
  else if sch = 'PI0020' then
    res := 'Le fichier suivant a un mauvais CRC. Le fichier ne sera pas installé.%nSi vous avez téléchargez ce fichier, re-téléchargez le.%n%n%f'
  else if sch = 'PI0021' then
    res := 'Le fichier suivant a une mauvaise taille. Le fichier ne sera pas installé.%nSi vous avez téléchargez ce fichier, re-téléchargez le.%n%n%f'
  else if sch = 'PI0022' then
    res := 'Installation avec succés de %i fichier(s)...'
  else if sch = 'PI0023' then
    res := 'Installation teminée avec succés...'
  else if sch = 'PI0024' then
    res := 'Installation non réussie (%e fichier(s) ont donnés des erreurs)...'
  else if sch = 'PI0025' then
    res := 'Installation non réussie... %i fichier(s) installés avec succés et %e erreur(s)...'
  else if sch = 'PI0026' then
    res := 'Chemin d''accés a Dragon UnPACKer 5 introuvable.%nVeuillez lancer Dragon UnPACKer 5 au moins une fois avant de rééssayer.'
  else if sch = 'PI0027' then
    res := 'Evité...'
  else if sch = 'PI0028' then
    res := 'Ko'
  else if sch = 'PI0029' then
    res := 'Lecture...'
  else if sch = 'PI0030' then
    res := 'Décompression...'
  else if sch = 'PI0031' then
    res := 'Ecriture...'
  else if sch = 'PI0032' then
    res := 'OK'
  else if sch = 'PI0033' then
    res := 'Version'
  else if sch = 'PI0034' then
    res := 'Ce programme vous permet d''installer des packages de Dragon UnPACKer 5.'
  else if sch = 'PI0035' then
    res := 'Que voulez vous faire?'
  else if sch = 'PI0036' then
    res := 'Rechercher sur internet les mises a jour et les installer.'
  else if sch = 'PI0037' then
    res := 'Remarque: Aucune information n''est envoyé à Dragon Software.'
  else if sch = 'PI0038' then
    res := 'Options Proxy'
  else if sch = 'PI0039' then
    res := 'Installer un package depuis le disque dur:'
  else if sch = 'PI0040' then
    res := 'Selectionner le package a installer...'
  else if sch = 'PI0041' then
    res := 'Pour installer ce fichier D5P vous devez disposer d''une version de Duppi plus récente.'+#10+'Votre version de Duppi: %y'+#10+'Version de Duppi requise: %v'+#10+#10+'Pour cela mettez à jour votre Dragon UnPACKer 5.'
  else if sch = 'PI0042' then
    res := 'Ce package ne peut pas être installé avec votre version de Dragon UnPACKer.'
  else if sch = 'PI0043' then
    res := 'Impossible d''enregistrer %s.'

  else if sch = 'PII001' then
    res := 'Titre'
  else if sch = 'PII002' then
    res := 'Votre version'
  else if sch = 'PII003' then
    res := 'Version disponible'
  else if sch = 'PII004' then
    res := 'Description'
  else if sch = 'PII005' then
    res := 'Taille'
  else if sch = 'PII100' then
    res := 'la liste des mises a jours'
  else if sch = 'PII101' then
    res := 'Telechargement de %f...'
  else if sch = 'PII102' then
    res := 'Telechargement de %f (%b octets reçus)'
  else if sch = 'PII103' then
    res := 'Reception terminée de %f (%b octets)'
  else if sch = 'PII104' then
    res := 'Erreur: %c (%d)'
  else if sch = 'PII105' then
    res := 'Serveur contacté avec succés!'
  else if sch = 'PII106' then
    res := '-Aucune description-'
  else if sch = 'PII107' then
    res := 'Une nouvelle version de Dragon UnPACKer est disponible en téléchargement.%n%nNouvelle version: %v%nCommentaire: %c%n%nVoulez vous aller sur la page officielle pour la télécharger?'
  else if sch = 'PII200' then
    res := 'Aucune mise a jour n''a pu être téléchargée.%nLe programme va maintenant s''arreter.'

  else if sch = 'PIP000' then
    res := 'Configuration du proxy'
  else if sch = 'PIP001' then
    res := 'Proxy:'
  else if sch = 'PIP002' then
    res := 'Port du proxy:'
  else if sch = 'PIP003' then
    res := 'Le proxy requiere une identification:'
  else if sch = 'PIP004' then
    res := 'Utilisateur:'
  else if sch = 'PIP005' then
    res := 'Mot de passe:'

  else if sch = '11TH01' then
    res := 'Pour activer le support des fichiers du jeu The 11th Hour, le plugin a besoin de copier deux fichiers que vous pouvez trouver dans le répertoire GROOVIE du CDRom de The 11th Hour.%n%nVoulez-vous continuer ?'
  else if sch = '11TH02' then
    res := 'Selectionnez le fichier %f de 11th Hour...'
  else if sch = '11TH03' then
    res := 'Le plugin est désormais activé.%nMaintenant vous pouvez ouvrir les fichiers GJD de The 11th Hour!'
  else if sch = '11TH04' then
    res := 'La désactivation du support The 11th Hour va supprimer les fichiers suivants:%n%n%a%n%b%n%nVous pourrez les recréer plus tard en réactivant le support The 11th Hour.%n%nEtes-vous sur de vouloir continuer?'
  else if sch = '11TH05' then
    res := 'Statut du plugin: %s%n(Activé signifie que vous pouvez ouvrir des fichiers GJD)%n(Désactivé signifie que vous devez importer les fichiers GJD.GJD et DIR.RL)'
  else if sch = '11TH06' then
    res := 'Désactivé'
  else if sch = '11TH07' then
    res := 'Activé'
  else if sch = '11TH10' then
    res := 'Configuration du plugin The 11th Hour'
  else if sch = '11TH11' then
    res := 'Activer'
  else if sch = '11TH12' then
    res := 'Désactiver'
  else if sch = '11TH13' then
    res := 'Statut actuel:'
  else if sch = '11TH14' then
    res := 'Support The 11th Hour:'

  else if sch = 'DUT100' then
    res := 'Configuration'
  else if sch = 'DUT101' then
    res := 'Librairie'
  else if sch = 'DUT110' then
    res := 'ID'
  else if sch = 'DUT111' then
    res := 'Chemin d''accès'
  else if sch = 'DUT112' then
    res := 'Jeu'
  else if sch = 'DUT113' then
    res := 'ND?'   // Ne plus demander? (PD? aurait été moyen non?)
  else if sch = 'DUT114' then
    res := 'IDJ'   // ID du jeu
  else if sch = 'DUT201' then
    res := 'Indiquez le jeu correspondant au fichier ouvert:'
  else if sch = 'DUT202' then
    res := 'Ne plus demander pour ce répertoire'
  else if sch = 'DUT203' then
    res := '- Inconnu / Autre -'

  else if sch = 'TLD001' then
    res := 'Lecture de %f par le driver...'
  else if sch = 'TLD002' then
    res := 'Recuperation des données...'
  else if sch = 'TLD003' then
    res := 'Parsing et Affichage de la racine...'

  else if sch = 'EX' then
    res := 'Fichier %e'
  else if sch = 'EXANIM' then
    res := 'Animation (%e)'
  else if sch = 'EXART' then
    res := 'Archive ART (Textures)'
  else if sch = 'EXBIN' then
    res := 'Données (%e)'
  else if sch = 'EXCFG' then
    res := 'Configuration (%e)'
  else if sch = 'EXDLL' then
    res := 'Librairie à Liaison Dynamique'
  else if sch = 'EXSCRP' then
    res := 'Script (%e)'
  else if sch = 'EXFIRE' then
    res := 'Texture Feu (Dynamique)'
  else if sch = 'EXIMG' then
    res := 'Image %e (%d)'
  else if sch = 'EXMAP' then
    res := 'Level Map (%e)'
  else if sch = 'EXMDL' then
    res := 'Modèle 3D (%e)'
  else if sch = 'EXMPEG' then
    res := 'Audio/Video MPEG'
  else if sch = 'EXMUS' then
    res := 'Musique (%d)'
  else if sch = 'EXPAL' then
    res := 'Palette'
  else if sch = 'EXSND' then
    res := 'Son (%d)'
  else if sch = 'EXSPR' then
    res := 'Sprite'
  else if sch = 'EXTEX' then
    res := 'Texture (%e)'
  else if sch = 'EXTXT' then
    res := 'Document Texte'

  else if sch = 'LOG001' then
    res := 'Initialisation des plugins:'
  else if sch = 'LOG002' then
    res := 'Chargement des plugins Drivers...'
  else if sch = 'LOG003' then
    res := 'Chargement des plugins Convertions...'
  else if sch = 'LOG004' then
    res := 'Chargement des plugins HyperRipper...'
  else if sch = 'LOG009' then
    res := '%p plugin(s)'
  else if sch = 'LOG101' then
    res := 'Ouverture du fichier "%f":'
  else if sch = 'LOG102' then
    res := 'Format de fichier non reconnu!'
  else if sch = 'LOG103' then
    res := 'Démarrage de HyperRipper...'
  else if sch = 'LOG104' then
    res := 'Fichier introuvable (ou bloqué par un autre programme/utilisateur)...'
  else if sch = 'LOG200' then
    res := 'Fermeture fichier actuel...'
  else if sch = 'LOG300' then
    res := 'Affichage des entrées du répertoire "%d"...'
  else if sch = 'LOG301' then
    res := '%e entrée(s)...'
  else if sch = 'LOG400' then
    res := 'Utilisation de la détection intelligente du format du fichier source.'
  else if sch = 'LOG500' then
    res := 'Le plugin Driver "%d" pense pouvoir ouvrir ce fichier.'
  else if sch = 'LOG501' then
    res := 'Ouverture du fichier en utilisant le plugin "%d"...'
  else if sch = 'LOG502' then
    res := 'Récupération de %x entrée(s)...'
  else if sch = 'LOG503' then
    res := 'Récupération des répertoires...'
  else if sch = 'LOG504' then
    res := 'Fichier ouvert grâce au plugin "%p" (format détecté: "%f")'
  else if sch = 'LOG510' then
    res := 'Fait!'
  else if sch = 'LOG511' then
    res := '- Succès!'
  else if sch = 'LOG512' then
    res := '- Echec!'
  else if sch = 'LOG513' then
    res := '- Erreur!'
  else if sch = 'LOG514' then
    res := 'Erreur!'
  else if sch = 'LOGC01' then
    res := 'Libération de %p plugins...'
  else if sch = 'LOGC02' then
    res := 'Recherche des plugins...'
  else if sch = 'LOGC10' then
    res := 'Convertion de "%a" vers "%b"...'
  else if sch = 'LOGC11' then
    res := 'Méthode rapide!'
  else if sch = 'LOGC12' then
    res := 'Méthode lente (plugins obsolètes)!'
  else if sch = 'LOGC13' then
    res := 'Convertion vers "%b"...'
  else if sch = 'LOGC14' then
    res := 'Convertion de multiples entrées vers "%b"...'
  else if sch = 'LOGC15' then
    res := 'Convertion...'

  else if sch = 'ERR000' then
    res := 'Erreur'
  else if sch = 'ERR101' then
    res := 'Une erreur est survenue pendant l''extraction.'
  else if sch = 'ERR102' then
    res := 'Une erreur est survenue pendant l''extraction du fichier:'
  else if sch = 'ERR200' then
    res := 'Une erreur non prise en charge est survenue:'
  else if sch = 'ERR201' then
    res := 'Dans:'
  else if sch = 'ERR202' then
    res := 'Exception:'
  else if sch = 'ERR203' then
    res := 'Message:'
  else if sch = 'ERR204' then
    res := 'Si vous voulez faire un rapport d''erreur veuillez inclure les details (appuyez sur bouton "Details").'
  else if sch = 'ERR205' then
    res := 'Copier'
  else if sch = 'ERR206' then
    res := 'Envoyez le rapport d''erreur a:'
  else if sch = 'ERRCMP' then
    res := 'Impossible de trouver le fichier companion (nécessaire) suivant:%n%n%f'
  else if sch = 'ERRFIL' then
    res := 'Ceci n''est pas un fichier %f valide (%g).'
  else if sch = 'ERROPN' then
    res := 'Impossible d''ouvrir le fichier source:%n%n%f'
  else if sch = 'ERRUNK' then
    res := 'Aucun driver n''a pu charger ce fichier.'
  else if sch = 'ERRTMP' then
    res := 'Impossible de supprimer le fichier temporaire:%n%n%f'
  else if sch = 'ERRD01' then
    res := 'Le Driver n''a pas pu etre chargé (mauvaise version de l''interface ou ce n''est pas un driver DUP5).'
  else if sch = 'ERRD02' then
    res := 'Le Driver n''a pas pu etre chargé (des fonctions importantes sont manquantes).'
  else if sch = 'ERRDRV' then
    res := 'Une erreur est survenue lors de l''utilisation du driver "%d":'
  else if sch = 'ERRDR1' then
    res := 'Pour toute question en relation avec cette erreur veuillez contacter l''auteur du driver (%a).'
  else if sch = 'ERRC01' then
    res := 'Le Plugin de convertion n''a pas pu etre chargé (mauvaise version de l''interface ou ce n''est pas un plugin DUP5).'
  else if sch = 'ERRC02' then
    res := 'Le Plugin de convertion n''a pas pu etre chargé (des fonctions importantes sont manquantes).'
  else if sch = 'ERRH01' then
    res := 'Le Plugin HyperRipper n''a pas pu etre chargé (mauvaise version de l''interface ou ce n''est pas un plugin DUP5).'
  else if sch = 'ERRH02' then
    res := 'Le Plugin HyperRipper n''a pas pu etre chargé (des fonctions importantes sont manquantes).'
  else if sch = 'ERRH03' then
    res := 'Attention: Ce plugin ne peut pas rechercher après 2Go de données (après cette limite il ne trouvera rien).'
  else if sch = 'ERRH04' then
    res := 'HyperRipper plugin ID #%i inconnu'
  else if sch = 'ERRH05' then
    res := 'Le plugin "%p" ne peut pas rechercher de données après la limite des 2Go.'
  else if sch = 'ERREMP' then
    res := 'Le fichier est vide.'
  else if sch = 'ERRIO' then
    res := 'Impossible d''ouvrir le fichier:%n%n%f%n%nVérifiez qu''il n''est pas déjà ouvert par un autre programme ou qu''il ne soit pas/plus accessible.'
  else
    res := '--Non defini--';


  DLNGInternalStr := res;

end;

function PadRight(Data: string; PadWidth: integer) : string;
begin
   result := data;
   while length(result) < PadWidth do
      result := result + ' ';
end;

function DLNGStr(sch: string): string;
var res: string;
    x: integer;
begin

  res := '';

  if (length(sch) > 0) and (length(sch) < 7) then
  begin
    if UseInternalLanguage then
      res := DLNGInternalStr(sch)
    else
    begin
      sch := PadRight(sch,6);
      x := 1;
      while (res = '') and (x <= numLNG) do
      begin
        //MessageDlg(tabLNG[x].ID + chr(10)+tabLNG[x].Value,mtInformation,[mbOk],0);
        if tabLNG[x].ID = sch then
          res := tabLNG[x].Value;
        x := x + 1;
      end;
    end
  end;

  if res = '' then
    res := '--Undefined--'+sch+'--';

  while Pos('%n',res) > 0 do
  begin
    res := ReplaceValue('%n',res,chr(10));
  end;

  DLNGStr := res;

end;

function ReplaceValue(substr: string; str: string; newval: string): string;
var possub: integer;
    res: string;
begin

  possub := Pos(substr,str);
  if possub > 0 then
  begin
    res := Copy(str,0,possub-1) + Copy(str,possub+length(substr),length(str)-length(substr)+1);
    Insert(newval,res,possub);
  end
  else
    res := str;

  ReplaceValue := res;

end;

end.
