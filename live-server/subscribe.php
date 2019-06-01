<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

function my_function($broadcaster, $subscriber, $session)
{
	// connect
	$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
	$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

	// prepare and execute
	$sth = $dbh->prepare('INSERT INTO subscriptions (broadcaster, subscriber, session) VALUES (:broadcaster, :subscriber, :session)');
	$sth->execute(array('broadcaster' => $broadcaster, 'subscriber' => $subscriber, 'session' => $session));
}
?>