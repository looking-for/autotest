WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
INT=$4
FUNC_PATH=$5

# cp -fr ${FUNC_PATH}/config_files/etc_1 ${INSTALL_PATH}/nta/etc
# ${INSTALL_PATH}/nta/bin/pcap_save.sh restart
cp -f ${INSTALL_PATH}/nta/etc/nta.yaml ${INSTALL_PATH}/nta/etc/nta_backup.yaml
if [ "$?" != "0" ] ; then
	echo "cannot backup nta's nta/etc/nta.yaml" >> $RESULT
	exit 1
fi

cp -f ${FUNC_PATH}/config_files/etc_1/nta.yaml ${INSTALL_PATH}/nta/etc/
if [ "$?" != "0" ] ; then
	echo "cannot cp config_files/etc_1/nta.yaml to nta/etc" >> $RESULT
	exit 1
fi

${INSTALL_PATH}/nta/bin/nta_start.sh restart
if [ "$?" != "0" ] ; then
	echo "cannot restart nta" >> $RESULT
	exit 1
fi

exit 0