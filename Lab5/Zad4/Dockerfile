ARG version=3.10
ARG port=8080

FROM alpine

ARG version
ARG port

RUN apk add --no-cache python3 py3-pip


ENV PYTHON_VERSION=${version}
ENV SERVER_PORT=${port}

WORKDIR /app

VOLUME [ "/data" ]

EXPOSE ${port}

CMD ["python3", "-c", "import os; print('Hello from Python', os.environ.get('PYTHON_VERSION'), 'running on port', os.environ.get('SERVER_PORT'))"]