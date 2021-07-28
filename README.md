# Automated Terraform Best Practice Setup
## Overview

Infrastructure/Network/Security admins have strong expertise in their respective domain however may not be aware of the best practices when deploying and managing environments with Terraform. This use case will provide a turnkey solution for an admin to setup a new Terraform workspace, variables, and sentinel policies. It will also associated a Github account with predefined Terraform config for their selected pilar

## Prerequisites
1.	Intersight SaaS platform account with Advantage licenses
2.	An Intersight Assist appliance that is connected to your Intersight environment
3.	Terraform Cloud Business Tier Account
4.	ACI account 
5.	GitHub account to host your Terraform code
6.	Bash access to run the deployment script


## Steps to Deploy Use Case

**Setup Terraform Cloud Business Tier Account**

- To add your Terraform Cloud credentials in Intersight you will need the following:

  - Terraform Cloud Username
  - Terraform Cloud API Token
  - Terraform Cloud Organization

**Setup Terraform Cloud to Intersight connection and claim agent**
- [Click here for the instructions](https://cdn.intersight.com/components/an-hulk/1.0.9-771/docs/cloud/data/resources/terraform-service/en/Cisco_IST_Getting_Started_Guide.pdf)

**Setup Terraform Cloud Integration with Github**
- [Click here for the instructions](https://www.terraform.io/docs/cloud/vcs/github.html)
- **NOTE:** You can ignore `Step 4: On Terraform Cloud, Set Up SSH Keypair (Optional)`
- Copy the `OAuth Token ID` for use later

**Generate a new Github Personal Access Token**
- Create a token with the following scopes
  - `repo`
  - `delete_repo`
- [Click here to generate a token](https://github.com/settings/tokens)
- Copy the token for use later

**Create a new Terraform Cloud User API Token**
- [Click here to create a token](https://app.terraform.io/app/settings/tokens)
- Copy the token for use later

### Summary
- You should now have the following:
  - Github token
  - Oauth ID
  - Terraform Cloud user token
  - Terraform Cloud organization name
  - Terraform Cloud agent pool name

## Running the deployment wizard
- Enter all the information collected (tokens, IDs, names) in the setup into the `envs` file.
- Here's an example:
```
export GITHUB_TOKEN=ghp_12345qwerty
export OAUTH_TOKEN_ID=ot-XU12345qwerty
export TERRAFORM_TOKEN=12345qwerty.atlasv1.12345qwerty
export TERRAFORM_ORGANIZATION_NAME=my_terraform_organization
export TERRAFORM_AGENT_POOL_NAME=my_terraform_agent_pool
```
- Source the `envs` file from the bash prompt on your local machine

`source envs`

- Make the `deployment_wizard.sh` file executable

`chmod +x deployment_wizard.sh`

- Run the deployment wizard

`./deployment_wizard.sh`

- Select the infrastructure you wish to setup

```
$ ./deployment_wizard.sh

What do you need to deploy?

1) ACI
2) Intersight
3) Quit
> 1

What are you configuring in ACI?

1) Application Profile
2) Access Policies
3) Quit
> 1
Running ...

***** FORKING ACI SINGLE BD, SINGLE EPG REPO *****

{
  "id": xxx,
  "node_id": "xxx",
  "name": "tfe_control_aci_single_bd_single_epg",
  "full_name": "<your_github_user>/tfe_control_aci_single_bd_single_epg",
  "private": false,
  ...
  "subscribers_count": 1
}

**** CREATING TERRAFORM WORKSPACE ****

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  2919    0  2484  100   435   1504    263  0:00:01  0:00:01 --:--:--  1766
Workspace ID: ws-xxxxxxx

**** CREATING TERRAFORM VARIABLES ****

{"data":{"id":"var-xxxx","type":"vars","attributes":{"key":"GITHUB_TOKEN","value":null,"sensitive":true,"category":"env","hcl":false,"created-at":"2021-07-28T13:13:55.970Z","description":null},"relationships":{"configurable":{"data":{"id":"ws-xxxxx","type":"workspaces"},"links":{"related":"/api/v2/organizations/<your_terraform_organization>/workspaces/TFE_CONTROL_aci_applications"}}},"links":{"self":"/api/v2/workspaces/ws-xxxx/vars/var-xxxx"}}}

...

{"data":{"id":"var-xxxx","type":"vars","attributes":{"key":"tfcb_token","value":null,"sensitive":true,"category":"terraform","hcl":false,"created-at":"2021-07-28T13:13:55.970Z","description":null},"relationships":{"configurable":{"data":{"id":"ws-xxxxx","type":"workspaces"},"links":{"related":"/api/v2/organizations/<your_terraform_organization>/workspaces/TFE_CONTROL_aci_applications"}}},"links":{"self":"/api/v2/workspaces/ws-xxxx/vars/var-xxxx"}}}
%  
```

## Deploying Best Practice Configurations

- If everything has worked successfully you should now have a new Terraform workspace with a name similar to `TFE_CONTROL_aci_applications`, and a new Github repo with the same name

- Using the `ACI Application Profile ` as aan example, you can go into the Terraform Workspace that was created and have a look at the variables. 

- You should see a variable, `applications`, with the value, `["",""]`. 
- Edit this variables and put in a list of the ACI application profiles you wish to configure and then click `Save`
- Click `Actions` at the top of the page and then `Start new plan`
- Click `Start plan`

- You should see that Terraform is running and plan and will create a new Terraform workspace for each application that you've configured.
- This workspace is configured and connected automatically with a new Github repo that has been created. The repo will contain all the configuration necessary to deploy the individual ACI application profile, ACI endpoint groups, and other resources.
- The workspace has also been configured with the required variables
- You are now ready to get started with your application profile deployment