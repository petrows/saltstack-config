
server-software:
  pkg.installed:
    - pkgs:
      # Linux kernel headers for version 6.14.0
      # - linux-headers-6.14.0-112033-tuxedo
      # TUXEDO Linux kernel headers
      # - linux-headers-tuxedo-24.04
      # Linux kernel image for version 6.14.0
      # - linux-image-6.14.0-112033-tuxedo
      # TUXEDO Linux kernel image
      # - linux-image-tuxedo-24.04
      # Linux kernel extra modules for version 6.14.0
      # - linux-modules-6.14.0-112033-tuxedo
      # Linux kernel extra modules for version 6.14.0
      # - linux-modules-extra-6.14.0-112033-tuxedo
      # Complete TUXEDO Linux kernel and headers generic package name
      - linux-tuxedo
      # Complete TUXEDO Linux kernel and headers
      # - linux-tuxedo-24.04
      # theme for sddm
      - sddm-theme-tuxedo
      # GnuPG archive keys of the tuxedo archive
      - tuxedo-archive-keyring
      # TUXEDO system miscellaneous files
      # - tuxedo-base-files
      # Common settings (installed mode)
      - tuxedo-common-settings
      # Tuxedo control center
      - tuxedo-control-center
      # Add easy ways to launch programms on dGPU on optimus devices
      - tuxedo-dgpu-run
      # Kernel modules for TUXEDO devices
      - tuxedo-drivers
      # grub-theme for tuxedo
      # - tuxedo-grub-theme
      # Shows Linux System Information with Distribution Logo
      - tuxedo-neofetch
      # boot animation, logger and I/O multiplexer
      - tuxedo-plymouth
      # boot animation, logger and I/O multiplexer - label control
      - tuxedo-plymouth-label
      # boot animation, logger and I/O multiplexer - spinner theme
      - tuxedo-plymouth-theme-spinner
      # TUXEDO Plasma Theme
      # - tuxedo-theme-plasma
      # little helper that provides services, updates and fixes for TUXEDO devices
      - tuxedo-tomte
      # Toggles the touchpad and the attached disabled-LED on Uniwill/Tongfang laptops.
      - tuxedo-touchpad-switch
      # default ufw profiles
      - tuxedo-ufw-profiles
      # Wallpapers for tuxedo
      # - tuxedo-wallpapers-2204
      # Wallpapers for tuxedo
      # - tuxedo-wallpapers-2404
      # TUXEDO WebFAI Creator is the easiest way to prepare an USB pendrive for TUXEDO’s own Fully Automated Installation (WebFAI). It protects you from accidentally writing to your hard-drives, ensures every byte of data was written correctly and much more. Please visit https://webfai.de for more details on WebFAI.
      - tuxedo-webfai-creator
      # grub menu entry for TUXEDO Webfai
      - tuxedo-webfai-grub
      # Driver for Motorcomm YT6801
      - tuxedo-yt6801
      # TUXEDO OS Plasma Desktop system
      - tuxedoos-desktop

# tuxedo-blacklisted:
#   pkg.purged:
#     - pkgs:
#       # TUXEDO OS Plasma Desktop system
#       - tuxedoos-desktop
