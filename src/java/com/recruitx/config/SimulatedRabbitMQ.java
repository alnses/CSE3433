package com.recruitx.config;

import com.recruitx.consumers.AnalyticsConsumer;
import com.recruitx.consumers.ApplicationConsumer;
import com.recruitx.consumers.InterviewConsumer;
import com.recruitx.consumers.NotificationConsumer;
import com.recruitx.consumers.ResumeScreeningConsumer;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class SimulatedRabbitMQ {

    private static final ExecutorService threadPool
            = Executors.newFixedThreadPool(5);

    public static void publishEvent(String eventType,
            String jsonPayload) {

        /*
            Save all events into event_logs
         */
        threadPool.execute(() -> {

            try (java.sql.Connection conn = DBConnection.getConnection(); java.sql.PreparedStatement stmt
                    = conn.prepareStatement(
                            "INSERT INTO event_logs "
                            + "(event_type, payload) "
                            + "VALUES (?, ?)")) {

                stmt.setString(1, eventType);
                stmt.setString(2, jsonPayload);

                stmt.executeUpdate();

            } catch (Exception e) {

                System.err.println(
                        "Event Log Entry Failure: "
                        + e.getMessage());
            }
        });

        /*
            Candidate submits application
         */
        if ("ApplicationReceived".equals(eventType)) {

            threadPool.execute(
                    () -> ApplicationConsumer.process(jsonPayload));

            threadPool.execute(
                    () -> ResumeScreeningConsumer.process(jsonPayload));

            threadPool.execute(
                    () -> AnalyticsConsumer.process(jsonPayload));
        } /*
            Candidate passed screening
         */ else if ("CandidateShortlisted".equals(eventType)) {

            threadPool.execute(
                    () -> InterviewConsumer.process(jsonPayload));

        } /*
            Recruiter posted new job
         */ else if ("JobPosted".equals(eventType)) {

            threadPool.execute(
                    () -> NotificationConsumer.process(
                            eventType,
                            jsonPayload));

        } /*
            Recruiter updated candidate status
         */ else if ("ApplicationStatusUpdated".equals(eventType)) {

            threadPool.execute(
                    () -> NotificationConsumer.process(
                            eventType,
                            jsonPayload));

        } /*
            Interview scheduled
         */ else if ("InterviewScheduled".equals(eventType)) {

            threadPool.execute(
                    () -> NotificationConsumer.process(
                            eventType,
                            jsonPayload));

            threadPool.execute(
                    () -> AnalyticsConsumer.process(jsonPayload));
        }
    }

    public static void sendMessage(String jobexchange,
            String routingjobposted,
            String payload) {

        throw new UnsupportedOperationException(
                "Not supported yet.");
    }
}
