<?php

// connect
$dbh = new PDO('mysql:host=localhost;dbname=fame;charset=utf8mb4', 'root', 'theFAME44');
$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

function get_string_between($string, $start, $end, $offset)
{
    $split_string = explode($end,$string);
    foreach($split_string as $data) 
    {
         $str_pos = strpos($data,$start);
         $last_pos = strlen($data);
         $capture_len = $last_pos - $str_pos;
         $return[] = substr($data,$str_pos+$offset,$capture_len);
    }
    return $return;
}

$log = file_get_contents($argv[1]);
$log = explode("from 'intro_new.mp4':", $log)[1];

$analytics = get_string_between($log, "[!BEGIN_ANALYTICS!]", "[!END_ANALYTICS!]", 19);
array_pop($analytics);

$timer = 0;
$usersInterval = [];
$disconnects = [];

/* Get connections */

foreach ($analytics as $analytic)
{
	$connection = get_string_between($analytic, "[!CONNECTIONS!]", "[!END_CONNECTIONS!]", 15)[0];
	// get each line
	$connection = explode("\n", $connection);
	foreach ($connection as $username)
	{
		$username = explode(": ", $username);
		$socketid = str_replace("  ", "", $username[0]);
		$username = str_replace("',", "", $username[1]);
		$username = str_replace("' }", "", $username);
		$username = str_replace("'", "", $username);
		$socketid = preg_replace('/\s+/', '', $socketid);
		$username = preg_replace('/\s+/', '', $username);
		if ($socketid != $username)
		{
			// don't print fakes
			$totalUsers[] = $username;
			$usersInterval[$timer][] = $username;
		}
	}
	$timer += 30;
}

/* Get other data */
$timer = 0;
$ended = 0;
$lines = explode("\n", $log);
$comments = [];
$upvotes = [];
$switch = [];
$payouts = [];
$potentials = [];
$date = date("Y-m-d H:i:s");

foreach ($lines as $line)
{
	// if line is a tick
	if (strpos($line, "!Tick:") !== false)
	{
		$timer += 1;
	}

	// if line is disconnect
	if (strpos($line, "!disconnect:") !== false)
	{
		$details = explode("  ", $line);
		$disconnects[$details[1]][$timer] = true;
	}

	// if show ended
	if (strpos($line, "[!PAYOUTS!]") !== false)
	{
		$ended = $timer;
	}

	// if line is a comment
	if (strpos($line, "!comment ") !== false)
	{
		$author = get_string_between($line, "by ", ":", 3)[0];
		$text = get_string_between($line, "text: '", "',", 7)[0];
		$comments[$author][$timer] = $text;
	}

	// if line is an upvote
	if (strpos($line, "!upvote:") !== false)
	{
		$upvotes[$timer] += 1;
	}

	// if line is a payout
	if (strpos($line, "!stored:") !== false)
	{
		$details = explode(" ", $line);
		$user = $details[1];
		$payout = $details[2];
		$payouts[$user][$timer] = $payout;
	}

	// if line is a toggle
	if (strpos($line, "!toggle") !== false)
	{
		$details = explode(" ", $line);
		$result = str_replace(":", "", $details[1]);
		$user = $details[2];
		$switch[$user][$timer] = $result;
	}

	// if line contains potential streamers
	if (strpos($line, "!POTENTIAL:") !== false)
	{
		$details = explode(" ", $line);
		$potential = $details[1];
		$count = sizeof(explode(",", $potential));
		$potentials[$timer] = $count;
	}

	// if line is INIT_DATE
	if (strpos($line, "!INIT_DATE:") !== false)
	{
		$details = explode(": ", $line);
		$initDate = $details[1];
	}
	// if line is INIT_PAYOUT
	if (strpos($line, "!INIT_PAYOUT:") !== false)
	{
		$details = explode(": ", $line);
		$initPayout = $details[1];
	}

	// if line is INIT_INTERVAL
	if (strpos($line, "!INIT_INTERVAL") !== false)
	{
		$details = explode(": ", $line);
		$initInterval = $details[1];
	}
}	

