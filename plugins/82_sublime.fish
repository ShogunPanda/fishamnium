#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function subl --description 'Open Sublime Text 2'
  if test -d "/Applications/Sublime Text 2.app"
    "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" $argv
  end
end