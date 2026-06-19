package com.recruitx.consumers;

import com.recruitx.config.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class NotificationConsumer {

    public static void process(String eventType, String jsonPayload) {

        System.out.println("-> [NotificationConsumer] Event: " + eventType);

        try {

            if ("InterviewScheduled".equals(eventType)) {

                String[] tokens = jsonPayload.split(",");

                int applicationId =
                        Integer.parseInt(tokens[0].split(":")[1]);

                String schedule =
                        tokens[1].split(":")[1];

                String meetingLink =
                        tokens[2].split(":")[1];

                /*
                    Find candidate
                 */
                String sql =
                    "SELECT candidate_id "
                  + "FROM applications "
                  + "WHERE id=?";

                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps =
                             conn.prepareStatement(sql)) {

                    ps.setInt(1, applicationId);

                    ResultSet rs = ps.executeQuery();

                    if (rs.next()) {

                        int candidateId =
                                rs.getInt("candidate_id");

                        String message =
                                "Interview scheduled on "
                                + schedule
                                + ". Meeting Link: "
                                + meetingLink;

                        String insert =
                            "INSERT INTO notifications "
                          + "(candidate_id,message) "
                          + "VALUES (?,?)";

                        try (PreparedStatement insertPs =
                                 conn.prepareStatement(insert)) {

                            insertPs.setInt(1, candidateId);
                            insertPs.setString(2, message);

                            insertPs.executeUpdate();
                        }

                        System.out.println(
                                "Notification sent to candidate "
                                + candidateId);
                    }
                }
            }

        } catch (Exception e) {

            System.err.println(
                    "NotificationConsumer Error: "
                    + e.getMessage());
        }
    }
}