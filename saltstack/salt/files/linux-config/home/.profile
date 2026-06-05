# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# # Force all QT apps to use this theme
# export QT_QPA_PLATFORMTHEME=qt{{ pillar.i3.qt_version }}ct
# # Force libreoffice to use this theme
# export SAL_USE_VCLPLUGIN=gtk3
# # Default apps scaling for HDPI
# export GDK_DPI_SCALE={{ pillar.xsession.gtk_scale }}
# export QT_FONT_DPI={{ pillar.xsession.qt_dpi }}
# export QT_AUTO_SCREEN_SET_FACTOR=0
# export QT_SCALE_FACTOR=1

export QT_QPA_PLATFORMTHEME=kde
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1  # use Sway's borders, not Qt's
export GTK_THEME=Breeze-Dark
export GTK_ICON_THEME=breeze-dark

# Ask python to use system CA bundle
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
