#!/bin/sh


PYPI_URLS="https://test.pypi.org/legacy/ https://upload.pypi.org/legacy/"


echo "installing libraries for Python deployments"
for i in setuptools twine wheel keyring ; do
    pip install -U $i
done

echo "installing libraries for Python documentation"
for i in sphinx sphinx-rtd-theme recommonmark rst2pdf ; do
    pip install -U $i
done

echo "installing libraries for development with Emacs Elpy"
for i in jedi flake8 autopep8 yapf importmagic ; do
    pip install -U $i
done

echo "yeah, you really have to provide password (each time); this stores it with keyring"
for i in $PYPI_URLS ; do
    python -m keyring set $i zensols
done

# needed for python utililty scripts
pip install -r requirements.txt 
