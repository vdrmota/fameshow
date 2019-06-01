<?php
$pid = shell_exec("node automatic.js> output.log 2>&1 & echo $!;"); 
echo 'Running. REMEMBER! run <a href="kill.php?pid='.$pid.'">this</a> when done.'; 
?>
