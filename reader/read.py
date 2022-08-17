from reader.utils import get_project_root
import os    
import pickle
from scipy.io import loadmat

def collect_files():
    # get all files
    eeg = []
    ee_ = []
    mats = []
    for name in os.listdir("."):
        if name.endswith(".EEG"):
            eeg.append(name)
        elif name.endswith(".EE_"):
            ee_.append(name)
        elif name.endswith(".mat"):
            mats.append(name)
    return eeg, ee_, mats

def make_new_dir(sub='eingelegt'):
    new_folder = sub
    try:
        os.mkdir(new_folder)
    except:
        pass

def call_octave_convert_files(file_to_convert="empty"):
    # if no file give, insult the user
    if file_to_convert == "empty":
        print("Come on then, give us a file")
    
    # brute force the environment variable setting. Seems to take 1-5 iterations. No clue why
    os.environ['OCTAVE_EXECUTABLE'] = ""
    while "octave.exe" not in os.environ['OCTAVE_EXECUTABLE']:
        OCTAVE_EXECUTABLE = "C:\\Users\\eri\\AppData\\Local\\Programs\\GNU Octave\\Octave-7.2.0\\mingw64\\bin\\octave.exe"
        os.environ['OCTAVE_EXECUTABLE'] = "C:\\Users\\eri\\AppData\\Local\\Programs\\GNU Octave\\Octave-7.2.0\\mingw64\\bin\\octave.exe"
    
    # when the environment variable is finally set, call octave to convert binary to .mat
    if 'octave' in os.environ['OCTAVE_EXECUTABLE']:
        # get the root directory for this repo
        root = get_project_root() + '\\octave'
        
        from oct2py import octave
        octave.addpath(root) # get the octave files from the repo folder
        octave.push("savepath", os.getcwd()) # send where to save the mat files
        octave.loadEEG(file_to_convert, nout=0) # call the conversion function
    else:
        print("Failed, try again or contact support")
    
def save_as_pickle(file_name, to_save):
    # basic pickle saver
    with open(file_name + '.pickle', 'wb') as handle:
        pickle.dump(to_save, handle, protocol=pickle.HIGHEST_PROTOCOL)

def np_to_py(matfile, folder='eingelegt'):
    
    # collect the info, data, and marker files
    NP_info_data_marker = {}
    for which in ['info', 'data', 'marker']:
        # get the NP_ mat file
        mat = loadmat(matfile + which + '.mat', struct_as_record=False) # set to false to preserve the struct key:values
        data = mat['NP_' + which][0][0] # pull the data out of nested dicts
        # prepare to loop the key values into a dict
        keys = [i for i in dir(data) if not i.startswith('__')]
        np_dict = {}
        for key in keys:
            temp = getattr(data, key)
            # at least fix the channels values so they're not nested deeply
            if key == 'channels':
                temp_chan = [temp[0][i][0] for i in range(temp.shape[1])]
                np_dict['channels'] = temp_chan
            else:
                np_dict[key] = temp
        # collect the dict into a larger one for later saving
        NP_info_data_marker[which] = np_dict
        # save the dict with each individual file only
        save_as_pickle(folder + '\\' + matfile + '_' + which, np_dict)
                
    # save the dict with all three files in it
    save_as_pickle(folder + '\\' + matfile + '_info_data_marker', NP_info_data_marker)
    
    

