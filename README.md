[![Build status](https://travis-ci.org/radanalyticsio/base-notebook.svg?branch=master)](https://travis-ci.org/radanalyticsio/base-notebook)
[![Docker build](https://img.shields.io/docker/automated/radanalyticsio/base-notebook.svg)](https://hub.docker.com/r/radanalyticsio/base-notebook)
[![Layers info](https://images.microbadger.com/badges/image/radanalyticsio/base-notebook.svg)](https://microbadger.com/images/radanalyticsio/base-notebook)

# base-notebook-py36

This is a container image intended to make it easy to run Jupyter notebooks with python 3.6 with Apache Spark 2.3.0 on OpenShift. 
This image extends from the Apache Spark 2.3.0 image that is built from this repository at

## Usage

Build the image using the provided Dockerfile
docker build -f Dockerfile -t base-notebook-py36 .
docker tag <imageid> tmehrarh/base-notebook-py36:latest
docker push tmehrarh/base-notebook-py36:latest
  
## Notes

Make sure that this notebook image is running the same version of Spark as the external cluster you want to connect it to.

## Credits

This image was initially based on [Graham Dumpleton's images](https://github.com/getwarped/jupyter-stacks), which have some additional functionality (notably s2i support) that we'd like to incorporate in the future.
