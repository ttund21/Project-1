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
   
2. Começar a escrever seu código no Terraform: <br>
  2.1. Primeiro devemos criar o nosso arquivo <i >main.tf </i> que vai nós dar acesso ao Terraform à nossa Cloud.  
   &nbsp;<b>2.1.1. Google Cloud:</b>
   ```
    provider "google" { 
     credentials = "${file("Sua_credencial_da_conta_de_servico.json")}"
     project     = "nomedoprojeto"
     region      = "southamerica-east1"
    }
   ```
   Primeiro deve-se criar no seu console da google cloud um <a href="https://support.google.com/a/answer/7378726?hl=pt-BR">projeto e uma conta de serviço </a>, após criado você deve adicionar sua credencial .json na linha credentials e o nome do seu projeto na linha project. Após configurado o main.tf execute em seu terminal o comando <b> terraform init </b>, para que o terraform baixe os plugins do provider.
   
   &nbsp; <b>2.1.2. AWS:</b>
   ```
   provider "aws" {
    access_key = "Sua access key"
    secret_key = "Sua secret key"
    region     = "sa-east-1"
   }
   ```
   Aqui você deve gerar <a href="https://docs.aws.amazon.com/pt_br/IAM/latest/UserGuide/id_credentials_access-keys.html"> uma chave de acesso </a> e prencher as linhas de acordo com as informções do arquivo .csv baixado. Após configurado o main.tf execute em seu terminal o comando <b> terraform init </b>, para que o terraform baixe os plugins do provider.
   
   &nbsp; <b>2.1.3. Azure:</b> 
   ```
   provider "azurerm" {
    version = "1.29.0"
   }
   ```
   No azure para configurar o provider é um pouco diferente, primeiro você tem que <a href="https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli?view=azure-cli-latest"> instalar a CLI do azure na sua maquina </a> , após a instalação você deve fazer o logon com terminal usando o comando <a href="https://docs.microsoft.com/pt-br/cli/azure/authenticate-azure-cli?view=azure-cli-latest"> az login </a> . Após fazer o login só adicionar uma versão linha version e usar o comando <b> terraform init </b>, para que o terraform baixe os plugins do provider.
   
   2.2. Agora devemos começar a criar as <i> maquinas virtuais e suas dependencias</i>: <br>
    &nbsp; <b>2.2.1. Google Cloud:</b>
    
    &nbsp;&nbsp;vminstance.tf:
    
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
    
    &nbsp;<b>2.2.2. AWS:</b>
    
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
    
    &nbsp;<b>2.2.2. Azure:</b>
    
    &nbsp;virtual_machine.tf:
    ```
    resource "azurerm_virtual_machine" "terraform-vm" {
     name                  = "terraform-vm"
     location              = "${azurerm_resource_group.terraform-rg.location}"
     resource_group_name   = "${azurerm_resource_group.terraform-rg.name}"
     vm_size               = "Standard_B1ls"
     network_interface_ids = ["${azurerm_network_interface.terraform-netint.id}"]

     storage_image_reference {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "16.04-LTS"
      version   = "latest"
    }

     storage_os_disk {
      name              = "terraform_osdisk"
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Standard_LRS"
    }

    os_profile {
      computer_name  = "terraform"
      admin_username = "Damocles"
    }

    os_profile_linux_config {
      disable_password_authentication = true
      ssh_keys {
        path     = "/home/Damocles/.ssh/authorized_keys"
        key_data = "${file("~/.ssh/id_rsa.pub")}"
      }
     }
    }
    ```
    O recurso acima, <a href="https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html"> azurerm_virtual_machine </a> , vai subir uma maquina virtual no Azure.
    
    &nbsp;resource_group.tf:
    ```   
    resource "azurerm_resource_group" "terraform-rg" {
     name     = "terraform-rg"
     location = "brazilsouth"
    }
    ```
    O recurso acima, <a href="https://www.terraform.io/docs/providers/azurerm/r/resource_group.html">azurerm_resource_group</a> , criará um grupo de recurso.
    
    &nbsp;network_interface.tf:
    ```
    resource "azurerm_network_interface" "terraform-netint" {
     name                      = "terraform-netint"
     location                  = "${azurerm_resource_group.terraform-rg.location}"
     resource_group_name       = "${azurerm_resource_group.terraform-rg.name}"
     network_security_group_id = "${azurerm_network_security_group.terraform-sg.id}"

     ip_configuration {
      name                          = "testconf"
      subnet_id                     = "${azurerm_subnet.terraform-subnet.id}"
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = "${azurerm_public_ip.terraform-publicip.id}"
     }
    }
    ```
    O recurso acima, <a href="https://www.terraform.io/docs/providers/azurerm/r/network_interface.html"> azurerm_network_interface </a>, criará uma interface de rede para a maquina virtual.
    
    &nbsp;public_ip.tf:
    ```
    resource "azurerm_public_ip" "terraform-publicip" {
     name                = "terraform-puclicip"
     location            = "${azurerm_resource_group.terraform-rg.location}"
     resource_group_name = "${azurerm_resource_group.terraform-rg.name}"
     allocation_method   = "Static"
     domain_name_label   = "terraform"
    }
    ```
    O recurso acima, <a href="https://www.terraform.io/docs/providers/azurerm/r/public_ip.html"> azurerm_public_ip </a> , criará um ip público.
    
    &nbsp;security_group.tf:
    ```
    resource "azurerm_network_security_group" "terraform-sg" {
     name                = "terraform-sg"
     location            = "${azurerm_resource_group.terraform-rg.location}"
     resource_group_name = "${azurerm_resource_group.terraform-rg.name}"
     
     security_rule {
      name                       = "HTTP"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
     }
     
     security_rule {
      name                       = "SSH"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
     }
    }
    ```
    &nbsp;subnet.tf:
    ```
    resource "azurerm_subnet" "terraform-subnet" {
     name                 = "terraform-subnet"
     virtual_network_name = "${azurerm_virtual_network.terraform-vnet.name}"
     resource_group_name  = "${azurerm_resource_group.terraform-rg.name}"
     address_prefix       = "10.0.2.0/24"
    }
    ```
    O recurso acima, <a href="https://www.terraform.io/docs/providers/azurerm/r/subnet.html"> azurerm_subnet </a> ,  criará uma sub-rede.
    
    &nbsp;virtual_network.tf:
    ```
    resource "azurerm_virtual_network" "terraform-vnet" {
     name                = "terraform-vnet"
     location            = "${azurerm_resource_group.terraform-rg.location}"
     resource_group_name = "${azurerm_resource_group.terraform-rg.name}"
     address_space       = ["10.0.0.0/16"]
    }
    ```
    O recurso acima,<a href="https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html"> azurerm_virtual_network </a> , criará uma rede virtual.
    
    <u>3. Usar o Terraform no terminal</u> <br>
    &nbsp;3.1. No mesmo diretorio aonde você criou seus arquivos digite os seguites comandos:
    <ul>
     <li><a href="https://www.terraform.io/docs/commands/plan.html">terraform plan</a></li>
     <i>Esse comando mostrará um plano de execução.</i>
     <li><a href="https://www.terraform.io/docs/commands/apply.html">terraform apply</a></li>
     <i>Esse comando irá aplicar as configurações</i>
     <li><a href="https://www.terraform.io/docs/commands/show.html"> terraform show </a></li>
     <i>Esse comando irá te mostrar as informações do que foi criado.</i>
    </ul>
    <br>
       
    <u>4. Orquestrando uma aplicação web com o Ansible.</u> <br>
    &nbsp;4.1. Primeiro devemos criar uma diretorio para o ansible, dentro desse diretorio devemos criar um arquivo chamado hosts, que vai ser o nosso <a href="https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html"> inventário </a> ,vai ser onde vai ser declarado os host-alvos e os nós.
    ```
    [WebServer]
    192.168.1.2
    ```
    Acima há um exemplo de inventário, nesse exemplo temos "[WebServer]" que é um tag criada para o host-alvo "192.168.1.2". Então o que você tem que fazer é colocar ip da sua maquina e criar uma tag (<i>lembrando que o ip da sua maquina virtual você consegue usando terraform show no diretorio que vc criou os arquivos .tf</i>), exemplo:
    ```
    [nome_qualquer_da_sua_tag]
    ip_da_sua_maquina_virtual
    ```
    
    &nbsp;4.2. Após a criação do inventario, ainda no diretorio criado para o ansible, vamos fazer um teste usando <a href="https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html">comando ad-hoc</a> com o <a href="https://docs.ansible.com/ansible/latest/modules/ping_module.html#ping-module"> modulo ping </a> para testar a comunicação com a maquina virtual.
    ```
    ansible all -i hosts -m ping
    ```
