FROM openhab/openhab:2.2.0-amd64-alpine

RUN setcap 'cap_net_raw,cap_net_admin=+eip cap_net_bind_service=+ep' \
  $(realpath /usr/bin/java)
