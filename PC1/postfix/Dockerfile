FROM alpine:3.19

RUN apk add --no-cache \
    postfix \
    postfix-pcre \
    cyrus-sasl \
    gettext \
    bash \
    shadow

COPY main.cf /etc/postfix/main.cf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]
