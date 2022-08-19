import click
import os
from tqdm import tqdm
from neuropraxpy.reader.read import collect_files, make_new_dir, call_octave_convert_files, np_to_py
from neuropraxpy.reader.utils import get_project_root

@click.command()
def main():
    
    # get the path of the octave exe
    local_octave = get_project_root() + '\\octave\\mingw64\\bin\\octave.exe'
    
    # collect the binary files
    eeg, ee_, _ = collect_files()
    
    # make a folder in the current working directory for the new stuff
    make_new_dir(sub='eingelegt')
    
    # convert files to Python dicts
    for file in tqdm(eeg):
        call_octave_convert_files(local_octave=local_octave, file_to_convert=file)
        np_to_py(file[:-4] + '_NP_')
        
    # collect the mat files
    _, _, mats = collect_files()
    # make a folder for the mat files
    make_new_dir(sub='matfiles')
    # send the matfiles to the folder (didn't work to just do it through octave for some reason)
    try:
        for mat in mats:
            os.rename(os.getcwd()+"\\"+mat, os.getcwd()+"\\matfiles\\"+mat)
    except:
        print("Cannot move .mat files, as the destination already has them")

    
    click.echo("Finished with conversion to Python and all files pickled. Bitteschön.")