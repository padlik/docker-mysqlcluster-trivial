#!/bin/bash
set -e

CLUSTER_SHARED_CONF=/cluster.conf.d/cluster.cnf
MYSQL_HOST=localhost

run_cluster_scripts(){
exec="Cluser scripts in /cluster.conf.d/"
    for f in /cluster.conf.d/*; do
	    case "$f" in
		*.cnf)    echo "$exec: Applaying settings for  $f"; source "$f" || true ;;
		*)        echo "$exec: Ignoring $f" ;;
	    esac
	    echo
    done
}

wait_for_mysql(){
  echo -n "Checking for MYSQL server: $MYSQL_HOST"
  while ! mysqladmin ping -h "$MYSQL_HOST" --silent >/dev/null 2>&1; do
   echo -n "."
   sleep 1
   done
  echo
  echo "MYSQL server is seems ok: $MYSQL_HOST"
}


case "$1" in
	'')
		run_cluster_scripts
                if [ $BOOTSTRAP = true ]; then
                 echo "Starting Master cluster node"
                 CLUSTER_NAME=`hostname`_cluster
                 touch ${CLUSTER_SHARED_CONF}
                 echo  "CLUSTER_NAME=${CLUSTER_NAME}" > ${CLUSTER_SHARED_CONF}
		 echo  "MASTER_HOST=`hostname`" >> ${CLUSTER_SHARED_CONF}
		 echo  "Cluster configuration has been written to:  ${CLUSTER_SHARED_CONF}"
		 echo  "Point your shared cluster volume at /cluster.conf.d/ for automatic configuration"
		 mysqld --wsrep-cluster-name=${CLUSTER_NAME} --wsrep-cluster-address=gcomm:// &
                else
                 echo "Starting slave node:"
                 echo "Master is set to:  gcomm://${MASTER_HOST}"
                 echo "Cluster name is: ${CLUSTER_NAME}"
		 mysqld --wsrep-cluster-name=${CLUSTER_NAME} --wsrep-cluster-address=gcomm://${MASTER_HOST} &
                fi
		wait_for_mysql
	        mysql -uroot -e "GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;"||true	
		while [ "$END" == '' ]; do
		    sleep 1
		    trap "mysqladmin -uroot shutdown" INT TERM
		done
		;;
         
	*)
		echo "Empty run detected. Please run '/entrypoint.sh' for installing database or debug an instance."
		$1
		;;
esac

