<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

	if (!isset($_POST['username']) || !isset($_POST['password']))
	{
		die('Missing username');
	}

	// connect
	$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
	$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

	// prepare and execute
	$sth = $dbh->prepare('SELECT * FROM users WHERE username = :username LIMIT 1');
	$sth->execute(array('username' => $_POST['username']));

	// iterate through rows
	foreach ($sth as $row) {
		if (hash("sha256", $_POST['password']) == $row['password'])
		{
			echo 1;
		}
		else
		{
			echo 0;
		}
	}

?>