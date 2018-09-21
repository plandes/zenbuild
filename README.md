# Build Utilities

This package has tools, configuration files and utilities for building,
installing and deploying projects.


## Usage

This repo, with its set of make files, is to be used on Clojure and Python
build projects like the [NLP parse project].  Scala/sbt make setup is under
development.

## Compiling and Using Build Environment

This repo use to be used as a dependency, and you can too if you want.
However, I've *flipped* the paradigm and now use this repo as a [git module]
since it works well as a tracked version by the parent for each project that
uses it.  Examples:

* [Python project](https://github.com/plandes/zotsite)
* [Clojure](https://github.com/plandes/clj-nlp-parse)

See the [template](https://github.com/plandes/template#usage) project for more
information on use cases and how to use this repo.


## Building and Dependencies

Building a project using this build setup requires certain software to be
installed:

1. Install [GNU make]:

*MacOS*:
```bash
brew install make
```

*Linux (CentOS)*:
```bash
sudo yum groupinstall "Development Tools"
```

2. Install [Git]:

*MacOS*:
```bash
brew install git
```

*Linux (CentOS)*:
```bash
sudo yum install git
```
3. Install [Python 3]:

*MacOS*:
```bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install python
```

*Linux (CentOS)*:
```bash
sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
sudo yum -y install python36u
```

4. Install [gitpython]:

```bash
pip install gitpython
```

5. For Clojure projects: install [Leiningen] (this is just a script):
```bash
wget -O /usr/local/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && chmod 0755 /usr/local/bin/lein
```


## License

Copyright © 2018 Paul Landes

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


<!-- links -->
[NLP parse project]: https://github.com/plandes/clj-nlp-parse
[mkproj]: https://github.com/plandes/clj-mkproj
[gitpython]: https://github.com/gitpython-developers/GitPython
[Git]: https://git-scm.com
[GNU make]: https://www.gnu.org/software/make/
[Leiningen]: http://leiningen.org
[Python 3]: https://www.python.org/download/releases/3.0/
[git module]: https://git-scm.com/book/en/v2/Git-Tools-Submodules
