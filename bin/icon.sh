
theme_dir=/usr/share/icons/Numix
theme_24_dir=$theme_dir/24x24/status
theme_16_dir=$theme_dir/16x16/status
numix_24_dir=/usr/share/icons/Numix/24x24/status
hicolor_24_dir=/usr/share/icons/hicolor/24x24/status

#dropbox
if [ -d  /opt/dropbox/images/hicolor/16x16/status/ ];then
    cp -rf /usr/share/icons/Numix-Dark/Numix-Dark/16x16/status/*.png  /opt/dropbox/images/hicolor/16x16/status/
fi

# blueman
if which blueman > /dev/null 2>&1;then
    cp -rf ${theme_24_dir}/*.png ${hicolor_24_dir}
fi

# clipit
if which clipit > /dev/null 2>&1;then
    cp -rf ${numix_24_dir}/todo-indicator.svg /usr/share/icons/hicolor/scalable/apps/clipit-trayicon.svg
fi

# fcitx
if which fcitx > /dev/null 2>&1;then
    if [ -d /usr/share/Numix ];then
        cp -rf ${theme_24_dir}/indicator-keyboard-Ja.svg /usr/share/fcitx/skin/default/inactive.png
    fi
fi

# lilyterm
if which lilyterm > /dev/null 2>&1;then
    curl -sL https://raw.githubusercontent.com/syui/arch/master/icon/terminal.png -o /usr/share/pixmaps/lilyterm.png
fi
