# base-was

This cookbook can be used to demo setting up an IBM WebSphere Application Server ND.

This cookbook has been tested with an AWS Marketplace Centos AMI.

To create the instace follow these instructions:

	AWS Marketplace search and select - CentOS 6 (x86_64) - with Updates

	Select - m3.medium

	Network - vpc-93a22ff6
	Subnet - subnet-4098fe37
	Auto assign public IP = enable
	Network Interfaces Primary IP = 10.0.0.90

	Storage size - 16Gb
	Delete on termination - true

	Tag Name - <your key pair name> <customer> Demo WebSphere Application Server

	Security Group - sg-007d7465 - ChefSecurityGroup (plus 28000 and 28001 on TCP)

	Key Pair - <your key pair name>

To bootstrap the node, make the node able to talk to the chefserver on it's internal IP and then add the role (or recipe) to the node using the following commands:

	$env:DEMO_SSH_KEY='C:\Users\Administrator\.ssh\stack.pem'
	$env:DEMO_IP='10.0.0.90'
	$env:DEMO_NODE_NAME='websphere'

	ssh -i $env:DEMO_SSH_KEY root@$env:DEMO_IP 'echo "10.0.0.10 chefserver" >> /etc/hosts'

Either use a role:

	knife role from file was.rb

	knife bootstrap $env:DEMO_IP -N $env:DEMO_NODE_NAME -x root -i $env:DEMO_SSH_KEY
	
	knife node run_list add $env:DEMO_NODE_NAME '''role[was]'''

Or use a recipe:

	knife bootstrap $env:DEMO_IP -N $env:DEMO_NODE_NAME -x root -i $env:DEMO_SSH_KEY -r 'recipe[base-was]'
	
From the Workstation log into the node and run chef-client:

	ssh -i $env:DEMO_SSH_KEY root@$env:DEMO_IP

	chef-client --audit-mode enabled

	# Get a cup of tea, or two....this takes about 35 mins to complete. 

Test the installation
	
	Log into the WAS Console http://10.0.0.90:28000/ibm/console wasadmin/wasadmin
