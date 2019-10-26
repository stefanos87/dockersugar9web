#!/bin/bash

cd /var/www/html

echo "avvio"

FILE=/var/www/html/config.php
if [ -f "$FILE" ]; then
    echo "$FILE exist"
    
else 
   echo "copia"
   git clone ${REPO_SUGAR} /var/www/html
   mkdir /var/www/html/sessioni
   chmod -R 777 /var
   chown -R sugar:sugar /var/www/html

#    cd /sugarsource
#    cp -pfr * /var/www/html
   echo "fine"
#    cd /var/www/html
fi


apachectl -D FOREGROUND



# RUN git clone ${REPO_SUGAR} /sugarsource
# RUN mkdir /sugarsource/sessioni
# RUN chmod -R 777 /var
# RUN chown -R sugar:sugar /sugarsource