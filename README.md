# Project#1

<b>Objetivos:</b>
<ol>
  <li> Provisionar uma máquina virtual em três clouds diferentes.</li>
  <li> Orquestrar uma aplicação web nas tres maquinas virtuais. </li>
</ol>

<b>Ferramentas usadas:</b>
<ul>
  <li> Linux </li>
  <li> <a href=https://www.terraform.io/> Terraform v0.12.0 </a> </li>
  <li> <a href=https://www.ansible.com/> Ansible v2.8.0 </a> </li>
  <li> <a href=https://cloud.google.com/> Google Cloud </a> </li>
  <li> <a href=https://aws.amazon.com/> AWS </a> </li>
  <li> <a href=https://azure.microsoft.com/> Azure </a> </li>
</ul>

<b>Passo a Passo:</b>
1.  Primeiro devemos fazer a instalaçao do Terraform e do Ansible. 
   <ul>
     <li> <a href="http://blog.aeciopires.com/conhecendo-o-terraform/"> Guia de Instalação do Terraform </a> </li>
     <li> <a href="http://ebasso.net/wiki/index.php?title=Ansible:_Instalando_e_Configurando_o_Ansible"> Guia de Instalação do Ansible </a> </li>
   </ul>
   
2. Começar a usar o Terraform: <br>
  2.1. Primeiro devemos criar o nosso arquivo <i >main.tf </i> que vai nós dar acesso ao Terraform à nossa Cloud.  
   &nbsp;2.1.1. Google Cloud:  
   ```
    provider "google" { 
     credentials = "${file("Sua_credencial_da_conta_de_servico.json")}"
     project     = "nomedoprojeto"
     region      = "southamerica-east1"
    }
   ```
   Primeiro deve-se criar no seu console da google cloud um <a href="https://support.google.com/a/answer/7378726?hl=pt-BR">projeto e uma conta de serviço </a>, após criado você deve adicionar sua credencial .json na linha credentials e o nome do seu projeto na linha project. Após configurado o main.tf execute em seu terminal o comando <b> terraform init </b>, para que o terraform baixe os plugins do provider.
   
   &nbsp; 2.1.2. AWS: 
   ```
   provider "aws" {
    access_key = "Sua access key"
    secret_key = "Sua secret key"
    region     = "sa-east-1"
   }
   ```
   Aqui você deve gerar <a href="https://docs.aws.amazon.com/pt_br/IAM/latest/UserGuide/id_credentials_access-keys.html"> uma chave de acesso </a> e prencher as linhas de acordo com as informções do arquivo .csv baixado. Após configurado o main.tf execute em seu terminal o comando <b> terraform init </b>, para que o terraform baixe os plugins do provider.
   
   &nbsp; 2.1.3. Azure: 
   ```
   provider "azurerm" {
    version = "1.29.0"
   }
   ```
   No azure para configurar o provider é um pouco diferente, primeiro você tem que <a href="https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli?view=azure-cli-latest"> instalar a CLI do azure na sua maquina </a> , após a instalação você deve fazer o logon com terminal usando o comando <a href="https://docs.microsoft.com/pt-br/cli/azure/authenticate-azure-cli?view=azure-cli-latest"> az login </a> . Após fazer o login só adicionar uma versão linha version e usar o comando <b> terraform init </b>, para que o terraform baixe os plugins do provider.



