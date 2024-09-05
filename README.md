# moiday.nvim

moiday.nvim is a Neovim plugin that helps you manage and quickly access your recent files. It provides a popup interface to list and open recent files, and allows customization of ignored files and file types.

## Features

- Automatically tracks recently opened files.
- Provides a popup interface to list and open recent files.
- Customizable options for ignored files and file types.
- Key mappings for quick access and navigation within the popup.
- Help panel for quick reference of key mappings.

## Installation

You can install moiday.nvim using your favorite plugin manager. Here are examples for some popular ones:

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'ThanhKhoaIT/moiday.nvim'
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'ThanhKhoaIT/moiday.nvim'
```

## Configuration

You can configure moiday.nvim by calling the `setup` function with your custom options. Here is an example configuration:

```lua
require('moiday').setup({
  storage = vim.fn.stdpath('data') .. '/moiday.files',
  maxRecentFiles = 10,
  autoShowOnFileTypes = { 'nerdtree' },
  ignoreFiles = {'tags', 'TAGS', 'quickfix'},
  ignoreExtensions = {'log', 'swp', 'jpg', 'png', 'jpeg', 'gif', 'mp4', 'mp3', 'avi', 'mkv', 'pdf', 'zip', 'tar', 'gz', 'rar', '7z', 'iso', 'exe', 'dll', 'so', 'dylib', 'app', 'dmg', 'pkg', 'deb', 'rpm', 'msi', 'apk', 'ipa', 'jar', 'war', 'ear', 'class', 'o', 'obj', 'a', 'lib', 'dll', 'pdb', 'bin', 'dat', 'db', 'sqlite', 'sqlite3', 'db3', 'sql', 'bak', 'tmp', 'temp'},
})
```

## Usage

### Commands

- `:MoidayFiles` - Opens the popup to list recent files.

### Key Mappings

Within the popup, you can use the following key mappings:

- Press a number (1-9) to open the corresponding file.
- Press `o` or `Enter` to open the selected file.
- Press `r` to reset the list of recent files.
- Press `h` to show the help panel.
- Press `q` to close the popup.

### Events

moiday.nvim automatically tracks files you open and adds them to the recent files list. It also shows the recent files popup when you open Neovim, depending on your configuration.

## Contributing

Feel free to open issues or submit pull requests if you have any suggestions or improvements.

## License

This project is licensed under the MIT License.

---

Replace `ThanhKhoaIT` with your actual GitHub username or the appropriate repository path. This README provides a comprehensive overview of your plugin, including installation, configuration, usage, and contribution guidelines.

