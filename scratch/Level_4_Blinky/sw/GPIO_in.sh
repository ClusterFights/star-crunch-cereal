#!/bin/bash
echo $1 > /sys/class/gpio/export
[ -w /sys/class/gpio/gpio$1/direction ] && {
  echo in > /sys/class/gpio/gpio$1/direction
  echo -n "GPIO$1 ="; cat /sys/class/gpio/gpio$1/value
}

