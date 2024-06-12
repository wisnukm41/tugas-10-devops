# Untuk mengconfig akses
aws configure

# untuk membuat security group
aws ec2 create-security-group --group-name tuts-sg \
--description "AWS ec2 DEMO" --tag=spesification 'ResourceType=Security-group, Tags=[{Key:Name, Value=test=sg}]' \ 
--vpc-id "vpc-07eb3c8d25504dd9e"

# untuk memetakan network pada security group
aws ec2 authorize-security-group-ingress \
    --group-id "sg-0e3c78dff6faa4794" \
    --protocol tcp \
    --port 22 \
    --cidr "0.0.0.0/0" 

# untuk membuat ssh key pair
aws ec2 create-key-pair --key-name test-key --query 'KeyMaterial' --output text > ~/.ssh/test-key


#Untuk run Instance
#Cari AMI ID untuk menyesuaikan dengan platform yang akan digunakan, disini saya menggunakan ubuntu 64x bit
#subnet-id ini bisa di kosongkan, tapi jika tidak diisi akan menggunaka subnet default
#EBS (Elastic Block Storage) disini saya set 30 gb
aws ec2 run-instances \
    --image-id ami-04b70fa74e45c3917 \
    --instance-type t2.micro \
    --key-name test-key \
    --security-group-ids sg-0e3c78dff6faa4794 \
    --subnet-id subnet-06ccf21bb05bbe8e3 \
    --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":30,\"DeleteOnTermination\":false}}]" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=demo-server}]' 'ResourceType=volume,Tags=[{Key=Name,Value=demo-server-disk}]'