; *** Inno Setup version 4.1.4+ English messages ***
;
; To download user-contributed translations of this file, go to:
;   http://www.jrsoftware.org/is3rdparty.php
;
; Note: When translating this text, do not add periods (.) to the end of
; messages that didn't have them already, because on those messages Inno
; Setup adds the periods automatically (appending a period would result in
; two periods being displayed).
;
; Transtated by Alain MILANDRE (v3.0.5)    email almi@almiservices.com
; Update to v3.0.6 by Alexandre STANCIC    email a.stancic@laposte.net
; Update to v4.0.0 by Stephane WIERZBICKI  email swierzbicki@free.fr
; Update to v4.1.3 by Michel DESSSAINTES   email michel.dessaintes@free.fr
; Update to v4.1.4 by Alexandre DEVILLIERS email is414fr@drgsoft.com
;
; $jrsoftware: issrc/Files/Default.isl,v 1.51 2004/02/08 18:50:49 jr Exp $

[LangOptions]
LanguageName=Français
LanguageID=$040C
; If the language you are translating to requires special font faces or
; sizes, uncomment any of the following entries and change them accordingly.
;DialogFontName=MS Shell Dlg
;DialogFontSize=8
;WelcomeFontName=Verdana
;WelcomeFontSize=12
;TitleFontName=Arial
;TitleFontSize=29
;CopyrightFontName=Arial
;CopyrightFontSize=8

[Messages]

; *** Application titles
SetupAppTitle=Installation
SetupWindowTitle=Installation - %1
UninstallAppTitle=Désinstallation
UninstallAppFullTitle=Désinstallation de %1

; *** Misc. common
InformationTitle=Information
ConfirmTitle=Confirmation
ErrorTitle=Erreur

; *** SetupLdr messages
SetupLdrStartupMessage=%1 va être installé(e). Souhaitez-vous continuer ?
LdrCannotCreateTemp=Impossible de créer un fichier temporaire. Installation annulée
LdrCannotExecTemp=Impossible d'exécuter un fichier depuis le répertoire temporaire. Installation annulée

; *** Startup error messages
LastErrorMessage=%1.%n%nErreur %2: %3
SetupFileMissing=Le fichier %1 n'a pas été trouvé dans le répertoire de l'installation. Corrigez le problème ou obtenez une nouvelle copie du programme.
SetupFileCorrupt=Les fichiers de l'installation sont corrompus. Obtenez une nouvelle copie du programme.
SetupFileCorruptOrWrongVer=Les fichiers d'installation sont corrompus ou sont incompatibles avec cette version de l'installeur. Corrigez le problème ou obtenez une nouvelle copie du programme.
NotOnThisPlatform=Ce programme ne s'exécutera pas sur %1.
OnlyOnThisPlatform=Ce programme doit être exécuté sur %1.
WinVersionTooLowError=Ce programme requiert %1 version %2 ou supérieure.
WinVersionTooHighError=Ce programme ne peut être installé sur %1 version %2 ou supérieure.
AdminPrivilegesRequired=Vous devez être connecté en tant qu'administrateur pour installer ce programme.
PowerUserPrivilegesRequired=Vous devez être connecté en tant qu'administrateur ou comme un membre du groupe Administrateurs pour installer ce programme.
SetupAppRunningError=L'installation a détecté que %1 est actuellement en cours d'exécution.%n%nFermez toutes les instances de cette application maintenant, puis cliquez OK pour continuer, ou Annulation pour arrêter l'installation.
UninstallAppRunningError=La procédure de désinstallation a détecté que %1 est actuellement en cours d'exécution.%n%nFermez toutes les instances de cette application maintenant, puis cliquez OK pour continuer, ou Annulation pour arrêter l'installation.

; *** Misc. errors
ErrorCreatingDir=L'installeur n'a pas pu créer le répertoire "%1"
ErrorTooManyFilesInDir=L'installeur n'a pas pus créer un fichier dans le répertoire "%1" parce qu'il contient trop de fichiers

