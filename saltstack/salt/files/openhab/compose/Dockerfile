FROM openhab/openhab:latest

RUN apt-get -qq update &&\
	apt-get -qq install -y --no-install-recommends \
    netcat-openbsd \
	python3-pip \
    python3-venv \
    && \
	apt-get -qq clean && \
	rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/var/venv
RUN mkdir -m 777 $VIRTUAL_ENV
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip3 install --no-cache-dir \
    yeecli \
    telegram-send \
    && \
    chmod -R 777 $VIRTUAL_ENV

RUN echo -n "[telegram]\ntoken = {{ pillar.pws_secrets.telegram_notification_bot.token }}\nchat_id = {{ pillar.pws_secrets.telegram_notification_bot.chat_id }}" > /etc/telegram-send.conf

# Fix problem with ping in openhab container
# See here: https://community.openhab.org/t/network-pingdevice-breaks-after-4-3-6-5-0-1-update-docker/166175
RUN setcap cap_net_raw+ep /bin/ping
