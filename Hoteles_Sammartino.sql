create schema Hoteles;

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
)
