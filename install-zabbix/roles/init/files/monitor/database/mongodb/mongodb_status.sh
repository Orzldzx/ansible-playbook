#This script is used to get mongodb server status

#echo "db.serverStatus().uptime"|mongo 127.0.0.1:27017/admin
#echo "db.serverStatus().mem.mapped"|mongo 127.0.0.1:27017/admin
#echo "db.serverStatus().globalLock.activeClients.total"|mongo 127.0.0.1:27017/admin

MONGO_CMD="/opt/mongodb/bin/mongo"

case $# in
    2) output=$(/bin/echo "db.serverStatus().$2" |sudo $MONGO_CMD 127.0.0.1:$1/admin |sed -n '3p') ;;
    3) output=$(/bin/echo "db.serverStatus().$2.$3" |sudo $MONGO_CMD 127.0.0.1:$1/admin |sed -n '3p') ;;
    4) output=$(/bin/echo "db.serverStatus().$2.$3.$4" |sudo $MONGO_CMD 127.0.0.1:$1/admin |sed -n '3p') ;;
esac

# check if the output contains "NumberLong"
if [[ "$output" =~ "NumberLong" ]]; then
    echo $output|sed -n 's/NumberLong(//p'|sed -n 's/)//p'
else
    echo $output
fi
