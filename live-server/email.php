<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

	if (!isset($_POST['email']))
	{
		die('Missing email');
	}

	$_POST['email'] = str_replace(" ", "", $_POST['email']);

	if (strpos($_POST['email'], '@') === false) {
    	die('Invalid email');
	}

	$exists = "no";

	// connect
	$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
	$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

	// prepare and execute
	$sth = $dbh->prepare('SELECT * FROM users WHERE email = :email');
	$sth->execute(array('email' => $_POST['email']));

	// iterate through rows
	foreach ($sth as $row) {
		$exists = "yes";
	}

	if ($exists == "no")
	{
		echo "success";
	}
	else
	{
		echo "The email is already taken. Please use a new one.";
	}

?>