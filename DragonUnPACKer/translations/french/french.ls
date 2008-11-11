# Language Source File (pour DLNGC v4.0)
# ============================================================================
#  Programme: Dragon UnPACKer v5.4.0
#     Langue: English
#    Version: 12
#     Auteur: Alex Devilliers
# ============================================================================
#
# Ce fichier est le model pour les traductions de Dragon UnPACKer.
#
# Il vous suffit de traduire entre les tags {BODY} et {/BODY}
#
# Compilez ce fichier avec DLNGC et mettez le fichier .LNG resultant dans le
# sous-répertoire \Data\ de Dragon UnPACKer.
#
# Pour selectionner une autre langue pour Dragon UnPACKer lancez:
# DrgUnPACK5.exe /lng
# Ou aller dans les Options générale.
#
# NE MODIFIEZ AUCUN MOT CLE - CHANGEZ JUSTE LE TEXTE APRES LE SYMBOLE =
#
# Si vous faite une traduction n'hésitez pas a l'envoyer a Alex Devilliers
# afin qu'elle soit distribuée sur le site internet et avec le programme.
#
# Vous pouvez contacter Alex Devilliers par e-mail:
# translation@dragonunpacker.com et par ICQ: 1535372 (Elbereth)
#
# ============================================================================
# Informations sur cette traduction
# ============================================================================
#
# version 11:
# Nouvelles entrées pour la prévisualisation
#
# version 10:
# Première version sous forme de fichier .LS
#
{LSF}
{HEADER}
#
# * Header *
#
# + Name +
# Ecriverz ici le nom qui apparaitra das la boite de dialogue de Dragon
# UnPACKer pour votre fichier de langue. Ex: Français (French)
#
# Peut contenir jusqu'à 80 caractères
#
Name = Français (French)
#
# + Author +
# Inscrivez ici votre nom ou un surnom (et n'importe quel commentaire)
#
# Peut contenir jusqu'à 80 caractères
#
Author = Alexandre Devilliers
#
# + Email +
# Inscrivez ici votre email (ou vide si vous ne voulez pas le divulger)
#
# Peut contenir jusqu'à 80 caractères
#
Email = dup5.translation@dragonunpacker.com
#
# + URL +
# Inscrivez une adresse internet où l'on peut récuperer la derniere version de
# votre traduction
#
# Peut contenir jusqu'à 80 caractères
#
URL = http://www.dragonunpacker.com
#
# + Block identifiant programme (ProgramID & ProgramVer)
#
# NE CHANGEZ LES VALEURS QUE SI VOUS SAVEZ CE QUE VOUS FAITES
#
#                                ID      Ver
# Dragon UnPACKer v5.0.0 Beta 1  UP       1
# Dragon UnPACKer v5.0.0 Beta 2  UP       2
# Dragon UnPACKer v5.0.0 Beta 3  UP       3
# Dragon UnPACKer v5.0.0 Beta 4  UP       3
# Dragon UnPACKer v5.0.0 RC1     UP       4
# Dragon UnPACKer v5.0.0 RC2     UP       5
# Dragon UnPACKer v5.0.0 RC3     UP       6
# Dragon UnPACKer v5.1.0         UP       7
# Dragon UnPACKer v5.1.2         UP       8
# Dragon UnPACKer v5.2.0         UP       9
# Dragon UnPACKer v5.2.0a        UP       9
# Dragon UnPACKer v5.2.0b        UP       9
# Dragon UnPACKer v5.3.2         UP      10
# Dragon UnPACKer v5.3.3 Beta    UP      11
# Dragon UnPACKer v5.4.0         UP      12
#
ProgramID = UP
ProgramVer = 12
#
# + IconFile +
# Chemin & nom du fichier de l'icône affichée avec le nom de langue.
#
# Ce fichier doit être de type Windows Bitmap 16x16 (Hauteur=16 Largeur=16).
# Le compilateur ne teste pas ce fichier mais le programme n'affichera pas
# l'icone si ce n'est pas un fichier valide.
#
# Si vous ne désirez pas d'icône commentez la ligne.
#
IconFile = flag_fr.bmp
#
# + OutFile +
# Chemin & nom du fichier du resultat de la compilation.
#
OutFile = french.lng
#
# + FontName +
# Nom de la fonte a utiliser (si vous ne désirez pas utiliser celle par défaut)
# (Par ex Arial, Tahoma, etc..)
#
#FontName=Comic Sans MS
#
# + Compression +
# Compression a utiliser pour les données.
#
# Valeurs possibles:   0 = Sans compression (Par Défaut)
#                     99 = Zlib
#
Compression=99
#
{/HEADER}
#
# * Body *
#
# Chaque mot clé utilisé dans le programme est suivi du texte qui apparait
# dans le programme.
#
# Ex: TEST01=Ceci est un test
#
# Chaque mot clé ne peut faire que 6 caractères alpha-numériques au maximum.
#
# Macro speciales:
#  %n = Saute une ligne
# N'importe qu'el autre lettre suivant un % (ex: %k) est une macro speciale qui
# sera remplacée par Dragon UnPACKer lors de l'execution.
#
# N'AJOUTER/SUPPRIMER PAS DE MOT CLE SAUF SI VOUS SAVEZ CE QUE VOUS FAITES.
# LE PROGRAMME TESTE LA PRESENCE DE CERTAINS MOT CLE ET N'UTILISERA PAS VOTRE
# FICHIER DE LANGUE S'IL MANQUE DES MOTS CLES.
#
{BODY}
MNU1=&Fichier
MNU1S1=&Ouvrir...
MNU1S2=&Fermer
MNU1S3=&Quitter
MNU4=&Edition
MNU4S1=&Rechercher
MNU5=&Outils
MNU5S1=Créer une liste d'entrées...
MNU2=&Options
MNU2S1=Générales
MNU2S2=Drivers
MNU2S3=Icônes/Look
MNU2S4=Associations
MNU2S5=Convertion
MNU2S6=Extensions
MNU2S7=Avancé
MNU2S8=Journal d'exécution
MNU2S9=Prévisualisation
MNU3=&?
MNU3S1=A Propos de
LSTCP1=Fichier
LSTCP2=Taille (Octets)
LSTCP3=Position
LSTCP4=Description
STAT10=objet(s)
STAT20=octet(s)

