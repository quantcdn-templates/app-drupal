#!/bin/bash

# Configure SMTP if available.
if [ -n "$QUANT_SMTP_HOST" ]; then
    cat <<EOL > /etc/ssmtp/ssmtp.conf 
root=$QUANT_SMTP_FROM
mailhub=$QUANT_SMTP_HOST:$QUANT_SMTP_PORT
AuthUser=$QUANT_SMTP_USERNAME
AuthPass=$QUANT_SMTP_PASSWORD
UseTLS=YES
AuthMethod=LOGIN
FromLineOverride=YES
EOL
fi