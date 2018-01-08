Docker Alpine image of [openHAB](http://openhab.org/) with settings for 
Amazon Dash Button to use on Synology.

Amazon Dash Button OpenHAB binding needs that you use `docker run` with command line options:

    --cap-add NET_ADMIN --cap-add NET_RAW

But in Synology command line is hidden and there are no such settings in GUI.

So we have to add inside docker image:

    setcap 'cap_net_raw,cap_net_admin=+eip cap_net_bind_service=+ep' $(realpath /usr/bin/java)
