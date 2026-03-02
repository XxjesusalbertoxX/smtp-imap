FROM alpine:3.19

RUN apk add --no-cache \
    exim \
    exim-doc \
    bash \
    shadow \
    gettext

COPY exim4.conf /etc/exim/exim.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]
