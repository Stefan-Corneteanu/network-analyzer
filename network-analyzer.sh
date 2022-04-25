#!/bin/bash
ipfull=$1
lenstr=${#ipfull}
for (( i=0; i<$lenstr; i++))
do
	if [ ${ipfull:$i:1} = "/" ]
	then
		break
	fi
done
ip=${ipfull:0:$i}
maskno=${ipfull:$(($i+1)):2}
maskbin=""
for (( i=0; i<$maskno; i++ ))
do
	if [ $(($i%8)) -eq 0 -a $i -ne 0 ]
	then
		maskbin=$maskbin"."
	fi
	maskbin=$maskbin"1"
done
for (( i=$maskno; i<32; i++ ))
do
	if [ $(($i%8)) -eq 0 -a $i -ne 0 ]
	then
		maskbin=$maskbin"."
	fi
	maskbin=$maskbin"0"
done
notmaskbin=""
for (( i=0; i<${#maskbin}; i++ ))
do
	if [ ${maskbin:$i:1} = "1" ]
	then
		notmaskbin=$notmaskbin"0"
	elif [ ${maskbin:$i:1} = "0" ]
	then
		notmaskbin=$notmaskbin"1"
	elif [ ${maskbin:$i:1} = "." ]
	then
		notmaskbin=$notmaskbin"."
	fi 
done
ipbin=""
start=0
stop=0
for (( i=0; i<=${#ip}; i++ ))
do
	if [ ${ipfull:$i:1} = "." ] || [ $i -eq ${#ip} ]
	then
		stop=$i-1
		num=${ip:start:stop-start+1}
		if [ $(($num-128)) -ge 0 ]
		then
			ipbin=$ipbin"1"
			num=$(($num-128))
		else
			ipbin=$ipbin"0"
		fi
		if [ $(($num-64)) -ge 0 ]
		then
			ipbin=$ipbin"1"
			num=$(($num-64))
		else
			ipbin=$ipbin"0"
		fi
		if [ $(($num-32)) -ge 0 ]
		then
			ipbin=$ipbin"1"
			num=$(($num-32))
		else
			ipbin=$ipbin"0"
		fi
		if [ $(($num-16)) -ge 0 ]
		then
			ipbin=$ipbin"1"
			num=$(($num-16))
		else
			ipbin=$ipbin"0"
		fi
		
		if [ $(($num-8)) -ge 0 ]
		then
			ipbin=$ipbin"1"
			num=$(($num-8))
		else
			ipbin=$ipbin"0"
		fi
		if [ $(($num-4)) -ge 0 ]
		then
			ipbin=$ipbin"1"
			num=$(($num-4))
		else
			ipbin=$ipbin"0"
		fi
		
		if [ $(($num-2)) -ge 0 ]
		then
			ipbin=$ipbin"1"
			num=$(($num-2))
		else
			ipbin=$ipbin"0"
		fi
		
		if [ $(($num-1)) -ge 0 ]
		then
			ipbin=$ipbin"1"
		else
			ipbin=$ipbin"0"
		fi
		if [ $i -ne ${#ip} ]
		then
			ipbin=$ipbin"."
		fi
		start=$i+1
	fi
done
nwaddrbin=""
firstaddrbin=""
lastaddrbin=""
bcaddrbin=""
for (( i=0; i<${#ipbin}; i++ ))
do
	if [ ${ipbin:$i:1} = "." ]
	then
		nwaddrbin=$nwaddrbin"."
		bcaddrbin=$bcaddrbin"."
		continue
	fi
	if [ ${ipbin:$i:1} = "1" ] && [ ${maskbin:$i:1} = "1" ]
	then
		nwaddrbin=$nwaddrbin"1"
	else
		nwaddrbin=$nwaddrbin"0"
	fi
	if [ ${ipbin:$i:1} = "1" ] || [ ${notmaskbin:$i:1} = "1" ]
	then
		bcaddrbin=$bcaddrbin"1"
	else
		bcaddrbin=$bcaddrbin"0"
	fi
done
firstaddrbin=${nwaddrbin:0:$((${#nwaddrbin}-1))}
firstaddrbin=$firstaddrbin"1"
lastaddrbin=${bcaddrbin:0:$((${#bcaddrbin}-1))}
lastaddrbin=$lastaddrbin"0"
nostations=1
for (( i=0; i<$((32-$maskno)); i++ ))
do
	nostations=$(($nostations*2))
done
nostations=$(($nostations-2))
nwaddr=""
firstaddr=""
lastaddr=""
bcaddr=""
pow=7
numn=0
numf=0
numl=0
numb=0
for (( j=0; j<8; j++ ))
do
	bitn=${nwaddrbin:$j:1}
	bitf=${firstaddrbin:$j:1}
	bitl=${lastaddrbin:$j:1}
	bitb=${bcaddrbin:$j:1}
	
	if [ $bitn = "1" ]
	then
		for (( k=0; k<$pow; k++ ))
		do
			bitn=$(($bitn*2))
		done
		numn=$(($numn+$bitn))
	fi
	if [ $bitf = "1" ]
	then
		for (( k=0; k<$pow; k++ ))
		do
			bitf=$(($bitf*2))
		done
		numf=$(($numf+$bitf))
	fi
	if [ $bitl = "1" ]
	then
		for (( k=0; k<$pow; k++ ))
		do
			bitl=$(($bitl*2))
		done
		numl=$(($numl+$bitl))
	fi
	if [ $bitb = "1" ]
	then
		for (( k=0; k<$pow; k++ ))
		do
			bitb=$(($bitb*2))
		done
		numb=$(($numb+$bitb))
	fi
	pow=$(($pow-1))
done
nwaddr=$nwaddr$numn"."
firstaddr=$firstaddr$numf"."
lastaddr=$lastaddr$numl"."
bcaddr=$bcaddr$numb"."
for (( i=0; i<${#ipbin}; i++ ))
do
	if [ ${ipbin:$i:1} = "." ]
	then
		pow=7
		numn=0
		numf=0
		numl=0
		numb=0
		for (( j=0; j<8; j++ ))
		do
			bitn=${nwaddrbin:$(($i+$j+1)):1}
			bitf=${firstaddrbin:$(($i+$j+1)):1}
			bitl=${lastaddrbin:$(($i+$j+1)):1}
			bitb=${bcaddrbin:$(($i+$j+1)):1}
			
			if [ $bitn = "1" ]
			then
				for (( k=0; k<$pow; k++ ))
				do
					bitn=$(($bitn*2))
				done
				numn=$(($numn+$bitn))
			fi
			if [ $bitf = "1" ]
			then
				for (( k=0; k<$pow; k++ ))
				do
					bitf=$(($bitf*2))
				done
				numf=$(($numf+$bitf))
			fi
			if [ $bitl = "1" ]
			then
				for (( k=0; k<$pow; k++ ))
				do
					bitl=$(($bitl*2))
				done
				numl=$(($numl+$bitl))
			fi
			if [ $bitb = "1" ]
			then
				for (( k=0; k<$pow; k++ ))
				do
					bitb=$(($bitb*2))
				done
				numb=$(($numb+$bitb))
			fi
			pow=$(($pow-1))
		done
		nwaddr=$nwaddr$numn"."
		firstaddr=$firstaddr$numf"."
		lastaddr=$lastaddr$numl"."
		bcaddr=$bcaddr$numb"."
	fi
done
nwaddr=${nwaddr:0:$((${#nwaddr}-1))}
firstaddr=${firstaddr:0:$((${#firstaddr}-1))}
lastaddr=${lastaddr:0:$((${#lastaddr}-1))}
bcaddr=${bcaddr:0:$((${#bcaddr}-1))}
nwaddr=$nwaddr"/"$maskno
firstaddr=$firstaddr"/"$maskno
lastaddr=$lastaddr"/"$maskno
bcaddr=$bcaddr"/"$maskno
echo The network address is $nwaddr
echo The broadcast address is $bcaddr
echo The first address is $firstaddr
echo The last address is $lastaddr
echo The number of available stations is: $nostations