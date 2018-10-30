

WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
SUDO_PWD=$4
input_file=$5

cp -fr ${WORK_PATH}/config_files/nta_configure.sh ${INSTALL_PATH}/nta/bin/nta_configure.sh >/dev/null 2>/dev/null

${INSTALL_PATH}/nta/bin/nta_configure.sh 0< ${input_file}

