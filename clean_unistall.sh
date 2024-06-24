# Debian and Ubuntu
$ sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni kube*


# Debian and Ubuntu
$ sudo apt autoremove

2.3. Remove Related Files and Directories
For the most part, kubeadm reset takes care of deleting the relevant files. However, just to be on the safe side, we’ll remove some of the Kubernetes-specific files that might be left out:

$ rm -rf ~/.kube
$ rm -rf /etc/cni /etc/kubernetes rm -f /etc/apparmor.d/docker /etc/systemd/system/etcd*
$ rm -rf /var/lib/dockershim /var/lib/etcd /var/lib/kubelet \
         /var/lib/etcd2/ /var/run/kubernetes
Copy
2.4. Clear out the Firewall Tables and Rules
Usually, kubeadm reset clears the iptables rules. However, as a precaution, we’ll reset them manually. We start with flushing and deleting the filter table:

$ iptables -F && iptables -X
Copy
Next, we flush and delete the NAT (Network Address Translation) table:

$ iptables -t nat -F && iptables -t nat -X
Copy
Then, we flush and remove the chains and rules in the raw table:

$ iptables -t raw -F && iptables -t raw -X
Copy
Finally, we remove the chains and rules in the mangle table:

$ iptables -t mangle -F && iptables -t mangle -X
Copy
2.5. Optional: Docker
We can remove the Docker containers, images, and the docker group as well. However, it’s optional:

$ docker image prune -a
Copy
It removes all the unused Docker images that aren’t associated with any containers. Afterward, we restart the Docker service:

$ sudo systemctl restart docker
Copy
Next, we can uninstall Docker if we need to:

# Debian and Ubuntu
$ sudo apt purge docker-engine docker docker.io docker-ce docker-ce-cli containerd containerd.io runc --allow-change-held-packages



# Debian and Ubuntu
$ sudo apt autoremove

# Fedora and Red Hat
$ sudo dnf autoremove
Copy
Finally, let’s remove the docker group as well:

$ sudo groupdel docker


$ sudo systemctl reload-daemon
