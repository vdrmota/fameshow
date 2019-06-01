<?php

ini_set('display_errors', 1);

	if (!isset($_POST['username']) || !isset($_POST['token']))
	{
		die('Missing username or some data');
	}

	// connect
	$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
	$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

	// prepare and execute
	$sth = $dbh->prepare('INSERT INTO tokens (username, token) VALUES (:username, :token)');
	$sth->execute(array('username' => $_POST['username'], 'token' => $_POST['token']));

	echo 1;
?>