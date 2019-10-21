#!/bin/bash

cd /var/www/html

echo "avvio"

FILE=/var/www/html/config.php
if [ -f "$FILE" ]; then
    echo "$FILE exist"
    apachectl -D FOREGROUND
else 
   echo "copia"
   cd /sugarsource
   cp -pfr * /var/www/html
   echo "fine"
   cd /var/www/html
   apachectl -D FOREGROUND
fi

