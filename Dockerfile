# Soju build stage
FROM codeberg.org/emersion/soju AS soju

# Kimchi build stage
FROM codeberg.org/emersion/kimchi AS kimchi

# Gamja build stage
FROM codeberg.org/emersion/gamja AS gamja

FROM alpine:3.22 AS overmind
# renovate: datasource=github-releases depName=DarthSim/overmind
ARG OVERMIND_VERSION=v2.5.1

ARG OVERMIND=overmind-${OVERMIND_VERSION}-linux-amd64

RUN apk add --no-cache wget gzip ca-certificates tmux

ENV OVERMIND_FILE=overmind-${OVERMIND_VERSION}-linux-amd64.gz

ENV OVERMIND_URL=https://github.com/DarthSim/overmind/releases/download/${OVERMIND_VERSION}/${OVERMIND_FILE}

WORKDIR /
RUN wget "$OVERMIND_URL" && gunzip ${OVERMIND_FILE} && chmod +x "$OVERMIND" && mv ${OVERMIND} /usr/bin/overmind

# soju
COPY --from=soju /soju /sojudb /sojuctl /usr/bin/

# kimchi
COPY --from=kimchi /kimchi /usr/bin/

# gamja
COPY --from=gamja /gamja /gamja

# config
ADD Procfile /
ADD config/kimchi /kimchi-config
ADD config/soju /soju-config

CMD ["overmind", "start"]
