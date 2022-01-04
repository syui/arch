## install Arch Linux


```sh
$ curl -sL git.io/air|bash
```

### set disk

```sh
$ fdisk -l
sdc

$ export x=c
$ curl -sL git.io/air | zsh
```

### set user

```sh
$ export u=syui
$ curl -sL git.io/air | zsh
```

```sh
# or
$ curl -sLO git.io/air
$ zsh air syui

# or
$ curl -sL git.io/airarch | zsh
```

### user : password

- root : root

- arch : arch

```sh
$ packer build packer/arch.json
$ vagrant box add syui/arch ./arch.box --force
$ vagrant up
```

