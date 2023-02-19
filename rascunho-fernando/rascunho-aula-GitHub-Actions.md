
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------

## Git - commit - resumo

git status
git add .
git commit -m "CURSO devops-mao-na-massa-docker-kubernetes-rancher --- AULA 58. GitHub Actions - Terraform + EKS"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push
git status



-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
## RESUMO - Manual do projeto

- Projeto usa região de Ohio(us-east-2).
- Trigger são PR's e commits que tenham modificações em arquivos da pasta eks(manifestos do Terraform do Cluster EKS).
- AWS Keys, ajustar. Cadastrar nas Secrets do repo do Github.
- Projeto usa região de Ohio(us-east-2).
- Criar bucket no S3 na mesma região que o projeto. Ajustar o manifesto de providers, colocando este bucket.
- Criar 1 Token no Github, para uso no "actions/github-script@0.9.0". 
- Habilitar permissões dos Actions nas settings do repositório. Marcar "Workflows have read and write permissions in the repository for all scopes."
- DESTROY, criei uma branch chamada "branch-destruidora", que ao receber um merge ela trigga o destroy.

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
## AWS Keys

- ANTES:

trazendo buckets incorretos:

fernando@debian10x64:~$ aws s3 ls
2022-04-02 19:13:00 tfstate-816678621138



- Ajustadas as credentials da AWS na VM Debian.
ajustada para:
arn:aws:iam::261106957109:user/fernandomullerjr8596


- Testando minha chave AWS

fernando@debian10x64:~$ aws s3 ls
2022-09-07 12:26:39 fernandomullerjr.site
2022-09-07 12:26:29 fernandomullerjr.site-logs
2022-07-27 21:18:17 tfstate-261106957109
2022-09-07 12:26:54 www.fernandomullerjr.site
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ date
Sat 11 Feb 2023 10:09:49 PM -03
fernando@debian10x64:~$



buscou os buckets corretos agora!







-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
## 58. GitHub Actions - Terraform + EKS

- Usar o material do README do Jonathan:
/home/fernando/cursos/terraform/github-actions-terraform-eks-traefik-app/README.md

- Efetuado fork do repo

Link do repo forkado:
https://github.com/fernandomullerjr/github-actions-terraform-eks-traefik-app
<https://github.com/fernandomullerjr/github-actions-terraform-eks-traefik-app>

- Arquivo do Github Actions, com os steps:
  /home/fernando/cursos/terraform/github-actions-terraform-eks-traefik-app/.github/workflows/eks.yaml



## Roteiro

- Repositorio
  - AWS Access Keys
  - IAM Permission
- Github Actions - Pipeline
- EKS 


- Necessário garantir as permissões necessárias no usuário dono das AWS Keys, senão, o Github Actions não vai conseguir provisionar a infra do Cluster EKS.


# Permissões IAM

https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html

https://docs.aws.amazon.com/eks/latest/userguide/security_iam_id-based-policy-examples.html#policy_example3

