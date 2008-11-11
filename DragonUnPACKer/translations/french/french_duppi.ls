# Language Source File (pour DLNGC v4.0)
# ============================================================================
#  Programme: Dragon UnPACKer v5.3.3 Beta
#     Langue: English
#    Version: 1
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
#
ProgramID = PI
ProgramVer = 1
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
PI0000=Version de DUP5 detectée:
PI0001=Titre
PI0002=Auteur
PI0003=Commentaire
PI0004=URL
PI0005=Informations sur le package 
PI0006=Veuillez patientez pendant l'installation du package...
PI0007=Ce programme va installer le package suivant dans le répertoire de Dragon UnPACKer.
PI0008=Dragon UnPACKer 5 doit être fermé pour continuer.
PI0009=Statut:
PI0010=En attente de l'utilisateur...
PI0011=Etes-vous sur de vouloir quitter?
PI0012=Erreur... DUP5 est lancé...
PI0013=Erreur Dragon UnPACKer 5 est lancé...%nFermez le puis ré-essayez.
PI0014=Erreur fatale.. Version non supportée de Package Dragon UnPACKer 5 (.D5P) [version %v]
PI0015=Erreur fatale.. Ceci n'est pas un fichier de Package Dragon UnPACKer 5 (.D5P)
PI0016=Utilisation: duppi <fichier.d5p>%n%nCeci installera le package fichier.d5p dans le répertoire de Dragon UnPACKer 5.
PI0017=Fichier introuvable!%n%f
PI0018=Lecture du package...
PI0019=Le fichier suivant existe déjà et est plus récent (ou le même) que le fichier que vous essayez d'installer:%n%n%f%n%nVersion actuelle: %1%nFichier du package: %2%n%nInstaller quand même?
PI0020=Le fichier suivant a un mauvais CRC. Le fichier ne sera pas installé.%nSi vous avez téléchargez ce fichier, re-téléchargez le.%n%n%f
PI0021=Le fichier suivant a une mauvaise taille. Le fichier ne sera pas installé.%nSi vous avez téléchargez ce fichier, re-téléchargez le.%n%n%f
PI0022=Installation avec succés de %i fichier(s)...
PI0023=Installation teminée avec succés...
PI0024=Installation non réussie (%e fichier(s) ont donnés des erreurs)...
PI0025=Installation non réussie... %i fichier(s) installés avec succés et %e erreur(s)...
PI0026=Chemin d'accés a Dragon UnPACKer 5 introuvable.%nVeuillez lancer Dragon UnPACKer 5 au moins une fois avant de rééssayer.
PI0027=Evité...
PI0028=Ko
PI0029=Lecture...
PI0030=Décompression...
PI0031=Ecriture...
PI0032=OK
PI0033=Version
PI0034=Ce programme vous permet d'installer des packages de Dragon UnPACKer 5.
PI0035=Que voulez vous faire?
PI0036=Rechercher sur internet les mises a jour et les installer.
PI0037=Remarque: Aucune information n'est envoyé à Dragon Software.
PI0038=Options Proxy
PI0039=Installer un package depuis le disque dur:
PI0040=Selectionner le package a installer...
PI0041=Pour installer ce fichier D5P vous devez disposer d'une version de Duppi plus récente.%nVotre version de Duppi: %y%nVersion de Duppi requise: %v%n%nPour cela mettez à jour votre Dragon UnPACKer 5.
PI0042=Ce package ne peut pas être installé avec votre version de Dragon UnPACKer.
PI0043=Impossible d'enregistrer %s.
PI0044=Données erronnées en provenance du serveur de mises à jour!
PI0045=Répertoire de destination inconnu!
PI0046=Mise à jour de Duppi terminée avec succès!
PII001=Titre
PII002=Votre version
PII003=Version disponible
PII004=Description
PII005=Taille
PII011=Afficher les:
PII012=Plugins
PII013=Traductions
PII021=Version stable actuelle :
PII022=Version WIP actuelle :
PII030=Traduction
PII031=Revision
PII032=Auteur
PII100=la liste des mises a jours
PII101=Telechargement de %f...
PII102=Telechargement de %f (%b octets reçus)
PII103=Reception terminée de %f (%b octets)
PII104=Erreur: %c (%d)
PII105=Serveur contacté avec succés!
PII106=-Aucune description-
PII107=Une nouvelle version de Dragon UnPACKer est disponible en téléchargement.%n%nNouvelle version: %v%nCommentaire: %c%n%nVoulez vous aller sur la page officielle pour la télécharger?
PII108=%p plugin(s) et %t traduction(s) disponibles!
PII200=Aucune mise a jour n'a pu être téléchargée.%nLe programme va maintenant s'arreter.
PIEM01=Connection à la base de données impossible. Réessayez ultérieurement!
PIEM10=Erreur serveur lors de la recherche dernière version stable!
PIEM11=Erreur serveur lors de la recherche dernière version WIP!
PIEM20=Erreur serveur lors de la recherche de votre version!
PIEM30=Erreur serveur lors de la recherche des plugins de convertion disponibles!
PIEM31=Erreur serveur lors de la recherche des plugins driver disponibles!
PIEM32=Erreur serveur lors de la recherche des plugins HyperRipper disponibles!
PIEM33=Erreur serveur lors de la recherche des traductions disponibles!
PIEP01=Paramètre erronnée! Si vous n'avez pas encore lancer Dragon UnPACKer faites-le, puis relancer Duppi.
PIEP02=Le serveur n'a pas reconnu votre version de Dragon UnPACKer.
PIEUNK=Erreur serveur inconnu: "%e"
PIP000=Configuration du proxy
PIP001=Proxy:
PIP002=Port du proxy:
PIP003=Le proxy requiere une identification:
PIP004=Utilisateur:
PIP005=Mot de passe:

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
{/BODY}
#
# Fin du fichier source de langue (Language Source File)
#
{/LSF}
