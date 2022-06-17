
# DTIPlaygroundTools


## What is it?

This project builds tools which are used for DTIPlayground project.

These Softwares will be installed in dtiplayground-tools directory

- niral_utilities (ImageMath, Crop tools, ...)
- ResampleDTIlogEuclidean
- DTIProcess (dtiprocess, dtiaverage, dtiestim, ... )
- BRAINSTools (BRAINSFit)
- AtlasWerks (GreedyAtlas, ...)
- ANTs
- DTI-Reg
- MriWatcher
- ITKTransformTools
- DCMTK
- Trafic
- teem (unu, ...)

## Build environment

Following OS level library and tools needs to be installed before build (Refer to the dockerfiles/Dockerfile.centos7 for the detailed environment)

- python-devel
- freeglut-devel
- cmake 3.4 or above

## Build with CMake

```
  $ git clone https://github.com/NIRALUser/DTIPlaygroundTools.git
  $ mkdir DTIPlaygroundTools-build
  $ cd DTIPlaygroundTools-build
  $ cmake ../DTIPlaygroundTools
  $ make
```

Tools will be in DTIPlaygroundTools-install/dtiplayground-tools directory

## Build with Docker compose (Docker and compose required)

Note: Change user information in docker-compose.yml before run the script

```
$ cd dockerfiles
$ docker-compose run dtiplayground-build-centos7
```

The script will build the projects and generate `dist` directory containing distribution tarball.

## Change Log:

#### v0.0.1 (2022-05-03)

Initial commit

