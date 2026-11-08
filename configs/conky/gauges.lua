--[[ Cyber-Tactical-Mint :: gauges.lua
     Relojes estilo tablero de carreras para Conky (Cairo).
     Muestra: carga CPU, temperatura CPU, RAM y GPU.
     Si un sensor no existe (VM, sin GPU dedicada) el reloj marca N/A. ]]

require 'cairo'
pcall(require, 'cairo_xlib')

local PI = math.pi
local START, SWEEP, SEGMENTS = 135, 270, 36
local FONT = "monospace"

local function rad(d) return d * PI / 180 end
local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end

local function read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

local function read_num(path)
  local s = read_file(path)
  if not s then return nil end
  return tonumber(s:match("%-?%d+%.?%d*"))
end

---------------------------------------------------------------- sensores
local cpu_temp_path, cpu_temp_searched = nil, false

local function find_cpu_temp()
  for i = 0, 15 do
    local name = read_file("/sys/class/hwmon/hwmon" .. i .. "/name")
    if name and (name:match("coretemp") or name:match("k10temp") or name:match("zenpower")) then
      return "/sys/class/hwmon/hwmon" .. i .. "/temp1_input"
    end
  end
  for i = 0, 15 do
    local t = read_file("/sys/class/thermal/thermal_zone" .. i .. "/type")
    if t and (t:match("x86_pkg_temp") or t:match("cpu")) then
      return "/sys/class/thermal/thermal_zone" .. i .. "/temp"
    end
  end
  if read_file("/sys/class/thermal/thermal_zone0/temp") then
    return "/sys/class/thermal/thermal_zone0/temp"
  end
  return false
end

local function cpu_temp()
  if not cpu_temp_searched then
    cpu_temp_path = find_cpu_temp()
    cpu_temp_searched = true
  end
  if not cpu_temp_path then return nil end
  local v = read_num(cpu_temp_path)
  return v and v / 1000 or nil
end

local gpu_kind, gpu_amd_dir = nil, nil
local gpu_cache = { load = nil, temp = nil, stamp = 0 }

local function detect_gpu()
  local p = io.popen("command -v nvidia-smi 2>/dev/null")
  if p then
    local out = p:read("*a"); p:close()
    if out and out:match("%S") then return "nvidia" end
  end
  for i = 0, 3 do
    local d = "/sys/class/drm/card" .. i .. "/device"
    if read_file(d .. "/gpu_busy_percent") then gpu_amd_dir = d; return "amd" end
  end
  return "none"
end

-- Se consulta cada 2 s para no gastar CPU lanzando nvidia-smi cada segundo
local function gpu_read()
  local now = os.time()
  if now - gpu_cache.stamp < 2 then return gpu_cache.load, gpu_cache.temp end
  gpu_cache.stamp = now
  if not gpu_kind then gpu_kind = detect_gpu() end
  if gpu_kind == "nvidia" then
    local p = io.popen("nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null")
    if p then
      local out = p:read("*l"); p:close()
      if out then
        local l, t = out:match("(%d+)%s*,%s*(%d+)")
        gpu_cache.load, gpu_cache.temp = tonumber(l), tonumber(t)
      end
    end
  elseif gpu_kind == "amd" then
    gpu_cache.load = read_num(gpu_amd_dir .. "/gpu_busy_percent")
    gpu_cache.temp = nil
    for j = 0, 10 do
      local t = read_num(gpu_amd_dir .. "/hwmon/hwmon" .. j .. "/temp1_input")
      if t then gpu_cache.temp = t / 1000; break end
    end
  end
  return gpu_cache.load, gpu_cache.temp
end

---------------------------------------------------------------- dibujo
local function seg_color(f)
  if f < 0.55 then return 0.0, 0.95, 0.85      -- cian
  elseif f < 0.80 then return 1.0, 0.75, 0.0   -- ámbar
  else return 1.0, 0.12, 0.2 end               -- zona roja
end

local function center_text(cr, text, x, y, size, bold, r, g, b, a)
  cairo_select_font_face(cr, FONT, CAIRO_FONT_SLANT_NORMAL,
    bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)
  cairo_set_font_size(cr, size)
  local ext = cairo_text_extents_t:create()
  cairo_text_extents(cr, text, ext)
  cairo_set_source_rgba(cr, r, g, b, a or 1)
  cairo_move_to(cr, x - (ext.width / 2 + ext.x_bearing), y)
  cairo_show_text(cr, text)
end

