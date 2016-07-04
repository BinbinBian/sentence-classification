#!/bin/bash:

####### Initialize Parameters #######
GPU=0
cnl="relu"
lr_decay=0.95
mode="add" 
dropout=0.5
activation=3
sqr_norm_lim=9

####### Define Functions #######

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
if [ $1 -eq 1 ]; then
	randomNum 2 0
	GPU_NO=$?
	qsub -v BATCH_SIZE_F=$bs,DROPOUT_F=$dropout,CNL_F=$cnl,GPU_NO=$GPU,LR_DECAY=$lr_decay,ACTIVATION=$activation,SQR_NORM_LIM=$sqr_norm_lim job-baseline.sh
	
else
	#id=`python select_gpu.py`
	while [ $count -le 10 ]
	do
		GPU=$((GPU+1))
		if [ $GPU -eq 3 ]; then
			GPU=0
		fi
		let "count=$count+1"
		randomNum 40 10
		num=$?
		mode="add"
		if [ $num -le 10 ]; then
			mode="mul"
		elif [ $num -le 20 ]; then
			mode="concat"
		elif [ $num -le 30 ]; then
			mode="circ"
		fi
		#mode="add"
        randomNum 20 10
        num=$?
		cnl="tanh"
		if [ $num -le 15 ]; then
			cnl="relu"
		fi
		cnl="relu"
		randomNum 50 20
		#dropout=20
		dropout=$?
		echo "Dropout is --- $dropout"
		randomNum 94 85
		lr_decay=$?
		#lr_decay=95
		echo "Random number for lr_decay --- $lr_decay"
		randomNum 50 30
		alpha=$?
		#alpha=40
		#alpha=100
		let "beta=100-$alpha"
		echo "Setting alpha and beta to --- $alpha, $beta"
		activationNum
		activation=$?
		#activation=3
		echo "Activation num: $activation"
		randomNum 10 6
		sqr_norm_lim=$?
		#sqr_norm_lim=9
		echo "sqr_norm_lim --- $sqr_norm_lim"
		echo "Starting job with batch size: $bs, dropout: $dropout, conv_non_linear: $cnl lr_decay: $lr_decay in mode: $mode on GPU: $GPU"
		echo "Starting Model 3 with MODE $mode"
		qsub -v BATCH_SIZE_F=$bs,DROPOUT_F=$dropout,CNL_F=$cnl,GPU_NO=$GPU,MODE=$mode,LR_DECAY=$lr_decay,ALPHA=$alpha,BETA=$beta,ACTIVATION=$activation,SQR_NORM_LIM=$sqr_norm_lim job4.sh
	done
fi


exit 0