ABT001=Open Source / Mozilla Public License 1.1
ABT002=Contactez moi:
ABT003=Page Internet:
ABT004=Dragon UnPACKer utilise:
ABT005=Equipe de Beta testeurs:
ABT006=Remerciements spéciaux a tous les traducteurs:

INFO99=Informations 
INFO00=Driver 
INFO01=Nom:  
INFO02=Auteur:
INFO03=Commentaire:
INFO04=Version: 
INFO05=E-mail: 
INFO10=Fichier 
INFO11=Format: 
INFO12=Entrées: 
INFO13=Taille: 
INFO14=Chargement: 
INFO20=Nom de l'extension
INFO21=Version
INFO22=Informations Avancées
INFO23=Ver.Int.:
SCHTIT=Rechercher 
SCHGRP=Options 
SCH001=Faire la  différence entre Majuscules et Minuscules
SCH002=Tous les fichiers
SCH003=Répertoire actuel uniquement
SCH004=objet(s) trouvé(s)
DIRTIT=Choisissez le répertoire...
POP1S1=Extraire le fichier vers...
PSUB01=Sans convertion
PSUB02=Convertir vers %d
POP1S2=Extraire les fichiers vers...
POP1S3=Ouvrir
POP1S4=Sans Convertion
POP2S1=Extraire tout vers...
POP2S2=Extraire les sous-répertoires vers...
POP2S3=Informations
POP2S4=Développer tout
POP2S5=Replier tout
POP3S1=Afficher le journal
POP3S2=Cacher le journal
POP3S3=Effacer le journal
POP4S1=Cacher la prévisualisation
POP4S2=Afficher la prévisualisation
POP5S1=Mode d'affichage
POP5S2=Taille originale avec barres de défilement (si nécessaire)
POP5S3=Réduit/Augmenté à la taille du paneau
POP5S4=Options de la prévisualisation...
OPTTIT=Configuration
OPT000=Options Avancées
OPT010=Répertoire Temporaire
OPT011=Utiliser le répertoire auto-detecté
OPT012=Utiliser le répertoire défini:
OPT013=Selectionnez le répertoire temporaire a utiliser...
OPT020=Options pour le double click
OPT021=Option 'Extraire fichier... Sans conversion' l'option par défaut
OPT030=Mémoire cache
OPT031=Selectionnez la taille pour la mémoire cache lors de l'extraction:
OPT032=Pas de buffer / Déconseillé! (Trés lent)
OPT033=%d octet(s)
OPT034=%d koctets
OPT035=%d Moctets
OPT036=Par Défaut
OPT100=Options générales
OPT110=Langue
OPT120=Options
OPT121=Ne pas afficher d'écran de démarrage
OPT122=Permettre seulement une instance du programme a la fois
OPT123=Détection intelligente des formats de fichiers
OPT124=Prendre les icones dans le registre Windows (plus lent)
OPT125=Utiliser l'HyperRipper si aucune extension n'arrive à ouvrir le fichier
OPT126=Afficher le journal d'exécution
OPT191=Ces extensions gèrent la convertion des formats de fichiers lors de l'extraction et de la prévisualisation. Exemple: Conversion des textures .ART vers .BMP
OPT192=Ces extensions gèrent l'ouverture des formats de fichiers pour que Dragon UnPACKer puisse les explorer. Si un fichier n'est pas supporté cela signifie qu'aucune extension ne peut le lire (voir HyperRipper dans ce cas ci-dessous).
OPT193=Ces extensions gèrent les formats qu'il est possible de rechercher dans le HyperRipper (ex: MPEG Audio, BMP, etc..)
OPT200=Drivers
OPT201=A Propos..
OPT202=Configurer
OPT203=Drivers:
OPT210=Informations
OPT220=Priorité :      
OPT221=Rafraîchir la liste 
OPT300=Icones/Look
OPT310=Informations
OPT320=Fichiers de Look: 
OPT330=Options de Look:  
OPT331=Style XP pour les menus et la barre d'outils 
OPT400=Types de fichiers 
OPT401=Selectionnez les extensions que Dragon UnPACKer doit ouvrir quand vous double-cliquez dessus dans l'Explorateur:
OPT402=Icône actuelle pour l'association:
OPT411=Aucune
OPT412=Toutes
OPT420=Vérifier les associations au démarrage
OPT430=Utiliser une icône externe:
OPT431=Selectionnez l'icône a utiliser pour l'association avec Dagon UnPACKer 5...
OPT432=Icônes
OPT440=Changer le texte associé:
OPT450=Ajout de l'extension "%d" dans Windows Explorer
OPT451=Ouvrir avec Dragon UnPACKer 5
OPT500=Convertion
OPT501=Extensions de convertion:
OPT510=Informations
OPT600=Extensions
OPT701=Extensions HyperRipper:
OPT710=Informations 
OPT800=Journal d'exécution 
OPT810=Options du journal d'exécution 
OPT811=Afficher le journal d'exécution dans la fenêtre principale 
OPT840=Niveau de détail
OPT841=Sélectionnez le niveau de détail pour le journal d'exécution: 
OPT850=Bas - Aucune information supplémentaire
OPT851=Moyen - Affichage de plus d'informations 
OPT852=Haut - Affichage du maximum d'informations
OPT900=Prévisualisation
OPT910=Options de la prévisualisation
OPT911=Activer la prévisualisation
OPT920=Taille limite de prévisualisation
OPT921=Ne pas limiter la taille des fichiers à prévisualiser
OPT922=Limiter la taille des fichiers à prévisualiser (Recommandé)
OPT923=Limite:
OPT924=Trés Basse
OPT925=Basse
OPT926=Moyenne (Recommandé)
OPT927=Haute
OPT928=Très Haute
OPT940=Mode d'affichage de la prévisualisation
OPEN00=Ouvrir un fichier...
XTRCAP=Extraction en cour...
XTRSTA=Extraction de %f...
ALLCMP=Tous les fichiers compatibles
ALLFIL=Tous les fichiers
BUTSCH=Chercher
BUTOK=Ok
BUTGO=Go!
BUTDIR=Nouveau Dossier
BUTDET=Details
BUTDEL=Supprimer
BUTADD=Ajouter
BUTCNV=Convertir
BUTCAN=Annuler
BUTINS=Installer
BUTCLO=Terminer
BUTCON=Continuer
BUTNEX=Suivant
BUTPAL=Ajouter Palette
BUTREF=Rafraichir
BUTREM=Supprimer
BUTEDT=Editer
HYPAD=Cette pre-version ne cherche que les fichiers sons WAVE.
HYPFIN=Type %t (Position %o / %s octets)
HYPOPN=Choisissez le fichier a scanner...
HR0000=A Propos...
HR0001=Le HyperRipper permet de rechercher des formats de fichiers "standard"%ndans d'autres fichiers non supportés directement par Dragon UnPACKer.
HR0002=ATTENTION: Pour utilisateurs experimentés uniquement!
HR0003=Nombre d'extensions chargés:
HR0004=Nombre total de formats:
HR1000=Rechercher
HR1001=Source:
HR1002=Créer un fichier HyperRipper (HRF):
HR1003=Annuler / Arreter
HR1011=Taille du buffer:
HR1012=Taille du rollback:
HR1013=Vitesse de recherche:
HR1014=Fichiers trouvées:
HR2000=Formats
HR2011=Format
HR2012=Type
HR2021=Configurer
HR2022=Tous/Aucun
HR3000=Fichier HyperRipper
HR3010=Inclure les informations suivantes:
HR3011=Titre:
HR3012=URL:
HR3020=Version HRF
HR3021=Version
HR3030=Options
HR3031=Ne pas identifier le programme (anonyme)
HR3032=Ne pas indiquer la version du programme
HR3033=Taille maximum du nom d'une entrée:
HR3034=%c caractères
HR3035=Compatible avec version:
HR3036=%v et plus recentes
HR4000=Options Avancées
HR4010=Tampon mémoire
HR4011=Koctets
HR4012=octets
HR4020=Rollback de mémoire
HR4021=Pas de Rollback (non recommandé)
HR4022=Rollback par défaut (128 octets)
HR4023=Grand Rollback (1/4 du tampon)
HR4024=Enorme Rollback (1/2 du tampon)
HR4030=Formattage des entrées
HR4031=Faire des répertoires grâce au type retourné par l'extension
HR4050=Nommage
HR4051=Automatique
HR4052=Personnalisé
HR4053=Exemple
HRLEGF=fichier
HRLEGN=nombre
HRLEGX=extension
HRLEGO=position (Dec)
HRLEGH=position (Hex)
HRLG01=Pas de formats sélectionnées...
HRLG02=Fichier %f introuvable!
HRLG03=Ouverture de %f...
HRLG04=Fait!
HRLG05=Allocation mémoire...
HRLG06=Recherche des formats dans le fichier...
HRLG07=Impossible de lire %b octets dans le fichier...
HRLG08=Format %e trouvé @ %a (%s octets)
HRLG09=Scanné %s en %t secs!
HRLG10=octets
HRLG11=Ko
HRLG12=Mo
HRLG13=Go
HRLG14=Sauvegarde HRF...
HRLG15=Affichage du résultat dans Dragon UnPACKer...
HRLG16=Erreur pendant la recherche... Annulation...
HRLG17=Libération de la mémoire...
HRLG18=Erreur!
HRTYP0=Inconnu
HRTYP1=Audio
HRTYP2=Video
HRTYP3=Image
HRTYPM=Autre
HRTYPE=Type (%i)
HRD000=Options MPEG Audio
HRD100=Formats MPEG Audio à rechercher
HRD101=Non standard
HRD200=Limitations
HRD211=Nombre de frames minimum:
HRD212=Nombre de frames maximum:
HRD213=frame(s)
HRD221=Taille minimum:
HRD222=Taille maximum:
HRD223=octet(s)
HRD300=Spécial
HRD301=Rechercher entête Xing VBR
HRD302=Rechercher ID3Tag v1.0/1.1
LST000=Créer une liste
LST001=Trier
LST100=Modèle
LST101=Version:
LST102=Auteur:
LST103=Email:
LST104=URL:
LST200=Liste
LST201=Entrées sélectionnées
LST202=Toutes les entrées
LST203=Répertoire actuel
LST204=Inclure les sous-répertoires
LST300=Ordre de tri
LST301=Alphabétique
LST302=Taille
LST303=Position
LST304=Décroissant
LST400=ATTENTION: Activer le tri ralentira enormement le traitement...
LST500=Sauvegarder la liste vers...
LST501=Récuperation de l'entête du modèle...
LST502=Récuperation du footer du modèle...
LST503=Récuperation de l'élement variable du modèle...
LST504=Récuperation de la liste d'entrées...
LST505=Tri de la liste de %v entrées...
LST506=Création de la liste de %v entrées... %p%
LST507=Sauvegarde du fichier de liste...
LST508=Extraction des fichiers supplémentaires du modèle...
LST509=Terminé!
CNV000=Convertion d'une image/texture...
CNV001=Palette
CNV010=Note:%nUtilisez la boite de configuration pour%ngérer (ajouter ou supprimer) des palettes.
CNV100=Ajout d'une nouvelle palette
CNV101=Source:
CNV102=Titre:
CNV103=Auteur:
CNV104=Format:
CNV110=Palette de données brutes (RAW) 768octets
CNV120=Inconnu
CNV900=Une erreur est survenue durant la création de la palette.%n%nFichier source: %f%nFormat source: %t%n%nErreur: %e%n%nImpossible d'ajouter la palette.
CNV901=La palette a été convertie avec succés!%nVous pouvez désormais la sélectionner dans la liste.
CNV990=Le nom de palette spécifié existe déjà.
CNV991=Format inconnu (essayez de changer le format).
CNV992=Etes-vous sur de vouloir supprimer la palette?
11TH01=Pour activer le support des fichiers du jeu The 11th Hour, l'extension a besoin de copier deux fichiers que vous pouvez trouver dans le répertoire GROOVIE du CDRom de The 11th Hour.%n%nVoulez-vous continuer ?
11TH02=Selectionnez le fichier %f de 11th Hour...
11TH03=L'extension est désormais activée.%nMaintenant vous pouvez ouvrir les fichiers GJD de The 11th Hour!
11TH04=La désactivation du support The 11th Hour va supprimer les fichiers suivants:%n%n%a%n%b%n%nVous pourrez les recréer plus tard en réactivant le support The 11th Hour.%n%nEtes-vous sur de vouloir continuer?
11TH05=Statut de l'extension: %s%n(Activée signifie que vous pouvez ouvrir des fichiers GJD)%n(Désactivée signifie que vous devez importer les fichiers GJD.GJD et DIR.RL)
11TH06=Désactivée
11TH07=Activée
11TH10=Configuration de l'extension pour le support de The 11th Hour
11TH11=Activer
11TH12=Désactiver
11TH13=Statut actuel:
11TH14=Support The 11th Hour:
DUT100=Configuration
DUT101=Librairie
DUT110=ID
DUT111=Chemin d'accès
DUT112=Jeu
DUT113=ND?
DUT114=IDJ
DUT201=Indiquez le jeu correspondant au fichier ouvert:
DUT202=Ne plus demander pour ce répertoire
DUT203=- Inconnu / Autre -

