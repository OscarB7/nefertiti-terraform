FROM golang:1.16-alpine AS build
WORKDIR /opt
USER root

ARG NEFERTITI_VERSION=latest

ENV GIT_REPO_URL=https://api.github.com/repos/svanas/nefertiti/tags

RUN \
  if [[ ${NEFERTITI_VERSION} == "latest" ]]; then \
    NEFERTITI_VERSION=`wget -qO - ${GIT_REPO_URL} | grep '"name": "' | grep -o 'v[0-9]*.[0-9]*.[0-9]*[^"]*' | sort -ur | head -n 1` && \
    NEFERTITI_VERSION=${NEFERTITI_VERSION#v}; \
  fi && \
  wget -qO - https://github.com/svanas/nefertiti/archive/refs/tags/v${NEFERTITI_VERSION}.tar.gz | tar zxf - && \
  mv nefertiti* nefertiti && \
  cd nefertiti && \
  sed -i "s/99.99.999/${NEFERTITI_VERSION}/" main.go && \
  go build && \
  ./nefertiti --version


FROM alpine:latest
WORKDIR /opt/nefertiti/
USER root

ENV \
  # PS1='\[\e[32m\][\[\033[01;32m\]\u\[\033[01;32m\]@\[\033[01;32m\]\h\[\033[01;32m\] \[\033[01;36m\]\W\[\033[01;32m\]]\[\e[m\]$ ' \
  nefertiti_home=/opt/nefertiti \
  loop=true \
  increase_min_repetition=0 \
  increase_min_off=10 \
  command=about \
  test=true \
  listen=false \
  exchange=GDAX

ENV PATH=${PATH}:${nefertiti_home}

RUN \
  apk update --no-cache 1>/dev/null && \
  apk upgrade --no-cache 1>/dev/null && \
  addgroup -g 1000 nefertiti && \
  adduser -u 1000 -S -G nefertiti -h ${nefertiti_home} -s /sbin/nologin nefertiti && \
  chmod -R 755 ${nefertiti_home} && \
  chown -R nefertiti:nefertiti ${nefertiti_home}

USER nefertiti

COPY --chown=nefertiti:nefertiti --from=build /opt/nefertiti/nefertiti ${nefertiti_home}/
COPY --chown=nefertiti:nefertiti run.sh ${nefertiti_home}/

CMD sh run.sh
