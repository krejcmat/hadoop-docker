# hadoop-docker

Quickly build arbitrary size Hadoop Cluster based on Docker
------
Core of this project is based on [kiwenlau](https://github.com/kiwenlau) and [Serf](https://github.com/jai11/docker-serf) docker file. Hadoop version is upgraded and its configuration is partly rewritten. In addition HBase support has been added. As UNIX system is used [Debian wheezy minimalistic](https://hub.docker.com/r/philcryer/min-wheezy/) instead of Ubuntu. Hadoop is setup as fully distributed cluster with YARN. Size of docker images was reduced but room for optimizing  still there. [Squash utility](https://github.com/jwilder/docker-squash) during optimization reduced only approx. 30Mb. The method is not used due to losing information of docker image layers. 

Tip: See other Hadoop based project in [kjrecmat](https://github.com/krejcmat) repository.

######Version of products
| system          | version    | 
| ----------------|:----------:| 
| Hadoop          | 2.71       |
| Java            | JDK 7.60.19|
| Serf            | 0.7.0      |


######See file structure of project 
```
$ tree 
.
├── build-image.sh
├── hadoop-base
│   ├── Dockerfile
│   └── files
│       ├── bashrc
│       ├── hadoop-env.sh
│       └── ssh_config
├── hadoop-dnsmasq
│   ├── dnsmasq
│   │   ├── dnsmasq.conf
│   │   └── resolv.dnsmasq.conf
│   ├── Dockerfile
│   ├── handlers
│   │   ├── member-failed
│   │   ├── member-join
│   │   └── member-leave
│   └── serf
│       ├── event-router.sh
│       ├── serf-config.json
│       └── start-serf-agent.sh
├── hadoop-master
│   ├── Dockerfile
│   └── files
│       └── hadoop
│           ├── configure-members.sh
│           ├── core-site.xml
│           ├── hdfs-site.xml
│           ├── mapred-site.xml
│           ├── run-wordcount.sh
│           ├── start-hadoop.sh
│           ├── start-ssh-serf.sh
│           ├── stop-hadoop.sh
│           └── yarn-site.xml
├── hadoop-slave
│   ├── Dockerfile
│   └── files
│       └── hadoop
│           ├── core-site.xml
│           ├── hdfs-site.xml
│           ├── mapred-site.xml
│           ├── start-ssh-serf.sh
│           └── yarn-site.xml
├── README.md
├── resize-cluster.sh
└── start-container.sh

```

###Usage
####1] Clone git repository
```
$ git clone https://github.com/krejcmat/hadoop-docker.git
$ cd hadoop-docker
```

####2] Get docker images 
Two options how to get images are available. By pulling images directly from Docker official repository or build from Dockerfiles and sources files(see Dockerfile in each hadoop-* directory). Builds on DockerHub are automatically created by pull trigger or GitHub trigger after update Dockerfiles. Triggers are setuped for tag:latest. Below is example of stable version krejcmat/hadoop-<>:0.1. Version krejcmat/hadoop-<>:latest is compiled on DockerHub from master branche on GitHub.

######a) Download from Docker hub
```
$ docker pull krejcmat/hadoop-master:latest
$ docker pull krejcmat/hadoop-slave:latest
```

######b)Build from sources(Dockerfiles)
The first argument of the script for bulilds is must be folder with Dockerfile. Tag for sources is **latest**
```
$ ./build-image.sh hadoop-dnsmasq
```

######Check images
```
$ docker images

REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
krejcmat/hadoop-slave     latest              81cddf669d42        42 minutes ago      670.9 MB
krejcmat/hadoop-master    latest              ed91c813b86f        42 minutes ago      670.9 MB
krejcmat/hadoop-base      latest              cae006d1c427        50 minutes ago      670.9 MB
krejcmat/hadoop-dnsmasq   latest              89f0052d964c        53 minutes ago      156.9 MB
philcryer/min-wheezy      latest              214c501b67fa        14 months ago       50.74 MB


```
images:
philcryer/min-wheezy, krejcmat/hadoop-dnsmasq, krejcmat/hadoop-base are only temporary for builds. For removing use command:
```
$ docker rmi c4c4000322cf e148f587cc4f d196b785d987
``` 


####3] Initialize Hadoop (master and slaves)
######a)run containers
The first parameter of start-container.sh script is tag of image version, second parameter configuring number of nodes.
```
$ ./start-container.sh latest 2

start master container...
start slave1 container...
```

#####Check status
######Check members of cluster
```
$ serf members

master.krejcmat.com  172.17.0.2:7946  alive  
slave1.krejcmat.com  172.17.0.3:7946  alive
```


#####b)Run Hadoop cluster
######Creating configures file for Hadoop and Hbase(includes zookeeper)
```
$ cd ~
$ ./configure-members.sh

Warning: Permanently added 'slave1.krejcmat.com,172.17.0.3' (ECDSA) to the list of known hosts.slaves          100%     40     0.0KB/s   00:00    
Warning: Permanently added 'slave1.krejcmat.com,172.17.0.3' (ECDSA) to the list of known hosts.slaves          100%     40     0.0KB/s   00:00    
Warning: Permanently added 'slave1.krejcmat.com,172.17.0.3' (ECDSA) to the list of known hosts.hbase-site.xml  100%   1730     1.7KB/s   00:00    
Warning: Permanently added 'master.krejcmat.com,172.17.0.2' (ECDSA) to the list of known hosts.slaves          100%     40     0.0KB/s   00:00    
Warning: Permanently added 'master.krejcmat.com,172.17.0.2' (ECDSA) to the list of known hosts.slaves          100%     40     0.0KB/s   00:00    
Warning: Permanently added 'master.krejcmat.com,172.17.0.2' (ECDSA) to the list of known hosts.hbase-site.xml  100%    1730    1.7KB/s  00:00    
```

######Starting Hadoop
```
$ ./start-hadoop.sh 
 #For stop Hadoop ./stop-hadoop.sh

Starting namenodes on [master.krejcmat.com]
master.krejcmat.com: Warning: Permanently added 'master.krejcmat.com,172.17.0.2' (ECDSA) to the list of known hosts.
master.krejcmat.com: starting namenode, logging to /usr/local/hadoop/logs/hadoop-root-namenode-master.krejcmat.com.out
slave1.krejcmat.com: Warning: Permanently added 'slave1.krejcmat.com,172.17.0.3' (ECDSA) to the list of known hosts.
master.krejcmat.com: Warning: Permanently added 'master.krejcmat.com,172.17.0.2' (ECDSA) to the list of known hosts.
slave1.krejcmat.com: starting datanode, logging to /usr/local/hadoop/logs/hadoop-root-datanode-slave1.krejcmat.com.out
master.krejcmat.com: starting datanode, logging to /usr/local/hadoop/logs/hadoop-root-datanode-master.krejcmat.com.out
Starting secondary namenodes [0.0.0.0]
0.0.0.0: Warning: Permanently added '0.0.0.0' (ECDSA) to the list of known hosts.
0.0.0.0: starting secondarynamenode, logging to /usr/local/hadoop/logs/hadoop-root-secondarynamenode-master.krejcmat.com.out

starting yarn daemons
starting resource manager, logging to /usr/local/hadoop/logs/yarn--resourcemanager-master.krejcmat.com.out
master.krejcmat.com: Warning: Permanently added 'master.krejcmat.com,172.17.0.2' (ECDSA) to the list of known hosts.
slave1.krejcmat.com: Warning: Permanently added 'slave1.krejcmat.com,172.17.0.3' (ECDSA) to the list of known hosts.
slave1.krejcmat.com: starting nodemanager, logging to /usr/local/hadoop/logs/yarn-root-nodemanager-slave1.krejcmat.com.out
master.krejcmat.com: starting nodemanager, logging to /usr/local/hadoop/logs/yarn-root-nodemanager-master.krejcmat.com.out
```

######Print Java processes
```
$ jps

342 NameNode
460 DataNode
1156 Jps
615 SecondaryNameNode
769 ResourceManager
862 NodeManager
```

######Print status of Hadoop cluster 
```
$ hdfs dfsadmin -report

Name: 172.17.0.2:50010 (master.krejcmat.com)
Hostname: master.krejcmat.com
Decommission Status : Normal
Configured Capacity: 98293264384 (91.54 GB)
DFS Used: 24576 (24 KB)
Non DFS Used: 77983322112 (72.63 GB)
DFS Remaining: 20309917696 (18.92 GB)
DFS Used%: 0.00%
DFS Remaining%: 20.66%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 1
Last contact: Wed Feb 03 16:09:14 UTC 2016

Name: 172.17.0.3:50010 (slave1.krejcmat.com)
Hostname: slave1.krejcmat.com
Decommission Status : Normal
Configured Capacity: 98293264384 (91.54 GB)
DFS Used: 24576 (24 KB)
Non DFS Used: 77983322112 (72.63 GB)
DFS Remaining: 20309917696 (18.92 GB)
DFS Used%: 0.00%
DFS Remaining%: 20.66%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 1
Last contact: Wed Feb 03 16:09:14 UTC 2016
```

####4] Control cluster from web UI
######Overview of UI web ports
| web ui           | port       |
| ---------------- |:----------:| 
| Hadoop namenode  | 50070      |
| Hadoop cluster   | 8088       |

so your IP address is 172.17.0.2

```
$ xdg-open http://172.17.0.2:60010/
```
######Direct access from container(not implemented)
Used Linux distribution is installed without graphical UI. Easiest way is to use another Unix distribution by modifying Dockerfile of hadoop-hbase-dnsmasq and rebuild images. In this case start-container.sh script must be modified. On the line where the master container is created must add parameters for [X forwarding](http://wiki.ros.org/docker/Tutorials/GUI). 

###Documentation
####hadoop-hbase-dnsmasq
Base image for all the others. Dockerfile of dnsmaq provide image build based on Debian wheezy minimalistic and (Serf)[https://www.serfdom.io/] which is solution for cluster membership. Serf is also workaround for problem with  **/etc/hosts** which is readonly in docker containers. With starting docker container instance the reference is pass as: ```docker run -h -dns <IP_OF_DNS>```. Advantage of usage **Serf** is handling cluster, like nodes joining, leaving, failing. Configuration scripts are used from [Docker container Serf/Dnsmasq](https://github.com/jai11/docker-serf)


###Sources & references

######configuration
[Hadoop YARN installation guide](http://www.alexjf.net/blog/distributed-systems/hadoop-yarn-installation-definitive-guide/)

[Hbase main manual](https://hbase.apache.org/book.html)

######docker
[Docker cheat sheet](https://github.com/wsargent/docker-cheat-sheet)

[how to make docker image smaller](http://jasonwilder.com/blog/2014/08/19/squashing-docker-images/)

######Serf
[SERF: tool for cluster membership](https://www.serfdom.io/intro/)

[Serf docker presentation from Hadoop summit14](http://www.slideshare.net/JanosMatyas/docker-based-hadoop-provisioning)

[Docker Serf/Dnsmasq](https://github.com/jai11/docker-serf)


###Some notes, answers
######Region server vs datanode 
Data nodes store data. Region server(s) essentially buffer I/O operations; data is permanently stored on HDFS (that is, data nodes). I do not think that putting region server on your 'master' node is a good idea.

Here is a simplified picture of how regions are managed:

You have a cluster running HDFS (NameNode + DataNodes) with a replication factor of 3 (each HDFS block is copied into 3 different DataNodes).

You run RegionServers on the same servers as DataNodes. When write request comes to RegionServer it first writes changes into memory and commit log; then at some point, it decides that it is time to write changes to permanent storage on HDFS. Here is where data locality comes into play: since you run RegionServer and DataNode on the same server, first HDFS block replica of the file will be written to the same server. Two other replicas will be written to, well, other DataNodes. As a result, RegionServer serving the region will almost always have access to a local copy of data.

What if RegionServer crashes or RegionMaster decided to reassign region to another RegionServer (to keep cluster balanced)? New RegionServer will be forced to perform remote read first, but as soon as compaction is performed (merging of change log into the data) - new file will be written to HDFS by the new RegionServer, and local copy will be created on the RegionServer (again, because DataNode and RegionServer runs on the same server).

Note: in the case of RegionServer crash, regions previously assigned to it will be reassigned to multiple RegionServers.
