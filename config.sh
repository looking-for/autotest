

WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
SUDO_PWD=$4

APP_DIR=${INSTALL_PATH}/nta

setup_libpcap()
{
    LIBPCAPDIR=${APP_DIR}/package/libpcap
	LPEXSIST=`rpm -qa libpcap`
	if [ -z "$LPEXSIST" ];then
		rpm -Uvh ${LIBPCAPDIR}/libpcap-1.5.3-11.el7.x86_64.rpm
	else
		echo "libpcap : "$LPEXSIST" has been installed"
	fi


}


setup_supervisor()
{
	    SUPERVISORDIR=${APP_DIR}/package/supervisor
		supervisorctl version > /dev/null 2>&1
		SVCEXSIST=$?
		if [ ${SVCEXSIST} -eq 0 ]; then
			CURSV=`supervisorctl version`
			echo supervisor version:${CURSV} has been installed
			if [ ${CURSV} != "3.1.4" ]; then
				echo "warning: supervisor's version is not expected. we need 3.1.4 "
				exit
			fi
		else
			rpm -Uvh ${SUPERVISORDIR}/python-backports-1.0-8.el7.x86_64.rpm
			rpm -Uvh ${SUPERVISORDIR}/python-backports-ssl_match_hostname-3.4.0.2-4.el7.noarch.rpm
			rpm -Uvh ${SUPERVISORDIR}/python-meld3-0.6.10-1.el7.x86_64.rpm
			rpm -Uvh ${SUPERVISORDIR}/python-setuptools-0.9.8-7.el7.noarch.rpm
		    rpm -Uvh ${SUPERVISORDIR}/supervisor-3.1.4-1.el7.noarch.rpm
		    cp ${SUPERVISORDIR}/supervisor.service /lib/systemd/system/
		    systemctl enable supervisor.service
		    systemctl daemon-reload
		    service supervisor start
		    cp ${SUPERVISORDIR}/*.ini /etc/supervisord.d/ -f
		fi

}

etup_libpcap
setup_supervisor

echo "$SUDO_PWD" | sudo -S cp -fr ${WORK_PATH}/config_files/etc ${INSTALL_PATH}/nta/etc

echo "$SUDO_PWD" | sudo -S ${INSTALL_PATH}/nta/bin/nta_start.sh restart >/dev/null 2>/dev/null
