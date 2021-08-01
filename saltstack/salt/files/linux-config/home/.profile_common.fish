# Common profile config
set -gx EDITOR (which vim)
set -gx VISUAL $EDITOR
set -gx GIT_EDITOR $EDITOR

set test_user_path "$HOME/.poetry/bin" "$HOME/.cargo/bin" "$HOME/.local/bin" "$HOME/bin"

set SALT_SSH_KEY "$HOME/.ssh/id_ed25519"

for p in $test_user_path;
    if test -d $p;
        set -gx PATH $p $PATH
    end
end

# Load local config, if exists
if test -f $HOME/.profile_local.fish
    source $HOME/.profile_local.fish
end
