FROM ubuntu:14.04

MAINTAINER  Lohit "lohit.halemani@opexsoftware.com"

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer libxext-dev libxrender-dev libxtst-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Install libgtk as a separate step so that we can share the layer above with
# the netbeans image
RUN apt-get update && apt-get install -y libgtk2.0-0 libcanberra-gtk-module

RUN wget http://eclipse.c3sl.ufpr.br/technology/epp/downloads/release/luna/SR1a/eclipse-java-luna-SR1a-linux-gtk-x86_64.tar.gz -O /tmp/eclipse.tar.gz -q && \
    echo 'Installing eclipse' && \
    tar -xvzf /tmp/eclipse.tar.gz -C /opt && \
    rm /tmp/eclipse.tar.gz

# Selenium Webdriver 
RUN wget http://selenium-release.storage.googleapis.com/2.47/selenium-java-2.47.1.zip 
RUN apt-get install unzip
RUN apt-get install zip
RUN unzip selenium-java-2.47.1.zip -d /opt/ 

# Apache POI
RUN wget http://www.us.apache.org/dist/poi/release/bin/poi-bin-3.13-20150929.zip
RUN unzip poi-bin-3.13-20150929.zip -d /opt/ 

# Apache log4j
RUN wget http://www.eu.apache.org/dist/logging/log4j/1.2.17/log4j-1.2.17.zip
RUN unzip log4j-1.2.17.zip -d /opt/ 

# Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    google-chrome-stable \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/*

# Chrome Driver
ENV CHROME_DRIVER_VERSION 2.18
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

# Firefox
RUN apt-get update -qqy \
 && apt-get -qqy --no-install-recommends install \
 firefox \
 && rm -rf /var/lib/apt/lists/*

RUN wget http://www.java2s.com/Code/JarDownload/gson/gson-2.3.jar.zip
RUN unzip gson-2.3.jar.zip -d /opt/ 



RUN wget http://apache.osuosl.org//commons/logging/binaries/commons-logging-1.2-bin.zip
RUN unzip commons-logging-1.2-bin.zip -d /opt/ 
RUN wget http://apache.osuosl.org//commons/logging/source/commons-logging-1.2-src.zip
RUN unzip commons-logging-1.2-src.zip -d /opt/

RUN wget http://selenium-release.storage.googleapis.com/2.47/selenium-server-standalone-2.47.1.jar
ADD run /usr/local/bin/eclipse

RUN chmod +x /usr/local/bin/eclipse && \
    mkdir -p /home/developer && \
    echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown developer:developer -R /home/developer && \
    chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo

USER developer
ENV HOME /home/developer
WORKDIR /home/developer
CMD /usr/local/bin/eclipse  

