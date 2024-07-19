create schema Hoteles;
use Hoteles;

create table hotel(
hotel_id int auto_increment not null,
nombre varchar(50) not null,
direccion varchar(50) not null,
categoria varchar(20),
estrellas int,
primary key(hotel_id)
);

create table habitacion (
habitacion_id int auto_increment not null ,
precio varchar(10),
capacidad varchar(10),
estado varchar(10) not null,
primary key(habitacion_id)
);

create table cliente (
cliente_id int auto_increment not null,
nombre varchar(50) not null,
apellido varchar(50) not null,
email varchar(30) not null,
telefono varchar(20),
primary key(cliente_id)
);

create table reserva (
reserva_id int auto_increment not null,
cliente_id int,
habitacion_id int,
fecha_entrada varchar(20),
fecha_salida varchar(20),
primary key(reserva_id),
foreign key(cliente_id) references cliente(cliente_id),
foreign key(habitacion_id) references habitacion(habitacion_id)
);

create table empleado (
empleado_id int not null auto_increment,
nombre varchar(50) not null,
apellido varchar(50) not null,
cargo varchar(30) not null,
fecha_contratacion varchar(30),
primary key(empleado_id)
);

-- modificaciones luego de la primera preentrega--

alter table hotel modify column estrellas decimal(2,1);
alter table habitacion modify column precio decimal, modify column capacidad int;
alter table reserva modify column fecha_entrada date, modify column fecha_salida date;

ALTER TABLE habitacion
ADD COLUMN hotel_id INT;
ALTER TABLE habitacion
ADD CONSTRAINT FOREIGN KEY (hotel_id) REFERENCES hotel(hotel_id);

ALTER TABLE empleado
ADD COLUMN hotel_id INT;
ALTER TABLE empleado
ADD CONSTRAINT FOREIGN KEY (hotel_id) REFERENCES hotel(hotel_id);

-- incercion de datos --

INSERT INTO hotel (nombre, direccion, categoria, estrellas) VALUES
('Hotel Sunshine', '123 Sunny Road', 'Luxury', 9.3),
('Hotel Oceanview', '456 Beach Ave', 'Resort', 6.5),
('Hotel Mountain', '789 Hill St', 'Boutique', 8.0);

-- Insertar datos en la tabla habitacion
INSERT INTO habitacion (precio, capacidad, estado, hotel_id) VALUES
(150.00, 2, 'Disponible', 1),
(200.00, 4, 'Ocupada', 1),
(180.00, 3, 'Disponible', 2),
(250.00, 2, 'Disponible', 2),
(120.00, 2, 'Mantenimiento', 3),
(100.00, 2, 'Disponible', 1),
(110.00, 3, 'Disponible', 2),
(120.00, 4, 'Disponible', 3),
(130.00, 2, 'Disponible', 1),
(140.00, 3, 'Disponible', 2),
(150.00, 4, 'Disponible', 3),
(160.00, 2, 'Disponible', 1),
(170.00, 3, 'Disponible', 2),
(180.00, 4, 'Disponible', 3),
(190.00, 2, 'Disponible', 1),
(200.00, 3, 'Disponible', 2),
(210.00, 4, 'Disponible', 3),
(220.00, 2, 'Disponible', 1),
(230.00, 3, 'Disponible', 2),
(240.00, 4, 'Disponible', 3),
(250.00, 2, 'Disponible', 1),
(260.00, 3, 'Disponible', 2),
(270.00, 4, 'Disponible', 3),
(280.00, 2, 'Disponible', 1);

INSERT INTO empleado (nombre, apellido, cargo, fecha_contratacion, hotel_id) VALUES
('Carlos', 'Perez', 'Gerente', '2023-01-15', 1),
('Maria', 'Garcia', 'Recepcionista', '2023-02-20', 2),
('Luis', 'Martinez', 'Conserje', '2023-03-10', 3),
('Ana', 'Lopez', 'Cocinero', '2023-04-05', 1),
('Jorge', 'Gonzalez', 'Botones', '2023-05-12', 2);

-- vista para ver todas las habitaciones disponibles --
create view habitaciones_disponibles_v as
select *  from habitacion 
where estado ="Disponible";

-- vista para ver todos las habitaciones del hotel sunshine --
create view habitaciones_sunshine_v as
select * from habitacion
where hotel_id = 1 ;

-- vista para ver todos las habitaciones del hotel oceanview--
create view habitaciones_oceanview_v as
select * from habitacion
where hotel_id = 2 ;

-- vista para ver todos las habitaciones del hotel mountain --
create view habitaciones_mountain_v as
select * from habitacion
where hotel_id = 3 ;

-- trigger para comprobar que el email no se repita --
DELIMITER //

CREATE TRIGGER before_insert_cliente
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
    DECLARE email_count INT;
    SELECT COUNT(*) INTO email_count FROM cliente WHERE email = NEW.email;
    IF email_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El correo electrónico ya está en uso';
    END IF;
END //

DELIMITER ;

-- trigger para validar que el empleado este asignado a un hotel -- 
DELIMITER //

CREATE TRIGGER validar_empleado_hotel 
BEFORE INSERT ON empleado
FOR EACH ROW
BEGIN
  DECLARE hotel_exists INT;

  SELECT COUNT(*) INTO hotel_exists
  FROM hotel
  WHERE hotel_id = NEW.hotel_id;

  IF hotel_exists = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hotel ID no existe.';
  END IF;
END//

DELIMITER ;

-- trigger para desocupar una habitacion --
DELIMITER //

