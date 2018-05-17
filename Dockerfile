# (ideally) minimal pyspark/jupyter notebook

FROM tmehrarh/spark-analytics:2.3.0

USER root

ENV LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    PYTHONIOENCODING=UTF-8 \
    SPARK_HOME=/opt/spark \
    NB_USER=nbuser \
    NB_UID=1011 \
    CONDA_DIR=/opt/conda \
    HADOOP_HOME=/opt/hadoop-2.7.6 \
    HOME=/home/nbuser \
    JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.x86_64/jre \
    PATH=/opt/conda/bin:/opt/app-root/bin:/opt/hadoop-2.7.6/bin:/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.x86_64/jre/bin:$PATH \
    HOME=/home/nbuser

RUN export PATH=$PATH

ADD fix-permissions.sh /usr/local/bin/fix-permissions.sh

RUN mkdir -p /opt/hadoop-2.7.6 && \ 
    chmod +x /usr/local/bin/fix-permissions.sh

RUN wget http://www-us.apache.org/dist/hadoop/common/hadoop-2.7.6/hadoop-2.7.6.tar.gz \
    && tar -xzvf hadoop-2.7.6.tar.gz -C /opt

RUN yum install -y curl wget java-headless bzip2 gnupg2 sqlite3 which \
    && yum clean all -y \
    && cd /tmp \
    && wget -q https://repo.continuum.io/miniconda/Miniconda3-4.3.31-Linux-x86_64.sh \
    && bash Miniconda3-4.3.31-Linux-x86_64.sh -b -p $CONDA_DIR \
    && rm Miniconda3-4.3.31-Linux-x86_64.sh \
    && yum install -y gcc gcc-c++ glibc-devel \
#   && $CONDA_DIR/bin/conda config --set ssl_verify false \
    && $CONDA_DIR/bin/conda install -c conda-forge 'jupyterhub=0.8.1' \
    && $CONDA_DIR/bin/conda install --quiet --yes 'nomkl' jupyter 'notebook=5.4.1' \
        'jupyterlab=0.32.0' \
        'ipywidgets=7.0*' \
        'pandas=0.19*' \
        'matplotlib=2.0*' \
        'scipy=0.19*' \
        'seaborn=0.7*' \
        'scikit-learn=0.18*' \
        'protobuf=3.*' \
    && pip install widgetsnbextension \
    && yum erase -y gcc gcc-c++ glibc-devel \
    && yum clean all -y \
    && rm -rf /root/.npm \
    && rm -rf /root/.cache \
    && rm -rf /root/.config \
    && rm -rf /root/.local \
    && rm -rf /root/tmp \
    && useradd -m -s /bin/bash -N -u $NB_UID $NB_USER \
    && usermod -g root $NB_USER \
    && chown -R $NB_USER $CONDA_DIR \
    && conda remove --quiet --yes --force qt pyqt \
    && conda remove --quiet --yes --force --feature mkl ; conda clean -tipsy


# Add a notebook profile.

RUN mkdir /notebooks && chown $NB_UID:root /notebooks && chmod 1777 /notebooks

EXPOSE 8888

RUN mkdir -p -m 700 /home/$NB_USER/.jupyter/ && \
    echo "c.NotebookApp.ip = '*'" >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.notebook_dir = '/notebooks'" >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py && \
    chown -R $NB_UID:root /home/$NB_USER && \
    chmod g+rwX,o+rX -R /home/$NB_USER

LABEL io.k8s.description="PySpark Jupyter Notebook." \
      io.k8s.display-name="PySpark Jupyter Notebook." \
      io.openshift.expose-services="8888:http"

ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
#RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 0527A9B7 && gpg --verify /tini.asc

ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

WORKDIR /notebooks
ENTRYPOINT ["tini", "--"]

CMD ["/entrypoint", "/usr/local/bin/start.sh"]

USER $NB_UID
