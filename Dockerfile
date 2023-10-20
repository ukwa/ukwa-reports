FROM python:3.11

WORKDIR /ukwa-reports

COPY setup.py .

RUN pip install --no-cache -v .

COPY content .
COPY build.sh .

# Default action is to run the full build script to generate output at ./_build
# Use volumes to map input (content) and/or output (_build)
CMD ./build.sh
