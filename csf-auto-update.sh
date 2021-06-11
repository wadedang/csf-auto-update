#/usr/bin/env bash



# ==== Settings ====
ips_link="https://www.quic.cloud/ips?ln"
csf_allow_file="/etc/csf/csf.allow"
csf_ignore_file="/etc/csf/csf.ignore"
exit_flag=0;



check_input(){
    if [ -z "${1}" ]; then
        help_message
        exit 1
    fi
}



echow(){
    FLAG=${1}
    shift
    echo -e "\033[1m${EPACE}${FLAG}\033[0m${@}"
}



check_environment(){
    if [ ! -f "$csf_allow_file" ]; then
        echo "$csf_allow_file is not exists"
        exit_flag=1;
    fi
    if [ ! -f "$csf_ignore_file" ]; then
        echo "$csf_ignore_file is not exists"
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
check_environment
while [ ! -z "${1}" ]; do
    case ${1} in
        -[hH] | -help | --help)
            help_message
            ;;
        -[uU] | -update | --update)
            echo ${1}
            ;;
        -[rR] | -restore | --restor)
            echo ${1}
            ;;          
        *) 
            help_message
            ;;
    esac
    shift
done
exit 1;