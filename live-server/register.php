<?php

ini_set('display_errors', 1);

	if (!isset($_POST['username']) || !isset($_POST['password']) || !isset($_POST['email']))
	{
		die('Missing username or some data');
	}

	// connect
	$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
	$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

	$datea = date("d:m:Y H:i:s");

	// prepare and execute
	$sth = $dbh->prepare('INSERT INTO users (username, email, password, date, ip) VALUES (:username, :email, :password, :datea, :ip)');
	$sth->execute(array('username' => $_POST['username'], 'email' => $_POST['email'], 'password' => hash("sha256", $_POST['password']), 'datea' => $datea, 'ip' => $_SERVER['REMOTE_ADDR']));

	echo "success";
?>