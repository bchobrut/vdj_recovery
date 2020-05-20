FROM ubuntu:18.04
RUN apt-get -y upgrade
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
RUN apt-get install software-properties-common
RUN apt-add-repository universe
RUN apt-get update
RUN apt-get install -y python-pip
RUN pip install -y pandas
RUN pip install -y biopython
RUN pip install -y regex
RUN apt-get install -y git-all
RUN git clone https://github.com/bchobrut/vdj_recovery.git