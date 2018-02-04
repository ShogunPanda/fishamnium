#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

function fish_user_key_bindings
  bind \e\[1\;5A history-token-search-backward
  bind \e\[1\;5B history-token-search-forward
  bind \e\[1\;5C forward-word
  bind \e\[1\;5D backward-word
  bind \eB backward-word
  bind \eF forward-word
end
