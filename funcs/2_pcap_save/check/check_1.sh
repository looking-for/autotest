WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
INT=$4
FUNC_PATH=$5

pid=`pgrep pcap_save_file`
if [ "$pid" == "" ] ; then
	echo "got pid fail" >> $RESULT
	exit 1
fi

flag="pidstat -t -p `pgrep pcap_save_file` | grep pcap_capture"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread pcap_capture fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep pcap_save_file` | grep pcap_storage"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread pcap_storage fail" >> $RESULT
	exit 1
fi

flag="pidstat -t -p `pgrep pcap_save_file` | grep pcap_delete"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread pcap_delete fail" >> $RESULT
	exit 1
fi

flag="pidstat -t -p `pgrep pcap_save_file` | grep pcap_save_file"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread pcap_save_file fail" >> $RESULT
	exit 1
fi

flag="pidstat -t -p `pgrep pcap_save_file` | grep log4rs"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread log4rs fail" >> $RESULT
	exit 1
fi
exit 0

