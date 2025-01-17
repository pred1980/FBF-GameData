<?php

//require_once 'Zend/Db/Table/Abstract.php';

class Default_Model_Index extends Zend_Db_Table_Abstract {

    CONST GAMESTATE_END = 16;
    
    /**
     * The default table name
    */
    protected $_name = '???';
    protected $_db;

    public function __construct()
    {
        $this->_db = Zend_Registry::get('ghostpp');
    }

    public function getGhostData()
    {

    }

    public function getGameList()
    {
        $select = $this->_db->select('*')
            ->from('gamelist');
        $result = $this->_db->query($select)->fetchAll(Zend_Db::FETCH_ASSOC);
        if (!$result) {
            $result = array();
        }
        return new ArrayObject($result);
    }
    
    public function getGames($gamestate = null)
    {
        $select = $this->_db->select('*')
        	->from('games');
        if (null !== $gamestate) {
            $select->where('gamestate = ?', $gamestate);
        }
        $result = $this->_db->query($select)->fetchAll(Zend_Db::FETCH_ASSOC);
        if (!result) {
            $result = array();
        }
        return new ArrayObject($result);
    }


    # gametrack collects information based on the latest games
    # specifically, for every player (name-realm combination), it maintains:
    #  * the last ten bots that the player was seen in
    #  * the last ten games that the player was seen in
    #  * averagy stay percentage
    #  * total number of games
    #  * time user was first seen
    #  * time user was last seen
    # the bots and games are based on games.botid and games.id respectively
    #  additionally, they are both stored as comma-delimited strings
    #  to retrieve an array of ID integers, use explode(',', $str)

    # it is recommended to set this up as a cronjob every five minutes:
    #    */5 * * * * cd /path/to/gametrack/ && php gametrack.php > /dev/null

    # BEGIN CONFIGURATION
    public function getGameTrack(){

        $db_name = "ghost";
        $db_host = "localhost";
        $db_username = "ghost";
        $db_password = "";

        # END CONFIGURATION

        function escape($str) {
        	return mysql_real_escape_string($str);
        }

        echo "Connecting to database\n";

        mysql_connect($db_host, $db_username, $db_password);
        mysql_select_db($db_name);

        # create table if not already there
        echo "Creating table if not exists\n";
        mysql_query("CREATE TABLE IF NOT EXISTS gametrack (name VARCHAR(15), realm VARCHAR(100), bots VARCHAR(40), lastgames VARCHAR(100), total_leftpercent DOUBLE, num_leftpercent INT, num_games INT, time_created DATETIME, time_active DATETIME, KEY name (name), KEY realm (realm))") or die(mysql_error());

        # read the next player from file
        echo "Detecting next player\n";
        $next_player = 1;
        $filename = "next_player.txt";

        if(file_exists($filename) && is_readable($filename)) {
        	$fh = fopen($filename, 'r');
        	$next_player = intval(trim(fgets($fh)));
        	fclose($fh);
        }

        echo "Detected next player: $next_player\n";

        # get the next 5000 players
        echo "Reading next 5000 players\n";
        $result = mysql_query("SELECT gameplayers.botid, name, spoofedrealm, gameid, gameplayers.id, (`left`/duration) FROM gameplayers LEFT JOIN games ON games.id = gameid WHERE gameplayers.id >= '$next_player' ORDER BY gameplayers.id LIMIT 5000") or die(mysql_error());
        echo "Got " . mysql_num_rows($result) . " players\n";

        while($row = mysql_fetch_array($result)) {
        	$botid = intval($row[0]);
        	$name = escape($row[1]);
        	$realm = escape($row[2]);
        	$gameid = escape($row[3]);
        	$leftpercent = escape($row[5]);

        	# see if this player already has an entry, and retrieve if there is
        	$checkResult = mysql_query("SELECT bots, lastgames FROM gametrack WHERE name = '$name' AND realm = '$realm'") or die(mysql_error());

        	if($checkRow = mysql_fetch_array($checkResult)) {
        	# update bots and lastgames shifting-window arrays
        	$bots = explode(',', $checkRow[0]);
        	$lastgames = explode(',', $checkRow[1]);

        	if(in_array($botid, $bots)) {
        	$bots = array_diff($bots, array($botid));
        	}

        	$bots[] = $botid;
        	$lastgames[] = $gameid;

        	if(count($bots) > 10) {
        	array_shift($bots);
        	}

        	if(count($lastgames) > 10) {
        	array_shift($lastgames);
        	}

        	$botString = escape(implode(',', $bots));
        	$lastString = escape(implode(',', $lastgames));
        	mysql_query("UPDATE gametrack SET bots = '$botString', lastgames = '$lastString', total_leftpercent = total_leftpercent + '$leftpercent', num_leftpercent = num_leftpercent + 1, num_games = num_games + 1, time_active = NOW() WHERE name = '$name' AND realm = '$realm'") or die(mysql_error());
        	} else {
        	$botString = escape($botid);
        	$lastString = escape($gameid);
        	mysql_query("INSERT INTO gametrack (name, realm, bots, lastgames, total_leftpercent, num_leftpercent, num_games, time_created, time_active) VALUES ('$name', '$realm', '$botString', '$lastString', '$leftpercent', '1', '1', NOW(), NOW())") or die(mysql_error());
        	}

        	$next_player = $row[4] + 1;
        	}

        	$fh = fopen($filename, 'w');
        	fwrite($fh, $next_player . "\n");

    }

