#!/usr/bin/env fish

set -g test_root (mktemp -d)
set -g git_log "$test_root/git.log"
set -g reject_branch_changes 0
set -g fail_rebase 0
set -gx GIT_MERGE_AUTOEDIT no
set -gx GIT_CONFIG_NOSYSTEM 1
set -gx GIT_CONFIG_GLOBAL /dev/null

function cleanup --on-event fish_exit
  command rm -rf "$test_root"
end

function fail
  printf 'FAIL: %s\n' "$argv" >&2
  exit 1
end

function assert_equal
  if test "$argv[1]" != "$argv[2]"
    fail "$argv[3]: expected '$argv[2]', got '$argv[1]'"
  end
end

function assert_success
  if test "$argv[1]" -ne 0
    fail "$argv[2]: expected success, got status $argv[1]"
  end
end

function assert_ref_exists
  command git -C "$fixture_repo" show-ref --verify --quiet "$argv[1]"; or fail "$argv[2]: missing $argv[1]"
end

function assert_ref_missing
  if command git -C "$fixture_repo" show-ref --verify --quiet "$argv[1]"
    fail "$argv[2]: unexpected $argv[1]"
  end
end

function logged_count
  set count 0

  while read -l line
    set fields (string split "\t" -- "$line")
    if test "$fields[1]" = "$argv[1]"
      set count (math $count + 1)
    end
  end <"$git_log"

  echo $count
end

function assert_logged
  while read -l line
    if test "$line" = "$argv[1]"
      return 0
    end
  end <"$git_log"

  fail "$argv[2]: missing '$argv[1]'"
end

function reset_log
  printf '' >"$git_log"
  set -g reject_branch_changes 0
  set -g fail_rebase 0
end

function git
  printf '%s\n' (string join "\t" -- $argv) >>"$git_log"

  if test "$reject_branch_changes" = 1
    switch $argv[1]
      case checkout switch pull
        return 97
    end
  end

  if test "$fail_rebase" = 1; and test "$argv[1]" = rebase
    return 98
  end

  command git $argv
end

function __fishamnium_print_error
  printf '%s\n' "$argv" >&2
end

set -g FISHAMNIUM_COLOR_BOLD
set -g FISHAMNIUM_COLOR_FG_PRIMARY
set -g FISHAMNIUM_COLOR_FG_SECONDARY
set -g FISHAMNIUM_COLOR_ERROR
set -g FISHAMNIUM_COLOR_RESET
set -g FISHAMNIUM_HELPER false

source (path resolve (status dirname)/../plugins/30_git.fish)

function g_is_repository
  command git rev-parse --git-dir >/dev/null 2>/dev/null
end

function g_branch_name
  command git symbolic-ref --quiet --short HEAD
end

function setup_fixture
  set name $argv[1]
  set root "$test_root/$name"
  set -g fixture_origin "$root/origin.git"
  set -g fixture_publisher "$root/publisher"
  set -g fixture_repo "$root/repository"
  set -g fixture_base_worktree "$root/base-worktree"

  command mkdir -p "$root"
  command git init --bare --initial-branch=main "$fixture_origin" >/dev/null
  command git init --initial-branch=main "$fixture_publisher" >/dev/null
  command git -C "$fixture_publisher" config user.name Fishamnium
  command git -C "$fixture_publisher" config user.email fishamnium@example.com
  printf 'base\n' >"$fixture_publisher/base.txt"
  command git -C "$fixture_publisher" add base.txt
  command git -C "$fixture_publisher" commit -m base >/dev/null
  command git -C "$fixture_publisher" remote add origin "$fixture_origin"
  command git -C "$fixture_publisher" push -u origin main >/dev/null

  command git clone "$fixture_origin" "$fixture_repo" >/dev/null
  command git -C "$fixture_repo" config user.name Fishamnium
  command git -C "$fixture_repo" config user.email fishamnium@example.com
  command git -C "$fixture_repo" config commit.gpgSign false
  command git -C "$fixture_repo" config pull.rebase false
  command git -C "$fixture_repo" config pull.ff false
  command git -C "$fixture_repo" switch -c feature >/dev/null
  printf 'feature\n' >"$fixture_repo/feature.txt"
  command git -C "$fixture_repo" add feature.txt
  command git -C "$fixture_repo" commit -m feature >/dev/null
  command git -C "$fixture_repo" worktree add "$fixture_base_worktree" main >/dev/null

  set -g fixture_local_main (command git -C "$fixture_repo" rev-parse refs/heads/main)
  set -g fixture_feature (command git -C "$fixture_repo" rev-parse refs/heads/feature)

  printf 'remote\n' >"$fixture_publisher/remote.txt"
  command git -C "$fixture_publisher" add remote.txt
  command git -C "$fixture_publisher" commit -m remote >/dev/null
  command git -C "$fixture_publisher" push origin main >/dev/null
  set -g fixture_remote_main (command git -C "$fixture_publisher" rev-parse refs/heads/main)

  cd "$fixture_repo"
  reset_log
