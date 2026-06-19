package com.recruitx.consumers;

import com.recruitx.config.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class AnalyticsConsumer {

    public static void process(String payload) {

        System.out.println(
                "[Analytics Service] Processing Event -> "
                + payload
        );

        try (Connection conn = DBConnection.getConnection()) {

            String sql
                    = "INSERT INTO analytics_logs "
                    + "(event_payload, generated_at) "
                    + "VALUES (?, NOW())";

            try (PreparedStatement stmt
                    = conn.prepareStatement(sql)) {

                stmt.setString(1, payload);
                stmt.executeUpdate();
            }

            System.out.println(
                    "[Analytics Service] Analytics Record Generated");

        } catch (Exception e) {

            System.err.println(
                    "AnalyticsConsumer Error: "
                    + e.getMessage());
        }
    }
}
