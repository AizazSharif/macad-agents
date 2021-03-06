FROM nvidia/cudagl:10.0-devel-ubuntu18.04
# Docker image for praveen-palanisamy/macad-agents
LABEL maintainer="Praveen Palanisamy <Praveen.Palanisamy@outlook.com>"

#ENV NO_PROXY="localhost, 127.0.0.1"
#ENV http_proxy=http://USER:PASSWORD@DOMAIN.com
#ENV https_proxy=https://USER:PASSWORd@DOMAIN.com:80
#ENV ftp_proxy=http://USER:PASSWORD@DOMAIN.com:80

RUN echo -e "\n**********************\nNVIDIA Driver Version\n**********************\n" && \
	cat /proc/driver/nvidia/version && \
	echo -e "\n**********************\nCUDA Version\n**********************\n" && \
	nvcc -V

ENV DEBIAN_FRONTEND=noninteractive

# Install some dependencies
RUN apt-get update && apt-get install -y \
		bc \
		build-essential \
		cmake \
		curl \
		g++ \
		gfortran \
		git \
		libffi-dev \
		libfreetype6-dev \
		libhdf5-dev \
		libjpeg-dev \
		liblcms2-dev \
		libopenblas-dev \
		liblapack-dev \
		libopenjp2-7 \
		libpng-dev \
		libssl-dev \
		libtiff5-dev \
		libwebp-dev \
		libzmq3-dev \
		nano \
		pkg-config \
		python-dev \
		software-properties-common \
		unzip \
		vim \
		wget \
		zlib1g-dev \
		qt5-default \
		libvtk6-dev \
		zlib1g-dev \
		libjpeg-dev \
		libwebp-dev \
		libpng-dev \
		libtiff5-dev \
		# libjasper-dev \ If reqd by OpenCV, sudo add-apt-repository “deb http://security.ubuntu.com/ubuntu xenial-security main” && sudo apt update && sudo apt install libjasper1 libjasper-dev
		libopenexr-dev \
		libgdal-dev \
		libdc1394-22-dev \
		libavcodec-dev \
		libavformat-dev \
		libswscale-dev \
		libtheora-dev \
		libvorbis-dev \
		libxvidcore-dev \
		libx264-dev \
		yasm \
		libopencore-amrnb-dev \
		libopencore-amrwb-dev \
		libv4l-dev \
		libxine2-dev \
		libtbb-dev \
		libeigen3-dev \
		python-dev \
		python-tk \
		python-numpy \
		python3-dev \
		python3-tk \
		python3-numpy \
		ant \
		default-jdk \
		doxygen \
	&& apt-get clean \
	&& apt-get autoremove \
	&& rm -rf /var/lib/apt/lists/*

# Setup conda and base pkgs
RUN	echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh \
    && wget \
        --quiet 'https://repo.continuum.io/archive/Anaconda3-5.2.0-Linux-x86_64.sh' \
        -O /tmp/anaconda.sh \
    && /bin/bash /tmp/anaconda.sh -b -p /opt/conda \
    && rm /tmp/anaconda.sh \
    && /opt/conda/bin/conda install -y \
        libgcc \
    && /opt/conda/bin/conda clean -y --all \
    && /opt/conda/bin/pip install \
        flatbuffers \
        cython==0.29.0 \
        numpy==1.15.4


ENV PATH "/opt/conda/bin:$PATH"

RUN conda install -y numpy
# The following is needed to support TensorFlow 1.14
RUN conda remove -y --force wrapt

RUN pip install -U pip && \
	pip install gym[atari] opencv-python-headless tensorflow-gpu==1.14 lz4 keras pytest-timeout smart_open tensorflow_probability && \
	pip install --upgrade bayesian-optimization hyperopt==0.1.2 ConfigSpace==0.4.10 sigopt nevergrad scikit-optimize hpbandster lightgbm xgboost && \
	pip install -U torch torchvision tabulate mlflow pytest-remotedata>=0.3.1 && \
	pip install ray==0.6.2 psutil ray[debug]==0.6.2 && \
	pip install macad-gym

# Download CARLA_0.9.4.tar.gz (1.1G)
RUN pip install gdown && \
	gdown --id 1p5qdXU4hVS2k5BOYSlEm7v7_ez3Et9bP --output ./CARLA_0.9.4.tar.gz
# Extract
RUN mkdir -p /home/software/CARLA && \
	tar --directory=/home/software/CARLA/ -xzf CARLA_0.9.4.tar.gz
# Set CARLA_SERVER path;
ENV CARLA_SERVER=/home/software/CARLA/CarlaUE4.sh
RUN chmod a+x /home/software/CARLA/CarlaUE4.sh
RUN chmod a+x /home/software/CARLA/CarlaUE4/Binaries/Linux/CarlaUE4
