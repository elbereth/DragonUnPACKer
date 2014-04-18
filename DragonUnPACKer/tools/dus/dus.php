<?php

//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// The Original Code is dus.php, released December 16, 2005.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).
//

  // Program version
  define('DUS_VERSION','3.3.0');
  define('DUS_DATE','20140418');

  // Retrieve the update
  function getCoreUpdate($mysqli,$buildfrom,$buildto) {

    global $servers, $numservers;

    $duscoreupd = '';

    // Retrieving core update (Duppi 3.0.0+) information
    $query2 = "SELECT * FROM dus_core_update WHERE buildfrom=? AND buildto=?";
    $stmt = $mysqli->prepare($query2);
    if ($stmt === FALSE) {
      echo "Result=M14\n";
      echo "ResultDescription=".$mysqli->error."\n";
      die;
    }
    if (!$stmt->bind_param("ii",$buildfrom,$buildto)) {
      echo "Result=M15\n";
      echo "ResultDescription=".$stmt->error."\n";
      die;
    }
    if (!$stmt->execute()) {
      echo "Result=M16\n";
      echo "ResultDescription=".$stmt->error."\n";
      die;
    }
    if (!($queryresult2 = $stmt->get_result())) {
      echo "Result=M12\n";
      echo "ResultDescription=".$stmt->error."\n";
      die;
    }
    $stmt->close();

    $line2 = $queryresult2->fetch_array(MYSQLI_ASSOC);
    $queryresult2->close();

    if ($line2 !== NULL) {
      for ($x=0;$x<$numservers;$x++) {
        $duscoreupd .= "PackageURL";
        if ($x > 0) {
          $duscoreupd .= "$x";
        }
        if ($servers[$x]['sourceforge']) {
          $duscoreupd .= "=".$servers[$x]['url'].$line2['URLSF']."\n";
        }
        else if ($servers[$x]['path']) {
          $duscoreupd .= "=".$servers[$x]['url'].$line2['URL']."\n";
        }
        else {
          $duscoreupd .= "=".$servers[$x]['url'].$line2['fileDL']."\n";
        }
      }
      $duscoreupd .= "PackageSize=".$line2['size']."\nPackageFileDL=".$line2['fileDL']."\nRealSize=".$line2['realsize']."\nHash=".$line2['hash']."\n";
    }

    return $duscoreupd;

  }

  // Sending the header
  header('Content-type: text/plain');
  echo "[ID]\n";
  echo "DUS=3\n";
  echo "Description=Dragon UnPACKer 5 Update Server v".DUS_VERSION." (".DUS_DATE.")\n";

  // Getting user build from HTTP GET parameter
  $userBuild = $_GET['installedbuild'];
  if ((!isset($userBuild)) | (strlen($userBuild) == 0) | (!is_numeric($userBuild))) {
    echo "Result=P01\n";
    echo "ResultDescription=Parameter \"installedbuild\" is missing!\n";
    die;
  }

  // Connect to MYSQL Database
  $mysqli = new mysqli('localhost', 'd108923ro', 'rofordus3', 'drgunpackdus', 3306, '/var/run/mysqld/mysqld.sock');
  if ($mysqli->connect_error) {
    echo "Result=M01\n";
    echo "ResultDescription=".$mysqli->connect_error."\n";
    $mysqli->close();
    die;
  }

  // Selecting database
  if (!$mysqli->select_db("drgunpackdus")) {
    echo "Result=M02\n";
    echo "ResultDescription=".$mysqli->error."\n";
    die;
  }

  // Initialize body
  $dusbody = '';

  // Retrieving servers information
  $query = "SELECT serverID, serverURL, serverUsePaths, serverName FROM dus_servers WHERE serverEnabled='true' ORDER BY serverPriority";
  $queryresult = $mysqli->query($query);
  if ($queryresult === FALSE) {
    echo "Result=M40\n";
    echo "ResultQuery=".$query."\n";
    echo "ResultDescription=".$mysqli->error."\n";
    die;
  }

  $dusservers = '';
  $numservers = 0;
  $servers = array();
  while ($line = $queryresult->fetch_array(MYSQLI_ASSOC)) {

    if (!(array_key_exists('serverID',$line) && array_key_exists('serverURL',$line)
     && array_key_exists('serverUsePaths',$line) && array_key_exists('serverName',$line))) {
      echo "Result=M41\n";
      echo "ResultDescription=Missing columns in server query\n";
      die;
    }

    $servers[$numservers]['id'] = $line['serverID'];
    $servers[$numservers]['url'] = $line['serverURL'];
    $servers[$numservers]['path'] = ($line['serverUsePaths'] == 'true');
    $servers[$numservers]['sourceforge'] = ($line['serverUsePaths'] == 'sourceforge');
    $dusservers .= "Server".$numservers."=".$line['serverName']."\n";
    $numservers++;

  }
  $dusservers = "NumServers=".$numservers."\n".$dusservers;

  $queryresult->close();

  // Getting user Duppi version from HTTP GET parameter
  $userDuppiVersion = $_GET['duppiversion'];
  if ((!isset($userDuppiVersion)) | (strlen($userDuppiVersion) == 0) | (!is_numeric($userDuppiVersion))) {
        $userDuppiVersion = 0;
  }

  // Retrieving duppi information
  $query = 'SELECT * FROM dus_duppi WHERE versionfrom=? ORDER BY version DESC LIMIT 1';
  $stmt = $mysqli->prepare($query);
  if ($stmt === FALSE) {
    echo "Result=M60\n";
    echo "ResultDescription=".$mysqli->error."\n";
    die;
  }
  if (!$stmt->bind_param("i", $userDuppiVersion)) {
    echo "Result=M62\n";
    echo "ResultDescription=".$stmt->error."\n";
    die;
  }
  if (!$stmt->execute()) {
    echo "Result=M63\n";
    echo "ResultDescription=".$stmt->error."\n";
    die;
  }
  if (!($queryresult = $stmt->get_result())) {
    echo "Result=M64\n";
    echo "ResultDescription=".$stmt->error."\n";
    die;
  }
  $stmt->close();

  $line = $queryresult->fetch_array(MYSQLI_ASSOC);
  $queryresult->close();

  if ($line === NULL) {
    $query = 'SELECT * FROM dus_duppi WHERE versionfrom=0 ORDER BY version DESC LIMIT 1';
    $queryresult = $mysqli->query($query);
    if ($stmt === FALSE) {
      echo "Result=M61\n";
      echo "ResultDescription=".$mysqli->error."\n";
      die;
    }
    $line = $queryresult->fetch_array(MYSQLI_ASSOC);
    $queryresult->close();
  }

  if ($line !== NULL) {

    $dusbody .= "[duppi]\nVersion=".$line['version']."\nVersionDisp=".$line['versiondisp']."\n";
    for ($x=0;$x<$numservers;$x++) {
      $dusbody .= "URL";
      if ($x > 0) {
        $dusbody .= "$x";
      }
      if ($servers[$x]['path']) {
        $dusbody .= "=".$servers[$x]['url'].$line['URL']."\n";
      }
      else {
        $dusbody .= "=".$servers[$x]['url'].$line['fileDL']."\n";
      }
    }
    $dusbody .= "FileDL=".$line['fileDL']."\nSize=".$line['size']."\nRealSize=".$line['realsize']."\nHash=".$line['hash']."\n\n";

  }

  // Retrieving core information
  $query = "SELECT * FROM dus_core WHERE type = 'stable' AND available = 'yes' ORDER BY build DESC LIMIT 1";
  $queryresult = $mysqli->query($query);
  if ($queryresult === FALSE) {
    echo "Result=M10\n";
    echo "ResultDescription=".$mysqli->error."\n";
    die;
  }

  $line = $queryresult->fetch_array(MYSQLI_ASSOC);
  $queryresult->close();

  if ($line !== NULL) {

    $duscoreupd = getCoreUpdate($mysqli,$userBuild,$line['build']);
    $dusbody .= "[core]\nVersion=".$line['build']."\nVersionDisp=".$line['versiondisp']."\nUpdateURL=".$line['URL']."\n".$duscoreupd."\n";

  }

  // Retrieving corewip information
  $query = "SELECT * FROM dus_core WHERE type = 'wip' AND available = 'yes' ORDER BY build DESC LIMIT 1";
  $queryresult = $mysqli->query($query);
  if ($queryresult === FALSE) {
    echo "Result=M11\n";
    echo "ResultDescription=".$mysqli->error."\n";
    die;
  }

  $line = $queryresult->fetch_array(MYSQLI_ASSOC);
  $queryresult->close();

  if ($line !== NULL) {

    // Retrieving core update (Duppi 3.0.0+) information
    $duscoreupd = getCoreUpdate($mysqli,$userBuild,$line['build']);
    $dusbody .= "[corewip]\nVersion=".$line['build']."\nVersionDisp=".$line['versiondisp']."\nUpdateURL=".$line['URL']."\n".$duscoreupd."\n";

  }

  // Retrieving information about user build
  $query = "SELECT * FROM dus_versions WHERE (dupfrom <= ?) AND (dupto >= ?)";
  $stmt = $mysqli->prepare($query);
  if ($stmt === FALSE) {
    echo "Result=M60\n";
    echo "ResultDescription=".$mysqli->error."\n";
    die;
  }
  if (!$stmt->bind_param("ii", $userBuild, $userBuild)) {
    echo "Result=M62\n";
    echo "ResultDescription=".$stmt->error."\n";
    die;
  }
  if (!$stmt->execute()) {
    echo "Result=M63\n";
    echo "ResultDescription=".$stmt->error."\n";
    die;
  }
  if (!($queryresult = $stmt->get_result())) {
    echo "Result=M64\n";
    echo "ResultDescription=".$stmt->error."\n";
    die;
  }
  $stmt->close();

  $line = $queryresult->fetch_array(MYSQLI_ASSOC);
  $queryresult->close();

  if ($line !== NULL) {

    $userducifrom = $line['ducifrom'];
    $userducito   = $line['ducito'];
    $userdudifrom = $line['dudifrom'];
    $userdudito   = $line['dudito'];
    $userduhi     = $line['duhi'];
    $userlang     = $line['translation'];

  }
  else
  {
    echo "Result=P02\n";
    echo "ResultDescription=Unknown build of Dragon UnPACKer\n\n";
    echo "ResultQuery=".$query."\n";
    echo $dusbody;
    die;
  }

  // Retrieving available convert plugins
  $query = sprintf("SELECT name, version, description, versiondisp, URL, file, fileDL, size, comment, commentFR, DATE(date) FROM dus_convert WHERE duci>=%d AND duci<=%d AND versiontype='stable' ORDER BY name, version DESC",$userducifrom, $userducito);
  $queryresult = $mysqli->query($query);
  if ($queryresult === FALSE) {
    echo "Result=M30\n";
    echo "ResultDescription=".$mysqli->error."\n";
    die;
  }

  $dusupdates = "Updates=";
  $dusupdatesuntable = "UpdatesUnstable=";
  $lastconvertname = '';

  while ($line = $queryresult->fetch_array(MYSQLI_ASSOC)) {

    if ($lastconvertname != $line['name']) {
      $dusbody .= '['.$line['name']."]\nAutoUpdate=1\nVersion=".$line['version']."\nVersionDisp=".$line['versiondisp']."\nDescription=".$line['description']."\nComment=".$line['comment']."\nCommentFR=".$line['commentFR']."\n";
      $lastconvertname = $line['name'];
      $dusupdates .= $line['name'].' ';
      for ($x=0;$x<$numservers;$x++) {
        $dusbody .= 'URL';
        if ($x > 0) {
          $dusbody .= "$x";
        }
        if ($servers[$x]['path']) {
          $dusbody .= "=".$servers[$x]['url'].$line['URL']."\n";
        }
        else {
          $dusbody .= "=".$servers[$x]['url'].$line['fileDL']."\n";
        }
      }
      $dusbody .= "Size=".$line['size']."\nFile=".$line['file']."\nFileDL=".$line['fileDL']."\nDate=".$line['DATE(date)']."\nRealSize=".$line['realsize']."\nHash=".$line['hash']."\n\n";
    }

  }

  $queryresult->close();

  // Retrieving available stable drivers plugins
  $query = sprintf("SELECT name, version, description, versiondisp, URL, file, fileDL, size, comment, commentFR, DATE(date), realsize, hash FROM dus_driver WHERE dudi>=%d AND dudi<=%d AND versiontype='stable' ORDER BY name, version DESC",$userdudifrom,$userdudito);
  $queryresult = $mysqli->query($query);
  if ($queryresult === FALSE) {
    echo "Result=M31\n";
    echo "ResultDescription=".$mysqli->error."\n";
    die;
  }

  $lastdrivertname = '';

  while ($line = $queryresult->fetch_array(MYSQLI_ASSOC)) {

    if ($lastdrivertname != $line['name']) {
      $dusbody .= '['.$line['name']."]\nAutoUpdate=1\nVersion=".$line['version']."\nVersionDisp=".$line['versiondisp']."\nDescription=".$line['description']."\nComment=".$line['comment']."\nCommentFR=".$line['commentFR']."\n";
      $lastdrivertname = $line['name'];
      $drivercheck[$line['name']] = $line['version'];
      $dusupdates .= $line['name'].' ';
      for ($x=0;$x<$numservers;$x++) {
        $dusbody .= 'URL';
        if ($x > 0) {
          $dusbody .= "$x";
        }
        if ($servers[$x]['path']) {
          $dusbody .= "=".$servers[$x]['url'].$line['URL']."\n";
        }
        else {
          $dusbody .= "=".$servers[$x]['url'].$line['fileDL']."\n";
        }
      }
      $dusbody .= "Size=".$line['size']."\nFile=".$line['file']."\nFileDL=".$line['fileDL']."\nDate=".$line['DATE(date)']."\nRealSize=".$line['realsize']."\nHash=".$line['hash']."\n\n";
    }

  }

  $queryresult->close();

  // Retrieving available unstable+stable drivers plugins
  $query = sprintf("SELECT name, version, versiontype, description, versiondisp, URL, file, fileDL, size, comment, commentFR, DATE(date), realsize, hash FROM dus_driver WHERE dudi>=%d AND dudi<=%d ORDER BY name, version DESC",$userdudifrom,$userdudito);
  $queryresult = $mysqli->query($query);
  if ($queryresult === FALSE) {
    echo "Result=M41\n";
    echo "ResultDescription=".$mysqli->error."\n";
    die;
  }

  $lastdrivertname = '';

  while ($line = $queryresult->fetch_array(MYSQLI_ASSOC)) {

    if ($lastdrivertname != $line['name']) {
      $lastdrivertname = $line['name'];
      if ($drivercheck[$line['name']] != $line['version']) {
        $dusbody .= '[unstable:'.$line['name']."]\nAutoUpdate=1\nVersion=".$line['version']."\nVersionDisp=".$line['versiondisp']."\nDescription=".$line['description']."\nComment=".$line['comment']."\nCommentFR=".$line['commentFR']."\n";
        $drivercheck[$line['name']] = $line['version'];
        $dusupdatesuntable .= 'unstable:'.$line['name'].' ';
        for ($x=0;$x<$numservers;$x++) {
          $dusbody .= "URL";
          if ($x > 0) {
            $dusbody .= "$x";
          }
          if ($servers[$x]['path']) {
            $dusbody .= "=".$servers[$x]['url'].$line['URL']."\n";
          }
          else {
            $dusbody .= "=".$servers[$x]['url'].$line['fileDL']."\n";
          }
        }
        $dusbody .= "Size=".$line['size']."\nFile=".$line['file']."\nFileDL=".$line['fileDL']."\nDate=".$line['DATE(date)']."\n\n";
      }
      else {
        $dusupdatesuntable .= $line['name'].' ';
      }
    }

  }

  $queryresult->close();

  // Retrieving available hyperripper plugins
  $query = sprintf("SELECT name, version, description, versiondisp, URL, file, fileDL, size, comment, commentFR, DATE(date) FROM dus_hyperripper WHERE duhi=%d AND versiontype='stable' ORDER BY name, version DESC",$userduhi);
  $queryresult = $mysqli->query($query);
  if ($queryresult === FALSE) {
    echo "Result=M32\n";
    echo "ResultQuery=".$query."\n";
    echo "ResultDescription=".$mysqli->error."\n";
    die;
  }

  $lasthyperrippername = '';

  while ($line = $queryresult->fetch_array(MYSQLI_ASSOC)) {

    if ($lasthyperrippername != $line['name']) {
      $dusbody .= '['.$line['name']."]\nAutoUpdate=1\nVersion=".$line['version']."\nVersionDisp=".$line['versiondisp']."\nDescription=".$line['description']."\nComment=".$line['comment']."\nCommentFR=".$line['commentFR']."\n";
      $lasthyperrippername = $line['name'];
      $dusupdates .= $line['name'].' ';
      for ($x=0;$x<$numservers;$x++) {
        $dusbody .= 'URL';
        if ($x > 0) {
          $dusbody .= "$x";
        }
        if ($servers[$x]['path']) {
          $dusbody .= "=".$servers[$x]['url'].$line['URL']."\n";
        }
        else {
          $dusbody .= "URL=".$servers[$x]['url'].$line['fileDL']."\n";
        }
      }
      $dusbody .= "Size=".$line['size']."\nFile=".$line['file']."\nFileDL=".$line['fileDL']."\nDate=".$line['DATE(date)']."\n\n";
    }

  }

  $queryresult->close;

  // Retrieving available translations
  $query = sprintf("SELECT * FROM dus_translation WHERE version=%d ORDER BY name DESC",$userlang);
  $queryresult = $mysqli->query($query);
  if ($queryresult === FALSE) {
    echo "Result=M33\n";
    echo "ResultQuery=".$query."\n";
    echo "ResultDescription=".$mysqli->error."\n";
    die;
  }

  $lastlangname = '';
  $dustranslations = 'Translations=';

  while ($line = $queryresult->fetch_array(MYSQLI_ASSOC)) {

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

  $queryresult->close();

  echo "Result=OK\n";
  echo trim($dusupdates)."\n";
  echo trim($dusupdatesuntable)."\n";
  echo trim($dustranslations)."\n";
  echo trim($dusservers)."\n\n";
  echo $dusbody;

  // Closing MYSQL connection
  $mysqli->close();

?>