# build-gitea

A dockerfile to build gitea https://gitea.io/ for Debian, Ubuntu etc.

[Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) or [Podman](https://podman.io/getting-started/installation.html) (preferred) is a prerequisite, but any old version will do (we are not doing anything fancy).

This only builds the binary, but given that Golang application by design do not have runtime depedencies it is
perfectly fine to copy the resulting binary to `/usr/local/bin` and be done with it.

Update `VERSION` inside `Makefile` to a more recent stable version when the time comes ;) and send me the pull request if
I miss it. Similarly update `GO_REL` to a more recent Golang release at the appropriate time.

The downside of not having any runtime dependencies is that the binary should be rebuilt whenever **any** of its source dependencies change.
It is a good thing that Golang binaries build really quickly.


```
make
sudo cp dist/gitea /usr/local/bin/
sudo chown root:root /usr/local/bin/gitea
```

#### NOTE

The actual build is running inside `docker build` (and not *docker run*, as one might expect). To delete build files, do `docker image rm build-gitea-$USER` afterwards.

Enjoy!


#### PS

I am not the best person to answer build question, I simply followed the instructions at https://docs.gitea.io/en-us/install-from-source/

#### PS2

There is also https://github.com/Bronek/build-hugo
