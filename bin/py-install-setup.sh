#!/bin/sh

PYPI_URLS="https://test.pypi.org/legacy/ https://upload.pypi.org/legacy/"

for i in setuptools twine wheel keyring ; do
    pip install -U $i
done

echo "yeah, you really have to provide password (each time); this stores it with keyring"
for i in $PYPI_URLS ; do
    python -m keyring set $i zensols
done

# install certifications on OSX
if [[ "$OSTYPE" == "darwin"* ]] ; then
    /Applications/Python\ 3.6/Install\ Certificates.command
fi
