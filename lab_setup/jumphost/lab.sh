#!/bin/bash
# IXP lab GNS3 console menu
# Generated from: IXP lab.gns3
# Purpose: allow students on the jumphost to telnet to GNS3 router consoles.
# Set GNS3_HOST to the GNS3 server address reachable over VPN.

GNS3_HOST="${GNS3_HOST:-172.233.75.181}"

declare -A BORDER_PORT=(
    [1]=5011
    [2]=5021
    [3]=5031
    [4]=5041
    [5]=5051
    [6]=5061
    [7]=5071
    [8]=5081
)

declare -A CORE_PORT=(
    [1]=5012
    [2]=5022
    [3]=5032
    [4]=5042
    [5]=5052
    [6]=5062
    [7]=5072
    [8]=5082
)

declare -A PEER_PORT=(
    [1]=5013
    [2]=5023
    [3]=5033
    [4]=5043
    [5]=5053
    [6]=5063
    [7]=5073
    [8]=5083
)

declare -A ACCESS_PORT=(
    [1]=5014
    [2]=5024
    [3]=5034
    [4]=5044
    [5]=5054
    [6]=5064
    [7]=5074
    [8]=5084
)

connect_router() {
    local label="$1"
    local port="$2"
    clear
    echo "Connecting to ${label} on ${GNS3_HOST}:${port}"
    echo "Press Ctrl-] then type 'quit' to exit telnet."
    echo
    telnet "${GNS3_HOST}" "${port}"
    echo
    read -rp "Press Enter to return to the menu..." _
}

show_group_menu() {
    local group="$1"

    while true; do
        clear
        echo "======================================"
        printf "        IXP Lab - Group %02d
" "${group}"
        echo "======================================"
        #echo "GNS3 server: ${GNS3_HOST}"
        echo "GNS3 server: 1"
        echo
        echo "1) Border router"
        echo "2) Core router"
        echo "3) Peer router"
        echo "4) Access router"
        echo "b) Back to group list"
        echo "q) Quit"
        echo
        read -rp "Select router: " choice

        case "$choice" in
            1) connect_router "Group $(printf '%02d' "${group}") Border" "${BORDER_PORT[$group]}" ;;
            2) connect_router "Group $(printf '%02d' "${group}") Core" "${CORE_PORT[$group]}" ;;
            3) connect_router "Group $(printf '%02d' "${group}") Peer" "${PEER_PORT[$group]}" ;;
            4) connect_router "Group $(printf '%02d' "${group}") Access" "${ACCESS_PORT[$group]}" ;;
            b|B) return ;;
            q|Q|quit|exit) exit 0 ;;
            *) echo "Invalid selection."; sleep 1 ;;
        esac
    done
}

while true; do
    clear
    echo "======================================"
    echo "        IXP Lab - Group Console Menu"
    echo "======================================"
    #echo "GNS3 server: ${GNS3_HOST}"
	echo "GNS3 server: 1"
    echo
    printf "%2d) Group %02d\n" 1 1
    printf "%2d) Group %02d\n" 2 2
    printf "%2d) Group %02d\n" 3 3
    printf "%2d) Group %02d\n" 4 4
    printf "%2d) Group %02d\n" 5 5
    printf "%2d) Group %02d\n" 6 6
    printf "%2d) Group %02d\n" 7 7
    printf "%2d) Group %02d\n" 8 8
    echo " q) Quit"
    echo
    read -rp "Select group: " group_choice

    case "$group_choice" in
        q|Q|quit|exit)
            exit 0
            ;;
        ''|*[!0-9]*)
            echo "Invalid group."; sleep 1
            ;;
        *)
            if [[ "$group_choice" -ge 1 && "$group_choice" -le 8 ]]; then
                show_group_menu "$group_choice"
            else
                echo "Group must be between 1 and 8"; sleep 1
            fi
            ;;
    esac
done
