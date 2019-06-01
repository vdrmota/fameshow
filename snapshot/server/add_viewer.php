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
	$sth = $dbh->prepare('UPDATE viewers SET viewers = viewers + 1, maxviewers = maxviewers + 1 WHERE roomkey = :room');
	$sth->execute(array('room' => $room));

}
?>