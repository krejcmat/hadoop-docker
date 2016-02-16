#!/bin/bash

slaves=/tmp/slaves
rm -f $slaves
>$slaves


function init_members(){
        members=$(serf members 2>&1| tac)
        while read -r line; do
                if [[ ($line =~ "slave" || $line =~ "master") && $line =~ "alive" ]]
                then
                        alive_mem=$(echo $line | cut -d " " -f 1 2>&1) #get hosts
                        echo "$alive_mem">>$slaves
                        continue
                fi
        done <<< "$members"
        #copy slave file to all slaves and master
        #create hbase 
        members_line=$(paste -d, -s $slaves 2>&1)
        memstr='members' #uniq string for replace

        while read -r member
        do
                scp $slaves $member:$HADOOP_CONF_DIR/slaves #hadoop
        done < "$slaves"
}


init_members

