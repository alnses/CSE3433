-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Jun 19, 2026 at 09:05 AM
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
-- Database: `recruitx_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `analytics_logs`
--

CREATE TABLE `analytics_logs` (
  `id` int(11) NOT NULL,
  `event_payload` text DEFAULT NULL,
  `generated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `applications`
--

CREATE TABLE `applications` (
  `id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `candidate_id` int(11) NOT NULL,
  `status` varchar(50) DEFAULT 'SUBMITTED',
  `resume_path` varchar(500) DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `applications`
--

INSERT INTO `applications` (`id`, `job_id`, `candidate_id`, `status`, `resume_path`, `submitted_at`) VALUES
(6, 1, 8, 'ACCEPTED', 'Resume_aling.pdf', '2026-06-13 14:06:21'),
(7, 2, 8, 'ACCEPTED', 'Resume_aling.pdf', '2026-06-15 04:23:30');

-- --------------------------------------------------------

--
-- Table structure for table `event_logs`
--

CREATE TABLE `event_logs` (
  `id` int(11) NOT NULL,
  `event_type` varchar(100) NOT NULL,
  `payload` text NOT NULL,
  `processed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `event_logs`
--

INSERT INTO `event_logs` (`id`, `event_type`, `payload`, `processed_at`) VALUES
(1, 'ApplicationReceived', 'jobId:1,candidateId:3,resume:Resume_aling.pdf', '2026-06-07 07:57:17'),
(2, 'ApplicationReceived', 'jobId:1,candidateId:3,resume:Resume_aling.pdf', '2026-06-08 19:18:24'),
(3, 'ApplicationStatusUpdated', 'applicationId:1,status:ACCEPTED,recruiterId:1', '2026-06-08 19:28:35'),
(4, 'ApplicationStatusUpdated', 'applicationId:2,status:SHORTLISTED,recruiterId:1', '2026-06-08 19:35:37'),
(5, 'ApplicationStatusUpdated', 'applicationId:2,status:INTERVIEW,recruiterId:1', '2026-06-08 19:50:01'),
(6, 'ApplicationReceived', 'jobId:1,candidateId:6,resume:Resume_afiq.pdf', '2026-06-09 06:45:10'),
(7, 'JobPosted', 'title:lead backed software enginner', '2026-06-09 07:05:29'),
(8, 'ApplicationReceived', 'jobId:1,candidateId:6,resume:Resume_afiq.pdf', '2026-06-09 07:12:01'),
(9, 'ApplicationReceived', 'jobId:1,candidateId:6,resume:Resume_afiq.pdf', '2026-06-09 07:12:31'),
(10, 'ApplicationReceived', 'jobId:1,candidateId:8,resume:Resume_aling.pdf', '2026-06-13 14:06:21'),
(11, 'ApplicationStatusUpdated', 'applicationId:6,status:SHORTLISTED,recruiterId:7', '2026-06-13 14:12:12'),
(12, 'ApplicationStatusUpdated', 'applicationId:6,status:ACCEPTED,recruiterId:7', '2026-06-13 14:12:17'),
(13, 'ApplicationReceived', 'jobId:2,candidateId:8,resume:Resume_aling.pdf', '2026-06-15 04:23:30'),
(14, 'ApplicationReceived', 'jobId:2,candidateId:9,resume:Resume_s75034.pdf', '2026-06-15 04:30:53'),
(15, 'ApplicationReceived', 'jobId:1,candidateId:9,resume:Resume_s75034.pdf', '2026-06-15 04:31:21'),
(16, 'InterviewScheduled', 'applicationId:6,schedule:2026-06-15T13:17,meeting:https:webex.com', '2026-06-15 05:15:26'),
(17, 'ApplicationStatusUpdated', 'applicationId:7,status:ACCEPTED,recruiterId:7', '2026-06-15 05:34:15'),
(18, 'ApplicationStatusUpdated', 'applicationId:8,status:REJECTED,recruiterId:7', '2026-06-15 05:34:16'),
(19, 'ApplicationStatusUpdated', 'applicationId:8,status:ACCEPTED,recruiterId:7', '2026-06-15 05:38:02'),
(20, 'InterviewScheduled', 'applicationId:8,schedule:2026-06-13T13:38,meeting:https:webex.com', '2026-06-15 05:38:14');

-- --------------------------------------------------------

--
-- Table structure for table `interviews`
--

CREATE TABLE `interviews` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `schedule_time` datetime NOT NULL,
  `meeting_link` varchar(500) DEFAULT NULL,
  `feedback` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `interviews`
--

INSERT INTO `interviews` (`id`, `application_id`, `schedule_time`, `meeting_link`, `feedback`) VALUES
(1, 6, '2026-06-15 13:17:00', 'https:webex.com', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `requirements` text DEFAULT NULL,
  `recruiter_id` int(11) DEFAULT NULL,
  `status` varchar(50) DEFAULT 'OPEN'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`id`, `title`, `description`, `requirements`, `recruiter_id`, `status`) VALUES
(1, 'Junior Software Engineer', 'Develop robust scalable cloud web-native solutions using modular event-driven microservices structures.', 'Java, Spring Boot, SQL, Software Architecture baseline concepts.', NULL, 'OPEN'),
(2, 'lead backed software enginner', 'UI/UX ', 'MySQL', NULL, 'OPEN');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `candidate_id` int(11) DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_read` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `candidate_id`, `message`, `created_at`, `is_read`) VALUES
(1, 9, 'Interview scheduled on 2026-06-13T13. Meeting Link: https', '2026-06-15 05:38:14', 0);

-- --------------------------------------------------------

--
-- Table structure for table `screening_results`
--

CREATE TABLE `screening_results` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `fit_score` int(11) NOT NULL,
  `keyword_matches` text DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `screening_results`
--

INSERT INTO `screening_results` (`id`, `application_id`, `fit_score`, `keyword_matches`, `status`) VALUES
(6, 6, 40, 'Basic Criteria Met', 'REJECTED'),
(7, 7, 85, 'Java, Software Architecture, SQL, Web Systems Management', 'SHORTLISTED');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('ADMIN','RECRUITER','CANDIDATE') NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `resume_path` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `profile_completed` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `role`, `full_name`, `email`, `resume_path`, `phone`, `address`, `profile_completed`) VALUES
(7, 'rec_test', 'hrpass', 'RECRUITER', 'Test Recruiter HR', 'hr_test@recruitx.com', NULL, NULL, NULL, 0),
(8, 'aling', 'pass123', 'CANDIDATE', 'NUR ALIN HAYANI BINTI AHMAD SYUKRI', 'alin@umt.edu.my', 'Resume_aling.pdf', '0123456789', 'Kuala Terengganu', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `analytics_logs`
--
ALTER TABLE `analytics_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `applications`
--
ALTER TABLE `applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_candidate_job` (`candidate_id`,`job_id`),
  ADD KEY `job_id` (`job_id`);

--
-- Indexes for table `event_logs`
--
ALTER TABLE `event_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `interviews`
--
ALTER TABLE `interviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `application_id` (`application_id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `recruiter_id` (`recruiter_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `screening_results`
--
ALTER TABLE `screening_results`
  ADD PRIMARY KEY (`id`),
  ADD KEY `application_id` (`application_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `analytics_logs`
--
ALTER TABLE `analytics_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `applications`
--
ALTER TABLE `applications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `event_logs`
--
ALTER TABLE `event_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `interviews`
--
ALTER TABLE `interviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `screening_results`
--
ALTER TABLE `screening_results`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `applications`
--
ALTER TABLE `applications`
  ADD CONSTRAINT `applications_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `applications_ibfk_2` FOREIGN KEY (`candidate_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `interviews`
--
ALTER TABLE `interviews`
  ADD CONSTRAINT `interviews_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `jobs`
--
ALTER TABLE `jobs`
  ADD CONSTRAINT `jobs_ibfk_1` FOREIGN KEY (`recruiter_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `screening_results`
--
ALTER TABLE `screening_results`
  ADD CONSTRAINT `screening_results_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
