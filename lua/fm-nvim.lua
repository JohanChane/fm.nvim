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
  broot_conf = vim.fn.stdpath("data") .. "/site/pack/packer/start/fm-nvim/assets/broot_conf.hjson",
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
}

local choose_file
if vim.fn.has("win32") == 1 then
  choose_file = vim.fn.getenv("TEMP") .. "/fm-nvim"
else
  choose_file = "/tmp/fm-nvim"
end

function M.replace_placeholders(format, params)
  local cmd = format
  cmd = cmd:gsub("%%{choose_file}", params.choose_file)
  return cmd
end

local method = config.edit_cmd
function M.setup(user_options)
  config = vim.tbl_deep_extend("force", config, user_options)
end

function M.setMethod(opt)
  method = opt
end

local function checkFile(file)
  if io.open(file, "r") ~= nil then
    for line in io.lines(file) do
      vim.cmd(method .. " " .. vim.fn.fnameescape(line))
    end
    method = config.edit_cmd
    io.close(io.open(file, "r"))
    os.remove(file)
  end
end

local function on_exit()
  M.closeCmd()
  for _, func in ipairs(config.on_close) do
    func()
  end
  checkFile(choose_file)
  checkFile(vim.fn.getenv("HOME") .. "/.cache/fff/opened_file")
  vim.cmd [[ checktime ]]
end

local function postCreation(suffix)
  for _, func in ipairs(config.on_open) do
    func()
  end
  vim.api.nvim_buf_set_option(M.buf, "filetype", "Fm")
  vim.api.nvim_buf_set_keymap(
    M.buf,
    "t",
    config.mappings.edit,
    '<C-\\><C-n>:lua require("fm-nvim").setMethod("edit")<CR>i' .. suffix,
    { silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    M.buf,
    "t",
    config.mappings.tabedit,
    '<C-\\><C-n>:lua require("fm-nvim").setMethod("tabedit")<CR>i' .. suffix,
    { silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    M.buf,
    "t",
    config.mappings.horz_split,
    '<C-\\><C-n>:lua require("fm-nvim").setMethod("split | edit")<CR>i' .. suffix,
    { silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    M.buf,
    "t",
    config.mappings.vert_split,
    '<C-\\><C-n>:lua require("fm-nvim").setMethod("vsplit | edit")<CR>i' .. suffix,
    { silent = true }
  )
  vim.api.nvim_buf_set_keymap(M.buf, "t", "<ESC>", config.mappings.ESC, { silent = true })
end

local function createWin(cmd, suffix)
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
  postCreation(suffix)
  vim.fn.termopen(cmd, { on_exit = on_exit })
  vim.api.nvim_command("startinsert")
  vim.api.nvim_win_set_option(
    M.win,
    "winhl",
    "Normal:" .. config.ui.float.float_hl .. ",FloatBorder:" .. config.ui.float.border_hl
  )
  vim.api.nvim_win_set_option(M.win, "winblend", config.ui.float.blend)
  M.closeCmd = function()
    vim.api.nvim_win_close(M.win, true)
    vim.api.nvim_buf_delete(M.buf, { force = true })
  end
end

local function createSplit(cmd, suffix)
  vim.cmd(config.ui.split.direction .. " " .. config.ui.split.size .. "vnew")
  M.buf = vim.api.nvim_get_current_buf()
  postCreation(suffix)
  vim.fn.termopen(cmd, { on_exit = on_exit })
  vim.api.nvim_command("startinsert")
  M.closeCmd = function()
    vim.cmd("bdelete!")
  end
end

function M.CreateWindow(name, other_params, suffix)
  local format_params = {
    choose_file = choose_file,
  }
  local create_win_cmd = M.replace_placeholders(config.tools[name].create_win_cmd_format, format_params)
      .. " " .. table.concat(other_params, " ")
  if config.ui.default == "float" then
    createWin(create_win_cmd, suffix)
  elseif config.ui.default == "split" then
    local create_split_cmd
    local create_split_cmd_format = config.tools[name].create_split_cmd_format
    if create_split_cmd_format == nil then
      create_split_cmd = create_win_cmd
    else
      create_split_cmd = M.replace_placeholders(create_split_cmd_format, format_params)
          .. " " .. table.concat(other_params, " ")
    end

    createSplit(create_split_cmd, suffix)
  end
end

return M
