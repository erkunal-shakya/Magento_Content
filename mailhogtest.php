<?php

$host = '127.0.0.1';
$port = 1025;

$socket = fsockopen($host, $port, $errno, $errstr, 10);
if (!$socket) {
    die("❌ Connection failed: $errstr ($errno)\n");
}

// Force blocking mode (IMPORTANT)
stream_set_blocking($socket, true);

// Read response
function read_smtp($socket) {
    $data = '';
    while ($line = fgets($socket, 515)) {
        $data .= $line;
        echo "<< $line";
        if (preg_match('/^\d{3} /', $line)) break;
    }
    return $data;
}

// Send command
function send_smtp($socket, $cmd) {
    echo ">> $cmd\n";
    fwrite($socket, $cmd . "\r\n");
    return read_smtp($socket);
}

// Start
read_smtp($socket);

send_smtp($socket, "EHLO localhost");
send_smtp($socket, "MAIL FROM:<sender@localhost>");
send_smtp($socket, "RCPT TO:<receiver@localhost>");

// DATA
echo ">> DATA\n";
fwrite($socket, "DATA\r\n");
read_smtp($socket);

// ✅ VERY SIMPLE EMAIL (no MIME first to confirm)
$message  = "Subject: Test Mail\r\n";
$message .= "From: sender@localhost\r\n";
$message .= "To: receiver@localhost\r\n";
$message .= "\r\n";
$message .= "Hello from MailHog welcome  test!\r\n";

// 🔥 CRITICAL: send in ONE write
fwrite($socket, $message);

// 🔥 CRITICAL: terminate properly
fwrite($socket, "\r\n.\r\n");

// Force flush
fflush($socket);

// Read response
read_smtp($socket);

send_smtp($socket, "QUIT");

fclose($socket);

echo "\n✅ DONE - Check http://localhost:8025\n";