FROM python:3.11

RUN apt-get install -y libffi-dev

WORKDIR /ukwa-reports

# Python dependencies and shared code:
COPY setup.py .
COPY ukwa_reports ./ukwa_reports
RUN pip install --no-cache -v .

# Jupyter Book work:
COPY content content
COPY build.sh .
# Default action is to run the full build script to generate output at ./_build
# Use volumes to map input (content) and/or output (_build)
CMD ./build.sh
