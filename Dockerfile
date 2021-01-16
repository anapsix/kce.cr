## this stage installs everything required to build the project
FROM alpine:3.13 as build
RUN apk add --no-cache musl-dev yaml-static crystal upx
WORKDIR /tmp
COPY VERSION .
COPY shard.yml .
COPY ./src ./src
RUN \
    crystal build --progress --release --static src/cli.cr -o /tmp/kce && \
    upx /tmp/kce && \
    echo >&2 "## Version check: $(/tmp/kce -v)" && \
    echo >&2 "## Help Check" && \
    /tmp/kce --help


## this stage created final docker image
FROM busybox as release
COPY --from=build /tmp/kce /kce
USER nobody
ENTRYPOINT ["/kce"]
CMD ["--help"]
