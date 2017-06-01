FROM ubuntu:16.04

MAINTAINER Raghu Kanakamedala <dev@raghuveerk.com>
ENV REFRESHED_AT 2017-06-01 16:22:00

RUN \
  # configure the "liferay" user
  groupadd liferay && \
  useradd liferay -s /bin/bash -m -g liferay -G sudo && \
  echo 'liferay:liferay' |chpasswd && \
  mkdir /home/liferay/app && \

  # Install Oracle jdk
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y  software-properties-common && \
  add-apt-repository ppa:webupd8team/java -y && \
  apt-get update && \
  echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
  apt-get install -y oracle-java8-installer && \
  
  # install utilities
  apt-get install -y \
  	curl \
  	sudo \
  	unzip \
  	telnet \    
  	vim && \

  # cleanup
  apt-get clean && \
  rm -rf \
    /home/liferay/.cache/ \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* && \

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

ENV PATH $PATH:/usr/bin
WORKDIR "/opt/liferay-dxp-digital-enterprise-7.0-sp2"

VOLUME ["/opt/liferay-dxp-digital-enterprise-7.0-sp2/data", "/opt/liferay-dxp-digital-enterprise-7.0-sp2/deploy"]

ENV JPDA_ADDRESS 8000

# Expose port 8080, JMX port 13333 & Debug port 8000
EXPOSE 8080 13333 8000

CMD ["tail", "-f", "/opt/liferay-dxp-digital-enterprise-7.0-sp2/tomcat-8.0.32/logs/catalina.out"]