    public function getGameOfList(){
        mysql_connect("127.0.0.1:3306", "root", "password");
        mysql_select_db("ghost");
        $result = mysql_query("SELECT * FROM gamelist");
        while($row = mysql_fetch_array($result))
        {
        	if(!empty($row['gamename']))
        	{
        		echo "<br>There are " . $row['totalplayers'] . " players in " . $row['totalgames'] . " games.";
        		echo "<br>" . $row['id'] . ". " . $row['gamename'] . " (" . $row['slotstaken'] . "/" . $row['slotstotal'] . ") [TempOwner]: " . $row['ownername'] . " [Creator]: " . $row['creatorname'] . "<br>";
        		echo "Players in Lobby:";

        		$array = explode("\t", $row['usernames']);

        		echo '<table cellspacing="0" cellpadding="2" border="1">';

        		for($i = 0; $i < count($array) - 2; $i += 3)
        		{
        			$username = $array[$i];
        			$ping = $array[$i + 2];

        			if(!empty($username))
        				echo '<tr><td>' , $username , '</td><td>' , $ping , '</td></tr>';
        		}
        		echo '</table>';
        	}
        }
    }

    # logcron is a basic alternative to log_rotate that is much easier to setup
    # it will simply move your .log files to .log_
    # this way, old log files that are no longer important are overwritten

    # for advanced log rotation, we recommend logrotate (man logrotate)

    # it is recommended to set this up as a cronjob every day
    # this means that logs over a day old may be deleted, and logs two days old are sure to be deleted
    #   0 0 * * * cd /path/to/logcron/ && php logcron.php > /dev/null
    public function logCron(){
        # BEGIN CONFIGURATION

        # array of directories to scan for log files
        $paths = array("/path/to/ghost-battlenet", "/path/to/ghost-pvpgn");

        # END CONFIGURATION

        foreach($paths as $path) {
        	if(file_exists($path)) {
        		$it = new DirectoryIterator($path);

        		foreach($it as $file) {
        			if($it->isFile() && !$it->isDot() && substr($file, -4) == ".log") {
        				rename($path . '/' . $file, $path . '/' . $file . "_");
        			}
        		}
        	}
        }
    }

    # status will check the status of your servers and notify you of any problems
    # it checks:
    #  * whether your bots recently disconnected from battle.net
    #  * whether your bots are running at all
    #  * whether your bots are hosting
    #  * whether your web servers are responsive
    # the bot will be identified based on the name of the log file
    #  ex: ghost_blah.log will be identified as "ghost_blah"

