





- Saída completa do Terraform Apply que deu sucesso, após fazer re-run no Job, devido falha no ASG:

~~~~bash
##[debug]Evaluating: secrets.AWS_ACCESS_KEY_ID
##[debug]Evaluating Index:
##[debug]..Evaluating secrets:
##[debug]..=> Object
##[debug]..Evaluating String:
##[debug]..=> 'AWS_ACCESS_KEY_ID'
##[debug]=> '***'
##[debug]Result: '***'
##[debug]Evaluating: secrets.AWS_SECRET_ACCESS_KEY
##[debug]Evaluating Index:
##[debug]..Evaluating secrets:
##[debug]..=> Object
##[debug]..Evaluating String:
##[debug]..=> 'AWS_SECRET_ACCESS_KEY'
##[debug]=> '***'
##[debug]Result: '***'
##[debug]Evaluating condition for step: 'Terraform Apply'
##[debug]Evaluating: (success() && (github.ref == 'refs/heads/main') && (github.event_name == 'push'))
##[debug]Evaluating And:
##[debug]..Evaluating success:
##[debug]..=> true
##[debug]..Evaluating Equal:
##[debug]....Evaluating Index:
##[debug]......Evaluating github:
##[debug]......=> Object
##[debug]......Evaluating String:
##[debug]......=> 'ref'
##[debug]....=> 'refs/heads/main'
##[debug]....Evaluating String:
##[debug]....=> 'refs/heads/main'
##[debug]..=> true
##[debug]..Evaluating Equal:
##[debug]....Evaluating Index:
##[debug]......Evaluating github:
##[debug]......=> Object
##[debug]......Evaluating String:
##[debug]......=> 'event_name'
##[debug]....=> 'push'
##[debug]....Evaluating String:
##[debug]....=> 'push'
##[debug]..=> true
##[debug]=> true
##[debug]Expanded: (true && ('refs/heads/main' == 'refs/heads/main') && ('push' == 'push'))
##[debug]Result: true
##[debug]Starting: Terraform Apply
##[debug]Loading inputs
##[debug]Loading env
Run terraform apply -auto-approve
##[debug]      "mapUsers" = <<-EOT
##[debug]      []
##[debug]      
##[debug]      EOT
##[debug]    })
##[debug]    "id" = "kube-system/aws-auth"
##[debug]    "immutable" = false
##[debug]    "metadata" = tolist([
##[debug]      {
##[debug]        "annotations" = tomap({})
##[debug]        "generate_name" = ""
##[debug]        "generation" = 0
##[debug]        "labels" = tomap({
##[debug]          "app.kubernetes.io/managed-by" = "Terraform"
##[debug]          "terraform.io/module" = "terraform-aws-modules.eks.aws"
##[debug]        })
##[debug]        "name" = "aws-auth"
##[debug]        "namespace" = "kube-system"
##[debug]        "resource_version" = "902"
##[debug]        "uid" = "16c4a60a-058a-4772-bca7-a10eac7f5786"
##[debug]      },
##[debug]    ])
##[debug]  },
##[debug]]
##[debug]kubectl_config = <<EOT
##[debug]apiVersion: v1
##[debug]preferences: {}
##[debug]kind: Config
##[debug]
##[debug]clusters:
##[debug]- cluster:
##[debug]    server: https://5C21DF7350A6C37787AE5C231BF1B2A5.gr7.us-east-2.eks.amazonaws.com
##[debug]    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJek1ESXhPREl5TWpFd01Wb1hEVE16TURJeE5USXlNakV3TVZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTHc5Cjhnbm1qZU0yN1JSZGlIZkZUTTZzcDdZazBwTDlPaHhTZnN3UGlIVk8xUm9kK3IxL2o0RG1lMlFWMUR5Q0gvU2kKRkQrOERPZDN1bmR6TlFudG9sREtuMGNwQlgzVWZpOUo4WHJzREdxc0VvR3J5dXFKK2Q1ZlRvSWUxTU9Ta1dPTgp2RUg3TDNMVXllYlRwSHpkNk14VzFxeUJueENrb242SHRyaVNLL2FMU1FjVzduRFVZQ09KQ1hoRFNYa0xKT3Y3CndrejJEUWg5STJxV0NoRzlNK1dlZTlwdk9XSVVUd0t5aUNTaEp2eEZXWGJUOTRFZFA3bnppbVE4TVVMZCttU0sKNGFQZXRwRFVDY3U2dnpIQnFsTmdaOHRzTmdGSjY1aHFPN0dYa2t5Y25wYWxtYWVkaG5sRllhNHV4RWREM25nQQoxaVI0VTJhVXNSNGNkUnRSejhVQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZDbWxQaHhBZkpuTXpuOTZRSm9WRGJ5RS9pRG5NQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFCZ3VQZlY0NFg5VXk1SEUzZGVOczNHWURzaERYcVE2V0RPRlJXSzFBKy9CbVRCNGJLbgp2YkdrR2VPMVRQUktrSzc1eUFvMkhnZEl1M0lSeVdvMXpzcjdXNHQ2L1hFQnl4OXg3MjFHbVpuQkV2T1hHZnJRCkFOcW1UUGVxR1pmeHExZGRoVTlTWFRMT1FKNzZ2TmJ4cERsRFJyUTBlSEQ3Ui9RTDh4YUIyZ2loQlkweEZReDMKaTJBUWFRdUVhclhkVVBuL0JWekhDQWduOUJ5anRHN0tQcUkzbTlObmlPdjI4OEZzbityT29NaTNTTEpxZjdKNwp2MFRZdm1kUXJrZHkvNVZhZk1GUXFGSHBaZzNtNndnZ0pGaDJYWEJJcEE4QWZKMUxWZGtKQytndkJnOFR0SFVjCmROT1pGUnNsK0JXWEFYdmNQciszQ1BiYWdIVTUvb1h0ekZFTAotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
##[debug]  name: eks_devops-ninja-eks-SSSQrpuN
##[debug]
##[debug]contexts:
##[debug]- context:
##[debug]    cluster: eks_devops-ninja-eks-SSSQrpuN
##[debug]    user: eks_devops-ninja-eks-SSSQrpuN
##[debug]  name: eks_devops-ninja-eks-SSSQrpuN
##[debug]
##[debug]current-context: eks_devops-ninja-eks-SSSQrpuN
##[debug]
##[debug]users:
##[debug]- name: eks_devops-ninja-eks-SSSQrpuN
##[debug]  user:
##[debug]    exec:
##[debug]      apiVersion: client.authentication.k8s.io/v1alpha1
##[debug]      command: aws-iam-authenticator
##[debug]      args:
##[debug]        - "token"
##[debug]        - "-i"
##[debug]        - "devops-ninja-eks-SSSQrpuN"
##[debug]
##[debug]EOT
##[debug]region = "us-east-2"
##[debug]'

::set-output name=stderr::
Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/
##[debug]=''

::set-output name=exitcode::0
Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/
##[debug]='0'
##[debug]Finishing: Terraform Apply
~~~~