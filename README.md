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
  $ aws --profile usermgmt iam get-policy-version --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess --version-id v1 > AmazonEC2ReadOnlyAccess.json
  $ aws --profile usermgmt iam get-policy-version --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess --version-id v1 > IAMReadOnlyAccess.json
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
  $ aws --profile usermgmt iam create-policy --policy-name MyReadOnlyPolicy --policy-document file://<path>MyReadOnlyPolicy.json
  {
      "Policy": {
          "PolicyName": "MyReadOnlyPolicy",
          "CreateDate": "<>",
          "AttachmentCount": 0,
          "IsAttachable": true,
          "PolicyId": "<>",
          "DefaultVersionId": "v1",
          "Path": "/",
          "Arn": "arn:aws:iam::<account_id>:policy/MyReadOnlyPolicy",
          "UpdateDate": "<>"
      }
  }
```
- Attach policy to rouser
```
  $ aws --profile usermgmt attach-user-policy --user-name rouser --policy-arn arn:aws:iam::<account_id>:policy/MyReadOnlyPolicy
```
- Set read-only account as default CLI user
```
  $ aws --profile usermgmt create-access-key --user-name rouser 
  {
      "AccessKey": {
          "UserName": "rouser",
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
  $ aws iam list-users
  <should list all IAM users>
  $ aws iam create-user someuser
  <error>
```