end

function assert_base_unchanged
  assert_equal (command git -C "$fixture_repo" rev-parse refs/heads/main) "$fixture_local_main" "$argv[1] local base"
  assert_equal (command git -C "$fixture_base_worktree" rev-parse HEAD) "$fixture_local_main" "$argv[1] base worktree"
end

function test_refresh_rebase
  setup_fixture refresh-rebase
  set -g reject_branch_changes 1

  g_refresh -r origin main
  set result $status

  assert_success $result 'g_refresh rebase'
  assert_equal (command git branch --show-current) feature 'g_refresh rebase current branch'
  assert_base_unchanged 'g_refresh rebase'
  assert_equal (command git rev-parse refs/remotes/origin/main) "$fixture_remote_main" 'g_refresh rebase remote ref'
  command git merge-base --is-ancestor "$fixture_remote_main" HEAD; or fail 'g_refresh did not rebase onto the remote ref'
  assert_equal (logged_count fetch) 1 'g_refresh rebase fetch count'
  assert_equal (logged_count rebase) 1 'g_refresh rebase operation count'
  assert_equal (logged_count pull) 0 'g_refresh rebase pull count'
  assert_equal (logged_count checkout) 0 'g_refresh rebase checkout count'
  assert_equal (logged_count switch) 0 'g_refresh rebase switch count'
  assert_logged "fetch\torigin\t+refs/heads/main:refs/remotes/origin/main" 'g_refresh rebase fetch refspec'
  assert_logged "rebase\trefs/remotes/origin/main" 'g_refresh rebase target'
end

function test_refresh_merge
  setup_fixture refresh-merge
  set -g reject_branch_changes 1

  g_refresh -m -r origin main
  set result $status

  assert_success $result 'g_refresh merge'
  assert_equal (command git branch --show-current) feature 'g_refresh merge current branch'
  assert_base_unchanged 'g_refresh merge'
  assert_equal (command git rev-parse HEAD^1) "$fixture_feature" 'g_refresh merge first parent'
  assert_equal (command git rev-parse HEAD^2) "$fixture_remote_main" 'g_refresh merge second parent'
  assert_equal (logged_count fetch) 1 'g_refresh merge fetch count'
  assert_equal (logged_count merge) 1 'g_refresh merge operation count'
  assert_equal (logged_count pull) 0 'g_refresh merge pull count'
  assert_equal (logged_count checkout) 0 'g_refresh merge checkout count'
  assert_equal (logged_count switch) 0 'g_refresh merge switch count'
  assert_logged "merge\trefs/remotes/origin/main" 'g_refresh merge target'
end

function test_start_from_remote_ref
  setup_fixture start

  g_start -r origin topic main
  set result $status

  assert_success $result 'g_start'
  assert_equal (command git branch --show-current) topic 'g_start current branch'
  assert_equal (command git rev-parse HEAD) "$fixture_remote_main" 'g_start remote base'
  assert_base_unchanged 'g_start'
  assert_equal (logged_count fetch) 1 'g_start fetch count'
  assert_equal (logged_count pull) 0 'g_start pull count'
  assert_equal (logged_count checkout) 0 'g_start checkout count'
  assert_logged "switch\t--no-track\t-c\ttopic\trefs/remotes/origin/main" 'g_start switch target'
end

function test_update_uses_single_pull
  setup_fixture update

  g_update -r origin main
  set result $status

  assert_success $result 'g_update'
  assert_equal (logged_count fetch) 0 'g_update explicit fetch count'
  assert_equal (logged_count pull) 1 'g_update pull count'
  assert_logged "pull\torigin\tmain" 'g_update pull command'
end

function test_sync_direct_refs
  setup_fixture sync
  set upstream "$test_root/sync/upstream.git"
  command git clone --bare "$fixture_origin" "$upstream" >/dev/null
  command git -C "$fixture_repo" remote add upstream "$upstream"
  command git -C "$fixture_publisher" remote add upstream "$upstream"
  printf 'upstream\n' >"$fixture_publisher/upstream.txt"
  command git -C "$fixture_publisher" add upstream.txt
  command git -C "$fixture_publisher" commit -m upstream >/dev/null
  command git -C "$fixture_publisher" push upstream main >/dev/null
  set upstream_main (command git -C "$fixture_publisher" rev-parse refs/heads/main)
  reset_log
  set -g reject_branch_changes 1

  g_sync -r origin -u upstream main
  set result $status

  assert_success $result 'g_sync'
  assert_equal (command git branch --show-current) feature 'g_sync current branch'
  assert_base_unchanged 'g_sync'
  assert_equal (command git --git-dir="$fixture_origin" rev-parse refs/heads/main) "$upstream_main" 'g_sync destination ref'
  assert_equal (logged_count fetch) 1 'g_sync fetch count'
  assert_equal (logged_count push) 1 'g_sync push count'
  assert_equal (logged_count pull) 0 'g_sync pull count'
  assert_equal (logged_count checkout) 0 'g_sync checkout count'
  assert_equal (logged_count switch) 0 'g_sync switch count'
  assert_logged "fetch\tupstream\t+refs/heads/main:refs/remotes/upstream/main" 'g_sync fetch refspec'
  assert_logged "push\t-f\torigin\trefs/remotes/upstream/main:refs/heads/main" 'g_sync push refspec'
