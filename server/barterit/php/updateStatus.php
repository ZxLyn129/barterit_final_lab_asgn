<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

if (isset($_POST['sellerid'])){
	$sellerid = $_POST['sellerid'];
	$orderbill = $_POST['orderbill'];
	$date = $_POST['date'];
	
	$sqlupdate = "UPDATE `orders_tbl` SET `order_status`='Shipping',`ship_date`='$date' WHERE `seller_id` = '$sellerid' AND `order_bill` = '$orderbill'";

	try {
		if ($conn->query($sqlupdate) === TRUE) {	
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
}

if (isset($_POST['buyerid'])){
	$buyerid = $_POST['buyerid'];
	$orderbill = $_POST['orderbill'];
	$date = $_POST['date'];
	
	$sqlupdate = "UPDATE `orders_tbl` SET `order_status`='Completed',`complete_date`='$date' WHERE `buyer_id` = '$buyerid' AND `order_bill` = '$orderbill'";

	try {
		if ($conn->query($sqlupdate) === TRUE) {	
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
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>