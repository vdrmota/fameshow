<?php

$current_version = 1.0

if ($current_version == $_POST['version'])
{
	echo "success";
}
else
{
	echo "failure";
}
?>