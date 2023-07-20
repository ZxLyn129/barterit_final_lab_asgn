<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

if (isset($_POST['sellerid'])){
	$sellerid = $_POST['sellerid'];
	$sqlloadseller = "SELECT * FROM users_tbl WHERE user_id = '$sellerid'";
	$result = $conn->query($sqlloadseller);

	if ($result->num_rows > 0) {
		while ($row = $result->fetch_assoc()) {
			$sellerlist = array();
			$sellerlist['id'] = $row['user_id'];
			$sellerlist['name'] = $row['user_name'];
			$sellerlist['email'] = $row['user_email'];
			$sellerlist['dateregister'] = $row['user_date_register'];
		$response = array('status' => 'success', 'data' => $sellerlist);
		sendJsonResponse($response);
		}
	}else{
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