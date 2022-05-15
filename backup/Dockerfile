FROM ubuntu

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get -y install mysql-client-core-8.0 && \
    apt-get -y install zip && \
    apt-get -y install awscli

COPY backup.sh backup.sh
ENTRYPOINT ./backup.sh
