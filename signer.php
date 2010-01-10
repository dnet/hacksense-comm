#!/usr/bin/php
<?php

if ($argc < 2) die("Usage: $argv[0] <message>\n");
print(hash_hmac('sha256', $argv[1], file_get_contents('hacksense.key')) . "\n");

?>
