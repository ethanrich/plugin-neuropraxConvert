# tool-neuropraxpy
This is a CLI (command line interface) tool to read binary files from NEUROPRAX (.EEG/.EE_ files) and parse them into Python dictionaries. 

Functionality is limited to Windows. I could update it to include Linux. Let me know. 

Please follow the instructions below.

If there is a bug, please raise an Issue.

# Installation

#### 1. Install GNU Octave ####
[***Windows Installer***](https://ftpmirror.gnu.org/octave/windows/octave-7.2.0-w64-installer.exe)

#### 2. Download Repository ####

1) Git clone this repository to your machine OR download the ZIP folder and extract the files
2) Pip install the package into your python environment

#### 3. Configure Octave Executable ####

1) Find your Octave executable file that contains "mingw64\bin\" at the end, like this: ***C:\Users\eri\AppData\Local\Programs\GNU Octave\Octave-7.2.0\mingw64\bin\octave.exe***
2) Paste the full path of the Octave executable to the configuration file located in the repository, at ***tool-neuropraxpy\cli\config.ini***

#### 4. Convert Binary Files To Pickle (for Python) ####

1) Open a command prompt or Anaconda Prompt (whatever you used to pip install) in the folder of your .EEG/.EE_ files
2) Run the command `neuropraxpy`
3) Observe the command prompt for any warnings and watch the progress bar fill up
4) When finished, there will be two new folders next to the .EEG/.EE_ files. "Eingelegt" contains FOUR .pickle files ***for each .EEG file***, one for each data format (info, data, and marker) and a fourth file with all three in one "_NP__info_data_marker". The original name of the .EEG file is preserved, e.g. `20211014163727_NP__info_data_marker.pickle`

*Hint, "eingelegt" means "pickled" in German*

#### 5. Loading Data Into Python ####

1) In your python script, you can use functions from this package to load your data into python:
```
import os
from neuropraxpy.reader.load import pickle_jar, load_pickle

# set the working directory to the folder with the pickle files
os.chdir(r"C:\path\to\pickle\files\eingelegt")
# get all the pickled data files
pickles = pickle_jar()
# pick one to load
eeg_data = load_pickle(pickles[0])
```

2) You now have a variable called `eeg_data` that contains dictionaries of key:values similar to a MATLAB struct. I would recommend using Spyder to have a variable explorer.
