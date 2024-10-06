#!/bin/bash
clear

generate_echo() {
    local start_echo=$1
    local end_echo=$2
    local steps=$3
    local index=$4

    local start_r=$(( (start_echo & 0xFF0000) >> 16 ))
    local start_g=$(( (start_echo & 0x00FF00) >> 8 ))
    local start_b=$(( start_echo & 0x0000FF ))
    local end_r=$(( (end_echo & 0xFF0000) >> 16 ))
    local end_g=$(( (end_echo & 0x00FF00) >> 8 ))
    local end_b=$(( end_echo & 0x0000FF ))

    local r=$(( start_r + (end_r - start_r) * index / steps ))
    local g=$(( start_g + (end_g - start_g) * index / steps ))
    local b=$(( start_b + (end_b - start_b) * index / steps ))

    printf "\033[38;2;%d;%d;%dm" $r $g $b
}
gprint() {
    local input_string="$1"
    local start_echo=0xef09f7 # Blue
    local end_echo=0x7809f7 # Purple
    local delay1=0.02
    local delay=${2:-0.02}
    local newline="${3:-false}"
    local length=${#input_string}

    for (( i=0; i<$length; i++ )); do
        generate_echo $start_echo $end_echo $length $i
        printf "${input_string:$i:1}"
    done
    if [ "$newline" = "true" ]; then
         echo -n -e "\033[0m"
    else
         echo -e "\033[0m"
    fi
}

gprint2() {
    local input_string="$1"
    local start_echo=0xef09f7 # Blue
    local end_echo=0x7809f7 # Purple
    local delay1=0.02
    local delay=${2:-0.02}
    local newline="${3:-false}"
    local length=${#input_string}

    for (( i=0; i<$length; i++ )); do
        generate_echo $start_echo $end_echo $length $i
        printf "${input_string:$i:1}"
        sleep $delay
    done
    if [ "$newline" = "true" ]; then
         echo -n -e "\033[0m"
    else
         echo -e "\033[0m"
    fi
}

generate_gradient() {
    local start_echo=$1
    local end_echo=$2
    local steps=$3
    local index=$4
    local char="$5"

    
    local start_r=$(( (start_echo & 0xFF0000) >> 16 ))
    local start_g=$(( (start_echo & 0x00FF00) >> 8 ))
    local start_b=$(( start_echo & 0x0000FF ))
    local end_r=$(( (end_echo & 0xFF0000) >> 16 ))
    local end_g=$(( (end_echo & 0x00FF00) >> 8 ))
    local end_b=$(( end_echo & 0x0000FF ))

    
    local r=$(( start_r + (end_r - start_r) * index / steps ))
    local g=$(( start_g + (end_g - start_g) * index / steps ))
    local b=$(( start_b + (end_b - start_b) * index / steps ))

        printf "\033[38;2;%d;%d;%dm%s\033[0m" $r $g $b "$char"
}

generate2() {
    local length=$1
    local random_string=""
    for ((i = 0; i < length; i++)); do
        # Generate a random number for a Unicode code point in a certain range
        # 0x2600 to 0x26FF is used for miscellaneous symbols as an example
        code_point=$((RANDOM % 256 + 0x2600))
        # Convert code point to Unicode character
        random_string+=$(echo -e "\\U$(printf '%08x' "$code_point")")
    done
    echo "$random_string"
}

generate1() {
    local length=$1
    tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$length"
    echo
}

ascii="

888~~\            d8                   Y88b      /                    888   d8   
888   | Y88b  / _d88__  e88~~8e         Y88b    /    /~~~8e  888  888 888 _d88__ 
888 _/   Y888/   888   d888  88b         Y88b  /         88b 888  888 888  888   
888  \    Y8/    888   8888__888          Y888/     e88~-888 888  888 888  888   
888   |    Y     888   Y888    ,           Y8/     C888  888 888  888 888  888   
888__/    /      '88_/  '88___/             Y       '88_-888 '88_-888 888  '88_/ 
        _/                                                                       
"

./../gradient "0xef09f7" "0x7809f7" "$ascii"
tput civis
tput sc
        echo -n " > [ "; gprint "generate password" 0 "true"; echo " ]"
        echo "   [ password manager ]"
        echo "   [ exit ]"
selected=1
while true; do
	read -s -n 1 key
	case $key in
		'A')
			if [ "$selected" -eq 1 ]; then
				let "selected=3"
			else
				let "selected=selected-1"
			fi
			;;
		'B')
			if [ "$selected" -eq 3 ]; then
				let "selected=1"
			else
				let "selected=selected+1"
			fi
			;;
		'')
			break
			;;
        *)
            continue
            ;;
	esac
	tput rc

	if [ "$selected" -eq 1 ]; then
        echo -n " > [ "; gprint "generate password" 0 "true"; echo " ]"
        echo "   [ password manager ]"
        echo "   [ exit ]"
	fi
	if [ "$selected" -eq 2 ]; then
        echo "   [ generate password ]"
        echo -n " > [ "; gprint "password manager" 0 "true"; echo " ]"
        echo "   [ exit ]"
	fi
	if [ "$selected" -eq 3 ]; then
        echo "   [ generate password ]"
        echo "   [ password manager ]"
        echo -n " > [ "; gprint "exit" 0 "true"; echo " ]"
	fi
done
if [ $selected -eq 1 ]; then
    tput rc
    echo "                                                   "
    echo "                                                   "
    echo "                                                   "
    tput rc
    tput cnorm
    echo -n "["; gprint "?" 0 "true"; echo -n "] "; echo "please enter the lenth of the password (int)"
    tput sc
    while true; do
        read length
	re='^[0-9]+$'
        if [[ $length =~ $re ]]; then
            break
        else
            tput rc
            tput el
            tput rc
            continue
        fi
    done
    tput cuu 1
    tput el
    tput cuu 1
    tput el
    tput sc
    echo -n "["; gprint "?" 0 "true"; echo -n "] "; echo "Limit to standard characters? (y/n)"
    while true; do
	read -s -n 1 key
	case $key in
		y)
            option="yes"
			break
			;;
		n)
			option="no"
			break
			;;
		*)
			continue
			;;
	esac
    done 
    tput rc
    tput el
    tput sc
    if [ "$option" = "yes" ]; then
        password=$(generate1 $length)
        echo -n "the password that was generated is: "
        gprint2 "$password" 0.02 "false"
    else
        password=$(generate2 $length)
        echo -n "the password that was generated is: "
        gprint2 "$password" 0.02 "false"
    fi

    echo "save this password to password manager? (y/n)"
    while true; do
	read -s -n 1 key
	case $key in
		y)
            # not implimented yet lol
			break
			;;
		n)
			tput rc
            tput el
            echo ""
            tput el
            tput rc
            echo "return to main menu? (y/n)"
            while true; do
	            read -s -n 1 key
	            case $key in
		        y)
                    ./$0
                    clear
                    exit 1
			        break
			        ;;
		        n)
			        clear
                    exit 1
			        break
			        ;;
		        *)
			        continue
			        ;;
	            esac
            done

			break
			;;
		*)
			continue
			;;
	esac
    done 


fi
