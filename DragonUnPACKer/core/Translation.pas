unit Translation;

// $Id: Translation.pas,v 1.15 2009-09-11 20:16:04 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/core/Translation.pas,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is Translation.pas, released May 8, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface
procedure TranslateAbout();
procedure TranslateError();
procedure TranslateHyperRipper();
procedure TranslateInfos();
procedure TranslateList();
procedure TranslateMain();
procedure TranslateOptions();
procedure TranslateSearch();

implementation

uses Main,About,DrvInfo,Error,Options,Search,HyperRipper, lib_language,declFSE,List;

procedure TranslateMain();
begin

  with dup5Main do
  begin

    Font.Name := getFont();
    lstContent.Font.Name := getFont();
//    mainMenu.fontname := getFont();
//    Popup_Contents.fontname := getFont();
//    Popup_Index.fontname := getFont();

    PanPreview.Caption := DLNGStr('PRV002');

    menuFichier.Caption := DLNGStr('MNU1');
    menuFichier_Ouvrir.Caption := DLNGStr('MNU1S1');
    menuFichier_Fermer.Caption := DLNGStr('MNU1S2');
    menuFichier_Quitter.Caption := DLNGStr('MNU1S3');
    menuRecent.Caption := DLNGStr('MNU1S4');
    menuOptions.Caption := DLNGStr('MNU2');
    menuOptions_Sub.Caption := DLNGStr('MNU2S1');
    menuOptions_Basic.Caption := DLNGStr('MNU2S1');
    menuOptions_Drivers.Caption := DLNGStr('MNU2S2');
    MenuOptions_Look.Caption := DLNGStr('MNU2S3');
    MenuOptions_Assoc.Caption := DLNGStr('MNU2S4');
    MenuOptions_Convert.Caption := DLNGStr('MNU2S5');
    MenuOptions_Plugins.Caption := DLNGStr('MNU2S6');
    MenuOptions_Advanced.Caption := DLNGStr('MNU2S7');
    MenuOptions_Log.Caption := DLNGStr('MNU2S8');
    MenuOptions_Preview.Caption := DLNGStr('MNU2S9');
    menuEdit.Caption := DLNGStr('MNU4');
    menuEdit_Search.Caption := DLNGStr('MNU4S1');
    menuAbout.Caption := DLNGStr('MNU3');
    menuAbout_NewVersions.Caption := DLNGStr('MNU3S2');
    menuAbout_About.Caption := DLNGStr('MNU3S1') + ' Dragon UnPACKer';
    menuTools.Caption := DLNGstr('MNU5');
    menuTools_List.Caption := DLNGstr('MNU5S1');

    Popup_Extrairevers.Caption := DLNGStr('POP1S1');
    Popup_Extrairevers_RAW.Caption := DLNGStr('POP1S4');
    Popup_ExtraireMulti.Caption := DLNGStr('POP1S2');
    Popup_ExtraireMulti_RAW.Caption := DLNGStr('POP1S4');
    PopUp_Open.Caption := DLNGStr('POP1S3');

    menuIndex_ExtractAll.Caption := DLNGStr('POP2S1');
    menuIndex_ExtractDirs.Caption := DLNGStr('POP2S2');
    menuIndex_Infos.Caption := DLNGStr('POP2S3');
    menuIndex_Expand.Caption := DLNGStr('POP2S4');
    menuIndex_Collapse.Caption := DLNGStr('POP2S5');

    menuPreview_Hide.Caption := DLNGStr('POP4S1');
    menuPreview_DisplayMode.Caption := DLNGStr('POP5S1');
    menuPreview_Display_Full.Caption := DLNGStr('POP5S2');
    menuPreview_Display_Stretched.Caption := DLNGStr('POP5S3');
    menuPreview_Options.Caption := DLNGStr('POP5S4');

    menuStatus_PreviewHide.Caption := DLNGStr('POP4S1');
    menuStatus_PreviewShow.Caption := DLNGStr('POP4S2');
    menuStatus_LogHide.Caption := DLNGStr('POP3S2');
    menuStatus_LogShow.Caption := DLNGStr('POP3S1');

    menuLog_Show.Caption := DLNGstr('POP3S1');
    menuLog_Hide.Caption := DLNGstr('POP3S2');
    menuLog_Clear.Caption := DLNGstr('POP3S3');

    lstContent.Header.Columns.Items[0].Text := DLNGStr('LSTCP1');
    lstContent.Header.Columns.Items[1].Text := DLNGStr('LSTCP2');
    lstContent.Header.Columns.Items[2].Text := DLNGStr('LSTCP3');
    lstContent.Header.Columns.Items[3].Text := DLNGStr('LSTCP4');

    Status.Panels.Items[0].Text := copy(dup5Main.Status.Panels.Items[0].Text,1,pos(' ',dup5Main.Status.Panels.Items[0].Text))+DLNGStr('STAT10');
    Status.Panels.Items[1].Text := copy(dup5Main.Status.Panels.Items[1].Text,1,pos(' ',dup5Main.Status.Panels.Items[1].Text))+DLNGStr('STAT20');

  end;
