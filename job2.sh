#!/bin/bash
export PATH=$PATH:/opt/cuda-7.5.18/bin:/opt/cuDNN-7.0:
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/s1579267/tools/OpenBLAS/lib:/opt/cuda-7.5.18/lib64:/opt/cuDNN-7.0/lib64:/opt/cuDNN-7.0:
export CUDA_ROOT=/opt/cuda-7.5.18
export MLP_WDIR=/home/s1045064/dissertation

cd /home/s1045064/dissertation/repo-diss/sentence-classification/
source /home/s1045064/dissertation/venv/bin/activate

#THEANO_FLAGS="device=gpu$MLP_GPU" python /home/s1045064/dissertation/repo-diss/sentence-classification/conv_net_sentence.py -static -word2vec #$MLP_NH $MLP_R
echo "Single Sentence Casei CNN 3"
THEANO_FLAGS="device=gpu" python /home/s1045064/dissertation/repo-diss/sentence-classification/cv_conv_net_sentence-newerversion.py
THEANO_FLAGS="device=gpu" python /home/s1045064/dissertation/repo-diss/sentence-classification/three.py
