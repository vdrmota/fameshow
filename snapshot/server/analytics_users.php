<?php

	//PHP is for savages
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
	
 	header("Access-Control-Allow-Origin: *");

	// //this syntax is incomprehsible to me
	$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
	$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

	// //I miss OCAML
	$sth = $dbh->prepare("SELECT COUNT(*) count, DATE(STR_TO_DATE(date, '%d:%m:%Y %H:%i:%s')) day FROM users GROUP BY day");
    $sth->execute();
	$results = $sth->fetchAll(PDO::FETCH_ASSOC);
	$json = json_encode($results);

 	echo $json


?>