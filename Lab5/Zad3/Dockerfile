ARG version=latest

FROM python:${version}

WORKDIR /app

COPY /myapp .


RUN pip install --no-cache-dir -r requirements.txt

CMD [ "python", "app.py" ]