; *** Setup common messages
ExitSetupTitle=Quitter l'installation
ExitSetupMessage=L'installation n'est pas terminée. Si vous quittez maintenant, le programme ne sera pas installé.%n%nVous devrez relancer l'installation une autre fois pour la terminer.%n%nQuitter l'installation ?
AboutSetupMenuItem=&A propos...
AboutSetupTitle=A Propos...
AboutSetupMessage=%1 version %2%n%3%n%n%1 page Web :%n%4
AboutSetupNote=

; *** Buttons
ButtonBack=< &Précédent
ButtonNext=&Suivant >
ButtonInstall=&Installer
ButtonOK=OK
ButtonCancel=Annuler
ButtonYes=&Oui
ButtonYesToAll=Oui pour &tout
ButtonNo=&Non
ButtonNoToAll=N&on pour tout
ButtonFinish=&Terminer
ButtonBrowse=Pa&rcourir...
ButtonWizardBrowse=Pa&rcourir...
ButtonNewFolder=&Nouveau Dossier

; *** "Select Language" dialog messages
SelectLanguageTitle=Choisir la langue de l'installation
SelectLanguageLabel=Choisir la langue à utiliser pendant l'installation :

; *** Common wizard text
ClickNext=Cliquez sur Suivant pour continuer ou sur Annuler pour quitter l'installation.
BeveledLabel=
BrowseDialogTitle=Rechercher un Dossier
BrowseDialogLabel=Sélectionnez un dossier dans la liste ci-dessous, et cliquez sur OK.
NewFolderName=Nouveau Dossier

; *** "Welcome" wizard page
WelcomeLabel1=Bienvenue dans l'Assistant d'Installation de [name]
WelcomeLabel2=Ceci va installer [name/ver] sur votre ordinateur.%n%nIl est recommandé de fermer toutes les autres applications avant de continuer.

; *** "Password" wizard page
WizardPassword=Mot de passe
PasswordLabel1=Cette installation est protégée par un mot de passe.
PasswordLabel3=Entrez votre mot de passe.%n%nLes mots de passes tiennent compte des majuscules et des minuscules.
PasswordEditLabel=&Mot de passe :
IncorrectPassword=Le mot de passe entré n'est pas correct. Essayez à nouveau.

; *** "License Agreement" wizard page
WizardLicense=Accord de licence
LicenseLabel=Veuillez lire l'information importante suivante avant de continuer.
LicenseLabel3=Veuillez lire l'Accord de Licence qui suit. Vous devez accepter les termes de cet accord avant de continuer cette installation.
LicenseAccepted=J'&accepte cet accord
LicenseNotAccepted=Je &refuse cet accord

; *** "Information" wizard pages
WizardInfoBefore=Information
InfoBeforeLabel=Veuillez lire les informations importantes suivantes avant de continuer.
InfoBeforeClickLabel=Lorsque vous serez prêt à continuer, cliquez sur Suivant.
WizardInfoAfter=Information
InfoAfterLabel=Veuillez lire les informations importantes suivantes avant de continuer.
InfoAfterClickLabel=Lorsque vous serez prêt à continuer, cliquez sur "Suivant".

; *** "User Information" wizard page
WizardUserInfo=Information Utilisateur
UserInfoDesc=Veuillez entrer vos informations.
UserInfoName=&Nom d'Utilisateur :
UserInfoOrg=&Organisation :
UserInfoSerial=Numéro de &Série :
UserInfoNameRequired=Vous devez écrire un nom.

; *** "Select Destination Location" wizard page
WizardSelectDir=Choisissez la destination
SelectDirDesc=Où devrait être installé [name] ?
SelectDirLabel2=Le programme va installer [name] dans le dossier suivant.%n%nPour continuer, cliquez sur Suivant. Si vous souhaitez choisir une dossier différent, cliquez sur Parcourir.
DiskSpaceMBLabel=Le programme requiert au moins [mb] Mo d'espace disque libre.
ToUNCPathname=L'installeur ne sait pas utiliser les chemins d'accès UNC. Si vous souhaitez installer [name] sur un réseau, vous devez "mapper" un disque.
InvalidPath=Vous devez entrer un chemin complet avec une lettre de lecteur; par exemple :%n%nC:\APP%n%nou un chemin UNC de la forme : %n%n\\serveur\partage
InvalidDrive=Le lecteur ou le partage UNC que vous avez sélectionné n'existe pas. Choisissez en un autre.
DiskSpaceWarningTitle=Pas assez d'espace disque
DiskSpaceWarning=L'installation nécessite au moins %1 Ko d'espace disque libre, mais le lecteur sélectionné n'a que %2 Ko de disponible.%n%nSouhaitez-vous quand même continuer ?
DirNameTooLong=Le nom de dossier ou son chemin d'accès est trop long.
InvalidDirName=Le nom de dossier n'est pas valide.
BadDirName32=Le nom du répertoire ne peut pas contenir les caractères suivants :%n%n%1
DirExistsTitle=Ce dossier existe
DirExists=Le dossier :%n%n%1%n%nexiste déjà. Souhaitez-vous l'utiliser quand même ?
DirDoesntExistTitle=Ce dossier n'existe pas
DirDoesntExist=Le dossier :%n%n%1%n%nn'existe pas. Souhaitez-vous qu'il soit créé ?

