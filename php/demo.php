<html>
<head>
<title>Payment Example</title>
</head>
<body>
<div style="margin-left:30px">
<?php
//URL to targeted 

$url = "https://pal-test.adyen.com/pal/adapter/httppost";
$username = "ws@Company.YourCompany";
$password = "verys3cret";

$ch = curl_init();

$carddata = $_POST["adyen-encrypted-data"];

// set URL and other appropriate options
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, 1);

$data = array(
$data = array(
    'action' => 'Payment.authorise',
    'paymentRequest.amount.currency' => 'EUR',
    'paymentRequest.amount.value' => '1000',
    'paymentRequest.merchantAccount' => 'YourMerchantAccount',
    'paymentRequest.reference' => 'Example Order 1',
    'paymentRequest.additionalData.card.encrypted.json' => $carddata,
);

curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));

curl_setopt($ch, CURLOPT_USERPWD, $username . ':' . $password);

// grab URL and pass it to the browser

$info = curl_getinfo($ch);
$output = curl_exec($ch);

// close curl resource, and free up system resources
curl_close($ch);

parse_str($output, $parsedoutput);

echo "<pre>";
print_r($parsedoutput);
echo "</pre>";

?>
</div>
</body>
</html>

