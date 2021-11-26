#!/usr/bin/bash

get_dest_addr(){ :
    ss -tulpan | 
        sed -rn "/$COMM/ s/(\S+\s+){5}(\S+):[0-9]+\s+.*$/\2/p" | 
        sort -u
}

read_org(){
        while read -r IP; do
                whois "$IP" | grep "^$whois_str" | tr  -s ' ' | cut -d' ' -f2- 
        done
}

get_list(){
    echo "run $0 whith arg name or pid"
    ss -tulpan | 
        sed -rn 's/.*\(\((.*),fd.*\)\)/\1/p' | 
        sort -u
    exit 
}

check_get_name(){
    ps -C "$1" -o comm= 2> /dev/null && return 0
    ps -p "$1" -o comm= 2> /dev/null && return 0
    return 1 
}

check_requrements(){ 
    declare -i status=0
    for i ; {
        command -v "$i" &> /dev/null \
            && err_str+="$i \033[36mFound\033[0m\n" \
            || { 
                err_str+="$i \033[31mNot Found\033[0m\n" 
                status=1
                }
        }
    (( status == 0 )) || echo -e "$err_str" 
    return $status
}

check_requrements ss sed sort ps whois grep tr cut || get_list
(( EUID == 0 )) || echo "non-owned process info will not be shown, you would have to be root to see it all.)"
(( $# == 1 )) || { echo "run whith 1 args"; get_list;} 
COMM="$(check_get_name "$1" | head -1)" 
[[ -z "$COMM" ]] && echo "command or pid - incorrect" && get_list

declare -i num_lines=5
whois_str=Organization

< <(get_dest_addr) read_org | sort | uniq -c | tail -$num_lines




: '
 создайте README.md и опишите, что будет делать ваш скрипт
yes     * скрипт должен принимать PID или имя процесса в качестве аргумента
yes     * количество строк вывода должно регулироваться пользователем
???     * должна быть возможность видеть другие состояния соединений
yes     * скрипт должен выводить понятные сообщения об ошибках
yes     * скрипт не должен зависеть от привилегий запуска, выдавать предупреждение
yes     ** скрипт выводит число соединений к каждой организации
yes     ** скрипт позволяет получать другие данные из вывода `whois`
yes		** скрипт умеет работать с `ss`, вы используете утилиты/built-ins, не вошедшие в однострочник
'
