from flask import Flask, jsonify
import time
import random

app = Flask(__name__)
@app.route("/")
def hello():
    return "Hello, World!"
@app.route('/time')
def get_current_time():
    current_time = int(time.time())
    return jsonify({'timestamp': current_time})

@app.route('/random')
def get_random_numbers():
    random_numbers = [random.randint(0, 5) for _ in range(10)]
    return jsonify({'numbers': random_numbers})

if __name__ == '__main__':
    
    app.run(host="0.0.0.0")


