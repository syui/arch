
##How to install Arch Linux

[Installation guide](https://wiki.archlinux.org/index.php/Installation_guide)

```bash
$ cat install.txt

# wi-fi
$ wifi-menu -o
$ ping google.com
```

- USB, MacBook Air, HP OMEN, Android, VirtualBox, Docker

- [git.io/air](https://git.io/air)

- command : disk last

```bash
# check
$ loadkeys jp106
$ curl -sL git.io/air

# install
$ zsh <<(curl -sL git.io/air)
or
$ curl -sL git.io/air | zsh
```

- command : disk sdx

```bash
$ fdisk -l
sdc

$ export x=c
$ curl -sL git.io/air | zsh
```

- user setting file :

[https://github.com/syui/arch/tree/master/json](https://github.com/syui/arch/tree/master/json)

```bash
## https://github.com/syui/arch/tree/master/json
$ export u=syui
$ curl -sL git.io/air | zsh
```

- air arch :

```bash
$ curl -sL git.io/airarch | zsh
```

###user : password

- root : root

- user : root

###setup.json

```json
[
    {
        "user" : "guest",
        "host" : "notebook",
        "disk" : "sda",
        "partition" : {
            "sda1" :
            {
                "type" : "vfat",
                "size" : "0 200"
            },
            "sda2" :
            {
                "type" : "ext4",
                "size" : "200 100%"
            }
        },
        "app" : "
        git
        net-tools
        wireless_tools wpa_supplicant wpa_actiond
        ",
        "yaourt" : "
        vim
        zsh
        ",
        "script" : "
        touch /root/git.io.air
        echo 'curl git.io/air' >> /root/git.io.air
        ",
        "comment" : "
        #reboot
        restart arch linux !!
        ",
        "reboot" : "true"
    }
]
```

###Network

####eth

```bash
$ systemctl start dhcpcd
$ systemctl enable dhcpcd

$ ifconfig
enp0

$ ifconfig enp0 up
```

####wifi

```bash
$ ifconfig 
wlan0

$ ifconfig wlan0 down

$ wifi-menu

$ ls /etc/netctl
wlan0MyESSID

$ netctl start wlan0MyESSID
$ netctl enable wlan0MyESSID
```

####ip stable

`192.168.1.24`

```bash
##eth
$ cp /etc/netctl/examples/ethernet-static /etc/netctl/eth0
$ cat /etc/netctl/eth0
Interface=eth0
Connection=ethernet
IP=static
Address=('192.168.1.24/25')
#Routes=('192.168.0.0/24 via 192.168.1.2')
Gateway='192.168.1.1
DNS=('192.168.1.1')

$ netctl start eth0
$ netctl enable eth0

##wifi
$ cat /etc/netctl/examples/ethernet-static >> /etc/netctl/wlan0MyESSID

$ netctl start wlan0MyESSID
$ netctl enable wlan0MyESSID
```

###SSH

```bash
##guest
$ pacman -S openssh

$ systemctl start sshd

$ systemctl enable sshd

$ ifconfig
192.168.1.24

##host
$ brew install ssh-copy-id

$ ssh root@192.168.1.24

$ vi /etc/ssh/sshd_config
Port 11023
PasswordAuthentication no
PermitRootLogin no

$ ssh-keygen -t rsa -f ~/.ssh/id_rsa_user

$ ssh-copy-id -i ~/.ssh/id_rsa_user.pub user_name@192.168.1.24

$ exit

##guest
$ systemctl restart sshd

##host
$ vi ~/.ssh/config
Host conect_name
    HostName 192.168.1.24
    Port 11023
    IdentityFile ~/.ssh/id_rsa_user
    User user_name 

$ ssh conect_name

or

$ ssh user_name@192.168.1.24 -p 11023 -i ~/.ssh/id_rsa_user
```

###Secrity

####firewall

```bash
$ cp /etc/iptables/empty.rules /etc/iptables/iptables.rules
$ cat /etc/iptables/iptables.rules

$ systemctl start iptables
$ systemctl enable iptables
```

###tor

```bash
## tor
$ sudo pacman -S tor
$ sudo cp /etc/tor/torrc-dist /etc/tor/torrc
$ tor &
$ sudo systemctl enable tor
$ export http_proxy=socks5://127.0.0.1:9050
$ export HTTP_PROXY=$http_proxy
$ curl ipinfo.io 

## vidalia
$ gpg --recv-keys 0x63FEE659
$ yaourt -S vidalia
$ vidalia
C-c
$ sudo cp ~/.vidalia/torrc /etc/tor/torrc
$ sudo systemctl enable tor
```

> ~/.zshrc

```bash
if ps -ax | grep -w tor | grep -v grep > /dev/null 2>&1;then
  case $OSTYPE in
    darwin*)
      alias chrome='open -a Google\ Chrome --args --proxy-server=="socks5://localhost:9050" --host-resolver-rules="MAP * 0.0.0.0, EXCLUDE localhost"'
    ;;
    linux*)
      alias chrome='chromium --proxy-server="socks://localhost:9050"'
    ;;
  esac
   #alias curl="curl --socks5 localhost:9050"
   export http_proxy=socks5://127.0.0.1:9050
   export https_proxy=$http_proxy
   export ftp_proxy=$http_proxy
   export rsync_proxy=$http_proxy
   export HTTP_PROXY=$http_proxy
   export HTTPS_PROXY=$http_proxy
   export FTP_PROXY=$http_proxy
   export RSYNC_PROXY=$http_proxy
   #export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
else
   unset http_proxy
   unset https_proxy
   unset ftp_proxy
   unset rsync_proxy
   unset no_proxy
   unset HTTP_PROXY
   unset HTTPS_PROXY
   unset FTP_PROXY
   unset RSYNC_PROXY
   unset NO_PROXY
fi
```

##Download Arch Linux

###download and checksum

```bash
repo_url="http://ftp.tsukuba.wide.ad.jp/Linux/archlinux/iso/latest"
curl -Ls ${repo_url}/md5sums.txt | grep 'dual.iso' | read md5 filename
curl -LO ${repo_url}/${filename}
case $OSTYPE in
  darwin*)
  if [ "${md5}" = "$(md5 -q ${filename} ]; then
    echo ok
  fi
  ;;
  linux*)
    if [ "${md5}" = "$(md5sum ${filename})" ]; then
      echo ok
    fi
  ;;
esac
```

```bash
## x=a
$ dd bs=1 if=./${filename} of=/dev/sdx && sync
## mac
$ sudo dd bs=1 if=./${filename} of=/dev/disk1
```

###antergos

[http://antergos.com/](http://antergos.com/)

###black arch

[https://github.com/BlackArch/blackarch](https://github.com/BlackArch/blackarch)

###manjaro linux

[https://manjaro.github.io/](https://manjaro.github.io/)

##Virtual Arch Linux

###vagrant

[https://github.com/elasticdog/packer-arch](https://github.com/elasticdog/packer-arch)

```bash
$ yaourt -S vagrant
$ git clone https://github.com/elasticdog/packer-arch.git
$ cd packer-arch/
$ packer build -only=virtualbox-iso arch-template.json
$ vagrant box add arch packer_arch_virtualbox.box
```

###docker

```bash
$ yaourt -S docker
$ sudo systemctl start docker
$ sudo docker pull base/archlinux
$ sudo docker run -t -i --rm archlinux /bin/bash
```

###systemd

```bash
$ mkdir -p ~/Container/{arch-base,arch-base-devel,arch-desktop}
$ sudo pacstrap -i -c -d ~/Container/arch-base base
$ sudo systemd-nspawn -bD ~/Container/arch-base
$ sudo mv ~/Container/arch-base /var/lib/container/arch-base
$ sudo systemctl start systemd-nspawn@arch-base
$ sudo systemctl enable systemd-nspawn@arch-base
```

##Icons

By [Aha-Soft Team](https://www.iconfinder.com/icons/386451/arch_linux_archlinux_icon)

