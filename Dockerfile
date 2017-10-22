FROM alpine:3.6
RUN apk add --no-cache bash
ADD rbu /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/rbu"]

