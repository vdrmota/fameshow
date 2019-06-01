<?php
shell_exec("kill ".$_GET['pid']."");
echo "It's done, it's over. Find logs in 'output.log'";
?>
