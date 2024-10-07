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

generate_gradient() {
    local start_color=$1
    local end_color=$2
    local steps=$3
    local index=$4
    local char="$5"

    local start_r=$(( (start_color & 0xFF0000) >> 16 ))
    local start_g=$(( (start_color & 0x00FF00) >> 8 ))
    local start_b=$(( start_color & 0x0000FF ))
    local end_r=$(( (end_color & 0xFF0000) >> 16 ))
    local end_g=$(( (end_color & 0x00FF00) >> 8 ))
    local end_b=$(( end_color & 0x0000FF ))

    local r=$(( start_r + (end_r - start_r) * index / steps ))
    local g=$(( start_g + (end_g - start_g) * index / steps ))
    local b=$(( start_b + (end_b - start_b) * index / steps ))

    printf "\033[38;2;%d;%d;%dm%s\033[0m" "$r" "$g" "$b" "$char"
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












manager() {
    tput sc
    # Code for creating and setting up a vault if one doesn't exist already
    if [ ! -f "./psw.vault" ]; then
        echo -n "["; gprint "!" 0 "true"; echo -n "] "; echo "The vault file where the passwords are stored does not exist. Create one now? (y/n)"
        while true; do
            read -s -n 1 key
            case $key in
                y)  
                    sleep 1
                    echo "vault" > ./psw.vault
                    tput cuu 1
                    tput el
                    echo -n "["; gprint "+" 0 "true"; echo -n "] "; echo "Vault file created successfully."
                    echo -n "["; gprint "?" 0 "true"; echo -n "] "; echo "Please enter the master key to encrypt the vault, do not lose this."
                    tput cnorm
                    read psw
                    tput cuu 1
                    tput el
                    tput cuu 1
                    tput el
                    tput cuu 1
                    tput el
                    gpg --batch --yes --passphrase "$psw" -c --output "./psw.vault.gpg" ./psw.vault  # Use a different file for output
                    mv "./psw.vault.gpg" "./psw.vault"  # Overwrite the original vault file with the encrypted one
                    break
                    ;;
                n)
                    ./$0
                    clear
                    tput cnorm
                    exit 1
                    ;;
                *)
                    continue
                    ;;
            esac
        done 
    fi

    # Code for opening the vault
    echo -n "["; gprint "?" 0 "true"; echo -n "] "; echo "Please enter the key to open the vault"; echo -n "> "
    tput cnorm
    while true; do
        local input=""
        local char=""
        stty -echo

        # use magic to mask what the user is typing, idk i didnt write it

        while IFS= read -r -n 1 char; do
            if [[ $char == $'' ]]; then
                break
            fi
            input+="$char"
            printf "•"
        done

        psw1=$input

        stty echo
        echo

        # Decrypting using the entered passphrase
        decrypted_content=$(gpg --batch --yes --passphrase "$psw1" -d "./psw.vault" 2>/dev/null)  # Store in a variable
        if [ $? -ne 0 ]; then
            tput cuu 1
            tput el
            tput cuu 1
            tput el
            echo -n "["; gprint "!" 0 "true"; echo -n "] "; echo "The vault failed to open, likely due to an incorrect key. Please try again"; echo -n "> "
            continue
        else
            break
        fi
    done

    # Now that the vault is opened, its contents are stored in in $decrypted_content


    # ensure that what comes out is what went in
    idenitifyer=$(echo "$decrypted_content" | head -n 1)
    if [ ! $idenitifyer = "vault" ]; then
        echo -n "["; gprint "!" 0 "true"; echo -n "] "; echo "identifyer not found, there was likey a problem in the decryption or encryption, press any key to return to main menu"
        read -s -n 1
        ./$0
        clear
        tput cnorm
        exit 1
    fi

    edit_content="$decrypted_content"

    # adding each line other then the first one to a list (i might lose my mind)

    lines=()

    IFS=$'\n' read -rd '' -a content_list <<< "$decrypted_content"
    unset 'content_list[0]'

    tput cuu 1
    tput el
    tput cuu 1
    tput el

    if [ ! -z "$1" ]; then
        echo -n "["; gprint "?" 0 "true"; echo -n "] "; echo "please enter the user for this password"; echo -n "> "
        read username
        tput cuu 1
        tput el
        tput cuu 1
        tput el
        echo -n "["; gprint "?" 0 "true"; echo -n "] "; echo "please enter the website or platform this login is for"; echo -n "> "
        read platfrom
        tput cuu 1
        tput el
        tput cuu 1
        tput el
        echo -n "["; gprint "?" 0 "true"; echo -n "] "; echo "please enter the email being used for this login"; echo -n "> "
        read email
        add="$username,$1,$platfrom,$email"
        edit_content+="
