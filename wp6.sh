#!/bin/bash
# WiFi Pineapple Connector for Linux
# EULA https://www.wifipineapple.com/licence/eula.txt
# License https://www.wifipineapple.com/licence/software_licence.txt

wpver=6.5.1
spineapplenmask=255.255.255.0
spineapplenet=172.16.42.0/24
spineapplelan=eth1
spineapplewan=wlan0
spineapplegw=192.168.1.1
spineapplehostip=172.16.42.42
spineappleip=172.16.42.1
sfirsttime=1

if [ "$EUID" -ne 0 ]
    then echo "This WiFi Pineapple Connection script requires root."
    sudo su -s "$0"
    exit
fi

function banner {
    # Show random banner because 1337
    b=$(( ( RANDOM % 5 ) + 1 ))
    case "$b" in
        1)
        echo $(tput setaf 3)
        echo "    _       ___ _______    ____  _                              __    ";
        echo "   | |     / (_) ____(_)  / __ \\(_)___  ___  ____ _____  ____  / /__ ";
        echo "   | | /| / / / /_  / /  / /_/ / / __ \/ _ \/ __ '/ __ \/ __ \/ / _ \\";
        echo "   | |/ |/ / / __/ / /  / ____/ / / / /  __/ /_/ / /_/ / /_/ / /  __/ ";
        echo "   |__/|__/_/_/   /_/  /_/   /_/_/ /_/\___/\__,_/ .___/ .___/_/\___/  ";
        echo "                                               $(tput setaf 3)/_/   /_/$(tput sgr0)       v$wpver";
        ;;
        2)
        echo $(tput setaf 3)
        echo "           ___       __          ___       __   __        ___ ";
        echo "   |  | | |__  |    |__) | |\ | |__   /\  |__) |__) |    |__  ";
        echo "   |/\| | |    |    |    | | \| |___ /~~\ |    |    |___ |___ ";
        echo "                                                       $(tput sgr0)v$wpver"
        ;;
        3)
        echo $(tput setaf 3)
        echo "  ▄▄▌ ▐ ▄▌▪  ·▄▄▄▪       ▄▄▄·▪   ▐ ▄ ▄▄▄ . ▄▄▄·  ▄▄▄· ▄▄▄·▄▄▌  ▄▄▄ .";
        echo "  ██· █▌▐███ ▐▄▄·██     ▐█ ▄███ •█▌▐█▀▄.▀·▐█ ▀█ ▐█ ▄█▐█ ▄███•  ▀▄.▀·";
        echo "  ██▪▐█▐▐▌▐█·██▪ ▐█·     ██▀·▐█·▐█▐▐▌▐▀▀▪▄▄█▀▀█  ██▀· ██▀·██▪  ▐▀▀▪▄";
        echo "  ▐█▌██▐█▌▐█▌██▌.▐█▌    ▐█▪·•▐█▌██▐█▌▐█▄▄▌▐█ ▪▐▌▐█▪·•▐█▪·•▐█▌▐▌▐█▄▄▌";
        echo "   ▀▀▀▀ ▀▪▀▀▀▀▀▀ ▀▀▀    .▀   ▀▀▀▀▀ █▪ ▀▀▀  ▀  ▀ .▀   .▀   .▀▀▀  ▀▀▀ ";
        echo "                                                               $(tput sgr0)v$wpver"
        ;;
        4)
        echo $(tput setaf 3)
        echo "  ▄ ▄   ▄█ ▄████  ▄█    █ ▄▄  ▄█    ▄   ▄███▄   ██   █ ▄▄  █ ▄▄  █     ▄███▄ ";
        echo " █   █  ██ █▀   ▀ ██    █   █ ██     █  █▀   ▀  █ █  █   █ █   █ █     █▀   ▀";
        echo "█ ▄   █ ██ █▀▀    ██    █▀▀▀  ██ ██   █ ██▄▄    █▄▄█ █▀▀▀  █▀▀▀  █     ██▄▄  ";
        echo "█  █  █ ▐█ █      ▐█    █     ▐█ █ █  █ █▄   ▄▀ █  █ █     █     ███▄  █▄   ▄";
        echo " █ █ █   ▐  █      ▐     █     ▐ █  █ █ ▀███▀      █  █     █        ▀ ▀███▀ ";
        echo "  ▀ ▀        ▀            ▀      █   ██           █    ▀     ▀         $(tput sgr0)v$wpver";
        ;;
        5)
        echo $(tput setaf 3)
        echo "               (          (                                                 ";
        echo " (  (          )\ )       )\ )                                     (        ";
        echo " )\))(   ' (  (()/(  (   (()/( (            (     )                )\   (   ";
        echo "((_)()\ )  )\  /(_)) )\   /(_)))\   (      ))\ ( /(  \`  )   \`  )  ((_) ))\ ";
        echo "_(())\_)()((_)(_))_|((_) (_)) ((_)  )\ )  /((_))(_)) /(/(   /(/(   _  /((_) ";
        echo "\ \((_)/ / (_)| |_   (_) | _ \ (_) _(_/( (_)) ((_)_ ((_)_\ ((_)_\ | |(_))   ";
        echo " \ \/\/ /  | || __|  | | |  _/ | || ' \))/ -_)/ _\` || '_ \)| '_ \)| |/ -_)  ";
        echo "  \_/\_/   |_||_|    |_| |_|   |_||_||_| \___|\__,_|| .__/ | .__/ |_|\___|  ";
        echo "                                                    |_|    |_|       $(tput sgr0)v$wpver";
        ;;
    esac
}

