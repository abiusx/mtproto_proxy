#!/bin/sh
# Script that helps to overwrite port/secret/ad tag from command line without changing config-files

CMD="/opt/mtp_proxy/bin/mtp_proxy foreground"
# CMD="/opt/mtp_proxy/bin/mtp_proxy console"
THIS=$0

usage() {
    echo "Usage:"
    echo "port, secret, tag and allowed protocols can also be configured via environment variables:"
    echo "SECRET, TAG, MTP_DD_ONLY, MTP_TLS_ONLY"
}

error() {
    echo "ERROR: ${1}"
    usage
    exit 1
}
PORT=${PORT:-"4444"}

# check environment variables
PROTO_ARG="-mtproto_proxy allowed_protocols [mtp_fake_tls,mtp_secure]" # default

if [ -n "${DD_ONLY}" -a -n "${TLS_ONLY}" ]; then
    PROTO_ARG='-mtproto_proxy allowed_protocols [mtp_fake_tls,mtp_secure]'
elif [ -n "${DD_ONLY}" ]; then
    PROTO_ARG='-mtproto_proxy allowed_protocols [mtp_secure]'
elif [ -n "${TLS_ONLY}" ]; then
    PROTO_ARG='-mtproto_proxy allowed_protocols [mtp_fake_tls]'
fi

# if at least one option is set...
if [ -n "${PORT}" -o -n "${SECRET}" -o -n "${TAG}" ]; then
    # If at least one of them not set...
    [ -z "${PORT}" -o -z "${SECRET}" -o -z "${TAG}" ] && \
        error "Not enough options: -p '${PORT}' -s '${SECRET}' -t '${TAG}'"

    # validate format
    [ ${PORT} -gt 0 -a ${PORT} -lt 65535 ] || \
        error "Invalid port value: ${PORT}"
    [ -n "`echo $SECRET | grep -x '[[:xdigit:]]\{32\}'`" ] || \
        error "Invalid secret. Should be 32 chars of 0-9 a-f"
    [ -n "`echo $TAG | grep -x '[[:xdigit:]]\{32\}'`" ] || \
        error "Invalid tag. Should be 32 chars of 0-9 a-f"

    exec $CMD $PROTO_ARG -mtproto_proxy ports "[#{name => mtproto_proxy, port => $PORT, secret => <<\"$SECRET\">>, tag => <<\"$TAG\">>}]"
else
    exec $CMD $PROTO_ARG
fi
