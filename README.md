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
   
   2.2. Agora devemos começar a criar as <i> maquinas virtuais e suas dependencias</i>: <br>
    &nbsp; 2.2.1. Google Cloud:
    
    &nbsp;&nbsp;<b>vminstance.tf:</b>
    
    ```
    resource "google_compute_instance" "ProjetoTerraform" {
     name         = "projterra-vm-1"
     machine_type = "f1-micro"
     zone         = "southamerica-east1-b"

     boot_disk {
      initialize_params {
      image = "debian-cloud/debian-9"
      }
     }

     network_interface {
      network   = "default"
      access_config {
      }
     }
    }

    ```
    
    O recurso acima, <a href="https://www.terraform.io/docs/providers/google/r/compute_instance.html">google_compute_instance</a> , irá criar uma maquina virtual na Google Cloud.
    
    &nbsp;&nbsp;metadata.tf:
    ```
    resource "google_compute_project_metadata_item" "user" {
     key   = "ssh-keys"
     value = "User:${file("~/.ssh/id_rsa.pub")}" 
    }
    ```
    O recurso acima, <a href="https://www.terraform.io/docs/providers/google/r/compute_project_metadata_item.html"> google_compute_project_metadata_item </a> , ele vai exportar sua chave pública para a maquina virtual criada.
    
     &nbsp;&nbsp;firewall.tf:
     ```
     resource "google_compute_firewall" "firewall" {
      name    = "allowhttp"
      network = "default"
  
      allow {
       protocol = "tcp"
       ports    = ["80"]
      }
     }

     ```
     O recurso acima, <a href="https://www.terraform.io/docs/providers/google/r/compute_firewall.html"> google_compute_firewall </a> , vai habilitar o no firewall o trafego na porta 80.
    
    &nbsp;2.2.2. AWS:
    
    &nbsp;ec2.tf:
    ```   
    resource "aws_instance" "ec2" {
     ami                         = "ami-09f4cd7c0b533b081"
     instance_type               = "t2.micro"
     key_name                    = "${aws_key_pair.terraform.id}"
     vpc_security_group_ids      = ["${aws_security_group.allow_ssh_http.id}"]
     subnet_id                   = "subnet-52df0f09"
    }
    ```
    O recurso acima, <a href="https://www.terraform.io/docs/providers/aws/r/instance.html"> aws_instance </a> , vai criar uma ec2 na AWS.
    
    &nbsp;ssh_key.tf:
    ```
    resource "aws_key_pair" "terraform" {
     key_name   = "id_rsa"
     public_key = "${file("~/.ssh/id_rsa.pub")}"
    }
    ```
    O recurso acima, <a href="https://www.terraform.io/docs/providers/aws/r/key_pair.html"> aws_key_pair </a> ,ele vai exportar sua chave pública para a ec2 criada.
    
    &nbsp;security_group.tf:
   ```
    resource "aws_security_group" "allow_ssh_http" {
      name        = "allow_ssh_http"
      description = "Abir entrada ssh e http"
      vpc_id      = "vpc-4f0a5228"

      ingress {
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }

     ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
     }
     egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
     }
    }
   ```
    O recurso acima,<a href="https://www.terraform.io/docs/providers/aws/r/security_group.html"> aws_security_group </a> , vai configurar o firewall para que permita a entrada nas portas 22 e 80, e permitir a saida em qualquer porta.

 
