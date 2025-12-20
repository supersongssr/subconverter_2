# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Subconverter is a utility for converting between various proxy subscription formats. It supports multiple proxy protocols including SS, SSR, VMess, VLESS, Trojan, and can generate configurations for clients like Clash, Surge, QuantumultX, Loon, and others.

## Build Commands

### Basic Build
```bash
# Create build directory and compile
cmake -DCMAKE_BUILD_TYPE=Release .
make -j$(nproc)
```

### Platform-specific Builds
- **Debian/Ubuntu**: `./scripts/build.debian.release.sh`
- **macOS**: `./scripts/build.macos.release.sh`
- **Windows**: `./scripts/build.windows.release.sh`
- **Alpine Linux**: `./scripts/build.alpine.release.sh`

### Build Dependencies
The project requires:
- CMake 3.5+
- C++20 compiler
- PCRE2, yaml-cpp, RapidJSON, cURL, OpenSSL
- QuickJS (for JavaScript scripting support)
- LibCron (for scheduled tasks)

## Architecture

### Core Components

1. **Parser (`src/parser/`)**
   - `subparser.cpp`: Main subscription parsing logic
   - `infoparser.cpp`: Extract user info from subscription data

2. **Generator (`src/generator/`)**
   - `config/`: Configuration generation (nodemanip, ruleconvert, subexport)
   - `template/`: Template rendering with Jinja2 support

3. **Handler (`src/handler/`)**
   - `interfaces.cpp`: Main API endpoints and request routing
   - `webget.cpp`: HTTP client for fetching remote resources
   - `settings.cpp`: Configuration management
   - `upload.cpp`: GitHub Gist upload functionality

4. **Server (`src/server/`)**
   - `webserver_httplib.cpp`: HTTP server implementation
   - Uses httplib library for HTTP handling

5. **Script (`src/script/`)**
   - `script_quickjs.cpp`: JavaScript runtime integration
   - `cron.cpp`: Scheduled task execution

6. **Utils (`src/utils/`)**
   - Network, file handling, string manipulation, logging, etc.

### Configuration System

- **Main config**: `pref.ini`/`pref.yml`/`pref.toml` (in `base/` directory)
- **External configs**: Located in `base/config/` directory
- **Templates**: Located in `base/base/` directory
- **Rules**: Located in `base/rules/` directory

### Key Endpoints

- `/sub`: Main conversion endpoint
- `/getprofile`: Profile-based conversion
- `/getruleset`: Ruleset conversion
- `/render`: Template rendering
- `/version`: Version information

## Development Workflow

### Running the Server
```bash
# After building
./base/subconverter
# Server runs on port 25500 by default
```

### Testing Conversions
```bash
# Basic conversion
curl "http://127.0.0.1:25500/sub?target=clash&url=ENCODED_SUBSCRIPTION_URL"

# With external config
curl "http://127.0.0.1:25500/sub?target=clash&url=ENCODED_URL&config=ENCODED_CONFIG_URL"
```

### Configuration Files
- Use `pref.example.ini` as a template for main configuration
- External configs in `base/config/` provide different rule sets and proxy groups
- Template files use Jinja2 syntax for dynamic configuration generation

### Adding New Features
- New proxy types: Add to `src/parser/subparser.cpp`
- New target formats: Add to `src/generator/config/subexport.cpp`
- New rule types: Add to `src/generator/config/ruleconvert.cpp`

## Key Directories

- `src/`: Source code
- `base/`: Runtime configuration files and templates
- `scripts/`: Build scripts for different platforms
- `cmake/`: CMake configuration files

## Important Notes

- The server uses port 25500 by default
- Configuration files support INI, YAML, and TOML formats
- JavaScript scripting is supported via QuickJS engine
- The project includes extensive rule sets for different regions and services
- IPv6 and VLESS with gRPC support are recent additions (see current branch)