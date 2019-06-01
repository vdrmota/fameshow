<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

function my_function($room)
{
	// connect
	$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
	$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

	// prepare and execute
	$sth = $dbh->prepare('SELECT * FROM viewers WHERE roomkey = :room LIMIT 1');
	$sth->execute(array('room' => $room));

	// iterate through rows
	foreach ($sth as $row) {
		$viewers = $row['viewers'];
	}

	$sth = $dbh->prepare('SELECT * FROM votes WHERE roomkey = :room LIMIT 1');
	$sth->execute(array('room' => $room));

	// iterate through rows
	foreach ($sth as $row) {
		$votes = $row['votes'];
	}

	$res = array("votes" => $votes, "viewers" => $viewers);

	return json_encode($res);

}
?>