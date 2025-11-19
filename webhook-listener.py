from flask import Flask, request, abort
import hmac
import hashlib
import subprocess
import os

app = Flask(__name__)
WEBHOOK_SECRET = os.getenv('WEBHOOK_SECRET', '').encode()
BUILD_SCRIPT = os.getenv('BUILD_SCRIPT')

@app.route('/', methods=['POST'])
def webhook():
    signature = request.headers.get('X-Hub-Signature-256', '')
    
    # Require signature if secret is configured
    if WEBHOOK_SECRET and not signature:
        abort(401, 'Missing signature')
    
    # Validate signature if provided
    if signature and WEBHOOK_SECRET:
        mac = hmac.new(WEBHOOK_SECRET, request.data, hashlib.sha256)
        if not hmac.compare_digest(f'sha256={mac.hexdigest()}', signature):
            abort(403, 'Invalid signature')
    
    data = request.json
    if not data:
        abort(400, 'Invalid JSON payload')
    
    # Only process pushes to main branch
    if data.get('ref') == 'refs/heads/main':
        try:
            subprocess.Popen([BUILD_SCRIPT])
            return 'Build triggered', 200
        except Exception as e:
            abort(500, f'Failed to trigger build: {str(e)}')
    
    # Return different response for non-main branches
    return 'Ignored - not main branch', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)