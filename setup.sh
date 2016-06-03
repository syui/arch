


if [ ! -f ./setup.json ];then
    url=https://raw.githubusercontent.com/syui/arch/master/json
    if [ "$1" != "" ];then
        user=$1
        if [ "`curl -sL "$url/${user}.json"`" != "Not Found" ];then
            curl -sL "$url/${user}.json" -o ./setup.json
        fi
    fi
    if [ "$u" != "" ];then
        user=$u
        if [ "`curl -sL "$url/${user}.json"`" != "Not Found" ];then
            curl -sL "$url/${user}.json" -o ./setup.json
        fi
    fi
else
    if [ `ls -1 | wc -l` -eq 2 ];then
        user=`ls | grep -v 'install.txt'`
        if [ "`curl -sL "$url/${user}.json"`" != "Not Found" ];then
            curl -sL "$url/${user}.json" -o ./setup.json
        fi
    fi
fi

if [ "`curl -sL ipinfo.io | grep country | cut -d '"' -f 4`" = "JP" -a "${SHELL##*/}" = "zsh" ];then
    cp -rf /etc/pacman.d/mirrorlist /etc
    zsh -c "cat /etc/mirrorlist | grep -A1 Japan >! /etc/pacman.d/mirrorlist"
    sed -i 's/--//g' /etc/pacman.d/mirrorlist
fi

if ! pacman -Sy ;then
    pacman-key --refresh-keys
    pacman -Sy
fi

url_jq=https://github.com/stedolan/jq/releases/download/jq-1.4/jq-linux-x86
case `getconf LONG_BIT` in
	64)
		url_jq=${url_jq}_64
		file_jq=${url_jq##*/}
		curl -sLO $url_jq
	;;
	32)
		file_jq=${url_jq##*/}
		curl -sLO $url_jq
	;;
esac

curl -sLO https://raw.githubusercontent.com/stedolan/jq/master/sig/v1.4/sha256sum.txt
check=`sha256sum -c sha256sum.txt`
if echo $check |grep OK > /dev/null 2>&1;then
	chmod +x $file_jq
	mv $file_jq /usr/bin/jq
else
	rm $file_jq
fi

if [ -f ./setup.json ];then
    if ! -f /usr/bin/jq > /dev/null 2>&1;then
        pacman -S --noconfirm jq
    fi
    if [ "$x" = "" ];then
        x=`cat ./setup.json | jq -r '.[].disk'`
        n=`cat ./setup.json | jq -r '.[].partition|length'`
        if [ "$x" != "" ];then
            for (( i=1;i<=${n};i++ ))
            do
                t=ext4
                f=`cat ./setup.json | jq -r ".[].partition|.${x}${i}|.type"`
                if [ $i -eq $n ];then
                    m=${m}"mkfs.${f} /dev/${x}${i}"
                else
                    m=${m}"mkfs.${f} /dev/${x}${i} && "
                fi
                s=`cat ./setup.json | jq -r ".[].partition|.${x}${i}|.size"`
                c=$c"-s mkpart primary $t $s "
            done
        else
            x=`fdisk -l | grep '/dev/sd' | grep 'Disk' | tail -n 1| cut -d : -f 1`
            x=`echo ${x##*/}`
        fi
    else
        x=sd${x}
    fi
else
    if [ "$x" != "" ];then
        x=sd${x}
    else
        #virtualbox
        x=`fdisk -l | grep '/dev/sd' | grep 'Disk' | tail -n 1| cut -d : -f 1`
        x=`echo ${x##*/}`
    fi
fi

if [ "$c" != "" ];then
    zsh -c "parted /dev/${x} -s mklabel gpt ${c} -s p"
    zsh -c "${m}"
    mount /dev/${x}2 /mnt
else
    parted /dev/${x} \
      -s mklabel gpt \
      -s mkpart primary ext2 0 200 \
      -s mkpart primary ext4 200 100% \
      -s p
    mkfs.vfat /dev/${x}1
    mkfs.ext4 /dev/${x}2
    mount /dev/${x}2 /mnt
fi

pacstrap /mnt base base-devel grub dhcpcd efibootmgr
genfstab -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash -c " pacman-db-upgrade; grub-install --force --recheck /dev/${x}; grub-mkconfig -o /boot/grub/grub.cfg; systemctl enable dhcpcd; pacman -S archlinux-keyring --noconfirm;"
#json
if [ -f ./setup.json ];then
    url=https://raw.githubusercontent.com/syui/arch/master/bin
    curl -sL $url/jq.sh | zsh
    a=`cat ./setup.json | jq -r '.[].app' | tr '\n' ' '`
    u=`cat ./setup.json | jq -r '.[].user'`
    h=`cat ./setup.json | jq -r '.[].host'`
    y=`cat ./setup.json | jq -r '.[].yaourt' | tr '\n' ' '`
    s=`cat ./setup.json | jq -r '.[].script'`
    c=`cat ./setup.json | jq -r '.[].comment'`
    r=`cat ./setup.json | jq -r '.[].reboot'`
else
    reboot
fi

# user
# [ -n one -z zero]
if [ "$h" != "" ];then
    if ! cat /mnt/etc/sudoers | tail -n 1 | grep '%wheel ALL' > /dev/null 2>&1;then
        echo -e 'Defaults env_keep += "HOME"\n%wheel ALL=(ALL) ALL' >> /mnt/etc/sudoers
        echo -e '%wheel ALL=(ALL) NOPASSWD: /usr/bin/pacman -Syu --noconfirm, /usr/bin/yaourt -Syua --noconfirm, /usr/bin/reboot, /usr/bin/poweroff' >> /mnt/etc/sudoers
    fi
    if [ ! -f /mnt/etc/hostname ];then
        echo $h > /mnt/etc/hostname
    fi
fi

if [ "$u" != "" ];then
    if [ ! -d /mnt/home/$u ];then
    arch-chroot /mnt /bin/bash -c "
    useradd -m -G wheel -s /bin/bash $u
    "
    fi
fi

if [ "`curl -sL ipinfo.io | grep country | cut -d '"' -f 4`" = "JP" ];then
    if ! cat /mnt/etc/locale.gen | tail -n 1 | grep 'ja_JP.UTF-8 UTF-8' > /dev/null 2>&1;then
        echo -e 'en_US.UTF-8 UTF-8\nja_JP.UTF-8 UTF-8' >> /mnt/etc/locale.gen
    fi
    if [ ! -f /mnt/etc/locale.conf ];then
        echo 'LANG=ja_JP.UTF-8' > /mnt/etc/locale.conf
    fi
    arch-chroot /mnt /bin/bash -c "
    ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
    timedatectl set-timezone Asia/Tokyo
    timedatectl set-ntp true
    "
fi
arch-chroot /mnt /bin/bash -c "
hwclock --systohc --utc
hwclock --systohc
echo root:root | chpasswd
echo $u:root | chpasswd
#locale-gen
"

#yaourt
if [ "$y" != "" ];then
    echo "yaourt -S $y"
    if ! grep 'repo.archlinux.fr' /mnt/etc/pacman.conf > /dev/null 2>&1;then
        echo -e '[archlinuxfr]\nSigLevel = Never\nServer = http://repo.archlinux.fr/$arch' >> /mnt/etc/pacman.conf
    fi
    arch-chroot /mnt /bin/bash -c "
    pacman -Sy yaourt --noconfirm
    echo -e 'SUDONOVERIF=1\nNOCONFIRM=1\nBUILD_NOCONFIRM=0\nEDITFILES=0' >> /etc/yaourtrc
    yaourt -Sy $y --noconfirm
    update-ca-trust
    "
fi

#install
if [ "$a" != "" ];then
    arch-chroot /mnt /bin/bash -c "
    pacman -Sy $a --noconfirm
    "
fi

#script
if [ "$s" != "" ];then
    arch-chroot /mnt /bin/bash -c "
    $s
    "
fi

#comment
if [ "$c" != "" ];then
    echo "$c"
fi

#reboot
if [ "$r" != "false" ];then
    reboot
fi
