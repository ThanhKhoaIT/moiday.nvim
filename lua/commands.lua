local config = require('config')
local utils = require('utilities')

local C = {}

function C.setupCommands()
  vim.api.nvim_create_user_command('MoidayFiles', function()
    utils.listRecentFiles()
  end, {})
end

function C.setupEvents()
  vim.api.nvim_create_augroup('Moiday', { clear = true })
  vim.api.nvim_create_autocmd('BufReadPost', {
    group = 'Moiday',
    pattern = '*',
    callback = function()
      local filepath = vim.fn.expand('<afile>')
      utils.addRecentFile(filepath)
    end,
  })

  vim.api.nvim_create_autocmd('VimEnter', {
    group = 'Moiday',
    pattern = '*',
    callback = function()
      local filepath = vim.fn.expand('<afile>')
      if filepath == '' then
        utils.listRecentFiles()
        return
      end

      local allTypes = table.concat(config.options.autoShowOnFileTypes, ',')
      local checkTypes = ","..allTypes..","
      local isShow = string.find(checkTypes, ","..vim.bo.filetype..",")
      if isShow then
        utils.listRecentFiles()
      end
    end,
  })
end

return C
