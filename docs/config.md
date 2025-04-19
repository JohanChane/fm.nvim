# Advance configuration

```lua
return {
  {
    "JohanChane/fm.nvim",
    config = function()
      require("fm").setup({
        ui = {
          default = "float",
          float = {
            border = "single", -- see ":h nvim_open_win"
            float_hl = "Normal", -- see ":h winhl"
            border_hl = "Normal",
            blend = 0, -- see ":h winblend"
            height = 0.9, -- Num from 0 - 1 for measurements
            width = 0.9,
            x = 0.5, -- X and Y Axis of Window
            y = 0.4,
          },
          split = {
            direction = "left", -- see `:h nvim_open_win()`
            width = 24,
            height = 16,
          },
        },
        tools = {
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

      })

      local function get_path(modifier)
        local res = vim.fn.expand(modifier)
        if res == "" then
          res = vim.fn.getcwd()
        end
        return res
      end

      -- ## Use `yazi` tool
      vim.keymap.set("n", "<M-d>", function()
        -- Final command: `yazi --chooser-file %{_choose_file} 'vim.fn.getcwd()'`
        require("fm").open_fm({ name = "yazi", cmd_params = { entry = vim.fn.getcwd() } })
      end, { noremap = true })

      vim.keymap.set("n", "<M-f>", function()
        -- Final command: `yazi --chooser-file %{_choose_file} 'get_path("%:p")'`
        require("fm").open_fm({ name = "yazi", cmd_params = { entry = get_path("%:p") } })
      end, { noremap = true })

      -- ## joshuto
      vim.keymap.set("n", "<M-d>", function()
        require("fm").open_fm({ name = "joshuto", cmd_params = { entry = vim.fn.getcwd() } })
      end, { noremap = true })

      vim.keymap.set("n", "<M-f>", function()
        require("fm").open_fm({ name = "joshuto", cmd_params = { entry = get_path("%:p:h") } })
      end, { noremap = true })

      -- ## ranger
      vim.keymap.set("n", "<M-d>", function()
        require("fm").open_fm({ name = "ranger", cmd_params = { select_file_opt = "", entry = vim.fn.getcwd() } })
      end, { noremap = true })

      vim.keymap.set("n", "<M-f>", function()
        local path = vim.fn.expand("%:p")
        local cmd_params = {}
        if path == "" then
          cmd_params.select_file_opt = ""
          path = vim.fn.getcwd()
        else
          cmd_params.select_file_opt = "--selectfile"
        end
        cmd_params.entry = path
        require("fm").open_fm({ name = "ranger", cmd_params = cmd_params })
      end, { noremap = true })

      -- ## lazygit (Cmd)
      vim.api.nvim_create_user_command("Lazygit", function(opt)
        require("fm").open_fm({ name = "lazygit", cmd_params = { path = get_path("%:p:h"), opt.args } })
      end, { nargs = "?", bang = true })
    end,
  },
}
```
