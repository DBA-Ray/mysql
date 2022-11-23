USE sys;

DROP VIEW
IF
	EXISTS gr_member_routing_candidate_status;
CREATE OR REPLACE ALGORITHM = MERGE DEFINER = `root`@`localhost` SQL SECURITY DEFINER VIEW `sys`.`gr_member_routing_candidate_status` AS SELECT
IF
	(( `a`.`MEMBER_STATE` = 'ONLINE' ), 'YES', 'NO' ) AS `viable_candidate`,
IF
	((( SELECT `performance_schema`.`global_variables`.`VARIABLE_VALUE` FROM `performance_schema`.`global_variables` WHERE ( `performance_schema`.`global_variables`.`VARIABLE_NAME` = 'super_read_only' )) = 'ON' ), 'YES', 'NO' ) AS `read_only`,
	`b`.`COUNT_TRANSACTIONS_REMOTE_IN_APPLIER_QUEUE` AS `transactions_behind`,
	`b`.`COUNT_TRANSACTIONS_IN_QUEUE` AS `transactions_to_cert` 
FROM
	(
		`performance_schema`.`replication_group_members` `a`
		JOIN `performance_schema`.`replication_group_member_stats` `b` ON ((
				`a`.`MEMBER_ID` = `b`.`MEMBER_ID` 
			))) 
WHERE
	(
		`a`.`MEMBER_ID` = (
		SELECT
			`performance_schema`.`global_variables`.`VARIABLE_VALUE` 
		FROM
			`performance_schema`.`global_variables` 
	WHERE
	( `performance_schema`.`global_variables`.`VARIABLE_NAME` = 'server_uuid' )));

-- 不建议使用，当一个节点执行reset slave all时，会导致proxysql不可用