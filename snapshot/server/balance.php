<?php

ini_set('display_errors', 1);

	if (!isset($_POST['username']))
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
    	echo $row['balance'];
	}
?>