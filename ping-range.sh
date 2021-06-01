#!/bin/bash

while getopts c:i:r:w: flag
do
    case "${flag}" in 
    c) COUNT=${OPTARG};;
	i) INTER=${OPTARG};;
    r) RANGE=${OPTARG};;
	w) WAIT=${OPTARG};;
esac
done

if [[ -z ${COUNT} ]]; then 
COUNT='10'
fi

if [[ -z ${INTER} ]]; then 
INTER='0.2'
fi

if [[ -z ${WAIT} ]]; then 
WAIT='3'
fi

if [[ -z ${RANGE} ]]; then 
echo "Nao foi especificado o range de IP "
echo "Exemplo de uso ./test_ping.sh -r 192.168.0.3-192.168.0.22 -c20 "
echo "Parametros que podem ser utilizados -i -w -c "
exit
else
IFS='-' #setting comma as delimiter  
read -a IPS <<<"$RANGE" #reading str as an array as tokens separated by IFS  
fi

fin1=$(echo ${IPS[0]} | tr "." " " | awk '{ print $4 }')
fin2=$(echo ${IPS[1]} | tr "." " " | awk '{ print $4 }')
oct1=$(echo ${IPS} | tr "." " " | awk '{ print $1 }')
oct2=$(echo ${IPS} | tr "." " " | awk '{ print $2 }')
oct3=$(echo ${IPS} | tr "." " " | awk '{ print $3 }')

if [ "$fin2" -gt "$fin1" ] ; then 
n=0
for (( c=$fin1; c<=$fin2; c++ ))do
  values=$(ping "$oct1.$oct2.$oct3.$c" -c${COUNT} -i${INTER} -w${WAIT} | grep transmitted)
  #echo "$oct1.$oct2.$oct3.$c $values"
  loss=$(echo $values | awk '{ print $6 }' )
  echo "$oct1.$oct2.$oct3.$c $values  loss:${loss}"
  if [ "$loss" = "0%" ];then
  n=$((n+1))
  elif  [ "$loss" = "100%" ];then
  offline+=("$oct1.$oct2.$oct3.$c OFFLINE")
  else
  perda+=("$oct1.$oct2.$oct3.$c PERDA:${loss}")
  fi
done
else
echo "Range incorreto! "
exit
fi

echo " "
echo " "
echo "Count= ${COUNT}"
echo "Intervalo= ${INTER}"
echo "Range= ${IPS[0]} ate ${IPS[1]}"
echo " "
echo " "
echo "IP(s) sinalizacao SIP online(s) sem perda(s) de pacote(s):$n de $((fin2-fin1+1))"
echo "IP(s) sinalizacao SIP offline(s):"
for i in "${offline[@]}"; do 
echo "$i"
done
echo "IP(s) de sinalizacao SIP com perda(s) de pacote(s):"
for i in "${perda[@]}"; do 
echo "$i"
done
