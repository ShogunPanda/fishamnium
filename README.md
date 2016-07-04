# fishamnium

Some useful shell extension for fish shell.

http://sw.cowtech.it/fishamnium

https://github.com/ShogunPanda/fishamnium

## Prerequisites

To use git and bookmarks functions you need to have [Node.js 6+](https://nodejs.org) installed.

We suggest to install it using NVM, by following this [instructions](https://github.com/creationix/nvm#installation).

## Install

Type the following inside a fish shell and you're done!

`curl -sL http://sw.cowtech.it/fishamnium/installer | fish`

## Uninstall

Just type the following inside a fish shell and you're done!

`
set -x FISHAMNIUM_OPERATION uninstall
curl -sL http://sw.cowtech.it/fishamnium/installer | fish
set -e FISHAMNIUM_OPERATION
`

## Contributing to fishamnium

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.

## Copyright

Copyright (C) 2013 and above Shogun (shogun@cowtech.it).

Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.

### External scripts included

* `plugins/21_rvm.fish` was extracted from [lunks/fishnuggets](https://www.github.com/zmalltalker/lunks-nuggets).
* `plugins/41_nvm.fish` was extracted from [passcod/nvm-fish-wrapper](https://www.github.com/passcod/nvm-fish-wrapper).
* `completions/31_git.fish` was extracted from [lunks/fish-nuggets](https://www.github.com/lunks/fish-nuggets).
