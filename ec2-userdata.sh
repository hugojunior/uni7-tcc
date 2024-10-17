#!/bin/bash

# Atualizando o sistema e instalando pacotes necessários
yum update -y
yum install -y httpd
amazon-linux-extras install -y epel
yum install -y jq

# Iniciando e habilitando o Apache
systemctl enable httpd
systemctl start httpd

# Obtendo o token de acesso para a API de metadados da instância
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Obtendo informações da instância
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

# Criando a página HTML simples da nossa aplicação
cat > /var/www/html/index.html <<EOF
<!doctype html>
<html lang="en" class="h-100">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Arquiteturas Resilientes para Aplicações Escaláveis na AWS">
    <meta name="author" content="Hugo Júnior">
    <title>Arquiteturas Resilientes para Aplicações Escaláveis na AWS</title>
    <link href="https://getbootstrap.com/docs/5.0/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
  </head>
  <body class="d-flex flex-column h-100">
    <main class="flex-shrink-0">
      <div class="container">
        <h1 class="mt-5">UNI7 - Trabalho de Conclusão de Curso</h1>
        <p class="lead">Arquiteturas Resilientes para Aplicações Escaláveis na AWS.</p>
        <hr>
        <div class="card">
          <h5 class="card-header">Informações da Instância EC2</h5>
          <div class="card-body">
            <p><strong>ID:</strong> <span class="text-primary">${INSTANCE_ID}</span></p>
            <p><strong>Zona de disponibilidade:</strong> <span class="text-primary">${AVAILABILITY_ZONE}</span></p>
          </div>
        </div>
        <div class="card mt-3">
          <h5 class="card-header">Conteúdo a ser carregado</h5>
          <div class="card-body">
            <p>
              <img src="mac-computer-on-desk.jpg" width="150" class="rounded mt-1">
              <img src="man-watches-laptop.jpg" width="150" class="rounded mt-1">
              <img src="woman-works-on-bright-computer-screens.jpg" width="150" class="rounded mt-1">
              <img src="man-at-computer-using-trackpad.jpg" width="150" class="rounded mt-1">
            </p>
            <ul class="list-unstyled ">
              <li><small>As imagens acima estão armazenadas no mesmo diretório da aplicação com o objetivo de sobrecarregar a instância durante os testes de desempenho.</small></li>
              <li><small>As imagens foram obtidas no <a href="https://www.shopify.com/stock-photos" target="_blank">Shopify Stock Photos</a>, um banco de imagens gratuitas.</small></li>
            </ul>
          </div>
        </div>
      </div>
    </main>
    <footer class="footer mt-auto text-center py-3 bg-light">
      <div class="container">
        <span class="text-muted">Aplicação desenvolvida por <a href="https://github.com/hugojunior" target="_blank" class="fw-bold">Hugo Júnior</a> para simulação de testes de carga.</span>
      </div>
    </footer>   
  </body>
</html>
EOF

# Baixando 4 imagens do GitHub e salvando no mesmo diretório do index.html
curl -o /var/www/html/mac-computer-on-desk.jpg https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/mac-computer-on-desk.jpg
curl -o /var/www/html/man-at-computer-using-trackpad.jpg https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/man-at-computer-using-trackpad.jpg
curl -o /var/www/html/man-watches-laptop.jpg https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/man-watches-laptop.jpg
curl -o /var/www/html/woman-works-on-bright-computer-screens.jpg https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/woman-works-on-bright-computer-screens.jpg

# Alterando permissões dos arquivos
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/mac-computer-on-desk.jpg
chmod 644 /var/www/html/man-at-computer-using-trackpad.jpg
chmod 644 /var/www/html/man-watches-laptop.jpg
chmod 644 var/www/html/woman-works-on-bright-computer-screens.jpg
