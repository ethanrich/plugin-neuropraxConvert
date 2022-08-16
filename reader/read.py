
# fname = r"C:\Users\eri\OneDrive - neurocare group AG\Documents\readEEG_testData\20211014163742.EE_"
# with open(fname, mode="rb") as f:
#     contents = f.read()

# data = str(contents).split('\\')
# parsed_data = list(filter(lambda a: a != 'r', data))

#%%

import os

os.environ['OCTAVE_EXECUTABLE'] = ""
while "octave.exe" not in os.environ['OCTAVE_EXECUTABLE']:
    OCTAVE_EXECUTABLE = "C:\\Users\\eri\\AppData\\Local\\Programs\\GNU Octave\\Octave-7.2.0\\mingw64\\bin\\octave.exe"
    os.environ['OCTAVE_EXECUTABLE'] = "C:\\Users\\eri\\AppData\\Local\\Programs\\GNU Octave\\Octave-7.2.0\\mingw64\\bin\\octave.exe"
    print('Not yet')

if 'octave' in os.environ['OCTAVE_EXECUTABLE']:
    root = os.path.dirname(os.path.realpath(__file__))[:-6] + 'octave'
    
    from oct2py import octave
    octave.addpath(root)
    octave.push("savepath", os.getcwd())
    octave.loadEEG("20211014163742.EEG", nout=0)
    octave.exit()
    print("Success")
else:
    print("Failed")
