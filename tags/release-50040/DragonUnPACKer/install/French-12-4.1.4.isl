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
LanguageName=Fran�ais
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
UninstallAppTitle=D�sinstallation
UninstallAppFullTitle=D�sinstallation de %1

; *** Misc. common
InformationTitle=Information
ConfirmTitle=Confirmation
ErrorTitle=Erreur

; *** SetupLdr messages
SetupLdrStartupMessage=%1 va �tre install�(e). Souhaitez-vous continuer ?
LdrCannotCreateTemp=Impossible de cr�er un fichier temporaire. Installation annul�e
LdrCannotExecTemp=Impossible d'ex�cuter un fichier depuis le r�pertoire temporaire. Installation annul�e

; *** Startup error messages
LastErrorMessage=%1.%n%nErreur %2: %3
SetupFileMissing=Le fichier %1 n'a pas �t� trouv� dans le r�pertoire de l'installation. Corrigez le probl�me ou obtenez une nouvelle copie du programme.
SetupFileCorrupt=Les fichiers de l'installation sont corrompus. Obtenez une nouvelle copie du programme.
SetupFileCorruptOrWrongVer=Les fichiers d'installation sont corrompus ou sont incompatibles avec cette version de l'installeur. Corrigez le probl�me ou obtenez une nouvelle copie du programme.
NotOnThisPlatform=Ce programme ne s'ex�cutera pas sur %1.
OnlyOnThisPlatform=Ce programme doit �tre ex�cut� sur %1.
WinVersionTooLowError=Ce programme requiert %1 version %2 ou sup�rieure.
WinVersionTooHighError=Ce programme ne peut �tre install� sur %1 version %2 ou sup�rieure.
AdminPrivilegesRequired=Vous devez �tre connect� en tant qu'administrateur pour installer ce programme.
PowerUserPrivilegesRequired=Vous devez �tre connect� en tant qu'administrateur ou comme un membre du groupe Administrateurs pour installer ce programme.
SetupAppRunningError=L'installation a d�tect� que %1 est actuellement en cours d'ex�cution.%n%nFermez toutes les instances de cette application maintenant, puis cliquez OK pour continuer, ou Annulation pour arr�ter l'installation.
UninstallAppRunningError=La proc�dure de d�sinstallation a d�tect� que %1 est actuellement en cours d'ex�cution.%n%nFermez toutes les instances de cette application maintenant, puis cliquez OK pour continuer, ou Annulation pour arr�ter l'installation.

; *** Misc. errors
ErrorCreatingDir=L'installeur n'a pas pu cr�er le r�pertoire "%1"
ErrorTooManyFilesInDir=L'installeur n'a pas pus cr�er un fichier dans le r�pertoire "%1" parce qu'il contient trop de fichiers

; *** Setup common messages
ExitSetupTitle=Quitter l'installation
ExitSetupMessage=L'installation n'est pas termin�e. Si vous quittez maintenant, le programme ne sera pas install�.%n%nVous devrez relancer l'installation une autre fois pour la terminer.%n%nQuitter l'installation ?
AboutSetupMenuItem=&A propos...
AboutSetupTitle=A Propos...
AboutSetupMessage=%1 version %2%n%3%n%n%1 page Web :%n%4
AboutSetupNote=

; *** Buttons
ButtonBack=< &Pr�c�dent
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
SelectLanguageLabel=Choisir la langue � utiliser pendant l'installation :

; *** Common wizard text
ClickNext=Cliquez sur Suivant pour continuer ou sur Annuler pour quitter l'installation.
BeveledLabel=
BrowseDialogTitle=Rechercher un Dossier
BrowseDialogLabel=S�lectionnez un dossier dans la liste ci-dessous, et cliquez sur OK.
NewFolderName=Nouveau Dossier

; *** "Welcome" wizard page
WelcomeLabel1=Bienvenue dans l'Assistant d'Installation de [name]
WelcomeLabel2=Ceci va installer [name/ver] sur votre ordinateur.%n%nIl est recommand� de fermer toutes les autres applications avant de continuer.

