

WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
INT=$4
SUDO_PWD=$5
JSON_CHECK=$6
FUNC=$7

RPM_DIR=${WORK_PATH}/nta_src/janus/build/package

if [ ! -f ${RPM_DIR}/*.tar.gz ] ; then
	echo "build nta fail" >> $RESULT
	exit 1
fi

echo "#################### reinstall nta..." >>$RESULT

cd ${RPM_DIR} >/dev/null 2>/dev/null
if [ "$?" != "0" ] ; then
	echo "cd ${RPM_DIR} fail" >> $RESULT
	exit 1
fi

tar -xvzf *.tar.gz >/dev/null 2>/dev/null
cd nta >/dev/null 2>/dev/null
if [ "$?" != "0" ] ; then
	echo "cd nta fail, maybe tar err" >>$RESULT
	exit 1
fi

./nta_uninstall.sh >/dev/null 2>/dev/null
./nta_install.sh >/dev/null 2>/dev/null


#echo "$SUDO_PWD" | sudo -S ${INSTALL_PATH}/nta/bin/nta_start.sh stop >/dev/null 2>/dev/null
#echo "$SUDO_PWD" | sudo -S ${INSTALL_PATH}/nta/bin/pcap_save.sh stop >/dev/null 2>/dev/null
#echo "$SUDO_PWD" | sudo -S rpm -e nta >/dev/null 2>/dev/null
#echo "$SUDO_PWD" | sudo -S rm -fr ${INSTALL_PATH} >/dev/null 2>/dev/null
#echo "$SUDO_PWD" | sudo -S rpm -i ${RPM_DIR}/nta*.rpm >/dev/null 2>/dev/null

WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
INT=$4
SUDO_PWD=$5
JSON_CHECK=$6

echo ${WORK_PATH}/func_test.sh ${WORK_PATH} ${INSTALL_PATH} ${RESULT} ${INT} ${SUDO_PWD} ${JSON_CHECK} ${FUNC}
${WORK_PATH}/func_test.sh ${WORK_PATH} ${INSTALL_PATH} ${RESULT} ${INT} ${SUDO_PWD} ${JSON_CHECK} ${FUNC}

