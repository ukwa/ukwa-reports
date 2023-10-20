FROM python:3.11

WORKDIR /ukwa-reports

COPY setup.py .

RUN pip install --no-cache -v .

