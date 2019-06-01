<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$json = file_get_contents("https://timezoneapi.io/api/ip/?".$_SERVER['REMOTE_ADDR']."");
$json = json_decode($json, true);
$offset = $json["data"]["datetime"]["offset_hours"];

$days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

// connect
$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

// prepare and execute
$sth = $dbh->prepare('SELECT * FROM nextShow LIMIT 1');
$sth->execute();

// iterate through rows
foreach ($sth as $row) {
   $time_in_gmt = $row['time']; // this is PM in GMT; for AM use negatives, eg 10AM = -2, 8AM = -4, 12PM = 0.
	$day = $row['day']; // select index from array days.
}


if ($offset > 12 - $time_in_gmt)
{
	// if client timezone rolls over to next day
	$am_pm = "am";
	$hour = ($time_in_gmt + $offset) % 12;
	$day = ($day + 1) % 7;
}
elseif ($time_in_gmt + $offset == 12)
{
	// if client timezone is midnight
	$am_pm = "am";
	$hour = 12;
}
elseif ($time_in_gmt + $offset == 0)
{
	// if client timezone is noon
	$am_pm = "pm";
	$hour = 12;
}
elseif ($time_in_gmt + $offset < 0)
{
	// if client timezone is in the morning
	$am_pm = "am";
	$hour = 12 + ($time_in_gmt + $offset);
}
else
{
	// if client timezone is in the afternoon
	$hour = ($time_in_gmt + $offset) % 12;
	$am_pm = "pm";
}


$first = "GOING LIVE";
$second = $days[$day]." ".$hour.$am_pm;
$third = "Prize: $2/min";

echo $first . "," . $second . "," . $third;

?>
