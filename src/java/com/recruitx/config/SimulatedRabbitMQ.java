package com.recruitx.config;

import com.recruitx.consumers.ApplicationConsumer;
import com.recruitx.consumers.ResumeScreeningConsumer;
import com.recruitx.consumers.NotificationConsumer;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class SimulatedRabbitMQ {
    private static final ExecutorService threadPool = Executors.newFixedThreadPool(5);

    public static void publishEvent(String eventType, String jsonPayload) {
        threadPool.execute(() -> {
            try (java.sql.Connection conn = DBConnection.getConnection();
                 java.sql.PreparedStatement stmt = conn.prepareStatement("INSERT INTO event_logs (event_type, payload) VALUES (?, ?)")) {
                stmt.setString(1, eventType);
                stmt.setString(2, jsonPayload);
                stmt.executeUpdate();
            } catch (Exception e) {
                System.err.println("Event Log Entry Failure: " + e.getMessage());
            }
        });

        if ("ApplicationReceived".equals(eventType)) {
            threadPool.execute(() -> ApplicationConsumer.process(jsonPayload));
            threadPool.execute(() -> ResumeScreeningConsumer.process(jsonPayload));
            threadPool.execute(() -> NotificationConsumer.process(eventType, jsonPayload));
        } else if ("JobPosted".equals(eventType) || "ApplicationStatusChanged".equals(eventType) || "InterviewRequested".equals(eventType)) {
            threadPool.execute(() -> NotificationConsumer.process(eventType, jsonPayload));
        }
    }
}