#!/bin/bash

# Atualizando o sistema e instalando pacotes necessários
yum update -y
amazon-linux-extras install -y epel php8.1 mariadb10.5
yum install -y httpd

# Iniciando e habilitando o Apache
systemctl enable httpd
systemctl start httpd

# Definindo variáveis de conexão ao MySQL
DB_HOST="<rds-endpoint>"
DB_PORT="3306"
DB_USER="tccuser"
DB_PASS="tccpassword"
DB_NAME="tccdatabase"

# Obtendo o token de acesso para a API de metadados da instância
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Obtendo informações da instância
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

# Criando a página da nossa aplicação
cat > /var/www/html/index.php <<EOF
<!doctype html>
<html lang="en" class="h-100">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Arquitetura AWS Resiliente e Escalável: Implementação e Avaliação de um Cenário Real">
    <meta name="author" content="Hugo Júnior">
    <title>Arquitetura AWS Resiliente e Escalável: Implementação e Avaliação de um Cenário Real</title>
    <link href="https://getbootstrap.com/docs/5.0/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
  </head>
  <body class="d-flex flex-column h-100">
    <main class="flex-shrink-0">
      <div class="container">
        <h1 class="mt-5">UNI7 - Trabalho de Conclusão de Curso</h1>
        <p class="lead"><strong>Arquitetura AWS Resiliente e Escalável:</strong> Implementação e Avaliação de um Cenário Real.</p>
        <hr>
        <div class="card">
          <h5 class="card-header">Dados da Instância EC2</h5>
          <div class="card-body">
            <p><strong>ID:</strong> <span class="text-primary">${INSTANCE_ID}</span></p>
            <p><strong>Zona de disponibilidade:</strong> <span class="text-primary">${AVAILABILITY_ZONE}</span></p>
          </div>
        </div>
        <div class="card mt-3">
          <h5 class="card-header">Dados do RDS (MySQL)</h5>
          <div class="card-body p-0">
            <table class="table table-striped">
              <thead>
                <tr>
                  <th scope="col"></th>
                  <th scope="col">Nome</th>
                  <th scope="col">E-mail</th>
                  <th scope="col">Telefone</th>
                  <th scope="col">Nascimento</th>
                </tr>
              </thead>
              <tbody>
              <?php
                // Conexão ao banco de dados
                \$conn = new mysqli('$DB_HOST', '$DB_USER', '$DB_PASS', '$DB_NAME', '$DB_PORT');
                if (\$conn->connect_error) {
                    die("Falha na conexão com o banco de dados: " . \$conn->connect_error);
                }
                
                // Consultando dados da tabela 'peoples'
                \$sql = "SELECT name, email, phone, birth_date, image FROM peoples";
                \$result = \$conn->query(\$sql);

                if (\$result->num_rows > 0) {
                    while(\$row = \$result->fetch_assoc()) {
                        echo "<tr>";
                        echo "<td><img src='" . \$row['image'] . "' alt='Foto de " . \$row['name'] . "' height='50' class='rounded'></td>";
                        echo "<td>" . \$row['name'] . "</td>";
                        echo "<td>" . \$row['email'] . "</td>";
                        echo "<td>" . \$row['phone'] . "</td>";
                        echo "<td>" . date("d/m/Y", strtotime(\$row['birth_date'])) . "</td>";
                        echo "</tr>";
                    }
                }
                \$conn->close();
              ?>
              </tbody>
            </table>
            <ul class="list-unstyled px-3">
              <li><small>As imagens foram propositalmente adicionadas em alta resolução, com o objetivo de tornar a página mais pesada para os testes de desempenho.</small></li>
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

# Criando o diretório de imagens
mkdir -p /var/www/html/images

# Baixando imagens do GitHub e salvando no diretório de imagens
curl -o /var/www/html/images/smiling-man-in-blue.jpg https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/app/images/smiling-man-in-blue.jpg
curl -o /var/www/html/images/stylish-woman-wearing-sunglasses.jpg https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/app/images/stylish-woman-wearing-sunglasses.jpg
curl -o /var/www/html/images/the-man-in-the-hat.jpg https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/app/images/the-man-in-the-hat.jpg
curl -o /var/www/html/images/woman-in-office.jpg https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/app/images/woman-in-office.jpg
curl -o /var/www/html/images/woman-talking-during-meeting.jpg https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/app/images/woman-talking-during-meeting.jpg

# Alterando permissões dos arquivos
chmod 644 /var/www/html/index.php
chmod 644 /var/www/html/images/smiling-man-in-blue.jpg
chmod 644 /var/www/html/images/stylish-woman-wearing-sunglasses.jpg
chmod 644 /var/www/html/images/the-man-in-the-hat.jpg
chmod 644 /var/www/html/images/woman-in-office.jpg
chmod 644 /var/www/html/images/woman-talking-during-meeting.jpg