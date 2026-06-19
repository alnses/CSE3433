package com.recruitx.consumers;

import com.recruitx.config.DBConnection;
import com.recruitx.config.SimulatedRabbitMQ;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class InterviewConsumer {

    public static void process(String payload) {

        try {

            int applicationId
                    = Integer.parseInt(
                            payload.split(":")[1]);

            String scheduleTime
                    = "2026-06-30 10:00:00";

            String meetingLink
                    = "https://meet.recruitx.com/interview";

            try (Connection conn
                    = DBConnection.getConnection()) {

                PreparedStatement stmt
                        = conn.prepareStatement(
                                "INSERT INTO interviews "
                                + "(application_id,"
                                + "schedule_time,"
                                + "meeting_link) "
                                + "VALUES (?, ?, ?)");

                stmt.setInt(1, applicationId);
                stmt.setString(2, scheduleTime);
                stmt.setString(3, meetingLink);

                stmt.executeUpdate();
            }

            System.out.println(
                    "[InterviewConsumer] "
                    + "Interview Scheduled");

            SimulatedRabbitMQ.publishEvent(
                    "InterviewScheduled",
                    "applicationId:"
                    + applicationId
                    + ",schedule:"
                    + scheduleTime
                    + ",meeting:"
                    + meetingLink);

        } catch (Exception e) {

            System.err.println(
                    "InterviewConsumer Error: "
                    + e.getMessage());
        }
    }
}
