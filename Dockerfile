## this stage installs everything required to build the project
FROM alpine:3.9 as build
RUN apk add alpine-sdk yaml-dev crystal shards upx
WORKDIR /tmp
COPY ./kcp.cr /tmp/
RUN \
    crystal build --progress --static kcp.cr && \
    upx /tmp/kcp

## this stage created final docker image
FROM busybox as release
COPY --from=build /tmp/kcp /kcp
USER nobody
CMD /kcp
