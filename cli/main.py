
import click
import os
from reader.read import call_octave_convert_files, np_info_to_py
from tqdm import tqdm

def collect_files():
    # get all files
    eeg = []
    ee_ = []
    for name in os.listdir("."):
        if name.endswith(".EEG"):
            eeg.append(name)
        elif name.endswith(".EE_"):
            ee_.append(name)
    return eeg, ee_

@click.command()
def main():
    # collect the data files
    eeg, ee_ = collect_files()
    
    # make a folder in the current working directory for the new stuff
    new_folder = 'eingelegt'
    try:
        os.mkdir(new_folder)
    except:
        pass
    
    # convert files to Python dicts
    for file in tqdm(eeg):
        call_octave_convert_files(file_to_convert=file)
        np_info_to_py(file[:-4] + '_NP_info.mat', folder=new_folder)
        
    click.echo("Finished with conversion to Python and all files pickled. Bitteschön.")