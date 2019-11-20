#!/bin/bash
echo "收集信息"
ZONE_ID=`grep zone_id /pitrix/conf/global/server.yaml |head -1|awk -F"'" '{print $2}'`
if [ ! -d /root/getresource/assembly ]
then
	mkdir -p /root/getresource/assembly/info
	mkdir -p /root/getresource/assembly/result
fi
INFO_DIR=/root/getresource/assembly/info
echo "主机信息"
/pitrix/lib/pitrix-scripts/exec_sql -d zone -c "select instance.owner, image.base_id, router_static.val1, router_static.val2, instance.instance_name from (router_static LEFT OUTER JOIN instance on router_static.val1 = instance.instance_id) left join image on instance.image_id = image.image_id where router_static.val1 like '%i-%';" > $INFO_DIR/instance

echo "LB信息"
/pitrix/lib/pitrix-scripts/exec_sql -d zone -c "select owner from loadbalancer where status = 'active' order by 1;" > $INFO_DIR/loadbalance
echo "rdb信息"
/pitrix/lib/pitrix-scripts/exec_sql -d zone -c "select owner,rdb_engine,engine_version from rdb where status = 'active' order by 1;" > $INFO_DIR/rdb
echo "cache信息"
/pitrix/lib/pitrix-scripts/exec_sql -d zone -c "select owner,cache_id,cache_type from cache where status = 'active' order by 1;" > $INFO_DIR/cache
/pitrix/lib/pitrix-scripts/exec_sql -d zone -c "select image_id,image_name,owner from image where status = 'available' order by 3;" > $INFO_DIR/image
echo "整理"

RESULT_DIR=/root/getresource/assembly/result
rm -rf $RESULT_DIR/*
cd $INFO_DIR
echo -e "账户\t类型\t版本\t数量" >> $RESULT_DIR/loadbalance.txt
echo -e "账户\t类型\t版本\t数量" >> $RESULT_DIR/cache.txt
echo -e "账户\t类型\t版本\t数量" >> $RESULT_DIR/rdb.txt
egrep -v 'ks-|wheezyx64|trustysrvx64|rdb-|loadrunner|fixed-address' instance | awk -F"|" '{print $4"\t"$3"\t"$2"\t"$6}' >> $RESULT_DIR/instance.txt
grep usr loadbalance | uniq -c|awk -F"|" '{print $2"\t""LB""\t""haproxy1.6.3""\t"$1}' >> $RESULT_DIR/loadbalance.txt
grep redis3.0.5 cache |uniq -c|awk -F"|" '{print $4"\t""cache""\t""redis3.0.5""\t"$1}' >> $RESULT_DIR/cache.txt
grep redis2.8.17 cache |uniq -c|awk -F"|" '{print $4"\t""cache""\t""redis2.8.17""\t"$1}' >> $RESULT_DIR/cache.txt
grep memcached1.4.13 cache |uniq -c|awk -F"|" '{print $4"\t""cache""\t""memcached1.4.13""\t"$1}' >> $RESULT_DIR/cache.txt
grep 5.5 rdb |grep mysql |uniq -c|awk -F"|" '{print $3"\t""rdb""\t""mysql5.5""\t"$1}' >> $RESULT_DIR/rdb.txt
grep 5.6 rdb |grep mysql |uniq -c|awk -F"|" '{print $3"\t""rdb""\t""mysql5.6""\t"$1}' >> $RESULT_DIR/rdb.txt
grep 5.7 rdb |grep mysql |uniq -c|awk -F"|" '{print $3"\t""rdb""\t""mysql5.7""\t"$1}' >> $RESULT_DIR/rdb.txt
grep 9.3 rdb |grep psql |uniq -c|awk -F"|" '{print $3"\t""rdb""\t""psql9.3""\t"$1}' >> $RESULT_DIR/rdb.txt
grep 9.4 rdb |grep psql |uniq -c|awk -F"|" '{print $3"\t""rdb""\t""psql9.4""\t"$1}' >> $RESULT_DIR/rdb.txt
egrep -v 'rvg|rdb-|mongo|loadbalancer|spark|redis|nas|vxnetmgr|router|cache|citrixnsvpx|ks-|s2|kafka|zookeeper|bigdata' image |awk -F"|" '{print $2"\t"$3"\t"$4}' >> $RESULT_DIR/image-${ZONE_ID}.txt
/root/getresource/sed.sh
