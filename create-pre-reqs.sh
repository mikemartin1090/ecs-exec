source ./prototype.env

#TODO: add the two public subnets I had to create for example via CLI

KMS_KEY=$(aws kms create-key --region $AWS_REGION)
KMS_KEY_ARN=$(echo $KMS_KEY | jq --raw-output .KeyMetadata.Arn)
aws kms create-alias --alias-name alias/ecs-exec-demo-kms-key --target-key-id $KMS_KEY_ARN --region $AWS_REGION
echo "The KMS Key ARN is: "$KMS_KEY_ARN

aws ecs create-cluster \
    --cluster-name ecs-exec-demo-cluster \
    --region $AWS_REGION \
    --configuration executeCommandConfiguration="{logging=OVERRIDE,\
                                                kmsKeyId=$KMS_KEY_ARN,\
                                                logConfiguration={cloudWatchLogGroupName="/aws/ecs/ecs-exec-demo",\
                                                                s3BucketName=$ECS_EXEC_BUCKET_NAME,\
                                                                s3KeyPrefix=exec-output}}"

aws logs create-log-group --log-group-name /aws/ecs/ecs-exec-demo --region $AWS_REGION

aws s3api create-bucket --bucket $ECS_EXEC_BUCKET_NAME --region $AWS_REGION

ECS_EXEC_DEMO_SG=$(aws ec2 create-security-group --group-name ecs-exec-demo-SG --description "ECS exec demo SG" --vpc-id $VPC_ID --region $AWS_REGION)
ECS_EXEC_DEMO_SG_ID=$(echo $ECS_EXEC_DEMO_SG | jq --raw-output .GroupId)
aws ec2 authorize-security-group-ingress --group-id $ECS_EXEC_DEMO_SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $AWS_REGION

aws iam create-role --role-name ecs-exec-demo-task-execution-role --assume-role-policy-document file://ecs-tasks-trust-policy.json --region $AWS_REGION
aws iam create-role --role-name ecs-exec-demo-task-role --assume-role-policy-document file://ecs-tasks-trust-policy.json --region $AWS_REGION