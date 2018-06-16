##################################################################
# Startup script for a local AEM development instance
# Yuri Simione - @artika.biz - https://linkedin.com/in/yurisimione
# 

ADOBE_HOME=/Users/yuri/Documents/VMware/ADOBE
MAIN_RUN_MODE=author
LOCAL_RUN_MODE=yuri-dev 
OAK_RUN=$ADOBE_HOME/$MAIN_RUN_MODE/oak-run-1.6.9.jar
HEAP_SPACE=2g 
JMX_PORT=9999
DEBUG_PORT=8000
INSTANCE_PATH=author
CQ_PORT=4502
CQ_JARFILE=$ADOBE_HOME/$INSTANCE_PATH/AEM_6.3_Quickstart.jar
START_OPTS="-p $CQ_PORT -gui"
CQ_JVM_OPTS="-Dcom.sun.management.jmxremote.port=$JMX_PORT -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false  -Xrunjdwp:transport=dt_socket,address=$DEBUG_PORT,suspend=n,server=y -Dsling.run.modes=\'$MAIN_RUN_MODE,$LOCAL_RUN_MODE\' -server -Xmx$HEAP_SPACE -Xdebug" 

clear
cd $ADOBE_HOME/$INSTANCE_PATH
CURR_DIR=$ADOBE_HOME/$INSTANCE_PATH

echo
echo "☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰" 
echo
echo Cleaning and tuning environment before to run the AEM local instance
echo 1. Removing all old log files
(find . -name "*.log*" | grep "/logs" | xargs rm)

echo 2. Removing Threadumps directory
(rm -rf crx-quickstart/threaddumps)

echo 3. Removing unreferenced checkpoints
(java -jar $OAK_RUN checkpoints install-folder/crx-quickstart/repository/segmentstore)
(java -jar $OAK_RUN checkpoints install-folder/crx-quickstart/repository/segmentstore rm-unreferenced)

echo "4. Compacting the SegmentStore (TAR)"
(java -jar $OAK_RUN compact install-folder/crx-quickstart/repository/segmentstore > $CURR_DIR/crx-quickstart/logs/oak-compacting.log)
echo 5. Starting $MAIN_RUN_MODE AEM instance

(
  (
    java $CQ_JVM_OPTS -jar $CQ_JARFILE $START_OPTS &
    echo $! > $CURR_DIR/crx-quickstart/conf/cq.pid
  ) >> $CURR_DIR/crx-quickstart/logs/stdout.log 2>&1
) &

echo 
echo AEM Started with pid "$(cat $CURR_DIR/crx-quickstart/conf/cq.pid)"
echo Run modes: $MAIN_RUN_MODE,$LOCAL_RUN_MODE
echo Debug enabled on port $DEBUG_PORT
echo JMX enabled on port $JMX_PORT
echo

DATE=$(date)
echo ⏳ $DATE: Checking AEM Status
 
for i in 0 1 2 3 4 5 6 7 8 9
do
  (netstat -na | grep -E $CQ_PORT.*LISTEN > /dev/null)
  if [ $? = 0 ] ; then
      break
  fi
  echo ⏳ waiting ...
  sleep 5
done
(netstat -na | grep -E $CQ_PORT.*LISTEN > /dev/null) 
if [ $? -eq 0 ]; then
    DATE=$(date)
    echo ✅ AEM started listening on $CQ_PORT port - $DATE 
    echo
    echo Start looking for ERROR level messages in the error.log file
    echo "☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰☰"
    echo
    tail -f $CURR_DIR/crx-quickstart/logs/error.log | grep -e ERROR
else
    echo ❌ AEM did not start correctly ❌
    echo Please check CQ_JVM_OPTS, START_OPTS, CQ_JARFILE definitions.
fi

