<!DOCTYPE html>
<html>
<head>
	<title>Malicious - Submit</title>
	<meta charset="UTF-8">
</head>
<body>

<div align="center">
	<form method="POST" action="/comments.php">
		<textarea rows="3" name="comments" cols="60"></textarea>
		<p><input type="submit" value="Post"></p>
	</form>

	<form method="POST" action="/clear.php">
		<input type="hidden" name="filename" value="comments.txt">
		<input type="submit" value="Clear">
	</form>

	<?php
		$comments = file_get_contents('./comments.txt');
		echo "<br><br>".$comments;
	?>
</div>

</body>
</html>
