
import click
import os
from reader.read import read_brainvis_triplet

@click.command()
# @click.option("--name", prompt="Your name", help="The person to greet.")

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


def main():
    # collect the data files
    path = os.getcwd()
    eeg, ee_ = collect_files(path)

    # read them
    header, e, x = read_brainvis_triplet(path+"\\"+ee_[0], eeg_fname=path+"\\"+eeg[0])
    click.echo(header)