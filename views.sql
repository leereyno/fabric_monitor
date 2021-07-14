/*
Lee Reynolds <Lee.Reynolds@asu.edu>
ASU Research Computing
*/

use fabric_monitor;

drop view if exists combined;
drop view if exists badports;

create view combined as

	select
		hosts.uuid as uuid,
		hosts.hostname,
		hosts.osflavor,
		hosts.osversion,
		hosts.centosversion,
		hosts.oskernel,
		hosts.vendor,
		hosts.model,
		hosts.serial,
		hosts.infiniband,
		hosts.omnipath,
		devices.device,
		devices.board_id,
		devices.fw_ver,
		ports.port,
		ports.lid,
		ports.link_layer,
		ports.phys_state,
		ports.rate,
		ports.sm_lid,
		ports.state,
		from_unixtime(hosts.updatetime) as updatetime
	from
		hosts, devices, ports
	where
		hosts.uuid = devices.uuid
	and
		devices.uuid = ports.uuid
	and
		devices.device = ports.device;

create view badports as

	select
		updatetime,
		hostname,
		device,
		port,
		link_layer,
		rate,
		phys_state,
		state 
	from 
		combined 
	where 
		link_layer !='Ethernet'
	and
		(phys_state != '5: LinkUp' or state != '4: ACTIVE')
	order by hostname;