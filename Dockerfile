FROM ubuntu
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
   apt-get install -y software-properties-common && \
   apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 BC19DDBA && \
   add-apt-repository 'deb http://releases.galeracluster.com/ubuntu trusty main' && \
   apt-get update && \
   apt-get install -y galera-3 galera-arbitrator-3 mysql-wsrep-5.6 rsync lsof && \
   apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* && \
   mkdir /cluster.conf.d

EXPOSE 3306
EXPOSE 4567
EXPOSE 4568
EXPOSE 4444

COPY my.cnf /etc/mysql/my.cnf 
COPY entrypoint.sh /entrypoint.sh

ENV BOOTSTRAP=false


ENTRYPOINT ["/entrypoint.sh"]
