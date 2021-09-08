FROM checkmk/check-mk-raw:{{ pillar.check_mk_server.version }}

RUN apt-get -qq update &&\
	apt-get -qq install -y --no-install-recommends \
	python3 \
    patch \
    && \
	apt-get -qq clean && \
	rm -rf /var/lib/apt/lists/*


# Fix problem with systemd units, failed state is ignored
# Fix was introduced with: https://github.com/tribe29/checkmk/commit/151ba19c5c51a70c8c64a4f1ea40aab85b0f846d#diff-d6e72a5f64805f2c37bd569f34b1bf7ac039f0fdf7f635418770a7d44b4e88fd
# Fix was reverted with: https://github.com/tribe29/checkmk/commit/3097f9c57877fe7651d8c2a46e648a28cf920ed6#diff-d6e72a5f64805f2c37bd569f34b1bf7ac039f0fdf7f635418770a7d44b4e88fd
# Apply "right" patch from revision 151ba19c5c51a70c8c64a4f1ea40aab85b0f846d
COPY systemd_units.patch /systemd_units.patch
RUN cd /opt/omd/versions/{{ pillar.check_mk_server.version }}.cre/share/check_mk && \
    patch -p1 < /systemd_units.patch
