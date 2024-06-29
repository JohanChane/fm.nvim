# fm.nvim (fork fm-nvim)

`fm.nvim` is a Neovim plugin that lets you use your favorite terminal file managers (and fuzzy finders) from within Neovim.

## Why I Created This Project

I like [fm-nvim](https://github.com/is0n/fm-nvim). I modified it to be flexibly configurable by users without adding unnecessary commands. Additionally, `choose file` supports `Windows` path formats, which make some tools work on Windows.

## Installation:

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
"JohanChane/fm.nvim"
```

## Configuration:

The following configuration contains the defaults so if you find them satisfactory, there is no need to use the setup function.

```lua
require('fm').setup {
  -- (Vim) Command used to open files
  edit_cmd = "edit",

  -- See `Q&A` for more info
  on_close = {},
  on_open = {},

  -- UI Options
  ui = {
    -- Default UI (can be "split" or "float")
    default = "float",

    float = {
      -- Floating window border (see ':h nvim_open_win')
      border    = "none",

      -- Highlight group for floating window/border (see ':h winhl')
      float_hl  = "Normal",
      border_hl = "FloatBorder",

      -- Floating Window Transparency (see ':h winblend')
      blend     = 0,

      -- Num from 0 - 1 for measurements
      height    = 0.8,
      width     = 0.8,

      -- X and Y Axis of Window
      x         = 0.5,
      y         = 0.5
    },

    split = {
      -- Direction of split
      direction = "topleft",

      -- Size of split
      size      = 24
    }
  },
  -- Mappings used with the plugin
  mappings = {
    vert_split = "<C-v>",
    horz_split = "<C-h>",
    tabedit    = "<C-t>",
    edit       = "<C-e>",
    ESC        = "<ESC>"
  },

  tools = {
    ranger = {  -- tool name
      -- `%{choose_file}` is a parameter supported by `fm.nvim`.
      -- Because `fm.nvim` need to know which you select.
      create_win_cmd_format = "ranger --choosefile %{choose_file}",
      -- use with create_win_cmd_format if don't set
      --create_split_cmd_format = "ranger --choosefile %{choose_file}",

      -- Assume your ranger use `l` to open a file.
      suffix = "l",
    },
    joshuto = {
      create_win_cmd_format = "joshuto --file-chooser --output-file %{choose_file}",
      suffix = "l",
    },
    yazi = {
      create_win_cmd_format = "yazi --chooser-file %{choose_file}",
      suffix = "o",
    },
    lazygit = {
      create_win_cmd_format = "lazygit",
      suffix = "e",
    },
    -- ...
  },
  debug = false,        -- Debug mode. Use `:message` to show the debug info.
                        -- e.g. show final cmd.
}
```

### Configuration Example

Using Lazy.nvim:

```lua
"JohanChane/fm.nvim",
config = function()
  require('fm').setup {
    ui = {
      default = "float",
      float = {
        border    = "single",
        float_hl  = "Normal",
        border_hl = "Normal",
        blend     = 0,
        height    = 0.9,
        width     = 0.9,
        x         = 0.5,
        y         = 0.4
      },
    },
    tools = {
      ranger = {
        create_win_cmd_format = "ranger --choosefile %{choose_file}",
        suffix = "l",
      },
      joshuto = {
        create_win_cmd_format = "joshuto --file-chooser --output-file %{choose_file}",
        suffix = "l",
      },
      yazi = {
        create_win_cmd_format = "yazi --chooser-file %{choose_file}",
        suffix = "o",
      },
      lazygit = {
        create_win_cmd_format = "lazygit",
        suffix = "e",
      },
    },
    --debug = true,
  }

  local open_fm = function(does_just_open)
    --local fm = "ranger"
    --local fm = "joshuto"
    local fm = "yazi"

    if does_just_open then
      require('fm').create_win(fm, { "." })
      return
    end

    if vim.fn['bufname']("%") == "" then
      require('fm').create_win(fm, { "." })
      return
    end

    if fm == "ranger" then
      -- Usage: create_win(tool_name, other_params, suffix)
      -- The final `cmd` used in create_win combines the parameters
      --   generated from `config.tools.xxx_cmd_format` with `other_params`.
      -- final cmd: `ranger --choosefile <the %{choose file} in format_cmd> --selectfile <current file> .`
      require('fm').create_win("ranger", { "--selectfile", vim.fn.expand("%:p"), "." })
    elseif fm == "joshuto" then
      require('fm').create_win("joshuto", { "." })
    elseif fm == "yazi" then
      require('fm').create_win("yazi", { vim.fn.expand("%:p") })
    end
  end

  vim.keymap.set("n", "<M-f>", function() open_fm(false) end, { noremap = true })
  vim.keymap.set("n", "<M-d>", function() open_fm(true) end, { noremap = true })

  -- If you want to create a command for `ranger`
  vim.api.nvim_create_user_command(
    "Ranger",
    function(opts)
      require('fm').create_win("ranger", { opts.args, "." })
    end,
    { nargs = '?', complete = 'dir', bang = true }
  )

  vim.api.nvim_create_user_command(
    "Lazygit",
    function(opt)
      require("fm").create_win("lazygit", { "-w", vim.fn.expand("%:p:h"), opt.args })
    end,
    { nargs = '?', bang = true }
  )
end,
```
