<?php

class Class_Contact
{
	/* holds error messages */
	private $errors = array();
	
	/* number of errors in submitted form */  
	private $num_errors;

	/* is the email valid? */
	private $emailValid;
	
	public function __construct()
	{
		$this->emailValid = new Class_IsEmail();
		
		if(isset($_POST['newcontact']))
			$this->processNewMessage();
	}

	public function processNewMessage()
	{
		$email		= $_POST['email'];
		$name		= $_POST['name'];
		$website	= $_POST['website'];
		$message	= $_POST['message'];
		
		/* Server Side Data Validation */
		
		/* Email Validation */
		if(!$email || mb_strlen($email = trim($email)) == 0)
			$this->setError('email','required field');
		else{
			if(!$this->emailValid->is_email($email))
				$this->setError('email', 'invalid email');
			else if(mb_strlen($email) > 120)
				$this->setError('email', 'too long! 120');
		}
		
		/* Name Validation */
		if(!$name || mb_strlen($name = trim($name)) == 0)
			$this->setError('name', 'required field');
		else if(mb_strlen(trim($name)) > 120)
			$this->setError('name', 'too long! 120 characters');
		
		/* Website Validation */
		if(!mb_eregi("^[a-zA-Z0-9-#_.+!*'(),/&:;=?@]*$", $website))
			$this->setError('website', 'invalid website');	
		elseif(mb_strlen(trim($website)) > 120)
			$this->setError('website', 'too long! 120 characters');
		
		/* Message Validation */
		$message = trim($message);
		if(!$message || mb_strlen($message = trim($message)) == 0)
			$this->setError('message','required field');
		elseif(mb_strlen($message) > 300)
			$this->setError('message', 'too long! 300 characters');
		
		/* Errors exist */
		if($this->countErrors() > 0){
			$json = array(
				'result' => -1, 
				'errors' => array(
								array('name' => 'email'		,'value' => $this->error_value('email')),
								array('name' => 'name' 		,'value' => $this->error_value('name')),
								array('name' => 'website'	,'value' => $this->error_value('website')),
								array('name' => 'message'	,'value' => $this->error_value('message'))
							)
				);				
			$encoded = json_encode($json);
			echo $encoded;
			unset($encoded);
		}
		/* send mail*/
		else{
			$json = array('result' => 1);
			$this->sendEmail($email, $name, $website, $message);
		
		$encoded = json_encode($json);
		echo $encoded;
		unset($encoded);
		}
	}
	
	public function sendEmail($email,$name,$website,$message){
		/* Just format the email text the way you want ... */
		$emailFromName = 'FBF Team';
		$emailFromAddr = 'www.forsaken-bastions-fall.com';
		
		$message_body		= "Hi, ".$name."(".$email." - ".$website.") sent you a message from forsaken-bastions-fall.com\n"
									."email: ".$email."\n"
									."message: "."\n"
									.$message; 
		$headers			= "From: ".$emailFromName." <".$emailFromAddr.">";
		
		$emailTo = 'patrick.puls@arcor.de';
		$messageSubject = 'New Message From Contact Form!';
		
		return mail($emailTo, $messageSubject, $message_body, $headers);
	}
	
	public function setError($field, $errmsg){
		$this->errors[$field] 	= $errmsg;
		$this->num_errors 		= count($this->errors);
	}
	
	public function error_value($field){
		if(array_key_exists($field,$this->errors))
			return $this->errors[$field];
		else
			return '';
	}
	
	public function countErrors(){
		return $this->num_errors;
	}
}
?>