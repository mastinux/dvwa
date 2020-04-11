<?php

	$comments = $_POST['comments'];

	$log = fopen('comments.txt', 'a');

	#XXX user input is not sanitized
	fwrite($log, $comments."<br>");

	fclose($log);

	header('Location: ' . $_SERVER['HTTP_REFERER']);

?>
