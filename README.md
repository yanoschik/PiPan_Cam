PiPan Cam
=========

A set of simple scripts used to control a pan-tilt camera setup on Raspberry Pi running [pi-blaster](https://github.com/sarfata/pi-blaster/) and optionally with [motioneye](https://github.com/ccrisan/motioneye).

![Setup example 1](/setup_example1.jpg)
![Setup example 2](/setup_example2.jpg)


## Prerequisites
 - [Raspberry Pi](https://www.raspberrypi.org/products/) with a Camera (eg. [this](https://www.raspberrypi.org/products/camera-module-v2/))
 - a pan-tilt setup: platform ([you google it](https://www.google.com/search?q=Pan%2FTilt+Camera+Platform)) and servos (eg. [SG90](https://www.google.com/search?q=SG90+servo))
 - installed [pi-blaster](https://github.com/sarfata/pi-blaster/)

## Features and usage
There are two main scripts, which do the work ...
<br/>Their job is to move the servos while watching limiting values and to keep track of the current position.

### pipan_set.sh
This script sets a specific position of the camera according to passed arguments in PWM %.

**But first change the script with your defaults:**
<br/>(You have to set the pins used for your servos and determine the limiting values where servos can reach - simply by shifting small steps.)

     ENABLED=1              # enables pi-blaster calls (set to 0 for testing)
     myfile="./pipandata"   # file storing current position
     vertical="0.13"        # default vertical position
     horizontal="0.2"       # default horizontal position
     v_pin=18               # pin for vertical servo
     h_pin=17               # pin for horizontal servo
     v_max="0.2"            # vertical max value (down for me)
     v_min="0.055"          # vertical min value (up for me)
     h_max="0.285"          # horizontal max value (left for me)
     h_min="0.06"           # horizontal min value (right for me)

**Example**

     sh pipan_set.sh 0.12 0.2

### pipan_step.sh
This script moves the camera by steps according to passed arguments.
<br/>Use positive and negative whole numbers.

**But first change the script with your defaults:**
<br/>*(two more than in previous script)*

     v_step="0.005"         # one vertical step
     h_step="0.005"         # one horizontal step

**Example**

     sh pipan_step.sh 2 -5 

*That would move my camera two steps down and five steps right (camera view).*

---
The second set of scripts is similar, just use input in degrees. 

### pipan_set_dg.sh
This script sets a specific position of the camera according to passed arguments in (relative) degrees.
<br/>Use values 0 to 180 _(or according to your defaults)_.

**But first change the script with your defaults:**
<br/>*(two more than in first script)*

     dg_min="0"             # degrees min value
     dg_max="180"           # degrees max value
     deci="4"               # decimals for rounding the result [internal]

Script actually re-maps your min/max pwm values to min/max degrees.

**Example**

     sh pipan_set_dg.sh 90 90 

*That would move both servos in the middle of their range.*

### pipan_step_dg.sh
This script moves the camera by steps in (relative) degrees.
<br/>Use positive and negative whole numbers.
<br/>_[Note: script is currently not very precise]_

**But first change the script with your defaults:**
<br/>*(two more than in first script)*

     dg_min="0"             # degrees min value
     dg_max="180"           # degrees max value
     deci="4"               # decimals for rounding the result [internal]

**Example**

     sh pipan_step_dg.sh 0 8 

*That would move my camera eight degrees left (camera view).*

### Notes
Don't forget to make the scripts executable:

     chmod +x script_name.sh

You'll need **bc** installed:

     sudo apt-get install bc

If you run into problems with starting pi-blaster like [this](https://github.com/sarfata/pi-blaster/issues/68), [this](https://github.com/sarfata/pi-blaster/issues/72), or [this](https://github.com/sarfata/pi-blaster/issues/71) ... You may have to create the default config with:

     touch /etc/default/pi-blaster

Consider powering the servos from an external source and not from the Pi ... especially if you intend to move something heavier (like a bigger camera maybe).

### Usage with motioneye
Current (2016/07/06) version of [motioneye](https://github.com/ccrisan/motioneye) only offers a limited way of interfacing external/custom commands... via action buttons - see [here](https://github.com/ccrisan/motioneye/wiki/Action-Buttons).
<br/>And you can use this to call your scripts, which move the camera simply by clicking overlay buttons within the camera view :)

I've set that up using the scripts in [examples](/examples/) folder like this:

     sudo cp <.yourfolder.>/PiPan_Cam/examples/pipan_go_home.sh /etc/motioneye/lock_1
     sudo cp <.yourfolder.>/PiPan_Cam/examples/pipan_step_left.sh /etc/motioneye/light_on_1
     sudo cp <.yourfolder.>/PiPan_Cam/examples/pipan_step_right.sh /etc/motioneye/light_off_1
     sudo cp <.yourfolder.>/PiPan_Cam/examples/pipan_step_down.sh /etc/motioneye/alarm_on_1
     sudo cp <.yourfolder.>/PiPan_Cam/examples/pipan_step_up.sh /etc/motioneye/alarm_off_1


## License
MIT License (MIT) - see [here](LICENSE.txt)

## Change Log
**v 1.1 - Jul 08, 2016**

* two more scripts - for movement by degrees
* readme update

**v 1.0 - Jul 06, 2016**

* Initial version

### Future plans / TODOs

- [x] ~~moving by degrees and to a specific degree~~
- [ ] precision of movement by degree steps
- [ ] optimization?
 