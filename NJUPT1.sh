#!/bin/sh

#     _   _             _______  _
#    |  \| | _   _   ___  | |    _   __ _  _ __
#    | . ` || | | | / _ \ | |   | | / _` || '_ \
#    |_| \_| \__,_| \___/ |_|   |_| \__,_||_| |_|
#
#    Author: NuoTian (https://github.com/s235784)
#    Repository: https://github.com/s235784/NJUPT_AutoLogin
#    Version: 1.1.1

# Script usage format: bash NJUPT-AutoLogin.sh -e eth0.2 -i ctcc -l B21012250 12345678

# Network interface changed to 'wan'
eth="wan"

# ISP: njupt for campus network, ctcc for China Telecom, cmcc for China Mobile
isp="njupt"

# Restrict login to specified times
limit="false"

# Xianlin campus settings
wlanacip="10.255.252.150"
wlanacname="XL-BRAS-SR8806-X"

# Ignore errors regarding unplugged Ethernet cables
ignore_disconnet="false"

help() {
    echo "Login command:"
    echo "NJUPT-AutoLogin.sh [-e eth] [-i isp] [-l] [-s] [-d] username password"
    echo "Logout command:"
    echo "NJUPT-AutoLogin.sh [-e eth] [-s] -o"
    echo "Parameter description:"
    echo "eth, Ethernet port of the router"
    echo "isp, ISP: njupt for campus, ctcc for Telecom, cmcc for Mobile"
    echo "l, attempt automatic login only within specified times"
    echo "s, required for Sanpailou campus"
    echo "d, ignore errors about unplugged Ethernet cables"
    echo "username, account username"
    echo "password, account password"
    exit 0
}

logout() {
    ip=$(ifconfig "${eth}" | grep inet | awk '{print $2}' | tr -d "addr:")
    if [ ! "$ip" ]
    then
        printf "Failed to obtain IP address.\n"
        exit 0
    else
        printf "Current device IP address: ${ip}\n"
    fi
    result=$(curl -k --request GET "https://10.10.244.11:802/eportal/portal/logout?callback=dr1003&login_method=1&user_account=drcom&user_password=123&wlan_user_ip=${ip}&wlan_user_ipv6=&wlan_vlan_id=0&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=" \
    --connect-timeout 5 \
    --interface ${eth})
    printf "\n"
    if [[ $result =~ "成功" ]]
    then
        printf "Successfully logged out of the campus network.\n"
    else
        printf "API request error: ${result}\nPlease report this issue on GitHub if it persists.\n"
    fi
    exit 0
}

while getopts 'e:i:lsdoh' OPT; do
    case $OPT in
        e) eth="$OPTARG";;
        i) isp="$OPTARG";;
        l) limit="true";;
        s) wlanacip="10.255.253.118"
           wlanacname="SPL-BRAS-SR8806-X";;
        d) ignore_disconnet="true";;
        o) logout;;
        h) help;;
        ?) help;;
    esac
done

shift $(($OPTIND - 1))

# Account username
name=$1

# Account password
passwd=$2

echo "Ethernet port: $eth"
echo "ISP: $isp"
echo "Username: $name"
echo "Password: $passwd"
echo "Limit login times: $limit"
echo ""

# Check network connectivity
network()
{
    if curl -s --head --connect-timeout 5 https://www.baidu.com | grep "200 OK" > /dev/null; then
        echo "Network is up."
        return 0  # Network is up
    else
        echo "Network is down."
        return 1  # Network is down
    fi
}

# Log into the campus network
loginNet() {
    if [ ! "$eth" ]
    then
        printf "Ethernet interface cannot be empty.\n"
        exit 0
    fi

    if [ ! "$isp" ]
    then
        printf "ISP cannot be empty.\n"
        exit 0
    fi

    if [ ! "$name" ]
    then
        printf "Username cannot be empty.\n"
        exit 0
    fi

    if [ ! "$passwd" ]
    then
        printf "Password cannot be empty.\n"
        exit 0
    fi

    ip=$(ifconfig "${eth}" | grep inet | awk '{print $2}' | tr -d "addr:")
    if [ ! "$ip" ]
    then
        printf "Failed to obtain IP address.\n"
        exit 0
    else
        printf "Current device IP address: ${ip}\n"
    fi

    if [ "$isp" = "ctcc" ]
    then
        printf "ISP is China Telecom.\n"
        login="%2C0%2C${name}%40njxy"
    elif [ "$isp" = "cmcc" ]
    then
        printf "ISP is China Mobile.\n"
        login="%2C0%2C${name}%40cmcc"
    elif [ "$isp" = "njupt" ]
    then
        printf "ISP is NJUPT campus network.\n"
        login="%2C0%2C${name}"
    else
        printf "Unrecognized ISP.\n"
        exit 0
    fi

    result=$(curl -k --request GET "https://10.10.244.11:802/eportal/portal/login?callback=dr1003&login_method=1&user_account=${login}&user_password=${passwd}&wlan_user_ip=${ip}&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=" \
    --connect-timeout 5 \
    --interface ${eth})
    printf "\n"
    if [[ $result =~ "成功" ]]
    then
        printf "Successfully logged into the campus network.\n"
    else
        printf "API request error: ${result}\nPlease report this issue on GitHub if it persists.\n"
    fi
}

# Start login process
start() {
    network
    if [ $? -eq 1 ]  # If network is down, try to log in
    then
        echo "Attempting to log in due to network issue or ignore settings."
        loginNet
    else
        echo "Network is up, no need to log in."
    fi
}

# Time-based login check
checkTime() {
    week=$(date +%w)
    time=$(date +%H%M)

    # Monday to Thursday
    if [ "$week" -ge 1 ] && [ "$week" -le 4 ]
    then
        # From 7:01 AM to 11:29 PM
        if [ "$time" -ge 0701 ] && [ "$time" -le 2329 ]
        then
            printf "Within allowed time, preparing to log in.\n"
            start
        else
            printf "Outside allowed time.\n"
        fi
    # Friday
    elif [ "$week" -eq 5 ]
    then
        # After 7:01 AM
        if [ "$time" -ge 0701 ]
        then
            printf "Within allowed time, preparing to log in.\n"
            start
        else
            printf "Outside allowed time.\n"
        fi
    # Saturday all day
    elif [ "$week" -eq 6 ]
    then
        printf "Saturday, allowed all day.\n"
        start
    # Sunday
    elif [ "$week" -eq 0 ]
    then
        # Before 11:29 PM
        if [ "$time" -le 2329 ]
        then
            printf "Within allowed time, preparing to log in.\n"
            start
        else
            printf "Outside allowed time.\n"
        fi
    fi
}

# Check if there's a time limit
if [ "$limit" = "false" ]
then
    printf "No time limit, preparing to log in.\n"
    start
else
    checkTime
fi

printf "Completed.\n"