CREATE TRIGGER update_estado_habitacion
AFTER UPDATE ON reserva
FOR EACH ROW
BEGIN
  IF NEW.fecha_salida = CURDATE() THEN
    UPDATE habitacion 
    SET estado = 'Disponible'
    WHERE habitacion_id = OLD.habitacion_id;
  END IF;
END;//

DELIMITER ;

-- stored procedure para crear e insertar datos ficticios a las tablas --
DELIMITER $$

CREATE PROCEDURE insert_clients()
BEGIN
    DECLARE i INT DEFAULT 2;
    WHILE i <= 100 DO
        INSERT INTO cliente (nombre, apellido, email, telefono) 
        VALUES (CONCAT('Nombre', i), CONCAT('Apellido', i), CONCAT('email', i, '@example.com'), CONCAT('555-', FLOOR(1000 + (RAND() * 9000))));
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL insert_clients();
DROP PROCEDURE insert_clients;



DELIMITER $$
CREATE PROCEDURE insert_reservations()
BEGIN
    DECLARE i INT DEFAULT 2;
    WHILE i <= 100 DO
        INSERT INTO reserva (cliente_id, habitacion_id, fecha_entrada, fecha_salida) 
        VALUES (FLOOR(1 + (RAND() * 100)), FLOOR(1 + (RAND() * 100)), DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 30) DAY), DATE_ADD(CURDATE(), INTERVAL FLOOR(30 + (RAND() * 10)) DAY));
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL insert_reservations();
DROP PROCEDURE insert_reservations;



DELIMITER $$

CREATE PROCEDURE insert_employees()
BEGIN
    DECLARE i INT DEFAULT 2;
    WHILE i <= 100 DO
        INSERT INTO empleado (nombre, apellido, cargo, fecha_contratacion, hotel_id) 
        VALUES (CONCAT('EmpleadoNombre', i), CONCAT('EmpleadoApellido', i), 'Cargo', DATE_ADD(CURDATE(), INTERVAL -FLOOR(RAND() * 1000) DAY), FLOOR(1 + (RAND() * 100)));
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL insert_employees();
DROP PROCEDURE insert_employees;

-- funcion que calcula el precio total de la estadia en una reserva --
DELIMITER $$

CREATE FUNCTION calcular_precio_total_reserva(reserva_id INT) 
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE precio_total DECIMAL(10, 2);
    DECLARE precio_habitacion DECIMAL(10, 2);
    DECLARE noches INT;

    -- Obtener el precio de la habitación y la cantidad de noches de estancia
    SELECT 
        h.precio,
        DATEDIFF(r.fecha_salida, r.fecha_entrada)
    INTO 
        precio_habitacion,
        noches
    FROM 
        reserva r
    JOIN 
        habitacion h ON r.habitacion_id = h.habitacion_id
    WHERE 
        r.reserva_id = reserva_id;

    -- Calcular el precio total de la reserva
    SET precio_total = precio_habitacion * noches;

    RETURN precio_total;
END$$

DELIMITER ;

-- funcion para calcular la ocupacion total de un hotel --

DELIMITER $$

CREATE FUNCTION calcular_ocupacion_total(hotel_id INT, fecha DATE) 
RETURNS INT
BEGIN
    DECLARE ocupacion_total INT;

    -- Contar la cantidad de habitaciones ocupadas en la fecha dada
    SELECT COUNT(*) 
    INTO ocupacion_total
    FROM habitacion h
    JOIN reserva r ON h.habitacion_id = r.habitacion_id
    WHERE h.hotel_id = hotel_id
    AND r.fecha_entrada <= fecha
    AND r.fecha_salida > fecha
    AND h.estado = 'Ocupada';

    RETURN ocupacion_total;
END$$

DELIMITER ;

-- funcion para calcular el número total de reservas realizadas por un cliente específico --

DELIMITER $$

CREATE FUNCTION total_reservas_cliente(cliente_id INT) 
RETURNS INT
BEGIN
    DECLARE total_reservas INT;

    -- Contar el número total de reservas realizadas por el cliente
    SELECT COUNT(*) 
    INTO total_reservas
    FROM reserva
    WHERE cliente_id = cliente_id;

    RETURN total_reservas;
END$$

DELIMITER ;

-- ampliacion de tablas de la base-

CREATE TABLE comentario (
    comentario_id INT AUTO_INCREMENT NOT NULL,
    cliente_id INT NOT NULL,
    hotel_id INT NOT NULL,
    fecha DATE NOT NULL,
    comentario TEXT NOT NULL,
    puntuacion DECIMAL(2,1) NOT NULL,
    PRIMARY KEY(comentario_id),
    FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id),
    FOREIGN KEY (hotel_id) REFERENCES hotel(hotel_id)
);

CREATE TABLE evento (
    evento_id INT AUTO_INCREMENT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    fecha DATE NOT NULL,
    hotel_id INT,
    PRIMARY KEY(evento_id),
    FOREIGN KEY (hotel_id) REFERENCES hotel(hotel_id)
);

CREATE TABLE servicio (
    servicio_id INT AUTO_INCREMENT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    costo DECIMAL,
    PRIMARY KEY(servicio_id)
);

CREATE TABLE hotel_servicio (
    hotel_id INT NOT NULL,
    servicio_id INT NOT NULL,
    PRIMARY KEY(hotel_id, servicio_id),
    FOREIGN KEY (hotel_id) REFERENCES hotel(hotel_id),
    FOREIGN KEY (servicio_id) REFERENCES servicio(servicio_id)
);    