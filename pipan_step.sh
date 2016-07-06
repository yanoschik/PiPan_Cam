#!/bin/bash
# pan-tilt moving by steps [using pi-blaster]
#  script expects 2 arguments (vertical and horizontal step)
#  setting is saved to file

# Defines and defaults
ENABLED=1              # enables pi-blaster calls (set to 0 for testing)
myfile="./pipandata"   # file storing current position
vertical="0.13"        # default position
horizontal="0.2"       # default position
v_pin=18               # pin for vertical servo
h_pin=17               # pin for horizontal servo
v_max="0.2"            # vertical max value (down for me)
v_min="0.055"          # vertical min value (up for me)
v_step="0.005"         # one vertical step
h_max="0.285"          # horizontal max value (left for me)
h_min="0.06"           # horizontal min value (right for me)
h_step="0.005"         # one horizontal step

# Read current position from file, or if not exists create it
if [ -e "$myfile" ]; then
  echo "File exists - current data: "
  cnt=0
  while IFS='' read -r line || [ -n "$line" ]; do
#    echo "$line"
    cnt=$((cnt + 1))
    if [ "$cnt" = 1 ]; then
     vertical="$line"
    fi
    if [ "$cnt" = 2 ]; then
     horizontal="$line"
    fi
  done < "$myfile"
  echo "V=$vertical, H=$horizontal"
else
  echo "File not found ...creating default."
  touch "$myfile"
  # Write default position to file
  echo  "$vertical\n$horizontal" > "$myfile"
  # Go to default position
  if [ "$ENABLED" = 1 ]; then
    echo "$v_pin=$vertical" > /dev/pi-blaster
    echo "$h_pin=$horizontal" > /dev/pi-blaster
  fi
fi

# Read and evaluate input arguments
if [ -z "$1" ]; then
  echo "Argument 1 missing!"
  exit 1
else
  step="$(echo $1*$v_step | bc)"
  vertical=$(printf "%.4f" "$(echo $vertical '+' $step | bc)")
fi

if [ -z "$2" ]; then
  echo "Argument 2 missing!"
  exit 1
else
  step="$(echo $2*$h_step | bc)"
  horizontal=$(printf "%.4f" "$(echo $horizontal '+' $step | bc)")
fi

# Check value boundaries
if [ "$(echo $vertical '>' $v_max | bc -l)" -eq 1 ]; then
  echo "Vertical too high! ($vertical > $v_max)"
  exit 1
else
  if [ "$(echo $vertical '<' $v_min | bc -l)" -eq 1 ]; then
    echo "Vertical too low! ($vertical < $v_min)"
    exit 1
#  else
#    echo "Vertical OK ($vertical)"
  fi
fi

if [ "$(echo $horizontal '>' $h_max | bc -l)" -eq 1 ]; then
  echo "Horizontal too high ! ($horizontal > $h_max)"
  exit 1
else
  if [ "$(echo $horizontal '<' $h_min | bc -l)" -eq 1 ]; then
    echo "Horizontal too low! ($horizontal < $h_min)"
    exit 1
#  else
#    echo "Horizontal OK ($horizontal)"
  fi
fi

# Set new position
echo "New position: "
echo "V=$vertical, H=$horizontal"
if [ "$ENABLED" = 1 ]; then
  echo "$v_pin=$vertical" > /dev/pi-blaster
  echo "$h_pin=$horizontal" > /dev/pi-blaster
fi
echo "$vertical\n$horizontal" > "$myfile"

exit 0
