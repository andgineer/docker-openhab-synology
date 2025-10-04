FROM openhab/openhab:latest-alpine

RUN apk add libcap \
  && setcap 'cap_net_raw,cap_net_admin,cap_net_bind_service=+eip' \
  $(realpath /usr/bin/java) \
  && ln -s /usr/lib/jvm/java-17-openjdk/lib/libjli.so /usr/lib/ \
  && ln -s /usr/lib/jvm/java-17-openjdk/lib/libjava.so /usr/lib/ \
  && ln -s /usr/lib/jvm/java-17-openjdk/lib/server/libjvm.so /usr/lib/ \
  && sync

# Health check: interval=check every 30s, timeout=10s per check, start-period=120s grace period, retries=3 failures before unhealthy
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1
