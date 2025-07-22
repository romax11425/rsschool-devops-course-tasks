from flask import Flask, jsonify
import platform
import socket
import datetime
import os
import flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, World!'

'

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.datetime.now().isoformat(),
        'hostname': socket.gethostname(),
        'version': '1.0.0'
    })

@app.route('/info')
def info():
    return jsonify({
        'python_version': platform.python_version(),
        'flask_version': flask.__version__,
        'environment': os.environ.get('FLASK_ENV', 'development')
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)