-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 16-09-2025 a las 14:59:04
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `mundorp`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cuentas`
--

CREATE TABLE `cuentas` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(24) NOT NULL,
  `Contra` varchar(120) NOT NULL,
  `Ropa` int(3) NOT NULL,
  `X` float NOT NULL,
  `Y` float NOT NULL,
  `Z` float NOT NULL,
  `Genero` int(11) NOT NULL,
  `Vida` float NOT NULL,
  `Chaleco` float NOT NULL,
  `Muertes` int(11) NOT NULL,
  `Asesinatos` int(11) NOT NULL,
  `Faccion` int(11) NOT NULL,
  `Rango` int(11) NOT NULL,
  `Trabajo` int(11) NOT NULL,
  `Dinero` int(11) NOT NULL,
  `Interior` int(11) NOT NULL,
  `VW` int(11) NOT NULL,
  `Edad` int(11) NOT NULL,
  `Admin` int(11) DEFAULT 0,
  `Coins` int(11) DEFAULT 0,
  `PuntosRol` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `cuentas`
--

INSERT INTO `cuentas` (`ID`, `Nombre`, `Contra`, `Ropa`, `X`, `Y`, `Z`, `Genero`, `Vida`, `Chaleco`, `Muertes`, `Asesinatos`, `Faccion`, `Rango`, `Trabajo`, `Dinero`, `Interior`, `VW`, `Edad`, `Admin`, `Coins`, `PuntosRol`) VALUES
(1, 'demo', 'demo', 21, 0, 0, 0, 0, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL),
(2, 'Ethan_Weasel', '12345', 46, 632.484, -571.93, 16.336, 0, 100, 0, 0, 0, 0, 0, 0, 100000, 0, 0, 0, 0, 0, NULL),
(4, 'Julio_Paredes', 'juliocesar', 46, 1685.91, -2326.14, 13.547, 0, 100, 0, 0, 0, 0, 0, 0, 800, 0, 0, 25, 910, 5, 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facciones`
--

CREATE TABLE `facciones` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(120) NOT NULL,
  `Rango1` varchar(100) NOT NULL,
  `Rango2` varchar(100) NOT NULL,
  `Rango3` varchar(100) NOT NULL,
  `Rango4` varchar(100) NOT NULL,
  `Rango5` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `facciones`
--

INSERT INTO `facciones` (`ID`, `Nombre`, `Rango1`, `Rango2`, `Rango3`, `Rango4`, `Rango5`) VALUES
(1, 'Departamento Policial', 'Cadete', 'Oficial', 'Teniente', 'Coronel', 'General');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `puertas`
--

CREATE TABLE `puertas` (
  `id` int(11) NOT NULL,
  `x_afuera` float DEFAULT NULL,
  `y_afuera` float DEFAULT NULL,
  `z_afuera` float DEFAULT NULL,
  `x_dentro` float DEFAULT NULL,
  `y_dentro` float DEFAULT NULL,
  `z_dentro` float DEFAULT NULL,
  `interior` int(11) DEFAULT NULL,
  `vw` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `puertas`
--

INSERT INTO `puertas` (`id`, `x_afuera`, `y_afuera`, `z_afuera`, `x_dentro`, `y_dentro`, `z_dentro`, `interior`, `vw`) VALUES
(1, 1685.65, -2334.66, 13.5589, -1855.82, 44.3588, 1055.2, 14, 0);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cuentas`
--
ALTER TABLE `cuentas`
  ADD UNIQUE KEY `ID` (`ID`);

--
-- Indices de la tabla `puertas`
--
ALTER TABLE `puertas`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cuentas`
--
ALTER TABLE `cuentas`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `puertas`
--
ALTER TABLE `puertas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
