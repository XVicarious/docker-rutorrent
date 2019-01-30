# docker-rutorrent

Right now the config files require some tweaking for this to run properly. Paths in several pyrocore configuration files need to be updated for this to work.

The goal is to have this running with OpenVPN. Some of the work is based off of https://github.com/binhex/arch-rtorrentvpn but I've based it off of Alpine Edge.

I have rebuilt curl with c-ares support, and also built rtorrent and libtorrent from source to enable async DNS for rtorrent, which seems to be a limiting factor for the Arch build of rtorrent.