//  if FSE.DriverID = '' then
//    dup5Main.Status.Panels.Items[3].Text := DLNGStr('STAT30');

end;

procedure TranslateAbout();
begin

  with frmAbout do
  begin

    Font.Name := getFont();

    Caption := DLNGStr('MNU3S1') + ' Dragon UnPACKer 5';
    lblFreeware.Font.Name := getFont();
//    lblFreeware.caption := DLNGStr('ABT001');
    lblFreeware.Caption := 'Open Source / Mozilla Public Licence 1.1';
//  frmAbout.strContactMe.caption := DLNGStr('ABT002');
//  frmAbout.strContactMe.Left := 16;
//  frmAbout.lblContactMe.Left := frmAbout.strContactMe.Left+frmAbout.strContactMe.Width+5;
//  frmAbout.strURL.caption := DLNGStr('ABT003');
//  frmAbout.strURL.Left := 16;
//  frmAbout.lblURL.Left := frmAbout.strURL.Left+frmAbout.strURL.Width+5;
    cmdOk.Caption := DLNGStr('BUTOK');
    txtMoreinfo.Font.Name := getFont();

  end;

end;

procedure TranslateInfos();
begin

  with frmDrvInfo do
  begin

    Font.Name := getFont();
    Caption := DLNGStr('INFO99');

    Driver.Font.Name := getFont();
    Driver.Caption := DLNGStr('INFO00');
    strName.Font.Name := getFont();
    strName.Caption := DLNGStr('INFO01');
    lblName.Font.Name := getFont();
    strAuthor.Font.Name := getFont();
    strAuthor.Caption := DLNGStr('INFO02');
    lblAuthor.Font.Name := getFont();
    strComment.Font.Name := getFont();
    strComment.Caption := DLNGStr('INFO03');
    lblComment.Font.Name := getFont();
    strVersion.Font.Name := getFont();
    strVersion.Caption := DLNGStr('INFO04');
    lblVersion.Font.Name := getFont();

    Fichier.Font.Name := getFont();
    Fichier.Caption := DLNGStr('INFO10');
    strFileFormat.Font.Name := getFont();
    strFileFormat.Caption := DLNGstr('INFO11');
    lblFileFormat.Font.Name := getFont();
    strFileEntries.Font.Name := getFont();
    strFileEntries.Caption := DLNGstr('INFO12');
    lblFileEntries.Font.Name := getFont();
    strFileSize.Font.Name := getFont();
    strFileSize.Caption := DLNGstr('INFO13');
    lblFileSize.Font.Name := getFont();
    strFileLoadTime.Font.Name := getFont();
    strFileLoadTime.Caption := DLNGstr('INFO14');
    lblFileLoadTime.Font.Name := getFont();
    lblFileTotalTime.Font.Name := getFont();

  end;

end;

