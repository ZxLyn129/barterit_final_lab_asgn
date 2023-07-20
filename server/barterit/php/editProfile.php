<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

if (isset($_POST['image'])) {
    $encoded_string = $_POST['image'];
    $id = $_POST['id'];
    $decoded_string = base64_decode($encoded_string);
    $path = '../assets/profile/' . $id . '.png';
    $is_written = file_put_contents($path, $decoded_string);
    if ($is_written){
        $response = array('status' => 'success', 'data' => null);
        sendJsonResponse($response);
    }else{
        $response = array('status' => 'failed', 'data' => null);
        sendJsonResponse($response);
    }
    die();
}

if (isset($_POST['password'])){
	$email = $_POST['email'];
	$password = sha1($_POST['password']);

	$sqlupdate = "UPDATE users_tbl SET user_password = '$password' WHERE user_email ='$email'";
	databaseUpdate($sqlupdate);
	die();
}

if (isset($_POST['userid'])){
	$id = $_POST['userid'];
	$name = $_POST['name'];
	$phone = $_POST ['phone'];
	$email = $_POST['email'];
	
	$sqlupdate = "UPDATE `users_tbl` SET `user_email`='$email', `user_phone`='$phone',`user_name`='$name' WHERE `user_id` = '$id'";
	databaseUpdate($sqlupdate);
	die();
}

function databaseUpdate($sql){
	include_once("dbconnect.php");
	try{
		if ($conn->query($sql) === TRUE) {
			$response = array('status' => 'success', 'data' => null);
			sendJsonResponse($response);
			exit();
		}else{
			$response = array('status' => 'failed', 'data' => null);
			sendJsonResponse($response);
			exit();
		}
	}
	catch(Exception $e){
		$response = array('status' => 'failed', 'data' => null);
		sendJsonResponse($response);
	}
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
	exit();
}
?>