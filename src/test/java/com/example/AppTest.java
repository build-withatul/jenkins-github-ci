package com.example;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class AppTest {

    @Test
    void testMessage() {
        assertEquals("Hello from Jenkins CI - Build 2!", App.message());
    }
}
