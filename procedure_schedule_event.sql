-- use pipldb;-- 

use pipldb;
drop event if exists pipldb.turnFinishedAmaToMessage;

CREATE EVENT IF NOT EXISTS pipldb.turnFinishedAmaToMessage

ON SCHEDULE 
   EVERY 10 second
  
    
COMMENT 'invoking procedure that turns finished amas into messages'


DO call createMessageFromEndedAMA();
