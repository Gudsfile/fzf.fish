function run_in_non_git_dir
    set -l original_dir $PWD
    set -l temp_dir (mktemp -d)
    cd $temp_dir
    _fzf_search_git_branches $argv
    set -l status_code $status
    cd $original_dir
    rm -rf $temp_dir
    return $status_code
end

set stderr (run_in_non_git_dir 2>&1 >/dev/null)
@test "fails if not in a git repo" $status -ne 0

set expected_stderr "_fzf_search_git_branches: Not in a git repository."
@test "shows informative error if not in a git repo" "$stderr" = "$expected_stderr"
