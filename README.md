# docker-rutorrent
## branch: rut

This is the "rut" branch of this image. This only contains rutorrent and what it needs to run. You need a separate instance of rtorrent running with a scgi socket.

This image is bigger than I wanted it to be. I opted to use supervisord-go as opposed to the python version for size reasons. However, when packed with UPX `supervisord` seg faults. I will be investigating this, as it brings the image down by ~70MB.

To run this image:  
```
docker run -d --name rutorrent \
	-p 80:80/tcp \
	-v <config-dir>:/config \
	-v <rtorrent-socket>:/tmp/rpc.socket \
	bmaurer/rutorent:rut
```
