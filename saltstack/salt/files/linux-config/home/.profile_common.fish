# Common profile config
set -gx EDITOR (which vim)
set -gx VISUAL $EDITOR
set -gx GIT_EDITOR $EDITOR
set -gx SALT_SSH_KEY "$HOME/.ssh/id_ed25519"

set test_user_path "$HOME/.krew/bin" "$HOME/.poetry/bin" "$HOME/.cargo/bin" "$HOME/.local/bin" "$HOME/bin" "/opt/wine-staging/bin/"

for p in $test_user_path;
    if test -d $p;
        set -gx PATH $p $PATH
    end
end

# Alias
{%- for alias, cmd in pillar.shell_alias.items() %}
alias {{ alias }}="{{ cmd }}"
{%- endfor %}

# Load local config, if exists
if test -f $HOME/.profile_local.fish
    source $HOME/.profile_local.fish
end
