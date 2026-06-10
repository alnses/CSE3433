package com.recruitx.consumers;

public class InterviewConsumer {

    public static void process(String payload) {

        System.out.println(
                "[Interview Service] Scheduling Interview -> "
                + payload
        );
    }
}