# fishamnium

Some useful shell extension for fish shell.

https://sw.cowtech.it/fishamnium

## Install

To use fishamnium you need a recent version of [Node.js](https://nodejs.org) installed.

The minimum version required must be able to run async function (this means Node.js version 7.6.0 or above).

Type the following inside a fish shell and you're done!

`curl -sL http://sw.cowtech.it/fishamnium/installer | fish`

## Updating to version 4.0.0

Starting with version 4.0.0, format of bookmarks file has changed.

To update your local file, please clone the [repository](https://github.com/ShogunPanda/fishamnium) locally, then run `yarn run convert-bookmarks`.

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