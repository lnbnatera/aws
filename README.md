# aws

How to setup AWS account <br />
The instructions below assume that a secure AWS account is active <br />
1 - Create an IAM user in the Web Console that can manage IAM users <br />
    ie username: usermgmt <br />
       policy:   IAMFullAccess <br />
2 - Generate access keys for IAM administrator and configure CLI <br />
    $ aws --profile usermgmt configure <br />
3 - Create a read-only IAM user <br />
    $ aws --profile usermgmt iam create-user --user-name rouser <br />
    { <br />
        "User": { <br />
            "UserName": "rouser", <br />
            "Path": "/", <br />
            "CreateDate": "<>", <br />
            "UserId": "<>", <br />
            "Arn": "arn:aws:iam::<account_id>:user/rouser" <br />
        } <br />
    } <br />
4 - Create an IAM read-only policy document for EC2 and IAM <br />
  a - List policy document for AmazonEC2ReadOnlyAccess and IAMReadOnlyAccess <br />
      $ aws --profile usermgmt iam get-policy-version --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess --version-id v1 > AmazonEC2ReadOnlyAccess.json <br />
      $ aws --profile usermgmt iam get-policy-version --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess --version-id v1 > IAMReadOnlyAccess.json <br />
  b - Create a new policy document, ropolicy.json, based on the previously generated policies <br />
      $ cat MyReadOnlyPolicy.json <br />
      { <br />
         "Version": "2012-10-17", <br />
         "Statement": [ <br />
            { <br />
               "Action": [ <br />
                  "iam:List*", <br />
                  "iam:Get*" <br />
               ], <br />
               "Resource": "*", <br />
               "Effect": "Allow" <br />
            }, <br />
            { <br />
               "Action": "ec2:Describe*", <br />
               "Resource": "*", <br />
               "Effect": "Allow" <br />
            }, <br />
            { <br />
               "Action": "elasticloadbalancing:Describe*", <br />
               "Resource": "*", <br />
               "Effect": "Allow" <br />
            }, <br />
            { <br />
               "Action": [ <br />
                  "cloudwatch:ListMetrics", <br />
                  "cloudwatch:GetMetricStatistics", <br />
                  "cloudwatch:Describe*" <br />
               ], <br />
               "Resource": "*", <br />
               "Effect": "Allow" <br />
            }, <br />
            { <br />
               "Action": "autoscaling:Describe*", <br />
               "Resource": "*", <br />
               "Effect": "Allow" <br />
            } <br />
         ] <br />
      } <br />
5 - Create custom policy <br />
    $ aws --profile usermgmt iam create-policy --policy-name MyReadOnlyPolicy --policy-document file://<path>MyReadOnlyPolicy.json <br />
    { <br />
        "Policy": { <br />
            "PolicyName": "MyReadOnlyPolicy", <br />
            "CreateDate": "<>", <br />
            "AttachmentCount": 0, <br />
            "IsAttachable": true, <br />
            "PolicyId": "<>", <br />
            "DefaultVersionId": "v1", <br />
            "Path": "/", <br />
            "Arn": "arn:aws:iam::<account_id>:policy/MyReadOnlyPolicy", <br />
            "UpdateDate": "<>" <br />
        } <br />
    } <br />
6 - Attach policy to rouser <br />
    $ aws --profile usermgmt attach-user-policy --user-name rouser --policy-arn arn:aws:iam::<account_id>:policy/MyReadOnlyPolicy <br />
7 - Set read-only account as default CLI user <br />
    $ aws --profile usermgmt create-access-key --user-name rouser  <br />
    { <br />
        "AccessKey": { <br />
            "UserName": "rouser", <br />
            "Status": "Active", <br />
            "CreateDate": "<>", <br />
            "SecretAccessKey": "<>", <br />
            "AccessKeyId": "<>" <br />
        } <br />
    } <br />
    $ aws configure <br />
8 - Test <br />
    $ aws iam list-users <br />
    <should list all IAM users> <br />
    $ aws iam create-user someuser <br />
    <error> <br />
