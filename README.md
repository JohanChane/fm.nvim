# fm.nvim

## Features

- Supports Windows platform
- You can flexibly configure commands for TUI tools
- If you find there's no plugin supporting your TUI tool, you can try configuring it manually.

## Installation & Configuration

```lua
{
  "JohanChane/fm.nvim",
  config = function()
    require("fm").setup({
      -- Only configure the tools you use; no need to configure all of them.
      tools = {
        -- This configuration means: when pressing `o` in yazi, it will run the following command.
        -- The command is `yazi --chooser-file <choose_file> '<entry>'`
        -- `_choose_file` is internally used by fm.nvim (the name is fixed, not customizable)
        yazi = {
          create_win_cmd_format = "yazi --chooser-file %{_choose_file} '%{entry}'",
          suffix = "o",
        },
        joshuto = {
          create_win_cmd_format = "joshuto --file-chooser --output-file %{_choose_file} '%{entry}'",
          suffix = "l",
        },
        ranger = {
          create_win_cmd_format = "ranger --choosefiles %{_choose_file} %{select_file_opt} '%{entry}'",
          suffix = "l",
        },
        lazygit = {
          create_win_cmd_format = "lazygit -w %{path}",
          suffix = "e",
        },
      },
    })

    local function get_path(modifier)
      local res = vim.fn.expand(modifier)
      if res == "" then
        res = vim.fn.getcwd()
      end
      return res
    end

    ---- ## Use `yazi` tool
    vim.keymap.set("n", "<M-d>", function()
      -- Final command: `yazi --chooser-file %{_choose_file} 'vim.fn.getcwd()'`
      require("fm").open_fm({ name = "yazi", cmd_params = { entry = vim.fn.getcwd() } })
    end, { noremap = true })

    vim.keymap.set("n", "<M-f>", function()
      -- Final command: `yazi --chooser-file %{_choose_file} 'get_path("%:p")'`
      require("fm").open_fm({ name = "yazi", cmd_params = { entry = get_path("%:p") } })
    end, { noremap = true })
  end,
}
```

## Acknowledgments

- [fm-nvim](https://github.com/is0n/fm-nvim): My modifications are based on it.