local function gauge(cr, cx, cy, r, value, vmax, label, main_text)
  local frac = value and clamp(value / vmax, 0, 1) or 0

  -- esfera
  cairo_set_source_rgba(cr, 0.02, 0.04, 0.07, 0.85)
  cairo_arc(cr, cx, cy, r + 12, 0, 2 * PI); cairo_fill(cr)
  cairo_set_line_width(cr, 2)
  cairo_set_source_rgba(cr, 0.0, 0.95, 0.85, 0.5)
  cairo_arc(cr, cx, cy, r + 12, 0, 2 * PI); cairo_stroke(cr)

  -- arco segmentado
  cairo_set_line_width(cr, 9)
  cairo_set_line_cap(cr, CAIRO_LINE_CAP_BUTT)
  local seg = SWEEP / SEGMENTS
  for i = 0, SEGMENTS - 1 do
    local a1 = START + seg * i + 0.8
    local a2 = START + seg * (i + 1) - 0.8
    local f = (i + 0.5) / SEGMENTS
    if value and f <= frac then
      local sr, sg, sb = seg_color(f)
      cairo_set_source_rgba(cr, sr, sg, sb, 1)
    else
      cairo_set_source_rgba(cr, 0.25, 0.30, 0.35, 0.45)
    end
    cairo_arc(cr, cx, cy, r, rad(a1), rad(a2)); cairo_stroke(cr)
  end

  -- marcas
  cairo_set_line_width(cr, 1.5)
  cairo_set_source_rgba(cr, 0.8, 0.95, 0.95, 0.7)
  for i = 0, 10 do
    local a = rad(START + SWEEP * i / 10)
    local r1 = r - 9
    local r2 = r - ((i % 5 == 0) and 17 or 13)
    cairo_move_to(cr, cx + r1 * math.cos(a), cy + r1 * math.sin(a))
    cairo_line_to(cr, cx + r2 * math.cos(a), cy + r2 * math.sin(a))
    cairo_stroke(cr)
  end
  for _, k in ipairs({ 0, 5, 10 }) do
    local a = rad(START + SWEEP * k / 10)
    local rl = r - 28
    center_text(cr, string.format("%d", math.floor(vmax * k / 10)),
      cx + rl * math.cos(a), cy + rl * math.sin(a) + 3, 8, false, 0.7, 0.85, 0.85, 0.8)
  end

  -- aguja
  local na = rad(START + SWEEP * frac)
  cairo_set_line_width(cr, 3)
  cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
  cairo_set_source_rgba(cr, 1, 0.1, 0.2, 1)
  cairo_move_to(cr, cx - 9 * math.cos(na), cy - 9 * math.sin(na))
  cairo_line_to(cr, cx + (r - 6) * math.cos(na), cy + (r - 6) * math.sin(na))
  cairo_stroke(cr)
  cairo_set_source_rgba(cr, 0.05, 0.07, 0.1, 1)
  cairo_arc(cr, cx, cy, 6, 0, 2 * PI); cairo_fill(cr)
  cairo_set_source_rgba(cr, 1, 0.1, 0.2, 1)
  cairo_set_line_width(cr, 2)
  cairo_arc(cr, cx, cy, 6, 0, 2 * PI); cairo_stroke(cr)

  -- textos
  center_text(cr, main_text, cx, cy + r * 0.62, 14, true, 0.85, 1, 0.97, 1)
  center_text(cr, label, cx, cy + r * 0.62 + 12, 8, false, 0.0, 0.95, 0.85, 0.9)
end

local function panel(cr, w, h)
  local x, y, rr = 4, 4, 14
  cairo_new_sub_path(cr)
  cairo_arc(cr, x + w - rr, y + rr, rr, rad(-90), 0)
  cairo_arc(cr, x + w - rr, y + h - rr, rr, 0, rad(90))
  cairo_arc(cr, x + rr, y + h - rr, rr, rad(90), rad(180))
  cairo_arc(cr, x + rr, y + rr, rr, rad(180), rad(270))
  cairo_close_path(cr)
  cairo_set_source_rgba(cr, 0.03, 0.05, 0.08, 0.75)
  cairo_fill_preserve(cr)
  cairo_set_source_rgba(cr, 0.0, 0.95, 0.85, 0.6)
  cairo_set_line_width(cr, 1.5)
  cairo_stroke(cr)
end

local function num(expr) return tonumber(conky_parse(expr)) or 0 end

local function draw(cr, width)
  panel(cr, width - 8, 392)
  center_text(cr, "// CYBER-TACTICAL HUD", width / 2, 26, 11, true, 0.0, 0.95, 0.85, 1)

  local cx1, cx2 = width / 2 - 88, width / 2 + 88
  local cy1, cy2 = 118, 285
  local R = 62

  local cpu = num("${cpu cpu0}")
  gauge(cr, cx1, cy1, R, cpu, 100, "CPU LOAD", string.format("%d%%", cpu))

  local t = cpu_temp()
  gauge(cr, cx2, cy1, R, t, 110, "CPU TEMP", t and string.format("%d°C", t) or "N/A")

  local mem = num("${memperc}")
  local mlabel = "RAM " .. conky_parse("${mem}") .. "/" .. conky_parse("${memmax}")
  gauge(cr, cx1, cy2, R, mem, 100, mlabel, string.format("%d%%", mem))

  local gl, gt = gpu_read()
  local glabel = gt and string.format("GPU %d°C", gt) or "GPU"
  gauge(cr, cx2, cy2, R, gl, 100, glabel, gl and string.format("%d%%", gl) or "N/A")
end

function conky_main()
  if conky_window == nil then return end
  local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
    conky_window.visual, conky_window.width, conky_window.height)
  local cr = cairo_create(cs)
  pcall(draw, cr, conky_window.width)   -- un fallo de dibujo no debe tumbar Conky
  cairo_destroy(cr)
  cairo_surface_destroy(cs)
end