; *** "Password" wizard page
WizardPassword=Mot de passe
PasswordLabel1=Cette installation est prot�g�e par un mot de passe.
PasswordLabel3=Entrez votre mot de passe.%n%nLes mots de passes tiennent compte des majuscules et des minuscules.
PasswordEditLabel=&Mot de passe :
IncorrectPassword=Le mot de passe entr� n'est pas correct. Essayez � nouveau.

; *** "License Agreement" wizard page
WizardLicense=Accord de licence
LicenseLabel=Veuillez lire l'information importante suivante avant de continuer.
LicenseLabel3=Veuillez lire l'Accord de Licence qui suit. Vous devez accepter les termes de cet accord avant de continuer cette installation.
LicenseAccepted=J'&accepte cet accord
LicenseNotAccepted=Je &refuse cet accord

; *** "Information" wizard pages
WizardInfoBefore=Information
InfoBeforeLabel=Veuillez lire les informations importantes suivantes avant de continuer.
InfoBeforeClickLabel=Lorsque vous serez pr�t � continuer, cliquez sur Suivant.
WizardInfoAfter=Information
InfoAfterLabel=Veuillez lire les informations importantes suivantes avant de continuer.
InfoAfterClickLabel=Lorsque vous serez pr�t � continuer, cliquez sur "Suivant".

; *** "User Information" wizard page
WizardUserInfo=Information Utilisateur
UserInfoDesc=Veuillez entrer vos informations.
UserInfoName=&Nom d'Utilisateur :
UserInfoOrg=&Organisation :
UserInfoSerial=Num�ro de &S�rie :
UserInfoNameRequired=Vous devez �crire un nom.

; *** "Select Destination Location" wizard page
WizardSelectDir=Choisissez la destination
SelectDirDesc=O� devrait �tre install� [name] ?
SelectDirLabel2=Le programme va installer [name] dans le dossier suivant.%n%nPour continuer, cliquez sur Suivant. Si vous souhaitez choisir une dossier diff�rent, cliquez sur Parcourir.
DiskSpaceMBLabel=Le programme requiert au moins [mb] Mo d'espace disque libre.
ToUNCPathname=L'installeur ne sait pas utiliser les chemins d'acc�s UNC. Si vous souhaitez installer [name] sur un r�seau, vous devez "mapper" un disque.
InvalidPath=Vous devez entrer un chemin complet avec une lettre de lecteur; par exemple :%n%nC:\APP%n%nou un chemin UNC de la forme : %n%n\\serveur\partage
InvalidDrive=Le lecteur ou le partage UNC que vous avez s�lectionn� n'existe pas. Choisissez en un autre.
DiskSpaceWarningTitle=Pas assez d'espace disque
DiskSpaceWarning=L'installation n�cessite au moins %1 Ko d'espace disque libre, mais le lecteur s�lectionn� n'a que %2 Ko de disponible.%n%nSouhaitez-vous quand m�me continuer ?
DirNameTooLong=Le nom de dossier ou son chemin d'acc�s est trop long.
InvalidDirName=Le nom de dossier n'est pas valide.
BadDirName32=Le nom du r�pertoire ne peut pas contenir les caract�res suivants :%n%n%1
DirExistsTitle=Ce dossier existe
DirExists=Le dossier :%n%n%1%n%nexiste d�j�. Souhaitez-vous l'utiliser quand m�me ?
DirDoesntExistTitle=Ce dossier n'existe pas
DirDoesntExist=Le dossier :%n%n%1%n%nn'existe pas. Souhaitez-vous qu'il soit cr�� ?

