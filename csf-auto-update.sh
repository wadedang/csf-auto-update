#/usr/bin/env bash



# ==== Settings ====
ips_link="https://www.quic.cloud/ips?ln"
csf_allow_file="/etc/csf/csf.allow"
csf_ignore_file="/etc/csf/csf.ignore"
csf_ignore_bak_file="/etc/csf/csf.ignore.bak"
exit_flag=0;



check_input(){
    if [ -z "${1}" ]; then
        help_message
        exit 1
    fi
}



check_update_environment(){
    if [ ! -f "$csf_allow_file" ]; then
        echo "$csf_allow_file is not exists"
        exit_flag=1;
    fi
    if [ ! -f "$csf_ignore_file" ]; then
        echo "$csf_ignore_file is not exists"
        exit_flag=1;
    fi
    if [ ${1} = "-r" ] && [ ! -f "$csf_ignore_bak_file" ] ; then
        echo "$csf_ignore_bak_file is not exists"
        exit_flag=1;
    fi

    if [ "$EUID" -ne 0 ]; then 
        echo "You are not root"
        exit_flag=1;
    fi

    if [ $exit_flag = "0" ]; then
        echo "[Success] Environment checked!!"
    else
        echo "[ERROR] Failed Verificaion!!"
        exit 1;
    fi
}



echow(){
    FLAG=${1}
    shift
    echo -e "\033[1m${EPACE}${FLAG}\033[0m${@}"
}


help_message(){
    echo -e "\033[1mOPTIONS\033[0m"
    echow '-u, --update'
    echo "${EPACE}${EPACE}Backup csf.allow and csf.ignore to csf.allow.bak and csf.ignore.bak" 
    echo "${EPACE}${EPACE}Update quic.cloud/ips whitelist to csf.allow and csf.ignore list"
    echow '-r, --restore'
    echo "${EPACE}${EPACE}Restre csf.allow and csf.ignore from csf.allow.bak and csf.ignore.bak"
    echow '-h, --help'
    echo "${EPACE}${EPACE}Display help."
}



resotre_csf_setting(){
    while read line;
    do
    csf -ar $line
    done < <(curl -s $ips_link)
    cp /etc/csf/csf.ignore.bak /etc/csf/csf.ignore
}



update_csf_setting(){
    while read line; 
    do 
        csf -a $line \# quic.cloud whitelist;
    done < <(curl -s $ips_link)
    echo "[Success] Updated CSF csf.allow"
    
    cp /etc/csf/csf.ignore /etc/csf/csf.ignore.bak
    curl "https://www.quic.cloud/ips?ln" >> /etc/csf/csf.ignore
    echo "[Success] Updated CSF csf.ignore"

    csf -ra
}



check_input ${1}
if [ ! -z "${1}" ]; then
    case ${1} in
        -[hH] | -help | --help)
            help_message
            ;;
        -[uU] | -update | --update)
            check_update_environment "-u"
            update_csf_setting
            ;;
        -[rR] | -restore | --restor)
            check_update_environment "-r"
            resotre_csf_setting
            ;;          
        *) 
            help_message
           ;;
    esac
fi