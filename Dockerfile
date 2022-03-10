FROM python:3.7-slim

WORKDIR /assignment

ENV GOOGLE_APPLICATION_CREDENTIALS /root/.config/gcloud/application_default_credentials.json

COPY Pipfile Pipfile
COPY Pipfile.lock Pipfile.lock

RUN python -m pip install pipenv && pipenv sync

COPY driver.py driver.py
COPY queries queries

CMD ["pipenv", "run", "python", "driver.py"]
