# XoruX Docker Image

This is Dockerfile for building of [XoruX](https://www.xorux.com) applications - [LPAR2RRD](http://www.lpar2rrd.com) & [STOR2RRD](http://www.stor2rrd.com) for **ppc64le** systems.

Using source code from <https://github.com/XoruX/apps-docker>,
with modified `Dockerfile`.

Usage instructions: <https://www.lpar2rrd.com/docker.php>

## My Modifications

Changes from the original code:

- Removed `sshd`: Access the container with `docker exec` instead.
- No password set for `lpar2rrd` user
- Increased stack limit
