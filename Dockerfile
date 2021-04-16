FROM openjdk:16-slim

ENV USER archinaut
ENV UID 1001
ENV HOME /home/$USER
ENV PATH "$PATH:$HOME"

WORKDIR $HOME

RUN apt-get update && apt install -y unzip git wget bash

RUN adduser --system --group --uid $UID $USER

RUN chown -R $USER:$USER $HOME

USER $USER

# Download scc
RUN wget -q https://github.com/boyter/scc/releases/download/v2.13.0/scc-2.13.0-i386-unknown-linux.zip
RUN unzip -q -j ./scc-2.13.0-i386-unknown-linux.zip -d $HOME
RUN chmod +x $HOME/scc

# Download depends
RUN wget -q https://github.com/multilang-depends/depends/releases/download/0.9.6e/depends-0.9.6-package.zip
RUN unzip -q -j ./depends-0.9.6-package.zip -d $HOME

# Copy the gitlog analyzer
COPY bin/gitloganalyzer.jar $HOME

# Copy the Archinaut analyzer
COPY bin/archinaut-0.0.2-20210415.215733-1.jar $HOME/archinaut.jar

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash","/entrypoint.sh"]
