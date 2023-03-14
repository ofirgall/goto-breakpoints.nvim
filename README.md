# Goto breakpoints
Simple plugin to cycle between [nvim-dap's](https://github.com/mfussenegger/nvim-dap) breakpoints and jump to current stopped line with keymappings.

## Install
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use 'ofirgall/goto-breakpoints.nvim'
```

## Usage
```lua
local map = vim.keymap.set
map('n', ']d', require('goto-breakpoints').next, {})
map('n', '[d', require('goto-breakpoints').prev, {})
map('n', ']S', require('goto-breakpoints').stopped, {})
```
