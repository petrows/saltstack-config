# Soundcore Q30 linux connection fix

The Soundcore Life Q30 headset is nice, but having
some problems under linux:

* Connects without audio profiles
* Connects with profiles, but audio sink is not added
* Connects with profile and sink, but does not switch
profile headset / music

## Fix audio profile

To fix that, please use the following method.

Install required software:

```bash
sudo apt install pulseaudio-utils rfkill bluez
```

Copy scripts to your bin folder (user, or system):

```bash
cp saltstack/salt/files/linux-config/bin-local-pc/bt-force-profile ~/bin/
cp saltstack/salt/files/linux-config/bin-local-pc/soundcore-a2dp ~/bin/
cp saltstack/salt/files/linux-config/bin-local-pc/soundcore-hf ~/bin/
chmod +x ~/bin/*
```

Connect and pair your device, also set it to trust device.

Start script (select proper option):

```bash
# Auto find device and set to HEADSET mode
soundcore-hf
# Auto find device and set to MUSIC mode
soundcore-a2dp

# Or, select device by MAC and set profiles
# Headset
bt-force-profile handsfree_head_unit AC:12:2F:E0:12:34
# Music
bt-force-profile a2dp_sink AC:12:2F:E0:12:34
```

Wait some time. If device does not fixed in minute, turn headset off,
then turn it back on (and connect it, if not connected automatically).
Keep script running in background.

Device will connect with desired profile and will allow runtime selection.

## Control headset

You can also control device (select ANC or TRansparent mode, Equalizer, etc).

To do this, copy scripts:

```bash
cp saltstack/salt/files/linux-config/bin-local-pc/AnkerSoundcoreAPI.py ~/bin/
cp saltstack/salt/files/linux-config/bin-local-pc/soundcore-anc ~/bin/
cp saltstack/salt/files/linux-config/bin-local-pc/soundcore-transparent ~/bin/
chmod +x ~/bin/*
```

Switch device to ANC mode:

```bash
# Audo find device and switch modes
soundcore-anc
soundcore-transparent

# Or, select device by MAC and switch modes
AnkerSoundcoreAPI.py -AmbientSound ANC AC:12:2F:E0:12:34
AnkerSoundcoreAPI.py -AmbientSound Transparency AC:12:2F:E0:12:34

# Select equalizer profile
AnkerSoundcoreAPI.py -EQPresets "Acoustic" "AC:12:2F:E0:12:34"

# Full list of options
AnkerSoundcoreAPI.py
```

Enjoy! :-)
