if not status --is-interactive
    exit
end

function _fnm_cache_get -a dir
    set -l cache_count (count $_fnm_cache_dirs)
    if test $cache_count -gt 0
        for i in (seq $cache_count)
            if test "$_fnm_cache_dirs[$i]" = "$dir"
                echo "$_fnm_cache_results[$i]"
                return 0
            end
        end
    end

    return 1
end

function _fnm_cache_set -a dir result
    set -l cache_count (count $_fnm_cache_dirs)
    if test $cache_count -gt 0
        for i in (seq $cache_count)
            if test "$_fnm_cache_dirs[$i]" = "$dir"
                set -g _fnm_cache_results[$i] "$result"
                return
            end
        end
    end

    set -ga _fnm_cache_dirs "$dir"
    set -ga _fnm_cache_results "$result"
end

# fnm's folder goes on PATH now, before direnv's hook loads an .envrc on the first prompt: direnv
# undoes an .envrc by putting PATH back as it was before the load, which would drop the folder if
# fnm had added it after.
fnm env --corepack-enabled --resolve-engines --version-file-strategy=recursive --log-level=quiet --shell fish | source

function fnm_use --description 'Change node version'
    set -l _fnm_candidate_files .nvmrc .node-version
    test "$FNM_RESOLVE_ENGINES" = true; and set -a _fnm_candidate_files package.json

    set -l search_dir $PWD
    set -l found_file ""
    set -l search_chain

    if test "$FNM_VERSION_FILE_STRATEGY" = "recursive"
        while test -n "$search_dir"
            set -a search_chain "$search_dir"

            for file in $_fnm_candidate_files
                if test -f "$search_dir/$file"
                    set found_file "$search_dir/$file"
                    break
                end
            end

            if test -n "$found_file"
                break
            end

            set -l cached_result (_fnm_cache_get "$search_dir")
            if test $status -eq 0
                if test "$cached_result" != "__fnm_none__"
                    set found_file "$cached_result"
                end
                break
            end

            if test "$search_dir" = "/"
                break
            end

            set search_dir (path dirname "$search_dir")
        end
    else
        for file in $_fnm_candidate_files
            if test -f "$search_dir/$file"
                set found_file "$search_dir/$file"
                break
            end
        end
    end

    if test "$FNM_VERSION_FILE_STRATEGY" = "recursive"
        set -l cache_result "__fnm_none__"
        test -n "$found_file"; and set cache_result "$found_file"

        for dir in $search_chain
            _fnm_cache_set "$dir" "$cache_result"
        end
    end

    if test -n "$found_file"
        set -l mod_time (path mtime "$found_file")

        if not set -q _fnm_active_state
            or test "$_fnm_active_state[1]" != "$found_file"
            or test "$mod_time" -gt "$_fnm_active_state[2]"
            
            command fnm use --silent-if-unchanged
            
            # Cache state: [1]=Path [2]=Mtime
            set -g _fnm_active_state "$found_file" "$mod_time"
        end
    else if set -q _fnm_active_state
        command fnm use --silent-if-unchanged system
        set -e _fnm_active_state
    end
end

function _fnm_autoload_on_cd --on-variable PWD
    status --is-command-substitution; and return
    fnm_use
end

function _fnm_autoload_on_prompt --on-event fish_prompt
    functions -e _fnm_autoload_on_prompt
    fnm_use
end
