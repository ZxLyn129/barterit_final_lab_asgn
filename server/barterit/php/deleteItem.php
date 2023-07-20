<?php
	if (!isset($_POST)) {
		$response = array('status' => 'failed', 'data' => null);
		sendJsonResponse($response);
		die();
	}

	include_once("dbconnect.php");

	$ownerid = $_POST['owner_id'];
	$itmId = $_POST['itmid'];

	$sqldelete = "DELETE FROM `items_tbl` WHERE `itm_owner_id` = '$ownerid' AND `itm_id` = '$itmId'";

	try{
		if ($conn->query($sqldelete) === TRUE) {
			$filename1 = $itmId.'i';
			$path1 = '../assets/itemImages/'.$filename1.'.png';
			if (file_exists($path1)) {
				unlink($path1);
			}
			$filename2 = $itmId.'ii';
			$path2 = '../assets/itemImages/'.$filename2.'.png';
			if (file_exists($path2)) {
				unlink($path2);
			}
			$filename3 = $itmId.'iii';
			$path3 = '../assets/itemImages/'.$filename3.'.png';
			if (file_exists($path3)) {
				unlink($path3);
			}
			
			$response = array('status' => 'success', 'data' => null);
			sendJsonResponse($response);
		}else{
			$response = array('status' => 'failed', 'data' => null);
			sendJsonResponse($response);
		}
	}catch(Exception $e) {
		$response = array('status' => 'failed', 'data' => null);
		sendJsonResponse($response);
	}
	$conn->close();

	function sendJsonResponse($sentArray)
	{
		header('Content-Type: application/json');
		echo json_encode($sentArray);
	}

?>