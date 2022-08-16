
def call_octave_convert_files(file_to_convert="empty"):
    if file_to_convert == "empty":
        print("Come on then, give us a file")
    
    import os
    
    os.environ['OCTAVE_EXECUTABLE'] = ""
    while "octave.exe" not in os.environ['OCTAVE_EXECUTABLE']:
        OCTAVE_EXECUTABLE = "C:\\Users\\eri\\AppData\\Local\\Programs\\GNU Octave\\Octave-7.2.0\\mingw64\\bin\\octave.exe"
        os.environ['OCTAVE_EXECUTABLE'] = "C:\\Users\\eri\\AppData\\Local\\Programs\\GNU Octave\\Octave-7.2.0\\mingw64\\bin\\octave.exe"
        print('Getting matlab files and Octave executable..')
    
    if 'octave' in os.environ['OCTAVE_EXECUTABLE']:
        root = os.path.dirname(os.path.realpath(__file__))[:-6] + 'octave'
        
        from oct2py import octave
        octave.addpath(root)
        octave.push("savepath", os.getcwd())
        octave.loadEEG(file_to_convert, nout=0)
        octave.exit()
        print("Files converted")
    else:
        print("Failed, try again or contact support")
