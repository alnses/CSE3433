package com.recruitx.consumers;

import com.recruitx.config.DBConnection;
import java.sql.*;

// Automatically screens candidate resume text against target keywords [cite: 36, 69]
public class ResumeScreeningConsumer {

    public static void process(String jsonPayload) {
        try {
            Thread.sleep(1500); // Simulate processing delay [cite: 44]
            String[] tokens = jsonPayload.split(",");
            String resumeName = tokens[2].split(":")[1].toLowerCase();

            // Keyword analysis algorithms [cite: 36, 91]
            int fitScore = 40;
            String matches = "Basic Criteria Met";

            if (resumeName.contains("java") || resumeName.contains("software")) {
                fitScore = 85;
                matches = "Java, Software Architecture, SQL";
            }

            try (Connection conn = DBConnection.getConnection(); Statement fetch = conn.createStatement(); ResultSet rs = fetch.executeQuery("SELECT id FROM applications ORDER BY id DESC LIMIT 1")) {

                if (rs.next()) {
                    int appId = rs.getInt("id");
                    String status = (fitScore >= 70) ? "SHORTLISTED" : "REJECTED";

                    try (PreparedStatement insert = conn.prepareStatement(
                            "INSERT INTO screening_results (application_id, fit_score, keyword_matches, status) VALUES (?, ?, ?, ?)")) {
                        insert.setInt(1, appId);
                        insert.setInt(2, fitScore);
                        insert.setString(3, matches);
                        insert.setString(4, status);
                        insert.executeUpdate();
                    }

                    // Cascade update the core state [cite: 37]
                    try (PreparedStatement update = conn.prepareStatement("UPDATE applications SET status = ? WHERE id = ?")) {
                        update.setString(1, status);
                        update.setInt(2, appId);
                        update.executeUpdate();
                    }
                    System.out.println("-> [ResumeScreeningConsumer] Processed Auto-Screening. Candidate Status: " + status);
                }
            }
        } catch (Exception e) {
            System.err.println("ResumeScreeningConsumer Failure: " + e.getMessage());
        }
    }
}
