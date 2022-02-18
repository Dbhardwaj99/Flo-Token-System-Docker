FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
EXPOSE 6200
EXPOSE 5009

LABEL ranchimall="ranchimallfze@gmail.com"

# CMD { "echo", "Ranchi Mall" }

# for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update
RUN apt-get -y install python3-pip
RUN apt-get -y install git
RUN apt-get -y install python-chardet python3.9 python3.9-venv
RUN apt-get -y install libsecp256k1-dev libssl-dev build-essential automake pkg-config libtool libffi-dev libgmp-dev libyaml-cpp-dev
RUN python3 -m pip install supervisor
RUN echo_supervisord_conf
RUN echo_supervisord_conf > /etc/supervisord.conf

# Installation of Pybtc, currently named as Pyflo 
WORKDIR ../
RUN git clone https://github.com/ranchimall/pyflo
WORKDIR pyflo
RUN apt-get install -y pkg-config
RUN python3 setup.py install
WORKDIR ../


# Setup of Flo Token Tracker
RUN git clone https://github.com/vivekteega/ftt-docker
RUN apt install python3.8-venv 
WORKDIR ftt-docker
RUN python3 -m pip install chardet
RUN python3 -m pip install arrow
RUN python3 -m pip install sqlalchemy
RUN python3 -m pip install socketio
RUN python3 -m pip install requests
RUN python3 -m venv env
RUN sed -i "s|chardet==4.0.0|chardet|g" /ftt-docker/requirements.txt
RUN touch config.ini
RUN echo "[DEFAULT] \nNET = testnet \nFLO_CLI_PATH = /usr/local/bin/flo-cli \nSTART_BLOCK = 740400" >> /ftt-docker/config.ini

RUN touch config.py
RUN echo "committeeAddressList = ['oVwmQnQGtXjRpP7dxJeiRGd5azCrJiB6Ka'] \nsseAPI_url = 'https://ranchimallflo-testnet.duckdns.org/' \nprivKey = 'RG6Dni1fLqeT2TEFbe7RB9tuw53bDPDXp8L4KuvmYkd5JGBam6KJ' " >> /ftt-docker/config.py


# Setup of RanchimallFlo API
WORKDIR ../
RUN git clone https://github.com/ranchimall/ranchimallflo-api
WORKDIR ranchimallflo-api
RUN python3 -m pip install --upgrade pip setuptools wheel
RUN python3 -m venv env
RUN python3 -m pip install -r requirements.txt
RUN pip3 install apscheduler
RUN touch config.py
RUN echo "dbfolder = '/home/production/dev/shivam/ranchimallflo-api' \nsse_pubKey = '02b68a7ba52a499b4cb664033f511a14b0b8b83cd3b2ffcc7c763ceb9e85caabcf' \napiUrl = 'https://flosight.duckdns.org/api/' \napilayerAccesskey = '3abc51aa522420e4e185ac22733b0f30' \nFLO_DATA_DIR = '/home/production/.flo' " >> /ranchimallflo-api/config.py


# Setup of Floscout
WORKDIR ../
RUN git clone https://github.com/ranchimall/floscout.git
WORKDIR floscout
RUN git clone https://github.com/Dbhardwaj99/mongoose-server-files.git
WORKDIR mongoose-server-files
RUN mv example ~/floscout
WORKDIR ../
WORKDIR ../

# setup of mongoose server
# RUN git clone https://github.com/cesanta/mongoose.git
# WORKDIR mongoose
# RUN simplest_web_server.c
# WORKDIR ../

# Supervisor configurations
## Flo token tracking configuration
## Ranchimallflo configuration
WORKDIR /etc/supervisor/conf.d/
RUN touch ftt-ranchimallflo.conf
RUN echo "[supervisord] \nnodaemon=true\n[program:ftt-docker]\ndirectory=ftt-docker\ncommand=python3 tracktokens-smartcontracts.py\nuser=root\nautostart=true\nautorestart=true\nstopasgroup=true\nkillasgroup=true\nstderr_logfile=/var/log/flo-token-tracking/flo-token-tracking.err.log\nstdout_logfile=/var/log/flo-token-tracking/flo-token-tracking.out.log\n[program:ranchimallflo-api]\ndirectory=/ranchimallflo-api\ncommand=/ranchimallflo-api/env/bin/hypercorn -w 1 -b 0.0.0.0:5009 wsgi:app\nuser=root\nautostart=true\nautorestart=true\nstopasgroup=true\nkillasgroup=true\nstderr_logfile=/var/log/ranchimallflo-api/ranchimallflo-api.err.log \nstdout_logfile=/var/log/ranchimallflo-api/ranchimallflo-api.out.log" >> ftt-ranchimallflo.conf
RUN mkdir /var/log/flo-token-tracking
RUN touch /var/log/flo-token-tracking/flo-token-tracking.err.log
RUN touch /var/log/flo-token-tracking/flo-token-tracking.out.log
RUN mkdir /var/log/ranchimallflo-api/
RUN touch /var/log/ranchimallflo-api/ranchimallflo-api.err.log
RUN touch /var/log/ranchimallflo-api/ranchimallflo-api.out.log

# RUN service supervisor restart

WORKDIR ../
WORKDIR ../
WORKDIR ../
RUN touch run.sh
RUN echo "#!/bin/bash\nexec python3 ftt-docker/tracktokens-smartcontracts.py" >> run.sh
RUN chmod a+x run.sh
# CMD ["./run.sh"]
WORKDIR ranchimallflo-api
# RUN hypercorn -w 1 -b 0.0.0.0:5009 wsgi:app
# RUN python3 tracktokens-smartcontracts.py