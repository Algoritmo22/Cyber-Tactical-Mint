-- Managed by Cyber-Tactical-Mint (paleta: @@THEME_NAME@@)
-- Se genera desde configs/conky/conky.conf.tpl; edita la plantilla, no este archivo.

conky.config = {
  alignment = "top_right",
  gap_x = 24,
  gap_y = 48,
  xinerama_head = 0,
  minimum_width = 330,
  maximum_width = 330,

  own_window = true,
  own_window_class = "Conky",
  own_window_type = "desktop",
  own_window_hints = "undecorated,below,sticky,skip_taskbar,skip_pager",
  own_window_transparent = false,
  own_window_argb_visual = true,
  own_window_argb_value = 150,
  own_window_colour = "@@BG@@",

  double_buffer = true,
  background = true,
  update_interval = 1.0,
  cpu_avg_samples = 2,
  net_avg_samples = 2,
  no_buffers = true,
  text_buffer_size = 2048,
  short_units = true,
  pad_percents = 2,
  if_up_strictness = "address",

  use_xft = true,
  font = "@@FONT_MONO@@:size=9",
  draw_borders = false,
  draw_outline = false,
  draw_shades = false,
  draw_graph_borders = false,
  border_inner_margin = 14,
  border_outer_margin = 0,
  stippled_borders = 0,

  default_color = "@@FG@@",
  color1 = "@@PRIMARY@@",
  color2 = "@@SECONDARY@@",
  color3 = "@@ACCENT@@",
  color4 = "@@MUTED@@",
  color5 = "@@WARN@@",
  default_bar_height = 6,
  default_bar_width = 300,
}

conky.text = [[
${color1}${font :bold:size=12}◢ CYBER-TACTICAL ◣${font}${alignr}${color2}${time %H:%M}${color}
${color4}${hr 1}
${color3}▸ SISTEMA${color}
${color4}Host   ${color}${nodename}${alignr}${color4}Uptime ${color}${uptime_short}
${color4}Kernel ${color}${kernel}
${color4}Fecha  ${color}${time %A %d %b %Y}
${voffset 4}
${color3}▸ CPU${color}${alignr}${color2}${cpu cpu0}%${color}  ${color5}${execi 5 @@CONKY_DIR@@/cpu-temp.sh}°C${color}
${color1}${cpubar cpu0 6,300}${color}
${color4}${cpugraph cpu0 28,300 @@SECONDARY@@ @@PRIMARY@@}${color}
@@GPU_BLOCK@@
${voffset 4}
${color3}▸ MEMORIA${color}${alignr}${color2}${memperc}%${color}
${color1}${membar 6,300}${color}
${color4}RAM ${color}${mem} / ${memmax}${alignr}${color4}SWAP ${color}${swap} / ${swapmax}
${voffset 4}
${color3}▸ DISCO /${color}${alignr}${color2}${fs_used_perc /}%${color}
${color1}${fs_bar 6,300 /}${color}
${fs_used /} / ${fs_size /}${alignr}${color4}R ${color}${diskio_read} ${color4}W ${color}${diskio_write}
${voffset 4}
${color3}▸ RED${color} ${color4}@@NET_IFACE@@${color}
${if_up @@NET_IFACE@@}${color4}IP ${color}${addr @@NET_IFACE@@}
${color2}▼ ${downspeed @@NET_IFACE@@}${alignr}${color3}▲ ${upspeed @@NET_IFACE@@}
${downspeedgraph @@NET_IFACE@@ 24,146 @@SECONDARY@@ @@PRIMARY@@}${offset 8}${upspeedgraph @@NET_IFACE@@ 24,146 @@ACCENT@@ @@WARN@@}
${color4}Total ▼ ${color}${totaldown @@NET_IFACE@@}${alignr}${color4}▲ ${color}${totalup @@NET_IFACE@@}
${else}${color5}Sin conexión${color}
${endif}${voffset 4}
${color3}▸ PROCESOS${color}${alignr}${color4}CPU     MEM
${color}${top name 1}${alignr}${top cpu 1}  ${top mem 1}
${color}${top name 2}${alignr}${top cpu 2}  ${top mem 2}
${color}${top name 3}${alignr}${top cpu 3}  ${top mem 3}
${color}${top name 4}${alignr}${top cpu 4}  ${top mem 4}
${color}${top name 5}${alignr}${top cpu 5}  ${top mem 5}
@@BATT_BLOCK@@
]]
