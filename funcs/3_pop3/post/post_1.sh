

WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
SUDO_PWD=$4

#sudo ./post_1.sh /home/chenquanqing/fork_auto_test/autotest /opt/hansight ./1.log renminbi /home/chenquanqing/fork_auto_test/autotest/funcs/4_dlp_alert

if [ ! -f "${INSTALL_PATH}/nta/etc/nta_backup.yaml" ] ; then
    echo "${INSTALL_PATH}/nta/etc/nta_backup.yaml is not exist." >>$RESULT
    exit 1
fi
mv ${INSTALL_PATH}/nta/etc/nta_backup.yaml ${INSTALL_PATH}/nta/etc/nta.yaml
if [ "$?" != "0" ] ; then
	echo "cannot restore nta's nta/etc/nta.yaml" >> $RESULT
	exit 1
fi

exit 0