TLD001=Lecture de %f par le driver...
TLD002=Recuperation des données...
TLD003=Parsing et Affichage de la racine...

EX=Fichier %e
EXANIM=Animation (%e)
EXART=Archive ART (Textures)
EXBIN=Données (%e)
EXCFG=Configuration (%e)
EXDLL=Librairie à Liaison Dynamique
EXSCRP=Script (%e)
EXFIRE=Texture Feu (Dynamique)
EXIMG=Image %e (%d)
EXMAP=Level Map (%e)
EXMDL=Modèle 3D (%e)
EXMPEG=Audio/Video MPEG
EXMUS=Musique (%d)
EXPAL=Palette
EXSND=Son (%d)
EXSPR=Sprite
EXTEX=Texture (%e)
EXTXT=Document Texte

LOG001=Initialisation des extensions:
LOG002=Chargement des extensions Drivers...
LOG003=Chargement des extensions Convertions...
LOG004=Chargement des extensions HyperRipper...
LOG005=Librairies utilisées:
LOG009=%p extension(s)
LOG101=Ouverture du fichier "%f":
LOG102=Format de fichier non reconnu!
LOG103=Démarrage de HyperRipper...
LOG104=Fichier introuvable (ou bloqué par un autre programme/utilisateur)...
LOG200=Fermeture fichier actuel...
LOG300=Affichage des entrées du répertoire "%d"...
LOG301=%e entrée(s)... 
LOG400=Utilisation de la détection intelligente du format du fichier source. 
LOG500=L'extension Driver "%d" pense pouvoir ouvrir ce fichier.
LOG501=Ouverture du fichier en utilisant l'extension "%d"...
LOG502=Récupération de %x entrée(s)...
LOG503=Récupération des répertoires...
LOG504=Fichier ouvert grâce à l'extension "%p" (format détecté: "%f")
LOG510=Fait!
LOG511=Succès!
LOG512=Echec!
LOG513=Erreur!
LOGC01=Libération de %p extension(s)...
LOGC02=Recherche des extensions...
LOGC10=Convertion de "%a" vers "%b"...
LOGC11=Méthode rapide!
LOGC12=Méthode lente (extensions obsolètes)!
LOGC13=Convertion vers "%b"...
LOGC14=Convertion de multiples entrées vers "%b"...
LOGC15=Convertion...

