# #!/usr/bin/env fish
# #
# # This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# # Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
# #

# Pull and push
for i in gl gp
  complete -c $i -f -a "(__fish_git_heads) (__fish_git_remotes)"
end

# Checkout
for i in gco gcb
  complete -c $i -f -a '(__fish_git_branches)' --description 'Branch'
  complete -c $i -f -a '(__fish_git_tags)' --description 'Tag'
end

# Branch related
for i in gb gbd gbm gme gmt gmf
  complete -c $i -f -a '(__fish_git_branches)' --description 'Branch'
  complete -c $i -f -a '(__fish_git_tags)' --description 'Tag'
end

# Remote
for i in gr grv grmv grrm grset grup
  complete -c $i -f -a '(__fish_git_remotes)'
end

# Rebase
for i in grbi grbc grba
  complete -c $i -f -a "(__fish_git_heads)"
end
