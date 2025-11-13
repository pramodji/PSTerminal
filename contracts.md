# PowerShell Script Executor - API Contracts & Implementation Plan

## Overview
Convert frontend from mock data to actual PowerShell script execution via backend APIs.

## API Contracts

### 1. GET /api/scripts
**Purpose**: Retrieve list of available PowerShell scripts from /app/backend/scripts/

**Response**:
```json
{
  "scripts": [
    {
      "id": "uuid",
      "name": "Get-SystemInfo.ps1",
      "description": "Retrieves detailed system information",
      "parameters": [
        {
          "name": "ComputerName",
          "type": "String",
          "mandatory": false,
          "defaultValue": "localhost",
          "description": "Target computer name"
        }
      ]
    }
  ]
}
```

### 2. POST /api/execute
**Purpose**: Execute a PowerShell script with parameters

**Request**:
```json
{
  "script_name": "Get-SystemInfo.ps1",
  "parameters": {
    "ComputerName": "localhost",
    "IncludeDisk": true
  }
}
```

**Response**:
```json
{
  "success": true,
  "output": "script execution output...",
  "error": null,
  "execution_time": 1.234
}
```

## Backend Implementation

### Files to Create/Modify:

1. **Create `/app/backend/scripts/` directory** - Store PowerShell scripts
2. **Create sample .ps1 files** in scripts folder
3. **Add script parsing logic** - Extract parameters from .ps1 files using regex
4. **Add execution logic** - Execute PowerShell using subprocess
5. **Create new routes** in server.py:
   - GET /api/scripts
   - POST /api/execute

### PowerShell Parameter Parsing Strategy:
- Read .ps1 file content
- Parse `param()` block using regex
- Extract parameter name, type, mandatory flag, default value
- Extract script description from comment block

### PowerShell Execution Strategy:
- Use Python's `subprocess` module
- Build PowerShell command with parameters
- Capture stdout and stderr
- Handle timeouts (30 seconds default)
- Return formatted output

## Frontend Integration

### Files to Modify:

1. **src/components/RetroTerminal.jsx**:
   - Replace `mockScripts` import with API call to `/api/scripts`
   - Replace `mockExecutionResult()` with API call to `/api/execute`
   - Add loading states and error handling
   - Keep same UI/UX flow

2. **Remove/Keep mock.js**:
   - Keep mock.js as fallback but don't import in RetroTerminal.jsx

### Changes Required:
- Add axios API calls in RetroTerminal component
- Add useEffect to fetch scripts on mount
- Add error handling for failed API calls
- Add loading states during script execution

## Sample PowerShell Scripts to Create:

1. **Get-SystemInfo.ps1** - System information
2. **Get-FileList.ps1** - File listing
3. **Test-NetworkConnection.ps1** - Network connectivity test
4. **Export-UserReport.ps1** - User report generation
5. **Clear-TempFiles.ps1** - Temp file cleanup

## Security Considerations:
- Validate script names (no path traversal)
- Limit execution timeout
- Sanitize parameters
- Only allow scripts from designated folder