; *** "Select Components" wizard page
WizardSelectComponents=S�lection des Composants
SelectComponentsDesc=Quels sont les composants doivent �tre install�s ?
SelectComponentsLabel2=S�lectionnez les composants que vous souhaitez installer; d�sactiver les composants que vous ne souhaitez pas installer. Cliquez sur Suivant lorsque vous �tes pr�t � continuer.n.
FullInstallation=Installation compl�te
; if possible don't translate 'Compact' as 'Minimal' (I mean 'Minimal' in your language)
CompactInstallation=Installation compacte
CustomInstallation=Installation personnalis�e
NoUninstallWarningTitle=Existance d'un Composant
NoUninstallWarning=L'Installation a d�tect� que les composants suivants sont d�j� install�s sur votre ordinateur :%n%n%1%n%nD�s�lectionner ces composants ne les d�sinstallera pas.%n%nVoulez-vous quand m�me continuer ?
ComponentSize1=%1 KB
ComponentSize2=%1 MB
ComponentsDiskSpaceMBLabel=La s�lection courante n�cessite au moins [mb] MB d'espace disque.

; *** "Select Additional Tasks" wizard page
WizardSelectTasks=S�lection des T�ches Suppl�mentaires
SelectTasksDesc=Quelles t�ches additionnelles souhaitez-vous ex�cuter ?
SelectTasksLabel2=S�lectionnez les t�ches additionnelles que l'Installeur doit ex�cuter pendant l'installation de [name], ensuite cliquez sur Suivant.

; *** "Select Start Menu Folder" wizard page
WizardSelectProgramGroup=Selectionnez un Groupe de Programme
SelectStartMenuFolderDesc=O� voulez vous placer les racourcis du programme ?
SelectStartMenuFolderLabel2=L'installeur va cr�er les raccourcis du programme dans le Groupe de Programme suivant. Pour continuer, cliquez sur Suivant.
NoIconsCheck=&Ne pas cr�er d'ic�ne
MustEnterGroupName=Vous devez entrer un nom de groupe.
GroupNameTooLong=Le nom de dossier ou son chemin d'acc�s est trop long.
InvalidGroupName=Ce nom de dossier n'est pas valide.
BadGroupName=L'installation va ajouter les icones du programme dans le groupe du %1 suivant.
NoProgramGroupCheck2=&Ne pas cr�er de Groupe de Programme

; *** "Ready to Install" wizard page
WizardReady=Pr�t � installer
ReadyLabel1=L'installeur vas maintenant installer [name] sur votre ordinateur.
ReadyLabel2a=Cliquez sur "Installer" pour continuer ou sur "Pr�c�dent" pour changer une option.
ReadyLabel2b=Cliquez sur "Installer" pour continuer.
ReadyMemoUserInfo=Information utilisateur :
ReadyMemoDir=Dossier de destination :
ReadyMemoType=Type d'installation :
ReadyMemoComponents=Composants s�lectionn�s :
ReadyMemoGroup=Groupe de Programme :
ReadyMemoTasks=T�ches additionnelles :

; *** "Preparing to Install" wizard page
WizardPreparing=Pr�paration de la phase d'Installation
PreparingDesc=L'Installeur est pr�t � installer [name] sur votre ordinateur.
PreviousInstallNotCompleted=L'Installation/D�sinstallation d'une version pr�c�dente du programme n'est pas totalement achev�. Vueillez red�marrer votre ordinateur pour achever cette phase d'installation.%n%nApr�s le red�marrage de votre ordinateur, r�-ex�cutez l'Installeur pour terminer l'installation de [name].
CannotContinue=L'Installeur ne peut continuer. Veulliez cliquer sur Annuler pour sortir.

; *** "Installing" wizard page
WizardInstalling=Installation en cours
InstallingLabel=Veuillez patienter pendant que l'Installeur copie [name] sur votre ordinateur.

