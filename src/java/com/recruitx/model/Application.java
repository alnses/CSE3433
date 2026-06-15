package com.recruitx.model;

public class Application {

    private int id;
    private int candidateId;
    private int jobId;
    private String resume;
    private String status;

    public Application() {
    }

    public Application(int id, int candidateId, int jobId,
            String resume, String status) {

        this.id = id;
        this.candidateId = candidateId;
        this.jobId = jobId;
        this.resume = resume;
        this.status = status;
    }

    public int getId() {
        return id;
    }

    public int getCandidateId() {
        return candidateId;
    }

    public int getJobId() {
        return jobId;
    }

    public String getResume() {
        return resume;
    }

    public String getStatus() {
        return status;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setCandidateId(int candidateId) {
        this.candidateId = candidateId;
    }

    public void setJobId(int jobId) {
        this.jobId = jobId;
    }

    public void setResume(String resume) {
        this.resume = resume;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}