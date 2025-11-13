from fastapi import FastAPI, APIRouter, HTTPException
import uvicorn
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field, ConfigDict
from typing import List, Dict, Optional, Any
import uuid
from datetime import datetime, timezone
import subprocess
import re
import time


ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# MongoDB connection (tolerant of missing env)
mongo_url = os.getenv('MONGO_URL', 'mongodb://localhost:27017')
db_name = os.getenv('DB_NAME', 'psweb')
try:
    client = AsyncIOMotorClient(mongo_url) if mongo_url else None
    db = client[db_name] if client else None
except Exception as e:
    logging.warning(f"MongoDB client initialization failed: {e}")
    client = None
    db = None

# Create the main app without a prefix
app = FastAPI()

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")


# Define Models
class StatusCheck(BaseModel):
    model_config = ConfigDict(extra="ignore")  # Ignore MongoDB's _id field
    
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    client_name: str
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class StatusCheckCreate(BaseModel):
    client_name: str

# PowerShell Script Models
class Parameter(BaseModel):
    name: str
    type: str
    mandatory: bool
    defaultValue: Optional[str] = None
    description: str

class Script(BaseModel):
    id: str
    name: str
    description: str
    parameters: List[Parameter]

class ExecuteRequest(BaseModel):
    script_name: str
    parameters: Dict[str, Any]

class ExecuteResponse(BaseModel):
    success: bool
    output: str
    error: Optional[str] = None
    execution_time: float

# PowerShell script utilities
SCRIPTS_DIR = ROOT_DIR / "scripts"

def get_script_metadata() -> Dict[str, Dict]:
    """Hardcoded metadata for PowerShell scripts"""
    return {
        'Get-SystemInfo.ps1': {
            'description': 'Retrieves detailed system information',
            'parameters': [
                {'name': 'ComputerName', 'type': 'String', 'mandatory': False, 'defaultValue': 'localhost', 'description': 'Target computer name'},
                {'name': 'IncludeDisk', 'type': 'Switch', 'mandatory': False, 'defaultValue': None, 'description': 'Include disk information'}
            ]
        },
        'Get-FileList.ps1': {
            'description': 'Lists files in a directory with filters',
            'parameters': [
                {'name': 'Path', 'type': 'String', 'mandatory': True, 'defaultValue': None, 'description': 'Directory path to scan'},
                {'name': 'Filter', 'type': 'String', 'mandatory': False, 'defaultValue': '*.*', 'description': 'File filter pattern'},
                {'name': 'Recurse', 'type': 'Switch', 'mandatory': False, 'defaultValue': None, 'description': 'Search subdirectories'}
            ]
        },
        'Test-NetworkConnection.ps1': {
            'description': 'Tests network connectivity to hosts',
            'parameters': [
                {'name': 'HostName', 'type': 'String', 'mandatory': True, 'defaultValue': None, 'description': 'Target hostname or IP'},
                {'name': 'Port', 'type': 'Int32', 'mandatory': False, 'defaultValue': '80', 'description': 'Target port number'},
                {'name': 'Timeout', 'type': 'Int32', 'mandatory': False, 'defaultValue': '5000', 'description': 'Timeout in milliseconds'}
            ]
        },
        'Export-UserReport.ps1': {
            'description': 'Generates user activity report',
            'parameters': [
                {'name': 'UserName', 'type': 'String', 'mandatory': True, 'defaultValue': None, 'description': 'Username to report on'},
                {'name': 'Days', 'type': 'Int32', 'mandatory': False, 'defaultValue': '30', 'description': 'Number of days to analyze'},
                {'name': 'Format', 'type': 'String', 'mandatory': False, 'defaultValue': 'HTML', 'description': 'Output format (HTML/CSV/JSON)'}
            ]
        },
        'Clear-TempFiles.ps1': {
            'description': 'Cleans temporary files from system',
            'parameters': [
                {'name': 'OlderThanDays', 'type': 'Int32', 'mandatory': False, 'defaultValue': '7', 'description': 'Delete files older than N days'},
                {'name': 'WhatIf', 'type': 'Switch', 'mandatory': False, 'defaultValue': None, 'description': 'Preview without deleting'}
            ]
        }
    }

