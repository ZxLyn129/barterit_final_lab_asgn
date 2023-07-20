<?php
	if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
	}
	
	include_once("dbconnect.php");
	
	$itmId = $_POST['itm_id'];
	$ownerid = $_POST['itm_owner_id'];
	$itmName = addcslashes($_POST['itm_name'], "\0..\37!@\177..\377");
	$itmType = $_POST['itm_type'];
	$itmDesc = addcslashes($_POST['itm_des'], "\0..\37!@\177..\377");
	$itmPrice = $_POST['itm_price'];
	$itmQty = $_POST['itm_qty'];
	$itmImage1 = $_POST['itm_image1'];
	$itmImage2 = $_POST['itm_image2'];
	$itmImage3 = $_POST['itm_image3'];
  
	$sqlupdate = "UPDATE `items_tbl` SET `itm_name`='$itmName',`itm_type`='$itmType',`itm_des`='$itmDesc',`itm_price`='$itmPrice',`itm_qty`='$itmQty' WHERE `itm_owner_id` = '$ownerid' AND `itm_id` = '$itmId'";
	
	try {
		if ($conn->query($sqlupdate) === TRUE) {	
			if($itmImage1 !== ""){
				$filename1 = $itmId.'i';
				$path1 = '../assets/itemImages/'.$filename1.'.png';
				if (file_exists($path1)) {
					unlink($path1);
				}
				$decoded_string1 = base64_decode($itmImage1);
				file_put_contents($path1, $decoded_string1);
			}
			if($itmImage2 !== ""){
				$filename2 = $itmId.'ii';
				$path2 = '../assets/itemImages/'.$filename2.'.png';
				if (file_exists($path2)) {
					unlink($path2);
				}
				$decoded_string2 = base64_decode($itmImage2);
				file_put_contents($path2, $decoded_string2);
			}
			if($itmImage3 !== ""){
				$filename3 = $itmId.'iii';
				$path3 = '../assets/itemImages/'.$filename3.'.png';
				if (file_exists($path3)) {
					unlink($path3);
				}
				$decoded_string3 = base64_decode($itmImage3);
				file_put_contents($path3, $decoded_string3);
			}
			
			$response = array('status' => 'success', 'data' => null);
			sendJsonResponse($response);
		}
		else{
			$response = array('status' => 'failed', 'data' => null);
			sendJsonResponse($response);
		}
	}
	catch(Exception $e) {
		$response = array('status' => 'failed', 'data' => null);
		sendJsonResponse($response);
	}
	$conn->close();
	
	function sendJsonResponse($sentArray)
	{
    header('Content-Type= application/json');
    echo json_encode($sentArray);
	}
?>