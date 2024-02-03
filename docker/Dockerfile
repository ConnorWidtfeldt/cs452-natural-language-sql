# == BUILDER == #
FROM postgres:16-alpine AS builder

RUN apk add --no-cache clang15 git make llvm15 python3 libc-dev musl-dev

WORKDIR /usr/src
RUN git clone https://github.com/petere/pguint.git

WORKDIR /usr/src/pguint
RUN make && make install

# == RUNTIME == #
FROM postgres:16-alpine AS runtime

COPY --from=builder /usr/local/lib/postgresql /usr/local/lib/postgresql
COPY --from=builder /usr/local/share/postgresql /usr/local/share/postgresql
