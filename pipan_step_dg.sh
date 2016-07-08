#!/bin/bash
# pan-tilt moving by degree step [using pi-blaster]
#  script expects 2 arguments (vertical and horizontal degrees step)
#  setting is saved to file

# Defines and defaults
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
dg_min="0"             # degrees min value
dg_max="180"           # degrees max value
deci="4"               # decimals for rounding the result

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
fi

if [ -z "$2" ]; then
  echo "Argument 2 missing!"
  exit 1
fi

# rounding
# [http://stackoverflow.com/questions/26861118/rounding-numbers-with-bc-in-bash | http://askubuntu.com/questions/179898/how-to-round-decimals-using-bc-in-bash]
round()
{
  # $1 is expression to round (should be a valid bc expression)
  # $2 is number of decimal figures (optional). Defaults to three if none given
  local df=${2:-3}
  printf '%.*f' $df $(echo "a=$1; if(a>0) a+=5/10^($df+1) else if (a<0) a-=5/10^($df+1); scale=$df; a/1" | bc -l)
}

# mapping from input to output range
# [http://math.stackexchange.com/questions/377169/calculating-a-value-inside-one-range-to-a-value-of-another-range]
map()
{
  # $1 is value to be mapped
  # $2 is input min
  # $3 is input max
  # $4 is output min
  # $5 is output max
  local scl=10 # scale
  echo "$(echo 'scale='$scl';(' $1 '-' $2 ') * ((' $5 '-' $4 ') / (' $3 '-' $2 ')) +' $4 | bc -l)"
}

# Map to new position
v_deg="$(echo $(round $(map $vertical $v_min $v_max $dg_min $dg_max) $deci) '+' $1 | bc -l)"
h_deg="$(echo $(round $(map $horizontal $h_min $h_max $dg_min $dg_max) $deci) '+' $2 | bc -l)"
#echo "V:$v_deg, H:$h_deg"
vertical="$(round $(map $v_deg $dg_min $dg_max $v_min $v_max) $deci)"
horizontal="$(round $(map $h_deg $dg_min $dg_max $h_min $h_max) $deci)"

# Check value boundaries
if [ "$(echo $vertical '>' $v_max | bc -l)" -eq 1 ]; then
  echo "Vertical too high! ($vertical [$v_deg] > $v_max [$dg_max])"
  exit 1
else
  if [ "$(echo $vertical '<' $v_min | bc -l)" -eq 1 ]; then
    echo "Vertical too low! ($vertical [$v_deg] < $v_min [$dg_min])"
    exit 1
#  else
#    echo "Vertical OK ($vertical)"
  fi
fi

if [ "$(echo $horizontal '>' $h_max | bc -l)" -eq 1 ]; then
  echo "Horizontal too high ! ($horizontal [$h_deg] > $h_max [$dg_max])"
  exit 1
else
  if [ "$(echo $horizontal '<' $h_min | bc -l)" -eq 1 ]; then
    echo "Horizontal too low! ($horizontal [$h_deg] < $h_min [$dg_min])"
    exit 1
#  else
#    echo "Horizontal OK ($horizontal)"
  fi
fi

## Set new position
echo "New position: "
echo "V=$v_deg ($vertical), H=$h_deg ($horizontal)"
if [ "$ENABLED" = 1 ]; then
  echo "$v_pin=$vertical" > /dev/pi-blaster
  echo "$h_pin=$horizontal" > /dev/pi-blaster
fi
echo "$vertical\n$horizontal" > "$myfile"

exit 0
