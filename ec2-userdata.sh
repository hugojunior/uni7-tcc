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
  <body class="d-flex flex-column h-100" style="background-color:#f0f0f0">
    <main class="flex-shrink-0">
      <div class="container">
        <h1 class="mt-5">UNI7 - Trabalho de Conclusão de Curso</h1>
        <p class="lead text-primary pb-4"><strong>Arquitetura AWS Resiliente e Escalável:</strong> Implementação e Avaliação de um Cenário Real.</p>
        <div class="card">
          <h5 class="card-header">Dados da Instância em execução (EC2)</h5>
          <div class="card-body">
            <p>Identificador: <span class="text-primary h5">${INSTANCE_ID}</span></p>
            <p>Zona de disponibilidade: <span class="text-primary h5">${AVAILABILITY_ZONE}</span></p>
          </div>
        </div>
        <div class="card mt-3">
          <h5 class="card-header">Dados do Banco de Dados (RDS)</h5>
          <div class="card-body p-0">
            <table class="table table-striped align-middle m-0">
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
                
                // Consultando dados da tabela 'users'
                \$sql = "SELECT name, email, phone, birth_date, image FROM users";
                \$result = \$conn->query(\$sql);

                if (\$result->num_rows > 0) {
                    while(\$row = \$result->fetch_assoc()) {
                        echo "<tr>";
                        echo "<td><img src='" . \$row['image'] . "' alt='Foto de " . \$row['name'] . "' height='40'></td>";
                        echo "<td>" . \$row['name'] . "</td>";
                        echo "<td>" . \$row['email'] . "</td>";
                        echo "<td>" . \$row['phone'] . "</td>";
                        echo "<td>" . date("d/m/Y", strtotime(\$row['birth_date'])) . "</td>";
                        echo "</tr>";
                    }
                }
                \$conn->close();
                
                // Função de cálculo pesado para simular uso de CPU
                function heavyCalculation(\$n) {
                    \$result = 0;
                    for (\$i = 0; \$i < \$n; \$i++) {
                        \$result += sqrt(\$i) * log(\$i + 1);
                    }
                    return \$result;
                }
                heavyCalculation(100000);
              ?>
              </tbody>
            </table>
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
curl -o /var/www/html/images/ana-souza.png https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/app/images/ana-souza.png
curl -o /var/www/html/images/bruno-lima.png https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/app/images/bruno-lima.png
curl -o /var/www/html/images/carla-oliveira.png https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/app/images/carla-oliveira.png
curl -o /var/www/html/images/daniel-ferreira.png https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/app/images/daniel-ferreira.png
curl -o /var/www/html/images/fernanda-melo.png https://raw.githubusercontent.com/hugojunior/uni7-tcc/refs/heads/main/app/images/fernanda-melo.png

# Alterando permissões dos arquivos
chmod 644 /var/www/html/index.php
chmod 644 /var/www/html/images/ana-souza.png
chmod 644 /var/www/html/images/bruno-lima.png
chmod 644 /var/www/html/images/carla-oliveira.png
chmod 644 /var/www/html/images/daniel-ferreira.png
chmod 644 /var/www/html/images/fernanda-melo.png