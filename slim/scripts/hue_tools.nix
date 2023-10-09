{pkgs, ...}:
pkgs.writeShellScriptBin "hue_tools" ''
  # $0 <group> on|off|status <brightness (percent)>" #

  # define connection hash and bridge IP
  hash="0Ulyfn-2F0d87E5nGLu8jWAiRF8B7-9jRB4t3u9b"
  bridge="192.168.1.207"


  # define input order
  group=$1
  state=$2
  bri=$3


  # light groups
  harry="14"
  su="15"
  all="1 2"


  # define lights
  if [ $group = "harry" ]; then
          lights="$harry"
  elif [ $group = "su" ]; then
          lights="$su"
  elif [ $group = "all" ]; then
          lights="$all"
  elif [ $group -eq $group ]; then
          lights="$group"
  fi


  # light on function
  light_on () {
          # determine brightness
          if [ -z $bri ]; then
                  bri=100
          fi
          bright=$(($bri*254/100))

          for light in $lights; do
                  ltype=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |sed -e 's/.*\"modelid/modelid/' -e 's/\,.*//' -e 's/type\": \"//' -e 's/\"//'`
                  if [ `echo $ltype |grep -c LWB00[46]` = 1 ]; then
                          type="white"
                          on=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f1 |cut -d\{ -f3 |cut -d: -f2`
                          if [ $on = "true" ]; then
                                  curl -X PUT -d '{"bri":'$bright'}' http://$bridge/api/$hash/lights/$light/state > /dev/null 2>&1
                          elif [ $on = "false" ]; then
                                  curl -X PUT -d '{"on":true,"bri":'$bright'}' http://$bridge/api/$hash/lights/$light/state > /dev/null 2>&1
                          fi
                  elif [ `echo $ltype |grep -c LCT00[12]` = 1 ]; then
                          type="hue"
                          on=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f1 |cut -d\{ -f3 |cut -d: -f2`
                          if [ $on = "true" ]; then
                                  curl -X PUT -d '{"ct":369,"bri":'$bright'}' http://$bridge/api/$hash/lights/$light/state > /dev/null 2>&1
                          elif [ $on = "false" ]; then
                                  curl -X PUT -d '{"on":true,"ct":369,"bri":'$bright'}' http://$bridge/api/$hash/lights/$light/state > /dev/null 2>&1
                          fi
                  elif [ `echo $ltype |grep -c LST001` = 1 ]; then
                          type="lightstrip"
                          on=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f1 |cut -d\{ -f3 |cut -d: -f2`
                          if [ $on = "true" ]; then
                                  curl -X PUT -d '{"ct":369,"bri":'$bright'}' http://$bridge/api/$hash/lights/$light/state > /dev/null 2>&1
                          elif [ $on = "false" ]; then
                                  curl -X PUT -d '{"on":true,"ct":369,"bri":'$bright'}' http://$bridge/api/$hash/lights/$light/state > /dev/null 2>&1
                          fi
                  fi
          done
  }


  # light off function
  light_off () {
          for light in $lights; do
                  on=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f1 |cut -d\{ -f3 |cut -d: -f2`
                  while [ $on = "true" ]; do
                          curl -X PUT -d '{"on":false}' http://$bridge/api/$hash/lights/$light/state > /dev/null 2>&1
                          on=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f1 |cut -d\{ -f3 |cut -d: -f2`
                  done
          done
  }


  # light status function
  light_status () {

  if [ -t 1 ]; then
          clear
  fi

          printf "%-3s %-18s %-14s %-10s %-10s %-10s %-10s\n" "#" "name" "type" "state" "reachable" "bri" "hue"
          echo "------------------------------------------------------------------------------"

          for light in $lights; do
                  unset state reach chue on bri type reachable name type
                  ltype=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |sed -e 's/.*\"modelid/modelid/' -e 's/\,.*//' -e 's/type\": \"//' -e 's/\"//'`
                  if [ `echo $ltype |grep -c LWB00[46]` = 1 ]; then
                          type="white"
                          on=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f1 |cut -d\{ -f3 |cut -d: -f2`
                          reachable=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f4 |cut -d: -f2 |sed 's/}//'`
                          name=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f6 |cut -d: -f2 |sed -e 's/}//' -e 's/"//' -e 's/\"//'`
                          if [ $on = "true" ]; then
                                  bri=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f2 |cut -d: -f2`
                          fi
                  elif [ `echo $ltype |grep -c LCT00[12]` = 1 ]; then
                          type="hue"
                          on=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f1 |cut -d\{ -f3 |cut -d: -f2`
                          reachable=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f11 |cut -d: -f2 |sed 's/}//'`
                          name=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f13 |cut -d: -f2 |sed -e 's/}//' -e 's/"//' -e 's/\"//'`
                          if [ $on = "true" ]; then
                                  hue=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f3 |cut -d: -f2 |sed 's/}//'`
                                  bri=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f2 |cut -d: -f2`
                          fi
                  elif [ `echo $ltype |grep -c LST001` = 1 ]; then
                          type="lightstrip"
                          on=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f1 |cut -d\{ -f3 |cut -d: -f2`
                          reachable=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f10 |cut -d: -f2 |sed 's/}//'`
                          name=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f12 |cut -d: -f2 |sed -e 's/}//' -e 's/"//' -e 's/\"//'`
                          if [ $on = "true" ]; then
                                  hue=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f3 |cut -d: -f2 |sed 's/}//'`
                                  bri=`curl -X GET -s "http://$bridge/api/$hash/lights/$light" |cut -d, -f2 |cut -d: -f2`
                          fi
                  fi

                  if [ $reachable = "true" ]; then
                          reach="YES"
                  else
                          reach="NO"
                  fi

                  if [ $on = "true" ]; then
                          state="ON"
                  else
                          state="OFF"
                  fi

                  if [ "$state" = "ON" ]; then
                          if [ "$type" = "hue" ]; then
                                  printf "%-3s %-18s %-14s %-10s %-10s %-10s %-10s\n" "$light" "$name" "$type" "$state" "$reach" "$bri" "$hue"
                          fi
                          if [ "$type" = "lightstrip" ]; then
                                  printf "%-3s %-18s %-14s %-10s %-10s %-10s %-10s\n" "$light" "$name" "$type" "$state" "$reach" "$bri" "$hue"
                          fi
                          if [ "$type" = "white" ]; then
                                  printf "%-3s %-18s %-14s %-10s %-10s %-10s\n" "$light" "$name" "$type" "$state" "$reach" "$bri"
                          fi
                  fi
                  if [ "$state" = "OFF" ]; then
                          printf "%-3s %-18s %-14s %-10s %-10s\n"  "$light" "$name" "$type" "$state" "$reach"
                  fi

          done
          echo ""
  }



  # perform action
  if [ $2 = "on" ]; then
          light_on
  elif [ $2 = "off" ]; then
          light_off
  elif [ $2 = "status" ]; then
          light_status
  fi
''
/*
   -- Hue Lighting Junk
lghtLvl l b   = "hue light " <> l <> " brightness " <> b
lghtOff l     = "hue light " <> l <> " off"
lghtOn  l     = "hue light " <> l <> " on"
blackOut      = "hue light 1 off && hue light 2 off && hue light 5 off && hue light 6 off && hue light 8 off && hue light 9 off && hue light 14 off && hue light 16 off && hue light 17 off && hue light 18 off && hue light 19 off && hue light 20 off && hue light 21 off && hue light 3 off "
screenLocker  = "betterlockscreen -l dim"
darkLights    = "hue light 1 off && hue light 2 off && hue light 5 off && hue light 6 off && hue light 8 off && hue light 9 off && hue light 14 off && hue light 16 off && hue light 17 relax && hue light 17 brightness 28% && hue light 18 off && hue light 19 off && hue light 20 off && hue light 21 off && hue light 3 relax"
chillLights   = "hue light 3 relax && hue light 14 relax && hue light 17 relax && hue light 8 relax && hue light 5 relax && hue light 6 relax && hue light 9 relax"
coldLights    = "hue light 3 concentrate && hue light 14 concentrate && hue light 17 concentrate && hue light 8 concentrate && hue light 5 concentrate && hue light 6 pink && hue light 9 concentrate"
*/

