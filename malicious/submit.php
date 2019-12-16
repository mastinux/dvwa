<!DOCTYPE html>
<html>
<head>
        <meta charset="UTF-8">
</head>
<body>

<div align="center">
	<form method="POST" action="comments.php">
		<textarea rows="10" name="comments" cols="60"></textarea>
		<p>
			<input type="submit" value="Post" name="sub">
			<input type="submit" value="Clear" formaction="clear.php">
		</p>
	</form>

	<?php
		$comments = file_get_contents('./comments.txt');
		echo $comments;
	?>
</div>

</body>
</html>
