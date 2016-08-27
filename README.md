# aws

How to setup AWS account
The instructions below assume that a secure AWS account is active
1 - Create an IAM user in the Web Console that can manage IAM users
    ie username: usermgmt
       policy:   IAMFullAccess
2 - Generate access keys for IAM administrator and configure CLI
    $ aws --profile usermgmt configure
3 - Create a read-only IAM user
    $ aws --profile usermgmt iam create-user --user-name rouser
    {
        "User": {
            "UserName": "rouser",
            "Path": "/",
            "CreateDate": "<>",
            "UserId": "<>",
            "Arn": "arn:aws:iam::<account_id>:user/rouser"
        }
    }
4 - Create an IAM read-only policy document for EC2 and IAM
  a - List policy document for AmazonEC2ReadOnlyAccess and IAMReadOnlyAccess
      $ aws --profile usermgmt iam get-policy-version --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess --version-id v1 > AmazonEC2ReadOnlyAccess.json
      $ aws --profile usermgmt iam get-policy-version --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess --version-id v1 > IAMReadOnlyAccess.json
  b - Create a new policy document, ropolicy.json, based on the previously generated policies
      $ cat MyReadOnlyPolicy.json
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
5 - Create custom policy
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
6 - Attach policy to rouser
    $ aws --profile usermgmt attach-user-policy --user-name rouser --policy-arn arn:aws:iam::<account_id>:policy/MyReadOnlyPolicy
7 - Set read-only account as default CLI user
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
8 - Test
    $ aws iam list-users
    <should list all IAM users>
    $ aws iam create-user someuser
    <error>
