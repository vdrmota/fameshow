<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// connect
$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

// prepare and execute
$sth = $dbh->prepare('SELECT * FROM users ORDER BY balance DESC LIMIT 3');
$sth->execute();

$result = "";
$c = 0;

// iterate through rows
foreach ($sth as $row) {
	$sth2 = $dbh->prepare('SELECT COUNT(*) FROM totalUsers WHERE userOnline = "'.$row['username'].'"');
	$sth2->execute();
	$shows = $sth2->fetchAll()[0][0];
	if ($c == 2)
	{
		$result .= ";".$row['username'].",".$row['balance'].",7";
	}
	else if ($c == 1)
	{
		$result .= ";".$row['username'].",".$row['balance'].",9";
	}
	else
	{
		$result .= $row['username'].",".$row['balance'].",".$shows;
	}
	$c++;
}

echo $result;

?>