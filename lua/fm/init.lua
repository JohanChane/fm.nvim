local M = {}

function M.setup(opts)
  local config = require('fm.config')
  config.setup_opts = vim.tbl_deep_extend('force', config.default_opts, opts)
end

local lazyloaded_modules = {
  open_fm = { 'fm.fm', 'open_fm' },
}

for k, v in pairs(lazyloaded_modules) do
  M[k] = function(...)
    return require(v[1])[v[2]](...)
  end
end

local exported_modules = {
  'fm'
}

for _, m in ipairs(exported_modules) do
  M[m] = function()
    return require('fm.' .. m)
  end
end

return M
