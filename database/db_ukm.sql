-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 10, 2026 at 07:24 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_ukm`
--

-- --------------------------------------------------------

--
-- Table structure for table `absensi_ukm`
--

CREATE TABLE `absensi_ukm` (
  `id_absensi` int(11) NOT NULL,
  `id_aktivitas` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_ukm` int(11) NOT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `jarak_meter` double DEFAULT NULL,
  `status` enum('Hadir') NOT NULL DEFAULT 'Hadir',
  `waktu_absen` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `absensi_ukm`
--

INSERT INTO `absensi_ukm` (`id_absensi`, `id_aktivitas`, `id_user`, `id_ukm`, `latitude`, `longitude`, `jarak_meter`, `status`, `waktu_absen`) VALUES
(1, 3, 3, 3, -7.7859238902958, 110.36987953483, 7.4381124109529, 'Hadir', '2026-06-03 02:56:44'),
(2, 5, 3, 3, -7.7859238902958, 110.36987953483, 7.4381124109529, 'Hadir', '2026-06-03 02:56:46');

-- --------------------------------------------------------

--
-- Table structure for table `aktivitas_ukm`
--

CREATE TABLE `aktivitas_ukm` (
  `id_aktivitas` int(11) NOT NULL,
  `id_ukm` int(11) NOT NULL,
  `judul` varchar(150) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `tanggal_mulai` datetime NOT NULL,
  `lokasi` varchar(150) DEFAULT 'Sekretariat UKM',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `aktivitas_ukm`
--

INSERT INTO `aktivitas_ukm` (`id_aktivitas`, `id_ukm`, `judul`, `deskripsi`, `tanggal_mulai`, `lokasi`, `created_at`) VALUES
(1, 1, 'Latihan Rutin UKM Musik', 'Latihan rutin dan briefing agenda penampilan.', '2026-06-04 09:38:46', 'Sekretariat UKM Musik', '2026-06-03 02:38:46'),
(2, 2, 'Latihan Futsal Mingguan', 'Latihan fisik, strategi permainan, dan simulasi pertandingan.', '2026-06-05 09:38:46', 'Lapangan Futsal Kampus', '2026-06-03 02:38:46'),
(3, 3, 'Workshop Robotika Dasar', 'Pengenalan sensor, mikrokontroler, dan simulasi robot sederhana.', '2026-06-06 09:38:46', 'Lab Robotika', '2026-06-03 02:38:46'),
(4, 2, 'kicau', 'asdad', '2026-06-03 09:50:00', 'Sekretariat UKM', '2026-06-03 02:50:33'),
(5, 3, 'a', 'ad', '2026-06-03 09:55:00', 'Sekretariat UKM', '2026-06-03 02:56:06');

-- --------------------------------------------------------

--
-- Table structure for table `api_tokens`
--

CREATE TABLE `api_tokens` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `api_tokens`
--

INSERT INTO `api_tokens` (`id`, `user_id`, `token_hash`, `created_at`, `expires_at`) VALUES
(19, 2, '5b8cca2f622447d97e0b29e49063983dbbafa6f21c540804be2f85bc16163941', '2026-06-10 04:05:46', '2026-06-17 04:05:46'),
(20, 3, '559f05e3222cb7b1f84bd08929e07a4ec5575007a93f588d2b3a283726436e29', '2026-06-10 04:06:36', '2026-06-17 04:06:36'),
(21, 2, 'ed08edea233475865c209250942bf74667d5fb1d78f3d02966ab9fa5155794bf', '2026-06-10 04:08:19', '2026-06-17 04:08:19'),
(22, 3, 'da081c37bc312e7db861e73ef3d815ed326ce4b3a7aa88c66b26d37e957cea89', '2026-06-10 04:09:56', '2026-06-17 04:09:56'),
(23, 2, '7ced7e23fc93aff46e0186bb27f2248c472b7a87d629f733d8b6225b44d82584', '2026-06-10 04:58:47', '2026-06-17 04:58:47'),
(24, 3, 'bc707a0b13ae2c724533f759ea820baa3e2c99fdcd496ecb803896c99745f04b', '2026-06-10 05:18:36', '2026-06-17 05:18:36');

-- --------------------------------------------------------

--
-- Table structure for table `favorit_ukm`
--

CREATE TABLE `favorit_ukm` (
  `id` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_ukm` int(11) NOT NULL,
  `tanggal_follow` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifikasi`
--

CREATE TABLE `notifikasi` (
  `id_notif` int(11) NOT NULL,
  `id_ukm` int(11) NOT NULL,
  `judul` varchar(150) NOT NULL,
  `pesan` text NOT NULL,
  `tanggal` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pendaftaran`
--

CREATE TABLE `pendaftaran` (
  `id` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_ukm` int(11) NOT NULL,
  `alasan_bergabung` text NOT NULL,
  `status` enum('Pending','Diterima','Ditolak') DEFAULT 'Pending',
  `tanggal_daftar` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pendaftaran`
--

INSERT INTO `pendaftaran` (`id`, `id_user`, `id_ukm`, `alasan_bergabung`, `status`, `tanggal_daftar`) VALUES
(1, 1, 2, 'Saya ingin mengembangkan skill bermain futsal dan mencari relasi.', 'Diterima', '2026-04-30 04:03:02'),
(2, 2, 3, 'saya ingin mendaftar', 'Diterima', '2026-04-30 09:35:08'),
(4, 3, 3, 'gg', 'Diterima', '2026-06-03 02:55:41');

-- --------------------------------------------------------

--
-- Table structure for table `saran_tpm`
--

CREATE TABLE `saran_tpm` (
  `id_saran` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `isi_saran` text NOT NULL,
  `tanggal_kirim` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `saran_tpm`
--

INSERT INTO `saran_tpm` (`id_saran`, `id_user`, `isi_saran`, `tanggal_kirim`) VALUES
(1, 2, 'hahaahhab', '2026-04-30 09:34:20'),
(2, 2, 'dia terbaik', '2026-04-30 14:15:01'),
(3, 2, 'jssjssjsj', '2026-04-30 14:51:51'),
(4, 3, 'hahaha', '2026-06-10 04:08:05');

-- --------------------------------------------------------

--
-- Table structure for table `ukm`
--

CREATE TABLE `ukm` (
  `id` int(11) NOT NULL,
  `nama_ukm` varchar(100) NOT NULL,
  `kategori` varchar(50) NOT NULL,
  `deskripsi` text NOT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ukm`
--

INSERT INTO `ukm` (`id`, `nama_ukm`, `kategori`, `deskripsi`, `latitude`, `longitude`) VALUES
(1, 'UKM Musik Harmoni', 'Seni', 'Wadah bagi mahasiswa yang memiliki minat di bidang musik modern dan tradisional.', -7.79558, 110.36949),
(2, 'UKM Futsal Kampus', 'Olahraga', 'Membina bakat mahasiswa dalam olahraga futsal dan mengikuti kompetisi nasional.', -7.7828, 110.3755),
(3, 'UKM Robotika', 'Penalaran', 'Tempat riset dan pengembangan teknologi robotika serta IoT.', -7.7859458511786, 110.36994330568);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `foto_profil` varchar(255) DEFAULT NULL,
  `nim` varchar(50) DEFAULT NULL,
  `fakultas` varchar(100) DEFAULT NULL,
  `prodi` varchar(100) DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `role` enum('user','admin') NOT NULL DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `nama`, `email`, `password`, `created_at`, `foto_profil`, `nim`, `fakultas`, `prodi`, `alamat`, `role`) VALUES
(1, 'Budi Mahasiswa', 'budi@kampus.ac.id', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '2026-04-30 04:03:02', NULL, NULL, NULL, NULL, NULL, 'user'),
(2, 'ANDIKA DWI SAKTIAWAN', 'rudi@kampus.ac.id', '$2y$10$SIg6Jt0M4YbhcRGFXnaPB.3e7yVAFuWX1kOVPrfS1qgrTRKNszzn6', '2026-04-30 05:33:32', NULL, '123230033', 'Teknik Industri', 'Teknik informatika', 'Blang Puuk Kulu', 'admin'),
(3, 'aldi', 'aldi@kampus.ac.id', '$2y$10$T6R3zWt21k1Yr.BedCkY.eQmI9Kv0b9Z8whKT8fL0rVE0RhfQDOse', '2026-06-03 00:10:41', 'profil_3_32ac3bf6147a6761.jpg', NULL, NULL, NULL, NULL, 'user');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `absensi_ukm`
--
ALTER TABLE `absensi_ukm`
  ADD PRIMARY KEY (`id_absensi`),
  ADD UNIQUE KEY `uq_absensi_user_aktivitas` (`id_user`,`id_aktivitas`),
  ADD KEY `idx_absensi_aktivitas` (`id_aktivitas`),
  ADD KEY `idx_absensi_ukm_user` (`id_ukm`,`id_user`);

--
-- Indexes for table `aktivitas_ukm`
--
ALTER TABLE `aktivitas_ukm`
  ADD PRIMARY KEY (`id_aktivitas`),
  ADD KEY `idx_aktivitas_ukm` (`id_ukm`);

--
-- Indexes for table `api_tokens`
--
ALTER TABLE `api_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_token_hash` (`token_hash`),
  ADD KEY `idx_api_tokens_user_id` (`user_id`);

--
-- Indexes for table `favorit_ukm`
--
ALTER TABLE `favorit_ukm`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_favorit_user_ukm` (`id_user`,`id_ukm`),
  ADD KEY `fk_favorit_ukm` (`id_ukm`);

--
-- Indexes for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD PRIMARY KEY (`id_notif`),
  ADD KEY `fk_notif_ukm` (`id_ukm`);

--
-- Indexes for table `pendaftaran`
--
ALTER TABLE `pendaftaran`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pendaftaran_user_ukm` (`id_user`,`id_ukm`),
  ADD KEY `id_ukm` (`id_ukm`);

--
-- Indexes for table `saran_tpm`
--
ALTER TABLE `saran_tpm`
  ADD PRIMARY KEY (`id_saran`),
  ADD KEY `idx_saran_user` (`id_user`);

--
-- Indexes for table `ukm`
--
ALTER TABLE `ukm`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `absensi_ukm`
--
ALTER TABLE `absensi_ukm`
  MODIFY `id_absensi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `aktivitas_ukm`
--
ALTER TABLE `aktivitas_ukm`
  MODIFY `id_aktivitas` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `api_tokens`
--
ALTER TABLE `api_tokens`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `favorit_ukm`
--
ALTER TABLE `favorit_ukm`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifikasi`
--
ALTER TABLE `notifikasi`
  MODIFY `id_notif` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pendaftaran`
--
ALTER TABLE `pendaftaran`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `saran_tpm`
--
ALTER TABLE `saran_tpm`
  MODIFY `id_saran` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `ukm`
--
ALTER TABLE `ukm`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `absensi_ukm`
--
ALTER TABLE `absensi_ukm`
  ADD CONSTRAINT `fk_absensi_aktivitas` FOREIGN KEY (`id_aktivitas`) REFERENCES `aktivitas_ukm` (`id_aktivitas`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_absensi_ukm` FOREIGN KEY (`id_ukm`) REFERENCES `ukm` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_absensi_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `aktivitas_ukm`
--
ALTER TABLE `aktivitas_ukm`
  ADD CONSTRAINT `fk_aktivitas_ukm` FOREIGN KEY (`id_ukm`) REFERENCES `ukm` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `api_tokens`
--
ALTER TABLE `api_tokens`
  ADD CONSTRAINT `fk_api_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `favorit_ukm`
--
ALTER TABLE `favorit_ukm`
  ADD CONSTRAINT `fk_favorit_ukm` FOREIGN KEY (`id_ukm`) REFERENCES `ukm` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_favorit_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD CONSTRAINT `fk_notif_ukm` FOREIGN KEY (`id_ukm`) REFERENCES `ukm` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `pendaftaran`
--
ALTER TABLE `pendaftaran`
  ADD CONSTRAINT `pendaftaran_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pendaftaran_ibfk_2` FOREIGN KEY (`id_ukm`) REFERENCES `ukm` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
