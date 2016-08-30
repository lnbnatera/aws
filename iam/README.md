# AWS IAM
The instructions here assume that an IAM administrator has been created in the AWS console with full access priviledge with keys setup on CLI. <br />
##Manage permissions using policy(ies) attached to group(s) and/or user(s)
Policy(ies) attached to group(s) where a user belongs to has the same effect policy(ies) directly attached to user(s) with the later being more specific (ie user-based)
- Create an IAM group that has full access to EC2 and CloudWatch
```
    $ aws --profile <iamadm_account> iam create-group --group-name <ec2_admin_group>
    {
        "Group": {
            "Path": "/",
            "CreateDate": "<>",
            "GroupId": "<>",
            "Arn": "arn:aws:iam::329812010232:group/<ec2_admin_group>",
            "GroupName": "<ec2_admin_group>"
         }
    }
    $ aws iam list-policies --query "Policies[?PolicyName=='AmazonEC2FullAccess'||PolicyName=='CloudWatchFullAccess'].Arn" --output text
    arn:aws:iam::aws:policy/AmazonEC2FullAccess     arn:aws:iam::aws:policy/CloudWatchFullAccess
    $ for ARN in `aws iam list-policies --query "Policies[?PolicyName=='AmazonEC2FullAccess"||PolicyName=='CloudWatchFullAccess'].Arn" --output text`
    > do
    > aws --profile <iamadm_account> iam attach-group-policy --group-name <ec2_admin_group> --policy-arn $ARN
    > done
    $ aws iam list-attched-group-policies --group-name <ec2_admin_group> --output table
    ----------------------------------------------------------------------------
    |                         ListAttachedGroupPolicies                        |
    +--------------------------------------------------------------------------+
    ||                            AttachedPolicies                            ||
    |+-----------------------------------------------+------------------------+|
    ||                   PolicyArn                   |      PolicyName        ||
    |+-----------------------------------------------+------------------------+|
    ||  arn:aws:iam::aws:policy/AmazonEC2FullAccess  |  AmazonEC2FullAccess   ||
    ||  arn:aws:iam::aws:policy/CloudWatchFullAccess |  CloudWatchFullAccess  ||
    |+-----------------------------------------------+------------------------+|
    $ aws --profile <iamadm_account> iam add-user-to-group --group-name <ec2_admin_group> --user-name <ec2adm_account>
    $ aws iam list-groups-for-user --user-name ec2-admin --query "Groups[*].{Group_Name:GroupName}" --output text
    <ec2_admin_group>

```
##Delete an attached user policy
- Since an admin group with full access to EC2 and CloudWatch has been created, delete the attached user policy from EC2 admin user
```
   $ aws iam list-attached-user-policies --user-name <ec2adm_account> --query "AttachedPolicies[*].PolicyArn" --output text
   arn:aws:iam::aws:policy/AmazonEC2FullAccess
   $ aws --profile <iamadm_account> iam detach-user-policy \
   > --user-name <ec2adm_account> \
   > --policy-arn `aws iam list-attached-user-policies --user-name <ec2adm_account> --query "AttachedPolicies[*].PolicyArn" --output text`
   $ aws iam list-attached-user-policies --user-name <ec2adm_account> --query "AttachedPolicies[*].PolicyArn" --output text
   $
```
##Setup an IAM read-only account
The procedures outlined below discuss how to create a custom policy and attach it to a user <br />
- Create an IAM user that can manage IAM accounts
- Generate access keys for IAM administrator and configure CLI
```
$ aws --profile <iamadm_account> configure
```
- Create a read-only IAM user
```
    $ aws --profile <iamadm_account> iam create-user --user-name <ro_account>
    {
        "User": {
            "UserName": "<ro_account>",
            "Path": "/",
            "CreateDate": "<>",
            "UserId": "<>",
            "Arn": "arn:aws:iam::<account_id>:user/ro_account"
        }
    }
```
- Create an IAM read-only policy document for EC2 and IAM by generating the policy documents for each and creating a new json file that contains both
```
  $ aws --profile <iamadm_account> iam get-policy-version --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess --version-id v1 > AmazonEC2ReadOnlyAccess.json
  $ aws --profile <iamadm_account> iam get-policy-version --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess --version-id v1 > IAMReadOnlyAccess.json
  $ cat ropolicy.json
  {
     "Version": "2012-10-17",
     "Statement": [
        {
           "Action": [
              "iam:List*",
              "iam:Get*"
           ],
           "Resource": "*",
           "Effect": "Allow"
        },
        {
           "Action": "ec2:Describe*",
           "Resource": "*",
           "Effect": "Allow"
        },
        {
           "Action": "elasticloadbalancing:Describe*",
           "Resource": "*",
           "Effect": "Allow"
        },
        {
           "Action": [
              "cloudwatch:ListMetrics",
              "cloudwatch:GetMetricStatistics",
              "cloudwatch:Describe*"
           ],
           "Resource": "*",
           "Effect": "Allow"
        },
        {
           "Action": "autoscaling:Describe*",
           "Resource": "*",
           "Effect": "Allow"
        }
     ]
  }
```
- Create custom policy
```
  $ aws --profile <iamadm_account> iam create-policy --policy-name RoPolicy --policy-document file://<path>ropolicy.json
  {
      "Policy": {
          "PolicyName": "RoPolicy",
          "CreateDate": "<>",
          "AttachmentCount": 0,
          "IsAttachable": true,
          "PolicyId": "<>",
          "DefaultVersionId": "v1",
          "Path": "/",
          "Arn": "arn:aws:iam::<account_id>:policy/RoPolicy",
          "UpdateDate": "<>"
      }
  }
```
- Attach policy to <ro_account>
```
  $ aws --profile <iamadm_account> attach-user-policy --user-name <ro_account> --policy-arn arn:aws:iam::<account_id>:policy/RoPolicy
```
- Set read-only account as default CLI user
```
  $ aws --profile <iamadm_account> create-access-key --user-name <ro_account> 
  {
      "AccessKey": {
          "UserName": "<ro_account>",
          "Status": "Active",
          "CreateDate": "<>",
          "SecretAccessKey": "<>",
          "AccessKeyId": "<>"
      }
  }
  $ aws configure
```
- Test
```
  $ aws iam list-users --query "Users[*].{UserName:UserName}"
  [
      {
          "UserName": "<account1>"
      },
      {
          "UserName": "<account2>"
      },
      {
          "UserName": "<ro_account>"
      }
  ]
  $ aws iam create-user --user-name <account3>

  An error occurred (AccessDenied) when calling the CreateUser operation: User: arn:aws:iam::<account_id>:user/<ro_account> is not authorized to perform: iam:CreateUser on resource: arn:aws:iam::<account_id>:user/<account3>

  $ aws ec2 describe-security-groups --query "SecurityGroups[*].{Group_Name:GroupName,Group_ID:GroupId}"
  [
      {
          "Group_ID": "sg-be18bcda",
          "Group_Name": "default"
      }
  ]
  $ aws ec2 create-security-group --group-name <group2> --description "test group"

  An error occurred (UnauthorizedOperation) when calling the CreateSecurityGroup operation: You are not authorized to perform this operation.
```
