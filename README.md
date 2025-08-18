[![Docker Automated build](https://img.shields.io/docker/image-size/andgineer/openhab-synology)](https://hub.docker.com/r/andgineer/openhab-synology)

Docker Alpine [image](https://hub.docker.com/r/andgineer/openhab-synology) of [openHAB](http://openhab.org/) with settings for
Amazon Dash Button to use on Synology.

### Usage

    docker run --network=host --privileged andgineer/openhab-synology
    
If you run it locally the server will be on `http://localhost:8080`.

For Synology, the `network` and `privileged` options should be configured in Synology GUI, 
[see details](https://sorokin.engineer/posts/en/amazon_dash_button_hack_install.html) - `execute container using high privilege` and `Use the same network as Docker host`.

### Why Use This Image and Why the Official One May Not Be Suitable for Synology

The Amazon Dash Button OpenHAB binding sniffs network traffic.

OpenHAB runs under a Linux account without root privileges, so you need to grant
additional permissions to enable network sniffing.

The official OpenHAB documentation recommends using `docker run` with the following command line options:

    --cap-add NET_ADMIN --cap-add NET_RAW

You can find more details in the [OpenHAB official docker image](https://hub.docker.com/r/openhab/openhab/#running-from-command-line).

However, when it comes to Synology, the Docker command line is hidden, 
and there are no such settings available in the Synology GUI. 
Therefore, you need to add these additional permissions within the Docker container.

Synology does provide an [openHAB package for Synology](https://www.openhab.org/docs/installation/synology.html). 
However, to use this package, you may need to tweak Linux settings for network sniffing, 
which could potentially affect the NAS's core functionality.

### Implementation Details

To enable network sniffing, we need to grant additional capabilities to Java. 
You can achieve this with the following command:

    setcap 'cap_net_raw,cap_net_admin=+eip cap_net_bind_service=+ep' $(realpath /usr/bin/java)

After granting capabilities, you'll encounter another issue:
[cannot run Java after granting POSIX capabilities](https://bugs.java.com/view_bug.do?bug_id=7157699).

To resolve this issue, symbolic links are added in the Dockerfile:

    ln -s /usr/lib/jvm/java-17-openjdk/lib/libjli.so /usr/lib/
    ln -s /usr/lib/jvm/java-17-openjdk/lib/libjava.so /usr/lib/
    ln -s /usr/lib/jvm/java-17-openjdk/lib/server/libjvm.so /usr/lib/

#### How to Locate These Paths

Check library loading problems:

    ldd /usr/bin/java

Find missing library:

    find / -iname "libjli*"
