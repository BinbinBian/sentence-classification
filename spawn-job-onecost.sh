#!/bin/bash:
GPU=0  #initialize
cnl="relu"  #initialize
lr_decay=0.95  #initialize
mode="add" #initializea
echo "$lr_decay"
function randomNum {
	# $RANDOM returns a different random integer at each invocation.
	# Nominal range: 0 - 32767 (signed 16-bit integer).
	let "RANGE=$1"
	echo

	let "FLOOR=$2"

	# Let's generate a random number within a given range
	number=0   #initialize
	while [ "$number" -le $FLOOR ]
	do
  		number=$RANDOM
  		let "number %= $RANGE"  # Scales $number down within $RANGE.
	done
	return $number
}

function randomBinary {
# Generate binary choice, that is, "true" or "false" value.
BINARY=2
T=1
number=$RANDOM

	let "number %= $BINARY"
	#  Note that    let "number >>= 14"    gives a better random distribution
	#+ (right shifts out everything except last binary digit).
	if [ "$number" -eq $T ]
	then
  		return $1
	else
  		return $2
	fi

	echo
}

function activationNum {
	# Generate a on random an initialisation.
	SPOTS=4   # Modulo 6 gives range 0 - 3.
    # Incrementing by 1 gives desired range of 1 - 4.
	die1=0
	# Would it be better to just set SPOTS=7 and not add 1? 
	# Tosses each die separately, and so gives correct odds.

    	let "die1 = $RANDOM % $SPOTS +1" # Roll first one.

	let "throw = $die1"
	return $throw
}

count=0
bs=50
while [ $count -le 6 ]
do
	GPU=$((GPU+1))
	if [ $GPU -eq 3 ]; then
		GPU=0
	fia
	let "count=$count+1"
	randomBinary "add" "mul"
	mode=$?
	randomNum 65 10
	dropout=$?
	echo "Dropout is --- $dropout"
	randomNum 100 10
	lr_decay=$?
	echo "Random number for lr_decay --- $lr_decay"
	randomNum 50 10
	alpha=$?
	let "beta=100-$alpha"
	echo "Setting alpha and beta to --- $alpha, $beta"
	activationNum
	activation=$?
	echo "Activation num: $activation"
	randomNum 10 7
	sqr_norm_lim=$?
	echo "sqr_norm_lim --- $sqr_norm_lim"
	echo "Starting job with batch size: $bs, dropout: $dropout, conv_non_linear: $cnl lr_decay: $lr_decay in mode: $mode on GPU: $GPU"
	echo "Starting Model 3 with MODE $mode"
	qsub -v BATCH_SIZE_F=$bs,DROPOUT_F=$dropout,CNL_F=$cnl,GPU_NO=$GPU,MODE=$mode,LR_DECAY=$lr_decay,ALPHA=$alpha,BETA=$beta,ACTIVATION=$activation,SQR_NORM_LIM=$sqr_norm_lim job4.sh
done

exit 0
