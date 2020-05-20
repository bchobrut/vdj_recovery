FROM ubuntu:18.04
CMD apt-get -y upgrade
CMD apt-get update
CMD apt-get install -y build-essential
CMD ENV LANGUAGE=en_US:en
CMD ENV LANG=en_US.UTF-8
CMD ENV LC_ALL=en_US.UTF-8
CMD sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen &&     locale-gen
CMD apt-get install -y locales
