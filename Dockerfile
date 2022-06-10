FROM rust:1.61-alpine as builder

RUN apk add --no-cache musl-dev
COPY src src
COPY Cargo.toml Cargo.toml
COPY Cargo.lock Cargo.lock

RUN cargo build --release

FROM nfcore/base
COPY --from=eager-with-perf /usr/bin/perf /usr/bin/perf
COPY --from=builder target/release/do_stuff /usr/bin/do_stuff

