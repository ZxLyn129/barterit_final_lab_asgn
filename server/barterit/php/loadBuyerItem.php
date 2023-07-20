<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

$results_per_page = 10;

if (isset($_POST['search'])) {
    $search = $_POST['search'];
	
	if (isset($_POST['spage'])) {
		$spage = $_POST['spage'];
	} else {
		$spage = 1;
	}
	$page_first_result = ($spage - 1) * $results_per_page;
	
    $countQuery = "SELECT COUNT(*) as count FROM `items_tbl` WHERE `itm_name` LIKE '%$search%' OR `itm_type` LIKE '%$search%' OR `itm_des` LIKE '%$search%' OR `itm_state` LIKE '%$search%' OR `itm_locality` LIKE '%$search%'";
    $countResult = $conn->query($countQuery);
    $countRow = $countResult->fetch_assoc();
    $number_of_result = $countRow['count'];

    
    $number_of_page = ceil($number_of_result / $results_per_page);

    $sqlload = "SELECT * FROM `items_tbl` WHERE `itm_name` LIKE '%$search%' OR `itm_type` LIKE '%$search%' OR `itm_des` LIKE '%$search%' OR `itm_state` LIKE '%$search%' OR `itm_locality` LIKE '%$search%'";
	$sqlload = $sqlload . " LIMIT $page_first_result, $results_per_page";
} else {
	if (isset($_POST['pageno'])) {
		$pageno = $_POST['pageno'];
	} else {
		$pageno = 1;
	}
	$page_first_result = ($pageno - 1) * $results_per_page;
    
    $countQuery = "SELECT COUNT(*) as count FROM `items_tbl`";
    $countResult = $conn->query($countQuery);
    $countRow = $countResult->fetch_assoc();
    $number_of_result = $countRow['count'];

    
    $number_of_page = ceil($number_of_result / $results_per_page);

    $sqlload = "SELECT * FROM `items_tbl`";
	$sqlload = $sqlload . " LIMIT $page_first_result, $results_per_page";
}

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

    $response = array('status' => 'success', 'data' => $itemarray, 'numofpage'=> $number_of_page, 'numberofresult' => $number_of_result);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