; *** "Setup Completed" wizard page
FinishedHeadingLabel=Finalisation de l'Assistant d'Installation de [name]
FinishedLabelNoIcons=L'Installeur a termin� d'installer [name] sur votre ordinateur.
FinishedLabel=L'Installeur a termin� d'installer [name] sur votre ordinateur. L'application peut �tre lanc�e en s�lectionnant les ic�nes install�es.
ClickFinish=Cliquez sur Terminer pour quitter l'Installation.
FinishedRestartLabel=Pour finir l'installation de [name], L'Installeur doit red�marrer votre ordinateur.%n%nVoulez-vous red�marrer maintenant ?
FinishedRestartMessage=Pour finir l'installation de [name], L'Installeur doit red�marrer votre ordinateur.%n%nVoulez-vous red�marrer maintenant ?
ShowReadmeCheck=Oui, Je souhaiterais lire le fichier LisezMoi/ReadMe
YesRadio=&Oui, red�marrer l'ordinateur maintenant
NoRadio=&Non, je red�marrerai mon ordinateur plus tard
; used for example as 'Run MyProg.exe'
RunEntryExec=Executer %1
; used for example as 'View Readme.txt'
RunEntryShellExec=Voir %1

; *** "Setup Needs the Next Disk" stuff
ChangeDiskTitle=L'installation a besoin du disque suivant
SelectDiskLabel2=Veuillez ins�rer le disque %1 et cliquer sur OK.%n%nSi les fichiers de ce disque peuvent �tre trouv�s dans un %2 diff�rent de celui affich� ci-dessous, entrez le chemin correct ou cliquez sur Chercher.
PathLabel=&Chemin :
FileNotInDir2=Le fichier "%1" ne peut pas �tre trouv� dans "%2". Veuillez ins�rer le disque correct ou s�lectionnez un autre dossier.
SelectDirectoryLabel=Veuillez sp�cifier l'emplacement du disque suivant.

; *** Installation phase messages
SetupAborted=L'installation n'a pas �t� termin�e.%n%nVeuillez corriger le probl�me et relancer l'installation.
EntryAbortRetryIgnore=Cliquez sur Reprendre pour essayer � nouveau, sur Ignorer pour continuer dans tous les cas, ou sur Abandonner pour annuler l'installation.

; *** Installation status messages
StatusCreateDirs=Cr�ation des r�pertoires...
StatusExtractFiles=Extraction des fichiers...
StatusCreateIcons=Cr�ation des raccourcis...
StatusCreateIniEntries=Cr�ation des entr�es INI...
StatusCreateRegistryEntries=Cr�ation des entr�es de registre...
StatusRegisterFiles=Enregistrement des fichiers...
StatusSavingUninstall=Sauvegarde des informations de d�sinstallation...
StatusRunProgram=Finalisation de l'installation...
StatusRollback=Annulation des changements...

; *** Misc. errors
ErrorInternal2=Erreur interne : %1
ErrorFunctionFailedNoCode=%1 �chec
ErrorFunctionFailed=%1 �chec; code %2
ErrorFunctionFailedWithMessage=%1 �chec; code %2.%n%3
ErrorExecutingProgram=Impossible d'ex�cuter le fichier :%n%1

; *** Registry errors
ErrorRegOpenKey=Erreur pendant l'ouverture de la clef de registre :%n%1\%2
ErrorRegCreateKey=Erreur pendant la cr�ation de la clef de registre :%n%1\%2
ErrorRegWriteKey=Erreur lors de l'�criture de la clef de registre :%n%1\%2

; *** INI errors
ErrorIniEntry=Erreur lors de la cr�action de l'entr�e INI dans le fichier "%l".

