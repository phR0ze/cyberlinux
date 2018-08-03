# cyberlinux Kubernetes Profile
<img align="left" width="48" height="48" src="https://raw.githubusercontent.com/phR0ze/cyberlinux/master/art/logo_256x256.png">

The [kubernetes profile](kubernetes.yml) was developed as a slimmed down shell environment with
Kubernetes dependencies baked in.  It includes ***kubectl***, ***kubelet***, ***kubeadm***,
***docker*** and ***helm*** to easily and quickly setup a K8s cluster.

### Disclaimer
***cyberlinux*** comes with absolutely no guarantees or support of any kind. It is to be used at
your own risk.  Any damages, issues, losses or problems caused by the use of ***cyberlinux*** are
strictly the responsiblity of the user and not the developer/creator of ***cyberlinux***.

### Table of Contents
* [Kubernetes Deployment](#kubernetes-deployment)

## Kubernetes Deployment <a name="kubernetes-deployment"/></a>
![K8snode](../doc/images/k8snode-virtualbox.png)

```bash
# Deploys a k8snode with ip address of 192.168.56.10
sudo ./reduce deploy k8snode 10 -p k8snode
```
