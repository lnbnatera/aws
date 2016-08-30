#!/bin/sh
# Create a new AWS user and CLI profile
# Mandatory Parameters
#  $1 : IAM administrative account
#  $2 : IAM user to create
# Optional Paramters (TODO)
#  $3 : AWS region
#  $4 : Output format

PROFILE="--profile $1"
USERNAME="--user-name $2"

aws $PROFILE $1 iam create-user $USERNAME

KEYS=`aws $PROFILE create-access-key $USERNAME --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text`

aws configure set profile.$2.aws_access_key_id `echo $KEYS | cut -f1 -d" "`
aws configure set profile.$2.aws_secret_access_key `echo $KEYS | cut -f2 -d" "`

# TODO
# Error checking in parameters
# Accept region and output format entries for ~/.aws/config
#aws ec2 describe-regions --query Regions[*].RegionName --output text
#aws configure set profile.$2.region $3
#aws configure set profile.$2.output $4
