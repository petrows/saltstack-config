FROM openhab/openhab:{{ pillar.openhab.version }}

RUN apt-get -qq update &&\
	apt-get -qq install -y --no-install-recommends \
    netcat-openbsd \
	python3-pip \
    python3-virtualenv \
    && \
	apt-get -qq clean && \
	rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/var/venv
RUN mkdir -m 777 $VIRTUAL_ENV
RUN python3 -m virtualenv --python=/usr/bin/python3 $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip3 install --no-cache-dir \
    yeecli \
    telegram-send \
    && \
    chmod -R 777 $VIRTUAL_ENV

RUN echo -n "[telegram]\ntoken = {{ pillar.pws_secrets.telegram_notification_bot.token }}\nchat_id = {{ pillar.pws_secrets.telegram_notification_bot.chat_id }}" > /etc/telegram-send.conf
