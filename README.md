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

To bootstrap the node and add the role to the node run the following commands:

    knife role from file was.rb

	ssh -i <your private key> root@10.0.0.90 'echo "10.0.0.10 chefserver" >> /etc/hosts;'

	knife bootstrap 10.0.0.90 -N websphere -x root -i <your private key>
	
	knife node run_list add websphere role[was]
	
From the Workstation log into the node and run chef-client:

	ssh -i <your private key> root@10.0.0.90

	chef-client

	# Get a cup of tea, or two....this takes about 30 mins to complete. 

Test the installation
	
	Log into the WAS Console http://10.0.0.90:28000 wasadmin/wasadmin

	Note: There is a bug in the setup-iptables and the ports 28000 and 28001 are not open.  Therefore to turn off the firewall: service iptables stop
