Show latest AMI ID of named AMI
```
aws ec2 describe-images \
--filter 'Name=name,Values=amzn2-ami-hvm-2.0*' \
         'Name=virtualization-type,Values=hvm' \
         'Name=root-device-type,Values=ebs' \
         'Name=architecture,Values=x86_64'
--query "sort_by(Images, &CreationDate)[-1].ImageId"
```
```
aws ec2 describe-images \
--filter 'Name=name,Values=RHEL-6*' \
         'Name=virtualization-type,Values=hvm' \
         'Name=root-device-type,Values=ebs' \
         'Name=owner-id,Values=309956199498' \
         'Name=architecture,Values=x86_64' \
--query "sort_by(Images, &CreationDate)[-1].ImageId"
```

Generate CloudFormation Mapping in partial YAML format for RedHat 6, RedHat 7, Amazon 1, and Amazon 2
```
echo "Mappings:"
echo "  AMIRegionMap:"
for REGION in `aws ec2 describe-regions --query "Regions[].{Region:RegionName}"`
do
echo "    $REGION:"
echo -n "      amazon: "
aws ec2 describe-images --filter 'Name=name,Values=amzn-ami-hvm-*' 'Name=root-device-type,Values=ebs' 'Name=virtualization-type,Values=hvm' 'Name=architecture,Values=x86_64' --query "sort_by(Images, &CreationDate)[-1].ImageId" --region $REGION
echo -n "      amazon2: "
aws ec2 describe-images --filter 'Name=name,Values=amzn2-ami-hvm-2.0*' 'Name=root-device-type,Values=ebs' 'Name=virtualization-type,Values=hvm' 'Name=architecture,Values=x86_64' --query "sort_by(Images, &CreationDate)[-1].ImageId" --region $REGION
echo -n "      redhat6: "
aws ec2 describe-images --filter 'Name=name,Values=RHEL-6*' 'Name=root-device-type,Values=ebs' 'Name=virtualization-type,Values=hvm' 'Name=architecture,Values=x86_64' --query "sort_by(Images, &CreationDate)[-1].ImageId" --region $REGION
echo -n "      redhat7: "
aws ec2 describe-images --filter 'Name=name,Values=RHEL-7*' 'Name=root-device-type,Values=ebs' 'Name=virtualization-type,Values=hvm' 'Name=architecture,Values=x86_64' --query "sort_by(Images, &CreationDate)[-1].ImageId" --region $REGION
done
```

Show KeyPair Names
```
aws ec2 describe-key-pairs --query "KeyPairs[].{KeyName:KeyName}"
```

Show default VPC
```
aws ec2 describe-vpcs --filter "Name=isDefault,Values=true" --query "Vpcs[0].VpcId"
```

Create Security Group
```
aws ec2 create-security-group --description <desription> --group-name <group_name> --vpc-id <vpc_id>
```

Grant SSH access in security group
```
aws ec2 authorize-security-group-ingress --group-name <group_name> --protocol tcp --port 22 --cidr <ip_address>
```

Run Vanilla ec2 instance
```
aws ec2 run-instances \
--image-id ami-0de53d8956e8dcf80 \
--key-name us-east-1-2019 \
--security-groups ssh-only \
--instance-type t2.micro \
--query "Instances[0].InstanceId"
```

Wait for instance to have status OK
```
aws ec2 wait instance-status-ok --instance-ids <instance_id>
```

Filter out not equal to
```
aws ec2 describe-instances --query "Reservations[].Instances[?InstanceId != '<instanec_id>'].InstanceId"
```

Wait until instance is terminated
```
aws ec2 wait instance-terminated --instance-ids <instance_id>
```

Show Instance ID of instances in running state only
```
aws ec2 describe-instances \
--query "Reservations[].Instances[].InstanceId" \
--filters "Name=instance-state-name,Values=running"
```

Show Public IP of Instance ID
```
# 1
aws ec2 describe-instances \
--instance-ids i-0a8db4b8290e0263a \
--query "Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp"
# 2
aws ec2 describe-instances --query "Reservations[0].Instances[0].PublicIpAddress"
```
