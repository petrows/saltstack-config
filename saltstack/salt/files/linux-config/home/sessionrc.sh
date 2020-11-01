export QT_QPA_PLATFORMTHEME=qt5ct
export GDK_DPI_SCALE={{ pillar.xsession.gtk_scale }}
# Force libreoffice to use QT5 theme
export SAL_USE_VCLPLUGIN=qt5

{{ pillar.xsession.script|default('') }}
