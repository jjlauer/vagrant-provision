#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# defaults
ES_VERSION="2.3.2"
JAVA_HOME=/usr/lib/jvm/current

# arguments
for i in "$@"; do
  case $i in
    --version=*)
      ES_VERSION="${i#*=}"
      ;;
    --javahome=*)
      JAVA_HOME="${i#*=}"
      ;;
    *)
      echo "Unknown argument '$i'"
      exit 1  
      ;;
  esac
done

echo "Installing elasticsearch $ES_VERSION..."

echo "Downloading elasticsearch..."
wget --no-verbose https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/$ES_VERSION/elasticsearch-$ES_VERSION.deb
dpkg -i elasticsearch-$ES_VERSION.deb

# elastic has awful java detection - tell it where java_home is
echo "Configuring elasticsearch to search $JAVA_HOME for java"
echo "JAVA_HOME=\"$JAVA_HOME\"" >> /etc/default/elasticsearch

# port forwards only work to a real ip, not localhost
echo "Configuring elasticsearch to bind to all network interfaces (not just localhost by default)"
sed -i "s/^.*network\.host.*$/network.host: 0.0.0.0/" /etc/elasticsearch/elasticsearch.yml

service elasticsearch restart

echo "Installed elasticsearch $ES_VERSION"