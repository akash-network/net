FROM akashnet/base-ubuntu

ADD bin/stats_linux_amd64 /stats

CMD /stats -b ":$PORT"
