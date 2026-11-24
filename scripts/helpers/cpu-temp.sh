#!/usr/bin/env bash
# Imprime la temperatura de la CPU en °C, sin depender de lm-sensors.
# Managed by Cyber-Tactical-Mint
read_first() {
  local f
  for f in "$@"; do
    [[ -r $f ]] || continue
    local v; v=$(<"$f")
    [[ $v =~ ^[0-9]+$ ]] && { echo $(( v / 1000 )); return 0; }
  done
  return 1
}

# 1) hwmon de CPU (Intel coretemp / AMD k10temp)
for h in /sys/class/hwmon/hwmon*; do
  [[ -r $h/name ]] || continue
  case $(<"$h/name") in
    coretemp|k10temp|zenpower|cpu_thermal)
      read_first "$h"/temp1_input && exit 0 ;;
  esac
done
# 2) zonas térmicas
for z in /sys/class/thermal/thermal_zone*; do
  [[ -r $z/type ]] || continue
  case $(<"$z/type") in
    x86_pkg_temp|cpu*|soc*) read_first "$z/temp" && exit 0 ;;
  esac
done
read_first /sys/class/thermal/thermal_zone0/temp && exit 0
echo "N/A"
