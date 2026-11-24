# Managed by Cyber-Tactical-Mint (paleta: @@THEME_NAME@@)
add_newline = true
format = """
[┌─](fg:#@@MUTED@@)$username$hostname$directory$git_branch$git_status$python$nodejs$rust$cmd_duration
[└─](fg:#@@MUTED@@)$character"""

[character]
success_symbol = "[▸](bold fg:#@@PRIMARY@@)"
error_symbol = "[▸](bold fg:#@@DANGER@@)"

[username]
show_always = true
style_user = "fg:#@@PRIMARY@@"
format = "[\\[$user]($style_user)"

[hostname]
ssh_only = false
format = "[@$hostname\\]]($style)"
style = "fg:#@@PRIMARY@@"

[directory]
style = "bold fg:#@@SECONDARY@@"
truncation_length = 3
format = "[─\\[$path\\]]($style)"

[git_branch]
symbol = "⎇ "
style = "fg:#@@ACCENT@@"
format = " [$symbol$branch]($style)"

[git_status]
style = "fg:#@@WARN@@"
format = "[$all_status$ahead_behind]($style)"

[cmd_duration]
min_time = 2000
style = "fg:#@@WARN@@"
format = " [󰔛 $duration]($style)"
