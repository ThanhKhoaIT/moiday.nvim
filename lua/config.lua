local C = {}

C.default = {
  storage = vim.fn.stdpath('data') .. '/moiday.files',
  maxRecentFiles = 10,
  autoShowOnFileTypes = { 'nerdtree' },
  ignoreFiles = { 'tags', 'TAGS', 'quickfix' },
  ignoreFileTypes = { 'fugitive', 'git' },
  ignoreProtocals = { 'fugitive' },
  ignoreExtensions = { 'log', 'swp', 'jpg', 'png', 'jpeg', 'gif', 'mp4', 'mp3', 'avi', 'mkv', 'pdf', 'zip', 'tar', 'gz', 'rar', '7z', 'iso', 'exe', 'dll', 'so', 'dylib', 'app', 'dmg', 'pkg', 'deb', 'rpm', 'msi', 'apk', 'ipa', 'jar', 'war', 'ear', 'class', 'o', 'obj', 'a', 'lib', 'dll', 'pdb', 'bin', 'dat', 'db', 'sqlite', 'sqlite3', 'db3', 'sql', 'bak', 'tmp', 'temp' },
}

function C.finalizeOptions(custom)
  local merged = {}
  for k, v in pairs(C.default) do
    merged[k] = v
  end
  for k, v in pairs(custom or {}) do
    merged[k] = v
  end
  return merged
end

function C.include(list, check)
  for _, item in ipairs(list) do
    if item == check then
      return true
    end
  end
  return false
end

return C
