/*
Lee Reynolds <Lee.Reynolds@asu.edu>
ASU Research Computing
*/

drop database if exists fabric_monitor;

create database fabric_monitor;

use fabric_monitor;

drop table if exists hosts;
drop table if exists devices;
drop table if exists ports;

create table hosts
(
	uuid char(40) not null,
	hostname varchar(40) not null,
	osflavor varchar(40) not null,
	osversion varchar(40) not null,
	centosversion varchar(40) not null,
	oskernel varchar(80) not null,
	vendor varchar(40) not null,
	model varchar(40) not null,
	serial varchar(80) not null,
	infiniband BOOLEAN not null,
	omnipath BOOLEAN not null,
	updatetime int unsigned not null,
	primary key ( uuid )
);

create table devices
(
	uuid char(40) not null,
	device char(20) not null,
	board_id varchar(100) not null,
	fw_ver varchar(20) not null,
	hca_type varchar(40) not null,
	updatetime int unsigned not null,
	primary key ( uuid, device )
);

create table ports
(
	uuid char(40) not null,
	device varchar(40) not null,
	port int unsigned not null,
	lid varchar(20) not null,
	link_layer varchar(20) not null,
	phys_state varchar(20) not null,
	rate varchar(40) not null,
	sm_lid varchar(20) not null,
	state varchar(20) not null,
	updatetime int unsigned not null,
	primary key (uuid,device,port)
);



