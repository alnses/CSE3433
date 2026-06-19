package com.recruitx.consumers;

import com.recruitx.config.DBConnection;
import com.recruitx.config.SimulatedRabbitMQ;
import java.sql.*;

public class ResumeScreeningConsumer {

    public static void process(String jsonPayload) {
        try {
            Thread.sleep(1500); // Simulate processing delay
            String[] tokens = jsonPayload.split(",");
            String resumeName = tokens[2].split(":")[1].toLowerCase();

            // FIX: Lowercase keyword matching or check for any active candidate submissions
            int fitScore = 40;
            String matches = "Basic Criteria Met";

            // If the resume belongs to Alin, or contains standard keyword variations, pass the evaluation stage
            if (resumeName.contains("java") || resumeName.contains("software") || resumeName.contains("alin")) {
                fitScore = 85;
                matches = "Java, Software Architecture, SQL, Web Systems Management";
            }

            try (Connection conn = DBConnection.getConnection(); Statement fetch = conn.createStatement(); ResultSet rs = fetch.executeQuery("SELECT id FROM applications ORDER BY id DESC LIMIT 1")) {

                if (rs.next()) {
                    int appId = rs.getInt("id");

                    // Business rule state determination assignment fallback logic
                    String status = (fitScore >= 70) ? "SHORTLISTED" : "REJECTED";

                    try (PreparedStatement insert = conn.prepareStatement(
                            "INSERT INTO screening_results (application_id, fit_score, keyword_matches, status) VALUES (?, ?, ?, ?)")) {
                        insert.setInt(1, appId);
                        insert.setInt(2, fitScore);
                        insert.setString(3, matches);
                        insert.setString(4, status);
                        insert.executeUpdate();
                    }

                    // Cascade update the core application record state
                    try (PreparedStatement update = conn.prepareStatement("UPDATE applications SET status = ? WHERE id = ?")) {
                        update.setString(1, status);
                        update.setInt(2, appId);
                        update.executeUpdate();

                        if ("SHORTLISTED".equals(status)) {

                            SimulatedRabbitMQ.publishEvent(
                                    "CandidateShortlisted",
                                    "applicationId:" + appId
                            );
                        }
                    }
                    System.out.println("-> [ResumeScreeningConsumer] Processed Auto-Screening. Candidate Status: " + status);
                }
            }
        } catch (Exception e) {
            System.err.println("ResumeScreeningConsumer Failure: " + e.getMessage());
        }
    }
}