function showsettings {
    printf "\n\
    $(tput bold)Saved Settings$(tput sgr0): Share Internet connection from $spineapplewan\n\
    to WiFi Pineapple at $spineapplelan through default gateway $spineapplegw\n"
}

function menu {
    printf "\n\
    [$(tput bold)C$(tput sgr0)]onnect using saved settings\n\
    [$(tput bold)G$(tput sgr0)]uided setup (recommended)\n\
    [$(tput bold)M$(tput sgr0)]anual setup\n\
    [$(tput bold)A$(tput sgr0)]dvanced IP settings\n\
    [$(tput bold)Q$(tput sgr0)]uit\n\n    "
    read -r -sn1 key
    case "$key" in
            [gG]) guidedsetup;;
            [mM]) manualsetup;;
            [cC]) connectsaved;;
            [aA]) advancedsetup;;
            [bB]) bunny;;
            [qQ]) printf "\n"; exit;;
    esac
}

function manualsetup {
    ipinstalled=$(which ip)
    if [[ "$?" == 0 ]]; then
        ifaces=($(ip link show | grep -v link | awk {'print $2'} | sed 's/://g' | grep -v lo))
        printf "\n    Select WiFi Pineapple Interface:\n"
        for i in "${!ifaces[@]}"; do
            printf "    [$(tput bold)%s$(tput sgr0)]\t%s\t" "$i" "${ifaces[$i]}"
            printf "$(ip -4 addr show ${ifaces[$i]} | grep inet | awk {'print $2'} | head -1)\n"
        done
        read -r -p "    > " planq
        if [ "$planq" -eq "$planq" ] 2>/dev/null; then
            spineapplelan=(${ifaces[planq]})
        else
            printf "\n    Response must be a listed numeric option\n"; manualsetup
        fi
        printf "\n    Select Internet Interface:\n"
        for i in "${!ifaces[@]}"; do
            printf "    [$(tput bold)%s$(tput sgr0)]\t%s\t" "$i" "${ifaces[$i]}"
            printf "$(ip -4 addr show ${ifaces[$i]} | grep inet | awk {'print $2'} | head -1)\n"
        done
        read -r -p "    > " inetq
        if [ "$inetq" -eq "$inetq" ] 2>/dev/null; then
            spineapplewan=(${ifaces[inetq]})
        else
            printf "\n    Response must be a listed numeric option\n"; manualsetup
        fi
        printf "\n$(netstat -nr)\n\n"
        read -r -p "    Specify Default Gateway IP Address: " spineapplegw
        savechanges
    else
        printf "\n\n    Configuration requires the 'iproute2' package (aka the 'ip' command).\n    Please install 'iproute2' to continue.\n"
        menu
    fi
}

