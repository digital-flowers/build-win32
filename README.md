# build-win32

Build a libvips binary for 32-bit Windows. The resulting zip file includes all
necessary DLLs and EXEs.

### Build with docker

Docker will make a light-weight virtual machine containing all the
tools you need and build inside that. You won't need to install any
extra stuff on the host machine, and everything is automated.

First, install docker:

```
sudo apt-get install docker.io
```

On some Ubuntu installs, docker can fail to see DNS thanks to some interaction
with NetworkManager. If it can't download stuff, edit `/etc/default/docker`
and uncomment the line:

```
DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"
```

And restart docker.

Then pass the build instructions to the docker service. You have to run
this as root.

```
sudo ./build.sh 8.4 all
```

At the end of the build, the script will display the paths of all the
zip files it created, ready to be uploaded to the server. Be patient,
this process can take an hour, even on a powerful machine.

### Build with `jhbuild`

See the README in the 8.4 subdirectory for instructions for building
directly in `jhbuild`.

### TODO

- linux build needs to include all components that the win build has, so pdf,
  svg, gif etc. 

  maybe we should just include a good typelib? and Vips.py too? much simpler
  than trying to build a complete linux install in the container

- could turn on orc now

- try installing win32 python and running it under wine so we can run the test
  suite? who knows, it could work

	wget https://www.python.org/ftp/python/2.7.10/python-2.7.10.amd64.msi

  headless install

	wine msiexec /qn /i python-2.7.10.amd64.msi 

  does not set PATH, so to run, use:

	WINEPATH=c:/python27 wine python.exe test.py

  try

	WINEPATH="c:/python27;/home/john/GIT/build-win32/8.4/x/vips-dev-8.4.1/bin" GI_TYPELIB_PATH=/home/john/GIT/build-win32/8.4/x/vips-dev-8.4.1/lib/girepository-1.0 wine python test_all.py


