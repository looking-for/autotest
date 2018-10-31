WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
INT=$4
FUNC_PATH=$5

#sudo ./config_1.sh /home/chenquanqing/fork_auto_test/autotest /opt/hansight ./1.log renminbi /home/chenquanqing/fork_auto_test/autotest/funcs/4_dlp_alert
cp -f ${INSTALL_PATH}/nta/etc/nta/rules/hansight-dlp.rules ${INSTALL_PATH}/nta/etc/nta/rules/hansight-dlp_backup.rules
if [ "$?" != "0" ] ; then
	echo "cannot backup nta's /nta/etc/nta/rules/hansight-dlp.rules" >> $RESULT
	exit 1
fi

cp -f ${FUNC_PATH}/config_files/etc_1/hansight-dlp.rules ${INSTALL_PATH}/nta/etc/nta/rules/hansight-dlp.rules
if [ "$?" != "0" ] ; then
	echo "cannot cp config_files/etc_1/hansight-dlp.rules to nta/etc/nta/rules/hansight-dlp.rules" >> $RESULT
	exit 1
fi

${INSTALL_PATH}/nta/bin/nta_start.sh restart
if [ "$?" != "0" ] ; then
	echo "cannot restart nta" >> $RESULT
	exit 1
fi

exit 0