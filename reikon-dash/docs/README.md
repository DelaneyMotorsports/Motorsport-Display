# Reikon Dash Documentation

This directory contains comprehensive documentation for the Reikon Dash motorsport display system.

## Documentation Structure

### User Documentation
- **[README.md](../README.md)** - Project overview, installation, and quick start
- **[architecture.md](architecture.md)** - System architecture and design decisions
- **[can_mapping.md](can_mapping.md)** - CAN signal definitions and DBC information

### API Documentation (Generated)
- **doxygen/html/index.html** - Comprehensive API reference (generated from source code)
- **doxygen/latex/** - LaTeX/PDF documentation (generated from source code)

## Generating API Documentation

Reikon Dash uses [Doxygen](https://www.doxygen.nl/) to automatically generate professional API documentation from inline source code comments.

### Prerequisites

Install Doxygen and Graphviz (for diagrams):

**Ubuntu/Debian:**
```bash
sudo apt-get install doxygen graphviz
```

**macOS (via Homebrew):**
```bash
brew install doxygen graphviz
```

**Arch Linux:**
```bash
sudo pacman -S doxygen graphviz
```

### Generate Documentation

From the `reikon-dash/` directory, run:

```bash
doxygen Doxyfile
```

This will create:
- **docs/doxygen/html/** - HTML documentation (open `index.html` in browser)
- **docs/doxygen/latex/** - LaTeX source files for PDF generation

### View Documentation

Open the generated documentation:

```bash
# Linux
xdg-open docs/doxygen/html/index.html

# macOS
open docs/doxygen/html/index.html

# Or use any web browser
firefox docs/doxygen/html/index.html
```

### Generate PDF Manual

If you want a PDF version of the complete manual:

```bash
cd docs/doxygen/latex
make
# Output: refman.pdf
```

## Documentation Features

The generated documentation includes:

### Class Documentation
- Complete class hierarchies with inheritance diagrams
- All public/protected/private members
- Method parameters and return values
- Usage examples embedded in source code

### Call Graphs
- Visual representation of function call relationships
- Caller/callee graphs for debugging and understanding flow
- Interactive SVG diagrams (click to navigate)

### File Documentation
- File dependencies and inclusion graphs
- All functions, classes, and data structures per file
- Cross-references between related components

### Module Organization
- **CAN Platform Layer** (`@defgroup can_platform`)
  - CanTypes.h - CAN frame data structures
  - CanBackend.h - CAN communication interface

- **Model Layer** (`@defgroup model_layer`)
  - SignalBus.h - Telemetry signal distribution

- **Services Layer** (`@defgroup services_layer`)
  - Logger.h - Diagnostic logging

### Code Examples
All major classes include usage examples in the documentation, extracted from `@code` blocks in source files.

### Search Functionality
The HTML documentation includes full-text search across:
- Class names
- Method names
- Parameters
- Documentation text
- Code examples

## Documentation Standards

All source files in Reikon Dash follow strict Doxygen documentation standards:

### Required Elements
1. **File Header** - Purpose, design philosophy, dependencies, author
2. **Class Documentation** - Brief description, detailed explanation, usage notes
3. **Method Documentation** - Brief, parameters (`@param`), return value (`@return`), notes
4. **Examples** - Real-world usage patterns where applicable

### Doxygen Commands Used
- `@file`, `@brief`, `@details` - File-level documentation
- `@class`, `@struct` - Type documentation
- `@param`, `@return` - Method signatures
- `@note`, `@warning`, `@see` - Important information
- `@code`, `@endcode` - Inline code examples
- `@defgroup`, `@ingroup`, `@{`, `@}` - Module organization

## Contributing to Documentation

When adding new code to Reikon Dash:

1. **Document all public APIs** - Every public class, method, and function
2. **Include usage examples** - At least one example per major class
3. **Cross-reference related components** - Use `@see` to link related classes
4. **Update this README** - If adding new modules or major features
5. **Regenerate Doxygen** - Run `doxygen Doxyfile` to verify documentation builds

### Example Documentation Template

```cpp
/**
 * @file    MyNewClass.h
 * @brief   Brief one-line description.
 * @ingroup appropriate_group
 *
 * @details
 * Detailed multi-line description explaining purpose, design decisions,
 * and how this class fits into the overall architecture.
 *
 * @section dependencies Dependencies
 * - List required libraries
 * - List required headers
 *
 * @example
 * @code{.cpp}
 * MyNewClass obj;
 * obj.doSomething();
 * @endcode
 *
 * @author  Your Name
 * @date    YYYY-MM-DD
 * @company Delaney Motorsports, LLC
 */
```

## Documentation Versioning

- Documentation version matches project version (see `PROJECT_NUMBER` in Doxyfile)
- Current version: **1.0.0**
- Regenerate documentation for each release

## Support

For questions about the documentation or API:
- File an issue: https://github.com/DelaneyMotorsports/Motorsport-Display/issues
- Review generated docs: Open `docs/doxygen/html/index.html` after running Doxygen

---

**Author:** Kevin Delaney
**Company:** Delaney Motorsports, LLC
**Location:** Sarasota, FL
**Date:** January 10, 2026
