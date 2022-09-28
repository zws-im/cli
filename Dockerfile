FROM nimlang/nim:1.6.8-alpine AS builder

WORKDIR /usr/src/app

COPY cli.nimble .
COPY ./src ./src

RUN nimble build -d:release

FROM alpine:3.16.2

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/zws /usr/local/bin

ENTRYPOINT ["zws"]
CMD ["-h"]