procedure TranslateList();
begin

  with frmList do
  begin

    Font.Name := getFont();
    Caption := DLNGStr('LST000');

    grp1.Caption := DLNGStr('LST100');
    grp1.Font.Name := getFont();
    grp2.Caption := DLNGStr('LST200');
    grp2.Font.Name := getFont();
    grp3.Caption := DLNGStr('LST300');
    grp3.Font.Name := getFont();

    panSortDisabled.Caption := DLNGStr('LST400');
    panSortDisabled.Font.Name := getFont();
    chkSort.Caption := DLNGStr('LST001');
    chkSort.Font.Name := getFont();
    cmdCancel.Caption := DLNGStr('BUTCAN');
    cmdCancel.Font.Name := getFont();
    cmdGo.Caption := DLNGStr('BUTCON');
    cmdGo.Font.Name := getFont();
    strVersion.Caption := DLNGStr('LST101');
    strVersion.Font.Name := getFont();
    strAuthor.Caption := DLNGStr('LST102');
    strAuthor.Font.Name := getFont();
    strEmail.Caption := DLNGStr('LST103');
    strEmail.Font.Name := getFont();
    strURL.Caption := DLNGStr('LST104');
    strURL.Font.Name := getFont();
    optSelected.Caption := DLNGStr('LST201');
    optSelected.Font.Name := getFont();
    optAll.Caption := DLNGStr('LST202');
    optAll.Font.Name := getFont();
    optCurrentDir.Caption := DLNGStr('LST203');
    optCurrentDir.Font.Name := getFont();
    chkSubDirs.Caption := DLNGStr('LST204');
    chkSubDirs.Font.Name := getFont();
    optSortAlpha.Caption := DLNGStr('LST301');
    optSortAlpha.Font.Name := getFont();
    optSortSize.Caption := DLNGStr('LST302');
    optSortSize.Font.Name := getFont();
    optSortOffset.Caption := DLNGStr('LST303');
    optSortOffset.Font.Name := getFont();
    optSortInvert.Caption := DLNGStr('LST304');
    optSortInvert.Font.Name := getFont();

  end;

end;

