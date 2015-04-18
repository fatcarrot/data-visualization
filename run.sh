#!/bin/sh
hive="/root/tool/qe_yuce/queryengine/bin/queryengine"
hadoop="/root/tool/hadoop-client-nj-trends-data-ZK/hadoop/bin/hadoop-internal"
mysql_client="/usr/bin/mysql"
Rscript="/usr/bin/Rscript"

#检测 trends_bl_skyeye_basic_data 数据是否生成
ret=1
day=""
if [ $# == 1 ]; then
    day=$1
else
    day=`date "+%Y%m%d" -d "-1 days"`
fi

while [ $ret -ne 0 ]
do
    sh ./table_exist.sh default trends_bl_skyeye_basic_data "event_day=${day}" ${hadoop} ${hive}
    ret=$?
    if [ $ret -eq 0 ]; then
        break
    fi  
    echo "sleep 10 minutes for waiting"
    sleep 10m 
done

#导出 mysql 库中的设备、机场数据
${mysql_client} -h10.48.25.150 -P8306 -uroot -p123456 --default-character-set=utf8 skyeye_base <device.sql  | awk 'NR>1' >device.data
${mysql_client} -h10.48.25.150 -P8306 -uroot -p123456 --default-character-set=utf8 bdg_skyeye  <airport.sql | awk 'NR>1' >airport.data
${mysql_client} -h10.48.25.150 -P8306 -uroot -p123456 --default-character-set=utf8 bdg_skyeye  <flight.sql  | awk 'NR>1' >flight.data

#导出设备信号数据
hdfs_path="/app/trends-data/temp/yucan/visual/signal.data/${day}"
${hadoop} fs -mkdir "${hdfs_path}"
${hive} --hivevar date=${day} path=${hdfs_path} -f signal.sql
rm signal.data
${hadoop} fs -getmerge ${hdfs_path} signal.data

#启用 R 完成可视化
${Rscript} device_airport_signal.R device.data signal.data flight.data airport.data area_jwd.data ${day}
