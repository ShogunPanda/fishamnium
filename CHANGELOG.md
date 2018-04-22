### 2018-04-22 / 6.1.2

* Improve generation file.
* Improve updating of the version.
* Replace Rakefile with Magefile.
* Removed vendor folder from GIT.
* Added dep file.

### 2018-02-21 / 6.1.1

* Bugfixes.

### 2018-02-21 / 6.1.0

* Bugfixes.

### 2018-02-14 / 6.0.6

* Version 6.0.6

### 2018-02-14 / 6.0.5

* Version 6.0.5

### 2018-02-14 / 6.0.4

* Do not cleanup if there is nothing to clean.
* PR correctly moves to the base branch.

### 2018-02-04 / 6.0.3

* Update license file.

### 2018-02-04 / 6.0.2

* Correctly tag version.

### 2018-02-04 / 6.0.1

* Version 6.0.1

### 2018-02-04 / 6.0.1

* Switched to tempera
* Minor fixes

### 2018-01-27 / 6.0.0

* Updated release script

### 2017-01-25 / 6.0.0

* Rewrite the helper in go and provide libraries for all platforms (on amd64 architecture).
* Discard any dependency to Node.js.
* Embed convert utility in the bookmarks module.
* Vastly improve autocompletion.
* Discard `g_*` functions

### 2017-12-06 / 5.2.1

* Bugfix.

### 2017-12-05 / 5.0.0

* Rewritten helpers to avoid external dependencies.
* Improved installer.

### 2017-07-19 / 4.3.2

* Fixed name handling.

### 2017-07-19 / 4.3.1

* Minor bugfix.

### 2017-07-19 / 4.3.0

* Version 4.3.0

### 2017-07-19 / 4.2.4

* Version 4.3.0

### 2017-07-19 / 4.3.0

* Add name as second optional argument to the bookmark saving.

### 2017-07-13 / 4.2.3

* Add force flag to the push command of git helper.

### 2017-07-13 / 4.2.3

* Added `--force` flag to the `push` command of the git helper.

### 2017-06-22 / 4.2.2

* Bugfix for GitHub PRs.

### 2017-06-22 / 4.2.1

* Bugfix on reading local configuration file.

### 2017-06-21 / 4.2.0

* Added `push` to the git helper to push the current branch.

### 2017-06-20 / 4.1.3

* Fixed autocompletion.

### 2017-05-08 / 4.1.2

* Bugfix for `g cleanup`.

### 2017-05-02 / 4.1.0

* Added `update` to the git helper to fetch and pull a branch.
* Bugfix for `g cleanup`.

### 2017-04-06 / 4.0.0

* Change format of bookmarks file. See README.md for more information on how to upgrade.
* Renamed `is_git_repository` to `g_is_repository` and replace `git_` prefix with `g_` in `32_git_functions.fish`.
* Rewritten helpers in Node.js (which now is a dependency along with Yarn) to maximize portability.
* Rewritten core installer in Node.js

### 2017-02-08 / 3.4.1

* Minor fix.

### 2017-02-08 / 3.4.0

* Added `pull_request` and `fast_pull_request` to the git helper.

### 2017-01-20 / 3.3.0

* Replaced `nvm` with `n` (and `FISHAMNIUM_THEME_SHOW_NVM` with `FISHAMNIUM_THEME_SHOW_NODE` option) and added yarn support.
* Replaced `rvm` with `rbenv` (and `FISHAMNIUM_THEME_SHOW_RVM` with `FISHAMNIUM_THEME_SHOW_RUBY` option).
* Cleanup.

### 2016-12-09 / 3.2.0

* Added `e` and `o` commands to the bookmark helper to edit bookmarks.

### 2016-10-19 / 3.1.2

* Bugfix.

### 2016-10-19 / 3.1.1

* Added single bookmark shortcut.

### 2016-10-19 / 3.1

* Refactored helpers completions.

### 2016-10-14 / 3.0.6

* Minor fast-commit issue.

### 2016-10-12 / 3.0.5

* Minor fast-commit issue.

### 2016-10-12 / 3.0.4

* Minor fast-commit issue.

### 2016-10-12 / 3.0.3

* Minor formatting issue.

### 2016-10-11 / 3.0.2

* Fixed labels.

### 2016-10-11 / 3.0.1

* Minor helper fixes.

### 2016-10-09 / 3.0.0

* Rewritten helpers in Swift.
* Introduced a `rake build:helpers` to build helpers locally (Swift 3 and Swift Package Manager needed).
* Introduced `FISHAMNIUM_THEME_SHOW_RVM` and `FISHAMNIUM_THEME_SHOW_NVM` to show RVM and NVM in the default prompt. Otherwise they are hidden by default now.
* Move bookmarks back to `l`, `s`, `d` commands. Renamed d_g to `m`.

### 2016-07-11 / 2.1.3

* Removed debug line.

### 2016-07-11 / 2.1.2

* Minor execution bug.

### 2016-07-08 / 2.1.1

* Moved all bookmarks aliases to d

### 2016-07-08 / 2.1.0

* Moved all GIT aliases to g

### 2016-07-06 / 2.0.2

* Bugfix for execution.

### 2016-07-05 / 2.0.1

* Bugfix

