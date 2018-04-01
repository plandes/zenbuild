# Build Utilities

This package has tools, configuration files and utilities for building,
installing and deploying projects.


## Usage

This repo, with its set of make files, is to be used on Clojure and Python
build projects like the [NLP parse project].  Scala/sbt make setup is under
development.

See the [template](https://github.com/plandes/template#usage) project for more
information on use cases and how to use this repo.


## Building and Dependencies

Building a project using this build setup requires certain software to be
installed:

1. Install [GNU make]: `brew install make` / `sudo yum groupinstall "Development Tools"`
2. Install [Git]: `brew install git` / `sudo yum install git`
3. Install [Python 3]:
  - MacOS:
```bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install python
```
   - Linux (CentOS):
```bash
sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
sudo yum -y install python36u
```
4. Install [gitpython]: `pip install gitpython`
5. For Clojure projects: install [Leiningen] (this is just a script):
```bash
wget -O /usr/local/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && chmod 0755 /usr/local/bin/lein
```


## License

Copyright © 2016, 2017 Paul Landes

Apache License version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


<!-- links -->
[NLP parse project]: https://github.com/plandes/clj-nlp-parse
[mkproj]: https://github.com/plandes/clj-mkproj
[gitpython]: https://github.com/gitpython-developers/GitPython
[Git]: https://git-scm.com
[GNU make]: https://www.gnu.org/software/make/
[Leiningen]: http://leiningen.org
[Python 3]: https://www.python.org/download/releases/3.0/
