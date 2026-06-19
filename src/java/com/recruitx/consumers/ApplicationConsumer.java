package com.recruitx.consumers;

import com.recruitx.config.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class ApplicationConsumer {

    public static void process(String jsonPayload) {
        try {
            // Decouple data fields from JSON string payload format
            String[] tokens = jsonPayload.split(",");
            int jobId = Integer.parseInt(tokens[0].split(":")[1]);
            int candId = Integer.parseInt(tokens[1].split(":")[1]);
            String resume = tokens[2].split(":")[1].replace("\"", "");

            // FIX: Explicitly enforce 'SUBMITTED' initial status mapping during the table row creation state step
            String sql = "INSERT INTO applications (job_id, candidate_id, status, resume_path) VALUES (?, ?, ?, ?)";
            
            try (Connection conn = DBConnection.getConnection(); 
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, jobId);
                stmt.setInt(2, candId);
                stmt.setString(3, "SUBMITTED"); // Safe default initialization path override
                stmt.setString(4, resume);
                stmt.executeUpdate();
                System.out.println("-> [ApplicationConsumer] Saved Application to DB with initial 'SUBMITTED' status.");
            }
        } catch (Exception e) {
            System.err.println("ApplicationConsumer Error: " + e.getMessage());
        }
    }
}