function guidedsetup {
    pineappledetected=$(ip addr | grep '00:[cC]0:[cC][aA]\|00:13:37' -B1 | awk {'print $2'} | head -1 | grep 'eth\|en')
    if [[ "$?" == 0 ]]; then
        printf "\n    WiFi Pineapple detected. Please disconnect the WiFi Pineapple from\n    this computer and $(tput bold)press any key$(tput sgr0) to continue with guided setup.\n    "
        read -r -sn1 anykey
        guidedsetup
    fi
    hasiproute2=$(which ip)
    if [[ "$?" == 1 ]]; then
        printf "\n\n    Configuration requires the 'iproute2' package (aka the 'ip' command).\n    Please install 'iproute2' to continue.\n"; menu
    fi
    hasdefaultroute=$(ip route)
    if [[ "$?" == 1 ]]; then
        printf "\n    No route detected. Check connection and try again.\n"; menu
    fi

    printf "\n    $(tput setaf 3)Step 1 of 3: Select Default Gateway$(tput sgr0)\n\
    Default gateway reported as $(tput bold)$(ip route | grep default | awk {'print $3'} | head -1)$(tput sgr0)\n"
    read -r -p "    Use the above reported default gateway?             [Y/n]? " usedgw
    case $usedgw in
        [yY][eE][sS]|[yY]|'')
        spineapplegw=($(ip route | grep default | awk {'print $3'}))
        ;;
        [nN][oO]|[nN])
        printf "\n$(ip route)\n\n"
        read -r -p "    Specify the default gateway by IP address: " spineapplegw
        ;;
    esac

    printf "\n    $(tput setaf 3)Step 2 of 3: Select Internet Interface$(tput sgr0)\n\
    Internet interface reported as $(tput bold)$(ip route | grep default | awk {'print $5'} | head -1)$(tput sgr0)\n"
    read -r -p "    Use the above reported Internet interface?          [Y/n]? " useii
    case $useii in
        [yY][eE][sS]|[yY]|'')
            spineapplewan=($(ip route | grep default | awk {'print $5'}))
        ;;
        [nN][oO]|[nN])
            printf "\n    Available Network Interfaces:\n"
            ifaces=($(ip link show | grep -v link | awk {'print $2'} | sed 's/://g' | grep -v lo))
            for i in "${!ifaces[@]}"; do
                printf "    \t%s\t" "${ifaces[$i]}"
                printf "$(ip -4 addr show ${ifaces[$i]} | grep inet | awk {'print $2'} | head -1)\n"
            done
            read -r -p "    Specify the internet interface by name: " spineapplewan
        ;;
    esac

    printf "\n    $(tput setaf 3)Step 3 of 3: Select WiFi Pineapple Interface$(tput sgr0)\n    Please connect the WiFi Pineapple to this computer.\n    "

    a="0"
    until pineappleiface=$(ip addr | grep '00:[cC]0:[cC][aA]\|00:13:37' -B1 | awk {'print $2'} | head -1 | grep 'eth\|en')
    do
        printf "."
        sleep 1
        a=$[$a+1]
        if [[ $a == "51" ]]; then
            printf "\n    "
            a=0
        fi
    done
    printf "[Checking]"
    sleep 5 # Wait as the system is likely to rename interface. Sleeping rather than more advanced error handling becasue reasons. Try: dmesg | tail | grep -E 'asix.*renamed'
    pineappleiface=$(ip addr | grep '00:[cC]0:[cC][aA]\|00:13:37' -B1 | awk {'print $2'} | head -1 | grep 'eth\|en' | sed 's/://g')
    printf "\n    Detected WiFi Pineapple on interface $(tput bold)$pineappleiface$(tput sgr0)\n";
    read -r -p "    Use the above detected WiFi Pineapple interface?    [Y/n]? " pi
    case $pi in
        [yY][eE][sS]|[yY]|'')
            spineapplelan=$pineappleiface
        ;;
        [nN][oO]|[nN])
            printf "\n    Available Network Interfaces:\n"
            ifaces=($(ip link show | grep -v link | awk {'print $2'} | sed 's/://g' | grep -v lo))
            for i in "${!ifaces[@]}"; do
                printf "    \t%s\t" "${ifaces[$i]}"
                printf "$(ip -4 addr show ${ifaces[$i]} | grep inet | awk {'print $2'} | head -1)\n"
            done
            read -r -p "    Specify the WiFi Pineapple interface by name: " spineapplelan
        ;;
    esac
    savechanges
}

function advancedsetup {
    printf "\n\
    By default the WiFi Pineapple resides on the $(tput bold)172.16.42.0/24$(tput sgr0) network\n\
    with the IP Address $(tput bold)172.16.42.1$(tput sgr0) and Ethernet default route $(tput bold)172.16.42.42$(tput sgr0).\n\n\
    The WiFi Pineapple expects an Internet connection from 172.16.42.42 by\n\
    default, which this script aids in configuring. These IP addresses may\n\
    be changed if desired by modifying network configs on the WiFi Pineapple.\n\n"
    read -r -p "    Continue with advanced IP config [y/N]? " qcontinue
    case $qcontinue in
        [nN][oO]|[nN]|'') menu ;;
        [yY][eE][sS]|[yY])
            read -r -p "    WiFi Pineapple Network           [172.16.42.0/24]: " spineapplenet
            if [[ $spineapplenet == '' ]]; then 
            spineapplenet=172.16.42.0/24 # Pineapple network. Default is 172.16.42.0/24
            fi
            read -r -p "    WiFi Pineapple Netmask           [255.255.255.0]: " spineapplenmask
            if [[ $spineapplenmask == '' ]]; then 
            spineapplenmask=255.255.255.0 #Default netmask for /24 network
            fi
            read -r -p "    Host IP Address                  [172.16.42.42]: " spineapplehostip
            if [[ $spineapplehostip == '' ]]; then 
            spineapplehostip=172.16.42.42 #IP Address of host computer
            fi
            read -r -p "    WiFi Pineapple IP Address        [172.16.42.1]: " spineappleip
            if [[ $spineappleip == '' ]]; then 
            spineappleip=172.16.42.1 #Don't forget your towel
            fi
            printf "\n    Advanced IP settings will be saved for future sessions.\n    Default settings may be restored by selecting Advanced IP settings and\n    pressing [ENTER] when prompted for IP settings.\n\n    Press any key to continue"
            savechanges
        ;;
    esac
}

