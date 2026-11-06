FROM golang:1 AS build
ARG SOURCE_URL
ARG VERSION

WORKDIR /src
ADD $SOURCE_URL /tmp/anubis-src.tar.gz
RUN tar xzf /tmp/anubis-src.tar.gz --strip-components=1

COPY img/*.webp web/static/img/
COPY theme.css /tmp/
RUN cat /tmp/theme.css >> xess/xess.min.css

RUN CGO_ENABLED=0 go build -ldflags "-X github.com/TecharoHQ/anubis.Version=$VERSION" -o /anubis ./cmd/anubis

FROM cgr.dev/chainguard/static
COPY --from=build /src/LICENSE /usr/share/doc/anubis/LICENSE
COPY --from=build /anubis /usr/bin/anubis
ENTRYPOINT ["/usr/bin/anubis"]
