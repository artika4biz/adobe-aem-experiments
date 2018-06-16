#####################################################
# Startup script for a local AEM development instance
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
PATH=$PATH:$ADOBE_HOME/$INSTANCE_PATH/crx-quickstart/bin #just if you need to run stop or status command from the current shell
$CQ_JVM_OPTS=-Dcom.sun.management.jmxremote.port=$JMX_PORT -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -server -Xmx$HEAP-SPACE  -Xrunjdwp:transport=dt_socket,address=$DEBUG_PORT,suspend=n,server=y -Dsling.run.modes=\'$MAIN_RUN_MODE,$LOCAL_RUN_MODE\' -Xdebug  


cd $ADOBE_HOME/$INSTANCE_PATH

echo Cleaning and tuning environment before to run the AEM local instance
echo 1. Removing old log files
find . -name "*.log*" | grep "/logs" | xargs rm

echo 2. Removing Threadumps directory
rm -rf crx-quickstart/threaddumps

echo 3. Removing unreferenced checkpoints
java -jar $OAK_RUN checkpoints install-folder/crx-quickstart/repository/segmentstore 
java -jar $OAK_RUN checkpoints install-folder/crx-quickstart/repository/segmentstore rm-unreferenced

echo 4. Compacting the SegmentStore (TAR)
java -jar $OAK_RUN compact install-folder/crx-quickstart/repository/segmentstore 

echo 5. Starting $MAIN_RUN_MODE AEM instance and $LOCAL_RUN_MODE run mode, debug enabled on port $DEBUG_PORT, JMX enabled on port $JMX_PORT

(
  (
    java $CQ_JVM_OPTS -jar $CQ_JARFILE $START_OPTS &
    echo $! > $CURR_DIR/crx-quickstart/conf/cq.pid
  ) >> $CURR_DIR//crx-quickstart/logs/stdout.log 2>&1
) &



