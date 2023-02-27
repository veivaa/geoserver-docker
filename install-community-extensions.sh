#!/bin/bash
# Inspired by https://github.com/kartoza/docker-geoserver and https://github.com/geosever/docker

function download_extension() {
  URL=$1
  EXTENSION=$2
  DOWNLOAD_FILE="${ADDITIONAL_LIBS_DIR}geoserver-${COMMUNITY_EXTENSION_VERSION}-community-${EXTENSION}-plugin.zip"

  if [ -e "$DOWNLOAD_FILE" ]; then
      echo "$DOWNLOAD_FILE already exists. Skipping download."
  else
    if curl --output /dev/null --silent --head --fail "${URL}"; then
        echo -e "\nDownloading ${EXTENSION} extension from ${URL} to ${DOWNLOAD_FILE}"
        wget --progress=bar:force:noscroll -c --no-check-certificate "${URL}" -O ${DOWNLOAD_FILE}
      else
        echo "URL does not exist: ${URL}"
    fi
  fi
}

# Download stable plugins only if INSTALL_EXTENSIONS is true
if [ "$COMMUNITY_INSTALL_EXTENSIONS" = "true" ]; then
  echo "Starting download of community extensions"
  if [ ! -d "$ADDITIONAL_LIBS_DIR" ]; then
    mkdir -p $ADDITIONAL_LIBS_DIR
  fi
  for EXTENSION in $(echo "${COMMUNITY_EXTENSIONS}" | tr ',' ' '); do
    URL="${COMMUNITY_PLUGIN_URL}/geoserver-${COMMUNITY_EXTENSION_VERSION}-SNAPSHOT-${EXTENSION}-plugin.zip"
    download_extension ${URL} ${EXTENSION}
  done
  echo "Finished download of community extensions"
fi

# Install the extensions
# example file name geoserver-2.22-SNAPSHOT-ogcapi-plugin.zip    
echo "Starting installation of community extensions"
for EXTENSION in $(echo "${COMMUNITY_EXTENSIONS}" | tr ',' ' '); do
  ADDITIONAL_LIB=${ADDITIONAL_LIBS_DIR}geoserver-${COMMUNITY_EXTENSION_VERSION}-community-${EXTENSION}-plugin.zip
  [ -e "$ADDITIONAL_LIB" ] || continue

  if [[ $ADDITIONAL_LIB == *.zip ]]; then
    unzip -o -d ${GEOSERVER_LIB_DIR} ${ADDITIONAL_LIB} "*.jar"
    echo "Installed all jar files from ${ADDITIONAL_LIB}"
  elif [[ $ADDITIONAL_LIB == *.jar ]]; then
    cp ${ADDITIONAL_LIB} ${GEOSERVER_LIB_DIR}
    echo "Installed ${ADDITIONAL_LIB}"
  else
    echo "Skipping ${ADDITIONAL_LIB}: unknown file extension."
  fi
done
echo "Finished installation of community extensions"
