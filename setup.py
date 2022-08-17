import setuptools
from setuptools import find_packages
from distutils.core import setup
from pathlib import Path


with (Path(__file__).parent / "readme.md").open("r") as f:
    long_description = f.read()

with (Path(__file__).parent / "requirements.txt").open("r") as f:
    requirements = [l for l in f.readlines() if not "http" in l]


packages = setuptools.find_namespace_packages(exclude=["tests*", "docs*", "htmlcov*"])

setup(
    name="neuropraxpy",
    version="0.1.0",
    description="read binary EEG files to Python",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Ethan Rich",
    author_email="ethan.rich@neurocaregroup.com",
    url="https://github.com/ethanrich/tool-neuropraxpy.git",
    download_url="https://github.com/ethanrich/tool-neuropraxpy.git",
    license="MIT",
    packages=find_packages(),
    entry_points={'console_scripts': ['neuropraxpy=neuropraxpy.cli.main:main']},
    install_requires=requirements,
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: MIT License",
        "Operating System :: Windows",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3",
    ],
)