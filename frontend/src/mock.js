// Mock data for PowerShell scripts
export const mockScripts = [
  {
    id: '1',
    name: 'Get-SystemInfo.ps1',
    description: 'Retrieves detailed system information',
    parameters: [
      { name: 'ComputerName', type: 'String', mandatory: false, defaultValue: 'localhost', description: 'Target computer name' },
      { name: 'IncludeDisk', type: 'Switch', mandatory: false, description: 'Include disk information' }
    ]
  },
  {
    id: '2',
    name: 'Get-FileList.ps1',
    description: 'Lists files in a directory with filters',
    parameters: [
      { name: 'Path', type: 'String', mandatory: true, description: 'Directory path to scan' },
      { name: 'Filter', type: 'String', mandatory: false, defaultValue: '*.*', description: 'File filter pattern' },
      { name: 'Recurse', type: 'Switch', mandatory: false, description: 'Search subdirectories' }
    ]
  },
  {
    id: '3',
    name: 'Test-NetworkConnection.ps1',
    description: 'Tests network connectivity to hosts',
    parameters: [
      { name: 'HostName', type: 'String', mandatory: true, description: 'Target hostname or IP' },
      { name: 'Port', type: 'Int32', mandatory: false, defaultValue: '80', description: 'Target port number' },
      { name: 'Timeout', type: 'Int32', mandatory: false, defaultValue: '5000', description: 'Timeout in milliseconds' }
    ]
  },
  {
    id: '4',
    name: 'Export-UserReport.ps1',
    description: 'Generates user activity report',
    parameters: [
      { name: 'UserName', type: 'String', mandatory: true, description: 'Username to report on' },
      { name: 'Days', type: 'Int32', mandatory: false, defaultValue: '30', description: 'Number of days to analyze' },
      { name: 'Format', type: 'String', mandatory: false, defaultValue: 'HTML', description: 'Output format (HTML/CSV/JSON)' }
    ]
  },
  {
    id: '5',
    name: 'Clear-TempFiles.ps1',
    description: 'Cleans temporary files from system',
    parameters: [
      { name: 'OlderThanDays', type: 'Int32', mandatory: false, defaultValue: '7', description: 'Delete files older than N days' },
      { name: 'WhatIf', type: 'Switch', mandatory: false, description: 'Preview without deleting' }
    ]
  }
];

export const mockExecutionResult = (scriptName, params) => {
  const results = {
    'Get-SystemInfo.ps1': `
╔════════════════════════════════════════════════════════════════╗
║                    SYSTEM INFORMATION REPORT                   ║
╚════════════════════════════════════════════════════════════════╝

Computer Name    : ${params.ComputerName || 'localhost'}
OS Version       : Microsoft Windows 11 Pro
OS Build         : 22631.3007
Processor        : Intel(R) Core(TM) i7-11800H @ 2.30GHz
Total Memory     : 16.0 GB
Available Memory : 8.4 GB
System Uptime    : 3 days, 12 hours, 45 minutes

${params.IncludeDisk ? `
[DISK INFORMATION]
Drive C: - Total: 512 GB | Free: 145 GB | Used: 72%
Drive D: - Total: 1024 GB | Free: 512 GB | Used: 50%
` : ''}
[SUCCESS] System information retrieved successfully.
`,
    'Get-FileList.ps1': `
╔════════════════════════════════════════════════════════════════╗
║                      FILE LIST REPORT                          ║
╚════════════════════════════════════════════════════════════════╝

Scanning Path: ${params.Path}
Filter: ${params.Filter || '*.*'}
Recursive: ${params.Recurse ? 'YES' : 'NO'}

┌─────────────────────────────────────────────────────────────┐
│ Name                          Size        Modified          │
├─────────────────────────────────────────────────────────────┤
│ document.txt                  2.5 KB      2024-01-15 10:30  │
│ report.pdf                    1.2 MB      2024-01-14 15:22  │
│ presentation.pptx             5.8 MB      2024-01-13 09:15  │
│ data.xlsx                     856 KB      2024-01-12 14:45  │
│ image.png                     3.2 MB      2024-01-11 11:20  │
└─────────────────────────────────────────────────────────────┘

Total Files: 5 | Total Size: 11.5 MB

[SUCCESS] File listing completed.
`,
    'Test-NetworkConnection.ps1': `
╔════════════════════════════════════════════════════════════════╗
║                   NETWORK CONNECTION TEST                      ║
╚════════════════════════════════════════════════════════════════╝

Target Host: ${params.HostName}
Port: ${params.Port || '80'}
Timeout: ${params.Timeout || '5000'}ms

[TESTING] Resolving hostname...
[OK] Resolved to: 172.217.164.46

[TESTING] Checking port connectivity...
[OK] Port ${params.Port || '80'} is open and accepting connections

[TESTING] Measuring response time...
  Attempt 1: 45ms
  Attempt 2: 42ms
  Attempt 3: 47ms
  Average: 44.67ms

╔════════════════════════════════════════════════════════════════╗
║  CONNECTION STATUS: ✓ SUCCESSFUL                               ║
╚════════════════════════════════════════════════════════════════╝
`,
    'Export-UserReport.ps1': `
╔════════════════════════════════════════════════════════════════╗
║                    USER ACTIVITY REPORT                        ║
╚════════════════════════════════════════════════════════════════╝

User: ${params.UserName}
Period: Last ${params.Days || '30'} days
Format: ${params.Format || 'HTML'}

[PROCESSING] Collecting login data...
[OK] Found 87 login events

[PROCESSING] Analyzing activity patterns...
[OK] Processed 1,245 activities

[PROCESSING] Generating ${params.Format || 'HTML'} report...
[OK] Report created: C:\Reports\${params.UserName}_Report.${(params.Format || 'HTML').toLowerCase()}

Summary:
  Total Logins: 87
  Active Days: 24 out of ${params.Days || '30'}
  Avg Session: 6.5 hours
  Peak Activity: 10:00 AM - 12:00 PM

[SUCCESS] User report exported successfully.
`,
    'Clear-TempFiles.ps1': `
╔════════════════════════════════════════════════════════════════╗
║                    TEMP FILES CLEANUP                          ║
╚════════════════════════════════════════════════════════════════╝

Criteria: Files older than ${params.OlderThanDays || '7'} days
Mode: ${params.WhatIf ? 'PREVIEW (WhatIf)' : 'EXECUTE'}

[SCANNING] C:\\Windows\\Temp\ ...
[FOUND] 1,234 files (2.3 GB)

[SCANNING] C:\\Users\\*\\AppData\\Local\\Temp\ ...
[FOUND] 3,456 files (5.7 GB)

[SCANNING] C:\\Temp\ ...
[FOUND] 89 files (145 MB)

${params.WhatIf ? `
╔════════════════════════════════════════════════════════════════╗
║  PREVIEW MODE - No files were deleted                          ║
╚════════════════════════════════════════════════════════════════╝

Would delete: 4,779 files
Would free: 8.1 GB
` : `
[DELETING] Removing temporary files...
[PROGRESS] ████████████████████████████████████████ 100%

╔════════════════════════════════════════════════════════════════╗
║  CLEANUP COMPLETE                                              ║
╚════════════════════════════════════════════════════════════════╝

Deleted: 4,779 files
Freed: 8.1 GB
`}

[SUCCESS] Cleanup operation completed.
`
  };

  return results[scriptName] || `[ERROR] Script execution failed: Unknown script '${scriptName}'`;
};