$add"
        tput cuu 1
        tput el
        tput cuu 1
        tput el
        echo -n "["; gprint "?" 0 "true"; echo -n "] "; echo "save and close vault? (y/n)"
        while true; do
        read -s -n 1 key
        case $key in
            y)
                gpg --batch --yes --passphrase "$psw1" -c --output "./psw.vault.gpg" <<< "$edit_content"
                mv "./psw.vault.gpg" "./psw.vault"
                ./$0
                exit 1
                ;;
            n)
                break
                ;;
            *)
                continue
                ;;
        esac
    done 
    else
        tput sc
                echo -n " > [ "; gprint "veiw logins" 0 "true"; echo " ]"
        echo "   [ add login ]"
        echo "   [ close vault ]"


        selected2=1
        while true; do
            read -s -n 1 ke
            case $ke in
                'A')
                    if [ "$selected2" -eq 1 ]; then
                        let "selected2=3"
                    else
                        let "selected2=selected2-1"
                    fi
                    ;;
                'B')
                    if [ "$selected2" -eq 3 ]; then
                        let "selected2=1"
                    else
                        let "selected2=selected2+1"
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

            if [ "$selected2" -eq 1 ]; then
                echo -n " > [ "; gprint "veiw logins" 0 "true"; echo " ]"
                echo "   [ add login ]"
                echo "   [ close vault ]"
            fi
            if [ "$selected2" -eq 2 ]; then
                echo "   [ veiw logins ]"
                echo -n " > [ "; gprint "add login" 0 "true"; echo " ]"
                echo "   [ close vault ]"
            fi
            if [ "$selected2" -eq 3 ]; then
                echo "   [ veiw logins ]"
                echo "   [ add login ]"
                echo -n " > [ "; gprint "close vault" 0 "true"; echo " ]"
            fi
        done
        if [ $selected2 -eq 1 ]; then
        tput rc
        echo "                                                   "
        echo "                                                   "
        echo "                                                   "
        tput rc
        num=1
            for line in "${content_list[@]}"; do
                IFS=',' read -ra items <<< "$line"
                echo "$num. ${items[0]} @ ${items[2]}"
                let 'num+=1'
            done
        fi


    fi


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

start_color="0xef09f7"
end_color="0x7809f7"

while IFS= read -r line; do
    line_length=${#line}

    for ((i=0; i<line_length; i++)); do
        char="${line:i:1}"
        generate_gradient $start_color $end_color $line_length $i "$char"
    done

    echo
done <<< "$ascii"

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
    echo -n "["; gprint "?" 0 "true"; echo -n "] "; echo "please enter the lenth of the password (int)"; echo -n "> "
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
    tput civis
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
        echo -n "["; gprint "+" 0 "true"; echo -n "] "; echo -n "the password that was generated is: "
        gprint2 "$password" 0.02 "false"
    else
        password=$(generate2 $length)
        echo -n "["; gprint "+" 0 "true"; echo -n "] "; echo -n "the password that was generated is: "
        gprint2 "$password" 0.02 "false"
    fi

    echo -n "["; gprint "?" 0 "true"; echo -n "] "; echo "save this password to password manager? (y/n)"
    while true; do
	read -s -n 1 key
	case $key in
		y)
            tput rc
            tput el
            echo ""
            tput el
            tput rc
            manager "$password"
			break
			;;
		n)
			tput rc
            tput el
            echo ""
            tput el
            tput rc
            echo -n "["; gprint "?" 0 "true"; echo -n "] ";
            echo "return to main menu? (y/n)"
            while true; do
	            read -s -n 1 key
	            case $key in
		        y)
                    ./$0
                    clear
                    tput cnorm
                    exit 1
			        break
			        ;;
		        n)
			        clear
                    tput cnorm
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

if [ $selected -eq 2 ]; then
    tput rc
    echo "                                                   "
    echo "                                                   "
    echo "                                                   "
    tput rc
    manager
fi

if [ $selected -eq 3 ]; then
    clear
    tput cnorm
    exit 1
fi

tput cnorm