end

function test_pull_request_preserves_occupied_branch
  setup_fixture pull-request-occupied
  set -g reject_branch_changes 1

  __g_pull_request origin main feature
  set result $status

  assert_success $result 'g_pull_request occupied base'
  assert_equal (command git branch --show-current) feature 'g_pull_request occupied base current branch'
  assert_ref_exists refs/heads/feature 'g_pull_request occupied base'
  assert_base_unchanged 'g_pull_request occupied base'
  assert_equal (logged_count switch) 0 'g_pull_request occupied base switch count'
  assert_logged "push\torigin\trefs/heads/feature:refs/heads/feature" 'g_pull_request occupied base push refspec'
end

function test_pull_request_cleanup_when_available
  setup_fixture pull-request-cleanup
  command git -C "$fixture_repo" worktree remove "$fixture_base_worktree"
  reset_log

  __g_pull_request origin main feature
  set result $status

  assert_success $result 'g_pull_request cleanup'
  assert_equal (command git branch --show-current) main 'g_pull_request cleanup current branch'
  assert_ref_missing refs/heads/feature 'g_pull_request cleanup'
  assert_logged "switch\tmain" 'g_pull_request cleanup switch'
  assert_logged "branch\t-D\t--\tfeature" 'g_pull_request cleanup delete'
end

function test_pull_request_stops_after_refresh_failure
  setup_fixture pull-request-refresh-failure
  set -g fail_rebase 1

  g_pull_request -r origin main
  set result $status

  if test $result -eq 0
    fail 'g_pull_request refresh failure: expected failure'
  end

  assert_equal (logged_count push) 0 'g_pull_request refresh failure push count'
  assert_equal (command git branch --show-current) feature 'g_pull_request refresh failure current branch'
end

function test_fast_pull_request_dry_run_does_not_mutate_refs
  setup_fixture fast-pull-request-dry-run
  set feature_head (command git rev-parse refs/heads/feature)
  set origin_main (command git --git-dir="$fixture_origin" rev-parse refs/heads/main)

  g_fast_pull_request -N -r origin dry-topic message main >/dev/null
  set result $status

  assert_success $result 'g_fast_pull_request dry run'
  assert_equal (command git branch --show-current) feature 'g_fast_pull_request dry run current branch'
  assert_equal (command git rev-parse refs/heads/feature) "$feature_head" 'g_fast_pull_request dry run feature ref'
  assert_equal (command git --git-dir="$fixture_origin" rev-parse refs/heads/main) "$origin_main" 'g_fast_pull_request dry run remote ref'
  assert_ref_missing refs/heads/dry-topic 'g_fast_pull_request dry run'
  assert_equal (logged_count fetch) 0 'g_fast_pull_request dry run fetch count'
  assert_equal (logged_count switch) 0 'g_fast_pull_request dry run switch count'
  assert_equal (logged_count commit) 0 'g_fast_pull_request dry run commit count'
  assert_equal (logged_count rebase) 0 'g_fast_pull_request dry run rebase count'
  assert_equal (logged_count push) 0 'g_fast_pull_request dry run push count'
end

function test_delete_rejects_occupied_branch_before_mutation
  setup_fixture delete-occupied

  g_delete -r origin main
  set result $status

  if test $result -eq 0
    fail 'g_delete occupied branch: expected failure'
  end

  assert_ref_exists refs/heads/main 'g_delete occupied branch'
  assert_equal (logged_count branch) 0 'g_delete occupied branch delete count'
  assert_equal (logged_count push) 0 'g_delete occupied branch push count'
end

test_refresh_rebase
test_refresh_merge
test_start_from_remote_ref
test_update_uses_single_pull
test_sync_direct_refs
test_pull_request_preserves_occupied_branch
test_pull_request_cleanup_when_available
test_pull_request_stops_after_refresh_failure
test_fast_pull_request_dry_run_does_not_mutate_refs
test_delete_rejects_occupied_branch_before_mutation

printf 'All Git workflow tests passed.\n'
