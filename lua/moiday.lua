local config = require('config')
local commands = require('commands')

local M = {}

function M.setup(options)
  config.options = config.finalizeOptions(options or {})
  commands.setupCommands()
  commands.setupEvents()
end

return M
