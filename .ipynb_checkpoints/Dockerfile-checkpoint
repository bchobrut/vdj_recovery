FROM ubuntu:latest
RUN apt-get -y upgrade
RUN apt-get update
RUN apt-get install -y apt-transport-https
RUN apt-get install -y build-essential
RUN apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
RUN apt-add-repository universe
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python-pip
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python-tk
RUN yes | pip install --upgrade pip
RUN yes | pip install numpy
RUN yes | pip install pandas
RUN yes | pip install biopython
RUN yes | pip install regex
RUN yes | pip install openpyxl
RUN yes | pip install tables
RUN yes | pip install localcider
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git-all
RUN git clone https://github.com/bchobrut/vdj_recovery.git
RUN chmod -R 777 /vdj_recovery
CMD sh /vdj_recovery/Master_Header.sh