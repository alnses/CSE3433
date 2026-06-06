package com.recruitx.consumers;

public class NotificationConsumer {
    public static void process(String eventType, String jsonPayload) {
        System.out.println("-> [NotificationConsumer] Handling communications channel for event: " + eventType);
        System.out.println("-> [NotificationConsumer] Payload data processed: " + jsonPayload);
    }
}