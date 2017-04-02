FROM ubuntu:latest
RUN apt-get update --fix-missing \
  && apt-get install -y --no-install-recommends \
  # These are common dependencies
  ca-certificates \
  git \
  # These install your conda based dev environment
  bzip2 \
  gcc \
  libglib2.0-0 libxext6 libsm6 libxrender1 \
  make \
  mercurial \
  subversion \
  wget \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8 
ENV LANGUAGE=C.UTF-8

RUN cd /tmp && \
  mkdir -p $CONDA_DIR && \
  wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh && \
  echo "c59b3dd3cad550ac7596e0d599b91e75d88826db132e4146030ef471bb434e9a *Miniconda3-4.2.12-Linux-x86_64.sh" | sha256sum -c - && \
  /bin/bash Miniconda3-4.2.12-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
  rm Miniconda3-4.2.12-Linux-x86_64.sh && \
  $CONDA_DIR/bin/conda config --system --add channels conda-forge && \
  $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
  conda clean -tipsy

ADD . /srv/notebook-server/
RUN conda env update --file=/srv/notebook-server/requirements/environment.yml
RUN pip install --no-cache-dir -r /srv/notebook-server/requirements/requirements.txt
RUN /bin/bash /srv/notebook-server/install.sh
WORKDIR /srv/notebook-server/
CMD jupyter notebook --port=8888 --ip=0.0.0.0 
  
