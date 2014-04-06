# fishamnium

Some useful shell extension for fish shell.

http://sw.cow.tc/fishamnium

https://github.com/ShogunPanda/fishamnium

[![Bitdeli Trend](https://d2weczhvl823v0.cloudfront.net/ShogunPanda/fishamnium/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
<iframe src="http://ghbtns.com/github-btn.html?user=ShogunPanda&repo=lazier&type=fishamnium&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="135" height="20"></iframe>

## Install

Just type the following inside a fish shell and you're done!

`curl -sL http://sw.cow.tc/fishamnium/installer | fish`

### Install Git aliases

`fishamnium_install_git_aliases`

## Uninstall

Just type the following inside a fish shell and you're done!

`
set -x FISHAMNIUM_OPERATION uninstall
curl -sL http://sw.cow.tc/fishamnium/installer | fish
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
* `plugins/71_fishmarks.fish` was extracted from [techwizrd/fishmarks](https://www.github.com/zmalltalker/techwizrd/fishmarks).
* `completions/31_git.fish` was extracted from [zmalltalker/fish-nuggets](https://www.github.com/zmalltalker/fish-nuggets).
