#########
#
#     Dockerfile for Analysis of High Throughput Sequencing Data October 2018
#
### To run the container for the first time with generic graphics:
# xhost +
# docker run -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix:rw --privileged -e DISPLAY=unix$DISPLAY \
# -v $HOME/:/home/training/ --device /dev/dri --privileged --name highthroughput ebitraining/highthroughput
#
## To run with Nvidia graphics, add the following option:
# "-v /usr/lib/nvidia-340:/usr/lib/nvidia-340 -v /usr/lib32/nvidia-340:/usr/lib32/nvidia-340"
#
### To resume using an container:
# docker exec -it highthroughput /bin/bash
#
### To build the container:
# docker build -f ./Dockerfile -t highthroughput .
# docker tag highthroughput ebitraining/highthroughput:latest
# docker push ebitraining/highthroughput:latest
#
#########

FROM ubuntu:18.04
LABEL author="Mohamed Alibi" \
description="Docker image for Analysis of High Throughput Sequencing Data training course." \
maintainer="Mohamed Alibi <alibi@ebi.ac.uk>"

# Pre requirements
########
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en



RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y --reinstall language-pack-en \
    && apt-get install -y gnupg gdebi expect \
    && locale-gen en_GB.UTF-8

ADD https://download1.rstudio.org/rstudio-xenial-1.1.456-amd64.deb /usr/local/rstudio.deb
RUN echo "deb http://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" >> /etc/apt/sources.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9

RUN apt-get update; apt-get install -y build-essential ca-certificates libbz2-dev liblzma-dev gfortran \
    libncurses5-dev libncursesw5-dev zlib1g-dev automake pkg-config unzip openjdk-8-jre-headless perl-base \
    git wget sudo autoconf make xml2 locales libjpeg-dev zlibc libjpeg62 libxslt1.1 nano openjdk-8-jre \
    libxcomposite1 libtiff5 libqt5widgets5 libqt5webkit5 libssl-dev python3 mesa-common-dev libxml2-dev \
    libcurses-ocaml-dev libgl1-mesa-dri libgl1-mesa-glx mesa-utils fcitx-frontend-qt5 libqt5gui5 gdebi \
    fcitx-modules fcitx-module-dbus libedit2 libqt5core5a libqt5dbus5 libqt5network5 libqt5printsupport5 \
    default-jre default-jre-headless expect libcurl4 libcurl4-openssl-dev python python3 curl libopenblas-dev \
    libopenblas-base libgsl-dev liblapacke liblapacke-dev perl python-dev python3-dev cpanminus mysql-client \
    openssl libssl-dev apache2 libmysqlclient-dev libpng-dev manpages perl-base vim \
    && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java \
    && echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_GB.utf8 \
    && /usr/sbin/update-locale LANG=en_GB.UTF-8


