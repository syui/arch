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

if ! -f /usr/bin/jq > /dev/null 2>&1;then
    pacman -S --noconfirm jq
fi

if [ -f ./setup.json ];then

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

pacstrap /mnt base base-devel grub dhcpcd efibootmgr linux zsh git tmux vim atool net-tools vagrant ansible openssh
genfstab -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash -c "pacman-db-upgrade; grub-install --force --recheck /dev/${x}; grub-mkconfig -o /boot/grub/grub.cfg; systemctl enable dhcpcd;systemctl enable sshd;pacman -S archlinux-keyring --noconfirm;"

if [ -f ./setup.json ];then
    url=https://raw.githubusercontent.com/syui/arch/master/bin
    curl -sL $url/jq.sh | zsh
    a=`cat ./setup.json | jq -r '.[].app' | tr '\n' ' '`
    u=`cat ./setup.json | jq -r '.[].user'`
    h=`cat ./setup.json | jq -r '.[].host'`
    s=`cat ./setup.json | jq -r '.[].script'`
    c=`cat ./setup.json | jq -r '.[].comment'`
    r=`cat ./setup.json | jq -r '.[].reboot'`
fi

echo -e 'Defaults env_keep += "HOME"\n%wheel ALL=(ALL) ALL' >> /mnt/etc/sudoers
echo -e '%wheel ALL=(ALL) NOPASSWD: /usr/bin/pacman -Syu --noconfirm, /usr/bin/reboot, /usr/bin/poweroff' >> /mnt/etc/sudoers

u=arch

if [ ! -f /mnt/etc/hostname ];then
     echo $u > /mnt/etc/hostname
fi

arch-chroot /mnt /bin/bash -c "
hwclock --systohc --utc
hwclock --systohc
echo root:root | chpasswd
"

arch-chroot /mnt /bin/bash -c "useradd -m -G wheel -s /bin/bash $u;echo $u:$u | chpasswd"

arch-chroot /mnt /bin/bash -c "su $u -c 'mkdir -p /home/arch/.ssh;curl --output /home/arch/.ssh/authorized_keys --location https://raw.github.com/syui/arch/master/keys/vagrant.pub';
su $u -c 'git clone https://github.com/elnappo/dotfiles /home/arch/dotfiles'
"

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

#reboot
if [ "$r" != "false" ];then
    reboot
fi
