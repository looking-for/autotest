
WORK_PATH=$1
INSTALL_PATH=$2
RESULT_DIR=$3
INT=$4
SUDO_PWD=$5
JSON_CHECK=$6
FUNC=$7

mkdir -p ${RESULT_DIR} >/dev/null
mkdir -p ${WORK_PATH}/nta_src >/dev/null
cd ${WORK_PATH}/nta_src
if [ "$?" != "0" ] ; then
	echo "cd ${WORK_PATH}/nta_src fail, exit the auto test."
	exit 1
fi

git clone https://github.com/HanSight-Dev/janus.git >/dev/null 2>/dev/null 
cd ${WORK_PATH}/nta_src/janus
if [ "$?" != "0" ] ; then
	echo "cd ${WORK_PATH}/nta_src/janus fail, exit the auto test."
	exit 1
fi

git checkout 4.0.5-merge -f >/dev/null 2>/dev/null
git pull >/dev/null 2>/dev/null
GIT_COMMIT_VERSION=`git show | grep commit | cut -d ' ' -f 2`
GIT_REMOTE=`git remote -v| grep fetch | cut -d ' ' -f 1`
GIT_BRANCH=`git branch| grep "*"`

file_flag=`ls ${RESULT_DIR}/ | grep ${GIT_COMMIT_VERSION}`
if [ "$file_flag" != "" ] ; then
	echo "this git version has already tested. ignore it."
	exit 0
fi

date1=`date +%F`
date2=`date +%T`
date="${date1}_${date2}"
RESULT="${RESULT_DIR}/${date}_${GIT_COMMIT_VERSION}"
touch $RESULT

echo "" >> $RESULT
echo "########################################" >> $RESULT
echo "nta auto test" >> $RESULT
echo "	git remote: ${GIT_REMOTE}" >> $RESULT
echo "	git branch: ${GIT_BRANCH}" >> $RESULT
echo "	git commit version: ${GIT_COMMIT_VERSION}" >> $RESULT
echo "########################################" >> $RESULT
echo "" >> $RESULT

echo "#################### rebuild nta..." >>$RESULT
rm -fr build && ./build.sh >/dev/null 2>/dev/null

cd ${WORK_PATH}/rust/check >/dev/null
if [ "$?" != "0" ] ; then
	echo "cannot cd rust/check for rebuild rust" >> $RESULT
	exit 1
fi

echo "#################### rebuild rust..." >>$RESULT
rm -fr ./target >/dev/null 2>/dev/null
cargo build >/dev/null 2>/dev/null
if [ "$?" != "0" ] ; then
	echo "cargo build rust fail" >> $RESULT
	exit 1
fi

echo ${WORK_PATH}/reinstall.sh ${WORK_PATH} ${INSTALL_PATH} ${RESULT} ${INT} ${SUDO_PWD} ${JSON_CHECK} ${FUNC} 
echo "${SUDO_PWD}" | sudo -S ${WORK_PATH}/reinstall.sh ${WORK_PATH} ${INSTALL_PATH} ${RESULT} ${INT} ${SUDO_PWD} ${JSON_CHECK} ${FUNC} 