procedure TranslateOptions();
begin

  with frmConfig do
  begin
    Caption := DLNGStr('OPTTIT');
    Font.Name := GetFont();

    cmdOk.Caption := DLNGStr('BUTOK');
    cmdOk.Font.Name := GetFont();

    treeConfig.Font.Name := GetFont();

    treeConfig.Items.Item[0].Text := DLNGStr('OPT100');
    treeConfig.Items.Item[1].Text := DLNGStr('OPT000');
    treeConfig.Items.Item[2].Text := DLNGStr('OPT800');
    treeConfig.Items.Item[3].Text := DLNGStr('OPT600');
    treeConfig.Items.Item[4].Text := DLNGStr('OPT500');
    treeConfig.Items.Item[5].Text := DLNGStr('OPT200');
    treeConfig.Items.Item[6].Text := DLNGStr('OPT300');
    treeConfig.Items.Item[7].Text := DLNGStr('OPT400');
    treeConfig.Items.Item[8].Text := DLNGStr('OPT900');

    grpLanguage.Caption := DLNGStr('OPT110');
    grpLanguage.Font.Name := GetFont();

    lblFindNewLanguages.Caption := DLNGStr('OPT111');
    lblFindNewLanguages.Font.Name := GetFont();

    strAuthor.Caption := DLNGStr('INFO02');
    strAuthor.Font.Name := GetFont();

    strEmail.Caption := DLNGStr('INFO05');
    strEmail.Font.Name := GetFont();

    strURL.Caption := DLNGStr('ABT003');
    strURL.Font.Name := GetFont();

    lblURL.Left := strURL.Left + strURL.Width + 7;
    lblURL.Width := 297 - lblURL.Left ;
    lblURL.Font.Name := GetFont();

    grpOptions.Caption := DLNGStr('OPT120');
    grpOptions.Font.Name := GetFont();

    ChkNoSplash.Caption := DLNGStr('OPT121');
    chkNoSplash.Font.Name := GetFont();

    chkOneInstance.Caption := DLNGStr('OPT122');
    chkOneInstance.Font.Name := GetFont();

    chkSmartOpen.Caption := DLNGStr('OPT123');
    chkSmartOpen.Font.Name := GetFont();

    chkRegistryIcons.Caption := DLNGStr('OPT124');
    chkRegistryIcons.Font.Name := GetFont();

    chkUseHyperRipper.Caption := DLNGStr('OPT125');
    chkUseHyperRipper.Font.Name := GetFont();

    chkAutoExpand.Caption  := DLNGStr('OPT127');
    chkAutoExpand.Font.Name := GetFont();

    chkKeepFilterIndex.Caption  := DLNGStr('OPT128');
    chkKeepFilterIndex.Font.Name := GetFont();

    cmdCnvAbout.Caption := DLNGStr('OPT201');
    cmdCnvAbout.Font.Name := GetFont();

    cmdCnvSetup.Caption := DLNGStr('OPT202');
    cmdCnvSetup.Font.Name := GetFont();

    grpCnvInfo.Caption := DLNGStr('OPT510');
    grpCnvInfo.Font.Name := GetFont();

    strCnvInfoAuthor.Caption := DLNGStr('INFO02');
    strCnvInfoAuthor.Font.Name := GetFont();

    strCnvInfoVersion.Caption := DLNGStr('INFO04');
    strCnvInfoVersion.Font.Name := GetFont();

    strCnvInfoComments.Caption := DLNGStr('INFO03');
    strCnvInfoComments.Font.Name := GetFont();

    strConvertList.Caption := DLNGstr('OPT501');
    strConvertList.Font.Name := GetFont();

    lstConvert2.Columns.Items[0].Caption := DLNGStr('INFO20');
    lstConvert2.Columns.Items[1].Caption := DLNGStr('INFO21');
    lstConvert2.Columns.Items[2].Caption := DLNGStr('INFO10');
    grpCnvAdvInfo.Caption := DLNGStr('INFO22');
    lblCIntVer.Caption := DLNGStr('INFO23');

    strDriversList.Caption := DLNGStr('OPT203');
    strDriversList.Font.Name := GetFont();

    cmdDrvAbout.Caption := DLNGStr('OPT201');
    cmdDrvAbout.Font.Name := GetFont();

    cmdDrvSetup.Caption := DLNGStr('OPT202');
    cmdDrvSetup.Font.Name := GetFont();

    grpDrvInfo.Caption := DLNGStr('OPT210');
    grpDrvInfo.Font.Name := GetFont();

    strDrvInfoAuthor.Caption := DLNGStr('INFO02');
    strDrvInfoAuthor.Font.Name := GetFont();

    strDrvInfoVersion.Caption := DLNGStr('INFO04');
    strDrvInfoVersion.Font.Name := GetFont();

    strDrvInfoComments.Caption := DLNGStr('INFO03');
    strDrvInfoComments.Font.Name := GetFont();

    lstDrivers2.Columns.Items[1].Caption := DLNGStr('INFO20');
    lstDrivers2.Columns.Items[2].Caption := DLNGStr('INFO21');
    lstDrivers2.Columns.Items[3].Caption := DLNGStr('INFO10');
    grpAdvInfo.Caption := DLNGStr('INFO22');
    lblIntVer.Caption := DLNGStr('INFO23');
    butRefresh.Caption := DLNGStr('OPT221');
    lblPriority.Caption := DLNGStr('OPT220');

    grpLookInfo.Caption := DLNGStr('OPT310');
    grpLookInfo.Font.Name := GetFont();

    strLookName.Caption := DLNGStr('INFO01');
    strLookName.Font.Name := GetFont();

    strLookAuthor.Caption := DLNGStr('INFO02');
    strLookAuthor.Font.Name := GetFont();

    strLookComment.Caption := DLNGStr('INFO03');
    strLookComment.Font.Name := GetFont();

    strLookEmail.Caption := DLNGStr('INFO05');
    strLookEmail.Font.Name := GetFont();

    strLookList.Caption := DLNGstr('OPT320');
    strLookList.Font.Name := GetFont();
    
    tabAssoc.Caption := DLNGStr('OPT400');
    tabAssoc.Font.Name := GetFont();

    cmdTypesNone.Caption := DLNGStr('OPT411');
    cmdTypesNone.Font.Name := GetFont();

    cmdTypesAll.Caption := DLNGStr('OPT412');
    cmdTypesAll.Font.Name := GetFont();

    lblAssocInfo.Caption := DLNGStr('OPT401');
    lblAssocInfo.Font.Name := GetFont();
    lblAssocCurIcon.Caption := DLNGStr('OPT402');
    lblAssocCurIcon.Font.Name := GetFont();
    chkAssocCheckStartup.Caption := DLNGStr('OPT420');
    chkAssocCheckStartup.Font.Name := GetFont();
    chkAssocExtIcon.Caption := DLNGStr('OPT430');
    chkAssocExtIcon.Font.Name := GetFont();
    chkAssocText.Caption := DLNGStr('OPT440');
    chkAssocText.Font.Name := GetFont();
    chkAssocOpenWith.Caption := ReplaceValue('%d',DLNGStr('OPT450'),DLNGStr('OPT451'));
    chkAssocOpenWith.Font.Name := GetFont();

    grpLogOptions.Caption := DLNGStr('OPT810');
    grpLogOptions.Font.Name := GetFont();

    grpLogVerbose.Caption := DLNGStr('OPT840');
    grpLogVerbose.Font.Name := GetFont();

    strVerbose.Caption := DLNGStr('OPT841');
    strVerbose.Font.Name := GetFont();

    chkLog.Caption := DLNGStr('OPT811');
    chkLog.Font.Name := GetFont();
    chkLogClearNew.Caption := DLNGStr('OPT812');
    chkLogClearNew.Font.Name := GetFont();

    lblPluginsDrivers.Caption := DLNGStr('OPT203');
    lblPluginsDrivers.Font.Name := GetFont();
    lblPluginsConvert.Caption := DLNGStr('OPT501');
    lblPluginsConvert.Font.Name := GetFont();

    lblPluginsDriversInfo.Caption := DLNGStr('OPT191');
    lblPluginsDriversInfo.Font.Name := GetFont();
    lblPluginsConvertInfo.Caption := DLNGStr('OPT192');
    lblPluginsConvertInfo.Font.Name := GetFont();

    grpPluginsInfo.Caption := DLNGStr('OPT600');
    grpPluginsInfo.Font.Name := GetFont();

    grpAdvTemp.Caption := DLNGStr('OPT010');
    grpAdvTemp.Font.Name := GetFont();

    radTmpDirDefault.Caption := DLNGStr('OPT011');
    radTmpDirDefault.Font.Name := GetFont();

    radTmpDirOther.Caption := DLNGStr('OPT012');
    radTmpDirOther.Font.Name := GetFont();

    grpAdvOpenFile.Caption := DLNGStr('OPT020');
    grpAdvOpenFile.Font.Name := GetFont();

    chkMakeExtractDefault.Caption := DLNGStr('OPT021');
    chkMakeExtractDefault.Font.Name := GetFont();

    grpAdvBufferSize.Caption := DLNGStr('OPT030');
    grpAdvBufferSize.Font.Name := GetFont();

    lblBufferSize.Caption := DLNGStr('OPT031');
    lblBufferSize.Font.Name := GetFont();

    lstBufferSize.Font.Name := GetFont();
    lstBufferSize.Items[0] := ReplaceValue('%d',DLNGStr('OPT033'),'1')+' -- '+DLNGStr('OPT032');
    lstBufferSize.Items[1] := ReplaceValue('%d',DLNGStr('OPT033'),'512');
    lstBufferSize.Items[2] := ReplaceValue('%d',DLNGStr('OPT034'),'1');
    lstBufferSize.Items[3] := ReplaceValue('%d',DLNGStr('OPT034'),'2');
    lstBufferSize.Items[4] := ReplaceValue('%d',DLNGStr('OPT034'),'4');
    lstBufferSize.Items[5] := ReplaceValue('%d',DLNGStr('OPT034'),'8');
    lstBufferSize.Items[6] := ReplaceValue('%d',DLNGStr('OPT034'),'16')+' -- '+DLNGStr('OPT036');
    lstBufferSize.Items[7] := ReplaceValue('%d',DLNGStr('OPT034'),'32');
    lstBufferSize.Items[8] := ReplaceValue('%d',DLNGStr('OPT034'),'64');
    lstBufferSize.Items[9] := ReplaceValue('%d',DLNGStr('OPT034'),'128');
    lstBufferSize.Items[10] := ReplaceValue('%d',DLNGStr('OPT034'),'256');
    lstBufferSize.Items[11] := ReplaceValue('%d',DLNGStr('OPT034'),'512');
    lstBufferSize.Items[12] := ReplaceValue('%d',DLNGStr('OPT035'),'1');

    grpPreviewBasic.Caption := DLNGStr('OPT910');
    grpPreviewBasic.Font.Name := GetFont();

    chkPreviewEnable.Caption := DLNGStr('OPT911');
    chkPreviewEnable.Font.Name := GetFont();

    grpPreviewLimits.Caption := DLNGStr('OPT920');
    grpPreviewLimits.Font.Name := GetFont();

    optPreviewLimitNo.Caption := DLNGStr('OPT921');
    optPreviewLimitNo.Font.Name := GetFont();

    optPreviewLimitYes.Caption := DLNGStr('OPT922');
    optPreviewLimitYes.Font.Name := GetFont();

    lblPreviewLimit.Caption := DLNGStr('OPT923');
    lblPreviewLimit.Font.Name := GetFont();

    lstPreviewLimit.Items[0] := DLNGStr('OPT924');
    lstPreviewLimit.Items[1] := DLNGStr('OPT925');
    lstPreviewLimit.Items[2] := DLNGStr('OPT926');
    lstPreviewLimit.Items[3] := DLNGStr('OPT927');
    lstPreviewLimit.Items[4] := DLNGStr('OPT928');
    lstPreviewLimit.Font.Name := GetFont();
    lstPreviewLimit.ItemIndex := dup5Main.previewLimitValue;

    lblPreviewLimitBytes.Caption := DLnGStr('HR4012');
    lblPreviewLimitBytes.Font.Name := GetFont();

    grpPreviewDisplay.Caption := DLNGStr('OPT940');
    grpPreviewDisplay.Font.Name := GetFont();

    optPreviewDisplayFull.Caption := DLNGStr('POP5S2');
    optPreviewDisplayFull.Font.Name := GetFont();
    optPreviewDisplayStretch.Caption := DLNGStr('POP5S3');
    optPreviewDisplayStretch.Font.Name := GetFont();

    trackbarVerboseUpdateHint;

  end;