    # it is recommended to set this up as a cronjob every ten minutes:
    #    */10 * * * * cd /path/to/status/ && php status.php > /dev/null
    public function getStatus(){
        # BEGIN CONFIGURATION

        # smtp configuration
        $smtp_host = "smtp.example.com";
        $smtp_port = 25;
        $smtp_username = "statusbot";
        $smtp_password = "status";

        # email configuration
        $from_address = "statusbot@example.com";
        $to_address = "status-list@example.com";

        # web configuration (include trailing slash)
        $web_path = '/var/www/status/';

        # ghost configuration
        # this is array of directories where log files may be found
        # trailing slash is optional
        # note: it is recommended to keep all files in one ghost directory
        #  and use different configuration files to maintain different bots
        $paths = array("/path/to/ghost-battlenet/", "/path/to/ghost-pvpgn/");

        # web pages to check whether are up
        # each page must have the status/test.txt file
        #  the contents of this should be one character, '1'
        # for example, for "target.com" below, we will ping <http://target.com/status/test.txt>
        $targets = array('example.com', 's1.example.com', 's2.example.com');

        # whether we should email status results using SMTP and mail configuration above
        $doEmail = true;

        # whether we should update the status website
        $doWeb = true;

        # END CONFIGURATION

        $knownErrors = array(); //stores errors from file
        $errors = array(); //stores errors we find
        $botStatus = array(); //stores status array (status integer, error messages array) for each bot

        # read error data from file

        if(file_exists("status.txt")) {
        	$handle = fopen("status.txt", "r");

        	if($handle) {
        		while(($buffer = fgets($handle, 4096)) !== false) {
        			$knownErrors[] = trim($buffer);
        		}

        		fclose($handle);
        	}
        }

        # get hostname
        $hostname = exec("hostname");

        # loop based on log files

        foreach($paths as $path) {
        	if(file_exists($path)) {
        		$it = new DirectoryIterator($path);

        		foreach($it as $file) {
        			if($it->isFile() && !$it->isDot() && substr($file, -4) == ".log") {
        				$botname = substr($file, 0, -4);
        				$thisStatus = 0; //0 is neutral (maybe not in lobby)
        				$thisError = array(); //stores error messages for just this bot
        				$filename = $path . '/' . $file;

        				$output_array = array();
        				$lastline = exec("tail -n 1000 " . escapeshellarg($filename), $output_array);

        				# scan output_array for interesting things
        				foreach($output_array as $line) {
        				# check if we disconnected from battle.net
        					if(strpos($line, 'disconnected from battle.net') !== false) {
        					$posBegin = strpos($line, 'BNET: ');

        							if($posBegin !== false) {
        							$realmBegin = $posBegin + 6;
        							$posEnd = strpos($line, ']', $posBegin);

        							if($posEnd !== false) {
        							$realm = substr($line, $realmBegin, $posEnd - $realmBegin);

        							if($realm != "GCloud") {
        							$error = "$botname has disconnected from bnet/$realm";

        							//need to ensure this error wasn't added
        							// because this could occur multiple times
        							if(!in_array($error, $errors)) {
        							$errors[] = $error;
        							$thisError[] = $error;
        							}
        							}
        							}
        							}
        							}

        							# check if user has joined game recently
        							if(strpos($line, 'joined the game') !== false) {
        							$thisStatus = 1;
        					}
        					}

        						# check last line to see if the bot is still running
        						$posBegin = strpos($lastline, '[');

        						if($posBegin !== false) {
        						$posEnd = strpos($lastline, ']', $posBegin);

        						if($posEnd !== false) {
        						$strTime = substr($lastline, $posBegin + 1, $posEnd - $posBegin - 1);
        						$time = strtotime($strTime);

        						if(time() - $time > 1200) {
        						$error = "$botname does not appear to be running";
        						$thisStatus = -1;

        						$errors[] = $error;
        						$thisError[] = $error;
        						}
        						}
        						}

        						$botStatus[$botname] = array($thisStatus, $thisError);
        				}
        				}
        				}
        				}

        				# write bot status to web
        						$handle = fopen($web_path . 'index.html', 'w') or die('failed to write status');
fwrite($handle, '<html><body><table><tr><th>Bot</th><th>Status</th><th>Error</th></tr>');

foreach($botStatus as $botname => $statusArray) {
        $statusString = '<font color="orange">Unknown</font>';

	if($statusArray[0] == 0) {
        	$statusString = '<font color="orange">Up, no game</font>';
	} else if($statusArray[0] == 1) {
        	$statusString = '<font color="green">Good</font>';
	} else if($statusArray[0] == -1) {
        	$statusString = '<font color="red">Down</font>';
	}

	$errorString = '<font color="green">None</font>';

	if(count($statusArray[1]) > 0) {
        	$errorString = '<font color="red">' . implode('; ', $statusArray[1]) . '</font>';
        						}

        						fwrite($handle, '<tr><td>' . $botname . '</td><td>' . $statusString . '</td><td>' . $errorString . '</td></tr>');
        						}

fwrite($handle, '</table><p>Generated at ' . gmdate(DATE_RSS) . '.</p></body></html>');
fclose($handle);

        # make sure pages are working

        foreach($targets as $target) {
        $targetHandle = fopen('http://' . $target . '/status/test.txt', 'r');

	$line = '0';

        if($targetHandle) {
        $line = fgets($targetHandle);
        fclose($targetHandle);
        }

        if(trim($line) != '1') {
        $errors[] = 'failed to retrieve ' . $target . ' test page; down?';
        }
        }

# write errors to file
        $handle = fopen('status.txt', 'w') or die('failed to write to status text file');

foreach($errors as $error) {
        fwrite($handle, $error . "\n");
        }

        fclose($handle);

# see which errors are new, if any
        $newErrors = array();

        foreach($errors as $error) {
        if(!in_array($error, $knownErrors)) {
        $newErrors[] = $error;
        }
        }

        	# report new errors via email
        	if(count($newErrors) > 0) {
        	$message = "The status script on $hostname reports error(s)!\n\n";

        	foreach($newErrors as $error) {
        	$message .= "* $error\n";
        	}

        		require_once "Mail.php";

        		$host = $smtp_host;
	$port = $smtp_port;
        	$username = $smtp_username;
        		$password = $smtp_password;
        		$headers = array ('From' => $from_address,
        		'To' => $to_address,
        		'Subject' => "Alert from $hostname",
        		'Content-Type' => 'text/plain');
        		$smtp = Mail::factory('smtp',
        				array ('host' => $host,
        				'port' => $port,
        				'auth' => true,
        				'username' => $username,
        				'password' => $password));

        				$mail = $smtp->send($to_address, $headers, $message);

        				if (PEAR::isError($mail)) {
        				echo "Error while mailing " . $mail->getMessage() . " :(\n";
        				}
        	}

    }
}