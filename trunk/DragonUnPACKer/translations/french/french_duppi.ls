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
# sous-r�pertoire \Data\ de Dragon UnPACKer.
#
# Pour selectionner une autre langue pour Dragon UnPACKer lancez:
# DrgUnPACK5.exe /lng
# Ou aller dans les Options g�n�rale.
#
# NE MODIFIEZ AUCUN MOT CLE - CHANGEZ JUSTE LE TEXTE APRES LE SYMBOLE =
#
# Si vous faite une traduction n'h�sitez pas a l'envoyer a Alex Devilliers
# afin qu'elle soit distribu�e sur le site internet et avec le programme.
#
# Vous pouvez contacter Alex Devilliers par e-mail:
# translation@dragonunpacker.com et par ICQ: 1535372 (Elbereth)
#
# ============================================================================
# Informations sur cette traduction
# ============================================================================
#
# version 11:
# Nouvelles entr�es pour la pr�visualisation
#
# version 10:
# Premi�re version sous forme de fichier .LS
#
{LSF}
{HEADER}
#
# * Header *
#
# + Name +
# Ecriverz ici le nom qui apparaitra das la boite de dialogue de Dragon
# UnPACKer pour votre fichier de langue. Ex: Fran�ais (French)
#
# Peut contenir jusqu'� 80 caract�res
#
Name = Fran�ais (French)
#
# + Author +
# Inscrivez ici votre nom ou un surnom (et n'importe quel commentaire)
#
# Peut contenir jusqu'� 80 caract�res
#
Author = Alexandre Devilliers
#
# + Email +
# Inscrivez ici votre email (ou vide si vous ne voulez pas le divulger)
#
# Peut contenir jusqu'� 80 caract�res
#
Email = dup5.translation@dragonunpacker.com
#
# + URL +
# Inscrivez une adresse internet o� l'on peut r�cuperer la derniere version de
# votre traduction
#
# Peut contenir jusqu'� 80 caract�res
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
# Chemin & nom du fichier de l'ic�ne affich�e avec le nom de langue.
#
# Ce fichier doit �tre de type Windows Bitmap 16x16 (Hauteur=16 Largeur=16).
# Le compilateur ne teste pas ce fichier mais le programme n'affichera pas
# l'icone si ce n'est pas un fichier valide.
#
# Si vous ne d�sirez pas d'ic�ne commentez la ligne.
#
IconFile = flag_fr.bmp
#
# + OutFile +
# Chemin & nom du fichier du resultat de la compilation.
#
OutFile = french.lng
#
# + FontName +
# Nom de la fonte a utiliser (si vous ne d�sirez pas utiliser celle par d�faut)
# (Par ex Arial, Tahoma, etc..)
#
#FontName=Comic Sans MS
#
# + Compression +
# Compression a utiliser pour les donn�es.
#
# Valeurs possibles:   0 = Sans compression (Par D�faut)
#                     99 = Zlib
#
Compression=99
#
{/HEADER}
#
# * Body *
#
# Chaque mot cl� utilis� dans le programme est suivi du texte qui apparait
# dans le programme.
#
# Ex: TEST01=Ceci est un test
#
# Chaque mot cl� ne peut faire que 6 caract�res alpha-num�riques au maximum.
#
# Macro speciales:
#  %n = Saute une ligne
# N'importe qu'el autre lettre suivant un % (ex: %k) est une macro speciale qui
# sera remplac�e par Dragon UnPACKer lors de l'execution.
#
# N'AJOUTER/SUPPRIMER PAS DE MOT CLE SAUF SI VOUS SAVEZ CE QUE VOUS FAITES.
# LE PROGRAMME TESTE LA PRESENCE DE CERTAINS MOT CLE ET N'UTILISERA PAS VOTRE
# FICHIER DE LANGUE S'IL MANQUE DES MOTS CLES.
#
{BODY}
PI0000=Version de DUP5 detect�e:
PI0001=Titre
PI0002=Auteur
PI0003=Commentaire
PI0004=URL
PI0005=Informations sur le package 
PI0006=Veuillez patientez pendant l'installation du package...
PI0007=Ce programme va installer le package suivant dans le r�pertoire de Dragon UnPACKer.
PI0008=Dragon UnPACKer 5 doit �tre ferm� pour continuer.
PI0009=Statut:
PI0010=En attente de l'utilisateur...
PI0011=Etes-vous sur de vouloir quitter?
PI0012=Erreur... DUP5 est lanc�...
PI0013=Erreur Dragon UnPACKer 5 est lanc�...%nFermez le puis r�-essayez.
PI0014=Erreur fatale.. Version non support�e de Package Dragon UnPACKer 5 (.D5P) [version %v]
PI0015=Erreur fatale.. Ceci n'est pas un fichier de Package Dragon UnPACKer 5 (.D5P)
PI0016=Utilisation: duppi <fichier.d5p>%n%nCeci installera le package fichier.d5p dans le r�pertoire de Dragon UnPACKer 5.
PI0017=Fichier introuvable!%n%f
PI0018=Lecture du package...
PI0019=Le fichier suivant existe d�j� et est plus r�cent (ou le m�me) que le fichier que vous essayez d'installer:%n%n%f%n%nVersion actuelle: %1%nFichier du package: %2%n%nInstaller quand m�me?
PI0020=Le fichier suivant a un mauvais CRC. Le fichier ne sera pas install�.%nSi vous avez t�l�chargez ce fichier, re-t�l�chargez le.%n%n%f
PI0021=Le fichier suivant a une mauvaise taille. Le fichier ne sera pas install�.%nSi vous avez t�l�chargez ce fichier, re-t�l�chargez le.%n%n%f
PI0022=Installation avec succ�s de %i fichier(s)...
PI0023=Installation temin�e avec succ�s...
PI0024=Installation non r�ussie (%e fichier(s) ont donn�s des erreurs)...
PI0025=Installation non r�ussie... %i fichier(s) install�s avec succ�s et %e erreur(s)...
PI0026=Chemin d'acc�s a Dragon UnPACKer 5 introuvable.%nVeuillez lancer Dragon UnPACKer 5 au moins une fois avant de r��ssayer.
PI0027=Evit�...
PI0028=Ko
PI0029=Lecture...
PI0030=D�compression...
PI0031=Ecriture...
PI0032=OK
PI0033=Version
PI0034=Ce programme vous permet d'installer des packages de Dragon UnPACKer 5.
PI0035=Que voulez vous faire?
PI0036=Rechercher sur internet les mises a jour et les installer.
PI0037=Remarque: Aucune information n'est envoy� � Dragon Software.
PI0038=Options Proxy
PI0039=Installer un package depuis le disque dur:
PI0040=Selectionner le package a installer...
PI0041=Pour installer ce fichier D5P vous devez disposer d'une version de Duppi plus r�cente.%nVotre version de Duppi: %y%nVersion de Duppi requise: %v%n%nPour cela mettez � jour votre Dragon UnPACKer 5.
PI0042=Ce package ne peut pas �tre install� avec votre version de Dragon UnPACKer.
PI0043=Impossible d'enregistrer %s.
PI0044=Donn�es erronn�es en provenance du serveur de mises � jour!
PI0045=R�pertoire de destination inconnu!
PI0046=Mise � jour de Duppi termin�e avec succ�s!
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
PII102=Telechargement de %f (%b octets re�us)
PII103=Reception termin�e de %f (%b octets)
PII104=Erreur: %c (%d)
PII105=Serveur contact� avec succ�s!
PII106=-Aucune description-
PII107=Une nouvelle version de Dragon UnPACKer est disponible en t�l�chargement.%n%nNouvelle version: %v%nCommentaire: %c%n%nVoulez vous aller sur la page officielle pour la t�l�charger?
PII108=%p plugin(s) et %t traduction(s) disponibles!
PII200=Aucune mise a jour n'a pu �tre t�l�charg�e.%nLe programme va maintenant s'arreter.
PIEM01=Connection � la base de donn�es impossible. R�essayez ult�rieurement!
PIEM10=Erreur serveur lors de la recherche derni�re version stable!
PIEM11=Erreur serveur lors de la recherche derni�re version WIP!
PIEM20=Erreur serveur lors de la recherche de votre version!
PIEM30=Erreur serveur lors de la recherche des plugins de convertion disponibles!
PIEM31=Erreur serveur lors de la recherche des plugins driver disponibles!
PIEM32=Erreur serveur lors de la recherche des plugins HyperRipper disponibles!
PIEM33=Erreur serveur lors de la recherche des traductions disponibles!
PIEP01=Param�tre erronn�e! Si vous n'avez pas encore lancer Dragon UnPACKer faites-le, puis relancer Duppi.
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
