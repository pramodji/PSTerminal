# PowerShell Script Executor - Retro Terminal Edition

A web-based PowerShell script executor with an authentic FoxPro/DOS retro aesthetic featuring blue/cyan terminal colors, CRT scanlines, and classic box-drawing characters.

## 🎨 Features

### User Interface
- **Retro FoxPro/DOS Design**: Blue/cyan color scheme with authentic terminal aesthetics
- **CRT Effects**: Scanlines, glow effects, and radial vignette
- **Interactive Navigation**: Smooth transitions between menu, script details, execution, and results
- **Parameter Intellisense**: Auto-populated forms with parameter descriptions and types
- **Responsive Design**: Works on desktop and mobile devices

### Functionality
- **Script Discovery**: Automatically reads .ps1 files from `/app/backend/scripts/`
- **Parameter Parsing**: Detects mandatory/optional parameters, types, and default values
- **Script Execution**: Executes PowerShell scripts with user-provided parameters
- **Real-time Results**: Displays script output in retro terminal format
- **Error Handling**: Graceful error messages and fallback behaviors

## 📦 Available Scripts

1. **Get-SystemInfo.ps1** - Retrieves system information
2. **Get-FileList.ps1** - Lists files in a directory
3. **Test-NetworkConnection.ps1** - Tests network connectivity
4. **Export-UserReport.ps1** - Generates user activity report
5. **Clear-TempFiles.ps1** - Cleans temporary files

## 🚀 Quick Start

### Access the Application
Open http://localhost:3000 in your browser

### For Windows Users
PowerShell is pre-installed. Scripts will execute immediately.

### For Linux/Mac Users
Install PowerShell Core to enable script execution:
```bash
# Ubuntu/Debian
wget https://aka.ms/install-powershell.sh && bash install-powershell.sh

# Mac
brew install powershell/tap/powershell
```

## 🔧 Adding Custom Scripts

1. Create your `.ps1` script in `/app/backend/scripts/`
2. Add metadata in `server.py` > `get_script_metadata()`
3. Reload the page - your script appears automatically!

## ⚠️ Current Environment Note

This application is running on Linux without PowerShell. The web interface is fully functional for demonstration, but actual script execution requires PowerShell installation or Windows environment.

## 🎯 Technology Stack

- **Frontend**: React 19, Axios, Lucide Icons, Custom CSS
- **Backend**: FastAPI, Python 3.x
- **Font**: IBM Plex Mono (authentic terminal look)
- **Design**: Blue/cyan FoxPro-style retro terminal