end;

procedure TranslateSearch();
begin

  with frmSearch do
  begin
    Font.Name := getFont();
    Caption := DLNGStr('SCHTIT');
    cmdSearch.Caption := DLNGStr('BUTGO');
    cmdSearch.Font.Name := getFont();
    cmdOk.Caption := DLNGStr('BUTOK');
    cmdOk.Font.Name := getFont();
    GroupBox.Caption := DLNGStr('SCHGRP');
    GroupBox.Font.Name := getFont();
    CheckCase.Caption := DLNGStr('SCH001');
    CheckCase.Font.Name := getFont();
    RadioTout.Caption := DLNGStr('SCH002');
    RadioTout.Font.Name := getFont();
    RadioDirOnly.Caption := DLNGStr('SCH003');
    RadioDirOnly.Font.Name := getFont();
  end;

end;

procedure TranslateError();
begin

  with frmError do
  begin
    Font.Name := getFont();
    Caption := DLNGStr('ERR000');
    strInfo.Caption := DLNGStr('ERR200');
    strInfo.Font.Name := getFont();
    strFrom.Caption := DLNGStr('ERR201');
    strFrom.Font.Name := getFont();
    strEx.Caption := DLNGStr('ERR202');
    strEx.Font.Name := getFont();
    strMessage.Caption := DLNGStr('ERR203');
    strMessage.Font.Name := getFont();
    cmdOk.Caption := DLNGStr('BUTOK');
    cmdOk.Font.Name := getFont();
    strReports.Caption := DLNGStr('ERR204');
    strReports.Font.Name := getFont();
    butCopy.Caption := DLNGStr('ERR205');
    butCopy.Font.Name := getFont();
    strBugRep.Caption := DLNGStr('ERR206');
    strBugRep.Font.Name := getFont();
  end;

