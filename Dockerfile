FROM 192.168.88.222:5000/mariadb-10.1:latest
MAINTAINER alexander.helmos@gmail.com

COPY scripts/ /docker-entrypoint-initdb.d/.

# we need to touch and chown config files, since we cant write as mysql user
RUN mkdir -p /etc/mysql/conf.d/ \ 
    && mkdir -p /etc/mysql/mysql.conf.d \
    && touch /etc/mysql/conf.d/galera.cnf \
    && chown mysql.mysql /etc/mysql/conf.d/galera.cnf \
    && chown mysql.mysql /docker-entrypoint-initdb.d/*.sql \
    && mkdir -p /etc/mysql/conf.d \
    && mkdir -p /etc/mysql/mysql.conf.d \
    && echo '!includedir /etc/mysql/conf.d/' >> /etc/mysql/my.cnf \
    && echo '!includedir /etc/mysql/mysql.conf.d/' >> /etc/mysql/my.cnf \
    && apt-get update && apt-get install -y --no-install-recommends rsync  lsof  && rm -rf /var/lib/apt/lists/* \

# we expose all Cluster related Ports
# 3306: default MySQL/MariaDB listening port
# 4444: for State Snapshot Transfers
# 4567: Galera Cluster Replication
# 4568: Incremental State Transfer
EXPOSE 3306 4444 4567 4568

# we set some defaults
ENV GALERA_USER=galera \
    GALERA_PASS=galerapass \
    MAXSCALE_USER=maxscale \
    MAXSCALE_PASS=maxscalepass \ 
    CLUSTER_NAME=docker_cluster \
    MYSQL_ALLOW_EMPTY_PASSWORD=1
    
CMD ["mysqld"]

