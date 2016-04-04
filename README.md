# Gemini

Gemini is an open source cluster manager responsible for deploying, managing, and maintaining clustering systems.

Gemini intends on supporting multiple clustering systems such as [Kubernetes](http://kubernetes.io/), [Apache Mesos](http://mesos.apache.org/), [Docker Swarm](https://www.docker.com/products/docker-swarm), and others. Currently, Gemini supports the following cluster formation:

* **Cluster Type**: [Kubernetes](http://kubernetes.io/)
* **Cluster OS**: [CoreOS](https://coreos.com/)
* **Cluster Target**: BareMetal | [Vagrant](https://www.vagrantup.com/)

Gemini includes abstractions for grouping clusters in loosely and tightly coupled formations, and provides mechanisms for clusters to communicate with each other in familiar ways.

The key features of Gemini are:

* **simple**: install, interfaces, operations, integration
* **lean**: lightweight, accessible
* **portable**: public, private, hybrid, multi-cloud
* **extensible**: modular, pluggable, composable

Gemini builds upon best-of-breed open source technologies.

<hr>

### Gemini can run anywhere!
However, the initial release supports bare metal and vagrant deployments.  If you make it work on other infrastructure, please let us know and contribute instructions/code.

### Gemini is NOT ready for Production!
Gemini will not be ready to serve your production workloads until a 1.0 release (TBD).

## Documentation

* Use the [Vagrant Setup Guide](vagrant/README.md) if you're interested in developing Gemini or just play with the technology.
* Use the [Installation Guide](docs/install/README.md) if you are interested in deploying Gemini to bare metal servers.
* Use the [Design Documentation](docs/design) if you are interested in learning more about the design details of Gemini.
* If you are planning to contribute to the project, review the [contributor guidelines](CONTRIBUTING.md).

### Code of conduct

Participation in the Gemini community is governed by the [Gemini Code of Conduct](code-of-conduct.md).

### Support

Please use the following resources to get support or create a [GitHub Issue](https://github.com/gemini-project/gemini/issues):

-       Website: https://www.gemin.io (coming soon)
-       Slack: gemini-project.slack.com
-       Mailing list: [Google Groups](https://groups.google.com/group/geminio)
