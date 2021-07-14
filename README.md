# Overview
Shell script and database to help track the status of IB/OPA ports on compute nodes.

There is nothing here that can't be obtained from the various infiniband troubleshooting tools:

https://linux.die.net/man/8/infiniband-diags

The purpose of this code is to put this information into a database that can be easily queried.

This is a quick and dirty project created in a couple of hours to help solve specific problems we're having with our IB fabric, so don't laugh too hard at the code.

## Missing File

You'll need to create a file called `credentials.source` that has the following format:

```
MyUSER="database_user"
MyPASS="database_password"
MyHOST="mysql_server_hostname"
```

## Ansible

We're running the following as a cron job every five minutes from a management server:

```
ansible -i /etc/ansible/agavehosts all -m shell -a "/path/to/script/fabric_monitor.sh"
ansible -i /etc/ansible/beegfs all -m shell -a "/path/to/script/fabric_monitor.sh"
```

## Usage Examples

What ports are not fully up and running?

```
fabricmon@monitordb [fabric_monitor]> select * from badports;
+---------------------+--------------------------+--------+------+------------+---------------------+--------------+----------+
| updatetime          | hostname                 | device | port | link_layer | rate                | phys_state   | state    |
+---------------------+--------------------------+--------+------+------------+---------------------+--------------+----------+
| 2021-07-13 18:45:19 | cg19-1.agave.rc.asu.edu  | mlx4_1 |    1 | InfiniBand | 56 Gb/sec (4X FDR)  | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:19 | cg19-10.agave.rc.asu.edu | mlx4_1 |    1 | InfiniBand | 56 Gb/sec (4X FDR)  | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:19 | cg19-11.agave.rc.asu.edu | mlx4_1 |    1 | InfiniBand | 56 Gb/sec (4X FDR)  | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:18 | cg19-2.agave.rc.asu.edu  | mlx4_1 |    1 | InfiniBand | 56 Gb/sec (4X FDR)  | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:18 | cg19-3.agave.rc.asu.edu  | mlx4_1 |    1 | InfiniBand | 56 Gb/sec (4X FDR)  | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:19 | cg19-4.agave.rc.asu.edu  | mlx4_1 |    1 | InfiniBand | 56 Gb/sec (4X FDR)  | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:19 | cg19-7.agave.rc.asu.edu  | mlx4_1 |    1 | InfiniBand | 56 Gb/sec (4X FDR)  | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:19 | cg19-8.agave.rc.asu.edu  | mlx4_1 |    1 | InfiniBand | 56 Gb/sec (4X FDR)  | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:19 | cg19-9.agave.rc.asu.edu  | mlx4_1 |    1 | InfiniBand | 56 Gb/sec (4X FDR)  | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:20 | cg20-11.agave.rc.asu.edu | mlx5_0 |    1 | InfiniBand | 56 Gb/sec (4X FDR)  | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:19 | cg20-7.agave.rc.asu.edu  | mlx5_0 |    1 | InfiniBand | 56 Gb/sec (4X FDR)  | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:20 | cg20-8.agave.rc.asu.edu  | mlx5_0 |    1 | InfiniBand | 56 Gb/sec (4X FDR)  | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:24 | cg30-9.agave.rc.asu.edu  | hfi1_0 |    1 | OmniPath   | 100 Gb/sec (4X EDR) | 9: <unknown> | 1: DOWN  |
| 2021-07-13 18:45:25 | cg31-2.agave.rc.asu.edu  | mlx5_0 |    1 | InfiniBand | 100 Gb/sec (4X EDR) | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:25 | cg31-3.agave.rc.asu.edu  | mlx5_0 |    1 | InfiniBand | 100 Gb/sec (4X EDR) | 5: LinkUp    | 3: ARMED |
| 2021-07-13 18:45:25 | cg31-4.agave.rc.asu.edu  | mlx5_0 |    1 | InfiniBand | 100 Gb/sec (4X EDR) | 5: LinkUp    | 2: INIT  |
| 2021-07-13 18:45:31 | gpu5-2.agave.rc.asu.edu  | mlx5_0 |    1 | InfiniBand | 10 Gb/sec (4X SDR)  | 3: Disabled  | 1: DOWN  |
| 2021-07-13 18:45:31 | s60-1.agave.rc.asu.edu   | mlx4_0 |    2 | InfiniBand | 10 Gb/sec (4X SDR)  | 2: Polling   | 1: DOWN  |
| 2021-07-13 18:45:31 | s65-1.agave.rc.asu.edu   | mlx4_0 |    2 | InfiniBand | 10 Gb/sec (4X SDR)  | 2: Polling   | 1: DOWN  |
| 2021-07-13 18:45:31 | s65-2.agave.rc.asu.edu   | mlx4_0 |    2 | InfiniBand | 10 Gb/sec (4X SDR)  | 2: Polling   | 1: DOWN  |
| 2021-07-13 18:45:31 | s65-3.agave.rc.asu.edu   | mlx4_0 |    2 | InfiniBand | 10 Gb/sec (4X SDR)  | 2: Polling   | 1: DOWN  |
| 2021-07-13 18:45:37 | s76-6.agave.rc.asu.edu   | hfi1_0 |    1 | OmniPath   | 100 Gb/sec (4X EDR) | 9: <unknown> | 1: DOWN  |
| 2021-07-13 18:45:32 | s76-7.agave.rc.asu.edu   | hfi1_0 |    1 | OmniPath   | 100 Gb/sec (4X EDR) | 2: Polling   | 1: DOWN  |
+---------------------+--------------------------+--------+------+------------+---------------------+--------------+----------+
```

Info on one of the hosts

```
fabricmon@monitordb [fabric_monitor]> select * from hosts limit 1\G
*************************** 1. row ***************************
         uuid: 00000000-0000-0000-0000-0025905ECF9A
     hostname: cg23-17.agave.rc.asu.edu
     osflavor: centos
    osversion: 7
centosversion: 7.9.2009
     oskernel: 3.10.0-1160.21.1.el7.x86_64
       vendor: SuperMacro
        model: big-bad-box
       serial: OU812
   infiniband: 0
     omnipath: 1
   updatetime: 1626227722
1 row in set (0.00 sec)
```

Info on one of the fabric devices

```
fabricmon@monitordb [fabric_monitor]> select * from devices limit 1\G
*************************** 1. row ***************************
      uuid: 00000000-0000-0000-0000-0025905ECF9A
    device: hfi1_0
  board_id: Intel Omni-Path Host Fabric Interface Adapter 100 Series
    fw_ver: 1.27.0
updatetime: 1626227722
```

Info on one of the ports
```
fabricmon@monitordb [fabric_monitor]> select * from ports limit 1\G
*************************** 1. row ***************************
      uuid: 00000000-0000-0000-0000-0025905ECF9A
    device: hfi1_0
      port: 1
       lid: 0xea
link_layer: OmniPath
phys_state: 5: LinkUp
      rate: 100 Gb/sec (4X EDR)
    sm_lid: 0x12
     state: 4: ACTIVE
updatetime: 1626228322
```
