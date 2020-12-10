#!/bin/sh


PYPI_URLS="https://test.pypi.org/legacy/ https://upload.pypi.org/legacy/"


echo "installing libraries for Python deployments"
for i in setuptools twine wheel keyring ; do
    pip install -U $i
done

echo "installing libraries for Python documentation"
for i in sphinx sphinx-rtd-theme recommonmark rst2pdf sphinx-autodoc-typehints ; do
    pip install -U $i
done

echo "installing libraries for development with Emacs Elpy"
for i in jedi flake8 autopep8 yapf importmagic ; do
    pip install -U $i
done

echo "installing jupyter and widgets for notebook web interface"
for i in notebook ipywidgets ; do
    pip install -U $i
done

echo "yeah, you really have to provide password (each time); this stores it with keyring"
echo "on linux or if you don't want to store a password, press <RET> several times"
for i in $PYPI_URLS ; do
    python -m keyring set $i zensols
done

# needed for python utililty scripts
pip install -r requirements.txt 
