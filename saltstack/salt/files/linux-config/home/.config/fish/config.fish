# This block called only on "human" shells
if status --is-interactive
    # Include powerline (if exists)
    if test -d /usr/share/powerline
        set fish_function_path $fish_function_path /usr/share/powerline/bindings/fish
        source /usr/share/powerline/bindings/fish/powerline-setup.fish
        powerline-setup
    end

    # Include FZF (if exists)
    if test -d /opt/fzf
        set fish_function_path $fish_function_path "/opt/fzf/shell/key-bindings.fish"
        set PATH $PATH /opt/fzf/bin
        source /opt/fzf/shell/key-bindings.fish
        # This must be wrapped with function to be activated later
        function fish_user_key_bindings
            fzf_key_bindings
        end
    end

    # Python VENV: functions to (if not exists) create and activate
    # virtual env in current folder with `.env` path, or specified as arg
    function venv
        set env_name $argv[1]
        if test -z "$env_name"
            set env_name ".env"
        end
        echo "Activating python venv: $env_name"
        if not test -f $env_name/bin/activate.fish
            echo "Creating new venv"
            python -m virtualenv $env_name
        end
        source $env_name/bin/activate.fish
    end
    # Python VENV: shortcut for venv <system default venv>
    function vapp
        venv /opt/venv/app
    end
end

# User config
if test -f $HOME/.profile_common.fish
    source $HOME/.profile_common.fish
end
