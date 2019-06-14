#!/bin/bash

echo -e "*********** Criando Maquina Virtual na Google Cloud ***********"
cd terraform_gc
terraform apply -auto-approve
GCIP=$(terraform output | grep '"nat_ip" =' | cut '-d"' -f4)

echo -e "*********** Criando Maquina Virtual na AWS ***********"
cd ../terraform_aws
terraform apply -auto-approve
AWSIP=$(terraform output | cut '-d ' -f3)

echo -e "*********** Criando Maquina Virtual na Azure ***********"
cd ../terraform_azu
terraform apply -auto-approve
AZUIP=$(terraform output | cut '-d ' -f3)

echo -e "*********** Adicionando IP ao inventario Ansible ***********"
echo "[webserver]" > ../ansible/hosts
echo "$GCIP" >> ../ansible/hosts
echo "$AWSIP" >> ../ansible/hosts
echo "$AZUIP" >> ../ansible/hosts

echo -e "*********** Adicionando o fingerprint ***********"
ssh-keyscan -H $GCIP >> ~/.ssh/known_hosts
ssh-keyscan -H $AWSIP >> ~/.ssh/known_hosts
ssh-keyscan -H $AZUIP >> ~/.ssh/known_hosts

echo -e "*********** Orquestrando Aplicacao Web ***********"
cd ../ansible
ansible-playbook -i hosts apache.yml
ansible-playbook -i hosts -u ubuntu apache.yml

echo -e "*********** Testando pagina web ***********"
echo -e "Google Cloud"
curl $GCIP
echo -e "AWS"
curl $AWSIP
echo -e "Azure"
curl $AZUIP
