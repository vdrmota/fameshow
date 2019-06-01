<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

function my_function($payouts)
{
	// connect
	$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
	$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

	foreach ($payouts as $user => $payout)
	{

		// prepare and execute
		//$sth = $dbh->prepare('UPDATE rooms SET time = :time, finished = 1 WHERE streamid = :streamid AND finished = 0');
		//$sth->execute(array('time' => $time, 'streamid' => $streamid));

		// prepare and execute
		$sth = $dbh->prepare('UPDATE users SET balance = balance + :payout WHERE username = :user');
		$sth->execute(array('payout' => $payout, 'user' => $user));

	}
 
	$day = (intval(date("N")) + 1) % 6;
	$time = 7;

	$sth = $dbh->prepare('UPDATE nextShow SET day = :day, time = :time');
	$sth->execute(array('day' => $day, 'time' => $time));
}
?>