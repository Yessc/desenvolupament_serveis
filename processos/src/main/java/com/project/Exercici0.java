package com.project;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class Exercici0 {
    public static void main(String[] args) {
        ExecutorService executor = Executors.newFixedThreadPool(2);

        Task tasca1 = new Task("Registrar esdeveniments de sistema");
        Task tasca2 = new Task("Comprovar l'estat de la xarxa");

        executor.execute(tasca1);
        executor.execute(tasca2);

        executor.shutdown();

        try {
            if (!executor.awaitTermination(10, TimeUnit.SECONDS)) {
                executor.shutdownNow();
            }
        } catch (InterruptedException e) {
            executor.shutdownNow();
        }
    }
}

class Task implements Runnable {
    private final String nomTasca;

    public Task(String nomTasca) {
        this.nomTasca = nomTasca;
    }

    @Override
    public void run() {
        try {
            System.out.println("[INICI] " + nomTasca);
            Thread.sleep(2000);
            System.out.println("[FINAL] " + nomTasca);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}