<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}
include_once("dbconnect.php");

$email = $_POST['email'];
$password = sha1($_POST['password']);

$sqllogin = "SELECT * FROM users_tbl WHERE user_email = '$email' AND user_password = '$password'";

$result = $conn->query($sqllogin);
try{
if ($result->num_rows > 0) {
	while ($row = $result->fetch_assoc()) {
		$userlist = array();
		$userlist['id'] = $row['user_id'];
		$userlist['email'] = $row['user_email'];
		$userlist['name'] = $row['user_name'];
		$userlist['phone'] = $row['user_phone'];
		$userlist['password'] = sha1($_POST['password']);
		$userlist['otp'] = $row['user_otp'];
		$userlist['datereg'] = $row['user_date_register'];
		$response = array('status' => 'success', 'data' => $userlist);
		sendJsonResponse($response);
	}
}
else {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}
}
catch(Exception $e){
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