FROM parrotstream/centos-openjdk

USER root

ADD cloudera-cdh5.repo /etc/yum.repos.d/

RUN rpm --import https://archive.cloudera.com/cdh5/redhat/7/x86_64/cdh/RPM-GPG-KEY-cloudera \
 && yum install -y sudo hadoop-hdfs-namenode hadoop-hdfs-datanode \
                   postgresql hive hive-jdbc hive-metastore \
                   hadoop-libhdfs \
                   impala impala-server impala-shell \
                   impala-catalog impala-state-store \
		   kudu kudu-master kudu-tserver \
 && yum clean all \
 && wget https://jdbc.postgresql.org/download/postgresql-9.4.1209.jre7.jar \
      -O /usr/lib/hive/lib/postgresql-9.4.1209.jre7.jar \
 && mkdir -p /var/run/hdfs-sockets /data/dn \
 && chown hdfs.hadoop /var/run/hdfs-sockets /data/dn \
 && groupadd supergroup; \
    usermod -a -G supergroup impala; \
    usermod -a -G hdfs impala; \
    usermod -a -G supergroup hive; \
    usermod -a -G hdfs hive

WORKDIR /

ADD etc/supervisord.conf /etc/
ADD etc/hive-site.xml /etc/hive/conf/
ADD etc/core-site.xml \
    etc/hdfs-site.xml /etc/hadoop/conf/
ADD etc/core-site.xml \
    etc/hdfs-site.xml \
    etc/hive-site.xml /etc/impala/conf/

# Various helper scripts
ADD bin/start-impala.sh \
    bin/supervisord-bootstrap.sh \
    bin/wait-for-it.sh /
ADD bin/supervisord-bootstrap.sh /

RUN chmod +x ./*.sh

# HDFS
EXPOSE 50010 50020 50070 50075 50090 50091 50100 50105 \
       50475 50470 8020 8485 8480 8481 50030 50060 13562 \
       10020 19888 9020 \
       21000 21050 22000 23000 24000 25000 25010 25020 \
       26000 28000 \
       9083 \
       8050 7050 8051 7051

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
