# PSWeb - Portable Deployment Package

A web-based PowerShell script execution platform with a retro terminal interface.

## 🚀 Quick Start (Portable - No Internet Required)

### Windows
1. **Copy the entire `PSWeb-main` folder** to the target computer
2. **Install Python 3.10+** if not already installed: https://www.python.org/downloads/
3. **Install Node.js 18+** if not already installed: https://nodejs.org/
4. Double-click **`START.bat`** in the project root

### Linux / macOS
1. **Copy the entire `PSWeb-main` folder** to the target computer
2. **Install Python 3.10+** and **Node.js 18+** if not already installed
3. Make scripts executable and run:
```bash
chmod +x START.sh
./START.sh
```

## 📦 What Gets Copied

**IMPORTANT:** When copying to a new computer, copy the **entire folder** including:

```
PSWeb-main/
├── START.bat / START.sh           # Main launcher
├── start-backend.bat / .sh        # Backend launcher
├── start-frontend.bat / .sh       # Frontend launcher
├── backend/
│   ├── .venv/                     # ✅ Python virtual environment (keep this!)
│   ├── server.py
│   ├── requirements.txt
│   ├── .env                       # Auto-created if missing
│   └── scripts/                   # PowerShell scripts
└── frontend/
    ├── node_modules/              # ✅ Node dependencies (keep this!)
    ├── package.json
    ├── .env.local                 # Auto-created if missing
    ├── build/                     # Production build (optional)
    └── src/                       # React application
```

## ⚡ No Internet Installation

The application is **fully portable** and works offline:

- ✅ Python dependencies are in `backend/.venv/`
- ✅ Node.js dependencies are in `frontend/node_modules/`
- ✅ No download during startup
- ✅ Only requires Python and Node.js runtime to be installed

## 📋 Prerequisites (One-Time on New Computer)

Only the runtime environments need to be installed:

- **Python 3.10+** - [Download](https://www.python.org/downloads/)
- **Node.js 18+** - [Download](https://nodejs.org/)

## 🎯 Manual Startup (Alternative)

### Option 1: Individual Scripts

**Backend:**
```bash
# Windows
start-backend.bat

# Linux/Mac
./start-backend.sh
```

**Frontend:**
```bash
# Windows
start-frontend.bat

# Linux/Mac
./start-frontend.sh
```

### Option 2: VS Code Tasks

1. Open project in VS Code
2. Press `Ctrl+Shift+P`
3. Select "Tasks: Run Task"
4. Choose "Start All Servers"

### Option 3: Manual Commands

**Backend:**
```bash
cd backend
python -m venv .venv
.venv\Scripts\activate      # Windows
source .venv/bin/activate   # Linux/Mac
pip install -r requirements.txt
python server.py
```

**Frontend:**
```bash
cd frontend
npm install
npm start
```

## 🌐 Access the Application

Once started:
- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:8000
- **API Docs:** http://localhost:8000/docs

## 📁 Project Structure

```
PSWeb-main/
├── START.bat                 # 🎯 Main launcher (Windows)
├── START.sh                  # 🎯 Main launcher (Linux/Mac)
├── start-backend.bat         # Backend launcher (Windows)
├── start-backend.sh          # Backend launcher (Linux/Mac)
├── start-frontend.bat        # Frontend launcher (Windows)
├── start-frontend.sh         # Frontend launcher (Linux/Mac)
├── backend/
│   ├── server.py             # FastAPI server
│   ├── requirements.txt      # Python dependencies
│   ├── .env                  # Environment config (auto-created)
│   └── scripts/              # PowerShell scripts (.ps1 files)
└── frontend/
    ├── package.json          # Node dependencies
    ├── .env.local            # React config (auto-created)
    └── src/                  # React application
```

## 🔧 Configuration

### Backend (.env)
Auto-created on first run. Default values:
```env
MONGO_URL=mongodb://localhost:27017
DB_NAME=psweb
CORS_ORIGINS=*
HOST=0.0.0.0
PORT=8000
RELOAD=false
```

### Frontend (.env.local)
Auto-created on first run:
```env
REACT_APP_BACKEND_URL=http://localhost:8000
```

## 📝 Adding PowerShell Scripts

1. Place `.ps1` files in `backend/scripts/`
2. Add metadata in `backend/server.py` → `get_script_metadata()`
3. Restart backend server
4. Scripts appear automatically in the UI

## 🐛 Troubleshooting

### "Python/Node not found"
- Install Python 3.10+ and Node.js 18+
- Verify they're in your system PATH
- Restart terminal/computer after installation

### "node_modules folder not found"
- Ensure you copied the **entire folder** including `frontend/node_modules/`
- If missing, run `npm install` in the frontend directory (requires internet)

### ".venv not found" or Python import errors
- Ensure you copied `backend/.venv/` folder
- If missing, run in backend directory (requires internet):
  ```bash
  python -m venv .venv
  .venv\Scripts\activate
  pip install -r requirements.txt
  ```

### "Port already in use"
Kill existing processes:
```bash
# Windows
netstat -ano | findstr :8000
netstat -ano | findstr :3000
taskkill /PID <process_id> /F

# Linux/Mac
lsof -ti:8000 | xargs kill -9
lsof -ti:3000 | xargs kill -9
```

### Frontend can't connect to backend
1. Verify backend is running on port 8000
2. Check `frontend/.env.local` has `REACT_APP_BACKEND_URL=http://localhost:8000`
3. Clear browser cache and hard refresh (Ctrl+Shift+R)

## 🔒 PowerShell Execution Policy (Windows)

If PowerShell scripts fail to execute:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## 📦 Creating Deployment Package

To prepare a portable copy for another computer:

1. **Ensure dependencies are installed** on source computer:
   ```bash
   cd backend
   python -m venv .venv
   .venv\Scripts\activate
   pip install -r requirements.txt
   
   cd ../frontend
   npm install
   ```

2. **Copy entire `PSWeb-main` folder** including:
   - `backend/.venv/` (Python dependencies)
   - `frontend/node_modules/` (Node dependencies)
   - All `.bat` and `.sh` launcher scripts
   - All source code and configuration files

3. **Zip the folder** (optional for easier transfer)

4. **On target computer:**
   - Extract to any location
   - Install Python 3.10+ and Node.js 18+
   - Run `START.bat` or `./START.sh`

## ⚠️ Important Notes

- **Virtual environments are NOT portable across different OS types** (Windows `.venv` won't work on Linux)
- For cross-OS deployment, only copy source code and run setup scripts on target machine
- `node_modules` can be large (~500MB) - consider using `.zip` compression for transfer
- Keep folder structure intact - relative paths are used throughout

## 🛠️ Development

### Backend Hot Reload
Set `RELOAD=true` in `backend/.env` for auto-reload on code changes.

### Frontend Hot Reload
Enabled by default with `npm start` (watches file changes automatically).

## 📜 License

See LICENSE file for details.

## 🙋 Support

For issues or questions:
1. Check the troubleshooting section above
2. Verify prerequisites are installed
3. Check terminal output for specific error messages
