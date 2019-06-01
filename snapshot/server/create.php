<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

function my_function($room, $streamid, $username, $session)
{
	// connect
	$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
	$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

	// prepare and execute
	$sth = $dbh->prepare('INSERT INTO rooms (roomkey, time, streamid, user, session) VALUES (:room, 0, :streamid, :user, :session)');
	$sth->execute(array('room' => $room, 'streamid' => $streamid, 'user' => $username, 'session' => $session));
}
?>