function savechanges {
    sed -i "s/^spineapplenmask.*/spineapplenmask=$spineapplenmask/" $0
    sed -i "s&^spineapplenet.*&spineapplenet=$spineapplenet&" $0
    sed -i "s/^spineapplelan.*/spineapplelan=$spineapplelan/" $0
    sed -i "s/^spineapplewan.*/spineapplewan=$spineapplewan/" $0
    sed -i "s/^spineapplegw.*/spineapplegw=$spineapplegw/" $0
    sed -i "s/^spineapplehostip.*/spineapplehostip=$spineapplehostip/" $0
    sed -i "s/^spineappleip.*/spineappleip=$spineappleip/" $0
    sed -i "s/^sfirsttime.*/sfirsttime=0/" $0
    sfirsttime=0
    printf "\n    Settings saved.\n"
    showsettings
    menu
}

function connectsaved {
    if [[ "$sfirsttime" == "1" ]]; then
        printf "\n    Error: Settings unsaved. Run either Guided or Manual setup first.\n"; menu
    fi
    ifconfig $spineapplelan $spineapplehostip netmask $spineapplenmask up #Bring up Ethernet Interface directly connected to Pineapple
    printf "Detecting WiFi Pineapple..."
    until ping $spineappleip -c1 -w1 >/dev/null
    do
        printf "."
        ifconfig $spineapplelan $spineapplehostip netmask $spineapplenmask up &>/dev/null
        sleep 1
    done
    printf "...found.\n\n"
    printf "    $(tput setaf 6)     _ .   $(tput sgr0)        $(tput setaf 7)___$(tput sgr0)          $(tput setaf 3)\||/$(tput sgr0)\n"
    printf "    $(tput setaf 6)   (  _ )_ $(tput sgr0) $(tput setaf 2)<-->$(tput sgr0)  $(tput setaf 7)[___]$(tput sgr0)  $(tput setaf 2)<-->$(tput sgr0)  $(tput setaf 3),<><>,$(tput sgr0)\n"
    printf "    $(tput setaf 6) (_  _(_ ,)$(tput sgr0)       $(tput setaf 7)\___\\$(tput sgr0)        $(tput setaf 3)'<><>'$(tput sgr0)\n"
    ifconfig $spineapplelan $spineapplehostip netmask $spineapplenmask up #Bring up Ethernet Interface directly connected to Pineapple
    
    #
    # IP Forwarding Settingup 
    #
    
    # Enable kernel IP forwarding
    echo '1' > /proc/sys/net/ipv4/ip_forward
    # Enable iptables forwarding 
    iptables -I FORWARD 1 -i $spineapplewan -o $spineapplelan -m state --state NEW,ESTABLISHED,RELATED -m comment --comment "WifiPineapple to Inetnet" -j ACCEPT 
    iptables -I FORWARD 2 -i $spineapplelan -o $spineapplewan -m state --state NEW,ESTABLISHED,RELATED -m comment --comment "Inetnet to WifiPineapple" -j ACCEPT
    # Enable connection masquerading 
    iptables -A POSTROUTING -t nat -o $spineapplewan -m comment --comment "Inetnet Connection Sharing (ICS)" -j MASQUERADE
    # remove default route
    route del default
    # add default gateway
    route add default gw $spineapplegw $spineapplewan
    printf "\n    Browse to http://$spineappleip:1471\n\n"
    exit
}

function bunny {
    printf "\nNetmask $spineapplenmask\nPineapple Net $spineapplenet\nPineapple LAN $spineapplelan\nPineapple WAN $spineapplewan\nPineapple GW $spineapplegw\nPineapple IP $spineappleip\nHost IP $spineapplehostip\n"
    printf "\n$(lsusb | grep ASIX)\n\n$(ifconfig -a)\n\n$(route)\n\n$(dmesg | grep -E '[aA][sS][iI[[xX].*|00:[cC]0:[cC][aA]')\n"
    printf "\n/)___(\ \n(='.'=)\n(\")_(\")\n"
    exit
}

banner # remove for less 1337
showsettings
if [[ "$sfirsttime" == "1" ]]; then
    printf "
    Since this is the first time running the WP6 Internet Connection Sharing\n\
    script, Guided setup is recommended to save initial configuration.\n\
    Subsequent sessions may be quickly connected using saved settings.\n"
fi
menu
