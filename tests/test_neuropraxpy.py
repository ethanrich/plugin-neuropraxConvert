from neuropraxpy.reader.utils import get_project_root
from neuropraxpy.reader.read import brute_force_octave
import os
import pytest

def test_root_dir():
    assert get_project_root().endswith("tool-neuropraxpy\\neuropraxpy")

def test_octave_exe():
    local_octave = get_project_root() + '\\octave\\mingw64\\bin\\octave-cli.exe'
    brute_force_octave(local_octave)
    assert "octave-cli.exe" in os.environ['OCTAVE_EXECUTABLE']
    
def test_octave_import():
    import oct2py
    import sys
    assert 'oct2py' in sys.modules
