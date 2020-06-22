USE sys;

DROP VIEW
IF
	EXISTS gr_member_routing_candidate_status;
CREATE ALGORITHM = MERGE DEFINER = `root` @`localhost` SQL SECURITY DEFINER VIEW `gr_member_routing_candidate_status` AS SELECT
IF
	( a.MEMBER_STATE = 'ONLINE', 'YES', 'NO' ) AS `viable_candidate`,
IF
	(( SELECT variable_value FROM `performance_schema`.global_variables WHERE Variable_name = 'super_read_only' )='ON', 'YES', 'NO' ) AS `read_only`,(
	SELECT
		( SELECT Received_transaction_set FROM PERFORMANCE_SCHEMA.replication_connection_status WHERE Channel_name = 'group_replication_applier' )-(
		SELECT
			variable_value
		FROM
			`performance_schema`.global_variables
		WHERE
			Variable_name = 'gtid_executed'
		)) AS `transactions_behind`,
	b.`COUNT_TRANSACTIONS_IN_QUEUE` AS `transactions_to_cert`
FROM
	`performance_schema`.`replication_group_members` a
	JOIN `performance_schema`.`replication_group_member_stats` b ON a.member_id = b.member_id
WHERE
	a.member_id =(
	SELECT
		`VARIABLE_VALUE`
	FROM
		`performance_schema`.`global_variables`
	WHERE
	`VARIABLE_NAME` = 'server_uuid'
	);