### 2016-07-02 / 2.0.0

* Moved all GIT related tasks to a Node.js helper, fishamnium_git.
* Rewritten bookmarks functionality in a Node.js helper, fishamnium_bookmarks.

### 2016-06-30 / 1.27.1

* Minor fix.

### 2016-06-30 / 1.27.0

* Removed docker-machine.

### 2016-06-30 / 1.26.0

* Added git_fast_commit.

### 2016-06-14 / 1.25.0

* Improve Git workflow.

### 2016-06-14 / 1.25.0

* Improve Git workflow.

### 2016-03-04 / 1.24.0

* Improve Git task detection.

### 2016-03-03 / 1.23.16

* Bugfix on RVM

### 2016-02-29 / 1.23.15

* Do not assume a default name for docker machine.

### 2016-02-27 / 1.23.14

* Bugfix.

### 2016-02-27 / 1.23.13

* Bugfix.

### 2016-02-27 / 1.23.12

* Bugfix.

### 2016-02-27 / 1.23.11

* Enable RVM and NVM only if it makes sense.

### 2016-02-27 / 1.23.10

* Bugfix for RVM under Alpine.

### 2016-02-27 / 1.23.9

* Bugfix.

### 2016-02-27 / 1.23.8

* Change installer not to require Ruby and rake.

### 2016-02-26 / 1.23.7

* Added seconds to the shell prompt.
* Speed up checking whether within GIT repo.

### 2016-01-21 / 1.23.6

* Docker Machine (0.5.5+) now supports fish.

### 2015-12-14 / 1.23.5

* Minor fixes.

### 2015-10-13 / 1.23.4

* Minor fixes.

### 2015-10-13 / 1.23.3

* Regression fixes.

### 2015-10-13 / 1.23.2

* Minor fixes.

### 2015-10-13 / 1.23.1

* Minor fixes.

### 2015-10-13 / 1.23.0

* Added help to all git workflow commands.
* Renamed `g_release` to `g_release_tag`.
* Added `g_hotfix_full_finish`, `g_release_start`, `g_release_refresh`, `g_release_finish`, `g_release_full_finish`, `g_import_release`, `g_import_production`.

### 2015-04-29 / 1.22.0

* Add docker_setup.

### 2015-04-25 / 1.21.0

* Add Docker Machine support.

### 2015-01-27 / 1.20.0

* Switched to nvm-fish-wrapper.

### 2015-01-27 / 1.11.1

* Fixed bug in `g_import`.

### 2015-01-27 / 1.11.0

* Added `g_full_finish`.

### 2015-01-27 / 1.10.0

* Added `g_hotfix_start`, `g_hotfix_start`, `g_hotfix_refresh`, `g_hotfix_finish` and `g_import`.
* Fixed bin path.

### 2014-12-28 / 1.9.1

* Maintenance version. Added `release` task.

### 2014-12-28 / 1.9.0

* Added support for NVM.
* Added `clcd` command.

### 2014-11-11 / 1.8.0

* Added support for NPM local bins.

### 2014-10-25 / 1.7.0

* Added `git_full_branch_name`, `git_full_branch_name_copy`, `git_branch_name`, `git_branch_name_copy`, `git_task`, `git_task_copy`, `git_commit_with_task`, `gct`, `gcat` functions.

### 2014-10-25 / 1.6.0

* Added compatibility functions.

### 2014-09-12 / 1.5.9

* Added missing statement.

### 2014-09-12 / 1.5.8

* Fixed RVM debug handling.

### 2014-09-12 / 1.5.7

* Updated RVM support.

### 2014-08-27 / 1.5.6

* Bugfix.

### 2014-08-11 / 1.5.5

* Bugfix.

### 2014-08-10 / 1.5.3

* Do not rely on external aliases.

### 2014-08-10 / 1.5.2

* Bugfix on g_cleanup.

### 2014-08-10 / 1.5.1

* Renamed g_clean to g_reset.
* Added g_cleanup.

### 2014-08-10 / 1.5.0

* Add Git workflow.

### 2014-04-06 / 1.4.4

* Update to SublimeText 3.

### 2014-04-06 / 1.4.3

* Update to SublimeText 3.

### 2014-02-26 / 1.4.2

* Updated keybindings.

### 2014-02-07 / 1.4.1

* Include the current directory bin in the path.

### 2014-02-07 / 1.4.0

* Added fishamnium_reload.

### 2014-01-25 / 1.3.1

* Bugfix.

### 2014-01-25 / 1.3.0

* Added new aliases for git.

### 2013-10-11 / 1.1.0

* Added new aliases for git.

### 2013-10-11 / 1.0.13

* Added GIT autocompletions.

### 2013-09-12 / 1.0.12

* Update RVM settings.

### 2013-09-12 / 1.0.11

* Fixed installer.

### 2013-09-15 / 1.0.10

* Unix compatibility.

### 2013-09-14 / 1.0.9

* Fixed Rakefile indentation.

### 2013-09-14 / 1.0.8

* Removed unused Rake tasks.

### 2013-09-13 / 1.0.7

* Added "gfbnc" and "gbnc".

### 2013-08-26 / 1.0.6

* Fixed GIT autocompletion.

### 2013-08-26 / 1.0.5

* Fixed keybindings.
