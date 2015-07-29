# Demo Notes 

	$env:DEMO_SSH_KEY='C:\Users\Administrator\.ssh\stack.pem'
	$env:DEMO_IP='10.0.0.91'
	$env:DEMO_NODE_NAME='websphere91'

## Provision WebSphere

	ssh -i $env:DEMO_SSH_KEY root@$env:DEMO_IP 'echo "10.0.0.10 chefserver" >> /etc/hosts'
	knife bootstrap $env:DEMO_IP -N $env:DEMO_NODE_NAME -x root -i $env:DEMO_SSH_KEY
	knife node run_list add $env:DEMO_NODE_NAME '''role[was]'''
	ssh -i $env:DEMO_SSH_KEY root@$env:DEMO_IP 'chef-client --audit-mode enabled'

## Test WebSphere

	https://$env:DEMO_IP:28001/ibm/console

## Manually Reset WebSphere Demo

	ssh -i $env:DEMO_SSH_KEY root@$env:DEMO_IP
	cd /opt/IBM/WebSphere85/profiles/node01/bin
	./stopServer.sh server01 -username wasadmin -password wasadmin
	./stopNode.sh -username wasadmin -password wasadmin
	cd /opt/IBM/WebSphere85/profiles/Dmgr01/bin
	./stopManager.sh -username wasadmin -password wasadmin
	cd /opt/IBM/WebSphere85/bin
	./manageprofiles.sh -delete -profileName node01
	./manageprofiles.sh -delete -profileName Dmgr01
	./manageprofiles.sh -validateAndUpdateRegistry
	cd /opt/IBM/WebSphere85/profiles
	rm -Rf node01
	rm -Rf Dmgr01
