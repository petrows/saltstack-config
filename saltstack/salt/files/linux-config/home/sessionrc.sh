# Force all QT apps to use this theme
export QT_QPA_PLATFORMTHEME=qt5ct
# Force libreoffice to use this theme
export SAL_USE_VCLPLUGIN=gtk3
# Default apps scaling for HDPI
export GDK_DPI_SCALE={{ pillar.xsession.gtk_scale }}

# Start private autorun (if exists)
if [[ -x $HOME/bin/autorun ]]; then
    $HOME/bin/autorun
fi

{{ pillar.xsession.script|default('') }}
