# concourse-worker

A packer file for [Concourse](https://concourse-ci.org/) workers.

## Description

* Based on Fedora 33 and Concourse 7.0.0
* Disables cgroups v2
* Re-enables RSA keys in OpenSSH to allow packer to work via cloud-init

## Environment

* `HCLOUD_TOKEN` is required if you use the included Hetzner Cloud source.

## Configuration

* Set the Concourse web IP in `files/concourse-worker.env` (`CONCOURSE_TSA_HOST`). If you use HA, use an internal load balancer.
* Replace `files/tsa_host_key.pub` with your own TSA public key.

## Building

```
packer build .
```