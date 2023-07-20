<?php
    if (!isset($_POST)) {
        $response = array('status' => 'failed', 'data' => null);
        sendJsonResponse($response);
        die();
    }

    include_once("dbconnect.php");

    $orderbill = $_POST['receiptid'];
    $itemid = $_POST['itemid'];
    $orderqty = $_POST['orderqty'];
    $totalpaid = $_POST['paid'];
    $buyerid = $_POST['buyerid'];
    $sellerid = $_POST['sellerid'];
	$address = $_POST['address'];

    $sqlgetqty = "SELECT `itm_qty` FROM `items_tbl` WHERE `itm_id` = '$itemid'";
    $result = $conn->query($sqlgetqty);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $currentqty = $row['itm_qty'];

        $updatedqty = $currentqty - $orderqty;

        $sqlupdate = "UPDATE `items_tbl` SET `itm_qty`='$updatedqty' WHERE `itm_id` = '$itemid'";
        if ($conn->query($sqlupdate) === TRUE) {
            $sqlorder = "INSERT INTO `orders_tbl`(`order_bill`, `item_id`, `order_qty`, `order_paid`, `buyer_id`, `seller_id`, `order_status`, `delivery_address`, `ship_date`, `complete_date`) VALUES ('$orderbill','$itemid','$orderqty','$totalpaid','$buyerid', '$sellerid', 'Processing', '$address', '-', '-')";
            if ($conn->query($sqlorder) === TRUE) {
                $response = array('status' => 'success', 'data' => null);
                sendJsonResponse($response);
            } else {
                $response = array('status' => 'failed', 'data' => null);
                sendJsonResponse($response);
            }
        } else {
            $response = array('status' => 'failed', 'data' => null);
            sendJsonResponse($response);
        }
    } else {
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
