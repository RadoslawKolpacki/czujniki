<?php
$receivedData = file_get_contents("php://input");

$jsonData = json_decode($receivedData, true);

if ($jsonData !== null) {
    $filename = 'dane.json';
    if (!file_exists($filename)) {
        fopen($filename, 'w');
    }
    $currentData = json_decode(file_get_contents($filename), true);
    $currentData[] = $jsonData;
    file_put_contents($filename, json_encode($currentData, JSON_PRETTY_PRINT));

    echo 'Dane dodane poprawnie.';
} else {
    echo 'Błąd: Otrzymane dane nie są w formacie JSON.';
}
?>