; *** File copying errors
FileAbortRetryIgnore=Cliquez sur Reprendre pour essayer � nouveau, sur Ignorer pour ignorer ce fichier (non recommand�), ou sur Abandonner pour annuler l'installation.
FileAbortRetryIgnore2=Cliquez sur Reprendre pour essayer � nouveau, sur Ignorer continuer dans tous les cas (non recommand�), ou sur Abandonner pour annuler l'installation.
SourceIsCorrupted=Le fichier source est corrompu
SourceDoesntExist=Le fichier source "%1" n'existe pas
ExistingFileReadOnly=Le fichier existant est en lecture seule.%n%nCliquez sur Reprendre pour supprimer l'attribut lecture seule et r�essayer, sur Ignorer pour ignorer ce fichier, ou sur Abandonner pour annuler l'installation.
ErrorReadingExistingDest=Une erreur est survenue en essayant de lire le fichier existant :
FileExists=Le fichier existe d�j�.%n%nSouhaitez-vous que l'Installeur l'�crase ?
ExistingFileNewer=Le fichier existant est plus r�cent que celui qui doit �tre install�. Il est recommand� de conserver le fichier existant.%n%nSouhaitez-vous garder le fichier existant ?
ErrorChangingAttr=Une erreur est survenue en essayant de changer les attributs du fichier existant :
ErrorCreatingTemp=Une erreur est survenue en essayant de cr�er un fichier dans le r�pertoire de destination :
ErrorReadingSource=Une erreur est survenue lors de la lecture du fichier source :
ErrorCopying=Une erreur est survenue lors de la copie d'un fichier :
ErrorReplacingExistingFile=Une erreur est survenue lors du remplacement d'un fichier existant :
ErrorRestartReplace=Remplacement au red�marrage a �chou� :
ErrorRenamingTemp=Une erreur est survenue en essayant de renommer un fichier dans le r�pertoire de destination :
ErrorRegisterServer=Impossible d'enregistrer la librairie DLL/OCX : %1
ErrorRegisterServerMissingExport=DllRegisterServer : export non trouv�
ErrorRegisterTypeLib=Impossible d'enregistrer la librairie de type : %1

; *** Post-installation errors
ErrorOpeningReadme=Une erreur est survenue � l'ouverture du fichier LISEZMOI/README.
ErrorRestartingComputer=L'Installeur a �t� incapable de red�marrer l'ordinateur. Veuillez le faire manuellement.

; *** Uninstaller messages
UninstallNotFound=Le fichier "%1" n'existe pas. D�sinstallation impossible.
UninstallOpenError=Le fichier "%1" ne peut pas �tre ouvert. D�sinstallation impossible
UninstallUnsupportedVer=Le fichier journal de d�sinstallation "%1" est dans un format non reconnu par cette version du d�sinstalleur. Impossible de d�sinstaller.
UninstallUnknownEntry=Une entr�e inconnue (%1) a �t� rencontr�e dans le journal de d�sinstallation
ConfirmUninstall=Souhaitez-vous supprimer d�finitivement %1 ainsi que tous ses composants ?
OnlyAdminCanUninstall=Cette application ne peut �tre supprim�e que par un utilisateur poss�dant les droits d'administration.
UninstallStatusLabel=Patientez pendant que %1 est supprim� de votre ordinateur.
UninstalledAll=%1 a �t� supprim� de votre ordinateur.
UninstalledMost=La d�sinstallation de %1 est termin�e.%n%nCertains �l�ments n'ont pu �tre supprim�s. Ils peuvent �tre supprim�s manuellement.
UninstalledAndNeedsRestart=Pour compl�ter la d�sinstallation de %1, votre ordinateur doit �tre red�marr�.%n%nVoulez-vous red�marrer maintenant ?
UninstallDataCorrupted=Le ficher "%1" est corrompu. D�sinstallation impossible

; *** Uninstallation phase messages
ConfirmDeleteSharedFileTitle=Supprimer les fichiers partag�s ?
ConfirmDeleteSharedFile2=Le syst�me indique que le fichier partag� suivant n'est plus utilis� par d'autres programmes. Souhaitez-vous supprimer celui-ci ?%n%n%1%n%nSi certains programmes utilisent ce fichier et qu'il est supprim�, ces programmes risquent de ne pas fonctionner normallement. Si vous n'�tes pas certain, choisissez Non. Laisser ce fichier sur votre syst�me ne pose aucun probl�me.
SharedFileNameLabel=Nom de fichier :
SharedFileLocationLabel=Emplacement :
WizardUninstalling=Etat de la d�sinstallation
StatusUninstalling=D�sintallation de %1...





