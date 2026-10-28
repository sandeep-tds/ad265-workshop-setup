# AD265 Workshop Setup

Two-step setup process for the AD265 workshop.

## Quick Start

**Run this script to do everything:**
```
install-npm-packages.bat
```

This will:
1. Install required SAP MDK npm packages to `C:\Software`
2. Automatically launch the main setup which will:
   - Clone the MDKApp project to your Desktop
   - Install Cline configuration
   - Open VS Code with the project

## Manual Setup (if needed)

If you need to run the steps separately:

### Step 1: Install npm packages
```
install-npm-packages.bat
```

### Step 2: Run main setup
```
setup-ad265.bat
```

## Requirements

- **Git** - for cloning the project
- **Node.js/npm** - for installing SAP MDK packages
- **VS Code** - for the development environment

## What Gets Installed

The setup installs these npm packages to `C:\Software`:
- `@sap/mdk-tools`
- `@sap/mdk-mcp-server`
- `@sap/generator-mdk`

## Troubleshooting

**"npm was not found"**
- Install Node.js from https://nodejs.org/
- Restart your terminal/command prompt after installation

**"npm install failed"**
- Check your network connection
- Verify SAP npm registry is configured
- Check if authentication is required

**VS Code doesn't open**
- Make sure VS Code is installed
- Try adding `code` command to your PATH
