FROM centos:7
RUN yum install -y tar wget mysql mysql-devel gcc gcc-c++ make

RUN useradd zabbix
RUN mkdir /opt/zabbix

RUN mkdir -p /opt/zabbix/src/zmq
WORKDIR /opt/zabbix/src/zmq
RUN wget http://download.zeromq.org/zeromq-3.2.5.tar.gz
RUN tar xf zeromq-3.2.5.tar.gz
WORKDIR /opt/zabbix/src/zmq/zeromq-3.2.5
RUN ./configure
RUN make
RUN make install
RUN echo "/usr/local/lib" >> /etc/ld.so.conf

ADD . /opt/zabbix/src/zabbix
WORKDIR /opt/zabbix/src/zabbix
RUN ./configure --enable-server --with-mysql --enable-queue
RUN make
RUN cp /opt/zabbix/src/zabbix/src/zabbix_server/zabbix_server /opt/zabbix/

ADD ./conf/zabbix_server.conf /opt/zabbix/
ADD ./database/mysql/zabbix_schema.sql /opt/zabbix/
ADD ./alertscripts /etc/zabbix/alertscripts/
RUN chmod go+rx /etc/zabbix/alertscripts/*

ENV ALERTSCRIPTS=/etc/zabbix/alertscripts EXTERNALSCRIPTS=/etc/zabbix/externalscripts

VOLUME /volume
EXPOSE 8443

ADD ./docker/start.sh /opt/zabbix/
WORKDIR /opt/zabbix

CMD /opt/zabbix/start.sh
