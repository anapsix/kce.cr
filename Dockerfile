## this stage installs everything required to build the project
FROM alpine:3.9 as build
RUN apk add alpine-sdk yaml-dev crystal shards upx
WORKDIR /tmp
COPY ./kce.cr /tmp/
RUN \
    crystal build --progress --static kce.cr && \
    upx /tmp/kce

## this stage created final docker image
FROM busybox as release
COPY --from=build /tmp/kce /kce
USER nobody
CMD /kce
