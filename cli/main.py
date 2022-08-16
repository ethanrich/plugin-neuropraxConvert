
import click
import os
from reader.read import call_octave_convert_files

def collect_files(path):
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
    path = os.getcwd()
    eeg, ee_ = collect_files(path)

    click.echo("Collected files")
    
    # convert files
    for file in eeg:
        call_octave_convert_files(file_to_convert=file)
    click.echo("Finished")