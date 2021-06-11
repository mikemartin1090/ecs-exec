source ./prototype.env

aws ecs stop-task --cluster ecs-exec-demo-cluster --region $AWS_REGION --task 9054f4d0ea6c4cb499fcb54e49a4c0ee
aws ecs delete-cluster --cluster ecs-exec-demo-cluster --region $AWS_REGION

aws logs delete-log-group --log-group-name /aws/ecs/ecs-exec-demo --region $AWS_REGION

# Be careful running this command. This will delete the bucket we previously created
aws s3 rm s3://$ECS_EXEC_BUCKET_NAME --recursive
aws s3api delete-bucket --bucket $ECS_EXEC_BUCKET_NAME

aws iam detach-role-policy --role-name ecs-exec-demo-task-execution-role --policy-arn "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
aws iam delete-role --role-name ecs-exec-demo-task-execution-role

aws iam delete-role-policy --role-name ecs-exec-demo-task-role --policy-name ecs-exec-demo-task-role-policy
aws iam delete-role --role-name ecs-exec-demo-task-role

aws kms schedule-key-deletion --key-id 53c6ea1e-5fa0-4295-bce3-08532109abb7 --region $AWS_REGION

aws ec2 delete-security-group --group-id $ECS_EXEC_DEMO_SG_ID --region $AWS_REGION

#TODO: remove subnets