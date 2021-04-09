FROM openjdk:8 as builder

RUN apt update && apt install -y build-essential

RUN wget http://www.erights.org/download/0-9-3/E-src-0.9.3d.tar.gz \
  && echo '4b1a126280fd05e839935a9b224844ee21b54ee7666de93082075c1a87b81fcb  E-src-0.9.3d.tar.gz' \
  | sha256sum --check

RUN tar --extract --file E-src-0.9.3d.tar.gz
WORKDIR /e
RUN make -C src
RUN sed -i s!/tmp/etrace!/var/log/etrace!g dist/inst-e.bash && dist/inst-e.bash

FROM openjdk:8-jre-alpine
RUN mkdir /var/log/etrace
COPY --from=builder /usr/local/e/e /usr/local/e

LABEL name="e" \
      version="0.9.3d" \
      url="http://www.erights.org/"

ENTRYPOINT [ \
    "/usr/bin/java", \
    "-cp", "/usr/local/e/e.jar", \
    "-Xfuture", \
    "-De.home=/usr/local/e/", \
    "org.erights.e.elang.interp.Rune" \
]
