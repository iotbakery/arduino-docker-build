FROM ubuntu:16.04

RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends -f software-properties-common \
  && add-apt-repository ppa:openjdk-r/ppa \
  && apt-get update \
  && apt-get install --no-install-recommends --allow-change-held-packages -y \
  wget \
  unzip \
  git \
  make \
  srecord \
  bc \
  xz-utils \
  gcc \
  curl \
  xvfb \
  python \
  python-pip \
  python-dev \
  build-essential \
  libncurses-dev \
  flex \
  bison \
  gperf \
  python-serial \
  libxrender1 \
  libxtst6 \
  libxi6 \
  openjdk-8-jre \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt

RUN curl https://downloads.arduino.cc/arduino-1.8.10-linux64.tar.xz > ./arduino-1.8.10-linux64.tar.xz \
 && unxz ./arduino-1.8.10-linux64.tar.xz \
 && tar -xvf arduino-1.8.10-linux64.tar \
 && rm -rf arduino-1.8.10-linux64.tar \
 && mv ./arduino-1.8.10 ./arduino \
 && cd ./arduino \
 && ./install.sh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add boards manager URL (warning, mismatch in boardsmanager vs. boards_manager in 2.6.0 coming up)
RUN /opt/arduino/arduino \
     --pref "boardsmanager.additional.urls=http://arduino.esp8266.com/stable/package_esp8266com_index.json,https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json" \
     --save-prefs \
  && /opt/arduino/arduino \
     --install-boards esp8266:esp8266 \
     --save-prefs \
  && /opt/arduino/arduino \
     --install-boards esp32:esp32 \
     --save-prefs

WORKDIR /root/.arduino15/packages/esp32
RUN wget https://github.com/duff2013/ulptool/archive/2.4.1.zip \
&& unzip 2.4.1.zip \
&& rm -rf 2.4.1.zip \
&& mv ./ulptool-2.4.1 ./ulptool \
&& cp ./ulptool/platform.local.txt /root/.arduino15/packages/esp32/hardware/esp32/1.0.4/platform.local.txt \
&& mv ./ulptool /root/.arduino15/packages/esp32/tools/ulptool/ 


RUN curl https://github.com/espressif/binutils-esp32ulp/releases/download/v2.28.51-esp-20191205/binutils-esp32ulp-linux-amd64-2.28.51-esp-20191205.tar.gz -O -J -L \
&& tar -zxvf binutils-esp32ulp-linux-amd64-2.28.51-esp-20191205.tar.gz \
&& rm -rf binutils-esp32ulp-linux-amd64-2.28.51-esp-20191205.tar.gz \
&& mv ./esp32ulp-elf-binutils /root/.arduino15/packages/esp32/tools/ulptool/src/esp32ulp-elf-binutils 

RUN mkdir /opt/workspace
WORKDIR /opt/workspace
COPY cmd.sh /opt/
CMD [ "/opt/cmd.sh" ]
