FROM python:3

LABEL Maintainer="Aaron Bowen <github.com/aareano>"

ARG DEBIAN_FRONTEND=noninteractive

# run container set-up as root
USER root

WORKDIR /app

RUN apt-get update

RUN apt-get install -y python3-pip && pip3 install --upgrade pip

COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

COPY src src

# set up the user for running the container
RUN groupadd -g 999 app && \
    useradd --system --create-home -u 999 -g app app && \
    chown -R app /app
USER app
