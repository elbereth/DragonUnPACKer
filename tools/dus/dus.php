<?php

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

  // Program version
  define(DUS_VERSION,'3.2.1');
  define(DUS_DATE,'13:03 19/03/2011');
  
  // Sending the header
  header('Content-type: text/plain');
  echo "[ID]\n";
  echo "DUS=3\n";
  echo "Description=Dragon UnPACKer 5 Update Server v".DUS_VERSION." (".DUS_DATE.")\n";

  // Connect to MYSQL Database
  $link = mysql_connect("mysql-d", "d108923ro", "rofordus3");
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

  // Retrieving servers information
  $query = "SELECT * FROM dus_servers WHERE serverEnabled='true' ORDER BY serverPriority";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M40\n";
       echo "ResultQuery=".$query."\n";
       echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  $dusservers = '';
  $numservers = 0;
  $servers = array();
  while ($line = mysql_fetch_assoc($queryresult)) {

    $servers[$numservers]['id'] = $line['serverID'];
    $servers[$numservers]['url'] = $line['serverURL'];
    $servers[$numservers]['path'] = $line['serverUsePaths'];
    $dusservers .= "Server".$numservers."=".$line['serverName']."\n";
    $numservers++;
     	
  }
  $dusservers = "NumServers=".$numservers."\n".$dusservers;

  mysql_free_result($queryresult);
 
  // Getting user Duppi version from HTTP GET parameter
  $userDuppiVersion = $_GET['duppiversion'];
  if ((!isset($userDuppiVersion)) | (strlen($userDuppiVersion) == 0) | (!is_numeric($userDuppiVersion))) {
	$userDuppiVersion = 0;
  }
  
  // Retrieving duppi information
  $query = sprintf('SELECT * FROM dus_duppi WHERE versionfrom = %d ORDER BY version DESC',$userDuppiVersion);
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M60\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  $line = mysql_fetch_array($queryresult, MYSQL_NUM);

  if (!$line) {
    $query = 'SELECT * FROM dus_duppi WHERE versionfrom = 0 ORDER BY version DESC';
    $queryresult = mysql_query ($query);
    if (mysql_errno() != 0) {
    	echo "Result=M61\n";
        echo "ResultDescription=".mysql_error()."\n";
    	return;
    }
    $line = mysql_fetch_array($queryresult, MYSQL_NUM);
  }
  
  if ($line) {

    $dusbody .= "[duppi]\nVersion=".$line[1]."\nVersionDisp=".$line[2]."\n";
    for ($x=0;$x<$numservers;$x++) {
      if ($x == 0) {
        if ($servers[$x]['path'] == 'true') {
          $dusbody .= "URL=".$servers[$x]['url'].$line[3]."\n";
        }
        else {
          $dusbody .= "URL=".$servers[$x]['url'].$line[4]."\n";
        }
      }
      else {
        if ($servers[$x]['path'] == 'true') {
          $dusbody .= "URL$x=".$servers[$x]['url'].$line[3]."\n";
        }
        else {
          $dusbody .= "URL$x=".$servers[$x]['url'].$line[4]."\n";
        }
      }
    }
    $dusbody .= "FileDL=".$line[4]."\nSize=".$line[5]."\nRealSize=".$line[6]."\nHash=".$line[7]."\n\n";

  }

  // Retrieving core information
  $query = "SELECT * FROM dus_core WHERE type = 'stable' AND available = 'yes' ORDER BY build DESC";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M10\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  if ($line = mysql_fetch_array($queryresult, MYSQL_NUM)) {

    $duscoreupd = '';

    // Retrieving core update (Duppi 3.0.0+) information
    $query2 = "SELECT * FROM dus_core_update WHERE buildfrom=$userBuild AND buildto=".$line[0];
    $queryresult2 = mysql_query ($query2);
    if (mysql_errno() != 0) {
  	echo "Result=M12\n";
       echo "ResultDescription=".mysql_error()."\n";
    	return;
    }
    if ($line2 = mysql_fetch_array($queryresult2, MYSQL_NUM)) {
      for ($x=0;$x<$numservers;$x++) {
        if ($x == 0) {
          if ($servers[$x]['path'] == 'true') {
            $duscoreupd .= "PackageURL=".$servers[$x]['url'].$line2[2]."\n";
          }
          else {
            $duscoreupd .= "PackageURL=".$servers[$x]['url'].$line2[3]."\n";
          }
        }
        else {
          if ($servers[$x]['path'] == 'true') {
            $duscoreupd .= "PackageURL$x=".$servers[$x]['url'].$line2[2]."\n";
          }
          else {
            $duscoreupd .= "PackageURL$x=".$servers[$x]['url'].$line2[3]."\n";
          }
        }
      }
      $duscoreupd .= "PackageSize=".$line2[4]."\nPackageFileDL=".$line2[3]."\nRealSize=".$line2[5]."\nHash=".$line2[6]."\n";
    }

    mysql_free_result($queryresult2);

    $dusbody .= "[core]\nVersion=".$line[0]."\nVersionDisp=".$line[3]."\nUpdateURL=".$line[4]."\n".$duscoreupd."\n";
     	
  }

  mysql_free_result($queryresult);

  // Retrieving corewip information
  $query = "SELECT * FROM dus_core WHERE type = 'wip' AND available = 'yes' AND build>=$userBuild ORDER BY build DESC";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M11\n";
       echo "ResultQuery=".$query."\n";
       echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  if ($line = mysql_fetch_array($queryresult, MYSQL_NUM)) {

    $duscoreupd = '';

    // Retrieving core update (Duppi 3.0.0+) information
    $query2 = "SELECT * FROM dus_core_update WHERE buildfrom=$userBuild AND buildto=".$line[0];
    $queryresult2 = mysql_query ($query2);
    if (mysql_errno() != 0) {
  	echo "Result=M13\n";
       echo "ResultDescription=".mysql_error()."\n";
    	return;
    }
    if ($line2 = mysql_fetch_array($queryresult2, MYSQL_NUM)) {
      for ($x=0;$x<$numservers;$x++) {
        if ($x == 0) {
          if ($servers[$x]['path'] == 'true') {
            $duscoreupd .= "PackageURL=".$servers[$x]['url'].$line2[2]."\n";
          }
          else {
            $duscoreupd .= "PackageURL=".$servers[$x]['url'].$line2[3]."\n";
          }
        }
        else {
          if ($servers[$x]['path'] == 'true') {
            $duscoreupd .= "PackageURL$x=".$servers[$x]['url'].$line2[2]."\n";
          }
          else {
            $duscoreupd .= "PackageURL$x=".$servers[$x]['url'].$line2[3]."\n";
          }
        }
      }
      $duscoreupd .= "PackageSize=".$line2[4]."\nPackageFileDL=".$line2[3]."\nRealSize=".$line2[5]."\nHash=".$line2[6]."\n";
    }

    mysql_free_result($queryresult2);

    $dusbody .= "[corewip]\nVersion=".$line[0]."\nVersionDisp=".$line[3]."\nUpdateURL=".$line[4]."\n".$duscoreupd."\n";
     	
  }

  mysql_free_result($queryresult);

  // Retrieving information about user build
  $query = "SELECT duci, dudi, duhi, translation FROM dus_versions WHERE (dupfrom <= ".$userBuild.") AND (dupto >= ".$userBuild.")";
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
    echo "ResultQuery=".$query."\n";
    echo $dusbody;
  	return;
  }

  mysql_free_result($queryresult);

  // Retrieving available convert plugins
  $query = "SELECT name, version, description, versiondisp, URL, file, fileDL, size, comment, commentFR, DATE(date) FROM dus_convert WHERE duci = ".$userduci." AND versiontype='stable' ORDER BY name, version DESC";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M30\n";
    echo "ResultQuery=".$query."\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  $dusupdates = "Updates=";
  $dusupdatesuntable = "UpdatesUnstable=";
  $lastconvertname = '';

  while ($line = mysql_fetch_array($queryresult, MYSQL_NUM)) {

    if ($lastconvertname != $line[0]) {
      $dusbody .= '['.$line[0]."]\nAutoUpdate=1\nVersion=".$line[1]."\nVersionDisp=".$line[3]."\nDescription=".$line[2]."\nComment=".$line[8]."\nCommentFR=".$line[9]."\n";
      $lastconvertname = $line[0];
      $dusupdates .= $line[0].' ';
      for ($x=0;$x<$numservers;$x++) {
        if ($x == 0) {
          if ($servers[$x]['path'] == 'true') {
            $dusbody .= "URL=".$servers[$x]['url'].$line[4]."\n";
          }
          else {
            $dusbody .= "URL=".$servers[$x]['url'].$line[6]."\n";
          }
        }
        else {
          if ($servers[$x]['path'] == 'true') {
            $dusbody .= "URL$x=".$servers[$x]['url'].$line[4]."\n";
          }
          else {
            $dusbody .= "URL$x=".$servers[$x]['url'].$line[6]."\n";
          }
        }
      }
      $dusbody .= "Size=".$line[7]."\nFile=".$line[5]."\nFileDL=".$line[6]."\nDate=".$line[10]."\n\n";
    }
 	
  }

  mysql_free_result($queryresult);

  // Retrieving available stable drivers plugins
  $query = "SELECT name, version, description, versiondisp, URL, file, fileDL, size, comment, commentFR, DATE(date), realsize, hash FROM dus_driver WHERE dudi = ".$userdudi." AND versiontype='stable' ORDER BY name, version DESC";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M31\n";
    echo "ResultQuery=".$query."\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  $lastdrivertname = '';

  while ($line = mysql_fetch_array($queryresult, MYSQL_NUM)) {

    if ($lastdrivertname != $line[0]) {
      $dusbody .= '['.$line[0]."]\nAutoUpdate=1\nVersion=".$line[1]."\nVersionDisp=".$line[3]."\nDescription=".$line[2]."\nComment=".$line[8]."\nCommentFR=".$line[9]."\n";
      $lastdrivertname = $line[0];
      $drivercheck[$line[9]] = $line[1];
      $dusupdates .= $line[0].' ';
      for ($x=0;$x<$numservers;$x++) {
        if ($x == 0) {
          if ($servers[$x]['path'] == 'true') {
            $dusbody .= "URL=".$servers[$x]['url'].$line[4]."\n";
          }
          else {
            $dusbody .= "URL=".$servers[$x]['url'].$line[6]."\n";
          }
        }
        else {
          if ($servers[$x]['path'] == 'true') {
            $dusbody .= "URL$x=".$servers[$x]['url'].$line[4]."\n";
          }
          else {
            $dusbody .= "URL$x=".$servers[$x]['url'].$line[6]."\n";
          }
        }
      }
      $dusbody .= "Size=".$line[7]."\nFile=".$line[5]."\nFileDL=".$line[6]."\nDate=".$line[10]."\nRealSize=".$line[11]."\nHash=".$line[12]."\n\n";
    }
 	
  }

  mysql_free_result($queryresult);

  // Retrieving available unstable+stable drivers plugins
  $query = "SELECT name, version, description, versiondisp, URL, file, fileDL, size, comment, commentFR, DATE(date) FROM dus_driver WHERE dudi = ".$userdudi." ORDER BY name, version DESC";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M41\n";
    echo "ResultQuery=".$query."\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  $lastdrivertname = '';

  while ($line = mysql_fetch_array($queryresult, MYSQL_NUM)) {

    if ($lastdrivertname != $line[0]) {
      $lastdrivertname = $line[0];
      if ($drivercheck[$line[9]] != $line[1]) {
        $dusbody .= '[unstable:'.$line[0]."]\nAutoUpdate=1\nVersion=".$line[1]."\nVersionDisp=".$line[3]."\nDescription=".$line[2]."\nComment=".$line[8]."\nCommentFR=".$line[9]."\n";
        $drivercheck[$line[9]] = $line[1];
        $dusupdatesuntable .= 'unstable:'.$line[0].' ';
        for ($x=0;$x<$numservers;$x++) {
          if ($x == 0) {
            if ($servers[$x]['path'] == 'true') {
              $dusbody .= "URL=".$servers[$x]['url'].$line[4]."\n";
            }
            else {
              $dusbody .= "URL=".$servers[$x]['url'].$line[6]."\n";
            }
          }
          else {
            if ($servers[$x]['path'] == 'true') {
              $dusbody .= "URL$x=".$servers[$x]['url'].$line[4]."\n";
            }
            else {
              $dusbody .= "URL$x=".$servers[$x]['url'].$line[6]."\n";
            }
          }
        }
        $dusbody .= "Size=".$line[7]."\nFile=".$line[5]."\nFileDL=".$line[6]."\nDate=".$line[10]."\n\n";
      }
      else {
        $dusupdatesuntable .= $line[0].' ';
      }
    }
 	
  }

  mysql_free_result($queryresult);

  // Retrieving available hyperripper plugins
  $query = "SELECT name, version, description, versiondisp, URL, file, fileDL, size, comment, commentFR, DATE(date) FROM dus_hyperripper WHERE duhi = ".$userduhi." AND versiontype='stable' ORDER BY name, version DESC";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M32\n";
    echo "ResultQuery=".$query."\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  $lasthyperrippername = '';

  while ($line = mysql_fetch_array($queryresult, MYSQL_NUM)) {

    if ($lasthyperrippername != $line[0]) {
      $dusbody .= '['.$line[0]."]\nAutoUpdate=1\nVersion=".$line[1]."\nVersionDisp=".$line[3]."\nDescription=".$line[2]."\nComment=".$line[8]."\nCommentFR=".$line[9]."\n";
      $lasthyperrippername = $line[0];
      $dusupdates .= $line[0].' ';
      for ($x=0;$x<$numservers;$x++) {
        if ($x == 0) {
          if ($servers[$x]['path'] == 'true') {
            $dusbody .= "URL=".$servers[$x]['url'].$line[4]."\n";
          }
          else {
            $dusbody .= "URL=".$servers[$x]['url'].$line[6]."\n";
          }
        }
        else {
          if ($servers[$x]['path'] == 'true') {
            $dusbody .= "URL$x=".$servers[$x]['url'].$line[4]."\n";
          }
          else {
            $dusbody .= "URL$x=".$servers[$x]['url'].$line[6]."\n";
          }
        }
      }
      $dusbody .= "Size=".$line[7]."\nFile=".$line[5]."\nFileDL=".$line[6]."\nDate=".$line[10]."\n\n";
    }
 	
  }

  mysql_free_result($queryresult);

  // Retrieving available translations
  $query = "SELECT * FROM dus_translation WHERE version = ".$userlang." ORDER BY dus_translation.name,dus_translation.release DESC";
  $queryresult = mysql_query ($query);
  if (mysql_errno() != 0) {
  	echo "Result=M33\n";
    echo "ResultQuery=".$query."\n";
    echo "ResultDescription=".mysql_error()."\n";
  	return;
  }

  $lastlangname = '';
  $dustranslations = 'Translations=';

  while ($line = mysql_fetch_assoc($queryresult)) {

    if ($lastlangname != $line['name']) {
      $dusbody .= '['.$line['name']."]\nRelease=".$line['release']."\nDescription=".$line['description']."\nAuthor=".$line['author']."\n";
      $lastlangname = $line['name'];
      $dustranslations .= $line['name'].' ';
      $numadd = 0;
      for ($x=0;$x<$numservers;$x++) {
        if ($servers[$x]['id'] != 0) {
          if ($numadd== 0) {
            if ($servers[$x]['path'] == 'true') {
              $dusbody .= "URL=".$servers[$x]['url'].$line['URL']."\n";
            }
            else {
              $dusbody .= "URL=".$servers[$x]['url'].$line['fileDL']."\n";
            }
          }
          else {
            if ($servers[$x]['path'] == 'true') {
              $dusbody .= "URL$numadd=".$servers[$x]['url'].$line['URL']."\n";
            }
            else {
              $dusbody .= "URL$numadd=".$servers[$x]['url'].$line['fileDL']."\n";
            }
          }
          $numadd++;
        }
      }
      $dusbody .= "Size=".$line['size']."\nFile=".$line['file']."\nFileDL=".$line['fileDL']."\nDate=".$line['date']."\nRealSize=".$line['realsize']."\nHash=".$line['hash']."\n\n";
    }
 	
  }

  mysql_free_result($queryresult);

  echo "Result=OK\n";
  echo trim($dusupdates)."\n";
  echo trim($dusupdatesuntable)."\n";
  echo trim($dustranslations)."\n";
  echo trim($dusservers)."\n\n";
  echo $dusbody;
  
  // Closing MYSQL connection
  mysql_close ($link);

?>