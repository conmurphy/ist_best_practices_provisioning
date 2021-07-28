#!/bin/sh

# github token
# github username
# terraform github oath token
# terraform user token
# organization name

# Coloured text
GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
NC=$'\e[0m'

if [ -z "${GITHUB_TOKEN}" ] 
then
	echo "Enter Github token: "
	read GITHUB_TOKEN
fi

if [ -z "${TERRAFORM_TOKEN}" ] 
then
	echo "Enter Terraform Cloud user token: "
	read TERRAFORM_TOKEN
fi

if [ -z "${TERRAFORM_ORGANIZATION_NAME}" ] 
then
	echo "Enter Terraform Cloud Organization name: "
	read TERRAFORM_ORGANIZATION_NAME
fi

if [ -z "${OAUTH_TOKEN_ID}" ] 
then
	echo "Enter Github OAUTH token ID: "
	read OAUTH_TOKEN_ID
fi

if [ -z "${TERRAFORM_AGENT_POOL_NAME}" ] 
then
	echo "Enter Terraform Cloud agent pool name: "
	read TERRAFORM_AGENT_POOL_NAME
fi


echo
echo "${GREEN}***** FORKING ACI SINGLE BD, SINGLE EPG REPO *****${NC}"
echo

curl -X POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/conmurphy/tfe_control_aci_single_bd_single_epg/forks"

echo
echo "${GREEN}**** CREATING TERRAFORM WORKSPACE ****${NC}"
echo

WORKSPACE=$(cat <<-EOF 
	{
		"data": {
			"attributes": {
				"name": "TFE_CONTROL_aci_applications",
				"description": "This workspace will deploy the Terraform Cloud workspaces for individual applications",
				"terraform_version": "1.0.3",
				"working-directory": "",
				"allow-destroy-plan":false,
				"auto-apply":true,
				"vcs-repo": {
					"identifier": "conmurphy/tfe_control_aci_single_bd_single_epg",
					"oauth-token-id": "$OAUTH_TOKEN_ID",
					"branch": ""
				}
			},
			"type": "workspaces"
		}
	}
EOF
)

WORKSPACE_ID=$(curl \
  --header "Authorization: Bearer $TERRAFORM_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$WORKSPACE" \
  https://app.terraform.io/api/v2/organizations/$TERRAFORM_ORGANIZATION_NAME/workspaces | jq -r '.data.id')

echo "Workspace ID: $WORKSPACE_ID"

echo
echo "${GREEN}**** CREATING TERRAFORM VARIABLES ****${NC}"
echo

# YOU NEED TO USE AN ENVIRONMENTAL VARIABLE FOR THE TOKEN BECAUSE OF AN ERROR WITH THE GITHUB PROVIDER
# https://github.com/integrations/terraform-provider-github/issues/830

VARIABLE_GITHUB_TOKEN=$(cat <<-EOF
	{
		"data": { 
			"type":"vars", 
			"attributes": {
				"key":"GITHUB_TOKEN", 
				"value":"${GITHUB_TOKEN}",
				"category":"env", 
				"hcl":false,
				"sensitive":true
			} 
		} 
	}
EOF
)

curl \
  --header "Authorization: Bearer $TERRAFORM_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$VARIABLE_GITHUB_TOKEN" \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars



VARIABLE_TERRAFORM_TOKEN=$(cat <<-EOF
	{
		"data": { 
			"type":"vars", 
			"attributes": {
				"key":"tfcb_token", 
				"value":"${TERRAFORM_TOKEN}",
				"category":"terraform", 
				"hcl":false,
				"sensitive":true
			} 
		} 
	}
EOF
)

curl \
  --header "Authorization: Bearer $TERRAFORM_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$VARIABLE_TERRAFORM_TOKEN" \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars


VARIABLE_TERRAFORM_ORGANIZATION_NAME=$(cat <<-EOF
	{
		"data": { 
			"type":"vars", 
			"attributes": {
				"key":"tfe_organization_name", 
				"value":"${TERRAFORM_ORGANIZATION_NAME}",
				"category":"terraform", 
				"hcl":false,
				"sensitive":false
			} 
		} 
	}
EOF
)

curl \
  --header "Authorization: Bearer $TERRAFORM_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$VARIABLE_TERRAFORM_ORGANIZATION_NAME" \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars


VARIABLE_OAUTH_TOKEN_ID=$(cat <<-EOF
	{
		"data": { 
			"type":"vars", 
			"attributes": {
				"key":"oauth_token_id", 
				"value":"${OAUTH_TOKEN_ID}",
				"category":"terraform", 
				"hcl":false,
				"sensitive":true
			} 
		} 
	}
EOF
)

curl \
  --header "Authorization: Bearer $TERRAFORM_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$VARIABLE_OAUTH_TOKEN_ID" \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars

VARIABLE_TERRAFORM_AGENT_POOL_NAME=$(cat <<-EOF
	{
		"data": { 
			"type":"vars", 
			"attributes": {
				"key":"tfe_agent_pool_name", 
				"value":"${TERRAFORM_AGENT_POOL_NAME}",
				"category":"terraform", 
				"hcl":false,
				"sensitive":false
			} 
		} 
	}
EOF
)

curl \
  --header "Authorization: Bearer $TERRAFORM_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$VARIABLE_TERRAFORM_AGENT_POOL_NAME" \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars


VARIABLE_APPLICATIONS=$(cat <<-EOF
	{
		"data": { 
			"type":"vars", 
			"attributes": {
				"key":"applications", 
				"value":"[\"\",\"\"]",
				"category":"terraform", 
				"hcl":true,
				"sensitive":false
			} 
		} 
	}
EOF
)

curl \
  --header "Authorization: Bearer $TERRAFORM_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$VARIABLE_APPLICATIONS" \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars