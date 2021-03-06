"""
Sample code for modelling entailments with CNNs.
This work was influenced from: http://arxiv.org/abs/1408.5882
This implementation supports SNLI and MR datasets.
The latter is only used for the basic model which is used as a
means of verification that the implementation achieves the results
presented in the paper referenced above. The SNLI dataset can be used
for both basic and complex implementations as hinted below.

Much of the code is modified from
- deeplearning.net (for ConvNet classes)
- https://github.com/mdenil/dropout (for dropout)
- https://groups.google.com/forum/#!topic/pylearn-dev/3QbKtCumAW4 (for Adadelta)
- https://github.com/yoonkim/CNN_sentence

@author: Todor Davchev
@date: 23.07.2016
"""
import cPickle
import numpy as np
from collections import defaultdict, OrderedDict
import theano
import theano.tensor as T
import theano.tensor.signal.conv
import re
import warnings
import sys
import time
warnings.filterwarnings("ignore")

if __name__=="__main__":
    '''
    file_name         - specify the pickle file which contains the SNLI dataset
                        with GloVe or word2vec embeddings.
    word_vectors      - specify embedding type (i.e. rand, word2vec or GloVe)
    mode              - static or nonstatic
    batch_size_f      - specify the batch size
    dropout_rate_f    - specify the dropout rate
    conv_non_linear_f - specify the convolution non linear function (i.e. relu or tanh)
    modeOp            - specify the mode to run as follows: [concat, add, sub, mul, circ, mix1-9]
                        (see models/three-cnns.py for details)
    lr_decay          - learning rate decay
    alpha             - first weight for weighted addition and subtraction
    beta              - second weight for weighted addition and subtraction
    whichAct          - specify (1 to 4) which activation function to use: [ReLU, Sigmoid, Tanh, Iden]
    sqr_norm_lim      - s^2 in the paper referenced above.
    which_model       - basic which refers to the baseline or complex which refers to the extended Siamese models                    
    '''

    # Set Parameters
    file_name = sys.argv[1]
    word_vectors = sys.argv[2]
    mode= sys.argv[3]
    batch_size_f = sys.argv[4]
    batch_size_f = int(batch_size_f)
    dropout_rate_f = sys.argv[5]
    dropout_rate_f = float(dropout_rate_f)
    conv_non_linear_f = sys.argv[6]
    modeOp = sys.argv[7]
    lr_decay = sys.argv[8]
    lr_decay = float(lr_decay)
    lr_decay /= 100
    alpha = sys.argv[9]
    alpha = float(alpha)
    alpha /= 100
    beta = sys.argv[10]
    beta = float(beta)
    beta /= 100
    whichAct = sys.argv[11]
    whichAct = int(whichAct)-1
    sqr_norm_lim = sys.argv[12]
    sqr_norm_lim = int(sqr_norm_lim)
    which_model = sys.argv[13]

    print "loading data..."
    sys.stdout.flush()
    print file_name
    x = cPickle.load(open(file_name,"rb"))
    revs, W, W2, word_idx_map, vocab = x[0], x[1], x[2], x[3], x[4]
    print "data loaded!"
    sys.stdout.flush()

    if dropout_rate_f > 0:
        dropout_rate_f /= 100
    else:
        dropout_rate_f = 0 

    # The MR dataset uses cross validation as opposed to SNLI
    if "snli" in file_name:
        cv = False
    else:
        cv = True

    if "GloVe" in file_name:
        if word_vectors != "-rand":
            word_vectors = "-glove"

    if which_model == "basic":
        model = "baseline"
        model_type = "basic"
    else:
        model = "three-cnns"
        model_type = "extended"
    
    if mode=="-nonstatic":
        print "model architecture: CNN-non-static"
        sys.stdout.flush()
        non_static=True
    elif mode=="-static":
        print "model architecture: CNN-static"
        sys.stdout.flush()
        non_static=False

    first_sent = []  # note currently takes the output of the convolution layers and not the predictions
    second_sent = [] # I need to try it with predictions as well
    execfile("utils/conv_net_classes.py")
    execfile("utils/arithmetics.py")
    execfile("utils/helpers.py")
    execfile("utils/"+model_type+".py")
    execfile("models/"+model+".py")
    if word_vectors=="-rand":
        print "using: random vectors"
        sys.stdout.flush()
        U = W2
    elif word_vectors=="-word2vec":
        print "using: word2vec vectors"
        sys.stdout.flush()
        U = W
    elif word_vectors == "-glove":
        print "using: GloVe vectors"
        sys.stdout.flush()
        U = W
    results = []
    if which_model=="basic":
        if cv:
            r = range(0,10)    
            for i in r:
                datasets = make_idx_data_cv(revs, word_idx_map, i, max_l=51,k=300, filter_h=7)
                print "datasets configured."
                sys.stdout.flush()
                perf = train_conv_net(datasets,
                    U,
                    lr_decay=0.95,
                    filter_hs=[2,3,4,5],
                    conv_non_linear="relu",
                    hidden_units=[100,2], 
                    shuffle_batch=True, 
                    n_epochs=25, 
                    sqr_norm_lim=9,
                    non_static=non_static,
                    batch_size=50,
                    dropout_rate=[0.5],
                    cv=True)
                print "cv: " + str(i) + ", perf: " + str(perf)
                results.append(perf)  
        else:
            datasets = make_idx_data(revs, word_idx_map, max_l=118, k=300, filter_h=5)
            print "datasets configured."
            sys.stdout.flush()
            activations = [ReLU, Sigmoid, Tanh, Iden]
            results = []
            perf = train_conv_net(datasets,
               U,
               lr_decay=lr_decay,
               filter_hs=[3,4,5],
               conv_non_linear=conv_non_linear_f,
               hidden_units=[100,3], 
               shuffle_batch=True, 
               n_epochs=25, 
               sqr_norm_lim=sqr_norm_lim,
               non_static=non_static,
               batch_size=batch_size_f,
               dropout_rate=[dropout_rate_f],
               cv=False)
            results.append(perf)
        
        print str(np.mean(results))
        sys.stdout.flush()
    else:
        datasets = make_idx_data(revs, word_idx_map, max_l=81,k=300, filter_h=7)
        print "datasets configured."
        sys.stdout.flush()
        activations = [ReLU, Sigmoid, Tanh, Iden]
        perf = train_conv_net(datasets,
           U,
           img_w=300,
           filter_hs=[2,3,4,5],
           hidden_units=[100,3],
           dropout_rate=[dropout_rate_f],
           shuffle_batch=True,
           n_epochs=10,
           batch_size=batch_size_f,
           lr_decay = lr_decay,
           conv_non_linear=conv_non_linear_f,
           activations=[activations[whichAct]],
           sqr_norm_lim=sqr_norm_lim,
           non_static=non_static,
           modeOp=modeOp,
           alpha=alpha,
           beta=beta)

        results.append(perf)
        print str(np.mean(results))
        sys.stdout.flush()
