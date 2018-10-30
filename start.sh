

help(){
	echo "$0 pwd interface [all/funcs]"
	echo "	- pwd: sudo password"
	echo "	- interface: the interface which send the pcap files"
	echo "	- funcs: the one in ./funcs/"
}


start()
{
	if [ $# -lt 2 ] || [ $# -gt 3 ]  ; then
		help
		exit 1
	fi

	mkdir -p /tmp/nta >/dev/null 2>/dev/null

	WORK_PATH="$PWD"
	INSTALL_PATH=/opt/hansight
	RESULT_DIR=${WORK_PATH}/result
	SUDO_PWD=$1
	INT=$2
	FUNC=$3
	JSON_CHECK=${WORK_PATH}/rust/check/target/debug/check

	echo ##################################################################
	echo ${WORK_PATH}/rebuild_nta.sh ${WORK_PATH} ${INSTALL_PATH} ${RESULT_DIR} ${INT} ${SUDO_PWD} ${JSON_CHECK} ${FUNC}
	echo ##################################################################
	${WORK_PATH}/rebuild_nta.sh ${WORK_PATH} ${INSTALL_PATH} ${RESULT_DIR} ${INT} ${SUDO_PWD} ${JSON_CHECK} ${FUNC}
}



start $*
