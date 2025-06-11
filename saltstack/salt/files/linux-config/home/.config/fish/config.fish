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
    # FSSH shortcut implementation (moved from script)
    function fssh
        set SSH_CONN $argv[1]
        if test -z "$SSH_CONN"
            echo "Usage: fssh <user@host>"
            return 1
        end

        # Check - do we have SSH agent running?
        if not set -q SSH_AGENT_PID
            echo "SSH Agent seems to be not running, start it"
            ssh-add
        end

        set SSH_HOSTNAME_SHORT (echo "$SSH_CONN" | cut -d '@' -f 2)

        # If this is .pws domain -> cut off suffix
        if string match -q "*.pws" $SSH_HOSTNAME_SHORT
            set SSH_HOSTNAME_SHORT (string replace -r "\.pws\$" "" $SSH_HOSTNAME_SHORT)
        else
            # Cut hostname before 1st dot (short)
            set SSH_HOSTNAME_SHORT (echo "$SSH_CONN" | cut -d '@' -f 2 | cut -d '.' -f 1)
        end

        # Cut username (if exists)
        if string match -q "*@*" $SSH_CONN
            set SSH_USERNAME (echo "$SSH_CONN" | cut -d '@' -f 1)
            set SSH_HOSTNAME (echo "$SSH_CONN" | cut -d '@' -f 2)
        else
            set SSH_USERNAME root
            set SSH_HOSTNAME $SSH_CONN
        end

        if test -z "$SSH_USERNAME"
            echo "Invalid SSH user@host!"
            return 1
        end

        # Fake konsole tab title: create and cd to "host"
        set FAKE_NAME "($SSH_USERNAME) $SSH_HOSTNAME_SHORT"
        set FAKE_PATH /tmp/fssh-fake-path/$FAKE_NAME
        mkdir -p $FAKE_PATH
        cd $FAKE_PATH

        # Call SSH
        ssh -A $SSH_USERNAME@$SSH_HOSTNAME -t fish
    end
end

# User config
if test -f $HOME/.profile_common.fish
    source $HOME/.profile_common.fish
end
