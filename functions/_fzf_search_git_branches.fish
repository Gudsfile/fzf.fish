function _fzf_search_git_branches --description "Search git branches with fzf (multi-select)"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo '_fzf_search_git_branches: Not in a git repository.' >&2
        return 1
    end

    set -f preview_cmd 'bash -c "
        branch=\$(echo {} | sed \"s/^..//\");
        git log --color=always --oneline --decorate --max-count=20 \"\$branch\"
    "'

    set -f selected_branches (
        git branch --all --color=always |
        _fzf_wrapper --ansi \
            --multi \
            --prompt="Git Branches> " \
            --query=(commandline --current-token) \
            --preview="$preview_cmd" \
            --preview-window=right:60% \
            $fzf_git_branches_opts
    )

    if test $status -eq 0
        set -f cleaned_branches

        for branch in $selected_branches
            set branch (string replace -r '^[* ]+ ' '' $branch)
            set branch (string trim $branch)
            set branch (string replace -r '^remotes/[^/]+/' '' $branch)

            if string match -rq '^\(HEAD detached' -- $branch
                set branch HEAD
            end

            if not contains -- $branch $cleaned_branches
                set --append cleaned_branches $branch
            end
        end

        commandline --current-token --replace -- (string join ' ' $cleaned_branches)
    end

    commandline --function repaint
end
