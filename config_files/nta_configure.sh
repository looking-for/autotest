#!/bin/bash

APP_DIR=/opt/hansight/nta
ITERFACE_SH=${APP_DIR}/bin/.nta_configure.sh
CONFIG_FILE=${APP_DIR}/etc/nta/nta.yaml
CONFIG_NIC_FILE=${APP_DIR}/bin/nta_nic.sh
# APP_WEB_PACKAGE=nta_web.tar.gz
APP_WEB_DIR=${APP_DIR}/web
WEB_INIT=${APP_WEB_DIR}/sync.sh
APP_WEB_CONF=${APP_WEB_DIR}/config.yml
PCAP_CONFIG_FILE=${APP_DIR}/etc/pcap_save

wNIC=""
ENT_IP=""
ES_HOST=""
TMP_DIR=""
IS_YES=y
ASK_WHILE=1
SLEEP_TIME=2

chg_rust_logdir()
{
      ORACLELOGFILE=${APP_DIR}/etc/oracle_parser/log4rs.yml
      sed -e "s|path:.*\/|path: \"$1/|g" -i ${ORACLELOGFILE}
      sed "/roller/{N;N;s|pattern.*/|pattern: \'$1/|g;}" -i ${ORACLELOGFILE}
      POP3LOGFILE=${APP_DIR}/etc/pop3_parser/log4rs.yml
      sed -e "s|path:.*\/|path: \"$1/|g" -i ${POP3LOGFILE}
      sed "/roller/{N;N;s|pattern.*/|pattern: \'$1/|g;}" -i ${POP3LOGFILE}
      PCAPLOGFILE=${APP_DIR}/etc/pcap_save/log4rs.yml
      sed -e "s|path:.*\/|path: \"$1/|g" -i ${PCAPLOGFILE}
      sed "/roller/{N;N;s|pattern.*/|pattern: \'$1/|g;}" -i ${PCAPLOGFILE}
   
}

function traffic_monitor {
  NICs=$(ip addr | awk -v FS=": " '/BROADCAST/{print $2}')
  speedest=0
  
  local -A netmap
  for nic in ${NICs}; do
  	#statements
  	ip link set ${nic} promisc on
  	RXpre=$(grep "${nic}:"  /proc/net/dev | tr : " " | awk '{print $2}')
  	# 判断获取值若为空,则网口不存在
    if [[ $RXpre == "" ]]; then
      echo "Error parameter,please input the right port after run the script!"
      exit 0
    fi
    netmap[${nic}]=${RXpre}
  done

  sleep ${SLEEP_TIME}
  echo -e "Date:  `date +%F`"
  echo -e "Time:  `date +%k:%M:%S`"
  echo -e  "network interface \t    RX"
  echo "------------------------------"
  for nic in ${NICs}; do
  	#statements
  	RXnext=$(grep "${nic}:"  /proc/net/dev | tr : " " | awk '{print $2}')
  	RX=$(( (${RXnext}-${netmap[${nic}]})/${SLEEP_TIME} ))
  	# 判断接收流量如果大于MB数量级则显示MB单位,否则显示KB数量级
    if [[ $RX -lt 1024 ]];then
      RX="${RX}B/s"
    elif [[ $RX -gt 1048576 ]];then
      if [[ $RX -gt ${speedest} ]]; then
        #statements
        speedest=$RX
        wNIC=$nic
        echo ${wNIC}
      fi
      RX=$(echo $RX | awk '{print $1/1048576 "MB/s"}')
    else
      RX=$(echo $RX | awk '{print $1/1024 "KB/s"}')
    fi
    ip link set ${nic} promisc off
    echo -e "${nic} \t :  ${RX}"
  done
  echo "------------------------------"
}

mkdir -p /var/log/nta
# traffic_monitor
# read -p "Input Mirrored NIC name :" wNIC

if [[ -n ${wNIC} ]]; then
  #statements
  echo "============================================"
  echo "| Choosing the NIC with the maximal input bandwidth as the NIC for port mirroring, which is:"
  echo -e "|                        \033[31m${wNIC}\033[0m"
  echo "|"
  echo "| If it's not the right NIC, please modify the following configuration item:"
  echo "| /opt/hansight/nta/etc/nta/nta.yaml "
  echo -e "|  af-packet: \n\t interface: ****** "
  echo "============================================"
else
  echo "============================================"
  echo "| If it's not the right NIC, please modify"
  echo "|    the following configuration item:"
  echo "| Maybe port mirroring has not been configured correctly? "
  echo "|    Please modify the following configuration "
  echo "|    item and make sure port mirroring is configured correctly."
  echo "| /opt/hansight/nta/etc/nta/nta.yaml"
  echo -e "|  af-packet: \n\t interface: ******"
  echo "============================================"
  read -p "If  Input Mirrored NIC name :" wNIC

fi
# --------------------------------- do with net work --------------------------
ASK_WHILE=1
echo "Mirrored NIC name is : "  ${wNIC}
read -p "Is it the right NIC [y/N]y: " IS_YES
if [[ -z ${IS_YES} ]]; then
	#statements
	IS_YES=y
