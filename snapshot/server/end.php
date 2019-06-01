<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if (!isset($_GET['session']))
{
	die("no session");
}
	// connect
	$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
	$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

	// prepare and execute
	$sth = $dbh->prepare('SELECT * FROM rooms WHERE session = :session ORDER BY time DESC');
	$sth->execute(array('session' => $_GET['session']));

	$result = new array();

	// iterate through rows
	foreach ($sth as $row) {
		$result[$row['user']] = $row['time'];
	}

	echo json_encode($result);

?>