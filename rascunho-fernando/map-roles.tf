
map_roles = [
	{
    “groups”:[ “system:bootstrappers”, “system:nodes”],
    "rolearn":“arn:aws:iam::<ACCOUNT_ID>:role/<EKS_NODE_ROLE>”,
    “username”: “system:node:{{EC2PrivateDNSName}”
	},
  {
    "groups": [ "system:masters" ],
    "rolearn": "arn:aws:iam::<ACCOUNT_ID>:role/eks-admin-role",
    "username": "eks-admin"
  },
  {
    "groups": [ "" ],
    "rolearn": "arn:aws:iam::<ACCOUNT_ID>:role/eks-developer-role",
    "username": "eks-developer"
  }
]

  map_roles          = [
    {
      rolearn  = "arn:aws:iam::261106957109:role/eks-admin-role"     # The ARN of the IAM role
      username = "eks-admin-role"                                           # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"]                                   # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    },
    {
      rolearn  = "arn:aws:iam::261106957109:role/eks-developer-role"     # The ARN of the IAM role
      username = "eks-developer-role"                                           # The user name within Kubernetes to map to the IAM role
      groups   = [ "" ]                                   # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    }
  ]