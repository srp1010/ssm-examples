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

Usage:
- Clone
- chmod +x <eachfile>
- First run ./manage_asg <asg_name>
  - If 0 instances, will prompt to deploy then wait until InstanceID known
  - If 1 instances, will show InstanceID and prompt to terminate
- Once InstanceID shown, run either
  -   ./start_session <instanceid>
  -   ./startpf_session <instanceid>
- First is session manager to instance to interact via command line, second opens port forward session where localhost:<localPortNumber> can be used to view website

NB - not intended as a full/complete bullet proof solution - just some quick and dirty scripts to save time.
