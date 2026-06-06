package com.recruitx.consumers;

import com.recruitx.config.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;

// Saves the core job application into the database [cite: 65, 66]
public class ApplicationConsumer {

    public static void process(String jsonPayload) {
        try {
            // Decouple data fields from JSON string payload format [cite: 85]
            String[] tokens = jsonPayload.split(",");
            int jobId = Integer.parseInt(tokens[0].split(":")[1]);
            int candId = Integer.parseInt(tokens[1].split(":")[1]);
            String resume = tokens[2].split(":")[1].replace("\"", "");

            try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement("INSERT INTO applications (job_id, candidate_id, resume_path) VALUES (?, ?, ?)")) {
                stmt.setInt(1, jobId);
                stmt.setInt(2, candId);
                stmt.setString(3, resume);
                stmt.executeUpdate();
                System.out.println("-> [ApplicationConsumer] Saved Application to DB Successfully.");
            }
        } catch (Exception e) {
            System.err.println("ApplicationConsumer Error: " + e.getMessage());
        }
    }
}
