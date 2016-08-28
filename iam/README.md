# aws

How to setup AWS account <br />
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
