FROM node:19

RUN git clone --recursive https://github.com/lasthead0/yandex2mqtt.git /opt/yandex2mqtt && \
    cd /opt/yandex2mqtt && \
    npm install

WORKDIR /opt/yandex2mqtt

CMD node app.js --log-info
