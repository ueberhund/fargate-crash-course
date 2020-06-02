from flask import Flask, render_template
import os
import random


app = Flask(__name__)

@app.route("/catnip")
def index():
    return render_template("index.html")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