fi
while [[ ${ASK_WHILE} != 0 ]]; do
	#statements
	case ${IS_YES} in
		[yY] )
            ASK_WHILE=0
			;;
        [nN] )
            read -p "Input Mirrored NIC name :" wNIC
            echo "Mirrored NIC name is : "  ${wNIC}
            read -p "Is it the right NIC [y/N]y: " IS_YES
            ;;
        *   )                # 其他参数就输出脚本正确用法 
            ;;
	esac
	if [[ -n $wNic ]]; then
		#statements
        read -p "Input Mirrored NIC name :" wNIC
        echo "Mirrored NIC name is : "  ${wNIC}
        read -p "Is it the right NIC [y/N]y: " IS_YES
	fi
done

sed -i "s/\(- interface:\).*/\1 ${wNIC}/" ${CONFIG_FILE}
ETHTOOL=`which ethtool`
echo " ${ETHTOOL} -L ${wNIC} combined 1 " > ${CONFIG_NIC_FILE}
chmod +x ${CONFIG_NIC_FILE}
# --------------------------- pcap_save_file config save ------------------------------
echo "[necessary]" > ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "dev_name=${wNIC}" >> ${PCAP_CONFIG_FILE}/pcap_save.ini

# --------------------------  do with enterprise ip ------------------------------------
ASK_WHILE=1
while [[ ${ASK_WHILE} != 0 ]]; do
	#statements
    read -p "Input enterpriser IP: " ENT_IP
    echo "Enterpriser IP is : " ${ENT_IP}
    read -p "Is it the right Enterpriser IP [y/N]y :  " IS_YES
    if [[ -z ${IS_YES} ]]; then
    	#statements
    	IS_YES=y
    fi
	case ${IS_YES} in
		[yY] )
         ASK_WHILE=0
			;;
		  *)                # 其他参数就输出脚本正确用法 
           ;;
	esac
done

if [[ -n ${ENT_IP} ]]; then
	#statements
	if [[ ${ENT_IP} != "127.0.0.1" ]]; then
		#statements
		sed "s#\(server.host:\).*#\1 0.0.0.0#" -i ${APP_WEB_CONF}
		sed "s#\(enterprise.host:\).*#\1 ${ENT_IP}#" -i ${APP_WEB_CONF}
		sed "s#\(filename: \).*\(:9293\)#\1${ENT_IP}\2#"  -i ${CONFIG_FILE}
	fi
fi
echo ""

# ------------------------- do with elasticsearch host --------------------
ASK_WHILE=1
while [[ ${ASK_WHILE} != 0 ]]; do
	#statements
    read -p "Input elasticsearch host 'IP:port' : " ES_HOST
    echo "Elasticsearch host is : " ${ES_HOST}
    read -p "Is it the right Elasticsearch host [y/N]y :  " IS_YES
    if [[ -z ${IS_YES} ]]; then
    	#statements
    	IS_YES=y
    fi
    if [[ ${ES_HOST} != "127.0.0.1:9200" ]]; then
    	#statements
    	sed "/- *127.0.0.1:9200.*/d" -i ${APP_WEB_CONF}
    	case ${IS_YES} in
	    	[yY] )
             sed "/elastic.hosts:/a \  - ${ES_HOST}" -i ${APP_WEB_CONF}
	    		;;
	    	  *)                # 其他参数就输出脚本正确用法 
                ;;
	    esac
    fi
	

	read -p "Do you want to add Elasticsearch host [y/N]N:  " IS_ADD
	if [[ -z ${IS_ADD} ]]; then
    	#statements
    	IS_ADD=N
    fi
    case ${IS_ADD} in
    	[yY] )
    	    ;;
         * )
          ASK_WHILE=0
		    ;;
    esac
done

# -------------------------- do with middle file store ------------------------
ASK_WHILE=1
while [[ ${ASK_WHILE} != 0 ]]; do
	#statements
    read -p "Input NTA store dirctory: " TMP_DIR
    echo "NTA store dirctory is : " ${TMP_DIR}
    read -p "Is it the right  NTA store dirctory [y/N]y :  " IS_YES
    if [[ -z ${IS_YES} ]]; then
    	#statements
    	IS_YES=y
    fi
	case ${IS_YES} in
		[yY] )
         ASK_WHILE=0
			;;
		  *)                # 其他参数就输出脚本正确用法 
           ;;
	esac
	if [[ ! -n ${TMP_DIR} ]]; then
		echo "NTA store dirctory needed necessary!"
		ASK_WHILE=1
	fi
done

if [[ -n ${TMP_DIR} ]]; then
	#statements
	sed "s#dir: /tmp/nta#dir: ${TMP_DIR}#" -i ${CONFIG_FILE}
	chg_rust_logdir ${TMP_DIR}
    mkdir -p ${TMP_DIR}
fi
echo ""

# ---------------------------config pcap_save_file------------------------------
echo "dir_name=${TMP_DIR}/pcapsavefile/pcap" >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "[default]" >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "pcap_file_prefix_name=log" >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "snap_shot_len=65535" >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "; pcap_size as byte, default value is 1024*1024*1024" >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "pcap_size=1073741824" >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "storage_file_num=1024" >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "; max cache packets number for storage." >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "packet_caches=300000" >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "; cpu affinity set" >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "cpu_affinity_capture=-1" >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "cpu_affinity_storage=-1" >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "cpu_affinity_delete=-1" >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "cpu_affinity_manage=-1" >> ${PCAP_CONFIG_FILE}/pcap_save.ini
echo "log_file_name=${PCAP_CONFIG_FILE}/log4rs.yml" >> ${PCAP_CONFIG_FILE}/pcap_save.ini


# -------------------------- config run web ----------------------------------
cd ${APP_WEB_DIR}
. ${WEB_INIT}
cd -
