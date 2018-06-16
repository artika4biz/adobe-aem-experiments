export ADOBE_HOME=/Users/yuri/Documents/VMware/ADOBE
export MAIN_RUN_MODE=author
export OAK_RUN=$ADOBE_HOME/$MAIN_RUN_MODE/oak-run-1.6.9.jar

cd $ADOBE_HOME/$MAIN_RUN_MODE

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

echo 5. Starting AEM, debug mode, JMX enabled
java -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -server -Xmx2g  -Xrunjdwp:transport=dt_socket,address=8000,suspend=n,server=y -Dsling.run.modes='author,ysvlocaldev' -Xdebug -jar ./AEM_6.3_Quickstart.jar -p 4502 -gui

 
