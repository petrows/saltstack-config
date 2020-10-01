# Include powerline (if exists)
if test -d /usr/share/powerline
    set fish_function_path $fish_function_path "/usr/share/powerline/bindings/fish"
    source /usr/share/powerline/bindings/fish/powerline-setup.fish
    powerline-setup
end

# Include FZF (if exists)
if test -d /opt/fzf
    set fish_function_path $fish_function_path "/opt/fzf/shell/key-bindings.fish"
    set PATH $PATH /opt/fzf/bin
    source /opt/fzf/shell/key-bindings.fish
    fzf_key_bindings
end

# User config
if test -f $HOME/.profile_common.fish
    source $HOME/.profile_common.fish
end
