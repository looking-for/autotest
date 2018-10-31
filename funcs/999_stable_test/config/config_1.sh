WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
INT=$4
FUNC_PATH=$5

cp -fr ${FUNC_PATH}/config_files/pcap_save.ini ${INSTALL_PATH}/nta/etc/pcap_save/pcap_save.ini
# ${INSTALL_PATH}/nta/bin/nta_start.sh restart
${INSTALL_PATH}/nta/bin/pcap_save.sh restart >/dev/null 2>/dev/null
