#!/bin/bash

function say_hello {
    echo 'hello'
}

function print_message_content {
    echo $MESSAGE
}

function get_web_page {
   domain=$1
   curl -XGET "http://www.google.com"
}
