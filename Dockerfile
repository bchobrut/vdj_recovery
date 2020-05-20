FROM ubuntu:18.04
RUN apt-get -y upgrade
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
RUN apt-get install -y software-properties-common
RUN apt-add-repository universe
RUN apt-get update
RUN apt-get install -y python-pip
RUN yes | pip install pandas
RUN yes | pip install biopython
RUN yes | pip install regex
RUN yes | pip install openpyxl
RUN yes | pip install tables
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git-all
RUN git clone https://github.com/bchobrut/vdj_recovery.git
CMD sh /vdj_recovery/Master_Header.sh