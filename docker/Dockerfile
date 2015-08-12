FROM centos:7
RUN yum install -y tar wget mysql mysql-devel gcc gcc-c++ make

RUN useradd zabbix
RUN mkdir /opt/zabbix

ENV ALERTSCRIPTS=/etc/zabbix/alertscripts EXTERNALSCRIPTS=/etc/zabbix/externalscripts LOG_DIR=/volume/log 
VOLUME /volume
EXPOSE 8443

RUN mkdir -p /opt/zabbix/src/zmq
WORKDIR /opt/zabbix/src/zmq
RUN wget http://download.zeromq.org/zeromq-4.1.2.tar.gz
RUN tar xf zeromq-4.1.2.tar.gz
WORKDIR /opt/zabbix/src/zmq/zeromq-4.1.2
RUN ./configure --without-libsodium 
RUN make
RUN make install
RUN echo "/usr/local/lib" >> /etc/ld.so.conf
RUN ldconfig

ADD . /opt/zabbix/src/zabbix
WORKDIR /opt/zabbix/src/zabbix
RUN ./configure --enable-server --with-mysql --enable-queue
RUN make
RUN cp /opt/zabbix/src/zabbix/src/zabbix_server/zabbix_server /opt/zabbix/

ADD ./docker/zabbix_server.conf /opt/zabbix/
ADD ./database/mysql/zabbix_schema.sql /opt/zabbix/
ADD ./alertscripts /etc/zabbix/alertscripts/
ADD ./docker/start.sh /opt/zabbix/
RUN chmod go+rx /etc/zabbix/alertscripts/*

WORKDIR /opt/zabbix

CMD ["/opt/zabbix/start.sh"]
