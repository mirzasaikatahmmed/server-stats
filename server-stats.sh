#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

print_header() {
    echo -e "\n${BOLD}${BLUE}==================== $1 ====================${NC}"
}

print_subheader() {
    echo -e "${CYAN}$1${NC}"
}

clear
echo -e "${BOLD}${GREEN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           SERVER PERFORMANCE STATISTICS ANALYZER              ║"
echo "╔════════════════════════════════════════════════════════════════╗"
echo -e "${NC}"
echo -e "Generated on: ${YELLOW}$(date '+%Y-%m-%d %H:%M:%S')${NC}"

print_header "SYSTEM INFORMATION"

if [ -f /etc/os-release ]; then
    OS_NAME=$(grep -w "PRETTY_NAME" /etc/os-release | cut -d'"' -f2)
    echo -e "${BOLD}OS:${NC} $OS_NAME"
elif [ -f /etc/redhat-release ]; then
    OS_NAME=$(cat /etc/redhat-release)
    echo -e "${BOLD}OS:${NC} $OS_NAME"
else
    echo -e "${BOLD}OS:${NC} $(uname -s) $(uname -r)"
fi

echo -e "${BOLD}Kernel:${NC} $(uname -r)"

echo -e "${BOLD}Hostname:${NC} $(hostname)"

UPTIME=$(uptime -p 2>/dev/null || uptime | awk -F'( |,|:)+' '{print $6,$7",",$8,"hours,",$9,"minutes"}')
echo -e "${BOLD}Uptime:${NC} $UPTIME"

LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}')
echo -e "${BOLD}Load Average:${NC}$LOAD_AVG"

LOGGED_USERS=$(who | wc -l)
echo -e "${BOLD}Logged in Users:${NC} $LOGGED_USERS"
if [ $LOGGED_USERS -gt 0 ]; then
    echo -e "${CYAN}Current Sessions:${NC}"
    who | awk '{printf "  %-15s %-12s %s %s\n", $1, $2, $3, $4}'
fi

if [ -f /var/log/auth.log ]; then
    FAILED_LOGINS=$(grep -i "failed password" /var/log/auth.log 2>/dev/null | wc -l)
    echo -e "${BOLD}Failed Login Attempts (auth.log):${NC} $FAILED_LOGINS"
elif [ -f /var/log/secure ]; then
    FAILED_LOGINS=$(grep -i "failed password" /var/log/secure 2>/dev/null | wc -l)
    echo -e "${BOLD}Failed Login Attempts (secure):${NC} $FAILED_LOGINS"
fi

print_header "CPU USAGE"

CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d'%' -f1)
CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc -l 2>/dev/null || awk "BEGIN {printf \"%.2f\", 100 - $CPU_IDLE}")

echo -e "${BOLD}Total CPU Usage:${NC} ${GREEN}${CPU_USAGE}%${NC}"
echo -e "${BOLD}CPU Idle:${NC} ${CPU_IDLE}%"

CPU_CORES=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo)
echo -e "${BOLD}CPU Cores:${NC} $CPU_CORES"

CPU_STATS=$(top -bn1 | grep "Cpu(s)" | sed 's/,//g')
echo -e "\n${CYAN}Detailed CPU Breakdown:${NC}"
echo "$CPU_STATS" | awk '{
    printf "  User:   %s\n", $2
    printf "  System: %s\n", $4
    printf "  Nice:   %s\n", $6
    printf "  Idle:   %s\n", $8
    printf "  Wait:   %s\n", $10
}'

print_header "MEMORY USAGE"

MEMORY_STATS=$(free -h | grep "Mem:")
TOTAL_MEM=$(echo $MEMORY_STATS | awk '{print $2}')
USED_MEM=$(echo $MEMORY_STATS | awk '{print $3}')
FREE_MEM=$(echo $MEMORY_STATS | awk '{print $4}')
AVAILABLE_MEM=$(echo $MEMORY_STATS | awk '{print $7}')

TOTAL_MEM_KB=$(free | grep "Mem:" | awk '{print $2}')
USED_MEM_KB=$(free | grep "Mem:" | awk '{print $3}')
MEM_PERCENTAGE=$(awk "BEGIN {printf \"%.2f\", ($USED_MEM_KB/$TOTAL_MEM_KB)*100}")

echo -e "${BOLD}Total Memory:${NC} $TOTAL_MEM"
echo -e "${BOLD}Used Memory:${NC} ${RED}$USED_MEM${NC} (${RED}${MEM_PERCENTAGE}%${NC})"
echo -e "${BOLD}Free Memory:${NC} ${GREEN}$FREE_MEM${NC}"
echo -e "${BOLD}Available Memory:${NC} $AVAILABLE_MEM"

