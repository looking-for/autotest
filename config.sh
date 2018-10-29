

WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3

SUDO_PWD=$4

echo "$SUDO_PWD" | sudo -S cp -fr ${WORK_PATH}/config_files/etc ${INSTALL_PATH}/nta/etc

echo "$SUDO_PWD" | sudo -S ${INSTALL_PATH}/nta/bin/nta_start.sh restart >/dev/null 2>/dev/null
