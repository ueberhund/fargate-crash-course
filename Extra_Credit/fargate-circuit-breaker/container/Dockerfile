FROM python:3

EXPOSE 5000

COPY ./flask_app.py /flask_app/app.py

RUN pip install requests flask

WORKDIR /flask_app

CMD ["flask", "run", "--host", "0.0.0.0"]
#CMD ["exit", "2"]