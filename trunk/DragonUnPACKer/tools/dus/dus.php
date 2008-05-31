<?php

// $Id: dus.php,v 1.4 2008-05-31 14:46:13 elbereth Exp $
// $Source: /home/elbzone/backup/cvs/DragonUnPACKer/tools/dus/dus.php,v $
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is dus.php, released December 16, 2005.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

  // CVS variables
  $CVS_REVISION = '$Revision: 1.4 $';
  $CVS_REVISION_DISPLAY = substr($CVS_REVISION,11,strlen($CVS_REVISION)-13);
  $CVS_DATE = '$Date: 2008-05-31 14:46:13 $';
  $CVS_DATE_DISPLAY = substr($CVS_DATE,7,strlen($CVS_DATE)-9);

  // Sending the header
  header('Content-type: text/plain');
  echo "[ID]\n";
  echo "DUS=3\n";
  echo "Description=Dragon UnPACKer 5 Update Server v3.$CVS_REVISION_DISPLAY ($CVS_DATE_DISPLAY)\n";

  // Connect to MYSQL Database
  $link = mysql_connect("mysql4-d", "d108923ro", "rofordus3");
  if (mysql_errno() != 0) {
    echo "Result=M01\n";
    echo "ResultDescription=".mysql_error()."\n";
    return;
  }
 
  // Selecting database
  mysql_select_db ("d108923_DragonUnPACKer");
  if (mysql_errno() != 0) {
    echo "Result=M02\n";
    echo "ResultDescription=".mysql_error()."\n";
    return;
  }

  // Getting user build from HTTP GET parameter
  $userBuild = $_GET['installedbuild'];
  if ((!isset($userBuild)) | (strlen($userBuild) == 0) | (!is_numeric($userBuild))) {
  	echo "Result=P01\n";
  	echo "ResultDescription=Parameter \"installedbuild\" is missing!\n";
  	return;
  }

  // Initialize body
  $dusbody = '';

  // Retrieving core information
  $query = "SELECT * FROM dus_core WHERE type = 'stable' AND available = 'yes' ORDER BY build DESC";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M10\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  if ($line = mysql_fetch_array($queryresult, MYSQL_NUM)) {

    $dusbody .= "[core]\nVersion=".$line[0]."\nVersionDisp=".$line[3]."\nUpdateURL=".$line[4]."\n\n";
     	
  }

  mysql_free_result($queryresult);

  // Retrieving corewip information
  $query = "SELECT * FROM dus_core WHERE type = 'wip' AND available = 'yes' AND build>=$installedbuild ORDER BY build DESC";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M11\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  if ($line = mysql_fetch_array($queryresult, MYSQL_NUM)) {

    $dusbody .= "[corewip]\nVersion=".$line[0]."\nVersionDisp=".$line[3]."\nUpdateURL=".$line[4]."\n\n";
     	
  }

  mysql_free_result($queryresult);

  // Retrieving information about user build
  $query = "SELECT duci, dudi, duhi, translation FROM dus_versions WHERE dup = ".$userBuild;
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M20\n";
    echo "ResultQuery=".$query."\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  if ($line = mysql_fetch_array($queryresult, MYSQL_NUM)) {

    $userduci = $line[0];
    $userdudi = $line[1];
    $userduhi = $line[2];
    $userlang = $line[3];

  }
  else
  {
  	echo "Result=P02\n";
    echo "ResultDescription=Unknown build of Dragon UnPACKer\n\n";
    echo $dusbody;
  	return;
  }

  mysql_free_result($queryresult);

  // Retrieving available convert plugins
  $query = "SELECT name, version, description, versiondisp, URL, file, fileDL, size, comment, commentFR FROM dus_convert WHERE duci = ".$userduci." ORDER BY name, version DESC";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M30\n";
    echo "ResultQuery=".$query."\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  $dusupdates = "Updates=";
  $lastconvertname = '';

  while ($line = mysql_fetch_array($queryresult, MYSQL_NUM)) {

    if ($lastconvertname != $line[0]) {
      $dusbody .= '['.$line[0]."]\nAutoUpdate=1\nVersion=".$line[1]."\nVersionDisp=".$line[3]."\nDescription=".$line[2]."\nComment=".$line[8]."\nCommentFR=".$line[9]."\nURL=".$line[4]."\nSize=".$line[7]."\nFile=".$line[5]."\nFileDL=".$line[6]."\n\n";
      $lastconvertname = $line[0];
      $dusupdates .= $line[0].' ';
    }
 	
  }

  mysql_free_result($queryresult);

  // Retrieving available drivers plugins
  $query = "SELECT name, version, description, versiondisp, URL, file, fileDL, size, comment, commentFR FROM dus_driver WHERE dudi = ".$userdudi." ORDER BY name, version DESC";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M31\n";
    echo "ResultQuery=".$query."\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  $lastconvertname = '';

  while ($line = mysql_fetch_array($queryresult, MYSQL_NUM)) {

    if ($lastconvertname != $line[0]) {
      $dusbody .= '['.$line[0]."]\nAutoUpdate=1\nVersion=".$line[1]."\nVersionDisp=".$line[3]."\nDescription=".$line[2]."\nComment=".$line[8]."\nCommentFR=".$line[9]."\nURL=".$line[4]."\nSize=".$line[7]."\nFile=".$line[5]."\nFileDL=".$line[6]."\n\n";
      $lastconvertname = $line[0];
      $dusupdates .= $line[0].' ';
    }
 	
  }

  mysql_free_result($queryresult);

  // Retrieving available hyperripper plugins
  $query = "SELECT name, version, description, versiondisp, URL, file, fileDL, size, comment, commentFR FROM dus_hyperripper WHERE duhi = ".$userduhi." ORDER BY name, version DESC";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M32\n";
    echo "ResultQuery=".$query."\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  $lastconvertname = '';

  while ($line = mysql_fetch_array($queryresult, MYSQL_NUM)) {

    if ($lastconvertname != $line[0]) {
      $dusbody .= '['.$line[0]."]\nAutoUpdate=1\nVersion=".$line[1]."\nVersionDisp=".$line[3]."\nDescription=".$line[2]."\nComment=".$line[8]."\nCommentFR=".$line[9]."\nURL=".$line[4]."\nSize=".$line[7]."\nFile=".$line[5]."\nFileDL=".$line[6]."\n\n";
      $lastconvertname = $line[0];
      $dusupdates .= $line[0].' ';
    }
 	
  }

  mysql_free_result($queryresult);

  // Retrieving available translations
  $query = "SELECT name, release, description, author, URL, file, fileDL, size, date FROM dus_translation WHERE version = ".$userlang." ORDER BY name, release DESC";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M33\n";
    echo "ResultQuery=".$query."\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  $lastlangname = '';
  $dustranslations = 'Translations=';

  while ($line = mysql_fetch_array($queryresult, MYSQL_NUM)) {

    if ($lastlangname != $line[0]) {
      $dusbody .= '['.$line[0]."]\nRelease=".$line[1]."\nDescription=".$line[2]."\nAuthor=".$line[3]."\nURL=".$line[4]."\nSize=".$line[7]."\nFile=".$line[5]."\nFileDL=".$line[6]."\nDate=".$line[8]."\n\n";
      $lastlangname = $line[0];
      $dustranslations .= $line[0].' ';
    }
 	
  }

  mysql_free_result($queryresult);

	echo "Result=OK\n";
  echo trim($dusupdates)."\n";
  echo trim($dustranslations)."\n\n";
  echo $dusbody;
  
  // Closing MYSQL connection
  mysql_close ($link);

?>