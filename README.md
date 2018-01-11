Docker Alpine [image](https://hub.docker.com/r/masterandrey/docker-openhab-synology/) of [openHAB](http://openhab.org/) with settings for
Amazon Dash Button to use on Synology.

Amazon Dash Button OpenHAB binding needs that you use `docker run` with command line options:

    --cap-add NET_ADMIN --cap-add NET_RAW

But in Synology command line is hidden and there are no such settings in GUI.

So we have to add inside docker image:

    setcap 'cap_net_raw,cap_net_admin=+eip cap_net_bind_service=+ep' $(realpath /usr/bin/java)

After that we will have another problem:
[can not run java after granting posix capabilities](https://bugs.java.com/view_bug.do?bug_id=7157699).

To fix it I added `ln` into Dockerfile.

Check libraries loading:

    ldd /usr/bin/java

Find lost library:

    find / -iname "libjli*"

And do not forget to run container as privileged and in host network (GUI settings in Synology,
command line analogs `--network=host --privileged`).

