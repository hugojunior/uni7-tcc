CREATE DATABASE tccdatabase;

USE tccdatabase;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  phone VARCHAR(20),
  birth_date DATE,
  image VARCHAR(255)
);

INSERT INTO users (name, email, phone, birth_date, image) VALUES
('Ana Souza', 'ana.souza@example.com', '(85) 98765-4321', '1990-03-12', 'images/ana-souza.png'),
('Bruno Lima', 'bruno.lima@example.com', '(11) 99887-6543', '1985-07-15', 'images/bruno-lima.png'),
('Carla Oliveira', 'carla.oliveira@example.com', '(21) 91234-5678', '1995-11-23', 'images/carla-oliveira.png'),
('Daniel Ferreira', 'daniel.ferreira@example.com', '(31) 97654-3210', '1988-05-02', 'images/daniel-ferreira.png'),
('Fernanda Melo', 'fernanda.melo@example.com', '(61) 98123-4567', '1992-09-19', 'images/fernanda-melo.png');
