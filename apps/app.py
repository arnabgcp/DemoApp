from flask import Flask
import subprocess
app = Flask(__name__)

@app.route('/')
def hello_geek():
    host = str(subprocess.check_output('hostname'))
    retstr = '<h1>From host ' + host + '</h1>' 
    return retstr
    
@app.route('/getsec')
def hello_sec():
    try:
     secret = str(subprocess.check_output("cat /secrets/*", shell=True))
     return "<h1>From vault secret : " + secret + "</h1>" 
    except:
     secret = "Secret not found"
     return secret

@app.route('/health')
def hello_health():
    return "healthy"


if __name__ == "__main__":
    app.run(debug=True)