FROM centos:centos7.3.1611

RUN yum -y install \
    # common stuff
        git \
        wget \
        unzip \
    # fmp
        ruby \
        ruby-devel \
        rubygems \
        gcc \
        make \
	rpm-build

# install fpm
RUN gem install --no-ri --no-rdoc fpm

# add PIUS repo for Python 3.5
RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm \
 && yum -y install python35u-pip python35u-tools python35u-setuptools

WORKDIR /root

ADD . /root
