#!/usr/bin/env python3
import os
import glob
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
from datetime import datetime

def find_logs_directory():
    """Find the logs directory by searching common locations"""
    current_dir = os.getcwd()
    
    # Check current directory
    if os.path.exists('logs'):
        return 'logs'
    
    # Check parent directory
    parent_dir = os.path.dirname(current_dir)
    if os.path.exists(os.path.join(parent_dir, 'logs')):
        return os.path.join(parent_dir, 'logs')
    
    # Check MassiVM subdirectory
    massivm_dir = os.path.join(current_dir, 'MassiVM')
    if os.path.exists(os.path.join(massivm_dir, 'logs')):
        return os.path.join(massivm_dir, 'logs')
    
    # Check if we're in MassiVM directory
    if os.path.basename(current_dir) == 'MassiVM' and os.path.exists('logs'):
        return 'logs'
    
    # Create logs directory if not found
    logs_dir = os.path.join(current_dir, 'logs')
    os.makedirs(logs_dir, exist_ok=True)
    return logs_dir

class LogHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            # Find logs directory
            logs_dir = find_logs_directory()
            
            # Get all log files
            log_files = glob.glob(os.path.join(logs_dir, '*.log'))
            log_files.sort(reverse=True)
            
            html = '''
            <!DOCTYPE html>
            <html>
            <head>
                <title>MassiVM Installation Logs</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
                    .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                    h1 { color: #333; text-align: center; }
                    .log-file { margin: 10px 0; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
                    .log-file a { color: #007bff; text-decoration: none; font-weight: bold; }
                    .log-file a:hover { text-decoration: underline; }
                    .timestamp { color: #666; font-size: 0.9em; }
                    .size { color: #28a745; font-weight: bold; }
                    pre { background: #f8f9fa; padding: 15px; border-radius: 4px; overflow-x: auto; white-space: pre-wrap; }
                    .refresh { text-align: center; margin: 20px 0; }
                    .refresh a { background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; }
                    .status { text-align: center; margin: 10px 0; padding: 10px; border-radius: 4px; }
                    .status.running { background: #d4edda; color: #155724; }
                    .status.stopped { background: #f8d7da; color: #721c24; }
                    .info { background: #e7f3ff; color: #0c5460; padding: 10px; border-radius: 4px; margin: 10px 0; }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>📋 MassiVM Installation Logs</h1>
                    <div class="refresh">
                        <a href="/">🔄 Refresh Logs</a>
                    </div>
                    <div class="info">
                        📁 Logs directory: <strong>''' + logs_dir + '''</strong>
                    </div>
            '''
            
            # Check if MassiVM container is running
            import subprocess
            try:
                result = subprocess.run(['docker', 'ps', '--filter', 'name=MassiVM', '--format', '{{.Names}}'], 
                                      capture_output=True, text=True, timeout=5)
                if 'MassiVM' in result.stdout:
                    html += '<div class="status running">🟢 MassiVM container is running</div>'
                else:
                    html += '<div class="status stopped">🔴 MassiVM container is not running</div>'
            except:
                html += '<div class="status stopped">🔴 Could not check container status</div>'
            
            if log_files:
                html += '<h2>Available Log Files:</h2>'
                for log_file in log_files:
                    stat = os.stat(log_file)
                    size = stat.st_size
                    mtime = datetime.fromtimestamp(stat.st_mtime)
                    size_str = f"{size/1024:.1f} KB" if size < 1024*1024 else f"{size/(1024*1024):.1f} MB"
                    
                    html += f'''
                    <div class="log-file">
                        <a href="/log/{os.path.basename(log_file)}">{os.path.basename(log_file)}</a>
                        <span class="timestamp"> - {mtime.strftime('%Y-%m-%d %H:%M:%S')}</span>
                        <span class="size">({size_str})</span>
                    </div>
                    '''
            else:
                html += '<p>No log files found.</p>'
            
            html += '''
                </div>
            </body>
            </html>
            '''
            
            self.wfile.write(html.encode())
            
        elif self.path.startswith('/log/'):
            log_name = self.path[5:]  # Remove '/log/'
            logs_dir = find_logs_directory()
            log_path = os.path.join(logs_dir, log_name)
            
            if os.path.exists(log_path):
                self.send_response(200)
                self.send_header('Content-type', 'text/plain')
                self.end_headers()
                
                with open(log_path, 'r') as f:
                    content = f.read()
                self.wfile.write(content.encode())
            else:
                self.send_response(404)
                self.end_headers()
                self.wfile.write(b'Log file not found')
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Not found')

if __name__ == '__main__':
    port = 8081
    logs_dir = find_logs_directory()
    
    print(f"📋 MassiVM Log Viewer")
    print(f"📁 Logs directory: {logs_dir}")
    print(f"🌐 Access at: http://localhost:{port}")
    print("Press Ctrl+C to stop")
    print("")
    
    server = HTTPServer(('localhost', port), LogHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Log viewer stopped") 