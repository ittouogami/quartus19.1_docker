FROM ubuntu16
LABEL maintainer "ittou <VYG07066@gmail.com>"
ENV DEBIAN_FRONTEND noninteractive
ARG ALTERA_VER="19.1"
ARG IP
ENV INTELFPGA_TOOLDIR="/opt/Intel/intelFPGA_lite/${ALTERA_VER}"
ENV MODELSIM_DIR="${INTELFPGA_TOOLDIR}/modelsim_ase"
ENV QUARTUS_ROOTDIR="${INTELFPGA_TOOLDIR}/quartus"
ENV HLS_ROOTDIR="${INTELFPGA_TOOLDIR}/hls"
ENV QSYS_ROOTDIR="${QUARTUS_ROOTDIR}/sopc_builder/bin"
ENV QUARTUS_ROOTDIR_OVERRIDE=${QUARTUS_ROOTDIR}
ENV CPLUS_INCLUDE_PATH=/usr/include/c++/4.4.7:/usr/include/c++/4.4.7/x86_64-linux-gnu
ENV PATH=/opt/Intel/intelFPGA_lite/$ALTERA_VER/quartus/bin:/opt/Intel/intelFPGA_lite/$ALTERA_VER/qsys/bin:/opt/Intel/intelFPGA_lite/$ALTERA_VER/quartus/sopc_builder/bin:/opt/Intel/intelFPGA_lite/$ALTERA_VER/modelsim_ase/linux:/opt/Intel/intelFPGA_lite/$ALTERA_VER/hls/bin:$PATH
ENV PERL5LIB=/opt/intelFPGA_lite/19.1/quartus/linux64/perl/lib/5.28.1
ARG URIS=smb://${IP}/Share/Quartus${ALTERA_VER}/
ARG QUARTUS=QuartusLiteSetup-19.1.0.670-linux.run
ARG MAX10=max10-19.1.0.670.qdz
ARG CYCLONE10LP=cyclone10lp-19.1.0.670.qdz
ARG MODELSIM=ModelSimSetup-19.1.0.670-linux.run
ARG HLS=HLSProSetup-19.1.0.670-linux.run
RUN mkdir /quartus-installer && \
  apt-get update && \
  apt-get -y -qq install sudo && \
  apt-get -y -qq install locales && locale-gen en_US.UTF-8 && \
  apt-get -y -qq install software-properties-common \
                           libglib2.0-0 \
                           libfreetype6 \
                           libsm6 \
                           libxrender1 \
                           libfontconfig1 \
                           libxext6 \
                           libpng12-0 \
                           xterm \
                           gcc \
                           g++ \
                           smbclient && \
  dpkg --add-architecture i386 && \
  apt-get update && \
  apt-get -y -qq install libc6:i386 \
                           libncurses5:i386 \
                           libstdc++6:i386 \
                           libxft2:i386 \
                           libxext6:i386 && \
  add-apt-repository "deb http://jp.archive.ubuntu.com/ubuntu/ trusty main universe" && \
  add-apt-repository "deb http://jp.archive.ubuntu.com/ubuntu/ trusty-updates main universe" && \
  apt-get update && \
  apt-get -y -qq install g++-4.4 \
                       g++-4.4-multilib && \
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 10 --slave /usr/bin/g++ g++ /usr/bin/g++-5 && \
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.4 5 --slave /usr/bin/g++ g++ /usr/bin/g++-4.4 && \
  update-alternatives --set gcc /usr/bin/gcc-4.4 && \
  apt-get autoclean && \
  apt-get autoremove && \
  smbget -a ${URIS}${QUARTUS} -o /quartus-installer/${QUARTUS} && \
  smbget -a ${URIS}${MAX10} -o /quartus-installer/${MAX10} && \
  smbget -a ${URIS}${CYCLONE10LP} -o /quartus-installer/${CYCLONE10LP} && \
  smbget -a ${URIS}${MODELSIM} -o /quartus-installer/${MODELSIM} && \
  smbget -a ${URIS}${HLS} -o /quartus-installer/${HLS} && \
  chmod 755 /quartus-installer/${QUARTUS} && \
  chmod 755 /quartus-installer/${MODELSIM} && \
  chmod 755 /quartus-installer/${HLS} && \
  rm -rf /var/lib/apt/lists/* && \
  /quartus-installer/${QUARTUS} --mode unattended --unattendedmodeui none --installdir ${INTELFPGA_TOOLDIR} --accept_eula 1 && \
  /quartus-installer/${MODELSIM} --mode unattended --unattendedmodeui none --installdir ${INTELFPGA_TOOLDIR} --accept_eula 1 && \
  /quartus-installer/${HLS} --mode unattended --unattendedmodeui none --installdir ${INTELFPGA_TOOLDIR} --accept_eula 1 && \
  rm -rf /quartus-installer/ && \
  ln --backup=simple --suffix=.orig -sft /opt/Intel/intelFPGA_lite/19.1/quartus/linux64 /usr/lib/x86_64-linux-gnu/libstdc++.so.6 \
  ln -s ${MODELSIM_DIR}/linux ${MODELSIM_DIR}/linux_rh60 && \
  mkdir ${MODELSIM_DIR}/Unused && \
  mv ${MODELSIM_DIR}/gcc-4.* ${MODELSIM_DIR}/Unused
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash", "-c", "source ${INTELFPGA_TOOLDIR}/hls/init_hls.sh;/bin/bash"]

