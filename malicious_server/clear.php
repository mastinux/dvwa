<?php

if (isset($_POST['filename'])){
	$filename = $_POST['filename'];

	file_put_contents($filename, "");
}

header('Location: ' . $_SERVER['HTTP_REFERER']);

?>
