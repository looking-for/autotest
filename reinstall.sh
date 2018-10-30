

WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
INT=$4
SUDO_PWD=$5
JSON_CHECK=$6
FUNC=$7

RPM_DIR=${WORK_PATH}/nta_src/janus/build/package

if [ ! -f ${RPM_DIR}/nta*.rpm ] ; then
	echo "build nta fail" >> $RESULT
	exit 1
fi

echo "$SUDO_PWD" | sudo -S ${INSTALL_PATH}/nta/bin/nta_start.sh stop >/dev/null 2>/dev/null
echo "$SUDO_PWD" | sudo -S ${INSTALL_PATH}/nta/bin/pcap_save.sh stop >/dev/null 2>/dev/null
echo "$SUDO_PWD" | sudo -S rpm -e nta >/dev/null 2>/dev/null
echo "$SUDO_PWD" | sudo -S rm -fr ${INSTALL_PATH} >/dev/null 2>/dev/null
echo "$SUDO_PWD" | sudo -S rpm -i ${RPM_DIR}/nta*.rpm >/dev/null 2>/dev/null

WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
INT=$4
SUDO_PWD=$5
JSON_CHECK=$6

echo ##################################################################
echo ${WORK_PATH}/func_test.sh ${WORK_PATH} ${INSTALL_PATH} ${RESULT} ${INT} ${SUDO_PWD} ${JSON_CHECK} ${FUNC}
echo ##################################################################
${WORK_PATH}/func_test.sh ${WORK_PATH} ${INSTALL_PATH} ${RESULT} ${INT} ${SUDO_PWD} ${JSON_CHECK} ${FUNC}

