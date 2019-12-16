<?php
	
	if(!isset($_COOKIE['admin'])){
		header("Location:admin.php?user=admin");
	}

?>
