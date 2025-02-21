# ssm-examples
Just some super simple scripts to use to save typing.

Background
- Used for private webserver instance in AWS where SSM Session Manager is used to access
- ASG Desired Count used to start/stop webserver as and when needed (for testing)
- Webserver User-Data installs everything needed from base AWS AMI then pulls a dockerised webserver from source repo (docker-compose-up)


Assumption is 
- AWS CLI already setup and authenticating correctly.
- Role assumed has necessary permission to amend the ASG Desired Count, and use SSM Start-session etc
- Region and ports updated per requirement

Usage: (Linux/Bash etc)
- Clone
- ```chmod +x <eachfile>```
- First run ```./manage_asg asg-name```
  - If 0 instances, will prompt to deploy then wait until InstanceID known
  - If 1 instances, will show InstanceID and prompt to terminate
- Once InstanceID shown, run either
  -   ```.\start_session instanceid```
  -   ```.\start_pf_session instanceid```
- First is session manager to instance to interact via command line, second opens port forward session where localhost:<localPortNumber> can be used to view website

Usage: (Powershell)
- clone
- ```Set-ExecutionPolicy RemoteSigned -Scope CurrentUser```
- First run ```.\manage-autoscaling.ps1 -AutoScalingGroupName <Auto-Scaling-Group-Name>```
  - If 0 instances, will prompt to deploy then wait until InstanceID known
  - If 1 instances, will show InstanceID and prompt to terminate
- Once InstanceID shown, run either
  -   ```.\start_session.ps1 -InstanceId <INSTANCE_ID>```
  -   ```.\start_pf_session.ps1 -InstanceId <INSTANCE_ID>```

NB - not intended as a full/complete bullet proof solution - just some quick and dirty scripts to save time.
