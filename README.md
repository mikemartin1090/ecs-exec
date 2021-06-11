# Overview
ecs execute-command allows us to talk directly to tasks that are running on ECS (GDS). I followed the [blog post here that showed off the feature along with a quick sandbox that I built out](https://aws.amazon.com/blogs/containers/new-using-amazon-ecs-exec-access-your-containers-fargate-ec2/).

[Here is more formal documentation and examples for when I need to implement.](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html)

### Get it working at GLG...
In order to get ecs execute-command working at all, we'd probably need at least the following:
- modify task definitions that get built in terraform
- Evaluate this: "Note how the task definition does not include any reference or configuration requirement about the new ECS Exec feature, thus, allowing you to continue to use your existing definitions with no need to patch them. As a best practice, we suggest to set the initProcessEnabled parameter to true to avoid SSM agent child processes becoming orphaned. However, this is not a requirement."
- Change IAM roles (task execution, task, etc.)
- Fill in more here...

Here is an example of how we would execute a command within a task.
```
aws ecs execute-command \
 --cluster v2-j01 \
 --task fa2c0f0bf18e47d4a6ba41f696540703 \
 --container ecs-instance-watchdog-service \
 --command "/bin/bash" \
 --interactive
```

take aways:
- if we want to audit these, the command-id along with the commands run are stored in either s3 or cloudwatch (s3 is probably cheaper?)
  - you can then corelate the command-id with the `"sessionId": "ecs-execute-command-008ea97fae32c4042",` that is stored in cloudtrail. Have sumo build some connection or corelation between who ran what command...
- this kind of scares me that you can execute right into a container...being able to change live code. Is it any different than ssh'ing on to the machine? Probably not...just more direct