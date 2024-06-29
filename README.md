# fm-nvim (fork)

`fm-nvim` is a Neovim plugin that lets you use your favorite terminal file managers (and fuzzy finders) from within Neovim.

## Why I Created This Project

I like `fm-nvim`. I modified it to be flexibly configurable by users without adding unnecessary commands. Additionally, `choose file` supports `Windows` path formats, which make some tools work on Windows.

## Installation:

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
"JohanChane/fm-nvim"
```

## Configuration:

The following configuration contains the defaults so if you find them satisfactory, there is no need to use the setup function.

```lua
require('fm-nvim').setup {
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

  -- Path to broot config
  broot_conf = vim.fn.stdpath("data") .. "/site/pack/packer/start/fm-nvim/assets/broot_conf.hjson",

  tools = {
    ranger = {  -- tool name
      -- `%{choose_file}` is a parameter supported by `fm-nvim`.
      create_win_cmd_format = "ranger --choosefile %{choose_file}",
      -- use with create_win_cmd_format if don't set
      --create_split_cmd_format = "ranger --choosefile %{choose_file}",
    },
    joshuto = {
      create_win_cmd_format = "joshuto --choosefile %{choose_file}",
    },
    yazi = {
      create_win_cmd_format = "yazi --chooser-file %{choose_file}",
    },
    lazygit = {
      create_win_cmd_format = "lazygit",
    },
    -- ...
  },
}
```

### Configuration Example

Using Lazy.nvim:

```lua
"JohanChane/fm-nvim",
config = function()
  require('fm-nvim').setup {
    ui = {
      -- Default UI (can be "split" or "float")
      default = "float",

      float = {
        -- Floating window border (see ':h nvim_open_win')
        border    = "single",

        -- Highlight group for floating window/border (see ':h highlight-groups')
        float_hl  = "Normal",
        border_hl = "Normal",

        -- Floating Window Transparency (see ':h winblend')
        blend     = 0,

        -- Num from 0 - 1 for measurements
        height    = 0.9,
        width     = 0.9,

        -- X and Y Axis of Window
        x         = 0.5,
        y         = 0.4
      },
    },
    tools = {
      ranger = {
        create_win_cmd_format = "ranger --choosefile %{choose_file}",
      },
      joshuto = {
        create_win_cmd_format = "joshuto --choosefile %{choose_file}",
      },
      yazi = {
        create_win_cmd_format = "yazi --chooser-file %{choose_file}",
      },
      lazygit = {
        create_win_cmd_format = "lazygit",
      },
    },
  }

  local open_fm = function(does_just_open)
    --local fm = "ranger"
    --local fm = "joshuto"
    local fm = "yazi"

    if does_just_open then
      require('fm-nvim').CreateWindow(fm, {"."}, "l")
      return
    end

    if vim.fn['bufname']("%") == "" then
      require('fm-nvim').CreateWindow(fm, {"."}, "l")
      return
    end

    if fm == "ranger" then
      -- Usage: CreateWindow(tool_name, other_params, suffix)
      -- The final `cmd` used in CreateWindow combines the parameters
      --   generated from `config.tools.xxx_cmd_format` with `other_params`.
      -- final cmd: `ranger --choosefile <the %{choose file} in format_cmd> --selectfile <current file> .`
      -- `l`:Assume your ranger use `l` to open a file.
      require('fm-nvim').CreateWindow("ranger", {"--selectfile", vim.fn.expand("%:p"), "."}, "l")
    elseif fm == "joshuto" then
      require('fm-nvim').CreateWindow("joshuto", {"."}, "l")
    elseif fm == "yazi" then
      require('fm-nvim').CreateWindow("yazi", {vim.fn.expand("%:p")}, "o")
    end
  end

  vim.keymap.set("n", "<M-f>", function() open_fm(false) end, { noremap = true })
  vim.keymap.set("n", "<M-d>", function() open_fm(true) end, { noremap = true })

  -- If you want to create a command for `ranger`
  vim.api.nvim_create_user_command(
      "Ranger",
      function(opts)
          require('fm-nvim').CreateWindow("ranger", {opts.args, "."}, "l")
      end,
      { nargs = '?', complete = 'dir', bang = true }
  )

  vim.api.nvim_create_user_command(
    "Lazygit",
    function(opt)
      require("fm-nvim").CreateWindow("lazygit", {"-w", vim.fn.expand("%:p:h"), opt.args}, "e")
    end,
    {}
  )
end,
```
