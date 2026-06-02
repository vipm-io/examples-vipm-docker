FROM nationalinstruments/labview:2026q1-linux

ARG VIPM_RELEASE_TYPE=preview
ARG VIPM_VERSION=26.3.0-3859


# wget is required to download VIPM, and is not included in the base LabVIEW image.
RUN apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

# Install VIPM
RUN wget -O /tmp/vipm.deb \
    https://packages.jki.net/vipm/${VIPM_RELEASE_TYPE}/vipm_${VIPM_VERSION}_amd64.deb \
    && dpkg -i /tmp/vipm.deb \
    && rm /tmp/vipm.deb

RUN wget -O /tmp/vipm.deb \
    https://packages.jki.net/vipm/preview/vipm_latest_preview_amd64.deb \
    && dpkg -i /tmp/vipm.deb \
    && rm /tmp/vipm.deb


WORKDIR /root

COPY docker-display.sh /usr/local/jki/vipm/support/docker-display.sh
RUN chmod +x /usr/local/jki/vipm/support/docker-display.sh

COPY docker-entrypoint.sh /usr/local/jki/vipm/support/docker-entrypoint.sh
RUN chmod +x /usr/local/jki/vipm/support/docker-entrypoint.sh
    
RUN vipm help

ENTRYPOINT [ "/usr/local/jki/vipm/support/docker-entrypoint.sh" ]
CMD [ "bash" ]
