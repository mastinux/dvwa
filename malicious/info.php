<!DOCTYPE html>
<html>
<head>
        <meta charset="UTF-8">
</head>
<body>

<div align="center">
	<form method="GET" action="/info.php">
		<textarea rows="3" name="msg" cols="60"></textarea>
		<p><input type="submit" value="Post"></p>
	</form>

	<form method="POST" action="/clear.php">
		<input type="hidden" name="filename" value="errorlog.php">
		<input type="submit" value="Clear errorlog">
	</form>

	<?php
		if (isset($_GET['msg'])){
			$msg = $_GET['msg'];

			$ip = getenv('REMOTE_ADDR');

			$error = fopen('errorlog.php','a');

			fwrite($error,'<br>'.$msg.'<br>'.$ip.'<br>');

			fclose($error);
		}

		# showing content
		$content = file_get_contents('./errorlog.php');
		echo $content;
	?>
</div>

</body>
</html>
