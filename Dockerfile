FROM ubuntu:xenial

MAINTAINER Raghu Kanakamedala <dev@raghuveerk.com>
ENV REFRESHED_AT 2017-04-19 18:05:00

RUN \
  # configure the "liferay" user
  groupadd liferay && \
  useradd liferay -s /bin/bash -m -g liferay -G sudo && \
  echo 'liferay:liferay' |chpasswd && \
  mkdir /home/liferay/app && \

  # install open-jdk 8
  apt-get update && \
  apt-get install -y openjdk-8-jdk && \

  # install utilities
  apt-get install -y \
    curl \
    sudo \
    unzip \    
    vim && \
    
  # cleanup
  apt-get clean && \
  rm -rf \
    /home/liferay/.cache/ \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

RUN \
  # fix liferay user permissions
  chown -R liferay:liferay /home/liferay

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mkdir -p /opt/bin/ 

ADD bin/liferay-dxp-digital-enterprise-tomcat-7.0-sp2-20170317165321327.zip /opt/bin

RUN unzip /opt/bin/liferay-dxp-digital-enterprise-tomcat-7.0-sp2-20170317165321327.zip -d /opt/

ENV LIFERAY_HOME /opt/liferay-dxp-digital-enterprise-7.0-sp2

ADD resources/portal-ext.properties /opt/liferay-dxp-digital-enterprise-7.0-sp2
ADD resources/portal-setup-wizard.properties /opt/liferay-dxp-digital-enterprise-7.0-sp2
ADD resources/setenv.sh /opt/liferay-dxp-digital-enterprise-7.0-sp2/tomcat-8.0.32/bin

RUN echo "Beginning of catalina log" > /opt/liferay-dxp-digital-enterprise-7.0-sp2/tomcat-8.0.32/logs/catalina.out

RUN \
  # fix liferay permissions
  chown -R liferay:liferay /opt/liferay-dxp-digital-enterprise-7.0-sp2

RUN chmod +x /opt/liferay-dxp-digital-enterprise-7.0-sp2/tomcat-8.0.32/bin/*.sh

# change to Liferay user
USER liferay

RUN echo "set autoindent" > ~/.vimrc

ENV PATH $PATH:/usr/bin
WORKDIR "/opt/liferay-dxp-digital-enterprise-7.0-sp2"

VOLUME ["/opt/liferay-dxp-digital-enterprise-7.0-sp2/data", "/opt/liferay-dxp-digital-enterprise-7.0-sp2/deploy"]

# Expose port 8080
EXPOSE 8080

CMD ["tail", "-f", "/opt/liferay-dxp-digital-enterprise-7.0-sp2/tomcat-8.0.32/logs/catalina.out"]