import React, { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import { ChevronRight, Terminal, Play, ArrowLeft, FileCode, AlertCircle, Command } from 'lucide-react';

const RAW_BACKEND_URL = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8000';
const BACKEND_URL = RAW_BACKEND_URL.replace(/\/$/, '');
const API = BACKEND_URL.endsWith('/api') ? BACKEND_URL : `${BACKEND_URL}/api`;

const RetroTerminal = () => {
  const [currentView, setCurrentView] = useState('menu'); // menu, script-detail, execution, results, terminal
  const [selectedScript, setSelectedScript] = useState(null);
  const [parameters, setParameters] = useState({});
  const [executionOutput, setExecutionOutput] = useState('');
  const [isExecuting, setIsExecuting] = useState(false);
  const [cursorVisible, setCursorVisible] = useState(true);
  const [scripts, setScripts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [commandInput, setCommandInput] = useState('');
  const [commandHistory, setCommandHistory] = useState([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const commandInputRef = useRef(null);

  // Fetch scripts on mount
  useEffect(() => {
    fetchScripts();
  }, []);

  // Blinking cursor effect
  useEffect(() => {
    const interval = setInterval(() => {
      setCursorVisible(prev => !prev);
    }, 530);
    return () => clearInterval(interval);
  }, []);

  const fetchScripts = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await axios.get(`${API}/scripts`);
      setScripts(response.data.scripts || []);
    } catch (err) {
      console.error('Error fetching scripts:', err);
      setError('Failed to load PowerShell scripts. Please check backend connection.');
    } finally {
      setLoading(false);
    }
  };

  const handleScriptSelect = (script) => {
    setSelectedScript(script);
    setParameters({});
    setCurrentView('script-detail');
  };

  const handleParameterChange = (paramName, value) => {
    setParameters(prev => ({
      ...prev,
      [paramName]: value
    }));
  };

  const handleExecute = async () => {
    setIsExecuting(true);
    setCurrentView('execution');
    setError(null);
    
    try {
      const response = await axios.post(`${API}/execute`, {
        script_name: selectedScript.name,
        parameters: parameters
      });
      
      const result = response.data;
      
      if (result.success) {
        setExecutionOutput(result.output);
      } else {
        setExecutionOutput(`[ERROR] Script execution failed\n\n${result.error || 'Unknown error'}\n\n${result.output}`);
      }
      
      setIsExecuting(false);
      setCurrentView('results');
    } catch (err) {
      console.error('Error executing script:', err);
      setExecutionOutput(`[ERROR] Failed to execute script\n\n${err.message || 'Network error'}`);
      setIsExecuting(false);
      setCurrentView('results');
    }
  };

  const handleBackToMenu = () => {
    setCurrentView('menu');
    setSelectedScript(null);
    setParameters({});
    setExecutionOutput('');
    setCommandInput('');
  };

  const handleOpenTerminal = () => {
    setCurrentView('terminal');
    setCommandHistory([]);
    setCommandInput('');
    setTimeout(() => {
      commandInputRef.current?.focus();
    }, 100);
  };

  const handleCommandSubmit = async (e) => {
    e.preventDefault();
    
    if (!commandInput.trim()) return;
    
    // Add to history
    const newHistory = [...commandHistory, { command: commandInput, output: null, timestamp: new Date() }];
    setCommandHistory(newHistory);
    setHistoryIndex(-1);
    
    const currentCommand = commandInput;
    setCommandInput('');
    setIsExecuting(true);
    
    try {
      const response = await axios.post(`${API}/execute-command`, {
        command: currentCommand
      });
      
      const result = response.data;
      
      // Update the last history item with output
      setCommandHistory(prev => {
        const updated = [...prev];
        updated[updated.length - 1] = {
          ...updated[updated.length - 1],
          output: result.output,
          success: result.success,
          executionTime: result.execution_time
        };
        return updated;
      });
      
    } catch (err) {
      console.error('Error executing command:', err);
      setCommandHistory(prev => {
        const updated = [...prev];
        updated[updated.length - 1] = {
          ...updated[updated.length - 1],
          output: `[ERROR] Failed to execute command\n\n${err.message || 'Network error'}`,
          success: false
        };
        return updated;
      });
    } finally {
      setIsExecuting(false);
      setTimeout(() => {
        commandInputRef.current?.focus();
      }, 100);
    }
  };

  const handleKeyDown = (e) => {
    // Arrow up - previous command
    if (e.key === 'ArrowUp') {
      e.preventDefault();
      const allCommands = commandHistory.map(h => h.command);
      if (allCommands.length > 0) {
        const newIndex = historyIndex === -1 ? allCommands.length - 1 : Math.max(0, historyIndex - 1);
        setHistoryIndex(newIndex);
        setCommandInput(allCommands[newIndex]);
      }
    }
    // Arrow down - next command
    else if (e.key === 'ArrowDown') {
      e.preventDefault();
      const allCommands = commandHistory.map(h => h.command);
      if (historyIndex !== -1) {
        const newIndex = Math.min(allCommands.length - 1, historyIndex + 1);
        setHistoryIndex(newIndex);
        setCommandInput(allCommands[newIndex]);
      }
    }
  };

  const renderHeader = () => (
    <div className="retro-header">
      <div className="header-bar">
        <div className="header-title">
          <Terminal className="header-icon" size={24} />
          <span>PowerShell Script Executor v2.0</span>
        </div>
        <div className="header-date">
          {new Date().toLocaleDateString('en-US', { 
            weekday: 'short', 
            year: 'numeric', 
            month: 'short', 
            day: 'numeric' 
          })}
        </div>
      </div>
      <div className="header-border">═══════════════════════════════════════════════════════════════════════════════════</div>
    </div>
  );

  const renderMenu = () => {
    if (loading) {
      return (
        <div className="retro-content">
          <div className="execution-screen">
            <div className="execution-title">╔═════════════════════════════════════╗</div>
            <div className="execution-title">║     LOADING SCRIPTS...              ║</div>
            <div className="execution-title">╚═════════════════════════════════════╝</div>
            <div className="execution-status">
              <div className="spinner">▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░</div>
              <div className="status-text">
                Please wait{cursorVisible && <span className="cursor">█</span>}
              </div>
            </div>
          </div>
        </div>
      );
    }

    if (error) {
      return (
        <div className="retro-content">
          <div className="error-box">
            <AlertCircle size={48} />
            <div className="error-title">CONNECTION ERROR</div>
            <div className="error-message">{error}</div>
            <button className="retro-button retro-button-execute" onClick={fetchScripts}>
              <span>RETRY</span>
            </button>
          </div>
        </div>
      );
    }

    return (
      <div className="retro-content">
        <div className="menu-title">
          <div className="title-box">
            ╔═══════════════════════════════════════════════════════════════════════════╗
            <br />
            ║                     AVAILABLE POWERSHELL SCRIPTS                          ║
            <br />
            ╚═══════════════════════════════════════════════════════════════════════════╝
          </div>
        </div>

        <div className="script-list">
          {scripts.length === 0 ? (
            <div className="no-scripts">
              <FileCode size={48} />
              <p>No PowerShell scripts found</p>
              <p className="help-text">Add .ps1 files to /app/backend/scripts/ directory</p>
            </div>
          ) : (
            scripts.map((script, index) => (
          <div
            key={script.id}
            className="script-item"
            onClick={() => handleScriptSelect(script)}
            onMouseEnter={(e) => e.currentTarget.classList.add('script-item-hover')}
            onMouseLeave={(e) => e.currentTarget.classList.remove('script-item-hover')}
          >
            <div className="script-number">[{index + 1}]</div>
            <FileCode className="script-icon" size={20} />
            <div className="script-info">
              <div className="script-name">{script.name}</div>
              <div className="script-description">{script.description}</div>
            </div>
            <ChevronRight className="script-arrow" size={20} />
          </div>
            ))
          )}
        </div>

        <div className="menu-footer">
          <div className="footer-help">
            <span className="key-hint">[CLICK]</span> Select Script
            <span className="scripts-count">| {scripts.length} script(s) loaded</span>
          </div>
          <button className="terminal-button" onClick={handleOpenTerminal}>
            <Command size={18} />
            <span>PS TERMINAL</span>
          </button>
        </div>
      </div>
    );
  };

  const renderTerminal = () => (
    <div className="retro-content terminal-view">
      <div className="terminal-header">
        <div className="title-box">
          ╔═══════════════════════════════════════════════════════════════════════════╗
          <br />
          ║                     POWERSHELL COMMAND TERMINAL                           ║
          <br />
          ╚═══════════════════════════════════════════════════════════════════════════╝
        </div>
        <div className="terminal-help">
          <span className="help-item"><span className="key-hint">↑↓</span> Command History</span>
          <span className="help-item"><span className="key-hint">ENTER</span> Execute</span>
          <span className="help-item"><span className="key-hint">ESC</span> Clear</span>
        </div>
      </div>

      <div className="terminal-output">
        {commandHistory.map((item, index) => (
          <div key={index} className="terminal-entry">
            <div className="terminal-prompt">
              <span className="prompt-symbol">PS&gt;</span>
              <span className="prompt-command">{item.command}</span>
            </div>
            {item.output && (
              <div className={`terminal-result ${item.success ? 'success' : 'error'}`}>
                <pre>{item.output}</pre>
                {item.executionTime && (
                  <div className="execution-time">[Executed in {item.executionTime}s]</div>
                )}
              </div>
            )}
          </div>
        ))}
        
        {isExecuting && (
          <div className="terminal-executing">
            <span className="spinner">▓▓▓▓░░░░</span> Executing...
          </div>
        )}
      </div>

      <form onSubmit={handleCommandSubmit} className="terminal-input-form">
        <div className="terminal-input-wrapper">
          <span className="input-prompt">PS&gt;</span>
          <input
            ref={commandInputRef}
            type="text"
            className="terminal-input"
            value={commandInput}
            onChange={(e) => setCommandInput(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Enter PowerShell command..."
            disabled={isExecuting}
            autoFocus
          />
          {cursorVisible && !isExecuting && <span className="input-cursor">█</span>}
        </div>
      </form>

      <div className="action-buttons">
        <button className="retro-button retro-button-back" onClick={handleBackToMenu}>
          <ArrowLeft size={18} />
          <span>BACK TO MENU</span>
        </button>
        <button 
          className="retro-button retro-button-execute" 
          onClick={() => {
            setCommandHistory([]);
            setCommandInput('');
          }}
        >
          <span>CLEAR HISTORY</span>
        </button>
      </div>
    </div>
  );

  const renderScriptDetail = () => (
    <div className="retro-content">
      <div className="detail-header">
        <div className="title-box">
          ╔═══════════════════════════════════════════════════════════════════════════╗
          <br />
          ║  SCRIPT: {selectedScript.name.padEnd(63)}║
          <br />
          ╚═══════════════════════════════════════════════════════════════════════════╝
        </div>
        <div className="script-desc-box">{selectedScript.description}</div>
      </div>

      <div className="parameters-section">
        <div className="section-title">═══ PARAMETERS ═══</div>
        
        {selectedScript.parameters.length === 0 ? (
          <div className="no-params">[ No parameters required ]</div>
        ) : (
          <div className="params-list">
            {selectedScript.parameters.map((param) => (
              <div key={param.name} className="param-item">
                <div className="param-label">
                  <span className="param-name">
                    {param.name}
                    {param.mandatory && <span className="mandatory">*</span>}
                  </span>
                  <span className="param-type">({param.type})</span>
                </div>
                <div className="param-description">{param.description}</div>
                
                {param.type === 'Switch' ? (
                  <label className="switch-container">
                    <input
                      type="checkbox"
                      checked={parameters[param.name] || false}
                      onChange={(e) => handleParameterChange(param.name, e.target.checked)}
                    />
                    <span className="switch-label">
                      {parameters[param.name] ? '[ ENABLED ]' : '[ DISABLED ]'}
                    </span>
                  </label>
                ) : (
                  <input
                    type={param.type === 'Int32' ? 'number' : 'text'}
                    className="param-input"
                    placeholder={param.defaultValue || `Enter ${param.name}...`}
                    value={parameters[param.name] || ''}
                    onChange={(e) => handleParameterChange(param.name, e.target.value)}
                  />
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="action-buttons">
        <button className="retro-button retro-button-back" onClick={handleBackToMenu}>
          <ArrowLeft size={18} />
          <span>BACK TO MENU</span>
        </button>
        <button className="retro-button retro-button-execute" onClick={handleExecute}>
          <Play size={18} />
          <span>EXECUTE SCRIPT</span>
        </button>
      </div>
    </div>
  );

  const renderExecution = () => (
    <div className="retro-content">
      <div className="execution-screen">
        <div className="execution-title">╔═══════════════════════════════════════╗</div>
        <div className="execution-title">║     EXECUTING SCRIPT...               ║</div>
        <div className="execution-title">╚═══════════════════════════════════════╝</div>
        
        <div className="execution-status">
          <div className="spinner">▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░</div>
          <div className="status-text">
            Running: {selectedScript.name}
            {cursorVisible && <span className="cursor">█</span>}
          </div>
        </div>
      </div>
    </div>
  );

  const renderResults = () => (
    <div className="retro-content">
      <div className="results-header">
        <div className="title-box">
          ╔═══════════════════════════════════════════════════════════════════════════╗
          <br />
          ║  EXECUTION RESULTS                                                        ║
          <br />
          ╚═══════════════════════════════════════════════════════════════════════════╝
        </div>
      </div>

      <div className="output-container">
        <pre className="output-text">{executionOutput}</pre>
      </div>

      <div className="action-buttons">
        <button className="retro-button retro-button-back" onClick={handleBackToMenu}>
          <ArrowLeft size={18} />
          <span>BACK TO MENU</span>
        </button>
      </div>
    </div>
  );

  return (
    <div className="retro-terminal">
      <div className="crt-overlay"></div>
      <div className="scanlines"></div>
      
      <div className="terminal-container">
        {renderHeader()}
        
        {currentView === 'menu' && renderMenu()}
        {currentView === 'script-detail' && renderScriptDetail()}
        {currentView === 'execution' && renderExecution()}
        {currentView === 'results' && renderResults()}
        {currentView === 'terminal' && renderTerminal()}
      </div>
    </div>
  );
};

export default RetroTerminal;