def parse_powershell_script(script_path: Path) -> Dict:
    """Get script metadata from hardcoded definitions"""
    try:
        metadata = get_script_metadata()
        script_name = script_path.name
        
        if script_name in metadata:
            return {
                'id': str(uuid.uuid4()),
                'name': script_name,
                'description': metadata[script_name]['description'],
                'parameters': metadata[script_name]['parameters']
            }
        else:
            # Fallback for unknown scripts
            return {
                'id': str(uuid.uuid4()),
                'name': script_name,
                'description': 'PowerShell script',
                'parameters': []
            }
    
    except Exception as e:
        logger.error(f"Error parsing script {script_path}: {e}")
        return None

def check_powershell_available() -> tuple[bool, str]:
    """Check if PowerShell is available"""
    try:
        # Try pwsh (PowerShell Core) first
        result = subprocess.run(['pwsh', '-Version'], capture_output=True, timeout=5)
        if result.returncode == 0:
            return True, 'pwsh'
    except:
        pass
    
    try:
        # Try powershell.exe (Windows PowerShell)
        result = subprocess.run(['powershell.exe', '-Version'], capture_output=True, timeout=5)
        if result.returncode == 0:
            return True, 'powershell.exe'
    except:
        pass
    
    return False, None

def execute_powershell_script(script_name: str, parameters: Dict[str, Any]) -> Dict:
    """Execute a PowerShell script with parameters"""
    try:
        script_path = SCRIPTS_DIR / script_name
        
        # Validate script exists
        if not script_path.exists():
            return {
                'success': False,
                'output': '',
                'error': f'Script not found: {script_name}',
                'execution_time': 0.0
            }
        
        # Check PowerShell availability
        ps_available, ps_cmd = check_powershell_available()
        
        if not ps_available:
            # Return informative message about PowerShell not being available
            return {
                'success': False,
                'output': f'''
╔═══════════════════════════════════════════════════════════════╗
║           POWERSHELL NOT AVAILABLE ON THIS SYSTEM            ║
╚═══════════════════════════════════════════════════════════════╝

Script: {script_name}
Parameters: {parameters}

[INFO] This application requires PowerShell to execute scripts.
       
Windows: PowerShell is pre-installed
Linux/Mac: Install PowerShell Core using:
  - Ubuntu/Debian: wget https://aka.ms/install-powershell.sh && bash install-powershell.sh
  - Mac: brew install powershell/tap/powershell
  
For demonstration purposes, the scripts are available in:
  /app/backend/scripts/

[NOTE] The web interface and all UI features are fully functional.
       Only actual script execution requires PowerShell installation.
''',
                'error': 'PowerShell not installed on this system',
                'execution_time': 0.0
            }
        
        # Build PowerShell command
        cmd = [ps_cmd, '-ExecutionPolicy', 'Bypass', '-File', str(script_path)]
        
        # Add parameters
        for key, value in parameters.items():
            if isinstance(value, bool):
                if value:
                    cmd.append(f'-{key}')
            else:
                cmd.extend([f'-{key}', str(value)])
        
        logger.info(f"Executing: {' '.join(cmd)}")
        
        # Execute script
        start_time = time.time()
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=60,
            encoding='utf-8',
            errors='replace'
        )
        execution_time = time.time() - start_time
        
        # Combine stdout and stderr
        output = result.stdout
        if result.stderr:
            output += f"\n\n[STDERR]\n{result.stderr}"
        
        return {
            'success': result.returncode == 0,
            'output': output,
            'error': None if result.returncode == 0 else f"Script exited with code {result.returncode}",
            'execution_time': round(execution_time, 3)
        }
    
    except subprocess.TimeoutExpired:
        return {
            'success': False,
            'output': '',
            'error': 'Script execution timeout (60 seconds)',
            'execution_time': 60.0
        }
    except Exception as e:
        logger.error(f"Error executing script: {e}")
        return {
            'success': False,
            'output': '',
            'error': str(e),
            'execution_time': 0.0
        }

