use pipldb;
-- use pipldb_dev;
drop procedure if exists createMessageFromEndedAMA;
delimiter // 
create procedure createMessageFromEndedAMA()
BEGIN
    DECLARE done INT DEFAULT FALSE;

    declare id bigint(11);
	declare caption varchar(50);
    declare proof_vid_url varchar	(300);
	declare thumb_url varchar(500);
	declare creation_date bigint(11);
	declare scheduled_date bigint(11);
	declare duration_in_hours double;
	declare replied_count int(11);
	declare asked_count int(11);
	declare owner_id bigint(11);
	declare exists_as_message bool;
	declare count int(11);
    declare debug_totalConvertedAmas int(11);
    declare reports text;
    declare width int(4);
    declare height int(4);
    
    DECLARE curs CURSOR FOR SELECT * FROM pipldb.amas where amas.scheduled_date + amas.duration_in_hours*60*60*1000<= unix_timestamp()*1000 and amas.exists_as_message=false;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    select 0 into @debug_totalConvertedAmas;

    SELECT count(*) into @count FROM pipldb.amas where amas.scheduled_date + amas.duration_in_hours*60*60*1000<= unix_timestamp()*1000 and amas.exists_as_message=false;
	select @count;
	set debug_totalConvertedAmas=@debug_totalConvertedAmas+@count;

    if @count > 0 
		then 

		OPEN curs;
		read_loop: LOOP
		   fetch curs into id,caption,proof_vid_url,thumb_url,creation_date,scheduled_date,duration_in_hours,replied_count,asked_count,exists_as_message,reports,width,height,owner_id;
		   IF done THEN
				LEAVE read_loop;
			END IF;
            
			update amas set amas.exists_as_message=true where amas.id=id;
			INSERT INTO `pipldb`.`messages` (`owner_id`,`content`,`link`,`type`,`image_url`,`video_url`,`width`,`height`,`date_created`,`upvote_count`,`hide_from_feed`,`smile_count`,
			`fire_count`,`kiss_count`,`sad_count`) VALUES (owner_id,caption,null,3,thumb_url,proof_vid_url,width,height,scheduled_date + duration_in_hours*60*60*1000,id,false,0,0,asked_count,replied_count);
		END LOOP;
		CLOSE curs;
		CALL mysql.lambda_async(
	       'YOUR_LAMBDA_ARN',
        END if;
END;