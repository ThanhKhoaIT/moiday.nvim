local config = require('config')

local U = {}

local function getTopItems(list, count)
  local topItems = {}
  for i = 1, math.min(count, #list) do
    table.insert(topItems, list[i])
  end
  return topItems
end

local function removeByValue(array, value)
  for i, v in ipairs(array) do
    if v == value then
      return table.remove(array, i)
    end
  end
  return nil
end

local function updateList(list)
  local workspace = vim.fn.system('echo -n ' .. vim.fn.getcwd() .. ' | md5sum | cut -d " " -f 1')
  local storageWorkspace = config.options.storage .. '.' .. workspace
  local file = io.open(storageWorkspace, "w")
  for _, line in ipairs(list) do
    file:write(line .. "\n")
  end
  file:close()
end

local function currentList()
  local workspace = vim.fn.system('echo -n ' .. vim.fn.getcwd() .. ' | md5sum | cut -d " " -f 1')
  local storageWorkspace = config.options.storage .. '.' .. workspace
  local file = io.open(storageWorkspace, "r")
  if not file then
    return {}
  end

  local lines = {}
  for filepath in file:lines() do
    if (vim.fn.filereadable(filepath) == 1) then
      table.insert(lines, filepath)
    end
  end

  file:close()
  return lines
end

local function buildPopup(content, title)
  function _G.getEditorWidth()
    local totalWidth = 0
    local windows = vim.api.nvim_list_wins()
    local uniqueColumns = {}

    for _, win in ipairs(windows) do
      local config = vim.api.nvim_win_get_config(win)
      if config.relative == '' then  -- Only consider non-floating windows
        local winWidth = vim.api.nvim_win_get_width(win)
        local winCol = vim.api.nvim_win_get_position(win)[2]

        -- Mark columns occupied by this window
        for col = winCol, winCol + winWidth - 1 do
          uniqueColumns[col] = true
        end
      end
    end
    for _ in pairs(uniqueColumns) do
      totalWidth = totalWidth + 1
    end
    return totalWidth
  end

  local editorWidth = _G.getEditorWidth()
  local width = math.max(math.floor(editorWidth / 2), 80)
  local height = config.options.maxRecentFiles + 1
  local row = 3
  local col = math.floor((editorWidth - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_set_hl(0, 'PopupNormal', { bg = '#1e1e1e', fg = '#d4d4d4' })
  vim.api.nvim_set_hl(0, 'PopupCursorLine', { bg = '#3c3836', fg = '#ffffff' })
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  local win = vim.api.nvim_open_win(buf, true, {
    width = width,
    height = height,
    row = row,
    col = col,
    title = title,
    title_pos = 'center',
    relative = 'editor',
    style = 'minimal',
    border = 'rounded',
    footer = 'Press `h` for help',
    footer_pos = 'right',
  })
  vim.api.nvim_win_set_option(win, 'winhighlight', 'Normal:PopupNormal,CursorLine:PopupCursorLine')
  vim.api.nvim_win_set_option(win, 'cursorline', true)

  return buf, win
end

local function buildHelpPanel()
  local helpContent = {
    '  Press a number to open a file',
    '  Press "o" or "Enter" to open a file',
    '  Press "r" to reset recent files',
    '  Press "q" to close the popup',
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, helpContent)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  local editorWidth = _G.getEditorWidth()
  local width = math.max(math.floor(editorWidth / 2), 80)
  local height = #helpContent + 1
  local row = 5
  local col = math.floor((editorWidth - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    title = 'Help',
    title_pos = 'center',
    footer = 'Press `b` to go back',
    footer_pos = 'right',
    focusable = false,
    width = width,
    height = #helpContent,
    row = row,
    col = col,
    relative = 'editor',
    style = 'minimal',
    border = 'rounded',
  })

  function _G.closeHelp()
    vim.api.nvim_win_close(win, true)
    U.listRecentFiles()
  end

  vim.api.nvim_create_autocmd('BufLeave', { buffer = buf, callback = _G.closeHelp })
  vim.api.nvim_buf_set_keymap(buf, 'n', 'b', '', { noremap = true, silent = true, callback = _G.closeHelp })

  return buf, win
end

local function fileProtocal(filepath)
  local protocalLength = string.find(filepath, '://') or 0
  return string.sub(filepath, 1, protocalLength - 1)
end

local function ignoreFile(filepath)
  local fileName = vim.fn.fnamemodify(filepath, ':t')
  local fileExt = vim.fn.fnamemodify(filepath, ':e')
  local fileType = vim.bo.filetype
  local ignoreByFilename = config.include(config.options.ignoreFiles, fileName)
  local ignoreByExtension = config.include(config.options.ignoreExtensions, fileExt)
  local ignoreByProtocal = config.include(config.options.ignoreProtocals, fileProtocal(filepath))
  local ignoreByType = config.include(config.options.ignoreFileTypes, vim.bo.filetype)
  local nonType = fileType.isnil or fileType == ''

  return ignoreByFilename or ignoreByExtension or ignoreByProtocal or ignoreByType or nonType
end

local function setupPopupKeymaps(buf, win, list)
  function _G.openFile(lineNumber)
    local lineNumber = lineNumber or vim.api.nvim_win_get_cursor(win)[1]
    for i, filepath in ipairs(list) do
      if i == lineNumber then
        vim.api.nvim_win_close(win, true)
        vim.cmd('edit ' .. filepath)
        break
      end
    end
  end

  function _G.closePopup()
    vim.api.nvim_win_close(win, true)
  end

  function _G.resetRecentFiles()
    updateList({})
    vim.api.nvim_win_close(win, true)
  end

  function _G.showHelp()
    buildHelpPanel()
  end

  -- Open the file when pressing number keys
  for i = 1, 9 do
    vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
      noremap = true,
      silent = true,
      callback = function()
        _G.openFile(i)
      end,
    })
  end
  -- Open the file when pressing 'o', 'Enter' or clicking with the mouse
  vim.api.nvim_buf_set_keymap(buf, 'n', 'o', '', { noremap = true, silent = true, callback = _G.openFile })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', { noremap = true, silent = true, callback = _G.openFile })
  -- Reset recent files when pressing 'r'
  vim.api.nvim_buf_set_keymap(buf, 'n', 'r', '', { noremap = true, silent = true, callback = _G.resetRecentFiles })
  -- Show help when pressing 'h'
  vim.api.nvim_buf_set_keymap(buf, 'n', 'h', '', { noremap = true, silent = true, callback = _G.showHelp })
  -- Close the popup when pressing 'q' or leaving the buffer
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', { noremap = true, silent = true, callback = _G.closePopup })
  vim.api.nvim_create_autocmd('BufLeave', { buffer = buf, callback = _G.closePopup })
end

function U.listRecentFiles()
  local list = currentList()
  if #list == 0 then
    print("No recent files")
    return -- Skip if there are no recent files
  end

  local content = {}
  for index, filepath in ipairs(list) do
    table.insert(content, ' ' .. index .. '. ' .. filepath)
  end

  local buf, win = buildPopup(content, "Recent Files")
  setupPopupKeymaps(buf, win, list)
end

function U.addRecentFile(filepath)
  local list = currentList() or {}

  local isIgnored = ignoreFile(filepath)

  if isIgnored then
    return
  end
  removeByValue(list, filepath)
  table.insert(list, 1, filepath)
  list = getTopItems(list, config.options.maxRecentFiles)
  updateList(list)
end

return U
