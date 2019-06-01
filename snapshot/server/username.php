<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

	if (!isset($_POST['username']))
	{
		die('Missing username');
	}

	if (strlen($_POST['username']) <= 3)
	{
		die("Your username needs to be at least 4 character long.");
	}

	if(preg_match('/^[a-zA-Z]+[a-zA-Z0-9._]+$/', $_POST['username']))
	{
	    //Valid
	}
	else
	{
	    die("Only letters, numbers, periods, and underscores.");
	}

	$exists = "no";

	// connect
	$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
	$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

	// prepare and execute
	$sth = $dbh->prepare('SELECT * FROM users WHERE username = :username');
	$sth->execute(array('username' => $_POST['username']));

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
		echo "Your username is already taken.";
	}

?>