<?php

if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
	sendJsonResponse($response);
	die();
}

include_once("dbconnect.php");

if (isset($_POST['sellerid'])){
	$sellerid = $_POST['sellerid'];	
	$sqlorder = "SELECT * FROM `orders_tbl` JOIN `items_tbl` ON orders_tbl.item_id = items_tbl.itm_id JOIN `users_tbl` ON orders_tbl.buyer_id = users_tbl.user_id WHERE orders_tbl.seller_id = '$sellerid' ORDER BY orders_tbl.order_date DESC";

	$result = $conn->query($sqlorder);

	if ($result->num_rows > 0) {
		$orderdetailslist["orders"] = array();
		while ($row = $result->fetch_assoc()) {
			$orderdetails = array();
            $orderdetails['orderdetail_id'] = $row['order_id'];
            $orderdetails['order_bill'] = $row['order_bill'];
            $orderdetails['item_id'] = $row['item_id'];
            $orderdetails['itm_name'] = $row['itm_name'];
            $orderdetails['itm_price'] = $row['itm_price'];
            $orderdetails['order_qty'] = $row['order_qty'];
            $orderdetails['order_paid'] = $row['order_paid'];
            $orderdetails['buyer_id'] = $row['buyer_id'];
			$orderdetails['buyer_name'] = $row['user_name'];
            $orderdetails['seller_id'] = $row['seller_id'];
			$orderdetails['order_status'] = $row['order_status'];
            $orderdetails['delivery_address'] = $row['delivery_address'];
            $orderdetails['order_date'] = $row['order_date'];
			$orderdetails['ship_date'] = $row['ship_date'];
			$orderdetails['complete_date'] = $row['complete_date'];
			
			array_push($orderdetailslist["orders"], $orderdetails);
		}
		$response = array('status' => 'success', 'data' => $orderdetailslist);
		sendJsonResponse($response);
	} else {
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
