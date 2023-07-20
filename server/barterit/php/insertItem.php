<?php
	if (!isset($_POST)) {
		$response = array('status' => 'failed', 'data' => null);
		sendJsonResponse($response);
		die();
	}

	include_once("dbconnect.php");

	$ownerid = $_POST['itm_owner_id'];
	$itmName = addcslashes($_POST['itm_name'], "\0..\37!@\177..\377");
	$itmType = $_POST['itm_type'];
	$itmDesc = addcslashes($_POST['itm_des'], "\0..\37!@\177..\377");
	$itmPrice = $_POST['itm_price'];
	$itmQty = $_POST['itm_qty'];
	$itmState = addcslashes($_POST['itm_state'], "\0..\37!@\177..\377");
	$itmLocality = addcslashes($_POST['itm_locality'], "\0..\37!@\177..\377");
	$itmLatitude = $_POST['itm_latitude'];
	$itmLongitude = $_POST['itm_longitude'];
	$itmImage1 = $_POST['itm_image1'];
	$itmImage2 = $_POST['itm_image2'];
	$itmImage3 = $_POST['itm_image3'];

	$sqlinsert = "INSERT INTO `items_tbl`(`itm_owner_id`, `itm_name`, `itm_type`, `itm_des`, `itm_price`, `itm_qty`, `itm_state`, `itm_locality`, `itm_latitude`, `itm_longitude`) VALUES ('$ownerid','$itmName','$itmType','$itmDesc','$itmPrice','$itmQty','$itmState','$itmLocality','$itmLatitude','$itmLongitude')";

	try{
		if ($conn->query($sqlinsert) === TRUE) {
			$decoded_string1 = base64_decode($itmImage1);
			$filename1 = mysqli_insert_id($conn).'i';
			$path1 = '../assets/itemImages/'.$filename1.'.png';
			file_put_contents($path1, $decoded_string1);
			
			$decoded_string2 = base64_decode($itmImage2);
			$filename2 = mysqli_insert_id($conn).'ii';
			$path2 = '../assets/itemImages/'.$filename2.'.png';
			file_put_contents($path2, $decoded_string2);
			
			$decoded_string3 = base64_decode($itmImage3);
			$filename3 = mysqli_insert_id($conn).'iii';
			$path3 = '../assets/itemImages/'.$filename3.'.png';
			file_put_contents($path3, $decoded_string3);
			
			$response = array('status' => 'success', 'data' => null);
			sendJsonResponse($response);
		}else{
			$response = array('status' => 'failed', 'data' => null);
			sendJsonResponse($response);
		}
	}catch(Exception $e){
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