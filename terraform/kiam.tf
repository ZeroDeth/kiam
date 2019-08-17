data "aws_iam_policy_document" "kiam_node_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kiam_node" {
  name               = "kiam-node"
  assume_role_policy = "${data.aws_iam_policy_document.kiam_node_assume_role.json}"
}

data "aws_iam_policy_document" "kiam_node_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "${aws_iam_role.kiam_server_role.arn}",
    ]
  }
}

resource "aws_iam_role_policy" "kiam_node_policy" {
  name   = "kiam_node_policy"
  role   = "${aws_iam_role.kiam_node.name}"
  policy = "${data.aws_iam_policy_document.kiam_node_policy_document.json}"
}

data "aws_iam_policy_document" "kiam_server_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.kiam_node.arn}"]
    }
  }
}

resource "aws_iam_role" "kiam_server_role" {
  name               = "kiam-server"
  assume_role_policy = "${data.aws_iam_policy_document.kiam_server_assume_role.json}"
}

data "aws_iam_policy_document" "kiam_server_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "kiam_server_policy" {
  name        = "kiam_server_policy"
  description = "Policy for the Kiam Server process"

  policy = "${data.aws_iam_policy_document.kiam_server_policy_document.json}"
}

resource "aws_iam_policy_attachment" "kiam_server_policy_attach" {
  name       = "kiam-server-attachment"
  roles      = ["${aws_iam_role.kiam_server_role.name}"]
  policy_arn = "${aws_iam_policy.kiam_server_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "kiam_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.kiam_node.name}"
}

resource "aws_iam_role_policy_attachment" "kiam_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.kiam_node.name}"
}

resource "aws_iam_role_policy_attachment" "kiam_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.kiam_node.name}"
}

resource "aws_iam_role_policy_attachment" "kiam_node_AmazonEC2RoleforSSM" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = "${aws_iam_role.kiam_node.name}"
}

data "aws_iam_policy_document" "kiam_app_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.kiam_server_role.arn}"]
    }
  }
}

resource "aws_iam_role" "kiam_app_role" {
  name_prefix = "app-role-"

  assume_role_policy = "${data.aws_iam_policy_document.kiam_app_policy_document.json}"

  depends_on = [
    "aws_iam_role.kiam_node",
  ]
}

// App Test
data "aws_iam_policy_document" "manage_parameter_store" {
  statement {
    actions   = ["ssm:*"]
    resources = ["${aws_ssm_parameter.foo.arn}"]
  }
}

resource "aws_iam_role_policy" "ssm_tst" {
  name   = "ssm_tst"
  role   = "${aws_iam_role.kiam_app_role.id}"
  policy = "${data.aws_iam_policy_document.manage_parameter_store.json}"
}

resource "aws_ssm_parameter" "foo" {
  name  = "kiam-ssm-tst"
  type  = "String"
  value = "Hello!"
}
