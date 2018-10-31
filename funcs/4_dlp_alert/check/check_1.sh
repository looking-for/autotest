WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
INT=$4
FUNC_PATH=$5

#######################nta status test######################
pid=`pgrep nta`
if [ "$pid" == "" ] ; then
	echo "got nta pid fail" >> $RESULT
	exit 1
fi

flag="pidstat -t -p `pgrep nta` | grep Hansight-nta-Ma"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread Hansight-nta-Ma fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep W#01"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread W#01 fail" >> $RESULT
	exit 1
fi

flag="pidstat -t -p `pgrep nta` | grep W#02"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread W#02 fail" >> $RESULT
	exit 1
fi

flag="pidstat -t -p `pgrep nta` | grep W#03"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread W#03 fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep W#04"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread W#0 fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep W#05"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread W#05 fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep W#06"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread W#06 fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep W#07"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread W#07 fail" >> $RESULT
	exit 1
fi

flag="pidstat -t -p `pgrep nta` | grep W#08"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread W#08 fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep FM"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread FM fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep FR"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread FR fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep CW"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread CW fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep CS"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread CS fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep US_web"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread US_web fail" >> $RESULT
	exit 1
fi
flag="pidstat -t -p `pgrep nta` | grep US| grep -v web"
flag=`eval $flag`
if [ "$flag" == "" ] ; then
	echo "got thread US fail" >> $RESULT
	exit 1
fi


exit 0

