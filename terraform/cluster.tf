  // Example for module eks

  worker_group_count = 2

  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t3.large"
      asg_desired_capacity = "2"
      asg_max_size         = "5"
      asg_min_size         = "2"
      asg_force_delete     = false

      kubelet_extra_args            = "--node-labels=kubernetes.io/role=node"
      ...
    },
    {
      name                 = "worker-group-2"
      instance_type        = "t3.medium"
      asg_desired_capacity = "2"
      asg_max_size         = "5"
      asg_min_size         = "1"
      asg_force_delete     = false


      iam_role_id                   = "${aws_iam_role.kiam_node.name}"
      kubelet_extra_args            = "--node-labels=kubernetes.io/role=master"
      ...
    },
  ]
