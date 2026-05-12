#! /usr/bin/env python3
## KmerVector.py ---------------------------------------------------------
## Summary: Python script to create kmer features from protein sequences based on protein language methods
## Author: Rafael Bargiela, PhD
## Source: https://www.kaggle.com/code/mohdmuttalib/biological-sequence-modeling-with-k-mer-features/notebook
## Last update: 29th of November, 2025
import numpy as np
import pandas as pd
from pandas import read_excel
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import r2_score
from scipy import stats
import seaborn as sns
import matplotlib.pyplot as plt
import lightgbm as lgb
#-----------------------------------------------------------------------------
def kmer(seq,seq_length,kmer_length=3):
    kmer_words = [seq[i:i+seq_length] for i in range(len(seq)-seq_length+1)]
    return ' '.join(kmer_words)
#-----------------------------------------------------------------------------
# DF=read_excel("/home/rafa/WORKDIRECTORY/DATABASES/PLASTICS/PLASTICmergeDB.04SEP2025.xlsx",sheet_name = "Summary",header=5,index_col=0,usecols=("B:P"),engine='openpyxl',nrows=4615)
# DF=read_excel("/home/rafa/WORKDIRECTORY/MADRID/EXTREMOPHILES/POLYMERs_BIORE2AIRCRAFT/PETases/PETases.23DEC2025.xlsx",sheet_name = "PETases_Candidates_Extremophile",header=5,index_col=0,usecols=("C:AM"),engine='openpyxl',nrows=1326)
# DF=read_excel("/home/rafa/WORKDIRECTORY/MADRID/EXTREMOPHILES/POLYMERs_BIORE2AIRCRAFT/PETases/PETases.14JAN2026.xlsx",sheet_name = "PETases_Candidates_MARDB",header=5,index_col=0,usecols=("B:U"),engine='openpyxl',nrows=980)
DF=read_excel("/home/rafa/WORKDIRECTORY/MADRID/EXTREMOPHILES/POLYMERs_BIORE2AIRCRAFT/PETases/PETases.14JAN2026.xlsx",sheet_name = "PETases_Candidates_SOILDB",header=5,index_col=0,usecols=("B:U"),engine='openpyxl',nrows=340)

kmer_length = 3
# DF['kmer seq'] = DF['AA seq'].apply(lambda x: kmer(x,kmer_length))
# DF['kmer seq'] = DF['query seq'].apply(lambda x: kmer(x,kmer_length))
DF['kmer seq'] = DF['query_seq'].apply(lambda x: kmer(x,kmer_length))

tfidfvector = TfidfVectorizer()
vectorsFE=tfidfvector.fit_transform(DF['kmer seq']).astype('float32')
feat_names = tfidfvector.get_feature_names_out()
DFFE=pd.DataFrame(vectorsFE.toarray())
DFFE = pd.DataFrame(data=vectorsFE.toarray(),index=DF.index,columns=feat_names)

# DFFE.to_csv('/home/rafa/WORKDIRECTORY/MADRID/EXTREMOPHILES/POLYMERs_BIORE2AIRCRAFT/PETases/ML/FEATURES/KMERSvec/PETases.Candidates.30DEC2025.KmerVectors.K3.tsv', sep="\t")
# DFFE.to_csv('/home/rafa/WORKDIRECTORY/MADRID/EXTREMOPHILES/POLYMERs_BIORE2AIRCRAFT/PETases/ML/FEATURES/KMERSvec/PETases.MARDB.Candidates.KmerVectors.K3.20JAN2026.tsv', sep="\t")
DFFE.to_csv('/home/rafa/WORKDIRECTORY/MADRID/EXTREMOPHILES/POLYMERs_BIORE2AIRCRAFT/PETases/ML/FEATURES/KMERSvec/PETases.SOILDB.Candidates.KmerVectors.K3.20JAN2026.tsv', sep="\t")