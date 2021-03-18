#!/bin/sh

if [ "$1" == "--help" ] ; then
    echo "usage: $0 [--skip]"
    echo "if --skip is given, then skip keyring install"
    exit 0
fi

PYPI_URLS="https://test.pypi.org/legacy/ https://upload.pypi.org/legacy/"

which dot > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "must install graphviz: brew install graphviz"
    exit 1
fi


echo "installing libraries for Python deployments"
for i in setuptools twine wheel keyring ; do
    pip install -U $i
done

echo "installing libraries for Python documentation"
# pin sphinx version since 3.4 has error: search page freezes
for i in 'sphinx==3.3.1' sphinx-rtd-theme recommonmark rst2pdf \
			 sphinx-autodoc-typehints \
			 btd.sphinx.graphviz \
			 btd.sphinx.inheritance_diagram ; do
    pip install -U $i
done

echo "installing libraries for development with Emacs Elpy, virtualenv for jedi"
for i in jedi flake8 autopep8 yapf importmagic virtualenv ; do
    pip install -U $i
done

echo "installing jupyter and widgets for notebook web interface"
for i in notebook ipywidgets ; do
    pip install -U $i
done

if [ "$1" != "--skip" ] ; then
    echo "yeah, you really have to provide password (each time); this stores it with keyring"
    echo "on linux or if you don't want to store a password, press <RET> several times"
    for i in $PYPI_URLS ; do
	python -m keyring set $i zensols
    done
fi

# needed for python utililty scripts
pip install -r requirements.txt 
