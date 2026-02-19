# fishamnium

[![Release](https://img.shields.io/github/release/ShogunPanda/fishamnium.svg)](https://github.com/ShogunPanda/fishamnium/releases/latest)
[![License](https://img.shields.io/github/license/ShogunPanda/fishamnium.svg)](https://github.com/ShogunPanda/fishamnium/blob/master/LICENSE.md)

Some useful shell extension for fish shell.

https://sw.cowtech.it/fishamnium

## Dependencies

Fishamnium requires the following dependencies:

| Name                | Description                                                                  | URL                             | Installation guide                           |
| ------------------- | ---------------------------------------------------------------------------- | ------------------------------- | -------------------------------------------- |
| yq                  | Lightweight and portable command-line YAML, JSON and XML processor.          | https://mikefarah.gitbook.io/yq | https://mikefarah.gitbook.io/yq#install      |
| starship            | The minimal, blazing-fast, and infinitely customizable prompt for any shell! | https://starship.rs/guide/      | https://starship.rs/guide/#🚀-installation   |
| fzf                 | A command-line fuzzy finder                                                  | https://github.com/junegunn/fzf | https://github.com/junegunn/fzf#installation |
| Fira Code Nerd Font | An amazing looking font with icons                                           | https://www.nerdfonts.com/      | N/A                                          |

If you are using Homebrew on MacOS, you can install them easily by using:

```bash
brew install starship yq fzf font-fira-code-nerd-font
```

## Install

Type the following inside a fish shell and you're done!

```bash
curl -sL https://sw.cowtech.it/fishamnium/installer | fish
```

## Uninstall

Type the following inside a fish shell and you're done!

```bash
~/.local/share/fishamnium/installer -u
```

## Contributing to fishamnium

- Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
- Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
- Fork the project
- Start a feature/bugfix branch
- Commit and push until you are happy with your contribution
- Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.

## Copyright

Copyright (C) 2013 and above Shogun (shogun@cowtech.it).

Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
