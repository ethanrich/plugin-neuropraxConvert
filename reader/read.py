
def call_octave_convert_files(file_to_convert="empty"):
    # if no file give, insult the user
    if file_to_convert == "empty":
        print("Come on then, give us a file")
    
    # brute force the environment variable setting. Seems to take 1-5 iterations. No clue why
    import os    
    os.environ['OCTAVE_EXECUTABLE'] = ""
    while "octave.exe" not in os.environ['OCTAVE_EXECUTABLE']:
        OCTAVE_EXECUTABLE = "C:\\Users\\eri\\AppData\\Local\\Programs\\GNU Octave\\Octave-7.2.0\\mingw64\\bin\\octave.exe"
        os.environ['OCTAVE_EXECUTABLE'] = "C:\\Users\\eri\\AppData\\Local\\Programs\\GNU Octave\\Octave-7.2.0\\mingw64\\bin\\octave.exe"
    
    # when the environment variable is finally set, call octave to convert binary to .mat
    if 'octave' in os.environ['OCTAVE_EXECUTABLE']:
        root = os.path.dirname(os.path.realpath(__file__))[:-6] + 'octave'
        
        from oct2py import octave
        octave.addpath(root)
        octave.push("savepath", os.getcwd())
        octave.loadEEG(file_to_convert, nout=0)
    else:
        print("Failed, try again or contact support")
    
def save_as_pickle(matfile, datafile):
    import pickle
    with open(matfile[:-4] + '.pickle', 'wb') as handle:
        pickle.dump(datafile, handle, protocol=pickle.HIGHEST_PROTOCOL)

def np_info_to_py(matfile, folder='eingelegt'):
    from scipy.io import loadmat
    # get the NP_info mat file
    mat = loadmat(matfile, struct_as_record=False) # set to false to preserve the struct key:values
    data = mat['NP_info'][0][0]
    # prepare to loop the key values into a dict
    keys = [i for i in dir(data) if not i.startswith('__')]
    np_info = {}
    for key in keys:
        temp = getattr(data, key)
        # at least fix the channels values
        if key == 'channels':
            temp_chan = [temp[0][i][0] for i in range(temp.shape[1])]
            np_info['channels'] = temp_chan
        else:
            np_info[key] = temp
    # save the dict
    save_as_pickle(folder + '\\' + matfile, np_info)

