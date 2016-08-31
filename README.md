# Corosync/Pacemaker

Corosync and Pacemaker is a high availability cluster solution with corosync working as the
messaging layer and pacemaker as the resorce manager.

This role installed corosync and pacemaker to a group of nodes named `pacemaker-nodes`, which must
consist of at least two resource nodes and one witness node, or such that the combination of
resource and witness nodes is an odd number. This role only sets up the HA layer, it does not
configure any resources, except for some *hopefully* sane global defaults. For an example of such,
see `ig/deploy/infra_routers` for the `router-vip` role.

By default, the role configures the cluster to run in multicast mode and requires all nodes to be
online and join the cluster before it can be configured. Corosync can use the redundant ring
protocol for redundant communication, but currently the role only configures a single ring.

## Example Playbook

This example is an excerpt from `ig/deploy/infra_routers`

    - name: Install Pacemaker and configure VIPs
      hosts: pacemaker-nodes
      roles:
        - { role: pacemaker, tags: ['pacemaker'] }
        - { role: router-vip, tags: ['vip'] }
      tags:
        - highavailability

## Requirements

### Inventory

This role requires the use of the inventory group `pacemaker-nodes`

    [pacemaker-nodes]
    router1.vagrant
    router2.vagrant
    router-witness.vagrant

### Variables

**Default Variables**:
* `pacemaker_resource_stickiness`: Integer value, used to associate a "cost" to moving resources.
* `pacemaker_migration_threshold`: Integer value, when a node fail count passes this value, resources are banned from this node
* `pacemaker_mode`: Used to control the cluster membership mechanism of either `multicast`(default) or `unicast`
* `pacemaker_mcastport`: Which port to use for broadcast traffic

**Required**:
* `environment_name`: This is used to fine the `authkey` file used for encrypted communication, stored in the deploy at `files/<environment_name>/authkey`
* `pacemaker_cluster_name`: Used by corosync to name the cluster
* `pacemaker_bindaddr`: Address used by the node to join the cluster
* `pacemaker_mcastaddr`: Specify the multicast address, choose a free IP from the 239.192.0.0/24 range. See [RFC2365: Section 6.2](https://tools.ietf.org/html/rfc2365#section-6.2). *Only used in multicast mode*
* `pacemaker_nodeid`: Interger value, used to uniquely identify a node. *Only used in unicast mode*

### Encrypted communication

*Coming Soon*
