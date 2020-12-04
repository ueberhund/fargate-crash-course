#!/usr/bin/env python3

from flask import Flask
from os import getenv
from requests import get

import json

app = Flask(__name__)

def get_service_version():
    #https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-metadata-endpoint-v4.html
    metadata_endpoint = getenv('ECS_CONTAINER_METADATA_URI_V4', None)
    if metadata_endpoint is None:
        return "Metadata endpoint not available"
    else:
        response = get("{}/task".format(metadata_endpoint)).text
        json_response = json.loads(response)
        return "{}:{}".format(json_response['Family'], json_response['Revision'])

@app.route('/')
def hello():
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Circuit Breaker Demo!</title>
</head>
<body>
   <h1> My Amazon ECS Application Demo </h1>
   <p> Current version of the service {} </p>
</body>
</html>
    """.format(get_service_version())

if __name__ == '__main__':
    app().run(host='0.0.0.0')