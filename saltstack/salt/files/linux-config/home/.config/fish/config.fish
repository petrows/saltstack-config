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

    function venv
        python -m venv .env
        source .env/bin/activate.fish
    end
end

# User config
if test -f $HOME/.profile_common.fish
    source $HOME/.profile_common.fish
end
