FROM checkmk/check-mk-raw:{{ pillar.check_mk_server.version }}

RUN apt-get -qq update &&\
	apt-get -qq install -y --no-install-recommends \
	python3 \
    patch \
    && \
	apt-get -qq clean && \
	rm -rf /var/lib/apt/lists/*
