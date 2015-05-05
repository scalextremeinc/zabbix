FROM centos:7
RUN yum install -y tar mysql mysql-devel gcc gcc-c++ make

RUN useradd zabbix
RUN mkdir /opt/zabbix

RUN mkdir /tmp/zmq
WORKDIR /tmp/zmq
RUN wget http://download.zeromq.org/zeromq-3.2.5.tar.gz
RUN tar xf zeromq-3.2.5.tar.gz
WORKDIR /tmp/zmq/zeromq-3.2.5
RUN ./configure
RUN make
RUN make install
RUN echo "/usr/local/lib" >> /etc/ld.so.conf
RUN ldconfig
RUN rm -rf /tmp/zmq

ADD . /tmp/zabbix
WORKDIR /tmp/zabbix
RUN ./configure --enable-server --with-mysql --enable-queue
RUN make
RUN cp /tmp/zabbix/src/zabbix_server/zabbix_server /opt/zabbix/
# reduce container size
RUN rm -rf /tmp/zabbix

# reduce container size
RUN yum erase -y mysql-devel gcc gcc-c++ make
RUN yum clean all

ADD ./conf/zabbix_server.conf /opt/zabbix/
ADD ./database/mysql/zabbix_schema.sql /opt/zabbix/

VOLUME /volume
EXPOSE 8443

ADD ./docker/start.sh /opt/zabbix/
WORKDIR /opt/zabbix

CMD /opt/zabbix/start.sh
