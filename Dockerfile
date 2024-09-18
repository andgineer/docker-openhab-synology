FROM openhab/openhab:latest-alpine

RUN apk add libcap \
  && setcap 'cap_net_raw,cap_net_admin,cap_net_bind_service=+eip' \
  $(realpath /usr/bin/java) \
  && ln -s /usr/lib/jvm/java-17-openjdk/lib/libjli.so /usr/lib/ \
  && ln -s /usr/lib/jvm/java-17-openjdk/lib/libjava.so /usr/lib/ \
  && ln -s /usr/lib/jvm/java-17-openjdk/lib/server/libjvm.so /usr/lib/ \
  && sync
