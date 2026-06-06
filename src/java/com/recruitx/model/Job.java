package com.recruitx.model;

public class Job {

    private int id;
    private String title;
    private String description;
    private String requirements;
    private String status;

    public Job(int id, String title, String description, String requirements, String status) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.requirements = requirements;
        this.status = status;
    }

    public int getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getRequirements() {
        return requirements;
    }

    public String getStatus() {
        return status;
    }
}
