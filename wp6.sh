#!/bin/bash
# WiFi Pineapple Connector for Linux
# EULA https://www.wifipineapple.com/licence/eula.txt
# License https://www.wifipineapple.com/licence/software_licence.txt
spineapplenmask=255.255.255.0
spineapplenet=172.16.42.0/24
spineapplelan=eth18
spineapplewan=wlan0
spineapplegw=10.73.31.1
spineapplehostip=172.16.42.42
spineappleip=172.16.42.1



if [ "$EUID" -ne 0 ]
  then echo "The WiFi Pineapple Connection script requires root."
  exit
fi



function configure {
  echo ""
  read -r -p "WiFi Pineapple Netmask           [255.255.255.0]: " pineapplenmask
  if [[ $pineapplenmask == '' ]]; then 
  pineapplenmask=255.255.255.0 #Default netmask for /24 network
  fi
  
  read -r -p "WiFi Pineapple Network           [172.16.42.0/24]: " pineapplenet
  if [[ $pineapplenet == '' ]]; then 
  pineapplenet=172.16.42.0/24 # Pineapple network. Default is 172.16.42.0/24
  fi
  
  read -r -p "Host Interface to WiFi Pineapple [eth1]: " pineapplelan
  if [[ $pineapplelan == '' ]]; then 
  pineapplelan=eth1 # Interface connected to Pineapple
  fi
  
  read -r -p "Host Interface to Internet       [wlan0]: " pineapplewan
  if [[ $pineapplewan == '' ]]; then 
  pineapplewan=wlan0 #i.e. wlan0 for wifi, ppp0 for 3g modem/dialup, eth0 for lan
  fi
  
  temppineapplegw=`netstat -nr | awk 'BEGIN {while ($3!="0.0.0.0") getline; print $2}'` #Usually correct by default
  read -r -p "Internet Gateway                 [$temppineapplegw]: " pineapplegw
  if [[ $pineapplegw == '' ]]; then 
  pineapplegw=`netstat -nr | awk 'BEGIN {while ($3!="0.0.0.0") getline; print $2}'` #Usually correct by default
  fi
  
  read -r -p "IP Address of Host               [172.16.42.42]: " pineapplehostip
  if [[ $pineapplehostip == '' ]]; then 
  pineapplehostip=172.16.42.42 #IP Address of host computer
  fi
  
  read -r -p "IP Address of WiFi Pineapple     [172.16.42.1]: " pineappleip
  if [[ $pineappleip == '' ]]; then 
  pineappleip=172.16.42.1 #Don't forget your towel
  fi
  echo ""
  read -r -p "Save settings for next session   [Y/n]? " savechanges
  case $savechanges in
    [yY][eE][sS]|[yY]|'') savechanges ;;
    [nN][oO]|[nN])   
      read -r -p "Settings saved. Connect now      [Y/n]? " qconnectnow
      case $qconnectnow in
        [yY][eE][sS]|[yY]|'') connectnow ;;
        [nN][oO]|[nN]) exit ;;
      esac ;;
  esac
}



function savechanges {
  sed -i "s/^spineapplenmask.*/spineapplenmask=$pineapplenmask/" $0
  sed -i "s&^spineapplenet.*&spineapplenet=$pineapplenet&" $0
  sed -i "s/^spineapplelan.*/spineapplelan=$pineapplelan/" $0
  sed -i "s/^spineapplewan.*/spineapplewan=$pineapplewan/" $0
  sed -i "s/^spineapplegw.*/spineapplegw=$pineapplegw/" $0
  sed -i "s/^spineapplehostip.*/spineapplehostip=$pineapplehostip/" $0
  sed -i "s/^spineappleip.*/spineappleip=$pineappleip/" $0
  echo ""
  read -r -p "Settings saved. Connect now      [Y/n]? " qconnectnow
  case $qconnectnow in
    [yY][eE][sS]|[yY]|'') connectnow ;;
    [nN][oO]|[nN]) exit ;;
  esac
}



function connectnow {
  echo ""
  echo "$(tput setaf 6)     _ .   $(tput sgr0)        $(tput setaf 7)___$(tput sgr0)          $(tput setaf 3)\||/$(tput sgr0)   Internet: $pineapplegw - $pineapplewan"
  echo "$(tput setaf 6)   (  _ )_ $(tput sgr0) $(tput setaf 2)<-->$(tput sgr0)  $(tput setaf 7)[___]$(tput sgr0)  $(tput setaf 2)<-->$(tput sgr0)  $(tput setaf 3),<><>,$(tput sgr0)  Computer: $pineapplehostip"
  echo "$(tput setaf 6) (_  _(_ ,)$(tput sgr0)       $(tput setaf 7)\___\\$(tput sgr0)        $(tput setaf 3)'<><>'$(tput sgr0) Pineapple: $pineapplenet - $pineapplelan"
  ifconfig $pineapplelan $pineapplehostip netmask $pineapplenmask up #Bring up Ethernet Interface directly connected to Pineapple
  echo '1' > /proc/sys/net/ipv4/ip_forward # Enable IP Forwarding
  iptables -X #clear chains and rules
  iptables -F
  iptables -A FORWARD -i $pineapplewan -o $pineapplelan -s $pineapplenet -m state --state NEW -j ACCEPT #setup IP forwarding
  iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
  iptables -A POSTROUTING -t nat -j MASQUERADE
  route del default #remove default route
  route add default gw $pineapplegw $pineapplewan #add default gateway
  echo ""
  echo "Browse to http://$pineappleip:1471"
  echo ""
  exit
}



function connectsaved {
pineapplenmask=$spineapplenmask
pineapplenet=$spineapplenet
pineapplelan=$spineapplelan
pineapplewan=$spineapplewan
pineapplegw=$spineapplegw
pineapplehostip=$spineapplehostip
pineappleip=$spineappleip
connectnow
}



echo "$(tput setaf 3)  _       ___ _______    ____  _                              __   "
echo " | |     / (_) ____(_)  / __ \\(_)___  ___  ____ _____  ____  / /__ "
echo " | | /| / / / /_  / /  / /_/ / / __ \/ _ \/ __ '/ __ \/ __ \/ / _ \\"
echo " | |/ |/ / / __/ / /  / ____/ / / / /  __/ /_/ / /_/ / /_/ / /  __/"
echo " |__/|__/_/_/   /_/  /_/   /_/_/ /_/\___/\__,_/ .___/ .___/_/\___/ "
echo "                                             $(tput setaf 3)/_/   /_/$(tput sgr0)       v6.1"
echo ""
echo "Netmask:        $spineapplenmask"
echo "Network:        $spineapplenet"
echo "LAN:            $spineapplelan"
echo "WAN:            $spineapplewan"
echo "Gateway:        $spineapplegw"
echo "Host PC:        $spineapplehostip"
echo "WiFi Pineapple: $spineappleip"
echo ""
read -r -p "Connect using saved settings     [Y/n]? " usesettings
case $usesettings in
 [yY][eE][sS]|[yY]|'') connectsaved ;;
 [nN][oO]|[nN]) configure ;;
esac
echo "Invalid response"
exit
