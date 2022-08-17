# tool-readEEG
This is a CLI (command line interface) tool to read binary files from NEUROPRAX (.EEG/.EE_ files) and parse them into Python dictionaries. 
Please follow the instructions below. If there is a bug, please raise an Issue on this repository.


# Installation
Please install GNU Octave before you begin: https://ftpmirror.gnu.org/octave/windows/octave-7.2.0-w64-installer.exe

Download Repository
1) Git clone this repository to your machine OR download the ZIP folder and extract the files
2) Pip install the package into your python environment

Configure Octave Executable
3) Find your Octave executable file that contains "mingw64\bin\" at the end
4) Paste the full path of the Octave executable to the configuration file located in tool-neuropraxpy\cli\config.ini

Convert Binary Files
3) Open a command prompt or Anaconda Prompt in the folder of your .EEG/.EE_ files
4) run <command> <filename>
5) a .pickle file will appear in the same directory
6) loading this file will reveal a dictionary containing key:values for data contained in the EEG file
