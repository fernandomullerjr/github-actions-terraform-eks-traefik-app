module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints"

  # EKS CLUSTER
  cluster_version    = "1.21"                                         # EKS Cluster Version
  vpc_id             = "<vpcid>"                                      # Enter VPC ID
  private_subnet_ids = ["<subnet-a>", "<subnet-b>", "<subnet-c>"]     # Enter Private Subnet IDs

  # List of map_roles
  map_roles          = [
    {
      rolearn  = "arn:aws:iam::<aws-account-id>:role/<role-name>"     # The ARN of the IAM role
      username = "ops-role"                                           # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"]                                   # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    }
  ]

  # List of map_users
  map_users = [
    {
      userarn  = "arn:aws:iam::<aws-account-id>:user/<username>"      # The ARN of the IAM user to add.
      username = "opsuser"                                            # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"]                                   # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    }
  ]

  map_accounts = ["123456789", "9876543321"]                          # List of AWS account ids
}