end;

procedure TranslateHyperRipper();
begin

  with frmHyperRipper do
  begin
    Font.Name := getFont();
    tabSearch.Caption := DLNGStr('HR1000');
    tabSearch.Font.Name := getFont();
    strSource.Caption := DLNGStr('HR1001');
    strSource.Font.Name := getFont();
    chkHRF.Caption := DLNGStr('HR1002');
    chkHRF.Font.Name := getFont();
    cmdSearch.Caption := DLNGStr('BUTSCH');
    cmdSearch.Font.Name := getFont();
    strBufferLength.Caption := DLNGStr('HR1011');
    strBufferLength.Font.Name := getFont();
    strRollback.Caption := DLNGStr('HR1012');
    strRollback.Font.Name := getFont();
    strSpeed.Caption := DLNGStr('HR1013');
    strSpeed.Font.Name := getFont();
    strFound.Caption := DLNGStr('HR1014');
    strFound.Font.Name := getFont();
    cmdOk.Caption := DLNGStr('BUTOK');
    cmdOk.Font.Name := getFont();
    cmdCancel.Caption := DLNGstr('HR1003');
    cmdCancel.Font.Name := getFont();

    tabFormats.Caption := DLNGstr('HR2000');
    tabFormats.Font.Name := getFont();
    lstFormats.Font.Name := getFont();
    lstFormats.Columns.Items[0].Caption := DLNGstr('HR2011');
    lstFormats.Columns.Items[1].Caption := DLNGstr('HR2012');
    lstFormats.Columns.Items[2].Caption := DLNGstr('LSTCP4');
    cmdConfig.Caption := DLNGstr('HR2021');
    cmdConfig.Font.Name := getFont();
    cmdAll.Caption := DLNGstr('HR2022');
    cmdAll.Font.Name := getFont();
    cmdAudio.Caption := DLNGstr('HRTYP1');
    cmdAudio.Font.Name := getFont();
    cmdVideo.Caption := DLNGstr('HRTYP2');
    cmdVideo.Font.Name := getFont();
    cmdImage.Caption := DLNGstr('HRTYP3');
    cmdImage.Font.Name := getFont();
    chkExcludeFalsePositive.Caption := DLNGstr('HR2031');
    chkExcludeFalsePositive.Font.Name := getFont();

    tabHRF.Caption := DLNGstr('HR3000');
    tabHRF.Font.Name := getFont();
    chkHRFInfo.Caption := DLNGstr('HR3010');
    chkHRFInfo.Font.Name := getFont();
    strHRFTitle.Caption :=  DLNGstr('HR3011');
    strHRFTitle.Font.Name := getFont();
    strHRFURL.Caption := DLNGstr('HR3012');
    strHRFURL.Font.Name := getFont();
    strHRFAuthor.Caption := DLNGstr('INFO02');
    strHRFAuthor.Font.Name := getFont();
    grpHRFVersion.Caption := DLNGstr('HR3020');
    grpHRFVersion.Font.Name := getFont();
    radiov10.Caption := DLNGstr('HR3021')+' 1';
    radiov10.Font.Name := getFont();
    radiov20.Caption := DLNGstr('HR3021')+' 2';
    radiov20.Font.Name := getFont();
    radiov30.Caption := DLNGstr('HR3021')+' 3.0';
    radiov30.Font.Name := getFont();
    grpHRFOptions.Caption := DLNGstr('HR3030');
    grpHRFOptions.Font.Name := getFont();
    chkHRF3_NoPRGID.caption := DLNGstr('HR3031');
    chkHRF3_NoPRGID.Font.Name := getFont();
    chkHRF3_NoPRGVer.caption := DLNGstr('HR3032');
    chkHRF3_NoPRGVer.Font.Name := getFont();
    strMaxLength.Caption := DLNGstr('HR3033');
    strMaxLength.Font.Name := getFont();
    strCompatible.Caption := DLNGstr('HR3035');
    strCompatible.Font.Name := getFont();

    tabAdvanced.Caption := DLNGstr('HR4000');
    tabAdvanced.Font.Name := getFont();
