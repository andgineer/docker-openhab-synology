Docker Alpine [image](https://cloud.docker.com/u/andgineer/repository/docker/andgineer/openhab-synology) of [openHAB](http://openhab.org/) with settings for
Amazon Dash Button to use on Synology.

### Why do you need this image and while official one is not good enough for Synology

Amazon Dash Button binding sniffs network.

OpenHAB is running under linux account without root privileges so you have to add some
additional rights to allow this sniff.

To do so official OpenHAB doc recommends you use `docker run` with command line options:

    --cap-add NET_ADMIN --cap-add NET_RAW

But in Synology Docker's command line is hidden and there are no such settings in Synology GUI.
So we have to add additional rights inside the Docker container.

They do have [openHAB package for Synology](https://docs.openhab.org/installation/synology.html).
But you have to mess around with settings for sniffing network and I do not want to do 
that on my NAS. It's very stable now and I do not want to break that.


### How to use it

Just as recommended for [OpenHAB official docker image](https://hub.docker.com/r/openhab/openhab/#running-from-command-line).

Do not forget to run container as privileged and in host network:

    docker run --network=host --privileged ...

In case of Synology this is GUI options, described, for example, [here](https://sorokin.engineer/posts/en/amazon_dash_button_hack_install.html) - `execute container using high privilige` and `Use the same network as Docker host`.

### Implementation details

We have to add additional capabilities to java:

    setcap 'cap_net_raw,cap_net_admin=+eip cap_net_bind_service=+ep' $(realpath /usr/bin/java)

After that we will have another problem:
[can not run java after granting posix capabilities](https://bugs.java.com/view_bug.do?bug_id=7157699).

To fix it I added `ln` into Dockerfile:

    ln -s /usr/lib/jvm/java-1.8-openjdk/lib/amd64/jli/libjli.so /usr/lib/

#### How to find all this paths

Check libraries loading problems:

    ldd /usr/bin/java

Find lost library:

    find / -iname "libjli*"
