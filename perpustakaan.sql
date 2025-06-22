-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 22, 2025 at 06:34 PM
-- Server version: 8.4.3
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `perpustakaan`
--

-- --------------------------------------------------------

--
-- Table structure for table `anggotas`
--

CREATE TABLE `anggotas` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `kode_anggota` varchar(20) NOT NULL,
  `nama_lengkap` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `jenis_kelamin` enum('Laki-Laki','Perempuan') NOT NULL,
  `nim` varchar(20) NOT NULL,
  `prodi` varchar(200) NOT NULL,
  `anggkatan` varchar(5) NOT NULL,
  `no_telp` varchar(20) NOT NULL,
  `email` varchar(255) NOT NULL,
  `tanggal_bergabung` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `update_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bukus`
--

CREATE TABLE `bukus` (
  `id_buku` int NOT NULL,
  `kode_buku` varchar(100) DEFAULT NULL,
  `judul` varchar(250) DEFAULT NULL,
  `penerbit_id` int DEFAULT NULL,
  `pengarang_id` int DEFAULT NULL,
  `isbn` varchar(200) DEFAULT NULL,
  `jumlah_halaman` int DEFAULT NULL,
  `tahun_terbit` varchar(4) DEFAULT NULL,
  `sinopsis` text,
  `gambar` varchar(300) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `pengarang` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dendas`
--

CREATE TABLE `dendas` (
  `id_denda` int NOT NULL,
  `pinjaman_id` int DEFAULT NULL,
  `tanggal_kembali` date DEFAULT NULL,
  `jumlah_hari_terlambat` int DEFAULT NULL,
  `total_denda` decimal(10,2) DEFAULT NULL,
  `status_pembayaran` enum('lunas','belum') DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `jumlah_hari` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2019_12_14_000001_create_personal_access_tokens_table', 1),
(2, '2025_06_20_102403_add_email_to_users_table', 2),
(3, '2025_06_20_102754_update_level_column_on_users_table', 3),
(4, '2025_06_20_144917_add_jumlah_hari_to_dendas_table', 3),
(5, '2025_06_20_151451_add_tanggal_kembali_to_pinjamans_table', 3),
(6, '2025_06_20_151953_add_pengarang_to_bukus_table', 3),
(7, '2025_06_20_152919_add_timestamps_to_bukus_table', 4),
(8, '2025_06_22_113151_add_level_to_users_table', 5),
(9, '2025_06_22_115153_add_nama_lengkap_to_users_table', 6);

-- --------------------------------------------------------

--
-- Table structure for table `penerbits`
--

CREATE TABLE `penerbits` (
  `id_penerbit` int NOT NULL,
  `kode_penerbit` varchar(20) DEFAULT NULL,
  `nama_penerbit` varchar(250) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pengarangs`
--

CREATE TABLE `pengarangs` (
  `id_pengarang` int NOT NULL,
  `nama` varchar(250) DEFAULT NULL,
  `email` varchar(300) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pengembalians`
--

CREATE TABLE `pengembalians` (
  `id_pengembalian` int NOT NULL,
  `kode_pengembalian` varchar(100) DEFAULT NULL,
  `tanggal_kembali` date DEFAULT NULL,
  `nama_buku` varchar(240) DEFAULT NULL,
  `denda` int DEFAULT NULL,
  `denda_id` int DEFAULT NULL,
  `pinjaman_id` int DEFAULT NULL,
  `anggota_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pengembalian_details`
--

CREATE TABLE `pengembalian_details` (
  `id_pengembalian_detail` int NOT NULL,
  `pinjaman_detail_id` int DEFAULT NULL,
  `jumlah_buku` int DEFAULT NULL,
  `kondisi_buku` varchar(250) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 3, 'auth_token', '48a5d15b7ac22fa7b6ea9a5184b9815875c15432c6b6e6293e3a565f63b9f143', '[\"*\"]', NULL, NULL, '2025-06-22 04:43:59', '2025-06-22 04:43:59'),
(2, 'App\\Models\\User', 3, 'auth_token', '9a2051dc1854d303a253627858dda1e21bb97c6921c85649e38b4a5606fd6538', '[\"*\"]', NULL, NULL, '2025-06-22 04:54:43', '2025-06-22 04:54:43'),
(3, 'App\\Models\\User', 3, 'auth_token', 'f1784d3935c915f74205181a0778a3e0d82d6f632c7242dbe75936156923bba4', '[\"*\"]', NULL, NULL, '2025-06-22 05:02:56', '2025-06-22 05:02:56');

-- --------------------------------------------------------

--
-- Table structure for table `pinjamans`
--

CREATE TABLE `pinjamans` (
  `id_pinjaman` int NOT NULL,
  `tanggal_pinjaman` date DEFAULT NULL,
  `lama_pinjaman` int DEFAULT NULL,
  `nama_buku` varchar(250) DEFAULT NULL,
  `keterangan` tinytext,
  `status_pinjaman` enum('pending','disetujui','ditolak','selesai') DEFAULT NULL,
  `anggota_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `buku_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tanggal_kembali` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pinjaman_details`
--

CREATE TABLE `pinjaman_details` (
  `id_pinjaman_detail` int NOT NULL,
  `pinjaman_id` int DEFAULT NULL,
  `buku_id` int DEFAULT NULL,
  `jumlah` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` varchar(255) NOT NULL,
  `price` decimal(10,0) NOT NULL,
  `stock` int NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `nama_lengkap` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `level` enum('admin','anggota') NOT NULL DEFAULT 'anggota'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `nama_lengkap`, `username`, `password`, `email`, `created_at`, `updated_at`, `level`) VALUES
(1, '', 'dewilestari', '$2y$10$2Kf.Fb9qX5dvu6zHZe7Y3e0tSGy1OnIDXfsdJDFwkJTKyB63UoXXe', 'dewi@example.com', '2025-06-22 11:24:39', '2025-06-22 11:24:39', 'anggota'),
(2, '', 'AgungGanteng', '$2y$10$mObVENyiqHt1B9qjNbPUleovF.gXi2Xb/CxtqmiSpzjkMjQNYR2KC', 'Agung@gmail.com', '2025-06-22 11:27:53', '2025-06-22 11:27:53', 'anggota'),
(3, '', 'MuhammadGung', '$2y$10$qL0qzdxMMBWJQVtcNEX6uubvBKh2ajoX.CxmcUbWpcONGPPgfZAey', 'Aku@gmail.com', '2025-06-22 11:43:58', '2025-06-22 11:43:58', 'anggota'),
(4, 'Admin Agung', 'admin', 'e3afed0047b08059d0fada10f400c1e5', 'admin@gmail.com', '2025-06-22 18:23:33', '2025-06-22 18:23:33', 'admin');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `anggotas`
--
ALTER TABLE `anggotas`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `bukus`
--
ALTER TABLE `bukus`
  ADD PRIMARY KEY (`id_buku`);

--
-- Indexes for table `dendas`
--
ALTER TABLE `dendas`
  ADD PRIMARY KEY (`id_denda`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `penerbits`
--
ALTER TABLE `penerbits`
  ADD PRIMARY KEY (`id_penerbit`);

--
-- Indexes for table `pengarangs`
--
ALTER TABLE `pengarangs`
  ADD PRIMARY KEY (`id_pengarang`);

--
-- Indexes for table `pengembalians`
--
ALTER TABLE `pengembalians`
  ADD PRIMARY KEY (`id_pengembalian`);

--
-- Indexes for table `pengembalian_details`
--
ALTER TABLE `pengembalian_details`
  ADD PRIMARY KEY (`id_pengembalian_detail`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `pinjamans`
--
ALTER TABLE `pinjamans`
  ADD PRIMARY KEY (`id_pinjaman`);

--
-- Indexes for table `pinjaman_details`
--
ALTER TABLE `pinjaman_details`
  ADD PRIMARY KEY (`id_pinjaman_detail`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `anggotas`
--
ALTER TABLE `anggotas`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bukus`
--
ALTER TABLE `bukus`
  MODIFY `id_buku` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dendas`
--
ALTER TABLE `dendas`
  MODIFY `id_denda` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `penerbits`
--
ALTER TABLE `penerbits`
  MODIFY `id_penerbit` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pengarangs`
--
ALTER TABLE `pengarangs`
  MODIFY `id_pengarang` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pengembalians`
--
ALTER TABLE `pengembalians`
  MODIFY `id_pengembalian` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pengembalian_details`
--
ALTER TABLE `pengembalian_details`
  MODIFY `id_pengembalian_detail` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `pinjamans`
--
ALTER TABLE `pinjamans`
  MODIFY `id_pinjaman` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pinjaman_details`
--
ALTER TABLE `pinjaman_details`
  MODIFY `id_pinjaman_detail` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