ERR000=Erreur
ERR101=Une erreur est survenue pendant l'extraction.
ERR102=Une erreur est survenue pendant l'extraction du fichier:
ERR200=Une erreur non prise en charge est survenue:
ERR201=Dans:
ERR202=Exception:
ERR203=Message:
ERR204=Si vous voulez faire un rapport d'erreur veuillez inclure les details (appuyez sur bouton "Details").
ERR205=Copier
ERR206=Envoyez le rapport d'erreur a:
ERRCMP=Impossible de trouver le fichier companion (nécessaire) suivant:%n%n%f
ERRFIL=Ceci n'est pas un fichier %f valide (%g).
ERROPN=Impossible d'ouvrir le fichier source:%n%n%f
ERRUNK=Aucun driver n'a pu charger ce fichier.
ERRTMP=Impossible de supprimer le fichier temporaire:%n%n%f
ERRD01=Le Driver n'a pas pu etre chargé (mauvaise version de l'interface ou ce n'est pas un driver DUP5).
ERRD02=Le Driver n'a pas pu etre chargé (des fonctions importantes sont manquantes).
ERRDRV=Une erreur est survenue lors de l'utilisation du driver "%d":
ERRDR1=Pour toute question en relation avec cette erreur veuillez contacter l'auteur du driver (%a).
ERRC01=L'extension de convertion n'a pas pu etre chargé (mauvaise version de l'interface ou ce n'est pas une extension DUP5).
ERRC02=L'extension de convertion n'a pas pu etre chargé (des fonctions importantes sont manquantes).
ERRH01=L'extension HyperRipper n'a pas pu etre chargé (mauvaise version de l'interface ou ce n'est pas une extension DUP5).
ERRH02=L'extension HyperRipper n'a pas pu etre chargé (des fonctions importantes sont manquantes).
ERRH03=Attention: Cette extension ne peut pas rechercher au delà de 2Go de données (après cette limite elle ne trouvera rien).
ERRH04=Extension HyperRipper ID #%i inconnue
ERRH05=L'extension "%p" ne peut pas rechercher de données au delà des 2Go.
ERREMP=Le fichier est vide.
ERRIO=Impossible d'ouvrir le fichier:%n%n%f%n%nVérifiez qu'il n'est pas déjà ouvert par un autre programme ou qu'il ne soit pas/plus accessible.
{/BODY}
#
# Fin du fichier source de langue (Language Source File)
#
{/LSF}
