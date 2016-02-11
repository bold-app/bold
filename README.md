Bold [![Build Status](https://travis-ci.org/bold-app/bold.svg?branch=master)](https://travis-ci.org/bold-app/bold)
====

For blogging. And small web sites. Maybe even big web sites. Who knows.


Requirements
------------

- Ruby 2.3
- PostgreSQL 9.x with `hstore` extension.



Running the tests
-----------------

    bundle install
    bundle exec rake db:setup
    bundle exec rake


### Integration tests

Some integration tests use poltergeist / phantomjs for javascript enabled test
runs. In order for these to work, first map test.host to your local machine in
`/etc/hosts`:

    127.0.0.1 localhost test.host

Then install a phantomjs binary if you are on a Mac, or compile it yourself if
you are on Linux. See http://phantomjs.org/download.html .

Contributing
------------

Contributions in the form of patches / pull requests are welcome under the
following rules:

- add tests for anything you fix / add
- look at the code around you and make sure your own code fits in nicely in
  terms of style and formatting
- by contributing to this project you grant to me the right to redistribute /
  relicense your contribution at any time and under any terms I see fit.


License
-------

Copyright (C) 2015-2016 Jens Krämer <jk@jkraemer.net>

Bold is free software: you can redistribute it and/or modify it under the terms
of the GNU Affero General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

Bold is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

You should have received a copy of the GNU Affero General Public License along
with Bold. If not, see [www.gnu.org/licenses](http://www.gnu.org/licenses/).

Should you be interested in a commercial license without the AGPL's sharing
obligations, please contact the author under the address above.

