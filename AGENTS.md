# Agent Guidelines for Dotfiles Repository

## Build/Test/Lint Commands
- No centralized build system - this is a personal dotfiles repository

## Code Style Guidelines

### Lua (Hammerspoon configuration)
- Use snake_case for variables and functions
- Use camelCase for module names and methods following Hammerspoon conventions
- Prefer explicit module returns with start/stop functions
- Use hs.logger for debugging: `local log = hs.logger.new("module", "debug")`
- Follow existing patterns for hotkey bindings and modal management

### Ruby (IRB/Pry helpers)
- Use snake_case for method names
- Prefer explicit module definitions with extend pattern
- Use UTF-8 encoding declaration at top of files
- Follow 2-space indentation

### Shell Scripts
- Use `#!/usr/bin/env bash` shebang
- Use `set -e` for error handling
- Prefer double quotes for variable expansion

## File Organization
- Tag-based structure: `tag-{platform}/` for platform-specific configs
- Shared configs in root or `config/` directories
- Binary scripts in `bin/` directory
- Use rcm conventions for symlinking dotfiles
