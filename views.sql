/*
Lee Reynolds <Lee.Reynolds@asu.edu>
ASU Research Computing
*/

use fabric_monitor;

drop view if exists combined;
drop view if exists badports;
drop view if exists fw_check;

/* DENORMALIZED VIEW OF SYSTEM DATA */

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
		devices.hca_type,
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

/* BAD PORTS */

create view badports as

	select
		updatetime,
		hostname,
		device,
		hca_type,
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

/* FIRMWARE CHECK */

create view fw_check as

	select
		combined.hostname,
		 combined.device,
		 combined.board_id,
		 combined.fw_ver as loaded_fw,
		 latest_fw.fw_ver as latest_fw,
		 combined.updatetime
	from
		combined
	inner join latest_fw
		on combined.board_id = latest_fw.board_id and combined.fw_ver != latest_fw.fw_ver;


