
WORK_PATH=$1
INSTALL_PATH=$2
RESULT=$3
INT=$4
SUDO_PWD=$5
JSON_CHECK=$6
FUNC=$7


start(){
echo "" >> $RESULT
echo "########## funcs test ##########" >> $RESULT


funcs=`ls ${WORK_PATH}/funcs/`
for func in $funcs
do

	if [ "$FUNC" != "" ] && [ "$FUNC" != "all" ] && [ "$FUNC" != "$func" ] ; then
		continue
	fi

	echo "" >> $RESULT
	echo "test $func: " >> $RESULT

	func_path=${WORK_PATH}/funcs/${func}

	if [ -f "${func_path}/list/index" ] ; then
		cat ${func_path}/list/index | while read kv nothing
		do
			flag=`echo $kv | cut -d '=' -f 2`
			if [ "$flag" == "" ] ; then
				continue
			else
				test_lists $func_path $flag
				if [ "$?" == "0" ] ; then
					echo "	test ok" >> $RESULT
				else
					echo "	test fail" >> $RESULT
				fi
			fi
			# only use the first line
			break
		done
	else
		test_lists $func_path 0
		if [ "$?" == "0" ] ; then
			echo "	test ok" >> $RESULT
		else
			echo "	test fail" >> $RESULT
		fi
	fi
done
}

check_all_list()
{
	func_path=$1
	list_files=`ls ${func_path}/list/ | grep list`

	bak=0
	for list_file in $list_files
	do
		echo "		-- test list ${func_path}/list/${list_file}" >> $RESULT
		test_list ${func_path} ${func_path}/list/${list_file}
		if [ "$?" != "0" ] ; then
			echo "		   fail" >> $RESULT
			bak=1
		else
			echo "		   ok" >> $RESULT
		fi
	done

	return $bak
}

