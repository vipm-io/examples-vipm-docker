FROM nationalinstruments/labview:2025q3patch1-linux

# Install prerequisites for VIPM installation and any other utils (wget, vim, etc.)
RUN apt-get update \
  && apt-get install -y wget vim \
  && rm -rf /var/lib/apt/lists/*

# Ensure that these important VIPM files are at least present, even if empty right now.
RUN mkdir -p /usr/local/jki/vipm /etc/jki \
    && touch /usr/local/jki/vipm/Settings.ini /etc/jki/jki.conf

# Install VIPM from official preview package.
RUN wget -O /tmp/vipm.deb \
    https://packages.jki.net/vipm/preview/vipm_latest_preview_amd64.deb \
    && dpkg -i /tmp/vipm.deb \
    && rm /tmp/vipm.deb

# Copy over our custom VIPM settings file, configured for LabVIEW 2025
COPY Settings.ini /usr/local/jki/vipm/Settings.ini

# Set the default command to bash, so that when we run the container, we get a shell prompt.
CMD [ "bash" ]