; *** "Select Components" wizard page
WizardSelectComponents=Sélection des Composants
SelectComponentsDesc=Quels sont les composants doivent être installés ?
SelectComponentsLabel2=Sélectionnez les composants que vous souhaitez installer; désactiver les composants que vous ne souhaitez pas installer. Cliquez sur Suivant lorsque vous êtes prêt à continuer.n.
FullInstallation=Installation complète
; if possible don't translate 'Compact' as 'Minimal' (I mean 'Minimal' in your language)
CompactInstallation=Installation compacte
CustomInstallation=Installation personnalisée
NoUninstallWarningTitle=Existance d'un Composant
NoUninstallWarning=L'Installation a détecté que les composants suivants sont déjà installés sur votre ordinateur :%n%n%1%n%nDésélectionner ces composants ne les désinstallera pas.%n%nVoulez-vous quand même continuer ?
ComponentSize1=%1 KB
ComponentSize2=%1 MB
ComponentsDiskSpaceMBLabel=La sélection courante nécessite au moins [mb] MB d'espace disque.

; *** "Select Additional Tasks" wizard page
WizardSelectTasks=Sélection des Tâches Supplémentaires
SelectTasksDesc=Quelles tâches additionnelles souhaitez-vous exécuter ?
SelectTasksLabel2=Sélectionnez les tâches additionnelles que l'Installeur doit exécuter pendant l'installation de [name], ensuite cliquez sur Suivant.

; *** "Select Start Menu Folder" wizard page
WizardSelectProgramGroup=Selectionnez un Groupe de Programme
SelectStartMenuFolderDesc=Où voulez vous placer les racourcis du programme ?
SelectStartMenuFolderLabel2=L'installeur va créer les raccourcis du programme dans le Groupe de Programme suivant. Pour continuer, cliquez sur Suivant.
NoIconsCheck=&Ne pas créer d'icône
MustEnterGroupName=Vous devez entrer un nom de groupe.
GroupNameTooLong=Le nom de dossier ou son chemin d'accès est trop long.
InvalidGroupName=Ce nom de dossier n'est pas valide.
BadGroupName=L'installation va ajouter les icones du programme dans le groupe du %1 suivant.
NoProgramGroupCheck2=&Ne pas créer de Groupe de Programme

; *** "Ready to Install" wizard page
WizardReady=Prêt à installer
ReadyLabel1=L'installeur vas maintenant installer [name] sur votre ordinateur.
ReadyLabel2a=Cliquez sur "Installer" pour continuer ou sur "Précédent" pour changer une option.
ReadyLabel2b=Cliquez sur "Installer" pour continuer.
ReadyMemoUserInfo=Information utilisateur :
ReadyMemoDir=Dossier de destination :
ReadyMemoType=Type d'installation :
ReadyMemoComponents=Composants sélectionnés :
ReadyMemoGroup=Groupe de Programme :
ReadyMemoTasks=Tâches additionnelles :

; *** "Preparing to Install" wizard page
WizardPreparing=Préparation de la phase d'Installation
PreparingDesc=L'Installeur est prêt à installer [name] sur votre ordinateur.
PreviousInstallNotCompleted=L'Installation/Désinstallation d'une version précédente du programme n'est pas totalement achevé. Vueillez redémarrer votre ordinateur pour achever cette phase d'installation.%n%nAprès le redémarrage de votre ordinateur, ré-exécutez l'Installeur pour terminer l'installation de [name].
CannotContinue=L'Installeur ne peut continuer. Veulliez cliquer sur Annuler pour sortir.

