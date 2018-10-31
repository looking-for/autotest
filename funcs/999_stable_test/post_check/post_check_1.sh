WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
INT=$4
FUNC_PATH=$5

# ###########################################
# check nta
# ###########################################
# check nta and record pid
pid=`pgrep nta`
if [ "$pid" == "" ] ; then
	echo "post got nta pid fail" >> $RESULT
	exit 1
else
	pidinfile=`cat ${FUNC_PATH}/tmp/tmp_nta.info`
	if [ "$pid" != "$pidinfile" ] ; then
		echo "post check nta pid is different." >> $RESULT
		exit 1
	fi
fi

flag="pidstat -t -p `pgrep nta` | grep Hansight-nta-Ma"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread Hansight-nta-Ma fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep W#01"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread W#01 fail" >> $RESULT
	exit 1
fi

flag="pidstat -t -p `pgrep nta` | grep W#02"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread W#02 fail" >> $RESULT
	exit 1
fi

flag="pidstat -t -p `pgrep nta` | grep W#03"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread W#03 fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep W#04"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread W#0 fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep W#05"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread W#05 fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep W#06"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread W#06 fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep W#07"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread W#07 fail" >> $RESULT
	exit 1
fi

flag="pidstat -t -p `pgrep nta` | grep W#08"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread W#08 fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep FM"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread FM fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep FR"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread FR fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep CW"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread CW fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep CS"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread CS fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep US_web"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread US_web fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep US| grep -v web"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got thread US fail" >> $RESULT
	exit 1
fi

# ###########################################
# check pcap_save
# ###########################################
# check pcap_save and record it pid
pid=`pgrep pcap_save_file`
if [ "$pid" == "" ] ; then
	echo "post got pcap_save_file pid fail" >> $RESULT
	exit 1
else
	pidinfile=`cat ${FUNC_PATH}/tmp/tmp_pcap.info`
	if [ "$pidinfile" != "$pid" ] ; then
		echo "pcap_save_file restarted when send many pcap files" >> $RESULT
		exit 1
	fi
fi
flag="pidstat -t -p `pgrep pcap_save_file` | grep '|' | sed 's/[ ][ ]*/,/g' |grep pcap_save_file|cut -d ',' -f 4"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got pcap_save_file thread pcap_delete fail" >> $RESULT
	exit 1
else
	newtid=`cat ${FUNC_PATH}/tmp/tmp_pcap_pcap_save_file.info`
	if [ "$newtid" != "$flag" ] ; then
		echo "post check pcap_save_file main thread id is different." >>$RESULT
		exit 1
	fi
fi
flag="pidstat -t -p `pgrep pcap_save_file` | grep '|' | sed 's/[ ][ ]*/,/g' |grep log4rs |cut -d ',' -f 4"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got pcap_save_file thread log4rs fail" >> $RESULT
	exit 1
else
	newtid=`cat ${FUNC_PATH}/tmp/tmp_pcap_log4rs.info`
	if [ "$newtid" != "$flag" ] ; then
		echo "post check pcap_save_file log4rs thread id is different." >>$RESULT
		exit 1
	fi
fi

flag="pidstat -t -p `pgrep pcap_save_file` | grep '|' | sed 's/[ ][ ]*/,/g' |grep pcap_storage |cut -d ',' -f 4"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got pcap_save_file thread pcap_storage fail" >> $RESULT
	exit 1
else
	newtid=`cat ${FUNC_PATH}/tmp/tmp_pcap_storage.info`
	if [ "$newtid" != "$flag" ] ; then
		echo "post check pcap_save_file pcap_storage thread id is different." >>$RESULT
		exit 1
	fi
fi
flag="pidstat -t -p `pgrep pcap_save_file` | grep '|' | sed 's/[ ][ ]*/,/g' |grep pcap_capture |cut -d ',' -f 4"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got pcap_save_file thread pcap_capture fail" >> $RESULT
	exit 1
else
	newtid=`cat ${FUNC_PATH}/tmp/tmp_pcap_capture.info`
	if [ "$newtid" != "$flag" ] ; then
		echo "post check pcap_save_file pcap_capture thread id is different." >>$RESULT
		exit 1
	fi
fi
flag="pidstat -t -p `pgrep pcap_save_file` | grep '|' | sed 's/[ ][ ]*/,/g' |grep pcap_delete |cut -d ',' -f 4"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "post got pcap_save_file thread pcap_delete fail" >> $RESULT
	exit 1
else
	newtid=`cat ${FUNC_PATH}/tmp/tmp_pcap_delete.info`
	if [ "$newtid" != "$flag" ] ; then
		echo "post check pcap_save_file pcap_delete thread id is different." >>$RESULT
		exit 1
	fi
fi
# ##########################################
# check pop3
# ##########################################
pid=`pgrep pop3_parser`
if [ "$pid" == "" ] ; then
	echo "post got pop3_parser pid fail" >> $RESULT
	exit 1
else
	newtid=`cat ${FUNC_PATH}/tmp/tmp_pop3_parser.info`
	if [ "$newtid" != "$flag" ] ; then
		echo "post check pop3_parser pid is different." >>$RESULT
		exit 1
	fi
fi


exit 0

