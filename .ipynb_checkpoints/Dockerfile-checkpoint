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
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-tk
RUN yes | pip3 install --upgrade pip
RUN yes | pip3 install numpy
RUN yes | pip3 install pandas
RUN yes | pip3 install biopython
RUN yes | pip3 install regex
RUN yes | pip3 install openpyxl
RUN yes | pip3 install tables
RUN yes | pip3 install localcider
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git-all
RUN git clone https://github.com/bchobrut/vdj_recovery.git
RUN chmod -R 777 /vdj_recovery
CMD sh /vdj_recovery/Master_Header.sh