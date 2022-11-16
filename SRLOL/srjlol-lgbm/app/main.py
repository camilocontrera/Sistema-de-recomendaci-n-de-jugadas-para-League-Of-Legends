from flask import Flask
from flask import request, jsonify, Response
import joblib
import pandas as pd 
import numpy as np
from lightgbm import LGBMClassifier 
from app.lgbm import Lgbm

app = Flask(__name__)
model = joblib.load('./app/model.pkl')    

@app.route("/")
def home_view():
        return "<h1>Welcome to srlol predictions service</h1>"

@app.route('/predictions', methods=['POST'])
def predict():
    try:
        json_ = request.json
        lgbm = Lgbm(model)
        prediction = lgbm.predict(json_)
        if type(prediction) != type(None):
            return jsonify({'prediction': list(list(map( lambda x: int(x), prediction)))})
        else:
            return jsonify({'mssg': "impossible to predict with the given data, check your input."}, 422)
    except Exception as e:
        print("error", str(e))
        return jsonify({'mssg': "impossible to predict with the given data, check your input."}, 422)