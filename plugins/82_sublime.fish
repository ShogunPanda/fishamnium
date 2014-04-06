#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function subl --description 'Open Sublime Text 3'
  if test -d "/Applications/Sublime Text.app"
    "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" $argv
  end
end
