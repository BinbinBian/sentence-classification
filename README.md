## Convolutional Neural Networks for Sentence Classification
Code influenced by the paper [Convolutional Neural Networks for Sentence Classification](http://arxiv.org/abs/1408.5882) (EMNLP 2014).

Runs the model on Pang and Lee's movie review dataset (MR in the paper).
It can also run the model on Stanford Natural Language Inference (SNLI) dataset.

### Requirements
Code is written in Python (2.7) and requires Theano (0.7).

Using the pre-trained `word2vec` vectors will also require downloading the binary file from
https://code.google.com/p/word2vec/


### Data Preprocessing
Open process_data.py and edit the path to the three snli.txt data files
To process the raw SNLI data, run

```
python process_snli.py /path-to-file/file.txt model >> /path/to/data/type.txt
e.g. python process_snli.py ../data/unprocessed/snli/snli_1.0_train.txt 1 >>../data/processed/train.txt

python process_data.py path/to/embedding False/True file-name.p
e.g. python process_data.py ../data/embeddings/word2vec.bin True ../data/snli-w2v-Split.p

Options for model = 1 will process a premise and hypothesis
	     			21 will process premise only
	     			22 will process hypothesis only

True/False - refers to whether or not to process SNLI dataset as one pair or index premises as 0 and
hypotheses with 1
embedding - refers to the path to a GloVe.txt or word2vec.bin embedding.
```
where path points to the word2vec binary file (i.e. `GoogleNews-vectors-negative300.bin` file). 
This will create a pickle object called `file-name.p` in the allocated folder.

Alternatively, one can process the MR dataset and use it to test the correctness of the model.
The results can be comapared with the paper [Convolutional Neural Networks for Sentence Classification](http://arxiv.org/abs/1408.5882) (EMNLP 2014).
```

python process_data.py path/to/embedding
```

Note: This will create the dataset with different fold-assignments than was used in the paper.
You should still be getting a CV score of >81% with CNN-nonstatic model, though.

### Running the models (CPU)
Example commands:

```
bash init-jobs.sh num times

Where num = 1 will run the baseline mode for either MR or SNLI
	  num > 1 will run the siamese model

Where times is the number of times you'd like the script to run (where 0 indicates 1 run).

Note the script calls a second script which is being sent to a cluster with which uses the Open Grid scheduler.
If you'd like to change that simply open job.sh and delete the "qsub" command infront of the THEANO_FLAGS
```

This will run the CNN-rand, CNN-static, and CNN-nonstatic models respectively in the paper.

### Using the GPU
GPU will result in a good 10x to 20x speed-up, so it is highly recommended. 
To use the GPU, simply change `device=cpu` to `device=gpu` (or whichever gpu you are using).
For example:
```
THEANO_FLAGS="mode=FAST_RUN,device=gpu,floatX=float32" python baseline.py -nonstatic -word2vec name.p

Where name.p is the pickle file's name (i.e. mr.p or snli-GloVe-Full.p)
```

### Example output
CPU output:
```
epoch: 1, training time: 219.72 secs, train perf: 81.79 %, val perf: 79.26 %
epoch: 2, training time: 219.55 secs, train perf: 82.64 %, val perf: 76.84 %
epoch: 3, training time: 219.54 secs, train perf: 92.06 %, val perf: 80.95 %
```
GPU output:
```
epoch: 1, training time: 16.49 secs, train perf: 81.80 %, val perf: 78.32 %
epoch: 2, training time: 16.12 secs, train perf: 82.53 %, val perf: 76.74 %
epoch: 3, training time: 16.16 secs, train perf: 91.87 %, val perf: 81.37 %
```

### Other Implementations
#### TensorFlow
[Denny Britz](http://www.wildml.com) has an implementation of the model in TensorFlow:

https://github.com/dennybritz/cnn-text-classification-tf

He also wrote a [nice tutorial](http://www.wildml.com/2015/12/implementing-a-cnn-for-text-classification-in-tensorflow) on it, as well as a general tutorial on [CNNs for NLP](http://www.wildml.com/2015/11/understanding-convolutional-neural-networks-for-nlp).

#### Torch
[HarvardNLP](http://harvardnlp.github.io/) group has an implementation in Torch.

https://github.com/harvardnlp/sent-conv-torch

### Hyperparameters
At the time of my original experiments I did not have access to a GPU so I could not run a lot of different experiments.
Hence the paper is missing a lot of things like ablation studies and variance in performance, and some of the conclusions
were premature (e.g. regularization does not always seem to help).

Ye Zhang has written a [very nice paper](http://arxiv.org/abs/1510.03820) doing an extensive analysis of model variants (e.g. filter widths, k-max pooling, word2vec vs Glove, etc.) and their effect on performance.
