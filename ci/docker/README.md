This directory includes scripts to build the docker container image used for
building flutter/plugins in our CI system (currently [Cirrus](cirrus-ci.org)).

In order to run the scripts, you have to setup `docker` and `gcloud`. Please
refer to the [internal flutter team doc](go/flutter-team) for how to setup in a
Google internal environment.

After setup,
* edit `Dockerfile` to change how the container image is built.
* run `./build_docker.sh` to build the container image.
* run `./push_docker.sh` to push the image to google cloud registry. This will
  affect our CI tests.

You can see uploaded Docker containers and their tags on the
[Google Container Registry](https://pantheon.corp.google.com/gcr/images/flutter-cirrus/GLOBAL/build-plugins-image)
console.

Currently, the only tagged container is `latest`, and that's the tag that is
applied by the scripts in this directory by default, and the one referenced in
the [`.cirrus.yml` file](../../.cirrus.yml).
