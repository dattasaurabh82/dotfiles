!/bin/bash

sudo apt update -y
sudo apt upgrade -y
sudo apt install gnupg2 nginx-full openjdk-11-jdk apt-transport-https -y
sudo apt-add-repository universe -y
sudo apt update -y

curl https://download.jitsi.org/jitsi-key.gpg.key | sudo sh -c 'gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg'
echo 'deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/' | sudo tee /etc/apt/sources.list.d/jitsi-stable.list > /dev/null
sudo apt update -y

sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 4443/tcp
sudo ufw allow 10000/udp
sudo ufw allow 22/tcp
sudo ufw allow 3478/udp
sudo ufw allow 5349/tcp
sudo ufw enable
sudo ufw status verbose

sudo apt install jitsi-meet -y

BLUE='\033[0;34m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

l1_prefix="org.ice4j.ice.harvest.NAT_HARVESTER_LOCAL_ADDRESS="
l1_suffix="127.0.0.1"
l1="$l1_prefix$l1_suffix"

l2_prefix="org.ice4j.ice.harvest.NAT_HARVESTER_PUBLIC_ADDRESS="
l2_suffix="$(hostname -I | cut -f1 -d' ')"
l2="$l2_prefix$l2_suffix"

# echo "$l1"
# echo "$l2"

# check the file /etc/jitsi/videobridge/sip-communicator.properties contains these lines
# if it contains, replace
# if it doesn't Adding
if grep -q "$l1_prefix" "/etc/jitsi/videobridge/sip-communicator.properties"
then
echo -e "${YELLOW}REPLACING the line${RESET}: \"$l1_prefix...\""
echo -e "with: ${BLUE}$l1${RESET}"
sed -i "s/.*$l1_prefix.*/$l1/" "/etc/jitsi/videobridge/sip-communicator.properties"
else
echo -e "${RED}MISSING line:${RESET} \"$l1\""
echo -e "${GREEN}Adding ...${RESET}"
echo "$l1" | tee -a "/etc/jitsi/videobridge/sip-communicator.properties" > /dev/null
fi


if grep -q "$l2_prefix" "/etc/jitsi/videobridge/sip-communicator.properties"
then
echo -e "${YELLOW}REPLACING the line${RESET}: \"$l2_prefix...\""
echo -e "with: ${BLUE}$l2${RESET}"
sed -i "s/.*$l2_prefix.*/$l2/" "/etc/jitsi/videobridge/sip-communicator.properties"
else
echo -e "${RED}MISSING line:${RESET} \"$l2\""
echo -e "${GREEN}Adding ...${RESET}"
echo "$l2" | tee -a "/etc/jitsi/videobridge/sip-communicator.properties" > /dev/null
fi

sudo systemctl restart prosody
sudo systemctl restart jicofo
sudo systemctl restart jitsi-videobridge2
sudo systemctl restart nginx

