FROM nimlang/nim:1.6.4-alpine AS builder

WORKDIR /usr/src/app

COPY cli.nimble .
COPY ./src ./src

RUN nimble build -d:release

FROM alpine:3.16.0

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/zws /usr/local/bin

ENTRYPOINT ["zws"]
CMD ["-h"]
