package com.recruitx.publisher;

import com.recruitx.config.SimulatedRabbitMQ;

public class JobEventPublisher {

    /**
     * Publishes a message to the simulated queue whenever a new job is created.
     */
    public static void publishJobPostedEvent(int jobId, String title, String requirements) {
        // Prevent NullPointerException if requirements or title come in null
        String safeTitle = (title != null) ? title.replace("\"", "\\\"") : "";
        String safeRequirements = (requirements != null) ? requirements.replace("\"", "\\\"") : "";

        // Construct a clean, structured payload string
        String payload = String.format(
            "{\"event\":\"JOB_POSTED\", \"jobId\":%d, \"title\":\"%s\", \"requirements\":\"%s\"}",
            jobId, safeTitle, safeRequirements
        );

        System.out.println("\n[EVENT PRODUCER] Triggering JOB_POSTED event...");
        
        // Ensure SimulatedRabbitMQ has: sendMessage(String exchange, String routingKey, String message)
        SimulatedRabbitMQ.sendMessage("job.exchange", "routing.job.posted", payload);
    }
}