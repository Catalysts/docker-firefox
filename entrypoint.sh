#!/bin/bash

ARTIFACTS=/tmp/artifacts
DISPLAY=:1
SCREEN=0
RESOLUTION=1920x1080

mkdir -p $ARTIFACTS

function wrap() {
  $@ > $ARTIFACTS/$1.out 2> $ARTIFACTS/$1.err &
}

wrap Xvfb \
  $DISPLAY \
  -screen $SCREEN \
  ${RESOLUTION}x24

sleep 1

wrap x11vnc \
  -geometry $RESOLUTION \
  -display $DISPLAY \
  -shared \
  -forever \
  -passwd stsylatac

wrap avconv \
  -f x11grab \
  -s $RESOLUTION \
  -i $DISPLAY.$SCREEN+nomouse \
  -r 20 \
  -vcodec libvpx \
  $ARTIFACTS/screencast.webm

wrap tcpdump \
  -w $ARTIFACTS/tcpdump.pcap

DISPLAY=$DISPLAY wrap java -jar /opt/selenium/selenium-server-standalone.jar

while [ true ] ; do
  sleep 60
  echo heartbeat
done