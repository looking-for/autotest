WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
INT=$4
FUNC_PATH=$5

# cp -fr ${FUNC_PATH}/config_files/etc_1 ${INSTALL_PATH}/nta/etc
# ${INSTALL_PATH}/nta/bin/nta_start.sh restart
${INSTALL_PATH}/nta/bin/pcap_save.sh stop >/dev/null 2>/dev/null
sleep 3
rm -fr /tmp/nta/pcapsavefile >/dev/null 2>/dev/null
rm -fr ${FUNC_PATH}/tmp/* >/dev/null 2>/dev/null