print_subheader "\nMemory Usage Bar:"
FILLED=$(awk "BEGIN {printf \"%.0f\", $MEM_PERCENTAGE/2}")
printf "  ["
for ((i=0; i<50; i++)); do
    if [ $i -lt $FILLED ]; then
        printf "${RED}█${NC}"
    else
        printf "░"
    fi
done
printf "] ${MEM_PERCENTAGE}%%\n"

SWAP_STATS=$(free -h | grep "Swap:")
if [ ! -z "$SWAP_STATS" ]; then
    TOTAL_SWAP=$(echo $SWAP_STATS | awk '{print $2}')
    USED_SWAP=$(echo $SWAP_STATS | awk '{print $3}')
    FREE_SWAP=$(echo $SWAP_STATS | awk '{print $4}')

    echo -e "\n${CYAN}Swap Usage:${NC}"
    echo -e "${BOLD}Total Swap:${NC} $TOTAL_SWAP"
    echo -e "${BOLD}Used Swap:${NC} $USED_SWAP"
    echo -e "${BOLD}Free Swap:${NC} $FREE_SWAP"
fi

print_header "DISK USAGE"

echo -e "${BOLD}Filesystem Usage:${NC}\n"
df -h --output=source,size,used,avail,pcent,target -x tmpfs -x devtmpfs 2>/dev/null | \
    awk 'NR==1 {printf "%-20s %8s %8s %8s %6s  %s\n", $1, $2, $3, $4, $5, $6; print "--------------------------------------------------------------------------------"}
         NR>1 {
             usage = substr($5, 1, length($5)-1)
             if (usage >= 90) color = "\\033[0;31m"
             else if (usage >= 75) color = "\\033[1;33m"
             else color = "\\033[0;32m"

             printf "%-20s %8s %8s %8s %s%6s\\033[0m  %s\n", $1, $2, $3, $4, color, $5, $6
         }'

echo -e "\n${CYAN}Disk Usage Summary:${NC}"
TOTAL_DISK=$(df -h --total -x tmpfs -x devtmpfs 2>/dev/null | grep "total" | awk '{print $2}')
USED_DISK=$(df -h --total -x tmpfs -x devtmpfs 2>/dev/null | grep "total" | awk '{print $3}')
FREE_DISK=$(df -h --total -x tmpfs -x devtmpfs 2>/dev/null | grep "total" | awk '{print $4}')
DISK_PERCENTAGE=$(df -h --total -x tmpfs -x devtmpfs 2>/dev/null | grep "total" | awk '{print $5}')

echo -e "${BOLD}Total Disk:${NC} $TOTAL_DISK"
echo -e "${BOLD}Used Disk:${NC} ${RED}$USED_DISK${NC} (${RED}${DISK_PERCENTAGE}${NC})"
echo -e "${BOLD}Free Disk:${NC} ${GREEN}$FREE_DISK${NC}"

print_header "TOP 5 PROCESSES BY CPU USAGE"

echo -e "${BOLD}%-10s %-10s %-10s %-10s %s${NC}" "PID" "USER" "CPU%" "MEM%" "COMMAND"
echo "--------------------------------------------------------------------------------"
ps aux --sort=-%cpu | head -n 6 | tail -n 5 | awk '{
    if ($3 >= 50) color = "\\033[0;31m"
    else if ($3 >= 25) color = "\\033[1;33m"
    else color = "\\033[0;32m"

    printf "%s%-10s %-10s %-10s %-10s %s\\033[0m\n", color, $2, $1, $3"%", $4"%", $11
}'

print_header "TOP 5 PROCESSES BY MEMORY USAGE"

echo -e "${BOLD}%-10s %-10s %-10s %-10s %s${NC}" "PID" "USER" "MEM%" "CPU%" "COMMAND"
echo "--------------------------------------------------------------------------------"
ps aux --sort=-%mem | head -n 6 | tail -n 5 | awk '{
    if ($4 >= 50) color = "\\033[0;31m"
    else if ($4 >= 25) color = "\\033[1;33m"
    else color = "\\033[0;32m"

    printf "%s%-10s %-10s %-10s %-10s %s\\033[0m\n", color, $2, $1, $4"%", $3"%", $11
}'

echo -e "\n${BOLD}${GREEN}"
echo "╚════════════════════════════════════════════════════════════════╝"
echo "║                    End of Report                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"
