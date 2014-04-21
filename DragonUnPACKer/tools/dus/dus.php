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
  define('DUS_VERSION','3.3.2');
  define('DUS_DATE','20140421');

  // MySQL configuration
  define('DUS_SQL_HOST','localhost');
  define('DUS_SQL_USER','d108923ro');
  define('DUS_SQL_PASS','rofordus3');
  define('DUS_SQL_DATABASE','drgunpackdus');          // Production Database
  define('DUS_SQL_DATABASE_TEST','drgunpackdustest'); // Test Database
  define('DUS_SQL_PORT', 3306);
  define('DUS_SQL_SOCKET', '/var/run/mysqld/mysqld.sock');

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

  function sendData($data) {

//    $supportsGzip = strpos( $_SERVER['HTTP_ACCEPT_ENCODING'], 'gzip' ) !== false;

//    if ( $supportsGzip ) {
//      $content = gzcompress($data,6);
//      header('Content-Encoding: gzip');
//      header('Vary: Accept-Encoding');
//    }
//    else {
      $content = $data;
//    }

    header( 'Content-Length: ' . strlen( $content ) );

    echo $content;

    die;

  }

  // Sending the header
  header('Content-type: text/plain');
  $dusheader = "[ID]\n";
  $dusheader .= "DUS=3\n";
  $dusheader .= "Description=Dragon UnPACKer 5 Update Server v".DUS_VERSION." (".DUS_DATE.")";

  // Test information
  define('DUS_TEST',isset($_GET['test']) && (strlen($_GET['test']) > 0) && boolVal($_GET['test']));
  if (DUS_TEST) {
    $testinfo = ' [TEST]';
  }
  else {
    $testinfo = '';
  }

  $dusheader .= "$testinfo\n";

  // Getting user build from HTTP GET parameter
  $userBuild = $_GET['installedbuild'];
  if ((!isset($userBuild)) | (strlen($userBuild) == 0) | (!is_numeric($userBuild))) {
    $dusheader .= "Result=P01\n";
    $dusheader .= "ResultDescription=Parameter \"installedbuild\" is missing!\n";
    sendData($dusheader);
  }

  // Connect to MYSQL Database
  if (DUS_TEST) {
    $sqldb = DUS_SQL_DATABASE_TEST;
  }
  else {
    $sqldb = DUS_SQL_DATABASE;
  }
  $mysqli = new mysqli(DUS_SQL_HOST, DUS_SQL_USER, DUS_SQL_PASS, $sqldb, DUS_SQL_PORT, DUS_SQL_SOCKET);
  if ($mysqli->connect_error) {
    $mysqli->close();
    $dusheader .= "Result=M01\n";
    $dusheader .= "ResultDescription=".$mysqli->connect_error."\n";
    sendData($dusheader);
  }

  // Selecting database
  if (!$mysqli->select_db($sqldb)) {
    $mysqli->close();
    $dusheader .= "Result=M02\n";
    $dusheader .= "ResultDescription=".$mysqli->error."\n";
    sendData($dusheader);
  }

  // Initialize body
  $dusbody = '';

  // Retrieving servers information
  $query = "SELECT serverID, serverURL, serverUsePaths, serverName FROM dus_servers WHERE serverEnabled='true' ORDER BY serverPriority";
  $queryresult = $mysqli->query($query);
  if ($queryresult === FALSE) {
    $dusheader .= "Result=M40\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$mysqli->error."\n";
    sendData($dusheader);
  }

  $dusservers = '';
  $numservers = 0;
  $servers = array();
  while ($line = $queryresult->fetch_array(MYSQLI_ASSOC)) {

    if (!(array_key_exists('serverID',$line) && array_key_exists('serverURL',$line)
     && array_key_exists('serverUsePaths',$line) && array_key_exists('serverName',$line))) {
      $dusheader .= "Result=M41\n";
      $dusheader .= "ResultDescription=Missing columns in server query\n";
      sendData($dusheader);
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
    $dusheader .= "Result=M60\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$mysqli->error."\n";
    sendData($dusheader);
  }
  if (!$stmt->bind_param("i", $userDuppiVersion)) {
    $dusheader .= "Result=M62\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$stmt->error."\n";
    sendData($dusheader);
  }
  if (!$stmt->execute()) {
    $dusheader .= "Result=M63\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$stmt->error."\n";
    sendData($dusheader);
  }
  if (!($queryresult = $stmt->get_result())) {
    $dusheader .= "Result=M64\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$stmt->error."\n";
    sendData($dusheader);
  }
  $stmt->close();

  $line = $queryresult->fetch_array(MYSQLI_ASSOC);
  $queryresult->close();

  if ($line === NULL) {
    $query = 'SELECT * FROM dus_duppi WHERE versionfrom=0 ORDER BY version DESC LIMIT 1';
    $queryresult = $mysqli->query($query);
    if ($stmt === FALSE) {
      $dusheader .= "Result=M61\n";
      $dusheader .= "ResultQuery=".$query."\n";
      $dusheader .= "ResultDescription=".$mysqli->error."\n";
      sendData($dusheader);
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
    $dusheader .= "Result=M10\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$mysqli->error."\n";
    sendData($dusheader);
  }

  $line = $queryresult->fetch_array(MYSQLI_ASSOC);
  $queryresult->close();
  $currentbuild = 0;

  if ($line !== NULL) {

    $duscoreupd = getCoreUpdate($mysqli,$userBuild,$line['build']);
    $dusbody .= "[core]\nVersion=".$line['build']."\nVersionDisp=".$line['versiondisp']."\nUpdateURL=".$line['URL']."\n".$duscoreupd."\n";
        $currentbuild = $line['build'];

  }

  // Retrieving corewip information
  $query = "SELECT * FROM dus_core WHERE type = 'wip' AND available = 'yes' AND build>? ORDER BY build DESC LIMIT 1";
  $stmt = $mysqli->prepare($query);
  if ($stmt === FALSE) {
    $dusheader .= "Result=M70\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$mysqli->error."\n";
    sendData($dusheader);
  }
  if (!$stmt->bind_param("i", $currentbuild)) {
    $dusheader .= "Result=M71\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$stmt->error."\n";
    sendData($dusheader);
  }
  if (!$stmt->execute()) {
    $dusheader .= "Result=M72\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$stmt->error."\n";
    sendData($dusheader);
  }
  if (!($queryresult = $stmt->get_result())) {
    $dusheader .= "Result=M11\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$stmt->error."\n";
    sendData($dusheader);
  }
  $stmt->close();

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
    $dusheader .= "Result=M60\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$mysqli->error."\n";
    sendData($dusheader);
  }
  if (!$stmt->bind_param("ii", $userBuild, $userBuild)) {
    $dusheader .= "Result=M62\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$stmt->error."\n";
    sendData($dusheader);
  }
  if (!$stmt->execute()) {
    $dusheader .= "Result=M63\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$stmt->error."\n";
    sendData($dusheader);
  }
  if (!($queryresult = $stmt->get_result())) {
    $dusheader .= "Result=M64\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$stmt->error."\n";
    sendData($dusheader);
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
    $dusheader .= "Result=P02\n";
    $dusheader .= "ResultDescription=Unknown build of Dragon UnPACKer\n\n";
    $dusheader .= "ResultQuery=".$query."\n";
	$dusbody = $dusheader.$dusbody;
    sendData($dusbody);
  }

  // Retrieving available convert plugins
  $query = sprintf("SELECT name, version, description, versiondisp, URL, file, fileDL, size, comment, commentFR, DATE(date) FROM dus_convert WHERE duci>=%d AND duci<=%d AND versiontype='stable' ORDER BY name, version DESC",$userducifrom, $userducito);
  $queryresult = $mysqli->query($query);
  if ($queryresult === FALSE) {
    $dusheader .= "Result=M30\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$mysqli->error."\n";
    sendData($dusheader);
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
    $dusheader .= "Result=M31\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$mysqli->error."\n";
    sendData($dusheader);
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
    $dusheader .= "Result=M41\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$mysqli->error."\n";
    sendData($dusheader);
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
    $dusheader .= "Result=M32\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$mysqli->error."\n";
    sendData($dusheader);
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
    $dusheader .= "Result=M33\n";
    $dusheader .= "ResultQuery=".$query."\n";
    $dusheader .= "ResultDescription=".$mysqli->error."\n";
    sendData($dusheader);
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

  $dusheader .= "Result=OK\n";
  $dusheader .= trim($dusupdates)."\n";
  $dusheader .= trim($dusupdatesuntable)."\n";
  $dusheader .= trim($dustranslations)."\n";
  $dusheader .= trim($dusservers)."\n\n";
  $dusbody = $dusheader.$dusbody;

  // Closing MYSQL connection
  $mysqli->close();

  sendData($dusbody);

?>