//    grpBuffer.Caption := DLNGstr('HR4010');
//    grpBuffer.Font.Name := getFont();
//    chkBuffer32K.Caption := '256 '+DLNGstr('HR4012');
//    chkBuffer32K.Font.Name := getFont();
//    chkBuffer64K.Caption := '512 '+DLNGstr('HR4012');
//    chkBuffer64K.Font.Name := getFont();
//    chkBuffer128K.Caption := '1024 '+DLNGstr('HR4012');
//    chkBuffer128K.Font.Name := getFont();
//    lblBufferUD.Caption := DLNGstr('HR4012');
//    lblBufferUD.Font.Name := getFont();
//    grpRollback.Caption := DLNGstr('HR4020');
//    grpRollback.Font.Name := getFont();
//    chkRollback0.Caption := DLNGstr('HR4021');
//    chkRollback0.Font.Name := getFont();
//    chkRollback1.Caption := DLNGstr('HR4022');
//    chkRollback1.Font.Name := getFont();
//    chkRollback2.Caption := DLNGstr('HR4023');
//    chkRollback2.Font.Name := getFont();
//    chkRollback3.Caption := DLNGstr('HR4024');
//    chkRollback3.Font.Name := getFont();
    grpFormatting.Caption := DLNGstr('HR4030');
    grpFormatting.Font.Name := getFont();
    chkMakeDirs.Caption := DLNGstr('HR4031');
    chkMakeDirs.Font.Name := getFont();

    grpNaming.Caption := DLNGstr('HR4050');
    grpNaming.Font.Name := getFont();
    chkNamingAuto.Caption := DLNGstr('HR4051');
    chkNamingAuto.Font.Name := getFont();
    chkNamingCustom.Caption := DLNGstr('HR4052');
    chkNamingCustom.Font.Name := getFont();
    panNamingExemple.Caption := DLNGstr('HR4053');
    panNamingExemple.Font.Name := getFont();
    panNaming.Font.Name := getFont();
    lblNamingLegF.Caption := '%f = '+DLNGstr('HRLEGF');
    lblNamingLegF.Font.Name := getFont();
    lblNamingLegX.Caption := '%x = '+DLNGstr('HRLEGX');
    lblNamingLegX.Font.Name := getFont();
    lblNamingLegO.Caption := '%o = '+DLNGstr('HRLEGO');
    lblNamingLegO.Font.Name := getFont();
    lblNamingLegN.Caption := '%n = '+DLNGstr('HRLEGN');
    lblNamingLegN.Font.Name := getFont();
    lblNamingLegH.Caption := '%h = '+DLNGstr('HRLEGH');
    lblNamingLegH.Font.Name := getFont();

    chkAutoStart.Caption := DLNGstr('HR4061');
    chkAutoStart.Font.Name := getFont();
    chkAutoClose.Caption := DLNGstr('HR4062');
    chkAutoClose.Font.Name := getFont();
    chkForceBufferSize.Caption := DLNGstr('HR4063');
    chkForceBufferSize.Font.Name := getFont();

    tabAbout.Caption := DLNGstr('HR0000');
    tabAbout.Font.Name := getFont();
    strHRVersion.Caption := DLNGstr('INFO04');
    strHRVersion.Font.Name := getFont();
    lblAboutInfo.Caption := DLNGstr('HR0001');
    lblAboutInfo.Font.Name := getFont();
    lblAboutBeware.Caption := DLNGstr('HR0002');
    lblAboutBeware.Font.Name := getFont();
//    strNumPlugs.Caption := DLNGstr('HR0003');
//    strNumPlugs.Font.Name := getFont();
    strNumFormats.Caption := DLNGstr('HR0004');
    strNumFormats.Font.Name := getFont();

  end;
//  frmHyperRipper.lblAd.Caption := DLNGStr('HYPAD');

end;

end.
