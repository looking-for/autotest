WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
INT=$4
FUNC_PATH=$5

exit 0

log_dir=$(cat ${FUNC_PATH}/input/input | sed -n  '8p')
if [ "$log_dir" == "" ] ; then
	echo "got stats.log location fail" >> $RESULT
	exit 1
fi

flag=$(cat ${log_dir}/stats.log |grep app_layer.flow.pop3 |sed -n '$p'|awk '{printf $5}')
if [ "$flag" == "" ] ; then
	echo "pop3_parser err:app_layer.flow.pop3 is null" >> $RESULT
	exit 1
fi

flag=$(cat ${log_dir}/stats.log |grep ntamng.group.pop3.sendtimes |sed -n '$p'|awk '{printf $5}')
if [ "$flag" == "" ] ; then
	echo "pop3_parser err:ntamng.group.pop3.sendtimes is null" >> $RESULT
	exit 1
fi

flag=$(cat ${log_dir}/stats.log |grep ntamng.group.pop3.sendfails |sed -n '$p'|awk '{printf $5}')
if [ "$flag" != "" ] ; then
	echo "pop3_parser err:ntamng.group.pop3.sendfails have value" >> $RESULT
	exit 1
fi

flag=$(cat ${log_dir}/stats.log |grep pop3mng.Pop3Statis.output_cnt |sed -n '$p'|awk '{printf $5}')
if [ "$flag" == "" ] ; then
	echo "pop3_parser err:pop3mng.Pop3Statis.output_cnt is null" >> $RESULT
	exit 1
fi

flag=$(cat ${log_dir}/stats.log |grep pop3mng.Pop3Statis.output_fail |sed -n '$p'|awk '{printf $5}')
if [ "$flag" != "" ] ; then
	echo "pop3_parser err:pop3mng.Pop3Statis.output_fail have value" >> $RESULT
	exit 1
fi

exit 0

