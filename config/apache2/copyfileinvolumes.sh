#!/bin/bash

cd /var/www/html

echo "avvio"

FILE=/var/www/html/config.php
if [ -f "$FILE" ]; then
    echo "$FILE exist"
    
else 
   echo "copia"
    if [ -z "${REPO_USER}" ]
    then
    echo "repo user empty"
        git clone https://${REPO_SUGAR} /var/www/html
    else
        echo "repo user not empty"
        git clone https://${REPO_USER}:${REPO_PASSWORD}@${REPO_URL_SUGAR}.git /var/www/html
    fi
  
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