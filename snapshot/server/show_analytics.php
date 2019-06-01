<?php

	//PHP is for savages
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
	
 	header("Access-Control-Allow-Origin: *");

	// //this syntax is incomprehsible to me
	$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
	$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, true);

	$sth = $dbh->prepare("SELECT COUNT(userOnline) count FROM `totalUsers` WHERE showDate = :showDate;");
	$sth->execute(
		array("showDate" => htmlspecialchars($_GET["date"]))
	);
	echo '['
	while($rowset = $sth->fetchAll()){
	    //do stuff
		//echo json_encode($rowset);
		echo ','

	    $sth->nextRowset();
	}
	echo ']'

	// // //I miss OCAML
	// try {
	// 	$sth = $dbh->prepare("SELECT COUNT(userOnline) count FROM `totalUsers` WHERE showDate = :showDate;");
	//     $sth->execute(array(
	//     "showDate" => htmlspecialchars($_GET["date"])));
	// 	$results = $sth->fetchAll(PDO::FETCH_ASSOC);
	// 	$json = json_encode($results);
	// }
	// catch (PDOException $e)
	// {
	//     echo $e->getMessage();
	//     die();
	// }

// SELECT timeElapsed, COUNT(DISTINCT userOnline) count FROM `intervalUsers` WHERE showDate = :showDate GROUP BY timeElapsed;
// 		SELECT timeElapsed, potentialStreamers FROM `potentialStreamers` WHERE showDate = :showDate;
// 		SELECT timeElapsed, user, comment FROM `comments` WHERE showDate = :showDate ORDER BY timeElapsed  ASC;

	// SELECT COUNT(userOnline) FROM `totalUsers` WHERE showDate = :showDate
	// SELECT timeElapsed, COUNT(DISTINCT userOnline) FROM `intervalUsers` WHERE showDate = :showDate GROUP BY timeElapsed;
	// SELECT timeElapsed, potentialStreamers, showDate FROM `potentialStreamers` WHERE showDate = :showDate;
	// SELECT timeElapsed, user, comment FROM `comments` WHERE showDate = :showDate ORDER BY timeElapsed  ASC;

 	//echo $json


?>