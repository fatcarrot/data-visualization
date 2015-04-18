#!/bin/sh
#输入: 库名 表名 分区标识
if [ $# == 5 ]; then
        echo "begin check!"
else
        echo "paramenter num wrong, please input 3 paramenters"
fi

hadoop=$4
hive=$5

cmd="USE $1; SHOW PARTITIONS $2 PARTITION($3)"
res=`${hive} -e "${cmd}"`
if [ $? == 0 ]; then
    echo "check hql statement execute success"
    if [ "${res}" != "" ]
    then
        echo "PARTITION($3) exist"
		echo ""
        exit 0
    else
        echo "PARTITION($3) not exist"
		echo ""
        exit 1
    fi
else
    echo "check hql statement execute wrong"
	echo ""
    exit 1
fi
