# -*- coding: utf-8 -*-
"""
Created on Wed Aug 17 15:15:40 2022

@author: eri
"""
import os
import pickle

def pickle_jar(which="_NP__info_data_marker.pickle"):
    # gather a list of all pickled data files
    pickles = []
    for name in os.listdir("."):
        if name.endswith(which):
            pickles.append(name)
    return pickles

def load_pickle(to_load):
    # basic pickle loader
    with open(to_load, 'rb') as handle:
        data_file = pickle.load(handle)
    return data_file
