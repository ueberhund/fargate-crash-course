FROM amazon/aws-lambda-python

# set a directory for the app
WORKDIR ${LAMBDA_TASK_ROOT}

RUN pip install --upgrade pip 

# copy all the files to the container
COPY . .

# install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# run the command
CMD [ "lambda.lambda_handler" ]
