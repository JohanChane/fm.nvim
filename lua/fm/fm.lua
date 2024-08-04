local setup_opts = require('fm.config').setup_opts
local Window = require('fm.window').Window
local fm_window = Window:new(setup_opts.ui)
local fm_log = require('fm.log').Log:new({
  enable = setup_opts.debug
})

local choose_file
local cf_edit_cmd = setup_opts.edit_cmd -- edit_cmd for choose files

local function inspect()
  print('choose_file:')
  print(vim.inspect(choose_file))
  print('cf_edit_cmd:')
  print(vim.inspect(cf_edit_cmd))
end

local function get_choose_file()
  choose_file = os.tmpname()
  return choose_file
end

local function handle_choosefile(file, edit_cmd)
  local f = io.open(file)
  if f == nil then
    return
  end

  for line in f:lines() do
    fm_log:log('lines of choose file', string.format('line: %s', line))
    vim.cmd(edit_cmd .. ' ' .. vim.fn.fnameescape(line))
  end
  cf_edit_cmd = setup_opts.edit_cmd -- reset cf_edit_cmd

  io.close(f)
  os.remove(file)
end

local on_inner_exit
local function on_exit()
  on_inner_exit()
  handle_choosefile(choose_file, cf_edit_cmd)
end

local function set_keymap(buf_hdr, opts)
  local function on_suffix(c, s)
    cf_edit_cmd = c
    --vim.api.nvim_command('startinsert')
    fm_log:log('', string.format('cmd:%s, feedkeys:%s', c, s))
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(s or '', true, true, true), 'n', false)
  end

  local suffix = setup_opts.tools[opts.name].suffix
  vim.keymap.set('t', setup_opts.mappings.edit, function()
      on_suffix('edit', suffix)
    end,
    { buffer = buf_hdr, noremap = true, silent = true }
  )
  vim.keymap.set('t', setup_opts.mappings.tabedit, function()
      on_suffix('tabedit', suffix)
    end,
    { buffer = buf_hdr, noremap = true, silent = true }
  )
  vim.keymap.set('t', setup_opts.mappings.horz_split, function()
      on_suffix('split', suffix)
    end,
    { buffer = buf_hdr, noremap = true, silent = true }
  )
  vim.keymap.set('t', setup_opts.mappings.vert_split, function()
      on_suffix('vsplit', suffix)
    end,
    { buffer = buf_hdr, noremap = true, silent = true }
  )
  vim.api.nvim_buf_set_keymap(buf_hdr, 't', '<ESC>', setup_opts.mappings.ESC, { silent = true })
end

local function replace_placeholders(format, params)
  local cmd = format:gsub('%%{choose_file}', params.choose_file)
  return cmd
end

-- opts: {name, cmd}
local function create_fm_win_helper(opts)
  local win
  if setup_opts.ui.default == 'split' then
    win = fm_window:create_split_win()
  else
    win = fm_window:create_float_win()
  end

  vim.api.nvim_set_option_value('filetype', 'Fm', { buf = win.buf_hdr })

  -- ## set keymaps
  set_keymap(win.buf_hdr, opts)

  -- ## open term
  vim.fn.termopen(opts.cmd, { on_exit = on_exit })
  vim.api.nvim_command('startinsert')

  -- ## exit
  on_inner_exit = function()
    Window.remove_win(win)
  end
end

-- user_opts: {name, other_params}. other params of cmd
local function open_fm(user_opts)
  local opts = {}
  opts.name = user_opts.name

  local tool = setup_opts.tools[user_opts.name]
  local create_win_cmd = replace_placeholders(
    tool.create_win_cmd_format or tool.create_split_cmd_format,
    { choose_file = get_choose_file() }
  ) .. ' ' .. table.concat(user_opts.other_params, ' ')
  if setup_opts.debug then
    fm_log:log('cmd', string.format('cmd: %s', create_win_cmd, { inspect = inspect }))
  end
  opts.cmd = create_win_cmd

  create_fm_win_helper(opts)
end

return {
  open_fm = open_fm,
}
