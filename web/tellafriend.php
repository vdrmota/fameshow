<?php
// connect
	$dbh = new PDO('mysql:host=localhost;dbname=fame', 'root', 'theFAME44');
	$dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

	$referred = $_POST['username'];

	// prepare and execute
	$sth = $dbh->prepare('INSERT INTO referrals (user, referred_by) VALUES (:user, :referred)');
	$sth->execute(array('referred' => $referred, 'user' => $_POST['user']));
?>
<html>
<head>
<title>Success</title>
<meta scrollable = "false" />
<meta name="viewport" content="initial-scale=1, maximum-scale=1">
<meta charset="utf-8" /> 
<style>
* {
	font-family: "Avenir";
	-webkit-user-select: none;  /* Chrome all / Safari all */
	-webkit-tap-highlight-color: rgba(0,0,0,0);
/*	-webkit-touch-callout: none;
*/}
.table {
	position:absolute;
	bottom:0;
  }
ul#footer {
/*min-width: 320px;*/
list-style: none;
padding-top: 20px;
}
ul#footer li {
	display: inline;
}
h3 {
	font-size: 1.9em
}

.content {
        position:absolute; /*it can be fixed too*/
        left: 50%;
        top: 50%; /* position the left edge of the element at the middle of the parent */

        min-width: 250px;

        transform: translate(-50%, -50%); 
    }

</style>
</head>
<body>
Your referral has been submitted! We will review it within 24 hours. 
</body>
<html>