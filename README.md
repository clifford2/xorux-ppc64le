# XoruX Docker Image

This is Dockerfile for building of [XoruX](https://www.xorux.com) applications - [LPAR2RRD](https://www.lpar2rrd.com) & [STOR2RRD](https://www.stor2rrd.com) for **ppc64le** systems.

Using source code from <https://github.com/XoruX/apps-docker>,
with modified `Dockerfile`.

Usage instructions: <https://www.lpar2rrd.com/docker.php>

## Versions

Contains LPAR2RRD version 6.20 and STOR2RRD version 2.81
(equivalent to XoruX release [2.70](https://github.com/XoruX/apps-docker/releases/tag/2.70)).

## My Modifications

Changes from the original code:

- Removed `sshd`: Access the container with `docker exec` instead.
- No password set for `lpar2rrd` user
- Increased stack limit
