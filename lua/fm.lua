local M = {}

local config = {
  ui = {
    default = "float",
    float = {
      border = "none",
      float_hl = "Normal",
      border_hl = "FloatBorder",
      blend = 0,
      height = 0.8,
      width = 0.8,
      x = 0.5,
      y = 0.5
    },
    split = {
      direction = "topleft",
      size = 24
    }
  },
  edit_cmd = "edit",
  on_close = {},
  on_open = {},
  mappings = {
    vert_split = "<C-v>",
    horz_split = "<C-h>",
    tabedit = "<C-t>",
    edit = "<C-e>",
    ESC = "<ESC>"
  },
  tools = {},
  debug = false,
}

local choose_file
if vim.fn.has("win32") == 1 then
  choose_file = vim.fn.getenv("TEMP") .. "/fm.nvim"
else
  choose_file = "/tmp/fm.nvim"
end

local function replace_placeholders(format, params)
  local cmd = format:gsub("%%{choose_file}", params.choose_file)
  return cmd
end

local method = config.edit_cmd
function M.setup(user_options)
  config = vim.tbl_deep_extend("force", config, user_options)
end

function M.set_method(opt)
  method = opt
end

local function check_file(file)
  local f = io.open(file)
  if f == nil then
    return
  end

  for line in f:lines() do
    vim.cmd(method .. " " .. vim.fn.fnameescape(line))
  end
  method = config.edit_cmd    -- restore the default edit method
  io.close(f)
  os.remove(file)
end

local function on_exit()
  M.close_cmd()
  for _, func in ipairs(config.on_close) do
    func()
  end
  check_file(choose_file)
  --vim.cmd [[ checktime ]]
end

local function post_creation(suffix)
  for _, func in ipairs(config.on_open) do
    func()
  end

  vim.api.nvim_buf_set_option(M.buf, "filetype", "Fm")

  local function on_suffix(m, s)
      require("fm").set_method(m)
      --vim.api.nvim_command("startinsert")
      if config.debug then
        print("method: ", m, "feedkeys: ", s)
      end
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(s or "", true, true, true), "n", false)
  end
  vim.keymap.set("t", config.mappings.edit, function()
      on_suffix("edit", suffix)
    end,
    { buffer = M.buf, noremap = true, silent = true }
  )
  vim.keymap.set("t", config.mappings.tabedit, function()
      on_suffix("tabedit", suffix)
    end,
    { buffer = M.buf, noremap = true, silent = true }
  )
  vim.keymap.set("t", config.mappings.horz_split, function()
      on_suffix("split", suffix)
    end,
    { buffer = M.buf, noremap = true, silent = true }
  )
  vim.keymap.set("t", config.mappings.vert_split, function()
      on_suffix("vsplit", suffix)
    end,
    { buffer = M.buf, noremap = true, silent = true }
  )
  vim.api.nvim_buf_set_keymap(M.buf, "t", "<ESC>", config.mappings.ESC, { silent = true })
end

local function create_win(cmd, suffix)
  M.buf = vim.api.nvim_create_buf(false, true)
  local win_height = math.ceil(vim.api.nvim_get_option("lines") * config.ui.float.height - 4)
  local win_width = math.ceil(vim.api.nvim_get_option("columns") * config.ui.float.width)
  local col = math.ceil((vim.api.nvim_get_option("columns") - win_width) * config.ui.float.x)
  local row = math.ceil((vim.api.nvim_get_option("lines") - win_height) * config.ui.float.y - 1)
  local opts = {
    style = "minimal",
    relative = "editor",
    border = config.ui.float.border,
    width = win_width,
    height = win_height,
    row = row,
    col = col
  }
  M.win = vim.api.nvim_open_win(M.buf, true, opts)
  post_creation(suffix)
  vim.fn.termopen(cmd, { on_exit = on_exit })
  vim.api.nvim_command("startinsert")
  vim.api.nvim_win_set_option(
    M.win,
    "winhl",
    "Normal:" .. config.ui.float.float_hl .. ",FloatBorder:" .. config.ui.float.border_hl
  )
  vim.api.nvim_win_set_option(M.win, "winblend", config.ui.float.blend)
  M.close_cmd = function()
    vim.api.nvim_win_close(M.win, true)
    vim.api.nvim_buf_delete(M.buf, { force = true })
  end
end

local function create_split(cmd, suffix)
  vim.cmd(config.ui.split.direction .. " " .. config.ui.split.size .. "vnew")
  M.buf = vim.api.nvim_get_current_buf()
  post_creation(suffix)
  vim.fn.termopen(cmd, { on_exit = on_exit })
  vim.api.nvim_command("startinsert")
  M.close_cmd = function()
    vim.cmd("bdelete!")
  end
end

function M.create_win(name, other_params)
  local format_params = {
    choose_file = choose_file,
  }
  local tool = config.tools[name]
  if config.ui.default == "float" then
    local create_win_cmd = replace_placeholders(
        tool.create_win_cmd_format or tool.create_split_cmd_format,
        format_params
      ) .. " " .. table.concat(other_params, " ")
    if config.debug then
      print("create_win_cmd: " .. create_win_cmd)
    end
    create_win(create_win_cmd, tool.suffix)
  elseif config.ui.default == "split" then
    local create_split_cmd = M.replace_placeholders(
        tool.create_split_cmd_format or tool.create_win_cmd_format,
        format_params
      ) .. " " .. table.concat(other_params, " ")

    if config.debug then
      print("create_split_cmd: ", create_split_cmd)
    end
    create_split(create_split_cmd, tool.suffix)
  end
end

return M