- Policy original:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeNodegroup",
                "eks:ListNodegroups",
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:AccessKubernetesApi",
                "ssm:GetParameter",
                "eks:ListUpdates",
                "eks:ListFargateProfiles"
            ],
            "Resource": "*"
        }
    ]
}
```



- Criei uma versão personalizad, mais permissiva:


```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*",
                "ssm:*"
            ],
            "Resource": "*"
        }
    ]
}
```




- Criando policy no IAM:

eks-politica-permite-terraform-github-actions
Permite que o Github Actions crie a estrutura do EKS via Terraform
arn:aws:iam::261106957109:policy/eks-politica-permite-terraform-github-actions

- Atrelada ao grupo:
arn:aws:iam::261106957109:group/devops-admin



# Github

- Ajustar as settings do Repositório
ir em Secrets das Actions
https://github.com/fernandomullerjr/github-actions-terraform-eks-traefik-app/settings/secrets/actions

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

cadastradas!





# Pipeline

- Agora vamos trabalhar com o arquivo do pipeline:
.github/workflows/eks.yaml

- Sempre que houver alteração na pasta "eks", ele vai triggar a pipeline, devido a linha:
eks/**


- Depois, nos steps
ele usa um Ubuntu, sobe um Terraform
Faz um Terraform Init usando as credenciais que cadastramos no repo

~~~~yaml
    # Initialize a new or existing Terraform working directory by creating initial files, loading any remote state, downloading modules, etc.
    - name: Terraform Init
      id: init
      run: terraform init
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
~~~~





# Terraform

- Ajustando o manifesto do eks-cluster
eks/eks-cluster.tf
Colocando a familia "t3a.micro" no lugar das small e medium

DE:

~~~~h
  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]
}
~~~~


PARA:

~~~~h
  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3a.micro"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t3a.micro"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]
}
~~~~










# Actions

Workflows aren’t being run on this forked repository

Because this repository contained workflow files when it was forked, we have disabled them from running on this fork. Make sure you understand the configured workflows and their expected usage before enabling Actions on this repository.




- Criada uma branch
teste-branch-1


git add .
git commit -m "CURSO devops-mao-na-massa-docker-kubernetes-rancher --- AULA 58. GitHub Actions - Terraform + EKS"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push


git push --set-upstream origin teste-branch-1


fernando@debian10x64:~/cursos/terraform/github-actions-terraform-eks-traefik-app$ git push --set-upstream origin teste-branch-1

Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 8 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 464 bytes | 464.00 KiB/s, done.
Total 4 (delta 3), reused 0 (delta 0)
remote: Resolving deltas: 100% (3/3), completed with 3 local objects.
remote:
remote: Create a pull request for 'teste-branch-1' on GitHub by visiting:
remote:      https://github.com/fernandomullerjr/github-actions-terraform-eks-traefik-app/pull/new/teste-branch-1
remote:
To github.com:fernandomullerjr/github-actions-terraform-eks-traefik-app.git
 * [new branch]      teste-branch-1 -> teste-branch-1
Branch 'teste-branch-1' set up to track remote branch 'teste-branch-1' from 'origin'.
fernando@debian10x64:~/cursos/terraform/github-actions-terraform-eks-traefik-app$
fernando@debian10x64:~/cursos/terraform/github-actions-terraform-eks-traefik-app$


 teste-branch-1 had recent pushes less than a minute ago 



- Actions
ativado Workflows
"There are no workflow runs yet."


- Gerado PR
https://github.com/fernandomullerjr/github-actions-terraform-eks-traefik-app/pull/1

- PR não tem os "Checks" esperados:
    Workflow runs completed with no jobs







- Ajustando arquivo da pasta "eks", ajustado o outputs, apenas com a finalidade de triggar a pipeline.

~~~~bash
fernando@debian10x64:~/cursos/terraform/github-actions-terraform-eks-traefik-app$ git status
On branch teste-branch-1
Your branch is up to date with 'origin/teste-branch-1'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   eks/.infracost/terraform_modules/manifest.json
        modified:   eks/outputs.tf
        modified:   rascunho-fernando/rascunho-aula-GitHub-Actions.md

no changes added to commit (use "git add" and/or "git commit -a")
fernando@debian10x64:~/cursos/terraform/github-actions-terraform-eks-traefik-app$
~~~~


- Efetuando novo push:

git add .
git commit -m "CURSO devops --- AULA 58. GitHub Actions - Ajustado arquivo na pasta EKS, visando trigger da Pipeline e ocorrência de Checks no PR."
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push



- OK, funcionou, agora chamou os Checks do PR:

Terraform CI on: pull_request 7
Terraform
Terraform
failed Feb 11, 2023 in 9s
3s


- ERRO

~~~~bash
1s
2s
Run terraform init
  terraform init
  shell: /usr/bin/bash --noprofile --norc -e -o pipefail {0}
  env:
    TERRAFORM_CLI_PATH: /home/runner/work/_temp/dc224b8c-bfc0-4a26-9ed0-d4201a252ac5
    AWS_ACCESS_KEY_ID: ***
    AWS_SECRET_ACCESS_KEY: ***
/home/runner/work/_temp/dc224b8c-bfc0-4a26-9ed0-d4201a252ac5/terraform-bin init
Initializing modules...
Downloading registry.terraform.io/terraform-aws-modules/eks/aws 19.7.0 for eks...
- eks in .terraform/modules/eks
- eks.eks_managed_node_group in .terraform/modules/eks/modules/eks-managed-node-group
- eks.eks_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data
- eks.fargate_profile in .terraform/modules/eks/modules/fargate-profile
Downloading registry.terraform.io/terraform-aws-modules/kms/aws 1.1.0 for eks.kms...
- eks.kms in .terraform/modules/eks.kms
- eks.self_managed_node_group in .terraform/modules/eks/modules/self-managed-node-group
- eks.self_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data
Downloading registry.terraform.io/terraform-aws-modules/vpc/aws 2.66.0 for vpc...
- vpc in .terraform/modules/vpc
╷
│ Error: Unsupported Terraform Core version
│ 
│   on versions.tf line 34, in terraform:
│   34:   required_version = "~> 0.14"
│ 
│ This configuration does not support Terraform version 1.3.8. To proceed,
│ either choose another supported Terraform version or update this version
│ constraint. Version constraints are normally set for good reason, so
│ updating the constraint may lead to other errors or unexpected behavior.
╵


Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
~~~~






- Ajustando arquivo de versões:
eks/versions.tf
DE:
required_version = "~> 0.14"
PARA:
required_version = "1.3.8"


- Efetuando novo push:

git add .
git commit -m "CURSO devops --- AULA 58. GitHub Actions - Ajustado version do Terraform."
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push



- NOVO ERRO
step do "Terraform Init"

~~~~bash
1s
1s
4s
Run terraform init
/home/runner/work/_temp/88fa721c-49f1-40f8-9693-de0ae11073a3/terraform-bin init
Initializing modules...
Downloading registry.terraform.io/terraform-aws-modules/eks/aws 19.7.0 for eks...
- eks in .terraform/modules/eks
- eks.eks_managed_node_group in .terraform/modules/eks/modules/eks-managed-node-group
- eks.eks_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data
- eks.fargate_profile in .terraform/modules/eks/modules/fargate-profile
Downloading registry.terraform.io/terraform-aws-modules/kms/aws 1.1.0 for eks.kms...
- eks.kms in .terraform/modules/eks.kms
- eks.self_managed_node_group in .terraform/modules/eks/modules/self-managed-node-group
- eks.self_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data
Downloading registry.terraform.io/terraform-aws-modules/vpc/aws 2.66.0 for vpc...
- vpc in .terraform/modules/vpc

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
Error refreshing state: AccessDenied: Access Denied
	status code: 403, request id: A8X4TFE71JSQ7QJS, host id: dHxJqdfqLARZyHKay+w6MW6eNnwJCp3MS6vqlOg/RwLN+YvMbCA1V+PJYyVccoU4VgIpM/+KKtI=

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
~~~~


- Erro de "AccessDenied"


# PENDENTE
- Erro de "AccessDenied"









# Dia 12/02/2023

All checks have failed
1 failing check
@github-actions
Terraform CI / Terraform (pull_request) Failing after 6s 



Error refreshing state: AccessDenied: Access Denied




- Ajustada a politica
arn:aws:iam::261106957109:policy/eks-politica-permite-terraform-github-actions
ADICIONADAS permissões de s3 e dynamodb

~~~~YAML
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*",
                "s3:*",
                "dynamodb:*",
                "ssm:*"
            ],
            "Resource": "*"
        }
    ]
}
~~~~


- Segue com erro:

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
Error refreshing state: AccessDenied: Access Denied
	status code: 403, request id: Z4Y3P8Z3VV629JJN, host id: QKmME3Qa9kMT7b7LPAQ7sGiDTOFxi7oeVzBccso7GjDk7z9Rm8z37AfS4ke8WeOnIcYfX8a5sFk=


- Ajustar a policy do usuário não resolveu.






- Criado bucket no S3:
github-actions-terraform-eks-traefik-app-fernandomuller

- Bucket foi criado na mesma região que estará o projeto.

- Ajustado manifesto do providers
eks/providers.tf


- Commitando:

git add .
git commit -m "AULA 58. GitHub Actions - Terraform + EKS. Ajustando o provider, criado um novo bucket no S3."
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push

- RESOLVIDO!
passou do step de "Terraform init"






- Novo erro:
step:
"Run actions/github-script@0.9.0"

~~~~bash
4s
0s
Run actions/github-script@0.9.0
Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/
RequestError [HttpError]: Resource not accessible by integration
Error: Resource not accessible by integration
    at /home/runner/work/_actions/actions/github-script/0.9.0/dist/index.js:8705:23
    at processTicksAndRejections (internal/process/task_queues.js:97:5) {
  status: 403,
  headers: {
    'access-control-allow-origin': '*',
    'access-control-expose-headers': 'ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset',
    connection: 'close',
    'content-encoding': 'gzip',
    'content-security-policy': "default-src 'none'",
    'content-type': 'application/json; charset=utf-8',
    date: 'Sun, 12 Feb 2023 23:46:50 GMT',
    'referrer-policy': 'origin-when-cross-origin, strict-origin-when-cross-origin',
    server: 'GitHub.com',
    'strict-transport-security': 'max-age=31536000; includeSubdomains; preload',
    'transfer-encoding': 'chunked',
    vary: 'Accept-Encoding, Accept, X-Requested-With',
    'x-content-type-options': 'nosniff',
    'x-frame-options': 'deny',
    'x-github-api-version-selected': '2022-11-28',
    'x-github-media-type': 'github.v3',
    'x-github-request-id': 'A100:5A28:3E58C41:807C26B:63E97A6A',
    'x-ratelimit-limit': '1000',
    'x-ratelimit-remaining': '999',
    'x-ratelimit-reset': '1676249210',
    'x-ratelimit-resource': 'core',
    'x-ratelimit-used': '1',
    'x-xss-protection': '0'
  },
  request: {
    method: 'POST',
    url: 'https://api.github.com/repos/fernandomullerjr/github-actions-terraform-eks-traefik-app/issues/1/comments',
    headers: {
      accept: 'application/vnd.github.-preview+json',
      'user-agent': 'actions/github-script octokit.js/16.43.1 Node.js/12.22.7 (Linux 5.15; x64)',
      authorization: 'token [REDACTED]',
      'content-type': 'application/json; charset=utf-8'
    },
    body: '{"body":"#### Terraform Format and Style 🖌`success`\\n#### Terraform Initialization ⚙️`success`\\n#### Terraform Plan 📖`failure`\\n\\n<details><summary>Show Plan</summary>\\n\\n```terraform\\n```\\n\\n</details>\\n\\n*Pusher: @fernandomullerjr, Action: `pull_request`*"}',
    request: { hook: [Function: bound bound register], validate: [Object] }
  },
  documentation_url: 'https://docs.github.com/rest/reference/issues#create-an-issue-comment'
}
~~~~




- Erro
Error: Resource not accessible by integration


- TSHOOT
<https://dev.to/callmekatootie/debug-resource-not-accessible-by-integration-error-when-working-with-githubs-graphql-endpoint-5bim>
This error basically talks about a permission issue. When working with Github apps, you may not have set the necessary permission to access the resource you need. Hence the Resource not accessible by integration error.

- Exemplo deste site:

>So - how would one go about finding out which permission is needed in this case?

>The graphql documentation does not talk about this - weirdly, one first needs to instead go to their REST api documentation. In our case, since we are interested in the count of the collaborators on a repository, we would look for the REST api that fetches the collaborators for a repository. That would be the list repository collaborators endpoint:
>GET /repos/{owner}/{repo}/collaborators

>Now that we know the endpoint path, we then head over to the permissions required for Github Apps page and proceed to locate this endpoint (Do a Ctrl / Cmd + F in your browser and search for the endpoint you need).

>We find the above endpoint under the Collaborators permission list:

>Collaborators Permission List

>which, if you scroll up, falls under the Metadata permissions. Boom! There you go! Head over to your Github App and under Repository permissions, provide read-only access for the Metadata permissions:

>Github App Repository Permissions

>That should resolve your "Resource not accessible by integration" issue.





- No meu caso, é provável que seja o comment, conforme:

~~~~bash
    method: 'POST',
    url: 'https://api.github.com/repos/fernandomullerjr/github-actions-terraform-eks-traefik-app/issues/1/comments',
~~~~

- Documentação:
<https://docs.github.com/en/rest/overview/permissions-required-for-github-apps?apiVersion=2022-11-28>
exemplo:
POST /repos/{owner}/{repo}/comments/{comment_id}/reactions (write)

<https://docs.github.com/en/rest/reactions?apiVersion=2022-11-28#create-reaction-for-a-commit-comment>


https://docs.github.com/en/developers/apps


- Criado 1 Token no Github:
FernandoTesteTerraform





    - uses: actions/github-script@0.9.0
      if: github.event_name == 'pull_request'
      env:
        PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}










## Automatic token authentication

<https://docs.github.com/en/actions/security-guides/automatic-token-authentication>

In this article

    About the GITHUB_TOKEN secret
    Using the GITHUB_TOKEN in a workflow
    Permissions for the GITHUB_TOKEN

GitHub provides a token that you can use to authenticate on behalf of GitHub Actions.
About the GITHUB_TOKEN secret

At the start of each workflow run, GitHub automatically creates a unique GITHUB_TOKEN secret to use in your workflow. You can use the GITHUB_TOKEN to authenticate in a workflow run.

When you enable GitHub Actions, GitHub installs a GitHub App on your repository. The GITHUB_TOKEN secret is a GitHub App installation access token. You can use the installation access token to authenticate on behalf of the GitHub App installed on your repository. The token's permissions are limited to the repository that contains your workflow. For more information, see "Permissions for the GITHUB_TOKEN."

Before each job begins, GitHub fetches an installation access token for the job. The GITHUB_TOKEN expires when a job finishes or after a maximum of 24 hours.

The token is also available in the github.token context. For more information, see "Contexts."







- Não é necessário criar 1 Secret com o valor do Token, conforme a DOC acima.


- Check segue com erro:
Error: Resource not accessible by integration





https://stackoverflow.com/questions/70435286/resource-not-accessible-by-integration-on-github-post-repos-owner-repo-ac
configure permissions in Actions settings



Workflow permissions

Choose the default permissions granted to the GITHUB_TOKEN when running workflows in this repository. You can specify more granular permissions in the workflow using YAML. Learn more.
Workflows have read and write permissions in the repository for all scopes.
Workflows have read permissions in the repository for the contents and packages scopes only.




- Estava com:
Workflows have read permissions in the repository for the contents and packages scopes only.

- Ajustado para:
Workflows have read and write permissions in the repository for all scopes.

- Marcada opção que permite que as Actions criem e aprovem PR.






git add .
git commit -m "AULA 58. GitHub Actions - Terraform + EKS, Novo teste do Check, ajustadas as permissões dos Actions no repositório!"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push




- Verificando o PR e os Checks
existem erros no step do "Terraform Plan"
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.


- Detalhado:

~~~~bash
0s
4s
Run terraform plan -no-color
/home/runner/work/_temp/cb4e874d-bebe-4e0f-b55f-711c6fb52170/terraform-bin plan -no-color

Error: Unsupported argument

  on eks-cluster.tf line 5, in module "eks":
   5:   subnets         = module.vpc.public_subnets

An argument named "subnets" is not expected here.

Error: Unsupported argument

  on eks-cluster.tf line 14, in module "eks":
  14:   workers_group_defaults = {

An argument named "workers_group_defaults" is not expected here.

Error: Unsupported argument

  on eks-cluster.tf line 18, in module "eks":
  18:   worker_groups = [

An argument named "worker_groups" is not expected here.

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
~~~~




-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
# PENDENTE
- Ver sobre versão do TERRAFORM nos providers, pode estar quebrando o projeto.
- Tratar erros no Terraform Plan
https://github.com/fernandomullerjr/github-actions-terraform-eks-traefik-app/pull/1/checks
<https://github.com/fernandomullerjr/github-actions-terraform-eks-traefik-app/pull/1/checks>
- Fazer merge da branch "teste-branch-1" com a branch "main", para triggar o apply do Terraform.
- Video continua em:
16:19h
na criação do apply
- Ver sobre commits e histórico no Profile, na cobrinha.




teste3



# Dia 17
ver sobre versão do terraform nos providers





- Ajustando arquivo de versões:
eks/versions.tf
DE:
required_version = "~> 0.14"
PARA:
required_version = "1.3.8"




~~~~bash
Run terraform init
/home/runner/work/_temp/f15a73aa-cddd-4d60-b31d-54eb33ba489a/terraform-bin init
Initializing modules...
Downloading registry.terraform.io/terraform-aws-modules/eks/aws 19.10.0 for eks...
- eks in .terraform/modules/eks
- eks.eks_managed_node_group in .terraform/modules/eks/modules/eks-managed-node-group
- eks.eks_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data
- eks.fargate_profile in .terraform/modules/eks/modules/fargate-profile
Downloading registry.terraform.io/terraform-aws-modules/kms/aws 1.1.0 for eks.kms...
- eks.kms in .terraform/modules/eks.kms
- eks.self_managed_node_group in .terraform/modules/eks/modules/self-managed-node-group
- eks.self_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data
Downloading registry.terraform.io/terraform-aws-modules/vpc/aws 2.66.0 for vpc...
- vpc in .terraform/modules/vpc
╷
│ Error: Unsupported Terraform Core version
│ 
│   on versions.tf line 34, in terraform:
│   34:   required_version = "1.1.5"
│ 
│ This configuration does not support Terraform version 1.3.9. To proceed,
│ either choose another supported Terraform version or update this version
│ constraint. Version constraints are normally set for good reason, so
│ updating the constraint may lead to other errors or unexpected behavior.
╵

~~~~






- Passei para:
required_version = "1.3.9"








- Agora o erro é:

~~~~bash
0s
3s
Run terraform apply -auto-approve
/home/runner/work/_temp/31716924-4680-46d3-adc8-dce7c80fac18/terraform-bin apply -auto-approve
╷
│ Error: Unsupported argument
│ 
│   on eks-cluster.tf line 5, in module "eks":
│    5:   subnets         = module.vpc.public_subnets
│ 
│ An argument named "subnets" is not expected here.
╵
╷
│ Error: Unsupported argument
│ 
│   on eks-cluster.tf line 14, in module "eks":
│   14:   workers_group_defaults = {
│ 
│ An argument named "workers_group_defaults" is not expected here.
╵
╷
│ Error: Unsupported argument
│ 
│   on eks-cluster.tf line 18, in module "eks":
│   18:   worker_groups = [
│ 
│ An argument named "worker_groups" is not expected here.
╵

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
~~~~










- Testando a versão especifica no pipeline do Actions, para ele nao pegar a ultima versão do Terraform:

~> 0.14

    # Install the latest version of Terraform CLI and configure the Terraform CLI configuration file with a Terraform Cloud user API token
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v1
      with:
        terraform_version: 0.14.0







- PR com problemas, ficando em QUEUED os jobs, devido incidente no Github.



# PENDENTE
- PR com problemas, ficando em QUEUED os jobs, devido incidente no Github.
- Ver sobre TERRAFORM VERSION.
- Pegar versão especifica no pipeline do Actions, para ele nao pegar a ultima versão do Terraform:
            with:
              terraform_version: 0.14.0
- PR com problemas, ficando em QUEUED os jobs, devido incidente no Github.
- Tratar erros no Terraform Plan
https://github.com/fernandomullerjr/github-actions-terraform-eks-traefik-app/pull/1/checks
<https://github.com/fernandomullerjr/github-actions-terraform-eks-traefik-app/pull/1/checks>
- Fazer merge da branch "teste-branch-1" com a branch "main", para triggar o apply do Terraform.
- Video continua em:
16:19h
na criação do apply
- Ver sobre commits e histórico no Profile, na cobrinha.




- Fonte:
<https://developer.hashicorp.com/terraform/language/expressions/version-constraints>

~>: Allows only the rightmost version component to increment. For example, to allow new patch releases within a specific minor release, use the full version number: ~> 1.0.4 will allow installation of 1.0.5 and 1.0.10 but not 1.1.0. This is usually called the pessimistic constraint operator.






Novo PR - Teste branch 1 - Ajustada version
Modificada a version nos arquivos
github-actions-terraform-eks-traefik-app/eks/versions.tf
github-actions-terraform-eks-traefik-app/.github/workflows/eks.yaml
Necessário testar pipeline.


- Erro:

~~~~bash
Error: Unsupported Terraform Core version

  on .terraform/modules/eks/versions.tf line 2, in terraform:
   2:   required_version = ">= 1.0"

Module module.eks (from terraform-aws-modules/eks/aws) does not support
Terraform version 0.14.0. To proceed, either choose another supported
Terraform version or update this version constraint. Version constraints are
normally set for good reason, so updating the constraint may lead to other
errors or unexpected behavior.


Error: Unsupported Terraform Core version

  on .terraform/modules/eks/modules/_user_data/versions.tf line 2, in terraform:
   2:   required_version = ">= 1.0"

Module module.eks.module.eks_managed_node_group.module.user_data (from
../_user_data) does not support Terraform version 0.14.0. To proceed, either
choose another supported Terraform version or update this version constraint.
Version constraints are normally set for good reason, so updating the
constraint may lead to other errors or unexpected behavior.


Error: Unsupported Terraform Core version

  on .terraform/modules/eks/modules/_user_data/versions.tf line 2, in terraform:
   2:   required_version = ">= 1.0"

Module module.eks.module.self_managed_node_group.module.user_data (from
../_user_data) does not support Terraform version 0.14.0. To proceed, either
choose another supported Terraform version or update this version constraint.
Version constraints are normally set for good reason, so updating the
constraint may lead to other errors or unexpected behavior.


Error: Unsupported Terraform Core version

  on .terraform/modules/eks/modules/eks-managed-node-group/versions.tf line 2, in terraform:
   2:   required_version = ">= 1.0"

Module module.eks.module.eks_managed_node_group (from
./modules/eks-managed-node-group) does not support Terraform version 0.14.0.
To proceed, either choose another supported Terraform version or update this
version constraint. Version constraints are normally set for good reason, so
updating the constraint may lead to other errors or unexpected behavior.


Error: Unsupported Terraform Core version

  on .terraform/modules/eks/modules/fargate-profile/versions.tf line 2, in terraform:
   2:   required_version = ">= 1.0"

Module module.eks.module.fargate_profile (from ./modules/fargate-profile) does
not support Terraform version 0.14.0. To proceed, either choose another
supported Terraform version or update this version constraint. Version
constraints are normally set for good reason, so updating the constraint may
lead to other errors or unexpected behavior.


Error: Unsupported Terraform Core version

  on .terraform/modules/eks/modules/self-managed-node-group/versions.tf line 2, in terraform:
   2:   required_version = ">= 1.0"

Module module.eks.module.self_managed_node_group (from
./modules/self-managed-node-group) does not support Terraform version 0.14.0.
To proceed, either choose another supported Terraform version or update this
version constraint. Version constraints are normally set for good reason, so
updating the constraint may lead to other errors or unexpected behavior.


Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
~~~~









- Ajustando para
  required_version = "1.0.5"




git add .
git commit -m "CURSO devops-mao-na-massa-docker-kubernetes-rancher --- AULA 58. GitHub Actions - Terraform + EKS"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push








- Erro:

~~~~bash
0s
4s
Run terraform plan -no-color
/home/runner/work/_temp/478dd61f-cb07-434b-888b-db4a4d57620d/terraform-bin plan -no-color

Error: Unsupported argument

  on eks-cluster.tf line 5, in module "eks":
   5:   subnets         = module.vpc.public_subnets

An argument named "subnets" is not expected here.

Error: Unsupported argument

  on eks-cluster.tf line 14, in module "eks":
  14:   workers_group_defaults = {

An argument named "workers_group_defaults" is not expected here.

Error: Unsupported argument

  on eks-cluster.tf line 18, in module "eks":
  18:   worker_groups = [

An argument named "worker_groups" is not expected here.
~~~~










jabadia commented Jan 6, 2022

I found a temporary workaround: fix the version of eks module. I guess version 18 recently released breaks this code.

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  ...

jonathanmeier5 and evolart reacted with thumbs up emoji





- Adicionando no arquivo "github-actions-terraform-eks-traefik-app/eks/eks-cluster.tf":
version = "17.24.0"



~~~~h
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"
~~~~



~~~~bash
fernando@debian10x64:~/cursos/terraform/github-actions-terraform-eks-traefik-app$ terraform fmt
fernando@debian10x64:~/cursos/terraform/github-actions-terraform-eks-traefik-app$ terraform fmt -h
Usage: terraform [global options] fmt [options] [DIR]

        Rewrites all Terraform configuration files to a canonical format. Both
        configuration files (.tf) and variables files (.tfvars) are updated.
        JSON files (.tf.json or .tfvars.json) are not modified.

        If DIR is not specified then the current working directory will be used.
        If DIR is "-" then content will be read from STDIN. The given content must
        be in the Terraform language native syntax; JSON is not supported.

Options:

  -list=false    Don't list files whose formatting differs
                 (always disabled if using STDIN)

  -write=false   Don't write to source files
                 (always disabled if using STDIN or -check)

  -diff          Display diffs of formatting changes

  -check         Check if the input is formatted. Exit status will be 0 if all
                 input is properly formatted and non-zero otherwise.

  -no-color      If specified, output won't contain any color.

  -recursive     Also process files in subdirectories. By default, only the
                 given directory (or current directory) is processed.
fernando@debian10x64:~/cursos/terraform/github-actions-terraform-eks-traefik-app$ terraform fmt -recursive
eks/eks-cluster.tf
rascunho-fernando/eks-3.tf
fernando@debian10x64:~/cursos/terraform/github-actions-terraform-eks-traefik-app$
~~~~



git add .
git commit -m "CURSO devops-mao-na-massa-docker-kubernetes-rancher --- AULA 58. GitHub Actions - Terraform + EKS"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push

https://github.com/fernandomullerjr/github-actions-terraform-eks-traefik-app/pull/4/commits/cfb80960324559789632f18bc68243c7df89c62b


- OK!
- Commit "cfb80960324559789632f18bc68243c7df89c62b" passou o init e o plan, OK.
cfb80960324559789632f18bc68243c7df89c62b

- Necessário fazer o merge com a main, para validar o apply.



Ajustado version do Terraform para 1.0.5 nos versions e no pipeline.
Para o módulo do EKS, foi setada a version 17.24.0, que não estava setada manualmente.









Pull request successfully merged and closed

You’re all set—the teste-branch-1 branch can be safely deleted.



- Triggou a Action na main
 Merge pull request #4 from fernandomullerjr/teste-branch-1 - Mergeand… Terraform CI #24: Commit e59577a pushed by fernandomullerjr
main
February 18, 2023 18:51 In progress









- Erro durante apply:

~~~~bash

module.vpc.aws_nat_gateway.this[0]: Still creating... [1m10s elapsed]
module.vpc.aws_nat_gateway.this[0]: Still creating... [1m20s elapsed]
module.vpc.aws_nat_gateway.this[0]: Creation complete after 1m25s [id=nat-081186370d79e1124]
module.vpc.aws_route.private_nat_gateway[0]: Creating...
module.vpc.aws_route.private_nat_gateway[0]: Creation complete after 1s [id=r-rtb-0a3b91070834b3b491080289494]
╷
│ Error: creating EKS Cluster (devops-ninja-eks-SSSQrpuN): InvalidParameterException: unsupported Kubernetes version
│ {
│   RespMetadata: {
│     StatusCode: 400,
│     RequestID: "64ba0a36-755a-4051-b2d1-cbcef6ae6361"
│   },
│   ClusterName: "devops-ninja-eks-SSSQrpuN",
│   Message_: "unsupported Kubernetes version"
│ }
│ 
│   with module.eks.aws_eks_cluster.this[0],
│   on .terraform/modules/eks/main.tf line 11, in resource "aws_eks_cluster" "this":
│   11: resource "aws_eks_cluster" "this" {
│ 
╵

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/

Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
~~~~






- Ajustando
github-actions-terraform-eks-traefik-app/eks/eks-cluster.tf
de:
cluster_version = "1.18"
para:
cluster_version = "1.21"




git add .
git commit -m "AULA 58. GitHub Actions - Terraform + EKS. TSHOOT, terraform apply"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push







https://github.com/fernandomullerjr/github-actions-terraform-eks-traefik-app/pull/5

Terraform Format and Style 🖌success
Terraform Initialization ⚙️success
Terraform Plan 📖success

All checks have passed
1 successful check
@github-actions
Terraform CI / Terraform (pull_request) Successful in 41s
Details
This branch has no conflicts with the base branch
Merging can be performed automatically. 



- Mergeando

 Merge pull request #5 from fernandomullerjr/teste-branch-1 Terraform CI #26: Commit 98ec739 pushed by fernandomullerjr
main
February 18, 2023 19:14 Queued










- Criando cluster EKS

        },
    ]
  + kubectl_config      = (known after apply)
module.eks.aws_eks_cluster.this[0]: Creating...
module.eks.aws_eks_cluster.this[0]: Still creating... [10s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [20s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [30s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [40s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [50s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [1m0s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [1m10s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [1m20s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [1m30s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [1m40s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [1m50s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [2m0s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [2m10s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [2m20s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [2m30s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [2m40s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [2m50s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [3m0s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [3m10s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [3m20s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [3m30s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [3m40s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [3m50s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [4m0s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [4m10s elapsed]
module.eks.aws_eks_cluster.this[0]: Still creating... [4m20s elapsed]




- Erro

~~~~bash
rs[1]: Creation complete after 1s [id=devops-ninja-eks-SSSQrpuN20230218222436242400000002]
module.eks.aws_iam_instance_profile.workers[0]: Creation complete after 1s [id=devops-ninja-eks-SSSQrpuN20230218222436243700000003]
module.eks.aws_launch_configuration.workers[0]: Creating...
module.eks.kubernetes_config_map.aws_auth[0]: Creating...
module.eks.aws_launch_configuration.workers[1]: Creating...
module.eks.kubernetes_config_map.aws_auth[0]: Creation complete after 0s [id=kube-system/aws-auth]
module.eks.aws_launch_configuration.workers[1]: Creation complete after 10s [id=devops-ninja-eks-SSSQrpuN-worker-group-220230218222436921600000008]
module.eks.aws_launch_configuration.workers[0]: Creation complete after 10s [id=devops-ninja-eks-SSSQrpuN-worker-group-120230218222436910700000007]
module.eks.aws_autoscaling_group.workers[0]: Creating...
module.eks.aws_autoscaling_group.workers[1]: Creating...
╷
│ Error: waiting for Auto Scaling Group (devops-ninja-eks-SSSQrpuN-worker-group-22023021822244694250000000a) capacity satisfied: 1 error occurred:
│ 	* Scaling activity (4ea6199a-84fe-2a3c-41db-354193e680ac): Failed: Authentication Failure. Launching EC2 instance failed.
│ 
│ 
│ 
│   with module.eks.aws_autoscaling_group.workers[1],
│   on .terraform/modules/eks/workers.tf line 3, in resource "aws_autoscaling_group" "workers":
│    3: resource "aws_autoscaling_group" "workers" {
│ 
╵
╷
│ Error: waiting for Auto Scaling Group (devops-ninja-eks-SSSQrpuN-worker-group-120230218222446937500000009) capacity satisfied: 1 error occurred:
│ 	* Scaling activity (13d6199a-8540-85cf-c08c-e034cfd38c4d): Failed: Authentication Failure. Launching EC2 instance failed.
│ 
│ 
│ 
│   with module.eks.aws_autoscaling_group.workers[0],
│   on .terraform/modules/eks/workers.tf line 3, in resource "aws_autoscaling_group" "workers":
│    3: resource "aws_autoscaling_group" "workers" {
│ 
╵
~~~~



Terraform Error: waiting for Auto Scaling Group  Failed: Authentication Failure. Launching EC2 instance failed. aws_autoscaling_group workers eks












de:
instance_type                 = "t3a.micro"
para:
instance_type                 = "t3.micro"










- OK
- Resolvido após dar re-run, o ASG estava custando a provisionar.
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











- Depois disto, o Terraform fez o destroy de 2 ASG e deixou apenas os 2 ASG novos:

Auto Scaling groups (2)Info

	
Name
	
Launch template/configuration
	
Instances
	
Status
	
Desired capacity
	
Min
	
Max
	
Availability Zones
	
devops-ninja-eks-SSSQrpuN-worker-group-220230218224301411900000001
	devops-ninja-eks-SSSQrpuN-worker-group-220230218222436921600000008	1	-	1	1	3	us-east-2a, us-east-2b, us-east-2c
	
devops-ninja-eks-SSSQrpuN-worker-group-120230218224301424100000002
	devops-ninja-eks-SSSQrpuN-worker-group-120230218222436910700000007	1	-	1	1	3	us-east-2a, us-east-2b, us-east-2c








# PENDENTE
- Ver sobre o State, como fazer o destroy e tudo mais.
- Fazer KB.










# Conectar ao cluster

```sh

$ aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)

```


https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html

Pegar o kubeconfig
```sh
$ aws sts get-caller-identity

$ aws eks --region us-east-2 update-kubeconfig --name <NOME_CLUSTER>

$ cat ~/.kube/config
```



aws eks --region us-east-2 update-kubeconfig --name devops-ninja-eks-SSSQrpuN




- Pods em pending:

~~~~bash
fernando@debian10x64:~$ aws eks --region us-east-2 update-kubeconfig --name devops-ninja-eks-SSSQrpuN
Added new context arn:aws:eks:us-east-2:261106957109:cluster/devops-ninja-eks-SSSQrpuN to /home/fernando/.kube/config
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get pods
No resources found in default namespace.
fernando@debian10x64:~$ kubectl get pods -A
NAMESPACE     NAME                      READY   STATUS    RESTARTS   AGE
kube-system   coredns-f47955f89-pbz6b   0/1     Pending   0          34m
kube-system   coredns-f47955f89-wrs77   0/1     Pending   0          34m
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get nodes
No resources found
fernando@debian10x64:~$ kubectl get nodes -A
No resources found
fernando@debian10x64:~$

fernando@debian10x64:~$ kubectl get all -A
NAMESPACE     NAME                          READY   STATUS    RESTARTS   AGE
kube-system   pod/coredns-f47955f89-pbz6b   0/1     Pending   0          35m
kube-system   pod/coredns-f47955f89-wrs77   0/1     Pending   0          35m

NAMESPACE     NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
default       service/kubernetes   ClusterIP   172.20.0.1    <none>        443/TCP         36m
kube-system   service/kube-dns     ClusterIP   172.20.0.10   <none>        53/UDP,53/TCP   35m

NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kube-system   daemonset.apps/aws-node     0         0         0       0            0           <none>          35m
kube-system   daemonset.apps/kube-proxy   0         0         0       0            0           <none>          35m

NAMESPACE     NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   deployment.apps/coredns   0/2     2            0           35m

NAMESPACE     NAME                                DESIRED   CURRENT   READY   AGE
kube-system   replicaset.apps/coredns-f47955f89   2         2         0       35m
fernando@debian10x64:~$
~~~~







- Verificar como fazer pro EKS ler os ASG e adicionar os node-groups.







# PENDENTE


# PENDENTE
- Verificar como fazer pro EKS ler os ASG e adicionar os node-groups. Efetuar TSHOOT.
    https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html
- Ver sobre o State, como fazer o destroy e tudo mais.
- Fazer KB. Sobre o "~>". Sobre os versions do Terraform, EKS module, Github Actions Terraform version.
    https://developer.hashicorp.com/terraform/language/expressions/version-constraints
    https://github.com/hashicorp/learn-terraform-provision-eks-cluster/issues/53
    https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/17.24.0






- Criando via Console
Criação do grupo de nós em andamento
node-group-teste-1 está sendo criado. Esse processo pode levar vários minutos.



Status
Criando





- ERRO verificado via Console:

Seu usuário ou função atual não tem acesso a objetos do Kubernetes neste cluster do EKS nodegroup
Isso pode ocorrer porque o usuário ou a função atual não tem permissões RBAC do Kubernetes para descrever recursos de cluster ou não tem uma entrada no mapa de configuração de autenticação do cluster.Saiba mais 




kubectl describe configmap -n kube-system aws-auth

~~~~bash
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl describe configmap aws-auth
Error from server (NotFound): configmaps "aws-auth" not found
fernando@debian10x64:~$ kubectl describe configmap aws-auth -n kube-system
Name:         aws-auth
Namespace:    kube-system
Labels:       app.kubernetes.io/managed-by=Terraform
              terraform.io/module=terraform-aws-modules.eks.aws
Annotations:  <none>

Data
====
mapRoles:
----
- "groups":
  - "system:bootstrappers"
  - "system:nodes"
  "rolearn": "arn:aws:iam::261106957109:role/devops-ninja-eks-SSSQrpuN20230218222435567700000001"
  "username": "system:node:{{EC2PrivateDNSName}}"

mapUsers:
----
[]

mapAccounts:
----
[]


BinaryData
====

Events:  <none>
fernando@debian10x64:~$
~~~~







- EXEMPLO:

apiVersion: v1
data:
mapRoles: |
  - groups:
    - eks-console-dashboard-full-access-group
    rolearn: arn:aws:iam::111122223333:role/my-console-viewer-role
    username: my-console-viewer-role        
mapUsers: |
  - groups:
    - eks-console-dashboard-restricted-access-group
    userarn: arn:aws:iam::111122223333:user/my-user
    username: my-user

Important

The role ARN can't include a path such as role/my-team/developers/my-console-viewer-role. The format of the ARN must be arn:aws:iam::111122223333:role/my-console-viewer-role. In this example, my-team/developers/ needs to be removed.





- EXEMPLO 2:

apiVersion: v1
data:
  mapRoles: |
    - rolearn: arn:aws:iam::123456789012:role/EKS-WorkerNodes-NodeInstanceRole-1R46GDBD928V5
      username: system:node:{{EC2PrivateDNSName}}
      groups: 
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::123456789012:user/Alice
      username: alice
      groups: 
        - system:masters
    - userarn: arn:aws:iam::123456789012:group/eks-admin
      username: eks-admin
      groups: 
        - system:masters





kubectl edit configmap -n kube-system aws-auth

  mapUsers: |
    - userarn: arn:aws:iam::261106957109:user/fernandomullerjr8596
      username: fernandomullerjr8596
      groups: 
        - system:masters



fernando@debian10x64:~$ kubectl edit configmap -n kube-system aws-auth
configmap/aws-auth edited
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ date
Sat 18 Feb 2023 08:30:08 PM -03
fernando@debian10x64:~$



fernando@debian10x64:~$ kubectl describe configmap aws-auth -n kube-system
Name:         aws-auth
Namespace:    kube-system
Labels:       app.kubernetes.io/managed-by=Terraform
              terraform.io/module=terraform-aws-modules.eks.aws
Annotations:  <none>

Data
====
mapAccounts:
----
[]

mapRoles:
----
- "groups":
  - "system:bootstrappers"
  - "system:nodes"
  "rolearn": "arn:aws:iam::261106957109:role/devops-ninja-eks-SSSQrpuN20230218222435567700000001"
  "username": "system:node:{{EC2PrivateDNSName}}"

mapUsers:
----
- userarn: arn:aws:iam::261106957109:user/fernandomullerjr8596
  username: fernandomullerjr8596
  groups:
    - system:masters


BinaryData
====

Events:  <none>
fernando@debian10x64:~$







- Comparando
IAM:
arn:aws:iam::261106957109:role/devops-ninja-eks-SSSQrpuN20230218215142661500000001
Configmap:
"rolearn": "arn:aws:iam::261106957109:role/devops-ninja-eks-SSSQrpuN20230218222435567700000001"






kubectl edit configmap -n kube-system aws-auth

    - rolearn: arn:aws:iam::261106957109:role/devops-ninja-eks-SSSQrpuN20230218215142661500000001
      username: system:node:{{EC2PrivateDNSName}}
      groups: 
        - system:bootstrappers
        - system:nodes
        - system:masters



fernando@debian10x64:~$ kubectl edit configmap -n kube-system aws-auth
configmap/aws-auth edited
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl describe configmap aws-auth -n kube-system
Name:         aws-auth
Namespace:    kube-system
Labels:       app.kubernetes.io/managed-by=Terraform
              terraform.io/module=terraform-aws-modules.eks.aws
Annotations:  <none>

Data
====
mapAccounts:
----
[]

mapRoles:
----
- "groups":
  - "system:bootstrappers"
  - "system:nodes"
  "rolearn": "arn:aws:iam::261106957109:role/devops-ninja-eks-SSSQrpuN20230218222435567700000001"
  "username": "system:node:{{EC2PrivateDNSName}}"
- rolearn: arn:aws:iam::261106957109:role/devops-ninja-eks-SSSQrpuN20230218215142661500000001
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
    - system:masters

mapUsers:
----
- userarn: arn:aws:iam::261106957109:user/fernandomullerjr8596
  username: fernandomullerjr8596
  groups:
    - system:masters


BinaryData
====

Events:  <none>
fernando@debian10x64:~$ date
Sat 18 Feb 2023 08:33:54 PM -03
fernando@debian10x64:~$







Your current user or role does not have access to Kubernetes objects on this EKS cluster
This may be due to the current user or role not having Kubernetes RBAC permissions to describe cluster resources or not having an entry in the cluster’s auth config map



- Idéia

https://veducate.co.uk/aws-console-permission-eks-cluster/
<https://veducate.co.uk/aws-console-permission-eks-cluster/>

kubectl apply -f /home/fernando/cursos/terraform/github-actions-terraform-eks-traefik-app/rascunho-fernando/eks-console-full-access.yaml

fernando@debian10x64:~$ kubectl apply -f /home/fernando/cursos/terraform/github-actions-terraform-eks-traefik-app/rascunho-fernando/eks-console-full-access.yaml
clusterrole.rbac.authorization.k8s.io/eks-console-dashboard-full-access-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/eks-console-dashboard-full-access-binding created
fernando@debian10x64:~$




kubectl edit configmap/aws-auth -n kube-system



Add in the following under the data tree:

  mapUsers: |
    - userarn: arn:aws:iam::261106957109:user/fernandomullerjr8596
      username: admin
      groups:
        - system:masters



fernando@debian10x64:~$ kubectl edit configmap/aws-auth -n kube-system
configmap/aws-auth edited
fernando@debian10x64:~$ date
Sat 18 Feb 2023 09:05:55 PM -03
fernando@debian10x64:~$ kubectl describe configmap/aws-auth -n kube-system
Name:         aws-auth
Namespace:    kube-system
Labels:       app.kubernetes.io/managed-by=Terraform
              terraform.io/module=terraform-aws-modules.eks.aws
Annotations:  <none>

Data
====
mapAccounts:
----
[]

mapRoles:
----
- "groups":
  - "system:bootstrappers"
  - "system:nodes"
  "rolearn": "arn:aws:iam::261106957109:role/devops-ninja-eks-SSSQrpuN20230218222435567700000001"
  "username": "system:node:{{EC2PrivateDNSName}}"
- rolearn: arn:aws:iam::261106957109:role/devops-ninja-eks-SSSQrpuN20230218215142661500000001
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
    - system:masters

mapUsers:
----
- userarn: arn:aws:iam::261106957109:user/fernandomullerjr8596
  username: admin
  groups:
    - system:masters


BinaryData
====

Events:  <none>
fernando@debian10x64:~$





- Erro continua
Your current user or role does not have access to Kubernetes objects on this EKS cluster
This may be due to the current user or role not having Kubernetes RBAC permissions to describe cluster resources or not having an entry in the cluster’s auth config map.Learn more 
The Co





- Testando
kubectl apply -f /home/fernando/cursos/terraform/github-actions-terraform-eks-traefik-app/eks/kubernetes-dashboard-admin.rbac.yaml
kubectl edit configmap/aws-auth -n kube-system

fernando@debian10x64:~$ kubectl apply -f /home/fernando/cursos/terraform/github-actions-terraform-eks-traefik-app/eks/kubernetes-dashboard-admin.rbac.yaml
serviceaccount/admin-user created
clusterrolebinding.rbac.authorization.k8s.io/admin-user created
fernando@debian10x64:~$

fernando@debian10x64:~$ kubectl edit configmap/aws-auth -n kube-system
configmap/aws-auth edited
fernando@debian10x64:~$





- Criada a branch chamada
branch-destruidora

    - name: Terraform Destroy
      if: github.ref == 'refs/heads/branch-destruidora' && github.event_name == 'push'
      run: terraform destroy -auto-approve
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}



git add .
git commit -m "CURSO devops-mao-na-massa-docker-kubernetes-rancher --- AULA 58. GitHub Actions - Terraform + EKS"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push




github-actions bot commented Feb 18, 2023
Terraform Format and Style 🖌success
Terraform Initialization ⚙️success
Terraform Plan 📖success
Show Plan

Pusher: @fernandomullerjr, Action: pull_request

All checks have passed
1 successful check
@github-actions
Terraform CI / Terraform (pull_request) Successful in 38s
Details
This branch has no conflicts with the base branch
Merging can be performed automatically. 




Merge pull request #6 from fernandomullerjr/teste-branch-1
Teste branch 1 com a branch-destruidora


- Não triggou o destroy






- Erro continua
Your current user or role does not have access to Kubernetes objects on this EKS cluster
This may be due to the current user or role not having Kubernetes RBAC permissions to describe cluster resources or not having an entry in the cluster’s auth config map.Learn more


- AJUSTANDO
criando condition para destroy do Cluster EKS via pipeline.

on:
  
  push:
    branches:
      - main
      - branch-destruidora


git status
git add .
git commit -m "CURSO devops-mao-na-massa-docker-kubernetes-rancher --- AULA 58. GitHub Actions - Terraform + EKS"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push
git status




github-actions bot commented Feb 18, 2023
Terraform Format and Style 🖌success
Terraform Initialization ⚙️success
Terraform Plan 📖success
Show Plan

Pusher: @fernandomullerjr, Action: pull_request


All checks have passed
1 successful check
@github-actions
Terraform CI / Terraform (pull_request) Successful in 33s
Details
This branch has no conflicts with the base branch
Merging can be performed automatically. 



 Merge pull request #7 from fernandomullerjr/teste-branch-1 Terraform CI #29: Commit 3cbee36 pushed by fernandomullerjr
branch-destruidora 





Deleting NODE GROUP


0s
Started at 1676766532000
module.vpc.aws_internet_gateway.this[0]: Still destroying... [id=igw-0b07f6385db955545, 6m0s elapsed]
module.vpc.aws_internet_gateway.this[0]: Still destroying... [id=igw-0b07f6385db955545, 6m10s elapsed]
module.vpc.aws_internet_gateway.this[0]: Still destroying... [id=igw-0b07f6385db955545, 6m20s elapsed]



module.vpc.aws_internet_gateway.this[0]: Still destroying... [id=igw-0b07f6385db955545, 6m30s elapsed]
module.vpc.aws_internet_gateway.this[0]: Destruction complete after 6m38s
╷
│ Error: deleting EKS Cluster (devops-ninja-eks-SSSQrpuN): ResourceInUseException: Cluster has nodegroups attached
│ {
│   RespMetadata: {
│     StatusCode: 409,
│     RequestID: "1922a2cc-1106-47cb-96b1-eda9a7a36844"
│   },
│   ClusterName: "devops-ninja-eks-SSSQrpuN",
│   Message_: "Cluster has nodegroups attached",
│   NodegroupName: "node-group-teste-1"
│ }
│ 
│ 
╵









- destruidos

                - "token"
                - "-i"
                - "devops-ninja-eks-SSSQrpuN"
    EOT -> null
  - region                    = "us-east-2" -> null
module.eks.aws_eks_cluster.this[0]: Destroying... [id=devops-ninja-eks-SSSQrpuN]
module.eks.aws_eks_cluster.this[0]: Still destroying... [id=devops-ninja-eks-SSSQrpuN, 10s elapsed]
module.eks.aws_eks_cluster.this[0]: Still destroying... [id=devops-ninja-eks-SSSQrpuN, 20s elapsed]
module.eks.aws_eks_cluster.this[0]: Still destroying... [id=devops-ninja-eks-SSSQrpuN, 30s elapsed]
module.eks.aws_eks_cluster.this[0]: Still destroying... [id=devops-ninja-eks-SSSQrpuN, 40s elapsed]
module.eks.aws_eks_cluster.this[0]: Still destroying... [id=devops-ninja-eks-SSSQrpuN, 50s elapsed]
module.eks.aws_eks_cluster.this[0]: Still destroying... [id=devops-ninja-eks-SSSQrpuN, 1m0s elapsed]
module.eks.aws_eks_cluster.this[0]: Still destroying... [id=devops-ninja-eks-SSSQrpuN, 1m10s elapsed]
module.eks.aws_eks_cluster.this[0]: Still destroying... [id=devops-ninja-eks-SSSQrpuN, 1m20s elapsed]
module.eks.aws_eks_cluster.this[0]: Destruction complete after 1m24s
module.eks.aws_security_group_rule.cluster_https_worker_ingress[0]: Destroying... [id=sgrule-3551837232]
module.vpc.aws_subnet.public[1]: Destroying... [id=subnet-01c93e0c77b884900]
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy[0]: Destroying... [id=devops-ninja-eks-SSSQrpuN20230218215142661500000001-20230218215143422000000005]
module.vpc.aws_subnet.public[2]: Destroying... [id=subnet-0ee1fa147a5facd17]
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy[0]: Destroying... [id=devops-ninja-eks-SSSQrpuN20230218215142661500000001-20230218215143522900000007]
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceControllerPolicy[0]: Destroying... [id=devops-ninja-eks-SSSQrpuN20230218215142661500000001-20230218215143539300000008]
module.vpc.aws_subnet.public[0]: Destroying... [id=subnet-0fd1907e73600a101]
module.eks.aws_security_group_rule.cluster_egress_internet[0]: Destroying... [id=sgrule-470887055]
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceControllerPolicy[0]: Destruction complete after 0s
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy[0]: Destruction complete after 0s
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy[0]: Destruction complete after 0s
module.eks.aws_iam_role.cluster[0]: Destroying... [id=devops-ninja-eks-SSSQrpuN20230218215142661500000001]
module.eks.aws_iam_role.cluster[0]: Destruction complete after 0s
module.vpc.aws_subnet.public[2]: Destruction complete after 0s
module.vpc.aws_subnet.public[0]: Destruction complete after 0s
module.eks.aws_security_group_rule.cluster_https_worker_ingress[0]: Destruction complete after 0s
module.eks.aws_security_group.workers[0]: Destroying... [id=sg-0663727d343a9f66d]
module.vpc.aws_subnet.public[1]: Destruction complete after 0s
module.eks.aws_security_group_rule.cluster_egress_internet[0]: Destruction complete after 0s
module.eks.aws_security_group.cluster[0]: Destroying... [id=sg-047399f5e0e3c0681]
module.eks.aws_security_group.workers[0]: Destruction complete after 1s
module.eks.aws_security_group.cluster[0]: Destruction complete after 1s
module.vpc.aws_vpc.this[0]: Destroying... [id=vpc-0bf3fb417cc06c090]
module.vpc.aws_vpc.this[0]: Destruction complete after 0s
random_string.suffix: Destroying... [id=SSSQrpuN]
random_string.suffix: Destruction complete after 0s

Destroy complete! Resources: 14 destroyed.
::debug::Terraform exited with code 0.







- Outro dia:
    tentar:
    https://aws.amazon.com/pt/premiumsupport/knowledge-center/eks-kubernetes-object-access-error/
    tentar-2:
    https://varlogdiego.com/eks-your-current-user-or-role-does-not-have-access-to-kubernetes



# PENDENTE
- Pegar ajuda/suporte do Baraldi.
- Tratar erro da console do EKS:
    Your current user or role does not have access to Kubernetes objects on this EKS cluster
    This may be due to the current user or role not having Kubernetes RBAC permissions to describe cluster resources or not having an entry in the cluster’s auth config map.Learn more
    https://aws.amazon.com/pt/premiumsupport/knowledge-center/eks-kubernetes-object-access-error/
    tentar:
    https://aws.amazon.com/pt/premiumsupport/knowledge-center/eks-kubernetes-object-access-error/
    tentar-2:
    https://varlogdiego.com/eks-your-current-user-or-role-does-not-have-access-to-kubernetes
    PERGUNTA: https://www.udemy.com/course/devops-mao-na-massa-docker-kubernetes-rancher/learn/lecture/25888594#questions/19247906
- Verificar como fazer pro EKS ler os ASG e adicionar os node-groups. Efetuar TSHOOT, porque o cluster EKS não adiciona os workers/node-groups.
    https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html
    https://aws.amazon.com/pt/premiumsupport/knowledge-center/eks-kubernetes-object-access-error/
- Ver sobre o State, como fazer o destroy e tudo mais.
    Criado step que faz o destroy via Pipeline.
    ver como utilizar o State do S3 localmente. Alternar version do TF???
- Fazer KB. Sobre o "~>". Sobre os versions do Terraform, EKS module, Github Actions Terraform version.
    https://developer.hashicorp.com/terraform/language/expressions/version-constraints
    https://github.com/hashicorp/learn-terraform-provision-eks-cluster/issues/53
    https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/17.24.0
- Billing, acompanhar.







# Dia 19/02/2023

Domingo - 19:12h



git status
git add .
git commit -m "AULA 58. GitHub Actions - Terraform + EKS"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push
git status