; *** "Installing" wizard page
WizardInstalling=Installation en cours
InstallingLabel=Veuillez patienter pendant que l'Installeur copie [name] sur votre ordinateur.

; *** "Setup Completed" wizard page
FinishedHeadingLabel=Finalisation de l'Assistant d'Installation de [name]
FinishedLabelNoIcons=L'Installeur a terminé d'installer [name] sur votre ordinateur.
FinishedLabel=L'Installeur a terminé d'installer [name] sur votre ordinateur. L'application peut être lancée en sélectionnant les icônes installées.
ClickFinish=Cliquez sur Terminer pour quitter l'Installation.
FinishedRestartLabel=Pour finir l'installation de [name], L'Installeur doit redémarrer votre ordinateur.%n%nVoulez-vous redémarrer maintenant ?
FinishedRestartMessage=Pour finir l'installation de [name], L'Installeur doit redémarrer votre ordinateur.%n%nVoulez-vous redémarrer maintenant ?
ShowReadmeCheck=Oui, Je souhaiterais lire le fichier LisezMoi/ReadMe
YesRadio=&Oui, redémarrer l'ordinateur maintenant
NoRadio=&Non, je redémarrerai mon ordinateur plus tard
; used for example as 'Run MyProg.exe'
RunEntryExec=Executer %1
; used for example as 'View Readme.txt'
RunEntryShellExec=Voir %1

; *** "Setup Needs the Next Disk" stuff
ChangeDiskTitle=L'installation a besoin du disque suivant
SelectDiskLabel2=Veuillez insérer le disque %1 et cliquer sur OK.%n%nSi les fichiers de ce disque peuvent être trouvés dans un %2 différent de celui affiché ci-dessous, entrez le chemin correct ou cliquez sur Chercher.
PathLabel=&Chemin :
FileNotInDir2=Le fichier "%1" ne peut pas être trouvé dans "%2". Veuillez insérer le disque correct ou sélectionnez un autre dossier.
SelectDirectoryLabel=Veuillez spécifier l'emplacement du disque suivant.

; *** Installation phase messages
SetupAborted=L'installation n'a pas été terminée.%n%nVeuillez corriger le problème et relancer l'installation.
EntryAbortRetryIgnore=Cliquez sur Reprendre pour essayer à nouveau, sur Ignorer pour continuer dans tous les cas, ou sur Abandonner pour annuler l'installation.

; *** Installation status messages
StatusCreateDirs=Création des répertoires...
StatusExtractFiles=Extraction des fichiers...
StatusCreateIcons=Création des raccourcis...
StatusCreateIniEntries=Création des entrées INI...
StatusCreateRegistryEntries=Création des entrées de registre...
StatusRegisterFiles=Enregistrement des fichiers...
StatusSavingUninstall=Sauvegarde des informations de désinstallation...
StatusRunProgram=Finalisation de l'installation...
StatusRollback=Annulation des changements...

; *** Misc. errors
ErrorInternal2=Erreur interne : %1
ErrorFunctionFailedNoCode=%1 échec
ErrorFunctionFailed=%1 échec; code %2
ErrorFunctionFailedWithMessage=%1 échec; code %2.%n%3
ErrorExecutingProgram=Impossible d'exécuter le fichier :%n%1

; *** Registry errors
ErrorRegOpenKey=Erreur pendant l'ouverture de la clef de registre :%n%1\%2
ErrorRegCreateKey=Erreur pendant la création de la clef de registre :%n%1\%2
ErrorRegWriteKey=Erreur lors de l'écriture de la clef de registre :%n%1\%2

; *** INI errors
ErrorIniEntry=Erreur lors de la créaction de l'entrée INI dans le fichier "%l".

