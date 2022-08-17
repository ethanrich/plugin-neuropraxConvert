import click
import os
from tqdm import tqdm
import configparser
from neuropraxpy.reader.read import collect_files, make_new_dir, call_octave_convert_files, np_to_py
from neuropraxpy.reader.utils import get_project_root

@click.command()
def main():
    
    # get the path of the local octave executable from the user setting
    ini_path = get_project_root() + "\\cli\\" + "config.ini"
    config = configparser.ConfigParser()
    config.read(ini_path)
    local_octave = config.get('settings','local_octave')
    
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
    for mat in mats:
        os.rename(os.getcwd()+"\\"+mat, os.getcwd()+"\\matfiles\\"+mat)

    
    click.echo("Finished with conversion to Python and all files pickled. Bitteschön.")