# Install R CRAN
########
RUN apt-get update; apt-get install -y r-base r-base-core r-recommended \
    && gdebi -n /usr/local/rstudio.deb \
    && rm -rf /usr/local/*.deb \
    && ln -f -s /usr/lib/rstudio/bin/rstudio /usr/bin/rstudio \
    && apt-get install -fy

# Set default CRAN repo
########
RUN echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
    && echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
    && ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
    && ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
    && ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
    && ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
    && echo '"\e[5~": history-search-backward' >> /etc/inputrc \
    && echo '"\e[6~": history-search-backward' >> /etc/inputrc \
    && chmod 777 -R /usr/local/lib/R/ \
    && chmod 777 -R /usr/lib/R/ \
    && chmod 777 -R /usr/share/R/

# Install R downloaded_packages
########
COPY ./script.R /usr/local/script.R
RUN Rscript /usr/local/script.R \
    && chmod 777 -R /usr/local/lib/R/ \
    && chmod 777 -R /usr/lib/R/ \
    && chmod 777 -R /usr/share/R/

# Install Trimmomatic
########
ADD http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.38.zip /usr/local/Trimmomatic-0.38.zip
RUN unzip /usr/local/Trimmomatic-0.38.zip -d /usr/local/ \
    && echo -e '#!/bin/bash \n\njava -jar /usr/local/Trimmomatic-0.38/trimmomatic-0.38.jar $@' > /usr/local/Trimmomatic-0.38/trimmomatic \
    && chmod -R 777 /usr/local/Trimmomatic-0.38/ \
    && ln -s /usr/local/Trimmomatic-0.38/trimmomatic* /usr/local/bin/ \
    && rm /usr/local/Trimmomatic-0.38.zip

# Install FastQC
########
ADD https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.8.zip /usr/local/fastqc.zip
RUN unzip /usr/local/fastqc.zip -d /usr/local/ \
    && chmod -R 777 /usr/local/FastQC \
    && ln -s /usr/local/FastQC/fastqc /usr/local/bin/ \
    && rm /usr/local/fastqc.zip

# Install SOAPec
########
ADD https://kent.dl.sourceforge.net/project/soapdenovo2/ErrorCorrection/SOAPec_v2.01.tar.gz /usr/local/SOAPec.tar.gz
RUN tar xvf /usr/local/SOAPec.tar.gz -C /usr/local/ \
    && chmod 777 -R /usr/local/SOAPec_v2.01 \
    && ln -s /usr/local/SOAPec_v2.01/bin/* /usr/local/bin/ \
    && rm /usr/local/SOAPec.tar.gz

# Install IGV
########
ADD http://data.broadinstitute.org/igv/projects/downloads/2.4/IGV_2.4.14.zip /usr/local/IGV.zip
RUN unzip /usr/local/IGV.zip -d /usr/local/ \
    && chmod 777 -R /usr/local/IGV_2.4.14/ \
    && sed -i 's/\"$prefix\"/\/usr\/local\/IGV_2.4.14/g' /usr/local/IGV_2.4.14/igv.sh \
    && ln -s /usr/local/IGV_2.4.14/igv.sh /usr/local/bin/igv \
    && rm /usr/local/IGV.zip

# Install Tablet
########
ADD https://ics.hutton.ac.uk/resources/tablet/installers/tablet_linux_x64_1_17_08_17.sh /usr/local/tablet.sh
RUN chmod 777 /usr/local/tablet.sh \
    && /usr/bin/expect -c "spawn /usr/local/tablet.sh -c; expect -re \"OK \[o, Enter\], Cancel \[c\]\"; send \"o\r\r\"; expect -re \"\[Enter\]\"; send \"\r\"; expect -re \"Yes \[1\], No \[2\]\"; send \"1\r\"; sleep 2; expect -re \"\[\/opt\/Tablet\]\"; send \"\/usr\/local\/Tablet\/\r\"; expect -re \"Yes \[y, Enter\], No \[n\]\"; send \"y\r\"; expect -re \"\[\/usr\/local\/bin\]\"; send \"\r\"; expect -re \"Yes \[y, Enter\], No \[n\]\"; send \"n\r\"; interact" \
    && chmod 777 -R /usr/local/Tablet \
    && rm /usr/local/tablet.sh

# Install tools from the system repo
########
RUN apt-get install -y bwa graphviz \
    && rm -rf /var/lib/apt/lists/* \
    && apt -y autoremove && apt autoclean && rm -rf /var/lib/apt/lists/*

# Install htslib
########
ADD https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2 /usr/local/htslib.tar.bz2
RUN tar xvjf /usr/local/htslib.tar.bz2 -C /usr/local/ \
     && chmod 777 -R /usr/local/htslib-1.9 \
     && cd /usr/local/htslib-1.9 \
     && ./configure \
     && make \
     && make install \
     && rm /usr/local/htslib.tar.bz2

# Install bcftools
########
ADD https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2 /usr/local/bcftools.tar.bz2
RUN tar xvjf /usr/local/bcftools.tar.bz2 -C /usr/local/ \
     && chmod 777 -R /usr/local/bcftools-1.9 \
     && cd /usr/local/bcftools-1.9 \
     && ./configure \
     && make \
     && make install \
     && rm /usr/local/bcftools.tar.bz2

# Install samtools
########
ADD https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 /usr/local/samtools.tar.bz2
RUN tar xvjf /usr/local/samtools.tar.bz2 -C /usr/local/ \
     && chmod 777 -R /usr/local/samtools-1.9 \
     && cd /usr/local/samtools-1.9 \
     && ./configure \
     && make \
     && make install \
     && rm /usr/local/samtools.tar.bz2

# Install picard
########
ADD https://github.com/broadinstitute/picard/releases/download/2.18.14/picard.jar /usr/local/bin/picard.jar
RUN echo -e '#!/bin/bash \n\njava -jar /usr/local/bin/picard.jar $@' > /usr/local/bin/picard \
    && chmod 777 /usr/local/bin/picard*

# Install gatk
########
ADD https://github.com/broadinstitute/gatk/releases/download/4.0.10.0/gatk-4.0.10.0.zip /usr/local/gatk.zip
RUN unzip /usr/local/gatk.zip -d /usr/local/ \
    && chmod 777 -R /usr/local/gatk-4.0.10.0 \
    && ln -s /usr/local/gatk-4.0.10.0/gatk /usr/local/bin/ \
    && rm /usr/local/gatk.zip

# Install vcftools
########
RUN git clone https://github.com/vcftools/vcftools.git /usr/local/vcftools \
    && cd /usr/local/vcftools \
    && chmod 777 -R /usr/local/vcftools \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install

# Install freebayes
########
RUN git clone --recursive git://github.com/ekg/freebayes.git /usr/local/freebayes \
    && chmod 777 -R /usr/local/freebayes \
    && cd /usr/local/freebayes \
    && make \
    && make install

# Install qualimap
########
ADD https://bitbucket.org/kokonech/qualimap/downloads/qualimap_v2.2.1.zip /usr/local/qualimap.zip
RUN unzip /usr/local/qualimap.zip -d /usr/local/ \
    && chmod 777 -R /usr/local/qualimap_v2.2.1 \
    && Rscript /usr/local/qualimap_v2.2.1/scripts/installDependencies.r \
    && ln -s /usr/local/qualimap_v2.2.1/qualimap /usr/local/bin/ \
    && chmod 777 -R /usr/local/lib/R/ \
    && chmod 777 -R /usr/lib/R/ \
    && chmod 777 -R /usr/share/R/

# Install PLINK 1.90
########
ADD https://www.cog-genomics.org/static/bin/plink181012/plink_linux_x86_64.zip /usr/local/plink.zip
RUN unzip /usr/local/plink.zip -d /usr/local/Plink \
    && chmod 777 -R /usr/local/Plink \
    && ln -s /usr/local/Plink/plink /usr/local/bin/ \
    && rm /usr/local/plink.zip

# Install Admixture
########
ADD http://software.genetics.ucla.edu/admixture/binaries/admixture_linux-1.3.0.tar.gz /usr/local/admixture.tar.gz
RUN tar xvf /usr/local/admixture.tar.gz -C /usr/local/ \
    && chmod 777 -R /usr/local/admixture_linux-1.3.0 \
    && ln -s /usr/local/admixture_linux-1.3.0/admixture /usr/local/bin/ \
    && rm /usr/local/admixture.tar.gz

# Install EIGENSTRAT
########
RUN git clone https://github.com/DReichLab/EIG.git /usr/local/EIG \
    && chmod 777 -R /usr/local/EIG \
    && cd /usr/local/EIG/src \
    && make LDLIBS="-llapacke" \
    && make install \
    && ln -s /usr/local/EIG/bin/* /usr/local/bin/

# Install GCTA
########
ADD https://cnsgenomics.com/software/gcta/gcta_1.91.7beta.zip /usr/local/gcta.zip
RUN unzip /usr/local/gcta.zip -d /usr/local/ \
    && chmod 777 -R /usr/local/gcta_1.91.7beta \
    && ln -s /usr/local/gcta_1.91.7beta/gcta64 /usr/local/bin/ \
    && ln -s /usr/local/gcta_1.91.7beta/gcta64 /usr/local/bin/gcta \
    && rm /usr/local/gcta.zip

# Install SHAPEIT
########
ADD https://mathgen.stats.ox.ac.uk/genetics_software/shapeit/shapeit.v2.r904.glibcv2.17.linux.tar.gz /usr/local/shapeit.tar.gz
RUN tar xvf /usr/local/shapeit.tar.gz -C /usr/local/ \
    && chmod 777 -R /usr/local/shapeit.v2.904.3.10.0-693.11.6.el7.x86_64 \
    && ln -s /usr/local/shapeit.v2.904.3.10.0-693.11.6.el7.x86_64/bin/shapeit /usr/local/bin/ \
    && rm /usr/local/shapeit.tar.gz

# Install VEP
########
ADD https://github.com/Ensembl/ensembl-vep/archive/release/94.zip /usr/local/94.zip
RUN unzip /usr/local/94.zip -d /usr/local/ \
    && cd /usr/local/ensembl-vep-release-94 \
    && cpanm DBI DBD::mysql GraphViz SOAP::Lite \
    && ./travisci/get_dependencies.sh \
    && git clone https://github.com/Ensembl/ensembl-xs.git /usr/local/ensembl-vep-release-94/ensembl-xs \
    && git clone https://github.com/bioperl/bioperl-ext.git
ENV KENT_SRC /usr/local/ensembl-vep-release-94/kent-335_base/src
ENV HTSLIB_DIR /usr/local/ensembl-vep-release-94/htslib
ENV MACHTYPE x86_64
ENV CFLAGS "-fPIC"
ENV DEPS /usr/local/ensembl-vep-release-94
RUN chmod 777 -R /usr/local/ensembl-vep-release-94 \
    && cd /usr/local/ensembl-vep-release-94/htslib \
    && make install \
    && cd /usr/local/ensembl-vep-release-94/bioperl-ext/Bio/Ext/Align/ \
    && perl -pi -e"s|(cd libs.+)CFLAGS=\\\'|\$1CFLAGS=\\\'-fPIC |" Makefile.PL \
    && perl Makefile.PL \
    && make \
    && make install \
    && cd /usr/local/ensembl-vep-release-94/ensembl-xs \
    && perl Makefile.PL \
    && make \
    && make install \
    && cd /usr/local/ensembl-vep-release-94/ \
    && cpanm --installdeps --with-recommends --notest --cpanfile ./cpanfile . \
    && ln -s /usr/local/ensembl-vep-release-94/vep /usr/local/bin \
    && ln -s /usr/local/ensembl-vep-release-94/variant_recoder /usr/local/bin \
    && ln -s /usr/local/ensembl-vep-release-94/haplo /usr/local/bin \
    && ln -s /usr/local/ensembl-vep-release-94/filter_vep /usr/local/bin \
    && ln -s /usr/local/ensembl-vep-release-94/cpanfile /usr/local/bin \
    && ln -s /usr/local/ensembl-vep-release-94/convert_cache.pl /usr/local/bin \
    && ./INSTALL.pl -a a -l; exit 0

## Create user training
########
RUN useradd -r -s /bin/bash -U -m -d /home/training -p '' training

# Setup the user envirenment
########
ENV HOME /home/training
RUN chown -R training:training $HOME \
    && usermod -aG sudo,audio,video training \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR $HOME
USER training