test_lists()
{
	echo [$func_path] [$flag]
	func_path=$1
	flag=$2
	if [ "$flag" == "" ] ; then
		echo "	test lists $flag fail" >> $RESULT
		echo "		flag is null" >> $RESULT
		return 1
	fi

	if [ "$flag" == "0" ] ; then
		check_all_list $func_path
		if [ "$?" != "0" ] ; then
			return 1
		else
			return 0
		fi
	fi

	bak=0
	r=$(echo $flag | grep ",")
	if [ "$r" != "" ] ; then
		array=(${flag//,/ })
		for var in ${array[@]}
		do
			list_file="${func_path}/list/list_${index}"
			echo "		-- test list ${list_file}" >> $RESULT
			test_list ${func_path} ${list_file}
			if [ "$?" != "0" ] ; then
				echo "		   fail" >> $RESULT
				bak=1
			else
				echo "		   ok" >> $RESULT
			fi
		done
		return $bak
	fi

	r=$(echo $flag | grep "-")
	if [ "$r" != "" ] ; then
		start=`echo $flag | cut -d '-' -f 1`
		end=`echo $flag | cut -d '-' -f 2`
		for ((i=$start; i<=$end; i ++))
		do
			list_file="{func_path}/list/list_${index}"
			echo "		-- test list ${list_file}" >> $RESULT
			test_list ${func_path} ${list_file}
			if [ "$?" != "0" ] ; then
				echo "		   fail" >> $RESULT
				bak=1
			else
				echo "		   ok" >> $RESULT
			fi
		done
		return $bak
	fi

	list_file="${func_path}/list/list_${flag}"
	echo "		   -- test list ${list_file}" >>$RESULT
	test_list ${func_path} ${list_file}
	if [ "$?" != "0" ] ; then
		echo "		   fail" >> $RESULT
		bak=1
	else
		echo "		   ok" >> $RESULT
	fi
	
	return $bak
}

test_list()
{
		func_path=$1
		list_file=$2
		if [ ! -f "${list_file}" ] ; then
			echo "		   list file [${list_file}] is not exist" >> $RESULT
			return 1
		fi

		_test_list $func_path ${list_file}
		if [ "$?" != "0" ] ; then
			return 1
		else
			return 0
		fi
}

_test_list()
{
		func_path=$1
		list_file=$2
		#name=`cat $list_file | grep name | cut -d '=' -f 2`
		input=`cat ${list_file} | grep "input=" | cut -d '=' -f 2 | cut -d ' ' -f 1`
		config=`cat ${list_file} | grep "config=" | cut -d '=' -f 2 | cut -d ' ' -f 1`
		pcap=`cat ${list_file} | grep "pcap=" | grep -v send | cut -d '=' -f 2 | cut -d ' ' -f 1`
		pcap_send=`cat ${list_file} | grep "pcap_send=" | cut -d '=' -f 2 | cut -d ' ' -f 1`
		json=`cat ${list_file} | grep "json=" | cut -d '=' -f 2 | cut -d ' ' -f 1`
		check=`cat ${list_file} | grep "check=" | grep -v post | cut -d '=' -f 2 | cut -d ' ' -f 1`
		post_check=`cat ${list_file} | grep "post_check=" | cut -d '=' -f 2 | cut -d ' ' -f 1`
		post=`cat ${list_file} | grep "post=" | cut -d '=' -f 2 | cut -d ' ' -f 1`

		## global config
		global_config=${WORK_PATH}/config.sh
		if [ -f ${global_config} ] ; then
			echo "$SUDO_PWD" | sudo -S ${global_config} ${WORK_PATH} ${INSTALL_PATH} ${RESULT}
			sleep 30
		fi

		## input
		global_input=${WORK_PATH}/input.sh
		if [ "$input" != "" ] ; then
			input_file="${func_path}/input/${input}"
			if [ ! -f "${input_file}" ] ; then
				echo "		   input is [${input}], but input file [${input_file}] is not exist." >>$RESULT
				return 1
			fi
			echo "$SUDO_PWD" | sudo -S ${global_input} ${WORK_PATH} ${INSTALL_PATH} ${RESULT} ${input_file}
			if [ "$?" != "0" ] ; then
				echo "		   $global_input err" >> $RESULT
				return 1
			fi
			sleep 2
		fi
		## config
		if [ "$config" != "" ] ; then
			config_file="${func_path}/config/${config}"
			if [ ! -f "${config_file}" ] ; then
				echo "		   config is [${config}], but config file [${config_file}] is not exist." >>$RESULT
				return 1
			fi
			echo "$SUDO_PWD" | sudo -S ${config_file} ${WORK_PATH} ${INSTALL_PATH} ${RESULT} ${INT} ${func_path}
			if [ "$?" != "0" ] ; then
				echo "		   $config_file err" >> $RESULT
				return 1
			fi
			sleep 30
		fi
		## check
		if [ "$check" != "" ] ; then
			check_file="${func_path}/check/${check}"
			if [ ! -f "${check_file}" ] ; then
				echo "		   check is [${check}], but check file [${check_file}] is not exist." >>$RESULT
				return 1
			fi
			echo -n "		   " >> $RESULT
			echo "$SUDO_PWD" | sudo -S ${check_file}  ${WORK_PATH} ${INSTALL_PATH} ${RESULT} ${INT} ${func_path}
			if [ "$?" != "0" ] ; then
				echo "		   ${check_file} fail" >> $RESULT
				return 1
			else
				echo -n -e "\r" >> $RESULT
			fi
		fi
		## JSON_CHECK
		if [ "$pcap" != "" ] ; then
			if [ -f "$JSON_CHECK" ] ; then
				echo "$SUDO_PWD" | sudo -S ${JSON_CHECK} -f ${pcap}  ${INT} 100 ${json} 
				if [ "$?" != "0" ] ; then
					echo "		   ${JSON_CHECK} pcap file fail" >> $RESULT
					return 1
				fi
			else
				echo "		   pcap and json is not null, but json check file [${JSON_CHECK}] is not exist" >> $RESULT
				return 1
			fi
		fi

		if [ "$pcap_send" != "" ] ; then
			if [ -f "$JSON_CHECK" ] ; then
				echo "$SUDO_PWD" | sudo -S ${JSON_CHECK} -s ${pcap_send}  ${json} 
				if [ "$?" != "0" ] ; then
					echo "		   ${JSON_CHECK} send shell fail" >> $RESULT
					return 1
				fi
			else
				echo "		   pcap and json is not null, but json check file [${JSON_CHECK}] is not exist" >> $RESULT
				return 1
			fi
		fi

		## post check
		if [ "$post_check" != "" ] ; then
			post_check_file="${func_path}/post_check/${post_check}"
			if [ ! -f "${post_check_file}" ] ; then
				echo "		   post check is [${post_check}], but post check file [${post_check_file}] is not exist." >> $RESULT
				return 1
			fi
			echo -n "		   " >> $RESULT
			echo "$SUDO_PWD" | sudo -S ${post_check_file} ${WORK_PATH} ${INSTALL_PATH} ${RESULT} ${INT} ${func_path}
			if [ "$?" != "0" ] ; then
				echo "		   ${post_check_file} fail" >> $RESULT
				return 1
			else
				echo -n -e "\r" >> $RESULT
			fi
		fi
		
		## post
		if [ "$post" != "" ] ; then
			post_file="${func_path}/post/${post}"
			if [ ! -f "${post_file}" ] ; then
				echo "		   post is [${post}], but post file [${post_file}] is not exist." >>$RESULT
				return 1
			fi
			echo "$SUDO_PWD" | sudo -S ${post_file}  ${WORK_PATH} ${INSTALL_PATH} ${RESULT} ${INT} ${func_path}
			if [ "$?" != "0" ] ; then
				echo "		   ${post_file} err" >> $RESULT
				return 1
			fi
			sleep 10
		fi

		## global post
		global_post=${WORK_PATH}/post.sh
		if [ -f ${global_post} ] ; then
			echo "$SUDO_PWD" | sudo -S ${global_post} ${WORK_PATH} ${INSTALL_PATH} ${RESULT} ${SUDO_PWD}
			sleep 10
		fi
}


start