; *** File copying errors
FileAbortRetryIgnore=Cliquez sur Reprendre pour essayer à nouveau, sur Ignorer pour ignorer ce fichier (non recommandé), ou sur Abandonner pour annuler l'installation.
FileAbortRetryIgnore2=Cliquez sur Reprendre pour essayer à nouveau, sur Ignorer continuer dans tous les cas (non recommandé), ou sur Abandonner pour annuler l'installation.
SourceIsCorrupted=Le fichier source est corrompu
SourceDoesntExist=Le fichier source "%1" n'existe pas
ExistingFileReadOnly=Le fichier existant est en lecture seule.%n%nCliquez sur Reprendre pour supprimer l'attribut lecture seule et réessayer, sur Ignorer pour ignorer ce fichier, ou sur Abandonner pour annuler l'installation.
ErrorReadingExistingDest=Une erreur est survenue en essayant de lire le fichier existant :
FileExists=Le fichier existe déjà.%n%nSouhaitez-vous que l'Installeur l'écrase ?
ExistingFileNewer=Le fichier existant est plus récent que celui qui doit être installé. Il est recommandé de conserver le fichier existant.%n%nSouhaitez-vous garder le fichier existant ?
ErrorChangingAttr=Une erreur est survenue en essayant de changer les attributs du fichier existant :
ErrorCreatingTemp=Une erreur est survenue en essayant de créer un fichier dans le répertoire de destination :
ErrorReadingSource=Une erreur est survenue lors de la lecture du fichier source :
ErrorCopying=Une erreur est survenue lors de la copie d'un fichier :
ErrorReplacingExistingFile=Une erreur est survenue lors du remplacement d'un fichier existant :
ErrorRestartReplace=Remplacement au redémarrage a échoué :
ErrorRenamingTemp=Une erreur est survenue en essayant de renommer un fichier dans le répertoire de destination :
ErrorRegisterServer=Impossible d'enregistrer la librairie DLL/OCX : %1
ErrorRegisterServerMissingExport=DllRegisterServer : export non trouvé
ErrorRegisterTypeLib=Impossible d'enregistrer la librairie de type : %1

; *** Post-installation errors
ErrorOpeningReadme=Une erreur est survenue à l'ouverture du fichier LISEZMOI/README.
ErrorRestartingComputer=L'Installeur a été incapable de redémarrer l'ordinateur. Veuillez le faire manuellement.

; *** Uninstaller messages
UninstallNotFound=Le fichier "%1" n'existe pas. Désinstallation impossible.
UninstallOpenError=Le fichier "%1" ne peut pas être ouvert. Désinstallation impossible
UninstallUnsupportedVer=Le fichier journal de désinstallation "%1" est dans un format non reconnu par cette version du désinstalleur. Impossible de désinstaller.
UninstallUnknownEntry=Une entrée inconnue (%1) a été rencontrée dans le journal de désinstallation
ConfirmUninstall=Souhaitez-vous supprimer définitivement %1 ainsi que tous ses composants ?
OnlyAdminCanUninstall=Cette application ne peut être supprimée que par un utilisateur possédant les droits d'administration.
UninstallStatusLabel=Patientez pendant que %1 est supprimé de votre ordinateur.
UninstalledAll=%1 a été supprimé de votre ordinateur.
UninstalledMost=La désinstallation de %1 est terminée.%n%nCertains éléments n'ont pu être supprimés. Ils peuvent être supprimés manuellement.
UninstalledAndNeedsRestart=Pour compléter la désinstallation de %1, votre ordinateur doit être redémarré.%n%nVoulez-vous redémarrer maintenant ?
UninstallDataCorrupted=Le ficher "%1" est corrompu. Désinstallation impossible

; *** Uninstallation phase messages
ConfirmDeleteSharedFileTitle=Supprimer les fichiers partagés ?
ConfirmDeleteSharedFile2=Le système indique que le fichier partagé suivant n'est plus utilisé par d'autres programmes. Souhaitez-vous supprimer celui-ci ?%n%n%1%n%nSi certains programmes utilisent ce fichier et qu'il est supprimé, ces programmes risquent de ne pas fonctionner normallement. Si vous n'êtes pas certain, choisissez Non. Laisser ce fichier sur votre système ne pose aucun problème.
SharedFileNameLabel=Nom de fichier :
SharedFileLocationLabel=Emplacement :
WizardUninstalling=Etat de la désinstallation
StatusUninstalling=Désintallation de %1...