// total users in show
$totalUsers = array_unique($totalUsers);
$sth = $dbh->prepare('INSERT INTO glance (showDate, totalUsers, showLength) VALUES (:date, :users, :length)');
$sth->execute(array('date' => $date, 'users' => sizeof(array_unique($totalUsers)), 'length' => $timer));

// all users in a show
foreach ($totalUsers as $user)
{
	//echo $user . "\n";
	$sth = $dbh->prepare('INSERT INTO totalUsers (showDate, userOnline) VALUES (:date, :user)');
	$sth->execute(array('date' => $date, 'user' => $user));
}

// users at each 30s interval
//print_r($usersInterval);
foreach ($usersInterval as $time => $users)
{
	foreach ($users as $user) {
		//echo $user . " @ " . $time . "\n";
		$sth = $dbh->prepare('INSERT INTO intervalUsers (showDate, userOnline, timeElapsed) VALUES (:date, :user, :timeElapsed)');
		$sth->execute(array('date' => $date, 'user' => $user, 'timeElapsed' => $time));
	}
}

// when each person disconnected
//print_r($disconnects);
foreach ($disconnects as $user => $times) {
	foreach ($times as $time => $bool) {
		//echo $user . " @ " . $time . "\n";
		$sth = $dbh->prepare('INSERT INTO disconnects (showDate, userDisconnected, timeElapsed) VALUES (:date, :user, :timeElapsed)');
		$sth->execute(array('date' => $date, 'user' => $user, 'timeElapsed' => $time));
	}
}

// when and what each person commented

foreach($comments as $user => $value)
{
	foreach ($value as $elapsed => $text)
	{
		//echo $user . " => " . $text . " @ " . $elapsed . "\n";

		$sth = $dbh->prepare('INSERT INTO comments (showDate, user, comment, timeElapsed) VALUES (:date, :user, :comment, :timeElapsed)');
		$sth->execute(array('date' => $date, 'user' => $user, 'comment' => $text, 'timeElapsed' => $elapsed));
	}
}

// when and how many upvotes
//print_r($upvotes);
foreach ($upvotes as $time => $amount) {
	//echo $amount . " @ " . $time . "\n";
	$sth = $dbh->prepare('INSERT INTO upvotes (showDate, timeElapsed, upvotes) VALUES (:date, :time, :upvotes)');
	$sth->execute(array('date' => $date, 'time' => $time, 'upvotes' => $amount));
}

// when a user turned their switch on/off
//print_r($switch);
foreach ($switch as $user => $value) {
	foreach ($value as $elapsed => $result) {
		//echo $user . " turned " . $result . " @ " . $elapsed . "\n";
		$sth = $dbh->prepare('INSERT INTO switchToggles (showDate, user, toggleResult, timeElapsed) VALUES (:date, :user, :toggle, :timeElapsed)');
		$sth->execute(array('date' => $date, 'user' => $user, 'toggle' => $result, 'timeElapsed' => intval($elapsed)));
	}
}

// who streamed, when, how long, and how much they were paid
print_r($payouts);
foreach ($payouts as $user => $value) {
	foreach ($value as $elapsed => $amount) {
		$streamtime = intval(($amount / $initPayout) * $initInterval);
		//print $user . " was paid " . $amount . " @ " . $elapsed . "\n";
		$sth = $dbh->prepare('INSERT INTO streamers (showDate, user, streamTime) VALUES (:date, :user, :streamtime)');
		$sth->execute(array('date' => $date, 'user' => $user, 'streamtime' => $streamtime));
	}
}

// amount of potential streamers at a given time
//print_r($potentials);
foreach ($potentials as $elapsed => $amount) {
	//echo $amount . " @ " . $elapsed . "\n";
	$sth = $dbh->prepare('INSERT INTO potentialStreamers (showDate, potentialStreamers, timeElapsed) VALUES (:date, :user, :timeElapsed)');
	$sth->execute(array('date' => $date, 'user' => $amount, 'timeElapsed' => $elapsed));
}
?>