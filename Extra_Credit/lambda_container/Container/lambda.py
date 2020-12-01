import json
import pandas as pd 

def lambda_handler(event, context):

    df = pd.read_csv('sample-data.csv')
    result = df.to_json(orient="split")
    parsed = json.loads(result)
    return json.dumps(parsed,indent=4)


#def handler(event, context): 
#    return 'Hello from AWS Lambda using Python!'