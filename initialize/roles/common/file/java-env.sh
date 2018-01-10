#!/bin/bash

cd /opt
tar xf jdk.tar.bz2
echo "export JAVA_HOME=/opt/jdk1.7.0_80" >> /etc/profile
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >>/etc/profile
echo "export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /etc/profile

rm -f /opt/jdk.tar.bz2
