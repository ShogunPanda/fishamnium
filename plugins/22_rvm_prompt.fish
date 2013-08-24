#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function rvm_current
  which rvm-prompt > /dev/null;
  and test -n (rvm-prompt i);
  and set -l rv
  and rvm-prompt i v g;
end

rvm reload > /dev/null ^ /dev/null