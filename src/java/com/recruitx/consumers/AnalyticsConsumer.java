package com.recruitx.consumers;

public class AnalyticsConsumer {

    public static void process(String payload) {

        System.out.println(
                "[Analytics Service] Processing Event -> "
                + payload
        );
    }
}