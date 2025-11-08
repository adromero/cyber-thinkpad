# Contributing to ThinkPad Cyberpunk

Thank you for your interest in contributing! This document provides guidelines and best practices.

## Code Quality Standards

### Python Code

1. **Python Version**: Minimum Python 3.7
   - Use type hints for function signatures
   - Use f-strings for string formatting
   - Use dataclasses where appropriate

2. **Error Handling**
   - NEVER use bare `except:` clauses
   - Always catch specific exceptions
   - Add explanatory comments for exception handling
   ```python
   # Good
   try:
       value = int(data)
   except ValueError:
       # Invalid number format - use default
       value = 0

   # Bad
   try:
       value = int(data)
   except:
       value = 0
   ```

3. **Code Organization**
   - Import shared modules from `lib/`
   - Use the shared `Colors` class from `lib/colors.py`
   - Define constants at module level, not inline

4. **Documentation**
   - Add docstrings to all functions and classes
   - Use clear, descriptive variable names
   - Add comments for complex logic

### Shell Scripts

1. **Path Safety**
   - ALWAYS validate paths before `rm -rf`
   - Use `case` statements to ensure paths are in expected locations
   ```bash
   # Good
   CONFIG_TARGET="${HOME}/.config/${dir}"
   case "$CONFIG_TARGET" in
       "${HOME}/.config/"*)
           rm -rf "$CONFIG_TARGET"
           ;;
       *)
           echo "Error: Invalid path"
           exit 1
           ;;
   esac

   # Bad
   rm -rf ~/.config/$dir
   ```

2. **Variable Quoting**
   - Always quote variables: `"$VAR"` not `$VAR`
   - Use `${VAR}` for clarity in complex expressions

3. **Error Handling**
   - Check command return codes
   - Provide meaningful error messages
   - Use timeouts for potentially hanging operations

4. **Path Resolution**
   - Use script-relative paths, not hardcoded paths
   ```bash
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   ```

## Testing

Before submitting changes:

1. Test on a clean system or VM
2. Verify all paths work correctly
3. Test error conditions
4. Check for shell script errors with `shellcheck`
5. Test Python code with different Python versions (3.7+)

## Commit Messages

Use clear, descriptive commit messages:
- Start with a verb: "Add", "Fix", "Update", "Remove"
- Be specific about what changed
- Reference issues if applicable

Examples:
```
Add timeout handling to polybar launch script

Fix path inconsistency in demo.sh causing tools to not be found

Update cyberwidget to support multiple terminal emulators
```

## Security Considerations

1. **No Secret Exposure**: Never commit API keys, passwords, or secrets
2. **Path Validation**: Validate all file paths before operations
3. **Input Sanitization**: Validate user input in scripts
4. **Least Privilege**: Don't require root unless necessary

## Code Review Checklist

- [ ] Code follows style guidelines
- [ ] No hardcoded paths (use script-relative or configurable)
- [ ] Error handling uses specific exceptions
- [ ] All `rm -rf` operations have path validation
- [ ] Shell variables are properly quoted
- [ ] Documentation is updated
- [ ] Tested on target platforms (Ubuntu/Debian/Arch/Fedora)
- [ ] No security vulnerabilities introduced

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the guidelines above
4. Test thoroughly
5. Commit with clear messages
6. Push to your fork
7. Open a Pull Request with description of changes

## Questions?

Feel free to open an issue for:
- Bug reports
- Feature requests
- Questions about contributing
- Clarification on guidelines

Thank you for helping make ThinkPad Cyberpunk better!
