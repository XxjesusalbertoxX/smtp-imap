FROM alpine:3.19

RUN apk add --no-cache \
    dovecot \
    dovecot-lmtpd \
    bash \
    shadow

COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# IMAP
EXPOSE 143
# LMTP (recibe correo de Postfix/Exim)
EXPOSE 24

ENTRYPOINT ["/entrypoint.sh"]
