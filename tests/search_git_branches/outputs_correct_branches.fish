# Setup test branches
set -l test_branch "test-branch-for-fzf-fish-$(random)"
set -l test_branch_2 "test-branch-for-fzf-fish-$(random)"
set -l current_branch (git rev-parse --abbrev-ref HEAD)
git branch $test_branch >/dev/null 2>&1
git branch $test_branch_2 >/dev/null 2>&1

mock commandline "--current-token --replace --" "echo \$argv"
mock commandline \* ""

# Test selecting one specific branch
set --export FZF_DEFAULT_OPTS "--select-1 --filter='$test_branch'"
set actual_single (_fzf_search_git_branches)
@test "outputs right branch for single selection" "$actual_single" = "$test_branch"

# Test selecting the current branch (with `* ` prefix)
set --export FZF_DEFAULT_OPTS "--select-1 --filter='$current_branch'"
set actual_current (_fzf_search_git_branches)
@test "correctly cleans current branch prefix" "$actual_current" = "$current_branch"

# Test selecting multiple branches (two test branches)
set --export FZF_DEFAULT_OPTS "--exact --filter='$test_branch | $test_branch_2 !HEAD'"
set actual_output (_fzf_search_git_branches)
set actual_sorted (string replace -a ' ' \n $actual_output | sort | string join ' ')
set expected_output "$test_branch $test_branch_2"
set expected_sorted (string replace -a ' ' \n $expected_output | sort | string join ' ')
test "$actual_sorted" = "$expected_sorted"
@test "outputs right branches for multiple selections" $status -eq 0

# Clean up the test branches
git branch -D $test_branch >/dev/null 2>&1
git branch -D $test_branch_2 >/dev/null 2>&1