# PowerShell script routes
@api_router.get("/scripts", response_model=Dict[str, List[Script]])
async def get_scripts():
    """Get list of available PowerShell scripts"""
    try:
        if not SCRIPTS_DIR.exists():
            SCRIPTS_DIR.mkdir(parents=True, exist_ok=True)
        
        scripts = []
        for script_file in SCRIPTS_DIR.glob("*.ps1"):
            script_data = parse_powershell_script(script_file)
            if script_data:
                scripts.append(script_data)
        
        return {"scripts": scripts}
    
    except Exception as e:
        logger.error(f"Error listing scripts: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.post("/execute", response_model=ExecuteResponse)
async def execute_script(request: ExecuteRequest):
    """Execute a PowerShell script with parameters"""
    try:
        # Validate script name (prevent path traversal)
        if '..' in request.script_name or '/' in request.script_name or '\\' in request.script_name:
            raise HTTPException(status_code=400, detail="Invalid script name")
        
        result = execute_powershell_script(request.script_name, request.parameters)
        return result
    
    except Exception as e:
        logger.error(f"Error executing script: {e}")
        raise HTTPException(status_code=500, detail=str(e))

class CommandRequest(BaseModel):
    command: str

@api_router.post("/execute-command", response_model=ExecuteResponse)
async def execute_command(request: CommandRequest):
    """Execute a custom PowerShell command"""
    try:
        # Check PowerShell availability
        ps_available, ps_cmd = check_powershell_available()
        
        if not ps_available:
            return {
                'success': False,
                'output': '''
╔═══════════════════════════════════════════════════════════════╗
║           POWERSHELL NOT AVAILABLE ON THIS SYSTEM            ║
╚═══════════════════════════════════════════════════════════════╝

[INFO] PowerShell is required to execute commands.
       
Windows: PowerShell is pre-installed
Linux/Mac: Install PowerShell Core
''',
                'error': 'PowerShell not installed',
                'execution_time': 0.0
            }
        
        # Execute command
        start_time = time.time()
        result = subprocess.run(
            [ps_cmd, '-Command', request.command],
            capture_output=True,
            text=True,
            timeout=30,
            encoding='utf-8',
            errors='replace'
        )
        execution_time = time.time() - start_time
        
        # Combine stdout and stderr
        output = result.stdout
        if result.stderr:
            output += f"\n\n[STDERR]\n{result.stderr}"
        
        # If output is empty, provide feedback
        if not output.strip():
            output = "[Command executed successfully with no output]"
        
        return {
            'success': result.returncode == 0,
            'output': output,
            'error': None if result.returncode == 0 else f"Command exited with code {result.returncode}",
            'execution_time': round(execution_time, 3)
        }
    
    except subprocess.TimeoutExpired:
        return {
            'success': False,
            'output': '',
            'error': 'Command execution timeout (30 seconds)',
            'execution_time': 30.0
        }
    except Exception as e:
        logger.error(f"Error executing command: {e}")
        return {
            'success': False,
            'output': '',
            'error': str(e),
            'execution_time': 0.0
        }

# Add your routes to the router instead of directly to app
@api_router.get("/")
async def root():
    return {"message": "Hello World"}

@api_router.post("/status", response_model=StatusCheck)
async def create_status_check(input: StatusCheckCreate):
    if db is None:
        raise HTTPException(status_code=503, detail="Database not configured. Set MONGO_URL and DB_NAME or provide a .env file.")
    status_dict = input.model_dump()
    status_obj = StatusCheck(**status_dict)
    doc = status_obj.model_dump()
    doc['timestamp'] = doc['timestamp'].isoformat()
    await db.status_checks.insert_one(doc)
    return status_obj

@api_router.get("/status", response_model=List[StatusCheck])
async def get_status_checks():
    if db is None:
        raise HTTPException(status_code=503, detail="Database not configured. Set MONGO_URL and DB_NAME or provide a .env file.")
    status_checks = await db.status_checks.find({}, {"_id": 0}).to_list(1000)
    for check in status_checks:
        if isinstance(check.get('timestamp'), str):
            check['timestamp'] = datetime.fromisoformat(check['timestamp'])
    return status_checks

@api_router.get("/health")
async def health_check():
    """Health check endpoint for monitoring and frontend connectivity verification"""
    return {
        "status": "ok",
        "service": "PSWeb API",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "database": "connected" if db is not None else "not configured"
    }

# Include the router in the main app
app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=os.environ.get('CORS_ORIGINS', '*').split(','),
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.on_event("shutdown")
async def shutdown_db_client():
    if client is not None:
        client.close()

if __name__ == "__main__":
    host = os.environ.get("HOST", "0.0.0.0")
    port = int(os.environ.get("PORT", "8000"))
    reload = os.environ.get("RELOAD", "false").lower() == "true"
    target = "server:app" if reload else app
    uvicorn.run(target, host=host, port=port, reload=reload)