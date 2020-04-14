<!DOCTYPE html>
<html>
<head>
	<title>Malicious - Include</title>
        <meta charset="UTF-8">
</head>
<body>
	<?php
		$file = $_GET["file"];

		include "./$file.php";
	?>

</body>
</html>
