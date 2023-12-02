#!/bin/sh

# @meta {desc: 'install Python build dependencies', date: '2023-11-30'}

PYPI_URLS="https://test.pypi.org/legacy/ https://upload.pypi.org/legacy/"

which dot > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "must install graphviz: brew install graphviz"
    exit 1
fi


echo "installing libraries for Python deployments"
for i in setuptools twine wheel keyring pip-tools pipdeptree plac ; do
    pip install -U $i
done

if [ $(uname -s) == "Darwin" ] ; then
    echo "installing macOS libraries"
    pip install -U applescript
fi

echo "installing libraries for Python documentation"
# pin sphinx version since 3.4 has error: search page freezes
for i in sphinx recommonmark rst2pdf furo \
		sphinx-autodoc-typehints sphinx-copybutton \
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

# needed for python utililty scripts
pip install -r requirements.txt 
