
if which pacman > /dev/null 2>&1;then
    pacman -Sy
    if ! which jq > /dev/null 2>&1;then
        pacman -S --noconfirm jq
    fi
fi

if [ -f ./setup.json ];then
    u=`cat setup.json | jq -r '.[].user'`
    h=`cat setup.json | jq -r '.[].host'`
    echo -e "user : $u\nhost : $h"
    a=`cat setup.json | jq -r '.[].app'`
    x=`cat setup.json | jq -r '.[].disk'`
    echo "$x : "
    n=`cat setup.json | jq -r '.[].partition|length'`
    yay=`cat setup.json | jq -r '.[].yay|.[]'`
    script=`cat setup.json | jq -r '.[].script|.[]'`
    comment=`cat setup.json | jq -r '.[].comment|.[]'`
    for (( i=1;i<=${n};i++ ))
    do
        echo -e "\t${x}${i} : "
        t=`cat setup.json | jq -r ".[].partition|.${x}${i}|.type"`
        echo -e "\t\ttype : $t"
        s=`cat setup.json | jq -r ".[].partition|.${x}${i}|.size"`
        echo -e "\t\ttype : $s"
    done
    echo "pacman : $a"
    echo "yay : $yay"
    echo "script : $script"
    echo "comment : $comment"
fi
