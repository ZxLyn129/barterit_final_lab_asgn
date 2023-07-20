<?php
	if (!isset($_POST)) {
		$response = array('status' => 'failed', 'data' => null);
		sendJsonResponse($response);
		die();
	}

	include_once("dbconnect.php");

	$itm_owner_id = $_POST['itm_owner_id'];
	$sqlload = "SELECT * FROM `items_tbl` WHERE itm_owner_id = '$itm_owner_id' ORDER BY itm_id DESC";
	$result = $conn->query($sqlload);

	if ($result->num_rows > 0) {
		$itemarray["items"] = array();
		
		while ($row = $result->fetch_assoc()) {
			$itemslist = array();
			$itemslist['itm_id'] = $row['itm_id'];
			$itemslist['itm_owner_id'] = $row['itm_owner_id'];
			$itemslist['itm_name'] = $row['itm_name'];
			$itemslist['itm_type'] = $row['itm_type'];
			$itemslist['itm_des'] = $row['itm_des'];
			$itemslist['itm_price'] = $row['itm_price'];
			$itemslist['itm_qty'] = $row['itm_qty'];
			$itemslist['itm_state'] = $row['itm_state'];
			$itemslist['itm_locality'] = $row['itm_locality'];
			$itemslist['itm_latitude'] = $row['itm_latitude'];
			$itemslist['itm_longitude'] = $row['itm_longitude'];
			$itemslist['itm_date'] = $row['itm_date'];
			array_push($itemarray["items"],$itemslist);
		}
		$response = array('status' => 'success', 'data' => $itemarray);
		sendJsonResponse($response);
	}else{
		$response = array('status' => 'failed', 'data' => null);
		sendJsonResponse($response);
	}

	function sendJsonResponse($sentArray)
	{
		header('Content-Type: application/json');
		echo json_encode($sentArray);
	}
?>